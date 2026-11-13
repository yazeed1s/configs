;;; shale-light-theme.el --- Shale Light earthy theme -*- lexical-binding: t; -*-

;;; Commentary:
;; Lichen, weathered stone, and heather on pale limestone.
;; Definitions carry an accent; function calls and variables stay neutral.
;; Paired with shale-dark.

;;; Code:

;; Reuse Quiet's local Base16 engine and its package/tree-sitter face mappings.
;; Requiring the file defines Quiet Dark without enabling it.
(require 'quiet-dark-theme
         (expand-file-name "quiet-dark-theme.el"
                           (file-name-directory (or load-file-name buffer-file-name))))

(defconst shale-light-theme-colors
  '(:base00 "#EDF1EE"
    :base01 "#E0E7E2"
    :base02 "#CAD7D2"
    :base03 "#84968F"
    :base0X "#5C716A"
    :base04 "#677C74"
    :base05 "#2C3C38"
    :base06 "#202E29"
    :base07 "#16231F"
    :base08 "#9C544B"
    :base09 "#88673F"
    :base0A "#746B35"
    :base0B "#5D6E46"
    :base0C "#3F7063"
    :base0D "#4C6C7C"
    :base0E "#7B607E"
    :base0F "#8C6752"
    :syntax-comment "#597369"
    :syntax-keyword "#416D60"
    :syntax-string "#656E3E"
    :syntax-type "#4C6C7C"
    :syntax-function "#7C663E"
    :syntax-number "#7B607E"
    :syntax-operator "#5C716A"
    :syntax-escape "#7B607E"
    :syntax-constant "#7B607E"
    :syntax-special "#7B607E"
    :syntax-function-call "#2C3C38"
    :syntax-variable "#2C3C38"
    :syntax-property "#2C3C38"
    :syntax-warning "#9C544B")
  "Earthy palette for Shale Light.")

(deftheme shale-light
  "Lichen, weathered stone, and heather on pale limestone.")

(base16-theme-define 'shale-light shale-light-theme-colors)
(provide-theme 'shale-light)
(provide 'shale-light-theme)

;;; shale-light-theme.el ends here
