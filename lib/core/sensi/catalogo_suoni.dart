/// I TREDICI SUONI del Cerchio, e nessuno di piu'.
///
/// **Il silenzio e' cio' che rende un suono importante.** Le app che stancano
/// suonano a ogni tocco: qui non c'e' suono sui tocchi ordinari e nessuno nello
/// scorrimento. Tredici momenti soltanto, e ognuno si sente perche' attorno
/// c'e' silenzio.
///
/// **DA OGGI C'E' ANCHE LA MUSICA, e non contraddice la riga qui sopra.**
/// Ordine CN, 1 settembre 2026. La musica non e' un suono di risposta a un
/// gesto: e' un tappeto che sta sotto e non chiede attenzione. Vive nel suo
/// catalogo, `MusicaDelCerchio`, e passa sotto un effetto invece di coprirlo.
/// Il silenzio che rende importante un suono e' il silenzio DEGLI EFFETTI, non
/// l'assenza di ogni cosa.
///
/// **I tre Maestri NON hanno tre suoni diversi.** Sarebbe rumore, non identita':
/// una firma che cambia a seconda di chi parla non e' piu' una firma.
///
/// Il catalogo e' un DATO, non una convenzione scritta in un commento: un test
/// fallisce se una schermata riproduce un suono che non e' qui dentro.
enum SuonoDelCerchio {
  /// L'apertura dell'app, il cosmo che respira. Due secondi.
  ///
  /// UNA volta per sessione e mai a ogni ritorno in home: una firma che si
  /// ripete a ogni passaggio smette di essere una firma e diventa un tic.
  firma('firma.mp3', Duration(seconds: 2)),

  /// Risonanza, animale, angeli, sigillo. Uno o due secondi.
  ///
  /// E' il picco: il momento che si racconta in una frase e' la Risonanza, e
  /// tutto il resto sta sotto quel picco.
  rivelazione('rivelazione.mp3', Duration(milliseconds: 1500)),

  /// LA VOCE DEL PRINCIPIO, sulla schermata nera dell'intro.
  ///
  /// E' il sesto, e per questo la regola dei cinque e' stata riscritta invece
  /// che aggirata: entra nel catalogo come gli altri, perche' il catalogo esiste
  /// proprio per non avere suoni che nascono fuori. Suona una volta per
  /// sessione e prende il posto della firma quando l'intro c'e': due suoni che
  /// si contendono la stessa schermata nera non fanno un'apertura piu' ricca,
  /// fanno rumore.
  ///
  /// Provvisorio quanto l'intro che accompagna.
  principio('principio.mp3', Duration(milliseconds: 2430)),

  /// Chiusura di un rito o di una lettura. Breve, risolutivo.
  ritoCompiuto('rito_compiuto.mp3', Duration(milliseconds: 1500)),

  /// Ingresso nel dominio di un Maestro. Mezzo secondo, discreto.
  soglia('soglia.mp3', Duration(milliseconds: 500)),

  /// Un limite raggiunto. Brevissimo, opaco, senza dramma.
  ///
  /// Il rifiuto non merita teatro: un suono drammatico su un limite lo
  /// trasformerebbe nel momento piu' memorabile dell'app.
  rifiuto('rifiuto.mp3', Duration(milliseconds: 300)),

  /// Il contatto delle pietre runiche col telo, nella gettata. Un tocco di
  /// pietra, secco e breve.
  ///
  /// SETTIMO, entrato dal catalogo come vuole la regola: la gettata
  /// fisica del 7 agosto 2026 fa cadere le pietre davvero, e un sasso
  /// che tocca senza suono e' un sasso finto.
  ///
  /// **L'asset e' arrivato il 1 settembre 2026, ordine CN.** Per
  /// venticinque giorni questa voce ha vissuto col ripiego silenzioso:
  /// il catalogo la dichiarava e il file non c'era, quindi la gettata
  /// vibrava senza suonare. Dura 1,70 secondi, non 0,4 come diceva la
  /// durata attesa scritta a stima quando l'asset non esisteva.
  pietra('pietra.mp3', Duration(milliseconds: 1700)),

  /// I SEI SUONI NUOVI, ordine CN del 1 settembre 2026.
  ///
  /// Entrano dal catalogo come tutti: nessun suono nasce fuori di qui, e
  /// la guardia che lo pretende non e' stata toccata per farli entrare.
  ///
  /// La festa di un traguardo. Tre secondi e sei decimi, e non si
  /// accorcia: e' una decisione del fondatore, perche' una festa
  /// tagliata a meta' non e' una festa piu' breve, e' una festa
  /// interrotta.
  festa('festa.mp3', Duration(milliseconds: 3600)),

  /// La carta che si gira, nella stesa e nelle estrazioni. Tre quarti di
  /// secondo, secco.
  carta('carta.mp3', Duration(milliseconds: 730)),

  /// Gli Eos che arrivano nella borsa. Due secondi interi, e nemmeno
  /// questo si accorcia, per la stessa ragione della festa.
  ///
  /// **ESCE AL SESSANTACINQUE PER CENTO.** Ordine CQ, rilancio del 3
  /// settembre 2026, decisione del fondatore: il tintinnio delle monete e'
  /// piu' forte del suo momento. E' l'unico dei tredici che non esce pieno,
  /// e la ragione e' che accompagna un'animazione invece di annunciare un
  /// fatto: un accompagnamento che copre cio' che accompagna e' un
  /// accompagnamento sbagliato.
  eos('eos.mp3', Duration(milliseconds: 2000), volume: 0.65),

  /// Il sigillo di ceralacca di un ricordo custodito. Quattro decimi di
  /// secondo: e' il piu' breve dei tredici, e sui file di origine era
  /// anche il piu' debole di quindici decibel. Adesso si sente.
  custodisci('custodisci.mp3', Duration(milliseconds: 420)),

  /// IL RESPIRO CHE ENTRA, nei Doni del Giorno che guidano il respiro.
  ///
  /// **La durata qui e' quella VERA del respiro**, coi silenzi tolti:
  /// dentro il file di origine il respiro finiva al secondo 5,1 e poi
  /// c'erano due secondi di niente. Serve che sia vera, perche' e' il
  /// numero con cui si accorda la velocita' di riproduzione alla fase
  /// che la figura sta disegnando: [PassoDelRespiro] la calcola da qui.
  respiroDentro('respiro_dentro.mp3', Duration(milliseconds: 4941)),

  /// IL RESPIRO CHE ESCE. Come sopra: 6,85 secondi di respiro vero, non
  /// gli 8,2 del file di origine.
  respiroFuori('respiro_fuori.mp3', Duration(milliseconds: 6847));

  const SuonoDelCerchio(this.file, this.durataAttesa, {this.volume = 1.0});

  /// Il nome del file atteso dentro `assets/audio/`.
  final String file;

  /// Quanto dovrebbe durare, per chi sceglie l'asset.
  final Duration durataAttesa;

  /// **QUANTO FORTE ESCE, E LO DICHIARA IL SUONO.**
  /// Ordine CQ, rilancio del 3 settembre 2026.
  ///
  /// **Il fatto, parole del fondatore:** *"l'effetto audio bisogna ridurre un
  /// po' il volume"*, detto delle monete.
  ///
  /// **Sta nel catalogo e non nel motore**, per la stessa ragione per cui ci
  /// sta la durata: e' una proprieta' del suono, non del lettore. Un
  /// abbassamento scritto dentro il motore varrebbe per tutti e tredici, e
  /// per abbassarne uno solo bisognerebbe scrivere un caso speciale in un
  /// posto dove i suoni non hanno un nome.
  ///
  /// **Le normalizzazioni dell'ordine CN restano intere.** Li' i tredici file
  /// sono stati portati alla stessa forza misurata in LUFS, cioe' resi
  /// confrontabili fra loro; questo numero e' una decisione sopra quella
  /// misura, per un suono che il fondatore sente troppo forte nel suo
  /// momento. Uno non sostituisce l'altra.
  final double volume;

  /// Il percorso completo dell'asset.
  String get percorso => 'audio/$file';
}
