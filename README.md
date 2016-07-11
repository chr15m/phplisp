## o no ##

Experimental lisp-to-PHP transpiler. Barely functional, **don't use**.

	$ cat test-basic.phl
	(print_r [1 2 3 4])
	$ ./compile.hy test-basic.phl
	<?php
	print_r(Array(1, 2, 3, 4))
	?>
	$ ./compile.hy test-basic.phl | php
	Array
	(
	    [0] => 1
	    [1] => 2
	    [2] => 3
	    [3] => 4
	)

