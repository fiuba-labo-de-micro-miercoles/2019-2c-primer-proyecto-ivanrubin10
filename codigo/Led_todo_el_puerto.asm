.include "m328pdef.inc"

.cseg ;A partir de aquí hay código.
.org 0x0000	;Voy a la posición de memoria 0x0000 (Donde se encuentra RESET).
			jmp		main	;Sobre-escribo RESET con un salto a main.

.org INT_VECTORS_SIZE ;Salteo la memoria reservada para periféricos.
main:
			
; Conecto LED en el pin 8, 9, 10, 11, 12 o 13 de ARDUINO UNO.
; Configuro puerto B.
			ldi		r19,0xff	;Cargo un registro con unos para prender el LED en cada ciclo.
			ldi		r16,0xff	;(PORTB como salida).
			out		DDRB,r16

; Rutina de encendido y apagado.
		
prendo:		out		PORTB,r19	; Se enciende el LED.
								; Poniendo un 1 lógio (Que se traduce a 5 Volts) en todo el puerto B (pins 8 a 13 ded ARDUINO).

demora1:
			ldi 	r16,0x00
			ldi 	r17,0x00
			ldi		r18,0x00	;Se setean los registros en cero.
ciclo1:		inc		r16			;Se incrementa uno de ellos.
			cpi		r16,0xff	;Se lo compara con el valor 0xff (255 en decimal).
			brlo	ciclo1		;Si la comparación es verdadera, vuelve a realizar el ciclo.
			ldi		r16,0x00	;Si es falsa, setea el registro incrementado a 0x00 y realiza el ciclo1
			inc		r17			;varias veces hasta que se cumpla la siguiente condición y asi.
			cpi		r17,0xff
			brlo	ciclo1
			ldi		r17,0x00
			inc		r18
			cpi		r18,0x30
			brlo	ciclo1
			
			
			out		PORTB,r16		; Se apaga el LED.

demora2:
			ldi 	r16,0x00	;Se realiza otro delay con la lógica anterior
			ldi 	r17,0x00
			ldi		r18,0x00
ciclo2:		inc		r16
			cpi		r16,0xff
			brlo	ciclo2
			ldi		r16,0x00
			inc		r17
			cpi		r17,0xff
			brlo	ciclo2
			ldi		r17,0x00
			inc		r18
			cpi		r18,0x30
			brlo	ciclo2

			RJMP	prendo		; Se reinicia el ciclo.

