;;; -*- lexical-binding: t -*-

(scroll-bar-mode -1)        ; Disable visible scrollbar
(tool-bar-mode -1)          ; Disable the toolbar
(tooltip-mode -1)           ; Disable tooltips
(menu-bar-mode -1)            ; Disable the menu bar

(setq visible-bell t) ;; Set up the visible bell

(set-face-attribute 'default nil :font "JetBrainsMono Nerd Font" :height 150)

; (load-theme 'modus-vivendi)
(load-theme 'tango-dark)

(setq inhibit-startup-message t)
