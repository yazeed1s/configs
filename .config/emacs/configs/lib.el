;;; lib.el --- Shared utility library -*- lexical-binding: t; -*-
 
;;; Commentary:
 
;; Consolidates yaz-utils, yaz-file-utils, and yaz-system.
 
;;; Code:
 
;; --- General Utilities (yaz-utils) ---
 

(defun yaz/increment-number-at-point (&optional arg) "increment number at point by arg (default 1)." (interactive "p") 
  (save-excursion 
    (skip-chars-backward "0-9") 
    (or (looking-at "[0-9]+") 
      (error "no number at point")) 
    (replace-match 
      (number-to-string 
        (+ (or arg 1) 
          (string-to-number (match-string 0))))))) 

(defun yaz/decrement-number-at-point (&optional arg) "decrement number at point by arg (default 1)." (interactive "p") 
  (yaz/increment-number-at-point (- (or arg 1)))) 

(defun yaz/duplicate-line () "duplicate current line." (interactive) 
  (let ((col (current-column))) 
    (save-excursion 
      (move-beginning-of-line 1) (kill-line) (yank) (newline) (yank)) (forward-line 1) (move-to-column col))) 

(defun yaz/move-line-up () "move current line up." (interactive) (transpose-lines 1) (forward-line -2) 
  (indent-according-to-mode)) 

(defun yaz/move-line-down () "move current line down." (interactive) (forward-line 1) (transpose-lines 1) (forward-line -1) 
  (indent-according-to-mode)) 

(defun yaz/join-line-below () "join line below to current line." (interactive) (forward-line 1) (join-line)) 

(defun yaz/join-line-above () "join current line to line above." (interactive) (join-line)) 

(defun yaz/indent-buffer () "indent entire buffer." (interactive) 
  (save-excursion 
    (indent-region (point-min) (point-max))) 
  (message "buffer indented")) 

(defun yaz/cleanup-buffer () "cleanup buffer: indent, untabify, delete trailing whitespace." (interactive) 
  (save-excursion (yaz/indent-buffer) 
    (untabify (point-min) (point-max)) 
    (delete-trailing-whitespace)) 
  (message "buffer cleaned up")) 

(defun yaz/count-words-buffer () "count words, characters, and lines in buffer." (interactive) 
  (let ((words (count-words (point-min) (point-max))) (chars (- (point-max) (point-min))) (lines 
        (count-lines (point-min) (point-max)))) 
    (message "words: %d | chars: %d | lines: %d" words chars lines))) 

(defun yaz/delete-blank-lines () "delete all blank lines in buffer." (interactive) 
  (save-excursion 
    (goto-char (point-min)) 
    (flush-lines "^\\s-*$")) 
  (message "deleted all blank lines")) 

(defun yaz/sort-lines-buffer () "sort all lines in buffer." (interactive) 
  (save-excursion 
    (sort-lines nil (point-min) (point-max))) 
  (message "buffer lines sorted")) 

(defun yaz/uniquify-lines () "remove duplicate lines in buffer." (interactive) 
  (save-excursion 
    (delete-duplicate-lines (point-min) (point-max))) 
  (message "removed duplicate lines")) 
;; --- File Utilities (yaz-file-utils) ---
 

(defun yaz/copy-file-path () "copy current buffer's file path to clipboard." (interactive) 
  (if-let*
    ((path (or buffer-file-name default-directory)))
    (progn (kill-new path) 
      (message "copied: %s" path)) 
    (message "no file associated with buffer"))) 

(defun yaz/copy-file-name () "copy current buffer's file name to clipboard." (interactive) 
  (if-let*
    ((name (file-name-nondirectory (or buffer-file-name (buffer-name)))))
    (progn (kill-new name) 
      (message "copied: %s" name)) 
    (message "no file name available"))) 

(defun yaz/copy-file-name-base () "copy current file name without extension." (interactive) 
  (if-let*
    ((name (file-name-sans-extension (file-name-nondirectory (or buffer-file-name (buffer-name))))))
    (progn (kill-new name) 
      (message "copied: %s" name)) 
    (message "no file name available"))) 

(defun yaz/copy-directory-path () "copy current file's directory path." (interactive) 
  (if-let*
    ((dir (file-name-directory (or buffer-file-name default-directory))))
    (progn (kill-new dir) 
      (message "copied: %s" dir)) 
    (message "no directory available"))) 

(defun yaz/delete-file-and-buffer () "kill buffer and delete associated file." (interactive) 
  (let ((filename (buffer-file-name))) 
    (if (not filename) 
      (message "buffer not visiting a file") 
      (when (y-or-n-p 
          (format "delete %s? " 
            (file-name-nondirectory filename))) 
        (delete-file filename) 
        (kill-buffer (current-buffer)) 
        (message "deleted: %s" filename))))) 

(defun yaz/rename-file-and-buffer () "rename current file and buffer." (interactive) 
  (let ((filename (buffer-file-name))) 
    (if (not filename) 
      (message "buffer not visiting a file") 
      (let ((new-name (read-file-name "new name: " 
              (file-name-directory filename) nil nil 
              (file-name-nondirectory filename)))) 
        (cond ((vc-backend filename) (vc-rename-file filename new-name)) 
          (t (rename-file filename new-name t) (set-visited-file-name new-name t t))) 
        (message "renamed to: %s" new-name))))) 

(defun yaz/move-file-to-trash () "move current file to trash." (interactive) 
  (let ((filename (buffer-file-name))) 
    (if (not filename) 
      (message "buffer not visiting a file") 
      (when (y-or-n-p 
          (format "move %s to trash? " 
            (file-name-nondirectory filename))) 
        (move-file-to-trash filename) 
        (kill-buffer (current-buffer)) 
        (message "moved to trash: %s" filename))))) 

(defun yaz/make-file-executable () "make current file executable." (interactive) 
  (let ((filename (buffer-file-name))) 
    (if (not filename) 
      (message "buffer not visiting a file") 
      (chmod filename 
        (logior (file-modes filename) #o111)) 
      (message "made executable: %s" filename)))) 

(defun yaz/open-file-externally () "open current file with external application." (interactive) 
  (let ((file (or buffer-file-name (read-file-name "file: ")))) 
    (start-process "open-external" nil "xdg-open" file) 
    (message "opened externally: %s" file))) 

(defun yaz/reveal-in-file-manager () "reveal current file in system file manager." (interactive) 
  (let ((file (or buffer-file-name default-directory))) 
    (start-process "reveal-file" nil "xdg-open" 
      (file-name-directory file)) 
    (message "here: %s" file))) 
 

(defvar yaz/terminal-command "alacritty" "terminal emulator command to use.") 

(defvar yaz/terminal-args '("--working-directory") "arguments for terminal command (before directory).") 

(defun yaz/run-tui (cmd buffer-name) 
  (let ((buf (get-buffer buffer-name))) 
    (if (and buf (get-buffer-process buf)) 
      (switch-to-buffer buf) 
      (when buf (kill-buffer buf)) 
      (ansi-term cmd buffer-name) 
      (set-process-sentinel 
        (get-buffer-process (current-buffer)) 
        (lambda (proc _event) 
          (when (memq (process-status proc) '(exit signal)) 
          (kill-buffer (process-buffer proc)))))))) 

(defun yaz/shell-command-to-string-or-buffer 
  (cmd &optional buffer-name) 
  (let* 
    ((buf-name (or buffer-name "*shell output*")) 
      (output (string-trim (shell-command-to-string cmd)))) 
    (if (and (< (length output) 200) (not (string-match-p "\n.*\n" output))) (message "%s" output) 
      (with-current-buffer 
        (get-buffer-create buf-name) 
        (let ((inhibit-read-only t)) (erase-buffer) 
          (insert (propertize (format "command: %s\n" cmd) 'face '(:weight bold :inherit font-lock-keyword-face))) 
          (insert (propertize "----------------------------\n" 'face 'shadow)) (insert output) 
          (goto-char (point-min)) (read-only-mode 1) 
          (local-set-key (kbd "q") 'quit-window) 
        (display-buffer (current-buffer))))))) 

(defun yaz/async-shell-reuse (cmd buffer-name) "run cmd async in buffer-name" 
  (let ((buf (get-buffer buffer-name))) 
    (when buf (kill-buffer buf))) 
  (async-shell-command cmd buffer-name)) 

(defun yaz/htop () "open htop in ansi-term." (interactive) 
  (yaz/run-tui "/usr/bin/htop" "*htop*")) 

(defun yaz/ncdu () "open ncdu (disk usage) in current directory." (interactive) 
  (yaz/run-tui 
    (format "/usr/bin/ncdu %s" default-directory) "*ncdu*")) 

(defun yaz/lazygit () "open lazygit in current directory." (interactive) 
  (if (executable-find "lazygit") 
    (yaz/run-tui "lazygit" "*lazygit*") 
    (message "lazygit not found. install with: sudo pacman -s lazygit"))) 

(defun yaz/ranger () "open ranger file manager." (interactive) 
  (if (executable-find "ranger") 
    (yaz/run-tui 
      (format "ranger %s" default-directory) "*ranger*") 
    (message "ranger not found. install with: sudo pacman -s ranger"))) 

(defun yaz/disk-usage () "show disk usage summary." (interactive) 
  (yaz/shell-command-to-string-or-buffer "df -h --output=source,fstype,size,used,avail,pcent,target | grep -v tmpfs" "*disk usage*")) 

(defun yaz/memory-usage () "show memory usage." (interactive) 
  (yaz/shell-command-to-string-or-buffer "free -h" "*memory*")) 

(defun yaz/cpu-info () "show cpu information." (interactive) 
  (yaz/shell-command-to-string-or-buffer "lscpu | grep -e '(model name|architecture|cpu\\(s\\)|thread|core|socket|mhz)'" "*cpu info*")) 

(defun yaz/system-info () "show comprehensive system information." (interactive) 
  (let 
    (
      (cmd "echo 'system' && uname -a && echo '\ncpu\n' && lscpu | grep -e '(model name|cpu\\(s\\))' && echo '\nmemory\n' && free -h && echo '\ndisk\n' && df -h / && echo '\nuptime\n' && uptime")) 
    (yaz/shell-command-to-string-or-buffer cmd "*system info*"))) 

(defun yaz/ip-info () "show network interface information." (interactive) 
  (yaz/shell-command-to-string-or-buffer "ip -br -c addr" "*ip info*")) 

(defun yaz/ip-public () "show public ip address." (interactive) 
  (yaz/shell-command-to-string-or-buffer "curl -s ifconfig.me" "*public ip*")) 

(defun yaz/ports () "show listening ports." (interactive) 
  (yaz/shell-command-to-string-or-buffer "ss -tulpn" "*ports*")) 

(defun yaz/network-connections () "show active network connections." (interactive) 
  (yaz/shell-command-to-string-or-buffer "ss -tunapo" "*network connections*")) 

(defun yaz/open-terminal-here () "open external terminal in current directory." (interactive) 
  (let ((dir (or default-directory "~"))) 
    (apply #'start-process "terminal" nil yaz/terminal-command 
      (append yaz/terminal-args (list dir))))) 

(defun yaz/copy-to-clipboard (text) "copy text to system clipboard using xclip or wl-copy." 
  (cond 
    ((executable-find "xclip") 
      (with-temp-buffer (insert text) 
        (call-process-region (point-min) (point-max) "xclip" nil nil nil "-selection" "clipboard"))) 
    ((executable-find "wl-copy") 
      (with-temp-buffer (insert text) 
        (call-process-region (point-min) (point-max) "wl-copy"))) 
    (t 
      (message "no clipboard utility found (xclip or wl-copy)")))) 

(defvar yaz/--theme-preview-original-theme nil "Stores the original theme before preview.") 

(defun yaz/--theme-preview-cleanup () "Restore original theme on cancel/quit." 
  (when yaz/--theme-preview-original-theme 
    (mapc #'disable-theme custom-enabled-themes) 
    (load-theme yaz/--theme-preview-original-theme t) 
    (setq yaz/--theme-preview-original-theme nil))) 

(defun yaz/--purge-broken-theme (theme)
  "Strip zombie settings left by THEME after a failed `enable-theme'.

When `load-theme' errors partway through (e.g. a face inheritance
cycle), Emacs has already attached THEME's face/value settings to the
global `theme-face'/`theme-value' plists of every symbol it touched,
but THEME itself never makes it into `custom-enabled-themes'.  Because
`disable-theme' silently no-ops on any theme that isn't in
`custom-enabled-themes' \(see `custom-theme-enabled-p'\), those zombie
entries are never cleaned up - and since `face-spec-recalc' reapplies
every entry in a face's `theme-face' plist regardless of whether its
theme is enabled, the corruption poisons every theme loaded afterwards
that touches the same faces. This manually removes THEME's entries the
way `disable-theme' would, without the enabled-only guard."
  (dolist (setting (get theme 'theme-settings))
    (let* ((prop (car setting))
           (symbol (cadr setting)))
      (put symbol prop (assq-delete-all theme (get symbol prop)))
      (when (eq prop 'theme-face)
        (dolist (frame (frame-list))
          (face-spec-recalc symbol frame)))))
  (setq custom-known-themes (delq theme custom-known-themes)))

(defun yaz/--load-theme-safely (theme)
  "Load THEME and report failures without breaking preview commands."
  (let ((previous-themes custom-enabled-themes))
    (condition-case err
        (progn
          (mapc #'disable-theme custom-enabled-themes)
          (load-theme theme t)
          t)
      (error
       (mapc #'disable-theme custom-enabled-themes)
       (unless (memq theme custom-enabled-themes)
         (yaz/--purge-broken-theme theme))
       (dolist (previous-theme previous-themes)
         (ignore-errors (load-theme previous-theme t)))
       (message "Could not load theme %s: %s" theme (error-message-string err))
       nil))))

(defun yaz/--local-theme-names ()
  "Return theme names installed in the local themes directory."
  (sort
   (mapcar (lambda (file)
             (string-remove-suffix "-theme.el" file))
           (directory-files (expand-file-name "themes" user-emacs-directory)
                            nil "-theme\\.el\\'"))
   #'string<))

(defun yaz/--preview-theme-names ()
  "Return theme names offered by the live preview picker."
  (yaz/--local-theme-names))

(defun yaz/load-theme-with-preview () "Select and load a theme with live preview. As you navigate through themes, each one is temporarily applied. If you cancel, the original theme is restored." (interactive) 
  (setq yaz/--theme-preview-original-theme 
    (car custom-enabled-themes)) 
  (ivy-read "Theme: " 
    (yaz/--preview-theme-names) :preselect 
    (symbol-name 
      (car custom-enabled-themes)) :update-fn 
    (lambda () 
      (let ((theme (intern (ivy-state-current ivy-last)))) 
        (yaz/--load-theme-safely theme))) :action 
    (lambda (theme-name) 
      (let ((theme (intern theme-name))) 
        (when (yaz/--load-theme-safely theme)
          (customize-save-variable 'yaz/saved-theme theme) 
          (setq yaz/--theme-preview-original-theme nil) 
          (message "Theme saved: %s" theme-name)))) :unwind #'yaz/--theme-preview-cleanup :caller 'yaz/load-theme-with-preview)) 


(defun yaz/search-in-file ()
  "ask for a file, open it, and search within it using swiper."
  (interactive)
  (let ((file (read-file-name "Search in file: ")))
    (when (and file (file-exists-p file))
      (find-file file)
      (swiper))))

(defun yaz/search-in-directory ()
  "ask for a directory, then search within it using ripgrep."
  (interactive)
  (let ((dir (read-directory-name "Search in directory: ")))
    (when (and dir (file-directory-p dir))
      (counsel-rg nil dir))))


(defvar yaz/search-engines
  '(("Google"           . "https://www.google.com/search?q=%s")
    ("GitHub"           . "https://github.com/search?q=%s")
    ("YouTube"          . "https://www.youtube.com/results?search_query=%s")
    ("Stack Overflow"   . "https://stackoverflow.com/search?q=%s")
    ("Go Docs"          . "https://pkg.go.dev/search?q=%s")
    ("Go Stdlib"        . "https://pkg.go.dev/search?q=%s&m=")
    ("C/C++ Reference"  . "https://en.cppreference.com/mwiki/index.php?search=%s")
    ("Arch Wiki"        . "https://wiki.archlinux.org/index.php?search=%s")
    ("AUR"              . "https://aur.archlinux.org/packages?K=%s")
    ("Man Pages"        . "https://man.archlinux.org/search?q=%s")
    ("Wikipedia"        . "https://en.wikipedia.org/w/index.php?search=%s")
    ("Reddit"           . "https://www.reddit.com/search/?q=%s"))
  "Alist of search engine names to URL templates.")

(defun yaz/web-search ()
  "Search the web using a selected engine. Pre-fills query with
region or word at point."
  (interactive)
  (let* ((default-query
           (if (use-region-p)
               (buffer-substring-no-properties (region-beginning) (region-end))
             (thing-at-point 'symbol t)))
         (engine (ivy-read "Search engine: "
                           (mapcar #'car yaz/search-engines)
                           :require-match t))
         (url-template (cdr (assoc engine yaz/search-engines)))
         (query (read-string (format "%s: " engine) default-query)))
    (when (and url-template (not (string-empty-p query)))
      (browse-url (format url-template (url-hexify-string query))))))

(defun yaz/search-on-browser ()
  "Quick Google search. Pre-fills with region or word at point."
  (interactive)
  (let* ((default-query
           (if (use-region-p)
               (buffer-substring-no-properties (region-beginning) (region-end))
             (thing-at-point 'symbol t)))
         (query (read-string "Google: " default-query)))
    (when (not (string-empty-p query))
      (browse-url (format "https://www.google.com/search?q=%s"
                          (url-hexify-string query))))))

(provide 'lib) 
;;; lib.el ends here
