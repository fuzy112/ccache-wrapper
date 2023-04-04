;;; ccache-wrapper.el --- Minor mode for compilation with ccache -*- lexical-binding: t; -*-

;;; Commentary:
;; Usage:
;; Add the following code to `init.el' file.
;; #+begin_src elisp
;; (use-package ccache-wrapper
;;  :demand t
;;  :straight (ccache-wrapper :type git :host github :repo "fuzy112/ccache-wrapper"
;;                            :files ("ccache-wrapper.c"
;;                                    "ccache-wrapper.el"))
;;  :commands (ccache-wrapper-mode)
;;  :config
;;  (ccache-wrapper-mode +1))
;; #+end_src elisp
;;

;;; Code:
(require 'compile)

(defvar ccache-wrapper-debug nil)

(defvar ccache-wrapper-path
  (let ((default-directory (file-name-directory (locate-library "ccache-wrapper.el"))))
    (unless (file-exists-p "ccache-wrapper.so")
      (shell-command "cc -shared -fPIC -O2 -o ccache-wrapper.so ccache-wrapper.c "))
    (expand-file-name "ccache-wrapper.so")))

(defconst ccache-wrapper-compilation-modes '(compilation-mode comint-mode))

(defun ccache-wrapper-environment ()
  (cons (format "LD_PRELOAD=%s" (expand-file-name ccache-wrapper-path))
        (if ccache-wrapper-debug
            (list "CCACHE_WRAPPER_DEBUG=1")
          nil)))

(define-minor-mode ccache-wrapper-mode
  "Minor mode for compilation with `ccache'."
  :lighter " ccache"
  :global nil
  :group 'comilation
  (if ccache-wrapper-mode
      (setq-default compilation-environment (append (ccache-wrapper-environment)
                                                    compilation-environment))
    (kill-local-variable 'compilation-environment)))


(define-minor-mode global-ccache-wrapper-mode
  "Global minor mode for compilation with `ccache'."
  :global t
  :group 'compilation
  (if global-ccache-wrapper-mode
      (dolist (mode ccache-wrapper-compilation-modes)
        (add-hook (intern (format "%s-hook" mode)) #'ccache-wrapper-mode))
    (dolist (mode ccache-wrapper-compilation-modes)
      (remove-hook (intern (format "%s-hook" mode)) #'ccache-wrapper-mode))))

(provide 'ccache-wrapper)
;;; ccache-wrapper.el ends here
