/*
 * A test application that try to execute non-supported (corrupted) instruction
 */
#include <stdio.h>
#include <unistd.h>
#include <time.h>

void func(void)
{
	printf("%s: called\n");
}

int main(int argc, char **argv)
{
	unsigned long *p;

	p = (void *)func;
	*p = 0xFFFFFFFF;

	printf("%s: Calling corrupted function\n", argv[0]);
	func();

	return 0;
}
