/*
 *
	Trabajo Práctico Obligatorio 5
	Autor: Ivan Eric Rubin
 *
 */
 .include "m328pdef.inc"

.def dummyr=R16
.cseg
.org 0X0000
		rjmp	config

.org ADCCaddr	
		rjmp	isr_adc

.org INT_VECTORS_SIZE

config:																												
		ldi		dummyr, HIGH(RAMEND)				;Inicializo el Stack Pointer.
		out		SPH, dummyr			
		ldi		dummyr, LOW(RAMEND)							
		out		SPL, dummyr

		ldi		dummyr, 0xFF						;Defino al puerto D como salida.
		out		DDRD, dummyr	

		ldi		dummyr, 0x00						;Defino al puerto C como entrada.
		out		DDRC, dummyr						
			
					

		ldi		dummyr, 0b10101111					;Habilito el ADC (bit 7), el auto-trigger (bit 5), 
		sts		ADCSRA, dummyr						;la interrupción de conversión (bit 3) y 
													;seteo el prescaler en 128 (bits 0 a 2).

		ldi		dummyr, 0b01100000					;Defino la tensión de referencia externa a la asociada al pin AVCC,
		sts		ADMUX, dummyr						;ignoro los dos bits mas significattivos (ADLAR = 1) y
													;selecciono ADC0 como canal de entrada analógico

		sei											;Habilito las interrupciones globales	

main:
		lds		dummyr, ADCSRA							
		ori		dummyr, (1<<ADSC)
		sts		ADCSRA, dummyr						;Inicio conversión (ADSC = 1)
		
fin:	
		rjmp	fin

isr_adc:
		lds		dummyr, ADCH						;Cargo en un registro el valor de conversión total dividido por 4

		lsr		dummyr								
		lsr		dummyr								;Divido el anterior valor por 4 nuevamente para poder representarlo con 6 bits

		out		PORTD, dummyr						;Envio el resultado final al puerto D

		reti