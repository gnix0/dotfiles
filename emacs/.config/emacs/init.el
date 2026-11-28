;;; init.el --- Personal Emacs Configuration -*- lexical-binding: t; -*-

;; Author: Gustavo Arantes aka gnix
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
(add-hook 'prog-mode-hook #'display-line-numbers-mode)

;; Disable auto-saving and backups
(setq auto-save-default nil
      make-backup-files nil
      create-lockfiles nil)

;; Keep Customize-generated settings separate
(setq custom-file
      (expand-file-name "custom.el" user-emacs-directory))

(load custom-file 'noerror 'nomessage)

;; Column bar
(setq-default fill-column 110)
(add-hook 'prog-mode-hook #'display-fill-column-indicator-mode)

;; Tabs
(setq-default indent-tabs-mode nil
	      tab-width 4)

;; RET behavior that just gets out of my way
(defun gnix/prog-newline-setup ()
  (local-set-key (kbd "RET") #'newline-and-indent))
(add-hook 'prog-mode-hook #'gnix/prog-newline-setup)

;; Package management

(require 'package)

(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/") t)

(require 'use-package)

(setq use-package-always-ensure t
      use-package-always-defer t)

;; Remove default scratch message and 'C-h C-a' on start
(setq initial-scratch-message nil)
(defun display-startup-echo-area-message ()
  (message ""))

;; 'y' and 'n' for confirmation on dialogs
(setq use-short-answers t)

;; Font & Theme
(set-face-attribute 'default nil
                    :font
                    "IBM Plex Mono 15")

(use-package kanagawa-themes
  :demand t
  :config
  (load-theme 'kanagawa-wave t))

;; Dired
(use-package dired-x
  :ensure nil
  :demand t
  :custom
  (dired-listing-switches "-alh")
  (dired-dwim-target t))

;; Scrolling
(setq scroll-conservatively 101
      scroll-margin 10
      scroll-preserve-screen-position t)

;; Multiple cursors
(use-package multiple-cursors
  :bind
  (("C-S-c C-S-c" . mc/edit-lines)
   ("C->"         . mc/mark-next-like-this)
   ("C-<"         . mc/mark-previous-like-this)
   ("C-c C-<"     . mc/mark-all-like-this)
   ("C-\""        . mc/skip-to-next-like-this)
   ("C-:"         . mc/skip-to-previous-like-this)))

;; Editing helpers
(use-package move-text
  :bind (("M-p" . move-text-up)
         ("M-n" . move-text-down)))

(global-set-key (kbd "C-,") #'duplicate-dwim)
(global-set-key (kbd "M-z") 'zap-up-to-char)

;; Minibuffer
(use-package vertico
  :init
  (vertico-mode)
  :config
  (setq vertico-cycle t
	vertico-count 8
	vertico-resize nil
	read-file-name-completion-ignore-case t
	read-buffer-completion-ignore-case t
	completion-ignore-case t))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles partial-completion)))))

(use-package marginalia
  :bind (:map minibuffer-local-map
	          ("M-A" . marginalia-cycle))
  :init
  (marginalia-mode)
  :custom
  (marginalia-align 'right))

;; (Better) Unique buffer naming
(setq uniquify-buffer-name-style 'forward)

;; Man pages
(global-set-key (kbd "C-c m") #'man)

;; Version control
(use-package magit)

(setq git-commit-summary-max-length 50)

(add-hook 'git-commit-setup-hook
          (lambda ()
            (setq-local fill-column 72)))

(use-package diff-hl
  :hook ((prog-mode          . diff-hl-mode)
         (text-mode          . diff-hl-mode)
         (dired-mode         . diff-hl-dired-mode)
         (magit-post-refresh . diff-hl-magit-post-refresh))
  :config
  (diff-hl-margin-mode 1))

(use-package ediff
  :ensure nil
  :config
  (setq ediff-window-setup-function #'ediff-setup-windows-plain)
  (setq ediff-split-window-function #'split-window-horizontally))

(use-package smerge-mode
  :ensure nil
  :bind ("C-c e" . smerge-ediff)) ;; Visual conflict resolution; use M-x smerge-mode for simple cases

;; Built-in persistent state
(global-auto-revert-mode 1)
(recentf-mode 1)

(global-set-key (kbd "C-c r") #'recentf-open-files)

;; Projects
(use-package envrc
  :hook (after-init . envrc-global-mode))

(setq project-list-file "~/.config/emacs/emacs-projects-list"
      project-vc-extra-root-markers
      '("CMakeLists.txt"
	    ".clangd"
        "GNUmakefile"
        "Makefile"
        "makefile"
        "pom.xml"
        "Cargo.toml"
        "go.mod"
        "mix.exs"))

(editorconfig-mode 1)

;; Bins needed for go, rust, and elixir
(dolist (dir '("~/.local/bin" "~/.cargo/bin" "~/go/bin"))
  (let ((dir (expand-file-name dir)))
    (add-to-list 'exec-path dir)
    (setenv "PATH" (concat dir ":" (getenv "PATH")))))

;; Compilation bind & behavior
(global-set-key (kbd "C-c x") #'compile)
(setq compilation-scroll-output 'first-error)

(defun gnix/compilation-read-command (_command)
  (read-shell-command "Compile command: "
                      (or (car compile-history) "")
                      'compile-history))

(with-eval-after-load 'compile
  (advice-add 'compilation-read-command :override
              #'gnix/compilation-read-command))

(add-hook 'compilation-filter-hook #'ansi-color-compilation-filter)

;; Remove trailing whitespace when saving source files
(defun gnix/delete-trailing-whitespace-on-save ()
  (add-hook 'before-save-hook #'delete-trailing-whitespace nil t))

(add-hook 'prog-mode-hook #'gnix/delete-trailing-whitespace-on-save)

;; C/C++: indent new lines and braces without rearranging existing code.
(defun gnix/c-mode-setup ()
  (c-set-style "k&r")
  (c-set-offset 'func-decl-cont 0)
  (setq-local c-basic-offset 4
              indent-tabs-mode nil
              c-auto-newline nil
              c-cleanup-list nil
              eglot-ignored-server-capabilities
              '(:documentOnTypeFormattingProvider)))

(add-hook 'c-mode-hook #'gnix/c-mode-setup)
(add-hook 'c++-mode-hook #'gnix/c-mode-setup)

(with-eval-after-load 'cc-mode
  (define-key c++-mode-map (kbd ":") #'self-insert-command))

;; Align region
(add-hook 'prog-mode-hook
	      (lambda ()
	        (local-set-key (kbd "C-c <tab>") #'align)))

;; Languages
(use-package treesit
  :ensure nil
  :demand t
  :custom
  (treesit-enabled-modes
   '(cmake-ts-mode
     bash-ts-mode
     elixir-ts-mode
     go-ts-mode
     go-mod-ts-mode
     java-ts-mode
     json-ts-mode
     lua-ts-mode
     rust-ts-mode
     toml-ts-mode
     yaml-ts-mode))
  (treesit-auto-install-grammar 'ask))

;; Language Server Protocol
(use-package eglot
  :ensure nil
  :custom
  (flymake-show-diagnostics-at-end-of-line nil)
  :hook
  ((c-mode
    c++-mode
    cmake-ts-mode
    bash-ts-mode
    verilog-ts-mode
    vhdl-ts-mode
    java-ts-mode
    rust-ts-mode
    go-ts-mode
    go-mod-ts-mode
    elixir-ts-mode
    lua-ts-mode
    json-ts-mode
    yaml-ts-mode
    toml-ts-mode) . eglot-ensure)
  :config
  (add-to-list 'eglot-server-programs
               '((verilog-mode verilog-ts-mode)
                 . ("verible-verilog-ls" "--rules_config_search")))
  (add-to-list 'eglot-server-programs
               '((vhdl-mode vhdl-ts-mode)
                 . ("vhdl_ls")))
  (setq eglot-code-action-indications nil)
  (setq eglot-code-action-indicator nil)
  (add-hook 'eglot-managed-mode-hook
            (lambda ()
              (eglot-inlay-hints-mode -1)))

  ;; Keep semantic-token change notifications buffer-local.
  (defun gnix/eglot-semtok-hook ()
    (remove-hook 'eglot--send-changes-hook
                 #'eglot--semtok-after-send-changes)
    (if eglot-semantic-tokens-mode
        (add-hook 'eglot--send-changes-hook
                  #'eglot--semtok-after-send-changes nil t)
      (remove-hook 'eglot--send-changes-hook
                   #'eglot--semtok-after-send-changes t)))

  (add-hook 'eglot-semantic-tokens-mode-hook
            #'gnix/eglot-semtok-hook)

  (dolist (type '(eglot-error eglot-warning eglot-note))
    (let ((control (get type 'flymake-overlay-control)))
      (setf (alist-get 'face control) nil
            (alist-get 'before-string control) "")
      (put type 'flymake-overlay-control control))))

(add-to-list 'auto-mode-alist '("\\.clangd\\'" . yaml-ts-mode))

(add-hook 'makefile-mode-hook
          (lambda ()
            (setq-local indent-tabs-mode t)))

(add-hook 'go-ts-mode-hook
          (lambda ()
            (setq-local indent-tabs-mode t
                        tab-width 4)))

(add-to-list 'auto-mode-alist '("\\.svd\\'"         . nxml-mode))
(add-to-list 'auto-mode-alist '("\\.ioc\\'"         . conf-javaprop-mode))
(add-to-list 'auto-mode-alist '("/openocd\\.cfg\\'" . tcl-mode))
(add-to-list 'auto-mode-alist '("CODEOWNERS\\'"     . conf-mode))
(add-to-list 'auto-mode-alist '("\\.env\\'"         . conf-mode))

(use-package markdown-mode
  :config
  (setq markdown-fontify-code-blocks-natively t))

(use-package verilog-ts-mode
  :mode (("\\.v\\'"   . verilog-ts-mode)
         ("\\.vh\\'"  . verilog-ts-mode)
         ("\\.sv\\'"  . verilog-ts-mode)
         ("\\.svh\\'" . verilog-ts-mode))
  :bind
  (:map verilog-ts-mode-map
        ("M-?" . xref-find-references))
  :custom
  (verilog-ts-linter-enable nil))

(with-eval-after-load 'verilog-ts-mode
  (setq verilog-auto-newline nil)
  (dolist (key '(";" ":" "`"))
    (keymap-set verilog-ts-mode-map key #'self-insert-command)))

(add-hook 'verilog-ts-mode-hook
          (lambda ()
            (setq-local electric-indent-inhibit t)))

(use-package vhdl-ts-mode
  :mode (("\\.vhd\\'"  . vhdl-ts-mode)
         ("\\.vhdl\\'" . vhdl-ts-mode))
  :bind
  (:map vhdl-ts-mode-map
        ("TAB" . indent-according-to-mode)
        ("M-TAB" . completion-at-point)
        ("M-?" . xref-find-references))
  :custom
  (vhdl-ts-linter-enable nil)
  :config
  (dolist (key '("'" "," "-" "." ";" "SPC" "[" "]"))
    (keymap-set vhdl-ts-mode-map key #'self-insert-command)))

(add-hook 'vhdl-mode-hook
          (lambda ()
            (vhdl-electric-mode -1)
            (vhdl-stutter-mode -1)
            (setq-local electric-indent-inhibit t)))

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
  (corfu-on-exact-match nil))

;; Eldoc only in a separate buffer
(setq eldoc-display-functions '(eldoc-display-in-buffer))

;; Org-mode
(use-package org
  :ensure nil
  :hook
  (org-mode       . org-indent-mode)
  :bind
  (("C-c l"       . org-store-link)
   ("C-c a"       . org-agenda)
   ("C-c c"       . org-capture))
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
          (todo   . " %i %-12:c")
          (tags   . " %i %-12:c")
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
        '((sequence "TODO(t)" "PLANNING(p)" "IN-PROGRESS(i/!)" "VERIFYING(v!)" "BLOCKED(b@)"  "|" "DONE(d!)" "OBE(o@!)" "WONT-DO(w@/!)" )))

  ;; TODO colors
  (setq org-todo-keyword-faces
        '(("TODO"        . (:foreground "GoldenRod" :weight bold))
          ("PLANNING"    . (:foreground "DeepPink" :weight bold))
          ("IN-PROGRESS" . (:foreground "Cyan" :weight bold))
          ("VERIFYING"   . (:foreground "DarkOrange" :weight bold))
          ("BLOCKED"     . (:foreground "Red" :weight bold))
          ("DONE"        . (:foreground "LimeGreen" :weight bold))
          ("OBE"         . (:foreground "LimeGreen" :weight bold))
          ("WONT-DO"     . (:foreground "LimeGreen" :weight bold))))

  (setq org-tag-alist
        '(;; Area (choose one)
          (:startgroup)
          ("@embedded"    . ?e)
          ("@programming" . ?p)
          ("@electronics" . ?E)
          ("@linux"       . ?l)
          ("@math"        . ?m)
          ("@physics"     . ?P)
          ("@cs"          . ?s)
          (:endgroup)
          ;; Type
          ("study"        . ?S)
          ("read"         . ?r)
          ("implement"    . ?i)
          ("bug"          . ?b)
          ("feature"      . ?f)
          ("research"     . ?R)
          ("chore"        . ?c)
          ("docs"         . ?d)
          ("testing"      . ?t)
          ;; Context
          ("work"         . ?w)
          ("personal"     . ?x))))

(defun gnix/open-notes ()
  "Open personal notes in Org overview."
  (interactive)
  (find-file "~/org/notes.org")
  (org-mode)
  (org-overview))

(global-set-key (kbd "C-c n") #'gnix/open-notes)

;; PDF viewing
(use-package pdf-tools
  :init
  (pdf-loader-install)
  :hook
  (pdf-view-mode
   . (lambda ()
       (display-line-numbers-mode -1)
       (hl-line-mode -1))))

(use-package pdf-view-restore
  :after pdf-tools
  :hook
  (pdf-view-mode . pdf-view-restore-mode))
