tcc -1 -f- -S -Z -mt -O -y- intro.c
tasm intro.asm
tlink /t c0t.obj intro.obj

