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
(add-hook 'text-mode-hook #'visual-line-mode)
(setq ring-bell-function #'ignore)

;; Disable auto-saving and backups
(setq auto-save-default nil)
(setq make-backup-files nil)

;; Column bar
(setq-default fill-column 110)
(add-hook 'prog-mode-hook #'display-fill-column-indicator-mode)

;; Relative line numbers
(defun gnix/relative-line-numbers ()
  "Enable relative line numbers."
  (interactive)
  (display-line-numbers-mode)
  (setq display-line-numbers 'relative))
(add-hook 'prog-mode-hook #'gnix/relative-line-numbers)

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
                    "IosevkaTermSlab Nerd Font"
                    :height 135)

;; (use-package gruber-darker-theme
;;   :demand t
;;   :config
;;   (load-theme 'gruber-darker t))

(use-package doom-themes
  :demand t
  :config
  (load-theme 'doom-monokai-pro t))

;; Dired
(use-package dired-x
  :straight nil
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
	vertico-count 15
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
        "Cargo.toml"
        "go.mod"
        "mix.exs"))

(use-package editorconfig
  :demand t
  :config
  (editorconfig-mode 1))

;; Bins needed for go, rust, and elixir
(dolist (dir '("~/.local/bin" "~/.cargo/bin" "~/go/bin"))
  (let ((dir (expand-file-name dir)))
    (add-to-list 'exec-path dir)
    (setenv "PATH" (concat dir ":" (getenv "PATH")))))

;; Compilation (not project-wise like project.el does)
(global-set-key (kbd "C-x c") #'compile)

;; Colours instead of ANSI escapes on compilation
(require 'ansi-color)
(defun gnix/colorize-compilation-buffer ()
  (let ((inhibit-read-only t))
    (ansi-color-apply-on-region compilation-filter-start (point))))
(add-hook 'compilation-filter-hook #'gnix/colorize-compilation-buffer)

;; Remove trailing whitespace when saving source files
(defun gnix/delete-trailing-whitespace-on-save ()
  (add-hook 'before-save-hook #'delete-trailing-whitespace nil t))

(add-hook 'prog-mode-hook #'gnix/delete-trailing-whitespace-on-save)

;; Keycast
(use-package keycast
  :demand t
  :config
  (setq keycast-mode-line-remove-tail-elements nil
	keycast-mode-line-format "%2s%K  %C%R ")
  (keycast-mode-line-mode 1))

;; C/C++
(defun gnix/c-ts-mode-setup ()
  (setq-local c-ts-mode-indent-style 'k&r
              c-ts-mode-indent-offset 4
              indent-tabs-mode nil
              eglot-ignored-server-capabilities
              '(:documentOnTypeFormattingProvider))
  (local-set-key (kbd "RET") #'newline-and-indent))

(defun gnix/c++-ts-mode-setup ()
  (setq-local c++-ts-mode-indent-style 'k&r
	      c++-ts-mode-indent-offset 4
	      indent-tabs-mode nil
	      eglot-ignored-server-capabilities
	      '(:documentOnTypeFormattingProvider))
  (local-set-key (kbd "RET") #'newline-and-indent))

(add-hook 'c-ts-base-mode-hook #'gnix/c-ts-mode-setup)
(add-hook 'c++-ts-mode-hook #'gnix/c++-ts-mode-setup)

;; Align region
(add-hook 'prog-mode-hook
	  (lambda ()
	    (local-set-key (kbd "C-c <tab>") #'align)))

;; Languages
(use-package treesit
  :straight nil
  :demand t
  :init
  (setq treesit-language-source-alist
        '((bash . ("https://github.com/tree-sitter/tree-sitter-bash" "v0.23.3"))
          (c       . ("https://github.com/tree-sitter/tree-sitter-c" "v0.23.6"))
          (cpp     . ("https://github.com/tree-sitter/tree-sitter-cpp" "v0.23.4"))
          (elixir  . ("https://github.com/elixir-lang/tree-sitter-elixir" "v0.3.0"))
          (go      . ("https://github.com/tree-sitter/tree-sitter-go" "v0.23.4"))
          (gomod   . ("https://github.com/camdencheek/tree-sitter-go-mod" "v1.0.2"))
          (heex    . ("https://github.com/phoenixframework/tree-sitter-heex" "v0.8.0"))
          (java    . ("https://github.com/tree-sitter/tree-sitter-java" "v0.23.5"))
          (json    . ("https://github.com/tree-sitter/tree-sitter-json" "v0.24.8"))
          (lua     . ("https://github.com/tree-sitter-grammars/tree-sitter-lua" "v0.2.0"))
          (rust    . ("https://github.com/tree-sitter/tree-sitter-rust" "v0.23.3"))
          (toml    . ("https://github.com/tree-sitter-grammars/tree-sitter-toml" "v0.7.0"))
          (yaml    . ("https://github.com/ikatyang/tree-sitter-yaml"))))

  (dolist (entry '((bash sh-mode bash-ts-mode)
                   (c c-mode c-ts-mode)
                   (cpp c++-mode c++-ts-mode)
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
    (add-to-list 'auto-mode-alist
                 '("\\.[hl]?eex\\'" . heex-ts-mode))))

;; Language Server Protocol
(use-package eglot
  :custom
  (flymake-show-diagnostics-at-end-of-line nil)
  :hook
  ((c-mode . eglot-ensure)
   (c-ts-mode . eglot-ensure)
   (c++-mode . eglot-ensure)
   (c++-ts-mode . eglot-ensure)
   (java-mode . eglot-ensure)
   (java-ts-mode . eglot-ensure)
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
      (put type 'flymake-overlay-control control))))

(use-package elixir-mode)
(use-package go-mode)
(use-package rust-mode)
(use-package lua-mode)
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
  (corfu-on-exact-match nil))

;; Eldoc only in a separate buffer
(setq eldoc-display-functions '(eldoc-display-in-buffer))

;; Org-mode
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
        '((sequence "TODO(t)" "PLANNING(p)" "IN-PROGRESS(i/!)" "VERIFYING(v!)" "BLOCKED(b@)"  "|" "DONE(d!)" "OBE(o@!)" "WONT-DO(w@/!)" )))

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
        ("study"     . ?S)
        ("read"      . ?r)
        ("implement" . ?i)
        ("bug"       . ?b)
        ("feature"   . ?f)
        ("research"  . ?R)
        ("chore"     . ?c)
        ("docs"      . ?d)
        ("testing"   . ?t)

        ;; Context
        ("work"     . ?w)
        ("personal" . ?x))))

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

(setq enable-local-variables :all)
