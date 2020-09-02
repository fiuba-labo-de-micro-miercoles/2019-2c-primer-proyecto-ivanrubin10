/*
 *
	Trabajo Práctico Obligatorio 6
	Autor: Ivan Eric Rubin
 *
 */
.include "m328pdef.inc"

.def dummyr=R16

.cseg 

.org 0x0000
	rjmp	config
.org OVF1addr
	rjmp	 isr_timer
.org INT_VECTORS_SIZE

config:
; Inicializo el Stack Pointer.
	ldi		dummyr, HIGH(RAMEND)							
	out		SPH, dummyr
	ldi		dummyr, LOW(RAMEND)
	out		SPL, dummyr

; Defino PORTB como puerto de salida.
	ldi		dummyr, 0xFF
	out		DDRB, dummyr

; Defino el PORTD como puerto de entrada.
	ldi		dummyr, 0x00
	out		DDRD, dummyr

; Enciendo la interrupcion por overflow del timer.
	ldi		dummyr, (1<<TOIE1)
	sts		TIMSK1, dummyr

; Habilito las interrupciones globales
	sei

main:
	in		dummyr, PIND						;Veo el estado del puerto D
	andi	dummyr, (1 << PIND1 | 1 << PIND2)	;y guardo en un registro los valores de los pines

	rcall   set_blink							;Defino el parpadeo
	rcall	delay								;Delay para evitar efecto de rebote
	rjmp		main

; Se compara el puerto D con cada prescaler para definir la frecuencia de parpadeo
set_blink:
	cpi		dummyr, (0 << PIND1 | 0 << PIND2)
	breq	fijo						

	cpi		dummyr, (1 << PIND1 | 0 << PIND2)
	breq	clock_64
		
	cpi		dummyr, (0 << PIND1 | 1 << PIND2)
	breq	clock_256
		
	cpi		dummyr, (1 << PIND1 | 1 << PIND2)
	breq	clock_1024

	fijo: 
		ldi		dummyr, 0x00							
		sts		TCCR1B, dummyr			 ; Se frena el timer.
		sbi		PORTB, 0				    ; Se enciende el LED.
	ret
; Segun el puerto D se utiliza el prescaler adecuado
	clock_64: 
		ldi		dummyr, 0x03						
		sts		TCCR1B, dummyr
	ret

	clock_256: 
		ldi		dummyr, 0x04							
		sts		TCCR1B, dummyr	
	ret

	clock_1024: 
		ldi		dummyr, 0x05							
		sts		TCCR1B, dummyr	
	ret

; Rutina de parpadeo del LED (cuando haya overflow)
isr_timer:								
		sbis	PORTB, 0				
		rjmp	enciendo
		cbi		PORTB, 0
reti

		enciendo:
		sbi		PORTB, 0
reti

delay:			
		ldi		dummyr, 0x00							;TCNT0 en 0
		out		TCNT0, dummyr

		ldi		dummyr, (1 << CS02 | 1 << CS00)			;timer0 en modo normal
		out     TCCR0B, dummyr							;prescaler 1024.
						
delay_loop:
		in		dummyr, TIFR0							;En caso de overflow en timer0
		sbrs	dummyr, TOV0							;esquivo la siguiente instrucción
		rjmp	delay_loop

		ldi		dummyr, 0X00
		out		TCCR0B, dummyr							;Desactivo timer0
		ldi		dummyr, (1<<TOV0)
		out		TIFR0, dummyr							;Limpio el flag de overflow
		
		ret