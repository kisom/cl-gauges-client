(unless (packagep (find-package 'ql))
        (let ((quicklisp-init (merge-pathnames "quicklisp/setup.lisp"
                                               (user-homedir-pathname))))
          (when (probe-file quicklisp-init)
            (format t "loading quicklisp... ")
            (load quicklisp-init)
            (format t "done!~%")))
        (format t "quicklisp already loaded..."))

(ql:quickload :gauges)

(defparameter *api-key* nil)

(defun get-api-key ()
  (let ((api-key
         (if (probe-file #p"~/.gauges.key")
             (with-open-file (in #p"~/.gauges.key")
               (with-standard-io-syntax
                 (string (read in))))
             (if (sb-unix::posix-getenv "GAUGES_API_KEY")
                 (sb-unix::posix-getenv "GAUGES_API_KEY")
                 nil))))
    (unless api-key
      (format t "[!] cannot proceed without API key.~%")
      (sb-ext:quit :unix-status 1))
    (setf *api-key* api-key)))

(defun get-value (key lst)
  "Extract the value of key from an assoc-list lst"
  (cdr (assoc key lst)))

(defun today (site)
  (get-value :today site))

(defun yesterday (site)
  (get-value :yesterday site))

(defun month (site)
  (car (get-value :recent--months site)))

(defun all-time (site)
  (get-value :all--time site))

(defun views (time-period)
  (get-value :views time-period))

(defun people (time-period)
  (get-value :people time-period))


(defun display-site (site)
  (format t "~A~%~4Ttoday:~16Tviews: ~A~32Tpeople: ~A~%"
          (get-value :title site)
          (views (today site))
          (people (today site)))
  (format t "~4Tmonth:~16Tviews: ~A~32Tpeople: ~A~%"
          (views (month site))
          (people (month site)))
  (format t "~4Tall time:~16Tviews: ~A~32Tpeople: ~A~%"
          (views (all-time site))
          (people (all-time site))))

(defun main ()
  (get-api-key)
  (gauges:authenticate *api-key*)
  (let ((gauges-data (cdar (gauges:gauges))))
    (when (equal '(:MESSAGE . "Authentication required") gauges-data)
      (abort))
    (dolist (site gauges-data)
      (display-site site))))

(defun install (&optional (image-name "gauges-client"))
    (install-image image-name #'main))

(defun install-image (image-path toplevel)
  (if (stringp image-path)
      (progn
        (format t "[+] writing to ~A~%" (pathname image-path))
        (sb-ext:save-lisp-and-die (pathname image-path)
                                  :executable t
                                  :toplevel toplevel))
      (progn
        (format t "~%~%[!] invalid image name!~%")
        (sb-ext:quit :unix-status 1))))
