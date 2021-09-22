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
            if (result & 1LU)
            {
                // multiplying by 3 and adding 1 a number is always even
                result = (result * 3L + 1L) >> 1;
                steps += 2;
            } else
            {
                ++steps;
                result >>= 1;
            }
        }
        if (steps > maxsteps)
        {
            maxsteps = steps;
            printf("Number: %lu, steps: %lu\n", i, maxsteps);
        }
        
    }
}