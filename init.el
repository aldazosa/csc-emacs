(setq gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3")

(require 'package)
(add-to-list 'package-archives
             '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))


;; keep the installed packages in .emacs.d
(setq package-user-dir (expand-file-name "elpa" user-emacs-directory))
(package-initialize)

;; update the package metadata if the local cache is missing
(unless package-archive-contents
  (package-refresh-contents))

;; Always load newest byte code
(setq load-prefer-newer t)

;; reduce the frequency of garbage collection by making it happen on
;; each 50MB of allocated data (the default is on every 0.76MB)
(setq gc-cons-threshold 50000000)

;; warn when opening files bigger than 100MB
(setq large-file-warning-threshold 100000000)

;; nice scrolling
(setq scroll-margin 0
      scroll-conservatively 100000
      scroll-preserve-screen-position 1)

;; more useful frame title, that shows either a file or a
;; buffer name (if the buffer isn't visiting a file)
(setq frame-title-format
      '((:eval (if (buffer-file-name)
                   (abbreviate-file-name (buffer-file-name))
                 "%b"))))


;; smart tab behavior - indent or complete
(setq tab-always-indent 'complete)

(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(eval-when-compile
  (require 'use-package))

(setq use-package-verbose t)

(when (null package-archive-contents)
  (package-refresh-contents))

(use-package diminish
  :ensure t)

(use-package bind-key
  :ensure t)

(use-package expand-region
  :ensure t
  :bind ("C-=" . er/expand-region))

(use-package paredit
  :diminish paredit-mode
  :ensure t
  :config
  (defun paredit-wrap-round-from-behind ()
    (interactive)
    (forward-sexp -1)
    (paredit-wrap-round)
    (insert " ")
    (forward-char -1)) ;; bind de esta función
  (add-hook 'emacs-lisp-mode-hook #'paredit-mode)
  (add-hook 'lisp-interaction-mode-hook #'paredit-mode)
  (add-hook 'ielm-mode-hook #'paredit-mode)
  (add-hook 'lisp-mode-hook #'paredit-mode)
  (add-hook 'clojure-mode-hook 'enable-paredit-mode)
  (add-hook 'eval-expression-minibuffer-setup-hook #'paredit-mode)
  (add-hook 'scheme-mode-hook 'enable-paredit-mode)
  :bind (:map paredit-mode-map
              ("M-)" . paredit-wrap-round-from-behind)))

(use-package paren
  :config
  (show-paren-mode +1))

(use-package abbrev
  :config
  (setq save-abbrevs 'silently)
  (setq-default abbrev-mode t))

;; Add parts of each file's directory to the buffer name if not unique
(use-package uniquify
  :config
  (setq uniquify-buffer-name-style 'forward)
  (setq uniquify-separator "/")
  ;; rename after killing uniquified
  (setq uniquify-after-kill-buffer-p t)
  ;; don't muck with special buffers
  (setq uniquify-ignore-buffers-re "^\\*"))

;; saveplace remembers your location in a file when saving files
(use-package saveplace
  :ensure t
  :config
  (setq-default save-place t)
  (setq save-place-file (expand-file-name ".places" user-emacs-directory)))

(use-package rainbow-delimiters
  :ensure t)

;; (use-package rainbow-mode
;;   :ensure t
;;   :config
;;   (add-hook 'prog-mode-hook #'rainbow-mode))

(use-package cider
  :ensure t
  ;; :pin melpa-stable
  :config
  (add-hook 'cider-mode-hook #'eldoc-mode)
  (add-hook 'cider-repl-mode-hook #'eldoc-mode)
  (add-hook 'cider-repl-mode-hook #'paredit-mode)
  (add-hook 'cider-repl-mode-hook #'rainbow-delimiters-mode)
  ;;
  (setq nrepl-hide-special-buffers t)
  (setq cider-repl-display-help-banner nil)
  (setq cider-repl-use-pretty-printing t)
  (setq cider-repl-history-file "~/.emacs.d/nrepl-history")
  (defun insert-ignore-form ()
    (interactive)
    (insert "#_")
    (indent-sexp))
  (define-key clojure-mode-map (kbd "ESC M-;") 'insert-ignore-form)
  (put-clojure-indent '-> 0)
  (put-clojure-indent '->> 0)
  (define-clojure-indent
    (fn-traced 'defun)
    (some-> 1)
    (some->> 1))
    :bind (:map clojure-mode-map
              ("C-c C-;" . cider-eval-defun-to-comment)
              ("C-c C-n" . cider-macroexpand-1)
              :map cider-repl-mode-map
              ("C-M-q" . prog-indent-sexp)))

(use-package clojure-mode
  :ensure t
  :config
  (add-hook 'clojure-mode-hook #'paredit-mode)
  (add-hook 'clojure-mode-hook #'subword-mode)
  (add-hook 'clojure-mode-hook #'rainbow-delimiters-mode)
  ;;
  (setq clojure-indent-style :align-arguments)
  ;;
  (setq cider-cljs-lein-repl
        "(do (require 'figwheel-sidecar.repl-api)
           (figwheel-sidecar.repl-api/start-figwheel!)
           (figwheel-sidecar.repl-api/cljs-repl))")
  (setq cider-pprint-fn 'puget)
  (setq cider-prompt-for-symbol nil)
  (setq cider-save-file-on-load t)
  (setq cider-font-lock-dynamically '(macro core function var))
  (setq clojure-align-forms-automatically t))


(use-package clj-refactor
  :ensure t
  ;; :pin melpa-stable
  :config
  (cljr-add-keybindings-with-prefix "C-c C-m")
  (setq cljr-favor-prefix-notation nil)
  (setq cljr-hotload-dependencies t)
  ;; (setq cljr-use-metadata-for-privacy t)
  (setq clojure-use-metadata-for-privacy t)
  (add-hook 'clojure-mode-hook 'clj-refactor-mode))

(use-package company
  :ensure t
  :config
  (global-company-mode)
  :bind (:map company-active-map
              ("C-n" . company-select-next)
              ("C-p" . company-select-previous)))

(use-package dockerfile-mode
  :ensure t
  :mode "Dockerfile")

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   (quote
    (dockerfile-mode company clj-refactor cider rainbow-delimiters paredit expand-region diminish use-package))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
