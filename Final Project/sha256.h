#ifndef _SHA256_H_
#define _SHA256_H_

#include <stdint.h>
#include <stdio.h>

/**
 *  Usefull magic values.
 */
#define AMOUNT_SATE_WORDS 8
#define AMOUNT_TMP_WORDS 64
#define SIZE_KEY 6
#define SIZE_BLOCK 32
#define SIZE_PADDED_BLOCK 64
#define NUM_CONSTANTS 64
#define NUM_BLOCKS 2
#define NUM_SHA_ROUNDS 64

#define SIZE_CONST_PAD_10 54
#define SIZE_CONST_PAD_32 32
#define SIZE_DATA_OF_PAD_10 10
#define SIZE_DATA_OF_PAD_32 32

/** Padding constants:

  The HMAC is in this case just called with size of 10 or 32.

  Each of these bytes is either my student id padded with (uint32_t)0x01
  or the result of the previously HMAC call.

  --> So we can  assume that we allays have full used bytes in data.
  --> We can create two statically paddings and append then in
      case of data_length == 10 or data_length == 32.
*/
extern const uint8_t PADDING_10[ SIZE_CONST_PAD_10 ];
extern const uint8_t PADDING_32[ SIZE_CONST_PAD_32 ];

/**
 * 	Load a uint32_t value x from a uint8_t array y.
 */
#define LOAD_32( x, y, offset )                   	               \
		{ x = ( (uint32_t) ( (y)[ 0 + offset ] & 255 ) << 24 ) |   \
			  ( (uint32_t) ( (y)[ 1 + offset ] & 255 ) << 16 ) |   \
			  ( (uint32_t) ( (y)[ 2 + offset ] & 255 ) << 8  ) |   \
           	  ( (uint32_t) ( (y)[ 3 + offset ] & 255 ) ); }

/**
 * 	Add a uint32_t value x to a uint8_t array y.
 */
#define ADD_32( y, x, offset )                                    \
		{ (y)[ 0 + offset ] += (uint8_t) ( ((x) >> 24) & 255 );   \
		  (y)[ 1 + offset ] += (uint8_t) ( ((x) >> 16) & 255 );   \
          (y)[ 2 + offset ] += (uint8_t) ( ((x) >> 8 ) & 255 );   \
		  (y)[ 3 + offset ] += (uint8_t) (  (x)        & 255 ); }

/**
 * 	Store a uint32_t value x to a uint8_t array y.
 */
#define STORE_32( y, x, offset )                                 \
		{ (y)[ 0 + offset ] = (uint8_t) ( ((x) >> 24) & 255 );   \
		  (y)[ 1 + offset ] = (uint8_t) ( ((x) >> 16) & 255 );   \
          (y)[ 2 + offset ] = (uint8_t) ( ((x) >> 8 ) & 255 );   \
		  (y)[ 3 + offset ] = (uint8_t) (  (x)        & 255 ); }

/**
 *  SHA256 internal functions.
 */
#define ROTR( a, b )  ( ( (a) >> (b) ) | ( (a) << ( 32 - (b) ) ) )
#define CH( x, y, z)  ( ( (x) & (y)) ^ ( ~(x) & (z) ) )
#define MAJ( x, y, z) ( ( (x) & (y) ) ^ ( (x) & (z) ) ^ ( (y) & (z) ) )
#define BSIG0( x )    ( ROTR( x, 2 ) ^ ROTR( x, 13 ) ^ ROTR( x, 22 ) )
#define BSIG1( x )    ( ROTR( x, 6 ) ^ ROTR( x, 11 ) ^ ROTR( x, 25 ) )
#define SSIG0( x )    ( ROTR( x, 7 ) ^ ROTR( x, 18 ) ^ ( (x) >> 3 ) )
#define SSIG1( x )    ( ROTR( x, 17 ) ^ ROTR( x, 19 ) ^ ( (x) >> 10 ) )

/**
 * SHA256 constants.
 */
extern const uint32_t K[ NUM_CONSTANTS ];
extern const uint32_t H_INIT[ AMOUNT_SATE_WORDS ];
extern const uint8_t IPAD[ SIZE_PADDED_BLOCK ];
extern const uint8_t OPAD[ SIZE_PADDED_BLOCK ];

/**
 *  SHA256 functions.
 */

/**
 *  An in ARM Thumb implemented SHA256 core function with constant padding
 *  for the case of this personalized PBKDF2 implementation.
 *
 * @param first_block first 512-bit block
 * @param data byte array of data to be hashed
 * @param data_length amount of data bytes
 * @param dest destination were hash is returned / state of SHA256
 *
 */
void sha256_core_s( uint8_t first_block[ SIZE_PADDED_BLOCK ],
                    uint8_t* data,
                    uint32_t data_length,
                    uint8_t dest[ SIZE_BLOCK ] );

/**
 *  An in C implemented SHA256 core function with constant padding
 *  for the case of this personalized PBKDF2 implementation.
 *
 * @param first_block first 512-bit block
 * @param data byte array of data to be hashed
 * @param data_length amount of data bytes
 * @param dest destination were hash is returned / state of SHA256
 *
 */
void sha256_core_c( uint8_t first_block[ SIZE_PADDED_BLOCK ],
                    uint8_t* data,
                    uint32_t data_length,
                    uint8_t dest[ SIZE_BLOCK ] );

/**
 *  An in C implemented SHA256-HMAC.
 *
 * @param key six key bytes
 * @param data byte array of data to be hashed
 * @param data_length amount of data bytes
 * @param dest destination were hash is returned
 *
 */
void sha256_hmac_c( uint8_t key[ SIZE_KEY ],
                    uint8_t* data,
                    uint32_t data_length,
                    uint8_t dest[ SIZE_BLOCK ] );

#endif
