;;; my-theme.el -*- lexical-binding: t; -*-

;; Use UTF-8 everywhere
(prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)

;; Font Configuration
(setq-default line-spacing 0.3)
(setq my-font "IntoneMono Nerd Font")
(setq my-font-size 
      (cond ((eq system-type 'darwin) 135) 
            ((eq system-type 'windows-nt) 100) 
            (t 105))) 

(when (find-font (font-spec :family my-font)) 
  (set-face-attribute 'default nil :family my-font :height my-font-size :weight 'normal)
  (set-face-attribute 'fixed-pitch nil :family my-font :height my-font-size :weight 'normal))

;; Icons for dired mode
(use-package nerd-icons
  :ensure t)

(use-package nerd-icons-dired
  :ensure t
  :hook
  (dired-mode . nerd-icons-dired-mode))

;; Emojis and Symbols
(when (fboundp 'set-fontset-font)
  (let ((emoji-fonts '("Apple Color Emoji" "Noto Color Emoji" "Segoe UI Emoji" "Symbola")))
    (dolist (font emoji-fonts)
      (set-fontset-font t 'emoji (font-spec :family font) nil 'append)
      (set-fontset-font t 'symbol (font-spec :family font) nil 'append))))

;; Tab-bar configuration
(use-package tab-bar
  :ensure nil
  :custom
  (tab-bar-show 1)
  (display-time-format "%a %F %T")
  (display-time-interval 1)
  :config
  (add-to-list 'tab-bar-format 'tab-bar-format-align-right 'append)
  (add-to-list 'tab-bar-format 'tab-bar-format-global 'append)
  (display-time-mode 1))

;; Theme Configuration
(use-package ef-themes
  :ensure t)

(use-package solarized-theme
  :ensure t
  :init
  (setq solarized-use-less-bold t))

(load-theme 'ef-autumn)

(defun my-switch-theme (theme)
  "Disable all active themes and load THEME."
  (mapc #'disable-theme custom-enabled-themes)
  (load-theme theme t)
  ;; Ensure tab-bar updates properly when theme changes
  (when (fboundp 'tab-bar-mode) (tab-bar-mode 1))
  (message "Switched to %s" theme))

;; Interactive wrappers for each theme
(defun my-theme-modus-vivendi () 
  "Switch to Modus Vivendi (Dark)." 
  (interactive) (my-switch-theme 'modus-vivendi))

(defun my-theme-modus-operandi () 
  "Switch to Modus Operandi (Light)." 
  (interactive) (my-switch-theme 'modus-operandi))

(defun my-theme-ef-autumn () 
  "Switch to ef-autumn." 
  (interactive) (my-switch-theme 'ef-autumn))

(defun my-theme-solarized-dark () 
  "Switch to Solarized Light." 
  (interactive) (my-switch-theme 'solarized-dark))

(defvar-keymap my-theme-prefix-map
  :doc "Prefix keymap for switching Emacs themes."
  "d" #'my-theme-modus-vivendi
  "l" #'my-theme-modus-operandi
  "a" #'my-theme-ef-autumn
  "s" #'my-theme-solarized-dark)

(keymap-global-set "C-c t" my-theme-prefix-map)

(provide 'my-theme)

