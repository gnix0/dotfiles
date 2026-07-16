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

(use-package gruber-darker-theme
  :demand t
  :init
  (load-theme 'gruber-darker t))

;; (add-to-list 'custom-theme-load-path "~/.config/emacs/themes/")
;; (load-theme 'ansi-black t)

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
(global-set-key (kbd "C-\"") 'mc/skip-to-next-like-this)
(global-set-key (kbd "C-:") 'mc/skip-to-previous-like-this)

;; Editing helpers
(use-package move-text
  :bind (("M-p" . move-text-up)
         ("M-n" . move-text-down)))

(global-set-key (kbd "C-,") #'duplicate-dwim)

;; Re-bind to zap UP TO char, but not INCLUDING the char
(global-set-key (kbd "M-z") 'zap-up-to-char)

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
(use-package treesit
  :straight nil
  :demand t
  :init
  (setq treesit-language-source-alist
        '((bash . ("https://github.com/tree-sitter/tree-sitter-bash"))
          (c . ("https://github.com/tree-sitter/tree-sitter-c"))
          (cpp . ("https://github.com/tree-sitter/tree-sitter-cpp"))
          (elixir . ("https://github.com/elixir-lang/tree-sitter-elixir"))
          (go . ("https://github.com/tree-sitter/tree-sitter-go"))
          (gomod . ("https://github.com/camdencheek/tree-sitter-go-mod"))
          (heex . ("https://github.com/phoenixframework/tree-sitter-heex"))
          (java . ("https://github.com/tree-sitter/tree-sitter-java"))
          (json . ("https://github.com/tree-sitter/tree-sitter-json"))
          (lua . ("https://github.com/tree-sitter-grammars/tree-sitter-lua"))
          (rust . ("https://github.com/tree-sitter/tree-sitter-rust"))
          (toml . ("https://github.com/tree-sitter-grammars/tree-sitter-toml"))
          (yaml . ("https://github.com/tree-sitter-grammars/tree-sitter-yaml")))
        c-ts-mode-indent-style 'k&r)

  (dolist (entry '((bash sh-mode bash-ts-mode)
                   (c c-mode c-ts-mode)
                   (cpp c++-mode c++-ts-mode)
                   (c c-or-c++-mode c-or-c++-ts-mode)
                   (elixir elixir-mode elixir-ts-mode)
                   (go go-mode go-ts-mode)
                   (gomod go-dot-mod-mode go-mod-ts-mode)
                   (java java-mode java-ts-mode)
                   (json js-json-mode json-ts-mode)
                   (lua lua-mode lua-ts-mode)
                   (rust rust-mode rust-ts-mode)
                   (toml conf-toml-mode toml-ts-mode)
                   (yaml yaml-mode yaml-ts-mode)))
    (when (treesit-language-available-p (nth 0 entry))
      (add-to-list 'major-mode-remap-alist
                   (cons (nth 1 entry) (nth 2 entry)))))

  (when (treesit-language-available-p 'heex)
    (add-to-list 'auto-mode-alist '("\\.[hl]?eex\\'" . heex-ts-mode))))

(defun gnix/ts-indent-offset ()
  "Return the indentation offset for the current C-like tree-sitter mode."
  (if (derived-mode-p 'java-ts-mode)
      java-ts-mode-indent-offset
    c-ts-mode-indent-offset))

(defun gnix/ts-newline-and-indent ()
  "Insert a newline and keep C-like scope indentation predictable."
  (interactive)
  (let* ((blank-line (save-excursion
                       (beginning-of-line)
                       (looking-at-p "[ \t]*$")))
         (indent (current-indentation))
         (control-line
          (save-excursion
            (back-to-indentation)
            (looking-at-p
             "\\(?:if\\|else\\|for\\|while\\|do\\|switch\\)\\b")))
         (opens-block
          (save-excursion
            (end-of-line)
            (skip-chars-backward " \t")
            (eq (char-before) ?{))))
    (when blank-line
      (delete-region (line-beginning-position) (line-end-position)))
    (newline)
    (if (or opens-block control-line)
        (indent-to (+ indent (gnix/ts-indent-offset)))
      (indent-according-to-mode)
      ;; Java's parser can temporarily lose the surrounding scope while
      ;; braces are incomplete.  Keep the indentation stable in that case.
      (when (and (derived-mode-p 'java-ts-mode)
                 (> indent 0)
                 (= (current-indentation) 0))
        (indent-to indent)))))

(defun gnix/ts-electric-brace ()
  "Insert a brace, then reindent only that brace line."
  (interactive)
  (call-interactively #'self-insert-command)
  (save-excursion
    (beginning-of-line)
    (when (looking-at-p "[ \t]*[{}]")
      (let ((control-indent
             (and (derived-mode-p 'c-ts-base-mode)
                  (eq (char-after (progn (back-to-indentation) (point))) ?{)
                  (save-excursion
                    (forward-line -1)
                    (back-to-indentation)
                    (when (looking-at-p
                           "\\(?:if\\|else\\|for\\|while\\|do\\|switch\\)\\b")
                      (current-indentation))))))
        (if control-indent
            (indent-line-to control-indent)
          (indent-according-to-mode))))))

(defun gnix/c-like-ts-mode-setup ()
  (electric-indent-local-mode -1)
  (if (derived-mode-p 'java-ts-mode)
      (setq-local java-ts-mode-indent-offset 4)
    (setq-local c-ts-mode-indent-offset 4))
  (setq-local indent-tabs-mode nil)
  (local-set-key (kbd "RET") #'gnix/ts-newline-and-indent)
  (local-set-key (kbd "<return>") #'gnix/ts-newline-and-indent)
  (local-set-key (kbd "C-m") #'gnix/ts-newline-and-indent)
  (local-set-key (kbd "{") #'gnix/ts-electric-brace)
  (local-set-key (kbd "}") #'gnix/ts-electric-brace))

(add-hook 'c-ts-base-mode-hook #'gnix/c-like-ts-mode-setup)
(add-hook 'java-ts-mode-hook #'gnix/c-like-ts-mode-setup)

(use-package eglot
  :custom
  (flymake-show-diagnostics-at-end-of-line nil)
  :hook ((java-mode . eglot-ensure)
         (java-ts-mode . eglot-ensure)
	 (c-mode . eglot-ensure)
         (c-ts-mode . eglot-ensure)
	 (c++-mode . eglot-ensure)
         (c++-ts-mode . eglot-ensure)
         (rust-mode . eglot-ensure)
         (rust-ts-mode . eglot-ensure)
         (go-mode . eglot-ensure)
         (go-ts-mode . eglot-ensure)
         (elixir-mode . eglot-ensure)
         (elixir-ts-mode . eglot-ensure)
	 (lua-mode . eglot-ensure)
         (lua-ts-mode . eglot-ensure))
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
     `((java-mode java-ts-mode) .
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
