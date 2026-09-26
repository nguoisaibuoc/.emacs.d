;; ...  -*- lexical-binding: t -*-

;; Startup speed: Max out garbage collection threshold.
;; (gcmh in init.el will automatically reset this when startup finishes)
(setq gc-cons-threshold most-positive-fixnum)

;; Annoyance suppression
(setq byte-compile-warnings '(not obsolete))
(setq warning-suppress-log-types '((comp) (bytecomp)))
(setq native-comp-async-report-warnings-errors 'silent)

;; Silence stupid startup message
(setq inhibit-startup-echo-area-message (user-login-name))

;; Frame configuration for smooth resizing
(setq frame-resize-pixelwise t)

;; Default frame configuration: full screen, good-looking title bar on macOS,
;; and PREVENT drawing toolbars/scrollbars to save startup time.
(setq default-frame-alist '((fullscreen . maximized)
                            (undecorated . t)
                            ;; Disable UI elements natively to prevent flashing
                            (tool-bar-lines . 0)
                            (menu-bar-lines . 0)
                            (vertical-scroll-bars . nil)
                            (horizontal-scroll-bars . nil)
                            ;; Setting the face in here prevents flashes of
                            ;; color as the theme gets activated
                            (background-color . "#000000")
                            (foreground-color . "#ffffff")
                            (ns-appearance . dark)
                            (ns-transparent-titlebar . t)))
