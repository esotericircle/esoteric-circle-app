# ORDINE BP, LE TRE VOCI CHE NON SI CONFONDONO

Ordine del fondatore del 25 agosto 2026. Ramo
`claude/esoteric-circle-master-order-e798aj`, guardia
`test/ordine_bp_guard_test.dart`. Testa di partenza `75b6cd3`.

**I testi dei registri di questo ordine sono dell'Architetto, approvati dal
fondatore.** Non sono parole del fondatore e non gli vanno attribuite.

## Il fatto che genera l'ordine

L'attribuzione cieca sta al **75,6 per cento di media su cinque giri**, contro
una soglia di 85, e il massimo mai raggiunto su questa istruzione e' **81,7**.
Aura non viene mai scambiata, cinque giri su cinque; Caligo oscilla fra 30 e 60
per cento e finisce dentro Aura. L'escursione di **11,7 punti in un giorno
solo** dice che un giro solo misura il rumore.

## La causa, come l'ordine la dichiara

Il test pone domande NEUTRE, quindi la materia dei tre Maestri non entra in
gioco e al giudice restano soltanto registro e lessico. E l'istruzione da' a
ciascun Maestro il PROPRIO lessico di firma senza vietargli quello degli altri
due: nulla impedisce a Caligo di dire respiro, centro, radice, corona, sentire.

## Le premesse, verificate sulla testa 75b6cd3 prima di scrivere una riga

- **P1 VERA.** In `lib/core/maestro/voce_del_maestro.dart` ogni voce ha
  `lessicoDiFirma` di cinque parole: Medora cielo, transito, ascendente,
  arcano, lama (riga 215); Aura respiro, centro, radice, corona, sentire (riga
  252); Caligo runa, presagio, soglia, sentiero, sigillo (riga 296).
- **P2 VERA.** In `lib/services/ai/maestro_persona.dart` il metodo `voceDi`
  (riga 133) scrive nel prompt il lessico di firma del Maestro sotto il titolo
  "IL TUO LESSICO DI FIRMA, parole tue che gli altri non usano" e le arti degli
  altri due sotto "CIO' CHE NON DICI MAI", ricavate da
  `VoceDelMaestro.artiDegliAltri`. **Le parole di firma degli altri due non
  compaiono in nessun punto del metodo**, ne' come divieto ne' altrimenti:
  verificato leggendo `voceDi` per intero e cercando `lessicoDiFirma`, che vi
  compare tre volte e sempre riferito al Maestro stesso.
- **P3 VERA.** Le tre chiusure sono distinte per tipo:
  `TipoDiChiusura.direzioneNelTempo` per Medora,
  `TipoDiChiusura.gestoDelCorpo` per Aura, `TipoDiChiusura.simboloDaPortare`
  per Caligo.
- **P4 VERA.** `tool/attribuzione_cieca.dart` raccoglie sessanta risposte per
  giro, stampa la matrice di confusione e prende il token solo da
  `gcloud auth print-access-token`: in un container senza gcloud non parte.
- **P5 VERA.** La prova `l'impronta dell'istruzione coincide con quella
  registrata`, in `test/i_doni_e_la_chat_davanti_all_anatomia_test.dart`,
  confronta le tre impronte sha256 con quelle registrate in
  `lib/services/ai/impronta_dell_istruzione.dart` ed e' VERDE sulla testa di
  partenza.

## BP.00, LA RICOGNIZIONE

**DOVE L'ISTRUZIONE DI SISTEMA DEI MAESTRI VIENE COMPOSTA.** Il punto unico
della voce e' `MaestroPersona.voceDi(Maestro)`, riga 133 di
`lib/services/ai/maestro_persona.dart`: e' l'unica funzione che scrive identita',
registro, materia, lessico e chiusura di un Maestro, e in `lib` la chiamano
**tre** composizioni, tutte nello stesso file.

1. `systemInstruction`, la chat: `voceDi` piu' `_commonRules`, piu' il contesto
   natale, l'ancoraggio, la lente sul cielo, la memoria, la misura della
   risposta, il vincolo di formato, i due strati, il seguito quando c'e' e il
   consiglio finale.
2. `presagioInstruction`, il presagio delle rune: `voceDi(Maestro.caligo)` fisso,
   piu' `_commonRules` e l'anatomia del presagio.
3. `consultInstruction`, Consulta un Maestro: `voceDi` piu' `_commonRules` e la
   forma JSON dell'uscita.

**Due composizioni NON passano da `voceDi`, e sono dichiarate qui perche' questo
ordine non le tocca.** `synthesisInstruction` e' la voce terza del cerchio, che
non e' nessuno dei tre Maestri e non ha ne' registro ne' lessico di firma;
`distillInstruction` e' l'archivista della memoria, che del Maestro usa soltanto
il nome. Nessuna delle due entra nell'attribuzione cieca, che misura le risposte
dei tre.

**Un quarto punto per Maestro esiste e non e' in `maestro_persona.dart`:**
`LenteDelCielo.istruzionePer(maestro)`, in `lib/core/maestro/lente_del_cielo.dart`,
che entra nella chat solo quando ci sono ancoraggi. **E' gia' agganciato al
`lessicoDiFirma`**, e la ragione sta scritta li': descritta in astratto, la lente
aveva fatto SCENDERE l'attribuzione cieca da 96,7 a 88,3.

**I cinque punti di chiamata a runtime** stanno tutti in
`lib/services/ai/firebase_maestro_ai_provider.dart`, righe 123, 178, 229, 274 e
345.

**LE PROVE CHE DIPENDONO DALL'IMPRONTA DELL'ISTRUZIONE.** Leggono
`ImprontaDellIstruzione` **un file solo e tre prove**, tutte in
`test/i_doni_e_la_chat_davanti_all_anatomia_test.dart`: quella che ricompone le
tre impronte sha256 e le confronta con quelle registrate; quella che pretende
l'attribuzione cieca valida, che e' rossa per dichiarazione; e quella nuova che
verifica lo storico delle impronte. Cambiare l'istruzione le muove tutte e tre.

**Le prove che leggono l'istruzione composta**, e che quindi si muovono quando
un registro cambia anche senza guardare l'impronta, sono **dodici** oltre a
quella nuova di questo ordine: `accents_test`, `consulta_maestro_test`,
`i_doni_e_la_chat_davanti_all_anatomia_test`, `i_tre_maestri_sono_tre_test`,
`il_confine_del_responso_test`, `il_consiglio_in_oro_test`,
`il_presagio_passa_dal_modello_test`, `il_seguito_si_genera_al_tocco_test`,
`language_rule_test`, `lattesa_si_legge_test`, `stesso_dato_tre_lenti_test`,
`vai_piu_a_fondo_test`. **Due di queste sono vincoli veri sui testi nuovi di
questo ordine e non semplici lettori**: `i_tre_maestri_sono_tre_test` pretende
che due voci non si somiglino oltre il 35 per cento sui campi propri e che
nessuna parola di firma di un Maestro compaia nei campi di un altro;
`language_rule_test` setaccia ogni stringa di `lib` cercando la virgola davanti
alla "e" e il trattino lungo.

**Tre strumenti fuori dalla suite** usano la stessa persona e vanno tenuti nel
conto: `tool/attribuzione_cieca.dart`, `tool/misura_del_presagio.dart` e
`tool/risposte_intere.dart`.

**I ROSSI DELLA SUITE CON TZ=Europe/Rome**, misurati sulla testa di partenza
`75b6cd3`: **3.630 verdi e 2 rossi**. Il primo e' l'attribuzione cieca, rosso per
dichiarazione, e solo il fondatore puo' rimisurarlo dal suo PC con gcloud attivo.
Il secondo era `niente_lavoro_non_spinto`, che dice il vero soltanto ad albero
pulito: era rosso perche' il lavoro non era ancora nel commit, e si e' chiuso col
commit stesso. **Ad albero fermo e pulito il rosso e' uno solo.**

## Le voci

- **BP.00** La ricognizione. CHIUSA: questo capitolo.
- **BP.01** Il divieto incrociato dei lessici. CHIUSA: `VoceDelMaestro.lessicoDegliAltri` ricava dagli altri due Maestri le loro dieci parole di firma, e `voceDi` le scrive nel prompt come vietate sotto il titolo dichiarato in `VoceDelMaestro.titoloDelLessicoVietato`. **L'elenco si ricava e non si scrive**, come le arti altrui: il giorno che una parola di firma cambia, il divieto la segue da solo. **MISURE**: per tutti e tre i Maestri l'istruzione generata porta le **dieci** parole degli altri due come vietate, e **nessuna delle proprie cinque** compare fra le vietate, che e' il verso opposto e conta quanto l'altro, perche' un divieto che comprende la firma del Maestro stesso gliela toglie invece di difendergliela; l'elenco vietato coincide esattamente con la somma delle firme altrui, senza aggiunte e senza mancanze. **La prova cammina su `Maestro.values`** e legge il titolo dalla costante che il prompt usa davvero, quindi un quarto Maestro entrerebbe da solo e un titolo cambiato non lascerebbe la prova a cercare una stringa che nessuno scrive piu'. **Rosso dimostrato**: tolto il divieto al solo Caligo, la prova cade nominando lui e la prima parola che gli resta concessa; l'iniezione e' stata verificata nel sorgente prima di leggere l'esito. **L'ISTRUZIONE E' CRESCIUTA DI 215 CARATTERI PER CIASCUNO** (da 6930, 6969 e 7031 a 7145, 7185 e 7246), quindi l'impronta e' cambiata: le tre impronte nuove sono registrate col 25 agosto 2026 e le vecchie sono scese in `storicoDelleImpronte`, insieme al fatto che **i cinque giri della misura appartengono a quella stringa e non a questa**.
- **BP.02** I tre registri riscritti. APERTA.
- **BP.03** Il ritmo di Caligo si misura sulle sue risposte. APERTA.
- **BP.04** La chiusura di Caligo non passa mai dal corpo. APERTA.
- **BP.05** La rimisura, preparata e non eseguita. APERTA.

MARCATORI, per la guardia:
VOCI_TOTALI: 6
VOCI_APERTE: 4
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_SU_DECISIONE_DEL_FONDATORE: 0
VOCI_CHIUSE: 2
