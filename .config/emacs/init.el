;;; init.el -*- lexical-binding: t; -*-


(require 'package)

(setq package-archives
      '(("melpa"        . "https://melpa.org/packages/")
        ("melpa-stable" . "https://stable.melpa.org/packages/")
        ("gnu"          . "https://elpa.gnu.org/packages/")
        ("nongnu"       . "https://elpa.nongnu.org/nongnu/")))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)

(setq use-package-always-ensure t
      use-package-verbose nil
      use-package-compute-statistics t    ; Enable to diagnose - run M-x use-package-report
      use-package-expand-minimally t)

;; (setq package-vc-allow-build-commands t)
;; (use-package reader
;;   :defer t
;;   :vc (:url "https://codeberg.org/divyaranjan/emacs-reader"
;; 			:make "all"))

(defvar yaz/config-dir (expand-file-name "configs" user-emacs-directory)
  "where the config modules live")

(add-to-list 'load-path yaz/config-dir)

(defvar yaz/lisp-dir (expand-file-name "lisp" user-emacs-directory)
  "where my custom functions live")

(add-to-list 'load-path yaz/lisp-dir)

;; load everything
;; order matters here
(require 'core)
(require 'completion)
(require 'ai)
(require 'lib)
(require 'proc-manager)
(require 'ui)
(require 'keybindings)
(require 'git-config)
;; (require 'lsp-config)
(require 'eglot-config)
(require 'writing)
;; (require 'inhibit-mouse-config)
(require 'org-config)
(require 'session-config)

(setq custom-file (expand-file-name "custom.el" user-emacs-directory))

(when (file-exists-p custom-file)
  (load custom-file 'noerror 'nomessage))

(message "loaded in %.2fs with %d gc runs"
         (float-time (time-subtract after-init-time before-init-time))
         gcs-done)

;;; init.el ends here
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-vc-selected-packages '((odin-mode :url "https://github.com/mattt-b/odin-mode"))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(font-lock-builtin-face ((t (:slant normal))))
 '(font-lock-constant-face ((t (:slant normal))))
 '(font-lock-function-name-face ((t (:slant normal))))
 '(font-lock-keyword-face ((t (:slant normal))))
 '(font-lock-string-face ((t (:slant normal))))
 '(font-lock-type-face ((t (:slant normal))))
 '(font-lock-variable-name-face ((t (:slant normal)))))
