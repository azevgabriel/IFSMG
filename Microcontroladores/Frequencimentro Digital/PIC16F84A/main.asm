#include "p16f84a.inc"

__CONFIG _CP_ON & _PWRTE_ON & _WDT_OFF & _HS_OSC

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    PAGINA��O DE MEM�RIA                         *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;DEFINI��O DE COMANDOS DE USU�RIO PARA ALTERA��O DA P�GINA DE MEM�RIA

#DEFINE	BANK0	BCF STATUS,RP0	
#DEFINE	BANK1	BSF STATUS,RP0	

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         VARI�VEIS                               *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DOS NOMES E ENDERE�OS DE TODAS AS VARI�VEIS UTILIZADAS 
; PELO SISTEMA

	CBLOCK	0x20	
					
		CONTADOR	;ARMAZENA O VALOR DA CONTAGEM
		COUNT		;ARMAZENA O VALOR DA CONTAGEM
		COUNT2		;ARMAZENA O VALOR DA CONTAGEM
		UP_DOWN		;ARMAZENA AS FLAGS DE CONTROLE
		LIG_DSLG	;ARMAZENA AS FLAGS DO LED
		HIGH_LOW	;ARMEZENA AS FLAGS DA ONDA_QUADRADA
		FILTRO		;FILTRAGEM PARA O BOT�O
		STATUS_TEMP	;AUXILIARES PARA RECUPERAR CONTEXTO
		W_TEMP		;AUXILIARES PARA RECUPERAR CONTEXTO	

	ENDC			;FIM DO BLOCO DE MEM�RIA		

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                        FLAGS INTERNOS                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

#DEFINE	CONTROLE	UP_DOWN,0	;Define a variavel para o Flag
#DEFINE LED		LIG_DSLG,0	;Define a variavel para o Flag		
#DEFINE ONDA		HIGH_LOW,0	;Define a variavel para o Flag							
							
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         CONSTANTES                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

MIN			EQU	.1	;Define constante valendo 1	
MAX			EQU	.9	;Define constante valendo 9	
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           ENTRADAS                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

#DEFINE	BOTAO	PORTB,1		;Define registro para a Entrada do bit 1 do PORTB	
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       VETOR DE RESET                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	ORG	0x00		; Endere�o de processamentp
	GOTO	INICIO		; Vai para o endere�o: INICIO 
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    IN�CIO DA INTERRUP��O                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	ORG	0x04		; Endere�o da interrup��o
	MOVWF 	W_TEMP		; Atribui W para W_TEMP	<1 Cycle>
	SWAPF	STATUS,W	; Troca os nibbles de STATUS e armazena em W <1 Cycle>
	MOVWF	STATUS_TEMP	; Atribui STATUS para STATUS_TEMP <1 Cycle>
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                   TRATAMENTO DA INTERRUP��O                     *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	BTFSS   INTCON,INTF	; Pula proxima instru��o caso FLAG 
				; da Interrup��o RB0/INT estiver SET(1) <1(2) Cycles>
	GOTO	ONDA_TROCA	; Vai para o endere�o: ONDA_TROCA <2 Cycles>
	
	BTFSC   INTCON,INTF	; Pula proxima instru��o caso FLAG 
				; da Interrup��o RB0/INT estiver CLEAN(2) <1(2) Cycles> 	
	GOTO	LED_TROCA	; Vai para o endere�o: LED_TROCA

ONDA_TROCA	
	BTFSS	ONDA		;Pula proxima instru��o caso ONDA estiver SET(1) <1(2) Cycle>
	GOTO 	ONDA_HIGH	;Vai para o endere�o: ONDA_HIGH <2 Cycle>
	GOTO 	ONDA_LOW	;Vai para o endere�o: ONDA_LOW

ONDA_HIGH
	BSF	ONDA		;Configura a FLAG HIGH_LOW para 1. <1 Cycle>
	BSF	PORTB,6		;Configura o bit 6 do PORTB como alto. <1 Cycle>
	GOTO	TESTA_1		;Vai para o endere�o: TESTA_01

ONDA_LOW
	BCF	ONDA		;Configura a FLAG HIGH_LOW para 0.
	BCF	PORTB,6		;Configura o bit 7 do PORTB como baixo.
	GOTO	TESTA_1		;Vai para o endere�o: TESTA_01
	
	
LED_TROCA
	BTFSS	LED		;Pula proxima instru��o caso LED estiver SET(1)
	GOTO 	LED_ACENDE	;Vai para o endere�o: LED_ACENDE
	GOTO 	LED_APAGA	;Vai para o endere�o: LED_APAGA
	
LED_ACENDE
	BSF	LED		;Configura a FLAG LIG_DSLG para 1.
	BSF	PORTB,7		;Configura o bit 7 do PORTB como alto.
	BCF	INTCON,INTF	;Clear na flag da interrup��o do RB0/INT
	GOTO 	FIM_INT		;Vai para o endere�o: FIM_INT	

LED_APAGA
	BCF	LED		;Configura a FLAG LIG_DSLG para 0.
	BCF	PORTB,7;	;Configura o bit 7 do PORTB como baixo.
	BCF	INTCON,INTF	;Clear na flag da interrup��o do RB0/INT
	GOTO 	FIM_INT		;Vai para o endere�o: FIM_INT

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                  TRATA O OVERFLOW DO TMR0                       *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
TESTA_1
	MOVF   	CONTADOR,W	;Passa o conteudo do CONTADOR para o W
	MOVWF 	COUNT		;Passa o conteudo do W para o COUNT, 
				;desta maneira n�o influenciamos o CONTADOR de sua rotina principal
	DECFSZ 	COUNT,W		;Desconta -1 do COUNT, se for DIFERENTE de ZERO pula a proxima instru��o	
	GOTO	TESTA_2		;Vai para o endere�o: TESTA_2
	MOVLW 	D'153'		;Passa um valor decimal de 153 para W
	MOVWF	COUNT2		;Passa o conteudo do W para o COUNT, 
	MOVLW 	D'0'		;Passa um valor decimal de 0 para W
	GOTO	ATRASO		;Vai para o endere�o: ATRASO
	
ATRASO
	DECFSZ	COUNT2, F	;Desconta -1 do COUNT2, se for DIFERENTE de ZERO pula a proxima instru��o
	GOTO	ATRASO		;Vai para o endere�o: ATRASO
	GOTO 	INI_TMR		;Vai para o endere�o: INI_TMR

	
TESTA_2
	MOVWF 	COUNT		;Passa o conteudo do W para o COUNT
	DECFSZ 	COUNT,W		;Desconta -1 do COUNT, se for DIFERENTE de ZERO pula a proxima instru��o
	GOTO 	TESTA_3		;Vai para o endere�o: TESTA_3
	MOVLW 	D'22'		;Passa um valor decimal de 22 para W
	GOTO 	INI_TMR		;Vai para o endere�o: INI_TMR
	
TESTA_3
	MOVWF 	COUNT		;Passa o conteudo do W para o COUNT
	DECFSZ	COUNT,W		;Desconta -1 do COUNT, se for DIFERENTE de ZERO pula a proxima instru��o
	GOTO 	TESTA_4		;Vai para o endere�o: TESTA_4
	MOVLW 	D'107'		;Passa um valor decimal de 107 para W
	GOTO 	INI_TMR		;Vai para o endere�o: INI_TMR
	
TESTA_4
	MOVWF 	COUNT		;Passa o conteudo do W para o COUNT
	DECFSZ 	COUNT,W		;Desconta -1 do COUNT, se for DIFERENTE de ZERO pula a proxima instru��o
	GOTO 	TESTA_5		;Vai para o endere�o: TESTA_5
	MOVLW 	D'151'		;Passa um valor decimal de 151 para W
	GOTO 	INI_TMR		;Vai para o endere�o: INI_TMR
	
TESTA_5
	MOVWF 	COUNT		;Passa o conteudo do W para o COUNT
	DECFSZ	COUNT,W		;Desconta -1 do COUNT, se for DIFERENTE de ZERO pula a proxima instru��o
	GOTO	TESTA_6		;Vai para o endere�o: TESTA_6
	MOVLW   D'178'		;Passa um valor decimal de 178 para W
	GOTO 	INI_TMR		;Vai para o endere�o: INI_TMR
	
TESTA_6
	MOVWF 	COUNT		;Passa o conteudo do W para o COUNT
	DECFSZ 	COUNT,W		;Desconta -1 do COUNT, se for DIFERENTE de ZERO pula a proxima instru��o
	GOTO 	TESTA_7		;Vai para o endere�o: TESTA_7
	MOVLW 	D'196'		;Passa um valor decimal de 196 para W
	GOTO 	INI_TMR		;Vai para o endere�o: INI_TMR
	
TESTA_7
	MOVWF 	COUNT		;Passa o conteudo do W para o COUNT
	DECFSZ  COUNT,W		;Desconta -1 do COUNT, se for DIFERENTE de ZERO pula a proxima instru��o
	GOTO 	TESTA_8		;Vai para o endere�o: TESTA_8
	MOVLW 	D'210'		;Passa um valor decimal de 210 para W
	GOTO 	INI_TMR		;Vai para o endere�o: INI_TMR
	
TESTA_8
	MOVWF 	COUNT		;Passa o conteudo do W para o COUNT
	DECFSZ  COUNT,W		;Desconta -1 do COUNT, se for DIFERENTE de ZERO pula a proxima instru��o
	GOTO 	TESTA_9		;Vai para o endere�o: TESTA_9
	MOVLW 	D'221'		;Passa um valor decimal de 221 para W
	GOTO 	INI_TMR		;Vai para o endere�o: INI_TMR
	
TESTA_9
	MOVLW 	D'228'		;Passa um valor decimal de 228 para W

	
INI_TMR
	MOVWF	TMR0		;Passa o conteudo do W para o TMR0
	BCF	INTCON,T0IF	;Clear na flag da interrup��o do TMR0 <1 Cycle>
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                   FINAL DA INTERRUP��O                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *	

FIM_INT
			
	SWAPF	STATUS_TEMP,W	;Atribui STATUS_TEMP para W
	MOVWF	STATUS		;Atribui W para STATUS_TEMP
	SWAPF	W_TEMP,F	;Troca os nibbles de W_TEMP e armazena em F
	SWAPF	W_TEMP,W	;Troca os nibbles de W_TEMP e armazena em W
	RETFIE			;Final da Interrup��o
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
	BANK1				
	MOVLW	B'00000000'	; Est� configurando todos os pinos de TRISA como sa�da.
	MOVWF	TRISA		
						
	MOVLW	B'00000011'	; Est� configurando o pino RB1 e RB0/INT como entrada, e o restante dos pinos como saida.
	MOVWF	TRISB		

	MOVLW	B'00000000'	; Est� habilitando os resistores pull-ups. 
	MOVWF	OPTION_REG     	; Prescaler funcionando para o TMR0/Prescaler de 1:2
										
	MOVLW	B'10110000'	;Interrup��es habilitadas: TMR0 OVERFLOW and EXTERNA RB0/INT
	MOVWF	INTCON		
	BANK0
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZA��O DAS VARI�VEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	
	
	MOVLW	MIN		;Atribuindo Min ara W
	MOVWF	CONTADOR	;Atribuindo W para Contador
	
	BCF	CONTROLE	;Atribui Clear para o Controle
	
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

MAIN
	MOVF	CONTADOR,W	;Atribui o valor do contador para W	
	MOVWF	PORTA		;Atribui o valor de W para o PORTA						
	MOVWF	FILTRO		;Atribui o valor de W para o FILTRO

CHECA_BT
	BTFSC	BOTAO		;Se o bot�o estiver SET(1) executa a proxima instru��o
	GOTO	MAIN		;Redireciona parao Main
	DECFSZ	FILTRO,F	;		
	GOTO	CHECA_BT
					
TRATA_BT
	BTFSS	CONTROLE	
	GOTO	SOMA
	    					
SUBTRAI
	DECF	CONTADOR,F
	MOVLW	MIN	
	SUBWF	CONTADOR,W	
	BTFSC	STATUS,Z	
	BCF	CONTROLE		
	GOTO	ATUALIZA	
	
SOMA
	INCF	CONTADOR,F
	MOVLW	MAX		
	SUBWF	CONTADOR,W	
	BTFSC	STATUS,Z	
	BSF	CONTROLE	

ATUALIZA
	MOVF	CONTADOR,W		
	MOVWF	PORTA					
	BTFSS	BOTAO		
	GOTO	$-1		
	GOTO	MAIN
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END	