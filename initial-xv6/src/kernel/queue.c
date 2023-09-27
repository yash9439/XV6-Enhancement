#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"

void popfront(deque *a)
{
    a->end -= 1;
    for (int i = 0; i < a->end; i++)
    {
        a->n[i] = a->n[i + 1];
    }
    return;
}
void pushback(deque *a, struct proc *x)
{
    if (a->end == NPROC)
    {
        panic("Panic Error");
        return;
    }
    a->n[a->end] = x;
    a->end += 1;
    return;
}
struct proc *front(deque *a)
{
    if (a->end == 0)
    {
        return 0;
    }
    return a->n[0];
}
int size(deque *a)
{
    return a->end;
}
void delete(deque *a, uint pid)
{
    int flag = 0;
    for (int i = 0; i < a->end; i++)
    {
        if (pid == a->n[i]->pid)
            flag = 1;

        if (flag == 1 && i != NPROC)
            a->n[i] = a->n[i + 1];
    }
    a->end -= 1;
    return;
}