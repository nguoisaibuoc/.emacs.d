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
(use-package swift-mode
  :ensure t
  :custom
  (swift-mode:basic-offset 4)
  :hook (swift-mode . (lambda ()
                        (setq-local eglot-ignored-server-capabilities '(:inlayHintProvider)))))

(let ((lang-dir (expand-file-name "extras/lang" user-emacs-directory)))
  (add-to-list 'load-path lang-dir)
  (let ((default-directory lang-dir))
    (normal-top-level-add-subdirs-to-load-path)))

(require 'rust-tools)
(require 'flutter-tools nil t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; LSP & FORMATTING
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package apheleia
  :ensure t
  :config
  (apheleia-global-mode +1))

(use-package eglot
  :ensure nil
  :hook
  ((rust-mode rust-ts-mode python-ts-mode lua-ts-mode dart-mode swift-mode) . eglot-ensure)
  :custom
  (eglot-sync-connect nil)
  (eglot-extend-to-xref t)
  (eglot-send-changes-idle-time 0.5)
  (eglot-report-progress nil)
  (eglot-code-action-indications nil)
  (eglot-events-buffer-config '(:size 0 :format short))
  (eglot-ignored-server-capabilities '(:inlayHintProvider :semanticTokensProvider :documentOnTypeFormattingProvider))
  :config
  (add-to-list 'eglot-server-programs
               `(swift-mode . ,(if (eq system-type 'darwin)
                                   '("xcrun" "sourcekit-lsp")
                                 '("sourcekit-lsp")))))

(use-package eldoc
  :ensure nil
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

(use-package flymake
  :ensure nil
  :custom
  (setq flymake-show-diagnostics-at-end-of-line t)
  :bind (("C-c d" . flymake-show-buffer-diagnostics)
         ("C-c D" . flymake-show-project-diagnostics)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; COMPILATION & WINDOW MANAGEMENT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package compile
  :ensure nil
  :custom
  (compilation-scroll-output t) 
  (compilation-always-kill t)
  (compilation-skip-threshold 2)
  (compilation-environment '("CARGO_TERM_COLOR=always" "CLICOLOR_FORCE=1"))
  :config
  (require 'ansi-color)
  (require 'ansi-osc nil t)
  (add-hook 'compilation-filter-hook #'ansi-color-compilation-filter)
  (when (fboundp 'ansi-osc-compilation-filter)
    (add-hook 'compilation-filter-hook #'ansi-osc-compilation-filter))
  (defun my-compilation-reuse-window (orig-fn &rest args)
    "Force compilation errors to use existing windows instead of splitting."
    (let ((display-buffer-overriding-action
           '((display-buffer-reuse-window
              display-buffer-in-previous-window
              display-buffer-use-some-window))))
      (apply orig-fn args)))
  (advice-add 'compilation-goto-locus :around #'my-compilation-reuse-window))

(add-to-list 'display-buffer-alist
             '("^\\*\\(eldoc.*\\)\\*$"
               (display-buffer-reuse-window display-buffer-in-side-window)
               (side . right)
               (window-width . 0.35)))

(add-to-list 'display-buffer-alist
             '("^\\*\\(compilation\\|cargo.*\\|rust.*\\|flutter.*\\)\\*$"
               (display-buffer-reuse-window display-buffer-in-side-window)
               (side . right)
               (window-width . 0.35)))

(provide 'dev)
