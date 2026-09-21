;=========================================================
; ACTIVIDAD I - MICROPROCESADORES
; MICROPROCESADOR Z80
;=========================================================
;
; FUNCION DEL PROGRAMA:
;
; 1. Solicitar al usuario su nombre y apellidos.
; 2. Leer los caracteres introducidos por teclado.
; 3. Aceptar solamente letras mayusculas, minusculas
;    y espacios.
; 4. Mostrar un mensaje de error si se introduce
;    cualquier otro caracter.
; 5. Guardar el nombre y apellidos en memoria de datos
;    a partir de la direccion F800H.
; 6. Contar solamente las letras, sin contar espacios.
; 7. Mostrar en decimal el numero total de letras.
;
; NOTA:
; El puerto 01H se utiliza como terminal de entrada/salida
; durante la simulacion en Z80 Workbench.
;
;=========================================================


;---------------------------------------------------------
; CONSTANTES DEL SISTEMA
;---------------------------------------------------------

PUERTO_TERMINAL .EQU 01H     ; Puerto de terminal de Z80 Workbench
INICIO_RAM      .EQU 0F800H  ; Inicio de la memoria de datos


;---------------------------------------------------------
; INICIO DEL PROGRAMA
;---------------------------------------------------------

.ORG 0000H                   ; El programa comienza en 0000H


INICIO:

    LD B,00H                 ; B sera el contador de letras.
                             ; Comienza en cero.

    LD DE,INICIO_RAM         ; DE apunta a F800H.
                             ; Aqui se almacenara el nombre.

    LD HL,MENSAJE            ; HL apunta al primer caracter
                             ; del mensaje inicial.


;---------------------------------------------------------
; IMPRIMIR MENSAJE INICIAL
;---------------------------------------------------------

IMPRIMIR:

    LD A,(HL)                ; Carga en A el caracter apuntado
                             ; por HL.

    OR A                     ; Comprueba si A contiene 00H.
                             ; Si A=00H, activa la bandera Z.

    JR Z,LEER_TECLA          ; Si encontramos 00H, significa
                             ; que termino el mensaje y pasamos
                             ; a leer el teclado.

    OUT (PUERTO_TERMINAL),A  ; Envia el caracter de A a la
                             ; terminal del simulador.

    INC HL                   ; Avanza a la siguiente posicion
                             ; del mensaje.

    JR IMPRIMIR              ; Repite hasta encontrar 00H.


;---------------------------------------------------------
; LECTURA DEL TECLADO
;---------------------------------------------------------

LEER_TECLA:

    IN A,(PUERTO_TERMINAL)   ; Lee un caracter desde el teclado
                             ; de Z80 Workbench.

    OR A                     ; Comprueba si se recibio un
                             ; caracter.

    JR Z,LEER_TECLA          ; Si A=00H, todavia no hay tecla.
                             ; Continua esperando.


;---------------------------------------------------------
; COMPROBAR SI SE PRESIONO ENTER
;---------------------------------------------------------

    CP 0DH                   ; Compara el caracter con 0DH.
                             ; 0DH corresponde a ENTER.

    JR Z,FIN_ENTRADA         ; Si es ENTER, termina la captura.


;---------------------------------------------------------
; COMPROBAR SI ES UN ESPACIO
;---------------------------------------------------------

    CP 20H                   ; 20H es el codigo ASCII
                             ; correspondiente al espacio.

    JR Z,ESPACIO_VALIDO      ; El espacio esta permitido,
                             ; pero no debe contarse como letra.


;---------------------------------------------------------
; VALIDAR LETRAS MAYUSCULAS: A - Z
;---------------------------------------------------------

    CP 'A'                   ; Compara el caracter con 'A'.

    JR C,ERROR               ; Si es menor que 'A', entonces
                             ; no es una letra valida.

    CP 'Z'+1                 ; Compara con el valor siguiente
                             ; a la letra 'Z'.

    JR C,CARACTER_VALIDO     ; Si es menor que 'Z'+1, entonces
                             ; esta entre A y Z.


;---------------------------------------------------------
; VALIDAR LETRAS MINUSCULAS: a - z
;---------------------------------------------------------

    CP 'a'                   ; Compara el caracter con 'a'.

    JR C,ERROR               ; Si esta entre 'Z' y 'a',
                             ; no corresponde a una letra.

    CP 'z'+1                 ; Compara con el valor siguiente
                             ; a la letra 'z'.

    JR NC,ERROR              ; Si es igual o mayor que 'z'+1,
                             ; el caracter no es valido.


;---------------------------------------------------------
; CARACTER VALIDO
;---------------------------------------------------------

CARACTER_VALIDO:

    LD (DE),A                ; Guarda la letra en la memoria
                             ; de datos.

    INC DE                   ; Avanza a la siguiente direccion
                             ; de memoria.

    INC B                    ; Incrementa el contador porque
                             ; este caracter SI es una letra.

    OUT (PUERTO_TERMINAL),A  ; Muestra la letra en terminal.

    JR LEER_TECLA            ; Regresa a esperar otro caracter.


;---------------------------------------------------------
; ESPACIO VALIDO
;---------------------------------------------------------

ESPACIO_VALIDO:

    LD (DE),A                ; Guarda tambien el espacio en RAM.

    INC DE                   ; Avanza a la siguiente posicion
                             ; de memoria.

                             ; NO se incrementa B porque
                             ; el espacio no es una letra.

    OUT (PUERTO_TERMINAL),A  ; Muestra el espacio.

    JR LEER_TECLA            ; Continua leyendo caracteres.


;---------------------------------------------------------
; ERROR DE CARACTER
;---------------------------------------------------------

ERROR:

    LD HL,MENSAJE_ERROR      ; HL apunta al mensaje de error.


IMPRIMIR_ERROR:

    LD A,(HL)                ; Obtiene un caracter del mensaje.

    OR A                     ; Comprueba si llegamos al 00H
                             ; que marca el final del mensaje.

    JR Z,FIN_ERROR           ; Si termino el mensaje, finaliza
                             ; el programa.

    OUT (PUERTO_TERMINAL),A  ; Muestra el caracter.

    INC HL                   ; Avanza al siguiente caracter.

    JR IMPRIMIR_ERROR        ; Continua imprimiendo.


FIN_ERROR:

    HALT                     ; Detiene el Z80 debido al error.


;---------------------------------------------------------
; FIN DE LA CAPTURA
;---------------------------------------------------------

FIN_ENTRADA:

    XOR A                    ; A XOR A siempre produce 00H.
                             ; Por lo tanto A queda en cero.

    LD (DE),A                ; Guarda 00H despues del ultimo
                             ; caracter del nombre.
                             ; Esto marca el final de la cadena.

    LD HL,MENSAJE_TOTAL      ; HL apunta al mensaje que anuncia
                             ; el numero de letras.


;---------------------------------------------------------
; IMPRIMIR MENSAJE DEL RESULTADO
;---------------------------------------------------------

IMPRIMIR_TOTAL:

    LD A,(HL)                ; Obtiene un caracter del mensaje.

    OR A                     ; Comprueba si es el terminador 00H.

    JR Z,CONVERTIR           ; Si termino el mensaje, convierte
                             ; el contador a decimal.

    OUT (PUERTO_TERMINAL),A  ; Imprime el caracter.

    INC HL                   ; Avanza al siguiente caracter.

    JR IMPRIMIR_TOTAL        ; Continua imprimiendo.


;=========================================================
; CONVERSION DEL CONTADOR A DECIMAL
;=========================================================
;
; El contador se encuentra en B y es un valor binario.
;
; Para mostrarlo en la terminal necesitamos convertirlo
; en digitos ASCII.
;
; D = centenas
; E = decenas
; C = unidades
;
;=========================================================

CONVERTIR:

    LD A,B                   ; Copia el numero de letras
                             ; del registro B al acumulador A.

    LD D,00H                 ; D almacenara las centenas.

    LD E,00H                 ; E almacenara las decenas.


;---------------------------------------------------------
; CALCULAR CENTENAS
;---------------------------------------------------------

CENTENAS:

    CP 100                   ; Compara A con 100.

    JR C,DECENAS             ; Si A es menor que 100,
                             ; ya no hay mas centenas.

    SUB 100                  ; Resta una centena.

    INC D                    ; Incrementa el contador
                             ; de centenas.

    JR CENTENAS              ; Comprueba nuevamente.


;---------------------------------------------------------
; CALCULAR DECENAS
;---------------------------------------------------------

DECENAS:

    CP 10                    ; Compara el residuo con 10.

    JR C,UNIDADES            ; Si es menor que 10,
                             ; el residuo son las unidades.

    SUB 10                   ; Resta una decena.

    INC E                    ; Incrementa el contador
                             ; de decenas.

    JR DECENAS               ; Repite hasta quedar por
                             ; debajo de 10.


;---------------------------------------------------------
; GUARDAR UNIDADES
;---------------------------------------------------------

UNIDADES:

    LD C,A                   ; El valor restante de A
                             ; corresponde a las unidades.


;---------------------------------------------------------
; MOSTRAR CENTENAS
;---------------------------------------------------------

    LD A,D                   ; Recupera las centenas.

    OR A                     ; Comprueba si son cero.

    JR Z,SIN_CENTENAS        ; Si son cero, no imprime
                             ; un cero a la izquierda.

    ADD A,'0'                ; Convierte el numero 0-9
                             ; a su codigo ASCII.

    OUT (PUERTO_TERMINAL),A  ; Imprime la centena.


;---------------------------------------------------------
; DETERMINAR SI HAY QUE MOSTRAR DECENAS
;---------------------------------------------------------

SIN_CENTENAS:

    LD A,D                   ; Comprueba nuevamente si
                             ; existieron centenas.

    OR A

    JR NZ,MOSTRAR_DECENA     ; Si hubo centenas, la decena
                             ; debe mostrarse incluso si es 0.

    LD A,E                   ; Si no hubo centenas,
                             ; comprueba las decenas.

    OR A

    JR Z,MOSTRAR_UNIDAD      ; Si tampoco hay decenas,
                             ; muestra directamente unidades.


;---------------------------------------------------------
; MOSTRAR DECENAS
;---------------------------------------------------------

MOSTRAR_DECENA:

    LD A,E                   ; Recupera el numero de decenas.

    ADD A,'0'                ; Lo convierte a ASCII.

    OUT (PUERTO_TERMINAL),A  ; Imprime la decena.


;---------------------------------------------------------
; MOSTRAR UNIDADES
;---------------------------------------------------------

MOSTRAR_UNIDAD:

    LD A,C                   ; Recupera las unidades.

    ADD A,'0'                ; Convierte el numero a ASCII.

    OUT (PUERTO_TERMINAL),A  ; Imprime la unidad.


;---------------------------------------------------------
; FIN DEL PROGRAMA
;---------------------------------------------------------

FIN:

    HALT                     ; Detiene la ejecucion del Z80.


;=========================================================
; CADENAS DE TEXTO
;=========================================================

MENSAJE:

    .DB "INGRESE NOMBRE Y APELLIDOS: ",0
                             ; Mensaje inicial.
                             ; El 0 indica el final de cadena.


MENSAJE_ERROR:

    .DB " ERROR: CARACTER NO VALIDO",0
                             ; Mensaje mostrado cuando el
                             ; usuario introduce algo distinto
                             ; de una letra o espacio.


MENSAJE_TOTAL:

    .DB " NUMERO DE LETRAS: ",0
                             ; Mensaje mostrado antes
                             ; del resultado numerico.


;=========================================================
; FIN DEL ARCHIVO
;=========================================================

.END