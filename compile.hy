#!/usr/bin/env hy

(import
  [sys]
  [hy.lex]
  [hy.models.expression [HyExpression]]
  [hy.models.string [HyString]]
  [hy.models.integer [HyInteger]]
  [hy.models.float [HyFloat]]
  [hy.models.list [HyList]])

(defn translate [form]
  (cond
    [(= (type form) HyExpression) (+ (first form) "(" (.join ", " (map translate (rest form))) ")")]
    [(= (type form) HyList) (+ "Array(" (.join ", " (map translate form)) ")")]
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
