.syntax unified

/*TODO:
 * Implement the following function:
 *
 *    uint32_t increment(uint32_t x):
 *      return x+1
 */
.global increment
increment:
	ADD R0, #1
	BX LR


/*TODO:
 * Implement the following function:
 *
 *    uint8_t hw(uint32_t x):
 *      return hamming weight of x
 */
.global hw
hw:
	/* not constant time... :( */
	MOV R1, R0, LSR #31				// Initilize R1 with MSB(x)
	not_zero_r0:
		LSLS R0, #2					// Left shift of R0 by 2; Carry flag updated
	    ADC R1, R1, R0, LSR #31		// Add the highest bit of R0 and Carry => doing two bits at once
	    BNE not_zero_r0
	MOV R0, R1
	BX LR


/*TODO:
 * Implement the following function:
 *
 *    uint32_t factorial(uint8_t n);
 *      return n!
 *		0! = 1
 *		n! = n * (n-1)!
 *
 *      Write your function recursively.
 *      You need the stack to save temporary values.
 */
.global factorial
factorial:
	/* factorial(0) */
	CMP R0, #0
	ITT EQ
	MOVEQ R0, #1
	BXEQ LR

	/* factorial(n) */

	PUSH {R4, LR}

	MOV R4, R0 // store n for recursion

	// R0 := factorial(n-1)
	SUB R0, #1
	BL factorial

	// return n * (n-1)!
	MUL R0, R4
	POP {R4, PC}

/*TODO:
 * Implement the following function:
 *
 *    uint8_t sbox(uint8_t x):
 *      return the sbox value of x.
 *      remember to work with bytes here!
 *      use a lookup table for your implementation.
 *      place the table at the end of this file (there is a TODO too).
 */
.global sbox
sbox:
	PUSH {R4, LR}
	LDR R4, =sbox_table
	LDRB R0, [R4, R0]
	POP {R4, PC}


/*TODO:
 * Implement the following function:
 *
 *    void applySBoxToArray(uint8_t *array, uint8_t length):
 *      apply the sbox to every value in the array.
 *      use your sbox function from above to do so.
 */
.global applySBoxToArray
applySBoxToArray:

	// if empty array
	CMP R1, #0
	IT EQ
	BXEQ LR

	PUSH {R0, LR}
	MOV R2, R0

	for_each:
		LDRB R0, [R2]
		BL sbox				// sbox(RO[R2])
		STRB R0, [R2], #1	// move pointer
		SUBS R1, #1
		BNE for_each

	POP {R0, PC}


/*TODO:
 * write your sbox table bytes after this label.
 */
sbox_table:
	.byte 0x63, 0x7C, 0x77, 0x7B, 0xF2, 0x6B, 0x6F, 0xC5, 0x30, 0x01, 0x67, 0x2B, 0xFE, 0xD7, 0xAB, 0x76
	.byte 0xCA, 0x82, 0xC9, 0x7D, 0xFA, 0x59, 0x47, 0xF0, 0xAD, 0xD4, 0xA2, 0xAF, 0x9C, 0xA4, 0x72, 0xC0
	.byte 0xB7, 0xFD, 0x93, 0x26, 0x36, 0x3F, 0xF7, 0xCC, 0x34, 0xA5, 0xE5, 0xF1, 0x71, 0xD8, 0x31, 0x15
	.byte 0x04, 0xC7, 0x23, 0xC3, 0x18, 0x96, 0x05, 0x9A, 0x07, 0x12, 0x80, 0xE2, 0xEB, 0x27, 0xB2, 0x75
	.byte 0x09, 0x83, 0x2C, 0x1A, 0x1B, 0x6E, 0x5A, 0xA0, 0x52, 0x3B, 0xD6, 0xB3, 0x29, 0xE3, 0x2F, 0x84
	.byte 0x53, 0xD1, 0x00, 0xED, 0x20, 0xFC, 0xB1, 0x5B, 0x6A, 0xCB, 0xBE, 0x39, 0x4A, 0x4C, 0x58, 0xCF
	.byte 0xD0, 0xEF, 0xAA, 0xFB, 0x43, 0x4D, 0x33, 0x85, 0x45, 0xF9, 0x02, 0x7F, 0x50, 0x3C, 0x9F, 0xA8
	.byte 0x51, 0xA3, 0x40, 0x8F, 0x92, 0x9D, 0x38, 0xF5, 0xBC, 0xB6, 0xDA, 0x21, 0x10, 0xFF, 0xF3, 0xD2
	.byte 0xCD, 0x0C, 0x13, 0xEC, 0x5F, 0x97, 0x44, 0x17, 0xC4, 0xA7, 0x7E, 0x3D, 0x64, 0x5D, 0x19, 0x73
	.byte 0x60, 0x81, 0x4F, 0xDC, 0x22, 0x2A, 0x90, 0x88, 0x46, 0xEE, 0xB8, 0x14, 0xDE, 0x5E, 0x0B, 0xDB
	.byte 0xE0, 0x32, 0x3A, 0x0A, 0x49, 0x06, 0x24, 0x5C, 0xC2, 0xD3, 0xAC, 0x62, 0x91, 0x95, 0xE4, 0x79
	.byte 0xE7, 0xC8, 0x37, 0x6D, 0x8D, 0xD5, 0x4E, 0xA9, 0x6C, 0x56, 0xF4, 0xEA, 0x65, 0x7A, 0xAE, 0x08
	.byte 0xBA, 0x78, 0x25, 0x2E, 0x1C, 0xA6, 0xB4, 0xC6, 0xE8, 0xDD, 0x74, 0x1F, 0x4B, 0xBD, 0x8B, 0x8A
	.byte 0x70, 0x3E, 0xB5, 0x66, 0x48, 0x03, 0xF6, 0x0E, 0x61, 0x35, 0x57, 0xB9, 0x86, 0xC1, 0x1D, 0x9E
	.byte 0xE1, 0xF8, 0x98, 0x11, 0x69, 0xD9, 0x8E, 0x94, 0x9B, 0x1E, 0x87, 0xE9, 0xCE, 0x55, 0x28, 0xDF
	.byte 0x8C, 0xA1, 0x89, 0x0D, 0xBF, 0xE6, 0x42, 0x68, 0x41, 0x99, 0x2D, 0x0F, 0xB0, 0x54, 0xBB, 0x16
