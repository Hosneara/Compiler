#!/bin/bash
flex first.l
bison first.y -d
gcc lex.yy.c first.tab.c -lfl -o first
./first
