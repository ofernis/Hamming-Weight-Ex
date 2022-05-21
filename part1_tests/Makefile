.PHONY: all
all: tester.out tests

tester.out: ../students_code.S my_main.c
	gcc -g $^ -o $@

.PHONY: tests clean
tests:
	./tester.sh

clean:
	rm tester.out
