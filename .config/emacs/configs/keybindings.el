;;; keybindings.el -*- lexical-binding: t; -*-

(use-package evil
  :ensure t
  :demand t
  :init
  (setq evil-want-integration t
        evil-want-keybinding nil
        evil-want-C-u-scroll t
        evil-want-C-i-jump t
        evil-want-Y-yank-to-eol t
        evil-symbol-word-search t)
  :config
  (evil-mode 1))

(use-package evil-surround
  :ensure t
  :after evil
  :config
  (global-evil-surround-mode 1))

(use-package evil-multiedit
  :ensure t
  :after evil
  :config
  (setq evil-multiedit-scope 'buffer
        evil-multiedit-follow-matches t)
  :bind (:map evil-normal-state-map
              ("C->" . evil-multiedit-match-and-next)
              ("C-<" . evil-multiedit-match-and-prev)
              ("C-." . evil-multiedit-match-all)
         :map evil-visual-state-map
              ("M->" . evil-multiedit-match-and-next)
              ("M-<" . evil-multiedit-match-and-prev)
              ("M-." . evil-multiedit-match-all)))

(use-package evil-collection
  :ensure t
  :after evil
  :config
  (setq evil-collection-mode-list
        (remove 'neotree evil-collection-mode-list))
  (evil-collection-init))

(with-eval-after-load 'dired
  (evil-define-key 'normal dired-mode-map
    (kbd "h") 'dired-up-directory
    (kbd "l") 'dired-open-file))

(use-package drag-stuff
  :ensure t
  :config
  (drag-stuff-global-mode 1)
  (drag-stuff-define-keys))

;;; Helper functions

(defun yaz/toggle-profiler ()
  "Toggle emacs profiler."
  (interactive)
  (if (profiler-running-p)
      (progn
        (profiler-stop)
        (profiler-report))
    (profiler-start 'cpu+mem)
    (message "profiler started")))

(defun yaz/toggle-writing-mode ()
  "Toggle distraction-free writing layout (olivetti / centered text)."
  (interactive)
  (if (bound-and-true-p olivetti-mode)
      (progn
        (olivetti-mode -1)
        (message "writing mode off"))
    (progn
      (olivetti-mode 1)
      (message "writing mode on"))))

(use-package transient
  :ensure t
  :defer t)

(defmacro yaz/def-compile-menu (name &rest body)
  "Define transient prefix NAME with BODY lazily.
NAME is autoloaded from transient and only defined once transient loads,
so transient (~0.16s) stays out of startup. The inner form is quoted so
eager macro-expansion does not pull transient in at load time."
  (declare (indent defun))
  `(progn
     (autoload ',name "transient" nil t)
     (with-eval-after-load 'transient
       (eval '(transient-define-prefix ,name ,@body) t))))

(defun yaz/project-root-or-default ()
  "Return the current project root or `default-directory'."
  (if-let* ((project (project-current nil)))
      (project-root project)
    default-directory))

(defun yaz/compile-in-dir (directory command)
  "Run COMMAND through `compile' with DIRECTORY as `default-directory'."
  (let ((default-directory (file-name-as-directory directory)))
    (compile command)))

(defun yaz/shell-command-string (&rest parts)
  "Build a shell command by quoting and joining PARTS."
  (string-join (mapcar #'shell-quote-argument (delq nil parts)) " "))

(defun yaz/transient-command-args (prefix)
  "Return transient args for PREFIX."
  (if (bound-and-true-p transient-current-command)
      (transient-args prefix)
    nil))

(defun yaz/c-compiler ()
  "Return a C-family compiler for the current buffer."
  (if (memq major-mode '(c++-mode c++-ts-mode))
      "g++"
    "gcc"))

(defun yaz/c-output-file ()
  "Return a default output path for the current C-family buffer."
  (if buffer-file-name
      (file-name-sans-extension buffer-file-name)
    "a.out"))

(defun yaz/c-command (action)
  "Compile or run a C-family file according to ACTION."
  (let* ((args (yaz/transient-command-args 'yaz/c-compile-menu))
         (source buffer-file-name)
         (output (yaz/c-output-file))
         (compile-command (apply #'yaz/shell-command-string
                                 (append (list (yaz/c-compiler) source "-o" output) args))))
    (unless source
      (user-error "Current buffer is not visiting a file"))
    (pcase action
      ('build (yaz/compile-in-dir (file-name-directory source) compile-command))
      ('run (yaz/compile-in-dir (file-name-directory source)
                                (concat compile-command " && "
                                        (shell-quote-argument output)))))))

(defun yaz/c-build () (interactive) (yaz/c-command 'build))
(defun yaz/c-run () (interactive) (yaz/c-command 'run))

(yaz/def-compile-menu yaz/c-compile-menu ()
  "C/C++ compile/run menu."
  ["C/C++"
   ("b" "build file" yaz/c-build)
   ("r" "build and run" yaz/c-run)
   ("p" "project compile" project-compile)
   ("c" "compile command" compile)]
  ["Flags"
   ("-g" "debug symbols" "-g")
   ("-w" "Wall" "-Wall")
   ("-W" "Wextra" "-Wextra")
   ("-0" "O0" "-O0")
   ("-1" "O1" "-O1")
   ("-2" "O2" "-O2")
   ("-3" "O3" "-O3")
   ("-s" "std" "-std=")
   ("-I" "include dir" "-I" :class transient-option)
   ("-L" "library dir" "-L" :class transient-option)
   ("-l" "library" "-l" :class transient-option)
   ("-D" "define" "-D" :class transient-option)])

(defun yaz/go-command (subcommand)
  "Run go SUBCOMMAND with flags from `yaz/go-compile-menu'."
  (let* ((args (yaz/transient-command-args 'yaz/go-compile-menu))
         (target (if buffer-file-name "." "./..."))
         (command (apply #'yaz/shell-command-string
                         (append (list "go" subcommand target) args))))
    (yaz/compile-in-dir (yaz/project-root-or-default) command)))

(defun yaz/go-build () (interactive) (yaz/go-command "build"))
(defun yaz/go-run () (interactive) (yaz/go-command "run"))
(defun yaz/go-test () (interactive) (yaz/go-command "test"))
(defun yaz/go-vet () (interactive) (yaz/go-command "vet"))

(yaz/def-compile-menu yaz/go-compile-menu ()
  "Go compile/run menu."
  ["Go"
   ("b" "build package" yaz/go-build)
   ("r" "run package" yaz/go-run)
   ("t" "test package" yaz/go-test)
   ("v" "vet package" yaz/go-vet)
   ("p" "project compile" project-compile)]
  ["Flags"
   ("-r" "race" "-race")
   ("-v" "verbose" "-v")
   ("-x" "print commands" "-x")
   ("-c" "cover" "-cover")
   ("-n" "count" "-count=")
   ("-R" "run test regexp" "-run=")
   ("-T" "test timeout" "-timeout=")
   ("-t" "tags" "-tags=")])

(defun yaz/rust-cargo (subcommand)
  "Run cargo SUBCOMMAND with flags from `yaz/rust-compile-menu'."
  (let* ((args (yaz/transient-command-args 'yaz/rust-compile-menu))
         (command (string-join (append (list "cargo" subcommand) args) " ")))
    (yaz/compile-in-dir (yaz/project-root-or-default) command)))

(defun yaz/rust-build () (interactive) (yaz/rust-cargo "build"))
(defun yaz/rust-run () (interactive) (yaz/rust-cargo "run"))
(defun yaz/rust-test () (interactive) (yaz/rust-cargo "test"))
(defun yaz/rust-check () (interactive) (yaz/rust-cargo "check"))
(defun yaz/rust-clippy () (interactive) (yaz/rust-cargo "clippy"))

(yaz/def-compile-menu yaz/rust-compile-menu ()
  "Rust compile/run menu."
  ["Cargo"
   ("b" "build" yaz/rust-build)
   ("r" "run" yaz/rust-run)
   ("t" "test" yaz/rust-test)
   ("c" "check" yaz/rust-check)
   ("l" "clippy" yaz/rust-clippy)]
  ["Flags"
   ("-r" "release" "--release")
   ("-a" "all features" "--all-features")
   ("-n" "no default features" "--no-default-features")
   ("-F" "features" "--features=")
   ("-p" "package" "--package=")
   ("-B" "bin" "--bin=")])

(defun yaz/odin-target ()
  "Return the current Odin package target."
  (or (and buffer-file-name
           (file-name-directory buffer-file-name))
      (yaz/project-root-or-default)))

(defun yaz/odin-command (subcommand)
  "Run odin SUBCOMMAND with flags from `yaz/odin-compile-menu'."
  (let* ((args (yaz/transient-command-args 'yaz/odin-compile-menu))
         (target (yaz/odin-target))
         (command (apply #'yaz/shell-command-string
                         (append (list "odin" subcommand target) args))))
    (yaz/compile-in-dir (yaz/project-root-or-default) command)))

(defun yaz/odin-build () (interactive) (yaz/odin-command "build"))
(defun yaz/odin-run () (interactive) (yaz/odin-command "run"))
(defun yaz/odin-test () (interactive) (yaz/odin-command "test"))
(defun yaz/odin-check () (interactive) (yaz/odin-command "check"))

(yaz/def-compile-menu yaz/odin-compile-menu ()
  "Odin compile/run menu."
  ["Odin"
   ("b" "build package" yaz/odin-build)
   ("r" "run package" yaz/odin-run)
   ("t" "test package" yaz/odin-test)
   ("c" "check package" yaz/odin-check)]
  ["Flags"
   ("-d" "debug" "-debug")
   ("-v" "vet" "-vet")
   ("-s" "strict style" "-strict-style")
   ("-0" "opt none" "-o:none")
   ("-1" "opt minimal" "-o:minimal")
   ("-2" "opt size" "-o:size")
   ("-3" "opt speed" "-o:speed")
   ("-o" "output" "-out:" :class transient-option)
   ("-C" "collection" "-collection:" :class transient-option)
   ("-D" "define" "-define:" :class transient-option)
   ("-T" "threads" "-thread-count:" :class transient-option)])

(defun yaz/zig-project-p ()
  "Return non-nil when the current project has build.zig."
  (file-exists-p (expand-file-name "build.zig" (yaz/project-root-or-default))))

(defun yaz/zig-command (subcommand)
  "Run zig SUBCOMMAND with flags from `yaz/zig-compile-menu'."
  (let* ((args (yaz/transient-command-args 'yaz/zig-compile-menu))
         (project-root (yaz/project-root-or-default))
         (uses-build (and (member subcommand '("build" "run"))
                          (yaz/zig-project-p)))
         (target (unless uses-build buffer-file-name))
         (command (apply #'yaz/shell-command-string
                         (append (list "zig" subcommand) (list target) args))))
    (yaz/compile-in-dir project-root command)))

(defun yaz/zig-build () (interactive) (yaz/zig-command "build"))
(defun yaz/zig-run () (interactive) (yaz/zig-command "run"))
(defun yaz/zig-test () (interactive) (yaz/zig-command "test"))

(yaz/def-compile-menu yaz/zig-compile-menu ()
  "Zig compile/run menu."
  ["Zig"
   ("b" "build" yaz/zig-build)
   ("r" "run" yaz/zig-run)
   ("t" "test" yaz/zig-test)]
  ["Flags"
   ("-D" "build option" "-D" :class transient-option)
   ("-O" "optimize" "-Doptimize=")
   ("-f" "emit bin" "-femit-bin=")
   ("-s" "strip" "-fstrip")
   ("-S" "single threaded" "-fsingle-threaded")])

(yaz/def-compile-menu yaz/generic-compile-menu ()
  "Generic compile menu."
  ["Compile"
   ("c" "compile here" compile)
   ("p" "compile project" project-compile)
   ("!" "shell command" shell-command)
   ("&" "async shell command" async-shell-command)])

(defun yaz/code-compile-menu ()
  "Open a compile/run menu for the current language."
  (interactive)
  (pcase major-mode
    ((or 'c-mode 'c-ts-mode 'c++-mode 'c++-ts-mode) (yaz/c-compile-menu))
    ((or 'go-mode 'go-ts-mode) (yaz/go-compile-menu))
    ((or 'rust-mode 'rust-ts-mode) (yaz/rust-compile-menu))
    ((or 'odin-mode 'odin-ts-mode) (yaz/odin-compile-menu))
    ('zig-mode (yaz/zig-compile-menu))
    (_ (yaz/generic-compile-menu))))

(global-set-key (kbd "C->") 'mc/mark-next-like-this)
(global-set-key (kbd "C-<") 'mc/mark-previous-like-this)
(global-set-key (kbd "C-*") 'mc/mark-all-like-this)
(global-set-key (kbd "C-s-c C-s-c") 'mc/edit-lines)
(global-set-key (kbd "C-c g") 'yaz/search-on-browser)
(global-set-key (kbd "C-=") 'text-scale-increase)
(global-set-key (kbd "C--") 'text-scale-decrease)
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)
(global-set-key (kbd "<C-right>") 'next-buffer)
(global-set-key (kbd "<C-left>") 'previous-buffer)
(global-set-key (kbd "M-k") 'yaz/join-line-above)
(global-set-key (kbd "M-j") 'yaz/join-line-below)
(global-set-key (kbd "M-p") 'yaz/duplicate-line)
(global-set-key (kbd "M-<up>") 'yaz/move-line-up)
(global-set-key (kbd "M-<down>") 'yaz/move-line-down)
(global-set-key (kbd "C-h C-f") 'find-function)
(global-set-key (kbd "C-h C-v") 'find-variable)
(global-set-key (kbd "C-h C-k") 'find-function-on-key)
(global-set-key (kbd "M-y") 'counsel-yank-pop)

(use-package general
  :ensure t
  :after evil
  :config
  (general-create-definer leader-keys
    :states '(normal insert visual emacs)
    :keymaps 'override
    :prefix "SPC"
    :global-prefix "M-SPC")

  (leader-keys
    "SPC" '(counsel-M-x                          :wk "M-x")
    "."   '(counsel-find-file                    :wk "find file (here)")
    ","   '(ivy-switch-buffer                    :wk "switch buffer")
    "/"   '(comment-line                         :wk "comment region")
    ";"   '(eval-expression                      :wk "eval")
    "<"   '(swiper                               :wk "search buffer")
    "-"   '(swiper-all                           :wk "search (all buffers)") 
    ">"   '(occur                                :wk "occur")
    "="   '(counsel-rg                           :wk "search (ripgrep)")
    "C"   '(project-compile                      :wk "compile (root)")
    "c"   '(yaz/code-compile-menu                :wk "compile/run")
    "!"   '(project-shell-command                :wk "shell (root)")
    "1"   '(shell-command                        :wk "shell (here)")
    "8"   '(evil-switch-to-windows-last-buffer   :wk "last buffer")
    "RET" '(bookmark-jump                        :wk "bookmark")
    "y"   '(counsel-yank-pop                      :wk "paste history")
    "'"   '(counsel-mark-ring                     :wk "jump to mark")
    "m"   '((lambda () (interactive) (push-mark (point) t nil) (message "mark set")) :wk "set mark")

    "a"   '(:ignore t :wk "apps")
    "a a" '(mark-whole-buffer         :wk "select all")
    "a c" '(calculator                :wk "calculator")
    "a e" '(eshell                    :wk "eshell (here)")
    "a E" '(project-eshell            :wk "eshell (root)")
    "a o" '(counsel-linux-app         :wk "linux apps")
    "a t" '(term                      :wk "terminal")
    "a T" '(yaz/open-terminal-here    :wk "terminal (external)")
    "a -" '(dired-jump                :wk "dired (here)")

    ;; "&"   '(:ignore t :wk "shell")
    ;; "& !" '(project-shell-command                 :wk "cmd (root)")
    ;; "& h" '(shell-command                         :wk "cmd (here)")
    ;; "& a" '(async-shell-command                   :wk "cmd (async)")
    ;; "& r" '(project-async-shell-command           :wk "cmd (root async)")
    ;; "& t" '(yaz/open-terminal-here                :wk "external term")
    ;; "& e" '(project-eshell                        :wk "eshell (root)")
    ;; "& E" '(eshell                                :wk "eshell (here)")
    ;; "& v" '(project-shell                         :wk "shell (root)")
    ;; "& V" '(vterm                                 :wk "vterm (here)")

    ;; "r"   '(:ignore t :wk "registers")
    ;; "r r" '(list-registers             :wk "list registers")
    ;; "r R" '(jump-to-register           :wk "jump to")
    ;; "r s" '(copy-to-register           :wk "save to")
    ;; "r i" '(insert-register            :wk "insert from")
    ;; "r p" '(point-to-register          :wk "save position")
    ;; "r w" '(window-configuration-to-register :wk "save windows")
    ;; "r f" '(frameset-to-register       :wk "save frame")
    ;; "r SPC" '(point-to-register        :wk "save point")
    ;; "r +" '(increment-register         :wk "increment")
    ;; "r n" '(number-to-register         :wk "save number")

    "i"   '(:ignore t :wk "ai")
    ;; panel
    "i i" '(yaz/ai-focus                  :wk "focus code <-> agent")
    "i h" '(yaz/ai-toggle-panel           :wk "hide/show panel")
    "i b" '(yaz/ai-switch                 :wk "switch session...")
    "i l" '(agent-shell-manager-toggle    :wk "all agents (dashboard)")
    ;; agents: lowercase = open/reuse, uppercase = new session
    "i c" '(yaz/ai-claude                 :wk "claude")
    "i C" '(yaz/ai-claude-new             :wk "claude (new session)")
    "i o" '(yaz/ai-codex                  :wk "codex")
    "i O" '(yaz/ai-codex-new              :wk "codex (new session)")
    "i r" '(agent-shell-resume-session    :wk "resume old session")
    "i w" '(agent-shell-new-worktree-shell :wk "new in git worktree")
    ;; send to the active agent
    "i s"   '(:ignore t :wk "send")
    "i s s" '(agent-shell-send-dwim         :wk "region / error")
    "i s r" '(agent-shell-send-region-to    :wk "region to...")
    "i s f" '(agent-shell-send-current-file :wk "this file")
    "i s F" '(agent-shell-send-other-file   :wk "other file...")
    "i s i" '(agent-shell-send-clipboard-image :wk "clipboard image")
    ;; control the active agent (works from any buffer)
    "i k" '(yaz/ai-interrupt              :wk "stop agent")
    "i m" '(yaz/ai-model                  :wk "model")
    "i M" '(yaz/ai-mode                   :wk "mode (plan/edit/auto)")
    "i e" '(yaz/ai-effort                 :wk "thinking effort")
    "i u" '(yaz/ai-usage                  :wk "usage")
    "i x" '(yaz/ai-restart                :wk "clear conversation")
    ;; review git changes
    "i v"   '(:ignore t :wk "review diff")
    "i v c" '(yaz/ai-review-claude        :wk "with claude")
    "i v o" '(yaz/ai-review-codex         :wk "with codex")
    ;; misc
    ;; "i p" '(copilot-mode                  :wk "copilot (toggle)")
    "i ?" '(agent-shell-help-menu         :wk "all agent-shell commands")

    "b"   '(:ignore t :wk "buffers")
    "b k" '(kill-current-buffer       :wk "kill")
    "b r" '(revert-buffer             :wk "revert")
    "b m" '(bookmark-set              :wk "set bookmark")
    "b l" '(list-bookmarks            :wk "list bookmarks")


    "d"   '(:ignore t :wk "dired/debug")
    "d d" '(dired                     :wk "dired")
    "d j" '(dired-jump                :wk "dired (here)")
    "d w" '(wdired-change-to-wdired-mode :wk "wdired mode")


    "e"   '(neotree-toggle            :wk "file tree")

    "E"   '(:ignore t :wk "errors/eval")
    "E b" '(eval-buffer               :wk "eval buffer")
    "E d" '(eval-defun                :wk "eval defun")
    "E e" '(eval-last-sexp            :wk "eval sexp")
    "E r" '(eval-region               :wk "eval region")
    "E l" '(flymake-show-project-diagnostics :wk "list errors (project)")
    "E L" '(flymake-show-buffer-diagnostics  :wk "list errors (buffer)")
    "E n" '(flymake-goto-next-error          :wk "next error")
    "E p" '(flymake-goto-prev-error          :wk "prev error")

    "f"   '(:ignore t :wk "files")
    "f f" '(find-file                 :wk "find file")
    "f F" '(find-file-at-point        :wk "find at point")
    "f r" '(counsel-recentf           :wk "recent")
    "f s" '(save-buffer               :wk "save")
    "f S" '(write-file                :wk "save as")
    "f R" '(yaz/rename-file-and-buffer :wk "rename")
    "f d" '(yaz/delete-file-and-buffer :wk "delete")
    "f y" '(yaz/copy-file-path        :wk "copy path")
    "f Y" '(yaz/copy-file-name        :wk "copy name")

    "f l" '(counsel-locate            :wk "locate")
    "f m" '(yaz/make-file-executable  :wk "make executable")
    "f o" '(yaz/open-file-externally  :wk "open external")
    "f v" '(yaz/reveal-in-file-manager :wk "reveal in fm")
    "f t" '(yaz/move-file-to-trash    :wk "move to trash")
    "f c"   '(:ignore t :wk "config")
    "f c e" '((lambda () (interactive) (dired "~/.config/emacs/")) :wk "emacs dir")
    "f c z" '((lambda () (interactive) (find-file "~/.zshrc")) :wk ".zshrc")

    "h"     '(:ignore t :wk "help")
    "h t"   '(yaz/load-theme-with-preview      :wk "theme")
    "h v"   '(describe-variable        :wk "variable")
    "h r"   '(:ignore t :wk "reload")
    "h r r" '((lambda () (interactive) (load-file "~/.config/emacs/init.el")) :wk "reload config")
    "h r p" '(package-refresh-contents :wk "refresh packages")

    ;; "i"   '(:ignore t :wk "insert")
    ;; "i c" '(insert-char               :wk "unicode char")
    ;; "i d" '((lambda () (interactive) (insert (format-time-string "%Y-%M-%d"))) :wk "date")
    ;; "i D" '((lambda () (interactive) (insert (format-time-string "%Y-%M-%d %H:%m:%S"))) :wk "datetime")
    ;; "i f" '((lambda () (interactive) (insert (buffer-file-name))) :wk "file path")
    ;; "i n" '((lambda () (interactive) (insert (buffer-name))) :wk "file name")
    ;; "i s" '(yas-insert-snippet        :wk "snippet")
    ;; "i u" '(counsel-unicode-char      :wk "unicode")

    "l"   '(:ignore t :wk "eglot")
    "l l" '(eglot                     :wk "start")
    "l q" '(eglot-shutdown            :wk "shutdown")
    "l r" '(eglot-reconnect           :wk "reconnect")
    "l a" '(eglot-code-actions        :wk "code action")
    "l f" '(eglot-format-buffer       :wk "format")
    "l F" '(eglot-format              :wk "format region")
    "l n" '(eglot-rename              :wk "rename")
    "l o" '(eglot-code-action-organize-imports :wk "organize imports")
    "l h" '(eldoc                     :wk "eldoc")
    "l d" '(xref-find-definitions   :wk "definition")
    "l D" '(eglot-find-declaration  :wk "declaration")
    "l i" '(eglot-find-implementation :wk "implementation")
    "l R" '(xref-find-references    :wk "references")
    "l t" '(eglot-find-typeDefinition :wk "type def")
    "l e" '(flymake-show-buffer-diagnostics :wk "list errors")

    "p"   '(:ignore t :wk "project")
    "p p" '(project-switch-project           :wk "switch")
    "p f" '(project-find-file                :wk "find file")
    "p d" '(project-dired                    :wk "dired root")
    "p b" '(project-switch-to-buffer         :wk "buffer")
    "p k" '(project-kill-buffers             :wk "kill buffers")
    "p s"   '(:ignore t :wk "search")
    "p s s" '(project-find-regexp            :wk "grep")
    "p s r" '(project-query-replace-regexp   :wk "replace (regex)")
    "p c" '(project-compile                  :wk "compile")
    "p !" '(project-shell-command            :wk "shell command")
    "p &" '(project-async-shell-command      :wk "async shell cmd")
    "p e" '(project-eshell                   :wk "eshell")
    "p v" '(project-shell                    :wk "shell")

    "s"   '(:ignore t :wk "search")
    "s s" '(swiper                    :wk "search file")
    "s b" '(swiper-all                :wk "search buffers")
    "s d" '(counsel-rg                :wk "search directory")
    "s f" '(yaz/search-in-file        :wk "search in file...")
    "s D" '(yaz/search-in-directory   :wk "search in dir...")
    "s i" '(counsel-imenu             :wk "search symbols")
    "s I" '(imenu-list-smart-toggle   :wk "symbol sidebar")
    "s a" '(xref-find-apropos         :wk "search symbols (project)")
    "s r" '(query-replace             :wk "replace")
    "s R" '(query-replace-regexp      :wk "replace regex")
    "s m" '(man                       :wk "man")
    "s w" '(woman                     :wk "woman")
    "s g" '(yaz/search-on-browser     :wk "google")
    "s G" '(yaz/web-search            :wk "web search...")
    "s x" '(deadgrep                  :wk "deadgrep")
    "s ." '(ivy-resume                :wk "resume last search")

    "S"   '(:ignore t :wk "sessions")
    "S S" '(yaz/session-save          :wk "save")
    "S s" '(yaz/session-save-as       :wk "save as...")
    "S l" '(yaz/session-load          :wk "load / switch...")
    "S r" '(yaz/session-reload        :wk "reload from disk")
    "S d" '(yaz/session-delete        :wk "delete...")
    "S c" '(yaz/session-clear         :wk "clear buffers")
    "S i" '(yaz/session-info          :wk "info")
    "S t" '(desktop-save-mode         :wk "toggle auto-save")

    "j"   '(:ignore t :wk "jump")
    "j j" '(avy-goto-char-timer       :wk "jump to char")
    "j l" '(avy-goto-line             :wk "jump to line")
    "j w" '(avy-goto-word-1           :wk "jump to word")

    "t"   '(:ignore t :wk "toggle")
    "t f" '(toggle-frame-fullscreen   :wk "fullscreen")
    "t l" '(display-line-numbers-mode :wk "line numbers")
    "t m" '(yaz/toggle-mouse-inhibit  :wk "mouse")
    "t z" '(yaz/toggle-writing-mode    :wk "zen mode")
    "t s" '(flyspell-mode             :wk "spell check")

    "n"   '(:ignore t :wk "neotree")
    "n d" '(neotree-dir                :wk "open dir")
    "n f" '(neotree-find               :wk "find file")
    "n r" '(neotree-refresh            :wk "refresh")
    "n h" '(neotree-hidden-file-toggle :wk "hidden files")
    "n c" '(neotree-change-root        :wk "change root")
    "n s" '(neotree-stretch-toggle     :wk "stretch")
    "n p" '(neotree-projectile-action  :wk "project root")

    "w"   '(:ignore t :wk "windows")
    "w w" '(other-window              :wk "other")
    "w d" '(delete-window             :wk "delete")
    "w s" '(split-window-below        :wk "split below")
    "w v" '(split-window-right        :wk "split right")
    "w h" '(windmove-left             :wk "move left")
    "w j" '(windmove-down             :wk "move down")
    "w k" '(windmove-up               :wk "move up")
    "w l" '(windmove-right            :wk "move right")
    "w H" '(evil-window-move-far-left :wk "move win left")
    "w J" '(evil-window-move-very-bottom :wk "move win down")
    "w K" '(evil-window-move-very-top :wk "move win up")
    "w L" '(evil-window-move-far-right :wk "move win right")
    "w =" '(balance-windows           :wk "balance")
    "w +" '(enlarge-window            :wk "enlarge v")
    "w -" '(shrink-window             :wk "shrink v")
    "w >" '(enlarge-window-horizontally :wk "enlarge h")
    "w <" '(shrink-window-horizontally :wk "shrink h")
    "w m" '(delete-other-windows      :wk "maximize")
    "w u" '(winner-undo               :wk "undo")
    "w r" '(winner-redo               :wk "redo")

    "x"   '(:ignore t :wk "system")
    "x D" '(yaz/disk-usage            :wk "disk usage")
    "x m" '(yaz/memory-usage          :wk "memory")
    "x i" '(yaz/ip-info               :wk "ip info")
    "x I" '(yaz/ip-public             :wk "public ip")
    "x o" '(yaz/ports                 :wk "ports")
    "x h" '(yaz/htop                  :wk "htop")
    "x c" '(yaz/cpu-info              :wk "cpu info")
    "x s" '(yaz/system-info           :wk "system info")
    "x n" '(yaz/network-connections   :wk "network")
    "x e"   '(:ignore t :wk "processes (emacs)")
    "x e l" '(list-processes          :wk "list emacs procs")
    "x e k" '(kill-process            :wk "kill process")
    "x e K" '(kill-process-force      :wk "kill -9 process")
    "x e s" '(signal-process          :wk "signal process")
    "x p"   '(:ignore t :wk "processes (external)")
    "x p l" '(yaz/list-processes      :wk "list")
    "x p k" '(yaz/kill-process        :wk "kill")
    "x p K" '(yaz/kill-process-force  :wk "kill -9")
    "x p s" '(yaz/signal-process      :wk "signal")

    "o"   '(:ignore t :wk "org")
    "o a" '(org-agenda                :wk "agenda")
    "o c" '(org-capture               :wk "capture")
    "o l" '(org-store-link            :wk "store link")
    "o f"   '(:ignore t :wk "files")
    "o f s" '(yaz/find-school-file    :wk "find school file")
    "o f S" '(yaz/new-school-file     :wk "new school file")
    "o f p" '(yaz/find-project-file   :wk "find project file")
    "o f P" '(yaz/new-project-file    :wk "new project file")
    "o f l" '(yaz/find-learning-file  :wk "find learning file")
    "o f L" '(yaz/new-learning-file   :wk "new learning file")
    "o f f" '(yaz/open-org-file       :wk "find any org file")
    "o n"   '(:ignore t :wk "roam")
    "o n f" '(org-roam-node-find      :wk "find node")
    "o n i" '(org-roam-node-insert    :wk "insert node")
    "o n c" '(org-roam-capture        :wk "capture")
    "o n l" '(org-roam-buffer-toggle  :wk "toggle buffer")
    "o n t" '(org-roam-dailies-goto-today :wk "today's daily")
    "o r"   '(:ignore t :wk "research")
    "o r r" '(yaz/create-paper-review-from-bib :wk "review from bib")
    "o r f" '(yaz/create-paper-review-from-pdf :wk "review from pdf")
    "o r c" '(citar-insert-citation   :wk "insert citation")
    "o r o" '(citar-open              :wk "open paper")
    "o r n" '(citar-open-notes        :wk "open notes")
    "o r l" '(citar-open-link         :wk "open link"))
)

(add-hook 'prog-mode-hook #'hs-minor-mode)

(winner-mode 1)

(provide 'keybindings)
;;; keybindings.el ends here
