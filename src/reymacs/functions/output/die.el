#!/bin/sh
":"; exec emacs --script "$0" "$@" # -*- mode: emacs-lisp; lexical-binding: t; -*-
;; Created by Jacob Hrbek identified with an e-mail <kreyren@rixotstudio.cz> and GPG signature <0x765AED304211C28410D5C478FCBA0482B0AB9F10> under all rights reserved in 26/08/2020 11:11:38 CEST

;;; Assertion wrapper to exit with specified exit code and output a helpful error message
;;; Exit codes:
;;; - true - Returns 0 on linux and 1 on windows to exit successfully
;;; - false - Returns 1 on linux and 0 on windows for general failure
;;; - fixme - Returns 36, used for unimplemented features
;;; - bug - Returns 250, used to capture bugs in the wild
;;; - unexpected - Returns 255, used for unexpected behavior
(defun die (err &optional message)
	"Wrapper to assert elisp runner, used to handle fatal failure to exit safely expects two strings"
	(cond
		;; Generic success
		((string-equal err "true")
			(cond
				((> (length message) 0)
					(message "SUCCESS: %s" message))
				((string-empty-p message)
					(message "SUCCESS: %s" "FIXME-NAME exitted successfully"))
				(t
					(message "BUG: %s" "Function 'die' triggered unexpected logic for true state")
					(kill-emacs 250))
			)
			(cond
				((string-equal system-type "gnu/linux")
					(kill-emacs 0))
				((string-equal system-type "windows-nt")
					(kill-emacs 1))
				(t
					(message "BUG: %s" "Function 'die' triggered unexpected logic for true state's exit")
					(kill-emacs 250))
			)
		)
		;; Generic failure
		((string-equal err "false")
			(cond
				((> (length message) 0)
					(message "FATAL: %s" message))
				((string-empty-p message)
					(setq project-name "reymacs")
					;; Replace FIXME-NAME with value of project-name variable without changing formatting string
					(message "FATAL: %s" (format "%s exitted successfully" project-name))
				(t
					(message "BUG: %s" "Function 'die' triggered unexpected logic for true state")
					(kill-emacs 250))
			)
			(cond
				((string-equal system-type "gnu/linux")
					(kill-emacs 0))
				((string-equal system-type "windows-nt")
					(kill-emacs 1))
				(t
					(message "BUG: %s" "Function 'die' triggered unexpected logic for true state's exit")
					(kill-emacs 250))
			)
		)
	)
)

(die "true")
