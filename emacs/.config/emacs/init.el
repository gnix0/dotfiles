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
                    "Iosevka"
                    :height 150)

;; (use-package gruber-darker-theme
;;   :demand t
;;   :init
;;   (load-theme 'gruber-darker))

(load (expand-file-name
       "themes/gruber-darker-custom.el"
       user-emacs-directory)
      nil
      'nomessage)
(enable-theme 'gruber-darker-custom)

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

;; Minibuffer and Searching
(use-package ido
  :straight nil
  :demand t
  :config
  (ido-mode 1)
  (ido-everywhere 1))

(use-package ido-completing-read+
  :demand t
  :config
  (ido-ubiquitous-mode 1))

(use-package smex
  :bind
  (("M-x" . smex)
   ("C-c C-c M-x" . execute-extended-command)))

(use-package helm
  :bind
  (("C-c h t" . helm-cmd-t)
   ("C-c h f" . helm-find)
   ("C-c h a" . helm-org-agenda-files-headings)
   ("C-c h r" . helm-recentf))
  :custom
  (helm-ff-transformer-show-only-basename nil))

(use-package helm-git-grep
  :bind
  ("C-c h g g" . helm-git-grep))

(use-package helm-ls-git
  :bind
  ("C-c h g l" . helm-ls-git-ls))

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
(global-set-key (kbd "C-c k") #'compile)

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
	keycast-mode-line-format "%K  %C%R ")
  (keycast-mode-line-mode 1))

;; C/C++
(defun astyle-buffer (&optional justify)
  (interactive)
  (let ((saved-line-number (line-number-at-pos)))
    (shell-command-on-region
     (point-min)
     (point-max)
     "astyle --style=kr"
     nil
     t)
    (goto-line saved-line-number)))

(defun gnix/simpc--line-starts-with-closing-delimiter-p ()
  "Return non-nil when the current line starts with a closing delimiter."
  (save-excursion
    (back-to-indentation)
    (memq (char-after) '(?\) ?\] ?}))))

(defun gnix/simpc--control-paren-p (open-paren)
  "Return non-nil when OPEN-PAREN belongs to a control statement."
  (save-excursion
    (goto-char open-paren)
    (string-match-p
     "\\_<\\(?:if\\|for\\|switch\\|while\\)\\_>\\s-*\\'"
     (buffer-substring-no-properties (line-beginning-position) (point)))))

(defun gnix/simpc--control-before-brace-indentation (open-brace)
  "Return the control statement's indentation before OPEN-BRACE, if any."
  (save-excursion
    (goto-char open-brace)
    (skip-chars-backward " \t\n")
    (when (eq (char-before) ?\))
      (let ((open-paren (ignore-errors (scan-sexps (point) -1))))
        (when (and open-paren (gnix/simpc--control-paren-p open-paren))
          (goto-char open-paren)
          (current-indentation))))))

(defun gnix/simpc--macro-body-indentation ()
  "Return indentation for the first line of a continued macro body."
  (save-excursion
    (beginning-of-line)
    (when (> (line-number-at-pos) 1)
      (forward-line -1)
      (when (save-excursion
              (end-of-line)
              (skip-chars-backward " \t")
              (eq (char-before) ?\\))
        (back-to-indentation)
        (when (looking-at-p "#\\s-*define\\_>")
          (+ (current-indentation) 4))))))

(defun gnix/simpc--after-top-level-close-indentation ()
  "Return indentation after a top-level closing brace, if applicable."
  (let ((previous (simpc--previous-non-empty-line)))
    (when (and previous
               (string-prefix-p "}" (string-trim-left (car previous))))
      (max (- (cdr previous) 4) 0))))

(defun gnix/simpc--delimiter-indentation (open-delimiter)
  "Return AStyle-like indentation relative to OPEN-DELIMITER."
  (let ((closing-delimiter
         (gnix/simpc--line-starts-with-closing-delimiter-p)))
    (save-excursion
      (goto-char open-delimiter)
      (let ((open-column (current-column))
            (open-indent (current-indentation))
            (control-indent
             (and (eq (char-after) ?{)
                  (gnix/simpc--control-before-brace-indentation
                   open-delimiter))))
        (cond
         (closing-delimiter (or control-indent open-indent))
         ((eq (char-after) ?\()
          (if (gnix/simpc--control-paren-p open-delimiter)
              (+ open-indent 8)
            (1+ open-column)))
         ((eq (char-after) ?{)
          (+ (or control-indent open-indent)
             4)))))))

(defun gnix/simpc-indent-line ()
  "Indent a Simple C line, including expressions continued across lines."
  (interactive)
  (let* ((offset-from-indentation
          (max (- (current-column) (current-indentation)) 0))
         (open-delimiter
          (save-excursion
            (back-to-indentation)
            (nth 1 (syntax-ppss))))
         (after-label
          (let ((previous (simpc--previous-non-empty-line)))
            (and previous
                 (string-suffix-p
                  ":"
                  (string-trim-right (car previous))))))
         (desired-indentation
          (cond
           ((and open-delimiter (not after-label))
            (gnix/simpc--delimiter-indentation open-delimiter))
           ((gnix/simpc--macro-body-indentation))
           ((gnix/simpc--after-top-level-close-indentation))
           (t (simpc--desired-indentation)))))
    (indent-line-to desired-indentation)
    (forward-char offset-from-indentation)))

(defun gnix/simpc-electric-closing-delimiter ()
  "Insert a closing delimiter and reindent it when it starts the line."
  (interactive)
  (let ((starts-line
         (string-match-p
          "\\`[ \t]*\\'"
          (buffer-substring-no-properties
           (line-beginning-position)
           (point)))))
    (call-interactively #'self-insert-command)
    (when starts-line
      (indent-according-to-mode))))

(defun gnix/simpc-mode-setup ()
  (setq-local eglot-ignored-server-capabilities
              '(:documentOnTypeFormattingProvider))
  (setq-local indent-tabs-mode nil)
  (setq-local indent-line-function #'gnix/simpc-indent-line)
  (setq-local fill-paragraph-function 'astyle-buffer)
  (local-set-key (kbd "RET") #'newline-and-indent)
  (local-set-key (kbd "<return>") #'newline-and-indent)
  (local-set-key (kbd "C-m") #'newline-and-indent)
  (local-set-key (kbd ")") #'gnix/simpc-electric-closing-delimiter)
  (local-set-key (kbd "]") #'gnix/simpc-electric-closing-delimiter)
  (local-set-key (kbd "}") #'gnix/simpc-electric-closing-delimiter)
  (local-set-key (kbd "M-q") #'astyle-buffer))

(use-package simpc-mode
  :straight (:type git
             :host github
             :repo "rexim/simpc-mode")
  :mode ("\\.\\(?:c\\(?:c\\|pp\\|xx\\)?\\|h\\(?:h\\|pp\\|xx\\)?\\)\\'" . simpc-mode)
  :hook (simpc-mode . gnix/simpc-mode-setup))

;; Languages
(use-package treesit
  :straight nil
  :demand t
  :init
  (setq treesit-language-source-alist
        '((bash . ("https://github.com/tree-sitter/tree-sitter-bash"))
          (elixir . ("https://github.com/elixir-lang/tree-sitter-elixir"))
          (go . ("https://github.com/tree-sitter/tree-sitter-go"))
          (gomod . ("https://github.com/camdencheek/tree-sitter-go-mod"))
          (heex . ("https://github.com/phoenixframework/tree-sitter-heex"))
          (java . ("https://github.com/tree-sitter/tree-sitter-java"))
          (json . ("https://github.com/tree-sitter/tree-sitter-json"))
          (lua . ("https://github.com/tree-sitter-grammars/tree-sitter-lua"))
          (rust . ("https://github.com/tree-sitter/tree-sitter-rust"))
          (toml . ("https://github.com/tree-sitter-grammars/tree-sitter-toml"))
          (yaml . ("https://github.com/tree-sitter-grammars/tree-sitter-yaml"))))

  (dolist (entry '((bash sh-mode bash-ts-mode)
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

(defun gnix/ts-indent-offset ()
  "Return the indentation offset for the current C-like tree-sitter mode."
  (if (derived-mode-p 'java-ts-mode)
      java-ts-mode-indent-offset
    c-ts-mode-indent-offset))

(defun gnix/ts-newline-and-indent ()
  "Insert a newline and keep C-like scope indentation predictable."
  (interactive)
  (let* ((blank-line
          (save-excursion
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
      ;; braces are incomplete. Keep the indentation stable in that case.
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
                  (eq (char-after
                       (progn
                         (back-to-indentation)
                         (point)))
                      ?{)
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

(add-hook 'java-ts-mode-hook #'gnix/c-like-ts-mode-setup)

;; Language Server Protocol
(use-package eglot
  :custom
  (flymake-show-diagnostics-at-end-of-line nil)
  :hook
  ((java-mode . eglot-ensure)
   (java-ts-mode . eglot-ensure)
   (simpc-mode . eglot-ensure)
   (rust-mode . eglot-ensure)
   (rust-ts-mode . eglot-ensure)
   (go-mode . eglot-ensure)
   (go-ts-mode . eglot-ensure)
   (elixir-mode . eglot-ensure)
   (elixir-ts-mode . eglot-ensure)
   (lua-mode . eglot-ensure)
   (lua-ts-mode . eglot-ensure))
  :config
  (add-to-list 'eglot-server-programs
               '((simpc-mode :language-id "c") . ("clangd")))

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

;; More relevant file types
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

;; Eldoc only in a separate buffer
(setq eldoc-display-functions '(eldoc-display-in-buffer))

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
