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

;; Column bar
(setq-default fill-column 100)
(add-hook 'prog-mode-hook #'display-fill-column-indicator-mode)

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

;; Zaps up to the char, not the char itself
(global-set-key (kbd "M-z") 'zap-up-to-char)

;; Tab config & Smart delimiters
(setq-default indent-tabs-mode nil)
(electric-pair-mode 1)

;; Font & Theme
(set-face-attribute 'default nil
                    :font
                    "IosevkaTermSlab Nerd Font Mono"
                    :height 150)

(setq modus-themes-to-toggle '(modus-vivendi modus-operandi-tinted))
(load-theme 'modus-vivendi)
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

(use-package forge
  :after magit)

(setq auth-sources '("~/.authinfo"))

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
(defun goa/pin-window ()
  (interactive)
  (set-window-dedicated-p (get-buffer-window (current-buffer)) t))

;; Don't ask before killing the current compilation and scroll as buffer grows
(setq compilation-always-kill t
      compilation-scroll-output t)

;; Colours instead of ANSI escapes on compilation
(require 'ansi-color)
(defun goa/colorize-compilation-buffer ()
  (let ((inhibit-read-only t))
    (ansi-color-apply-on-region compilation-filter-start (point))))
(add-hook 'compilation-filter-hook #'goa/colorize-compilation-buffer)

;; Languages
(setq major-mode-remap-alist
      '((java-mode       . java-ts-mode)
        (c-mode          . c-ts-mode)
        (c++-mode        . c++-ts-mode)
        (rust-mode       . rust-ts-mode)
        (elixir-mode     . elixir-ts-mode)
        (go-mode         . go-ts-mode)
        (bash-mode       . bash-ts-mode)
        (json-mode       . json-ts-mode)
        (yaml-mode       . yaml-ts-mode)))

(use-package eglot
  :straight nil
  :hook ((java-ts-mode . eglot-ensure)
         (c-ts-mode . eglot-ensure)
         (c++-ts-mode . eglot-ensure)
         (rust-ts-mode . eglot-ensure)
         (go-ts-mode . eglot-ensure)
         (elixir-ts-mode . eglot-ensure))
  :config
  (let ((java-debug-jar
         (car
          (file-expand-wildcards
           "~/.config/emacs/debug-adapters/java-debug/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-*.jar"))))
    (add-to-list
     'eglot-server-programs
     `((java-mode java-ts-mode)
       .
       ("jdtls"
        :initializationOptions
        (:bundles [,java-debug-jar]))))))

(use-package eglot-java
  :after eglot
  :hook ((java-ts-mode . eglot-java-mode)))

(use-package elixir-mode)


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
  (corfu-auto t)
  (corfu-cycle t)
  (corfu-preview-current nil)
  (corfu-on-exact-match nil)
  :bind
  (:map corfu-map
        ("C-y" . corfu-insert)
        ("RET" . newline)
        ("<return>" . newline)))

;; Tree-sitter
(setq treesit-language-source-alist
        '((java       . ("https://github.com/tree-sitter/tree-sitter-java"))
          (c          . ("https://github.com/tree-sitter/tree-sitter-c"))
          (cpp        . ("https://github.com/tree-sitter/tree-sitter-cpp"))
          (rust       . ("https://github.com/tree-sitter/tree-sitter-rust"))
          (elixir       . ("https://github.com/elixir-lang/tree-sitter-elixir"))
          (go         . ("https://github.com/tree-sitter/tree-sitter-go"))
          (bash       . ("https://github.com/tree-sitter/tree-sitter-bash"))
          (json       . ("https://github.com/tree-sitter/tree-sitter-json"))
          (yaml       . ("https://github.com/ikatyang/tree-sitter-yaml"))
          (toml       . ("https://github.com/tree-sitter-grammars/tree-sitter-toml"))
          (markdown   . ("https://github.com/tree-sitter-grammars/tree-sitter-markdown"))))

(use-package combobulate
  :hook ((prog-mode . combobulate-mode))
  :load-path ("/home/gnix/.config/emacs/combobulate"))

(global-set-key (kbd "C-c C-o") 'combobulate)

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
