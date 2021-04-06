//Definição dos Leds
sbit LCD_D4 at RB3_bit;
sbit LCD_D5 at RB2_bit;
sbit LCD_D6 at RB1_bit;
sbit LCD_D7 at RB0_bit;
sbit LCD_RS at RB5_bit;
sbit LCD_EN at RB4_bit;

sbit LCD_D4_Direction at TRISB3_bit;
sbit LCD_D5_Direction at TRISB2_bit;
sbit LCD_D6_Direction at TRISB1_bit;
sbit LCD_D7_Direction at TRISB0_bit;
sbit LCD_RS_Direction at TRISB5_bit;
sbit LCD_EN_Direction at TRISB4_bit;

char freq[9]; //Texto LCD
unsigned int frequencia; //Variável para armazenar o valor da frequência

int ATRASO = 8; //Atraso set como 16 em Decimal
int TMPH; // Auxiliar para TMR1H
int TMPL; // Auxiliar para TMR1L

void main() {
    TRISA = 0b00000000; //Todas os RAs como saída
    TRISB = 0b11000000;  //RB6 como entrada do clock externo do TMR1
    OPTION_REG = 0b00000000;
    INTCON = 0b11000000; //Interrupções Globais e Periféricas habilitadas
    PIE1 = 0b00000010; //Interrupçâo por TMR2 habilitada
    PR2 = 0b01111010; //125 ms
    TMR2 = 0; //Zera o TMR2
    TMR1L = 0; //Zera o TMR1 LOW
    TMR1H = 0; //Zera o TMR1 HIGH
    T1CON=0b00000111; //Async, Clock externo, TMR1 ENABLE.
    T2CON=0b01111111; //1:16 Postscaler e 1:16 Preescaler
    PORTB.RB0 = 0; //Clear no RB0
    
    Lcd_Init();                   // Inicializando LCD.
    Lcd_Cmd(_LCD_CLEAR);          //Limpando LCD.
    Lcd_Cmd(_LCD_CURSOR_OFF);     //Desliga cursor.
    Lcd_Out(1, 4, "FREQUENCIA:"); // Escreve "FREQUENCIA:"
    Lcd_Out(2, 10, " Hz");        // Escreve " Hz"
    
    while(1){
        IntToStr(frequencia, freq); // Transforma o valor que está em frequencia para string e coloca no vetor
        Lcd_Out(2, 4, freq);        // Escreve a frequencia.
    }
}

void interrupt(){

     if (TMR2IF == 1){ //Verifica se teve interrupção no Timer2
         TMPH = TMR1H; //Armazena valor do TMR1High no TMPH
         TMPL = TMR1L; //Armazena valor do TMR1Low no TMPL
         if (TMPH - TMPL != 0){ //Se a diferença de TMRH - TMRL for diferente de 0
            TMPH = TMR1H; //Armazena valor do TMR1High no TMPH
            TMPL = TMR1L; //Armazena valor do TMR1Low no TMPL
         }
         PIR1.B1 = 0; //Clear na Flag do TMR2
         TMR2 = 0; //Reinicia o TMR2 para nova verificação
         if(ATRASO != 0){
             ATRASO --; //Decrementa ATRASO e salta se for 0, para atrasar.
             return;
         }else{
             ATRASO = 8; //Reinicia o auxiliar de tempo
             //512 ms = 1 || 1024 ms = 2 || 2048 ms = 3 ...
             PORTA = TMR1H; //Transfere o valor para o PORTA
             if(TMR1H == 1){ //Testa 01
                 frequencia = 1000;
             }else if(TMR1H == 2){ //Testa 02
                 frequencia = 2000;
             }else if(TMR1H == 3){ //Testa 03
                 frequencia = 3000;
             }else if(TMR1H == 4){ //Testa 04
                 frequencia = 4000;
             }else if(TMR1H == 5){ //Testa 05
                 frequencia = 5000;
             }else if(TMR1H == 6){ //Testa 06
                 frequencia = 6000;
             }else if(TMR1H == 7){ //Testa 07
                 frequencia = 7000;
             }else if(TMR1H == 8){ //Testa 08
                 frequencia = 8000;
             }else if(TMR1H == 9){ //Testa 09
                 frequencia = 9000;
             }
             T1CON.B0 = 0; //Desliga o TMR1
             TMR1L = 0; //Move o valor 0 para o TMR1L
             TMR1H = 0; //Move o valor 0 para o TMR1H
             T1CON.B0 = 1; //Liga o TMR1
         }
     }
}