;;; kiln-dark-theme.el --- Kiln Dark earthy theme -*- lexical-binding: t; -*-

;;; Commentary:
;; Terracotta, ash, and smoky olive over warm soot.
;; Definitions carry an accent; function calls and variables stay neutral.
;; Paired with kiln-light.

;;; Code:

;; Reuse Quiet's local Base16 engine and its package/tree-sitter face mappings.
;; Requiring the file defines Quiet Dark without enabling it.
(require 'quiet-dark-theme
         (expand-file-name "quiet-dark-theme.el"
                           (file-name-directory (or load-file-name buffer-file-name))))

(defconst kiln-dark-theme-colors
  '(:base00 "#151210"
    :base01 "#211B17"
    :base02 "#3A2D25"
    :base03 "#766053"
    :base0X "#A99283"
    :base04 "#B69E8E"
    :base05 "#E3D8CE"
    :base06 "#E9DDD2"
    :base07 "#F3E8DD"
    :base08 "#D48E79"
    :base09 "#C6A074"
    :base0A "#C6B28A"
    :base0B "#A5AD89"
    :base0C "#A0AAA0"
    :base0D "#A4A6B0"
    :base0E "#B99C9A"
    :base0F "#C8997B"
    :syntax-comment "#A09184"
    :syntax-keyword "#CEA493"
    :syntax-string "#C5C0A4"
    :syntax-type "#BABDB6"
    :syntax-function "#DDC5A9"
    :syntax-number "#CDB2AB"
    :syntax-operator "#B6A295"
    :syntax-escape "#CDB2AB"
    :syntax-constant "#CDB2AB"
    :syntax-special "#CDB2AB"
    :syntax-function-call "#E3D8CE"
    :syntax-variable "#E3D8CE"
    :syntax-property "#E3D8CE"
    :syntax-warning "#DBA290")
  "Earthy palette for Kiln Dark.")

(deftheme kiln-dark
  "Terracotta, ash, and smoky olive over warm soot.")

(base16-theme-define 'kiln-dark kiln-dark-theme-colors)
(provide-theme 'kiln-dark)
(provide 'kiln-dark-theme)

;;; kiln-dark-theme.el ends here
