;;;; -*- Mode: Lisp -*-

;;;; Manan Mohammad Ali  817205
;;;; Stranieri Francesco 816551



;;;;----------------------------------------------------------------------------
;;;; json-parse

(defun json-parse (JSONString)
  (let ((JSONList (skip-whitespaces (coerce JSONString 'list))))
    (or (is-object JSONList)
        (is-array JSONList)
        (error "ERROR: syntax error"))))

;;;;----------------------------------------------------------------------------



;;;;----------------------------------------------------------------------------
;;;; is-object

(defun is-object (object)
  (if (eql (car object) #\{)
      (if (eql (second object) #\})
          (values (list 'json-obj) (cdr (cdr object)))
        (multiple-value-bind (result more_object) 
            (is-member (cdr object))
          (if (eql (car more_object) #\})
              (values (cons 'json-obj result) (cdr more_object))
            (error "ERROR: syntax error"))))
    (values nil object)))

;;;;----------------------------------------------------------------------------



;;;;----------------------------------------------------------------------------
;;;; is-member

(defun is-member (member)
  (multiple-value-bind (result more_member) 
      (is-pair member)
    (if (null result)
        (error "ERROR: syntax error")
      (if (eql (car more_member) #\,)
          (multiple-value-bind (result_more_member rest_more_member) 
              (is-member (cdr more_member))
            (if (null result_more_member)
                (error "ERROR: syntax error")
              (values (cons result result_more_member) rest_more_member)))
        (values (cons result nil) more_member)))))
            
;;;;----------------------------------------------------------------------------



;;;;----------------------------------------------------------------------------
;;;; is-pair

(defun is-pair (pair)
  (multiple-value-bind (result more_pair) 
      (is-string pair)
    (if (or (null result)
            (null more_pair))
        (error "ERROR: syntax error")
      (if (eql (car more_pair) #\:)
          (multiple-value-bind (result_more_pair rest_more_pair) 
              (is-value (cdr more_pair))
            (if (null result_more_pair)
                (error "ERROR: syntax error")
              (values (list result result_more_pair) rest_more_pair)))
        (error "ERROR: syntax error")))))
          
;;;;----------------------------------------------------------------------------



;;;;----------------------------------------------------------------------------
;;;; is-array

(defun is-array (array)
  (if (eql (car array) #\[)
      (if (eql (second array) #\])
          (values (list 'json-array) (cdr (cdr array)))
        (multiple-value-bind (result more_array) 
            (is-element (cdr array))
          (if (eql (car more_array) #\])
              (values (cons 'json-array result) (cdr more_array))
            (error "ERROR: syntax error"))))
    (values nil array)))

;;;;----------------------------------------------------------------------------



;;;;----------------------------------------------------------------------------
;;;; is-element

(defun is-element (element)
  (multiple-value-bind (result more_element) 
      (is-value element)
    (if (null result)
        (error "ERROR: syntax error")
      (if (eql (car more_element) #\,)
          (multiple-value-bind (result_more_element rest_more_element) 
              (is-element (cdr more_element))
            (if (null result_more_element)
                (error "ERROR: syntax error")
              (values (cons result result_more_element) rest_more_element)))
        (values (cons result nil) more_element)))))
            
;;;;----------------------------------------------------------------------------



;;;;----------------------------------------------------------------------------
;;;; is-value

(defun is-value (value)
  (cond ((eql (car value) #\{) 
         (is-object value))
        ((eql (car value) #\[) 
         (is-array value))
        ((or (eql (car value) #\") 
             (eql (car value) #\')) 
         (is-string value))
        ((or (eql (car value) #\+) 
             (eql (car value) #\-) 
             (digit-char-p (car value))) (is-number value))
        (T (error "ERROR: syntax error"))))
         
;;;;----------------------------------------------------------------------------



;;;;----------------------------------------------------------------------------
;;;; is-number

(defun is-number (number)
  (cond ((or (eql (car number) #\-) 
             (eql (car number) #\+)
             (digit-char-p (car number)))
         (multiple-value-bind (result more_number) 
             (is-integer (cdr number))
           (values (car (multiple-value-list 
                         (read-from-string 
                          (coerce 
                           (cons (car number) result) 'string)))) more_number)))
        (T (error "ERROR: syntax error"))))

;;;;----------------------------------------------------------------------------



;;;;----------------------------------------------------------------------------
;;;; is-integer

(defun is-integer (integer)
  (if (null (car integer)) nil
    (cond ((and (eql (car integer) #\.)
                (digit-char-p (second integer)))
           (multiple-value-bind (result more_integer) 
               (is-float (cdr integer))
             (values (cons (car integer) result) more_integer)))
          ((digit-char-p (car integer))
           (multiple-value-bind (result more_integer) 
               (is-integer (cdr integer))
             (values (cons (car integer) result) more_integer)))
          (T (values nil integer)))))  
                                                                            
;;;;----------------------------------------------------------------------------



;;;;----------------------------------------------------------------------------
;;;; is-float

(defun is-float (float)
  (if (null (car float)) nil
    (if (digit-char-p (car float))
        (multiple-value-bind (result more_float) 
            (is-float (cdr float))
          (values (cons (car float) result) more_float))
      (values nil float))))
     
;;;;----------------------------------------------------------------------------



;;;;----------------------------------------------------------------------------
;;;; is-string

(defun is-string (string)
  (cond ((eql (car string) #\")
         (multiple-value-bind (result more_string_DQ) 
             (is-any-chars-DQ (cdr string) (car string))
           (values (coerce result 'string) more_string_DQ)))
        ((eql (car string) #\')
         (multiple-value-bind (result more_string_SQ) 
             (is-any-chars-SQ (cdr string) (car string))
           (values (coerce result 'string) more_string_SQ)))
        (T (error "ERROR: syntax error"))))
 
;;;;----------------------------------------------------------------------------



;;;;----------------------------------------------------------------------------
;;;; is-any-chars-DQ

(defun is-any-chars-DQ (chars end)
  (if (eql (car chars) end) (values nil (cdr chars))
    (if (and (<= (char-int (car chars)) 128) 
             (<= (char-int (car chars)) 128))
        (multiple-value-bind (result more_chars) 
            (is-any-chars-DQ (cdr chars) end)
          (values (cons (car chars) result) more_chars))
      (error "ERROR: syntax error"))))

;;;;----------------------------------------------------------------------------



;;;;----------------------------------------------------------------------------
;;;; is-any-chars-SQ

(defun is-any-chars-SQ (chars end)
  (if (eql (car chars) end) (values nil (cdr chars))
    (if (and (<= (char-int (car chars)) 128) 
             (<= (char-int (car chars)) 128))
        (multiple-value-bind (result more_chars) 
            (is-any-chars-SQ (cdr chars) end)
          (values (cons (car chars) result) more_chars))
      (error "ERROR: syntax error"))))

;;;;----------------------------------------------------------------------------



;;;;----------------------------------------------------------------------------
;;;; json-load

(defun json-load (filename)
  (with-open-file (in filename
                      :direction :input
                      :if-does-not-exist :error)
    (json-parse (coerce (read-line in) 'string))))

;;;;----------------------------------------------------------------------------



;;;;----------------------------------------------------------------------------
;;;; json-write

(defun json-write (json filename)
  (if (or (null json)
          (null filename))
      (error "ERROR: json-write")
    (with-open-file (out filename
                         :direction :output
                         :if-exists :supersede
                         :if-does-not-exist :create)
      (format out "~A" (coerce (flatten (or (write-object json)
                                            (write-array json))) 'string))))
  filename)

(defun write-object (json)
  (if (eq (car json) 'json-obj)
      (if (null (cdr json)) 
          (list #\{ #\})
        (list #\{ (write-pair (cdr json)) #\}))
    nil))

(defun write-array (json)
  (if (eq (car json) 'json-array)
      (if (null (cdr json)) 
          (list #\[ #\])
        (list #\[ (write-element (cdr json)) #\]))
    nil))

(defun write-pair (json)
  (if (null (cdr json))
      (list (write-value (car (car json)))
            #\:
            (write-value (car (cdr (car json)))))
    (list (write-value (car (car json)))
          #\:
          (write-value (car (cdr (car json))))
          #\,
          (write-pair (cdr json)))))

(defun write-element (json)
  (if (null (cdr json))
      (list (write-value (car json)))
    (list (write-value (car json))
          #\,
          (write-element (cdr json)))))

(defun write-value (json)
  (cond ((null json)
         nil)
        ((numberp json)
         (coerce (write-to-string json) 'list))
        ((stringp json)
         (list #\" (coerce json 'list) #\"))
        ((eq (car json) 'json-obj)
         (write-object json))
        ((eq (car json) 'json-array)
         (write-array json))))

(defun flatten (x)
  (cond ((null x)
         x)
        ((atom x)
         (list x))
        (T (append (flatten (first x))
                   (flatten (rest x))))))
        
;;;;----------------------------------------------------------------------------



;;;;----------------------------------------------------------------------------
;;;; json-get

(defun json-get (json &rest fields)
  (if (null json)
      (error "ERROR: syntax error")
    (if (null fields)
        json
      (let ((head (car json)))
        (cond ((eq head 'json-obj)
               (let ((field (assoc (car fields)
                                   (cdr json)
                                   :test 'equalp)))
                 (json-get-a (second field) fields)))
              ((eq head 'json-array)
               (if (numberp (car fields))
                   (let ((field (nth (car fields)
                                     (cdr json))))
                     (json-get-a field fields))
                 (error "ERROR: syntax error")))
              (T (error "ERROR: syntax error")))))))

(defun json-get-a (field fields)
  (if (null field)
      (error "ERROR: syntax error")
    (apply 'json-get field (cdr fields))))
              
;;;;----------------------------------------------------------------------------



;;;;----------------------------------------------------------------------------
;;;; skip-whitespaces

(defun skip-whitespaces (list)
  (let ((head (car list)))
    (cond ((or (eql head #\Space)
               (eql head #\Tab)
               (eql head #\NewLine))
           (skip-whitespaces (cdr list)))
          ((or (eql head #\") 
               (eql head #\')) 
           (cons head (skip-not-whitespaces (cdr list) head)))
          ((null head) nil)
          (T (cons head (skip-whitespaces (cdr list)))))))

(defun skip-not-whitespaces (list end)
  (let ((head (car list)))
    (cond ((null head) nil)
          ((eql head end) (cons head (skip-whitespaces (cdr list))))
          (T (cons head (skip-not-whitespaces (cdr list) end))))))

;;;;----------------------------------------------------------------------------



;;;; end of file -- json-parsing.lisp --