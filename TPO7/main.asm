/*
 *
	Trabajo Práctico Obligatorio 7
	Autor: Ivan Eric Rubin
 *
 */
.include "m328pdef.inc"

.def dummyr=R16
.def brillo=R17

.equ step=51	; con 51 tengo 5 niveles de brillo (5x51=255)

.cseg 

.org 0x0000
	rjmp	config

.org INT0addr
	rjmp	disminuyo
.org INT1addr
	rjmp	aumento

.org INT_VECTORS_SIZE

config:
	; Inicializo el Stack Pointer.
	ldi		dummyr, HIGH(RAMEND)
	out		SPH, dummyr
	ldi		dummyr, LOW(RAMEND)
	out		SPL, dummyr

	; Puerto B como salida.
	ldi		dummyr, 0xFF
	out		DDRB, dummyr

	;Puerto D como entrada.
	ldi		dummyr, 0x00
	out		DDRD, dummyr

	; Configuro timer en el modo PWM rápido (8 bits).
	ldi		dummyr, ( 1<<CS10 | 1<<WGM12)
	sts		TCCR1B, dummyr
	ldi		dummyr, ( 1<<COM1A1 |1<<WGM10)
	sts		TCCR1A, dummyr

	; Configuro las interrupciones por flanco ascendente.
	ldi		dummyr,(1 << ISC11 | 0 << ISC10 | 1 << ISC01 | 0 << ISC00  )
	sts		EICRA,dummyr				 
	ldi		dummyr,(1 << INT0 | 1 <<INT1) 
	out		EIMSK, dummyr

	; Habilito  las  interrupciones  globales.
	sei

	; Inicializo el brillo en 0.
	ldi		brillo, 0x00

main:
	rjmp	main

; Rutina de interrupcion de aumento de PWM.
aumento:
	cpi		brillo, 0xFF
	breq	limite				; Si se llega al límite superior, termina.
	ldi		dummyr, step
	add		brillo, dummyr		; Aumenta el brillo 'step' veces.
	sts		OCR1AL, brillo		; Modifico el ancho de pulso.
	reti

; Rutina de interrupción de disminución de PWM.
disminuyo:
	cpi		brillo, 0x00
	breq	limite				; Si se llega al límite inferior, termina.
	subi	brillo, step		; Disminuye el brillo 'step' veces.
	sts		OCR1AL, brillo		; Modifico el ancho de pulso.
	reti

limite:
	reti