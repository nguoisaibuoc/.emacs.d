;;; rust-tools.el --- Rust development tools -*- lexical-binding: t; -*-

;;; --- Helper Functions ---

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

;;; --- Interactive Commands ---

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

(use-package rust-mode
  :ensure t
  :init
  (setq rust-mode-treesitter-derive t)
  :custom
  (rust-format-on-save nil)
  :bind (:map rust-mode-map
              ("C-c C-c C-y" . my/rust-test-current-file)
              ("C-c C-c C-u" . my/rust-test-current-function)))

(setq-default eglot-workspace-configuration
              '((:rust-analyzer . (:check (:command "clippy" :extraArgs ["--no-deps"])
                                          :procMacro (:enable t)
                                          :cargo (:buildScripts (:enable t))))))

(provide 'rust-tools)
;;; rust-tools.el ends here
