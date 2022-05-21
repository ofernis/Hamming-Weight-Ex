#include <stdio.h>
#include <stdlib.h>
#include <string.h>

unsigned long read_input(unsigned long* codeword);
unsigned long hamming_weight(unsigned long* codeword, unsigned long len);
unsigned long negate_first_k(unsigned long codeword, unsigned char k);
unsigned long bring_balance_to_the_word(unsigned long* codeword, unsigned long len);
unsigned long codeword[1000];

static char* input_path = NULL;


long atam_atol(const char* s)
{
    return atol(s);
}

void get_path(char* _path)
{
    strncpy(_path, input_path, 1023);
    _path[1023] = '\0';
}

int main(int argc, char** argv)
{
    if(argc != 2)
    {
        printf("Usage: %s <input_file>\n", argv[0]);
        return 1;
    }
    input_path = argv[1];
    unsigned long len = read_input(codeword);
    printf("Input: ");
    for (int i = 0; i < len; i++)
    {
        printf("0x%lx", codeword[i]);
        if (i == len - 1)
            printf("\n");
        else
            printf(", ");
    }
    printf("Hamming weight: %lu\n", hamming_weight((unsigned long*) codeword, len));
    printf("After negating the first 5 bits of the first 8-byte: 0x%lx\n", negate_first_k(codeword[0], 5));
    printf("The index at which Knuth's algorithm stopped: %lu\n",
           bring_balance_to_the_word((unsigned long*) codeword, len));
    printf("The balanced word: ");
    for (int i = 0; i < len; i++)
    {
        printf("0x%lx", codeword[i]);
        if (i == len - 1)
            printf("\n");
        else
            printf(", ");
    }
    return 0;
}