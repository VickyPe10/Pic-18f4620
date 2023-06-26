
; -------------------------------------------------------------------------------
; CALCULADORA 2 : resta
; Integrantes:
;			Pereyra, Victoria
; Programa:
;		Este programa simula una calculadora que resuelve una resta entre 
;		2 números de un dígito cada uno, que ingresa como un único número
;		de 8 bits por el puerto A. La parte baja de dicho número es 
;		utilizada como el minuendo y la parte alta, como el sustraendo en
;		la operación aritmética. En el caso de que alguno de los números 
;		a utilizar sea de 2 digitos, se deben encender ambos displays 
;		mostrando "- -". Si el resultado de la resta es negativo, el 
;		display derecho mostrará "-" y, si el resultado de la resta es 
;		positivo, el display derecho encenderá el segmento superior.				
; -------------------------------------------------------------------------------
    list p=18f4620, r=DEC
#include <p18f4620.inc>

; VARIABLES A UTILIZAR ----------------------------------------------------------------------------------------------------------------- 
entrada		equ 0x20    ; variable aux para probar que los numeros sean de un digito y no perder los numeros reales
entrada_1	equ 0x21    ; variable que guarda los 4 bits bajos entrantes por PORTA
entrada_2	equ 0x22    ; variable que guarda los 4 bits altos entrantes por PORTA
diferencia	equ 0x26    ; variable que guarda el resultado de la resta

;---------------------------------------------------------------------------------------------------------------------------------------
    ORG 0x0000 ;comienzo del programa
    GOTO Main
 
; CONFIGURACION DE LOS PUERTOS --------------------------------------------------------------------------------------------------------- 
Main
    MOVLW h'0F'		; Configuramos todos los pines como digitales
    MOVWF ADCON1
    
    CLRF TRISC		; configura el puerto C como salida
			; PORTC es el display de 7 segmentos izquierdo 
				
    
    CLRF TRISD		; configura el puerto D como salida
			; PORTD es el display de 7 segmentos derecho
				
    MOVLW b'11111111'	; configura los bits RA7-RA0 del puerto A
    MOVWF TRISA		; PORTA es de entrada porque tiene conectados los 8 interruptores
			; del puerto RA0-RA3 se obtiene el primer numero a restar
			; del puerto RA4-RA7 se obtiene el segundo numero a restar    

    GOTO inicio

; PROGRAMA -----------------------------------------------------------------------------------------------------------------------------
inicio
    ; cuando el interruptor esta cerrado manda un 0 y cuando esta abierto manda un 1
    ; reseteo todas las variables
    CLRF entrada
    CLRF entrada_1
    CLRF entrada_2
    CLRF diferencia
    
    MOVF PORTA,W ; muevo lo que tiene el puerto A al registro w
    GOTO leerNumeros

; etiqueta para saber si el minuendo es de un digito
leerNumeros
    MOVWF entrada_1 ;
    MOVWF entrada_2 ;
    ; leo el primer numero (minuendo) que ingresa por PORTA
    ANDLW b'00001111' ; enmascaro "quito" los bits altos del numero ingresado en el puerto A para quedarme con los bits bajos (RA0-RA3)
    MOVWF entrada_1 ; muevo lo que tiene w (en este caso los bits bajos de PORTA) a la variable entrada_1 (minuendo)
    MOVWF entrada ; muevo lo que tiene w (en este caso los bits bajos de PORTA) a la variable entrada para comprobar que el numero sea de un digito
    ;verifico que el numero de la parte baja (el minuendo) sea de un digito
    MOVLW b'00001010' ; muevo a w el numero 10 en binario
    SUBWF entrada ; le resto a entrada, w (10)
    BTFSS STATUS, C ; miro el carry del resultado de la resta y se salta una instruccion si c = 1
    GOTO otroNumero ; si c = 0 (resta negativa), el numero es menor a 10, por lo tanto tiene un digito 
    GOTO noRepresentable ; si c = 1 (resta positiva), el numero es 10 o mayor a 10 y por lo tanto, es de dos digitos = no representable

; etiqueta para saber si el sustraendo es de un digito
otroNumero
    SWAPF entrada_2,0 ; intercambio los bits de la parte baja por los bits de la parte alta y guardo el resultado en w
    ANDLW b'00001111' ; enmascaro "quito" los bits altos del numero ingresado en el puerto A para quedarme con los bits bajos (RA4-RA7)
    ; guardo el numero enmascarado en la variable entrada_2
    MOVWF entrada_2
    ;el numero invertido lo copio a la variable entrada para comprobar que sea de un digito
    MOVFF entrada_2, entrada
    ; verifico que el numero de la parte alta de PORTA (el sustraendo) sea de un digito
    MOVLW b'00001010' ; muevo a w el numero 10 en binario
    SUBWF entrada ; le resto a entrada, w (10)
    BTFSS STATUS, C ; miro el carry del resultado de la resta y se salta una instruccion si c = 1
    GOTO restar	    ; si c = 0 (resta negativa), es porque el numero es menor a 10 entonces posee un digito y puedo restar entrada_1 con entrada_2 
    GOTO noRepresentable ; si c = 1 (resta positiva), es porque el numero es igual o mayor a 10 entonces posee más de un digito y no se puede restar 

; etiqueta para restar ambos numeros 
restar 
    MOVF entrada_1,W ; 
    MOVWF diferencia ; guardo en diferencia, el valor de entrada_1 
    MOVF entrada_2,W ;
    SUBWF diferencia ; resto la parte baja del numero con la parte alta (w)
    ; se salta una instruccion si c = 1
    BTFSS STATUS, C ; miro el valor del carry --> si el resultado de la resta es positivo (c = 1) 
		    ; --> si el resultado de la resta es negativo (c = 0) salta una instruccion   
    GOTO noCarry    
    GOTO carry
    
carry ; -> resultado de la resta positivo
    BCF PORTD,6	; apago el bit 6 del puerto D
    BCF PORTC,6	; apago el bit 6 del puerto C
    BSF PORTD,0 ; enciendo el bit 6 del puerto D
    GOTO inicio
      
noCarry ; -> resultado de la resta negativo
    BCF PORTC,6 ; apago el bit 6 del puerto C
    BCF PORTD,0 ; apago el bit 0 del puerto D
    BSF PORTD,6 ; enciendo el bit 6 del puerto D
    GOTO inicio

noRepresentable  ; --> cuando alguno de los numeros a utilizar en la resta tiene más de un digito
    BCF PORTD,0  ; apago el bit 0 del puerto D 
    BSF PORTC,6  ; enciendo el bit 6 del puerto C
    BSF PORTD,6  ; enciendo el bit 6 del puerto D
    GOTO inicio  
    
; FIN ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    END 