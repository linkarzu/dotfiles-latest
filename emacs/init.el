;;; -*- lexical-binding: t -*-
(setq custom-file (locate-user-emacs-file "custom.el"))
(load custom-file t)
      
(scroll-bar-mode -1)        ; Disable visible scrollbar
(tool-bar-mode -1)          ; Disable the toolbar
(tooltip-mode -1)           ; Disable tooltips
(menu-bar-mode -1)            ; Disable the menu bar

(setq visible-bell nil) ;; Set up the visible bell

(set-face-attribute 'default nil :font "JetBrainsMono Nerd Font" :height 150)

(load-theme 'modus-vivendi)
;(load-theme 'tango-dark)

(setq inhibit-startup-message t)

(setq mouse-drag-copy-region t)

(use-package vertico
  :ensure t
  :config
  (vertico-mode 1))

(use-package marginalia
  :ensure t
  :config
  (marginalia-mode 1))

(use-package savehist
  :ensure nil
  :config
  (savehist-mode 1))

(use-package orderless
  :ensure t
  :config
  (setq completion-styles '(orderless basic))
  (setq completion-category-defaults nil))

(use-package delsel
  :ensure nil
  :config
  (delete-selection-mode 1))
