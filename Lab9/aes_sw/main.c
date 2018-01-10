/************************************************************************
Lab 9 Nios Software

Dong Kai Wang, Fall 2017
Christine Chen, Fall 2013

For use with ECE 385 Experiment 9
University of Illinois ECE Department
************************************************************************/

#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include "aes.h"
#include "functions.h"

// Pointer to base address of AES module, make sure it matches Qsys
volatile unsigned int * AES_PTR = (unsigned int *) 0x00000040;

// Execution mode: 0 for testing, 1 for benchmarking
int run_mode = 0;

/** charToHex
 *  Convert a single character to the 4-bit value it represents.
 *
 *  input: a character c (e.g. 'A')
 *  output: converted 4-bit value (e.g. 0xA)
 */
char charToHex(char c)
{
	char hex = c;

	if (hex >= '0' && hex <= '9')
		hex -= '0';
	else if (hex >= 'A' && hex <= 'F')
	{
		hex -= 'A';
		hex += 10;
	}
	else if (hex >= 'a' && hex <= 'f')
	{
		hex -= 'a';
		hex += 10;
	}
	return hex;
}

/** charsToHex
 *  Convert two characters to byte value it represents.
 *  Inputs must be 0-9, A-F, or a-f.
 *
 *  input: two characters c1 and c2 (e.g. 'A' and '7')
 *  output: converted byte value (e.g. 0xA7)
 */
char charsToHex(char c1, char c2)
{
	char hex1 = charToHex(c1);
	char hex2 = charToHex(c2);
	return (hex1 << 4) + hex2;
}

// Perform AES Encryption in Software
void encrypt(unsigned char * plaintext_asc, unsigned char * key_asc, unsigned long * state, unsigned long * key)
{
	// convert plaintext ascii to initial state matrix
	uchar state_byte[16];
	uchar cypher_byte[16];
	int i;
	int j;
	// fill in column major
	for (i = 0; i < 4; i++) {
		for (j = 0; j < 4; j++) {
			state_byte[j*4+i] = charsToHex(plaintext_asc[(i*4+j)*2], plaintext_asc[(i*4+j)*2 + 1]);
			cypher_byte[j*4+i] = charsToHex(key_asc[(i*4+j)*2], key_asc[(i*4+j)*2 + 1]);
		}
	}
	// key schedule
	uint key_schedule[Nb*(Nr+1)];
	// perform key expansion
	keyExpansion(cypher_byte, key_schedule);

//	printf("key for round: %d \n", 0);
//	printWord(key_schedule, 0, 4);

	// add initial key
	addRoundKey(state_byte, key_schedule, 0);

	// go through other 9 rounds
	for (i = 1; i < 10; i++) {
//		printf("key for round: %d \n", i);
//		printWord(key_schedule, i*4, i*4+4);
//		printf("\n");

		subByte(state_byte);
		// printf("after subByte\n");
		// printState(state_byte);

		shiftRow(state_byte);
		// printf("after shiftRow\n");
		// printState(state_byte);

		mixColumns(state_byte);
		// printf("after mixColumns\n");
		// printState(state_byte);

		addRoundKey(state_byte, key_schedule, i);
		// printf("after addRoundKey\n");
		// printState(state_byte);
	}

	// perform last ops
	subByte(state_byte);
	shiftRow(state_byte);
	addRoundKey(state_byte, key_schedule, 10);
	// printf("Final State\n");
	// printState(state_byte);

	// put column major state in state
	for (i = 0; i < 4; i++) {
		state[i] = (state_byte[i] << 24) + (state_byte[i+4] << 16) + (state_byte[i+8] << 8) + state_byte[i+12];
		// clear out junk at beginning
		state[i] = 0x00000000FFFFFFFF & state[i];
	}

	// put onto avalon MM AES Module
	// put column major key in key
	for (i = 0; i < 4; i++) {
		key[i] = key_schedule[i];
		AES_PTR[i] = key_schedule[i];
//		printf("%08x ", AES_PTR[i]);
	}
//	printf("\n");
}

// Perform AES Decryption in Hardware
void decrypt(unsigned long * state, unsigned long * key)
{
//	printf("\n");
	int i;
	// dont start yet;
	AES_PTR[14] = 0;
//	for(i = 0; i < 4; i++){
//		printf("%08x ", AES_PTR[i]);
//	}
//	printf("\n");
	// set AES_MSG_ENC
	AES_PTR[4] = state[0];
	AES_PTR[5] = state[1];
	AES_PTR[6] = state[2];
	AES_PTR[7] = state[3];

	// set debug mode
	AES_PTR[12] = 0;
	// set starting step
	AES_PTR[13] = 0;
	// START!!!
	AES_PTR[14] = 1;
	// read intermediate state
	if (AES_PTR[12] == 0)
	while (AES_PTR[15] == 0) {
// code for stepping through
//		for(i = 0; i < 4; i++){
//			printf("%08x ", AES_PTR[8+i]);
//		}
//		printf("\n");
//		AES_PTR[13] = AES_PTR[13] + 1; // step ahead
	};
	state[0] = AES_PTR[8];
	state[1] = AES_PTR[9];
	state[2] = AES_PTR[10];
	state[3] = AES_PTR[11];
	// turn off AES_START
	AES_PTR[14] = 0;
//	printf("ptr 15: %d \n", AES_PTR[15]);
}


int main()
{
	// Input Message and Key as 32x 8bit ASCII Characters ([33] is for NULL terminator)
	unsigned char plaintext_asc[33];
	unsigned char key_asc[33];
	// Key and Encrypted Message in 4x 32bit Format
	unsigned long state[4];
	unsigned long key[4];
	// testing
	// ece298dcece298dcece298dcece298dc
	// 000102030405060708090a0b0c0d0e0f
	// daec3055df058e1c39e814ea76f6747e

	printf("Select execution mode: 0 for testing, 1 for benchmarking: ");
	scanf("%d", &run_mode);

	if (run_mode == 0) {
		while (1) {
			int i = 0;
			printf("\nEnter plain text:\n");
			scanf("%s", plaintext_asc);
			printf("\n");
			printf("\nEnter key:\n");
			scanf("%s", key_asc);
			printf("\n");
			encrypt(plaintext_asc, key_asc, state, key);
			printf("\nEncrypted message is: \n");
			for(i = 0; i < 4; i++){
				printf("%08lx", state[i]);
			}
			printf("\n");
			decrypt(state, key);
			printf("\nDecrypted message is: \n");
			for(i = 0; i < 4; i++){
				printf("%08lx", state[i]);
			}
			printf("\n");
		}
	}
	else {
		int i = 0;
		int size_KB = 1;
		for (i = 0; i < 32; i++) {
			plaintext_asc[i] = 'a';
			key_asc[i] = 'b';
		}

		clock_t begin = clock();
		for (i = 0; i < size_KB * 128; i++)
			encrypt(plaintext_asc, key_asc, state, key);
		clock_t end = clock();
		double time_spent = (double)(end - begin) / CLOCKS_PER_SEC;
		double speed = size_KB / time_spent;

		printf("Software Encryption Speed: %f KB/s \n", speed);

		begin = clock();
		for (i = 0; i < size_KB * 128; i++)
			decrypt(state, key);
		end = clock();
		time_spent = (double)(end - begin) / CLOCKS_PER_SEC;
		speed = size_KB / time_spent;

		printf("Hardware Encryption Speed: %f KB/s \n", speed);
	}
	return 0;
}
