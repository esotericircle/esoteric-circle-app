import '../maestri/rotta_arte.dart';
import '../maestri/widgets/foglio_delle_fonti.dart';
import 'dart:async';
import '../maestri/chat/chat_openers.dart';
import '../ricordi/azioni_del_responso.dart';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';

import '../../core/identity/birth_identity.dart';
import '../../core/identity/profile_controller.dart';
import '../../core/maestro/maestro.dart';
import '../../core/permissions/app_permission.dart';
import '../../core/permissions/avviso_del_permesso.dart';
import '../../core/permissions/esito_del_permesso.dart';
import '../../core/rituals/daily_elements.dart';
import '../../core/rituals/forma_del_soffio.dart';
import '../../core/rituals/dawn_gift.dart';
import '../../design_system/theme/abito_del_responso.dart';
import '../../core/rituals/ritual_streak.dart';
import '../../design_system/components/guida_del_respiro.dart';
import '../../design_system/theme/accento_del_maestro.dart';
import '../../design_system/components/cosmos_background.dart';
import '../../design_system/theme/maestro_palette.dart';
import 'forma_del_dono.dart';
import '../../services/ai/registro_dei_guasti.dart';
import '../../design_system/components/titolo_che_non_si_rompe.dart';
import 'soffione_inciso.dart';
import '../sigilli/regia_del_cammino.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../core/rituals/tempi_del_respiro.dart';
import '../../core/astro/natal_chart.dart';
import '../../core/astro/natal_chart_controller.dart';
import '../../core/horoscope/cielo_di_oggi.dart';
import '../../core/rituals/risposta_del_soffio.dart';
import 'ritual_gift_card.dart';
import '../../core/condivisione/premio_della_condivisione.dart';
import '../../design_system/transizioni/passaggio_del_cerchio.dart';
import '../../design_system/typography/paragrafi_di_lettura.dart';
import 'soffio_share_card.dart';

/// Soffio del Destino, dominio Aura.
///
/// Stesso impianto degli altri riti, fondale piu' dono, con un motore proprio a
/// livelli composti in un solo canvas: il prato del mattino con l'alone verde di
/// Aura, il soffione al centro coi pappi luminosi in additivo, e i semi che, al
/// soffio, si staccano e volano via come scintille disegnate dal codice, a
/// comporre il visivo del dono. Il gesto e' il microfono, col ripiego di
/// spazzare col dito o tenere premuto. Sotto Riduci Movimento i semi volano via
/// subito. Il dono e' quello di Aura, fondato ma provvisorio, mai inventato.
/// LE SUPERFICI DEL SOFFIO, dichiarate dove si dipingono.
///
/// **Perche' esistono.** Due cose in questa schermata si leggevano male, e non
/// per il colore del testo: perche' non avevano nessuna superficie sotto. Il
/// contatore dei giri stava sui raggi del soffione e le due righe della
/// Risposta sul prato, che nella fase di luce piena e' chiaro: testo chiaro su
/// fondo chiaro, con un contrasto che nessuna scelta di tinta poteva salvare.
///
/// Il rimedio non e' scurire il testo, che sul prato scuro tornerebbe
/// illeggibile al contrario: e' dare a quel testo un velo suo, e misurare il
/// contrasto contro il velo invece che contro una scena che cambia.
class SuperficiDelSoffio {
  const SuperficiDelSoffio._();

  /// Il velo dietro il testo: scuro e quasi opaco, cosi' regge il contrasto
  /// qualunque cosa la scena stia facendo sotto.
  ///
  /// **E' lo stesso della guida del respiro, letto da li'**: il conteggio dei
  /// giri e la Risposta stanno sulla stessa schermata, e due veli diversi si
  /// vedrebbero come due rettangoli di grigio diverso a un dito di distanza.
  static const Color velo = veloDelConteggio;

  /// L'inchiostro del contatore dei giri, letto dalla guida che lo dipinge.
  static const Color inchiostro = inchiostroDelConteggio;

  /// Le due righe della Risposta: la prima piena, la seconda in tono minore.
  static const Color inchiostroDellaRisposta = Color(0xFFF3EFE6);
  static const Color inchiostroSecondarioDellaRisposta = Color(0xFFCFC9BC);

  /// DOVE CADE IL DISCO LUMINOSO, in frazioni della scena.
  ///
  /// **E' il centro di due cose, non di una.** Il disco lo dipinge il painter e
  /// l'anello del respiro lo dispone il layout: erano due centri decisi in due
  /// sistemi diversi, il primo a 0,26 dell'altezza del corpo e il secondo
  /// dentro una colonna allineata a -0,2 di una zona flex, quindi non potevano
  /// coincidere per costruzione, e a video si leggeva come un difetto di
  /// stampa.
  ///
  /// **E' l'anello a inseguire il disco, non il contrario.** Il disco cresce
  /// col soffio fin dal primo istante, mentre l'anello nasce solo a gesto
  /// compiuto: spostare il disco sull'anello avrebbe prodotto un salto proprio
  /// a meta' del rito.
  /// **ALZATO DA 0,26 A 0,20. Ordine EF voce 01, seconda passata.**
  ///
  /// **Il fatto del fondatore, verbatim**: *"l'AREA DEDICATA ALLA DESCRIZIONE
  /// IN BASSO E' TROPPO PICCOLA, TI HO FATTO ALZARE TUTTO, SIA IL FIORE CHE
  /// IL PULSANTE, PER ALZARE LA BOLLA DELLA DESCRIZIONE!"*. La prima passata
  /// di quest'ordine aveva tolto il riquadro da sopra la figura e si era
  /// fermata li': misurata, la bolla aveva guadagnato **mezzo punto
  /// percentuale**, cioe' niente. Alzare la figura e' l'unico modo di dare
  /// spazio a cio' che sta sotto.
  static const Offset centroDelDisco = Offset(0.5, 0.148);

  /// Il centro del disco in punti, dentro una scena di [misura].
  static Offset discoDentro(Size misura) => Offset(
        misura.width * centroDelDisco.dx,
        misura.height * centroDelDisco.dy,
      );

  // ===========================================================================
  // DOVE STA IL SOFFIONE. Ordine EF voce 01, 23 settembre 2026.
  // ===========================================================================
  //
  // **Il difetto, e perche' non poteva non succedere.** Il soffione lo
  // dipingeva il pittore con numeri suoi, `h * 0.46` per il centro e
  // `h * 0.86` per l'altezza; il riquadro del respiro lo disponeva il layout
  // con un `Align` al centro della propria zona. **Due sistemi diversi che
  // decidono due posizioni sulla stessa scena si sovrappongono prima o poi**,
  // ed e' precisamente la lezione che questa classe porta scritta poche righe
  // piu' su per il disco e l'anello. Sulla build 2276 il riquadro copriva la
  // testa del soffione quasi per intero: a riposo se ne vedeva un dito sopra
  // il bordo.
  //
  // **Adesso il numero e' uno solo e lo leggono tutti e due.** Il pittore
  // prende di qui il centro e il raggio della testa; il layout prende di qui
  // il fondo della figura e ci appoggia sotto il riquadro. Non e' un margine
  // azzeccato: e' un'impossibilita' di sovrapporsi.

  /// Dove cade il centro della testa del soffione, in frazioni della scena.
  static const Offset centroDellaTesta = Offset(0.5, 0.148);

  /// Il raggio della testa a riposo, in frazione della LARGHEZZA.
  ///
  /// **IL SETTANTA PER CENTO E' SCESO A CINQUANTOTTO, PER DECISIONE DEL
  /// FONDATORE.** Ordine EF, 23 settembre 2026.
  ///
  /// L'ordine DD voce 03 pretendeva **almeno il settanta per cento** della
  /// larghezza al culmine, e nasceva dal fondatore che diceva *"il cerchio
  /// del respiro e' piccolo"*: quel cerchio ne prendeva trentasei.
  ///
  /// **Ma una figura larga occupa anche in verticale**, e con la figura gia'
  /// attaccata al bordo di sopra l'unico spazio che restava da dare alla
  /// bolla descrittiva era il suo. Il fondatore, tre volte nello stesso
  /// giorno: *"l'AREA DEDICATA ALLA DESCRIZIONE IN BASSO E' TROPPO
  /// PICCOLA"*, *"Alza il pulsante piu' possibile verso l'alto per
  /// guadagnare spazio"*.
  ///
  /// **Cinquantotto e' molto sopra il trentasei che aveva fatto nascere la
  /// pretesa**, ed e' cio' che permette al riquadro di salire di
  /// settantatre punti. Lo scambio e' dichiarato qui e misurato nel
  /// rapporto, cosi' chi un giorno rileggesse l'ordine DD non pensi che la
  /// soglia sia stata abbassata per far passare una prova.
  static const double raggioDellaTesta = 0.177;

  /// Quanto la testa si allarga al culmine dell'inspirazione e quanto si
  /// stringe a fine espirazione.
  static const double aperturaMassima = 1.40;
  static const double chiusuraMinima = 0.80;

  /// Il centro della testa in punti, dentro una scena di [misura].
  static Offset testaDentro(Size misura) => Offset(
        misura.width * centroDellaTesta.dx,
        misura.height * centroDellaTesta.dy,
      );

  /// **QUANTO IN BASSO PUO' ARRIVARE LA FIGURA**, in frazione dell'altezza.
  ///
  /// Sotto questa riga comincia il territorio del riquadro del respiro, e il
  /// riquadro non deve mai salire sulla figura: la voce 01 lo chiede per
  /// nome. **Il limite serve perche' la larghezza da sola non basta.** Su uno
  /// schermo da 640 punti con le barre alte e il testo alla scala massima, la
  /// figura dimensionata sulla sola larghezza arrivava fino a 338 punti e il
  /// riquadro non aveva piu' dove stare: la guardia
  /// `il_riquadro_non_copre_la_figura` l'ha misurato su due geometrie della
  /// griglia, fino a **47,0 punti coperti**.
  ///
  /// **A cedere e' la figura, non il riquadro**, ed e' una scelta dichiarata:
  /// una figura un po' piu' piccola la nota chi la cerca, un riquadro che
  /// copre il disegno lo vede chiunque, e il fondatore l'ha visto.
  static const double quotaMassimaDellaFigura = 0.46;

  /// Di quanto il SOFFIONE si stringe perche' ci stia, da zero a uno.
  ///
  /// **Su uno schermo comodo vale uno e non cambia niente** di cio' che il
  /// fondatore ha gia' approvato: si stringe solo dove la figura non ci
  /// starebbe.
  static double scalaDelSoffione(Size misura) => _quantoStringere(
        misura,
        centro: testaDentro(misura).dy,
        sopraIlCentro: misura.width *
            raggioDellaTesta *
            aperturaMassima *
            SoffioneInciso.sporgenzaDelPappo,
        fondoNudo: _fondoNudoDelSoffione(misura),
      );

  /// Di quanto il DONO si stringe perche' ci stia.
  ///
  /// **DUE FIGURE, DUE MISURE, ed e' la correzione che ha dato spazio alla
  /// bolla.** La prima stesura teneva una scala sola, presa sulla piu' bassa
  /// delle due figure, e la piu' bassa e' lo stelo del soffione: **ma durante
  /// il respiro il soffione non c'e' piu'**, e' volato via. Il riquadro del
  /// respiro stava quindi sotto l'ingombro di una cosa che in quel momento
  /// non e' a schermo, e regalava alla bolla mezzo punto invece di
  /// venticinque.
  static double scalaDelDono(Size misura) => _quantoStringere(
        misura,
        centro: discoDentro(misura).dy,
        sopraIlCentro: FormaDelDono.raggio(misura.width, 1.0,
            apertura: FormaDelDono.aperturaMassima),
        fondoNudo: _fondoNudoDelDono(misura),
      );

  /// Quanto stringere una figura perche' stia **dentro tutti e due i bordi**.
  ///
  /// **La prima stesura guardava solo il bordo di sotto**, e bastava alzare
  /// la figura per dare spazio alla bolla perche' uscisse di sopra: sullo
  /// schermo da 640 punti la testa al culmine sforava di trenta punti. La
  /// guardia `il_riquadro_non_copre_la_figura` l'ha preso subito, ed e' il
  /// motivo per cui quella guardia guarda anche la cima.
  static double _quantoStringere(
    Size misura, {
    required double centro,
    required double sopraIlCentro,
    required double fondoNudo,
  }) {
    // Di sotto: non oltre la quota, dove comincia cio' che sta sotto.
    final disponibile = misura.height * quotaMassimaDellaFigura;
    final sotto = fondoNudo - centro;
    final perStareSotto = sotto <= 0 ? 1.0 : (disponibile - centro) / sotto;
    // Di sopra: non oltre il bordo della scena.
    final perStareSopra = sopraIlCentro <= 0 ? 1.0 : centro / sopraIlCentro;
    return math
        .min(1.0, math.min(perStareSotto, perStareSopra))
        .clamp(0.35, 1.0);
  }

  /// Il fondo che il soffione avrebbe senza nessuna stretta.
  static double _fondoNudoDelSoffione(Size misura) {
    final rCulmine = misura.width * raggioDellaTesta * aperturaMassima;
    final rFermo = misura.width * raggioDellaTesta;
    final testa =
        testaDentro(misura).dy + rCulmine * SoffioneInciso.sporgenzaDelPappo;
    final stelo = testaDentro(misura).dy +
        rFermo * 0.10 +
        rFermo * SoffioneInciso.steloSuRaggio;
    return math.max(testa, stelo);
  }

  /// Il fondo che il dono avrebbe senza nessuna stretta.
  static double _fondoNudoDelDono(Size misura) =>
      discoDentro(misura).dy +
      FormaDelDono.raggio(misura.width, 1.0,
          apertura: FormaDelDono.aperturaMassima);

  /// Il raggio della testa in punti, col respiro gia' applicato.
  ///
  /// [respiro] arriva dalla guida nella corsa 0,55 - 1,0 e qui si apre sulla
  /// corsa vera della figura: **la guida era tarata su un cerchio, che poteva
  /// essere largo quanto si voleva; un soffione ha uno stelo e un limite.**
  static double raggioDellaTestaDentro(Size misura, {double respiro = 1.0}) {
    final quanto = chiusuraMinima +
        ((respiro - 0.55) / 0.45).clamp(0.0, 1.0) *
            (aperturaMassima - chiusuraMinima);
    return misura.width * raggioDellaTesta * quanto * scalaDelSoffione(misura);
  }

  /// Dove COMINCIA il soffione al culmine, cioe' il punto piu' alto che
  /// tocca. Sotto zero vuol dire tagliato dal bordo.
  ///
  /// **Serve perche' alzare la figura ha un limite, e non e' un'opinione.**
  /// Portando il centro a 0,165 dell'altezza per dare spazio alla bolla, la
  /// testa al culmine sarebbe uscita di **tredici punti** sopra il bordo: la
  /// voce 01 chiede che il soffione si veda **per intero**, e una figura
  /// tagliata in cima non lo e'.
  static double cimaDelSoffione(Size misura) =>
      testaDentro(misura).dy -
      misura.width *
          raggioDellaTesta *
          aperturaMassima *
          scalaDelSoffione(misura) *
          SoffioneInciso.sporgenzaDelPappo;

  /// Dove comincia il dono al culmine del respiro.
  static double cimaDelDono(Size misura) =>
      discoDentro(misura).dy -
      FormaDelDono.raggio(misura.width, 1.0,
              apertura: FormaDelDono.aperturaMassima) *
          scalaDelDono(misura);

  /// Dove finisce il soffione, stelo e ombrellini compresi, **al culmine**.
  ///
  /// Si misura sempre al culmine e mai alla misura del momento: una riga che
  /// si sposta col respiro farebbe ballare cio' che sta sotto a ogni
  /// inspirazione.
  ///
  /// **Lo legge l'invito al gesto**, che vive nella fase in cui il soffione
  /// c'e'.
  static double fondoDelSoffione(Size misura) {
    final k = scalaDelSoffione(misura);
    final rCulmine = misura.width * raggioDellaTesta * aperturaMassima * k;
    final rFermo = misura.width * raggioDellaTesta * k;
    final testa =
        testaDentro(misura).dy + rCulmine * SoffioneInciso.sporgenzaDelPappo;
    final stelo = testaDentro(misura).dy +
        rFermo * 0.10 +
        rFermo * SoffioneInciso.steloSuRaggio;
    return math.max(testa, stelo);
  }

  /// Dove finisce il dono al culmine del respiro.
  ///
  /// **Lo legge il riquadro del respiro**, che vive nella fase in cui a
  /// schermo c'e' il dono e il soffione non c'e' piu'.
  static double fondoDelDono(Size misura) =>
      discoDentro(misura).dy +
      FormaDelDono.raggio(misura.width, 1.0,
              apertura: FormaDelDono.aperturaMassima) *
          scalaDelDono(misura);

  /// **QUI C'ERA `fondoDellaFigura`, ED E' STATO IL DIFETTO DELLA PRIMA
  /// PASSATA.** Prendeva la piu' bassa fra le due figure, per non far
  /// saltare il riquadro fra una fase e l'altra. Sembra prudente e invece
  /// **regalava alla bolla lo spazio dello stelo di un soffione che durante
  /// il respiro non e' nemmeno a schermo**: la bolla ha guadagnato mezzo
  /// punto percentuale, e il fondatore l'ha visto subito.
  ///
  /// Adesso ogni fase legge il fondo della figura che ha davvero davanti:
  /// l'invito al gesto guarda [fondoDelSoffione], il riquadro del respiro
  /// guarda [fondoDelDono]. Il riquadro non salta, perche' nella fase in cui
  /// esiste la figura e' una sola.
}

class BreathDestinyScreen extends StatefulWidget {
  const BreathDestinyScreen({super.key, this.now});

  final DateTime? now;

  static Route<void> route({DateTime? now}) => PassaggioDelCerchio.rotta<void>(
      (_) => MaestroScope(child: BreathDestinyScreen(now: now)));

  @override
  State<BreathDestinyScreen> createState() => _BreathDestinyScreenState();
}

class _BreathDestinyScreenState extends State<BreathDestinyScreen>
    with TickerProviderStateMixin {
  // Dispersione dei semi, da 0 (testa piena) a 1 (dono rivelato).
  double _progress = 0;
  bool _revealed = false;
  DawnGift? _gift;
  int _streak = 0;

  /// LA RISPOSTA DEL SOFFIO, dai transiti veri. Nulla quando il cielo non e'
  /// stato interrogato davvero, e in quel caso non compare niente al posto
  /// suo: una risposta senza cielo sarebbe un oroscopo da giornale.
  RispostaDelSoffio? _risposta;

  /// L'ESITO DEL PERMESSO DEL MICROFONO, nei suoi tre valori distinti.
  ///
  /// Ordine 2166, voce 2. Prima qui c'era solo il silenzio: `hasPermission`
  /// torna si' o no, e un no valeva per tutti e due i no. Chi aveva negato
  /// per sempre non vedeva comparire nessun dialogo e non veniva avvisato di
  /// niente: il rito sembrava sordo. Adesso l'esito arriva dalla porta unica
  /// e la scena lo dice.
  EsitoDelPermesso? _esitoDelMicrofono;

  late final AnimationController _disperse;
  Animation<double>? _disperseAnim;
  late final AnimationController _ambient; // brezza e brillio

  // IL PRATO NON SI CARICA PIU', ordine P voce 26: il fondale e' il cosmo
  // condiviso, e un asset che nessuno dipinge sarebbe memoria decodificata per
  // niente.

  final AudioRecorder _recorder = AudioRecorder();
  StreamSubscription<Uint8List>? _micStream;

  /// **CHI DECIDE SE QUELLO ERA UN SOFFIO.** Ordine DD voce 01: guarda la
  /// forma dello spettro invece del volume, e vuole due decimi di secondo di
  /// aria continua prima di aprire il dono.
  final FormaDelSoffio _formaDelSoffio = FormaDelSoffio();

  /// **NESSUNO CI SCRIVE PIU' DENTRO, DAL 10 SETTEMBRE 2026.** Ordine DD voce
  /// 01: il flusso dell'ampiezza aggregata era la sorgente della soglia di
  /// volume, e la soglia di volume era il difetto. Adesso decide la forma
  /// dello spettro, che legge i campioni veri.
  ///
  /// **Il campo resta, e la sua chiusura anche.** Se un giorno qualcuno
  /// riaccende l'ampiezza per mostrare una barra di livello, la trova gia'
  /// spenta al momento giusto invece di lasciare il microfono acceso dietro
  /// una schermata chiusa.
  StreamSubscription<Amplitude>? _micAmplitude;

  // Distanza di spazzata sul soffione che disperde del tutto i semi.
  static const double _sweepSpan = 240;
  static const double _completeThreshold = 0.5;

  @override
  void initState() {
    super.initState();
    _disperse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      // **QUESTA E' LA CAUSA VERA, E NON ERA "LE ANIMAZIONI SPENTE".**
      // Ordine EF, 23 settembre 2026.
      //
      // **Il fatto del fondatore, verbatim**: *"il soffio sonoro ha
      // funzionato, ma l'immagine e' cambiata di botto e non c'e' stata
      // animazione con i petali che si sono staccati e allontanati dal
      // centro del soffione"*.
      //
      // **Flutter, quando la piattaforma dichiara `disableAnimations`, non
      // spegne le animazioni: ne moltiplica la durata per 0,05**, cioe' le
      // fa correre venti volte piu' in fretta. E' il comportamento di
      // `AnimationBehavior.normal`, che e' quello di partenza. Su Android
      // `disableAnimations` e' la scala di durata degli animatori, un numero
      // che moltissimi mettono a zero per far sembrare il telefono piu'
      // rapido: sul Realme del fondatore e' a zero.
      //
      // Quindi **il volo dei semi durava quarantacinque millisecondi invece
      // di novecento**: girava, e finiva prima che l'occhio la vedesse. Da
      // qui *"e' cambiata di botto"*.
      //
      // `AnimationBehavior.preserve` e' il modo documentato di dire che
      // **questa animazione e' il contenuto e non un abbellimento**: il volo
      // dei semi e' il gesto del rito, non una transizione.
      animationBehavior: AnimationBehavior.preserve,
    )..addListener(() {
        final anim = _disperseAnim;
        if (anim != null) setState(() => _progress = anim.value);
      });
    _ambient = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
      // Otto secondi di respiro d'aria diventerebbero quattro decimi: non
      // un'ambientazione, uno stroboscopio.
      animationBehavior: AnimationBehavior.preserve,
    )..repeat();
    // **NIENTE PIU' LIVELLI DA CARICARE. Ordine EF voce 03.**
    //
    // Qui si caricava `breath_dandelion.png`, la fotografia del soffione, e
    // quel caricamento non era solo lento: **era la ragione per cui questa
    // schermata era cieca alle prove**. Il pittore usciva subito quando
    // l'immagine mancava, e sotto `flutter test` mancava sempre, quindi
    // nessuna misura sul layout poteva vedere il soffione. Adesso il
    // soffione e' disegnato, `SoffioneInciso`, e c'e' anche nelle prove.
    _startMic();
  }

  // Chiede il permesso del microfono e ascolta il livello audio: un soffio e' un
  // picco d'ampiezza. Se il permesso e' negato o il microfono non c'e', resta il
  // ripiego tattile, senza mai sollevare un errore.
  Future<void> _startMic() async {
    try {
      // LA PORTA UNICA: torna i tre esiti distinti, non un si' o un no.
      final esito = await PortaDelPermesso.chiedi(
        AppPermission.microphone,
        richiestaDiSistema: _recorder.hasPermission,
      );
      if (mounted) setState(() => _esitoDelMicrofono = esito);
      if (esito != EsitoDelPermesso.concesso) return;
      final stream = await _recorder.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          numChannels: 1,
          sampleRate: 16000,
        ),
      );
      // **IL SOFFIO SI RICONOSCE DALLA FORMA, NON DAL VOLUME. Ordine DD
      // voce 01, 10 settembre 2026.**
      //
      // **Il fatto del fondatore**: il Soffio si apre da solo, basta un
      // rumore nella stanza.
      //
      // **Qui c'erano due righe, e sono il difetto per intero.** La prima
      // buttava via il flusso audio: `stream.listen((_) {})`. La seconda
      // guardava l'ampiezza aggregata e apriva il dono sopra i meno diciotto
      // decibel: **una soglia di volume nuda**, che la voce di chi parla, la
      // musica in cucina e una porta che sbatte superano tutte.
      //
      // **Misurato sui quattro campioni della guardia**: la soglia di volume
      // apriva il dono su **tre suoni su tre** che non erano soffi. La forma
      // ne apre **zero**.
      //
      // **Non si e' aperta nessuna porta nuova**: i campioni passavano gia'
      // di qui e venivano scartati. Adesso vanno a [FormaDelSoffio], che
      // guarda quanto e' **piatto** lo spettro, non quanto e' forte il suono:
      // l'aria non ha una nota dentro, la voce e la musica si'.
      _formaDelSoffio.ricomincia();
      // **IL MICROFONO DICE SE HA SENTITO. Ordine EF voce 04.**
      //
      // **Il fatto del fondatore, verbatim**: *"se soffio al microfono, NON
      // FUNZIONA, DEVO PER FORZA USARE IL DITO!"*. Il permesso sul suo
      // Realme risultava **concesso**, quindi la causa stava piu' avanti, e
      // qui non c'era niente che la potesse dire: i campioni entravano,
      // venivano misurati e nessuno sapeva con che numeri.
      //
      // Qui si tiene il conto di cio' che e' passato: quanti campioni sono
      // arrivati e quanto e' stata piatta la cosa piu' piatta che si e'
      // sentita. **Non e' strumentazione da buttare dopo**: e' cio' che
      // distingue "il microfono non arriva" da "il microfono arriva e la
      // soglia non scatta", e sono due guasti diversi con due cure diverse.
      _micStream = stream.listen((byte) {
        if (_revealed) return;
        _campioniDalMicrofono += byte.length;
        _formaDelSoffio.aggiungiCampioni(byte);
        if (_formaDelSoffio.planarita > _planaritaMassimaSentita) {
          _planaritaMassimaSentita = _formaDelSoffio.planarita;
        }
        // **E L'ENERGIA, perche' senza di lei il rapporto non decide
        // niente.** La planarita' vale zero per due ragioni diverse: o il
        // suono non e' piatto, o non e' arrivato abbastanza forte da essere
        // misurato, perche' sotto `energiaMinima` la finestra si scarta
        // prima. Con le due grandezze accanto il rapporto dice **quale dei
        // due filtri** ha fermato il soffio.
        if (_formaDelSoffio.energia > _energiaMassimaSentita) {
          _energiaMassimaSentita = _formaDelSoffio.energia;
        }
        // Una riga ogni due secondi circa, e non a ogni pacchetto: serve a
        // sapere **con che numeri** il microfono del telefono sente, e
        // trentadue righe al secondo non le legge nessuno.
        if (_campioniDalMicrofono ~/ 64000 != _ultimoRapportoDelMicrofono) {
          _ultimoRapportoDelMicrofono = _campioniDalMicrofono ~/ 64000;
          debugPrint('SOFFIO: campioni $_campioniDalMicrofono, energia più '
              'alta ${_energiaMassimaSentita.toStringAsFixed(5)} su '
              '${FormaDelSoffio.energiaMinima}, planarità più alta '
              '${_planaritaMassimaSentita.toStringAsFixed(3)} su '
              '${FormaDelSoffio.planaritaMinima}');
        }
        if (_formaDelSoffio.eSoffio) _complete();
      }, onError: (Object errore, StackTrace traccia) {
        GuastiVersoIlCruscotto.inoltro
            ?.call('soffio, flusso del microfono', errore, traccia);
        debugPrint('SOFFIO: il flusso del microfono è caduto. $errore');
      });
    } catch (errore, traccia) {
      // **NIENTE PIU' CATCH MUTO QUI. Ordine EF voce 04.**
      //
      // Questo `catch (_)` vuoto e' la ragione per cui il soffio al
      // microfono poteva essere rotto da settimane senza che nessuno lo
      // sapesse: se `startStream` non riesce sul telefono, il rito resta
      // compibile col dito e **sembra che vada tutto bene**. Il ripiego
      // tattile resta, ed e' obbligatorio, ma il guasto adesso si scrive.
      GuastiVersoIlCruscotto.inoltro
          ?.call('soffio, apertura del microfono', errore, traccia);
      debugPrint('SOFFIO: il microfono non si è aperto. $errore');
    }
  }

  /// Quanti byte di audio sono arrivati dal microfono da quando la schermata
  /// e' aperta. Zero vuol dire che il microfono non parla, ed e' un guasto
  /// diverso da una soglia che non scatta.
  int _campioniDalMicrofono = 0;

  /// La planarita' piu' alta sentita: se resta molto sotto
  /// `FormaDelSoffio.planaritaMinima` anche mentre la persona soffia, allora
  /// il microfono arriva e a non scattare e' il riconoscimento.
  double _planaritaMassimaSentita = 0;

  /// L'energia piu' alta sentita, da confrontare con
  /// `FormaDelSoffio.energiaMinima`.
  double _energiaMassimaSentita = 0;

  /// A che blocco di due secondi si e' fermato l'ultimo rapporto.
  int _ultimoRapportoDelMicrofono = -1;

  Future<void> _stopMic() async {
    await _micAmplitude?.cancel();
    await _micStream?.cancel();
    try {
      if (await _recorder.isRecording()) await _recorder.stop();
    } catch (_) {}
    await _recorder.dispose();
  }

  @override
  void dispose() {
    _stopMic();
    _disperse.dispose();
    _ambient.dispose();
    _respiro.dispose();
    super.dispose();
  }

  bool get _reduceMotion => MediaQuery.of(context).disableAnimations;

  /// LA CARTA NATALE, dalla stessa porta da cui la prende il Passaporto.
  ///
  /// Nulla quando non c'e', e allora la risposta non compare: senza carta non
  /// ci sono transiti sulla carta, e una risposta senza cielo sarebbe un
  /// oroscopo da giornale.
  NatalChart? _carta() {
    try {
      return context.read<NatalChartController>().chart;
    } catch (errore) {
      // NON E' UN GUASTO, e' un albero piu' povero: succede quando questa
      // schermata viene montata da sola, per esempio in una prova o in
      // un'anteprima, senza il fornitore della carta sopra di lei. Si dichiara
      // e si prosegue senza cielo, che e' esattamente il caso in cui la
      // risposta non deve comparire.
      debugPrint('Soffio, carta natale non raggiungibile: $errore');
      return null;
    }
  }

  BirthIdentity? _identity() {
    try {
      return context.read<ProfileController>().identity;
    } catch (_) {
      return null;
    }
  }

  // Ripiego a spazzata: il dito che scorre sul soffione disperde i semi.
  void _onPanUpdate(DragUpdateDetails d) {
    if (_revealed) return;
    _disperse.stop();
    setState(() {
      _progress = (_progress + d.delta.distance / _sweepSpan).clamp(0.0, 1.0);
    });
  }

  void _onPanEnd(DragEndDetails _) {
    if (_revealed) return;
    if (_progress >= _completeThreshold) {
      _complete();
    } else {
      _animateTo(0);
    }
  }

  // Ripiego a tocco prolungato.
  void _onLongPress() {
    if (_revealed) return;
    _complete();
  }

  /// Vero da quando il soffio e' stato riconosciuto a quando il dono si
  /// rivela.
  ///
  /// **SENZA QUESTO LA SCHERMATA RESTAVA BLOCCATA PER SEMPRE, e il difetto si
  /// vede solo sul telefono.** Ordine EF, 23 settembre 2026.
  ///
  /// Il riconoscimento del soffio, `FormaDelSoffio.eSoffio`, e' un **fermo**:
  /// una volta acceso resta acceso. Il flusso del microfono continua ad
  /// arrivare a pacchetti, e ogni pacchetto rientrava qui e faceva ripartire
  /// l'animazione **da zero**. Riavviare un `AnimationController` **annulla**
  /// il `TickerFuture` di prima, e un futuro annullato non chiama il suo
  /// `then`: quindi `_reveal()` non scattava mai. Il soffione spariva, il
  /// dono restava a meta' e l'invito *"Soffia, oppure spazza col dito"*
  /// rimaneva a video all'infinito.
  ///
  /// **Perche' nessuno l'aveva mai visto.** Il ramo di `_reduceMotion`
  /// portava il soffio a uno e chiamava `_reveal()` **nello stesso
  /// fotogramma**, senza animazione da annullare: sul telefono del fondatore,
  /// che ha la scala degli animatori a zero, la strada rotta non si
  /// percorreva. Tolto quel ramo nello stesso ordine, il blocco e' venuto a
  /// galla alla prima prova a video. **PROVENIENZA IGNOTA**: il rientro non
  /// e' mai stato guardato da nessun ordine.
  bool _soffioInCorso = false;

  void _complete() {
    if (_soffioInCorso) return;
    _soffioInCorso = true;
    // **IL VOLO DEI SEMI NON SI SPEGNE PIU'. Ordine EF, 23 settembre 2026.**
    //
    // Qui `_reduceMotion` saltava l'animazione e portava il soffio a uno in
    // un fotogramma: **il gesto del rito spariva**, i semi non volavano e il
    // dono compariva di colpo. E `_reduceMotion` legge
    // `disableAnimations`, che su Android e' la scala di durata degli
    // animatori: **un numero che moltissimi mettono a zero per far sembrare
    // il telefono piu' rapido**, non una richiesta di accessibilita'. Flutter
    // non ci obbedisce da solo, le sue animazioni girano lo stesso: era il
    // nostro codice a spegnerle.
    //
    // **Il fondatore, verbatim**: *"L'animazione del soffione ha sempre
    // funzionato, quindi non dire cazzate e sistemalo"*. Aveva ragione lui, e
    // il telefono non c'entrava.
    //
    // Cio' che resta legato a `reduceMotion` e' la **decorazione**: il
    // luccichio d'ambiente, il vento che devia i semi, l'onda dei petali. Il
    // gesto e il respiro no: sono il rito.
    _animateTo(1, onDone: _reveal);
  }

  void _animateTo(double target, {VoidCallback? onDone}) {
    _disperseAnim = Tween<double>(begin: _progress, end: target).animate(
      CurvedAnimation(parent: _disperse, curve: Curves.easeOutCubic),
    );
    _disperse.forward(from: 0).then((_) {
      if (mounted) onDone?.call();
    });
  }

  void _reveal() {
    if (_revealed) return;
    final date = widget.now ?? DateTime.now();
    setState(() {
      _revealed = true;
      // **PRIMA LA RISPOSTA DEL SOFFIO, POI IL DONO CHE LA PORTA.**
      // Ordine CQ voce 2.02, 3 settembre 2026, e l'ordine conta: il dono
      // dell'Alba nasceva prima e portava la risposta dell'Alba, cioe' la
      // stessa frase che il fondatore leggeva due ore prima.
      _risposta = RispostaDelSoffio.diOggi(
        CieloDiOggi.perIlGiorno(adesso: date, carta: _carta()),
      );
      // **IL SOFFIO NON PRENDE MAI LA RISPOSTA DELL'ALBA, con o senza
      // carta natale.** 7 settembre 2026, parole del fondatore: *"i responsi
      // di Alba e Soffio sono ancora uguali"*.
      //
      // Qui c'era `rispostaPropria: _risposta?.comeRisposta()`, e quel
      // punto interrogativo era il difetto: senza transiti veri `diOggi`
      // torna nulla, e `forMaestro` con `rispostaPropria` nulla restituisce
      // il rito dell'Alba INTERO, risposta compresa. Misurato sullo stesso giorno:
      // **senza carta le due risposte erano identiche parola per parola.**
      // La riparazione dell'ordine CQ voce 2.02 valeva solo per chi aveva
      // dato ora e luogo di nascita, e quella condizione non era scritta da
      // nessuna parte.
      //
      // Adesso una risposta c'e' sempre: col cielo se il cielo si legge,
      // altrimenti dalla Luna di oggi, che non chiede nessun dato alla
      // persona. **Dall'Alba resta soltanto la cadenza del respiro**, tempi
      // e giri, che e' la parte comune e che nel Soffio E' il gesto da
      // compiere: il rito da compiere il Soffio non lo chiede in prestito,
      // ce l'ha gia'.
      _gift = DawnGift.forMaestro(date, Maestro.aura,
          identity: _identity(),
          rispostaPropria: _risposta?.comeRisposta() ??
              RispostaDelSoffio.senzaIlTuoCielo(date));
    });
    _stopMic();
    _recordStreak(date);
  }

  Future<void> _recordStreak(DateTime date) async {
    final n = await const RitualStreak(id: 'breath').recordToday(date);
    if (!mounted) return;
    // IL CAMMINO SE NE ACCORGE: il rito e' compiuto, non aperto.
    // **IL DETTAGLIO CHE DICEVA IL FALSO E' STATO TOLTO.**
    // Ordine CP voce 03, 3 settembre 2026.
    //
    // Qui si mandava `'tenuto': ['intero']`, cioe' la dichiarazione che il
    // respiro era stato **tenuto fino alla fine senza interrompersi**, che e'
    // la frase del gradino `aur_7`. Il commento che stava qui diceva "chi esce
    // prima non passa da questa riga", ed era vero per chi esce e falso per
    // tutti e tre i modi in cui ci si arriva davvero:
    //
    // - il microfono chiude al PRIMO campione sopra la soglia, cioe' su un
    //   soffio deciso di un istante, non su un respiro tenuto;
    // - la spazzata col dito chiude quando il progresso supera la soglia, e
    //   una spazzata veloce la supera in mezzo secondo;
    // - **il tocco prolungato chiude subito, e la stessa riga e' agganciata
    //   anche a `onTap`**, quindi bastava un tocco singolo sull'etichetta.
    //
    // Nessuno dei tre misura la continuita'. **Un gesto che l'app non sa
    // misurare non si dichiara**: il Soffio manda il suo gesto e basta, e il
    // gradino che chiede il respiro tenuto trova la sua condizione nel corpus
    // nuovo dell'ordine CP, dove la condizione dice cio' che l'app sa vedere.
    unawaited(RegiaDelCammino.dopoUnGesto(context, 'soffio'));
    setState(() => _streak = n);
  }

  /// **SI CONDIVIDE CIO' CHE SI VEDE.** Ordine BB voce 06.
  ///
  /// La parola del giorno e' uscita dalla scheda, per decisione del fondatore:
  /// una parola in risalto che non chiede niente e non porta da nessuna parte
  /// occupava il posto piu' importante. **Se sparisce dallo schermo deve
  /// sparire anche di qui**, se no si condivide con gli altri una cosa che chi
  /// riceve non trovera' aprendo l'app. Resta l'orientamento del giorno, che
  /// e' cio' che il dono dice davvero.
  /// **TORNA L\'ESITO invece di ingoiarlo, ordine CG voce 06.**
  ///
  /// **E PARTE COME CARD, ordine DW voce 03.** Qui partiva un testo solo:
  /// chi lo riceveva leggeva una frase senza sapere da dove venisse. Adesso
  /// la card si disegna fuori campo, si fotografa e parte col suo testo.
  Future<bool> _shareWord(DawnGift gift) async {
    setState(() => _rendiLaCard = true);
    try {
      await WidgetsBinding.instance.endOfFrame;
      await Future<void>.delayed(const Duration(milliseconds: 80));
      final andata = await shareSoffioCard(
          boundaryKey: _cardDaCondividere,
          text: testoDelSoffioCondiviso(gift.orientation));
// Ordine BG voce 04: il premio dichiarato sul pulsante si paga qui,
// a condivisione davvero avvenuta.
      if (andata && mounted) {
        await PremioDellaCondivisione.premia(context,
            cosa: 'Hai condiviso il Soffio del Destino');
      }
      return andata;
    } catch (_) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Condivisione non disponibile ora.')),
      );
      // Un errore non e' una condivisione avvenuta, quindi non custodisce.
      return false;
    } finally {
      if (mounted) setState(() => _rendiLaCard = false);
    }
  }

  /// La card del Soffio, fuori campo: si disegna solo mentre si condivide.
  final GlobalKey _cardDaCondividere = GlobalKey();
  bool _rendiLaCard = false;

  /// LA SCENA E L'ANELLO, per misurare la distanza fra i due centri.
  ///
  /// Non si calcola a mente: si guarda dove la figura del respiro e' finita
  /// davvero e si sposta di quanto manca. Un conto fatto sui flex e sugli
  /// allineamenti sarebbe giusto oggi e falso domani, al primo padding che
  /// qualcuno cambia.
  final GlobalKey _scena = GlobalKey();

  /// **QUANTO E' APERTO IL RESPIRO, dal conteggio alla scena.** Ordine EE
  /// voce 02: la guida lo scrive, il soffione lo legge.
  final ValueNotifier<double> _respiro = ValueNotifier<double>(1);

  final GlobalKey _anello = GlobalKey();

  /// Quanto spostare l'anello perche' cada dentro il disco. Zero finche' non
  /// c'e' niente da misurare.
  double _inseguimento = 0;

  /// LA COLONNA, per sapere dove finisce DAVVERO la guida del respiro.
  /// Ordine DR voce 11.
  final GlobalKey _colonna = GlobalKey();

  /// LA GUIDA INTERA, che non e' l'anello.
  ///
  /// `_anello` sta sulla figura che deve cadere dentro il disco; sotto di lei
  /// la guida porta la parola del respiro e il pulsante, ed e' QUELLA la
  /// parte che finiva sotto la scheda. Misurare l'anello invece della guida
  /// e' l'errore che ho fatto al primo giro di questa voce: la cura non
  /// mordeva e i numeri restavano identici al punto.
  final GlobalKey _laGuida = GlobalKey();

  /// **Il fondo della FIGURA, in punti dall'alto della colonna.** Ordine EF
  /// voce 01.
  ///
  /// La geometria della figura vive in coordinate della scena, che comincia
  /// sotto la barra; il riquadro e l'invito vivono nella colonna, che
  /// comincia sotto l'area sicura. **Convertire una volta sola, a frame
  /// finito, evita che ognuno si faccia i conti suoi**, ed e' esattamente
  /// l'errore che ha prodotto questo difetto la prima volta.
  double _fondoFiguraInColonna = 0;

  /// Il fondo della guida del respiro, in punti dall'alto della colonna.
  /// Zero finche' non c'e' niente da misurare, e con zero la colonna si
  /// divide come si e' sempre divisa.
  double _fondoDellaGuida = 0;

  /// Lo spazio che resta fra il fondo della guida e il tetto della scheda.
  /// Non e' estetica: e' il margine che una misura presa a frame finito puo'
  /// sbagliare di un pelo, e che qui non deve mai diventare negativo.
  static const double respiroFraLeDueZone = 8;

  /// Misura la distanza fra i due centri e la corregge, una volta per frame.
  ///
  /// Si ferma da sola: appena i due coincidono lo scarto e' sotto il mezzo
  /// punto e non si chiede piu' nessun ridisegno.
  void _appoggiaLaGuidaSottoIlSoffione() {
    final scena = _scena.currentContext?.findRenderObject();
    if (scena is! RenderBox || !scena.hasSize) return;

    // **IL FONDO DELLA FIGURA SI MISURA SEMPRE, anche quando la guida non
    // c'e'.** Ordine EF voce 01: prima del soffio la guida del respiro non
    // esiste ancora, ma l'invito al gesto si', e anche lui deve stare sotto
    // la figura. La prima stesura di questo metodo usciva subito se la guida
    // mancava, quindi nella fase del soffio il fondo restava zero e la
    // pastiglia dell'invito finiva in cima allo schermo, **sopra i pappi**:
    // difetto visto in una cattura del banco, non nel codice.
    final colonnaPrima = _colonna.currentContext?.findRenderObject();
    if (colonnaPrima is RenderBox && colonnaPrima.hasSize) {
      final fondo = colonnaPrima
          .globalToLocal(scena.localToGlobal(
              Offset(0, SuperficiDelSoffio.fondoDelSoffione(scena.size))))
          .dy;
      if ((fondo - _fondoFiguraInColonna).abs() >= 0.5 && mounted) {
        setState(() => _fondoFiguraInColonna = fondo);
      }
    }

    final guidaBox = _laGuida.currentContext?.findRenderObject();
    if (guidaBox is! RenderBox || !guidaBox.hasSize) return;

    // **QUI SI INSEGUIVA UN ANELLO CHE NON ESISTE PIU'. Ordine EF voce 01.**
    //
    // Questo metodo si chiamava `_allineaLAnello` e portava il centro della
    // figura del respiro sul centro del disco luminoso, a 0,26 dell'altezza.
    // Aveva senso finche' la figura era un cerchio d'oro. **L'ordine EE voce
    // 02 ha svuotato quella figura**, `figura: const SizedBox.shrink()`,
    // perche' a respirare doveva essere il soffione: da quel momento la
    // rincorsa inseguiva **un punto largo zero**, e trascinava tutto il
    // riquadro del respiro fin sopra la testa del soffione. Sulla cattura
    // della 2276 il riquadro la copriva quasi per intero.
    //
    // **Padre: ordine EE voce 02**, che ha tolto il soggetto e lasciato viva
    // la rincorsa.
    //
    // Adesso non si insegue niente: **si appoggia**. Il tetto del riquadro va
    // sotto il fondo dichiarato del soffione, e i due numeri vengono dallo
    // stesso posto, quindi non possono sovrapporsi per costruzione.
    final tettoAttuale =
        scena.globalToLocal(guidaBox.localToGlobal(Offset.zero)).dy;
    // Il riquadro del respiro guarda il DONO: nella sua fase il soffione e'
    // gia' volato via.
    final fondoFigura = SuperficiDelSoffio.fondoDelDono(scena.size);
    final voluto = fondoFigura + respiroFraLeDueZone;
    final manca = voluto - tettoAttuale;

    // **E SI MISURA ANCHE DOVE LA GUIDA FINISCE. Ordine DR voce 11.**
    //
    // L'anello insegue il disco, e il disco sta nella SCENA, cioe' nello
    // schermo intero. La scheda invece stava sotto una zona decisa da un
    // rapporto fisso della colonna. Due autorita' diverse sullo stesso asse:
    // qualunque rapporto si scelga, c'e' uno schermo dove la guida arriva
    // piu' in basso di dove quel rapporto la lascerebbe stare, e la scheda,
    // che si dipinge dopo, se la mangia. E' cosi' che il difetto e' tornato.
    //
    // Qui si prende la stessa autorita' e la si da' anche alla scheda: dove
    // finisce la guida lo dice la guida, misurata a frame finito, non un
    // numero deciso a mano.
    final colonna = _colonna.currentContext?.findRenderObject();
    final guida = _laGuida.currentContext?.findRenderObject();
    var fondo = _fondoDellaGuida;
    if (colonna is RenderBox &&
        colonna.hasSize &&
        guida is RenderBox &&
        guida.hasSize) {
      // `localToGlobal` attraversa la traslazione, quindi questo e' il fondo
      // DIPINTO, non quello che la guida avrebbe se stesse ferma.
      final basso = guida.localToGlobal(Offset(0, guida.size.height));
      fondo = colonna.globalToLocal(basso).dy;
    }
    // **E L'INSEGUIMENTO SI FERMA AL BORDO.**
    //
    // **Il fatto misurato**: su uno schermo da 640 punti con novantasei punti
    // di barre e il testo alla scala massima, la guida **non ci sta**, e non
    // per colpa della colonna: il disco che insegue sta nella scena, e la
    // rincorsa la trascinava sotto il bordo. Li' il pulsante finiva fuori
    // dallo schermo utile, che e' tagliato uguale, solo da un altro bordo.
    //
    // **Cosa si sceglie, e si dichiara.** In quella geometria l'anello resta
    // un po' sopra il centro del disco invece che dentro, e la bolla resta
    // tutta leggibile e premibile. E' l'unico scambio possibile fra le due
    // cose, e la seconda vale piu' della prima: un anello un dito piu' in
    // alto lo nota chi lo cerca, un pulsante mezzo fuori lo trova chiunque.
    // Su tutte le altre trentacinque geometrie della griglia questo limite
    // non tocca niente, e l'inseguimento resta quello approvato.
    var nuovo = _inseguimento + (manca.abs() >= 0.5 ? manca : 0);
    var fondoVoluto = fondo + (nuovo - _inseguimento);
    if (colonna is RenderBox && colonna.hasSize) {
      final eccesso = fondoVoluto - (colonna.size.height - respiroFraLeDueZone);
      if (eccesso > 0) {
        nuovo -= eccesso;
        fondoVoluto -= eccesso;
      }
    }

    final fondoCambiato = (fondoVoluto - _fondoDellaGuida).abs() >= 0.5;
    final inseguimentoCambiato = (nuovo - _inseguimento).abs() >= 0.5;

    // **E QUI IL GIRO SI FERMA DAVVERO.** Senza questa riga la rincorsa
    // continuerebbe a chiedere di scendere e il bordo continuerebbe a
    // rimandarla su, un ridisegno per frame, per sempre: si guarda cio' che
    // cambierebbe DOPO il limite, non cio' che la rincorsa vorrebbe.
    if (!inseguimentoCambiato && !fondoCambiato) return;
    if (!mounted) return;
    setState(() {
      _inseguimento = nuovo;
      _fondoDellaGuida = fondoVoluto;
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.aura));
    // La misura si prende a frame finito, quando i due riquadri esistono
    // davvero: durante il build hanno ancora la misura del giro precedente.
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _appoggiaLaGuidaSottoIlSoffione());

    // IL FONDALE E' IL COSMO CONDIVISO, ordine P voce 26. Prima il Soffio si
    // dipingeva un prato suo dentro il pittore della scena: adesso passa da
    // `CosmosBackground`, la stessa porta del Sigillo del Sogno, quindi il cielo in
    // parallasse arriva anche qui e non c'e' un secondo fondale da mantenere.
    return CosmosBackground(
      seed: 31,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: palette.deepest.withValues(alpha: 0.4),
          elevation: 0,
          iconTheme: IconThemeData(color: palette.goldSoft),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: 'Indietro',
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          // **IL TITOLO NON SI TRONCA PIU'.** Ordine EF, 23 settembre 2026.
          //
          // **Il fatto del fondatore, verbatim**: *"Ti faccio anche notare il
          // titolo in alto troncato con dei puntini 'Soffio del destin...'"*.
          //
          // **La cura esisteva gia' e questa schermata non la usava.**
          // `TitoloCheNonSiRompe` nasce dall'ordine S voce 05 proprio per
          // questo, e lo usano ventidue schermate: va a capo fra le parole,
          // e se la parola piu' lunga non entra rimpicciolisce la misura fino
          // al pavimento invece di tagliare. Qui c'era un `Text` nudo, che in
          // una barra con tre azioni a destra non ha altra scelta che i
          // puntini.
          //
          // **Il difetto e' piu' largo di questa schermata**, e sta fuori dal
          // perimetro dell'ordine: nel rapporto c'e' il conto di quante altre
          // barre hanno ancora il titolo nudo.
          title: TitoloCheNonSiRompe(
              testo: 'Soffio del Destino',
              stile: TypographyTokens.titoloDiSchermata()),
          // **LA FONTE ARRIVA A CHI LEGGE.** Ordine CS, voce S2 della
          // scansione: il Soffio nasce dai transiti veri di oggi sul cielo
          // di nascita, la stessa porta dell'Oroscopo, e a video non lo
          // diceva niente.
          actions: [
            FoglioDelleFonti.bottone(context,
                palette: palette,
                testo: TestiDelleFonti.soffio,
                chiave: 'soffio_fonti'),
            // **E IL CUORE IN FILA, non sovrapposto.** Ordine DC voce 15:
            // questa barra portava il tooltip e non passava dal punto unico,
            // quindi qui il cuore restava quello disegnato sopra la scena,
            // nello stesso angolo delle azioni. Era la quarta schermata col
            // difetto che il fondatore ha visto sulle prime tre.
            const AngoloDellaBarra(),
          ],
        ),
        // LA SCENA HA UN NOME, ordine P voce 26.
        //
        // **Non e' una comodita' per le prove: e' la correzione di una misura
        // fragile.** La prova della concentricita' prendeva `Stack.first`, cioe'
        // il primo Stack che incontrava scendendo nell'albero, e finche' la
        // schermata cominciava col suo Scaffold quello era questa scena. Col cosmo
        // condiviso davanti il primo Stack e' quello del cosmo, alto 797 invece di
        // 741 e ancorato a zero invece che sotto la barra: la prova misurava un
        // altro riquadro e dichiarava 41,4 punti di scarto mentre l'anello era
        // centrato. L'inseguimento, misurato, converge a zero.
        //
        // Un riquadro che una prova deve misurare si chiama per nome.
        // **E UN RIQUADRO CHE UNA PROVA DEVE DIPINGERE E' UN
        // RepaintBoundary.** Ordine EE voce 02: il soffione non e' un widget
        // ma un dipinto, e l'unico modo di misurarlo e' rasterizzare la
        // scena. Senza questo confine  non ha da dove partire.
        body: RepaintBoundary(
          key: const Key('soffio_scena'),
          child: KeyedSubtree(
            child: Stack(
              key: _scena,
              fit: StackFit.expand,
              children: [
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation:
                          Listenable.merge([_disperse, _ambient, _respiro]),
                      builder: (context, _) => CustomPaint(
                        painter: _BreathScenePainter(
                          progress: _progress,
                          ambient: _reduceMotion ? 0 : _ambient.value,
                          reduceMotion: _reduceMotion,
                          palette: palette,
                          // **E IL RESPIRO ARRIVA SEMPRE. Ordine EF.**
                          // Qui `_reduceMotion` lo bloccava a uno, cioe' la
                          // figura ferma: una guida del respiro che non
                          // respira non guida niente.
                          respiro: _respiro.value,
                        ),
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  top: false,
                  // **LE DUE ZONE NON SI SPARTISCONO PIU' UN RAPPORTO FISSO.
                  // Ordine DR voce 11, 16 settembre 2026.**
                  //
                  // **Perche' il rapporto non poteva reggere.** La cura
                  // dell'ordine 2164 voce 8 era sei contro tre, e per un mese ha
                  // tenuto: sullo schermo su cui era stata misurata lasciava
                  // QUATTRO punti fra il pulsante e la scheda. Quattro punti non
                  // sono un margine, sono un avanzo. Misurate trentasei
                  // geometrie, la scheda saliva sopra la guida in ventinove:
                  // fino a 93,7 punti su uno schermo da 640 con le barre alte e
                  // il testo alla scala massima.
                  //
                  // **La forma nuova, e perche' regge dove l'altra non ha
                  // retto.** La zona del respiro non prende una frazione: prende
                  // **quanto serve alla guida per starci**, misurato a frame
                  // finito da chi la guida la disegna davvero. Il rapporto di
                  // prima resta come pavimento, quindi finche' la guida sta
                  // comoda non cambia niente di cio' che il fondatore ha gia'
                  // approvato; quando non ci sta, la zona cresce invece di
                  // lasciarsi invadere. Non c'e' nessun numero da azzeccare: se
                  // domani il carattere cresce, o arriva un telefono piu' basso,
                  // o la guida si allunga di una riga, la misura cambia da se'.
                  child: LayoutBuilder(
                    builder: (context, vincoli) {
                      // **IL PAVIMENTO E' IL RAPPORTO DI PRIMA**: finche' la
                      // guida ci sta comoda, questa schermata e' identica a
                      // quella che il fondatore ha gia' approvato.
                      // **IL PAVIMENTO SCENDE DA SEI NONI A 0,42. Ordine EF
                      // voce 01, seconda passata.**
                      //
                      // **Il fatto del fondatore, verbatim**: *"l'AREA
                      // DEDICATA ALLA DESCRIZIONE IN BASSO E' TROPPO
                      // PICCOLA, TI HO FATTO ALZARE TUTTO, SIA IL FIORE CHE
                      // IL PULSANTE, PER ALZARE LA BOLLA DELLA
                      // DESCRIZIONE!"*.
                      //
                      // **Misurato: era il pavimento a tenere ferma la
                      // bolla, non la figura.** Alzata la figura e separate
                      // le due fasi, la zona del respiro chiedeva 479 punti
                      // su 818 e il pavimento la teneva a 529: la bolla
                      // guadagnava mezzo punto percentuale invece di
                      // diciassette. Il pavimento dei sei noni veniva
                      // dall'ordine 2164 voce 8, quando la zona era decisa da
                      // un rapporto fisso e non c'era nessuna misura da
                      // credere.
                      //
                      // **Adesso la misura c'e' ed e' deterministica**: il
                      // riquadro si appoggia sotto un fondo dichiarato, non
                      // insegue piu' niente. Il pavimento resta solo per il
                      // primo fotogramma, quando la misura non esiste
                      // ancora, e non deve mai essere lui a decidere.
                      // **E IL PAVIMENTO VALE SOLO FINCHE' LA MISURA NON
                      // C'E'.** Abbassarlo e basta schiacciava la guida
                      // prima che qualcuno l'avesse misurata: sulla
                      // geometria piu' stretta della griglia la sua colonna
                      // **traboccava di ventinove pixel**, e il pulsante
                      // finiva sotto la striscia gialla e nera invece che
                      // sotto il dito. Preso da `la_scheda_non_sale_mai_sul_
                      // respiro`, che quel tocco lo prova davvero.
                      //
                      // Quindi: al primo fotogramma il pavimento resta quello
                      // largo di sempre, cosi' la guida si dispone comoda e
                      // si lascia misurare; dal secondo in poi comanda la
                      // misura, e il pavimento scende a un minimo che non
                      // decide niente.
                      final pavimento = _fondoDellaGuida > 0
                          ? vincoli.maxHeight * 0.30
                          : vincoli.maxHeight * 6 / 9;
                      // **E NON C'E' NESSUN TETTO SOTTO LO SCHERMO.** Un tetto
                      // e' un numero che qualcuno decide, ed e' esattamente la
                      // cosa che ha fatto tornare il difetto: messo a
                      // cinquantasei punti, tre geometrie su trentasei
                      // tornavano a coprirsi, la peggiore di 40,4 punti.
                      // L'unico limite che non e' un'opinione e' lo schermo.
                      final altezzaDelRespiro = math.min(
                        vincoli.maxHeight,
                        math.max(
                          pavimento,
                          _fondoDellaGuida + respiroFraLeDueZone,
                        ),
                      );
                      return Column(
                        key: _colonna,
                        children: [
                          SizedBox(
                            height: altezzaDelRespiro,
                            child: Semantics(
                              button: true,
                              label:
                                  'Libera il tuo destino. Soffia, oppure spazza col '
                                  'dito o tieni premuto.',
                              onTap: _onLongPress,
                              child: GestureDetector(
                                key: const Key('ritual_gesture'),
                                behavior: HitTestBehavior.opaque,
                                onPanUpdate: _onPanUpdate,
                                onPanEnd: _onPanEnd,
                                onLongPress: _onLongPress,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // **L'INVITO STA SOTTO LA FIGURA, NON
                                    // SOPRA. Ordine EF voce 01.**
                                    //
                                    // **Difetto trovato guardando una
                                    // cattura, non leggendo il codice.** Qui
                                    // c'era `Alignment(0, -0.55)`, cioe' un
                                    // punto deciso a mano dentro la zona del
                                    // respiro, e la pastiglia *"Soffia,
                                    // oppure spazza col dito"* si appoggiava
                                    // in mezzo alla testa del soffione. E'
                                    // lo stesso difetto del riquadro del
                                    // respiro, nello stato di prima: **due
                                    // sistemi che decidono due posizioni
                                    // sulla stessa scena**.
                                    //
                                    // Adesso legge lo stesso fondo della
                                    // figura che legge il riquadro, gia'
                                    // portato nelle coordinate della colonna.
                                    if (!_revealed)
                                      Positioned(
                                        left: 0,
                                        right: 0,
                                        top: _fondoFiguraInColonna +
                                            respiroFraLeDueZone,
                                        child: Align(
                                          alignment: Alignment.topCenter,
                                          child:
                                              _BreathPrompt(palette: palette),
                                        ),
                                      ),
                                    // L'ESITO DEL MICROFONO, detto a schermo: il rito
                                    // resta compibile col dito in ogni caso, ma chi ha
                                    // negato deve sapere perche' il soffio non viene
                                    // ascoltato, e chi ha negato PER SEMPRE deve sapere
                                    // che l'unica via sono le impostazioni.
                                    if (!_revealed &&
                                        _esitoDelMicrofono != null &&
                                        _esitoDelMicrofono !=
                                            EsitoDelPermesso.concesso)
                                      Align(
                                        alignment: const Alignment(0, 0.62),
                                        child: AvvisoDelPermesso(
                                          chiave: 'soffio',
                                          permesso: AppPermission.microphone,
                                          esito: _esitoDelMicrofono!,
                                          palette: palette,
                                          onRichiedi: () async {
                                            await _startMic();
                                          },
                                        ),
                                      ),
                                    // IL RESPIRO SI GUIDA, NON SI LEGGE.
                                    //
                                    // Compare a gesto compiuto, cioe' quando il rito del
                                    // giorno c'e' e dichiara la sua cadenza. Prima qui
                                    // non c'era niente: il testo diceva "sei tempi
                                    // dentro e sei fuori, tre volte" e la persona
                                    // contava a mente davanti a una figura ferma.
                                    if (_revealed && _gift?.rito != null)
                                      // L'ANELLO CADE DENTRO IL DISCO. L'allineamento di
                                      // partenza non conta piu': qualunque esso sia, la
                                      // misura a frame finito lo porta sul centro
                                      // dichiarato da `SuperficiDelSoffio`.
                                      Align(
                                        alignment: Alignment.center,
                                        child: Transform.translate(
                                          offset: Offset(0, _inseguimento),
                                          child: KeyedSubtree(
                                            key: _laGuida,
                                            child: GuidaDelRespiro(
                                              key: const Key('guida_respiro'),
                                              chiaveDellaFigura: _anello,
                                              // **IL CERCHIO SPARISCE E LA
                                              // MISURA ESCE.** Ordine EE voce
                                              // 02: la figura e' vuota, quindi
                                              // il cerchio di ripiego non si
                                              // disegna, e a respirare e' il
                                              // soffione della scena, che
                                              // legge di qui.
                                              figura: const SizedBox.shrink(),
                                              misuraDelRespiro: _respiro,
                                              tempi: TempiDelRespiro(
                                                tempi: _gift!.rito!.tempi,
                                                giri: _gift!.rito!.giri,
                                              ),
                                              colore: palette.gold,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // LA SCHEDA STA SOTTO IL RESPIRO, MAI SOPRA, ordine 2164
                          // voce 8. Visto da Mauro: il pulsante "Tocca per cominciare"
                          // era tagliato a meta' dalla scheda dell'intenzione, quindi
                          // non si poteva nemmeno premere per intero.
                          //
                          // La causa misurata: la guida del respiro insegue il disco
                          // luminoso con una traslazione verso il basso, e con le
                          // barre di sistema del telefono (una quarantina di punti in
                          // meno) SBORDAVA dalla sua zona; la scheda, che viene dopo
                          // nella colonna, si dipinge sopra e se lo mangiava. Con
                          // sei contro tre la zona del respiro torna a contenerlo:
                          // misurato 25,1 punti coperti prima, zero adesso, e il
                          // tocco al centro arriva.
                          // E QUESTA PRENDE CIO' CHE RESTA, senza numero proprio:
                          // un rapporto scritto qui sarebbe di nuovo una seconda
                          // autorita' sullo stesso asse.
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(
                                  SpacingTokens.lg,
                                  0,
                                  SpacingTokens.lg,
                                  SpacingTokens.lg),
                              child: (_revealed && _gift != null)
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        RitualGiftCard(
                                          key: const Key('ritual_content'),
                                          gift: _gift!,
                                          dono: DailyElement.breath,
                                          giorno: widget.now ?? DateTime.now(),
                                          streak: _streak,
                                          onShare: () => _shareWord(_gift!),
                                          // **LE TRE AZIONI, ordine CG voci 06 e 08.**
                                          // Cio' che si custodisce e' l'orientamento del
                                          // giorno, che e' cio' che il dono dice
                                          // davvero: la parola era uscita dalla scheda
                                          // per decisione del fondatore, e custodire una
                                          // cosa che non si vede sarebbe la stessa
                                          // bugia di condividerla.
                                          azioni: AzioniDelResponso(
                                            // **IL REGIME LO DICE IL VESTITO.
                                            // Ordine CW voce 08**, 7 settembre 2026.
                                            //
                                            // Qui c'era `suChiaro: true` con la
                                            // ragione dell'ordine CO voce 14, *"la
                                            // scheda del Dono e' il pannello del
                                            // regime chiaro"*: **vero per l'Alba,
                                            // falso per il Soffio.**
                                            // `AbitoDelResponso.di` da' il vestito
                                            // chiaro al SOLO `dawn`; qui il vestito
                                            // e' quello notturno.
                                            //
                                            // I due pulsanti dipingevano quindi
                                            // l'inchiostro chiaro #2A2213 sul vetro
                                            // notturno #1C1338: **1,11 a uno contro
                                            // 4,5**, che e' il "non si leggono" del
                                            // fondatore, misurato.
                                            suChiaro: AbitoDelResponso.di(
                                                    DailyElement.breath)
                                                .diGiorno,
                                            palette: palette,
                                            maestro: Maestro.aura,
                                            responso: ResponsoDaCustodire(
                                              arte: 'soffio',
                                              titolo:
                                                  'Il tuo Soffio del Destino',
                                              testo: _gift!.orientation,
                                            ),
                                            condividi: () => _shareWord(_gift!),
                                            aperturaDellaChat:
                                                ChatOpeners.soffio(
                                                    _gift!.orientation),
                                          ),
                                        ),
                                        // La card da mandare, fuori campo.
                                        if (_rendiLaCard)
                                          Stack(
                                            clipBehavior: Clip.none,
                                            children: [
                                              const SizedBox.shrink(),
                                              Positioned(
                                                left: -3000,
                                                top: 0,
                                                child: RepaintBoundary(
                                                  key: _cardDaCondividere,
                                                  child: SoffioShareCard(
                                                    orientamento:
                                                        _gift!.orientation,
                                                    palette: palette,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        if (_risposta != null) ...[
                                          const SizedBox(
                                              height: SpacingTokens.lg),
                                          _LaRisposta(
                                              risposta: _risposta!,
                                              palette: palette),
                                        ],
                                      ],
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// LE DUE RIGHE DELLA RISPOSTA, e nient'altro.
///
/// Nessuna domanda alla persona, nessun compito, nessun esito promesso, e
/// nessun verbo all'imperativo: quella e' la forma del Rito dell'Alba, e i due
/// riti non devono somigliarsi.
class _LaRisposta extends StatelessWidget {
  const _LaRisposta({required this.risposta, required this.palette});

  final RispostaDelSoffio risposta;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    // LE RIGHE HANNO UNA SUPERFICIE, e non e' un vezzo: senza, stavano sul
    // prato chiaro e il contrasto era sotto la soglia. Misurato da
    // `test/il_soffio_si_legge_test.dart`.
    return Container(
      key: const Key('soffio_risposta'),
      width: double.infinity,
      padding: const EdgeInsets.all(SpacingTokens.md),
      decoration: BoxDecoration(
        color: SuperficiDelSoffio.velo,
        borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
        border: Border.all(
            color: AccentoDelMaestro.su(Maestro.aura,
                    superficie: SuperficiDelSoffio.velo)
                .withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // **QUI C'ERA L'ETICHETTA "LA RISPOSTA", ED E' STATA TOLTA.
          // Ordine CQ voce 6.03, 4 settembre 2026.**
          //
          // Parole del fondatore: *alla fine del responso compare anche la
          // bolla "La risposta" come prima, mentre ho chiesto la
          // rielaborazione dei testi*.
          //
          // **Un'etichetta che annuncia una risposta non e' uno dei quattro
          // strati della legge dei testi**: il primo strato e' un titolo che
          // sia GIA' una risposta, non un cartello che dice che sotto ce
          // n'e' una. Chi legge arriva qui dopo il soffio e trova scritto
          // che sta per leggere una risposta, cioe' una riga di attesa in
          // piu' prima della risposta vera.
          //
          // **Il riquadro resta**, e non e' una svista: le due righe senza
          // superficie stavano sul prato chiaro sotto la soglia del
          // contrasto, misurato da `test/il_soffio_si_legge_test.dart`. Si
          // toglie il cartello, non il fondo che rende leggibile il testo.
          // **LA RISPOSTA DEL SOFFIO SI LEGGE, E STAVA A SEDICI.** Ordine
          // CE voce 10. L'ordine dava per buona la misura di questo Dono e
          // per mancante solo la porta: misurato, era il contrario, i due
          // paragrafi stavano a sedici punti come l'Arcano.
          if (risposta.apre != null)
            ParagrafiDiLettura(
                key: const Key('soffio_apre'),
                testo: risposta.apre!,
                stile: TypographyTokens.lettura().copyWith(
                    color: SuperficiDelSoffio.inchiostroDellaRisposta)),
          if (risposta.apre != null && risposta.nonForzare != null)
            const SizedBox(height: SpacingTokens.sm),
          if (risposta.nonForzare != null)
            ParagrafiDiLettura(
                key: const Key('soffio_non_forzare'),
                testo: risposta.nonForzare!,
                stile: TypographyTokens.lettura().copyWith(
                    color:
                        SuperficiDelSoffio.inchiostroSecondarioDellaRisposta)),
        ],
      ),
    );
  }
}

/// L'invito al soffio e il suo ripiego, chiari sul prato.
class _BreathPrompt extends StatelessWidget {
  const _BreathPrompt({required this.palette});

  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    // **VIA IL VELO, COME NELL'ALBA. Ordine AS voce 07.** Un `RadialGradient`
    // nero dentro un rettangolo lascia gli angoli piu' scuri del centro, e
    // quello che si vede e' un riquadro semitrasparente appoggiato sulla
    // scena. Il testo resta leggibile per la sua pillola, che e' un
    // contenitore voluto e con un bordo.
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.lg, vertical: SpacingTokens.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.air_rounded,
              color: palette.goldSoft.withValues(alpha: 0.9), size: 26),
          const SizedBox(height: SpacingTokens.sm),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.md, vertical: SpacingTokens.sm),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
              color: palette.deepest.withValues(alpha: 0.5),
              border: Border.all(color: palette.gold.withValues(alpha: 0.5)),
            ),
            // **UNA RIGA SOLA, E PIU' GRANDE. Ordine AS voce 07.** Erano due,
            // e dicevano tutte e due come si fa lo stesso gesto; la prima per
            // giunta a corpo DODICI scritto a mano, cioe' sotto il pavimento
            // tipografico del progetto. La via col dito non sparisce, entra
            // nella stessa riga: togliere una possibilita' sarebbe un'altra
            // cosa dal togliere una ripetizione.
            child: Text(
              'Soffia, oppure spazza col dito',
              key: const Key('soffio_invito_al_gesto'),
              textAlign: TextAlign.center,
              style: TypographyTokens.lettura()
                  .copyWith(color: palette.goldSoft, letterSpacing: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

/// Il motore del Soffio a livelli, composto in un solo canvas.
/// **IL PITTORE DELLA SCENA, pubblico per chi lo deve misurare.** Ordine EE
/// voce 02, 23 settembre 2026.
///
/// **Perche' esce dal privato.** Il soffione non e' un widget: e' un
/// dipinto, e l'unico modo di misurarlo e' dipingerlo. Montare la schermata
/// intera non basta, perche' l'immagine del soffione arriva da un asset PNG
/// che nelle prove non si carica, e senza immagine questo pittore **esce
/// subito**: la tela resterebbe vuota e la guardia misurerebbe il niente.
///
/// **Una scena si misura solo se una prova la puo' dipingere da sola**, ed e'
/// la stessa ragione per cui  e' pubblica dall'ordine DU voce
/// 14.
typedef BreathScenePainterDiProva = _BreathScenePainter;

class _BreathScenePainter extends CustomPainter {
  _BreathScenePainter({
    required this.progress,
    required this.ambient,
    required this.reduceMotion,
    required this.palette,
    this.respiro = 1.0,
  });

  /// **QUANTO E' APERTO IL RESPIRO, e a respirare e' il soffione.** Ordine
  /// EE voce 02, 23 settembre 2026.
  ///
  /// Uno quando non si respira e al culmine dell'inspirazione, meno a ogni
  /// espirazione. **La testa del soffione si allarga e si stringe con
  /// questo numero**, e il cerchio d'oro che lo faceva al posto suo non si
  /// disegna piu'.
  final double respiro;

  final double progress;
  final double ambient;
  final bool reduceMotion;
  final MaestroPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    // IL PRATO NON SI DIPINGE PIU' QUI, ordine P voce 26.
    //
    // **Non era un fondale: era un LIVELLO dentro questo pittore**, che sulla
    // stessa tela disegna anche il soffione e i semi che volano al soffio,
    // cioe' il gesto del rito. Per questo toglierlo obbligava a decidere cosa
    // succede al soffione, e per questo era rimasto due volte.
    //
    // La decisione: il soffione resta esattamente dov'e', dipinto da qui,
    // perche' e' il gesto e non lo sfondo; il fondale passa a
    // `CosmosBackground`, che e' la destinazione gia' precedentata dal Rito del
    // Sogno. Sotto il soffione resta l'alone verde di Aura, che c'era gia' e
    // che adesso fa anche da terreno: un soffione sospeso nel vuoto non e'
    // quello che si voleva.
    final p = progress.clamp(0.0, 1.0);
    final w = size.width, h = size.height;
    final rect = Offset.zero & size;

    // --- Alone verde di Aura del dominio, dal basso ---
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, 0.35),
          radius: 0.9,
          colors: [
            palette.glow.withValues(alpha: 0.30),
            palette.glow.withValues(alpha: 0.0),
          ],
        ).createShader(rect),
    );

    // **LA GEOMETRIA LA DICHIARA `SuperficiDelSoffio`, non questo pittore.**
    // Ordine EF voce 01: qui c'erano `h * 0.86` per l'altezza e `h * 0.46`
    // per il centro, mentre il riquadro del respiro si posizionava per conto
    // suo nel layout. **Due sistemi che decidono due posizioni sulla stessa
    // scena finiscono per coprirsi**, e sulla 2276 si coprivano.
    final headCenter = SuperficiDelSoffio.testaDentro(size);
    final headR =
        SuperficiDelSoffio.raggioDellaTestaDentro(size, respiro: respiro);
    final giftCenter = SuperficiDelSoffio.discoDentro(size);

    // --- Il dono: un soffione di luce che si accende man mano che le
    // scintille dei semi salgono a comporlo. **Ordine DU voce 14**: il disegno
    // sta in `FormaDelDono`, che e' pubblica perche' una scena si misura solo
    // se una prova la puo' dipingere da sola.
    // **E IL DONO RESPIRA, ordine EF voce 01.** Finito il soffio, la figura
    // che sta a schermo mentre la persona respira e' questa: il soffione di
    // semi e' gia' volato via, ed e' il dono a doversi allargare e stringere
    // col fiato.
    FormaDelDono.dipingi(
      canvas,
      centro: giftCenter,
      larghezza: w,
      soffio: p,
      respiro: ambient,
      palette: palette,
      fermo: reduceMotion,
      // La stessa stretta che si applica al soffione: su uno schermo dove
      // la figura non ci sta, a cedere e' lei e non il riquadro.
      // **CON RIDUCI MOVIMENTO LA FIGURA STA AL CULMINE, non a riposo.**
      // Ordine EF voce 01, misurato sul Realme del fondatore: **le tre scale
      // di animazione di quel telefono sono a zero**, quindi Flutter dichiara
      // Riduci Movimento e qui non si muove niente. Con l'apertura a uno la
      // figura restava ferma alla misura piu' piccola, **il 42,1 per cento
      // della larghezza**, e chi ha le animazioni spente vedeva per sempre la
      // versione rimpicciolita di una cosa che non si muove.
      //
      // Se non si muove, che stia grande: e' la stessa scelta gia' fatta per
      // il soffione inciso, che con Riduci Movimento riceve `respiro: 1.0`,
      // cioe' il culmine.
      apertura: FormaDelDono.aperturaDaRespiro(respiro) *
          SuperficiDelSoffio.scalaDelDono(size),
    );

    // --- IL SOFFIONE, DISEGNATO E NON FOTOGRAFATO. Ordine EF voce 03. ---
    //
    // Qui c'erano due `drawImageRect` sulla fotografia: uno per lo stelo e
    // uno per la testa, ritagliati a frazioni dell'immagine. La fotografia
    // aveva un alone scuro frastagliato attorno alla testa e lo stelo
    // spezzato da uno scalino a meta', e stava in mezzo a un'app incisa in
    // oro. **Adesso e' un disegno**, nello stesso vocabolario di
    // `FormaDelDono`, e **respira per davvero**: la testa si allarga e si
    // stringe perche' il raggio che arriva qui porta gia' il respiro dentro.
    //
    // **LO STELO SE NE VA DOPO I PAPPI. Ordine AS voce 07.** Un soffione
    // soffiato via non lascia il suo gambo in primo piano: lo stelo resta
    // intero mentre la testa si dirada, e si dissolve nell'ultimo terzo del
    // soffio, quando i pappi hanno finito di volare.
    const quandoLoSteloSiRitira = 0.7;
    final steloOpacita = p <= quandoLoSteloSiRitira
        ? 1.0
        : (1 - (p - quandoLoSteloSiRitira) / (1 - quandoLoSteloSiRitira))
            .clamp(0.0, 1.0);
    SoffioneInciso.dipingi(
      canvas,
      centro: headCenter,
      // **LO STELO NON RESPIRA, LA TESTA SI.** Il raggio che disegna i pappi
      // porta il respiro; quello che misura lo stelo no, o il gambo si
      // allungherebbe e accorcerebbe a ogni fiato come un elastico.
      raggio: headR,
      raggioDelloStelo: size.width * SuperficiDelSoffio.raggioDellaTesta,
      palette: palette,
      spoglio: p,
      steloOpacita: steloOpacita,
      aria: reduceMotion ? 0.0 : ambient,
      fermo: reduceMotion,
    );

    // --- IL TERRENO: un orizzonte sfumato che assorbe la fine dello stelo ---
    //
    // **Difetto trovato GUARDANDO l'anteprima, non ragionando.** Tolto il prato
    // della voce 26, lo stelo del soffione finiva nel vuoto: l'immagine termina
    // a 637 punti su 741, e i cento punti sotto restavano cielo con un gambo
    // tagliato in mezzo. Il prato quella terminazione la copriva, ed e' il
    // secondo modo in cui il prato non era "solo un fondale".
    //
    // Il rimedio non e' rimettere una fotografia: e' un orizzonte, cioe' il
    // verde di Aura che sale dal bordo basso e assorbe lo stelo. Sta SOPRA il
    // soffione perche' deve assorbirlo, e SOTTO i semi perche' quelli volano.
    final orizzonte = Rect.fromLTWH(0, h * 0.72, w, h * 0.28);
    canvas.drawRect(
      orizzonte,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            palette.glow.withValues(alpha: 0.0),
            palette.primary.withValues(alpha: 0.55),
            palette.deepest.withValues(alpha: 0.9),
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(orizzonte),
    );

    // --- Semi che volano via verso l'alto come scintille, con deriva di vento --
    _paintSeeds(canvas, headCenter, headR, giftCenter, p);
  }

  void _paintSeeds(
      Canvas canvas, Offset head, double headR, Offset gift, double p) {
    if (p <= 0.001) return;
    final rng = math.Random(31);
    const n = 90;
    final wind = reduceMotion ? 0.0 : math.sin(2 * math.pi * ambient);
    final paint = Paint()..blendMode = BlendMode.plus;
    for (var i = 0; i < n; i++) {
      final threshold = (i / n) * 0.85;
      if (p <= threshold) continue;
      final f = ((p - threshold) / (1 - threshold)).clamp(0.0, 1.0);
      // Punto di partenza sulla testa, arrivo verso la forma del dono.
      final a0 = rng.nextDouble() * 2 * math.pi;
      final r0 = math.sqrt(rng.nextDouble()) * headR;
      final start = head + Offset(math.cos(a0), math.sin(a0)) * r0;
      final endJitter = Offset((rng.nextDouble() - 0.5) * headR * 1.6,
          (rng.nextDouble() - 0.5) * headR * 0.8);
      final end = gift + endJitter;
      final flightCurve = Curves.easeOut.transform(f);
      final windX = wind * headR * 0.5 * (rng.nextDouble() + 0.3) * f;
      final pos = Offset.lerp(start, end, flightCurve)! + Offset(windX, 0);
      // Scintilla: piu' viva a meta' volo, si spegne arrivando.
      final glow = (math.sin(f * math.pi)).clamp(0.0, 1.0);
      final radius = 1.0 + rng.nextDouble() * 1.6;
      canvas.drawCircle(
        pos,
        radius * 2.4,
        paint
          ..color = palette.goldSoft.withValues(alpha: 0.10 * glow)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
      paint.maskFilter = null;
      canvas.drawCircle(
        pos,
        radius,
        paint..color = const Color(0xFFFFF6DC).withValues(alpha: 0.8 * glow),
      );
    }
  }

  @override
  bool shouldRepaint(_BreathScenePainter old) =>
      old.progress != progress ||
      old.ambient != ambient ||
      old.reduceMotion != reduceMotion ||
      old.palette != palette ||
      old.respiro != respiro;
}
