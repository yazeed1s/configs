;;; peat-light-theme.el --- Peat Light earthy theme -*- lexical-binding: t; -*-

;;; Commentary:
;; Olive, bark, and dried leaves on pale oat paper.
;; Definitions carry an accent; function calls and variables stay neutral.
;; Paired with peat-dark.

;;; Code:

;; Reuse Quiet's local Base16 engine and its package/tree-sitter face mappings.
;; Requiring the file defines Quiet Dark without enabling it.
(require 'quiet-dark-theme
         (expand-file-name "quiet-dark-theme.el"
                           (file-name-directory (or load-file-name buffer-file-name))))

(defconst peat-light-theme-colors
  '(:base00 "#F1F0E6"
    :base01 "#E6E6D9"
    :base02 "#D5D9C4"
    :base03 "#8B907D"
    :base0X "#686E5D"
    :base04 "#727966"
    :base05 "#33382D"
    :base06 "#252A21"
    :base07 "#191E17"
    :base08 "#9D5143"
    :base09 "#876337"
    :base0A "#75662D"
    :base0B "#566C3D"
    :base0C "#466D59"
    :base0D "#536A6E"
    :base0E "#78606A"
    :base0F "#8C6242"
    :syntax-comment "#6A7059"
    :syntax-keyword "#586D3E"
    :syntax-string "#6B672F"
    :syntax-type "#466D59"
    :syntax-function "#795D31"
    :syntax-number "#8C6242"
    :syntax-operator "#686E5D"
    :syntax-escape "#8C6242"
    :syntax-constant "#8C6242"
    :syntax-special "#8C6242"
    :syntax-function-call "#33382D"
    :syntax-variable "#33382D"
    :syntax-property "#33382D"
    :syntax-warning "#9D5143")
  "Earthy palette for Peat Light.")

(deftheme peat-light
  "Olive, bark, and dried leaves on pale oat paper.")

(base16-theme-define 'peat-light peat-light-theme-colors)
(provide-theme 'peat-light)
(provide 'peat-light-theme)

;;; peat-light-theme.el ends here
