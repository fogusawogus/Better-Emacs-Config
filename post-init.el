(load-file "~/.emacs.d/local.el")
(set-frame-font "personal iosevka 16" t)
(with-eval-after-load 'eglot
  (fset #'eglot--snippet-expansion-fn #'ignore))
(setq-default display-line-numbers-type 'absolute)
(dolist (hook '(prog-mode-hook text-mode-hook conf-mode-hook))
  (add-hook hook #'display-line-numbers-mode))
(add-hook 'after-init-hook #'show-paren-mode)
(setq make-backup-files t)
(setq vc-make-backup-files t)
(setq kept-old-versions 10)
(setq kept-new-versions 10)
(with-eval-after-load 'cc-mode
  (define-key c-mode-base-map (kbd "TAB") #'indent-for-tab-command))
(eldoc-add-command 'c-electric-paren)
(advice-add #'magit-version :override #'ignore)
(setq scroll-conservatively 101)
(add-to-list 'default-frame-alist '(fullscreen . maximized))
(setq split-height-threshold 0)
(setq split-width-threshold nil)
(setq select-enable-clipboard t)
(setq select-enable-primary t)
(setq meow-use-clipboard t)
(global-whitespace-mode 1)
(setq eglot-ignored-server-capabilities '(:codeActionProvider :inlayHintProvider))
(setq menu-bar-mode nil)
(add-hook 'odin-mode-hook #'indent-tabs-mode)

(defun to-projects () (interactive) (find-file "~/projects/"))

(add-hook 'prog-mode-hook (lambda () (interactive) (hs-minor-mode) (diminish 'hs-minor-mode "")))

(use-package diminish
  :ensure t)

(use-package ef-themes
  ;; stupid plugin doesnt load fonts correctly unless i do this
  :defer .000001
  :ensure t
  :config
  (let ((inhibit-redisplay t))
    (mapc #'disable-theme custom-enabled-themes)
    (load-theme 'ef-dream t)))

(use-package doom-themes
  :ensure t
  :custom
  ;; Global settings (defaults)
  (doom-themes-enable-bold nil)   ; if nil, bold is universally disabled
  (doom-themes-enable-italic nil)) ; if nil, italics is universally disabled

(use-package magit
  :ensure t)
(use-package nano-theme
  :ensure t)
(require 'view)
(keymap-global-set "C-v" (lambda () (interactive) (View-scroll-half-page-forward) (move-to-window-line nil)))
(keymap-global-set "M-v" (lambda () (interactive) (View-scroll-half-page-backward) (move-to-window-line nil)))

(setq whitespace-style '(face trailing tabs spaces space-mark tab-mark))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(whitespace-space ((t (:foreground "gray40"))))
 '(whitespace-tab ((t (:foreground "gray40")))))

(when (native-comp-available-p)
  (use-package compile-angel
    :demand t
    :config
    ;; The following disables compilation of packages during installation;
    ;; compile-angel will handle it.
    (setq package-native-compile nil)

    ;; Set `compile-angel-verbose' to nil to disable compile-angel messages.
    ;; (When set to nil, compile-angel won't show which file is being compiled.)
    (setq compile-angel-verbose t)

    ;; The following directive prevents compile-angel from compiling your init
    ;; files. If you choose to remove this push to `compile-angel-excluded-files'
    ;; and compile your pre/post-init files, ensure you understand the
    ;; implications and thoroughly test your code. For example, if you're using
    ;; the `use-package' macro, you'll need to explicitly add:
    ;; (eval-when-compile (require 'use-package))
    ;; at the top of your init file.
    (push "/init.el" compile-angel-excluded-files)
    (push "/early-init.el" compile-angel-excluded-files)
    (push "/pre-init.el" compile-angel-excluded-files)
    (push "/post-init.el" compile-angel-excluded-files)
    (push "/pre-early-init.el" compile-angel-excluded-files)
    (push "/post-early-init.el" compile-angel-excluded-files)

    ;; A local mode that compiles .el files whenever the user saves them.
    ;; (add-hook 'emacs-lisp-mode-hook #'compile-angel-on-save-local-mode)

    ;; A global mode that compiles .el files prior to loading them via `load' or
    ;; `require'. Additionally, it compiles all packages that were loaded before
    ;; the mode `compile-angel-on-load-mode' was activated.
    (compile-angel-on-load-mode 1)
    :diminish compile-angel-on-load-mode))

(use-package exec-path-from-shell
  :if (and (or (display-graphic-p) (daemonp))
           (eq system-type 'darwin)) ; macOS only
  :demand t
  :functions exec-path-from-shell-initialize
  :config
  (dolist (var '("TMPDIR"
                 "SSH_AUTH_SOCK" "SSH_AGENT_PID"
                 "GPG_AGENT_INFO"
                 ;; "FZF_DEFAULT_COMMAND" "FZF_DEFAULT_OPTS" ; fzf
                 ;; "VIRTUAL_ENV" ; Python
                 ;; "GOPATH" "GOROOT" "GOBIN" ; Go
                 ;; "CARGO_HOME" "RUSTUP_HOME" ; Rust
                 ;; "NVM_DIR" "NODE_PATH" ; Node/JS
                 "LANG" "LC_CTYPE"))
    (add-to-list 'exec-path-from-shell-variables var))
  ;; Initialize
  (exec-path-from-shell-initialize))

;; Auto-revert in Emacs is a feature that automatically updates the
;; contents of a buffer to reflect changes made to the underlying file
;; on disk.
(use-package autorevert
  :ensure nil
  :commands (auto-revert-mode global-auto-revert-mode)
  :hook
  (after-init . global-auto-revert-mode)
  :init
  ;; (setq auto-revert-verbose t)
  (setq auto-revert-interval 3)
  (setq auto-revert-remote-files nil)
  (setq auto-revert-use-notify t)
  (setq auto-revert-avoid-polling nil))

;; Recentf is an Emacs package that maintains a list of recently
;; accessed files, making it easier to reopen files you have worked on
;; recently.
(use-package recentf
  :ensure nil
  :commands (recentf-mode recentf-cleanup)
  :hook
  (after-init . recentf-mode)

  :init
  (setq recentf-auto-cleanup (if (daemonp) 300 'never))
  (setq recentf-exclude
        (list "\\.tar$" "\\.tbz2$" "\\.tbz$" "\\.tgz$" "\\.bz2$"
              "\\.bz$" "\\.gz$" "\\.gzip$" "\\.xz$" "\\.zip$"
              "\\.7z$" "\\.rar$"
              "COMMIT_EDITMSG\\'"
              "\\.\\(?:gz\\|gif\\|svg\\|png\\|jpe?g\\|bmp\\|xpm\\)$"
              "-autoloads\\.el$" "autoload\\.el$"))

  :config
  ;; A cleanup depth of -90 ensures that `recentf-cleanup' runs before
  ;; `recentf-save-list', allowing stale entries to be removed before the list
  ;; is saved by `recentf-save-list', which is automatically added to
  ;; `kill-emacs-hook' by `recentf-mode'.
  (add-hook 'kill-emacs-hook #'recentf-cleanup -90))

;; savehist is an Emacs feature that preserves the minibuffer history between
;; sessions. It saves the history of inputs in the minibuffer, such as commands,
;; search strings, and other prompts, to a file. This allows users to retain
;; their minibuffer history across Emacs restarts.
(use-package savehist
  :ensure nil
  :commands (savehist-mode savehist-save)
  :hook
  (after-init . savehist-mode)
  :init
  (setq history-length 300)
  (setq savehist-autosave-interval 600))

;; save-place-mode enables Emacs to remember the last location within a file
;; upon reopening. This feature is particularly beneficial for resuming work at
;; the precise point where you previously left off.
(use-package saveplace
  :ensure nil
  :commands (save-place-mode save-place-local-mode)
  :hook
  (after-init . save-place-mode)
  :init
  (setq save-place-limit 400))

;; Enable `auto-save-mode' to prevent data loss. Use `recover-file' or
;; `recover-session' to restore unsaved changes.
(setq auto-save-default t)

;; Trigger an auto-save after 300 keystrokes
(setq auto-save-interval 300)

;; Trigger an auto-save 30 seconds of idle time.
(setq auto-save-timeout 30)

(use-package corfu
  :ensure t
  :hook ((prog-mode . corfu-mode)
         (shell-mode . corfu-mode)
         (eshell-mode . corfu-mode))
  :custom
  (read-extended-command-predicate #'command-completion-default-include-p)
  (text-mode-ispell-word-completion nil)
  (tab-always-indent 'complete)
  (enable-recursive-minibuffers t)
  (context-menu-mode t)
  (completion-ignore-case t)
  (corfu-auto t)
  (corfu-auto-delay .2)
  (corfu-cycle t)
  (corfu-preselect 'prompt)
  :bind
  (:map corfu-map
        ("TAB" . corfu-next)
        ([tab] . corfu-next)
        ("S-TAB" . corfu-previous)
        ([backtab] . corfu-previous))
  :config
  (keymap-set corfu-map "RET" `(menu-item "" nil :filer
                                          ,(lambda (&optional _)
                                             (and (derived-mode-p 'eshell-mode 'comint-mode)
                                                  #'corfu-send))))
  :init
  (global-corfu-mode)
  (corfu-history-mode))
;; :bind ("C-x C-o" . ))

(use-package cape
  :ensure t
  ;; Bind prefix keymap providing all Cape commands under a mnemonic key.
  ;; Press C-c p ? to for help.
  :commands (cape-dabbrev cape-file cape-elisp-block )
  :bind ("C-c p" . cape-prefix-map) ;; Alternative key: M-<tab>, M-p, M-+
  ;; Alternatively bind Cape commands individually.
  ;; :bind (("C-c p d" . cape-dabbrev)
  ;;        ("C-c p h" . cape-history)
  ;;        ("C-c p f" . cape-file)
  ;;        ...)
  :init
  ;; Add to the global default value of `completion-at-point-functions' which is
  ;; used by `completion-at-point'.  The order of the functions matters, the
  ;; first function returning a result wins.  Note that the list of buffer-local
  ;; completion functions takes precedence over the global list.
  (add-hook 'completion-at-point-functions #'cape-dabbrev)
  (add-hook 'completion-at-point-functions #'cape-file)
  (add-hook 'completion-at-point-functions #'cape-elisp-block)
  ;; ...
  )

(use-package vertico
  :ensure t
  :init
  (vertico-mode))

(use-package orderless
  :ensure t
  :custom
  ;; (orderless-style-dispatchers '(orderless-affix-dispatch))
  ;; (orderless-component-separator #'orderless-escapable-split-on-space)
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles partial-completion))))
  (completion-category-defaults nil)) ;; Disable defaults, use our settings

(use-package marginalia
  :ensure t
  :hook
  (after-init . marginalia-mode))

(use-package embark
  ;; Embark is an Emacs package that acts like a context menu, allowing
  ;; users to perform context-sensitive actions on selected items
  ;; directly from the completion interface.
  :commands (embark-act
             embark-dwim
             embark-export
             embark-collect
             embark-bindings
             embark-prefix-help-command)
  :bind
  (("C-." . embark-act)         ;; pick some comfortable binding
   ("C-;" . embark-dwim)        ;; good alternative: M-.
   ("C-h B" . embark-bindings)) ;; alternative for `describe-bindings'

  :init
  (setq prefix-help-command #'embark-prefix-help-command)

  :config
  ;; Hide the mode line of the Embark live/completions buffers
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none)))))

(use-package embark-consult
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

(use-package consult
  :bind (;; C-c bindings in `mode-specific-map'
         ("C-c M-x" . consult-mode-command)
         ("C-c h" . consult-history)
         ("C-c k" . consult-kmacro)
         ("C-c m" . consult-man)
         ("C-c i" . consult-info)
         ([remap Info-search] . consult-info)
         ;; C-x bindings in `ctl-x-map'
         ("C-x M-:" . consult-complex-command)
         ("C-x b" . consult-buffer)
         ("C-x 4 b" . consult-buffer-other-window)
         ("C-x 5 b" . consult-buffer-other-frame)
         ("C-x t b" . consult-buffer-other-tab)
         ("C-x r b" . consult-bookmark)
         ("C-x p b" . consult-project-buffer)
         ;; Custom M-# bindings for fast register access
         ("M-#" . consult-register-load)
         ("M-'" . consult-register-store)
         ("C-M-#" . consult-register)
         ;; Other custom bindings
         ("M-y" . consult-yank-pop)
         ;; M-g bindings in `goto-map'
         ("M-g e" . consult-compile-error)
         ("M-g f" . consult-flymake)
         ("M-g g" . consult-goto-line)
         ("M-g M-g" . consult-goto-line)
         ("M-g o" . consult-outline)
         ("M-g m" . consult-mark)
         ("M-g k" . consult-global-mark)
         ("M-g i" . consult-imenu)
         ("M-g I" . consult-imenu-multi)
         ;; M-s bindings in `search-map'
         ("M-s d" . consult-find)
         ("M-s c" . consult-locate)
         ("M-s g" . consult-grep)
         ("M-s G" . consult-git-grep)
         ("M-s r" . consult-ripgrep)
         ("M-s l" . consult-line)
         ("M-s L" . consult-line-multi)
         ("M-s k" . consult-keep-lines)
         ("M-s u" . consult-focus-lines)
         ;; Isearch integration
         ("M-s e" . consult-isearch-history)
         :map isearch-mode-map
         ("M-e" . consult-isearch-history)
         ("M-s e" . consult-isearch-history)
         ("M-s l" . consult-line)
         ("M-s L" . consult-line-multi)
         ;; Minibuffer history
         :map minibuffer-local-map
         ("M-s" . consult-history)
         ("M-r" . consult-history))

  ;; Enable automatic preview at point in the *Completions* buffer.
  :hook (completion-list-mode . consult-preview-at-point-mode)

  :init
  ;; Optionally configure the register formatting. This improves the register
  (setq register-preview-delay 0.5
        register-preview-function #'consult-register-format)

  ;; Optionally tweak the register preview window.
  (advice-add #'register-preview :override #'consult-register-window)

  ;; Use Consult to select xref locations with preview
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)

  ;; Aggressive asynchronous that yield instantaneous results. (suitable for
  ;; high-performance systems.) Note: Minad, the author of Consult, does not
  ;; recommend aggressive values.
  ;; Read: https://github.com/minad/consult/discussions/951
  ;;
  ;; However, the author of minimal-emacs.d uses these parameters to achieve
  ;; immediate feedback from Consult.
  ;; (setq consult-async-input-debounce 0.02
  ;;       consult-async-input-throttle 0.05
  ;;       consult-async-refresh-delay 0.02)

  :config
  (consult-customize
   consult-theme :preview-key '(:debounce 0.2 any)
   consult-ripgrep consult-git-grep consult-grep
   consult-bookmark consult-recent-file consult-xref
   consult-source-bookmark consult-source-file-register
   consult-source-recent-file consult-source-project-recent-file
   ;; :preview-key "M-."
   :preview-key '(:debounce 0.4 any))
  (setq consult-narrow-key "<"))

(use-package vundo
  :bind ("C-c v" . vundo)
  :ensure t)


(use-package kirigami
  :commands (kirigami-open-fold
             kirigami-open-fold-rec
             kirigami-close-fold
             kirigami-toggle-fold
             kirigami-open-folds
             kirigami-close-folds-except-current
             kirigami-close-folds)

  :bind
  (("C-c z o" . kirigami-open-fold)          ; Open fold at point
   ("C-c z O" . kirigami-open-fold-rec)      ; Open fold recursively
   ("C-c z r" . kirigami-open-folds)         ; Open all folds
   ("C-c z c" . kirigami-close-fold)         ; Close fold at point
   ("C-c z m" . kirigami-close-folds)        ; Close all folds
   ("C-c z a" . kirigami-toggle-fold)))      ; Toggle fold at point

(use-package apheleia
  :commands (apheleia-mode
             apheleia-global-mode)
  :hook ((prog-mode . apheleia-mode))
  :diminish apheleia-mode)

(use-package dumb-jump
  :commands dumb-jump-xref-activate
  :init
  ;; Register `dumb-jump' as an xref backend so it integrates with
  ;; `xref-find-definitions'. A priority of 90 ensures it is used only when no
  ;; more specific backend is available.
  (add-hook 'xref-backend-functions #'dumb-jump-xref-activate 90)

  (setq dumb-jump-aggressive nil)
  ;; (setq dumb-jump-quiet t)

  ;; Number of seconds a rg/grep/find command can take before being warned to
  ;; use ag and config.
  (setq dumb-jump-max-find-time 3)

  ;; Use `completing-read' so that selection of jump targets integrates with the
  ;; active completion framework (e.g., Vertico, Ivy, Helm, Icomplete),
  ;; providing a consistent minibuffer-based interface whenever multiple
  ;; definitions are found.
  (setq dumb-jump-selector 'completing-read)

  ;; If ripgrep is available, force `dumb-jump' to use it because it is
  ;; significantly faster and more accurate than the default searchers (grep,
  ;; ag, etc.).
  (when (executable-find "rg")
    (setq dumb-jump-force-searcher 'rg)
    (setq dumb-jump-prefer-searcher 'rg)))

(use-package yasnippet
  :commands (yas-minor-mode
             yas-global-mode)

  :hook
  (after-init . yas-global-mode)

  :custom
  (yas-also-auto-indent-first-line t)  ; Indent first line of snippet
  (yas-also-indent-empty-lines t)
  (yas-snippet-revival nil)  ; Setting this to t causes issues with undo
  (yas-wrap-around-region nil) ; Do not wrap region when expanding snippets
  ;; (yas-triggers-in-field nil)  ; Disable nested snippet expansion
  ;; (yas-indent-line 'fixed) ; Do not auto-indent snippet content
  ;; (yas-prompt-functions '(yas-no-prompt))  ; No prompt for snippet choices

  :init
  ;; Suppress verbose messages
  (setq yas-verbosity 0))

(use-package stripspace
  :commands stripspace-local-mode

  ;; Enable for prog-mode-hook, text-mode-hook, conf-mode-hook
  :hook ((prog-mode . stripspace-local-mode)
         (text-mode . stripspace-local-mode)
         (conf-mode . stripspace-local-mode))

  :custom
  ;; The `stripspace-only-if-initially-clean' option:
  ;; - nil to always delete trailing whitespace.
  ;; - Non-nil to only delete whitespace when the buffer is clean initially.
  ;; (The initial cleanliness check is performed when `stripspace-local-mode'
  ;; is enabled.)
  (stripspace-only-if-initially-clean nil)

  ;; Enabling `stripspace-restore-column' preserves the cursor's column position
  ;; even after stripping spaces. This is useful in scenarios where you add
  ;; extra spaces and then save the file. Although the spaces are removed in the
  ;; saved file, the cursor remains in the same position, ensuring a consistent
  ;; editing experience without affecting cursor placement.
  (stripspace-restore-column t)
  :diminish stripspace-local-mode)

(use-package diff-hl
  :commands (diff-hl-mode
             global-diff-hl-mode)
  :hook (prog-mode . diff-hl-mode)
  :init
  (setq diff-hl-flydiff-delay 0.4)  ; Faster
  (setq diff-hl-show-staged-changes nil)  ; Realtime feedback
  (setq diff-hl-update-async t)  ; Do not block Emacs
  (setq diff-hl-global-modes '(not pdf-view-mode image-mode)))

(use-package org
  :commands (org-mode org-version)
  :mode
  ("\\.org\\'" . org-mode)
  :custom
  (org-hide-leading-stars t)
  (org-startup-indented t)
  (org-adapt-indentation nil)
  (org-edit-src-content-indentation 0)
  ;; (org-fontify-done-headline t)
  ;; (org-fontify-todo-headline t)
  ;; (org-fontify-whole-heading-line t)
  ;; (org-fontify-quote-and-verse-blocks t)
  (org-startup-truncated t))

(setq org-directory "~/org/")
(defun org-home () (interactive) (find-file "~/org/main.org"))
(add-hook 'org-mode-hook 'visual-line-mode)

(use-package org-appear
  :commands org-appear-mode
  :hook (org-mode . org-appear-mode))

(use-package eglot
  :ensure nil
  :commands (eglot-ensure
             eglot-rename
             eglot-format-buffer))


(use-package elec-pair
  :ensure nil
  :commands (electric-pair-mode
             electric-pair-local-mode
             electric-pair-delete-pair)
  :hook (after-init . electric-pair-mode))

(use-package prescient
  :ensure t
  :config
  (prescient-persist-mode 1))

(use-package corfu-prescient
  :ensure t
  :after corfu prescient
  :custom
  (corfu-prescient-enable-sorting t)
  (corfu-prescient-override-sorting nil)
  (corfu-prescient-enable-filtering nil)
  :config
  (corfu-prescient-mode 1))

(use-package flycheck
  :ensure t)

(use-package eglot-booster
  :straight (eglot-booster :type git :host nil :repo "https://github.com/jdtsmith/eglot-booster")
  :after eglot
  :config (eglot-booster-mode))

(use-package flycheck-eglot
  :ensure t
  :after (flycheck eglot)
  :config
  (global-flycheck-eglot-mode 1))

(use-package surround
  :ensure t
  :bind (("C-c s i" . surround-insert)
         ("C-c s d" . surround-delete)
         ("C-c s y" . surround-kill)
         ("C-c s c" . surround-change)))

(defun to-config()
  (interactive)
  (find-file "~/.emacs.d/post-init.el"))

(use-package vertico-prescient
  :ensure t
  :after vertico prescient
  :custom
  (vertico-prescient-enable-sorting t)
  (vertico-prescient-override-sorting nil)
  (vertico-prescient-enable-filtering nil)
  :config
  (vertico-prescient-mode 1))

(use-package meow
  :ensure t
  :init
  (defun meow-setup ()
    ;; (setq meow-cheatsheet-layout meow-cheatsheet-layout-qwerty)
    (meow-motion-overwrite-define-key
     '("j" . meow-next)
     '("k" . meow-prev)
     '("<escape>" . ignore))
    (meow-leader-define-key
     ;; Use SPC (0-9) for digit arguments.
     '("1" . meow-digit-argument)
     '("2" . meow-digit-argument)
     '("3" . meow-digit-argument)
     '("4" . meow-digit-argument)
     '("5" . meow-digit-argument)
     '("6" . meow-digit-argument)
     '("7" . meow-digit-argument)
     '("8" . meow-digit-argument)
     '("9" . meow-digit-argument)
     '("0" . meow-digit-argument)
     '("/" . meow-keypad-describe-key)
     '("?" . meow-cheatsheet))
    (meow-normal-define-key
     '("0" . meow-expand-0)
     '("9" . meow-expand-9)
     '("8" . meow-expand-8)
     '("7" . meow-expand-7)
     '("6" . meow-expand-6)
     '("5" . meow-expand-5)
     '("4" . meow-expand-4)
     '("3" . meow-expand-3)
     '("2" . meow-expand-2)
     '("1" . meow-expand-1)
     '("-" . negative-argument)
     '(";" . meow-reverse)
     '("," . meow-inner-of-thing)
     '("." . meow-bounds-of-thing)
     '("[" . meow-beginning-of-thing)
     '("]" . meow-end-of-thing)
     '("a" . meow-append)
     '("A" . meow-open-below)
     '("b" . meow-back-word)
     '("B" . meow-back-symbol)
     '("c" . meow-change)
     '("d" . meow-delete)
     '("D" . meow-backward-delete)
     '("e" . meow-next-word)
     '("E" . meow-next-symbol)
     '("f" . meow-find)
     '("g" . meow-cancel-selection)
     '("G" . meow-grab)
     '("h" . meow-left)
     '("H" . meow-left-expand)
     '("i" . meow-insert)
     '("I" . meow-open-above)
     '("j" . meow-next)
     '("J" . meow-next-expand)
     '("k" . meow-prev)
     '("K" . meow-prev-expand)
     '("l" . meow-right)
     '("L" . meow-right-expand)
     '("m" . meow-join)
     '("n" . meow-search)
     '("o" . meow-block)
     '("O" . meow-to-block)
     '("p" . meow-yank)
     '("q" . meow-quit)
     '("Q" . meow-goto-line)
     '("r" . meow-replace)
     '("R" . meow-swap-grab)
     '("s" . meow-kill)
     '("t" . meow-till)
     '("u" . meow-undo)
     '("U" . meow-undo-in-selection)
     '("v" . meow-visit)
     '("w" . meow-mark-word)
     '("W" . meow-mark-symbol)
     '("x" . meow-line)
     '("X" . meow-goto-line)
     '("y" . meow-save)
     '("Y" . meow-sync-grab)
     '("z" . meow-pop-selection)
     '("'" . repeat)
     '("<escape>" . ignore)
     '(":" . execute-extended-command)
     '("%" . query-replace-regexp)))
  :config
  (meow-setup)
  (meow-global-mode 1))

(use-package elfeed
  :ensure t)

(setq elfeed-feeds
      '("https://nesslabs.com/feed"
        "https://feeds.feedburner.com/scotthyoung/HAHx"
        "https://feeds.feedburner.com/bigthink/main"
        "http://steveblank.com/feed/"
        "http://ben-evans.com/benedictevans?format=rss"
        "https://lethain.com/feeds/"
        "https://hnrss.org/launches"
        "https://blog.pragmaticengineer.com/rss/"
        "https://medium.com/feed/paypal-engineering"
        "http://engineering.grab.com/feed.xml"
        "https://slack.engineering/feed"
        "http://githubengineering.com/atom.xml"
        "https://code.facebook.com/posts/rss"
        "http://labs.spotify.com/feed/"
        "https://instagram-engineering.com/feed"
        "https://blog.cloudflare.com/rss/"
        "https://medium.com/feed/airbnb-engineering"
        "https://dropbox.tech/feed"
        "https://browser.engineering/rss.xml"
        "https://engineering.atspotify.com/feed/"
        "https://engineering.fb.com/feed/"
        "https://jvns.ca/atom.xml"
        "https://sophiebits.com/atom.xml"
        "https://amasad.me/rss"
        "https://developer.nvidia.com/blog/feed"
        "https://blog.ml.cmu.edu/feed/"
        "http://news.mit.edu/rss/topic/artificial-intelligence2"
        "http://bair.berkeley.edu/blog/feed.xml"
        "https://thegradient.pub/rss/"
        "http://googleresearch.blogspot.com/atom.xml"
        "https://pytorch.org/feed"
        "https://interaction-design.org/rss/site_news.xml"
        "https://news.mit.edu/rss/topic/science-technology-and-society"
        "https://news.mit.edu/rss/research"
        "https://news.illinois.edu/feed/"
        "https://xkcd.com/rss.xml"
        "https://www.pff.com/feed/teams/6"))

(use-package meson-mode
  :ensure t)

(setq eglot-booster-io-only t)

(use-package odin-mode
  :straight (odin-mode :type git :host nil :repo "https://github.com/mattt-b/odin-mode")
  :ensure t)

(use-package markdown-mode
  :ensure t)

(use-package avy
  :bind
  ("C-c a :" . avy-goto-char)
  ("C-c a '" . avy-goto-char-2)
  ("C-c a w" . avy-goto-word-1)
  ("C-c a l" . avy-goto-line)
  :ensure t)

(use-package go-mode
  :ensure t)
