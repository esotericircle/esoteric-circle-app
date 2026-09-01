import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/astro/zodiac.dart';
import '../../design_system/components/zodiac_glyph.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../maestri/rotta_arte.dart';

/// LA CORSA DELLO ZODIACO. Ordine CC voce 03.
///
/// **Rilievo del fondatore, 29 agosto 2026, verbatim:** "in Oroscopo,
/// L'ANIMAZIONE DI RIFLESSIONE FA SCHIFO, tutti quei cerchietti gialli non si
/// capisce cosa siano e cmq poi i risultati compaiono di botto. mi avevi
/// illuso proponendomi il cielo che si ricomponeva".
///
/// **Cosa ha chiesto al suo posto, verbatim:** "VOGLIO che ci sia una
/// schermata nuova sopra tutto con tutti i simboli dello zodiaco grandi che
/// velocemente si succedono uno dopo l'altro e poi si ferma sul segno
/// zodiacale dell'utente (sotto una frase evocativa di caricamento o pensiero
/// tipo "Medora sta...", poi il segno dell'utente si ingrandisce e poi in
/// dissolvenza torni a mostrare la schermata di responso".
///
/// **I sei tempi della scena, nel suo ordine:**
/// 1. la scena copre l'Oroscopo,
/// 2. i dodici segni si succedono grandi e veloci,
/// 3. la corsa rallenta e si ferma sul segno di chi guarda,
/// 4. sotto scorre una frase di attesa nella voce di Medora,
/// 5. il segno si ingrandisce,
/// 6. la scena si dissolve e sotto c'e' il responso.
///
/// **I due arricchimenti che mi sono preso, e il fondatore mi autorizza a
/// prendermeli:**
/// - **La corsa DECELERA invece di fermarsi di colpo.** Una ruota che si ferma
///   secca sembra rotta; una che rallenta dice che si e' fermata su quel segno
///   per una ragione. Il passo cresce da 70 a 260 millesimi.
/// - **Il segno che si ingrandisce porta un alone che cresce con lui.** Senza,
///   l'ingrandimento e' solo un'immagine piu' grande; con l'alone e' il segno
///   che si accende.
class CorsaDelloZodiaco extends StatefulWidget {
  const CorsaDelloZodiaco({
    super.key,
    required this.segno,
    required this.palette,
    required this.durata,
    this.frase,
    this.riduciMovimento = false,
  });

  /// Il segno di chi guarda: e' qui che la corsa si ferma.
  final Zodiac segno;

  final MaestroPalette palette;

  /// Quanto dura tutta la scena, dalla prima immagine alla dissolvenza.
  /// La decide chi la monta, perche' e' lo stesso tempo che il consulto
  /// aspetta: due tempi diversi farebbero una scena che finisce prima o dopo
  /// il responso.
  final Duration durata;

  /// La frase di attesa. Se non arriva, la sceglie [FrasiDellaCorsa].
  final String? frase;

  /// Chi ha chiesto di non vedere movimento vede la stessa scena ferma: il
  /// segno gia' fermo, gia' grande, con la sua frase. Il momento resta, e resta
  /// lungo uguale.
  final bool riduciMovimento;

  @override
  State<CorsaDelloZodiaco> createState() => _CorsaDelloZodiacoState();
}

/// LE FRASI DELL'ATTESA, nella voce di Medora.
///
/// **SONO PROVVISORIE, e lo dichiaro qui invece di lasciarlo capire.** L'ordine
/// CC voce 03 dice che le frasi di attesa sono materia di scrittura e chiede di
/// scriverne di provvisorie marcandole come tali. Queste sono mie: il fondatore
/// le riscrivera' come ha fatto coi cinque fumetti del tutorial.
abstract final class FrasiDellaCorsa {
  /// **PROVVISORIE.** Da riscrivere quando il fondatore le approva.
  static const List<String> provvisorie = [
    'Medora sta leggendo il cielo di oggi',
    'Medora sta cercando il tuo segno fra i dodici',
    'Medora sta ascoltando cosa dicono i pianeti',
    'Medora sta mettendo il tuo cielo accanto a quello di oggi',
  ];

  /// La frase di questo consulto. Cambia col giorno, cosi' due consulti vicini
  /// non fanno rileggere la stessa riga.
  static String perIlGiorno(DateTime giorno) =>
      provvisorie[giorno.day % provvisorie.length];
}

class _CorsaDelloZodiacoState extends State<CorsaDelloZodiaco>
    with SingleTickerProviderStateMixin {
  /// Il passo piu' rapido e il piu' lento della corsa, in millesimi.
  static const int _passoRapido = 70;
  static const int _passoLento = 260;

  /// Quanta parte della scena se ne va nella corsa, quanta nell'ingrandimento
  /// e quanta nella dissolvenza.
  static const double _quotaDellaCorsa = 0.62;
  static const double _quotaDellIngrandimento = 0.20;

  Timer? _passo;
  late final AnimationController _finale;

  /// Quale segno si vede adesso.
  late Zodiac _mostrato = Zodiac.values.first;

  /// Vero quando la corsa si e' fermata sul segno di chi guarda.
  bool _fermo = false;

  /// Quanti passi ha gia' fatto la corsa. Serve a far crescere il passo.
  int _quanti = 0;

  @override
  void initState() {
    super.initState();
    _finale = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: (widget.durata.inMilliseconds *
                (_quotaDellIngrandimento +
                    (1 - _quotaDellaCorsa - _quotaDellIngrandimento)))
            .round(),
      ),
    );
    if (widget.riduciMovimento) {
      _mostrato = widget.segno;
      _fermo = true;
      _finale.value = 1;
      return;
    }
    _corri();
  }

  /// **LA CORSA, e perche' non e' un timer periodico.**
  ///
  /// Un passo fisso avrebbe fatto una ruota che si ferma di colpo. Qui ogni
  /// passo dura un poco piu' del precedente, e l'ultimo dura quasi quattro
  /// volte il primo: e' la decelerazione che dice "si e' fermata QUI".
  void _corri() {
    final quantiPassi = _quantiPassi();
    _passoSuccessivo(quantiPassi);
  }

  /// Quanti passi ci stanno nel tempo che la corsa ha.
  int _quantiPassi() {
    final perLaCorsa =
        (widget.durata.inMilliseconds * _quotaDellaCorsa).round();
    // La durata media di un passo, fra il rapido e il lento.
    const medio = (_passoRapido + _passoLento) / 2;
    final quanti = (perLaCorsa / medio).floor();
    // **ALMENO UN GIRO INTERO DI ZODIACO.** Meno di dodici passi non e' una
    // corsa fra i dodici segni, e' un lampeggio: la scena deve mostrarli tutti
    // almeno una volta, o non si capisce che sono i segni.
    return quanti < Zodiac.values.length ? Zodiac.values.length : quanti;
  }

  void _passoSuccessivo(int quantiPassi) {
    if (!mounted) return;
    if (_quanti >= quantiPassi) {
      setState(() {
        _mostrato = widget.segno;
        _fermo = true;
      });
      _finale.forward();
      return;
    }
    // Il passo cresce con l'avanzare della corsa, dalla velocita' alla calma.
    final quota = _quanti / quantiPassi;
    final durataDelPasso =
        (_passoRapido + (_passoLento - _passoRapido) * quota * quota).round();
    _passo = Timer(Duration(milliseconds: durataDelPasso), () {
      if (!mounted) return;
      setState(() {
        _quanti++;
        final i = Zodiac.values.indexOf(_mostrato);
        _mostrato = Zodiac.values[(i + 1) % Zodiac.values.length];
      });
      _passoSuccessivo(quantiPassi);
    });
  }

  /// **IL CUORE DELLE PREFERITE SI RITIRA, mentre la scena copre tutto.**
  ///
  /// Il cuore dorato non vive dentro questa schermata: fluttua in uno strato
  /// che sta SOPRA la rotta, e nessun velo montato qui dentro puo' coprirlo.
  /// L'anteprima lo ha mostrato galleggiare sopra l'Ariete. Esiste gia' la
  /// via giusta, ed e' quella che usa la barra delle arti: si dichiara di
  /// prenderlo in carico, e lui si toglie da se'.
  ValueNotifier<bool>? _cuore;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arte = ArteCorrente.of(context);
    if (arte?.reclamato != _cuore) {
      _cuore = arte?.reclamato;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _cuore?.value = true;
      });
    }
  }

  @override
  void dispose() {
    // **IL CUORE TORNA DOPO IL FOTOGRAMMA, non dentro il dispose.** Scrivere
    // sul notificatore mentre l'albero si smonta fa cadere l'app con "widget
    // tree was locked": la scena se ne sta andando, e chi ascolta non puo'
    // ricostruirsi adesso. Il notificatore appartiene alla rotta, che vive
    // piu' a lungo di questa scena, quindi aspettare un fotogramma e' sicuro.
    final cuore = _cuore;
    if (cuore != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => cuore.value = false);
    }
    _passo?.cancel();
    _finale.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    final larghezza = MediaQuery.sizeOf(context).width;
    // L'emblema prende poco piu' della meta' della larghezza: e' "grande",
    // come l'ordine chiede, e lascia respiro attorno.
    final misura = larghezza * 0.52;
    final frase = widget.frase ?? FrasiDellaCorsa.perIlGiorno(DateTime.now());

    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _finale,
        builder: (context, _) {
          // Il finale governa due cose in fila: prima il segno cresce, poi
          // tutta la scena si dissolve.
          final quotaIngrandimento = (_finale.value / 0.5).clamp(0.0, 1.0);
          final quotaDissolvenza =
              ((_finale.value - 0.5) / 0.5).clamp(0.0, 1.0);
          final scala = 1.0 + 0.35 * quotaIngrandimento;
          return IgnorePointer(
            // **UN `Material` SOPRA, altrimenti il testo esce sottolineato in
            // giallo.** Ordine CC voce 03, trovato guardando l'anteprima.
            // Questa scena vive FUORI dallo `Scaffold`, e senza un Material
            // sopra Flutter dipinge il ripiego di emergenza: righe gialle
            // sotto ogni parola. Non e' un dettaglio di stile, e' il segnale
            // che l'albero non e' quello che si credeva.
            child: Material(
              type: MaterialType.transparency,
              child: Opacity(
                opacity: 1 - quotaDissolvenza,
                child: ColoredBox(
                  // **OPACO, non velato.** Il fondatore ha chiesto "una
                  // schermata nuova sopra tutto": con un velo al 94 per cento
                  // l'Oroscopo si leggeva ancora dietro, e l'anteprima lo ha
                  // mostrato subito. Una schermata copre.
                  color: palette.deepest,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Transform.scale(
                          scale: scala,
                          child: Container(
                            key: Key('corsa_segno_${_mostrato.name}'),
                            width: misura,
                            height: misura,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                // **UN ALONE, NON UN DISCO.** A 0,55 di
                                // opacita' e con un raggio corto l'ombra si
                                // leggeva come un cerchio pieno dietro
                                // l'emblema: l'anteprima mostrava un leone
                                // seduto su una moneta. Piu' larga e piu'
                                // tenue, e' luce.
                                BoxShadow(
                                  color: palette.gold.withValues(
                                      alpha: 0.05 + 0.16 * quotaIngrandimento),
                                  blurRadius: misura * 0.9,
                                  spreadRadius: -misura * 0.1,
                                ),
                              ],
                            ),
                            child: ZodiacEmblem(
                              sign: _mostrato,
                              size: misura,
                              // Un posto vuoto qui sarebbe un buco nero in mezzo
                              // alla scena: se l'arte non si decodifica resta il
                              // nome del segno, che e' l'informazione vera.
                              ripiego: Center(
                                child: Text(
                                  _mostrato.symbol,
                                  style: TextStyle(
                                    fontSize: misura * 0.6,
                                    color: palette.goldSoft,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: SpacingTokens.lg),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: SpacingTokens.lg),
                          child: Text(
                            _fermo ? widget.segno.italianName : frase,
                            key: const Key('corsa_frase'),
                            textAlign: TextAlign.center,
                            style: TypographyTokens.titoloSezione()
                                .copyWith(color: palette.goldSoft),
                          ),
                        ),
                        if (!_fermo) ...[
                          const SizedBox(height: SpacingTokens.xs),
                          Text(
                            '...',
                            style: TypographyTokens.titoloSezione()
                                .copyWith(color: palette.goldSoft),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
