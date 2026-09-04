# -*- coding: utf-8 -*-
"""CQ5: la pagina del referto si riallinea all'ordine finito."""
import io
NL = chr(10)

P = ('C:/Users/user/AppData/Local/Temp/claude/'
     'C--Users-user-Desktop-esoteric-circle-app--claude-worktrees-'
     'esoteric-circle-v3-realignment-a88835/'
     '410c8eda-5b3b-4e64-9653-f6197491d4ab/scratchpad/referto_cq.html')
s = io.open(P, encoding='utf-8').read()


def cambia(vecchio, nuovo, quante=1):
    assert s.count(vecchio) == quante, (s.count(vecchio), vecchio[:70])
    return s.replace(vecchio, nuovo)


# Il pannello scuro era trasparente per uno zero di troppo nel colore.
s = cambia('--panel: #12152300;', '--panel: #121523;', 2)

# --- il timbro in cima ---------------------------------------------------
s = cambia(
    '<span>Build <b>2223</b></span>'
    + NL + '    <span>Voci <b>32</b> \u00b7 chiuse <b>22</b> \u00b7 aperte <b>6</b></span>',
    '<span>Build <b>2224</b></span>'
    + NL + '    <span>Voci <b>32</b> \u00b7 chiuse <b>31</b> \u00b7 aperte <b>0</b></span>')

s = cambia(
    "<p class=\"lede\">Le regressioni del telefono, i testi che non rispondevano, "
    "e il Cammino che murava.</p>",
    "<p class=\"lede\">Le regressioni del telefono, i testi che non rispondevano, "
    "il Cammino che murava. E adesso nessuna voce aperta.</p>")

# --- punto 3, il riquadro di cio' che non era stato fatto -----------------
s = cambia(
    "<div class=\"call\">" + NL +
    "  <p><strong>Cio' che non ho fatto, e lo dico per nome.</strong> La riscrittura "
    "frase per frase dei cinque responsi, la parola del giorno come corpus, la "
    "domanda della parola, il responso della runa singola, il ponte fra il motore "
    "delle date e la chat, la misura dei promemoria. Sono le sei voci "
    "<strong>aperte</strong> nel manifesto, e finch\u00e9 restano tali questo ordine "
    "non \u00e8 finito.</p>" + NL + "</div>",
    "<div class=\"call\">" + NL +
    "  <p><strong>Le sei voci che avevo lasciato indietro sono chiuse</strong>, e "
    "stanno una per una al punto 8. Sono la riscrittura dei cinque responsi, la "
    "parola del giorno, la domanda della parola, il responso della runa singola, il "
    "ponte fra il motore delle date e la chat, e la misura dei promemoria.</p>" + NL +
    "</div>")

# --- punto 5, la coda ----------------------------------------------------
s = cambia(
    "<p>Nessuna di queste sette \u00e8 sigillata <strong>chiusa</strong>. Cinque sono "
    "fermate su tua decisione, con scritto accanto chi le ha superate; CG.16 chiude "
    "oggi; CP.01 \u00e8 superata dalla voce 2.13.</p>",
    "<p>Nessuna di queste sette \u00e8 sigillata <strong>chiusa</strong>, ed \u00e8 "
    "esattamente ci\u00f2 che la tua voce 4.01 chiedeva. Sei sono fermate su tua "
    "decisione, con scritto accanto chi le ha superate; CG.16 chiude con la voce "
    "1.09.</p>")

# --- punto 6, la tavola dei manifesti ------------------------------------
vecchia = s[s.index('<h2><span class="num">Punto 6</span>'):
            s.index('<h2><span class="num">Punto 7</span>')]
nuova = """<h2><span class="num">Punto 6</span>I sei manifesti, e zero voci aperte</h2>
<div class="scroll">
<table>
  <thead><tr><th>Ordine</th><th class="n">Voci</th><th class="n">Chiuse</th><th class="n">Fermate</th><th class="n">Aperte</th></tr></thead>
  <tbody>
    <tr><td>CG</td><td class="n">16</td><td class="n">16</td><td class="n">0</td><td class="n up">0</td></tr>
    <tr><td>CM</td><td class="n">11</td><td class="n">11</td><td class="n">0</td><td class="n up">0</td></tr>
    <tr><td>CN</td><td class="n">16</td><td class="n">15</td><td class="n">1</td><td class="n up">0</td></tr>
    <tr><td>CO</td><td class="n">20</td><td class="n">15</td><td class="n">5</td><td class="n up">0</td></tr>
    <tr><td>CP</td><td class="n">10</td><td class="n">9</td><td class="n">1</td><td class="n up">0</td></tr>
    <tr><td><strong>CQ</strong></td><td class="n"><strong>32</strong></td><td class="n"><strong>31</strong></td><td class="n"><strong>1</strong></td><td class="n up"><strong>0</strong></td></tr>
    <tr><td><strong>Totale</strong></td><td class="n"><strong>105</strong></td><td class="n"><strong>97</strong></td><td class="n"><strong>8</strong></td><td class="n up"><strong>0</strong></td></tr>
  </tbody>
</table>
</div>
<p>Il Collaudatore prendeva solo manifesti terminali e sigillati: CM, CN, CO e CP non lo erano, quindi li saltava e andava a ritroso. <strong>Stava collaudando ordini di settimane fa</strong> mentre i quattro pi&ugrave; recenti non passavano da nessun controllo indipendente.</p>

<h3>Le otto fermate, con la tua decisione accanto</h3>
<p>La tua REGOLA G dice che una fermata vale solo se poggia su una decisione che hai preso per iscritto. Le elenco tutte.</p>
<div class="scroll">
<table>
  <thead><tr><th>Voce</th><th>La decisione tua che la ferma</th></tr></thead>
  <tbody>
    <tr><td><strong>CN.05</strong></td><td>l'hai annullata tu prima che cominciasse</td></tr>
    <tr><td><strong>CO.07</strong></td><td>hai rovesciato il pulsante che bloccava la scelta, voce 1.03</td></tr>
    <tr><td><strong>CO.13</strong></td><td>hai riaperto le etichette a dodici punti, voce 1.02</td></tr>
    <tr><td><strong>CO.15</strong></td><td>hai fatto togliere tutto il blocco del rito, voce 2.03</td></tr>
    <tr><td><strong>CO.17</strong></td><td>hai riscritto la legge dei testi nel pezzo secondo</td></tr>
    <tr><td><strong>CO.20</strong></td><td>hai ricentrato il cuore, voce 1.04</td></tr>
    <tr><td><strong>CP.01</strong></td><td>hai ordinato la misura del Cammino murato, voce 2.12</td></tr>
    <tr><td><strong>CQ.28</strong></td><td>hai chiesto di non toccare la curva</td></tr>
  </tbody>
</table>
</div>
<div class="call">
  <p><strong>Tre fermate le ho disfatte, perch&eacute; non erano fermate.</strong> CQ.21 e CQ.23 dicevano &laquo;premessa falsa&raquo;, che &egrave; un lavoro finito e non una tua decisione. <strong>CP.08 aspettava una decisione che non ti avevo mai chiesto</strong>: chiusa col criterio adottato, nessun giorno dell'anno porta pi&ugrave; di tre feste, che combacia col massimo misurato e non lascia margine.</p>
</div>

"""
s = s.replace(vecchia, nuova)

# --- punto 7 diventa 9, e prima entrano le sei voci e la build -----------
i = s.index('<h2><span class="num">Punto 7</span>')
prima = """<h2><span class="num">Punto 7</span>Le sei voci che erano aperte</h2>
<ul>
  <li><strong>La legge dei testi, sui cinque Doni.</strong> Misurata su tutte e quattro le schermate: <strong>due non avevano nessuna fonte</strong>. L'Arcano non diceva da dove nasce, il Tramonto la teneva dietro un pulsante in barra, cio&egrave; chi legge il responso non incontrava mai la strofa. <em>Una risposta che non si pu&ograve; risalire chiede di essere creduta.</em></li>
  <li><strong>La parola del giorno.</strong> Diceva &laquo;Parola del giorno&raquo;, che &egrave; il nome di una casella. Adesso dice di portarsela dietro, e sotto c'&egrave; scritto dove va a finire.</li>
  <li><strong>Il Sigillo del Giorno.</strong> La fermata era una ricerca fatta male: <strong>esiste</strong>, &egrave; la bindrune che chiude ogni gettata. L'avevo cercato fra i nomi delle schermate invece che dentro le schermate. Sotto il disegno c'era la definizione di cosa &egrave; una bindrune e niente su cosa te ne fai: adesso prima l'uso, poi la tradizione in fondo.</li>
  <li><strong>La domanda della parola.</strong> Il richiamo della sera diceva che parola era e finiva l&igrave;. Adesso dice che ha attraversato il giorno e che adesso si chiude.</li>
  <li><strong>La runa singola.</strong> Misurato: 264 caratteri di scheda contro 50 di risposta, <strong>cinque volte e un quarto</strong>. A una runa sola il corpo sta dietro una porta che si apre in posto; a tre e a cinque resta dov'era, perch&eacute; l&igrave; &egrave; la lettura.</li>
  <li><strong>Il ponte con la chat.</strong> Al massimo tre eventi e il prossimo gradino del Cammino, senza promettere niente. Se non c'&egrave; niente da dire, non compare affatto.</li>
  <li><strong>I promemoria.</strong> Ventuno eventi con una data calcolabile, e <strong>sedici avvisi in un anno</strong>, uno ogni ventitr&eacute; giorni. Non &egrave; un flusso, e per questo si poteva misurare invece di costruire.</li>
</ul>

<h2><span class="num">Punto 8</span>La build 2224, e la prova che non ho fatto</h2>
<div class="call">
  <p><strong>Nessun dispositivo ha acceso questa build.</strong> La prova di accensione l'ho saltata per tuo ordine esplicito di oggi: non sei al PC, non hai il telefono collegato, e hai detto che non installi la 2223. Il numero e la firma li ho letti dall'archivio, non da un telefono.</p>
</div>
<p>La stessa riga sta nelle note della build su App Distribution, perch&eacute; chi la scarica lo legga prima di installarla. <strong>Vale solo per questa consegna</strong>: alla prossima, con te al PC, la prova torna obbligatoria e non ti chiedo di saltarla.</p>
<p>Non &egrave; la 2223. Quella era costruita e tu hai detto che non la installavi: consegnartela di nuovo col vecchio numero avrebbe voluto dire chiederti di fidarti che dentro fosse cambiato qualcosa.</p>

"""
s = s[:i] + prima + s[i:]

s = cambia('<h2><span class="num">Punto 7</span>Cosa aspetta il tuo PC</h2>',
           '<h2><span class="num">Punto 9</span>Cosa aspetta il tuo PC</h2>')
s = cambia('<h2><span class="num">Punto 8</span>Trovati fuori dall\'ordine</h2>',
           '<h2><span class="num">Punto 10</span>Trovati fuori dall\'ordine</h2>')

s = cambia(
    "<h3>La consegna della 2223</h3>" + NL +
    "<p>L'archivio \u00e8 costruito e verificato, e <strong>non \u00e8 ancora "
    "caricato</strong>: la consegna si ferma alla prova di accensione, che pretende "
    "un telefono collegato. Non consegno al buio, e il salto di quella prova vuole "
    "un tuo ordine esplicito.</p>", '')

# --- punto 10, i due difetti nuovi del registro --------------------------
s = cambia(
    "  <li><strong>Il censimento dei caratteri</strong> guardava le schermate e non "
    "i ruoli. \u00c8 la quarta cecit\u00e0 di quel documento in quattro ordini.</li>",
    "  <li><strong>Il censimento dei caratteri</strong> guardava le schermate e non "
    "i ruoli. \u00c8 la quarta cecit\u00e0 di quel documento in quattro ordini.</li>"
    + NL +
    "  <li><strong>Il registro delle guardie mentiva su se stesso.</strong> Le tre "
    "categorie in cima dicevano 3, 39 e 235: sommavano al totale giusto e nessuna "
    "delle tre era il numero che la tavola porta nella propria colonna. La guardia "
    "non se ne accorgeva perch\u00e9 controllava solo che le tre cifre sommassero "
    "fra loro.</li>" + NL +
    "  <li><strong>E il disallineamento che tre ordini davano per vero non "
    "esisteva.</strong> Il comando che lo misurava cercava due nomi su "
    "<strong>quattro</strong> porte comuni: contate tutte e quattro, il numero della "
    "tavola era giusto da sempre.</li>")

# --- il piede -----------------------------------------------------------
s = cambia(
    "<p>Ramo <span class=\"mono\">claude/esoteric-circle-master-order-e798aj</span>. "
    "Registro delle guardie da 261 a 277, viste rosse da 46 a 59, dal 17,6 al 21,3 "
    "per cento. Sedici guardie nuove, quarantatr\u00e9 innesti provati e "
    "quarantatr\u00e9 rossi.</p>",
    "<p>Ramo <span class=\"mono\">claude/esoteric-circle-master-order-e798aj</span>. "
    "Registro delle guardie da 261 a 283, viste rosse da 46 a 65, dal 17,6 al 23,0 "
    "per cento. Ventidue guardie nuove, cinquantadue innesti provati e cinquanta "
    "rossi: i due restati verdi stanno scritti nel registro del rosso con la loro "
    "ragione.</p>")

io.open(P, 'w', encoding='utf-8', newline='').write(s)
print('PAGINA RIALLINEATA,', len(s), 'caratteri')
