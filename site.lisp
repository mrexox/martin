(in-package :martin)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; VARS and PARAMETERS for the server and SQL        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Pathname of the directory in current project's root
(defun resource-path (path)
  "Returns a path where this ASDF-system is installed"
  (truename (asdf:system-relative-pathname :martin path)))

(defvar *acceptor* nil "Hunchentoot acceptor")

;; Might be any database
(defparameter *sqlite-database*
	(merge-pathnames #P"test_db.sqlite3" (resource-path ".")))

;; SQLite3 as default
(defparameter *database-name* *sqlite-database*)

(defparameter *admin-pass-hash-query*
	"SELECT password_hash FROM admin_user
   WHERE login=?")
(defparameter *all-messages-query*
	"SELECT * FROM message")
(defparameter *all-orders-query*
	"SELECT * FROM done_order")
(defparameter *create-order-query*
	"INSERT INTO done_order 
   (name, description, photo, response, site_href, valyay_comment, ian_comment)
   VALUES (?,?,?,?,?,?,?)")
(defparameter *delete-message-query*
	"DELETE FROM message
   WHERE id=?")
(defparameter *update-order-query*
	"UPDATE done_order
   SET name=?,
       description=?,
       photo=?,
       response=?,
       site_href=?,
       valyay_comment=?,
       ian_comment=?
   WHERE id=?")
(defparameter *get-order-photo-query*
	"SELECT photo FROM done_order WHERE id=?")
(defparameter *delete-order-query*
	"DELETE FROM done_order
   WHERE id=?")

(setf *tmp-directory* (resource-path "tmp"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Functions and all helpful staff (utils)           ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun log-string (message)
	(acceptor-log-message *acceptor* nil message))

(defmacro with-my-connection (conn-symbol &body body)
	`(with-connection (,conn-symbol :sqlite3 :database-name *database-name*)
		 ,@body))

(defmacro with-authorization-check (&body body)
	`(if (not (authorized))
			 (format nil "Fuck off!")
			 (progn ,@body)))

(append *dispatch-table*
				(list (create-folder-dispatcher-and-handler
							 "/" (resource-path "www"))))

(defun start-server (&optional (port 8080))
  (setf *acceptor*
				(make-instance 'easy-acceptor
											 :port port
											 :document-root (resource-path "www")))
  (start *acceptor*))

(defun stop-server ()
  (stop *acceptor*))

(defun hash (str)
	(if (cl:null str)
			""
			(byte-array-to-hex-string 
			 (digest-sequence :md5
												(ascii-string-to-byte-array str)))))

(defun random-hash ()
	"Random hash string as an autorization key"
	(let ((rand-arr (make-array '(10) :element-type '(unsigned-byte 8))))
		(loop for i from 0 to 9
			 do (setf (aref rand-arr i) (random 128)))
		(byte-array-to-hex-string
		 (digest-sequence :md5 rand-arr))))

(defun extract-password-hash (query-object)
	(let ((rows (fetch-all query-object)))
		(getf (first rows) :|password_hash|)))

(defun authorized ()
	(and *session* (string= (session-value :auth-key)
													(cookie-in "auth-key"))))

(defun order-to-json (row)
	(new-js ("id" (getf row :|id|))									  
					("name" (getf row :|name|))
					("description" (getf row :|description|))
					("photo"  (getf row :|photo|))
					("response" (getf row :|response|))
					("site_href" (getf row :|site_href|))
					("valyay_comment" (getf row :|valyay_comment|))
					("ian_comment" (getf row :|ian_comment|))))

(defun done-orders-json ()
	(with-my-connection conn 
		(let* ((query (prepare conn *all-orders-query*))
					 (result (execute query))
					 orders-list)
			(loop for row = (fetch result)
				 while row
				 do (push (order-to-json row) orders-list))
			(to-json (new-js ("done_orders" orders-list))))))

(defun message-to-json (row)
	(new-js ("id"  (getf row :|id|))
					("email"  (getf row :|email|))
					("name" (getf row :|name|))
					("telephone" (getf row :|telephone|))
					("type_of_order" (getf row :|type_of_order|))
					("company_name" (getf row :|company_name|))
					("comment" (getf row :|comment|))))


(defun messages-json ()
	(with-my-connection conn
		(let* ((query (prepare conn *all-messages-query*))
					 (result (execute query))
					 (messages-list (list)))
			(loop for row = (fetch result)
				 while row
				 do (push (message-to-json row) messages-list))
			(to-json (new-js ("messages" messages-list))))))

(defun delete-message (id)
	(with-my-connection conn
		(let* ((query (prepare conn *delete-message-query*)))
			(execute query id))))

(defun update-order (id &key name description photo site-href response ian-comment valyay-comment)
	(with-my-connection conn
		(let* ((query (prepare conn *update-order-query*))
					 (result (execute query name description photo response site-href valyay-comment ian-comment id)))
			(if result t nil))))

(defun delete-order (id)
	(with-my-connection conn
		(if (execute (prepare conn *delete-order-query*) id)
				"Success"
				"Error")))

(defun delete-order-image-if-nessesary (order-id photo)
	(with-my-connection conn
		(let* ((query (prepare conn *get-order-photo-query*))
					 (result (execute query order-id)))
			(loop for row = (fetch result)
				 while row
				 do (when (not (string-equal photo  (getf row :|photo|)))
							;; If we couldn't delete file - it is YOUR MISTAKE, IAN
							(ignore-errors (delete-file (merge-pathnames (string-left-trim "./" (getf row :|photo|))
																						(resource-path "www")))))))))

(defun create-order (&key name description photo site-href response ian-comment valyay-comment)
	(with-my-connection conn
		(let* ((query (prepare conn *create-order-query*))
					 (result (execute query name description photo response site-href valyay-comment ian-comment)))
			(if result "{}"
					(progn (setf (return-code*) +http-internal-server-error+)
								 "Error while executing INSERT query, creating the order")))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Easy handlers: macroses to handle requests        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(define-easy-handler (index :uri "/") ()
	"HOME page"
	(setf (content-type*) "text/html")
	(handle-static-file
	 (merge-pathnames "index.html" (resource-path "www"))))

;; For test_db.sqlite3 passwords are: "password"
(define-easy-handler (login :uri "/login") () 
	(cond ((and *session*									; session was started
							(string= (session-value :auth-key) (cookie-in "auth-key")))
				 (redirect "/console"))
				
				((eq (request-method*) :post)
				 (let ((redirect-address ""))
					 (with-my-connection conn 
						 (let* ((query (prepare conn *admin-pass-hash-query*))
										(json-obj (parse (raw-post-data :force-text t)))
										(login (val json-obj "login"))
										(password (val json-obj "password"))
										(password-hash (hash password))
										(result (execute query login)))
							 (if (string= password-hash (extract-password-hash result))
									 (progn
										 (start-session)
										 (regenerate-session-cookie-value *session*) 
										 (let ((rhash (random-hash)))
											 (setf (session-value :auth-key) rhash
														 (session-value :user-login) login)
											 (set-cookie "auth-key" :value rhash)) ; Cookie needed for authorization
										 (setf redirect-address "/console"))
									 (setf (return-code*) +http-authorization-required+)))) ; 401
					 (setf (content-type*) "application/json")
					 (format nil (to-json (new-js ("address" redirect-address))))))

				((eq (request-method*) :get)
				 (progn
					 (setf (content-type*) "text/html")
					 (handle-static-file
						(merge-pathnames "login.html" (resource-path "www")))))))

(define-easy-handler (console :uri "/console") ()
	(unless (authorized) (redirect "/login"))
 	(setf (content-type*) "text/html")
	(handle-static-file
	 (merge-pathnames "console.html" (resource-path "www"))))

(define-easy-handler (done-orders :uri "/console/done-orders") ()
	"Returns all orders in JSON"
	(with-authorization-check
		(setf (content-type*) "application/json")
		(format nil (done-orders-json))))

(define-easy-handler (messages :uri "/console/messages") ()
	"Returns all messages in JSON"
	(with-authorization-check
		(setf (content-type*) "application/json")
		(format nil (messages-json))))

(define-easy-handler (del-message :uri "/console/delete-message") (id)
	"Deletes the message with given ID. Only DELETE method allowed."
	(with-authorization-check
		(when (eql (request-method*) :delete)
			(delete-message id)
			nil)))

(define-easy-handler (manage-order :uri "/console/done-order") (order-id)
	"Updates information about post. Only POST method allowed."
	(with-authorization-check
		(cond ((eql (request-method*) :post)															 
					 (let* ((json-obj (parse (raw-post-data :force-text t))) ; Why can't I get PUT raw data???
									(name (val json-obj "name"))
									(description (val json-obj "description"))
									(response (val json-obj "response"))
									(site-href (val json-obj "site_href"))
									(photo (val json-obj "photo"))
									(ian-comment (val json-obj "ian_comment"))
									(valyay-comment (val json-obj "valyay_comment")))
						 (if (cl:null order-id)
								 (create-order :name name
															 :description description
															 :response response
															 :site-href site-href
															 :photo photo
															 :ian-comment ian-comment
															 :valyay-comment valyay-comment)
								 (progn									; UPDATE method
									 (delete-order-image-if-nessesary order-id photo)
									 (if (update-order order-id
															 :name name
															 :description description
															 :photo photo
															 :site-href site-href
															 :response response
															 :ian-comment ian-comment
															 :valyay-comment valyay-comment)
								 (setf (return-code*) +http-no-content+)
								 (setf (return-code*) +http-bad-request+))
						 nil))))
					((eql (request-method*) :delete)
					 (delete-order order-id)))))

(define-easy-handler (upload-file :uri "/console/upload-file") ()
	"Uplaods file and returns the path to it"
	(with-authorization-check
		(if (not (eql (request-method*) :post))
				(progn
					(setf (content-type*) "text/plain")
					(setf (return-code*) +http-bad-request+)
					"Only POST request supported")
				(progn
					(let ((file-form (post-parameter "photo")))
						;; Gets (/tmp/hunchentoot/hunchentoot-1 cat1.jpeg image/jpeg)
						(if (not (or (string-equal (third file-form) "image/jpeg")
												 (string-equal (third file-form) "image/jpg")
												 (string-equal (third file-form) "image/png")))
								(progn
									(setf (return-code*) +http-bad-request+) ; Yet
									"Только изображения JPEG и PNG поддерживаются")
								(progn
									;; Add sending new pathname and checking if everything was ok
									(let ((uploaded-file-name (format nil "~a-~a" (get-universal-time) (second file-form))))
										(copy-file (first file-form)
															 (merge-pathnames uploaded-file-name
																								(resource-path "www/data-img")))
										(format nil "~A" (merge-pathnames uploaded-file-name
																											"./data-img/"))))))))))
	
