;;; early-init.el -*- lexical-binding: t; -*-


(setq gc-cons-threshold most-positive-fixnum  ; GC threshold during startup
      gc-cons-percentage 0.6)

(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 50 1024 1024)  ; 50MB for LSP/heavy workloads
                  gc-cons-percentage 0.1)
            (run-with-idle-timer 5 t #'garbage-collect)))

(setq inhibit-startup-message t
      inhibit-startup-echo-area-message t
      initial-scratch-message nil
      inhibit-compacting-font-caches t
      read-process-output-max (* 1024 1024)
      process-adaptive-read-buffering nil)
      
(setq-default bidi-display-reordering 'left-to-right
              bidi-paragraph-direction 'left-to-right)
(setq bidi-inhibit-bpa t)


(defvar yaz/file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq file-name-handler-alist yaz/file-name-handler-alist)))

(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

;; Set initial background to prevent white flash before theme loads
(set-face-attribute 'default nil :background "#292828" :foreground "#ebdbb2")

;; Native compilation settings (most effective in early-init)
(setq package-native-compile t
      native-comp-jit-compilation t
      native-comp-speed 2)

(setq package-enable-at-startup nil)
;; one precomputed autoloads file instead of scanning every package dir at startup.
;; package.el regenerates it on install/delete; after manual changes in elpa/
;; run M-x package-quickstart-refresh.
(setq package-quickstart t)

;;; early-init.el ends here
