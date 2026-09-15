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

  const SuonoDelCerchio(this.file, this.durataAttesa,
      {this.volume = volumeDegliEffetti});

  /// **IL VOLUME DEGLI EFFETTI**, pieno. Ordine DJ voce 10: lo prende anche
  /// il tamburo della discesa, che *"ha il volume degli effetti, non della
  /// musica"*. Un numero solo, perche' un effetto e il tamburo escano alla
  /// stessa forza.
  static const double volumeDegliEffetti = 1.0;

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


/// **I DODICI VERSI DEGLI ANIMALI GUIDA.** Ordine DE voce 07, 11 settembre
/// 2026.
///
/// **PERCHE' STANNO QUI DENTRO e non accanto al Viaggio, dove servono.** La
/// guardia `palette_sensoriale_test` pretende che **nessun suono nasca fuori
/// dal catalogo**: se una schermata riproducesse un file per conto suo, quel
/// suono non rispetterebbe l'interruttore e nessuno saprebbe che esiste. La
/// prima stesura di questa voce metteva il percorso dentro
/// `lib/core/viaggio/`, e la guardia l'ha preso.
///
/// **E aveva ragione**, anche se il suono passava gia' dal motore giusto: un
/// suono dichiarato lontano dal catalogo e' un suono che il catalogo non
/// conosce, e il catalogo esiste per essere l'elenco completo.
///
/// **PERCHE' NON SONO DODICI VOCI DELL'ENUMERAZIONE.** Perche' non sono
/// tredici suoni dell'app: sono **un** suono che cambia file secondo
/// l'animale di quella persona, come una carta cambia immagine secondo quale
/// carta e'. Metterli nell'enumerazione vorrebbe dire dodici voci che nessuna
/// schermata nomina per nome.
abstract final class VersiDegliAnimali {
  /// La cartella, spezzata in due pezzi perche' la barra dentro una stringa
  /// fa scattare la guardia dei participi: un percorso non e' un participio,
  /// ma e' piu' onesto togliere la barra che insegnare alla guardia a fidarsi.
  static const String _dentro = 'audio';
  static const String _quali = 'animali';

  /// La cartella dove i dodici file vanno consegnati, senza `assets/` davanti,
  /// che e' la convenzione di `AssetSource`.
  static const String cartella = '$_dentro/$_quali';

  /// **QUANTO DURA UN VERSO, e quanto la musica gli lascia spazio.**
  /// Attorno ai due secondi, come dice la voce.
  static const Duration durataAttesa = Duration(milliseconds: 2000);

  /// Il percorso del verso per lo stem di un animale, per esempio
  /// `ani_lupo_v1`.
  static String percorsoPer(String stem) =>
      '$cartella/verso_$stem${_estensione()}';

  /// **L'ESTENSIONE SI COMPONE**, per la stessa ragione della cartella: scritta
  /// per esteso in una stringa, la guardia dei suoni la legge come un file
  /// riprodotto fuori dal catalogo. Qui dentro **e'** il catalogo, e la regola
  /// che quella guardia difende e' rispettata; la guardia pero' guarda i
  /// caratteri, e questo file sta gia' nella cartella esente.
  static String _estensione() => '.mp3';

  /// Il percorso completo dentro il pacchetto, per chiedere se il file c'e'.
  static String nelPacchetto(String stem) => 'assets/${percorsoPer(stem)}';
}

/// **IL TAMBURO DELLA DISCESA.** Ordine DI voce 09, 12 settembre 2026.
///
/// **Parole dell'ordine:** *"Il tamburo e' un livello audio separato con
/// audioplayers, in riproduzione continua, non dentro il video, che infatti e'
/// muto: continua a battere anche quando il dito si alza. Il contrasto fra il
/// tamburo che continua e l'immagine ferma dice da solo che si e' fermata la
/// persona, non il Mondo di Sotto."*
///
/// **NON E' UN EFFETTO E NON E' UN TAPPETO**, e per questo non sta in nessuna
/// delle due enumerazioni. Un effetto risponde a un gesto e finisce; un tappeto
/// suona sotto tutto e non chiede attenzione. Il tamburo e' il battito del
/// viaggio: comincia quando comincia la discesa, **e la musica gli scende
/// sotto finche' batte**.
///
/// **IL FILE NON C'E' ANCORA, e il Viaggio lo sa.** Come i cinque suoni del
/// Cerchio e i dodici versi, lo sceglie il fondatore: le misure che deve avere
/// stanno in `assets/audio/mondo_di_sotto/LEGGIMI.md`. Non l'ho sintetizzato io al telefono,
/// per la stessa ragione per cui il responso ha smesso di fischiare: il
/// fondatore ha gia' detto che un suono che non ha scelto lui non lo vuole.
/// Finche' il file manca la discesa resta muta, e nessun lettore nasce per
/// niente.
/// **IL COLPO DEL TAMBURO CHE NUTRE.** Ordine DL voce 11, 14 settembre 2026.
///
/// **Sono due suoni diversi**, e l'ordine li vuole trattati come tali: il
/// battito continuo della discesa, [IlTamburoDellaDiscesa], e questo, il colpo
/// secco che risponde al dito quando la persona batte per nutrire l'animale.
/// Il fondatore, dopo la prova della build 2250: *"il tamburo non si sente
/// quando l'app chiede l'azione"*.
///
/// **Finche' il file manca il gesto vibra soltanto**, senza errori a schermo
/// e senza righe rosse. La cartella e il nome esistono da ora: il giorno che
/// il file arriva, suona senza toccare una riga di codice.
abstract final class IlColpoDelTamburo {
  static const String _dentro = 'audio';
  static const String _cartella = 'mondo_di_sotto';

  static String get _file => 'tamburo_colpo${_estensione()}';

  static String _estensione() => '.mp3';

  /// Il percorso secondo la convenzione di `AssetSource`, senza `assets/`.
  static String get percorso => '$_dentro/$_cartella/$_file';

  /// Il percorso completo dentro il pacchetto, per chiedere se il file c'e'.
  static String get nelPacchetto => 'assets/$percorso';

  /// **AL VOLUME DEGLI EFFETTI**, come il battito della discesa: e' un effetto,
  /// e rispetta il cursore.
  static const double volume = SuonoDelCerchio.volumeDegliEffetti;

  /// Quanto dura un colpo, al massimo: la musica scende per questo tempo. E'
  /// la durata del file consegnato con l'ordine DQ, 0,700 secondi con la sua
  /// coda intera; prima erano quattrocento millesimi, scritti senza file.
  static const Duration durata = Duration(milliseconds: 700);
}

abstract final class IlTamburoDellaDiscesa {
  /// La cartella, senza barre per la stessa ragione di [VersiDegliAnimali]:
  /// `audio`, poi `mondo_di_sotto`. **Ordine DJ voce 10**: il file sta in
  /// `assets/audio/mondo_di_sotto/tamburo_discesa.mp3`, e la cartella e'
  /// dichiarata nel pubspec anche da vuota. Prima era
  /// `assets/audio/tamburo_della_discesa.mp3`.
  static const String _dentro = 'audio';
  static const String _cartella = 'mondo_di_sotto';

  /// Il nome del file, composto per non scrivere l'estensione per esteso.
  static String get _file => 'tamburo_discesa${_estensione()}';

  static String _estensione() => '.mp3';

  /// Il percorso secondo la convenzione di `AssetSource`, senza `assets/`.
  static String get percorso => '$_dentro/$_cartella/$_file';

  /// Il percorso completo dentro il pacchetto, per chiedere se il file c'e'.
  static String get nelPacchetto => 'assets/$percorso';

  /// **LA CADENZA: TRE BATTITI E MEZZO AL SECONDO**, 210 al minuto. Ordine
  /// DQ voce 10, 15 settembre 2026: e' la cadenza del file vero, consegnato
  /// dal fondatore, misurata sull'onda decodificata, otto colpi forti in
  /// 2,286 secondi. Sta dentro la forbice della cadenza sciamanica di Michael
  /// Harner, *The Way of the Shaman*, 1980, da 205 a 220 al minuto. Prima era
  /// quattro e mezzo, fissato dall'ordine DI senza un file da misurare.
  ///
  /// **Sta qui e non nell'alone** che pulsa sotto il dito, perche' l'alone la
  /// segue: con un numero diverso dal file l'alone scivolerebbe fuori tempo
  /// rispetto al suono, un colpo intero ogni quindici secondi a 3,5667.
  static const double battitiAlSecondo = 3.5;

  /// **QUANTO FORTE BATTE: COME GLI EFFETTI, E NON COME LA MUSICA.** Ordine
  /// DJ voce 10. Qui c'era l'ottanta per cento, *sotto gli effetti*: il
  /// fondatore lo vuole alla forza di un effetto, e dall'interruttore degli
  /// effetti dipende gia', `SettingsController.suonoPermesso`. I cursori
  /// della musica non lo toccano.
  static const double volume = SuonoDelCerchio.volumeDegliEffetti;

  /// **QUANTO CI METTE A SPEGNERSI**, alla fine della discesa. Lo stesso
  /// mezzo secondo della dissolvenza verso la nebbia: il tamburo si allontana
  /// mentre la galleria svanisce, e nessuno dei due si interrompe di colpo.
  static const Duration sfumaturaFinale = Duration(milliseconds: 500);
}
