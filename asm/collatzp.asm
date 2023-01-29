bits	64
extern	printf

section .data
	pformat: db "Number: %lu, steps: %lu", 0xa, 0

section .text
global main
main:
	xor		r12,	r12			; number to process
	xor 	r13,	r13			; maximum number of steps

forEachNumber:
	inc		r12
	cmp		r12,	100000000	; compare to max number to process
	ja		end

	xor		r14,	r14			; number of steps
	mov		r15,	r12			; r15 contains the result of Collatz' computation	

whileResultNotOne:
	cmp		r15,	1
	je		endWhileResultNotOne

	inc		r14					; Increment number of steps

	test	r15b,	1
	jz		even
	; Result is odd

	mov		rax,	r15
	shl		rax,	1			; Multiply by 2
	add		rax,	r15			; add self to effectively multiply by 3
	inc		rax
	mov		r15,	rax

	; result will now always be even
	inc		r14
even:
	shr		r15,	1
	jmp		whileResultNotOne

endWhileResultNotOne:
	cmp		r14,	r13
	jle		forEachNumber

	mov		r13,	r14
	; Print the new high number of steps
	push	rbx					; Aligns the code on 16bytes

	mov		rdx,	r13
	mov		rsi,	r12
	mov		rdi,	pformat
	xor		rax,	rax			; no floating point arguments

    call	printf
	pop		rbx
  	jmp		forEachNumber

end:
	mov		eax,	1			; sys_exit
	xor		ebx,	ebx			; exit code 0
	int		0x80				; call kernel
