#include <stdio.h>

void decimalToBinary(int decimal) {
    if (decimal > 0) {
        decimalToBinary(decimal / 2);
        printf("%d", decimal % 2);
    }
}

int main(int n, char inp[], char out[]) {
    FILE* ptr;
    char ch;

    printf("Binary representation: ");
    if (decimal == 0) {
        printf("0");
    } else {
        decimalToBinary(decimal);
    }
    printf("\n");

    return 0;
}

