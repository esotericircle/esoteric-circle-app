# -*- coding: utf-8 -*-
"""CQ4.01: sigilla i manifesti arretrati CM, CN, CO, CP.

Ogni voce riceve uno dei cinque stati ammessi e il manifesto si chiude col
blocco dei marcatori a macchina, nella stessa forma dei manifesti gia'
sigillati. **Lo stato scritto e' quello vero, non quello comodo**: due voci
dell'ordine CO non hanno fatto cio' che l'ordine chiedeva e non si sigillano
CHIUSE.
"""
NL = chr(10)

CHIUSA = 'CHIUSA'
PREMESSA = 'FERMATA SU PREMESSA FALSA'
ATTESA = 'FERMATA IN ATTESA DI DECISIONE'
FONDATORE = 'FERMATA SU DECISIONE DEL FONDATORE'
APERTA = 'APERTA'

MANIFESTI = {
    'CM': [
        ('01', 'La quadratura del registro delle guardie', CHIUSA, ''),
        ('02', 'Il cardinale minimo a chi scopre un insieme', CHIUSA, ''),
        ('03', 'Le due popolazioni, dichiarate', CHIUSA, ''),
        ('04', 'La regola A, una guardia nasce rossa', CHIUSA, ''),
        ('05', 'La regola B, chi tocca una zona la prova rossa prima', CHIUSA,
         ''),
        ('06', 'La regola C, ogni difetto ha un padre', CHIUSA, ''),
        ('07', 'Le tre regole scritte in CLAUDE.md', CHIUSA, ''),
        ('08', 'La scala del testo, dichiarata e decisa', CHIUSA, ''),
        ('09', 'Le quarantadue schermate per famiglia di causa', CHIUSA, ''),
        ('10', 'Il corredo a scala massima dentro lo sbarramento', CHIUSA, ''),
        ('11', 'Quante ne restano e in quanti ordini si chiudono', CHIUSA, ''),
    ],
    'CN': [
        ('01', 'I sette effetti, misurati uno per uno', CHIUSA, ''),
        ('02', 'La normalizzazione, e la grandezza cambiata', CHIUSA,
         ', e la cura di `play` che non finisce e\' stata portata alla sola '
         'musica: agli effetti e ai toni e\' arrivata solo con l\'ordine CQ '
         'voce 1.04, tre giorni dopo'),
        ('03', 'I quattro anelli', CHIUSA, ''),
        ('04', 'Gli anelli ora girano', CHIUSA, ''),
        ('05', 'La voce annullata dal fondatore', FONDATORE,
         ': il fondatore l\'ha annullata prima che cominciasse'),
        ('06', 'I respiri', CHIUSA,
         ', con il debito dichiarato dei due file scollegati'),
        ('07', 'I volumi e il sottomenu', CHIUSA, ''),
        ('08', 'I tre video', CHIUSA, ''),
        ('09', 'L\'effetto sopra i video', CHIUSA, ''),
        ('10', 'Il peso', CHIUSA, ''),
        ('11', 'Le licenze', CHIUSA, ''),
        ('12', 'La card a misura fissa', CHIUSA, ''),
        ('13', 'I due file che pesano uguale', CHIUSA, ''),
        ('14', 'La build, consegnata e senza la prova di accensione', CHIUSA,
         ', e la coda dell\'ordine ha misurato perche\' la 2218 era muta'),
        ('15', 'Il foglio per il fondatore', CHIUSA, ''),
        ('16', 'Il referto', CHIUSA, ''),
    ],
    'CO': [
        ('01', 'Lo Shaman entra alla fine dell\'intro', CHIUSA, ''),
        ('02', 'Il suono della carta', CHIUSA,
         ' per l\'intercapedine vuota, e **il suono restava muto lo stesso**: '
         'il lettore degli effetti aspettava `play` e chiedeva il fuoco audio '
         'esclusivo, curati dall\'ordine CQ voce 1.04'),
        ('03', 'Una voce sola sulla festa', CHIUSA, ''),
        ('04', 'Le monete piu\' quiete', CHIUSA, ''),
        ('05', 'La domanda scritta a mano', CHIUSA,
         ' per l\'esistenza del campo, e la sua guardia pretendeva solo '
         'l\'ORDINE e non la DISTANZA: il fondatore non lo ha trovato, e '
         'l\'ordine CQ voce 1.05 lo ha portato sotto le suggerite'),
        ('06', 'La carta dentro la sua bolla', CHIUSA, ''),
        ('07', 'Il pulsante che comincia', FONDATORE,
         ': **non ha fatto cio\' che serviva.** Il pulsante e\' stato messo '
         'PRIMA delle carte e ha bloccato la scelta, cioe\' faceva premere per '
         'ottenere il permesso di scegliere. Il fondatore lo ha rovesciato con '
         'l\'ordine CQ voce 1.03, dove il ventaglio vive da subito e il '
         'pulsante apre il responso'),
        ('08', '"Carta Chiave" in oro', CHIUSA, ''),
        ('09', 'Il conteggio delle sinastrie', CHIUSA, ''),
        ('10', 'La testa del Maestro', CHIUSA, ''),
        ('11', 'La dotazione e il residuo', CHIUSA, ''),
        ('12', 'Il vuoto della chat', CHIUSA, ''),
        ('13', 'I testi dei Doni, terza richiesta', FONDATORE,
         ': **non ha chiuso la materia.** La prosa e\' salita a diciotto punti '
         'ed era giusto, ma il ruolo `etichetta` e\' rimasto a DODICI in '
         'duecentotre punti dell\'app, e il censimento non lo ha mai scritto '
         'perche\' guarda le schermate e non i ruoli. Il fondatore lo ha detto '
         'una QUARTA volta, e l\'ordine CQ voce 2.11 ha alzato le etichette'),
        ('14', 'Il giallo del Rito dell\'Alba', CHIUSA, ''),
        ('15', '"IL RITO DI STAMATTINA"', FONDATORE,
         ': la riga e\' stata scritta bene e **il fondatore ha poi fatto '
         'togliere tutto il blocco**, perche\' annunciava un rito che non '
         'esiste. Ordine CQ voce 2.03'),
        ('16', 'L\'accento vero', CHIUSA, ''),
        ('17', 'I responsi dei Doni, riscritti nella gerarchia', FONDATORE,
         ': la gerarchia e\' stata scritta e **la prima cosa che si leggeva '
         'restava un compito**, in tutti e cinque i Doni e non solo '
         'nell\'Arcano. Misurato dall\'ordine CQ voce 2.00, e l\'Alba e il '
         'Soffio davano per di piu\' la stessa identica risposta'),
        ('18', 'Le stelle della festa', CHIUSA, ''),
        ('19', 'Le monete che volano', CHIUSA,
         ' per il suono che usciva senza monete, e **restava il verso '
         'opposto**: le monete non volavano quando nessun borsellino era '
         'misurabile, cioe\' proprio alla chiusura della festa. Rimediato nel '
         'rilancio dell\'ordine CQ'),
        ('20', 'Il cuore dei preferiti', FONDATORE,
         ': **non ha fatto cio\' che l\'ordine chiedeva.** Il cuore e\' stato '
         'SPOSTATO nell\'angolo sinistro invece che centrato verticalmente a '
         'destra, e li\' si e\' fuso con la freccia Indietro rendendola non '
         'premibile. Parole del fondatore: *"IO AVEVO CHIESTO SOLO DI '
         'CENTRARLA VERTICALMENTE"*. Rimediato dall\'ordine CQ voce 1.02'),
    ],
    'CP': [
        ('01', 'Il gradino non matura finche\' il precedente non e\' congedato',
         FONDATORE,
         ': la scala ha portato le feste del giorno peggiore da tredici a '
         'tre, e **ha murato il Cammino**. Misurato dall\'ordine CQ voce 2.12: '
         'su quattrocento giorni di uso onesto, centododici traguardi '
         'soddisfatti e TREDICI accesi. Il fondatore ha deciso con la voce CQ '
         '2.13 che il tetto ferma la scena e non l\'accensione'),
        ('02', 'Lo stesso gesto conta una volta al giorno', CHIUSA, ''),
        ('03', 'I dettagli che dicevano il falso', CHIUSA, ''),
        ('04', 'I centosessantacinque traguardi riscritti da zero', CHIUSA,
         ''),
        ('05', 'Lo stato generoso costruito dal corpus', CHIUSA, ''),
        ('06', 'I dormienti', CHIUSA, ''),
        ('07', 'L\'evento che arma e la condizione scritta', CHIUSA, ''),
        ('08', 'La simulazione di un anno', ATTESA,
         ': il criterio di accettazione e\' proposto e **non approvato dal '
         'fondatore**. La simulazione c\'e\' ed e\' verde, ma il numero che la '
         'dichiara buona non e\' ancora stato deciso'),
        ('09', 'La simulazione dell\'abuso', CHIUSA, ''),
        ('10', 'Il manifesto e la guardia dell\'ordine', CHIUSA, ''),
    ],
}

INTESTAZIONE = """

---

## LE VOCI E IL LORO STATO

**Sigillato con l'ordine CQ voce 4.01, 4 settembre 2026.** Il Collaudatore
degli Ordini prende solo manifesti terminali e sigillati: senza questo blocco
saltava questo ordine e andava a ritroso, quindi **nessuno lo ha mai
collaudato**. Le due regressioni viste dal fondatore la sera del 3 settembre
nascono qui dentro e sarebbero state intercettate.

**Lo stato scritto e' quello vero, non quello comodo.** Un manifesto sigillato
con stati falsi e' peggio di un manifesto non sigillato, perche' fa passare il
Collaudatore su una menzogna.

"""

CODA = """
VOCI_TOTALI: %(totali)d
VOCI_CHIUSE: %(chiuse)d
VOCI_APERTE: %(aperte)d
VOCI_FERMATE_SU_PREMESSA_FALSA: %(premessa)d
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: %(attesa)d
VOCI_FERMATE_SU_DECISIONE_DEL_FONDATORE: %(fondatore)d
"""


def main():
    for ordine, voci in MANIFESTI.items():
        percorso = 'docs/ordini/ORDINE_%s_MANIFESTO.md' % ordine
        testo = open(percorso, encoding='utf-8').read().rstrip()
        assert 'VOCI_TOTALI' not in testo, '%s e gia sigillato' % ordine
        righe = []
        conti = {CHIUSA: 0, APERTA: 0, PREMESSA: 0, ATTESA: 0, FONDATORE: 0}
        for numero, nome, stato, nota in voci:
            conti[stato] += 1
            righe.append('- **%s.%s** %s. **%s%s**%s' % (
                ordine, numero, nome, stato,
                '.' if not nota else '', nota + '.' if nota else ''))
        blocco = INTESTAZIONE + NL.join(righe) + NL + CODA % {
            'totali': len(voci),
            'chiuse': conti[CHIUSA],
            'aperte': conti[APERTA],
            'premessa': conti[PREMESSA],
            'attesa': conti[ATTESA],
            'fondatore': conti[FONDATORE],
        }
        open(percorso, 'w', encoding='utf-8').write(testo + blocco)
        controllo = open(percorso, encoding='utf-8').read()
        assert 'VOCI_TOTALI: %d' % len(voci) in controllo, ordine
        print('SIGILLATO %s: %d voci, chiuse %d, fermate %d, aperte %d'
              % (ordine, len(voci), conti[CHIUSA],
                 conti[PREMESSA] + conti[ATTESA] + conti[FONDATORE],
                 conti[APERTA]))


if __name__ == '__main__':
    main()
