;;; init.el -- Reymacs <https://github.com/reymacs/reymacs> initialization file
;; FIXME-COPYRIGHT
;; Relevants:
;; - Output functions: https://www.gnu.org/software/emacs/manual/html_node/elisp/Output-Functions.html
;; - Reference for cross-platform elisp http://ergoemacs.org/emacs/elisp_determine_OS_version.html
;; - Reference for assertion https://www.gnu.org/software/emacs/manual///html_node/elisp/Killing-Emacs.html
;; - Emacs scripting https://gist.github.com/lunaryorn/91a7734a8c1d93a8d1b0d3f85fe18b1e
;; Suggestions:
;; - Quotting: C-h a is just commands, if you want even more results try M-x apropos (tries variables etc. too)
;; - Quotting: exec-path is an emacs variable, sometimes useful if you want to augment the path with additions based on the (cond ...) structure i mentioned above
;; Styling: Block form until it gets unreadable then standard!
;; Notes:
;; - We are expecting the end-user to have `user.el` file to configure the runtime without editing distro's emacs directory
;; HOW-TO-USE:
;; This is an init.el file designed to be sourced by emacs that then defines the file hierarchy
;; Expecting to run command emacs -l "${REYMACS_DIR:-${XDG_CONFIG_HOME:-/home/.config/}/reymacs/}/init.el"

;; DNM: Used for testing
;;(setq user-init-file (or load-file-name (buffer-file-name)))
;;(setq user-emacs-directory (file-name-directory user-init-file))

;; Custom functions
;; DIE - Wrapper for assertion to exit with specified exit code and output a helpful error message
;; NOTICE(Krey): This functiou has to be appended since it's used at the runtime, do not use sourcing of files for this.
;;;& APPEND src/raymacs/functions/output.el

(setq project-name "reymacs")

;; Define file hierarchy
user-reymacs-directory

;; Do not continue untill reymacs knows which keybinds to use
;; FIXME: Define the supported keybinds dynamically from available logic files
(while (memq reymacs-keybinds '(emacs vim vscode))
	;; Source the configuration file if present
	(cond
		;; Capture all supported
		(string-equal reymacs-keybinds '(emacs vim vscode))
			FIXME LOGIC
		;; Ask for user-input to select keybinds
		(string-empty-p reymacs-keybinds)
			(cond
				(string-equal system-type "gnu/linux")
					FIXME LOGIC
			)
		;; Else trap
		(t)
			;; FIXME: Define die
			(die 1 "Variable 'reymacs-keybinds' is storing unsupported value 'FIXME-VALUE'")
	)
)

;; Determine the keybinds if not already set
(cond
 (string-equal system-type "gnu/linux")
  ;; FIXME-DEBUG: Message
  (cond
   (file-directory-p (getenv "REYMACS_DIR") )
    ;; Get the relevant file hierarchy
    ;; FIXME: Implement debug message
    ;; FIXME: Sanitize to ensure that init.el exists
    ;; FIXME-QA: Do not rely on getenv to return the same value
    (setq user-init-file (getenv "REYMACS_DIR")/init.el) )
    (setq user-emacs-directory (getenv "REYMACS_DIR") )
    ;; FIXME: Implement override using REYMACS_USER_CONFIG
    (setq user-config-file (getenv "REYMACS_DIR")/user.el) )

    ;; if variable XDG_CONFIG_HOME is not blank then
    ;;   for *.el files in $XDG_CONFIG_HOME/reymacs/keybinds
    ;;   if directory $XDG_CONFIG_HOME/reymacs/keybinds exists and has files '*.el' then add them in the logic
    ;;   if directory $HOME/.
    ;; else if variable
    (completing-read "Select your preferred keybinds" (directory-files "(getenv "REYMACS_DIR/keybinds)") )

   (t)
    ;; FIXME: Implement wrapper to handle this while outputting in a log
    (kill-emacs 36) ;; Unknown system detected, unimplemented
 )
)

;; FIXME: Source the variables from the Makefile
(message "Reymacs initiated")
