NiteRide    
========
A 512b intro written in  C and compiled by the good old Turbo C compiler.
80's technology, hell yeah! Source included.

The effect is similar to Searchlight, but the shadows are rendered in screen
space rather than on the texture. I'm pretty sure this could be optimized
down to 256b if done by hand. I might give that a go eventually. The C seen
here was initially produced from my custom Oberon compiler and I'm currently
more interested in getting it to produce optimized assembly than writing
the asm by hand myself. Over the years I've learned to find what motivates me
to produce new things and making tools and languages is currently it. Stay
tuned for more stuff ;)

There is a c.bat file included that can be used to compile the intro. You
need the c0t.obj file, Turbo C, Tasm and Tlink.

Thanks to superogue for nudging me into making this!

Turbo C Tricks learned along the way
------------------------------------
One thing that allowed shaving a lot of bytes was to use block and declare
variables in those. Reusing a single set of global variables instead resulted
in running out of registers rather quickly.

Pointing directly into some memory address using a far pointer is fine at
this size.

Ternary expressions seem to be smaller than doing if+mutation.


