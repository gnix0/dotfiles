; init.el --- Personal Emacs Configuration -*- lexical-binding: t; -*-

;; Author: Gustavo Arantes (gnix)
;; Created: July 2026

(setq user-full-name "Gustavo Oliveira Arantes"
      user-mail-address "dev.gustavoa@gmail.com")

;; Basic UI settings
(setq inhibit-startup-message t)
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(global-hl-line-mode 1)
(blink-cursor-mode 0)
(setq use-file-dialog nil)
(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(add-hook 'text-mode-hook #'visual-line-mode)
(setq ring-bell-function #'ignore)

;; Disable auto-saving and backups
(setq auto-save-default nil)
(setq make-backup-files nil)

;; Disable mouse
(define-key global-map [mouse-1] 'ignore)
(define-key global-map [mouse-2] 'ignore)
(define-key global-map [mouse-3] 'ignore)
(define-key global-map [down-mouse-1] 'ignore)
(define-key global-map [drag-mouse-1] 'ignore)
(define-key global-map [mouse-movement] 'ignore)
(define-key global-map [wheel-up] 'ignore)
(define-key global-map [wheel-down] 'ignore)

;; straight.el as the package manager
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name
        "straight/repos/straight.el/bootstrap.el"
        (or (bound-and-true-p straight-base-dir)
            user-emacs-directory)))
      (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; Tidier specification and better performance
(straight-use-package 'use-package)
(setq straight-use-package-by-default t)
(setq use-package-always-defer t)

;; Remove default scratch message and 'C-h C-a' on start
(setq initial-scratch-message nil)
(defun display-startup-echo-area-message ()
  (message ""))


;; 'y' and 'n' for confirmation on dialogs
(defalias 'yes-or-no-p 'y-or-n-p)

;; Tab config & Smart delimiters
(setq-default indent-tabs-mode nil
              tab-width 2)
(electric-pair-mode 1)

;; Font & Theme
(set-face-attribute 'default nil
                    :font
                    "IosevkaTermSlab Nerd Font Mono"
                    :height 150)

(setq modus-themes-to-toggle '(modus-operandi-tinted modus-vivendi))
(load-theme 'modus-operandi-tinted)
(define-key global-map (kbd "<f5>") #'modus-themes-toggle)

(use-package doom-modeline
  :init
  (doom-modeline-mode 1))

(use-package nerd-icons)

;; Scrolling
(setq scroll-conservatively 101)
(setq scroll-margin 10)
(setq scroll-preserve-screen-position t)

;; Switch windows
(use-package ace-window
  :bind
  (("M-o" . ace-window)))

;; Pin current window so that no other buffer opens it.
;; Useful for compilation buffers and shells.
(defun goa/pin-window ()
  (interactive)
  (set-window-dedicated-p (get-buffer-window (current-buffer)) t))

;; Multiple cursors
(use-package multiple-cursors)

;; Minibuffer and Searching
(use-package vertico
  :init
  (vertico-mode)
  :config
  (setq vertico-cycle t
        vertico-count 15
        vertico-resize nil))

(use-package marginalia
  :init
  (marginalia-mode)
  :bind (:map minibuffer-local-map
              ("M-a" . marginalia-cycle))
  :custom
  (marginalia-max-relative-age 0)
  (marginalia-align 'right))

(use-package orderless
  :config
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil))

(use-package consult
  :bind(
        ("M-s M-g" . consult-grep)
        ("M-s M-f" . consult-find)
        ("M-s M-o" . consult-outline)
        ("M-s M-l" . consult-line)
        ("M-s M-b" . consult-buffer)))

(use-package wgrep
  :bind ( :map grep-mode-map
          ("e" . wgrep-change-to-wgrep-mode)
          ("C-x C-q" . wgrep-change-to-wgrep-mode)
          ("C-c C-c" . wgrep-finish-edit)))

;; Version control
(use-package magit)

(use-package forge
  :after magit)

(use-package diff-hl
  :hook ((prog-mode . diff-hl-mode)
         (text-mode . diff-hl-mode)
         (dired-mode . diff-hl-dired-mode))
  :config
  (diff-hl-flydiff-mode)
  (diff-hl-margin-mode))

;; Built-in persistent state
(global-auto-revert-mode 1)
(recentf-mode 1)
(savehist-mode 1)
(setq recentf-max-saved-items 150)

;; Terminal emulator
(use-package vterm
  :init
  (setq vterm-buffer-name-string "vterm: %s"
        vterm-copy-exclude-prompt t
        vterm-kill-buffer-on-exit t
        vterm-max-scrollback 10000
        vterm-timer-delay 0.01)
  :hook
  (vterm-mode .
              (lambda ()
                (display-line-numbers-mode -1)
                (visual-line-mode -1)
                (hl-line-mode -1)
                (setq-local mode-line-format '(" %b"))
                (setq-local truncate-lines t))))

;; Colours instead of ANSI escapes on compilation
(require 'ansi-color)
(defun goa/colorize-compilation-buffer ()
  (let ((inhibit-read-only t))
    (ansi-color-apply-on-region compilation-filter-start (point))))
(add-hook 'compilation-filter-hook #'goa/colorize-compilation-buffer)

;; Projects
(use-package envrc
  :init
  (envrc-global-mode))

(setq project-list-file "~/.config/emacs/emacs-projects-list"
      project-vc-extra-root-markers
      '("CMakeLists.txt"
        ".clangd" ;; for smaller C/C++ projects
        "GNUmakefile"
        "Makefile"
        "makefile"
        "pom.xml"
        "build.gradle"
        "Cargo.toml"
        "go.mod"
        "mix.exs"))
