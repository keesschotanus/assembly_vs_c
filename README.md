# C versus Assembly

In the late seventies I did some assembly programming on a
<a href="https://oldcomputers.net/trs80i.html">TRS-80 Model I, Level II</a>
which had a <a href="https://en.wikipedia.org/wiki/Zilog_Z80">Z80</a>
CPU running at 1,78MHz.

After that I never tried assembly programming until now (Sep 2021).
This time using an Intel(R) Core(TM) i7-6700K CPU @ 4.00GHz running Linux.

## The challenge

Write some simple code, first in C and then translate the C code,
manually to X86_64 assembly code. Then measure the speed of both programs.
Don't do any non obvious optimization at first.

Since I'm quite new to this I selected a simple algorithm.
It is called <a href="https://en.wikipedia.org/wiki/Collatz_conjecture">Collatz Conjecture</a>.
Take any positive number n and apply the following algorithm
```
while (n <> 1)
    if n is odd
        n = n / 2
    else
        n = n * 3 + 1
```
Collatz promises me this code will never loop endlessly

** The C Code

Here is the algorithm implemented in C for the first 100000000 numbers.

```c
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
            // printf("%lu, %lu\n", i, maxsteps);
        }
        
    }
}
```

Here is a summary of the output the program produces:
```
       2,   1
       3,   7
       9,  19
      97, 118
     871, 178
    6171, 261
   77031, 350
  837799, 524
 8400511, 685
63728127, 949
```
As you can see, the number of steps rises gradually.

The most obvious optimazation would be to compile with -O1, -O2 or -O3.
Another obvious optimization may be to use result & 1 instead of result % 2.
Less obvious may be that:
```result * 3L + 1L``` might be replaced with ```result << 1 + result```.

Not sure if using the register keyword may improve performance.
But as promised, I did not do any optimization, except maybe for using a shift
for division by 2.

## The Assembly Code

Keep in mind that I did not write any assembly code in this millennium!

```assembly
global _start

section .data

section .text

_start:
	mov	r8,	0			; number to process
	mov 	r9,	0			; maximum number of steps

forEachNumber:
	inc	r8
	cmp	r8,	100000000		; compare to max number to process
	ja	end

	mov	r10,	0			; number of steps
	mov	r11,	r8			; r11 contains the result of Collatz' computation	

whileResultNotOne:
	cmp	r11,	1
	je	endWhileResultNotOne

	inc	r10				; Increment number of steps

	test	r11b,	1
	jz		even
	; Result is odd

	mov	rax,	r11
	imul	rax,	3
	inc	rax
	mov	r11,	rax

	jmp	whileResultNotOne
even:
	shr	r11,	1
	jmp	whileResultNotOne

endWhileResultNotOne:
	cmp	r10,	r9
	jle	forEachNumber

	mov	r9,	r10
  	jmp	forEachNumber

end:
	mov	eax,	1			; sys_exit
	mov	ebx,	0			; exit code
	int	0x80				; call kernel
````

Obviously I used a shift to divide by 2 as is common in assembly language.
The test for an even number is performed by looking at the least significant bit
using a test instruction but other than that no optimization has been applied.


### Comparing the results

The C program was compiled using: gcc (Ubuntu 9.3.0-17ubuntu1~20.04) 9.3.0,
with the command: ```gcc collatz.c -o collatz```
The assembly program using:
```
nasm -f elf64 collatz.asm -o collatz.o
ld -m elf_x86_64 collatz.o -o collatz
```

| Code         | Duration      |
|--------------|---------------|
| C            | 0m49,521s     |
| Assembly     | **0m23,994s** |

As you can see the assembly code is twice as fast!
Now let's compile the C code with aggressive optimazation (-O3).

| Code         | Duration      |
|--------------|---------------|
| C            | 0m49,521s     |
| C -O3        | **0m23,164s** |
| Assembly     | 0m23,994s     |

The C code is slightly faster now than the assembly code.

## Conclusion

- C compilers are pretty amazing
- My assembly skills are bad

- I need to optimize the assembly code
    - By looking at the assembly code the compiler generates
        - Using <a href="https://godbolt.org/">Compiler Explorer</a> for example
    - Using some standard techniques like using xor to set a value to 0.

Note: Using the -O3 option with gcc 11 results in the following assembly code:
```bits	64
extern	printf

section .data
	pformat: db "Number: %lu, steps: %lu", 0xa, 0

section .text
global main
main:

main:
        xor     eax, eax
        ret
```
The compiler sees that the results are never used so it never generates code for it.
To prevent this problem, make sure the second printf statement is not commented out!

## Optimizing the Assembly code
A good place to start is to see what assembly code the compiler produces.
I included the second printf statement and used x86-64 gcc 11.2 with the -O3 option.
Here is the output on 
<a href="https://godbolt.org/#z:OYLghAFBqd5QCxAYwPYBMCmBRdBLAF1QCcAaPECAMzwBtMA7AQwFtMQByARg9KtQYEAysib0QXACx8BBAKoBnTAAUAHpwAMvAFYTStJg1DIApACYAQuYukl9ZATwDKjdAGFUtAK4sGIMwCspK4AMngMmAByPgBGmMQSAJykAA6oCoRODB7evv5BaRmOAmER0SxxCVzJdpgOWUIETMQEOT5%2BgbaY9sUMjc0EpVGx8Um2TS1teZ0KE4PhwxWj1QCUtqhexMjsHOYAzOHI3lgA1CZ7brP4qAB0COfYJhoAgk/P4QQnLEzhECtvJgA7FYXicwScvAwMsAIugTrQBMAvkxVLNMCkFGc9gARE4aELnEHPcEnfjEE4QSHQ2HwxEnPBY3FcQn0rFuc5MjRc7lclnWax4f6g8FAokkklUvAwzBwhFGE5ojGMvEEvZi8VgyXS2V04iYBReWifDn0wlvDVggDuCDomApeoNRpOYDAJq4ISFxItovNFpJ/MsioUZuFfrBDsNxpxJwjTvMAROZixADEY/rIycAFQnPYhM6WE7uk4gNOOqOPPbYQshr1hk4AenrJxSxA%2BVAg5jM5UqJfj3lIpcjvcC3hMATcDE7A7wA9jBH%2Bat9GqB2KX4rwVApQaxVe%2BqII6IUnr9PtDYb325NQZrdbBLbbHbMZj7XgHL7HE6n9IHF4PGIX6rLoCq5nv6Z4rgCwEcGstCcAEvB%2BBwWikKgnDspY1gKhsWx2vsPCkAQmjQWsADWIABBo%2BicJICFEShnC8AoICUYRSHQaQcCwEgaAsCktpkBQEA8Xx9AJMAXBcGYfB0AexBMRAMR0TE4TNAAnpw%2BE8WwggAPIMLQ6lsaQWDfEY4hGfger1AAbvqdGYKodReAeGm8B83R0bQeAxMQakeFgdEEK2LCuWsVAGMACgAGp4Jglo6SkjCuTIggiGI7BSCl8hKGodG6Fw%2BiGMYAY2F5MRMZAayoCkvRMRwAC0Ol7Ix3R1L0LgMO4njtP4lGhAs3ajJIABsqTpJkAhTB0lGFBNDBDINCQjV0PQNHMU16LU9QCP0LQLSMVTjAMG0FbMAz7UsVRrAo2HbHoQWYDsPAwXBtFGahHCqAAHMN9XDZIJzAMgyCFlwNxJhA6FWJYA64IQJD5nsBUnB4vH8YjXArLwrFaCspHkZRsEcDRpCIchH2McxBFEXjVEcGYb3kwx1NsbTtlyVkICSEAA%3D">Assembly code on godbolt</a>

As you can see the compiler knows that a ```xor edx, edx``` sets edx to zero,
but faster than ```mov edx, 0``` would do.
It even knows not to multiply by 3 and adding 1, by executing: ```lea rax, [rax+1+rax*2]```

Quite impressive!
It makes me want to give up on assembly and stick to C!

# Assembly part II

To resolve some of the performance issue and to be able to print the result,
I made a new file named collatzp.asm.
See below.

```assembly
bits	64                  	; explicitly use 64 bits
extern	printf              	; so I can use printf

section .data
	pformat: db "Number: %lu, steps: %lu", 0xa, 0

section .text
global main                 	; C programs expect main
main:                       	; Now uses registers that are preserved by function calls
	xor	r12,r12		; number to process
	xor 	r13,r13		; maximum number of steps

forEachNumber:
	inc	r12
	cmp	r12,100000000	; compare to max number to process
	ja	end

	xor	r14,r14		; number of steps
	mov	r15,r12		; r15 contains the result of Collatz' computation	

whileResultNotOne:
	cmp	r15,1
	je	endWhileResultNotOne

	inc	r14		; Increment number of steps

	test	r15b,1
	jz	even
	; Result is odd

	mov	rax,r15
	shl	rax,1		; Multiply by 2
	add	rax,r15		; add self to effectively multiply by 3
	inc	rax
	mov	r15,rax

	; result will now always be even
	inc	r14             ; Increment number of steps
even:
	shr	r15,1
	jmp	whileResultNotOne

endWhileResultNotOne:
	cmp	r14,r13
	jle	forEachNumber

	mov	r13,r14
	; Print the new high number of steps
	mov	rdx,r13
	mov	rsi,r12
	mov	rdi,pformat
	xor	rax,rax         ; no floating point arguments

    	call	printf
  	jmp	forEachNumber

end:
	mov	eax,1		; sys_exit
	xor	ebx,ebx		; exit code 0
	int	0x80		; call kernel

```

## Compiling the code

The following statements were used to compile and run
```
nasm -g -f elf64 collatzp.asm
gcc -no-pie collatzp.o -o collatz
./collatz
```

Since the C-library is used gcc is used to create the output file.
The program now takes: 0m21,410s to execute while the C program,
with the print takes 0m25,992s.
Not a completely fair comparison due to the fact that the assembly
code falls through from an odd number to an even number, skipping
the superfluous check.

# Conclusion

For a newbie at X86_64 assembly code, 
it looks like it is really hard to beat optimized C code!

## Optimizing the C code

Since the assembly code was optimized, for example by making use
of the fact that a number multiplied by 3 and adding 1, is always even,
the C code could be optimized as well.
See the collatz.c source for the final version.

The program run in: 0m20,703
making it faster again than the assembly version.
This again is proof that the compiler is way more knowledgeable on assembly
than I am.
