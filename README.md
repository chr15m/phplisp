Experimental lisp-to-PHP transpiler. Barely functional, **don't use**.

	$ cat test-cases/test-basic.phl
	(print_r [1 2 3 4])
	$ ./phplisp test-cases/test-basic.phl
	<?php
	print_r(Array(1, 2, 3, 4))
	?>
	$ ./phplisp test-cases/test-basic.phl | php
	Array
	(
	    [0] => 1
	    [1] => 2
	    [2] => 3
	    [3] => 4
	)

![](http://vignette1.wikia.nocookie.net/clubpenguin/images/a/a5/Emoticon_meme_Mother_od_God.png/revision/latest?cb=20140128144512&path-prefix=es)

### Hacking ###

	virtualenv virtualenv
	. ./virtualenv/bin/activate
	pip install -r requirements.txt

Patches welcome!
