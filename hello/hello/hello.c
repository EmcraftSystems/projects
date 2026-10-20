#include <stdio.h>
#include <unistd.h>
#include <sys/mount.h>

int main(void)
{
	char buff[4096];
	FILE *fp;

	printf("Mounting /proc..\n");

	if (mount("proc", "/proc", "proc", 0, NULL)) {
		perror("Unable to mount /proc");
	} else if (!(fp = fopen("/proc/meminfo", "r"))) {
		perror("fopen");
	} else {
		printf("Reading /proc/meminfo:\n");
		while (fgets(buff, sizeof(buff), fp)) {
			fputs(buff, stdout);
		}
		fclose(fp);
		printf("Done\n");
	}

	while (1) {
		printf("Hello, " HELLO_MCU "-Linux!\n");
		sleep(3);
	}
}
