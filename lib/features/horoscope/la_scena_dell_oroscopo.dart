import 'package:flutter/material.dart';

import '../../core/astro/zodiac.dart';
import '../../core/horoscope/astro_tradition.dart';
import '../../core/horoscope/i_segni_delle_tradizioni.dart';
import '../../design_system/components/zodiac_glyph.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../scene/la_scena_in_video.dart';
import 'la_testa_della_tradizione.dart';

/// **LA SCENA DELL'OROSCOPO: IL SOLE SCEGLIE IL SEGNO.** Ordine FU voce
/// FU.13, 15 ottobre 2026. Il fondatore, 14 ottobre 2026: *"In verità si apre
/// con al centro in Grande l'emblema del segno dell'utente. Sarebbe carino
/// lasciarlo alla fine ovvero qualcosa di memorabile sempre con Medora, ma
/// alla fine lei resta con davanti il segno dell'utente, magari facendo
/// vedere anche tutti gli altri"*; sulla proposta del Sole che sceglie il
/// segno: *"Vai"*.
///
/// All'apertura dell'Oroscopo parte il video di Medora davanti alla ruota
/// dello zodiaco, una volta per apertura, e si ferma sull'ultimo fotogramma.
/// Allora nel globo di luce al centro della ruota appare in dissolvenza
/// l'emblema del segno della persona, grande, lo stesso della testa della
/// tradizione ([LaTestaDellaTradizione.figura]); nelle dodici sedi della ruota
/// gli emblemi dei dodici segni nel loro ordine, piu' tenui, con quello della
/// persona nella sede del Sole, in alto. Poi la lettura sale sopra la scena,
/// che resta ferma e scura dietro il testo.
///
/// Il video, il tocco che lo salta e l'audio passano dalle parti comuni di
/// `lib/features/scene/la_scena_in_video.dart`.
abstract final class LaScenaDellOroscopo {
  static const String filmato =
      'brand_assets/oroscopo_scena/medora_ruota_dello_zodiaco_v1.mp4';

  /// Il primo fotogramma del video: si vede mentre il video si prepara,
  /// cosi' la partenza non ha un salto.
  static const String primoFotogramma =
      'assets/img/oroscopo_scena/oroscopo_primo_fotogramma_v1.webp';

  /// L'ultimo fotogramma: la scena ferma, a video finito o saltato, e quella
  /// di ripiego (Riduci Movimento, grafica alleggerita, video che non si
  /// carica). Misurato: lo scarto medio dall'ultimo fotogramma del video e'
  /// 10,33 livelli su 255 (`docs/collaudo/FU/fu13_scena_oroscopo.txt`).
  static const String ultimoFotogramma =
      'assets/img/oroscopo_scena/oroscopo_ultimo_fotogramma_v1.webp';

  /// La misura del fotogramma (e del video): le coordinate qui sotto sono
  /// in questi pixel.
  static const Size fotogramma = Size(1080, 1920);

  // **LE COORDINATE SONO MISURATE, NON A OCCHIO.** Le ha misurate
  // `docs/collaudo/FU/fu13_misure.py` sull'ultimo fotogramma 1080x1920 con
  // OpenCV, e l'uscita sta in `docs/collaudo/FU/fu13_scena_oroscopo.txt`:
  // - le undici sedi chiare: candidati della trasformata di Hough, poi il
  //   disco chiaro e poco saturo (luminosita' > 165, saturazione < 60) come
  //   componente connessa, centro e raggio del cerchio minimo che lo
  //   racchiude;
  // - la sede del Sole, d'oro: Hough in una finestra attorno al punto alto;
  // - il centro della ruota: il cerchio ai minimi quadrati per gli undici
  //   centri, (540,4, 654,6), raggio 403,3; ogni sede sta a 30 gradi dalla
  //   vicina con meno di mezzo grado di scarto;
  // - il globo: il bordo preso lungo 144 direzioni dove la luminosita' cade
  //   piu' ripida, poi un cerchio ai minimi quadrati togliendo i punti oltre
  //   due deviazioni standard (143 punti su 144, residuo 0,4 pixel).

  /// Il centro del globo di luce, in pixel del fotogramma.
  static const Offset centroDelGlobo = Offset(540.1, 655.4);

  /// Il raggio del globo di luce, in pixel del fotogramma.
  static const double raggioDelGlobo = 171.3;

  /// Le dodici sedi della ruota, in pixel del fotogramma, in senso orario
  /// a partire dall'alto: la prima e' la sede del Sole.
  static const List<Offset> sedi = [
    Offset(539.5, 246.5), // la sede del Sole, in alto
    Offset(744.2, 304.9),
    Offset(890.7, 455.1),
    Offset(942.6, 656.8),
    Offset(887.5, 857.5),
    Offset(739.8, 1004.3),
    Offset(540.8, 1061.4),
    Offset(340.1, 1004.0),
    Offset(192.8, 859.3),
    Offset(139.1, 658.4),
    Offset(189.6, 455.5),
    Offset(337.0, 305.7),
  ];

  /// Il raggio dei dischi chiari delle sedi (il piu' piccolo misurato, 40,2;
  /// il disco d'oro del Sole e' 46,1): l'emblema di una sede ci sta dentro.
  static const double raggioDelleSedi = 40.2;

  /// Quanto dura la comparsa degli emblemi a video finito o a scena ferma.
  static const Duration dissolvenzaDegliEmblemi = Duration(milliseconds: 900);

  /// Quanto la scena resta con gli emblemi accesi prima che la lettura
  /// salga, a video finito: e' il momento da ricordare. Un tocco lo accorcia.
  static const Duration sostaSugliEmblemi = Duration(milliseconds: 1600);

  /// Quanto dura la salita della lettura sopra la scena.
  static const Duration salitaDellaLettura = Duration(milliseconds: 700);

  /// **LA SCENA SCURA DIETRO IL TESTO.** Quanto e' fitto il velo sopra la
  /// scena quando la lettura e' salita. Misurato il contrasto del testo
  /// sulle righe sopra il globo, la parte piu' chiara della scena:
  /// `docs/collaudo/FU/fu13_scena_oroscopo.txt`.
  static const double veloDietroLaLettura = 0.80;

  /// Quanto sono tenui gli emblemi delle sedi, fuori da quella del Sole.
  static const double tenueDelleSedi = 0.55;

  /// L'emblema al centro: lo stesso della testa della tradizione. Per
  /// l'Occidentale il segno solare della schermata ([occidentale]), come
  /// nella testa occidentale.
  static String? emblemaAlCentro(
      AstroTradition t, SegnoDellaTradizione? s, Zodiac occidentale) {
    if (t == AstroTradition.occidentale) {
      return ZodiacArt.emblemPath(occidentale);
    }
    return LaTestaDellaTradizione.figura(t, s);
  }

  /// Se l'emblema al centro e' quadrato su fondo, e non una figura
  /// scontornata: si disegna con gli angoli arrotondati e piu' piccolo.
  static bool alCentroUnEmblema(AstroTradition t, SegnoDellaTradizione? s) =>
      t != AstroTradition.occidentale &&
      LaTestaDellaTradizione.eUnEmblema(t, s);

  /// **GLI EMBLEMI DELLE DODICI SEDI**, nell'ordine di [sedi]: il primo e'
  /// quello della persona, nella sede del Sole. Null quando le sedi restano
  /// accese e vuote: le tradizioni che non hanno dodici segni (Maya, Celtica,
  /// Egizia, Araba) e quelle a dodici segni quando il segno non e' certo (la
  /// Vedica senza l'ora nel giorno in cui la Luna cambia segno) o non si sa:
  /// mettere un segno nella sede del Sole sarebbe indovinare.
  ///
  /// **IL VERSO DELLA RUOTA.** L'Occidentale e la Vedica girano in senso
  /// antiorario, come i segni nella ruota di una carta del cielo: il segno
  /// che segue quello della persona sta alla sua sinistra. La Cinese gira in
  /// senso orario, come i dodici rami terrestri sulla bussola, col Topo a
  /// nord e il Bue dopo di lui verso est.
  static List<String>? emblemiDelleSedi(
      AstroTradition t, SegnoDellaTradizione? s, Zodiac occidentale) {
    switch (t) {
      case AstroTradition.occidentale:
        return [
          for (var k = 0; k < 12; k++)
            ZodiacArt.emblemPath(
                Zodiac.values[(occidentale.index - k + 12) % 12]),
        ];
      case AstroTradition.cinese:
        final i = s?.animale;
        if (s == null || !s.certo || i == null) return null;
        return [
          for (var k = 0; k < 12; k++) _animale((i + k) % 12),
        ];
      case AstroTradition.vedica:
        if (s == null || !s.certo) return null;
        final i = s.zodiaco?.index ?? (s.nome.startsWith('Mithuna') ? 2 : 9);
        return [
          for (var k = 0; k < 12; k++) _rashi((i - k + 12) % 12),
        ];
      case AstroTradition.maya:
      case AstroTradition.celtica:
      case AstroTradition.egizia:
      case AstroTradition.araba:
        return null;
    }
  }

  static String _animale(int i) => 'assets/img/zodiac/zod_cinese_'
      '${ISegniDelleTradizioni.animali[i].$1.toLowerCase()}.webp';

  /// La figura di un rashi: quella occidentale, o la propria per Mithuna e
  /// Makara, come nella testa della Vedica.
  static String _rashi(int i) => switch (i) {
        2 => 'assets/img/zodiac/zod_vedica_mithuna.webp',
        9 => 'assets/img/zodiac/zod_vedica_makara.webp',
        _ => ZodiacArt.emblemPath(Zodiac.values[i]),
      };
}

/// **IL PALCO DELLA SCENA**: il fotogramma fermo, il video sopra di lui e gli
/// emblemi sulla ruota, tutti nella stessa misura del fotogramma e tagliati
/// allo stesso modo dello schermo ([BoxFit.cover], come il video): le
/// coordinate misurate valgono a ogni misura di telefono.
class IlPalcoDellOroscopo extends StatelessWidget {
  const IlPalcoDellOroscopo({
    super.key,
    required this.regia,
    required this.palette,
    required this.emblemaAlCentro,
    required this.alCentroUnEmblema,
    required this.emblemiDelleSedi,
    required this.emblemiAccesi,
    required this.dissolvenzaDegliEmblemi,
    required this.scura,
    required this.letturaAnimata,
    this.onTocco,
  });

  final RegiaDellaScena regia;
  final MaestroPalette palette;
  final String? emblemaAlCentro;
  final bool alCentroUnEmblema;

  /// Null: le sedi restano accese e vuote.
  final List<String>? emblemiDelleSedi;
  final bool emblemiAccesi;
  final Duration dissolvenzaDegliEmblemi;

  /// Vero quando la lettura e' salita: la scena si fa scura.
  final bool scura;
  final bool letturaAnimata;

  /// Il tocco sulla scena ferma, prima che la lettura salga: la fa salire.
  final VoidCallback? onTocco;

  @override
  Widget build(BuildContext context) {
    const f = LaScenaDellOroscopo.fotogramma;
    // Mentre il video si prepara si vede il suo primo fotogramma; da ferma,
    // l'ultimo.
    final preparando = !regia.ferma && !regia.filmatoInScena;
    final palco = SizedBox(
      width: f.width,
      height: f.height,
      child: Stack(
        children: [
          Positioned.fill(
            child: preparando
                ? Image.asset(LaScenaDellOroscopo.primoFotogramma,
                    key: const Key('oroscopo_scena_primo_fotogramma'),
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.medium)
                : LaScenaFermaCheAppare(
                    appare: regia.saltata,
                    child: Image.asset(LaScenaDellOroscopo.ultimoFotogramma,
                        key: const Key('oroscopo_scena_ferma'),
                        fit: BoxFit.fill,
                        filterQuality: FilterQuality.medium),
                  ),
          ),
          if (regia.filmatoInScena)
            Positioned.fill(
              child: IlFilmatoCheSfuma(
                key: const Key('oroscopo_scena_filmato'),
                saltato: regia.saltata,
                child: regia.disegna(),
              ),
            ),
          if (emblemiAccesi)
            Positioned.fill(
              child: _GliEmblemi(
                palette: palette,
                emblemaAlCentro: emblemaAlCentro,
                alCentroUnEmblema: alCentroUnEmblema,
                emblemiDelleSedi: emblemiDelleSedi,
                dissolvenza: dissolvenzaDegliEmblemi,
              ),
            ),
        ],
      ),
    );
    final durataDelVelo =
        letturaAnimata ? LaScenaDellOroscopo.salitaDellaLettura : Duration.zero;
    return Stack(
      key: const Key('oroscopo_scena'),
      children: [
        Positioned.fill(
          child: ClipRect(
            child: FittedBox(fit: BoxFit.cover, child: palco),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedOpacity(
              key: const Key('oroscopo_scena_velo'),
              opacity: scura ? LaScenaDellOroscopo.veloDietroLaLettura : 0,
              duration: durataDelVelo,
              curve: Curves.easeOut,
              child: ColoredBox(color: palette.deepest),
            ),
          ),
        ),
        if (onTocco != null)
          Positioned.fill(
            child: GestureDetector(
              key: const Key('oroscopo_scena_alza_la_lettura'),
              behavior: HitTestBehavior.opaque,
              onTap: onTocco,
            ),
          ),
      ],
    );
  }
}

/// **LA LETTURA CHE SALE SOPRA LA SCENA**: entra in dissolvenza salendo di
/// poco, mentre la sua cascata d'ingresso fa quello che ha sempre fatto. Non
/// animata (scena ferma dall'apertura) o con Riduci Movimento, e' gia' al suo
/// posto.
class LaLetturaCheSale extends StatelessWidget {
  const LaLetturaCheSale({
    super.key,
    required this.animata,
    required this.child,
  });

  final bool animata;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!animata || MediaQuery.of(context).disableAnimations) {
      return KeyedSubtree(key: const Key('oroscopo_lettura'), child: child);
    }
    return TweenAnimationBuilder<double>(
      key: const Key('oroscopo_lettura'),
      tween: Tween(begin: 0, end: 1),
      duration: LaScenaDellOroscopo.salitaDellaLettura,
      curve: Curves.easeOutCubic,
      builder: (context, quanto, figlio) => Opacity(
        opacity: quanto,
        child: Transform.translate(
            offset: Offset(0, 48 * (1 - quanto)), child: figlio),
      ),
      child: child,
    );
  }
}

class _GliEmblemi extends StatelessWidget {
  const _GliEmblemi({
    required this.palette,
    required this.emblemaAlCentro,
    required this.alCentroUnEmblema,
    required this.emblemiDelleSedi,
    required this.dissolvenza,
  });

  final MaestroPalette palette;
  final String? emblemaAlCentro;
  final bool alCentroUnEmblema;
  final List<String>? emblemiDelleSedi;
  final Duration dissolvenza;

  Widget _luce(double lato, double alfa) => Container(
        width: lato,
        height: lato,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [
            palette.gold.withValues(alpha: alfa),
            palette.gold.withValues(alpha: 0),
          ]),
        ),
      );

  @override
  Widget build(BuildContext context) {
    const c = LaScenaDellOroscopo.centroDelGlobo;
    const rg = LaScenaDellOroscopo.raggioDelGlobo;
    const rs = LaScenaDellOroscopo.raggioDelleSedi;
    final sedi = emblemiDelleSedi;
    final centro = emblemaAlCentro;
    // L'emblema al centro: la figura scontornata grande quanto il globo
    // lascia (1,7 raggi, il globo e' largo 2), l'emblema quadrato su fondo
    // piu' piccolo (1,25 raggi), che i suoi angoli restino dentro il globo.
    final latoAlCentro = alCentroUnEmblema ? 1.25 * rg : 1.7 * rg;
    final figure = <Widget>[
      for (var k = 0; k < LaScenaDellOroscopo.sedi.length; k++) ...[
        // **LE SEDI ACCESE**: una luce d'oro su ogni sede, anche vuota.
        Positioned(
          left: LaScenaDellOroscopo.sedi[k].dx - 1.6 * rs,
          top: LaScenaDellOroscopo.sedi[k].dy - 1.6 * rs,
          child: IgnorePointer(
            child: SizedBox(
              key: Key('oroscopo_sede_accesa_$k'),
              child: _luce(3.2 * rs, k == 0 ? 0.6 : 0.4),
            ),
          ),
        ),
        if (sedi != null)
          Positioned(
            left: LaScenaDellOroscopo.sedi[k].dx - 0.95 * rs,
            top: LaScenaDellOroscopo.sedi[k].dy - 0.95 * rs,
            width: 1.9 * rs,
            height: 1.9 * rs,
            child: Opacity(
              opacity: k == 0 ? 1 : LaScenaDellOroscopo.tenueDelleSedi,
              child: Image.asset(sedi[k],
                  key: Key('oroscopo_sede_$k'),
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.medium),
            ),
          ),
      ],
      Positioned(
        left: c.dx - rg,
        top: c.dy - rg,
        width: 2 * rg,
        height: 2 * rg,
        child: _luce(2 * rg, 0.45),
      ),
      if (centro != null)
        Positioned(
          left: c.dx - latoAlCentro / 2,
          top: c.dy - latoAlCentro / 2,
          width: latoAlCentro,
          height: latoAlCentro,
          child: alCentroUnEmblema
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(latoAlCentro * 0.12),
                  child: Image.asset(centro,
                      key: const Key('oroscopo_emblema_al_centro'),
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.medium),
                )
              : Image.asset(centro,
                  key: const Key('oroscopo_emblema_al_centro'),
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.medium),
        ),
    ];
    return TweenAnimationBuilder<double>(
      key: const Key('oroscopo_emblemi'),
      tween: Tween(begin: 0, end: 1),
      duration: dissolvenza,
      curve: Curves.easeOut,
      builder: (context, quanto, figlio) =>
          Opacity(opacity: quanto, child: figlio),
      child: Stack(clipBehavior: Clip.none, children: figure),
    );
  }
}
