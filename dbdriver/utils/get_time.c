#include <stdio.h>
#include <stdlib.h>

#include <sys/time.h>

main()
{
	struct timeval tp;
	
	gettimeofday(&tp, NULL);
	printf("%ld\n", tp.tv_sec);
}
