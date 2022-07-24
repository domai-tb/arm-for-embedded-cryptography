.syntax unified

/*
 * TODO:
 * Implement the following function:
 *  void PRESENT128_decrypt_asm(uint8_t state[8], uint8_t roundkeys[32][8]);
 *  - The roundkeys array can be seen as 32*8 consecutive bytes in memory and R1 points to the first word.
 *    This means that [R1] and [R1+4] are the first round key, [R1+8] and [R1+12] the second and so on.
 *  - The plaintext has to be written back to the state array in the end.
 *  - The following code already contains a suggestion for you. You can change it if you want.
 */
.global PRESENT128_decrypt_asm
PRESENT128_decrypt_asm:
    // bind aliases
    state         	 .req R0
    state_low		 .req R11
    state_high		 .req R12
    roundkeys     	 .req R1
    counter          .req R2
    offset			 .req R3

    PUSH {R4-R11, LR}

    LDR			state_low, [state]
	LDR			state_high, [state, #4]

    // revert last add round key
    MOV counter, #31
    LSL offset, counter, #3
    BL revert_add_round_key

    // revert all the rounds
    revert_present_rounds:

        SUB counter, #1
     	LSL offset, counter, #3

        BL revert_p_layer
        BL revert_sbox
        BL revert_add_round_key

		CMP counter, #0
        BNE revert_present_rounds

    // write state back into memory
    STR			state_low, [state]
	STR			state_high, [state, #4]

    // return from function
    POP {R4-R11, PC}

    // unbind aliases
    .unreq state
    .unreq roundkeys
    .unreq state_low
    .unreq state_high
    .unreq counter
    .unreq offset


revert_add_round_key:
    // bind aliases
    roundkeys     	 .req R1
    offset			 .req R3
    roundkey_low	 .req R4
    roundkey_high	 .req R5
    state_low		 .req R11
    state_high		 .req R12

    LDR		roundkey_low, [roundkeys, offset]		// key[0], ..., key[3]
    ADD		offset, #4
    LDR		roundkey_high, [roundkeys, offset]		// key[4], ..., key[7]

    EOR		state_low, roundkey_low		// state[0...3] ^ roundkey[0...3]
    EOR		state_high, roundkey_high	// state[4...7] ^ roundkey[4...7]

    BX LR

    // unbind aliases
    .unreq roundkey_low
    .unreq roundkeys
    .unreq roundkey_high
    .unreq state_low
    .unreq state_high
    .unreq offset


revert_p_layer:

    // bind aliases
    state_low		 .req R11
    state_high		 .req R12
    perm_low		 .req R10
    perm_high		 .req R9
    carry			 .req R4
    zero			 .req R5

	EOR			zero, zero
	EOR			perm_low, perm_low
	EOR			perm_high, perm_high

	// permutation for first 32 bit
	RORS		R6, state_low, #1			// C = state(0)
	ADC			carry, zero, zero
	ADD			perm_low, perm_low, carry, LSL #0		// 0 -> 0

	RORS		R6, state_low, #2			// C = state(1)
	ADC			carry, zero, zero
	ADD			perm_low, perm_low, carry, LSL #4	// 1 -> 4

	RORS		R6, state_low, #3			// C = state(2)
	ADC			carry, zero, zero
	ADD			perm_low, perm_low, carry, LSL #8	// 2 -> 8

	RORS		R6, state_low, #4			// C = state(3)
	ADC			carry, zero, zero
	ADD			perm_low, perm_low, carry, LSL #12	// 3 -> 12

	RORS		R6, state_low, #5			// C = state(4)
	ADC			carry, zero, zero
	ADD			perm_low, perm_low, carry, LSL #16		// 4 -> 16

	RORS		R6, state_low, #6			// C = state(5)
	ADC			carry, zero, zero
	ADD			perm_low, perm_low, carry, LSL #20	// 5 -> 20

	RORS		R6, state_low, #7			// C = state(6)
	ADC			carry, zero, zero
	ADD			perm_low, perm_low, carry, LSL #24	// 6 -> 24

	RORS		R6, state_low, #8			// C = state(7)
	ADC			carry, zero, zero
	ADD			perm_low, perm_low, carry, LSL #28	// 7 -> 28

	RORS		R6, state_low, #9			// C = state(8)
	ADC			carry, zero, zero
	ADD			perm_high, perm_high, carry, LSL #0		// 8 -> 32

	RORS		R6, state_low, #10			// C = state(9)
	ADC			carry, zero, zero
	ADD			perm_high, perm_high, carry, LSL #4	// 9 -> 36

	RORS		R6, state_low, #11			// C = state(10)
	ADC			carry, zero, zero
	ADD			perm_high, perm_high, carry, LSL #8	// 10 -> 40

	RORS		R6, state_low, #12			// C = state(11)
	ADC			carry, zero, zero
	ADD			perm_high, perm_high, carry, LSL #12	// 11 -> 44

	RORS		R6, state_low, #13			// C = state(12)
	ADC			carry, zero, zero
	ADD			perm_high, perm_high, carry, LSL #16		// 12 -> 48

	RORS		R6, state_low, #14			// C = state(13)
	ADC			carry, zero, zero
	ADD			perm_high, perm_high, carry, LSL #20	// 13 -> 52

	RORS		R6, state_low, #15			// C = state(14)
	ADC			carry, zero, zero
	ADD			perm_high, perm_high, carry, LSL #24	// 14 -> 56

	RORS		R6, state_low, #16			// C = state(15)
	ADC			carry, zero, zero
	ADD			perm_high, perm_high, carry, LSL #28	// 15 -> 60

	RORS		R6, state_low, #17			// C = state(16)
	ADC			carry, zero, zero
	ADD			perm_low, perm_low, carry, LSL #1		// 16 -> 1

	RORS		R6, state_low, #18			// C = state(17)
	ADC			carry, zero, zero
	ADD			perm_low, perm_low, carry, LSL #5	// 17 -> 5

	RORS		R6, state_low, #19			// C = state(18)
	ADC			carry, zero, zero
	ADD			perm_low, perm_low, carry, LSL #9	// 18 -> 9

	RORS		R6, state_low, #20			// C = state(19)
	ADC			carry, zero, zero
	ADD			perm_low, perm_low, carry, LSL #13	// 19 -> 13

	RORS		R6, state_low, #21			// C = state(20)
	ADC			carry, zero, zero
	ADD			perm_low, perm_low, carry, LSL #17		// 20 -> 17

	RORS		R6, state_low, #22			// C = state(21)
	ADC			carry, zero, zero
	ADD			perm_low, perm_low, carry, LSL #21	// 21 -> 21

	RORS		R6, state_low, #23			// C = state(22)
	ADC			carry, zero, zero
	ADD			perm_low, perm_low, carry, LSL #25	// 22 -> 25

	RORS		R6, state_low, #24			// C = state(23)
	ADC			carry, zero, zero
	ADD			perm_low, perm_low, carry, LSL #29	// 23 -> 29

	RORS		R6, state_low, #25			// C = state(24)
	ADC			carry, zero, zero
	ADD			perm_high, perm_high, carry, LSL #1		// 24 -> 33

	RORS		R6, state_low, #26			// C = state(25)
	ADC			carry, zero, zero
	ADD			perm_high, perm_high, carry, LSL #5	// 25 -> 37

	RORS		R6, state_low, #27			// C = state(26)
	ADC			carry, zero, zero
	ADD			perm_high, perm_high, carry, LSL #9	// 26 -> 41

	RORS		R6, state_low, #28			// C = state(27)
	ADC			carry, zero, zero
	ADD			perm_high, perm_high, carry, LSL #13	// 27 -> 45

	RORS		R6, state_low, #29			// C = state(28)
	ADC			carry, zero, zero
	ADD			perm_high, perm_high, carry, LSL #17		// 28 -> 49

	RORS		R6, state_low, #30			// C = state(29)
	ADC			carry, zero, zero
	ADD			perm_high, perm_high, carry, LSL #21	// 29 -> 53

	RORS		R6, state_low, #31			// C = state(30)
	ADC			carry, zero, zero
	ADD			perm_high, perm_high, carry, LSL #25	// 30 -> 57

	LSLS		R6, state_low, #1			// C = state(31)
	ADC			carry, zero, zero
	ADD			perm_high, perm_high, carry, LSL #29	// 31 -> 61

	// permutation for last 32 bit
	RORS		R6, state_high, #1			// C = state(32)
	ADC			carry, zero, zero
	ADD			perm_low, perm_low, carry, LSL #2		// 32 -> 2

	RORS		R6, state_high, #2			// C = state(33)
	ADC			carry, zero, zero
	ADD			perm_low, perm_low, carry, LSL #6	// 33 -> 6

	RORS		R6, state_high, #3			// C = state(34)
	ADC			carry, zero, zero
	ADD			perm_low, perm_low, carry, LSL #10	// 34 -> 10

	RORS		R6, state_high, #4			// C = state(35)
	ADC			carry, zero, zero
	ADD			perm_low, perm_low, carry, LSL #14	// 35 -> 14

	RORS		R6, state_high, #5			// C = state(36)
	ADC			carry, zero, zero
	ADD			perm_low, perm_low, carry, LSL #18		// 36 -> 18

	RORS		R6, state_high, #6			// C = state(37)
	ADC			carry, zero, zero
	ADD			perm_low, perm_low, carry, LSL #22	// 37 -> 22

	RORS		R6, state_high, #7			// C = state(38)
	ADC			carry, zero, zero
	ADD			perm_low, perm_low, carry, LSL #26	// 38 -> 26

	RORS		R6, state_high, #8			// C = state(39)
	ADC			carry, zero, zero
	ADD			perm_low, perm_low, carry, LSL #30 // 39 -> 30

	RORS		R6, state_high, #9			// C = state(40)
	ADC			carry, zero, zero
	ADD			perm_high, perm_high, carry, LSL #2	// 40 -> 34

	RORS		R6, state_high, #10			// C = state(41)
	ADC			carry, zero, zero
	ADD			perm_high, perm_high, carry, LSL #6	// 41 -> 38

	RORS		R6, state_high, #11			// C = state(42)
	ADC			carry, zero, zero
	ADD			perm_high, perm_high, carry, LSL #10	// 42 -> 42

	RORS		R6, state_high, #12			// C = state(43)
	ADC			carry, zero, zero
	ADD			perm_high, perm_high, carry, LSL #14	// 43 -> 46

	RORS		R6, state_high, #13			// C = state(44)
	ADC			carry, zero, zero
	ADD			perm_high, perm_high, carry, LSL #18	// 44 -> 50

	RORS		R6, state_high, #14			// C = state(45)
	ADC			carry, zero, zero
	ADD			perm_high, perm_high, carry, LSL #22	// 45 -> 54

	RORS		R6, state_high, #15			// C = state(46)
	ADC			carry, zero, zero
	ADD			perm_high, perm_high, carry, LSL #26	// 46 -> 58

	RORS		R6, state_high, #16			// C = state(47)
	ADC			carry, zero, zero
	ADD			perm_high, perm_high, carry, LSL #30	// 47 -> 62

	RORS		R6, state_high, #17			// C = state(48)
	ADC			carry, zero, zero
	ADD			perm_low, perm_low, carry, LSL #3	// 48 -> 3

	RORS		R6, state_high, #18			// C = state(49)
	ADC			carry, zero, zero
	ADD			perm_low, perm_low, carry, LSL #7	// 49 -> 7

	RORS		R6, state_high, #19			// C = state(50)
	ADC			carry, zero, zero
	ADD			perm_low, perm_low, carry, LSL #11	// 50 -> 11

	RORS		R6, state_high, #20			// C = state(51)
	ADC			carry, zero, zero
	ADD			perm_low, perm_low, carry, LSL #15	// 51 -> 15

	RORS		R6, state_high, #21			// C = state(52)
	ADC			carry, zero, zero
	ADD			perm_low, perm_low, carry, LSL #19	// 52 -> 19

	RORS		R6, state_high, #22			// C = state(53)
	ADC			carry, zero, zero
	ADD			perm_low, perm_low, carry, LSL #23	// 53 -> 23

	RORS		R6, state_high, #23			// C = state(54)
	ADC			carry, zero, zero
	ADD			perm_low, perm_low, carry, LSL #27	// 54 -> 27

	RORS		R6, state_high, #24			// C = state(55)
	ADC			carry, zero, zero
	ADD			perm_low, perm_low, carry, LSL #31	// 55 -> 31

	RORS		R6, state_high, #25			// C = state(56)
	ADC			carry, zero, zero
	ADD			perm_high, perm_high, carry, LSL #3	// 56 -> 35

	RORS		R6, state_high, #26			// C = state(57)
	ADC			carry, zero, zero
	ADD			perm_high, perm_high, carry, LSL #7	// 57 -> 39

	RORS		R6, state_high, #27			// C = state(58)
	ADC			carry, zero, zero
	ADD			perm_high, perm_high, carry, LSL #11	// 58 -> 43

	RORS		R6, state_high, #28			// C = state(59)
	ADC			carry, zero, zero
	ADD			perm_high, perm_high, carry, LSL #15	// 59 -> 47

	RORS		R6, state_high, #29			// C = state(60)
	ADC			carry, zero, zero
	ADD			perm_high, perm_high, carry, LSL #19	// 60 -> 51

	RORS		R6, state_high, #30			// C = state(61)
	ADC			carry, zero, zero
	ADD			perm_high, perm_high, carry, LSL #23	// 61 -> 55

	RORS		R6, state_high, #31			// C = state(62)
	ADC			carry, zero, zero
	ADD			perm_high, perm_high, carry, LSL #27	// 62 -> 59

	LSLS		R6, state_high, #1			// C = state(63)
	ADC			carry, zero, zero
	ADD			perm_high, perm_high, carry, LSL #31	// 63 -> 63

	MOV			state_high, perm_high
	MOV			state_low, perm_low

	BX LR

	// unbind aliases
    .unreq state_high
    .unreq state_low
    .unreq perm_high
    .unreq perm_low

revert_sbox:

	// bind aliases
    state         	 .req R0
    sbox			 .req R4
    state_low		 .req R11
    state_high		 .req R12

	LDR 		sbox, =present_inverse_sbox

	UBFX		R5, state_low, #0, #8
	UBFX		R6, state_low, #8, #8
	UBFX		R7, state_low, #16, #8
	UBFX		R8, state_low, #24, #8

	LDRB		R5, [sbox, R5]
	LDRB		R6, [sbox, R6]
	LDRB		R7, [sbox, R7]
	LDRB		R8, [sbox, R8]

	EOR			state_low, state_low

	ADD			state_low, state_low, R5
	ADD			state_low, state_low, R6, LSL #8
	ADD			state_low, state_low, R7, LSL #16
	ADD			state_low, state_low, R8, LSL #24

	UBFX		R5, state_high, #0, #8
	UBFX		R6, state_high, #8, #8
	UBFX		R7, state_high, #16, #8
	UBFX		R8, state_high, #24, #8

	LDRB		R5, [sbox, R5]
	LDRB		R6, [sbox, R6]
	LDRB		R7, [sbox, R7]
	LDRB		R8, [sbox, R8]

	EOR			state_high, state_high

	ADD			state_high, state_high, R5
	ADD			state_high, state_high, R6, LSL #8
	ADD			state_high, state_high, R7, LSL #16
	ADD			state_high, state_high, R8, LSL #24

	BX LR

	 // unbind aliases
    .unreq state
    .unreq sbox
    .unreq state_low
    .unreq state_high

.data
present_inverse_sbox:
		.byte 0x55, 0x5e, 0x5f, 0x58, 0x5c, 0x51, 0x52, 0x5d, 0x5b, 0x54, 0x56, 0x53, 0x50;
		.byte 0x57, 0x59, 0x5a, 0xe5, 0xee, 0xef, 0xe8, 0xec, 0xe1, 0xe2, 0xed, 0xeb;
		.byte 0xe4, 0xe6, 0xe3, 0xe0, 0xe7, 0xe9, 0xea, 0xf5, 0xfe, 0xff, 0xf8, 0xfc;
		.byte 0xf1, 0xf2, 0xfd, 0xfb, 0xf4, 0xf6, 0xf3, 0xf0, 0xf7, 0xf9, 0xfa, 0x85;
		.byte 0x8e, 0x8f, 0x88, 0x8c, 0x81, 0x82, 0x8d, 0x8b, 0x84, 0x86, 0x83, 0x80;
		.byte 0x87, 0x89, 0x8a, 0xc5, 0xce, 0xcf, 0xc8, 0xcc, 0xc1, 0xc2, 0xcd, 0xcb;
		.byte 0xc4, 0xc6, 0xc3, 0xc0, 0xc7, 0xc9, 0xca, 0x15, 0x1e, 0x1f, 0x18, 0x1c;
		.byte 0x11, 0x12, 0x1d, 0x1b, 0x14, 0x16, 0x13, 0x10, 0x17, 0x19, 0x1a, 0x25;
		.byte 0x2e, 0x2f, 0x28, 0x2c, 0x21, 0x22, 0x2d, 0x2b, 0x24, 0x26, 0x23, 0x20;
		.byte 0x27, 0x29, 0x2a, 0xd5, 0xde, 0xdf, 0xd8, 0xdc, 0xd1, 0xd2, 0xdd, 0xdb;
		.byte 0xd4, 0xd6, 0xd3, 0xd0, 0xd7, 0xd9, 0xda, 0xb5, 0xbe, 0xbf, 0xb8, 0xbc;
		.byte 0xb1, 0xb2, 0xbd, 0xbb, 0xb4, 0xb6, 0xb3, 0xb0, 0xb7, 0xb9, 0xba, 0x45;
		.byte 0x4e, 0x4f, 0x48, 0x4c, 0x41, 0x42, 0x4d, 0x4b, 0x44, 0x46, 0x43, 0x40;
		.byte 0x47, 0x49, 0x4a, 0x65, 0x6e, 0x6f, 0x68, 0x6c, 0x61, 0x62, 0x6d, 0x6b;
		.byte 0x64, 0x66, 0x63, 0x60, 0x67, 0x69, 0x6a, 0x35, 0x3e, 0x3f, 0x38, 0x3c;
		.byte 0x31, 0x32, 0x3d, 0x3b, 0x34, 0x36, 0x33, 0x30, 0x37, 0x39, 0x3a, 0x05;
		.byte 0x0e, 0x0f, 0x08, 0x0c, 0x01, 0x02, 0x0d, 0x0b, 0x04, 0x06, 0x03, 0x00;
		.byte 0x07, 0x09, 0x0a, 0x75, 0x7e, 0x7f, 0x78, 0x7c, 0x71, 0x72, 0x7d, 0x7b;
		.byte 0x74, 0x76, 0x73, 0x70, 0x77, 0x79, 0x7a, 0x95, 0x9e, 0x9f, 0x98, 0x9c;
		.byte 0x91, 0x92, 0x9d, 0x9b, 0x94, 0x96, 0x93, 0x90, 0x97, 0x99, 0x9a, 0xa5;
		.byte 0xae, 0xaf, 0xa8, 0xac, 0xa1, 0xa2, 0xad, 0xab, 0xa4, 0xa6, 0xa3, 0xa0;
		.byte 0xa7, 0xa9, 0xaa;
