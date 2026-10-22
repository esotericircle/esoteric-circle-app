import 'package:flutter/material.dart';

import '../../../core/oracolo_angeli/i_ruoli_e_l_estrazione.dart';
import '../../../design_system/theme/maestro_palette.dart';
import '../../../design_system/tokens/color_tokens.dart';
import '../../../design_system/tokens/spacing_tokens.dart';
import '../../../design_system/tokens/typography_tokens.dart';

/// **IL COLPO D'OCCHIO DELL'ORACOLO: LA SCALA DI LUCE CHE SI ACCENDE.** Ordine
/// GC voce GC.18, 22 ottobre 2026.
///
/// Il fondatore, alle 16:06: *"io noto che c'è troppo testo e infografica zero
/// e ci sono delle regole per le risposte o responsi che indicano di inserire
/// sempre un impatto visivo grafico"*; alle 16:09: *"Approvo"*. Briefing V13,
/// sezione 33; Linee Guida V14, sezione 2: il responso apre con un colpo
/// d'occhio visivo prima del testo.
///
/// **LA SCALA E' QUELLA DELLA SCENA, GIA' DIPINTA (R8).** La Scala di
/// Giacobbe del filmato (ordine FU voce FU.02) esiste in due pitture ferme,
/// spenta e accesa (`oracolo_scala_spenta_v1`, `oracolo_scala_accesa_v1`,
/// ordine FU voce FU.01), che nessuna schermata usava ancora: il grafico
/// mostra la spenta e accende la pittura accesa a gradini, ritagliata sulla
/// scala ([ritaglio], misurato sulla differenza fra le due pitture: la scala
/// accesa sta fra le colonne 292 e 479 e scende fino al pixel 1000, dove
/// comincia l'altare). Il codice disegna solo cio' che e' funzionale: quale
/// gradino si accende, il suo colore e la sua riga.
///
/// **I GRADINI SEGUONO LE CARTE USCITE.** Un gradino per carta, dal basso:
/// Fare (la carta del Custode) alla base, Sentire (il Cuore) a meta',
/// Capire (l'Intelletto) in cima, ognuno nel colore del suo ruolo
/// ([coloreDi]). Nella stesa a una carta si accende un solo gradino, al
/// centro, nell'oro. Una carta coperta (l'Intelletto senza l'ora di nascita)
/// lascia il suo gradino spento, e cosi' le carte chiuse dall'assaggio del
/// Viandante.
///
/// **E' UN'ALTRA FORMA**, diversa dalle piste dei semi della Stesa di
/// Tarocchi (GC.06) e dai grafici dell'Oroscopo: una scala verticale dipinta
/// che si illumina, non una pista, una colonna o una ruota.
///
/// **LA MICRO-ANIMAZIONE**: i gradini si accendono uno dopo l'altro in
/// [durata]. Con Riduci Movimento o la grafica alleggerita ([ferma]) la
/// scala appare gia' accesa e ferma.
class LaScalaDelResponso extends StatefulWidget {
  const LaScalaDelResponso({
    super.key,
    required this.carte,
    required this.palette,
    this.chiuse = const {},
    this.ferma = false,
  });

  /// Le carte uscite, nell'ordine dei ruoli; una sola nella stesa a una carta.
  final List<CartaDellOracolo> carte;

  final MaestroPalette palette;

  /// I ruoli chiusi dall'assaggio del Viandante: il loro gradino resta spento.
  final Set<RuoloDellAngelo> chiuse;

  final bool ferma;

  static const String scalaSpenta =
      'assets/img/oracolo_angeli/oracolo_scala_spenta_v1.webp';
  static const String scalaAccesa =
      'assets/img/oracolo_angeli/oracolo_scala_accesa_v1.webp';

  /// Le misure delle due pitture, in pixel.
  static const Size pittura = Size(768, 1376);

  /// **IL RITAGLIO SULLA SCALA**, in pixel delle pitture: la scala con un
  /// po' dell'anello dietro, dall'alto fino all'altare.
  static const Rect ritaglio = Rect.fromLTRB(200, 140, 570, 1000);

  /// L'altezza del grafico a schermo.
  static const double altezza = 156;

  static const Duration durata = Duration(milliseconds: 1500);

  /// **IL COLORE DI UN RUOLO**: l'oro del Custode (fare), il rosa del Cuore
  /// (sentire), l'azzurro di Medora per l'Intelletto (capire).
  static Color coloreDi(RuoloDellAngelo ruolo) => switch (ruolo) {
        RuoloDellAngelo.custode => ColorTokens.goldLight,
        RuoloDellAngelo.cuore => const Color(0xFFF08FA8),
        RuoloDellAngelo.intelletto => ColorTokens.medoraGlow,
      };

  /// **LA PAROLA DEL GRADINO**, come la scritta sopra la carta in piedi
  /// (GC.14): "Fare", "Sentire", "Capire", o "La carta del momento".
  static String parolaDi(CartaDellOracolo c) {
    if (c.delMomento) return 'La carta del momento';
    return switch (c.ruolo) {
      RuoloDellAngelo.custode => 'Fare',
      RuoloDellAngelo.cuore => 'Sentire',
      RuoloDellAngelo.intelletto => 'Capire',
    };
  }

  /// **QUALE GRADINO, DA 0 IN BASSO A 2 IN CIMA.** La carta del momento sta
  /// al centro.
  static int gradinoDi(CartaDellOracolo c) {
    if (c.delMomento) return 1;
    return switch (c.ruolo) {
      RuoloDellAngelo.custode => 0,
      RuoloDellAngelo.cuore => 1,
      RuoloDellAngelo.intelletto => 2,
    };
  }

  /// Se il gradino di questa carta si accende.
  static bool accesa(CartaDellOracolo c, Set<RuoloDellAngelo> chiuse) =>
      !c.coperta && !(!c.delMomento && chiuse.contains(c.ruolo));

  @override
  State<LaScalaDelResponso> createState() => _LaScalaDelResponsoState();
}

class _LaScalaDelResponsoState extends State<LaScalaDelResponso>
    with SingleTickerProviderStateMixin {
  late final AnimationController _accendi = AnimationController(
      vsync: this, duration: LaScalaDelResponso.durata);

  @override
  void initState() {
    super.initState();
    if (widget.ferma) {
      _accendi.value = 1;
    } else {
      _accendi.forward();
    }
  }

  @override
  void didUpdateWidget(covariant LaScalaDelResponso vecchio) {
    super.didUpdateWidget(vecchio);
    if (widget.ferma) _accendi.value = 1;
  }

  @override
  void dispose() {
    _accendi.dispose();
    super.dispose();
  }

  /// Quanto e' acceso l'[i]-esimo gradino che si accende.
  double _luce(int i, int quanti) {
    if (quanti == 0) return 0;
    final inizio = i / (quanti + 1);
    final t = ((_accendi.value - inizio) * (quanti + 1) / 2).clamp(0.0, 1.0);
    return Curves.easeOut.transform(t);
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    final carte = [
      for (final c in widget.carte)
        if (LaScalaDelResponso.accesa(c, widget.chiuse)) c,
    ];
    const r = LaScalaDelResponso.ritaglio;
    const alta = LaScalaDelResponso.altezza;
    final larga = alta * r.width / r.height;
    final s = alta / r.height;
    const banda = alta / 3;
    Widget pittura(String percorso) => OverflowBox(
          alignment: Alignment.topLeft,
          minWidth: LaScalaDelResponso.pittura.width * s,
          maxWidth: LaScalaDelResponso.pittura.width * s,
          minHeight: LaScalaDelResponso.pittura.height * s,
          maxHeight: LaScalaDelResponso.pittura.height * s,
          child: Transform.translate(
            offset: Offset(-r.left * s, -r.top * s),
            child: Image.asset(percorso,
                fit: BoxFit.fill,
                // La pittura intera e' 768 per 1376: a schermo ne serve
                // meno di un terzo, e decodificarla piena costerebbe memoria.
                cacheWidth: 384,
                filterQuality: FilterQuality.medium),
          ),
        );
    return Semantics(
      label: 'La scala di luce: ${[
        for (final c in carte) '${LaScalaDelResponso.parolaDi(c)}, ${c.angelo.name}',
      ].join('; ')}',
      child: ExcludeSemantics(
        child: AnimatedBuilder(
          animation: _accendi,
          builder: (context, _) => Container(
            key: const Key('oracolo_colpo_d_occhio'),
            padding: const EdgeInsets.all(SpacingTokens.sm),
            decoration: BoxDecoration(
              color: palette.deepest.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
              border: Border.all(color: palette.gold.withValues(alpha: 0.25)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(SpacingTokens.radiusSm),
                  child: SizedBox(
                    width: larga,
                    height: alta,
                    child: Stack(
                      children: [
                        Positioned.fill(
                            child: pittura(LaScalaDelResponso.scalaSpenta)),
                        for (var i = 0; i < carte.length; i++)
                          Positioned(
                            key: Key('oracolo_gradino_'
                                '${LaScalaDelResponso.gradinoDi(carte[i])}'),
                            left: 0,
                            width: larga,
                            top: alta -
                                banda *
                                    (LaScalaDelResponso.gradinoDi(carte[i]) +
                                        1),
                            height: banda,
                            child: Opacity(
                              opacity: _luce(i, carte.length),
                              child: ClipRect(
                                child: OverflowBox(
                                  alignment: Alignment.topLeft,
                                  minHeight: alta,
                                  maxHeight: alta,
                                  child: Transform.translate(
                                    offset: Offset(
                                        0,
                                        -(alta -
                                            banda *
                                                (LaScalaDelResponso.gradinoDi(
                                                        carte[i]) +
                                                    1))),
                                    child: SizedBox(
                                      width: larga,
                                      height: alta,
                                      child: ColorFiltered(
                                        colorFilter: ColorFilter.mode(
                                            carte[i].delMomento
                                                ? ColorTokens.goldLight
                                                : LaScalaDelResponso.coloreDi(
                                                    carte[i].ruolo),
                                            BlendMode.modulate),
                                        child: pittura(
                                            LaScalaDelResponso.scalaAccesa),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: SpacingTokens.md),
                // Le righe dei gradini accesi, dall'alto in basso come la
                // scala: la parola del ruolo nel suo colore e il nome
                // dell'angelo.
                Flexible(
                  child: SizedBox(
                    height: alta,
                    child: Stack(
                      children: [
                        for (var i = 0; i < carte.length; i++)
                          Positioned(
                            left: 0,
                            right: 0,
                            top: alta -
                                banda *
                                    (LaScalaDelResponso.gradinoDi(carte[i]) +
                                        1),
                            height: banda,
                            child: Opacity(
                              opacity: 0.25 + 0.75 * _luce(i, carte.length),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                        LaScalaDelResponso.parolaDi(carte[i])
                                            .toUpperCase(),
                                        maxLines: 1,
                                        style: TypographyTokens.etichetta()
                                            .copyWith(
                                                color: carte[i].delMomento
                                                    ? ColorTokens.goldLight
                                                    : LaScalaDelResponso
                                                        .coloreDi(
                                                            carte[i].ruolo),
                                                letterSpacing: 1.3)),
                                  ),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Text(carte[i].angelo.name,
                                        maxLines: 1,
                                        style: TypographyTokens.titoloScheda()
                                            .copyWith(
                                                color:
                                                    ColorTokens.textPrimary)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
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
