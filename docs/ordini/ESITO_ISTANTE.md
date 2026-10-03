# ESITO: UN SOLO ISTANTE, DICHIARATO

## La causa NON era quella ipotizzata, e l'ho trovata misurando

L'Architetto ha letto "12 gradi, sud-est" e ha dedotto: **altezza della
mezzanotte, direzione dell'istante presente**, due momenti nella stessa riga.
Ho verificato prima di correggere, ed era un'altra cosa.

**IL FUSO VENIVA TOLTO DUE VOLTE.** `buildSkyFor` sottraeva `timeZoneOffset` a
mano, ottenendo un `DateTime` con i campi gia' spostati indietro ma ancora
marcato "locale"; poi `Celestial.julianDay` chiamava `toUtc()` e lo toglieva una
seconda volta. In Italia d'estate sono quattro ore invece di due.

Con due ore di troppo indietro la Bilancia stava **davvero** a dodici gradi
verso sud-est: **i due numeri erano coerenti fra loro, e sbagliati insieme.**
Non uno di un istante e uno di un altro. La coincidenza col valore della
mezzanotte, 13 contro 12,4, e' quello che ha reso l'ipotesi credibile.

La misura, per Milano, prima e dopo la correzione:

| istante | prima | dopo | calcolo indipendente |
|---|---|---|---|
| 18:04 del 1 agosto | 14,0 gradi, az 119 | **29,4 gradi, az 147** | 29,4 gradi, sud-est |
| mezzanotte fra 1 e 2 | 28,7 gradi, az 215 | **13,0 gradi, az 242** | 13,0 gradi, sud-ovest |

**Coincidono alla prima cifra decimale.**

## I 123,7 GRADI SONO LA STESSA CAUSA, e si chiudono qui

Stavano aperti in RIPRESA.md. Un istante gia' in UTC non veniva toccato, uno
civile veniva convertito due volte: i due modi di scrivere lo stesso momento non
potevano dare lo stesso cielo. **Una causa sola per due difetti che sembravano
distinti**, e una prova ora pretende che i due cieli coincidano.

## Un solo istante, e si legge

`mezzanotteDellaNotteCheViene` in `lib/core/astro/sky.dart`. **La regola sta li'
e in nessun altro posto**: prima di mezzogiorno la notte che viene e' quella gia'
cominciata, da mezzogiorno in poi quella che deve arrivare. Chi guarda alle due
di notte non vuole sentirsi dire "domani".

La schermata legge quel dato una volta. Tutto quello che mostra, posizioni,
altezze, direzioni e fase, discende da li'.

## Il titolo e i testi

"Il cielo sopra di te" e' diventato **"Il cielo di stanotte"**, e vive in
`SkyPostcard.titleFor`, che era gia' una porta sola. L'avverbio della schermata
sta in `quando()`, anch'esso un punto solo: cambiata quella riga, si sono
adeguate tutte le frasi che la leggono, la riga del calcolo insieme alla nota in
fondo. I tre "adesso" rimasti parlano del LUOGO, non del tempo, e sono diventati
"dove ti trovi": il luogo di adesso e' davvero quello di adesso.

## L'ora nella riga, e il punto della figura

La scheda ora dice **"Bilancia, 13 gradi sopra il suolo, a sud-ovest, a
mezzanotte"**. Senza l'ora quel numero non e' verificabile da nessuno, ed e'
esattamente cio' che ha costretto il fondatore a chiedere una verifica esterna.

**Il punto e' la stella piu' luminosa**, dichiarato in `puntoDellaFigura`. Le
stelle della Bilancia stanno fra 0,8 e 13 gradi allo stesso istante: dire "13
gradi" senza dire di cosa non e' un dato, e' un numero.

**Due difetti trovati facendolo:**
1. l'altezza era il MASSIMO fra le stelle e la direzione quella della PRIMA
   dell'elenco, cioe' due stelle diverse nella stessa frase;
2. due stelle della Bilancia hanno la STESSA magnitudine, a 13 e a 3,8 gradi, e
   il criterio non era deterministico: la figura poteva rispondere due altezze
   diverse allo stesso istante. A parita' di luce vince la piu' alta, che e'
   anche quella che si vede meglio.

## La Luna

Aveva fase e illuminazione e si fermava li', mentre di ogni costellazione si
diceva gradi e direzione. Ora ha la stessa forma delle altre, piu' la fase che
e' sua e resta: *"Luna, 19 gradi sopra il suolo, a sud-est, a mezzanotte.
Gibbosa calante, illuminata al 91 per cento."*

La verifica indipendente che gia' tornava, gibbosa calante al 91 per cento, non
e' stata toccata e continua a tornare.

## Le prove, viste rosse

**Prima prova**: a Milano, alla mezzanotte fra l'1 e il 2 agosto 2026, la
Bilancia sta a 13 gradi a sud-ovest. Rossa sul codice di prima con
`Actual: 3.81`, e rossa anche sulla direzione.

**Seconda prova**: nessun testo della schermata nomina il presente. **Questa
l'ho vista passare quando doveva fallire**: saltava le stringhe senza spazi, e
l'avverbio del punto solo e' la parola "Adesso" da sola. Riscritta, e' rossa
sul testo di prima con `Actual: ['... riga 44: adesso']`.

Entrambe verdi sul codice nuovo, e ho rimesso il codice vecchio per vederle
cadere invece di fidarmi.

## Le immagini

`cielo_adesso_prima.png` e `cielo_adesso_dopo.png`, piu' la coppia del cielo di
nascita. **Le catture ora usano un istante fisso**, quello della segnalazione:
prima il cielo "adesso" si catturava con l'ora della macchina, quindi due
immagini fatte in momenti diversi non erano confrontabili, e questa coppia serve
proprio a confrontare.

## La frase di accettazione

**Apri "Il cielo di stanotte" e tocca la Bilancia: la scheda dice quanti gradi,
in che direzione, e A CHE ORA. Il numero e' quello della mezzanotte, la
direzione anche, e chiunque puo' verificarli con un'effemeride.**
