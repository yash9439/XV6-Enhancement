#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fcntl.h"

#define NFORK 10
#define IO 4

int main()
{
    int n, pid;
    int wtime, rtime;
    int twtime = 0, trtime = 0;
    for (n = 0; n < NFORK; n++)
    {
        for (int j = 0; j < 100000000; ++j)
        {
        };
        pid = fork();
        if (pid < 0)
        {
            printf("ERR %d\n", n);
            break;
        }
        if (pid == 0)
        {
            if (n < IO)
            {
                for (uint64 i = 0; i < 10; i++)
                {
                };
                sleep(200); // IO bound processes
            }
            else
            {
                for (uint64 i = 0; i < n * 1000000000; i++)
                {
                }; // CPU bound process
            }
            printf("Process %d finished\n", n);
            exit(0);
        };
    }
    for (; n > 0; n--)
    {
        if (waitx(0, &wtime, &rtime) >= 0)
        {
            trtime += rtime;
            twtime += wtime;
        }
    }
    printf("Average rtime %d,  wtime %d\n", trtime / NFORK, twtime / NFORK);
    exit(0);
}
