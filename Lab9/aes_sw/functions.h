#include "aes.h"
#define Nb 4
#define Nk 4
#define Nr 10

void printState(uchar * state) {
	int i, j;
	for (i = 0; i < 4; i++) {
		for (j = 0; j < 4; j++) {
			printf("%02X ", state[i*4+j]);
		}
		printf("\n");
	}
    printf("\n");
}
void printWord(uint * u, int i, int j) {
    printf("\n");
	for (i; i<j; i++) {
		printf("%08lX\n", u[i]);
	}
}

// rotate word "upward"
uint RotWord(uint in) {
    uint p0 = (0x00FF0000 & in) << 8;
    uint p1 = (0x0000FF00 & in) << 8;
    uint p2 = (0x000000FF & in) << 8;
    uint p3 = (0xFF000000 & in) >> 24;
    return p0 + p1 + p2 + p3;
}
// perform sbox on every byte
// 1) shift the byte down to lsb
// 2) perform aes SBox
// 3) shift back up and add into final answer
uint SubWord(uint in) {
    return (aes_sbox[(0xFF000000 & in) >> 24] << 24) + (aes_sbox[(0x00FF0000 & in) >> 16] << 16) + (aes_sbox[(0x0000FF00 & in) >> 8] << 8) + (aes_sbox[0x000000FF & in]);
}

void keyExpansion(uchar * cipher, uint * keySched) {
    /*
    a0 a4 a8  a12
    a1 a5 a9  a13
    a2 a6 a10 a14
    a3 a7 a11 a15
    */
    int i = 0;
    // load initial cypherkey into first 4 slots of keysched
    while (i < Nk) {
        keySched[i] = (cipher[i] << 24) + (cipher[i+4] << 16) + (cipher[i+8] << 8) + cipher[i+12];
        i++;
    }
    i = Nk;
    while (i < (Nb * (Nr+1))) {
        // set temp to the keysched of 1 before
        uint temp = keySched[i-1];
        if (i % Nk == 0) {
            temp = SubWord(RotWord(temp)) ^ Rcon[i/Nk];
        }
        keySched[i] = (keySched[i-Nk] ^ temp); // wipe out the 1s from xor;
        // printWord(keySched,i,i+1);
        i++;
    }
}
// perform substitution with sbox
void subByte(uchar * state) {
    int i;
    for (i = 0; i < 16; i++) { // perform sbox on every element
        state[i] = aes_sbox[state[i]];
    }
}
// left shift each row by its rowcount
void shiftRow(uchar * state) {
	int i;
    for (i = 1; i < 4; i++) {
    uchar temp[4] = {state[4*i],state[4*i+1],state[4*i+2],state[4*i+3]};
        state[4*i] = temp[i%4];
        state[4*i+1] = temp[(i+1)%4];
        state[4*i+2] = temp[(i+2)%4];
        state[4*i+3] = temp[(i+3)%4];
    }
}
// perform mixing
void mixColumns(uchar * state) {
    uchar b[16];
    int i;
    for (i = 0; i < 4; i++) {
        uchar a0 = state[i];
        uchar a1 = state[i+4];
        uchar a2 = state[i+8];
        uchar a3 = state[i+12];
        uchar b0 = (gf_mul[a0][0]) ^ (gf_mul[a1][1]) ^ a2 ^ a3;
        uchar b1 = a0 ^ (gf_mul[a1][0]) ^ (gf_mul[a2][1]) ^ a3;
        uchar b2 = a0 ^ a1 ^ (gf_mul[a2][0]) ^ (gf_mul[a3][1]);
        uchar b3 = (gf_mul[a0][1]) ^ a1 ^ a2 ^ (gf_mul[a3][0]);
        b[i] = b0;
        b[i+4] = b1;
        b[i+8] = b2;
        b[i+12] = b3;
    }
    for (i = 0; i < 16; i++) {
        state[i] = b[i];
    }
}
void addRoundKey(uchar * state, uint * keysched, int round) {
	int i;
    for (i = 0; i < 4; i++) {
        uint curword = keysched[round*4+i];
        state[i] = state[i] ^ ((uchar) (curword >> 24));
        state[i+4] = state[i+4] ^ ((uchar) (curword >> 16));
        state[i+8] = state[i+8] ^ ((uchar) (curword >> 8));
        state[i+12] = state[i+12] ^ ((uchar) (curword));
    }
}
