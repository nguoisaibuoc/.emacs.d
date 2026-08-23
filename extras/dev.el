;;; dev.el -*- lexical-binding: t -*-

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; CORE DEV SETTINGS & TREE-SITTER
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq-default tab-width 4)
(setq-default indent-tabs-mode nil)

(use-package emacs
  :ensure nil
  :custom
  ;; Tell Emacs to prefer the treesitter mode for these languages.
  ;; Note: Run `M-x treesit-install-language-grammar' before editing.
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
  ;; Auto parenthesis matching
  (prog-mode . electric-pair-mode))

;; Built-in project management
(use-package project
  :ensure nil
  :custom
  (project-mode-line (if (>= emacs-major-version 30) t nil)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; VERSION CONTROL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Magit: slowest Git client to ever exist (but we love it anyway)
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
  (rust-format-on-save t)
  (rust-rustfmt-switches '("--edition" "2024")))

(use-package swift-mode
  :ensure t
  :custom
  (swift-mode:basic-offset 4)
  :hook (swift-mode . (lambda ()
                        ;; Enable Semantic Tokens locally for Swift to get compiler-accurate 
                        ;; highlighting (since we don't have a swift-ts-mode)
                        (setq-local eglot-ignored-server-capabilities '(:inlayHintProvider))
                        ;; Format on save
                        (add-hook 'before-save-hook 
                                  (lambda () 
                                    (eglot-format-buffer)) 
                                  nil t))))

(use-package dart-mode
  :ensure t
  :custom
  (dart-format-on-save t))

(defvar flutter-tools-path
  (cond
   ;; Windows
  ((eq system-type 'windows-nt) 
    "C:/Users/huypk/Projects/flutter-tools")
   ;; Linux
   ((eq system-type 'gnu/linux) 
    (expand-file-name "~/Developer/flutter-tools"))
   ;; macOS
   (t 
    "/Users/huypk/Developer/flutter-tools")))

(add-to-list 'load-path flutter-tools-path)
(require 'flutter-tools)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; LSP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package eglot
  :ensure nil
  :hook
  ((rust-mode python-ts-mode lua-ts-mode dart-mode swift-mode) . eglot-ensure)
  :custom
  (eglot-ignored-server-capabilities '(:inlayHintProvider :semanticTokensProvider))
  (eglot-send-changes-idle-time 0.5)
  (eglot-extend-to-xref t)
  (eglot-events-buffer-config '(:size 0))
  :config
  (fset #'jsonrpc--log-event #'ignore)
  (add-to-list 'eglot-server-programs
               `(swift-mode . ,(if (eq system-type 'darwin)
                                   '("xcrun" "sourcekit-lsp")
                                 '("sourcekit-lsp")))))

;; Set this globally so Eglot catches it immediately when rust-analyzer starts.
(setq-default eglot-workspace-configuration
              '((:rust-analyzer .
				(:check (:command "clippy" :extraArgs ["--no-deps"])
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
             '("^\\*\\(compilation\\|cargo.*\\|rust.*\\|eldoc.*\\)\\*$"
               (display-buffer-reuse-window display-buffer-in-side-window)
               (side . right)
               (window-width . 0.4)))

(provide 'dev)
