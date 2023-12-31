(setq inhibit-startup-message t)

(defvar efs/default-font-size 180)
(defvar efs/default-variable-font-size 180)

;; Make frame transparency overridable
(defvar efs/frame-transparency '(90 . 90))

;; The default is 800 kilobytes.  Measured in bytes.
(setq gc-cons-threshold (* 50 1000 1000))

(defun efs/display-startup-time ()
  (message "Emacs loaded in %s with %d garbage collections."
           (format "%.2f seconds"
                   (float-time
                     (time-subtract after-init-time before-init-time)))
           gcs-done))

(add-hook 'emacs-startup-hook #'efs/display-startup-time)

;;(scroll-bar-mode -1)        ; Disable visible scrollbar
;(tool-bar-mode -1)          ; Disable the toolbar
(tooltip-mode -1)           ; Disable tooltips
;;(set-fringe-mode 10)        ; Give some breathing room

(menu-bar-mode -1)            ; Disable the menu bar

(global-hl-line-mode 1)     ; highlight current line

;; Set up the visible bell
(setq visible-bell t)

(column-number-mode)
(global-display-line-numbers-mode t)

;; Set frame transparency
;;(set-frame-parameter (selected-frame) 'alpha efs/frame-transparency)
;;(add-to-list 'default-frame-alist `(alpha . ,efs/frame-transparency))
;;(set-frame-parameter (selected-frame) 'fullscreen 'maximized)
;;(add-to-list 'default-frame-alist '(fullscreen . maximized))

;; Disable line numbers for some modes
(dolist (mode '(org-mode-hook
                term-mode-hook
                shell-mode-hook
                treemacs-mode-hook
                eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))


(set-face-attribute 'default nil :font "Fira Code Retina" :height 120)

;; Set the fixed pitch face
(set-face-attribute 'fixed-pitch nil :font "Fira Code Retina" :height 120)

;; Set the variable pitch face
(set-face-attribute 'variable-pitch nil :font "Cantarell" :height 120 :weight 'regular)

;; Make ESC quit prompts
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

(load-theme 'tango-dark)

;; Initialize package sources
(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; Initialize use-package on non-Linux platforms
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

(use-package nerd-icons
;; :custom
;; The Nerd Font you want to use in GUI
;; "Symbols Nerd Font Mono" is the default and is recommended
;; but you can use any other Nerd Font if you want
;; (nerd-icons-font-family "Symbols Nerd Font Mono")
)

(use-package auto-package-update
  :custom
  (auto-package-update-interval 7)
  (auto-package-update-prompt-before-update t)
  (auto-package-update-hide-results t)
  :config
  (auto-package-update-maybe)
  (auto-package-update-at-time "09:00"))

(use-package command-log-mode)

(use-package doom-themes
  :init (load-theme 'doom-molokai t))

(use-package organic-green-theme
  :init (load-theme 'organic-green t))

(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :custom ((doom-modeline-height 32)))

;; Try IVY
(use-package ivy
  :bind (("C-s" . swiper)
         :map ivy-minibuffer-map
         ("TAB" . ivy-alt-done)
         ("C-l" . ivy-alt-done)
         ("C-j" . ivy-next-line)
         ("C-k" . ivy-previous-line)
         :map ivy-switch-buffer-map
         ("C-k" . ivy-previous-line)
         ("C-l" . ivy-done)
         ("C-d" . ivy-switch-buffer-kill)
         :map ivy-reverse-i-search-map
         ("C-k" . ivy-previous-line)
         ("C-d" . ivy-reverse-i-search-kill))
  :config
  (ivy-mode 1))

(use-package counsel
  :bind (("M-x" . counsel-M-x)
	 ("C-x b" . counsel-ibuffer)
	 ("C-x C-f" . counsel-find-file)
	 :map minibuffer-local-map
	 ("C-r" . 'counsel-minibuffer-history)))


;;(use-package ivy-rich
;;  :after ivy
;;  :init
;;  (ivy-rich-mode 1))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package which-key
  :init (which-key-mode)
  :config
  (setq which-key-idle-delay 0.6))

(use-package helpful
  :commands (helpful-callable helpful-variable helpful-command helpful-key)
  :custom
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable)
  :bind
  ([remap describe-function] . counsel-describe-function)
  ([remap describe-command] . helpful-command)
  ([remap describe-variable] . counsel-describe-variable)
  ([remap describe-key] . helpful-key))

(use-package terraform-mode)
(use-package yaml-mode)

(global-whitespace-mode 1)
;; see the apropos entry for whitespace-style
(setq
   whitespace-style
   '(face ; viz via faces
     trailing ; trailing blanks visualized
     lines-tail ; lines beyond
                ; whitespace-line-column
     space-before-tab
     space-after-tab
     newline ; lines with only blanks
     indentation ; spaces used for indent
                 ; when config wants tabs
     empty ; empty lines at beginning or end
     )
   whitespace-line-column 128 ; column at which
        ; whitespace-mode says the line is too long
)

;; go stuff
(use-package go-mode)
(use-package go-eldoc)

;;(use-package add-mode-hook)
;;(add-hook 'go-mode-hook (lambda ()
;;			       (setq tab-width 4)))

(setenv "GOPATH" (concat (getenv "HOME") "/go"))
(setenv "PATH" (concat (getenv "PATH") (concat (concat ":" (getenv "GOPATH")) "/bin")))

(setq exec-path (append exec-path '(concat (getenv("GOPATH") "/bin"))))
(setenv "PATH" (concat (getenv "PATH") ":/usr/local/go/bin"))
(setq exec-path (append exec-path '("/usr/local/go/bin")))

(add-hook 'before-save-hook 'gofmt-before-save)
;;https://honnef.co/articles/writing-go-in-emacs/
;;(add-hook 'go-mode-hook (lambda ()
;;                          (local-set-key (kbd "C-c C-r") 'go-remove-unused-imports)))

(use-package all-the-icons
  :if (display-graphic-p)
  :commands all-the-icons-install-fonts
  :init
  (unless (find-font (font-spec :name "all-the-icons"))
    (all-the-icons-install-fonts t)))

(use-package all-the-icons-dired
  :if (display-graphic-p)
  :hook (dired-mode . all-the-icons-dired-mode))

(use-package general)

(general-define-key
  "C-M-j" 'counsel-switch-buffer)

(use-package projectile
  :config (projectile-mode)
  :custom ((projectile-completion-system 'ivy))
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :init
  (when (file-directory-p "~/Pro-Tech")
    (setq projectile-project-search-path '("~/Pro-Tech")))
  (setq projectile-switch-project-action #'projectile-dired))

(use-package counsel-projectile
  :config (counsel-projectile-mode))


;; set the starting window size
(setq default-frame-alist
      '((top . 100) (left . 100)
        (width . 250) (height . 800)))

;; central backup file location
(setq backup-directory-alist '(("." . "~/.emacs_backups")))
(setq backup-by-copying t)

(global-set-key "j" 'eshell)
