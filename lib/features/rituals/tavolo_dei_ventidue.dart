import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/tarot/tarot_card.dart';
import '../tarot/tarot_card_art.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/typography_tokens.dart';

/// **IL TAVOLO DEI VENTIDUE.** Ordine DU, 17 settembre 2026, seconda stesura.
///
/// **Perche' non e' il ventaglio della Stesa.** La prima stesura riusava
/// `StesaFan`, l'arco sfogliabile dei settantotto. Il fondatore l'ha bocciato
/// con una ragione che vale piu' del risparmio: *"e' identico alla Stesa dei
/// Tarocchi, voglio qualcosa di originale"*. Gli arcani maggiori sono
/// **ventidue**, cioe' pochi abbastanza da stare tutti a video insieme: non
/// c'e' niente da sfogliare, c'e' un tavolo da guardare.
///
/// **Come entra in scena.** Le carte nascono da un punto solo, si aprono a
/// spirale e si posano nelle righe, una dopo l'altra, lasciando dietro una
/// scia di stelline. Poi **non stanno ferme**: ogni carta respira per conto
/// suo, con una fase diversa dalle altre, cosi' il tavolo resta vivo mentre
/// chi guarda sceglie.
///
/// **Le righe.** Ventidue carte leggermente sovrapposte: **tre righe da otto,
/// sette e sette** sul telefono, dove servono carte grandi abbastanza da
/// toccarle; **due righe da undici** dove lo schermo e' largo. Il conto non e'
/// scritto a mano: viene da [righeDi], che si legge e si prova.
///
/// **Mischia e taglia non cambiano l'esito, e va detto.** I ventidue dorsi
/// sono lo stesso disegno e la carta si estrae dal caso sicuro **nel momento
/// del tocco**: mescolare o tagliare muove le figure sul tavolo, non il
/// risultato. Restano perche' sono il gesto che una persona fa con un mazzo
/// vero, e perche' aiutano ad aspettare un istante prima di scegliere.
///
/// **E sono tutti e due un mazzo che si ricompone.** Il Mischia raccoglie,
/// mescola e ristende (ordine EE voce 01); il Taglia raccoglie, divide il
/// mazzo in due pacchetti, posa quello di sotto sopra l'altro e ristende
/// (ordine EL voce 02).
class TavoloDeiVentidue extends StatefulWidget {
  const TavoloDeiVentidue({
    super.key,
    required this.palette,
    required this.onScegli,
    required this.rivelazione,
    required this.faccia,
    this.scelta,
    this.ridotto = false,
    this.quante = 22,
  });

  final MaestroPalette palette;

  /// Il dorso toccato. **Quale sia non decide niente**: lo dice la voce DU.07.
  final ValueChanged<int> onScegli;

  /// Da zero a uno: la carta scelta che sale al centro e si gira.
  final Animation<double> rivelazione;

  /// La faccia da mostrare dopo il mezzo giro, costruita da chi ci chiama.
  final WidgetBuilder faccia;

  /// L'indice della carta scelta, quando la scelta c'e' stata.
  final int? scelta;

  /// Con Riduci Movimento il tavolo si posa fermo: niente spirale, niente
  /// respiro, niente scia.
  final bool ridotto;

  final int quante;

  /// **QUANTO DELLA LARGHEZZA OCCUPA LA CARTA RIVELATA.** Sta qui, pubblica,
  /// perche' la stessa misura vale anche quando il dono si riapre il giorno
  /// dopo: due numeri scritti in due posti diventano due carte di misura
  /// diversa per la stessa cosa.
  /// **Il settanta per cento della larghezza del tavolo**, che con i
  /// margini della colonna fa il sessantuno per cento dello schermo: e' la
  /// misura a cui la carta rivelata smette di sembrare persa in mezzo al
  /// vuoto. Al sessantadue si fermava al cinquantaquattro per cento dello
  /// schermo, misurato al banco.
  static const double parteDellaLarghezza = 0.70;

  /// **COME SI DIVIDONO IN RIGHE, dato lo spazio.** Due righe da undici dove
  /// c'e' larghezza, tre righe da otto, sette e sette dove non ce n'e'.
  static List<int> righeDi(int quante, double larghezza) {
    if (larghezza >= 420) {
      final prima = (quante / 2).ceil();
      return [prima, quante - prima];
    }
    final base = quante ~/ 3;
    final resto = quante % 3;
    return [
      for (var r = 0; r < 3; r++) base + (r < resto ? 1 : 0),
    ];
  }

  @override
  State<TavoloDeiVentidue> createState() => _TavoloDeiVentidueState();
}

class _TavoloDeiVentidueState extends State<TavoloDeiVentidue>
    with TickerProviderStateMixin {
  /// L'ingresso a spirale, una volta sola.
  late final AnimationController _ingresso;

  /// Il respiro del tavolo: gira per sempre, piano.
  late final AnimationController _respiro;

  /// I due gesti del mazzo, che muovono le figure e non l'esito.
  late final AnimationController _mischia;
  late final AnimationController _taglio;

  /// Se in questo taglio i posti si sono gia' scambiati. Lo scambio avviene
  /// una volta sola, a meta' corsa, e da li' il pacchetto di ogni carta si
  /// legge dal posto nuovo.
  bool _tagliato = false;

  /// Dove sta ogni carta sul tavolo: la posizione nella griglia. Mischiare
  /// rimescola questo, e siccome i dorsi sono uguali cambia la scena, non la
  /// sorte.
  late List<int> _posti = [for (var i = 0; i < widget.quante; i++) i];

  static const Duration _durataIngresso = Duration(milliseconds: 1500);
  static const Duration _durataRespiro = Duration(seconds: 7);

  /// **Ordine EE voce 01**: tre tempi, raccolta, mescolata e stesa, non
  /// stanno in 1100 millesimi senza sembrare uno strappo.
  static const Duration _durataMischia = Duration(milliseconds: 1800);

  /// **Ordine EL voce 02**: raccolta, taglio, mazzo rifatto e stesa sono
  /// quattro tempi, e in 900 millesimi, la durata del taglio di prima, il
  /// taglio stesso durerebbe un quinto di secondo.
  static const Duration _durataTaglio = Duration(milliseconds: 2000);

  /// **I TEMPI DEL TAGLIO**, in frazione della corsa. Fino a
  /// [_finoAllaRaccolta] le carte si radunano nel mazzo; fra
  /// [_siApreIlTaglio] e [_taglioAperto] il pacchetto di sopra si alza e va a
  /// destra mentre l'altro scivola a sinistra; a [_loScambio], con i due
  /// pacchetti separati, i posti si scambiano; fra [_siRichiude] e
  /// [_mazzoRifatto] il pacchetto che era sotto si alza e si posa sopra
  /// l'altro; poi le carte si ristendono dal mazzo.
  static const double _finoAllaRaccolta = 0.25;
  static const double _siApreIlTaglio = 0.31;
  static const double _taglioAperto = 0.49;
  static const double _loScambio = 0.52;
  static const double _siRichiude = 0.55;
  static const double _mazzoRifatto = 0.73;

  /// **Lo spessore del mazzo**: di quanto una carta si scosta da quella
  /// sotto. Ventidue dorsi perfettamente sovrapposti sembrerebbero una carta
  /// sola; cosi' il mazzo ha un bordo, e il pacchetto che si alza si vede
  /// staccarsi dall'altro.
  static const Offset _spessore = Offset(-0.3, -0.5);

  @override
  void initState() {
    super.initState();
    _ingresso = AnimationController(vsync: this, duration: _durataIngresso);
    _respiro = AnimationController(vsync: this, duration: _durataRespiro);
    _mischia = AnimationController(vsync: this, duration: _durataMischia);
    // **IL TAGLIO NON SI ACCORCIA.** E' il contenuto del pulsante: i
    // ventidue dorsi sono uguali, e un taglio corso venti volte piu' in
    // fretta, come Flutter fa coi controllori `normal` quando la scala degli
    // animatori e' a zero, non si vedrebbe. Vedi la guardia dell'ordine EF,
    // `le_animazioni_del_rito_non_si_accorciano_test.dart`.
    _taglio = AnimationController(
      vsync: this,
      duration: _durataTaglio,
      animationBehavior: AnimationBehavior.preserve,
    )..addListener(_scambiaNelTaglio);
    if (widget.ridotto) {
      _ingresso.value = 1;
    } else {
      _ingresso.forward();
      _respiro.repeat();
    }
  }

  @override
  void dispose() {
    _ingresso.dispose();
    _respiro.dispose();
    _mischia.dispose();
    _taglio.dispose();
    super.dispose();
  }

  bool get _sceglibile => widget.scelta == null;

  /// **CHI TOCCA MENTRE LE CARTE ENTRANO NON ASPETTA.** L'ingresso si chiude
  /// subito: nessuno deve guardare un'animazione che non ha chiesto.
  void _saltaLIngresso() {
    if (_ingresso.isCompleted) return;
    _ingresso.value = 1;
  }

  Future<void> _mescola() async {
    if (!_sceglibile || _mischia.isAnimating || _taglio.isAnimating) return;
    _saltaLIngresso();
    if (widget.ridotto) {
      setState(() => _posti = _mescolati());
      return;
    }
    // **LE CARTE SI MESCOLANO QUANDO SONO NEL MAZZO, non alla fine.**
    // Ordine EE voce 01.
    //
    // Prima i posti nuovi si assegnavano a corsa finita: durante tutta
    // l'animazione le carte puntavano al posto VECCHIO, e la stesa finale
    // le riportava dov'erano. Adesso il mazzo si chiude, i posti cambiano
    // **mentre le carte sono raccolte e nessuno le vede muoversi**, e la
    // seconda meta' le stende al posto nuovo.
    _mischia.forward(from: 0);
    // A meta' della raccolta il mazzo e' chiuso: e' li' che si mescola.
    await Future<void>.delayed(_durataMischia * 0.5);
    if (!mounted) return;
    setState(() => _posti = _mescolati());
    await _mischia.forward();
    if (!mounted) return;
    _mischia.value = 0;
  }

  /// **IL TAGLIO SI VEDE ANCHE CON RIDUCI MOVIMENTO**, ordine EL voce 02, e
  /// il Mischia no: e' una differenza dichiarata. Col movimento ridotto il
  /// Mischia cambia i posti senza animazione, come l'ha lasciato l'ordine
  /// EE, e il fondatore ha detto che il Mischia va bene cosi'. Il Taglia
  /// invece e' stato chiesto proprio come gesto da vedere, e sul telefono di
  /// collaudo, che ha la scala degli animatori a zero, senza il gesto un
  /// tocco su Taglia non mostrerebbe niente: i dorsi sono uguali.
  Future<void> _taglia() async {
    if (!_sceglibile || _mischia.isAnimating || _taglio.isAnimating) return;
    _saltaLIngresso();
    _tagliato = false;
    await _taglio.forward(from: 0);
    if (!mounted) return;
    setState(() {
      _taglio.value = 0;
      _tagliato = false;
    });
  }

  /// **I POSTI SI SCAMBIANO MENTRE I DUE PACCHETTI STANNO SEPARATI**, uno
  /// accanto all'altro: nessuna carta ne copre un'altra, e il cambio di quota
  /// fra i due pacchetti non si vede. Da li' il pacchetto che era sotto e'
  /// disegnato dopo l'altro, cioe' sopra, ed e' lui che si posa sul mazzo.
  /// Scambiare a corsa finita, come faceva il taglio di prima, fa saltare le
  /// carte sotto gli occhi.
  void _scambiaNelTaglio() {
    if (_tagliato || _taglio.value < _loScambio) return;
    setState(() {
      _posti = _tagliati();
      _tagliato = true;
    });
  }

  List<int> _mescolati() {
    final caso = math.Random();
    final lista = [..._posti];
    for (var i = lista.length - 1; i > 0; i--) {
      final j = caso.nextInt(i + 1);
      final t = lista[i];
      lista[i] = lista[j];
      lista[j] = t;
    }
    return lista;
  }

  /// Il taglio vero: il mazzo si divide in due e la meta' di sotto passa
  /// sopra.
  List<int> _tagliati() {
    final meta = _posti.length ~/ 2;
    return [..._posti.sublist(meta), ..._posti.sublist(0, meta)];
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, spazio) {
        final larghezza = spazio.maxWidth;
        final righe = TavoloDeiVentidue.righeDi(widget.quante, larghezza);
        final disegno = _DisegnoDelTavolo(
          righe: righe,
          larghezza: larghezza,
          quante: widget.quante,
        );
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // **LA LARGHEZZA VA DICHIARATA.** Con la sola altezza, la pila
            // delle carte non aveva niente che la tenesse larga e si
            // stringeva al centro: le carte finivano tutte spostate a destra
            // di mezza schermata. Visto sulla sonda, non dedotto.
            // **LA SCATOLA CRESCE COL VOLO.** La pila taglia cio' che esce
            // dai suoi bordi: con la carta ingrandita al 62 per cento della
            // larghezza, una scatola alta quanto le tre righe le tagliava la
            // testa e i piedi. Cresce quanto serve, e solo mentre serve.
            SizedBox(
              width: larghezza,
              height: _altezzaDellaScatola(disegno),
              child: _tavolo(disegno),
            ),
            const SizedBox(height: 6),
            _ComandiDelMazzo(
              palette: widget.palette,
              attivi: _sceglibile,
              onMischia: _mescola,
              onTaglia: _taglia,
            ),
          ],
        );
      },
    );
  }

  Widget _tavolo(_DisegnoDelTavolo disegno) {
    return GestureDetector(
      behavior: HitTestBehavior.deferToChild,
      onTapDown: (_) => _saltaLIngresso(),
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _ingresso,
          _respiro,
          _mischia,
          _taglio,
          widget.rivelazione,
        ]),
        builder: (context, _) => Stack(
          clipBehavior: Clip.none,
          children: [
            // Le stelline del tavolo, dietro le carte.
            Positioned.fill(
              child: CustomPaint(
                painter: _Stelline(
                  t: _respiro.value,
                  palette: widget.palette,
                  scia: _sciaDellaScelta(disegno),
                  acceso: !widget.ridotto,
                ),
              ),
            ),
            for (var posto = 0; posto < widget.quante; posto++)
              _carta(disegno, posto),
            if (widget.scelta != null) _cartaScelta(disegno),
          ],
        ),
      ),
    );
  }

  /// **L'ALTEZZA DELLA SCATOLA, in un posto solo.** A riposo e' quella delle
  /// righe piu' l'alone delle stelline; mentre la carta sale cresce fino a
  /// contenerla ingrandita, perche' la pila taglia cio' che esce dai suoi
  /// bordi. Serve anche al punto d'arrivo del volo: **quando i due conti
  /// stavano in due posti diversi, la carta arrivava centrata sulla scatola di
  /// prima e la testa finiva fuori.**
  double _altezzaDellaScatola(_DisegnoDelTavolo disegno) {
    final ferma = disegno.altezza + _Stelline.alone;
    final cresciuta = math.max(ferma, disegno.altezzaDellaRivelazione);
    final avanti =
        Curves.easeOutCubic.transform(widget.rivelazione.value.clamp(0.0, 1.0));
    return ferma + (cresciuta - ferma) * avanti;
  }

  /// La scia di stelline dietro la carta che sale: i punti dove e' passata.
  List<Offset> _sciaDellaScelta(_DisegnoDelTavolo disegno) {
    if (widget.scelta == null || widget.ridotto) return const [];
    final t = widget.rivelazione.value;
    if (t <= 0 || t >= 0.92) return const [];
    return [
      for (var k = 1; k <= 7; k++)
        if (t - k * 0.035 > 0) _puntoDelVolo(disegno, t - k * 0.035),
    ];
  }

  /// Dove si trova il centro della carta scelta al tempo [t] del volo.
  Offset _puntoDelVolo(_DisegnoDelTavolo disegno, double t) {
    final partenza = disegno.centroDi(_postoDi(widget.scelta!));
    final arrivo =
        Offset(disegno.larghezza / 2, _altezzaDellaScatola(disegno) / 2);
    final avanti = Curves.easeOutCubic.transform((t / 0.45).clamp(0.0, 1.0));
    return Offset.lerp(partenza, arrivo, avanti)!;
  }

  /// In che posto della griglia sta la carta [carta] adesso.
  int _postoDi(int carta) {
    final posto = _posti.indexOf(carta);
    return posto < 0 ? carta : posto;
  }

  Widget _carta(_DisegnoDelTavolo disegno, int posto) {
    final carta = _posti[posto];
    final scelta = widget.scelta;
    // La carta scelta esce dalla griglia: la disegna _cartaScelta. Il vuoto
    // che lascia porta la sua chiave, come ogni carta: vedi sotto.
    if (scelta != null && carta == scelta) {
      return SizedBox.shrink(key: ValueKey<int>(carta));
    }

    var centro = disegno.centroDi(posto);
    var scala = 1.0;
    // **L'inclinazione del ventaglio e' la posa di base**, e il respiro le si
    // somma sopra: senza, la carta respirerebbe tornando dritta a ogni onda.
    var angolo = disegno.angoloDi(posto);
    var opacita = 1.0;

    // **IL PUNTO DEL TAVOLO DOVE SI FA IL MAZZO**, lo stesso per il Mischia e
    // per il Taglia: due numeri scritti in due posti farebbero due mazzi.
    final mazzo = Offset(disegno.larghezza * 0.5, disegno.altezza * 0.42);

    if (!widget.ridotto) {
      // **L'INGRESSO A SPIRALE**, una carta dopo l'altra.
      final ritardo = posto / widget.quante * 0.45;
      final avanti = ((_ingresso.value - ritardo) / (1 - 0.45)).clamp(0.0, 1.0);
      if (avanti < 1) {
        final curva = Curves.easeOutBack.transform(avanti);
        final giro = (1 - curva) * math.pi * 1.2;
        final raggio = (1 - curva) * disegno.larghezza * 0.42;
        centro = Offset(
          centro.dx + math.cos(giro + posto) * raggio,
          centro.dy + math.sin(giro + posto) * raggio * 0.5 - (1 - curva) * 40,
        );
        scala = 0.35 + 0.65 * curva;
        angolo = (1 - curva) * math.pi * 0.8;
        opacita = avanti.clamp(0.0, 1.0);
      } else {
        // **IL RESPIRO DEL TAVOLO**: ogni carta con la sua fase.
        final fase = posto * 0.37;
        final onda = math.sin((_respiro.value + fase) * 2 * math.pi);
        centro = Offset(centro.dx, centro.dy + onda * 3.2);
        angolo += math.sin((_respiro.value * 1.3 + fase) * 2 * math.pi) * 0.022;
        scala = 1 + onda * 0.008;
      }

      // **IL MISCHIA E' UN MAZZO CHE SI RICOMPONE, SI MESCOLA E SI
      // RISTENDE.** Ordine EE voce 01, 23 settembre 2026.
      //
      // **Il fondatore, verbatim**: *"quando premo su Mischia le carte devono
      // ricomporsi in un mazzo, mischiarsi e poi stendersi nuovamente a
      // ventaglio su 3 righe"*.
      //
      // **Cosa faceva prima**: ogni carta girava attorno al PROPRIO posto,
      // tornandoci. Nessun mazzo si componeva, e da fuori si vedeva
      // un'ondata che passava sul ventaglio senza toglierlo di mezzo.
      //
      // **I tre tempi**, letti dal solo `_mischia.value`, che va da zero a
      // uno:
      //
      // - **fino a 0,35 le carte si radunano** nel mazzo, al centro del
      //   tavolo, e si raddrizzano: il ventaglio si chiude;
      // - **da 0,35 a 0,65 il mazzo si mescola** restando dov'e', con le
      //   carte che scorrono l'una sull'altra a ventagli stretti;
      // - **da 0,65 in poi si ristendono** verso il posto NUOVO, che la
      //   griglia ha gia' assegnato a tre righe.
      //
      // **Il posto nuovo e' gia' in `centro`**, perche' `_mescolati()` viene
      // applicato a fine animazione: qui si interpola fra il mazzo e quel
      // posto, quindi le carte arrivano stese dove staranno.
      if (_mischia.value > 0) {
        final t = _mischia.value;
        // Quanto la carta sta nel mazzo invece che al suo posto: uno vuol
        // dire mazzo chiuso, zero ventaglio steso.
        final double raccolta;
        if (t < 0.35) {
          raccolta = Curves.easeInOut.transform(t / 0.35);
        } else if (t < 0.65) {
          raccolta = 1;
        } else {
          raccolta = 1 - Curves.easeOutCubic.transform((t - 0.65) / 0.35);
        }
        // Nel mazzo le carte non stanno esattamente sovrapposte: un mazzo
        // vero ha uno scarto di pochi punti, o sembrerebbe una carta sola.
        final scartoNelMazzo = Offset(
          (posto % 5 - 2) * 1.6,
          (posto ~/ 5 - 2) * 1.1,
        );
        centro = Offset.lerp(centro, mazzo + scartoNelMazzo, raccolta)!;
        // Raddrizzate nel mazzo, e con un filo di scorrimento mentre si
        // mescolano.
        angolo *= 1 - raccolta;
        if (t >= 0.35 && t < 0.65) {
          final dentro = (t - 0.35) / 0.3;
          final scorre = math.sin(dentro * math.pi * 3 + posto * 0.7);
          centro = Offset(centro.dx + scorre * 9, centro.dy + scorre * 2.5);
          angolo += scorre * 0.08;
        }
      }
    }

    // **IL TAGLIA E' UN MAZZO CHE SI RICOMPONE, SI TAGLIA E SI RISTENDE.**
    // Ordine EL voce 02, 24 settembre 2026 sera.
    //
    // **Il fondatore, verbatim**: *"con il click al tasto "Mischia" le carte
    // si devono ricomporre in un mazzo, il mazzo viene tagliato e poi dal
    // mazzo le carte si ristendono"*, e subito dopo: *"Scusa non Mischia. Ma
    // "taglia". Il pulsante "Mischia" è già ok"*.
    //
    // **Cosa faceva prima**: le due meta' del ventaglio si scostavano a
    // destra e a sinistra e tornavano ognuna al suo posto, e a corsa finita i
    // posti si scambiavano di colpo. Nessun mazzo e nessun taglio da vedere.
    //
    // **Sta fuori dal ramo del movimento**, e il commento di `_taglia` dice
    // perche'.
    if (_taglio.value > 0) {
      final posa = _posaNelTaglio(
        disegno: disegno,
        posto: posto,
        mazzo: mazzo,
        centro: centro,
        angolo: angolo,
        scala: scala,
      );
      centro = posa.centro;
      angolo = posa.angolo;
      scala = posa.scala;
    }

    // Quando una carta e' stata scelta, le altre si spengono piano e
    // lasciano la scena a lei.
    if (widget.scelta != null) {
      opacita *= (1 - (widget.rivelazione.value / 0.3)).clamp(0.0, 1.0);
    }

    return _posata(
      // **LA CHIAVE STA SUL FIGLIO DELLA PILA, non solo sul dorso.** Ordine
      // EL voce 02. Le carte stanno nella pila in ordine di posto, cosi' chi
      // e' sopra si disegna dopo; quando Mischia e Taglia scambiano i posti,
      // senza questa chiave Flutter non poteva spostare le carte e ricreava
      // tutte e ventidue le immagini, che restano vuote finche' non
      // ritrovano il loro disegno. Sul Realme, con la build di prova di
      // prima, un tocco su Taglia ha lasciato il tavolo vuoto per circa un
      // secondo. Con la chiave qui ogni carta si sposta e l'immagine resta la
      // sua: lo misura `il_taglia_ricompone_il_mazzo_test.dart`.
      chiave: ValueKey<int>(carta),
      disegno: disegno,
      centro: centro,
      scala: scala,
      angolo: angolo,
      opacita: opacita,
      figlio: _Dorso(
        indice: carta,
        attivo: _sceglibile,
        onTap: () {
          // **Mentre un gesto del mazzo corre, nessun dorso si sceglie**: con
          // le carte raccolte il tocco prenderebbe quella in cima al mazzo, e
          // il volo partirebbe dal suo posto sul tavolo, lontano da dove la
          // si vede. Il blocco sta qui e non in `attivo`, perche' spegnere il
          // tocco da li' cambierebbe la forma del dorso: vedi `_Dorso`.
          if (_mischia.isAnimating || _taglio.isAnimating) return;
          widget.onScegli(carta);
        },
      ),
    );
  }

  /// **LA POSA DI UNA CARTA DURANTE IL TAGLIO**, dal solo `_taglio.value`.
  ///
  /// Il pacchetto di ogni carta si legge dal posto: prima dello scambio il
  /// pacchetto di sopra sono i posti dalla meta' in su, dopo lo scambio i
  /// primi. L'indice dentro il pacchetto resta lo stesso nei due casi, cosi'
  /// allo scambio nessuna carta si sposta di un punto.
  ({Offset centro, double angolo, double scala}) _posaNelTaglio({
    required _DisegnoDelTavolo disegno,
    required int posto,
    required Offset mazzo,
    required Offset centro,
    required double angolo,
    required double scala,
  }) {
    final t = _taglio.value;
    final quante = widget.quante;
    // Il taglio divide il mazzo a meta', come `_tagliati`.
    final sotto = quante ~/ 2;
    final sopra = quante - sotto;
    Offset nelMazzo(int p) => mazzo + _spessore * (p - (quante - 1) / 2);

    // La raccolta e la stesa: fra il posto sul tavolo e il mazzo.
    if (t < _finoAllaRaccolta || t >= _mazzoRifatto) {
      final raccolta = t < _finoAllaRaccolta
          ? Curves.easeInOut.transform(t / _finoAllaRaccolta)
          : 1 -
              Curves.easeOutCubic
                  .transform((t - _mazzoRifatto) / (1 - _mazzoRifatto));
      return (
        centro: Offset.lerp(centro, nelMazzo(posto), raccolta)!,
        angolo: angolo * (1 - raccolta),
        scala: 1 + (scala - 1) * (1 - raccolta),
      );
    }

    final diSopra = _tagliato ? posto < sopra : posto >= sotto;
    final indice = _tagliato
        ? (diSopra ? posto : posto - sopra)
        : (diSopra ? posto - sotto : posto);
    final nelPacchetto =
        _spessore * (indice - ((diSopra ? sopra : sotto) - 1) / 2);
    // Il pacchetto di sopra va a destra e l'altro a sinistra, abbastanza
    // lontani da non coprirsi: i due centri stanno a una carta e sette
    // decimi l'uno dall'altro.
    final lato = diSopra ? 1.0 : -1.0;
    final aperto =
        mazzo + Offset(lato * disegno.larghezzaCarta * 0.85, 0) + nelPacchetto;

    // Quanto il mazzo e' aperto, da zero a uno, e quanto e' sollevato il
    // pacchetto che si muove sopra l'altro.
    final double apertura;
    final double sollevato;
    final Offset chiuso;
    if (t < _siRichiude) {
      // **Il taglio**: si alza il pacchetto di sopra.
      final s = ((t - _siApreIlTaglio) / (_taglioAperto - _siApreIlTaglio))
          .clamp(0.0, 1.0);
      apertura = Curves.easeInOut.transform(s);
      sollevato = diSopra ? math.sin(s * math.pi) : 0;
      chiuso = nelMazzo(diSopra ? sotto + indice : indice);
    } else {
      // **Il mazzo si rifa'**: si alza il pacchetto che era sotto e si posa
      // sopra l'altro.
      final r =
          ((t - _siRichiude) / (_mazzoRifatto - _siRichiude)).clamp(0.0, 1.0);
      apertura = 1 - Curves.easeInOut.transform(r);
      sollevato = diSopra ? 0 : math.sin(r * math.pi);
      chiuso = nelMazzo(diSopra ? indice : sopra + indice);
    }
    return (
      centro:
          Offset.lerp(chiuso, aperto, apertura)!.translate(0, -14 * sollevato),
      angolo: lato * (diSopra ? 0.07 : 0.05) * apertura,
      scala: 1 + 0.06 * sollevato,
    );
  }

  /// La carta scelta: sale al centro, cresce e si gira. **La faccia compare
  /// solo dopo il mezzo giro**, cosi' il verso non si sa mai in anticipo.
  Widget _cartaScelta(_DisegnoDelTavolo disegno) {
    final t = widget.rivelazione.value;
    final centro = _puntoDelVolo(disegno, t);
    final salita = Curves.easeOutCubic.transform((t / 0.45).clamp(0.0, 1.0));
    final giro = Curves.easeInOut.transform(((t - 0.35) / 0.5).clamp(0.0, 1.0));
    final scala = 1 + (disegno.scalaDellaRivelazione - 1) * salita;
    final mostraLaFaccia = giro >= 0.5;
    return _posata(
      disegno: disegno,
      centro: centro,
      scala: scala,
      angolo: 0,
      opacita: 1,
      trasforma: Matrix4.identity()
        ..setEntry(3, 2, 0.0012)
        ..rotateY(giro * math.pi),
      figlio: mostraLaFaccia
          ? Transform(
              alignment: Alignment.center,
              // La faccia si rimette dritta: senza, dopo il mezzo giro si
              // vedrebbe specchiata.
              transform: Matrix4.identity()..rotateY(math.pi),
              child: Builder(builder: widget.faccia),
            )
          : _Dorso(indice: widget.scelta!, attivo: false, onTap: () {}),
    );
  }

  Widget _posata({
    required _DisegnoDelTavolo disegno,
    required Offset centro,
    required double scala,
    required double angolo,
    required double opacita,
    required Widget figlio,
    Matrix4? trasforma,
    Key? chiave,
  }) {
    final w = disegno.larghezzaCarta;
    final h = disegno.altezzaCarta;
    Widget corpo = SizedBox(width: w, height: h, child: figlio);
    if (trasforma != null) {
      corpo = Transform(
          alignment: Alignment.center, transform: trasforma, child: corpo);
    }
    return Positioned(
      key: chiave,
      left: centro.dx - w / 2,
      top: centro.dy - h / 2,
      width: w,
      height: h,
      child: Opacity(
        opacity: opacita.clamp(0.0, 1.0),
        child: Transform.rotate(
          angle: angolo,
          child: Transform.scale(scale: scala, child: corpo),
        ),
      ),
    );
  }
}

/// La geometria del tavolo: quante righe, quanto sono grandi le carte, dove
/// sta ognuna. Sta a parte perche' e' cio' che le prove misurano.
class _DisegnoDelTavolo {
  _DisegnoDelTavolo({
    required this.righe,
    required this.larghezza,
    required this.quante,
  });

  final List<int> righe;
  final double larghezza;
  final int quante;

  /// Quanto una carta copre quella accanto: **leggermente sovrapposte**.
  static const double sovrapposizione = 0.74;

  /// **L'ARCO DI OGNI RIGA.** Quanto sale la carta centrale rispetto a quelle
  /// dei bordi, in frazione dell'altezza di una carta. Sotto lo 0,08 la curva
  /// non si legge, sopra lo 0,20 le righe si mangiano fra loro.
  static const double arco = 0.14;

  /// Quanto si inclina la carta piu' esterna di una riga, in radianti: poco
  /// piu' di sette gradi, come un ventaglio tenuto in mano.
  static const double inclinazione = 0.13;

  /// Il margine tiene conto anche di quello che l'inclinazione porta fuori:
  /// una carta ruotata occupa piu' larghezza di una dritta.
  static const double _margine = 14;
  static const double _passoVerticale = 1.02;

  double get larghezzaCarta {
    final perRiga = righe.reduce(math.max);
    final utile = larghezza - _margine * 2;
    return utile / (1 + (perRiga - 1) * sovrapposizione);
  }

  double get altezzaCarta => larghezzaCarta / TarotFrame.aspect;

  double get altezza =>
      altezzaCarta * (1 + (righe.length - 1) * _passoVerticale) +
      altezzaCarta * arco +
      16;

  Offset get centroDelTavolo => Offset(larghezza / 2, altezza / 2);

  /// Quanto cresce la carta quando sale al centro: **il sessantadue per cento
  /// della larghezza**.
  ///
  /// Il tetto era 2,6 e tagliava la scala molto prima: su un telefono da 360
  /// punti la carta rivelata restava a 140 punti, cioe' il 39 per cento, e il
  /// fondatore l'ha vista *"piccola, con molto spazio intorno"*. Il tetto serve
  /// solo a non far esplodere la carta su uno schermo largo, quindi sta dove
  /// non morde: a 4,6.
  double get scalaDellaRivelazione => math.min(4.6,
      (larghezza * TavoloDeiVentidue.parteDellaLarghezza) / larghezzaCarta);

  /// L'altezza che serve alla carta quando e' salita e cresciuta.
  double get altezzaDellaRivelazione =>
      altezzaCarta * scalaDellaRivelazione + 24;

  /// Dove sta il [posto] dentro la sua riga: la riga, l'indice e quanti sono.
  ({int riga, int indice, int quanti}) rigaDi(int posto) {
    var scorso = 0;
    for (var r = 0; r < righe.length; r++) {
      if (posto < scorso + righe[r]) {
        return (riga: r, indice: posto - scorso, quanti: righe[r]);
      }
      scorso += righe[r];
    }
    return (riga: righe.length - 1, indice: 0, quanti: righe.last);
  }

  /// Da meno uno a piu' uno: dove sta la carta lungo la sua riga, con lo zero
  /// al centro. E' la misura da cui nascono l'arco e l'inclinazione.
  double posizioneNellaRiga(int posto) {
    final dove = rigaDi(posto);
    if (dove.quanti <= 1) return 0;
    return (dove.indice - (dove.quanti - 1) / 2) / ((dove.quanti - 1) / 2);
  }

  /// Il centro della casella [posto], contate riga per riga.
  ///
  /// **Ogni riga e' un arco**: la carta al centro sta piu' in alto e quelle
  /// dei bordi scendono, come un ventaglio aperto sul tavolo.
  Offset centroDi(int posto) {
    final dove = rigaDi(posto);
    final passo = larghezzaCarta * sovrapposizione;
    final largaRiga = larghezzaCarta + (dove.quanti - 1) * passo;
    final sinistra = (larghezza - largaRiga) / 2;
    final t = posizioneNellaRiga(posto);
    // La parabola: zero ai bordi, uno al centro.
    final salita = (1 - t * t) * altezzaCarta * arco;
    return Offset(
      sinistra + dove.indice * passo + larghezzaCarta / 2,
      8 +
          altezzaCarta * (0.5 + dove.riga * _passoVerticale) +
          altezzaCarta * arco -
          salita,
    );
  }

  /// **L'INCLINAZIONE DELLA POSA**, che e' cio' che fa leggere la curva come
  /// un ventaglio e non come una gobba: la carta di sinistra pende a sinistra,
  /// quella di destra a destra, e la centrale resta dritta.
  double angoloDi(int posto) => posizioneNellaRiga(posto) * inclinazione;
}

/// Un dorso del mazzo. **Sono tutti lo stesso disegno**, e il dorso e'
/// simmetrico al mezzo giro: una carta coperta non puo' dire il verso.
class _Dorso extends StatelessWidget {
  const _Dorso({
    required this.indice,
    required this.attivo,
    required this.onTap,
  });

  final int indice;
  final bool attivo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final immagine = ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image.asset(
        TarotDeck.dorsoFull,
        key: Key('arcano_alba_dorso_$indice'),
        fit: BoxFit.cover,
      ),
    );
    // **LA FORMA NON CAMBIA QUANDO IL TOCCO SI SPEGNE.** Ordine EL voce 02.
    // Restituire l'immagine nuda quando la carta non si sceglie, e il
    // `GestureDetector` quando si sceglie, cambiava il tipo del widget a ogni
    // passaggio: Flutter ricreava l'immagine, che resta vuota finche' non
    // ritrova il suo disegno. Succedeva a tutte e ventidue nel momento in
    // cui una carta viene scelta, cioe' mentre le altre devono spegnersi
    // piano. Adesso il rilevatore c'e' sempre e il tocco e' spento.
    return GestureDetector(
      key: Key('arcano_alba_carta_$indice'),
      behavior: HitTestBehavior.opaque,
      onTap: attivo ? onTap : null,
      child: immagine,
    );
  }
}

/// **LE STELLINE**: il pulviscolo del tavolo e la scia della carta che sale.
class _Stelline extends CustomPainter {
  _Stelline({
    required this.t,
    required this.palette,
    required this.scia,
    required this.acceso,
  });

  final double t;
  final MaestroPalette palette;

  /// I punti dove la carta scelta e' passata poco fa.
  final List<Offset> scia;
  final bool acceso;

  /// Quanto spazio lasciano le stelline oltre le carte.
  static const double alone = 18;

  static const int quante = 46;

  @override
  void paint(Canvas canvas, Size size) {
    final caso = math.Random(7);
    final pennello = Paint()..style = PaintingStyle.fill;
    if (acceso) {
      for (var i = 0; i < quante; i++) {
        final x = caso.nextDouble() * size.width;
        final y = caso.nextDouble() * size.height;
        final fase = caso.nextDouble();
        final battito =
            (math.sin((t + fase) * 2 * math.pi) + 1) / 2; // da zero a uno
        final raggio = 0.7 + battito * 1.6;
        pennello.color =
            palette.goldSoft.withValues(alpha: 0.10 + battito * 0.35);
        _stella(canvas, Offset(x, y), raggio, pennello);
      }
    }
    for (var i = 0; i < scia.length; i++) {
      final quanto = 1 - i / scia.length;
      final punto = scia[i];
      for (var k = 0; k < 3; k++) {
        final sparso = Offset(
          punto.dx + (caso.nextDouble() - 0.5) * 26,
          punto.dy + (caso.nextDouble() - 0.5) * 26,
        );
        pennello.color = palette.gold.withValues(alpha: 0.55 * quanto);
        _stella(canvas, sparso, 1.2 + 2.2 * quanto, pennello);
      }
    }
  }

  /// Una stellina a quattro punte, non un cerchio.
  void _stella(Canvas canvas, Offset centro, double raggio, Paint pennello) {
    final strada = Path();
    final piccolo = raggio * 0.32;
    strada.moveTo(centro.dx, centro.dy - raggio);
    strada.quadraticBezierTo(centro.dx + piccolo, centro.dy - piccolo,
        centro.dx + raggio, centro.dy);
    strada.quadraticBezierTo(centro.dx + piccolo, centro.dy + piccolo,
        centro.dx, centro.dy + raggio);
    strada.quadraticBezierTo(centro.dx - piccolo, centro.dy + piccolo,
        centro.dx - raggio, centro.dy);
    strada.quadraticBezierTo(centro.dx - piccolo, centro.dy - piccolo,
        centro.dx, centro.dy - raggio);
    canvas.drawPath(strada, pennello);
  }

  @override
  bool shouldRepaint(_Stelline vecchio) =>
      vecchio.t != t || vecchio.scia != scia || vecchio.acceso != acceso;
}

/// I due gesti del mazzo. **Non cambiano l'esito**, e il commento della
/// classe lo dice per esteso.
class _ComandiDelMazzo extends StatelessWidget {
  const _ComandiDelMazzo({
    required this.palette,
    required this.attivi,
    required this.onMischia,
    required this.onTaglia,
  });

  final MaestroPalette palette;
  final bool attivi;
  final VoidCallback onMischia;
  final VoidCallback onTaglia;

  @override
  Widget build(BuildContext context) {
    if (!attivi) return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _Gesto(
            chiave: 'arcano_alba_mischia',
            testo: 'Mischia',
            icona: Icons.shuffle_rounded,
            palette: palette,
            onTap: onMischia),
        const SizedBox(width: 26),
        _Gesto(
            chiave: 'arcano_alba_taglia',
            testo: 'Taglia',
            icona: Icons.content_cut_rounded,
            palette: palette,
            onTap: onTaglia),
      ],
    );
  }
}

class _Gesto extends StatelessWidget {
  const _Gesto({
    required this.chiave,
    required this.testo,
    required this.icona,
    required this.palette,
    required this.onTap,
  });

  final String chiave;
  final String testo;
  final IconData icona;
  final MaestroPalette palette;
  final VoidCallback onTap;

  /// Quanto misura la bolla: sotto gli 84 punti l'etichetta non ci sta senza
  /// rimpicciolirsi, e un pulsante che rimpicciolisce il testo non si legge.
  static const double misura = 92;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      key: Key(chiave),
      onPressed: onTap,
      style: TextButton.styleFrom(
        shape: const CircleBorder(),
        padding: EdgeInsets.zero,
        minimumSize: const Size(misura, misura),
        fixedSize: const Size(misura, misura),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          // L'alone dentro la bolla: il Maestro si riconosce dal colore,
          // e la bolla non e' un disco piatto.
          // **IL FONDO DELLA BOLLA E' SCURO, e non e' una scelta di gusto.**
          // Coll'alone al 26 per cento il fondo sotto l'etichetta veniva
          // #4C5EAC e l'oro ci stava sopra a 4,20 contro il 4,5 preteso: la
          // bolla era bella e l'etichetta non si leggeva.
          gradient: RadialGradient(
            colors: [
              palette.glow.withValues(alpha: 0.10),
              palette.deepest.withValues(alpha: 0.88),
            ],
            stops: const [0.0, 0.85],
          ),
          border: Border.all(color: palette.gold.withValues(alpha: 0.55)),
          boxShadow: [
            BoxShadow(
              color: palette.glow.withValues(alpha: 0.18),
              blurRadius: 14,
              spreadRadius: 1,
            ),
          ],
        ),
        child: SizedBox(
          width: misura,
          height: misura,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icona, size: 22, color: palette.goldSoft),
              const SizedBox(height: 4),
              Text(
                testo,
                // Il ruolo, non la misura: una misura scritta a mano qui e'
                // debito che il censimento conta, e il ruolo dell'etichetta
                // esiste e vale per tutta l'app.
                // **SEDICI PUNTI, non quattordici**: nei Doni nessun testo
                // scende sotto i sedici, voce CG.14, e l'etichetta vale
                // quattordici. Il ruolo della riga e' quello che regge.
                style: TypographyTokens.titoloDiRiga()
                    .copyWith(color: palette.goldSoft),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
