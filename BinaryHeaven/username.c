#include <stdio.h>
#include <strings.h>


int main()
{
    char *username = "kym~humr"; 

    char answer[8];
    int i = 0;
    while (i < 8)
    {
        answer[i] = (username[i] - 8) ^ 4;
        i++;
    }

    printf("Username is : %s\n", answer);
    return 0;
}
