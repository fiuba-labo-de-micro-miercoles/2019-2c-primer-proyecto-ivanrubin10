/*
 *
	Trabajo Práctico Obligatorio 8
	Autor: Ivan Eric Rubin
 *
 */
.include "m328pdef.inc"

.def dummyr=R16
.def char=R17
.def LED_number=R18
.def LED_pos=R19

.equ MSG_END='\0'

.cseg 

.org 0x0000
	jmp		configuracion

.org INT_VECTORS_SIZE

configuracion:
	; Inicializo el Stack Pointer.
	ldi		dummyr, HIGH(RAMEND)
	out		SPH, dummyr
	ldi		dummyr, LOW(RAMEND)
	out		SPL, dummyr

	; Puerto B como salida.
	ldi		dummyr, 0xFF
	out		DDRB, dummyr

	; Puerto D como salida salvo el pin 0.
	ldi		dummyr, 0xFE
	out		DDRD, dummyr

	; Configuro el BAUD RATE en 9600 bps.
	ldi		dummyr, 0x00
	sts		UBRR0H, dummyr 
	ldi		dummyr, 103
	sts		UBRR0L, dummyr 

	; Habilito recepcion y emisión de datos.
	ldi		dummyr, (1<<RXEN0) | (1<<TXEN0) 
	sts		UCSR0B, dummyr

	; 8 bits de datos, sin paridad, 1 bit de stop (8N1).
	ldi		dummyr, (1<<UCSZ01) | (1<<UCSZ00)
	sts		UCSR0C, dummyr

main:
; Envio el mensaje
	; Cargo el mensaje en el registro Z.
	ldi		ZH, HIGH(INIT_MSG <<1)	
	ldi		ZL, LOW(INIT_MSG <<1)

	; Envío caracter por caracter.
	set_char:
		lpm		char, Z+
		cpi		char, MSG_END
		breq	msg_ended			; Si el caracter es '\0', terminó.

	; Mando el caracter por el puerto serie.
	send_puerto_serie:
		lds		dummyr, UCSR0A
		sbrs	dummyr, UDRE0		; Si UDRE0=1 mando el siguiente caracter.
		rjmp	send_puerto_serie
		
		sts		UDR0, char			; Envío.
		rjmp	set_char			; Cargo siguiente caracter.

	msg_ended:
		rjmp	get_data
	
; Leo datos y controlo LEDs.
	get_data:
		lds		dummyr, UCSR0A
		sbrs	dummyr, RXC0		; Si se recibio algo lo proceso.
		rjmp	get_data

		; Guardo el numero de LED recibido y lo guardo.
		lds		LED_number, UDR0

		andi	LED_number, 0x0F

		; Si el dato es 1, 2, 3 o 4 enciendo el led correspondiente
		cpi		LED_number, 1						
		breq	LED1

		cpi		LED_number, 2						
		breq	LED2

		cpi		LED_number, 3						
		breq	LED3

		cpi		LED_number, 4						
		breq	LED4

		rjmp	get_data

		LED1:
		ldi		LED_pos, (1<<PORTB0)
		rjmp	on_off

		LED2:
		ldi		LED_pos, (1<<PORTB1)
		rjmp	on_off

		LED3:
		ldi		LED_pos, (1<<PORTB2)
		rjmp	on_off

		LED4:
		ldi		LED_pos, (1<<PORTB3)
		rjmp	on_off

	; Enciendo o apago el LED correspondiente
	on_off:
		in		dummyr, PORTB
		eor		dummyr, LED_pos
		out		PORTB, dummyr
		rjmp	get_data

INIT_MSG:	
	.db "*** Hola Labo de Micro ***", '\n','\n',"Escriba 1, 2, 3 o 4 para controlar los LEDs", '\0'