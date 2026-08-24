;;; vim-like.el  -*- lexical-binding: t -*-

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                   Core
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq fast-but-imprecise-scrolling t)
(setq jit-lock-defer-time 0)
(setq redisplay-skip-fontification-on-input t)

(use-package evil
  :ensure t

  :init
  (setq evil-respect-visual-line-mode t)
  (setq evil-undo-system 'undo-redo)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-keybinding nil)
  (setq evil-esc-delay 0)

  :config
  (evil-mode)

  ;; If you use Magit, start editing in insert state
  (add-hook 'git-commit-setup-hook 'evil-insert-state)

  ;; Configuring initial major mode for some modes
  (evil-set-initial-state 'eat-mode 'emacs)
  (evil-set-initial-state 'vterm-mode 'emacs)
  (evil-set-initial-state 'shell-mode 'emacs)
  (evil-set-initial-state 'eshell-mode 'emacs)
  (evil-set-initial-state 'comint-mode 'emacs))

(global-set-key (kbd "C-c u") #'universal-argument)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                  Visual
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Highlight yanked text
(require 'pulse)
(defun my-pulse-on-yank (beg end &rest _)
  (pulse-momentary-highlight-region beg end 'highlight))

(advice-add 'evil-yank :after #'my-pulse-on-yank)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                Keybindings
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Better key binding for evil
(use-package evil-collection
  :after evil
  :ensure t
  :config
  (evil-collection-init))

;; Diagnostic navigation
(with-eval-after-load 'flymake
  (evil-define-key 'normal flymake-mode-map
    (kbd "]d") #'flymake-goto-next-error
    (kbd "[d") #'flymake-goto-prev-error))

;; Rename and Code Actions (Eglot)
(with-eval-after-load 'eglot
  (evil-define-key 'normal eglot-mode-map
    (kbd "g c n") #'eglot-rename
    (kbd "g c a") #'eglot-code-actions))

(use-package flymake
  :bind (("C-c d" . flymake-show-buffer-diagnostics)
	 ("C-c D" . flymake-show-project-diagnostics)))

(provide 'vim-like)
