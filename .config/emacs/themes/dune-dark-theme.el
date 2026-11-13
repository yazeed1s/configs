;;; dune-dark-theme.el --- Dune Dark earthy theme -*- lexical-binding: t; -*-

;;; Commentary:
;; Dry grass, ochre, and dusty rose over blackened sand.
;; Definitions carry an accent; function calls and variables stay neutral.
;; Paired with dune-light.

;;; Code:

;; Reuse Quiet's local Base16 engine and its package/tree-sitter face mappings.
;; Requiring the file defines Quiet Dark without enabling it.
(require 'quiet-dark-theme
         (expand-file-name "quiet-dark-theme.el"
                           (file-name-directory (or load-file-name buffer-file-name))))

(defconst dune-dark-theme-colors
  '(:base00 "#171612"
    :base01 "#222018"
    :base02 "#3B3627"
    :base03 "#756B51"
    :base0X "#A79D83"
    :base04 "#B5AA90"
    :base05 "#DBD2BC"
    :base06 "#E9E0CC"
    :base07 "#F4EDD9"
    :base08 "#C88E78"
    :base09 "#C2A06D"
    :base0A "#C4B27B"
    :base0B "#ABB18B"
    :base0C "#A1B19E"
    :base0D "#A6ADAA"
    :base0E "#B59D9D"
    :base0F "#C4A087"
    :syntax-comment "#90866D"
    :syntax-keyword "#C6B078"
    :syntax-string "#B3BB96"
    :syntax-type "#A2B3A1"
    :syntax-function "#C9AA8D"
    :syntax-number "#BAA0A5"
    :syntax-operator "#A79D83"
    :syntax-escape "#BAA0A5"
    :syntax-constant "#BAA0A5"
    :syntax-special "#BAA0A5"
    :syntax-function-call "#DBD2BC"
    :syntax-variable "#DBD2BC"
    :syntax-property "#DBD2BC"
    :syntax-warning "#C88E78")
  "Earthy palette for Dune Dark.")

(deftheme dune-dark
  "Dry grass, ochre, and dusty rose over blackened sand.")

(base16-theme-define 'dune-dark dune-dark-theme-colors)
(provide-theme 'dune-dark)
(provide 'dune-dark-theme)

;;; dune-dark-theme.el ends here
