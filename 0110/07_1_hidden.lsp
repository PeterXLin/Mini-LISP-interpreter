(print-num
  ((fun (num) (- num 1)) 3))

(print-num
  ((fun (x y) (- x y)) 3 2))

(print-bool
  ((fun (x y) (and x y)) #t #f))

