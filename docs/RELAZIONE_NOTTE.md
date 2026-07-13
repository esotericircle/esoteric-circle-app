# Relazione della notte

Sessione notturna autonoma. Un task alla volta, in ordine. Dopo ogni task:
`flutter analyze` pulito, test verdi, screenshot headless committati, una riga
qui. Niente che richieda console Firebase, telefono, generazione immagini su
Vertex o credenziali. Niente pubblicazioni, niente PR.

## Task 1, schermata "Il cielo sopra di te" — FATTO

Costruita la schermata vera che si apre dal tocco sul cielo del Santuario, al
posto del segnaposto. Cosa contiene:

- Cielo ancorato all'ora di adesso: nuovo motore `lib/core/astro/night_sky.dart`
  che, dalla data, calcola la longitudine eclittica reale del Sole e quindi le
  costellazioni all'opposizione, cioè quelle alte a mezzanotte stanotte.
- Luna nella fase reale del momento (motore `moon_phase` già esistente).
- Corpi toccabili ed evidenziati: la Luna e le tre costellazioni alte, ciascuno
  con etichetta e una riga breve di cosa è, nella voce di Medora. Toccando un
  corpo la scheda in basso mostra la sua riga.
- La volta scorre col giroscopio (via `ParallaxController`), con ripiego allo
  scorrimento del dito per chi non ha il sensore, e si ferma con Riduci
  Movimento.
- Freccia Indietro che torna al Santuario, mai un vicolo cieco. Il cielo del
  Santuario apre già questa schermata (stessa route), ora non più segnaposto.
- I pianeti restano segnaposto dichiarato in schermo, in attesa del motore a
  effemeridi.

Limite dichiarato, non finto: nel repo non esisteva un motore del cielo di
nascita con catalogo J2000 e coordinate equatoriali reali da riusare. C'erano
gli asterismi stilizzati ma fedeli dello zodiaco (`zodiac_figures.dart`) e la
Luna reale. Ho costruito su quelli, usando astronomia vera per ciò che non
dipende dal luogo (posizione del Sole, opposizione). Il posizionamento reale
rispetto all'orizzonte, con stelle nominate e pianeti, richiede il motore a
effemeridi e la posizione dell'osservatore: resta il passo successivo.

Test: `test/night_sky_test.dart` (segno del Sole per stagione, costellazioni
opposte al Sole, longitudine in range, accenti puliti) e
`test/sky_overview_test.dart` (corpi presenti e toccabili, scheda, freccia
Indietro). Screenshot: `docs/preview/cielo-sopra-di-te.png`.

Dubbi aperti per te: la geometria delle costellazioni è ancora l'asterismo
stilizzato, non la posizione reale in alt-azimut. Serve decidere se il motore
del cielo userà un catalogo J2000 con la posizione GPS dell'utente (richiede
permesso di localizzazione) oppure una veduta simbolica indipendente dal luogo.
