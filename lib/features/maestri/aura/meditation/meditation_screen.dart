import '../../../maestri/widgets/foglio_delle_fonti.dart';
import 'dart:math' as math;

import 'dart:async';

import '../../../sigilli/regia_del_cammino.dart';

import 'package:flutter/material.dart';

import '../../../../design_system/theme/maestro_palette.dart';
import '../../../../design_system/theme/maestro_scope.dart';
import '../../../../design_system/components/cosmos_background.dart';
import '../../../../design_system/tokens/color_tokens.dart';
import '../../../../design_system/tokens/spacing_tokens.dart';
import '../../../../design_system/tokens/typography_tokens.dart';
import '../../../../core/maestro/chakra_del_giorno.dart';
import '../../../../core/maestro/colore_del_centro.dart';
import 'card_del_respiro.dart';
import '../../../../core/maestro/memoria_del_respiro.dart';
import '../../../../core/maestro/cio_che_aura_ricorda.dart';
import '../../../../core/maestro/frequenza_del_giorno.dart';
import '../../../../core/maestro/traccia_del_loto.dart';
import 'loto_che_respira.dart';
import 'pannello_della_libreria.dart';
import '../../../../core/maestro/libreria_dei_respiri.dart';
import 'meditation_audio.dart';
import 'sigillo_della_sessione.dart';
import '../../../../core/maestro/maestro.dart';
import '../../rotta_arte.dart';
import '../../../../../design_system/components/titolo_che_non_si_rompe.dart';
import '../../../../design_system/transizioni/passaggio_del_cerchio.dart';
import '../../../../design_system/typography/paragrafi_di_lettura.dart';

/// Meditazione di Aura con suono e cimatica.
///
/// Tre strati che nascono l'uno dall'altro: uno strato sonoro generato a runtime
/// (toni a 432 e 528 Hz e un battito binaurale, da ascoltare con le cuffie), un
/// visualizzatore a cimatica (un mandala di geometria sacra che nasce dal suono
/// e pulsa col respiro) e una guida al respiro. Fondamento onesto: cornice di
/// benessere e non cura, le frequenze come tradizione culturale, non fatto
/// medico. Il disclaimer completo sta all'ingresso, non si ripete qui.
///
/// La prova dell'audio resta al device, dietro `TonePlayer`: in headless si usa
/// il lettore silenzioso, che genera comunque i toni senza riprodurli.
class MeditationScreen extends StatefulWidget {
  MeditationScreen({super.key, TonePlayer? player, this.now})
      : player = player ?? LettoreToniReale();

  final TonePlayer player;

  /// **IL GIORNO, per la frequenza e per il centro.** Ordine CZ voce 06: la
  /// meditazione di oggi ha una frequenza sola, quella del centro acceso
  /// oggi, e una prova deve poter dire di che giorno si tratta senza
  /// aspettare martedi'.
  final DateTime? now;

  static Route<void> route({TonePlayer? player, DateTime? now}) {
    return PassaggioDelCerchio.rotta<void>((_) => SogliaArte(
        id: 'meditation',
        maestro: Maestro.aura,
        child: MeditationScreen(player: player, now: now)));
  }

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen>
    with TickerProviderStateMixin {
  // Il respiro: inspira, trattieni, espira, in un ciclo lento e continuo.
  static const int _inhaleMs = 4000;
  static const int _holdMs = 2000;
  static const int _exhaleMs = 5000;
  static const int _cycleMs = _inhaleMs + _holdMs + _exhaleMs;

  late final AnimationController _breath;

  /// **LA FREQUENZA DI PARTENZA E' QUELLA DEL CENTRO DI OGGI.**
  /// Ordine DD voce 12, 10 settembre 2026.
  ///
  /// **Difetto trovato leggendo il codice accanto al testo che l'app mostra.**
  /// La schermata scriveva *"la tradizione gli accosta i 639 hertz. E' la
  /// frequenza di questa sessione"* e poi suonava **432**, perche' questo
  /// campo partiva da `calm432` e nessuno lo legava al centro del giorno.
  /// **Il numero scritto e il numero suonato erano due**, e chi ascoltava con
  /// le cuffie sentiva la bugia.
  ///
  /// Nulla finche' `initState` non lo riempie: si assegna li', dove il giorno
  /// e' noto.
  late MeditationPreset _preset;
  bool _active = false;

  /// **LA MEDITAZIONE HA UNA FINE, ordine BF voce 05.b (ordine P voce 35).**
  /// Prima il respiro girava in cerchio per sempre: la schermata non
  /// arrivava a una chiusura, non accendeva traguardi e non funzionava come
  /// rito. La sessione dura [cicliDellaSessione] cicli di respiro (dodici
  /// da undici secondi, poco piu' di due minuti): al compimento il tono si
  /// ferma, la scena lo dice, e la regia registra il gesto `meditazione`,
  /// che e' cio' che sveglia aur_50 e aur_51. Il tempo lo tiene un Timer e
  /// non l'animazione, cosi' il compimento arriva anche con Riduci
  /// Movimento, dove il respiro visivo sta fermo.
  static const int cicliDellaSessione = 12;
  Timer? _sessione;
  bool _compiuta = false;

  /// **IL RESPIRO VERO DI CHI RESPIRA. Ordine CZ voce 08**, 8 settembre 2026.
  ///
  /// Il dito giu' e' l'inspiro, il dito alzato e' l'espiro, e sono i suoi
  /// tempi a muovere il fiore. Il ritmo guidato resta come **seconda strada
  /// dichiarata**, per chi non vuole tenere il dito: e' `_breath`, quello di
  /// prima, e non e' nascosto.
  /// **QUANTO E' DURATA LA SESSIONE FINO A ORA.** Ordine DD voce 17: e' il
  /// numero del titolo della card e il seme del sigillo, ed e' l'unico dato
  /// continuo che resta senza il dito.
  Duration get _quantoEDurata {
    final inizio = _cominciata;
    if (inizio == null) return Duration.zero;
    return (widget.now ?? DateTime.now()).difference(inizio);
  }

  /// Il sigillo di questa sessione, ricalcolato quando serve.
  List<double> get _sigilloDiOra => SigilloDellaSessione.figura(
        sintomo: _praticaScelta?.sintomo,
        hertz: _preset.leftHz.round(),
        centro: _indiceDelCentro,
        durata: _quantoEDurata,
      );

  /// La traccia dei giorni, che riempie il fiore. Ordine CZ voce 10.
  final TracciaDelLoto _traccia = TracciaDelLoto();

  /// **CIO' CHE LA MEDITAZIONE RICORDA.** Ordine DB voci 07 e 09.
  final MemoriaDelRespiro _memoria = MemoriaDelRespiro();

  /// **I RITI CHE LA PERSONA SI E' COSTRUITA.** Ordine DB voce 05.

  /// La frase che Aura dice alla fine, quando la memoria ha qualcosa di vero
  /// da dire. Nulla quando non ce l'ha: **non si inventa niente**.
  String? _cioCheAuraRicorda;

  /// Quando e' cominciata la sessione, per sapere quanto e' durata.
  DateTime? _cominciata;

  /// Il riquadro da cui nasce l'immagine della card del respiro.
  final GlobalKey _boundaryDellaCard = GlobalKey();

  /// Vero quando la persona ha chiesto meno movimento: i petali non si
  /// animano, la fase cambia con uno stato fermo, e la vibrazione resta.
  bool _riduciMovimento = false;

  // **QUI STAVA `_sceltaAperta`**, l'interruttore della scelta libera della
  // frequenza. Ordine DD voce 17: la frequenza si sceglie dentro il pannello
  // del sintomo, e un interruttore per aprire una cosa che e' gia' aperta non
  // serve a nessuno.

  /// **RESPIRO DA SOLO: il fiore segue il riferimento invece del dito.**
  /// Ordine DA voce 03, 10 settembre 2026.
  ///
  /// **Da dove nasce.** Nel manifesto dell'ordine DB, voce 12, avevo scritto
  /// che il gesto del dito si rompe *"a mani occupate, che e' il caso di chi
  /// medita sdraiato: li' il dito non e' la via giusta e nessuna soglia lo
  /// salva"*. Il fondatore ha detto di procedere.
  ///
  /// **Non e' un ripiego per un sensore che manca**, ed e' la differenza che
  /// conta: la regola di casa chiede un gesto tattile dove c'e' un sensore, e
  /// qui il sensore non c'e'. Questa e' l'altra meta': **un modo di respirare
  /// per chi non puo' toccare lo schermo.**
  ///
  /// Chi lo sceglie lo ritrova dichiarato sulla card, perche' quella figura
  /// e' del ritmo dell'app e non sua, e spacciarla per sua sarebbe la prima
  /// bugia di questa funzione.
  // **QUI STAVA `_daSolo`**, la scelta di respirare senza tenere il dito.
  // Ordine DD voce 17: senza il dito quella scelta non ha piu' un contrario,
  // e il ripiego e' diventato la via.

  /// La pratica piu' breve da proporre a chi lascia a meta', o nulla.
  /// Ordine DA voce 05.
  Respiro? _piuCorta;

  /// La pratica scelta dalla libreria, se qualcuna lo e'.
  /// Ordine DD voce 12.
  Respiro? _praticaScelta;

  /// L'indice del centro acceso oggi, per accenderne il petalo.
  int get _indiceDelCentro {
    final oggi = FrequenzaDelGiorno.centroDi(widget.now ?? DateTime.now());
    final i = ChakraDelGiorno.tutti.indexWhere((c) => c.nome == oggi.nome);
    return i < 0 ? 0 : i;
  }

  @override
  void initState() {
    super.initState();
    // **LA FREQUENZA SEGUE IL CENTRO DI OGGI**, e se un centro restasse senza
    // la sua si ripiega sul 432 dichiarandolo, invece di suonare un numero
    // diverso da quello scritto.
    _preset = MeditationPreset.perCentro(_indiceDelCentro) ??
        MeditationPreset.calm432;
    _breath = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _cycleMs),
    );
    // La traccia si legge dal disco: il fiore deve gia' portare i giorni
    // quando compare, non riempirsi sotto gli occhi di chi guarda.
    unawaited(_memoria.carica().then((_) {
      if (!mounted) return;
      // **LA PROPOSTA NASCE SOLO SE L'APP STA CHIEDENDO TROPPO.**
      // Ordine DA voce 05: piu' di una sessione su tre lasciata a meta', e
      // almeno quattro sessioni alle spalle. Sotto quelle soglie non c'e'
      // un'abitudine, c'e' quello che e' successo l'altro ieri.
      if (!_memoria.chiedeTroppo) return;
      final quanto = _memoria.quantoDuraDavvero;
      if (quanto == null) return;
      final piuCorta = LibreriaDeiRespiri.piuCortaDi(quanto);
      if (piuCorta == null) return;
      setState(() => _piuCorta = piuCorta);
    }));
    unawaited(_traccia.carica().then((_) {
      if (mounted) setState(() {});
    }));
  }

  /// **IL GIRO PARTE SOLO SENZA RIDUCI MOVIMENTO, ordine AJ voce 01**: il
  /// repeat di `_breath` girava anche per chi ha chiesto meno movimento. La
  /// MediaQuery non si legge in initState, quindi la guardia sta qui e vale
  /// a ogni cambio di dipendenze.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _riduciMovimento = MediaQuery.of(context).disableAnimations;
    // **L'OROLOGIO DEL RESPIRO NON SI FERMA MAI.** Ordine DD voce 16,
    // 10 settembre 2026.
    //
    // **Difetto trovato sul telefono 767f596c**, e la causa non era nel
    // codice della Meditazione: `settings get global animator_duration_scale`
    // risponde **0,0** su quel dispositivo, cioe' Riduci Movimento e' acceso.
    // Qui l'orologio veniva **fermato**, e con lui si fermavano la fase, il
    // fiore guidato e il conto alla rovescia: il numero al centro restava su
    // quattro per sempre, misurato su due fotografie a tre secondi di
    // distanza.
    //
    // **Un conto alla rovescia e' informazione, non decorazione**, e chi ha
    // spento le animazioni ne ha piu' bisogno, non meno: senza il movimento
    // continuo del petalo, il numero e' l'unica cosa che dice a che punto sta
    // la fase. Quindi l'orologio gira sempre, e Riduci Movimento **squadra la
    // figura** invece di fermare il tempo, che e' la stessa scelta gia' fatta
    // per la discesa del Viaggio.
    if (!_breath.isAnimating) _breath.repeat();
  }

  @override
  void dispose() {
    // IL TONO SI FERMA QUI. Prima si chiudeva il respiro e basta: il tono suona
    // in ciclo continuo, quindi uscendo dalla schermata restava acceso per
    // sempre. Che fosse una dimenticanza e non una scelta lo diceva il Rito del
    // Sogno, che con lo stesso lettore lo fermava gia'.
    _sessione?.cancel();
    widget.player.stop();
    _breath.dispose();
    super.dispose();
  }

  /// Quanto e' pieno il respiro adesso, l'etichetta della fase, **e quanti
  /// secondi mancano alla fine di questa fase**.
  ///
  /// **IL CONTO ALLA ROVESCIA, e lo ha chiesto il fondatore.** Ordine DD voce
  /// 16, 10 settembre 2026: *"l'utente fa click e parte l'animazione inspira e
  /// il fiore si ingrandisce, ma contemporaneamente l'utente vede un countdown
  /// in secondi che gli da una guida, poi si ferma altri tre secondi o quanto
  /// necessario di countdown e poi espira sempre con countdown e fiore che si
  /// riduce"*.
  ///
  /// **Perche' cambia tutto pur essendo un numero.** Il fiore diceva gia' cosa
  /// fare, e non diceva **per quanto ancora**: chi respira guidato ha bisogno
  /// di sapere quando finisce la fase, altrimenti tiene il fiato guardando un
  /// petalo e indovinando. Con gli occhi chiusi resta la vibrazione, che
  /// arriva al cambio di fase; con gli occhi aperti adesso c'e' il numero.
  ///
  /// **Il numero si arrotonda per eccesso**, cosi' non compare mai lo zero
  /// prima che la fase sia davvero finita: a quattro secondi di inspiro il
  /// conto va 4, 3, 2, 1 e cambia fase.
  ({double fill, String phase, int secondi}) _breathState() {
    final ms = _breath.value * _cycleMs;
    // **CON RIDUCI MOVIMENTO LA FIGURA VA A SCATTI, NON IL TEMPO.** Il fiore
    // si ferma su tre aperture, una per fase, e il conto continua a scorrere.
    if (_riduciMovimento) {
      if (ms < _inhaleMs) {
        return (
          fill: 0.5,
          phase: 'Inspira',
          secondi: _quantiSecondi(_inhaleMs - ms),
        );
      }
      if (ms < _inhaleMs + _holdMs) {
        return (
          fill: 1.0,
          phase: 'Trattieni',
          secondi: _quantiSecondi(_inhaleMs + _holdMs - ms),
        );
      }
      return (
        fill: 0.0,
        phase: 'Espira',
        secondi: _quantiSecondi(_cycleMs - ms),
      );
    }
    if (ms < _inhaleMs) {
      return (
        fill: Curves.easeInOut.transform(ms / _inhaleMs),
        phase: 'Inspira',
        secondi: _quantiSecondi(_inhaleMs - ms),
      );
    }
    if (ms < _inhaleMs + _holdMs) {
      return (
        fill: 1.0,
        phase: 'Trattieni',
        secondi: _quantiSecondi(_inhaleMs + _holdMs - ms),
      );
    }
    final e = (ms - _inhaleMs - _holdMs) / _exhaleMs;
    return (
      fill: 1.0 - Curves.easeInOut.transform(e),
      phase: 'Espira',
      secondi: _quantiSecondi(_cycleMs - ms),
    );
  }

  /// I secondi che mancano, arrotondati per eccesso e mai sotto uno.
  static int _quantiSecondi(double millisecondi) {
    final s = (millisecondi / 1000).ceil();
    return s < 1 ? 1 : s;
  }

  // **QUI VIVEVANO `_inspira` E `_espira`, i due gesti del dito.** Ordine DD
  // voce 17, 10 settembre 2026, decisione del fondatore: *"elimina la
  // possibilita' di tenere il dito premuto, solo pulsante play e stop"*.
  //
  // **Cosa facevano, perche' nessuno debba riscoprirlo.** Il dito giu' faceva
  // inspirare e, dall'ordine DD voce 12, accendeva anche la sessione se era
  // ferma; il dito su faceva espirare. Fra i due, `RespiroGuidatoDalDito`
  // misurava i millisecondi veri, e da quelli nasceva la figura della card.
  //
  // **Se ne sono andati insieme al gesto**, e con loro la vibrazione al cambio
  // di fase: senza un cambio deciso dalla persona, una vibrazione sarebbe il
  // telefono che parla da solo.

  void _togglePlay() {
    setState(() {
      _active = !_active;
      if (_active) _compiuta = false;
    });
    if (_active) {
      _cominciata = widget.now ?? DateTime.now();
      widget.player.play(_preset);
      _sessione?.cancel();
      _sessione = Timer(
        const Duration(milliseconds: _cycleMs * cicliDellaSessione),
        _alCompimento,
      );
    } else {
      // Fermarsi a meta' non e' compiere: il gesto si registra solo alla
      // fine della sessione, e chi interrompe riparte da capo.
      _sessione?.cancel();
      widget.player.stop();
    }
  }

  void _alCompimento() {
    if (!mounted) return;
    widget.player.stop();
    setState(() {
      _active = false;
      _compiuta = true;
    });
    // IL CAMMINO SE NE ACCORGE: la meditazione e' compiuta, non aperta.
    //
    // **E IL CENTRO VIAGGIA COL GESTO. Ordine DB voce 06**, 9 settembre 2026.
    // Il gesto partiva senza dettagli, e il diario non poteva sapere QUALE
    // centro era stato respirato: le condizioni `VarietaDelDettaglio` e
    // `CoincidenzaDelDettaglio` esistono gia' e sapevano gia' guardare i
    // dettagli, ma qui non ne arrivava nessuno. **Nessun traguardo si monta
    // qui**, che e' cio' che la voce 06 vieta: si apre soltanto la porta,
    // cosi' i traguardi che il fondatore scrivera' non chiedono codice nuovo.
    unawaited(RegiaDelCammino.dopoUnGesto(context, 'meditazione',
        dettagli: {'centro': ChakraDelGiorno.tutti[_indiceDelCentro].nome}));
    // **E LA GOCCIA RESTA NEL LOTO. Ordine CZ voce 10**, 8 settembre 2026.
    //
    // Il centro non si sceglie: e' quello acceso nel giorno in cui si respira,
    // e viene dalla stessa porta che ha deciso la frequenza. Una sorgente
    // sola per il centro, come per il numero.
    unawaited(
        _traccia.unaGoccia(quando: widget.now ?? DateTime.now()).then((_) {
      if (mounted) setState(() {});
    }));
    // **E LA MEMORIA SE NE ACCORGE.** Ordine DB voci 07 e 09, 9 settembre
    // 2026. La sessione si scrive PRIMA che nasca la frase, cosi' la frase
    // guarda una memoria che contiene anche oggi: dire *"e' la prima volta
    // che respiri su questo centro"* si puo' soltanto sapendo che oggi c'e'
    // dentro.
    unawaited(_segnaLaSessione());
  }

  /// Scrive la sessione appena chiusa e ne ricava la frase di Aura.
  Future<void> _segnaLaSessione({bool compiuta = true}) async {
    final adesso = widget.now ?? DateTime.now();
    final inizio = _cominciata ?? adesso;
    await _memoria.segna(SessioneDiRespiro(
      quando: inizio,
      centro: _indiceDelCentro,
      durata: adesso.difference(inizio),
      compiuta: compiuta,
      // **DA OGGI OGNI RESPIRO E' GUIDATO, e il campo resta a dirlo.**
      // Ordine DD voce 17, 10 settembre 2026: senza il dito il ritmo e' uno
      // solo, quello dell'app.
      //
      // **Il campo non si cancella**, perche' le sessioni gia' registrate
      // portano il loro valore e una memoria che cambia significato sotto i
      // piedi e' peggio di un campo sempre vero: chi legge lo storico deve
      // poter distinguere le sessioni col dito da queste.
      guidato: true,
    ));
    if (!mounted) return;
    setState(() {
      _cioCheAuraRicorda = compiuta
          ? CioCheAuraRicorda.unaCosaSola(_memoria,
              centroDiOggi: _indiceDelCentro)
          : null;
    });
  }

  /// **CONDIVIDE LA CARD, DAL PUNTO UNICO.** Ordine DB voce 10.
  Future<void> _condividiIlRespiro() async {
    final righe = [
      CardDelRespiro.titoloPer(_quantoEDurata),
      ...CardDelRespiro.righeDellaCard(
        sintomo: _praticaScelta?.sintomo,
        pratica: _praticaScelta?.nome,
        hertz: _preset.leftHz.round(),
        giorno: widget.now ?? DateTime.now(),
        giorniDiFila: _memoria.giorniDiFila,
      ),
    ];
    await condividiLaCardDelRespiro(
      boundaryKey: _boundaryDellaCard,
      testo: righe.join(' '),
    );
  }

  /// **SCELTO IL SINTOMO, LA PRATICA PARTE SUBITO.** Ordine DD voce 12.
  ///
  /// *"Scelto il sintomo, Aura fa partire la pratica adatta subito, senza
  /// altri passaggi da confermare."* Nessuna schermata in mezzo e nessuna
  /// conferma: si tocca e si respira.
  ///
  /// **E LA FREQUENZA SEGUE LA PRATICA.** Una pratica del centro del cuore
  /// suona il tono del cuore: e' l'unico modo perche' il numero che la
  /// schermata scrive e il numero che suona restino lo stesso numero.
  void _cominciaLaPratica(Respiro r) {
    final suo = MeditationPreset.perCentro(r.centro);
    setState(() {
      if (suo != null) _preset = suo;
      // **CHI HA SCELTO DEVE VEDERE COSA HA SCELTO.** Senza questa riga, chi
      // tocca una pratica mentre la sessione gira non vede cambiare niente:
      // misurato sul telefono, zero pixel.
      _praticaScelta = r;
    });
    if (!_active) {
      _togglePlay();
    } else {
      widget.player.play(_preset);
    }
  }

  /// **SCELTA UNA FREQUENZA, si accende e suona.** Ordine DD voce 17.
  ///
  /// **Se la sessione e' ferma, parte.** E' la stessa legge del sintomo della
  /// voce DD.12: un comando che risponde e non lo dice e' un comando morto per
  /// chi lo guarda, e toccare una frequenza senza sentirla cambiare non e'
  /// una risposta.
  void _scegliLaFrequenza(MeditationPreset preset) {
    setState(() => _preset = preset);
    if (_active) {
      widget.player.play(preset);
    } else {
      _togglePlay();
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Scaffold(
      backgroundColor: ColorTokens.neutralDeepest,
      appBar: AppBar(
        backgroundColor: palette.deepest.withValues(alpha: 0.4),
        elevation: 0,
        iconTheme: IconThemeData(color: palette.goldSoft),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Indietro',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        // **IL TITOLO NON SI ROMPE**, ordine S voce 05: a capo fra le
        // parole, la misura scende solo quanto serve, e non si tronca mai.
        // Col borsellino nella riga delle azioni lo spazio del titolo si e'
        // ristretto, e un `Text` nudo qui torna a mettere i puntini.
        title: TitoloCheNonSiRompe(
            testo: 'Meditazione', stile: TypographyTokens.titoloDiSchermata()),
        // IL BORSELLINO, ordine S voce 06: stesso segno, stesso angolo, in
        // ogni schermata della pratica. Un saldo che appare e scompare non
        // si impara.
        // **LA FONTE ARRIVA A CHI LEGGE.** Ordine CS, voce S2 della
        // scansione: la riga sul 432 dice cosa la Meditazione NON e', e non da dove nasce.
        actions: [
          FoglioDelleFonti.bottone(context,
              palette: palette,
              testo: TestiDelleFonti.meditazione,
              chiave: 'meditazione_fonti'),
          const AngoloDellaBarra(),
        ],
      ),
      // **LO SFONDO E' IL MONDO DI AURA, NON IL NERO.** Ordine DD voce 13,
      // 10 settembre 2026.
      //
      // **Difetto visto sul telefono 767f596c**, build 2244: la schermata
      // aveva `ColorTokens.neutralDeepest` e basta, cioe' **nero pieno**,
      // senza una stella e senza parallasse. Non e' il mondo di Aura e non e'
      // quello dell'app: ogni altra schermata di questo progetto poggia sul
      // cosmo, e la Meditazione era l'unica stanza buia della casa.
      //
      // Il cielo e' lo stesso della home, con la palette di Aura passata a
      // mano: **stesso componente, stesso movimento, colore del Maestro**.
      // Il seme e' suo, cosi' le stelle non ripetono la figura di un'altra
      // schermata.
      body: CosmosBackground(
        seed: 24,
        showZodiac: false,
        paletteOverride: palette,
        child: SafeArea(
          top: false,
          // **IL LOTO PRENDE LA LARGHEZZA INTERA, E IL RESTO SCORRE SOTTO.**
          // Ordine DB voce 13, difetto trovato sul telefono 767f596c il 9
          // settembre 2026.
          //
          // Qui c'era una `Column` col loto dentro un `Expanded`: il fiore
          // prendeva **l'altezza che avanzava** dopo la colonna di testo, e su
          // uno schermo vero avanzava poco. Il fiore occupava il 53,8 per cento
          // del suo riquadro, che e' cio' che la voce 04 pretende, **e il 35,0
          // per cento dello schermo**, che e' di nuovo la figura piccola con la
          // cornice vuota attorno.
          //
          // Adesso il riquadro e' un quadrato largo quanto lo schermo, e il
          // testo scorre invece di contendergli lo spazio: **la misura non
          // dipende piu' da quanto testo c'e' sotto.**
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Il visualizzatore a cimatica, col respiro sovrapposto.
                SizedBox(
                  width: double.infinity,
                  child: Center(
                    // **IL DITO GUIDA IL RESPIRO. Ordine CZ voce 08.**
                    //
                    // Giu' si inspira, alzato si espira, e al cambio di fase il
                    // telefono vibra piano: cosi' l'esperienza funziona **a occhi
                    // chiusi**, che e' l'unico modo in cui una meditazione ha
                    // senso. Nessun sensore richiesto: il gesto tattile e' gia' il
                    // gesto, quindi la regola di casa sul ripiego e' soddisfatta
                    // per costruzione.
                    // **UN COMANDO SOLO, CHE ACCENDE E SPEGNE. Ordine DD
                    // voce 17, 10 settembre 2026, decisione del fondatore:**
                    // *"elimina la possibilita' di tenere il dito premuto,
                    // solo pulsante play e stop (stesso pulsante)"*.
                    //
                    // **Cosa c'era, e perche' se n'e' andato.** Il dito giu'
                    // inspirava, il dito su espirava, e i tempi veri
                    // disegnavano la figura della card. Era la cosa piu'
                    // originale di questa schermata **e chiedeva di tenere il
                    // pollice sul vetro per cinque minuti**, che e' il
                    // contrario di chiudere gli occhi.
                    //
                    // **Il fiore resta toccabile e fa la STESSA cosa del
                    // pulsante**: parte e si ferma. Un cerchio grande e bello
                    // che ignora il dito e' peggio del difetto da cui
                    // quest'ordine e' nato, che era *"faccio click e non
                    // succede nulla"*. **Un'azione sola, due superfici,
                    // nessun gesto nascosto.**
                    child: GestureDetector(
                      key: const Key('meditation_dito'),
                      behavior: HitTestBehavior.opaque,
                      onTap: _togglePlay,
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: AnimatedBuilder(
                          animation: _breath,
                          builder: (context, _) {
                            final b = _breathState();
                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                // **IL LOTO AL POSTO DEL CERCHIO. Ordine CZ voce
                                // 08**, 8 settembre 2026. Parole del fondatore: *"Il
                                // cerchio che si gonfia esce. E' la forma di ogni
                                // altra app di meditazione e non e' la nostra."*
                                //
                                // I petali si aprono col respiro, portano la traccia
                                // dei giorni, e il petalo di un centro mai respirato
                                // resta spento.
                                Positioned.fill(
                                  child: LotoCheRespira(
                                    key: const Key('meditation_loto'),
                                    // **IL FIORE VA COL RITMO, SEMPRE.**
                                    // Ordine DD voce 17: senza il dito non
                                    // c'e' piu' un secondo ritmo da seguire.
                                    // Qui viveva la scelta fra il respiro
                                    // proprio e quello guidato, e adesso il
                                    // riferimento e' uno solo.
                                    apertura: b.fill,
                                    // **IL COLORE DEL CENTRO DI OGGI, non quello del
                                    // Maestro.** Ordine DB voce 04: siccome il
                                    // centro cambia ogni giorno, il fiore di domani
                                    // e' di un altro colore, ed e' un motivo per
                                    // tornare che non costa niente.
                                    coloreDelCentro: ColoreDelCentro.di(
                                        widget.now ?? DateTime.now()),
                                    gocce: _traccia.gocce,
                                    centroDiOggi: _indiceDelCentro,
                                    senzaMoto: _riduciMovimento,
                                  ),
                                ),
                                _BreathGuide(
                                  fill: b.fill,
                                  // **A SESSIONE FERMA IL CENTRO DICE COSA
                                  // FARE**, e lo dice con la parola del
                                  // comando: *premi play*. Ordine DD voce 17.
                                  phase: _active
                                      ? b.phase
                                      : (_compiuta
                                          ? 'Il respiro è compiuto'
                                          : 'Premi play'),
                                  // **IL CONTO ALLA ROVESCIA SOLO A SESSIONE VIVA.**
                                  // Ordine DD voce 16: un numero che scorre su una
                                  // schermata ferma sarebbe un orologio, non una
                                  // guida.
                                  secondi: _active ? b.secondi : null,
                                  palette: palette,
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      SpacingTokens.lg, 0, SpacingTokens.lg, SpacingTokens.md),
                  child: Column(
                    children: [
                      // **LA FREQUENZA LA ASSEGNA AURA, E LO DICE. Ordine CZ
                      // voce 06**, 8 settembre 2026.
                      //
                      // Parole del fondatore: *"Un menu' di frequenze davanti a
                      // chi non ha criterio per scegliere e' la forma sbagliata:
                      // Aura non e' un lettore multimediale, e' una guida, e una
                      // guida decide."*
                      //
                      // La riga di Aura nomina il centro e il numero, e dice
                      // perche' e' quello. La scelta libera **resta**, sotto,
                      // dietro un tocco: chi vuole scegliere puo', chi non sa
                      // cosa scegliere non deve.
                      // **IL TESTO NARRATO PASSA DALLA PORTA UNICA**, e non si
                      // tinge del colore del Maestro: due guardie lo pretendono,
                      // e hanno ragione. Il colore del Maestro sta nella scena,
                      // negli accenti e nei bordi; il testo che si legge resta
                      // inchiostro, perche' un testo tinto si legge peggio e
                      // cambia significato col Maestro del giorno.
                      // **E SE UNA PRATICA E' STATA SCELTA, QUESTA RIGA TACE.
                      // Ordine DD voce 12, trovato sul telefono 767f596c il
                      // 10 settembre 2026, dopo la cura.**
                      //
                      // La riga dice *"Oggi e' acceso il cuore... la
                      // tradizione gli accosta i 639 hertz. **E' la frequenza
                      // di questa sessione**"*. E' vera finche' la sessione e'
                      // quella che Aura ha scelto dal centro del giorno.
                      //
                      // **Scegliendo dalla libreria la sessione cambia**, e la
                      // riga restava a schermo a dichiarare una frequenza che
                      // non stava piu' suonando: sotto di lei si leggeva
                      // *"Senso di insicurezza: Il suono della radice"*, che
                      // e' 396. **Due frasi sulla stessa cosa che dicono due
                      // numeri diversi**, ed e' esattamente il difetto da cui
                      // questa voce e' nata.
                      //
                      // **Non si riscrive la riga con la frequenza nuova**: il
                      // suo soggetto e' *il centro di oggi*, non la sessione,
                      // e adattarla vorrebbe dire farle dire una cosa che non
                      // sa. Quando la scelta e' di chi guarda, a parlare resta
                      // la riga della pratica scelta, che dice il vero.
                      if (_praticaScelta == null)
                        ParagrafiDiLettura(
                          testo: FrequenzaDelGiorno.perche(
                              widget.now ?? DateTime.now()),
                          key: const Key('meditation_perche_la_frequenza'),
                          textAlign: TextAlign.center,
                          stile: TypographyTokens.lettura().copyWith(
                              color: ColorTokens.textPrimary, height: 1.4),
                        ),
                      // **LA PRATICA IN CORSO SI LEGGE**, quando ne e' stata
                      // scelta una: il sintomo e il nome, una riga sola.
                      if (_praticaScelta != null) ...[
                        const SizedBox(height: SpacingTokens.xs),
                        Text(
                          '${_praticaScelta!.sintomo.etichetta}: '
                          '${_praticaScelta!.nome}, '
                          '${_praticaScelta!.quantoDura}.',
                          key: const Key('meditazione_pratica_in_corso'),
                          textAlign: TextAlign.center,
                          style: TypographyTokens.corpo()
                              .copyWith(color: palette.goldSoft),
                        ),
                      ],
                      const SizedBox(height: SpacingTokens.md),
                      // **IL PULSANTE DEL SINTOMO STA SUBITO SOTTO LA RIGA DI
                      // AURA.** Ordine DD voce 12, 10 settembre 2026, e l'ordine
                      // lo colloca per nome: *"subito sotto la riga con cui Aura
                      // consiglia la meditazione del giorno"*.
                      //
                      // **Prima stava in fondo alla colonna**, dopo il fiore,
                      // dopo la frequenza, dopo il play e dopo la card: chi non
                      // scorreva fino in fondo non sapeva che la libreria
                      // esistesse. La porta principale resta quella dell'ordine
                      // CZ voce 06, Aura sceglie: questo e' il secondo modo, per
                      // chi arriva con un sintomo invece che con una giornata.
                      PannelloDellaLibreria(
                        palette: palette,
                        centroDiOggi: _indiceDelCentro,
                        onSceglie: _cominciaLaPratica,
                        // **E DA QUI SI SCEGLIE ANCHE LA FREQUENZA**, ordine
                        // DD voce 17: il pulsante promette sintomo **e**
                        // frequenza, e adesso le da' tutte e due.
                        frequenzaScelta: _preset,
                        onFrequenza: _scegliLaFrequenza,
                      ),
                      const SizedBox(height: SpacingTokens.sm),
                      // **QUI C'ERA "PREFERISCO SCEGLIERE IO", E SE N'E'
                      // ANDATO. Ordine DD voce 17, 10 settembre 2026,
                      // decisione del fondatore:** *"elimina 'preferisco
                      // scegliere io', e' ridondante visto che dal pulsante
                      // puo' gia' scegliere sintomo e frequenza"*.
                      //
                      // **Aveva ragione, e il nome del pulsante lo diceva
                      // gia'.** Il pulsante grande si chiama **SCEGLI SINTOMO
                      // E FREQUENZA** e apriva un pannello con i soli sintomi:
                      // la frequenza stava dietro un secondo interruttore, piu'
                      // in basso, con parole sue. **Due porte per una promessa
                      // sola.**
                      //
                      // Le nove frequenze adesso vivono **dentro quel
                      // pannello**, sotto i sintomi, e il pulsante mantiene
                      // cio' che il suo nome promette.
                      // **QUI C'ERA "RESPIRO DA SOLO", E NON HA PIU' UN
                      // CONTRARIO. Ordine DD voce 17.**
                      //
                      // Nasceva dall'ordine DA voce 03 per chi non puo' tenere
                      // il dito sullo schermo: era **il ripiego di un gesto**,
                      // e quel gesto non c'e' piu'. Adesso tutti respirano col
                      // ritmo dell'app, che era esattamente cio' che quel
                      // pulsante offriva: **il ripiego e' diventato la via**,
                      // e un interruttore che porta dove sei gia' e' rumore.
                      // **LA PRATICA PIU' BREVE, a chi lascia a meta'.**
                      // Ordine DA voce 05, 10 settembre 2026.
                      //
                      // **Non si dice mai alla persona che ha lasciato a meta'.**
                      // Si propone e basta: il giudizio non serve a nessuno, e la
                      // voce DB.08 vieta al Maestro di dichiarare che osserva.
                      if (_piuCorta != null) ...[
                        const SizedBox(height: SpacingTokens.xs),
                        Row(
                          key: const Key('meditazione_pratica_piu_corta'),
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.hourglass_bottom_rounded,
                                size: 16, color: palette.goldSoft),
                            const SizedBox(width: SpacingTokens.xs),
                            Expanded(
                              child: ParagrafiDiLettura(
                                testo: 'Se oggi hai poco tempo: '
                                    '${_piuCorta!.nome}, '
                                    '${_piuCorta!.quantoDura}.',
                                stile: TypographyTokens.lettura()
                                    .copyWith(color: palette.goldSoft),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: SpacingTokens.md),
                      // **IL COMPIMENTO SI DICE, ordine BF voce 05.b**: senza
                      // questa riga la sessione finirebbe in silenzio e la
                      // persona non saprebbe di essere arrivata.
                      if (_compiuta) ...[
                        Row(
                          key: const Key('meditazione_compiuta'),
                          children: [
                            Icon(Icons.spa_outlined,
                                size: 16, color: palette.goldSoft),
                            const SizedBox(width: SpacingTokens.xs),
                            Expanded(
                              child: ParagrafiDiLettura(
                                testo: 'La meditazione è portata a compimento: '
                                    'porta questa calma con te.',
                                stile: TypographyTokens.lettura()
                                    .copyWith(color: palette.goldSoft),
                              ),
                            ),
                          ],
                        ),
                        // **CIO' CHE AURA RICORDA, e nasce solo se e' vero.**
                        // Ordine DB voce 09, 9 settembre 2026: *"e' il momento in
                        // cui l'app dimostra di essersi accorta... una frase, mai
                        // due. E solo quando c'e' qualcosa di vero da dire: se la
                        // memoria non ha niente, non si inventa niente e la
                        // sessione si chiude com'e'."*
                        //
                        // **Una osservazione falsa distrugge in una riga la
                        // fiducia che dieci vere hanno costruito**, ed e' per
                        // questo che ogni frase ha una soglia sotto la quale non
                        // nasce: due sere di fila non sono una striscia, e sei
                        // sessioni sono il minimo per dire che si allungano.
                        if (_cioCheAuraRicorda != null) ...[
                          const SizedBox(height: SpacingTokens.sm),
                          Row(
                            key: const Key('meditazione_aura_ricorda'),
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.auto_awesome_rounded,
                                  size: 16, color: palette.gold),
                              const SizedBox(width: SpacingTokens.xs),
                              Expanded(
                                child: ParagrafiDiLettura(
                                  testo: _cioCheAuraRicorda!,
                                  // **ORO CHIARO E NON ORO PIENO**, e lo ha
                                  // chiesto il censimento dei grigi: su un fondo
                                  // di Maestro l'oro pieno non arriva alla soglia
                                  // che il corpo di lettura pretende.
                                  stile: TypographyTokens.lettura()
                                      .copyWith(color: palette.goldSoft),
                                ),
                              ),
                            ],
                          ),
                        ],
                        // **LA CARD DEL RESPIRO.** Ordine DB voce 10, e chiude
                        // la voce CZ.09 rimasta ferma: la figura era calcolata e
                        // provata, il disegno non esisteva.
                        //
                        // **Compare solo se ci sono respiri veri da disegnare**:
                        // una figura di zero respiri e' un cerchio vuoto, e
                        // mostrarlo sarebbe peggio che non mostrare niente.
                        // **LA CARD NASCE A SESSIONE VISSUTA, non a respiri
                        // contati.** Ordine DD voce 17: i respiri li contava
                        // il dito, e il dito non c'e' piu'. La soglia adesso
                        // e' il tempo davvero passato a respirare, e sotto il
                        // minuto non si offre da condividere niente: una card
                        // di venti secondi non e' un traguardo.
                        if (_quantoEDurata.inSeconds >= 60) ...[
                          const SizedBox(height: SpacingTokens.md),
                          Center(
                            child: RepaintBoundary(
                              key: _boundaryDellaCard,
                              child: CardDelRespiro(
                                figura: _sigilloDiOra,
                                giorno: widget.now ?? DateTime.now(),
                                durata: _quantoEDurata,
                                sintomo: _praticaScelta?.sintomo,
                                pratica: _praticaScelta?.nome,
                                hertz: _preset.leftHz.round(),
                                giorniDiFila: _memoria.giorniDiFila,
                              ),
                            ),
                          ),
                          const SizedBox(height: SpacingTokens.sm),
                          OutlinedButton.icon(
                            key: const Key('meditazione_condividi_respiro'),
                            onPressed: _condividiIlRespiro,
                            style: OutlinedButton.styleFrom(
                                foregroundColor: palette.goldSoft,
                                side: BorderSide(
                                    color: palette.gold.withValues(alpha: 0.6)),
                                minimumSize: const Size.fromHeight(48)),
                            icon: const Icon(Icons.ios_share_rounded, size: 18),
                            label: Text('Condividi il tuo respiro',
                                style: TypographyTokens.etichetta()),
                          ),
                        ],
                        const SizedBox(height: SpacingTokens.md),
                      ],
                      // Play e invito alle cuffie.
                      Row(
                        children: [
                          _PlayButton(
                            active: _active,
                            palette: palette,
                            onTap: _togglePlay,
                          ),
                          const SizedBox(width: SpacingTokens.md),
                          Expanded(
                            child: Text(
                              _preset.binaural
                                  ? 'Metti le cuffie: il battito nasce fra i due orecchi.'
                                  : 'Con le cuffie l\'ascolto si fa più pieno.',
                              style: TypographyTokens.corpo()
                                  .copyWith(color: ColorTokens.textSecondary),
                            ),
                          ),
                        ],
                      ),
                      // Fondamento onesto, senza ripetere il disclaimer.
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.eco_outlined,
                              size: 14, color: palette.goldSoft),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Cornice di benessere, non cura. Le frequenze Solfeggio '
                              'e il 432 sono tradizione culturale, non un fatto medico.',
                              style: TypographyTokens.corpo().copyWith(
                                color: palette.goldSoft.withValues(alpha: 0.7),
                                letterSpacing: 0.3,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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

/// La guida al respiro: un cerchio che si allarga inspirando e si restringe
/// espirando, con l'etichetta della fase al centro.
class _BreathGuide extends StatelessWidget {
  const _BreathGuide({
    required this.fill,
    required this.phase,
    required this.palette,
    this.secondi,
  });

  final double fill;
  final String phase;
  final MaestroPalette palette;

  /// **QUANTI SECONDI MANCANO ALLA FINE DELLA FASE**, oppure nulla quando la
  /// sessione non e' partita. Ordine DD voce 16, 10 settembre 2026.
  final int? secondi;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = math.min(constraints.maxWidth, constraints.maxHeight);
        final d = side * (0.28 + 0.16 * fill);
        return Container(
          width: d,
          height: d,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [
              palette.primary.withValues(alpha: 0.35),
              palette.deepest.withValues(alpha: 0.05),
            ]),
            border: Border.all(
                color: palette.gold.withValues(alpha: 0.5), width: 1.2),
          ),
          // **LA FASE SOPRA, IL NUMERO SOTTO.** Ordine DD voce 16.
          //
          // Il numero e' piu' grande della parola apposta: a occhi socchiusi
          // la parola si e' gia' letta al cambio di fase, il numero invece si
          // guarda per tutta la fase. **Il conto e' la guida, l'etichetta e'
          // il titolo.**
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                phase,
                textAlign: TextAlign.center,
                style: TypographyTokens.label(size: 12).copyWith(
                  color: palette.goldSoft,
                  letterSpacing: 1.4,
                ),
              ),
              if (secondi != null) ...[
                const SizedBox(height: 2),
                Text(
                  '$secondi',
                  key: const Key('meditazione_conto_alla_rovescia'),
                  textAlign: TextAlign.center,
                  style: TypographyTokens.titoloDiSchermata().copyWith(
                    color: palette.goldSoft,
                    height: 1.0,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// Un preset sonoro selezionabile.
class _PlayButton extends StatelessWidget {
  const _PlayButton({
    required this.active,
    required this.palette,
    required this.onTap,
  });

  final bool active;
  final MaestroPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: const Key('meditation_play'),
      onTap: onTap,
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [
            palette.primary.withValues(alpha: 0.7),
            palette.surfaceElevated.withValues(alpha: 0.6),
          ]),
          border: Border.all(color: palette.gold.withValues(alpha: 0.7)),
          boxShadow: [
            BoxShadow(
              color: palette.glow.withValues(alpha: active ? 0.5 : 0.2),
              blurRadius: 18,
              spreadRadius: -2,
            ),
          ],
        ),
        child: Icon(
          active ? Icons.pause_rounded : Icons.play_arrow_rounded,
          color: palette.goldSoft,
          size: 30,
        ),
      ),
    );
  }
}

/// **IL CERCHIO CHE SI GONFIA E' USCITO. Ordine CZ voce 08**, 8 settembre
/// 2026. Parole del fondatore: *"E' la forma di ogni altra app di meditazione
/// e non e' la nostra."* Al suo posto c'e' `LotoCheRespira`, e il pittore a
/// cimatica e' stato tolto invece di essere lasciato spento: un componente che
/// nessuno monta e' un componente che qualcuno rimonta.
