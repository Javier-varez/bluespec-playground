.section .bss._stack

.align 4
.skip 256
_stack_end:

.section .text._start

.global cxx_start

.global _start
_start:
	lui sp, %hi(_stack_end)
	addi sp, sp, %lo(_stack_end)
	jal cxx_start

_loop:
	jal x0, _loop
