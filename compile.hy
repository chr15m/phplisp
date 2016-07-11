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

(let [[output []]
      [forms (hy.lex.tokenize (.read (file (get sys.argv -1))))]]
  (.append output "<?php")
  (for [form forms]
    (.append output (translate form)))
  (.append output "?>")
  (print (.join "\n" output)))
