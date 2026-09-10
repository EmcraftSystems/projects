/*
 * A test application that overflows the user stack
 */
#include <stdio.h>
#include <unistd.h>
#include <time.h>

int main(int argc, char **argv)
{
	int a, *p = &a;

	printf("%s: Reading stack downwards\n", argv[0]);
	for (p = &a; ; p -= 0x20)
		printf("*%08x=%08x\n", p, *p);

	return 0;
}
