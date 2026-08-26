;;; my-essentials.el -*- lexical-binding: t; -*-

(use-package emacs
  :ensure nil
  :custom
  ;; Basic Interface Defaults
  (use-short-answers t)
  (inhibit-splash-screen t)
  (ring-bell-function 'ignore)
  (initial-major-mode 'fundamental-mode)
  (display-time-default-load-average nil)
  (mode-line-collapse-minor-modes t)
  (sentence-end-double-space nil)

  ;; File & Buffer Behavior
  (create-lockfiles nil)
  (switch-to-buffer-obey-display-actions t)

  ;; Minibuffer & Completion
  (enable-recursive-minibuffers t)
  (completion-cycle-threshold 1)
  (completions-detailed t)
  (tab-always-indent 'complete)
  (completion-styles '(basic initials substring))
  (completion-auto-help 'always)
  (completions-max-height 20)
  (completions-format 'one-column)
  (completions-group t)
  (completion-auto-select 'second-tab)

  ;; Visual Layout & Scrolling
  (line-number-mode t)
  (column-number-mode t)
  (display-line-numbers-width 3)
  (x-underline-at-descent-line nil)
  (show-trailing-whitespace nil)
  (indicate-buffer-boundaries 'left)
  (mouse-wheel-tilt-scroll t)
  (mouse-wheel-flip-direction t)
  (fast-but-imprecise-scrolling t)
  (jit-lock-defer-time 0)
  (redisplay-skip-fontification-on-input t)

  :hook
  ;; Auto-enable modes for specific situations
  (prog-mode . display-line-numbers-mode)
  (text-mode . visual-line-mode)
  (prog-mode . hl-line-mode)
  (text-mode . hl-line-mode)

  :config
  ;; Disable UI clutter
  (menu-bar-mode -1)
  (scroll-bar-mode -1)
  (blink-cursor-mode -1)
  (when (fboundp 'horizontal-scroll-bar-mode)
    (horizontal-scroll-bar-mode -1))

  ;; Enable Core global modes
  (savehist-mode 1)
  (global-auto-revert-mode 1)
  (global-visual-line-mode 1)
  (xterm-mouse-mode 1)
  (cua-mode 1)
  (when (display-graphic-p)
    (context-menu-mode 1))

  ;; Bindings and Keymaps
  (windmove-default-keybindings 'control)
  (keymap-set minibuffer-mode-map "TAB" 'minibuffer-complete))

;; Don't mess with my font size
(global-set-key (kbd "<pinch>") 'ignore)
(global-set-key (kbd "<C-wheel-up>") 'ignore)
(global-set-key (kbd "<C-wheel-down>") 'ignore)

(provide 'my-essentials)
