# Ordine GA voce GA.06, autoverifica della cura: l'Oroscopo

Fonte riletta: `docs/collaudo/GA/lettori_ciechi/oroscopo.json`, rigenerato dopo la cura con
`GA06_SCRIVI=1 flutter test test/ga06_campioni_per_i_lettori_ciechi_test.dart` (seme 606, senza
modello, gli stessi 48 casi: stesse persone, stessi giorni, stesse tradizioni, periodi, domini,
fasce e profondita'). Gli altri tre file dei campioni (tarocchi, rune, oracolo) non sono cambiati.
Riletto da chi ha fatto la cura, responso per responso, come lo leggerebbe una persona esigente;
dopo questa autoverifica un lettore cieco indipendente rifa' la prova.

Domande: (1) la prima frase risponde, cioe' dice com'e' il periodo in quel dominio? (2) "Cosa fare"
dice un'azione concreta? (3) e' coerente coi dati (livello, fascia, dominio, periodo) e, nella
Lunga, il rito e' coerente col reggente, col periodo e con la risposta?

## I conti, prima e dopo

| domanda | prima (lettore cieco, 1804c7d7) | dopo (questa rilettura) |
|---|---|---|
| (1) la prima frase risponde | 46 su 48 (no: 33, 40) | 48 su 48 |
| (2) Cosa fare concreto | 48 su 48 | 48 su 48 |
| (3) coerente coi dati e col reggente | 42 su 48 (no: 10, 26, 32, 42, 45, 48) | 48 su 48 |
| responsi con tre si' | 40 su 48 | 48 su 48 |

Gli altri difetti dell'esito, contati sul campione:

| difetto (sezione dell'esito) | prima | dopo |
|---|---|---|
| B. situazioni personali date per certe | circa 20 responsi | 0: ogni caso particolare sta dopo la prima frase, introdotto da "se" o "chi", con un'azione anche per chi non e' in quel caso |
| C. futuri dati per certi | 5 | 0 |
| D. riti uguali parola per parola fra due responsi | 3 coppie (7=15, 37=45, 39=47) | 0 |
| D. verso di Marte sulla contesa dove non c'e' contesa | 7 riti | 0: il verso sei resta al Generale; Amore il verso sette, Carriera e Fortuna il verso otto dello stesso inno |
| E. temi ripetuti fra tradizioni (13/45/48 imparare; 14/30/46 progetto di coppia) | 2 terne | 0: 13 l'ospitalita', 45 il vicinato, 48 i desideri detti; 14 il coraggio di dirlo, 30 il fascino curato, 46 ridere insieme |
| F. riti dell'Anno che parlano di un inizio lontano mesi | 3 (32, 45, 47) | 0 |
| G. "Da dove viene" criptici o che rimandano a parti assenti | 17 responsi (17, 22, 24, 25, 27, 29, 31, 33, 34, 35, 36, 37, 38, 39, 40, 42, 44) | 0 |
| H. testi deboli (20 il resto alla cassa; 1 il Generale ridotto agli spostamenti) | 2 | 0 |

## Una riga per responso (dopo la cura)

| id | tradizione, periodo, dominio, fascia, profondita' | D1 | D2 | D3 | nota |
|---|---|---|---|---|---|
| oroscopo-1 | occidentale, giorno, Generale, salita, Breve | si' | si' | si' | ora la prima frase dice la giornata in salita, poi il fuoco sui tempi |
| oroscopo-2 | occidentale, giorno, Amore, favorevole, Lunga | si' | si' | si' | due rami; il rito usa il verso di Ares che si volge all'amore |
| oroscopo-3 | occidentale, giorno, Carriera, favorevole, Breve | si' | si' | si' | non presume piu' il cambio di settore |
| oroscopo-4 | occidentale, giorno, Fortuna, equilibrio, Lunga | si' | si' | si' | non piu' disdette di abbonamenti; rito col verso delle opere di Demetra |
| oroscopo-5 | occidentale, settimana, Generale, equilibrio, Lunga | si' | si' | si' | nessun giorno della settimana per nome |
| oroscopo-6 | occidentale, settimana, Amore, favorevole, Breve | si' | si' | si' | due rami; niente "entro martedi'" |
| oroscopo-7 | occidentale, settimana, Carriera, favorevole, Lunga | si' | si' | si' | niente "progetto fermo da giorni"; rito della settimana, diverso da quello del 15 |
| oroscopo-8 | occidentale, settimana, Fortuna, favorevole, Breve | si' | si' | si' | "puo' portarti", non "ha buone probabilita'" |
| oroscopo-9 | occidentale, mese, Generale, favorevole, Breve | si' | si' | si' | niente gruppo di amici presunto ne' "risposte rapide" |
| oroscopo-10 | occidentale, mese, Amore, favorevole, Lunga | si' | si' | si' | era no: ora risposta e rito valgono per chi ha un legame e per chi no |
| oroscopo-11 | occidentale, mese, Carriera, equilibrio, Breve | si' | si' | si' | |
| oroscopo-12 | occidentale, mese, Fortuna, favorevole, Lunga | si' | si' | si' | rito del mese, coi trenta giorni |
| oroscopo-13 | occidentale, anno, Generale, favorevole, Lunga | si' | si' | si' | nessun "prossimi due mesi"; rito dell'anno "dal compleanno" |
| oroscopo-14 | occidentale, anno, Amore, favorevole, Breve | si' | si' | si' | non piu' "per la coppia" |
| oroscopo-15 | occidentale, anno, Carriera, equilibrio, Lunga | si' | si' | si' | rito dell'anno, diverso da quello del 7 |
| oroscopo-16 | occidentale, anno, Fortuna, equilibrio, Breve | si' | si' | si' | "ogni settimana", non "la prima domenica di ogni mese" |
| oroscopo-17 | vedica, giorno, Generale, salita, Lunga | si' | si' | si' | il Rahu Kalam ora e' spiegato; il rito non dice piu' "al mattino" |
| oroscopo-18 | vedica, giorno, Amore, favorevole, Breve | si' | si' | si' | non presume una storia finita: "se conservi tracce" |
| oroscopo-19 | vedica, giorno, Carriera, salita, Lunga | si' | si' | si' | niente corso e docente: due strade, con altri o in proprio |
| oroscopo-20 | vedica, giorno, Fortuna, equilibrio, Breve | si' | si' | si' | il resto alla cassa sostituito da scelte misurate fra le proposte |
| oroscopo-21 | vedica, settimana, Generale, favorevole, Breve | si' | si' | si' | |
| oroscopo-22 | vedica, settimana, Amore, equilibrio, Lunga | si' | si' | si' | il cane presunto diventa "un passo importante", due rami; "Da dove viene" senza rimandi |
| oroscopo-23 | vedica, settimana, Carriera, equilibrio, Breve | si' | si' | si' | "se il piano supera il tempo che hai" |
| oroscopo-24 | vedica, settimana, Fortuna, equilibrio, Lunga | si' | si' | si' | la Lunga apre sulla risposta |
| oroscopo-25 | vedica, mese, Generale, favorevole, Lunga | si' | si' | si' | |
| oroscopo-26 | vedica, mese, Amore, equilibrio, Breve | si' | si' | si' | era no: ora e' l'amore (dare e ricevere), due rami |
| oroscopo-27 | vedica, mese, Carriera, favorevole, Lunga | si' | si' | si' | niente "il tuo nome circola gia'" |
| oroscopo-28 | vedica, mese, Fortuna, favorevole, Breve | si' | si' | si' | "puo' nascondersi", non "c'e' un'opportunita' vera" |
| oroscopo-29 | vedica, anno, Generale, equilibrio, Breve | si' | si' | si' | la Sade Sati ora e' spiegata |
| oroscopo-30 | vedica, anno, Amore, favorevole, Lunga | si' | si' | si' | niente viaggio di coppia presunto |
| oroscopo-31 | vedica, anno, Carriera, salita, Breve | si' | si' | si' | la Sade Sati spiegata |
| oroscopo-32 | vedica, anno, Fortuna, equilibrio, Lunga | si' | si' | si' | era no: il rito dell'anno non parla piu' del "primo mattino del periodo" |
| oroscopo-33 | cinese, giorno, Generale, favorevole, Breve | si' | si' | si' | era no: "Oggi la giornata è favorevole alle conversazioni tranquille"; guardiano spiegato |
| oroscopo-34 | cinese, giorno, Amore, equilibrio, Lunga | si' | si' | si' | Sette Uccisioni spiegate una volta; la riga del tema e' leggibile |
| oroscopo-35 | cinese, giorno, Carriera, equilibrio, Breve | si' | si' | si' | niente laboratorio; "doma l'Ufficiale" riscritta |
| oroscopo-36 | cinese, giorno, Fortuna, salita, Lunga | si' | si' | si' | niente acquisto nell'usato; il Rivale spiegato una volta |
| oroscopo-37 | cinese, settimana, Generale, equilibrio, Lunga | si' | si' | si' | niente anziano da accompagnare; rito della settimana |
| oroscopo-38 | cinese, settimana, Amore, favorevole, Breve | si' | si' | si' | due rami |
| oroscopo-39 | cinese, settimana, Carriera, equilibrio, Lunga | si' | si' | si' | niente colleghi con le stesse ferie; rito diverso da quello del 47 |
| oroscopo-40 | cinese, settimana, Fortuna, equilibrio, Breve | si' | si' | si' | era no: "Settimana tranquilla per la fortuna, che passa ..." |
| oroscopo-41 | cinese, mese, Generale, equilibrio, Breve | si' | si' | si' | |
| oroscopo-42 | cinese, mese, Amore, favorevole, Lunga | si' | si' | si' | era no: ora e' il fascino in amore, due rami; rito del mese per chi ha un legame e per chi no |
| oroscopo-43 | cinese, mese, Carriera, equilibrio, Breve | si' | si' | si' | |
| oroscopo-44 | cinese, mese, Fortuna, equilibrio, Lunga | si' | si' | si' | non ripete piu' "il tempo, risorsa preziosa" del 40 |
| oroscopo-45 | cinese, anno, Generale, favorevole, Lunga | si' | si' | si' | era no: nessuna primavera ne' "dopo sei mesi"; rito dell'anno senza "inaugura" |
| oroscopo-46 | cinese, anno, Amore, favorevole, Breve | si' | si' | si' | |
| oroscopo-47 | cinese, anno, Carriera, favorevole, Lunga | si' | si' | si' | "da qui al prossimo Capodanno lunare"; rito senza "questo inizio" |
| oroscopo-48 | cinese, anno, Fortuna, favorevole, Breve | si' | si' | si' | era no: niente "verso meta' anno" |

## Quello che resta, detto apertamente

- oroscopo-10, il rito: a chi e' senza legame propone di condividere il frutto e la bevanda "con
  gli amici cari"; e' la festa di Lieo dell'inno, ma un lettore esigente puo' trovarlo un passo
  fuori dall'amore.
- Le Lunghe usano spesso la stessa costruzione per il rischio e per il segno di riuscita: "Il
  rischio è" stava in 316 voci, "Il segno che funziona" in 122. Sono state alternate con varianti
  della stessa misura ("La trappola è", "Il pericolo è", "L'errore tipico è"; "La prova che
  funziona", "Il segnale più chiaro", "La verifica più semplice"), ma restano una costruzione
  ricorrente.
- La vita inventata e la coerenza fine non si misurano a macchina: le misura il lettore cieco
  indipendente che rifa' la prova dopo questa autoverifica.
