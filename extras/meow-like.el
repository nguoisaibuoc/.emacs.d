;;; meow-like.el --- meow-mode with QWERTY layout  -*- lexical-binding: t; -*-

;;; Commentary:

;;; Code:

(global-set-key (kbd "C-c u") #'universal-argument)

(defun my-meow-setup ()
  "Standard QWERTY setup for Meow with custom tweaks."
  (setq meow-cheatsheet-layout meow-cheatsheet-layout-qwerty)
  
  (meow-motion-overwrite-define-key
   '("j" . meow-next)
   '("k" . meow-prev)
   '("<escape>" . ignore))

  ;; LEADER KEYS (Triggered by pressing SPC in normal/motion state)
  (meow-leader-define-key
   ;; To execute M-x, press SPC SPC
   '("SPC" . execute-extended-command)
   '("u" . meow-universal-argument)
   
   ;; Window management
   '("w h" . windmove-left)
   '("w j" . windmove-down)
   '("w k" . windmove-up)
   '("w l" . windmove-right)
   '("w w" . other-window)
   '("w c" . delete-window)
   '("w o" . delete-other-windows)
   '("w v" . split-window-right)
   '("w s" . split-window-below)
   
   ;; Custom: Diagnostic navigation (Flymake) -> Press SPC ] d
   '("] d" . flymake-goto-next-error)
   '("[ d" . flymake-goto-prev-error)
   
   ;; Custom: Eglot Code Actions & Rename -> Press SPC g c n
   '("g c n" . eglot-rename)
   '("g c a" . eglot-code-actions))

  ;; NORMAL STATE KEYS
  (meow-normal-define-key
   '("0" . meow-expand-0)
   '("9" . meow-expand-9)
   '("8" . meow-expand-8)
   '("7" . meow-expand-7)
   '("6" . meow-expand-6)
   '("5" . meow-expand-5)
   '("4" . meow-expand-4)
   '("3" . meow-expand-3)
   '("2" . meow-expand-2)
   '("1" . meow-expand-1)
   '("-" . negative-argument)
   '(";" . meow-reverse)
   '("," . meow-inner-of-thing)
   '("." . meow-bounds-of-thing)
   '("[" . meow-beginning-of-thing)
   '("]" . meow-end-of-thing)
   '("a" . meow-append)
   '("A" . meow-open-below)
   '("b" . meow-back-word)
   '("B" . meow-back-symbol)
   '("c" . meow-change)
   '("d" . meow-kill)
   '("D" . meow-backward-delete)
   '("e" . meow-next-word)
   '("E" . meow-next-symbol)
   '("f" . meow-find)
   '("g" . meow-cancel-selection)
   '("G" . meow-grab)
   '("h" . meow-left)
   '("H" . meow-left-expand)
   '("i" . meow-insert)
   '("I" . meow-open-above)
   '("j" . meow-next)
   '("J" . meow-next-expand)
   '("k" . meow-prev)
   '("K" . meow-prev-expand)
   '("l" . meow-right)
   '("L" . meow-right-expand)
   '("m" . meow-join)
   '("n" . meow-search)
   '("o" . meow-block)
   '("O" . meow-to-block)
   '("p" . meow-yank)
   '("q" . meow-quit)
   '("Q" . meow-goto-line)
   '("r" . meow-replace)
   '("R" . meow-swap-grab)
   '("s" . meow-kill-append)
   '("t" . meow-till)
   '("u" . meow-undo)
   '("U" . meow-undo-redo)
   '("v" . meow-visit)
   '("w" . meow-mark-word)
   '("W" . meow-mark-symbol)
   '("x" . meow-line)
   '("X" . meow-goto-line)
   '("y" . meow-save)
   '("Y" . meow-sync-grab)
   '("z" . meow-pop-selection)
   '("'" . repeat)
   '("<escape>" . ignore)
   
   ;; Custom: Vim-like scrolling
   '("C-u" . scroll-down-command)
   '("C-d" . scroll-up-command)))

(use-package meow
  :ensure t
  :config
  (add-to-list 'meow-mode-state-list '(eat-mode . insert))
  (add-to-list 'meow-mode-state-list '(vterm-mode . insert))
  (add-to-list 'meow-mode-state-list '(shell-mode . insert))
  (add-to-list 'meow-mode-state-list '(eshell-mode . insert))
  (add-to-list 'meow-mode-state-list '(comint-mode . insert))
  (add-to-list 'meow-mode-state-list '(git-commit-mode . insert))
  (my-meow-setup)
  (meow-global-mode 1)
  :custom
  (meow-use-clipboard t))

(require 'pulse)
(defun my-pulse-on-yank (&rest _)
  "Pulse highlight the region before saving it to the kill ring."
  (when (use-region-p)
    (pulse-momentary-highlight-region (region-beginning) (region-end) 'highlight)))

(advice-add 'meow-save :before #'my-pulse-on-yank)

(provide 'meow-like)
;;; meow-like.el ends here
