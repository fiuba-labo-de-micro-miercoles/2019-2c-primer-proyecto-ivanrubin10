/*
 *
	Trabajo Práctico Obligatorio 4
	Autor: Ivan Eric Rubin
 *
 */ 
 .include "m328pdef.inc"

.def dummyr = R16
.def count = R17
.def delay_reg1 = R18
.def delay_reg2 = R19
.def delay_reg3 = R20

.equ pinLED_0 = 0
.equ pinLED_1 = 1

; Código en memoria Flash
.cseg
.org 0x0000
	jmp config_puertos

.org INT0addr
	jmp	hay_int0

.org INT_VECTORS_SIZE

config_puertos:

	ldi	dummyr, HIGH(RAMEND)
	out	SPH, dummyr
	ldi	dummyr, LOW(RAMEND)
	out	SPL, dummyr

	ldi dummyr, 0xFF				; Declaro al puerto D como entrada
	out DDRD, dummyr
	ldi dummyr, 0x00				; Cargo 0x04 si quiero activar la resistencia de pullup
	out PORTD, dummyr

	ldi	dummyr, 0x00				; Declaro al puerto B como salida
	out	DDRB, dummyr
	ldi	dummyr, 0x01				; Arranca encendido el LED_0
	out	PORTB, dummyr

	; Configuro las interrupciones por flanco descendente
	ldi	dummyr, (1 << ISC01)			
	sts	EICRA, dummyr
	ldi	dummyr, (1 << INT0)					
	out	EIMSK, dummyr				; Habilito IE0

	sei								; Habilito las interrupciones globales

main:
	rjmp main


hay_int0:
	ldi count, 5
	cbi PORTB, pinLED_0

blink:
	sbi PORTB, pinLED_1
	rcall delay						; Retardo de 0,5 segundos
	cbi PORTB, pinLED_1
	rcall delay						; Retardo de 0,5 segundos
	dec count
	brne blink

	sbi PORTB, pinLED_0
	reti



delay:
		ldi delay_reg1, 32
	
loop1:	ldi delay_reg2, 250
loop2:	ldi delay_reg3, 250
loop3:	nop							; 4 Ciclos (250 nS)

		dec delay_reg3				; 250 nS x 250 = 62.5 uS
		brne loop3
		dec delay_reg2				; 62.5 uS x 250 = 15.625 mS
		brne loop2
		dec delay_reg1				; 15.625 mS x 32 = 0.5 S
		brne loop1

		ret

