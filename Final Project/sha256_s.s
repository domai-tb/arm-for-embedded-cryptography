.syntax unified
.text

/*****************************************************************************/
/******************************* CODE ****************************************/
/*****************************************************************************/

.global sha256_core_s
sha256_core_s:

    PUSH    {R4-R11, LR}
    sub     SP, SP, #340			// reserve memory

        STR     R3, [SP, #4]		// store input variables
        ADD     R3, SP, #12
        stm     R3, {R0, R1, R2}
        ADD     R4, SP, #84

        ADD     R12, R4, #12
        ADD     R0, R4, #32
        STR     R0, [SP, #8]

        LDR     R0, H_INIT_7	   // load H_INIT value
        LDR     R11, H_INIT_6	   // load them now -> reduce cycles
        LDR     LR, H_INIT_5
        LDR     R8, H_INIT_4
        LDR     R1, H_INIT_3
        LDR     R9, H_INIT_2
        LDR     R4, H_INIT_1
        LDR     R5, H_INIT_0

        LDR     R6, PAD_10_ADRS		// load them now -> reduce cycles

        STR     R0, [SP, #72]		// write them to stack -> doesn't need
        STR     R1, [SP, #76]		// to load them again. But registers are needed.
        STR     R12, [SP, #24]

        MOV     R7, #0				// N_i = 0

	block_loop:
        CMP     R7, #0				// N_i == 0

        STR     R8, [SP, #48]		// store values to stack
        STR     R7, [SP, #44]		// -> memory is faster
        STR     R11, [SP, #68]
        ADD     R0, SP, #56
        stm     R0, {R4, R5, LR}

        BEQ     first_block			// N_i == 0 => use first_block

        LDR     R0, [SP, #20]		// load data_length
        CMP     R0, #10				// data_length == 10
        BEQ     data_10

        CMP     R0, #32				// data_length == 32
        MOV     R12, R5
        MOV     R7, R4
        MOV     R2, R4
        MOV     R10, R9
        LDR     R0, [SP, #76]
        MOV     R1, R0
        MOV     R6, R8
        MOV     R4, LR
        MOV     R3, R11
        MOV     R11, R5
        LDR     R12, [SP, #72]
        BNE     tmp_words

		// prepare loading of data
	    MOV     LR, R8
	    MOV     R12, R2
	    MOV     R0, #0

	    LDR     R4, [SP, #16]	// load data pointer
	    ADD     R6, SP, #84

		load_data_32:
	        MOV     R1, R4

	        // load four data bytes
	        LDRB    R2, [R1, R0]
	        ADD		R1, R1, R0
	        LDRB    R3, [R1, #1]
	        LDRB    R7, [R1, #2]
	        LDRB    R1, [R1, #3]

	        // combine bytes to a word
	        LSL     R3, R3, #16
	        ORR     R2, R3, R2, LSL #24
	        ORR     R2, R2, R7, LSL #8
	        ORR     R1, R2, R1
	        STR     R1, [R6, R0]

	        // load data until all 32 bytes are loaded
	        ADD     R0, R0, #4
	        CMP     R0, #32
	        BNE     load_data_32

		// prepare loading of padding
	    MOV     R0, #0
	    LDR     R8, [SP, #68]
	    LDR     R4, [SP, #8]
	    LDR     R6, PAD_32_ADRS

		load_padding_32:
	        MOV     R1, R6

	        // load four data bytes
	        LDRB    R2, [R1, R0]
	        ADD		R1, R1, R0
	        LDRB    R3, [R1, #1]
	        LDRB    R7, [R1, #2]
	        LDRB    R1, [R1, #3]

	        // combine to one word
	        LSL     R3, R3, #16
	        ORR     R2, R3, R2, LSL #24
	        ORR     R2, R2, R7, LSL #8
	        ORR     R1, R2, R1
	        STR     R1, [R4, R0]

	        // load data until all 32 bytes are loaded
	        ADD     R0, R0, #4
	        CMP     R0, #32
	        BNE     load_padding_32

		// prepare other 15 < t < 64 words
	    MOV     R11, R5
	    MOV     R7, R12
	    MOV     R10, R9
	    LDR     R0, [SP, #76]
	    MOV     R1, R0
	    MOV     R6, LR
	    LDR     R4, [SP, #64]
	    MOV     R3, R8
	    LDR     R12, [SP, #72]
	    B       tmp_words

		first_block:

	        LDR     R4, [SP, #12]		// R4 := *first_block
	        ADD     R6, SP, #84
	        MOV     R0, #0				// load four bytes at once

			first_block_loop:
		        MOV     R1, R4

		        // load four data bytes
		        LDRB    R2, [R1, R0]		// first byte
		        ADD		R1, R1, R0
		        LDRB    R3, [R1, #1]		// second byte
		        LDRB    R7, [R1, #2]		// third byte
		        LDRB    R1, [R1, #3]		// fourth byte

				// combine bytes to one word
		        LSL     R3, R3, #16
		        ORR     R2, R3, R2, LSL #24
		        ORR     R2, R2, R7, LSL #8
		        ORR     R1, R2, R1
		        STR     R1, [R6, R0]

				// load data until all 64 bytes are loaded
		        ADD     R0, R0, #4
		        CMP     R0, #64
		        BNE     first_block_loop

		// load init values -> reduce cycle cost
        LDR     R11, H_INIT_0
        LDR     R7, H_INIT_1
        LDR     R10, H_INIT_2
        LDR     R1, H_INIT_3
        LDR     R6, H_INIT_4
        LDR     R4, H_INIT_5
        LDR     R3, H_INIT_6
        LDR     R12, H_INIT_7

        LDR     R0, [SP, #76]
        B       tmp_words

		data_10:
			// mix padding an data
			// --> last two bytes data || first two bytes padding
	        LDR     R7, [SP, #16]
	        LDRB    R0, [R7, #9]
	        LDRB    R1, [R7, #8]
	        LSL     R1, R1, #24
	        ORR     R0, R1, R0, LSL #16
	        EOR     R0, R0, #0x8000			// carry
	        STR     R0, [SP, #92]

			// load AND combine first data word
	        LDRB    R0, [R7]
	        LDRB    R1, [R7, #1]
	        LDRB    R2, [R7, #2]
	        LDRB    R3, [R7, #3]
	        LSL     R1, R1, #16
	        ORR     R0, R1, R0, LSL #24
	        ORR     R0, R0, R2, LSL #8
	        ORR     R0, R0, R3
	        STR     R0, [SP, #84]

			// load AND combine second data word
	        LDRB    R0, [R7, #4]
	        LDRB    R1, [R7, #5]
	        LSL     R1, R1, #16
	        ORR     R0, R1, R0, LSL #24
	        LDRB    R1, [R7, #6]
	        ORR     R0, R0, R1, LSL #8
	        LDRB    R1, [R7, #7]
	        ORR     R0, R0, R1
	        STR     R0, [SP, #88]


	        MOV     R0, #0

			load_padding_10:
		        ADD     R1, R6, R0

		        // load four bytes
		        LDRB    R2, [R1, #2]
		        LDRB    R3, [R1, #3]
		        LDRB    R7, [R1, #4]
		        LDRB    R1, [R1, #5]

				// combine to word
		        LSL     R3, R3, #16
		        ORR     R2, R3, R2, LSL #24
		        ORR     R2, R2, R7, LSL #8
		        ORR     R1, R2, R1
		        STR     R1, [R12, R0]

				// continue until all 54 bytes are loaded
				// (just 52 bytes of padding remain in loop)
		        ADD     R0, R0, #4
		        CMP     R0, #52
		        BNE     load_padding_10

		// prepare other 15 < t < 64 words
        MOV     R12, R5
        MOV     R7, R4
        MOV     R10, R9
        LDR     R0, [SP, #76]
        MOV     R1, R0
        MOV     R6, R8
        MOV     R4, LR
        MOV     R3, R11
        MOV     R11, R5
        LDR     R12, [SP, #72]

		// W[16] ... W[63]
		tmp_words:

	        STR     R10, [SP, #28]
	        STR     R4, [SP, #32]
	        MOV     R10, R7
	        STR     R6, [SP, #36]
	        STR     R11, [SP, #40]
	        MOV     R8, R1
	        STR     R0, [SP, #76]
	        STR     R9, [SP, #52]
	        MOV     R0, #0
	        ADD     R4, SP, #84

			tmp_words_loop:
		        LDR     R1, [R4, R0]	// load W[ t-16 ]
		        ADD     R2, R4, R0
		        LDR     R5, [R2, #4]	// load W[ t-15 ]
		        LDR     R6, [R2, #36]	// load W[ t-7 ]
		        LDR     R7, [R2, #56]	// load W[ t-2 ]
		        ADD     R1, R1, R6

		        // SSIG1
		        ROR     R6, R7, #19
		        EOR     R6, R6, R7, LSR #10
		        EOR     R7, R6, R7, ROR #17
		        ADD     R1, R1, R7

		        // SSIG0
		        ROR     R7, R5, #18
		        EOR     R7, R7, R5, LSR #3
		        EOR     R7, R7, R5, ROR #7
		        ADD     R1, R1, R7

		        STR     R1, [R2, #64]

		        // continue until 192 bytes = 48 words are initialized
		        ADD     R0, R0, #4
		        CMP     R0, #192
		        BNE     tmp_words_loop

		// main loop preperations:
        MOV     R11, #0
        STR     R8, [SP, #80]
        LDR     R6, [SP, #40]
        LDR     R7, [SP, #36]
        MOV     LR, R10
        LDR     R2, [SP, #28]
        LDR     R1, [SP, #32]

		main_loop:
	        MOV     R10, R6
	        MOV     R4, LR
	        MOV     R9, R2
	        MOV     R5, R7
	        MOV     R8, R1
	        MOV     R0, R3

	        /* T2 */
	        // MAJ
	        AND     R3, R2, LR
	        EOR     R7, R2, LR
	        AND     R7, R7, R6
	        EOR     R3, R7, R3

	        // BSIG0
	        ROR     R7, R6, #2
	        EOR     R7, R7, R6, ROR #13
	        EOR     R7, R7, R6, ROR #22

	        ADD     R3, R3, R7

	        /* T1 */
	        // CH
	        AND     R7, R1, R5
	        BIC     R6, R0, R5		// R6 = R0 & ~R5
	        EOR     R7, R6, R7

	        // BSIG1
	        ROR     R6, R5, #6
	        EOR     R6, R6, R5, ROR #11
	        EOR     R6, R6, R5, ROR #25

	        ADD     R6, R6, R12
	        ADD     R7, R6, R7
	        LDR     R1, K_ADRS
	        LDR     R6, [R1, R11, LSL #2]
	        ADD     R7, R7, R6
	        ADD     R1, SP, #84
	        LDR     R6, [R1, R11, LSL #2]
	        ADD     R7, R7, R6

	        // update a ... h
	        ADD     R6, R3, R7
	        LDR     R1, [SP, #80]
	        ADD     R7, R7, R1
	        ADD     R11, R11, #1
	        CMP     R11, #64		// 64 iterations
	        MOV     R12, R0
	        MOV     R3, R8
	        MOV     R1, R5
	        STR     R2, [SP, #80]
	        MOV     R2, LR
	        MOV     LR, R10
	        BNE     main_loop

		// H[ 7 ] += h
        LDR     R3, [SP, #72]
        ADD     R3, R0, R3
        STR     R3, [SP, #72]

        // H[ 6 ] += g
        LDR     R11, [SP, #68]
        ADD     R11, R8, R11

        // H[ 5 ] += f
        LDR     LR, [SP, #64]
        ADD     LR, R5, LR

		// H[ 4 ] += e
        LDR     R8, [SP, #48]
        ADD     R8, R7, R8

		// H[ 3 ] += d
        LDR     R0, [SP, #76]
        ADD     R0, R9, R0
        STR     R0, [SP, #76]

		// H[ 2 ] += c
        LDR     R9, [SP, #52]
        ADD     R9, R4, R9

		// H[ 1 ] += b
        LDR     R5, [SP, #56]
        ADD     R5, R10, R5
        MOV     R4, R5

		// H[ 0 ] += a
        LDR     R5, [SP, #60]
        ADD     R5, R6, R5

        LDR     R1, [SP, #44]
        ADD     R0, R1, #1
        CMP     R1, #0
        MOV     R7, R0
        LDR     R12, [SP, #24]
        LDR     R6, PAD_10_ADRS  // reduce cycles in second iteration
        BEQ     block_loop


	update_dest:
        LDR     R1, [SP, #4]		// R1 := dest
        LDR     R2, [SP, #72]		// R2 := H[7]

        STRB    R2, [R1, #31]		// first byte H[7]
        STRB    R11, [R1, #27]		// first byte H[6]
        STRB    LR, [R1, #23]		// first byte H[5]
        STRB    R8, [R1, #19]		// first byte H[4]

        LDR     R3, [SP, #76]		// R3 := H[3]
        STRB    R3, [R1, #15]		// first byte H[3]

        STRB    R9, [R1, #11]		// first byte H[2]
        STRB    R4, [R1, #7]		// first byte H[1]
        STRB    R5, [R1, #3]		// first byte H[0]

        // H[7]
        LSR     R0, R2, #8
        STRB    R0, [R1, #30]
        LSR     R0, R2, #16
        STRB    R0, [R1, #29]
        LSR     R0, R2, #24
        STRB    R0, [R1, #28]

        // H[6]
        LSR     R0, R11, #8
        STRB    R0, [R1, #26]
        LSR     R0, R11, #16
        STRB    R0, [R1, #25]
        LSR     R0, R11, #24
        STRB    R0, [R1, #24]

        // H[5]
        LSR     R0, LR, #8
        STRB    R0, [R1, #22]
        LSR     R0, LR, #16
        STRB    R0, [R1, #21]
        LSR     R0, LR, #24
        STRB    R0, [R1, #20]

        // H[4]
        LSR     R0, R8, #8
        STRB    R0, [R1, #18]
        LSR     R0, R8, #16
        STRB    R0, [R1, #17]
        LSR     R0, R8, #24
        STRB    R0, [R1, #16]

        // H[3]
        LSR     R0, R3, #8
        STRB    R0, [R1, #14]
        LSR     R0, R3, #16
        STRB    R0, [R1, #13]
        LSR     R0, R3, #24
        STRB    R0, [R1, #12]

        // H[2]
        LSR     R0, R9, #8
        STRB    R0, [R1, #10]
        LSR     R0, R9, #16
        STRB    R0, [R1, #9]
        LSR     R0, R9, #24
        STRB    R0, [R1, #8]

        // H[1]
        LSR     R0, R4, #8
        STRB    R0, [R1, #6]
        LSR     R0, R4, #16
        STRB    R0, [R1, #5]
        LSR     R0, R4, #24
        STRB    R0, [R1, #4]

        // H[0]
        LSR     R0, R5, #8
        STRB    R0, [R1, #2]
        LSR     R0, R5, #16
        STRB    R0, [R1, #1]
        LSR     R0, R5, #24
        STRB    R0, [R1]

    ADD     SP, SP, #340
    POP     {R4-R11, LR}
    BX      LR


/*****************************************************************************/
/******************************* VARIABLES ***********************************/
/*****************************************************************************/

//.data --> already defined... why?

H_INIT_0:
        .long   0x6a09e667
H_INIT_1:
        .long   0xbb67ae85
H_INIT_2:
        .long   0x3c6ef372
H_INIT_3:
        .long   0xa54ff53a
H_INIT_4:
        .long   0x510e527f
H_INIT_5:
        .long   0x9b05688c
H_INIT_6:
        .long   0x1f83d9ab
H_INIT_7:
        .long   0x5be0cd19


K_ADRS:
        .long   K
K:
        .long   0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5
        .long   0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5
        .long   0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3
        .long   0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174
        .long   0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc
        .long   0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da
        .long   0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7
        .long   0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967
        .long   0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13
        .long   0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85
        .long   0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3
        .long   0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070
        .long   0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5
        .long   0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3
        .long   0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208
        .long   0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2


/* Padding constant for data_lengt = 10 and one full block first_block
	-> 0b1000000, 0x00 ... 0x00, (uint64_t) ( ( data_length + SIZE_PADDED_BLOCK ) * 8 )
	-> 0x80, 0x00 ... 0x00, 0x02, 0x50
*/
PAD_10_ADRS:
        .long   PADDING_10
PADDING_10:
        .byte	0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        .byte	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        .byte	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        .byte	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        .byte	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        .byte	0x00, 0x00, 0x00, 0x00, 0x02, 0x50


/* Padding constant for data_lengt = 32 and one full block first_block
	-> 0b1000000, 0x00 ... 0x00, (uint64_t) ( ( data_length + SIZE_PADDED_BLOCK ) * 8 )
	-> 0x80, 0x00 ... 0x00, 0x03, 0x00
*/
PAD_32_ADRS:
        .long   PADDING_32
PADDING_32:
        .byte	0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        .byte	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        .byte 	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        .byte	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0x00
