;; FIXME: Implement these as a part of the invidual functions with sanitization

;; Customization of the output
;;; die
;;;; Generic output
(setq die-format-string "FATAL: %s\n")
(setq die-format-string-log "FATAL: %s\n")
(setq die-format-string-debug "FATAL: %s\n")
(setq die-format-string-debug-log "FATAL: %s\n")
;;;; Success trap
(setq die-format-string-success "SUCCESS: %s\n")
(setq die-format-string-success-log "SUCCESS: %s\n")
(setq die-format-string-success-debug "SUCCESS: %s\n")
(setq die-format-string-success-debug-log "SUCCESS: %s\n")
;;;; Syntax error trap
(setq die-format-string-synerr "SYNERR: %s\n")
(setq die-format-string-synerr-log "SYNERR: %s\n")
(setq die-format-string-synerr-debug "SYNERR: %s\n")
(setq die-format-string-synerr-debug-log "SYNERR: %s\n")
;;;; Fixme trap
(setq die-format-string-fixme "FIXME: %s\n")
(setq die-format-string-fixme-log "FIXME: %s\n")
(setq die-format-string-fixme-debug "FIXME: %s\n")
(setq die-format-string-fixme-debug-log "FIXME: %s\n")
;;;; Bug trap
(setq die-format-string-bug "BUG: %s\n")
(setq die-format-string-bug-log "BUG: %s\n")
(setq die-format-string-bug-debug "BUG: %s\n")
(setq die-format-string-bug-debug-log "BUG: %s\n")
;;;; Unexpected trap
(setq die-format-string-unexpected "UNEXPECTED: %s\n")
(setq die-format-string-unexpected-log "UNEXPECTED: %s\n")
(setq die-format-string-unexpected-debug "UNEXPECTED: %s\n")
(setq die-format-string-unexpected-debug-log "UNEXPECTED: %s\n")
