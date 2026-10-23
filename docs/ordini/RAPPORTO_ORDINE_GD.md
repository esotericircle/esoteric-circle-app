# RAPPORTO DELL'ORDINE GD, I VIDEO DI INGRESSO AI DOMINI, LA STESA DI TAROCCHI, L'ORACOLO DEGLI ANGELI, LA SINASTRIA EVOLUTIVA, IL RESPIRO DELLA LUNA E IL CIELO IN TEMPO REALE

23 ottobre 2026. Ramo `claude/esoteric-circle-master-order-e798aj`.
Manifesto: `docs/ordini/ORDINE_GD_MANIFESTO.md`, 26 voci: **23 chiuse, 3
aperte in attesa di verifica, 0 da fare, 0 premesse cadute, 0 divieti**.
Testo dell'ordine: `docs/ordini/ORDINE_GD_TESTO.md`.

## Le voci chiuse e la loro prova

- GD.01, `docs/collaudo/GD/simulazioni/catture/gd01_medora_gemelli_realme.png`
- GD.02, `docs/collaudo/GD/simulazioni/catture/gd02_caligo_dominio_runa_realme.png`
- GD.04, `test/gd04_le_carte_hanno_gia_parlato_test.dart`
- GD.05, `test/gd05_la_lunga_della_stesa_test.dart`
- GD.06, `test/gd_l_oracolo_degli_angeli_test.dart`
- GD.07, `test/gd_l_oracolo_degli_angeli_test.dart`
- GD.08, `test/gd_l_oracolo_degli_angeli_test.dart`
- GD.09, `test/gd_l_oracolo_degli_angeli_test.dart`
- GD.10, `test/gd_l_oracolo_degli_angeli_test.dart`
- GD.11, `test/gd_l_oracolo_degli_angeli_test.dart`
- GD.12, `test/gd_l_oracolo_degli_angeli_test.dart`
- GD.13, `docs/collaudo/GD/simulazioni/catture/gd13_sinastria_ingresso.png`
- GD.14, `docs/collaudo/GD/simulazioni/catture/gd14_4_ritorno_nella_tendina.png`
- GD.15, `test/gd_la_sinastria_evolutiva_test.dart`
- GD.16, `test/gd_la_sinastria_evolutiva_test.dart`
- GD.17, `test/gd_la_sinastria_evolutiva_test.dart`
- GD.18, `docs/collaudo/GD/simulazioni/catture/gd18_riflessione.png`
- GD.19, `test/gd_la_sinastria_evolutiva_test.dart`
- GD.20, `test/gd20_gli_amici_offline_hanno_una_porta_sola_test.dart`
- GD.22, `test/gd_la_sinastria_evolutiva_test.dart`
- GD.23, `test/gd23_il_respiro_col_solo_dito_test.dart`
- GD.24, `docs/collaudo/GD/simulazioni/gd24_fotogrammi_realme.txt`
- GD.25, `test/gd25_alza_il_telefono_al_cielo_test.dart`

Aperte: GD.03 (mancano le arti dipinte dei chakra), GD.21 (la porta del server
va pubblicata dal fondatore), GD.26 (si chiude col verde, riga in coda).

## La testa del ramo e le dodici premesse

- **Testa del ramo all'inizio dell'ordine: `02522987d2c2b3182b782dd7161b41ff53ed5ffd`**,
  verde di GitHub, la consegna della build 2316.
- **Le dodici premesse sono vere**, verificate sul filesystem prima di toccare
  qualunque cosa: la riga delle carte conservate in
  `lib/core/tarot/la_stesa_conservata.dart` righe 34-35; la riga della Lunga
  dell'Oracolo `RigaDelPiano.oracoloLunga` (`plan_catalog.dart`); il messaggio
  della rete in `oracolo_degli_angeli_screen.dart` righe 2123-2125; gli asset
  della Sinastria in `assets/img/sinastria/`; i file degli amici offline e la
  rubrica dell'Oroscopo (`oroscopo_screen.dart:931`); il Cerchio sociale
  (`il_cerchio_sociale.dart`, `lib/features/cerchio/`); i file della Sinastria;
  il Respiro che nominava il microfono (righe 54-118); il cielo in tempo reale;
  il manifesto GC a 32 voci tutte chiuse. Nessuna voce e' ferma.
- **Due fatti dell'ordine che non reggevano, scritti invece di fermare la
  voce** (non premesse da abbattere, quindi le voci sono state eseguite):
  GD.17 parlava di un ripiego che toglie la Lunga, ma la Sinastria evolutiva non
  chiama nessun modello, e la Lunga nasce dal corpus; GD.22 parlava della
  "scheda di una coppia già scoperta", che sul ramo non esisteva: e' nata qui
  (`LeCoppieScoperte`, senza salvare nascite).

## Come si e' lavorato

Le parti A (GD.01-GD.03), D (GD.13-GD.22) ed E/F (GD.23-GD.25) le hanno
eseguite tre agenti su rami locali (`gd-a`, `gd-d`, `gd-ef`) partiti dalla
testa `02522987` con regole comuni scritte (`docs/collaudo/GD/regole_per_gli_agenti.md`):
nessuna chiamata a pagamento, nessuna build, nessun telefono, solo i propri
file. I loro resoconti, voce per voce, stanno in `docs/collaudo/GD/parte_a.md`,
`parte_d.md` e `parte_ef.md`. Le parti B (GD.04, GD.05) e C (GD.06-GD.12)
le ho eseguite io. I tre rami sono stati fusi sul canonico senza conflitti, e
le loro prove rifatte qui dopo la fusione: verdi.

## Le due dichiarazioni sulla Lunga

### GD.05: perche' la prova della Stesa era verde mentre sul telefono i due paragrafi non c'erano

La Lunga della Stesa esisteva solo quando il modello tornava con una lettura
intera e a misura (`TarotReading.principaleDi`: `lunga = depth == profonda &&
dalModello != null && dalModello.approfondimento.isNotEmpty`). Ogni volta che
il modello non tornava entro il suo tempo, o tornava scartato (un paragrafo
fuori dai 40-50 parole, il titolo coi due punti, una frase col genere che non
si riusciva a curare), parlava la lettura di casa, e la lettura di casa era
scritta **"Sempre Breve: senza modello non c'e' un approfondimento"**. La
Lunga, che chiede al modello tre paragrafi a misura invece di due e usa Flash
invece di Flash-Lite, e' proprio la lettura che cade piu' spesso nel ripiego.

Le prove erano verdi per due ragioni, tutte e due scritte nel codice:

1. **La prova della forma pretendeva il difetto.** In
   `test/la_stesa_ha_la_forma_nuova_test.dart` la riga `final attesaLunga =
   lunga && dalModello != null;` diceva che senza modello la Lunga *non*
   doveva esserci: su 768 responsi provati, i 192 Lunghi senza modello erano
   misurati come giusti perche' Brevi. Lo stesso pretendeva
   `test/le_correzioni_dell_ordine_fn_test.dart` ("la lettura di casa, senza
   modello, non ha un approfondimento da mostrare"). Le due prove sono nate
   con l'ordine GA (commit `8208cbcf`) e con l'ordine FN (commit `2e0b69d0`).
2. **Ogni prova della Lunga col modello usava un modello finto che torna
   sempre ben formato** (`test/la_lettura_finta_della_stesa.dart`, a misura per
   costruzione): il caso che sul telefono capitava, il modello che non torna o
   torna scartato, non era mai misurato con la Lunga.

La cura: la lettura di casa ha il suo approfondimento
(`VoceDellaStesa.approfondimentoDiCasa`, l'ostacolo dal testo documentato della
carta chiave e i gesti della domanda non ancora detti) e la contemplazione dal
corpus; le due prove sono riscritte con la lapide e pretendono la Lunga anche
senza modello; la prova nuova `test/gd05_la_lunga_della_stesa_test.dart`
monta la schermata vera e conta i pezzi col modello e col modello che non
torna. Vista rossa rimettendo la regola di prima (2 pezzi contro 4).

### GD.10: perche' la prova di GC.19 era verde mentre sul telefono i due paragrafi non c'erano

Stessa forma, nell'Oracolo. La Lunga esisteva solo in `LaLetturaDellOracolo.leggi`
quando la risposta del modello reggeva; la via di ripiego
(`LaLetturaDellOracolo.delCorpus`, la risposta dai doni) **non aveva proprio il
parametro della profondita'**: era Breve per costruzione. E la via di ripiego
sul telefono capitava spesso: basta un paragrafo fuori misura, oppure una
parola della lista che la politica vieta (che cerca sottostringhe:
"guari" pesca anche parole innocue), e l'intera risposta del modello si butta.
La cattura del fondatore lo mostrava: sotto il responso c'era la riga "la
risposta scritta per te sulle tre carte arriva quando la rete torna", cioe'
quella lettura veniva dal ripiego.

La prova di GC.19 era verde perche' **tutte** le prove dell'Oracolo rispondono
con `jsonFintoDellOracolo` (`test/il_giro_dell_oracolo.dart`), un JSON scritto
a misura che non viene mai scartato: la prova contava il riquadro "Il salmo
propiziatorio" solo nel caso in cui il modello risponde bene, che e' il caso in
cui funzionava gia'. Il padre e' l'ordine GA voci GA.03-GA.05 (commit
`89ae8a24`), che ha messo la Lunga nella sola lettura del modello.

La cura: `delCorpus` prende la profondita' e da' anche lui l'approfondimento
(`LaRispostaDaiDoni.approfondimento`, dai gesti scritti per il Cuore e per
l'Intelletto sulla famiglia della domanda) e il salmo del Custode; `leggi` passa
la profondita' al ripiego. La prova nuova (`test/gd_l_oracolo_degli_angeli_test.dart`,
gruppo GD.10) conta i pezzi e trova il riquadro col modello **e col modello che
non torna**, e compone la Lunga dai doni su 72 angeli in stesa a una e a tre
carte: 144 su 144 a misura. Vista rossa togliendo il salmo dal ripiego.

## Voce per voce

Le righe DOMANDA, PROVA e MISURA di ogni voce stanno nel manifesto. Qui le
scelte e quello che il fondatore deve sapere.

- **GD.01, GD.02.** Il dono nel palmo entra in dissolvenza quando il video
  finisce o si salta, mai mentre gira. Lo scambio dei video di Calìgo e' una
  rinomina: prima di una build serve una build pulita o il `touch` dei quattro
  file (`brand_assets/maestri_scena/caligo_*_v1.mp4`,
  `assets/img/maestri_scena/caligo_*_ultimo_fotogramma_v1.webp`); le mie due
  build locali l'hanno fatto. **Da guardare**: il video del vortice, che ora
  apre la chat, finisce con una runa Dagaz dipinta dentro il video, fissa per
  tutti; e la runa nel dominio anticipa quella del rito della sera, come il
  fondatore ha chiesto (alternativa: mostrarla solo dopo il rito).
- **GD.03.** Aperta: servono sette arti dipinte dei chakra
  (`assets/img/chakra/chakra_N_<nome>_v1.webp`); il punto del loto e' gia'
  misurato.
- **GD.04.** Al rientro con la stessa domanda le carte si scelgono di nuovo:
  la vecchia regola dell'ordine FI ("chi rientra ritrova le sue carte")
  cadeva proprio nel caso del fondatore. Una stesa identica riletta non si
  riconta.
- **GD.06.** Senza il pulsante, le consultazioni del giorno si guardano al primo
  dorso toccato, prima della scelta, cosi' nessuno sceglie le carte per poi
  trovare la porta chiusa. La regola permanente di `CLAUDE.md` sulla freccia
  d'invio e' sostituita da quella nuova, con la lapide.
- **GD.12.** L'infografica nuova e' la mappa dei nove cori nelle tre sfere
  (`LaMappaDeiCori`), coi segni dipinti dei cori gia' nel ramo: accende i cori
  degli angeli usciti e dice il conto in una frase. E' un tipo di grafico che
  nessun'altra arte usa, e lo stesso in tutta la funzione (stesa a una carta,
  a tre, assaggio). La regola permanente di `CLAUDE.md` e' aggiornata.
- **GD.13-GD.22.** Il resoconto della parte D ha ogni misura. Nel collaudo
  sul Realme ho trovato e curato cinque difetti (tabella in
  `docs/collaudo/GD/le_opzioni.md`): la domanda e il pulsante che filtravano
  sotto la tendina, i selettori di data e ora di sistema, la frase col
  maschile, l'alone nero intorno alle statue, le etichette spezzate.
- **GD.21.** Aperta finche' non si pubblica la porta del server.
- **GD.24.** Il video del Respiro e' il tratto dell'inspiro tagliato dal video
  del fondatore con un fotogramma chiave per fotogramma
  (`brand_assets/respiro_della_luna/medora_il_respiro_della_luna_inspiro_v1.mp4`),
  comandato per posizione. Sul Realme: 703 fotogrammi in 12,6 secondi, 0 persi.

## Le guardie

Undici guardie nuove, tutte viste rosse con l'innesto verificato col grep; il
registro `docs/guardie.md` sale da 888 a **899** (categorie 169, 323, 407). Le
prove che difendevano le regole di prima sono state viste rosse sul codice
nuovo e riscritte con la lapide: `la_stesa_si_conserva`,
`la_rotazione_delle_varianti`, `la_stesa_ha_la_forma_nuova`,
`le_correzioni_dell_ordine_fn`, `gc_l_oracolo_degli_angeli`,
`l_oracolo_si_sceglie_e_si_avvia`, `l_oracolo_degli_angeli_a_video`. Due
guardie di casa cadute su GitHub e curate: `la_grafica_del_respiro_e_dipinta`
distingue ora la maschera di dissolvenza del video di Medora da un alone
disegnato (vista rossa), `il_cerchio_custodisce_il_cammino` dichiara la
callable nuova `mandaLaSinastria` (49).

## Spese

Nessuna chiamata a pagamento. Nessuna domanda ai Maestri. Il collaudo ha letto
la Stesa e l'Oracolo a rete spenta.

## Build e server

Nessuna build per i tester (R3). Due build di rilascio sul computer, installate
solo sul telefono di collaudo per le simulazioni, col si' del fondatore in chat
("Autorizzo la build locale"), mai distribuite.

**Il comando da far eseguire al fondatore** (non eseguito da Code), per la
GD.21: la porta nuova e quella del Cerchio che ora porta le sinastrie ricevute.

```
cd functions
npm run build
firebase deploy --only functions:mandaLaSinastria,functions:ilMioCerchio
```

## Le richieste del fondatore arrivate durante il collaudo

Mentre il collaudo sul Realme era in corso il fondatore ha scritto tre
richieste, eseguite dentro le voci che toccano e provate:

- *"Nel respiro, cerca di evitare di coprire il viso di Medora con i testi."*
  (GD.23) I testi del rito partono dalla riga 1030 del fotogramma, sotto il
  mento (il viso finisce alla 1000): prova in
  `test/gd23_il_respiro_col_solo_dito_test.dart`, vista rossa con la posizione
  di prima (testi da 390 punti, sul viso), verde a 516; viste sul Realme
  prima del gesto e all'inspiro
  (`docs/collaudo/GD/simulazioni/catture/richiesta_respiro_viso_libero_inspira.png`).
- *"Nella sinastria, il modulo tendina deve essere semitrasparente e vorrei
  che curassi graficamente di più l'estetica, mi piace la grafica cornice del
  pulsante «scopri la compatibilità», ma dovrebbe essere ripreso."* (GD.14,
  GD.15) La tendina e' velata a 0,6 come le barre del titolo, con la scena
  dietro sfocata e un velo leggero (0,25) al posto di quello comune dei
  fogli (0,72), che la faceva leggere piena; le scelte e i campi del modulo
  stanno nella cornice dipinta del pulsante largo (`CorniceDipinta`, la stessa
  pittura a nove parti). Prove in `test/gd_la_sinastria_evolutiva_test.dart`,
  viste rosse col velo di prima; viste sul Realme
  (`docs/collaudo/GD/simulazioni/catture/richiesta_tendina_semitrasparente_velo_leggero.png`).
- *"Il testo «oggi fra Voi» dovrebbe andare un po' piu in basso per non
  sovrapporsi alla statua."* (GD.22) Il blocco della riga viva e' stretto in
  basso: a 360 per 726 punti, la schermata del Realme, lo stacco dalla base
  della statua passa da 9,7 a 21,7 punti. Prova in
  `test/gd_la_sinastria_evolutiva_test.dart` a tre misure di telefono, vista
  rossa coi margini di prima.

## Il verde

Il commit della consegna e il suo verde di GitHub si scrivono in coda a questo
rapporto, con la chiusura di GD.26.

**Aggiunta del 23 ottobre 2026, ordine GD, la consegna.** Verde di GitHub sul commit `78aff7446214675f93d9c9074d96ffed6174072f` (`refs/verde/78aff7446214675f93d9c9074d96ffed6174072f`, tutti i controlli verdi, 0 rossi nuovi). GD.26 chiusa, `docs/ordini/RAPPORTO_ORDINE_GD.md`: manifesto a 24 voci chiuse e 2 aperte (GD.03, le arti dei chakra; GD.21, la pubblicazione del server). Nessuna build per i tester: la ordina il fondatore.

**Aggiunta del 23 ottobre 2026, ordine GD, la pubblicazione del server.** Alle 23:06 il fondatore ha pubblicato `mandaLaSinastria` (creata) e `ilMioCerchio` (aggiornata), in europe-west1, dalla cartella di questo ordine, compilata da Code senza errori: "Deploy complete!" (`docs/collaudo/GD/gd21_pubblicazione_del_server.jpg`). La pubblicazione delle 23:00 dalla cartella `aspetta-testo-riallineamento-5a7bfd` (ferma a `55323422`) ha rimesso `statoDelCerchio`, `consumaDelGiorno` e `muoviGliEos` con un codice identico a quello del ramo: i loro file non sono cambiati da allora, nessuna regressione. GD.21 resta APERTA IN ATTESA DI VERIFICA: la consegna si vede solo fra due account veri dello stesso Cerchio, e Code non crea account.
