all:
	yacc -d main.y 
	lex main.l 
	gcc lex.yy.c y.tab.c -o ex 
clean:
	rm -f ex
run:
	./ex test.txt
	