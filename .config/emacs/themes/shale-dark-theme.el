;;; shale-dark-theme.el --- Shale Dark earthy theme -*- lexical-binding: t; -*-

;;; Commentary:
;; Lichen, weathered stone, and heather over blue charcoal.
;; Definitions carry an accent; function calls and variables stay neutral.
;; Paired with shale-light.

;;; Code:

;; Reuse Quiet's local Base16 engine and its package/tree-sitter face mappings.
;; Requiring the file defines Quiet Dark without enabling it.
(require 'quiet-dark-theme
         (expand-file-name "quiet-dark-theme.el"
                           (file-name-directory (or load-file-name buffer-file-name))))

(defconst shale-dark-theme-colors
  '(:base00 "#111416"
    :base01 "#1A2022"
    :base02 "#2D373A"
    :base03 "#59676B"
    :base0X "#92A3A5"
    :base04 "#A0B0B0"
    :base05 "#D7DEDC"
    :base06 "#E0E7E3"
    :base07 "#EDF1ED"
    :base08 "#C68F85"
    :base09 "#BDA384"
    :base0A "#B9B48E"
    :base0B "#A9B497"
    :base0C "#8FB4AD"
    :base0D "#95AEBB"
    :base0E "#B2A0B5"
    :base0F "#B39A8C"
    :syntax-comment "#8FA0A2"
    :syntax-keyword "#B7CAC4"
    :syntax-string "#C9CCB4"
    :syntax-type "#BECCD5"
    :syntax-function "#D3C9B4"
    :syntax-number "#C8B8C7"
    :syntax-operator "#A3B1B3"
    :syntax-escape "#C8B8C7"
    :syntax-constant "#C8B8C7"
    :syntax-special "#C8B8C7"
    :syntax-function-call "#D7DEDC"
    :syntax-variable "#D7DEDC"
    :syntax-property "#D7DEDC"
    :syntax-warning "#D0A29A")
  "Earthy palette for Shale Dark.")

(deftheme shale-dark
  "Lichen, weathered stone, and heather over blue charcoal.")

(base16-theme-define 'shale-dark shale-dark-theme-colors)
(provide-theme 'shale-dark)
(provide 'shale-dark-theme)

;;; shale-dark-theme.el ends here
