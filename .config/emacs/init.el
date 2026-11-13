;;; init.el -*- lexical-binding: t; -*-


(require 'package)

(setq package-archives
      '(("melpa"        . "https://melpa.org/packages/")
        ("melpa-stable" . "https://stable.melpa.org/packages/")
        ("gnu"          . "https://elpa.gnu.org/packages/")
        ("nongnu"       . "https://elpa.nongnu.org/nongnu/")))

;; With `package-quickstart', every install regenerates the quickstart file,
;; and that calls `package-initialize' again -> one "Unnecessary call to
;; package-initialize" warning per package on a first run. Regenerate it
;; once after startup instead.
(defvar yaz/package-quickstart-pending nil)
(define-advice package--quickstart-maybe-refresh (:around (fn) yaz-defer-during-init)
  (if after-init-time
      (funcall fn)
    (setq yaz/package-quickstart-pending t)))
(add-hook 'after-init-hook
          (lambda ()
            (when yaz/package-quickstart-pending
              (package-quickstart-refresh))))

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
 '(package-vc-selected-packages
   '((odin-mode :url "https://github.com/mattt-b/odin-mode")
	 (agent-review :url "https://github.com/nineluj/agent-review")
	 (agent-shell-manager :url
						  "https://github.com/jethrokuan/agent-shell-manager"))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(agent-shell-buffer-name ((t :inherit font-lock-variable-name-face)))
 '(agent-shell-chat-agent-label ((t :inherit (bold font-lock-function-name-face) :inverse-video t :box t)))
 '(agent-shell-chat-me-label ((t :inherit (bold font-lock-keyword-face) :inverse-video t :box t)))
 '(agent-shell-diff-changes-label ((((type graphic)) :inherit diff-hunk-header :box t) (t :inherit diff-hunk-header :inverse-video t)))
 '(agent-shell-error ((t :inherit error)))
 '(agent-shell-input ((t :inherit comint-highlight-input)))
 '(agent-shell-key-binding ((t :inherit help-key-binding)))
 '(agent-shell-link ((t :inherit link)))
 '(agent-shell-markdown-blockquote ((t :inherit font-lock-comment-face)))
 '(agent-shell-markdown-bold ((t :inherit bold)))
 '(agent-shell-markdown-header-1 ((t :inherit org-level-1)))
 '(agent-shell-markdown-header-2 ((t :inherit org-level-2)))
 '(agent-shell-markdown-header-3 ((t :inherit org-level-3)))
 '(agent-shell-markdown-header-4 ((t :inherit org-level-4)))
 '(agent-shell-markdown-header-5 ((t :inherit org-level-5)))
 '(agent-shell-markdown-header-6 ((t :inherit org-level-6)))
 '(agent-shell-markdown-inline-code ((t :inherit org-code)))
 '(agent-shell-markdown-italic ((t :inherit italic)))
 '(agent-shell-markdown-link ((t :inherit link)))
 '(agent-shell-markdown-list-done ((t :inherit shadow :strike-through t)))
 '(agent-shell-markdown-list-marker ((t :inherit default)))
 '(agent-shell-markdown-source-block ((t :inherit org-block :foreground unspecified :extend t)))
 '(agent-shell-markdown-source-block-language ((t :inherit (italic font-lock-type-face agent-shell-markdown-source-block))))
 '(agent-shell-markdown-strikethrough ((t :strike-through t)))
 '(agent-shell-markdown-table ((t nil)))
 '(agent-shell-markdown-table-border ((t :inherit (agent-shell-markdown-table font-lock-comment-face))))
 '(agent-shell-markdown-table-header ((t :inherit (bold agent-shell-markdown-table))))
 '(agent-shell-markdown-table-zebra ((t :inherit (lazy-highlight agent-shell-markdown-table))))
 '(agent-shell-model ((t :inherit font-lock-negation-char-face)))
 '(agent-shell-pending ((t :inherit font-lock-comment-face)))
 '(agent-shell-permission-title ((t :inherit bold)))
 '(agent-shell-prompt ((t :inherit comint-highlight-prompt)))
 '(agent-shell-secondary ((t :inherit font-lock-comment-face)))
 '(agent-shell-section-annotation ((t :inherit font-lock-doc-face)))
 '(agent-shell-section-heading ((t :inherit font-lock-doc-markup-face)))
 '(agent-shell-success ((t :inherit success)))
 '(agent-shell-thought-body ((t)))
 '(agent-shell-thought-level ((t :inherit font-lock-keyword-face)))
 '(agent-shell-warning ((t :inherit warning)))
 '(font-lock-builtin-face ((t (:slant normal))))
 '(font-lock-constant-face ((t (:slant normal))))
 '(font-lock-function-name-face ((t (:slant normal))))
 '(font-lock-keyword-face ((t (:slant normal))))
 '(font-lock-string-face ((t (:slant normal))))
 '(font-lock-type-face ((t (:slant normal))))
 '(font-lock-variable-name-face ((t (:slant normal))))
 '(mode-line ((t :height 0.98 :box (:line-width 2 :style flat-button))))
 '(mode-line-active ((t :height 0.98 :box (:line-width 2 :style flat-button))))
 '(mode-line-inactive ((t :height 0.98 :box (:line-width 2 :style flat-button)))))
