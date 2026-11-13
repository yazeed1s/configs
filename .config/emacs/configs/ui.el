;;; ui.el -*- lexical-binding: t; -*-

;;; ui.el --- UI settings -*- lexical-binding: t; -*-

;;; Code:



(global-display-line-numbers-mode 1)
(setq display-line-numbers-type 'relative)

(global-visual-line-mode 1)
(column-number-mode 1)
(pixel-scroll-mode 1)
(pixel-scroll-precision-mode t)

(electric-pair-mode 1)
(add-to-list 'default-frame-alist '(alpha-background . 96))
(set-face-italic 'italic nil)
(setq-default indicate-empty-lines t)
(define-fringe-bitmap 'tilde [0 0 0 113 219 142 0 0] nil nil 'center)
(setcdr (assq 'empty-line fringe-indicator-alist) 'tilde)
(set-fringe-bitmap-face 'tilde 'font-lock-comment-face)

(set-face-attribute 'default nil
                    :family "jetbrainsmono nf"
                    :height 100
                    :weight 'regular)

(fringe-mode 0)

(custom-set-faces
 '(font-lock-keyword-face ((t (:slant normal))))
 '(font-lock-type-face ((t (:slant normal))))
 '(font-lock-variable-name-face ((t (:slant normal))))
 '(font-lock-function-name-face ((t (:slant normal))))
 '(font-lock-builtin-face ((t (:slant normal))))
 '(font-lock-constant-face ((t (:slant normal))))
 '(font-lock-string-face ((t (:slant normal)))))

(custom-theme-set-faces
 'user
 '(mode-line          ((t :height 0.98 :box (:line-width 2 :style flat-button))))
 '(mode-line-active   ((t :height 0.98 :box (:line-width 2 :style flat-button))))
 '(mode-line-inactive ((t :height 0.98 :box (:line-width 2 :style flat-button)))))


(add-to-list 'custom-theme-load-path "~/.config/emacs/themes/")
;; (setq custom-safe-themes t)
;; only the custom themes in themes/ are used; theme packages were removed
(defcustom yaz/saved-theme 'gruvbox-mat-medium "saved theme to load at startup." :type 'symbol :group 'yaz)
(add-hook 'after-init-hook (lambda () (load-theme yaz/saved-theme t)))

(defvar yaz/no-line-numbers-modes
  '(org-mode-hook
    pdf-view-mode-hook
    term-mode-hook
    eshell-mode-hook
    dashboard-mode-hook
    nov-mode-hook
    markdown-mode-hook
    gfm-mode-hook
    markdown-view-mode-hook
    gfm-view-mode-hook
    neotree-mode-hook)
  "modes where line numbers should be disabled.")

(dolist (mode yaz/no-line-numbers-modes)
  (add-hook mode (lambda () (display-line-numbers-mode -1))))
(add-hook 'window-configuration-change-hook
  (lambda ()
    (set-window-margins nil 1)))
(use-package dashboard
  :ensure t
  :init
  (setq dashboard-set-heading-icons nil
        dashboard-set-file-icons nil
        dashboard-projects-backend 'project-el
        dashboard-banner-logo-title "hey!"
        dashboard-startup-banner 2
        dashboard-center-content nil
        dashboard-items '((recents   . 5)
                          (projects  . 5)
                          (sessions  . 5))
        ;; agenda dropped: it loads all of org (~0.5s) on every startup.
        ;; to bring it back, add (agenda . 10) / (agenda . "a") /
        ;; (agenda . dashboard-insert-agenda) to the three lists here.
        dashboard-item-shortcuts '((recents   . "r")
                                   (projects  . "p")
                                   (sessions  . "s"))
        dashboard-item-generators
        '((recents . dashboard-insert-recents)
          (projects . dashboard-insert-projects)
          (sessions . yaz/dashboard-insert-sessions))
        dashboard-week-agenda t
        dashboard-filter-agenda-entry 'dashboard-no-filter-agenda
        dashboard-agenda-sort-strategy '(time-up priority-down)
        dashboard-agenda-prefix-format " %i %-12:c %s "
        dashboard-match-agenda-entry "TODO=\"TODO\"|TODO=\"IN-PROGRESS\"|scheduled|deadline")
  :config
  (dashboard-setup-startup-hook)

  ;; saved desktop sessions (see session-config.el); RET loads one
  (defun yaz/dashboard-insert-sessions (list-size)
    "Add LIST-SIZE saved desktop sessions to the dashboard."
    (dashboard-insert-section
     "Sessions:"
     (and (fboundp 'yaz/session--names) (yaz/session--names))
     list-size
     'sessions
     (dashboard-get-shortcut 'sessions)
     `(lambda (&rest _) (yaz/session-load ,el))
     (if (equal el (yaz/session-current))
         (format "%s  (current)" el)
       el)))

  ;; evil-collection only forwards r/p/a in normal state; "s" would be evil-substitute
  (defun yaz/dashboard-goto-sessions ()
    "Jump to the Sessions section of the dashboard."
    (interactive)
    (dashboard--goto-section 'sessions))
  (with-eval-after-load 'evil
    (evil-define-key 'normal dashboard-mode-map "s" #'yaz/dashboard-goto-sessions))

  (defun my/dashboard-setup-margins ()
    "Set margins for dashboard buffer only."
    (setq-local left-margin-width 1)
    (setq-local right-margin-width 1)
    (set-window-buffer nil (current-buffer)))

  (add-hook 'dashboard-mode-hook #'my/dashboard-setup-margins))

(defun yaz/setup-artist-mode ()
  "Toggle artist-mode with proper grid setup, saving/restoring previous state."
  (interactive)

  ;; Clear active region without aborting this function.
  (when (region-active-p)
    (deactivate-mark))

  (if (bound-and-true-p artist-mode)
      ;; ── Turn OFF: restore saved state ──
      (progn
        (artist-mode -1)

        ;; Restore minor modes.
        (when (bound-and-true-p yaz/--artist-saved-display-line-numbers)
          (display-line-numbers-mode 1))
        (when (bound-and-true-p yaz/--artist-saved-visual-line)
          (visual-line-mode 1))
        (when (bound-and-true-p yaz/--artist-saved-variable-pitch)
          (variable-pitch-mode 1))
        (when (bound-and-true-p yaz/--artist-saved-whitespace)
          (whitespace-mode 1))

        ;; Restore buffer-local variables.
        (setq-local truncate-lines  (default-value 'truncate-lines))
        (setq-local word-wrap       (default-value 'word-wrap))
        (setq-local line-spacing    (default-value 'line-spacing))
        (setq-local indent-tabs-mode (default-value 'indent-tabs-mode))
        (setq-local cursor-type     (default-value 'cursor-type))
        (when (bound-and-true-p yaz/--artist-saved-locals)
          (pcase-dolist (`(,sym . ,val) yaz/--artist-saved-locals)
            (set (make-local-variable sym) val)))

        ;; Restore buffer-face-mode.
        (if (bound-and-true-p yaz/--artist-saved-buffer-face)
            (progn
              (setq-local buffer-face-mode-face
                          (cdr (assq 'face yaz/--artist-saved-buffer-face)))
              (buffer-face-mode (if (cdr (assq 'active yaz/--artist-saved-buffer-face)) 1 -1)))
          (buffer-face-mode -1))

        ;; Restore text scale.
        (text-scale-set (or (bound-and-true-p yaz/--artist-saved-text-scale) 0))

        ;; Restore Evil state.
        (when (and (fboundp 'evil-change-state)
                   (bound-and-true-p yaz/--artist-saved-evil-state))
          (evil-change-state yaz/--artist-saved-evil-state))

        (message "Artist mode disabled; previous settings restored."))

    ;; ── Turn ON: save state, then configure ──
    ;; Save minor-mode states.
    (setq-local yaz/--artist-saved-display-line-numbers
                (bound-and-true-p display-line-numbers-mode))
    (setq-local yaz/--artist-saved-visual-line
                (bound-and-true-p visual-line-mode))
    (setq-local yaz/--artist-saved-variable-pitch
                (bound-and-true-p variable-pitch-mode))
    (setq-local yaz/--artist-saved-whitespace
                (bound-and-true-p whitespace-mode))

    ;; Save buffer-local variables we are about to override.
    (setq-local yaz/--artist-saved-locals
                `((truncate-lines   . ,truncate-lines)
                  (word-wrap        . ,word-wrap)
                  (line-spacing     . ,line-spacing)
                  (indent-tabs-mode . ,indent-tabs-mode)
                  (cursor-type      . ,cursor-type)))

    ;; Save buffer-face-mode state.
    (setq-local yaz/--artist-saved-buffer-face
                `((active . ,(bound-and-true-p buffer-face-mode))
                  (face   . ,(if (local-variable-p 'buffer-face-mode-face)
                                 buffer-face-mode-face
                               nil))))

    ;; Save text scale.
    (setq-local yaz/--artist-saved-text-scale
                (or (bound-and-true-p text-scale-mode-amount) 0))

    ;; Save Evil state.
    (when (boundp 'evil-state)
      (setq-local yaz/--artist-saved-evil-state evil-state))

    ;; Disable interfering modes.
    (when (bound-and-true-p display-line-numbers-mode)
      (display-line-numbers-mode -1))
    (when (bound-and-true-p visual-line-mode)
      (visual-line-mode -1))
    (when (bound-and-true-p variable-pitch-mode)
      (variable-pitch-mode -1))
    (when (bound-and-true-p whitespace-mode)
      (whitespace-mode -1))

    ;; Make the buffer behave like a simple monospace grid.
    (setq-local truncate-lines t)
    (setq-local word-wrap nil)
    (setq-local line-spacing nil)
    (setq-local indent-tabs-mode nil)
    (setq-local cursor-type 'box)

    ;; Force fixed-pitch font in this buffer.
    (setq-local buffer-face-mode-face 'fixed-pitch)
    (buffer-face-mode 1)

    ;; Reset text zoom.
    (text-scale-set 0)

    ;; Start artist-mode.
    (artist-mode 1)

    ;; Evil fix: artist-mode is easier in Emacs state.
    (when (fboundp 'evil-emacs-state)
      (evil-emacs-state))

    (message "Artist mode ready. Use C-c C-a C-o to choose line, rectangle, or text.")))

(use-package diminish
  :ensure t)


;; neotree classic NerdTree-style file explorer (local source)
(require 'neotree)

;; window & display
(setq neo-window-position                              'right
      neo-window-width                                 35
      neo-window-fixed-size                            nil
      neo-display-action                               '(neo-default-display-fn)
      neo-reset-size-on-open                           nil)

;; appearance
(setq neo-theme                                        'ascii  ; pure text +/-, zero icons
      neo-banner-message                               (nth (random 11)
                                                            '("don't touch my files."
                                                              "here be cats..."
                                                              "abandon all hope, ye who enter here"
                                                              "rm -rf / (just kidding)"
                                                              "it works ..."
                                                              "TODO: organize this mess"
                                                              "git push --force (oops)"
                                                              "chmod 777 everything"
                                                              "works 60% of the time, every time"
                                                              ":wq"
                                                              "have you tried (eval-buffer)?"))
      neo-show-updir-line                              t        ; show .. for navigating up
      neo-show-slash-for-folder                        t        ; folder/
      neo-cwd-line-style                               'text
      neo-mode-line-type                               'neotree    ; hide mode-line
      neo-mode-line-custom-format                      nil
      neo-help-echo-style                              'default
      neo-hide-cursor                                  nil)     ; keep cursor visible

;; behavior
(setq neo-smart-open                                   t   ; jump to current file on open
      neo-autorefresh                                  nil ; disable aggressive background auto-refresh to fix auto-scrolling bug
      neo-show-hidden-files                            t   ; show dotfiles by default
      neo-create-file-auto-open                        nil
      neo-click-changes-root                           nil
      neo-auto-indent-point                            nil
      neo-toggle-window-keep-p                         nil
      neo-force-change-root                            t
      neo-keymap-style                                 'default)

;; hidden file patterns
(setq neo-hidden-regexp-list                           '("^\\.\\." "\\.pyc$" "~$" "^#.*#$" "\\.elc$" "\\.o$"))

;; sorting
(setq neo-filepath-sort-function                       'string<)

;; system 
(setq neo-default-system-application                   "xdg-open")

;;  version control 
(setq neo-vc-integration                               '(face char)
      neo-vc-state-char-alist
      '((up-to-date       . ?\s)
        (edited           . ?E)
        (added            . ?+)
        (removed          . ?-)
        (missing          . ?!)
        (needs-merge      . ?M)
        (conflict         . ?!)
        (unlocked-changes . ?!)
        (needs-update     . ?U)
        (ignored          . ?\s)
        (user             . ?U)
        (unregistered     . ??)
        (nil              . ?\s)))

;;  confirmations 
(setq neo-confirm-change-root                          'yes-or-no-p
      neo-confirm-create-file                          'yes-or-no-p
      neo-confirm-create-directory                     'yes-or-no-p
      neo-confirm-delete-file                          'yes-or-no-p
      neo-confirm-delete-directory-recursively         'yes-or-no-p
      neo-confirm-kill-buffers-for-files-in-directory  'yes-or-no-p)

;;  hooks 
(setq neo-enter-hook                                   nil
      neo-after-create-hook                            nil)

;;  evil compatibility 
(with-eval-after-load 'evil
  (eval
   '(evil-define-key 'normal neotree-mode-map
      ;; navigation (vim-style)
      (kbd "j")   #'neotree-next-line
      (kbd "k")   #'neotree-previous-line
      (kbd "h")   #'neotree-select-previous-sibling-node ; one level up
      (kbd "H")   #'neotree-select-up-node      ; jump up (changes root if needed)
      (kbd "l")   #'neotree-enter               ; expand / open
      (kbd "TAB") #'neotree-enter
      (kbd "RET") #'neotree-enter
      (kbd "SPC") #'neotree-quick-look          ; peek file
      ;; file operations (dired-style)
      (kbd "a")   #'neotree-create-node         ; create file/dir
      (kbd "d")   #'neotree-delete-node         ; delete
      (kbd "r")   #'neotree-rename-node         ; rename
      (kbd "c")   #'neotree-copy-node           ; copy
      (kbd "C")   #'neotree-change-root         ; change root
      ;; tree controls
      (kbd "g")   #'neotree-refresh
      (kbd "I")   #'neotree-hidden-file-toggle
      (kbd "A")   #'neotree-stretch-toggle
      (kbd "q")   #'neotree-hide)))

;; global 
(global-set-key (kbd "C-x t t") #'neotree-toggle)
(global-set-key (kbd "C-x t d") #'neotree-dir)

(with-eval-after-load 'diminish
  (diminish 'abbrev-mode)
  (diminish 'visual-line-mode)
  (with-eval-after-load 'which-key (diminish 'which-key-mode))
  (with-eval-after-load 'yasnippet (diminish 'yas-minor-mode))
  (with-eval-after-load 'git-gutter (diminish 'git-gutter-mode))
  ;; Old third-party tree-sitter mode; native `treesit' uses major modes instead.
  ;; (with-eval-after-load 'tree-sitter (diminish 'tree-sitter-mode))
  (with-eval-after-load 'evil-collection (diminish 'evil-collection-unimpaired-mode))
  (with-eval-after-load 'drag-stuff (diminish 'drag-stuff-mode)))


(provide 'ui)
;;; ui.el ends here
