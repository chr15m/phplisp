#!/usr/bin/env hy

(import
  [sys]
  [hy.lex]
  [hy.models.expression [HyExpression]]
  [hy.models.string [HyString]]
  [hy.models.integer [HyInteger]]
  [hy.models.float [HyFloat]]
  [hy.models.list [HyList]])

;*** list of builtins ***;
(defn builtin-if [form]
  (cond
    [(= (len form) 3) (+ "if (" (translate (get form 1)) ") {" (translate (get form 2)) "}")]
    [(= (len form) 4) (+ "if (" (translate (get form 1)) ") {" (translate (get form 2)) "} else {" (translate (get form 3)) "}")]
    [true (raise (Exception "if: wrong number of arguments."))]))

(defn builtin-infix [form]
  (+ "(" (.join (+ " " (get form 0) " ") (map translate (rest form))) ")"))

(defn builtin-equality [form]
  (if (= (len form) 3)
    (+ "(" (.join (+ " " (get {"=" "==" "!=" "!="} (get form 0)) " ") (map translate (rest form))) ")")
    (raise (Exception "=: wrong number of arguments."))))

(defn force-str [f]
  (+ "print_r(" (translate f) ", true)"))

(defn builtin-str [form]
  (+ "(" (.join " . " (map force-str (rest form))) ")"))

(defn builtin-print [form]
  (+ "echo(" (builtin-str form) " . \"\\n\");"))

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
    (+ (first form) "(" (.join ", " (map translate (rest form))) ");")))

(defn translate [form]
  (cond
    [(= (type form) HyExpression) (translate-expression form)]
    [(= (type form) HyList) (+ "Array(" (.join ", " (map translate form)) ")")]
    [(= (type form) HyString) (+ "\"" form "\"")]
    [true (str form)]))

(defn translate-program [raw-code]
  (let [[output []]
        [forms (hy.lex.tokenize raw-code)]]
    (.append output "<?php")
    (for [form forms]
      (.append output (translate form)))
    (.append output "?>")
    (.join "\n" output)))

;*** invoke main ***;
(when (= __name__ "__main__")
  (import sys)
  (print (translate-program (.read (file (get sys.argv -1))))))
