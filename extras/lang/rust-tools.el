;;; rust-tools.el --- Rust development tools -*- lexical-binding: t; -*-

;;; --- Helper Functions ---

(defun my/rust--workspace-root ()
  "Find the root of the current project/workspace."
  (or (and (fboundp 'project-current)
           (when-let* ((pr (project-current)))
             (if (fboundp 'project-root)
                 (project-root pr)
               (cdr pr))))
      (when (fboundp 'vc-root-dir) (vc-root-dir))
      (locate-dominating-file default-directory ".git")
      default-directory))

(defun my/rust--package-name ()
  "Extract the package name from the nearest Cargo.toml."
  (when-let* ((file (buffer-file-name))
              (dir (locate-dominating-file file "Cargo.toml"))
              (manifest (expand-file-name "Cargo.toml" dir)))
    (with-temp-buffer
      (insert-file-contents manifest)
      (goto-char (point-min))
      (when (re-search-forward "^\\[package\\]" nil t)
        (when (re-search-forward "^name\\s-*=\\s-*\"\\([^\"]+\\)\"" nil t)
          (match-string 1))))))

(defun my/rust--target-flag ()
  "Determine the cargo target flag (--lib, --bin, --test) based on file path."
  (when-let* ((filename (buffer-file-name)))
    (cond
     ((string-match-p "/tests/" filename)
      (format "--test %s" (file-name-base filename)))
     ((string-match-p "/src/bin/" filename)
      (format "--bin %s" (file-name-base filename)))
     ((string-match-p "/src/main\\.rs$" filename)
      "--bin")
     ((string-match-p "/src/" filename)
      "--lib")
     (t ""))))

(defun my/rust--current-function-name ()
  "Find the name of the function enclosing the point."
  (or
   ;; Try Tree-sitter AST (accurate and handles nested code/closures)
   (when (and (fboundp 'treesit-node-at)
              (treesit-language-at (point)))
     (let ((node (treesit-node-at (point))))
       (while (and node (not (string= (treesit-node-type node) "function_item")))
         (setq node (treesit-node-parent node)))
       (when node
         (treesit-node-text (treesit-node-child-by-field-name node "name") t))))
   ;; Fallback: regex search backwards for fn name
   (save-excursion
     (when (re-search-backward "\\bfn\\s-+\\([a-zA-Z0-9_]+\\)" nil t)
       (match-string-no-properties 1)))))

;;; --- Cargo / Workspace Sync ---

(defun my/rust-analyzer-reload-workspace ()
  "Tell rust-analyzer to reload Cargo.toml and workspace metadata."
  (interactive)
  (let ((reloaded nil))
    (dolist (server (if (boundp 'eglot--servers-by-project)
                        (apply #'append (hash-table-values eglot--servers-by-project))
                      (list (eglot-current-server))))
      (when (and server (jsonrpc-running-p server))
        (jsonrpc-async-request server :rust-analyzer/reloadWorkspace nil)
        (setq reloaded t)))
    (if reloaded
        (message "rust-analyzer: workspace reload requested.")
      (message "No active rust-analyzer server found."))))

(defun my/rust-cargo-toml-after-save ()
  "Trigger rust-analyzer reload when saving Cargo.toml or Cargo.lock."
  (when (and (buffer-file-name)
             (member (file-name-nondirectory (buffer-file-name))
                     '("Cargo.toml" "Cargo.lock")))
    (my/rust-analyzer-reload-workspace)))

(add-hook 'after-save-hook #'my/rust-cargo-toml-after-save)

;;; --- Interactive Commands ---

(defun my/rust-run-app ()
  "Run the current Rust application using cargo run.
If in a binary file, runs that specific binary.
If in a library, falls back to running the default workspace binary."
  (interactive)
  (let* ((pkg (my/rust--package-name))
         (target-flag (my/rust--target-flag))
         (is-bin (and target-flag (string-prefix-p "--bin" target-flag))))
    (if is-bin
        ;; Run specific binary if cursor is inside a binary file
        (let* ((pkg-flag (if pkg (format "-p %s" pkg) ""))
               (raw-cmd (format "cargo run %s %s" pkg-flag target-flag))
               (cmd (replace-regexp-in-string " +" " " (string-trim raw-cmd))))
          (compile cmd))
      ;; Run the workspace's default app if we are inside a library crate
      (let ((default-directory (my/rust--workspace-root)))
        (compile "cargo run")))))

(defun my/rust-test-project ()
  "Run cargo test for the entire project/workspace."
  (interactive)
  (let ((default-directory (my/rust--workspace-root)))
    (compile "cargo test")))

(defun my/rust-test-current-function ()
  "Run cargo test specifically for the test function under point with -q, -p, and target flag."
  (interactive)
  (if-let* ((fn-name (my/rust--current-function-name)))
      (let* ((pkg (my/rust--package-name))
             (pkg-flag (if pkg (format "-p %s" pkg) ""))
             (target-flag (my/rust--target-flag))
             (raw-cmd (format "cargo test %s %s %s -- --nocapture"
                              pkg-flag
                              target-flag
                              fn-name))
             ;; Clean up extra spaces if flags are empty
             (cmd (replace-regexp-in-string " +" " " (string-trim raw-cmd))))
        (compile cmd))
    (message "No Rust function found at cursor!")))

(defun my/rust-test-current-file ()
  "Run cargo test using the module/file name as a filter with -q, -p, and target flag."
  (interactive)
  (if-let* ((filename (buffer-file-name)))
      (let* ((basename (file-name-base filename))
             (pkg (my/rust--package-name))
             (pkg-flag (if pkg (format "-p %s" pkg) ""))
             (target-flag (my/rust--target-flag))
             (filter
              (cond
               ((member basename '("main" "lib")) "")
               ((string= basename "mod")
                (let ((parent-dir (file-name-nondirectory
                                   (directory-file-name (file-name-directory filename)))))
                  (if (string= parent-dir "src") "" parent-dir)))
               (t basename)))
             (raw-cmd (format "cargo test %s %s %s -- --nocapture"
                              pkg-flag
                              target-flag
                              filter))
             (cmd (replace-regexp-in-string " +" " " (string-trim raw-cmd))))
        (compile cmd))
    (message "Buffer is not visiting a file!")))

;;; --- Package Configuration ---

(use-package rust-ts-mode
  :ensure nil
  :bind (:map rust-ts-mode-map
              ("C-c C-c C-r" . my/rust-run-app)
              ("C-c C-c C-t" . my/rust-test-project)
              ("C-c C-c C-y" . my/rust-test-current-file)
              ("C-c C-c C-u" . my/rust-test-current-function)
              ("C-c C-c C-s" . my/rust-analyzer-reload-workspace)))

(setq-default eglot-workspace-configuration
              '((:rust-analyzer . (:check (:command "clippy" :extraArgs ["--no-deps"])
                                          :procMacro (:enable t)
                                          :cargo (:buildScripts (:enable t))))))

(provide 'rust-tools)
;;; rust-tools.el ends here
