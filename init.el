;;; -*- lexical-binding: t; -*-

(when (< emacs-major-version 29)
  (error "Emacs Bedrock only works with Emacs 29 and newer; you have version %s" emacs-major-version))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; CORE & PERFORMANCE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Setup package archives
(use-package package
  :ensure nil
  :custom
  (package-native-compile t)
  :config
  (add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t))

;; Keep `.emacs.d` clean from auto-generated files
(use-package no-littering
  :ensure t
  :demand t
  :config
  (setq auto-save-file-name-transforms
	    `((".*" ,(no-littering-expand-var-file-name "auto-save/") t)))
  (setq backup-directory-alist
	    `((".*" . ,(no-littering-expand-var-file-name "backup/")))))

;; Increase read size for rust-analyzer's massive JSON responses
(setq read-process-output-max (* 5 1024 1024))

;; Smart Garbage Collection (speeds up Emacs significantly)
(use-package gcmh
  :ensure t
  :demand t
  :custom
  (gcmh-idle-delay 1.0)
  (gcmh-high-cons-threshold (* 100 1024 1024))
  :config
  (gcmh-mode 1))

;; Separate custom variables file so it doesn't pollute init.el
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; EMACS DEFAULTS & UI SETTINGS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))

(require 'my-essentials)
(require 'my-dired)
(require 'my-theme)
(require 'my-utils)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; EXTRAS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(add-to-list 'load-path (expand-file-name "extras" user-emacs-directory))

(require 'meow-like)
(require 'base)
(require 'dev)
(require 'organizer)
