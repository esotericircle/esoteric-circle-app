# Interpretazione della Stesa a Tre Carte, regole per Code, Esoteric Circle

Regole deterministiche per comporre la lettura, oltre ai testi per carta di tarocchi.md. Principio: massimizzare il contenuto deterministico e cacheabile, lasciare a Gemini solo l'ultima cucitura sull'argomento e sulla persona. Voce di Medora, mai fatalismo, sempre consapevolezza. Accenti veri, mai trattino lungo, mai una proposizione dopo la virgola con "e".

## Scegli argomento, la lente

Prima della stesa l'utente sceglie l'argomento da una tendina, etichetta Scegli argomento. La lettura viene direzionata su quello. Salute, medico, legale e domande fataliste restano fuori per etica. Voci, in tre gruppi:

Amore e sentimenti: Amore, il quadro generale; Cosa prova per me; Un ritorno d'amore; Fiducia e tradimento; Un nuovo incontro; Scegliere tra due.
Lavoro e denaro: Lavoro, trovarlo o cambiarlo; Carriera e crescita; Denaro e fortuna; Un affare o una decisione.
Vita e cammino: Il momento che vivo, lettura generale; Una scelta o un bivio; Un cambiamento in arrivo; Famiglia e casa; Un'amicizia; Un progetto o un sogno.

## Struttura dell'interpretazione, gli strati

1. Sintesi forte, una riga, dalla sintesi della carta del Presente.
2. Le tre posizioni, Passato Presente Futuro, ognuna col testo ricco della carta dal corpus, letta dentro l'argomento scelto.
3. Le carte che dialogano, una riga sul rapporto tra le tre.
4. La carta chiave, quale delle tre e' il cuore, con una riga sul perche'.
5. Il consiglio di Medora, azionabile, sull'argomento, consapevolezza mai fatalismo.
6. La domanda di chiusura, un invito che apre a Chiedi ai Maestri.
7. Azioni: condividi, salva, chiedi a Medora. Disclaimer una sola volta.

## Le carte che dialogano, regole deterministiche

Code sceglie la riga dalle carte uscite. Se piu' regole valgono, priorita' ai Maggiori.

- Due Arcani Maggiori tra le tre: un tema del destino, qualcosa di grande attraversa la tua stesa, non e' un caso.
- Tre Arcani Maggiori: un momento cardine della tua vita, il cielo insiste.
- Solo Minori, nessun Maggiore: la risposta e' nel quotidiano e nelle tue mani, non in un destino piu' grande.
- Una rovesciata accanto a due dritte: una svolta, un blocco che si scioglie mentre passi.
- Due o tre rovesciate: un nodo da sciogliere prima di andare avanti, con margine di scelta.
- Tre carte dello stesso seme: un filo unico, l'elemento domina la lettura, fuoco Bastoni, acqua Coppe, terra Denari, aria Spade.
- Spade con Coppe insieme: mente e cuore ti tirano da due parti, cercano equilibrio.
- Bastoni con Denari insieme: slancio e concretezza, l'impulso chiede di posarsi a terra.
- Stesso seme che ricorre dal Passato al Futuro: un cammino coerente, stai andando nella tua direzione.

## La carta chiave

Di default il Presente. Se tra le tre c'e' un Arcano Maggiore e il Presente e' un Minore, la chiave diventa il Maggiore piu' significativo, per numero piu' alto tra i Maggiori usciti. Una riga spiega perche' quella carta e' il cuore.

## Il consiglio di Medora, modelli per gruppo

Fallback deterministico, Gemini lo specializza sull'argomento e sulla persona a runtime. Sempre azionabile, mai una promessa.

- Amore e sentimenti: non forzare i tempi dell'altro, porta la tua verita' con dolcezza e osserva cosa torna indietro. La risposta si vede nei gesti, non nelle parole.
- Lavoro e denaro: fai il passo concreto che rimandi da tempo, anche piccolo. La fortuna qui premia chi si muove, non chi aspetta il momento perfetto.
- Vita e cammino: prima di decidere, dai un nome a cio' che davvero vuoi. La strada si chiarisce quando smetti di volerle tutte.

## Le domande di chiusura, pool

Code ne pesca una coerente con l'argomento.

- Cosa sei disposto a lasciare andare per fare spazio a questo?
- Se il cielo inclina e non obbliga, qual e' il primo passo che spetta a te?
- Cosa cambierebbe se ti fidassi di cio' che gia' senti?
- Qual e' la verita' che stai rimandando di dirti?
- Di cosa hai davvero bisogno, oltre a cio' che chiedi?

## Profondita' della lettura

UN SOLO selettore Breve Media Lunga per l'intera lettura, Premium bloccato, con Breve libera nella Demo. Governa la lunghezza di tutti i testi di responso: le tre posizioni sono una lettura unica e continua, e una profondita' diversa per posizione darebbe un racconto sbilanciato, lungo in un punto e stretto in quello dopo. A runtime la profondita' scelta e' il tetto di lunghezza del testo, e i testi lunghi si generano solo quando la persona li chiede, per risparmiare token.
