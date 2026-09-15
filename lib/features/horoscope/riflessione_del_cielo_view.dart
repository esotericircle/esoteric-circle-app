import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/astro/effemeridi.dart';
import '../../core/astro/transiti_del_giorno.dart';
import '../../core/horoscope/cielo_di_oggi.dart';
import '../../core/horoscope/riflessione_del_cielo.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';

/// LA CORONA DEI CORPI VERI DEL GIORNO, attorno all'emblema del segno.
///
/// Ordine BK voce 03, primo momento. **Non e' una decorazione che gira**: ogni
/// glifo sta dove sta davvero, all'angolo della sua longitudine eclittica del
/// giorno, presa dalle effemeridi locali con l'istante fisso di
/// `TransitiDelGiorno`. Chi guarda vede il cielo di oggi, non un carosello.
///
/// Sta in uno `Stack` insieme all'emblema, e non occupa spazio suo: il raggio
/// e' dato da chi la monta, cosi' la corona segue la figura invece di
/// imporle una misura.
class CoronaDeiCorpi extends StatelessWidget {
  const CoronaDeiCorpi({
    super.key,
    required this.adesso,
    required this.palette,
    required this.raggio,
    required this.durata,
  });

  final DateTime adesso;
  final MaestroPalette palette;
  final double raggio;

  /// Quanto ci mette la corona a comporsi. E' la durata del momento, cosi' i
  /// corpi finiscono di raccogliersi quando il momento finisce.
  final Duration durata;

  @override
  Widget build(BuildContext context) {
    final riduciMovimento = MediaQuery.of(context).disableAnimations;
    final posizioni = TransitiDelGiorno.posizioni(adesso);
    // Ordine stabile: l'enum, non la mappa. Due giri devono dare la stessa
    // scena, e l'ordine di iterazione di una mappa non e' una promessa.
    final corpi = CorpoCeleste.values
        .where((c) => posizioni.containsKey(c))
        .toList(growable: false);

    return SizedBox(
      width: raggio * 2,
      height: raggio * 2,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (var i = 0; i < corpi.length; i++)
            _corpoAlSuoPosto(
              context,
              corpo: corpi[i],
              longitudine: posizioni[corpi[i]]!,
              indice: i,
              quanti: corpi.length,
              riduciMovimento: riduciMovimento,
            ),
        ],
      ),
    );
  }

  /// **QUANTO E' GRANDE UN CORPO NELLA CORONA.**
  ///
  /// I due luminari sono piu' grandi, gli altri no: e' la gerarchia che
  /// qualunque cielo disegnato ha sempre avuto, e serve a far leggere la scena
  /// in un'occhiata invece che come dieci punti uguali.
  /// **PIU' GRANDI DI PRIMA, ordine BZ voce 06.** Erano 20, 16 e 11 punti: a
  /// quella misura un disco col glifo dentro non si legge, e infatti il glifo
  /// non c'era. La gerarchia resta quella: i due luminari davanti, gli altri
  /// dietro.
  double _misuraDi(CorpoCeleste corpo) => switch (corpo) {
        CorpoCeleste.sole => 30,
        CorpoCeleste.luna => 26,
        _ => 20,
      };

  Widget _corpoAlSuoPosto(
    BuildContext context, {
    required CorpoCeleste corpo,
    required double longitudine,
    required int indice,
    required int quanti,
    required bool riduciMovimento,
  }) {
    // Zero gradi in alto e il giro in senso orario, come la ruota natale.
    final angolo = (longitudine - 90) * math.pi / 180;
    final dx = raggio * math.cos(angolo);
    final dy = raggio * math.sin(angolo);

    // I corpi si raccolgono uno dopo l'altro dentro la durata del momento: il
    // primo subito, l'ultimo poco prima della fine. Con Riduci Movimento sono
    // tutti gia' posati, perche' il momento va VISTO lo stesso.
    final quota = quanti <= 1 ? 0.0 : indice / quanti;
    // **IL CORPO E' UN DISCO, E IL GLIFO GLI STA SOPRA. Ordine BZ voce 06.**
    //
    // **Il glifo adesso c'e', e prima no.** Il commento di qui diceva che
    // `NotoSansSymbols` non era un asset di questo repository, e quando fu
    // scritto era vero: il disco restava nudo. Il font e' entrato con la cura
    // del bosco del Cerchio (`assets/fonts/NotoSansSymbols-subset.ttf`,
    // dichiarato in pubspec.yaml), quindi il glifo si posa e si vede anche
    // dove il sistema non ne ha di suoi.
    //
    // **Era questo il difetto che il fondatore ha guardato**: "si formano dei
    // piccoli cerchi gialli intorno all'emblema del segno... mi sembra cmq
    // scarsa". Dieci dischi dorati senza simbolo SONO dei cerchi gialli. Con
    // il glifo sopra diventano il Sole, la Luna, Mercurio, e la scena dice
    // cosa sta guardando.
    final misura = _misuraDi(corpo);
    final glifo = Container(
      key: Key('riflessione_corpo_${corpo.id}'),
      width: misura,
      height: misura,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: palette.gold.withValues(alpha: 0.30),
        border: Border.all(color: palette.goldSoft.withValues(alpha: 0.9)),
        boxShadow: [
          BoxShadow(
            color: palette.gold.withValues(alpha: 0.35),
            blurRadius: misura * 0.7,
          ),
        ],
      ),
      child: Text(
        corpo.glifo,
        key: Key('riflessione_glifo_${corpo.id}'),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'NotoSansSymbols',
          fontSize: misura * 0.66,
          height: 1,
          color: ColorTokens.textPrimary,
        ),
      ),
    );

    return Transform.translate(
      offset: Offset(dx, dy),
      child: riduciMovimento
          ? glifo
          : TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: durata,
              curve: Interval(quota, 1.0, curve: Curves.easeOut),
              builder: (context, v, child) => Opacity(opacity: v, child: child),
              child: glifo,
            ),
    );
  }
}

/// LA RIGA DEL MOMENTO, sotto l'emblema che pulsa.
///
/// Ordine BK voce 03. Due momenti, uno dopo l'altro, e ognuno dice una cosa
/// sola: prima che il cielo si sta raccogliendo, poi QUALE fatto vero sta per
/// essere usato. Il fatto viene da `CorrenteDelCielo.fattoDelGiorno` e non e'
/// mai scritto a mano; quando il cielo vero non c'e' la riga dichiara il
/// ripiego invece di inventare un transito.
class RigaDellaRiflessione extends StatelessWidget {
  const RigaDellaRiflessione({
    super.key,
    required this.momento,
    required this.cielo,
    required this.palette,
  });

  final MomentoDellaRiflessione momento;
  final CieloDiOggi cielo;
  final MaestroPalette palette;

  /// Cosa si legge in questo momento.
  String get testo => switch (momento) {
        MomentoDellaRiflessione.raccolta => 'Il cielo si raccoglie.',
        MomentoDellaRiflessione.nomina =>
          RiflessioneDelCielo.rigaDelSecondoMomento(cielo),
      };

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: const Key('oroscopo_riflessione_riga'),
      padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.lg, vertical: SpacingTokens.md),
      child: Column(
        children: [
          Text(
            testo,
            key: Key('oroscopo_riflessione_${momento.name}'),
            textAlign: TextAlign.center,
            style: TypographyTokens.lettura().copyWith(
              color: momento == MomentoDellaRiflessione.nomina
                  ? palette.goldSoft
                  : ColorTokens.textSecondary,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
          const SizedBox(height: SpacingTokens.sm),
          _PassiDellaRiflessione(momento: momento, palette: palette),
        ],
      ),
    );
  }
}

/// I due passi, dichiarati: si vede a che punto e' la riflessione.
///
/// Serve a chi ha tolto le animazioni piu' che agli altri: senza movimento, il
/// solo modo di capire che i momenti sono due e che stanno passando e' vederli
/// contati.
class _PassiDellaRiflessione extends StatelessWidget {
  const _PassiDellaRiflessione({required this.momento, required this.palette});

  final MomentoDellaRiflessione momento;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final m in MomentoDellaRiflessione.values) ...[
          Container(
            key: Key('oroscopo_riflessione_passo_${m.name}'),
            width: m == momento ? 22 : 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: m.index <= momento.index
                  ? palette.gold.withValues(alpha: m == momento ? 0.95 : 0.5)
                  : palette.gold.withValues(alpha: 0.22),
            ),
          ),
        ],
      ],
    );
  }
}
