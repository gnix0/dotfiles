;;; init.el -*- lexical-binding: t; -*-

(doom!
 :completion
 company
 vertico

 :ui
 doom
 doom-dashboard
 hl-todo
 modeline
 ophints
 (popup +defaults)
 (vc-gutter +pretty)
 vi-tilde-fringe
 workspaces

 :editor
 (evil +everywhere)
 file-templates
 fold
 (format +onsave)
 snippets

 :emacs
 dired
 electric
 undo
 vc

 :term
 vterm

 :checkers
 syntax
 (spell +flyspell)

 :tools
 ansible
 (eval +overlay)
 (lookup +dictionary +offline +docsets)
 lsp
 magit
 terraform
 tree-sitter

 :lang
 (cc +lsp +treesitter)
 elixir
 (elm +lsp +treesitter)
 (emacs-lisp +lsp +treesitter)
 (go +lsp +treesitter)
 json
 (java +lsp +treesitter)
 kotlin
 latex
 (lua +lsp +treesitter)
 markdown
 nix
 org
 (ruby +rails +lsp +treesitter)
 (rust +lsp +treesitter)
 sh
 yaml
 (zig +lsp)

 :app
 (rss +org)

 :config
 (default +bindings +smartparens))
