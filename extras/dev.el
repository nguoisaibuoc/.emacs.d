;;; dev.el -*- lexical-binding: t -*-

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; CORE DEV SETTINGS & TREE-SITTER
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq-default tab-width 4)
(setq-default indent-tabs-mode nil)

(use-package emacs
  :ensure nil
  :custom
  (major-mode-remap-alist
   '((yaml-mode       . yaml-ts-mode)
     (bash-mode       . bash-ts-mode)
     (js2-mode        . js-ts-mode)
     (typescript-mode . typescript-ts-mode)
     (json-mode       . json-ts-mode)
     (css-mode        . css-ts-mode)
     (python-mode     . python-ts-mode)
     (lua-mode        . lua-ts-mode)))
  :hook
  (prog-mode . electric-pair-mode))

;; Built-in project management
(use-package project
  :ensure nil
  :custom
  (project-mode-line (if (>= emacs-major-version 30) t nil)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; VERSION CONTROL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package magit
  :ensure t
  :bind 
  (("C-x g" . magit-status)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; PROGRAMMING LANGUAGES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package markdown-mode
  :ensure t
  :hook (markdown-mode . visual-line-mode))

(use-package yaml-mode :ensure t)
(use-package json-mode :ensure t)
(use-package lua-mode  :ensure t)

(use-package rust-mode
  :ensure t
  :init
  (setq rust-mode-treesitter-derive t)
  :custom
  (rust-format-on-save nil)
  :config
  (defun my/rust-test-current-file ()
    "Run cargo test using the current file name as a filter."
    (interactive)
    (if-let* ((filename (buffer-file-name)))
        (let* ((basename (file-name-base filename))
               (filter (if (member basename '("main" "lib")) "" basename))
               (cmd (string-trim (format "cargo test -- --nocapture %s" filter))))
          (compile cmd))
      (message "Buffer is not visiting a file!")))
  :bind (:map rust-mode-map
              ("C-c C-c C-u" . my/rust-test-current-file)))

;; Ensure test shortcut works in rust-ts-mode as well
(with-eval-after-load 'rust-ts-mode
  (define-key rust-ts-mode-map (kbd "C-c C-c C-u") #'my/rust-test-current-file))

(use-package swift-mode
  :ensure t
  :custom
  (swift-mode:basic-offset 4)
  :hook (swift-mode . (lambda ()
                        (setq-local eglot-ignored-server-capabilities '(:inlayHintProvider)))))

(use-package dart-mode
  :ensure t
  :custom
  (dart-format-on-save t))

(defvar flutter-tools-path
  (cond
   ((eq system-type 'windows-nt) "C:/Users/huypk/Projects/flutter-tools")
   ((eq system-type 'gnu/linux)  (expand-file-name "~/Projects/flutter-tools"))
   (t                            "~/Developer/flutter-tools")))

(add-to-list 'load-path flutter-tools-path)
(require 'flutter-tools nil t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; LSP & FORMATTING
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package eglot
  :ensure nil
  :hook
  ((rust-mode rust-ts-mode python-ts-mode lua-ts-mode dart-mode swift-mode) . eglot-ensure)
  (eglot-managed-mode . (lambda ()
                          (add-hook 'before-save-hook #'eglot-format-buffer nil t)))
  :custom
  (eglot-ignored-server-capabilities '(:inlayHintProvider :semanticTokensProvider))
  (eglot-send-changes-idle-time 0.5)
  (eglot-extend-to-xref t)
  (eglot-events-buffer-config '(:size 0))
  :config
  (add-to-list 'eglot-server-programs
               `(swift-mode . ,(if (eq system-type 'darwin)
                                   '("xcrun" "sourcekit-lsp")
                                 '("sourcekit-lsp")))))

;; Global rust-analyzer workspace config
(setq-default eglot-workspace-configuration
              '((:rust-analyzer . (:check (:command "clippy" :extraArgs ["--no-deps"])
                                   :procMacro (:enable t)
                                   :cargo (:buildScripts (:enable t))))))

(use-package eldoc
  :ensure nil
  :custom
  (eldoc-idle-delay 1)
  :config
  (defun my-eldoc-dynamic-multiline (orig-fn &rest args)
    "Expand Eldoc to multiple lines only if there is a Flymake diagnostic at point."
    (let ((eldoc-echo-area-use-multiline-p
	       (if (and (bound-and-true-p flymake-mode)
		            (flymake-diagnostics (point)))
	           t
	         nil)))
      (apply orig-fn args)))
  (advice-add 'eldoc-display-in-echo-area :around #'my-eldoc-dynamic-multiline))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; COMPILATION & WINDOW MANAGEMENT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package compile
  :ensure nil
  :custom
  (compilation-scroll-output t) 
  (compilation-always-kill t)
  (compilation-skip-threshold 2)
  :config
  (require 'ansi-color)
  (add-hook 'compilation-filter-hook 'ansi-color-compilation-filter))

;; Force dev-related buffers to open in a side window on the right
(add-to-list 'display-buffer-alist
             '("^\\*\\(compilation\\|cargo.*\\|rust.*\\|eldoc.*\\|flutter.*\\)\\*$"
               (display-buffer-reuse-window display-buffer-in-side-window)
               (side . right)
               (window-width . 0.4)))

(provide 'dev)
