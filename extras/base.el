;;; base.el -*- lexical-binding: t -*-

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; MINIBUFFER COMPLETION (Vertico, Marginalia, Orderless)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Vertico: better vertical completion for minibuffer commands
(use-package vertico
  :ensure t
  :init
  (vertico-mode 1))

;; Makes navigating directories in Vertico much faster
(use-package vertico-directory
  :ensure nil
  :after vertico
  :bind (:map vertico-map
              ("M-DEL" . vertico-directory-delete-word))
  :hook (rfn-eshadow-update-overlay . vertico-directory-tidy))

;; Marginalia: adds rich annotations (descriptions, keybindings) to minibuffer
(use-package marginalia
  :ensure t
  :init
  (marginalia-mode 1))

;; Orderless: fuzzy and space-separated matching for completions
(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles partial-completion))))
  (completion-pcm-leading-wildcard t))

;; Persist history over Emacs restarts. Vertico sorts by history position!
(use-package savehist
  :ensure nil
  :init
  (savehist-mode 1))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; IN-BUFFER AUTOCOMPLETION (Corfu)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package corfu
  :ensure t
  :custom
  (corfu-cycle t)
  (corfu-quit-at-boundary nil)
  (corfu-quit-no-match t)
  (corfu-preview-current nil)
  (corfu-preselect 'prompt)
  :init
  (global-corfu-mode)
  (corfu-history-mode 1)
  (corfu-popupinfo-mode 1))

(use-package emacs
  :ensure nil
  :custom
  (tab-always-indent 'complete)
  (text-mode-ispell-word-completion nil)
 (read-extended-command-predicate #'command-completion-default-include-p))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; POWER-UPS: SEARCH & ACTIONS (Consult, Embark, Wgrep)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Consult: Enhanced search and navigation commands
(use-package consult
  :ensure t
  :custom
  (consult-narrow-key "<") ; Narrowing restricts results to certain groups
  :bind
  (("C-x b" . consult-buffer)        ; orig. switch-to-buffer
   ("M-y"   . consult-yank-pop)      ; orig. yank-pop
   ("M-s r" . consult-ripgrep)
   ("M-s l" . consult-line)          
   ("M-s s" . consult-line)          
   ("M-s L" . consult-line-multi)    
   ("M-s o" . consult-outline)
   :map isearch-mode-map
   ("M-e"   . consult-isearch-history) 
   ("M-s e" . consult-isearch-history) 
   ("M-s l" . consult-line)            
   ("M-s L" . consult-line-multi)))

;; Embark: Context-dependent menu (like a super right-click)
(use-package embark
  :ensure t
  :demand t
  :bind
  (("C-c e" . embark-act))
  :config
  ;; Integration with Avy for jumping and instantly acting on targets
  ;; `with-eval-after-load` ensures this code waits until Avy is fully loaded!
  (with-eval-after-load 'avy
    (defun bedrock/avy-action-embark (pt)
      (unwind-protect
          (save-excursion
            (goto-char pt)
            (embark-act))
        (select-window
         (cdr (ring-ref avy-ring 0))))
      t)
    (setf (alist-get ?. avy-dispatch-alist) 'bedrock/avy-action-embark)))

;; Ties Embark and Consult together
(use-package embark-consult
  :ensure t
  :after (embark consult)
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

;; Edit grep buffers directly and save the files en masse
(use-package wgrep
  :ensure t
  :custom
  (wgrep-auto-save-buffer t))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; MOTION AIDS (Avy)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Jump anywhere on screen instantly
(use-package avy
  :ensure t
  :demand t
  :bind 
  (("C-c j" . avy-goto-line)
   ("s-j"   . avy-goto-char-timer)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; TERMINALS & SHELLS (Eshell, Eat)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package eshell
  :ensure nil
  :hook (eshell-mode . bedrock/setup-eshell)
  :init
  (defun bedrock/setup-eshell ()
    ;; Work-around to make C-r search history inside Eshell
    (keymap-set eshell-mode-map "C-r" 'consult-history)))

;; Eat: Emulate A Terminal (Fast terminal emulator inside Emacs)
(use-package eat
  :ensure t
  :custom
  (eat-term-name "xterm")
  :config
  (eat-eshell-mode)                  ; use Eat to handle term codes in Eshell
  (eat-eshell-visual-command-mode))  ; handle interactive commands (like less, htop)

(provide 'base)
