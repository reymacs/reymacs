;; DNM: Proposal for rm-defun, process prior to merge

(defmacro rm-defun (name args &rest body)
  (declare (indent defun))
  `(cl-macrolet ((die (code message &rest args)
                   (apply 'message (format "%s: %s" ',name message) args)
                   (kill-emacs code)))
     (defun ,name ,args ,@body)))

(rm-defun test ()
  (die 1 "Too ugly to live, too pretty to die"))
