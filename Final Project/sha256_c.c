#include "sha256.h"

// The 64 constants K[ 0 ] ... K[ 63 ]
const uint32_t K[ NUM_CONSTANTS ] = {
	0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5,
	0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
	0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3,
	0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
	0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc,
	0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
	0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7,
	0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
	0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13,
	0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
	0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3,
	0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
	0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5,
	0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
	0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208,
	0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
};

// Before computing anything, the state H is initialized as follows:
const uint32_t H_INIT[ AMOUNT_SATE_WORDS ] = {
	0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a,
	0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19,
};

// Constant ipad is 0x36 repeated 64 times.
const uint8_t IPAD[ SIZE_PADDED_BLOCK ] = {
	0x36, 0x36, 0x36, 0x36, 0x36, 0x36, 0x36, 0x36,
	0x36, 0x36, 0x36, 0x36, 0x36, 0x36, 0x36, 0x36,
	0x36, 0x36, 0x36, 0x36, 0x36, 0x36, 0x36, 0x36,
	0x36, 0x36, 0x36, 0x36, 0x36, 0x36, 0x36, 0x36,
	0x36, 0x36, 0x36, 0x36, 0x36, 0x36, 0x36, 0x36,
	0x36, 0x36, 0x36, 0x36, 0x36, 0x36, 0x36, 0x36,
	0x36, 0x36, 0x36, 0x36, 0x36, 0x36, 0x36, 0x36,
	0x36, 0x36, 0x36, 0x36, 0x36, 0x36, 0x36, 0x36,
};

// Constant opad is 0x5C repeated 64 times.
const uint8_t OPAD[ SIZE_PADDED_BLOCK ] = {
	0x5C, 0x5C, 0x5C, 0x5C, 0x5C, 0x5C, 0x5C, 0x5C,
	0x5C, 0x5C, 0x5C, 0x5C, 0x5C, 0x5C, 0x5C, 0x5C,
	0x5C, 0x5C, 0x5C, 0x5C, 0x5C, 0x5C, 0x5C, 0x5C,
	0x5C, 0x5C, 0x5C, 0x5C, 0x5C, 0x5C, 0x5C, 0x5C,
	0x5C, 0x5C, 0x5C, 0x5C, 0x5C, 0x5C, 0x5C, 0x5C,
	0x5C, 0x5C, 0x5C, 0x5C, 0x5C, 0x5C, 0x5C, 0x5C,
	0x5C, 0x5C, 0x5C, 0x5C, 0x5C, 0x5C, 0x5C, 0x5C,
	0x5C, 0x5C, 0x5C, 0x5C, 0x5C, 0x5C, 0x5C, 0x5C,
};

/* Padding constant for data_lengt = 10 and one full block first_block
	-> 0b1000000, 0x00 ... 0x00, (uint64_t) ( ( data_length + SIZE_PADDED_BLOCK ) * 8 )
	-> 0x80, 0x00 ... 0x00, 0x02, 0x50
*/
const uint8_t PADDING_10[ SIZE_CONST_PAD_10 ] = {
	0x80, [ 1 ... (SIZE_CONST_PAD_10 - 3) ] = 0x00, 0x02, 0x50
};

/* Padding constant for data_lengt = 32 and one full block first_block
	-> 0b1000000, 0x00 ... 0x00, (uint64_t) ( ( data_length + SIZE_PADDED_BLOCK ) * 8 )
	-> 0x80, 0x00 ... 0x00, 0x03, 0x00
*/
const uint8_t PADDING_32[ SIZE_CONST_PAD_32 ] = {
	0x80, [ 1 ... (SIZE_CONST_PAD_32 - 3) ] = 0x00, 0x03, 0x00
};


/*
 * 	SHA256 CORE
 */
void sha256_core_c( uint8_t first_block[ SIZE_PADDED_BLOCK ],
                    uint8_t* data,
                    uint32_t data_length,
                    uint8_t dest[ SIZE_BLOCK ] )
{
	// because HMAC is only with data_length 10 or 32 called, we just have two blocks
	uint32_t W[ AMOUNT_TMP_WORDS ] = { 0 };
	uint32_t H[ AMOUNT_SATE_WORDS ] =
	{
			0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a,
			0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19,
	};
	uint32_t a, b, c, d, e, f, g, h, T1, T2;

	for ( int N_i = 0; N_i < NUM_BLOCKS; N_i++ )
	{
		// prepare 64 temporary data words W
		if ( N_i == 0 )
		{
			// use first block
			for ( int t = 0; t < 16; t++ ) {
				LOAD_32( W[ t ], first_block, (4 * t) )
			}

			// initialize working variables a-h
			a = H_INIT[0];
			b = H_INIT[1];
			c = H_INIT[2];
			d = H_INIT[3];
			e = H_INIT[4];
			f = H_INIT[5];
			g = H_INIT[6];
			h = H_INIT[7];

		} else if ( N_i > 0 )
		{
			// initialize working variables a-h
			a = H[ 0 ];
			b = H[ 1 ];
			c = H[ 2 ];
			d = H[ 3 ];
			e = H[ 4 ];
			f = H[ 5 ];
			g = H[ 6 ];
			h = H[ 7 ];

			// use data and constant padding
			if ( data_length == SIZE_DATA_OF_PAD_10 )
			{
				LOAD_32( W[ 0 ], data, 0 )
				LOAD_32( W[ 1 ], data, 4 )

				W[ 2 ] = data[ 8 ];
				W[ 2 ] = ( W[ 2 ] << 8 ) + data[ 9 ];
				W[ 2 ] = ( W[ 2 ] << 8 ) + PADDING_10[ 0 ];
				W[ 2 ] = ( W[ 2 ] << 8 ) + PADDING_10[ 1 ];

				for ( int t = 3; t < 16; t++ )
					LOAD_32( W[ t ], PADDING_10, ((4 * t) - 10) )
			}

			else if ( data_length == SIZE_DATA_OF_PAD_32 )
			{
				for ( int t = 0; t < 8; t++ )
					LOAD_32( W[ t ], data, (4 * t) )

				// use padding
				for ( int t = 0; t < 8; t++ )
					LOAD_32( W[ t + 8 ], PADDING_32, (4 * t) )
			}
		}

		for ( int t = 16; t < AMOUNT_TMP_WORDS; t++ )
			W[ t ] = SSIG1( W[ t-2 ] ) + W[ t-7 ] + SSIG0( W[ t-15 ] ) + W[ t-16 ];

		// perform main loop
		for ( int t = 0; t < NUM_SHA_ROUNDS; t++ )
		{
			T1 = h + BSIG1( e ) + CH( e, f, g ) + K[ t ] + W[ t ];
			T2 = BSIG0( a ) + MAJ( a, b, c );
			h = g; g = f; f = e; e = d + T1; d = c; c = b; b = a; a = T1 + T2;
		}

		// update hash value H -> update destination
		H[ 0 ] += a;
		H[ 1 ] += b;
		H[ 2 ] += c;
		H[ 3 ] += d;
		H[ 4 ] += e;
		H[ 5 ] += f;
		H[ 6 ] += g;
		H[ 7 ] += h;
	}

	// write H to destination
	STORE_32( dest, H[ 0 ], 0  )
	STORE_32( dest, H[ 1 ], 4  )
	STORE_32( dest, H[ 2 ], 8  )
	STORE_32( dest, H[ 3 ], 12 )
	STORE_32( dest, H[ 4 ], 16 )
	STORE_32( dest, H[ 5 ], 20 )
	STORE_32( dest, H[ 6 ], 24 )
	STORE_32( dest, H[ 7 ], 28 )
}

/*
 * 	SHA256 HMAC
 */
void sha256_hmac_c( uint8_t key[ SIZE_KEY ],
                    uint8_t* data,
                    uint32_t data_length,
                    uint8_t dest[ SIZE_BLOCK ] )
{
	// instead of copy OPAD / IPAD constants to edit them later
	uint8_t key_ipad[ SIZE_PADDED_BLOCK ] = { [ 0 ... (SIZE_PADDED_BLOCK - 1) ] = 0x36 };
	uint8_t key_opad[ SIZE_PADDED_BLOCK ] = { [ 0 ... (SIZE_PADDED_BLOCK - 1) ] = 0x5C };
	uint8_t tmp[ SIZE_BLOCK ] = { 0 };

	// key xor ipad; key xor opad
	for ( int i = 0; i < SIZE_KEY; i++ ) {
		key_ipad[ i ] ^= key[ i ];
		key_opad[ i ] ^= key[ i ];
	}

	// H(key xor ipad || data)
	//sha256_core_c( key_ipad, data, data_length, dest );
	sha256_core_s( key_ipad, data, data_length, dest );

	for ( int i = 0; i < SIZE_BLOCK; i++ )
		tmp[ i ] = dest[ i ];

	// H(key xor opad || H(key xor ipad || data))
	//sha256_core_c( key_opad, tmp, SIZE_BLOCK, dest );
	sha256_core_s( key_opad, tmp, SIZE_BLOCK, dest );
}
