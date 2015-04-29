#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <signal.h>
#include <sys/types.h>

char **parseParams(char *paramsString, int *argc)
{
	int paramsCount = 0;
	int paramsStringLen = strlen(paramsString);
	char param[256];
	int param_index = 0;

	paramsString[paramsStringLen] = ' ';

	for(int i = 0; i <= paramsStringLen; i++)
	{
		if(paramsString[i] == ' ' && i != 0 && paramsString[i-1] != ' ')
			paramsCount++;
	}

	char **argv = new char*[paramsCount+1];
	argv[paramsCount] = NULL;
	*argc = paramsCount;

	int argv_index = 0;

	for(int i = 0; i <= paramsStringLen; i++)
	{
		if(paramsString[i] == ' ' && i != 0 && paramsString[i-1] != ' ')
		{
			param[param_index] = 0;
			argv[argv_index] = new char[strlen(param)+1];
			strcpy(argv[argv_index], param);
			argv_index++;
			param_index = 0;	
		}
		else
			param[param_index++] = paramsString[i];
	}

	//for(int i = 0; i < paramsCount; i++)
	//	printf("%s\n", argv[i]);

	return argv;
}

int main(void)
{
	const int bsize = 1024;
	int rfd, count, job_index;
	char buffer[bsize+1];
	char job[bsize+1];

	memset(buffer, 0, bsize+1);
	memset(job, 0, bsize+1);
	job_index = 0;

	rfd = open("job_queue", O_RDONLY);
	if(rfd < 0)
	{
		printf("File 'job_queue' could not be opened.\n");
		return -1;
	}

	while(1)
	{
		count = read(rfd, buffer, bsize);
		for(int i = 0; i < count; i++)
		{
			if(buffer[i] != 10)
			{
				job[job_index++] = buffer[i];
			}
			else
			{
				job[job_index] = 0;
				int pid = fork();
				int ofd, ifd, efd;
				if(pid == 0)
				{
					int argc;
					char **argv = parseParams(job, &argc);
					ifd = open(argv[argc-2], O_RDONLY);
					if(ifd < 0)
					{
						printf("Input file could not be opened.\n");
						return -1;
					}
					ofd = open(argv[argc-1], O_WRONLY|O_CREAT|O_TRUNC, 00666);
					if(ofd < 0)
					{
						printf("Output file could not be opened.\n");
						return -1;
					}
					/*efd = open(argv[argc-1], O_WRONLY|O_CREAT|O_TRUNC, 00666);
					if(efd < 0)
					{
						printf("Error file could not be opened.\n");
						return -1;
					}*/
					argv[argc-2] = NULL;

					printf("Executing ");
					int l = 0;
					while(argv[l] != NULL)
						printf("%s ", argv[l++]);
					printf("\n");
					fchown(ofd, 1000, -1);
					close(0);
					dup(ifd);
					close(1);
					dup(ofd);
					//close(2);
					//dup(efd);
					setuid(1000);
					execv(argv[0], argv);
				}
				else
				{
					sleep(1);
					int killed = kill(pid, SIGTERM);
					int stdin = open("/dev/stdin", O_RDWR);
					int stdout = open("/dev/stdout", O_RDWR);
					//int stderr = open("/dev/stderr", O_RDWR);
					close(ifd);
					dup(stdin);
					close(ofd);
					dup(stdout);
					//close(efd);
					//dup(stderr);
					printf("Job completed.\n\n");
					memset(job, 0, bsize+1);
					job_index = 0;
				}
			}
		}
	}

	return 0;
}