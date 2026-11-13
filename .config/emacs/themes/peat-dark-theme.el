;;; peat-dark-theme.el --- Peat Dark earthy theme -*- lexical-binding: t; -*-

;;; Commentary:
;; Olive, bark, and dried leaves over peat-black.
;; Definitions carry an accent; function calls and variables stay neutral.
;; Paired with peat-light.

;;; Code:

;; Reuse Quiet's local Base16 engine and its package/tree-sitter face mappings.
;; Requiring the file defines Quiet Dark without enabling it.
(require 'quiet-dark-theme
         (expand-file-name "quiet-dark-theme.el"
                           (file-name-directory (or load-file-name buffer-file-name))))

(defconst peat-dark-theme-colors
  '(:base00 "#10110F"
    :base01 "#191C17"
    :base02 "#30362A"
    :base03 "#606657"
    :base0X "#969B8C"
    :base04 "#A8AD9E"
    :base05 "#DADDD1"
    :base06 "#E0E3D5"
    :base07 "#ECEEE3"
    :base08 "#C28D79"
    :base09 "#BCA079"
    :base0A "#B5B17D"
    :base0B "#A3B18A"
    :base0C "#8EA99A"
    :base0D "#96A6AA"
    :base0E "#AC9C96"
    :base0F "#B39478"
    :syntax-comment "#909586"
    :syntax-keyword "#BAC5A3"
    :syntax-string "#C8C5A5"
    :syntax-type "#A8BAAF"
    :syntax-function "#D2C4A6"
    :syntax-number "#C7B09A"
    :syntax-operator "#A5A99C"
    :syntax-escape "#C7B09A"
    :syntax-constant "#C7B09A"
    :syntax-special "#C7B09A"
    :syntax-function-call "#DADDD1"
    :syntax-variable "#DADDD1"
    :syntax-property "#DADDD1"
    :syntax-warning "#CC9F8E")
  "Earthy palette for Peat Dark.")

(deftheme peat-dark
  "Olive, bark, and dried leaves over peat-black.")

(base16-theme-define 'peat-dark peat-dark-theme-colors)
(provide-theme 'peat-dark)
(provide 'peat-dark-theme)

;;; peat-dark-theme.el ends here
