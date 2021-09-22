global _start

section .data

section .text

_start:
	mov		r8,		0			; number to process
	mov 	r9,		0			; maximum number of steps

forEachNumber:
	inc		r8
	cmp		r8,		100000000	; compare to max number to process
	ja		end

	mov		r10,	0			; number of steps
	mov		r11,	r8			; r11 contains the result of Collatz' computation	

whileResultNotOne:
	cmp		r11,	1
	je		endWhileResultNotOne

	inc		r10					; Increment number of steps

	test	r11b,	1
	jz		even
	; Result is odd

	mov		rax,	r11
	imul	rax,	3
	inc		rax
	mov		r11,	rax

	jmp		whileResultNotOne
even:
	shr		r11,	1
	jmp		whileResultNotOne

endWhileResultNotOne:
	cmp		r10,	r9
	jle		forEachNumber

	mov		r9,		r10
  	jmp		forEachNumber

end:
	mov		eax,	1			; sys_exit
	mov		ebx,	0			; exit code
	int		0x80				; call kernel
