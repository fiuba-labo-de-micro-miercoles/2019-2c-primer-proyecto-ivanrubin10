/*
 *
	Trabajo Práctico Obligatorio 2
	Autor: Ivan Eric Rubin
 *
 */ 

.include "m328pdef.inc"
 /*
 	Pin del botón (B) y Pin del LED (L).
 */
.EQU B = 0	; Botón en el pin B0 (8 de Arduino)
.EQU L = 4	; LED en el pin B4 (12 de Arduino)
/*
	Puertos	
*/
.EQU PUERTO_SALIDA = PORTB
.EQU PUERTO_ENTRADA = PINB
.EQU CONF_PUERTO = DDRB

.CSEG ; A partir de aquí hay código

	JMP MAIN

.ORG INT_VECTORS_SIZE 

MAIN:
/*
	Establezco entradas y salidas en el puerto
*/
	LDI R16, 0x30			; En B5 quiero que el LED del Arduino esté apagado entonces lo voy a establecer como pin de salida
	OUT CONF_PUERTO, R16	; Seteo los pines B4 y B5 como salida y el resto de los pines como entrada
/*
	Si se detecta un flanco ascendente se enciende el LED.
*/

ALTO:
	SBIS PUERTO_ENTRADA, B 	; Si se apreta el botón saltea la siguiente instrucción.
	JMP ALTO
	SBI PUERTO_SALIDA, L	; Se enciende el LED.
/*
	Luego de encenderse el LED se espera un flanco descendente.
*/
BAJO:
	SBIC PUERTO_ENTRADA, B 	; Si se suelta el botón saltea la siguiente instrucción.
	JMP BAJO
	CBI PUERTO_SALIDA, L	; Se apaga el LED.
	JMP ALTO				; Se vuelve a la detección de flanco ascendente.
