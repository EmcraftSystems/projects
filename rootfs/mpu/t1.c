/*
 * A test application that makes a data access outside of the process space
 */
#include <stdio.h>
#include <unistd.h>
#include <time.h>

int main(int argc, char **argv)
{
	int a, *p = &a;

	printf("%s: Reading stack upwards\n", argv[0]);
	for (p = &a; ; p += 0x20)
		printf("*%08x=%08x\n", p, *p);

	return 0;
}
