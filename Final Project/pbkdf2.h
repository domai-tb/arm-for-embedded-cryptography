#ifndef _PBKDF2_H_
#define _PBKDF2_H_

#include <stdint.h>
#include <stdio.h>

/**
 *  Usefull magic values.
 */
#define SIZE_MATNR_PADDED 10
#define SIZE_DERIVED_KEY 16
#define SIZE_PASSWORD 6
#define NUM_ROUNDS 10000

/********************************************
 *                                          *
 *	IMPLEMENTATION	CYCLES			TIME    *
 *											*
 *	sha256_core_c	~ 183.098.000	~1.3s	*
 *	sha256_core_s	~ 207.554.000	~1.4s	*
 *											*
 *	 HOME 	:<: ˓(ᑊᘩᑊ⁎) :<: 	ARM CAREER		*
 *											*
 ********************************************/

void pbkdf2(uint8_t password[ SIZE_PASSWORD ], uint8_t derivedKey[ SIZE_DERIVED_KEY ]);

#endif
