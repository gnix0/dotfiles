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

;; Column bar
(setq-default fill-column 100)
(add-hook 'prog-mode-hook #'display-fill-column-indicator-mode)

;; Relative line numbers
(defun gnix/relative-line-numbers ()
  "Enable relative line numbers."
  (interactive)
  (display-line-numbers-mode)
  (setq display-line-numbers 'relative))
(add-hook 'prog-mode-hook #'gnix/relative-line-numbers)

;; Decrease echo time
(setq echo-keystrokes 0.01)

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

;; Zaps up to char, not the char itself
(global-set-key (kbd "M-z") 'zap-up-to-char)

;; Tab config & Smart delimiters
(setq-default indent-tabs-mode nil)

;; Font & Theme
(set-face-attribute 'default nil
                    :font
                    "IosevkaTermSlab Nerd Font Mono"
                    :height 150)

(use-package solarized-theme
  :demand
  :config
  (defvar gnix-themes-to-toggle
    '(solarized-dark-high-contrast solarized-light-high-contrast))

  (load-theme (car gnix-themes-to-toggle) t)

  (defun gnix/toggle-theme ()
    (interactive)
    (let* ((one (car gnix-themes-to-toggle))
           (two (cadr gnix-themes-to-toggle))
           (current (car custom-enabled-themes))
           (next (if (eq current one) two one)))
      (mapc #'disable-theme custom-enabled-themes)
      (load-theme next t)))

  (global-set-key (kbd "<f1>") #'gnix/toggle-theme))

(use-package doom-modeline
  :init (doom-modeline-mode 1))

(use-package nerd-icons)

;; Scrolling
(setq scroll-conservatively 101)
(setq scroll-margin 10)
(setq scroll-preserve-screen-position t)

;; Multiple cursors
(use-package multiple-cursors)
(global-set-key (kbd "C-S-c C-S-c") 'mc/edit-lines)
(global-set-key (kbd "C->") 'mc/mark-next-like-this)
(global-set-key (kbd "C-<") 'mc/mark-previous-like-this)
(global-set-key (kbd "C-c C-<") 'mc/mark-all-like-this)

;; Minibuffer and Searching
(use-package vertico
  :init
  (vertico-mode)
  :config
  (setq vertico-cycle t
        vertico-count 15
        vertico-resize nil
        read-file-name-completion-ignore-case t
        read-buffer-completion-ignore-case t
        completion-ignore-case t))

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
        ("M-s M-r" . consult-ripgrep)
        ("M-s M-f" . consult-find)
        ("M-s M-o" . consult-outline)
        ("M-s M-l" . consult-line)
        ("M-s M-b" . consult-buffer)))

(use-package wgrep
  :bind ( :map grep-mode-map
          ("e" . wgrep-change-to-wgrep-mode)
          ("C-x C-q" . wgrep-change-to-wgrep-mode)
          ("C-c C-c" . wgrep-finish-edit)))

;; (Better) Unique buffer naming
(setq uniquify-buffer-name-style 'forward)

;; Version control
(use-package magit)

(setq git-commit-summary-max-length 50)

(add-hook 'git-commit-mode-hook
          (lambda ()
            (setq-local fill-column 72)))

(use-package diff-hl
  :hook ((prog-mode . diff-hl-mode)
         (text-mode . diff-hl-mode)
         (dired-mode . diff-hl-dired-mode)
         (magit-post-refresh . diff-hl-magit-post-refresh))
  :config
  (diff-hl-flydiff-mode)
  (diff-hl-margin-mode))

(use-package ediff
  :straight nil
  :defer t
  :config
  (setq ediff-window-setup-function #'ediff-setup-windows-plain)
  (setq ediff-split-window-function #'split-window-horizontally))

(use-package smerge-mode
  :straight nil
  :bind ("C-c e" . smerge-ediff)) ;; Visual conflict resolution; use M-x smerge-mode for simple cases

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

;; Development

;; Pin current window so that no other buffer opens it.
;; Useful for compilation buffers and shells.
(defun gnix/pin-window ()
  (interactive)
  (set-window-dedicated-p (get-buffer-window (current-buffer)) t))

;; Don't ask before killing the current compilation and scroll as buffer grows
(setq compilation-always-kill t
      compilation-scroll-output t)

;; Compilation (not project-wise like project.el does)
(global-set-key (kbd "C-x c") #'compile)
(global-set-key (kbd "C-x C") #'recompile)

;; Colours instead of ANSI escapes on compilation
(require 'ansi-color)
(defun gnix/colorize-compilation-buffer ()
  (let ((inhibit-read-only t))
    (ansi-color-apply-on-region compilation-filter-start (point))))
(add-hook 'compilation-filter-hook #'gnix/colorize-compilation-buffer)

;; Languages
(use-package eglot
  :straight nil
  :hook ((java-mode . eglot-ensure)
         (c-mode . eglot-ensure)
         (c++-mode . eglot-ensure)
         (rust-mode . eglot-ensure)
         (go-mode . eglot-ensure)
         (elixir-mode . eglot-ensure))
  :config
  (setq eglot-code-action-indications nil)
  (setq eglot-code-action-indicator nil)
  (let ((java-debug-jar
         (car
          (file-expand-wildcards
           "~/.config/emacs/debug-adapters/java-debug/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-*.jar"))))
    (add-to-list
     'eglot-server-programs
     `((java-mode) .
       ("jdtls"
        :initializationOptions
        (:bundles [,java-debug-jar]))))))

(use-package eglot-java
  :after eglot
  :hook ((java-mode . eglot-java-mode)))

(use-package elixir-mode)
(use-package go-mode)
(use-package rust-mode)

;; More relevant file-types
(use-package markdown-mode
  :config
  (setq markdown-fontify-code-blocks-natively t))

(use-package yaml-mode)

(add-to-list 'auto-mode-alist '("CODEOWNERS\\'" . conf-mode))
(add-to-list 'auto-mode-alist '("\\.env\\'" . conf-mode))

;; Code Completion
(use-package corfu
  :init
  (global-corfu-mode)
  :custom
  (corfu-auto nil)
  (corfu-cycle t)
  (corfu-preview-current nil)
  (corfu-on-exact-match nil)
  :bind
  (:map corfu-map
        ("C-y" . corfu-insert)
        ("RET" . newline)
        ("<return>" . newline)))

(setq eldoc-echo-area-use-multiline-p nil)
(setq eldoc-echo-area-prefer-doc-buffer t)

;; Debugger
(use-package dape
  :bind (("<f5>" . dape)
         ("<f6>" . dape-continue)
         ("<f9>" . dape-breakpoint-toggle)
         ("S-<f9>" . dape-breakpoint-remove-all)
         ("<f10>" . dape-next)
         ("<f11>" . dape-step-in)
         ("S-<f11>" . dape-step-out))
  :custom
  (dape-buffer-window-arrangement 'right)
  :config
  ;; Save all modified buffers before debugging
  (add-hook 'dape-start-hook
            (lambda ()
              (save-some-buffers t t))))

(use-package repeat
  :config
  (repeat-mode))

;; Org-mode and Email
(use-package org
  :straight nil
  :hook
  (org-mode . org-indent-mode)
  (org-mode . visual-line-mode)
  :bind
  (("C-c l" . org-store-link)
   ("C-c a" . org-agenda)
   ("C-c c" . org-capture))
  :config
  (setq org-agenda-files '("~/org")
        org-log-done 'time
        org-return-follows-link t
        org-hide-emphasis-markers t)

  (defun gnix/org-capture-schedule ()
    (when (member (org-capture-get :key) '("t" "c"))
      (let ((date (read-string "When (empty = unscheduled): ")))
        (unless (string-empty-p date)
          (org-schedule nil date)))))

  (add-hook 'org-capture-prepare-finalize-hook #'gnix/org-capture-schedule)
    
  (setq org-capture-templates
        '(("w" "Work Log Entry"
           entry (file+datetree "~/org/work-log.org")
           "* %?"
           :empty-lines 0)

          ("n" "Note"
           entry (file+headline "~/org/notes.org" "Random Notes")
           "** %?"
           :empty-lines 0)

          ("t" "To-do"
           entry (file+headline "~/org/todos.org" "Tasks")
           "* TODO [#B] %?\n:Created: %T\n "
           :empty-lines 0)

          ("c" "Code To-Do"
           entry (file+headline "~/org/todos.org" "Code Related Tasks")
           "* TODO [#B] %?\n:Created: %T\n%i\n%a\nProposed Solution: "
           :empty-lines 0)))

  ;; TODO states
  (setq org-todo-keywords
        '((sequence "TODO(t)" "PLANNING(p)" "IN-PROGRESS(i@/!)" "VERIFYING(v!)" "BLOCKED(b@)"  "|" "DONE(d!)" "OBE(o@!)" "WONT-DO(w@/!)" )))

  ;; TODO colors
  (setq org-todo-keyword-faces
        '(("TODO" . (:foreground "GoldenRod" :weight bold))
          ("PLANNING" . (:foreground "DeepPink" :weight bold))
          ("IN-PROGRESS" . (:foreground "Cyan" :weight bold))
          ("VERIFYING" . (:foreground "DarkOrange" :weight bold))
          ("BLOCKED" . (:foreground "Red" :weight bold))
          ("DONE" . (:foreground "LimeGreen" :weight bold))
          ("OBE" . (:foreground "LimeGreen" :weight bold))
          ("WONT-DO" . (:foreground "LimeGreen" :weight bold))))

  (setq org-tag-alist
        '(;; Work type (choose one)
          (:startgroup)
          ("@bug"     . ?b)
          ("@feature" . ?f)
          ("@chore"   . ?c)
          ("@research". ?r)
          ("@refactor". ?R)
          (:endgroup)

          ;; Area
        
          ("backend"  . ?k)
          ("frontend" . ?F)
          ("infra"    . ?i)
          ("docs"     . ?d)
          ("testing"  . ?t)

          ;; Context
          ("work"     . ?w)
          ("studies"  . ?p)
          )))
