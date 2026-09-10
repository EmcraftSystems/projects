/*
 * A test application that makes an instruction access outside of the process
 * space
 */
#include <stdio.h>
#include <unistd.h>
#include <time.h>

int main(int argc, char **argv)
{
	void (*fp)(void);

	printf("%s: Calling function outside of the process space\n", argv[0]);

	fp = (void *)0x1000;
	fp();

	return 0;
}
