;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

(setq user-full-name "Gustavo"
      user-mail-address "dev.gustavoa@gmail.com")

;; Fonts
(setq doom-font (font-spec :family "Terminess Nerd Font" :size 24 :weight 'medium)
      doom-variable-pitch-font (font-spec :family "Terminess Nerd Font" :size 24))

;; Theme
(setq doom-theme 'catppuccin)
(setq catppuccin-flavor 'macchiato)

;; Frames
(set-frame-parameter nil 'alpha-background 100)
(add-to-list 'default-frame-alist '(alpha-background . 100))

;; Editing
(setq display-line-numbers-type 'relative
      org-directory "~/org/"
      make-backup-files nil
      create-lockfiles nil
      ispell-program-name "aspell"
      ispell-dictionary "en_US")

;; Shells
(setq shell-file-name (executable-find "bash")
      vterm-shell (or (executable-find "zsh") shell-file-name)
      explicit-shell-file-name (or (executable-find "zsh") shell-file-name))

;; Emacs server
(require 'server)
(unless (server-running-p)
  (server-start))
(setq server-client-instructions nil)

;; Wayland clipboard
(when (and (string-equal (getenv "XDG_SESSION_TYPE") "wayland")
           (executable-find "wl-copy")
           (executable-find "wl-paste"))
  (defun my-wl-copy (text)
    "Copy TEXT with wl-copy."
    (if (display-graphic-p)
        (gui-select-text text)
      (let ((proc (make-process :name "wl-copy"
                                :buffer nil
                                :command '("wl-copy")
                                :connection-type 'pipe)))
        (process-send-string proc text)
        (process-send-eof proc))))
  (defun my-wl-paste ()
    "Paste with wl-paste."
    (if (display-graphic-p)
        (gui-selection-value)
      (shell-command-to-string "wl-paste --no-newline")))
  (setq interprogram-cut-function #'my-wl-copy
        interprogram-paste-function #'my-wl-paste))

;; Shared LSP
(after! lsp-mode
  (setq lsp-idle-delay 0.1
        lsp-completion-enable-additional-text-edit t
        lsp-modeline-code-actions-enable t))

;; Go
(after! lsp-mode
  (setq lsp-go-use-gofumpt t
        lsp-go-analyses '((fieldalignment . t)
                          (nilness . t)
                          (shadow . t)
                          (unusedparams . t)
                          (unusedwrite . t)
                          (useany . t)
                          (unusedvariable . t))))

(after! go-mode
  (add-hook 'before-save-hook #'lsp-organize-imports nil t))

(add-hook 'go-mode-hook #'lsp-deferred)

;; Java
(after! lsp-java
  (setq lsp-java-save-action-organize-imports t))

;; Diagnostics
(after! flycheck
  (setq flycheck-idle-change-delay 0.1))

;; Debugging
(use-package! dape)
