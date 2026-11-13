;;; eglot-config.el -*- lexical-binding: t; -*-


(setq read-process-output-max 
  (* 1024 1024)) 

(use-package eglot 
  :ensure t 
  :defer t 
  :commands 
    (eglot eglot-ensure) 
  :config 
    (setq eglot-events-buffer-size 0 eglot-autoshutdown t eglot-sync-connect nil eglot-connect-timeout 30 eglot-send-changes-idle-time 0.5) 
    (setq eglot-code-action-indications nil)
    (setq eglot-ignored-server-capabilities '(:documentHighlightProvider :inlayHintProvider)) 
    (setq eldoc-echo-area-use-multiline-p t) 
  :hook 
    (eglot-managed-mode . 
      (lambda () 
        (setq-local eldoc-documentation-function #'eldoc-documentation-compose)))) 

(add-hook 'eglot-managed-mode-hook 
  (lambda () 
    (add-hook 'before-save-hook #'eglot-format nil t)))

;;; Built-in tree-sitter (treesit)
;; Emacs 31 ships pinned grammar recipes and remaps classic modes
;; (c-mode, go-mode, rust-mode, python-mode, js-mode, ...) to their *-ts-mode
;; when the grammar is installed. Grammars live in ~/.config/emacs/tree-sitter/.
;; Install a missing one with M-x treesit-install-language-grammar.
;; No built-in ts mode yet for: zig, odin, svelte, scss, web-mode -> those keep
;; their regular font-lock modes.
;; Same effect as (setopt treesit-enabled-modes t), whose :set just copies the
;; preloaded `treesit-major-mode-remap-alist' into `major-mode-remap-alist'.
;; Doing it by hand avoids loading treesit.el at startup (~0.05s).
(setq treesit-enabled-modes t)
(when (treesit-available-p)
  (dolist (m treesit-major-mode-remap-alist)
    (add-to-list 'major-mode-remap-alist m))
  ;; not covered by the built-in list
  (dolist (m '((js-mode . js-ts-mode)
               (javascript-mode . js-ts-mode)
               (json-mode . json-ts-mode)
               (js-json-mode . json-ts-mode)))
    (add-to-list 'major-mode-remap-alist m))
  (add-to-list 'auto-mode-alist '("\\.tsx\\'" . tsx-ts-mode)))

;; *-ts-mode buffers need their own eglot hooks
(dolist (hook '(c-ts-mode-hook c++-ts-mode-hook go-ts-mode-hook rust-ts-mode-hook
                python-ts-mode-hook typescript-ts-mode-hook tsx-ts-mode-hook
                js-ts-mode-hook json-ts-mode-hook css-ts-mode-hook))
  (add-hook hook #'eglot-ensure))

;;; Old third-party tree-sitter (elisp-tree-sitter), replaced by treesit above.
;; Kept commented out for reference / easy rollback.
;; (use-package tree-sitter
;;   :ensure t
;;   :defer t
;;   :hook
;;     (prog-mode . (lambda ()
;;                    (condition-case nil
;;                        (tree-sitter-mode)
;;                      (error nil))))
;;   :config
;;     (add-hook 'tree-sitter-after-on-hook
;;               (lambda ()
;;                 (condition-case nil
;;                     (tree-sitter-hl-mode)
;;                   (error nil)))))
;;
;; (use-package tree-sitter-langs
;;   :ensure t
;;   :after tree-sitter
;;   :config
;;     (add-to-list 'tree-sitter-major-mode-language-alist '(c-mode . c))
;;     (add-to-list 'tree-sitter-major-mode-language-alist '(c++-mode . cpp))
;;     (add-to-list 'tree-sitter-major-mode-language-alist '(rust-mode . rust))
;;     (add-to-list 'tree-sitter-major-mode-language-alist '(go-mode . go))
;;     (add-to-list 'tree-sitter-major-mode-language-alist '(zig-mode . zig))
;;     (add-to-list 'tree-sitter-major-mode-language-alist '(odin-mode . odin))
;;     (add-to-list 'tree-sitter-major-mode-language-alist '(python-mode . python))
;;     (add-to-list 'tree-sitter-major-mode-language-alist '(ruby-mode . ruby))
;;     (add-to-list 'tree-sitter-major-mode-language-alist '(perl-mode . perl))
;;     (add-to-list 'tree-sitter-major-mode-language-alist '(lua-mode . lua))
;;     (add-to-list 'tree-sitter-major-mode-language-alist '(sh-mode . bash))
;;     (add-to-list 'tree-sitter-major-mode-language-alist '(bash-mode . bash))
;;     (add-to-list 'tree-sitter-major-mode-language-alist '(fish-mode . fish))
;;     (add-to-list 'tree-sitter-major-mode-language-alist '(typescript-mode . typescript))
;;     (add-to-list 'tree-sitter-major-mode-language-alist '(typescript-tsx-mode . tsx))
;;     (add-to-list 'tree-sitter-major-mode-language-alist '(js-mode . javascript))
;;     (add-to-list 'tree-sitter-major-mode-language-alist '(javascript-mode . javascript))
;;     (add-to-list 'tree-sitter-major-mode-language-alist '(json-mode . json))
;;     (add-to-list 'tree-sitter-major-mode-language-alist '(css-mode . css))
;;     (add-to-list 'tree-sitter-major-mode-language-alist '(scss-mode . scss))
;;     (add-to-list 'tree-sitter-major-mode-language-alist '(html-mode . html))
;;     (add-to-list 'tree-sitter-major-mode-language-alist '(web-mode . html))
;;     (add-to-list 'tree-sitter-major-mode-language-alist '(svelte-mode . svelte))
;;     (add-to-list 'tree-sitter-major-mode-language-alist '(java-mode . java))
;;     (add-to-list 'tree-sitter-major-mode-language-alist '(kotlin-mode . kotlin))
;;     (add-to-list 'tree-sitter-major-mode-language-alist '(scala-mode . scala))
;;     (add-to-list 'tree-sitter-major-mode-language-alist '(clojure-mode . clojure))
;;     (add-to-list 'tree-sitter-major-mode-language-alist '(groovy-mode . groovy))
;;     (add-to-list 'tree-sitter-major-mode-language-alist '(haskell-mode . haskell))
;;     (add-to-list 'tree-sitter-major-mode-language-alist '(ocaml-mode . ocaml))
;;     (add-to-list 'tree-sitter-major-mode-language-alist '(tuareg-mode . ocaml))
;;     (add-to-list 'tree-sitter-major-mode-language-alist '(elm-mode . elm))
;;     (add-to-list 'tree-sitter-major-mode-language-alist '(elixir-mode . elixir))
;;     (add-to-list 'tree-sitter-major-mode-language-alist '(erlang-mode . erlang))
;;     (add-to-list 'tree-sitter-major-mode-language-alist '(racket-mode . racket))
;;     (add-to-list 'tree-sitter-major-mode-language-alist '(scheme-mode . scheme))
;;     (add-to-list 'tree-sitter-major-mode-language-alist '(julia-mode . julia))
;;     (add-to-list 'tree-sitter-major-mode-language-alist '(ess-r-mode . r))
;;     (add-to-list 'tree-sitter-major-mode-language-alist '(r-mode . r))
;;     (add-to-list 'tree-sitter-major-mode-language-alist '(swift-mode . swift))
;;     (add-to-list 'tree-sitter-major-mode-language-alist '(dart-mode . dart))
;;     (add-to-list 'tree-sitter-major-mode-language-alist '(yaml-mode . yaml))
;;     (add-to-list 'tree-sitter-major-mode-language-alist '(toml-mode . toml))
;;     (add-to-list 'tree-sitter-major-mode-language-alist '(cmake-mode . cmake))
;;     (add-to-list 'tree-sitter-major-mode-language-alist '(dockerfile-mode . dockerfile))
;;     (add-to-list 'tree-sitter-major-mode-language-alist '(makefile-mode . make)))
;;
;; (with-eval-after-load 'tree-sitter-hl
;;   ;; The bundled Rust query omits several punctuation nodes, so they otherwise
;;   ;; fall back to the default foreground instead of the bracket face.
;;   (tree-sitter-hl-add-patterns
;;    'rust
;;    "[\"(\" \")\" \"[\" \"]\" \"{\" \"}\" \"|\" \"=>\" \"->\" \",\" \"_\"] @punctuation.bracket")
;;   ;; The bundled Go query does not capture punctuation at all.
;;   (tree-sitter-hl-add-patterns
;;    'go
;;    "[\"(\" \")\" \"[\" \"]\" \"{\" \"}\" \",\" \".\" \":\" \";\"] @punctuation.bracket"))

(defconst yaz/rust-punctuation-regexp
  (concat "\\(?:=>\\|->\\|[(){}|,]\\|\\[\\|\\]\\|"
          "\\_<" (regexp-quote "_") "\\_>\\)")
  "Rust punctuation that should use the same face as brackets.")

(defun yaz/rust-font-lock-punctuation ()
  "Highlight uncaptured Rust punctuation like brackets."
  (font-lock-add-keywords
   nil `((,yaz/rust-punctuation-regexp 0 'font-lock-bracket-face t)) 'append))

(add-hook 'rust-mode-hook #'yaz/rust-font-lock-punctuation)
(add-hook 'rust-ts-mode-hook #'yaz/rust-font-lock-punctuation)

(defconst yaz/go-punctuation-regexp
  "\\(?:[(){}.,:;]\\|\\[\\|\\]\\)"
  "Go punctuation that should use the same face as operators.")

(defun yaz/go-font-lock-punctuation ()
  "Highlight Go punctuation like operators."
  (font-lock-add-keywords
   nil `((,yaz/go-punctuation-regexp 0 'font-lock-operator-face t)) 'append))

(add-hook 'go-mode-hook #'yaz/go-font-lock-punctuation)
(add-hook 'go-ts-mode-hook #'yaz/go-font-lock-punctuation)

;; ;; auto-rebuild odin tree-sitter grammar if missing after tree-sitter-langs updates
;; (with-eval-after-load 'tree-sitter-langs
;;   (let ((grammar (expand-file-name "bin/odin.so" (file-name-directory (locate-library "tree-sitter-langs")))))
;;     (unless (file-exists-p grammar)
;;       (let ((script (expand-file-name "scripts/build-odin-ts-grammar.sh" user-emacs-directory)))
;;         (when (file-executable-p script)
;;           (message "odin tree-sitter grammar missing, rebuilding...")
;;           (set-process-sentinel
;;            (start-process "build-odin-ts" "*build-odin-ts*" script)
;;            (lambda (proc event)
;;              (if (eq (process-exit-status proc) 0)
;;                  (message "odin tree-sitter grammar rebuilt successfully")
;;                (message "odin tree-sitter grammar build failed, check *build-odin-ts* buffer")))))))))

(add-hook 'c-mode-hook #'eglot-ensure) 
(add-hook 'c++-mode-hook #'eglot-ensure) 

(use-package disaster 
  :ensure t 
  :defer t 
  :commands disaster 
  :init 
    (setq disaster-assembly-mode 'nasm-mode)) 

(use-package go-mode 
  :ensure t 
  :defer t 
  :mode "\\.go\\'" 
  :hook 
    (go-mode . eglot-ensure)) 

(use-package python-mode 
  :ensure t 
  :defer t 
  :mode "\\.py\\'" 
  :hook 
    (python-mode . eglot-ensure) 
  :config 
    (setq python-shell-interpreter "python3")) 

(use-package typescript-mode 
  :ensure t 
  :defer t 
  :mode 
    "\\.ts\\'"
  :hook 
    (typescript-mode . eglot-ensure) 
  :config 
    (setq typescript-indent-level 4)) 

(add-hook 'js-mode-hook #'eglot-ensure) 

(setq js-indent-level 4) 

(use-package web-mode 
  :ensure t 
  :defer t 
  :mode 
    ("\\.html\\'" "\\.htm\\'" "\\.vue\\'" "\\.jsx\\'" "\\.erb\\'" "\\.hbs\\'" "\\.mustache\\'" "\\.djhtml\\'" "\\.twig\\'" "\\.jinja2?\\'") 
  :hook 
    (web-mode . eglot-ensure) 
  :config 
    (setq web-mode-markup-indent-offset 4 web-mode-css-indent-offset 4 web-mode-code-indent-offset 4 web-mode-enable-auto-pairing t web-mode-enable-auto-closing t web-mode-enable-current-element-highlight t web-mode-enable-current-column-highlight t)) 

(use-package svelte-mode 
  :ensure t 
  :defer t 
  :mode "\\.svelte\\'" 
  :hook 
  (svelte-mode . eglot-ensure)) 

(use-package json-mode 
  :ensure t 
  :defer t 
  :mode 
    ("\\.json\\'" "\\.jsonc\\'") 
  :hook 
    (json-mode . eglot-ensure) 
  :config 
    (setq json-reformat:indent-width 4)) 

(add-hook 'css-mode-hook #'eglot-ensure) 

(setq css-indent-offset 4) 

(use-package scss-mode 
  :ensure t 
  :defer t 
  :mode "\\.scss\\'" 
  :hook 
    (scss-mode . eglot-ensure)) 

(use-package rust-mode
  :ensure t
  :defer t
  :mode "\\.rs\\'"
  :hook
    (rust-mode . eglot-ensure)
  :config
    (setq rust-format-on-save nil))  ; eglot handles formatting via format-on-save hook above

(use-package zig-mode
  :ensure t
  :defer t
  :mode "\\.zig\\'"
  :hook
    (zig-mode . eglot-ensure)
  :config
    (setq zig-format-on-save nil))  ; eglot handles formatting

(use-package odin-mode
  :ensure t
  :defer t
  :vc (:url "https://github.com/mattt-b/odin-mode")
  :mode "\\.odin\\'"
  :hook
    (odin-mode . eglot-ensure))

(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               '(odin-mode . ("ols"))))

(setq TeX-source-correlate-mode t TeX-source-correlate-method 'synctex) 

(use-package flymake :ensure nil :hook 
  (prog-mode . flymake-mode) :config 
  (setq flymake-no-changes-timeout 0.5) 
  (setq flymake-fringe-indicator-position 'right-fringe))

(provide 'eglot-config) 
;;;;; eglot-config.el ends here
