import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/rituals/animal_catalog.dart';
import '../../../../core/sensi/palette_sensoriale.dart';
import '../../../../design_system/theme/maestro_palette.dart';
import '../../../../design_system/tokens/spacing_tokens.dart';
import '../../../../design_system/tokens/typography_tokens.dart';
import '../../../../design_system/typography/paragrafi_di_lettura.dart';
import 'la_discesa_in_video.dart';
import 'l_ombra_dell_animale.dart';
import 'la_nebbia_e_l_animale.dart';
import 'sfondo_del_mondo_di_sotto.dart';

/// **IL TAMBURO CHE NUTRE.** Ordine DI voce 13, 12 settembre 2026.
///
/// **Le parole dell'ordine:** *"Il tamburo a schermo pieno. Si batte col dito
/// seguendo una pulsazione visibile, per quaranta secondi. Mentre si batte,
/// l'animale si avvicina fisicamente nell'immagine, dal fondo al primo piano,
/// e la nebbia intorno si dirada. Nessun punteggio, nessuna barra, nessuna
/// ricompensa dichiarata: la ricompensa e' che si vede meglio."*
///
/// **COSA C'ERA PRIMA.** Un pulsante, *"Richiamalo col tamburo"*, che al
/// tocco registrava il nutrimento e vibrava una volta: il gesto piu' importante
/// del rapporto con l'animale era un clic. Il meccanismo sotto resta quello
/// dell'ordine DE voce 12, un nutrimento vale sette giorni di vicinanza; quello
/// che cambia e' che adesso **si fa**.
///
/// **IL TEMPO SCORRE SOLO MENTRE SI BATTE.** Il battito visibile e' quello del
/// tamburo, quattro e mezzo al secondo, e nessuno puo' battere a quella
/// cadenza per venti secondi: la persona batte con lui quando vuole, un
/// colpo ogni tanto, e finche' un colpo e' caduto nell'ultimo secondo e poco
/// piu' l'animale continua ad avvicinarsi. Se smette, l'animale si ferma dove
/// e' arrivato e aspetta. **Venti** secondi di battito, non venti secondi di
/// orologio: erano quaranta fino all'ordine DR voce 09, che li ha dimezzati
/// perche' il fondatore ha detto che la fase annoia.
///
/// **Col `Timer` e non col controller**, per la ragione di sempre: sul
/// telefono di collaudo le scale di animazione valgono zero.
class IlTamburoCheNutre extends StatefulWidget {
  const IlTamburoCheNutre({
    super.key,
    required this.animale,
    required this.palette,
    required this.quandoHaiFinito,
    required this.quandoTorni,
    this.rigaDelloStato,
    this.riconosciuto = true,
  });

  final GuideAnimal animale;
  final MaestroPalette palette;

  /// Si chiama una volta sola, a venti secondi di battito: e' qui che il
  /// nutrimento si registra.
  final VoidCallback quandoHaiFinito;

  /// Si torna alla soglia, finito o no.
  final VoidCallback quandoTorni;

  /// **LA RIGA CHE DICHIARA LO STATO**, a rito finito. L'ordine: *"la riga che
  /// dichiara lo stato alla persona esiste gia' e resta com'e'"*: la calcola
  /// chi monta il rito, dalla nitidezza dopo il nutrimento. Nulla quando la
  /// scena e' gia' nitida, e allora non si dice niente.
  final String? Function()? rigaDelloStato;

  /// **SE L'ANIMALE E' GIA' STATO RICONOSCIUTO.** Ordine DN voce 06: il
  /// tamburo si apre anche dall'avviso della distanza, che c'e' solo
  /// prima della quarta discesa, e li' mostrava l'illustrazione intera e
  /// diceva *"La Volpe e' vicina a te"*. **Il nome non si dice prima
  /// della quarta**, ordine DC voce 02: prima si avvicina l'ombra, la
  /// stessa dell'incontro, e la riga dice l'animale.
  final bool riconosciuto;

  /// **VENTI SECONDI DI BATTITO**, ed erano quaranta.
  ///
  /// **Dimezzati con l'ordine DR voce 09**, parole del fondatore: *"la fase
  /// di nutrimento e' troppo lunga, e' solo un zoom ed annoia, bisogna
  /// dimezzarla"*. I quaranta venivano dall'ordine DI voce 13 e sono stati
  /// letti nel codice prima di toccarli, non a occhio.
  ///
  /// **Si accorcia e basta**: il movimento resta quello, la curva resta
  /// quella, l'ingrandimento arriva allo stesso punto. Cambia soltanto
  /// quanto ci si mette, perche' l'avanzamento e' `battuto / quantoDura` e
  /// nient'altro in questo rito e' legato a quel numero: il colpo che tiene
  /// vivo il battito dura un secondo e due decimi, l'onda del tocco un
  /// secondo, il passo sedici millesimi, e nessuno dei tre e' cambiato.
  static const Duration quantoDura = Duration(seconds: 20);

  /// **PER QUANTO UN COLPO TIENE VIVO IL BATTITO.** Un secondo e due decimi:
  /// piu' di un respiro fra un colpo e l'altro, meno di una pausa vera.
  static const Duration unColpoTieneVivo = Duration(milliseconds: 1200);

  /// **DOVE STA L'ANIMALE**, da 0 in fondo all'orizzonte a 1 in primo piano.
  /// I piedi scendono dalla linea dell'orizzonte del fondo, al 47 per cento
  /// dell'altezza, fino a poco sopra il bordo; la figura cresce da un quinto
  /// della larghezza fino a quasi tutta. La curva e' lenta all'inizio e piu'
  /// svelta alla fine, come chi arriva da lontano.
  static ({double piedi, double larga, double luce}) doveSta(double quanto) {
    final q = quanto.clamp(0.0, 1.0);
    final vicino = q * q;
    return (
      piedi: 0.47 + (0.90 - 0.47) * vicino,
      larga: 0.20 + (0.92 - 0.20) * vicino,
      luce: 0.35 + 0.65 * q,
    );
  }

  @override
  State<IlTamburoCheNutre> createState() => _IlTamburoCheNutreState();
}

class _IlTamburoCheNutreState extends State<IlTamburoCheNutre> {
  /// **IL TEMPO DEL RITO E' QUELLO DEI BATTITI DEL `Timer`**, e non un
  /// cronometro: `Timer.tick` conta anche i battiti persi, quindi sul telefono
  /// segue l'orologio vero, e nelle prove segue quello simulato. Con un
  /// cronometro le prove avrebbero misurato un rito fermo.
  Duration _adesso = Duration.zero;
  static const Duration _passo = Duration(milliseconds: 16);
  Timer? _battito;
  Duration _battuto = Duration.zero;
  Duration? _ultimoColpo;
  Duration _ultimoPasso = Duration.zero;
  bool _finito = false;
  String? _riga;

  /// Le onde dei colpi: dove e quando.
  final List<(Offset, Duration)> _onde = [];

  double get _quanto =>
      _battuto.inMilliseconds / IlTamburoCheNutre.quantoDura.inMilliseconds;

  @override
  void initState() {
    super.initState();
    _battito = Timer.periodic(_passo, _unPasso);
    // **QUI PARTIVA IL BATTITO CONTINUO DELLA DISCESA**, ordine DI voce 13,
    // sotto i colpi della persona. Tolto con l'ordine DL voce 11: il suono
    // del nutrimento e' il colpo del dito, e due tamburi insieme, uno a
    // quattro battiti e mezzo al secondo e uno al ritmo della mano, si
    // pestano i piedi. Il battito continuo resta alla discesa.
  }

  @override
  void dispose() {
    _battito?.cancel();
    super.dispose();
  }

  void _unPasso(Timer t) {
    if (!mounted) return t.cancel();
    final adesso = _passo * t.tick;
    _adesso = adesso;
    final passo = adesso - _ultimoPasso;
    _ultimoPasso = adesso;
    final vivo = _ultimoColpo != null &&
        adesso - _ultimoColpo! <= IlTamburoCheNutre.unColpoTieneVivo;
    setState(() {
      if (vivo && !_finito) {
        _battuto += passo;
        if (_battuto >= IlTamburoCheNutre.quantoDura) {
          _battuto = IlTamburoCheNutre.quantoDura;
          _finito = true;
          widget.quandoHaiFinito();
          _riga = widget.rigaDelloStato?.call();
        }
      }
      _onde.removeWhere((o) => adesso - o.$2 > const Duration(seconds: 1));
    });
  }

  void _colpo(TapDownDetails d) {
    if (_finito) return;
    _ultimoColpo = _adesso;
    _onde.add((d.localPosition, _adesso));
    unawaited(PaletteSensoriale.vibra(context, SchemaAptico.tocco));
    // **IL COLPO SI SENTE**, ordine DL voce 11, insieme alla vibrazione.
    unawaited(PaletteSensoriale.colpoDiTamburo(context));
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    final dove = IlTamburoCheNutre.doveSta(_quanto);
    final etichetta = TypographyTokens.etichetta().copyWith(
      color: palette.goldSoft,
      letterSpacing: 1.4,
      shadows: [
        Shadow(color: Colors.black.withValues(alpha: 0.7), blurRadius: 10)
      ],
    );
    return LayoutBuilder(builder: (context, vincoli) {
      final w = vincoli.maxWidth;
      final h = vincoli.maxHeight;
      final larga = w * dove.larga;
      return GestureDetector(
        key: const Key('viaggio_tamburo_che_nutre'),
        behavior: HitTestBehavior.opaque,
        onTapDown: _colpo,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const SfondoDelMondoDiSotto(quale: SfondoDelViaggio.fondo),
            // **LA NEBBIA CHE SI DIRADA**, la stessa della discesa, e sta
            // **dietro** l'animale: l'ordine dice *"la nebbia intorno"*, e
            // alla prima fotografia del rito la nebbia davanti lo copriva del
            // tutto, cioe' a meta' rito non si vedeva nessuno arrivare.
            IgnorePointer(
              child: Opacity(
                opacity: (1 - _quanto).clamp(0.0, 1.0),
                child: CustomPaint(
                  key: const Key('viaggio_nebbia_che_si_dirada'),
                  size: Size.infinite,
                  painter: PittoreDellaNebbia(
                    apertura: _quanto,
                    senzaMoto: false,
                  ),
                ),
              ),
            ),
            // **L'ANIMALE CHE ARRIVA**: i piedi sulla terra, e la figura che
            // cresce mentre si avvicina. In fondo e' quasi un'ombra.
            Positioned(
              key: const Key('viaggio_animale_che_si_avvicina'),
              left: (w - larga) / 2,
              top: h * dove.piedi - larga * 0.85,
              width: larga,
              height: larga * 0.85,
              child: widget.riconosciuto
                  ? Image.asset(
                      widget.animale.fullPath,
                      fit: BoxFit.contain,
                      alignment: Alignment.bottomCenter,
                      opacity: AlwaysStoppedAnimation(dove.luce),
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    )
                  : OmbraDellAnimale(
                      key: const Key('viaggio_ombra_che_si_avvicina'),
                      immagine: widget.animale.ombraPath,
                      giaSagoma: true,
                      quantaLuce: dove.luce,
                    ),
            ),
            // **LA PELLE DEL TAMBURO**, in basso: pulsa alla cadenza del
            // tamburo, e dice dove e quando battere senza dirlo a parole.
            Align(
              alignment: const Alignment(0, 0.93),
              child: IgnorePointer(
                child: SizedBox.square(
                  dimension: AloneDelPolpastrello.raggio * 2.4,
                  child: _finito
                      ? const SizedBox.shrink()
                      : AloneDelPolpastrello(
                          key: const Key('viaggio_pelle_del_tamburo'),
                          colore: palette.gold,
                        ),
                ),
              ),
            ),
            // Le onde dei colpi, dove il dito e' caduto.
            IgnorePointer(
              child: CustomPaint(
                size: Size.infinite,
                painter: _PittoreDelleOnde(
                  onde: List.of(_onde),
                  adesso: _adesso,
                  colore: palette.goldSoft,
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(SpacingTokens.lg),
                  child: Text(
                    _finito
                        ? '${_maiuscola(_conArticolo)} è $_vicino.'
                        : 'Batti sul tamburo. Non fermarti.',
                    key: const Key('viaggio_istruzione_del_tamburo'),
                    textAlign: TextAlign.center,
                    style: etichetta,
                  ),
                ),
              ),
            ),
            if (_finito)
              Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(SpacingTokens.lg),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_riga != null) ...[
                          ParagrafiDiLettura(
                            key: const Key('viaggio_riga_dello_stato'),
                            testo: _riga!,
                            textAlign: TextAlign.center,
                            stile: TypographyTokens.lettura()
                                .copyWith(color: palette.goldSoft),
                          ),
                          const SizedBox(height: SpacingTokens.md),
                        ],
                        FilledButton(
                          key: const Key('viaggio_torna_dal_tamburo'),
                          onPressed: widget.quandoTorni,
                          style: FilledButton.styleFrom(
                            backgroundColor: palette.primary,
                            foregroundColor: palette.onPrimary,
                            minimumSize: const Size.fromHeight(52),
                          ),
                          child: Text('Torna',
                              style: TypographyTokens.etichetta()),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              Align(
                alignment: Alignment.bottomRight,
                child: SafeArea(
                  child: TextButton(
                    key: const Key('viaggio_smetti_il_tamburo'),
                    onPressed: widget.quandoTorni,
                    child: Text('Smetti', style: etichetta),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  String get _conArticolo => widget.riconosciuto
      ? '${widget.animale.articolo}${widget.animale.name}'
      : "l'animale";

  /// *"e' vicino"* o *"e' vicina"*, e il resto della frase.
  String get _vicino => widget.riconosciuto && widget.animale.femminile
      ? 'vicina a te'
      : 'vicino a te';

  static String _maiuscola(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

/// Le onde dei colpi, che si allargano e svaniscono in un secondo.
class _PittoreDelleOnde extends CustomPainter {
  _PittoreDelleOnde({
    required this.onde,
    required this.adesso,
    required this.colore,
  });

  final List<(Offset, Duration)> onde;
  final Duration adesso;
  final Color colore;

  @override
  void paint(Canvas canvas, Size size) {
    for (final (dove, quando) in onde) {
      final t = ((adesso - quando).inMilliseconds / 1000).clamp(0.0, 1.0);
      canvas.drawCircle(
        dove,
        24 + 90 * math.sqrt(t),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = colore.withValues(alpha: 0.6 * (1 - t)),
      );
    }
  }

  @override
  bool shouldRepaint(_PittoreDelleOnde vecchio) => true;
}
