#!/usr/bin/env hy

(import
  [os]
  [sys]
  [hy.lex]
  [hy.models.expression [HyExpression]]
  [hy.models.string [HyString]]
  [hy.models.integer [HyInteger]]
  [hy.models.float [HyFloat]]
  [hy.models.list [HyList]]
  [hy.models.dict [HyDict]])

(def phplib (.join "\n"
              (-> (os.path.join (os.path.abspath (os.path.dirname __file__)) "phplisp-lib.php")
                (file)
                (.read)
                (.strip "\n")
                (.split "\n")
                (slice 1 -1))))

;*** helper functions ***;

(defn force-str [f]
  (let [[translated (translate f)]]
    (if (in (type f) [HyList HyDict HyExpression])
      (+ "phplisp_repr(" translated ")")
      (str translated))))

;*** list of builtins ***;
(defn builtin-if [form]
  (assert (or (= (len form) 3) (= (len form) 4)) "if: wrong number of arguments.")
  (+ (+ "if (" (translate (get form 1)) ") {" (translate (get form 2)) "}")
    (if (= (len form) 4)
      (+ " else {" (translate (get form 3)) "}")
      "")))

(defn builtin-infix [form]
  (+ "(" (.join (+ " " (get form 0) " ") (map translate (rest form))) ")"))

(defn builtin-equality [form]
  (assert (= (len form) 3) "=: wrong number of arguments.")
  (+ "(" (.join (+ " " (get {"=" "==" "!=" "!="} (get form 0)) " ") (map translate (rest form))) ")"))

(defn builtin-str [form]
  (+ "(" (.join " . " (map force-str (rest form))) ")"))

(defn builtin-print [form]
  (+ "echo(" (builtin-str form) " . \"\\n\")"))

(def builtins
  {"if" builtin-if
   "str" builtin-str
   "print" builtin-print
   "+" builtin-infix
   "-" builtin-infix
   "*" builtin-infix
   "=" builtin-equality
   "!=" builtin-equality})

;*** functions to perform translation from tokens to PHP code ***;

(defn translate-expression [form]
  (if (in (first form) builtins)
    ((get builtins (first form)) form)
    (+ (first form) "(" (.join ", " (map translate (rest form))) ")")))

(defn translate-dict [form]
  (+ "Array(" (.join ", " (map (fn [[k v]] (+ (translate k) " => " (translate v))) (.items form))) ")"))

(defn translate [form]
  (cond
    [(= (type form) HyExpression) (translate-expression form)]
    [(= (type form) HyList) (+ "Array(" (.join ", " (map translate form)) ")")]
    [(= (type form) HyDict) (translate-dict form)]
    [(= (type form) HyString) (+ "\"" form "\"")]
    [true (str form)]))

(defn translate-program [raw-code library]
  (let [[output []]
        [forms (hy.lex.tokenize raw-code)]]
    (.append output "<?php")
    (.append output library)
    (for [form forms]
      (.append output (+ (translate form) ";")))
    (.append output "?>")
    (.join "\n" output)))

;*** invoke main ***;
(when (= __name__ "__main__")
  (import sys)
  (let [[source-file (get sys.argv -1)]]
    (print (translate-program (.read (file source-file)) phplib))))
