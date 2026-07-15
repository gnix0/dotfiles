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

;; Human-readable file sized in Dired
(setq dired-listing-switches "-alh")

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

;; Font & Theme
(set-face-attribute 'default nil
                    :font
                    "IosevkaTermSlab Nerd Font Mono"
                    :height 160)

(add-to-list 'custom-theme-load-path "~/.config/emacs/themes/")
(load-theme 'ansi-black t)

(use-package keycast
  :demand t
  :config
  (setq keycast-mode-line-remove-tail-elements nil
	keycast-mode-line-format "%K  %C%R ")
  (keycast-mode-line-mode 1))

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
  :ensure t
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
  :demand t
  :commands vterm
  :config
  (setq term-prompt-regexp "^[^#$%>\n]*[#$%>] *")
  (setq vterm-shell "zsh")
  (setq vterm-max-scrollback 10000))

;; Projects
(use-package envrc
  :init
  (envrc-global-mode))

(setq project-list-file "~/.config/emacs/emacs-projects-list"
      project-vc-extra-root-markers
      '("CMakeLists.txt"
	".clangd"
        "GNUmakefile"
        "Makefile"
        "makefile"
        "pom.xml"
        "build.gradle"
        "Cargo.toml"
        "go.mod"
        "mix.exs"))

(use-package editorconfig
  :demand t
  :config
  (editorconfig-mode 1))

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

;; Colours instead of ANSI escapes on compilation
(require 'ansi-color)
(defun gnix/colorize-compilation-buffer ()
  (let ((inhibit-read-only t))
    (ansi-color-apply-on-region compilation-filter-start (point))))
(add-hook 'compilation-filter-hook #'gnix/colorize-compilation-buffer)

;; Languages
(use-package cc-mode
  :straight nil
  :defer t
  :init
  (setq c-default-style '((java-mode . "java")
                          (awk-mode . "awk")
                          (other . "k&r")))

  (defun gnix/newline-and-indent ()
    "Insert a newline and keep C-like scope indentation predictable."
    (interactive)
    (let* ((indent (current-indentation))
           (opens-block
            (save-excursion
              (end-of-line)
              (skip-chars-backward " \t")
              (eq (char-before) ?{))))
      (newline)
      (indent-to (+ indent (if opens-block c-basic-offset 0)))))

  (defun gnix/cc-electric-close-brace ()
    "Insert a closing brace, then reindent only that line."
    (interactive)
    (call-interactively #'c-electric-brace)
    (save-excursion
      (beginning-of-line)
      (when (looking-at-p "[ \t]*}")
        (c-indent-line))))

  (defun gnix/cc-mode-setup ()
    (electric-indent-local-mode -1)
    (setq-local c-basic-offset 4)
    (setq-local indent-tabs-mode nil)
    (local-set-key (kbd "RET") #'gnix/newline-and-indent)
    (local-set-key (kbd "<return>") #'gnix/newline-and-indent)
    (local-set-key (kbd "C-m") #'gnix/newline-and-indent)
    (local-set-key (kbd "}") #'gnix/cc-electric-close-brace))

  (add-hook 'c-mode-common-hook #'gnix/cc-mode-setup))

(use-package eglot
  :custom
  (flymake-show-diagnostics-at-end-of-line nil)
  :hook ((java-mode . eglot-ensure)
	 (c-mode . eglot-ensure)
	 (c++-mode . eglot-ensure)
         (rust-mode . eglot-ensure)
         (go-mode . eglot-ensure)
         (elixir-mode . eglot-ensure)
	 (lua-mode . eglot-ensure))
  :config
  (setq eglot-code-action-indications nil)
  (setq eglot-code-action-indicator nil)
  (dolist (type '(eglot-error eglot-warning eglot-note))
    (let ((control (get type 'flymake-overlay-control)))
      (setf (alist-get 'face control) nil
            (alist-get 'before-string control) "")
      (put type 'flymake-overlay-control control)))
  (let ((java-debug-jar
         (car
          (file-expand-wildcards
           (expand-file-name
            "~/.config/emacs/debug-adapters/java-debug/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-*.jar")))))
    (add-to-list
     'eglot-server-programs
     `((java-mode) .
       ("jdtls"
        :initializationOptions
        (:bundles [,java-debug-jar]))))))

(use-package elixir-mode)
(use-package go-mode)
(use-package rust-mode)
(use-package lua-mode)

;; More relevant file-types
(use-package markdown-mode
  :config
  (setq markdown-fontify-code-blocks-natively t))

(use-package yaml-mode)

(add-to-list 'auto-mode-alist '("CODEOWNERS\\'" . conf-mode))
(add-to-list 'auto-mode-alist '("\\.env\\'" . conf-mode))

;; Diagnostics
(global-set-key (kbd "C-c d") #'flymake-show-buffer-diagnostics)

;; Re-bind to zap UP TO char, but not INCLUDING the char
(global-set-key (kbd "M-z") 'zap-up-to-char)

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

;; File-path completion
(use-package cape
  :init
  (add-hook 'completion-at-point-functions #'cape-file))

;; Disable eldoc in the minibuffer
(setq eldoc-display-functions '(eldoc-display-in-buffer))

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

(defun gnix/open-notes ()
  "Open personal notes in Org overview."
  (interactive)
  (find-file "~/org/notes.org")
  (org-mode)
  (org-overview))

(global-set-key (kbd "C-c n") #'gnix/open-notes)

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
	org-agenda-start-on-weekday 0
	calendar-week-start-day 0
        org-agenda-use-time-grid nil
        org-log-done 'time
        org-return-follows-link t
        org-hide-emphasis-markers t
        org-agenda-prefix-format
        '((agenda . " %i %-12:c% s")
          (todo . " %i %-12:c")
          (tags . " %i %-12:c")
          (search . " %i %-12:c")))

  (defun gnix/org-clock-sum-string (minutes)
    (format "[%02d:%02d]" (/ minutes 60) (% minutes 60)))

  (defun gnix/org-update-heading-clock-sum ()
    (when (and (derived-mode-p 'org-mode)
               (not org-clock-out-removed-last-clock))
      (save-excursion
        (save-restriction
          (widen)
          (org-back-to-heading t)
          (let* ((components (org-heading-components))
                 (todo-keyword (nth 2 components))
                 (heading (nth 4 components)))
            (when (and todo-keyword heading)
              (let* ((minutes (org-clock-sum-current-item))
                     (clean-heading
                      (replace-regexp-in-string
                       "[ \t]+\\[[0-9]+:[0-9][0-9]\\]\\'" "" heading))
                     (updated-heading
                      (format "%s %s"
                              clean-heading
                              (gnix/org-clock-sum-string minutes))))
                (org-edit-headline updated-heading))))))))

  (add-hook 'org-clock-out-hook #'gnix/org-update-heading-clock-sum)

  (defun gnix/org-notes-date-heading ()
    (let ((date-heading (format-time-string "%Y-%m-%d")))
      (widen)
      (goto-char (point-min))
      (unless (re-search-forward "^\\* Random Notes[ \t]*$" nil t)
        (goto-char (point-max))
        (unless (bolp) (insert "\n"))
        (insert "* Random Notes\n"))
      (let ((notes-end (save-excursion (org-end-of-subtree t t))))
        (if (re-search-forward
             (format "^\\*\\* %s[ \t]*$" (regexp-quote date-heading))
             notes-end t)
            (forward-line 0)
          (goto-char notes-end)
          (unless (bolp) (insert "\n"))
          (insert "** " date-heading "\n")
          (forward-line -1)))))

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
           entry (file+function "~/org/notes.org" gnix/org-notes-date-heading)
           "*** %?"
           :empty-lines 0)

          ("t" "To-do"
           entry (file+headline "~/org/todos.org" "Tasks")
           "* TODO [#B] %?\n "
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
          (:endgroup)
          ;; Area
          ("backend"  . ?k)
          ("frontend" . ?F)
          ("infra"    . ?i)
          ("docs"     . ?d)
          ("testing"  . ?t)
          ;; Context
          ("work"     . ?w)
          ("studies"  . ?s)
	  ("personal" . ?p)
          )))

;; PDF viewing with note-taking
(use-package pdf-tools
  :init
  (pdf-loader-install)
  :hook
  (pdf-view-mode
   . (lambda ()
       (display-line-numbers-mode -1)
       (hl-line-mode -1))))
