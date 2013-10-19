YACC_FILE = project2.y
LEX_FILE = project2.l
RESULTANT = smartHome.exe
TEST_FILE = deneme.txt

all: compile

clear:
	clear
	
clean:
	rm -f lex.yy.c y.tab.c y.tab.h y.output $(RESULTANT)

prelex: $(YACC_FILE)
	bison -y -d $(YACC_FILE)

lex: prelex $(LEX_FILE)
	flex $(LEX_FILE)

yacc: lex $(YACC_FILE)
	bison -y -v $(YACC_FILE)

compile: prelex lex yacc
	gcc -o $(RESULTANT) lex.yy.c y.tab.c -lfl -lm

run:
	./$(RESULTANT) < $(TEST_FILE)
