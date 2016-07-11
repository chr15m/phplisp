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

(def builtins
  {"if" builtin-if})

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
