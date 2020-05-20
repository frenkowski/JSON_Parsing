-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------



Manan Mohammad Ali  817205
Francesco Stranieri 816551

-------------------------------------------------------------------------------

JSON-PARSE

La funzione json-parse trasforma, grazie alla coerce, la JSONString presa in
input in una lista, che viene passata a skip-whitespaces dove vengono tolti
gli spazi (eccetto quelli interni alla stringa) 
e il risultato viene collegato a JSONList tramite la let.
JSONList viene passata succesivamente a is-object/is-array.

-------------------------------------------------------------------------------

IS-OBJECT

Se il primo elemento della lista e` una graffa aperta e 
il secondo elemento della lista e` una graffa chiusa 
allora l'object e` json-obj.
Altrimenti utilizziamo la macro multiple-value-bind
che valuta is-member e a result associa il member, e 
se quello che viene associato a more-object e` una parentesi graffa chiusa
allora l`object e` (json-obj result).
In caso contrario segnaliamo un errore.

-------------------------------------------------------------------------------

IS-ARRAY

Se il primo elemento della lista e` una quadra aperta e 
il secondo elemento della lista e` una quadra chiusa
allora l'object e` json-array.
Altrimenti utilizziamo la macro multiple-value-bind
che valuta is-element e a result associa l`element, e 
se quello che viene associato a more-array e` una parentesi quadra chiusa
allora l`object e` (json-array result).
In caso contrario segnaliamo un errore.

-------------------------------------------------------------------------------

IS-ELEMENT

Utilizziamo la macro multiple-value-bind
che valuta is-value e a result associa il value, e 
se la testa di quello che viene associato a more-element e` una virgola
allora riutilizziamo la macro multiple-value-bind
che valuta is-element e a result-more-element associa l`element.
L`element e` formato da result (value) e result-more-element (element).

-------------------------------------------------------------------------------

IS-MEMBER

Utilizziamo la macro multiple-value-bind 
che valuta is-pair e a result associa il value, e 
se la testa di quello che viene associato a more-member e` una virgola
allora riutilizziamo la macro multiple-value-bind 
che valuta is-member e a result-more-member associa il member.
Il member e` formato da result (pair) e result-more-member (member).

-------------------------------------------------------------------------------

IS-PAIR

Utilizziamo la macro multiple-value-bind 
che valuta is-string e a result associa la string, e 
se la testa di quello che viene associato a more-pair corrisponde ai due punti
allora riutilizziamo la macro multiple-value-bind 
che valuta is-value e a result-more-pair associa il pair.
Il pair e` formato da result (string) e result-more-pair (pair).

-------------------------------------------------------------------------------

IS-STRING

Se il primo elemento della stringa inizia con un doppio apice 
allora utilizziamo la macro multiple-value-bind  
che valuta is-any-chars-DQ e a result associa la stringa, sottoforma di lista,
che viene trasformata, grazie alla coerce, in una stringa.
Altrimenti se il primo elemento della stringa inizia con un singolo apice 
allora utilizziamo la macro multiple-value-bind  
che valuta is-any-chars-SQ e a result associa la stringa, sottoforma di lista,
che viene trasformata, grazie alla coerce, in una stringa.
In caso contrario segnaliamo un errore.

-------------------------------------------------------------------------------

IS-ANY-CHARS-DQ

Se il primo elemento  della stringa e` uguale al doppio apice (end)
allora abbiamo finito di analizzare la stringa.
Altrimenti se la testa e` un carattere ascii 
allora utilizziamo la macro multiple-value-bind 
che valuta is-any-chars-DQ e a result associa il carattere stesso
che viene concatenato con il carattere ascii precedente (car chars).
In caso contrario segnaliamo un errore.

-------------------------------------------------------------------------------

IS-ANY-CHARS-SQ

Se il primo elemento della stringa e` uguale al singolo apice (end)
allora abbiamo finito di analizzare la stringa.
Altrimenti se la testa e` un carattere ascii
allora utilizziamo la macro multiple-value-bind 
che valuta is-any-chars-SQ e a result associa il carattere stesso
che viene concatenato con il carattere ascii precedente (car chars).
In caso contrario segnaliamo un errore.

-------------------------------------------------------------------------------

IS-VALUE

Se il primo elemento e` una graffa aperta 
allora chiamiamo is-object con value,
altrimenti se e` una quadra aperta 
allora chiamiamo is-array con value,
altrimenti se e` un singolo/doppio apice 
allora chiamiamo is-string con value,
altrimenti se e` un '+' o un '-' o un numero (digit-char-p) 
allora chiamiamo is-number con value.
In caso contrario segnaliamo un errore.

-------------------------------------------------------------------------------

IS-NUMBER

Se il primo elemento e` un '+' o un '-' o un numero (digit-char-p)
allora utilizziamo la macro multiple-value-bind
che valuta is-integer e a result associa il number.
Quando abbiamo finito di analizzare il number 
lo trasformiamo in una stringa.
In caso contrario segnaliamo un errore.

-------------------------------------------------------------------------------

IS-INTEGER

Se il primo elemento e` un numero intero (digit-char-p) 
allora utilizziamo la macro multiple-value-bind 
che valuta is-integer e associa a result il numero 
che viene concatenato con il numero intero precedente (car integer).
Se il primo elemento e` un punto 
allora utilizziamo la macro multiple-value-bind 
che valuta is-float e a result associa la parte decimale del numero 
che viene concatenato con la parte non decimale del numero (car integer).

-------------------------------------------------------------------------------

IS-FLOAT

Se il primo elemento e` un numero intero (digit-char-p) 
allora utilizziamo la macro multiple-value-bind 
che valuta is-float e a result associa il numero intero 
che viene concatenato con il numero intero precedente (car float).

-------------------------------------------------------------------------------

JSON-GET

Se il primo elemento e` 'json-obj 
allora colleghiamo a field quello che viene restituito dall`assoc 
(coppia di pair) e poi chiamiamo la json-get-a 
con il secondo elemento del field e fields.
Altrimenti se il primo elemento e` 'json-array 
allora colleghiamo a field l`elemento individuato tramite nth 
e poi chiamiamo la json-get-a con field e fields.
In caso contrario segnaliamo un errore.

-------------------------------------------------------------------------------

JSON-GET-A

Applichiamo (apply) la json-get su field e il resto di fields 
cosi da ottenere il valore che stavamo cercando.

-------------------------------------------------------------------------------

JSON-LOAD

Usiamo la macro with-open-file per aprire il file 
e se non esiste segnaliamo un errore.
Con la funzione read-line leggo una riga del file che termina con la newline
e la trasformo in una stringa che passo a json-parse.

-------------------------------------------------------------------------------

JSON-WRITE

Usiamo la macro with-open-file per aprire il file 
e se non esiste lo creiamo. 
Altrimenti, se esiste, lo sovvrascriviamo.
Produciamo un output (format) trasformando quello che ritorna dal flatten
in una stringa.

-------------------------------------------------------------------------------

WRITE-OBJECT

Se il primo elemento e` 'json-obj e 
se non viene seguito da nient'altro
allora restituiamo la lista {}.
Altrimenti restituiamo la lista dove all'interno delle parentesi graffe c'e`
il pair ( { (write-pair) } ).

-------------------------------------------------------------------------------

WRITE-ARRAY

Se il primo elemento e` 'json-array e 
se non viene seguito da nient'altro 
allora restituiamo la lista [].
Altrimenti restituiamo la lista dove all'interno delle parentesi quadre c'e`
l`element ( [ (write-element) ] ).

-------------------------------------------------------------------------------

WRITE-PAIR

Se il resto di JSON e` null 
allora restituiamo la lista formata da un value,
seguito dai due punti e da un altro value.
Altrimenti restituiamo una lista formata da un value,
dai due punti e un altro value seguiti a loro volta 
da una virgola e un altro pair.

-------------------------------------------------------------------------------

WRITE-ELEMENT

Se il resto di JSON e` null 
allora restituiamo la lista formata da un value.
Altrimenti restituiamo la lista formata da un value seguito da una virgola
e da un altro element.

-------------------------------------------------------------------------------

WRITE-VALUE

Se JSON e` un numero ( numberp ) 
allora lo trasformiamo in una lista.
Se e` una stringa 
allora restituiamo la stringa sottoforma di una lista 
che inizia e termina con i doppi apici.
Se il primo elemento e` 'json-obj 
allora chiamiamo write-object con JSON.
Se il primo elemento e` 'json-array 
allora chiamiamo write-array con JSON.

-------------------------------------------------------------------------------

FLATTEN

Se x e` un atomo restituiamo la lista contenente x,
se x e` null restituiamo x, 
altrimenti concateniamo le due chiamate ricorsive 
una per il primo elemento (flatten (first x)) 
e una sul resto di x (flatten (rest x)).

-------------------------------------------------------------------------------

SKIP-WHITESPACES

Colleghiamo il primo elemento della lista a head tramite la let.
Se head è uno spazio (#\Space) o un tab (#\Tab) o un newline (#\NewLine), 
allora richiamiamo ricorsivamente skip-whitespaces con il resto della lista.
Se e` un singolo/doppio apice 
allora chiamiamo skip-not-whitespaces con il resto della lista e head.
Altrimenti concateniamo head con la chiamata ricorsiva di skip-whitespaces
ed il resto della lista.

-------------------------------------------------------------------------------

SKIP-NOT-WHITESPACES

Colleghiamo il primo elemento della lista a head tramite la let.
Se head e` uguale a end
allora concateniamo head con la chiamata skip-whitespaces 
ed il resto della lista.
Altrimenti concateniamo head con la chiamata ricorsiva di
skip-not-whitespaces ed il resto della lista ed end.



-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------