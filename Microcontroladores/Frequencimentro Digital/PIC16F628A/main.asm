#include "p16f628a.inc"

 __CONFIG _FOSC_HS & _WDTE_OFF & _PWRTE_ON & _CP_ON
 
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    PAGINAÇÃO DE MEMÓRIA                         *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;DEFINIÇÃO DE COMANDOS DE USUÁRIO PARA ALTERAÇÃO DA PÁGINA DE MEMÓRIA

#DEFINE	BANK0	BCF STATUS,RP0	
#DEFINE	BANK1	BSF STATUS,RP0	 
 
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         VARIÁVEIS                               *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	 CBLOCK 0x20			
	    W_TEMP			
	    STATUS_TEMP
	    TMPH
	    TMPL
	    ATRASO
	 ENDC

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       VETOR DE RESET                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	ORG		0x0 
	GOTO	INICIO
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    INÍCIO DA INTERRUPÇÃO                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
	ORG	0x04
	MOVWF	W_TEMP
	SWAPF	STATUS,W
	MOVWF	STATUS_TEMP
	
	BTFSC	PIR1,TMR2IF 	; Verifica se teve interrupção no Timer2
	GOTO	ASYNC		; Se sim, interrupção no TMR2
	GOTO	INT_FIM		; Se nâo, final da Interrupção
	
ASYNC
;--------------------LEITURA/ESCRITA PARA CLOCK EXTERNO ASSÍNCRONO-------------------;

	MOVF	TMR1H, W		;Armazena valor do TMR1High no W
	MOVWF	TMPH			;Guarda W no TMPH
	MOVF	TMR1L, W 		;Armazena valor do TMR1Low no W
	MOVWF	TMPL			;Guarda W no TMPL
	MOVF	TMR1H, W		;Armazena valor do TMR1High no W
	SUBWF	TMPH, W			;Subtrai o valor W do TMPH e armazena em W
	BTFSC	STATUS,Z		;Verifica se o resultado é zero
	GOTO	ATRASA_TMR2		;Se sim, redireciona para Vereficaçâo
	
;--------------Caso ao contrário, repete o armazenamento nos auxiliares--------------;

	MOVF	TMR1H, W 		
	MOVWF	TMPH
	MOVF	TMR1L, W
	MOVWF	TMPL		
		
ATRASA_TMR2
	
	BCF	PIR1, TMR2IF	;Clear na Flag do TMR2	
	MOVLW	.0		;Reinicia o TMR2 para nova verificação
	MOVWF	TMR2		
		
	DECFSZ	ATRASO		;Decrementa ATRASO e salta se for 0, para atrasar. 
	GOTO	INT_FIM
	
;--------Caso terminar o ATRASO ele verfica qual é o bit correspondente à Frequencia---------;	
	
	; Exemplo para 1000 Hz, Digito 01:
	
	; Contagem no TMR1 com 1000Hz
	; Cada acrescimo de bit é um ciclo de aproximandamente 0,001 s
	
	; Janela do TMR2 é igual a 512ms
	; Total da contagem vai ser = 0,512 / 0,001 = 512
	
	; COUNT aproximadamente de D'512' B'10 00000000' 
	; TMR1H B'00000010'
	; TMR1L B'00000000'
	
	MOVLW	.16 		;Reinicia o auxiliar de tempo.
	MOVWF	ATRASO		
		
	RRF	TMPH		;Rotaciona o ultimo valor para a direita
	MOVLW	B'01111111'
	ANDWF	TMPH		;Porta AND com os bits do TMPH e B'00111111'
		
	
	MOVF	TMPH, W		; B'00000001' -> TMPH de 1024Hz
	MOVWF	PORTA		;Transfere o valor para o PORTA
	
	BCF	T1CON, TMR1ON	;Desliga o TMR1
	MOVLW	.0	
	MOVWF	TMR1L		;Move o valor 0 para o TMR1
	MOVWF	TMR1H
	
	BSF	T1CON, TMR1ON	;Liga o TMR1
	
;----------Checa se o RB0 está set-------------;
	
	BTFSS	PORTB, 0
	GOTO 	LED_ACENDE	;Se sim, pula a instruçâo.
	GOTO 	LED_APAGA
	
LED_ACENDE
	BSF	PORTB, 0	;Set no RB0
	GOTO	INT_FIM
	
LED_APAGA
	BCF	PORTB, 0	;Clear no RB0
	
INT_FIM
	SWAPF	STATUS_TEMP,W
	MOVWF	STATUS
	SWAPF	W_TEMP,F
	SWAPF	W_TEMP,W
	
	RETFIE
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

INICIO
	BANK1
	MOVLW	B'00000000'	;Todas os RAs como saída
	MOVWF	TRISA
      
	MOVLW	B'01000000'	;RB6 como entrada do clock externo do TMR1
	MOVWF	TRISB
		
	MOVLW	B'00000000'
	MOVWF	OPTION_REG
		
	MOVLW	B'11000000'	;Interrupções Globais e Periféricas habilitadas
	MOVWF	INTCON
	
	MOVLW	B'00000010'	;Interrupçâo por TMR2 habilitada
	MOVWF	PIE1
	
	MOVLW	B'11111010'	; 250 ms
	MOVWF	PR2
		
	BANK0
	
	MOVLW	.0		; Zera o TMR2
	MOVWF	TMR2

	MOVLW	.0
	MOVWF	TMR1L		; Zera o TMR1 LOW
	MOVWF	TMR1H		; Zera o TMR1 HIGH
	
	MOVLW	.16
	MOVWF	ATRASO		; Atraso set como 16 em Decimal
	
	MOVLW	B'00000111' 	; Async, Clock externo, TMR1 ENABLE.
	MOVWF	T1CON
      
      	MOVLW	B'01111111' 	; 1:16 Postscaler e 1:16 Preescaler 
	MOVWF	T2CON
	
	BCF	PORTB, 0	; Clear no RB0
	
MAIN
	GOTO	MAIN		; Loop do programa

	END