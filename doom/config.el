;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!

;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "Gustavo"
      user-mail-address "gustavo@exemplo.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
(setq doom-font (font-spec :family "Terminess Nerd Font" :size 24 :weight 'medium)
      doom-variable-pitch-font (font-spec :family "Terminess Nerd Font" :size 24))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'catppuccin)
(setq catppuccin-flavor 'macchiato) ; or 'frappe 'latte, 'macchiato, or 'mocha
(load-theme 'catppuccin t)
;; set transparency... I don't think this works so TODO
(set-frame-parameter nil 'alpha-background 85)
(add-to-list 'default-frame-alist '(alpha-background . 85))

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

;; source: https://nayak.io/posts/golang-development-doom-emacs/
;; golang formatting set up
;; use gofumpt
(after! lsp-mode
  (setq  lsp-go-use-gofumpt t)
  )
;; automatically organize imports
(add-hook 'go-mode-hook #'lsp-deferred)
;; Make sure you don't have other goimports hooks enabled.
(defun lsp-go-install-save-hooks ()
  (add-hook 'before-save-hook #'lsp-organize-imports t t))
(add-hook 'go-mode-hook #'lsp-go-install-save-hooks)

;; enable all analyzers; not done by default
(after! lsp-mode
  (setq  lsp-go-analyses '((fieldalignment . t)
                           (nilness . t)
                           (shadow . t)
                           (unusedparams . t)
                           (unusedwrite . t)
                           (useany . t)
                           (unusedvariable . t)))
  )

(after! lsp-java
  (setq lsp-java-save-action-organize-imports t))

;; use fish shell by default
(setq explicit-shell-file-name "/run/current-system/sw/bin/fish")

;; use wayland copy (I found this online, hopefully it works :D)
(when (string-equal (getenv "XDG_SESSION_TYPE") "wayland")
  (executable-find "wl-copy")
  (executable-find "wl-paste")
  (defun my-wl-copy (text)
    "Copy with wl-copy if in terminal, otherwise use the original value of `interprogram-cut-function'."
    (if (display-graphic-p)
        (gui-select-text text)
      (let ((wl-copy-process
             (make-process :name "wl-copy"
                           :buffer nil
                           :command '("wl-copy")
                           :connection-type 'pipe)))
        (process-send-string wl-copy-process text)
        (process-send-eof wl-copy-process))))
  (defun my-wl-paste ()
    "Paste with wl-paste if in terminal. otherwise use the original value of `interprogram-paste-function'"
    (if (display-graphic-p)
        (gui-selection-value)
      (shell-command-to-string "wl-paste --no-newline")))
  (setq interprogram-cut-function #'my-wl-copy)
  (setq interprogram-paste-function #'my-wl-paste))

;; remove LSP delays
(after! flycheck (setq flycheck-idle-change-delay 0.1))
(after! lsp-mode
  (setq lsp-idle-delay 0.1)
  (setq lsp-completion-enable-additional-text-edit t)
  (setq lsp-modeline-code-actions-enable t))

;; Better debugging
(use-package! dape)

;; No backup/temp files
(setq make-backup-files nil)
(setq create-lockfiles nil)
