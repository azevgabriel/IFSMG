//Varíaveis Globais

int ONDA = 0;
int LED = 0;
int contador = 1;
int aux_cont;
int aux_cont2;
int aux;
int controle;

void main() {
    TRISA = 0b00000000; //Todos os RBAs com saídas
    TRISB = 0b00000011; //Apenas o RB0 e RB1 como entrada
    OPTION_REG = 0b00000000; //Prescaler 1:2
    INTCON = 0b10110000; // TMR0 enable, Interrupção por overflow e global enable
    PORTA = contador; //As portas RBAs recebem um valor decimal e converte em binário.

    while(1){
     while(1){
      if(PORTB.B1 == 0){ //RB1 for clear break no while.
       break;
      }
     }
      if(contador == 1){
      controle = 0; // Função de Incrementar contador
     }
     if(contador == 9){
      controle = 1; // Função de Decrementar contador
     }
     if(controle == 0){
       contador++; //Incrementa contador
       PORTA = contador; //Atualiza o contador nas saídas RBA
     }
     if(controle == 1){
       contador--; //Decrementa contador
       PORTA = contador; //Atualiza o contador nas saídas RBA
     }
      while(PORTB.B1 == 0){
     }
    }
}

void interrupt() {
     //Interrupção de TMR0
     if (INTCON.B1 == 0){
        //Se ONDA igual a Clear, set saída da ONDA_QUADRADA.
        if(ONDA == 0){
         ONDA = 1;
         PORTB.B6 = 1;
        }
        //Se ONDA igual a Set, Clear saída da ONDA_QUADRADA.
        else{
         ONDA = 0;
         PORTB.B6 = 0;
        }

        if(aux_cont != contador){ //Se o aux do Contador for diferente do Contador,
        //ele atualiza os auxs e muda a frequencia da Onda Quadrada
        aux_cont = contador;

          //Teste 9
          if(aux_cont == 9){

               aux_cont2 = 221;
          }
          //Teste 8
          else if(aux_cont == 8){

               aux_cont2 = 214;
          }
          //Teste 7
          else if(aux_cont == 7){
               aux_cont2 = 205;
          }
          //Teste 6
          else if(aux_cont == 6){
               aux_cont2 = 193;
          }
          //Teste 5
          else if(aux_cont == 5){
               aux_cont2 = 177;
          }
          //Teste 4
          else if(aux_cont == 4){
               aux_cont2 = 152;
          }
          //Teste 3
          else if(aux_cont == 3){
               aux_cont2 = 111;
          }
          //Teste 2
          else if(aux_cont == 2){
               aux_cont2 = 28;
               OPTION_REG.B0 = 0;
          }
          //Teste 1
          else if(aux_cont == 1){
               aux_cont2 = 17;
               OPTION_REG.B0 = 1;
          }
        }
        TMR0 = aux_cont2; //TMR0 inicia com valor do aux_cont2
        INTCON.B2 = 0; //Clear na Flag de Overflow do TMR0
      return;
     }
     //Interrupção do LED
     if(INTCON.B1 == 1){
        //Se LED igual a Clear, set saída do Led.
        if(LED == 0){
         LED = 1;
         PORTB.B7 = 1;
         INTCON.B1 = 0;
         return;
        }
        //Se LED igual a Set, clear saída do Led.
        if(LED == 1){
         LED = 0;
         PORTB.B7 = 0;
         INTCON.B1 = 0;
         return;
        }
     }
     return;
}