-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------



Manan Mohammad Ali  817205
Stranieri Francesco 816551

-------------------------------------------------------------------------------

JSON_PARSE

Il predicato json_parse converte, grazie ad atom_codes, la JSONString presa
in input in una lista di codici numerici che vengono passati a
is_object/is_array. Infine effettuo un controllo (opzionale) con More per
verificare di avere solo WhiteSpaces dopo l'object/l'array.

-------------------------------------------------------------------------------

IS_OBJECT

Caso Base:	controlliamo se la lista di codici numerici e` composta solo
            da una parentesi graffa sinistra (is_leftCB) e una parentesi
            graffa destra (is_rightCB) in tal caso l`Object e`
            json_obj([]).

Caso Ricorsivo: 
			controlliamo se la lista di codici numerici inizia con una
            parentesi graffa sinistra (is_leftCB) e, in tal caso,
            controlliamo se quello che segue e` un Member
            (is_member) seguito da una parentesi graffa
	        destra (is_rightCB).

-------------------------------------------------------------------------------

IS_MEMBER/3

Caso D'Ingresso: richiamo is_member settando Done con [].


IS_MEMBER/4

Primo Caso:     controllo ricorsivamente se il Member e` composto
                da un Pair (is_pair), una virgola e altri Member (is_member).
		
Secondo Caso:   controllo se il Member e` un Pair (is_pair) e grazie
                all`append ottengo in Done i valori dei TmpDone
                precedenti (ottenuti grazie alla ricorsione) concatenati
                con il TmpObject attuale. A questo punto l`Object e` Done.

-------------------------------------------------------------------------------

IS_PAIR

Primo Caso:   	controllo se il Pair e` composto da una Stringa tra
              	doppi apici (is_stringDQ) seguita da due punti (is_colon) e
              	un valore (is_value). L`Object a questo punto e` l`Object_1
              	ottenuto dal predicato is_stringDQ, la virgola e
              	l`Object_2 ottenuto dal predicato (is_value).

Secondo Caso:   controllo se il Pair e` composto da una Stringa tra
	      		singoli apici (is_stringSQ) seguita da due punti (is_colon) e 
	      		un valore (is_value). L`Object a questo punto e` l`Object _1 
	      		ottenuto dal predicato is_stringSQ, la virgola e 
	      		l`Object_2 ottenuto dal predicato (is_value).

-------------------------------------------------------------------------------

IS_ARRAY

Caso Base:	controlliamo se la lista di codici numerici e` composta solo da
           	una parentesi quadra sinistra (is_leftSB) e una una parentesi
	   		quadra destra (is_rightSB). In tal caso l’Object e`
	  		json_array([]).

Caso Ricorsivo: 
			controlliamo se la lista di codici numerici inizia con una
	        parentesi quadra sinistra (is_leftSB) e in tal  caso
			controlliamo se quello che segue e` un Element (is_element)
			seguito da una parentesi quadra destra (is_rightSB).

-------------------------------------------------------------------------------

IS_ELEMENT/3

Caso D'Ingresso: richiamo is_element/4 settando Done con []

IS_ELEMENT/4

Primo Caso: 	controlliamo ricorsivamente se l`Element e` composta da un
	    		Value (is_value) una virgola (is_comma) 
				e altri Element (is_element).

Secondo Caso: 	controlliamo se l`Element e` un Value (is_value) seguito
	       		da qualcosa che non e` una virgola ((not (is_comma))
              	e che viene assegnato a MoreElement (e che in caso di
	      		successo sara` una parentesi quadra destra seguita
	      		eventualmente da WhiteSpaces) e grazie all`append
	      		ottengo in Done i valori dei TmpDone precedenti
              	(ottenuti grazie alla ricorsione) concatenati con il
	      		TmpObject attuale. A questo punto l`Object e` Done.

-------------------------------------------------------------------------------

IS_VALUE

Controlliamo se il Value e` una stringa fra doppi apici (is_stringDQ,
una stringa fra singoli apici (is_stringSQ), un numero (is_number),
un Object (is_object) o un Array (is_array).

-------------------------------------------------------------------------------

IS_NUMBER/3

Caso d'Ingresso:
		1) Se la testa del number e` un Digit (is_digit) controlliamo
		   ricorsivamente se la coda e` un number (is_number/4).
		2) Se la testa del number e`un '+' o '-' (is_signum)
		   controllo ricorsivamente se la coda e` un number
		   (is_number/4).


IS_NUMBER/4

Se la testa e` un Digit (is_digit) controllo ricorsivamente se la coda e`
un Number (is_number).
Altrimenti se la testa e` un punto (is_dot) seguita da qualcosa e preceduta da
un digit (is_digit (Last)) allora controllo ricorsivamente se cio` che segue
il punto rende il Number un Float (is_float).
Altrimenti se la testa non e` un digit (not (is_digit)) ma e` preceduta da un
digit (is_digit(last)) allora tutto cio` che precede la testa 
deve essere un Number.

-------------------------------------------------------------------------------

IS_FLOAT

Se la testa e` un Digit (is_digit) controllo ricorsivamente se la coda e` un
float (is_float).
Altrimenti se la testa non e` un digit (not (is_digit)) 
ma e` preceduta da un digit (is_digit (last)) 
allora tutto cio` che precede la testa e` un float.

-------------------------------------------------------------------------------

IS_STRING_DQ/3

Caso d`Ingresso:	se la testa della stringa e` un doppio apice (is_DQ) 
					allora controllo ricorsivamente il resto della stringa 
					(is_stringDQ/5).


IS_STRING_DQ/5

Primo Caso: 	se la testa della stringa e` un doppio apice (is_DQ) 
				allora ho finito di analizzare la Stringa 
				e trasformo i caratteri ASCII analizzati che ho in Done 
				nuovamente in una Stringa (string_codes).

Secondo Caso: 	se la testa della Stringa non e` un doppio apice (not (is_DQ))
	   			allora controllo che e` un carattere ASCII (is_ascii) e
	      		che cio` che segue il carattere sia una Stringa (is_stringDQ).

-------------------------------------------------------------------------------

IS_STRING_SQ/3

Caso d`Ingresso:	se la testa della stringa e` un singolo apice (is_SQ)
	        		allora controllo ricorsivamente il resto  della stringa 
					(is_stringSQ/5).


IS_STRINGSQ/5

Primo Caso: 	se la testa della stringa e` un singolo apice (is_SQ) 
				allora ho finito di analizzare la Stringa 
				e trasformo i caratteri ASCII analizzati che ho in Done 
				nuovamente in una Stringa (string_codes).

Secondo Caso: 	se la testa della Stringa non e` un singolo apice (not (is_SQ))
	      		allora controllo che e` un carattere ASCII (is_ascii) e
	      		che cio` che segue il carattere sia una Stringa (is_stringSQ).

-------------------------------------------------------------------------------

JSON_LOAD

Come visto al ricevimento apro un file, 
trasformo cio` che ho letto in Codes (read_file_to_codes) 
e chiamo il predicato json_parse.

-------------------------------------------------------------------------------

JSON_WRITE

Primo Caso: 	se JSON e` un object allora scrivo l`oggetto (write_object) 
				nel percorso inidicato da FileName.

Secondo Caso: 	se JSON e` un array allora scrivo l`array (write_array) 
				nel percorso indicato da FileName.

-------------------------------------------------------------------------------

WRITE_OBJECT

Scrivo l'object formato da Pair (write_pair) 
e racchiuso tra parentesi graffe (append).

-------------------------------------------------------------------------------

WRITE_ARRAY

Scrivo l`array formato da Value (write_value) 
e racchiuso tra parentesi quadre (append).

-------------------------------------------------------------------------------

WRITE_PAIR

Caso Base:	se non ho piu` Pair da scrivere 
			allora rimuovo l'ultimo elemento rappresentato da una virgola, 
			aggiunta nel caso ricorsivo.

Caso Ricorsivo: 
			trasformo la stringa in una lista di codici ASCII
			(e la re-inserisco tra apici visto che la
			trasformazione li rimuove) e a quel punto la faccio
			seguire dai due punti (che sostituiscono la virgola) 
			e scrivo il Value che segue la stringa (write_value).
			Infine, una volta avuto il Pair, lo faccio seguire da
			una virgola e richiamo ricorsivamente il predicato su
			quello che segue il Pair.

-------------------------------------------------------------------------------

WRITE_VALUE

Se il Value e` un Object, scrivo un Object (write_object).
Se e` un Array scrivo un Array (write_array).
Se e` una String allora trasformo la stringa in una lista di codici ASCII 
(e la re-inserisco tra apici visto che la trasformazione li rimuove) 
la quale rappresenta il Result.
Se e` un Number allora lo trasformo in una lista di codice ASCII 
la quale rappresentano il Result.

-------------------------------------------------------------------------------

REMOVE_LAST

Rimuove l`ultimo elemento di una lista.

-------------------------------------------------------------------------------

WRITE_STRING_TO_FILE

Permette di scrivere una stringa su di un file.

-------------------------------------------------------------------------------

JSON_GET

Caso Base:	se non ho Field da analizzare allora ho il Result finale.

Caso Speciale: 	1) Field in questo caso e` una stringa SWI Prolog quindi 
		   		   la trasformo in una lista contenente 
	           	   una stringa SWI-Prolog
	       		2) cerco i Pair (find_pair) della lista (List) 
  		   		   i quali hanno Field come campo. Successivamente richiamo
		  		   ricorsivamente la json_get per gli altri campi (MoreField).
               	3) se ho un array allora utilizzo il predicato nth0 
		   		   il quale e` true se, partendo da 0, TmpDone e` l`iesimo
	           	   elemento (Field) dell`array (List).

-------------------------------------------------------------------------------

FIND_PAIR

Primo Caso: 	se la testa della lista e` un Pair e ha Field come primo campo
            	allora il secondo campo e` il Result che stavo cercando.

Secondo Caso: 	se la testa della lista e` un Pair ma non ha Field come primo
              	campo allora cerco ricorsivamente sulla coda della lista.

-------------------------------------------------------------------------------

SKIP_WHITESPACES

Caso Base:		se la lista e` vuota non ha ovviamente WhiteSpace.

Primo Caso: 	se la testa non e` un WhiteSpace allora ho la lista senza
	    		WhiteSpace iniziali.

Secondo Caso: 	se la testa e` un WhiteSpace 
				allora controllo ricorsivamente se la coda ha WhiteSpace.


IS_WHITESPACE

Come visto a ricevimento tratto come WhiteSPace 
la spaziatua (white) or (;) l`a capo (NewLine).



-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------