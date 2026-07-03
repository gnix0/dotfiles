;;; init.el --- Personal Emacs Configuration -*- lexical-binding: t; -*-

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

;; Disable auto-saving and backups
(setq auto-save-default nil)
(setq make-backup-files nil)

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
(use-package emacs
  :init
  (setq initial-scratch-message nil)
  (defun display-startup-echo-area-message ()
    (message "")))

;; 'y' and 'n' for confirmation on dialogs
(use-package emacs
  :init
  (defalias 'yes-or-no-p 'y-or-n-p))

;; UTF-8
(use-package emacs
  :init
  (set-charset-priority 'unicode)
  (setq locale-coding-system 'utf-8
	coding-system-for-read 'utf-8
	coding-system-for-write 'utf-8)
  (set-terminal-coding-system 'utf-8)
  (set-keyboard-coding-system 'utf-8)
  (set-selection-coding-system 'utf-8)
  (prefer-coding-system 'utf-8)
  (setq default-process-coding-system '(utf-8-unix . utf-8-unix)))

;; Tab config
(use-package emacs
  :init
  (setq-default indent-tabs-mode nil)
  (setq-default tab-width 2))

;; Evil Mode & Relative line numbers (because vim motions are just the best)
;; (use-package evil
;;  :demand ; No lazy loading
;;  :config
;;  (evil-mode 1))

(use-package emacs
  :init
  (defun goa/enable-line-numbers ()
    "Enable relative line numbers"
    (interactive)
    (display-line-numbers-mode 1)
    (setq display-line-numbers 'relative))
  (add-hook 'prog-mode-hook #'goa/enable-line-numbers))

;; Font & Theme
(use-package emacs
  :init
  (set-face-attribute 'default nil
		      :font "Lucida Sans Typewriter"
		      :height 140))

(use-package doom-themes
  :demand
  :config
  (load-theme 'doom-solarized-dark t))

(use-package doom-modeline
  :init
  (doom-modeline-mode 1))

(use-package nerd-icons)

;; Navigate between visible buffers
(defun other-window-backward (&optional n)
  (interactive "p")
  (if n
      (other-window (- n))
    (other-frame -1)))
(global-set-key "\C-x\C-n" 'other-window)
(global-set-key "\C-x\C-p" 'other-window-backward)

;; Pin current window so that no other buffer opens it.
;; Useful for compilation buffers and shells.
(defun goa/pin-window ()
  (interactive)
  (set-window-dedicated-p (get-buffer-window (current-buffer)) t))

;; Revert
(global-set-key "\C-z"
                (lambda ()
                  (interactive)
                  (revert-buffer :ignore-auto :noconfirm)))

;; Multiple cursors
(use-package multiple-cursors)

;; Search engine & Completion
(use-package vertico
  :init
  (vertico-mode))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides
   '((file (styles basic partial-completion)))))

(use-package corfu
  :init
  (global-corfu-mode))

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

;; Clipboard & Terminal emulator
(use-package xclip
  :init
  (xclip-mode 1))

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
                (corfu-mode -1)
                (display-line-numbers-mode -1)
                (visual-line-mode -1)
                (setq-local global-hl-line-mode nil)
                (setq-local mode-line-format '(" %b"))
                (setq-local truncate-lines t))))

;; Colours instead of ANSI escapes on compilation
(require 'ansi-color)
(defun goa/colorize-compilation-buffer ()
  (let ((inhibit-read-only t))
    (ansi-color-apply-on-region compilation-filter-start (point))))
(add-hook 'compilation-filter-hook #'goa/colorize-compilation-buffer)
