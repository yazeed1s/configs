;;; kiln-light-theme.el --- Kiln Light earthy theme -*- lexical-binding: t; -*-

;;; Commentary:
;; Fired clay, ash, and olive on pale plaster.
;; Definitions carry an accent; function calls and variables stay neutral.
;; Paired with kiln-dark.

;;; Code:

;; Reuse Quiet's local Base16 engine and its package/tree-sitter face mappings.
;; Requiring the file defines Quiet Dark without enabling it.
(require 'quiet-dark-theme
         (expand-file-name "quiet-dark-theme.el"
                           (file-name-directory (or load-file-name buffer-file-name))))

(defconst kiln-light-theme-colors
  '(:base00 "#F5EDE5"
    :base01 "#EADDD1"
    :base02 "#DCC7B7"
    :base03 "#9B8070"
    :base0X "#7B6253"
    :base04 "#806B5D"
    :base05 "#43342B"
    :base06 "#32261F"
    :base07 "#231A15"
    :base08 "#A24F3D"
    :base09 "#8E6436"
    :base0A "#80662F"
    :base0B "#636D42"
    :base0C "#526E61"
    :base0D "#646A7A"
    :base0E "#855F69"
    :base0F "#9B6241"
    :syntax-comment "#816757"
    :syntax-keyword "#9B563F"
    :syntax-string "#696B3F"
    :syntax-type "#526E61"
    :syntax-function "#855C2D"
    :syntax-number "#855F69"
    :syntax-operator "#7B6253"
    :syntax-escape "#855F69"
    :syntax-constant "#855F69"
    :syntax-special "#855F69"
    :syntax-function-call "#43342B"
    :syntax-variable "#43342B"
    :syntax-property "#43342B"
    :syntax-warning "#A24F3D")
  "Earthy palette for Kiln Light.")

(deftheme kiln-light
  "Fired clay, ash, and olive on pale plaster.")

(base16-theme-define 'kiln-light kiln-light-theme-colors)
(provide-theme 'kiln-light)
(provide 'kiln-light-theme)

;;; kiln-light-theme.el ends here
