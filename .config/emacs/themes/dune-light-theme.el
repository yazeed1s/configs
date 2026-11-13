;;; dune-light-theme.el --- Dune Light earthy theme -*- lexical-binding: t; -*-

;;; Commentary:
;; Dry grass, ochre, and dusty rose on sun-bleached linen.
;; Definitions carry an accent; function calls and variables stay neutral.
;; Paired with dune-dark.

;;; Code:

;; Reuse Quiet's local Base16 engine and its package/tree-sitter face mappings.
;; Requiring the file defines Quiet Dark without enabling it.
(require 'quiet-dark-theme
         (expand-file-name "quiet-dark-theme.el"
                           (file-name-directory (or load-file-name buffer-file-name))))

(defconst dune-light-theme-colors
  '(:base00 "#F6F0DF"
    :base01 "#EAE1CA"
    :base02 "#DDD0AF"
    :base03 "#9C8C64"
    :base0X "#796D4D"
    :base04 "#847653"
    :base05 "#433C29"
    :base06 "#312B1D"
    :base07 "#221D12"
    :base08 "#A0533C"
    :base09 "#8A622D"
    :base0A "#80682C"
    :base0B "#63713F"
    :base0C "#526F54"
    :base0D "#626F69"
    :base0E "#825E6B"
    :base0F "#946543"
    :syntax-comment "#7C6C49"
    :syntax-keyword "#806628"
    :syntax-string "#63713F"
    :syntax-type "#526F54"
    :syntax-function "#8B603A"
    :syntax-number "#825E6B"
    :syntax-operator "#786C4C"
    :syntax-escape "#825E6B"
    :syntax-constant "#825E6B"
    :syntax-special "#825E6B"
    :syntax-function-call "#433C29"
    :syntax-variable "#433C29"
    :syntax-property "#433C29"
    :syntax-warning "#A0533C")
  "Earthy palette for Dune Light.")

(deftheme dune-light
  "Dry grass, ochre, and dusty rose on sun-bleached linen.")

(base16-theme-define 'dune-light dune-light-theme-colors)
(provide-theme 'dune-light)
(provide 'dune-light-theme)

;;; dune-light-theme.el ends here
