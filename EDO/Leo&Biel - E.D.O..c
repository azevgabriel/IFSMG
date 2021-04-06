//Criado por Gabriel Azevedo & Leonardo Henrique em 10/12/2019
//Qualquer plágio significa uma traição aos valores éticos e morais.

#include <stdio.h>
#include <stdlib.h>

double funcao(double x, double y);
double funcao2(double x, double y,double h);
double funcao3(double x, double y,double h);
double funcao4(double x, double y,double h);
double funcao5(double x, double y,double h);
double derivada(double x,double y);

int main(){
    int op,c;
    float x0,y0,r,aux1,aux2;
    float T=0,i=0;

    printf("Digite o valor de x0: ");
    scanf("%f", &x0);
    printf("Digite o valor de y0: ");
    scanf("%f", &y0);
    printf("Digite a razao: ");
    scanf("%f", &r);
    aux1 = x0;
    aux2 = y0;

    do{
        x0 = aux1;
        y0 = aux2;
        c=0;
        printf("\n[x0 = %.2f] [y0 = %.2f] [h = %.2f]\n",aux1,aux2,r);
        printf("\nEscolha o metodo desejado:");
        printf("\n1 - Taylor de Primeira Ordem");
        printf("\n2 - Taylor de Segunda Ordem");
        printf("\n3 - Euler Modificado");
        printf("\n4 - Euler Melhorado");
        printf("\n5 - Runge Kutta");
        printf("\n6 - Sair\n\n");
        scanf("%d", &op);

        fflush(stdin);
        system("cls");

        if(op==1){
            for(i=r;i<=1;i+=r){
                c++;
                T = y0+r * funcao(x0,y0);
                printf("x[%d] = %.2f T-1[%d] = %.6f\n",c,i,c,T);
                y0 = T;
                x0 = i;
            }
        }

        if(op==2){
            for(i=r;i<=1;i+=r){
                c++;
                T = y0+r *funcao(x0,y0) + (((r*r)/2)*derivada(x0,y0));
                printf("x[%d] = %.2f T-2[%d] = %.6f\n",c,i,c,T);
                y0=T;
                x0=i;
            }
        }

        if(op==3){
            for(i=r;i<=1;i+=r){
                c++;
                T = y0+r * funcao2(x0,y0,r);
                printf("x[%d] = %.2f E-Mo[%d] = %.6f\n",c,i,c,T);
                y0=T;
                x0=i;
            }
        }

        if(op==4){
            for(i=r;i<=1;i+=r){
                c++;
                T = y0+(r/2)*(funcao3(x0,y0,r)+funcao(x0,y0));
                printf("x[%d] = %.2f E-Me[%d] = %.6f\n",c,i,c,T);
                y0=T;
                x0=i;
            }
        }

        if(op==5){
            for(i=r;i<=1;i+=r){
                c++;
                T = y0+(r/6)*(funcao(x0,y0)+2*funcao2(x0,y0,r)+2*funcao4(x0,y0,r)+funcao5(x0,y0,r));
                printf("x[%d] = %.2f Kutta[%d] = %.6f\n",c,i,c,T);
                y0=T;
                x0=i;
            }
        }
    }
    while(op!=6);

    return 0;

}

double funcao(double x, double y){
	return (x-y+2);
}

double derivada(double x,double y){
	return (1 - (1*(x-y+2)));
}

double funcao2(double x, double y,double h){
	return ((x+(h/2))-(y+(h/2)*funcao(x,y))+2);
}

double funcao3(double x, double y,double h){
	return ((x+h)-(y+h*funcao(x,y))+2);
}

double funcao4(double x, double y,double h){
	return ((x+(h/2))-(y+(h/2)*funcao2(x,y,h))+2);
}

double funcao5(double x, double y,double h){
	return ((x+(h)-(y+(h)*funcao4(x,y,h))+2));
}
