.syntax unified

.global math
math:
PUSH {R4-R12}
    //TODO: Copy your solution for programming task 1.1 here
	LDR R1, =#0x7A801FA3
	ADD R1, R0
	ADD R0, R3
	SUB R2, R0, #3
	EOR R0, R2, R1
    //End of programming task 1.1
POP {R4-R12}
BX LR

.global sum_loop
sum_loop:
PUSH {R4-R12}
    //TODO: Copy your solution for programming task 1.2 here
	MOV R0, #0
	MOV R2, #1

	CBZ R1, loop_end
	loop:
		ADD R0, R2
		ADD R2, #1
		SUBS R1, #1
		BNE loop
	loop_end:
		// do something	
    //End of programming task 1.2
POP {R4-R12}
BX LR

.global sum_fast
sum_fast:
PUSH {R4-R12}
    //TODO: Copy your solution for programming task 1.3 here
	// 0 + 1 + ... + R1 = (R1^2 + R1) / 2
	MLA R1, R1, R1, R1		
	MOV R0, R1, LSR #1
    //End of programming task 1.3
POP {R4-R12}
BX LR

.global reverse_register
reverse_register:
PUSH {R4-R12}
    //TODO: Copy your solution for programming task 1.4 here
	MOV R1, #0

	CBZ R0, loop_end_zwei
	loop_zwei:
		LSRS R0, #1		// extract rightest bit, carry flag
		LSL R1, #1		// create space in R1
		ADCS R1, #0		// R1 := R1 + 0 + C
		BNE loop_zwei
	loop_end_zwei:
		MOV R0, R1
    //End of programming task 1.4
POP {R4-R12}
BX LR

.global reverse_byte
reverse_byte:
PUSH {R4-R12}
    //TODO: Copy your solution for programming task 1.5 here
	LSL R0, #3*8	// left shift 3 byte
	RBIT R0, R0
    //End of programming task 1.5
POP {R4-R12}
BX LR

.global cond_branch
cond_branch:
PUSH {R4-R12}
    //TODO: Copy your solution for programming task 1.6 here
	CMP R2, R1, LSR #5
	BLS else
	SUB R0, R2
	B endif
	else:
		LDR R0, =#0xDEADC0DE
	endif:
		// some code
    //End of programming task 1.6
POP {R4-R12}
BX LR

.global cond_instr
cond_instr:
PUSH {R4-R12}
    //TODO: Copy your solution for programming task 1.7 here
	CMP R2, R1, LSR #5
	ITE LS
	LDRLS R0, =#0xDEADC0DE
	SUBHI R0, R2
    //End of programming task 1.7
POP {R4-R12}
BX LR

.global swap
swap:
PUSH {R4-R12}
    //TODO: Copy your solution for programming task 1.8 here
	EOR R0, R1		// R0 := R0 XOR R1
	EOR R1, R0		// R1 := R0 XOR R1 XOR R1 = R0
	EOR R0, R1		// R0 := R0 XOR R1 XOR R0 = R1
    //End of programming task 1.8
POP {R4-R12}
BX LR

.global extract_byte
extract_byte:
PUSH {R4-R12}
    //TODO: Copy your solution for programming task 1.9 here
	UBFX R0, R1, #8, #8
    //End of programming task 1.9
POP {R4-R12}
BX LR

