;;; oh-lucy-theme.el --- Oh Lucy with pastel blue -*- lexical-binding: t; -*-

;;; Commentary:
;; Emacs adaptation of Yazeed1s/oh-lucy.nvim:
;; https://github.com/Yazeed1s/oh-lucy.nvim
;; Palette: lua/oh-lucy/colors.lua; syntax roles: lua/oh-lucy/theme.lua.
;; Local changes: softer blue (#8DBBD3 -> #B3CCE0), brighter comments and
;; punctuation, and subdued panel-colored window dividers via Quiet's engine.

;;; Code:

(require 'quiet-dark-theme
         (expand-file-name "quiet-dark-theme.el"
                           (file-name-directory (or load-file-name buffer-file-name))))

(defconst oh-lucy-theme-colors
  '(:base00 "#1B1D26"
    :base01 "#14161D"
    :base02 "#343842"
    :base03 "#606978"
    :base0X "#A4A7B5"
    :base04 "#A4A7B5"
    :base05 "#D7D7D7"
    :base06 "#E9E9E9"
    :base07 "#F3F3F3"
    :base08 "#FB7DA7"
    :base09 "#E39A65"
    :base0A "#E3CF65"
    :base0B "#76C5A4"
    :base0C "#6CAEC0"
    :base0D "#B3CCE0"
    :base0E "#BDA9D4"
    :base0F "#E0828D"
    :syntax-comment "#8A8E9F"
    :syntax-keyword "#FB7DA7"
    :syntax-operator "#A4A7B5"
    :syntax-string "#E3CF65"
    :syntax-escape "#BDA9D4"
    :syntax-number "#E0828D"
    :syntax-constant "#BDA9D4"
    :syntax-special "#AF98E6"
    :syntax-type "#B3CCE0"
    :syntax-function "#74C7A4"
    :syntax-function-call "#74C7A4"
    :syntax-variable "#D7D7D7"
    :syntax-property "#D7D7D7"
    :syntax-warning "#E39A65")
  "Oh Lucy palette with pastel blue and readable secondary syntax.")

(deftheme oh-lucy
  "Oh Lucy: blue-black, pink, mint, yellow, lavender, and pastel blue.")
(base16-theme-define 'oh-lucy oh-lucy-theme-colors)
(provide-theme 'oh-lucy)
(provide 'oh-lucy-theme)

;;; oh-lucy-theme.el ends here
