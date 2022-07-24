#include "pbkdf2.h"
#include "sha256.h"

/*
 * TODO:
 * Implement the pbkdf2 function for the given scenario:
 * 	- "password" holds the 6 byte password you sent via the software.
 *  - write the output into "derivedKey" (16 bytes).
 */
void pbkdf2(uint8_t password[ SIZE_PASSWORD ], uint8_t derivedKey[ SIZE_DERIVED_KEY ])
{
    uint8_t U[ SIZE_BLOCK ] = { 0 };
    uint8_t T[ SIZE_BLOCK ] = { 0 };
    uint8_t tmp[ SIZE_BLOCK ] = { 0 };

    // Matrikelnummer = 108019210718
    uint8_t matNr_with_pad[ SIZE_MATNR_PADDED ] = {
    		0x10, 0x80, 0x19, 0x21, 0x07, 0x18, 0x00, 0x00, 0x00, 0x01
    };

    // U_1 = HMAC( P, matNr || 0x00000001 )
    sha256_hmac_c( password, matNr_with_pad, SIZE_MATNR_PADDED, U );

    for ( int round = 1; round < NUM_ROUNDS; round++ )
    {
    	for ( int i = 0; i < SIZE_BLOCK; i++ ) {
    		tmp[ i ] = U[ i ];
    		T[ i ] ^= U[ i ];			// T = U_1 xor ... xor U_9999
    	}

        // U_i = HMAC( P, U_{i-1} )
        sha256_hmac_c( password, tmp, SIZE_BLOCK, U );
    }

    for ( int i = 0; i < SIZE_BLOCK; i++ ) {
        T[ i ] ^= U[ i ];			// T = U_1 xor ... xor U_9999 xor U_1000
    }

    // return T<0..15>
    for ( int i = 0; i < SIZE_DERIVED_KEY; i++ )
        derivedKey[i] = T[i];

}
