# -*- coding: utf-8 -*-
"""CQ4.03: il manifesto di CQ si sigilla come tutti gli altri."""
NL = chr(10)

CHIUSA = 'CHIUSA'
PREMESSA = 'FERMATA SU PREMESSA FALSA'
ATTESA = 'FERMATA IN ATTESA DI DECISIONE'
FONDATORE = 'FERMATA SU DECISIONE DEL FONDATORE'
APERTA = 'APERTA'

VOCI = [
    ('01', 'Pezzo primo 1.01, il piano attivo e i suoi tetti', CHIUSA,
     ', e la callable resta da distribuire dal PC del fondatore, PASSO 7'),
    ('02', 'Pezzo primo 1.02, il cuore sopra la freccia', CHIUSA, ''),
    ('03', 'Pezzo primo 1.03, il ventaglio vive subito', CHIUSA, ''),
    ('04', 'Pezzo primo 1.04, il suono della carta', CHIUSA, ''),
    ('05', 'Pezzo primo 1.05, la domanda libera si trova', CHIUSA, ''),
    ('06', 'Pezzo primo 1.06, scegliere la gettata non getta', CHIUSA, ''),
    ('07', 'Pezzo primo 1.07, la stella sotto il testo', CHIUSA, ''),
    ('08', 'Pezzo primo 1.08, nessun suono non scelto', CHIUSA,
     ', e i tredici file del catalogo sono elencati nel referto perche\' il '
     'fondatore dica quali non ha scelto'),
    ('09', 'Pezzo primo 1.09, le push non partivano', CHIUSA,
     ' per il fuso; **AppCheck resta spento** e accenderlo e\' una decisione '
     'del fondatore col suo PC'),
    ('10', 'Pezzo primo 1.10, il rosso a intermittenza', CHIUSA, ''),
    ('11', 'Pezzo primo 1.11, il verde che valeva piu\' di un rosso', CHIUSA,
     ''),
    ('12', 'Pezzo primo 1.12, gli indici creati a mano', CHIUSA, ''),
    ('13', 'Rilancio 1, da dove viene il trenta', CHIUSA,
     ': e\' il tetto dell\'Adepto, e le ore degli screenshot lo dicono'),
    ('14', 'Rilancio, le monete che non volavano e il loro volume', CHIUSA,
     ''),
    ('15', 'Pezzo secondo 2.00, cosa dicono i Doni, misurato', CHIUSA, ''),
    ('16', 'Pezzo secondo 2.01, i cinque Doni rivisti frase per frase',
     APERTA,
     ': i cinque Doni sono stati misurati e liberati dal compito che li '
     'apriva, e la riscrittura di ogni responso non e\' stata fatta'),
    ('17', 'Pezzo secondo 2.02, l\'Alba e il Soffio dicevano lo stesso',
     CHIUSA, ''),
    ('18', 'Pezzo secondo 2.03, il rito annunciato che non esiste', CHIUSA,
     ''),
    ('19', 'Pezzo secondo 2.04, la parola del giorno non dice a cosa serve',
     APERTA, ''),
    ('20', 'Pezzo secondo 2.05, l\'Arcano non era individuale', CHIUSA, ''),
    ('21', 'Pezzo secondo 2.06, lo stesso difetto sul Tramonto', PREMESSA,
     ': misurato, il Tramonto compone la sua chiave con la nascita intera e '
     'due nascite diverse vedono la stessa runa 34 sere su 365'),
    ('22', 'Pezzo secondo 2.07, il Sigillo del Giorno non dice a cosa serve',
     ATTESA,
     ': nell\'app non esiste nessuno "Sigillo del Giorno". Ci sono il Sigillo '
     'del Sogno, il Sigillo del Cerchio e il Sigillo dell\'Intenzione, e '
     'serve sapere quale dei tre'),
    ('23', 'Pezzo secondo 2.08, la runa rovesciata senza lettura', PREMESSA,
     ': misurato su tutte e ventiquattro le rune nei due versi, righe vuote '
     'zero e righe uguali zero. Le otto simmetriche sono l\'unico caso, e in '
     'tradizione non hanno verso d\'ombra'),
    ('24', 'Pezzo secondo 2.09, la domanda della parola senza risposta',
     APERTA, ''),
    ('25', 'Pezzo secondo 2.10, il responso della runa singola troppo lungo',
     APERTA, ''),
    ('26', 'Pezzo secondo 2.11, i caratteri ancora piccoli', CHIUSA,
     ': il ruolo etichetta valeva DODICI punti in duecentotre posti'),
    ('27', 'Pezzo secondo 2.12 e 2.13, il Cammino murava', CHIUSA,
     ': 112 soddisfatti e 13 accesi prima, 112 e 112 dopo'),
    ('28', 'Pezzo secondo 2.14, la curva non monotona', FONDATORE,
     ': il fondatore ha chiesto di non toccarla'),
    ('29', 'Pezzo secondo 2.15, il ponte fra il motore delle date e la chat',
     APERTA, ''),
    ('30', 'Pezzo secondo 2.16, i promemoria, misurare e non costruire',
     APERTA, ''),
    ('31', 'Aggiunta 4.01 e 4.02, i manifesti arretrati e la chiusura di CG',
     CHIUSA, ''),
    ('32', 'Aggiunta 4.03 e 4.04, questo manifesto e la REGOLA F', CHIUSA,
     ''),
]

CODA = """

---

## LE VOCI E IL LORO STATO

**Sigillato con l'ordine CQ voce 4.03, 4 settembre 2026.** REGOLA F: un ordine
non e' finito finche' il suo manifesto non e' sigillato coi marcatori
terminali, e senza sigillo il Collaudatore degli Ordini non lo vede affatto.

**Sette voci restano APERTE e il sigillo lo dice.** La guardia
`i_manifesti_sono_sigillati_test.dart` resta rossa finche' non sono zero, ed e'
la stessa legge di consegna che l'ordine CG ha portato per tre giorni: **un
manifesto sigillato con stati falsi e' peggio di un manifesto non sigillato.**

%(righe)s

VOCI_TOTALI: %(totali)d
VOCI_CHIUSE: %(chiuse)d
VOCI_APERTE: %(aperte)d
VOCI_FERMATE_SU_PREMESSA_FALSA: %(premessa)d
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: %(attesa)d
VOCI_FERMATE_SU_DECISIONE_DEL_FONDATORE: %(fondatore)d
"""

P = 'docs/ordini/ORDINE_CQ_MANIFESTO.md'
testo = open(P, encoding='utf-8').read().rstrip()
assert 'VOCI_TOTALI' not in testo, 'gia sigillato'
conti = {CHIUSA: 0, APERTA: 0, PREMESSA: 0, ATTESA: 0, FONDATORE: 0}
righe = []
for numero, nome, stato, nota in VOCI:
    conti[stato] += 1
    righe.append('- **CQ.%s** %s. **%s%s**%s' % (
        numero, nome, stato, '.' if not nota else '',
        nota + '.' if nota else ''))
open(P, 'w', encoding='utf-8').write(testo + CODA % {
    'righe': NL.join(righe),
    'totali': len(VOCI),
    'chiuse': conti[CHIUSA],
    'aperte': conti[APERTA],
    'premessa': conti[PREMESSA],
    'attesa': conti[ATTESA],
    'fondatore': conti[FONDATORE],
})
controllo = open(P, encoding='utf-8').read()
assert 'VOCI_TOTALI: %d' % len(VOCI) in controllo
print('SIGILLATO CQ: %d voci, chiuse %d, aperte %d, fermate %d'
      % (len(VOCI), conti[CHIUSA], conti[APERTA],
         conti[PREMESSA] + conti[ATTESA] + conti[FONDATORE]))
