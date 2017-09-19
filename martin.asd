(asdf:defsystem "martin"
    :description "A web studio by Ev. Valyaev and Val. Kiselev"
    :version "0.0.1"
    :author "V.K. <mrexox@yahoo.com>, E.V. <evgesha.valyaev@gmail.com>"
    :licence "BSD-like"
    :depends-on ("jsown" "hunchentoot" "cl-dbi" "ironclad" "cl-fad")
    :components ((:file "packages")
		 (:file "site" :depends-on ("packages"))))
    
