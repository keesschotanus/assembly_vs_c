#include <stdio.h>

int main()
{
    unsigned long maxsteps = 0L;
    for (unsigned long i = 1; i <= 100000000; ++i)
    {
        unsigned long steps = 0L;
        unsigned long result = i;
        while (result != 1L)
        {
            ++steps;
            result = result % 2 ? result * 3L + 1L : result >> 1;
            // printf("Number: %lu, result: %lu\n", i, result);
        }
        if (steps > maxsteps)
        {
            maxsteps = steps;
            printf("Number: %lu, steps: %lu\n", i, maxsteps);
        }
        
    }
}