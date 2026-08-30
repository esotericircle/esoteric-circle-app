# ORDINE CF, DICIOTTO VOCI

Ordine del fondatore del 30 agosto 2026, arrivato in tre pezzi. Guardia
`test/ordine_cf_guard_test.dart`.

**Da dove nasce.** Il fondatore ha disinstallato e reinstallato l'app sulla
build 2215, quella che contiene gli ordini CC, CD e CE, e ha trovato questi
difetti usandola davvero. **Tre voci nascono da lavoro dichiarato chiuso che sul
suo telefono non ha retto**: CF.09, CF.10 e CF.11.

Porta le tre regole degli ordini precedenti:

- **REGOLA ZERO.** Il testo dell'ordine non e' affidabile e l'Architetto che lo
  ha scritto non e' affidabile: ogni affermazione si verifica sul ramo prima di
  lavorarci. **E una misura scritta in un rapporto precedente non e' una misura
  di adesso**: nell'ordine CE tre premesse false su sette erano state EREDITATE
  dal rapporto dell'ordine CC invece di essere rimisurate.
- **REGOLA UNO.** Code non si ferma davanti a un ostacolo, risolve.
- **REGOLA DUE.** Le decisioni delegate si prendono e si motivano per iscritto;
  quelle non delegate si riportano come fatti.

## Le diciotto voci

- **CF.01** La barra sottile piu' alta, con l'anello del livello. **APERTA.**
- **CF.02** La striscia dei Doni piu' bassa. **APERTA.**
- **CF.03** La barra Esplora piu' bassa. **APERTA.**
- **CF.04** Le notifiche dei Doni, e le push. **APERTA.**
- **CF.05** "Bentornata Mauro", al femminile. **APERTA.**
- **CF.06** Rimasto sul Risveglio invece che in home. **APERTA.**
- **CF.07** I dati di nascita non erano rimasti memorizzati. **APERTA.**
- **CF.08** La ricerca della citta' non funziona nel popup. **APERTA.**
- **CF.09** Il lampo nero non c'e' ovunque. **APERTA.**
- **CF.10** Caratteri troppo piccoli nei Doni e altrove. **APERTA.**
- **CF.11** Il conteggio delle sinastrie. **APERTA.**
- **CF.12** La carta del VIP ingrandita e' schiacciata. **APERTA.**
- **CF.13** Le mappe calcolano sulla citta' natale. **APERTA.**
- **CF.14** Il Gemello astrale non e' appagante. **APERTA.**
- **CF.15** La riga della privacy policy manca a chi rientra. **APERTA.**
- **CF.16** Due porte quasi identiche, e ne resta una sola. **APERTA.**
- **CF.17** Le due lapidi vecchie, scritte col sale vuoto. **APERTA.**
- **CF.18** Il secondo cancello. **APERTA.**

VOCI_TOTALI: 18
VOCI_CHIUSE: 0
VOCI_APERTE: 18
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0
VOCI_FERMATE_SU_DECISIONE_DEL_FONDATORE: 0

## LE AFFERMAZIONI DI QUESTO ORDINE CHE HO TROVATO FALSE

**Nessuna. Diciotto premesse su diciotto sono vere**, e va detto perche' e' il
contrario esatto dell'ordine CE, dove sette su diciassette erano false e tre di
quelle erano state ereditate da un rapporto vecchio invece che rimisurate.
Questa volta l'Architetto ha misurato prima di scrivere.

Verificate tutte sulla testa `88e587ee`, prima di toccare una riga.

| # | esito | cosa ho misurato |
| --- | --- | --- |
| P01 | **vera, stato superato** | la testa non e' `e646f06f` ma `88e587ee`, cioe' un commit piu' avanti, e coincide col remoto |
| P02 | **vera** | `altezzaChiusa = 30`, `PortaDellAccount(misura: 22)`, `Positioned(top: 0)`, e dentro volto, "Eventi Cosmici" in `Expanded` e borsellino |
| P03 | **vera** | `_heightLarga` e `_heightStretta` valgono tutte e due 122, la striscia e' montata solo da `santuario_screen.dart`, il tetto della guardia e' 126 |
| P04 | **vera** | `SantuarioBottomBar.altezzaResa = 134`, `BarraDelCerchio.altezza` la legge da li' e `corsa = altezza` |
| P05 | **vera** | cinque chiamate locali con `zonedSchedule` e `AndroidScheduleMode.inexactAllowWhileIdle`, programmate da `RegiaDelleChiamate` |
| P06 | **vera** | zero occorrenze di `firebase_messaging` in `lib/`, in `pubspec.yaml` e in `functions/src/` |
| P07 | **vera** | una sola riga, chiave `consenso_informativa`, testo "Continuando accetti la privacy policy del Cerchio.", montata solo dentro `VieDellaCustodia` |
| P08 | **vera** | il ramo dell'email trovata costruisce i suoi `_PulsanteDellaVia` da solo, senza passare da `VieDellaCustodia`: la riga non c'e' |
| P09 | **vera** | Impostazioni ha "Privacy e dati" con dentro "Privacy e permessi" e "Cancella i miei dati" |
| P10 | **vera, e peggio** | il menu' utente ha "Privacy e dati" con le quattro voci, **e le due porte usano la stessa identica icona, `Icons.shield_outlined`** |
| P11 | **vera** | `RigaDelResiduo` e' il primo figlio della lista del verdetto, e la scelta del VIP avviene in un'altra schermata |
| P12 | **vera** | montata in quattro punti: confronti, domande, approfondimenti, sinastrie. Gettate e stese non ne hanno |
| P13 | **vera, ai numeri esatti** | 43 `PassaggioDelCerchio.rotta`, 36 `showModalBottomSheet`, 16 `showDialog`, 3 `showGeneralDialog` |
| P14 | **vera** | tutti e cinque i Doni usano `lettura()` sui testi lunghi e **nessuno dei cinque file ha un solo `fontSize` esplicito** |
| P15 | **vera, e il numero coincide** | `height: larga / 0.78` con `StackFit.expand` sopra un `AspectRatio` a 2 su 3 e `BoxFit.fill`: compressione verticale **14,53 per cento** |
| P16 | **vera** | `luogo.attuale` e' scritta solo da `dove_sei_adesso.dart`, montato solo nel Rito dell'Alba, e il profilo ha un solo campo, "Luogo di nascita" |
| P17 | **vera** | sfilata di 1600 millesimi, una miniatura da 120, una frase in due varianti, dentro `sinastria_gallery_screen.dart` |
| P18 | **vera** | `BENVENUTO_PEPPER` versione 1 montato da `statoDelCerchio`, revisione `statodelcerchio-00018-vat` |

### La domanda a parte, e la sua premessa e' falsa

L'ordine chiede: la prova nata nell'ordine CC per misurare la grandezza vera a
cui ogni titolo viene dipinto usava `getTransformTo`, ed e' stata cieca per due
ordini?

**Quella prova non e' mai esistita.** La prova dell'ordine CC voce 05,
`le_descrizioni_hanno_una_misura_sola_test.dart`, **contava** i titoli con la
misura scritta a mano e non misurava niente di dipinto: e' proprio per questo
che il difetto e' rimasto nascosto. La prova che misura la grandezza dipinta e'
nata nell'ordine CE voce 11, e **nella sua prima stesura usava davvero
`getTransformTo`**: e' stata cieca per il tempo della sua scrittura, il difetto
e' stato trovato dalla prova del rosso che non scattava, ed e' stato corretto
dentro lo stesso ordine prima della consegna. La ragione sta scritta nel file.

**Ma la ricerca ha trovato altro, e vale piu' della domanda.** `getTransformTo`
e' usato in altri due punti del progetto, tutti e due nella stessa forma cieca
`MatrixUtils.transformRect(getTransformTo(...), Offset.zero & size)`:

- `test/la_chiave_e_il_consiglio_si_vedono_test.dart`, in tre punti, per misurare
  l'altezza dipinta delle carte della Stesa;
- `lib/features/onboarding/primo_approdo.dart`, per calcolare il riquadro del
  faro del tutorial attorno a un'ancora.

**Oggi nessuno dei due e' cieco davvero**, perche' misurato: non c'e' nessun
`FittedBox` nei file della Stesa, e le quattro ancore del tutorial non stanno
sotto un ramo che scala. **Ma lo diventerebbero in silenzio** il giorno che
qualcuno ne aggiunge uno, e nella voce CF.01 si tocca proprio
`barra_dell_identita.dart`, che porta una di quelle ancore.

## LE SCELTE CHE HO PRESO IO E PERCHE'

Da riempire voce per voce.

## LE TRE COSE CHE QUEST'ORDINE PRETENDE SIANO SCRITTE

### CF.03 supera una decisione precedente del fondatore

"LA SCRITTA ESPLORA E IL SUO MENU' A SCOMPARSA NON SI TOCCANO" e' una decisione
del fondatore del 17 agosto 2026, ripetuta come vincolo permanente in cinque
manifesti d'ordine. **La richiesta del 30 agosto 2026 la supera**, e la voce
CF.03 la esegue per ordine esplicito.

### CF.09, CF.10 e CF.11 nascono da voci dichiarate chiuse

Da riempire alla chiusura di ognuna, con la ragione per cui la loro prova era
verde.

### Il debito lasciato aperto dall'ordine CE

La modifica del vincolo di copertura della spirale, sceso dal 71,4 al 59,9 per
cento con l'ordine CE voce 14, **va scritta anche nel manifesto dell'ordine AV**,
altrimenti AV continua a dichiarare un numero che non vale piu'.
