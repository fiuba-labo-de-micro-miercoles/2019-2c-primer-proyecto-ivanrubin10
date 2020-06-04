/*
 *
	Trabajo Práctico Obligatorio 3
	Autor: Ivan Eric Rubin
 *
 */ 

.include "m328pdef.inc"

.CSEG ;A partir de aquí hay código

	JMP MAIN

.ORG INT_VECTORS_SIZE 

MAIN:
	
	LDI R17, 0xFF
	OUT DDRD, R17 ;Establezco al puerto D como puerto de salida

	LDI R16, HIGH(RAMEND) ;Inicializo el Stack Pointer
	OUT SPH, R16
	LDI R16, LOW(RAMEND)
	OUT SPL, R16


CICLO:
	LDI ZH, HIGH(SECUENCIA_LEDS << 1) ;Cargo la posición de la tabla en el registro Z
	LDI ZL, LOW((SECUENCIA_LEDS << 1) + 1)
	LPM R18, Z+ ;Cargo el contador en R18


SECUENCIA:
	LPM R17, Z+ ;Cargo los LEDs a prender (segun la tabla) en el registro R17
	OUT PORTD, R17 ;Enciendo dichos LEDs
	CALL DELAY ;Aplico una demora
	DEC R18 ;Decremento el contador
	BRNE SECUENCIA ;Si el contador llega a cero salto a Ciclo y comienza todo de nuevo

	JMP CICLO


SECUENCIA_LEDS: .DB 0,10,1,2,4,8,16,32,16,8,4,2 ;Tabla con contador y secuencia de LEDs


.ORG RAMEND

DELAY:
			LDI R20, 30
	
	CICLO1: LDI R21, 255
	CICLO2: LDI R22, 255
	CICLO3:	
			DEC R22
			BRNE CICLO3
			DEC R21
			BRNE CICLO2
			DEC R20
			BRNE CICLO1

	RET
