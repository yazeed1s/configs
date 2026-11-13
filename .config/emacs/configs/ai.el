;;; ai.el --- AI tooling (completion, agents) -*- lexical-binding: t; -*-

;;; Commentary:
;; - (disabled) copilot            : inline completions
;; - agent-shell        : chat buffers for Claude / Codex over ACP (Agent Client Protocol)
;;                        needs `claude-agent-acp' and `codex-acp' on PATH
;;                        (pnpm add -g @agentclientprotocol/{claude-agent-acp,codex-acp})
;; - agent-shell-manager: table of all running agents (status, model, pending permissions)
;; - agent-review       : have an agent review your git diff, results as a navigable list
;;
;; Layout: agents live in a left-hand side panel (neotree takes the right). Claude takes the top slot,
;; Codex the bottom one, so both can be open at once.
;; Keybindings live in keybindings.el under SPC i.

;;; Code:

;; GUI Emacs started from a launcher may not see the shell PATH,
;; where claude, claude-agent-acp and codex-acp live.
(dolist (dir '("~/.local/bin" "~/.local/share/pnpm/bin"))
  (let ((dir (expand-file-name dir)))
    (when (file-directory-p dir)
      (add-to-list 'exec-path dir)
      (unless (member dir (split-string (or (getenv "PATH") "") path-separator))
        (setenv "PATH" (concat dir path-separator (getenv "PATH")))))))

;;; Inline completion

;; (defvar yaz/copilot-idle-delay 3
;;   "Seconds of idle time before copilot turns on in a new code buffer.")
;;
;; (defun yaz/copilot-enable-later ()
;;   "Turn on `copilot-mode' in this buffer once Emacs has been idle a bit.
;; Keeps copilot (and its node server) out of startup and file opening."
;;   (run-with-idle-timer
;;    yaz/copilot-idle-delay nil
;;    (lambda (buf)
;;      (when (buffer-live-p buf)
;;        (with-current-buffer buf
;;          (when (derived-mode-p 'prog-mode)
;;            (copilot-mode 1)))))
;;    (current-buffer)))
;;
;; (use-package copilot
;;   :vc (:url "https://github.com/copilot-emacs/copilot.el"
;;             :rev :newest
;;             :branch "main")
;;   :defer t
;;   :commands copilot-mode
;;   :init
;;   (add-hook 'prog-mode-hook #'yaz/copilot-enable-later)
;;   :bind (:map copilot-completion-map
;;               ("<tab>" . copilot-accept-completion)
;;               ("TAB" . copilot-accept-completion)
;;               ("C-<tab>" . copilot-accept-completion-by-word)
;;               ("C-TAB" . copilot-accept-completion-by-word)
;;               ("C-n" . copilot-next-completion)
;;               ("C-p" . copilot-previous-completion)))

;;; Terminal

(use-package vterm
  :ensure t
  :defer t
  :init
  (setq vterm-always-compile-module t)   ; build the module without asking
  :config
  (setq vterm-max-scrollback 10000))

;;; ─────────────────────────────────────────────────────────────────────
;;; agent-shell UI playground
;;;
;;; Every value below is the package default unless marked "(mine)".
;;; Change one, then `C-x C-e' after the closing paren (or SPC h r r).
;;; Most take effect in new shells; faces apply immediately.
;;; Browse interactively: M-x customize-group RET agent-shell
;;; ─────────────────────────────────────────────────────────────────────

;;;; Header (top bar)

(setq agent-shell-header-style 'text)
;; 'graphical (icon + styled text, default in GUI) | 'text (one line) | nil (no header)

(setq agent-shell-show-context-usage-indicator 'detailed)
;; 'detailed ("28k/1m (3%)") | t (bar only) | nil (hidden)

(setq agent-shell-show-cost-indicator nil)
;; t shows the session's cumulative cost

(setq agent-shell-show-session-id nil)
;; t shows the session id in the header and session picker

(setq agent-shell-show-busy-indicator t)
;; nil hides the "working" animation in header and mode line

(setq agent-shell-busy-indicator-frames 'wide)
;; 'wide | 'circle | 'wave | 'dots-block | 'dots-round
;; or static text "…" | or custom frames '("◐" "◓" "◑" "◒")

(setq agent-shell-show-welcome-message nil)   ; (mine) default t

;;;; What is expanded vs folded in a turn

(setq agent-shell-thought-process-expand-by-default nil)
;; t shows the agent's thinking expanded

(setq agent-shell-tool-use-expand-by-default nil)
;; t expands every file read / command / edit

(setq agent-shell-activity-group-expand-by-default 'latest)
;; 'latest (expanded only while the agent works in it) | t (always) | nil (never)

(setq agent-shell-user-message-expand-by-default nil)
;; t shows your long prompts in full

(setq agent-shell-show-usage-at-turn-end nil)
;; t prints token usage after each reply

;;;; Conversation look

(setq agent-shell-chat-mode-enabled t)
;; boxed "Me" / agent-name labels; nil = plain prompt style

(setq agent-shell-chat-label-function 'agent-shell-chat-boxed-label)
;; the only built-in label renderer; or your own (lambda (name me-p) ...)

(setq agent-shell-status-kind-label-function 'agent-shell--icon-and-kind-status-kind-label)
;; how tool-call status ("read ✓", "edit …") is drawn:
;;   agent-shell--icon-and-kind-status-kind-label
;;   agent-shell--unicode-icons-status-kind-label
;;   agent-shell--plain-colored-status-kind-label
;;   agent-shell--inverse-label-status-kind-label
;;   agent-shell--inverse-icon-status-kind-label
;;   agent-shell--background-tint-status-kind-label

(setq agent-shell-thought-process-icon "✶")
(setq agent-shell-permission-icon "⚠")

(setq agent-shell-prompt-busy-frames '("|" "/" "-" "\\"))
;; spinner on the prompt marker while the agent works

(setq agent-shell-highlight-blocks t)
;; nil disables syntax highlighting of code blocks in replies

(setq agent-shell-buffer-name-format 'default)
;; 'default ("Claude Agent @ strimo") | 'kebab-case ("claude-agent@strimo")
;; | (lambda (agent-name project-name) ...)

;;;; Faces (colors / fonts)
;; Each is the package default.  Edit the plist, e.g.
;;   '(agent-shell-thought-body ((t :inherit font-lock-comment-face :slant italic)))
;; Useful keys: :foreground "#hex" :background :weight bold :slant italic
;;              :height 0.9 :family "Iosevka" :inherit some-face :box t

(custom-theme-set-faces
 'user
 ;; header / mode line
 '(agent-shell-buffer-name   ((t :inherit font-lock-variable-name-face)))
 '(agent-shell-model         ((t :inherit font-lock-negation-char-face)))
 '(agent-shell-thought-level ((t :inherit font-lock-keyword-face)))
 '(agent-shell-key-binding   ((t :inherit help-key-binding)))
 ;; chat labels
 '(agent-shell-chat-me-label    ((t :inherit (bold font-lock-keyword-face) :inverse-video t :box t)))
 '(agent-shell-chat-agent-label ((t :inherit (bold font-lock-function-name-face) :inverse-video t :box t)))
 ;; prompt and your input
 '(agent-shell-prompt ((t :inherit comint-highlight-prompt)))
 '(agent-shell-input  ((t :inherit comint-highlight-input)))
 ;; thinking, sections, secondary text
 '(agent-shell-thought-body       ((t)))
 '(agent-shell-section-heading    ((t :inherit font-lock-doc-markup-face)))
 '(agent-shell-section-annotation ((t :inherit font-lock-doc-face)))
 '(agent-shell-secondary          ((t :inherit font-lock-comment-face)))
 '(agent-shell-link               ((t :inherit link)))
 ;; tool-call states
 '(agent-shell-success ((t :inherit success)))
 '(agent-shell-warning ((t :inherit warning)))
 '(agent-shell-error   ((t :inherit error)))
 '(agent-shell-pending ((t :inherit font-lock-comment-face)))
 '(agent-shell-permission-title ((t :inherit bold)))
 '(agent-shell-diff-changes-label ((((type graphic)) :inherit diff-hunk-header :box t)
                                   (t :inherit diff-hunk-header :inverse-video t)))
 ;; rendered markdown
 '(agent-shell-markdown-header-1 ((t :inherit org-level-1)))
 '(agent-shell-markdown-header-2 ((t :inherit org-level-2)))
 '(agent-shell-markdown-header-3 ((t :inherit org-level-3)))
 '(agent-shell-markdown-header-4 ((t :inherit org-level-4)))
 '(agent-shell-markdown-header-5 ((t :inherit org-level-5)))
 '(agent-shell-markdown-header-6 ((t :inherit org-level-6)))
 '(agent-shell-markdown-bold          ((t :inherit bold)))
 '(agent-shell-markdown-italic        ((t :inherit italic)))
 '(agent-shell-markdown-strikethrough ((t :strike-through t)))
 '(agent-shell-markdown-inline-code   ((t :inherit org-code)))
 '(agent-shell-markdown-link          ((t :inherit link)))
 '(agent-shell-markdown-blockquote    ((t :inherit font-lock-comment-face)))
 '(agent-shell-markdown-list-marker   ((t :inherit default)))
 '(agent-shell-markdown-list-done     ((t :inherit shadow :strike-through t)))
 '(agent-shell-markdown-source-block  ((t :inherit org-block :foreground unspecified :extend t)))
 '(agent-shell-markdown-source-block-language
   ((t :inherit (italic font-lock-type-face agent-shell-markdown-source-block))))
 '(agent-shell-markdown-table        ((t nil)))
 '(agent-shell-markdown-table-border ((t :inherit (agent-shell-markdown-table font-lock-comment-face))))
 '(agent-shell-markdown-table-header ((t :inherit (bold agent-shell-markdown-table))))
 '(agent-shell-markdown-table-zebra  ((t :inherit (lazy-highlight agent-shell-markdown-table)))))

;;;; Extras (not agent-shell options; implemented below in this file)

(defvar yaz/ai-panel-width 0.40
  "Width of the agent side panel, as a fraction of the frame (or columns if an integer).")

(defvar yaz/ai-panel-side 'left
  "Side of the frame for the agent panel: \\='right or \\='left.")

(defvar yaz/ai-chat-font nil
  "Font for chat buffers only, e.g. \\='(:family \"Inter\" :height 1.0). nil = your default font.")

(defvar yaz/ai-chat-line-spacing nil
  "Extra line spacing in chat buffers, e.g. 0.2 or 4 (pixels). nil = normal.")

(defvar yaz/ai-notify nil
  "Desktop notification when an agent finishes or asks for permission.
nil = off, t = always, \\='unfocused = only when its panel isn't visible
or Emacs isn't focused.")

;;; agent-shell helpers

(defun yaz/ai--agent-id (buffer)
  "Return the agent identifier (`claude-code', `codex', ...) of BUFFER."
  (or (ignore-errors
        (map-nested-elt (buffer-local-value 'agent-shell--state buffer)
                        '(:agent-config :identifier)))
      (let ((name (downcase (buffer-name buffer))))
        (cond ((string-prefix-p "codex" name) 'codex)
              ((string-prefix-p "claude" name) 'claude-code)))))

(defun yaz/ai--display-in-panel (buffer alist)
  "Show BUFFER in the agent side panel: Claude on top, Codex below."
  (display-buffer-in-side-window
   buffer
   (append `((side . ,yaz/ai-panel-side)
             (slot . ,(if (eq (yaz/ai--agent-id buffer) 'codex) 1 0))
             (window-width . ,yaz/ai-panel-width)
             (preserve-size . (t . nil))
             (window-parameters . ((no-delete-other-windows . t))))
           alist)))

(defun yaz/ai--shell-p (&optional buffer)
  (with-current-buffer (or buffer (current-buffer))
    (derived-mode-p 'agent-shell-mode)))

(defun yaz/ai--project-shells (&optional id)
  "Agent shells of the current project, most recent first, optionally only ID."
  (seq-filter (lambda (b) (or (null id) (eq (yaz/ai--agent-id b) id)))
              (agent-shell-project-buffers)))

(defun yaz/ai--panel-windows ()
  (seq-filter (lambda (w) (yaz/ai--shell-p (window-buffer w)))
              (window-list nil 'no-mini)))

(defun yaz/ai--current-shell ()
  "The shell commands should act on: this one, a visible one, or the latest."
  (cond ((yaz/ai--shell-p) (current-buffer))
        ((car (mapcar #'window-buffer (yaz/ai--panel-windows))))
        ((car (yaz/ai--project-shells)))
        ((car (agent-shell-buffers)))
        (t (user-error "No agent running; start one with SPC i c (claude) or SPC i o (codex)"))))

(defun yaz/ai--back-to-code ()
  "Select the most recent window that isn't an agent panel."
  (when-let* ((win (get-mru-window nil nil t)))
    (unless (yaz/ai--shell-p (window-buffer win))
      (select-window win))))

(defun yaz/ai--open (id make-config &optional new)
  "Open the project's ID agent (start one if none); NEW forces a fresh session.
An active region or the flymake error at point is carried into the prompt."
  (require 'agent-shell)
  (let ((existing (and (not new) (car (yaz/ai--project-shells id)))))
    (cond
     ((and existing (eq existing (current-buffer))) (yaz/ai--back-to-code))
     (existing
      (agent-shell--display-and-insert-context
       existing (agent-shell--context :shell-buffer existing)))
     (t (agent-shell--dwim :config (funcall make-config) :new-shell t)))))

(defun yaz/ai-claude ()
  "Open (or start) Claude for this project."
  (interactive)
  (yaz/ai--open 'claude-code #'agent-shell-anthropic-make-claude-code-config))

(defun yaz/ai-claude-new ()
  "Start an additional Claude session for this project."
  (interactive)
  (yaz/ai--open 'claude-code #'agent-shell-anthropic-make-claude-code-config t))

(defun yaz/ai-codex ()
  "Open (or start) Codex for this project."
  (interactive)
  (yaz/ai--open 'codex #'agent-shell-openai-make-codex-config))

(defun yaz/ai-codex-new ()
  "Start an additional Codex session for this project."
  (interactive)
  (yaz/ai--open 'codex #'agent-shell-openai-make-codex-config t))

(defun yaz/ai-focus ()
  "Jump between your code and the agent panel."
  (interactive)
  (require 'agent-shell)
  (if (yaz/ai--shell-p)
      (yaz/ai--back-to-code)
    (if-let* ((win (car (yaz/ai--panel-windows))))
        (select-window win)
      (agent-shell--display-buffer (yaz/ai--current-shell)))))

(defun yaz/ai-toggle-panel ()
  "Hide every agent window, or bring back the most recent one."
  (interactive)
  (require 'agent-shell)
  (if-let* ((wins (yaz/ai--panel-windows)))
      (progn (mapc #'delete-window wins) (yaz/ai--back-to-code))
    (agent-shell--display-buffer (yaz/ai--current-shell))))

(defun yaz/ai-switch ()
  "Pick any running agent session and show it."
  (interactive)
  (require 'agent-shell)
  (agent-shell '(16)))

(defmacro yaz/ai--def-shell-command (name command doc)
  "Define NAME that runs COMMAND inside the current agent shell, from anywhere."
  `(defun ,name ()
     ,doc
     (interactive)
     (require 'agent-shell)
     (with-current-buffer (yaz/ai--current-shell)
       (call-interactively #',command))))

(yaz/ai--def-shell-command yaz/ai-interrupt agent-shell-interrupt "Stop the agent.")
(yaz/ai--def-shell-command yaz/ai-model agent-shell-set-session-model "Change the agent's model.")
(yaz/ai--def-shell-command yaz/ai-mode agent-shell-set-session-mode "Change mode (plan/ask/edit/auto).")
(yaz/ai--def-shell-command yaz/ai-effort agent-shell-set-session-thought-level "Change thinking effort.")
(yaz/ai--def-shell-command yaz/ai-usage agent-shell-show-usage "Show context/token usage.")
(yaz/ai--def-shell-command yaz/ai-restart agent-shell-restart "Clear the conversation (restart).")

(defun yaz/ai-review-claude ()
  "Review uncommitted git changes with Claude."
  (interactive)
  (require 'agent-review)
  (agent-review (agent-shell-anthropic-make-claude-code-config)))

(defun yaz/ai-review-codex ()
  "Review uncommitted git changes with Codex."
  (interactive)
  (require 'agent-review)
  (agent-review (agent-shell-openai-make-codex-config)))

(defun yaz/ai--notify-p (buffer)
  (pcase yaz/ai-notify
    ('nil nil)
    ('unfocused (or (not (frame-focus-state))
                    (not (get-buffer-window buffer 'visible))))
    (_ t)))

(defun yaz/ai--notify (buffer body)
  (when (yaz/ai--notify-p buffer)
    (let ((title (buffer-name buffer)))
      (if (executable-find "notify-send")
          (start-process "agent-notify" nil "notify-send" "-a" "Emacs" title body)
        (message "%s: %s" title body)))))

(defun yaz/ai--subscribe-notifications ()
  (let ((buf (current-buffer)))
    (agent-shell-subscribe-to
     :shell-buffer buf :event 'turn-complete
     :on-event (lambda (_e) (yaz/ai--notify buf "Done, waiting for you")))
    (agent-shell-subscribe-to
     :shell-buffer buf :event 'permission-request
     :on-event (lambda (_e) (yaz/ai--notify buf "Needs your permission")))))

(defvar yaz/ai-blank-line-height 0.35
  "Height of empty lines in agent output, relative to normal text.
agent-shell hard-codes blank lines between blocks; this squashes them
visually without touching the buffer.  1.0 = normal, nil = off.")

(defun yaz/ai--compact-blank-lines (beg end)
  "Shrink empty read-only (agent output) lines between BEG and END.
Your own prompt input is left alone, since it isn't read-only."
  (save-excursion
    (goto-char beg)
    (beginning-of-line)
    (remove-overlays (point) end 'yaz-ai-compact t)
    (while (re-search-forward "^\n" end t)
      (let ((pos (1- (point))))
        (when (get-text-property pos 'read-only)
          (let ((ov (make-overlay pos (1+ pos) nil t nil)))
            (overlay-put ov 'yaz-ai-compact t)
            (overlay-put ov 'evaporate t)
            (overlay-put ov 'face `(:height ,yaz/ai-blank-line-height))))))))

(defun yaz/agent-shell-buffer-setup ()
  "Make agent-shell buffers read like a chat, not code."
  (when yaz/ai-blank-line-height
    (jit-lock-register #'yaz/ai--compact-blank-lines))
  (display-line-numbers-mode -1)
  (visual-line-mode 1)            ; wrap long lines at word boundaries
  (setq-local left-margin-width 1
              right-margin-width 1)
  (when yaz/ai-chat-font
    (setq-local buffer-face-mode-face yaz/ai-chat-font)
    (buffer-face-mode 1))
  (when yaz/ai-chat-line-spacing
    (setq-local line-spacing yaz/ai-chat-line-spacing))
  (yaz/ai--subscribe-notifications))

;;; agent-shell

(use-package agent-shell
  :ensure t
  :defer t
  :init
  (setq agent-shell-display-action
        '((display-buffer-reuse-window yaz/ai--display-in-panel)))

  ;; files clicked in the chat open in the main area, not inside the panel
  (setq agent-shell-file-display-action
        '((display-buffer-reuse-window display-buffer-use-some-window)
          (inhibit-same-window . t)))

  ;; behavior (UI options are in the playground above)
  (setq agent-shell-confirm-interrupt nil       ; interrupt without asking
        agent-shell-session-strategy 'new       ; resume explicitly with SPC i r
        ;; what opening an agent carries into the prompt: dired files, the
        ;; selected region, or the flymake error at point (not the current line)
        agent-shell-context-sources '(files region error))

  ;; evil in the chat (bindings from evil-collection), opening in insert state.
  ;; diff buffers and the review list stay in emacs state so y/n/RET/m/S
  ;; work directly.
  (with-eval-after-load 'evil
    (evil-set-initial-state 'agent-shell-mode 'insert)
    (evil-set-initial-state 'agent-shell-viewport-edit-mode 'insert)
    (dolist (mode '(agent-shell-diff-mode agent-review-mode))
      (evil-set-initial-state mode 'emacs)))

  :hook (agent-shell-mode . yaz/agent-shell-buffer-setup)

  :config
  ;; use the CLIs' existing logins (subscription), not API keys
  (setq agent-shell-anthropic-authentication
        (agent-shell-anthropic-make-authentication :login t)
        agent-shell-openai-authentication
        (agent-shell-openai-make-authentication :login t))

  ;; inside the chat: RET / C-RET send, S-RET newline, C-c C-c stop
  (define-key agent-shell-mode-map (kbd "C-<return>") #'agent-shell-submit)
  ;; same in evil: RET sends from insert and normal (evil-collection's
  ;; default is newline in insert), S-RET is newline
  (with-eval-after-load 'evil
    (evil-define-key* '(insert normal) agent-shell-mode-map
      (kbd "RET") #'agent-shell-submit
      (kbd "<return>") #'agent-shell-submit
      (kbd "S-<return>") #'newline))
  ;; C-c C-j (or SPC i i) jumps back to your code
  (define-key agent-shell-mode-map (kbd "C-c C-j") #'yaz/ai-focus))

;;; Dashboard of every running agent

(use-package agent-shell-manager
  :vc (:url "https://github.com/jethrokuan/agent-shell-manager" :rev :newest)
  :commands agent-shell-manager-toggle
  :init
  (setq agent-shell-manager-side 'bottom
        agent-shell-manager-transient t)         ; close after RET jumps to a shell
  :config
  ;; the manager only reads the legacy `:session :model-id', which Claude's
  ;; adapter doesn't set (it reports the model as an ACP config option), so
  ;; Claude showed "-".  Use agent-shell's own lookup, which handles both.
  (defun yaz/agent-shell-manager--model (buffer)
    (with-current-buffer buffer
      (let* ((state (bound-and-true-p agent-shell--state))
             (id (and state (agent-shell--current-model-id state)))
             (info (and id (seq-find (lambda (m) (equal (map-elt m :model-id) id))
                                     (agent-shell--get-available-models state)))))
        (cond (info (or (map-elt info :name) id))
              (id)
              (t "-")))))
  (advice-add 'agent-shell-manager--get-model-id
              :override #'yaz/agent-shell-manager--model))

;;; Cross-agent code review of your git diff

(use-package agent-review
  :vc (:url "https://github.com/nineluj/agent-review" :rev :newest)
  :commands agent-review)

(provide 'ai)
;;; ai.el ends here
