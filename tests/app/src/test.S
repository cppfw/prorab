#include "test1.inc"

	.include	"test.inc"
	TEXT_SECTION
	.globl	asm_func
asm_func:
/*  Do not use any assembler instructions, because, for example, ARM architecture does not have 'ret' command,
    and this function is not called in this test anyway, this assembler file is only used to test that compilation is invoked by build system */
/*	ret */
	.END
