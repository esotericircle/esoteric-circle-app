import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/astro/natal_chart_controller.dart';
import '../../core/astro/zodiac.dart';
import '../../core/astro/zodiac_controller.dart';
import '../../design_system/components/borsellino.dart';
import '../../design_system/components/porta_dell_account.dart';
import '../../design_system/components/zodiac_glyph.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import 'barra_del_cerchio.dart';

/// LA BARRA SOTTILE DELL'IDENTITA', CASA UNICA. Ordine AM voce 04, forma
/// decisa da Mauro dal collaudo della 2180.
///
/// Una fascia sottile e persistente in alto, sotto la barra di stato e sopra
/// il Navigator, con quattro cose in fila: la porta dell'account col volto,
/// il borsellino con la moneta d'oro e il saldo, il segno zodiacale in
/// miniatura e l'Ascendente. Al tocco scende e ingrandisce il contenuto, per
/// leggerlo meglio; un secondo tocco la richiude.
///
/// **E' LA CASA UNICA di quelle quattro cose**: volto, saldo, segno e
/// Ascendente non compaiono in nessun altro punto dell'app, e una prova
/// enumera i sorgenti e cade se una copia ricompare. E' la regola delle due
/// porte applicata alla scena, la stessa che ha tolto la pillola dalle
/// testate.
///
/// **La capsula, che stava qui prima, se n'e' andata** con la voce 03: era
/// un blocco in alto a destra e Mauro l'ha voluta via subito.
class BarraDellIdentita extends StatefulWidget {
  const BarraDellIdentita({
    super.key,
    required this.observatore,
    required this.child,
  });

  final OsservatoreDellaPila observatore;
  final Widget child;

  /// **L'ALTEZZA A RIPOSO, sottile.** Le schermate le fanno spazio come lo
  /// fanno alla barra di stato: si aggiunge al padding alto, cosi' ogni
  /// SafeArea gia' scritto ne tiene conto da solo e nessuna testata finisce
  /// coperta. E' una misura che descrive una resa, e la prova la confronta
  /// con l'altezza vera.
  static const double altezzaChiusa = 30;

  /// L'ALTEZZA APERTA: la barra scende e il contenuto si ingrandisce, per
  /// essere piu' leggibile. Tarata sulle anteprime.
  static const double altezzaAperta = 66;

  /// Quanto dura la discesa. Con Riduci Movimento il passaggio e' secco.
  static const Duration discesa = Duration(milliseconds: 260);

  /// Dove NON si vede: le soglie del Risveglio, dove la persona non ha
  /// ancora ne' volto ne' saldo ne' cielo, e una barra dell'identita' sopra
  /// il rito d'ingresso sarebbe una promessa vuota.
  static const Set<String> soglie = {
    'OnboardingScreen',
    'MaestroRevealScreen',
    'ArtIntroScreen',
  };

  static bool siVede(String? schermata) => !soglie.contains(schermata);

  @override
  State<BarraDellIdentita> createState() => _BarraDellIdentitaState();
}

class _BarraDellIdentitaState extends State<BarraDellIdentita> {
  String? _schermata;
  bool _aperta = false;

  @override
  void initState() {
    super.initState();
    widget.observatore.cambi.addListener(_pilaCambiata);
    _pilaCambiata();
  }

  @override
  void dispose() {
    widget.observatore.cambi.removeListener(_pilaCambiata);
    super.dispose();
  }

  void _pilaCambiata() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final cima = widget.observatore.schermataInCima();
      if (cima == _schermata) return;
      // Cambiando schermata la barra torna sottile: l'apertura apparteneva
      // alla lettura di prima.
      setState(() {
        _schermata = cima;
        _aperta = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final siVede = BarraDellIdentita.siVede(_schermata);
    final altezza = _aperta
        ? BarraDellIdentita.altezzaAperta
        : BarraDellIdentita.altezzaChiusa;
    final quantoOccupa = siVede ? altezza : 0.0;
    final durata =
        mq.disableAnimations ? Duration.zero : BarraDellIdentita.discesa;

    return Stack(
      children: [
        // **LE SCHERMATE LE FANNO SPAZIO**, esattamente come alla barra di
        // stato: si somma al padding alto e ogni SafeArea la rispetta senza
        // saperlo. Nessuna testata finisce coperta.
        MediaQuery(
          data: mq.copyWith(
            padding: mq.padding.copyWith(top: mq.padding.top + quantoOccupa),
            viewPadding:
                mq.viewPadding.copyWith(top: mq.viewPadding.top + quantoOccupa),
          ),
          child: widget.child,
        ),
        if (siVede)
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: _LaBarra(
              altezza: altezza,
              aperta: _aperta,
              durata: durata,
              suTocco: () => setState(() => _aperta = !_aperta),
              suChiusura: () => setState(() => _aperta = false),
            ),
          ),
      ],
    );
  }
}

class _LaBarra extends StatelessWidget {
  const _LaBarra({
    required this.altezza,
    required this.aperta,
    required this.durata,
    required this.suTocco,
    required this.suChiusura,
  });

  final double altezza;
  final bool aperta;
  final Duration durata;
  final VoidCallback suTocco;
  final VoidCallback suChiusura;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final palette = MaestroScope.forse(context) ?? MaestroPalette.neutral;
    // Le misure del contenuto: sottile a riposo, leggibile da aperta.
    final volto = aperta ? 40.0 : 22.0;
    final glifo = aperta ? 30.0 : 18.0;

    return Material(
      type: MaterialType.transparency,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: suTocco,
        child: AnimatedContainer(
          key: const Key('barra_dell_identita'),
          duration: durata,
          curve: Curves.easeOut,
          // La fascia occupa anche l'area sicura di sistema: sta SOTTO
          // l'orologio del telefono e non ci finisce mai sopra.
          padding: EdgeInsets.only(top: mq.padding.top),
          height: altezza + mq.padding.top,
          decoration: BoxDecoration(
            // Un velo di colore, mai una sfocatura per fotogramma.
            color: palette.deepest.withValues(alpha: aperta ? 0.92 : 0.72),
            border: Border(
              bottom: BorderSide(
                  color: palette.goldSoft.withValues(alpha: 0.22)),
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: SpacingTokens.sm),
              // 1. IL VOLTO, con i ripieghi di sempre.
              PortaDellAccount(
                misura: volto,
                suTocco: aperta ? NavigazioneDellaBarra.allAccount : suTocco,
              ),
              const SizedBox(width: SpacingTokens.sm),
              // 2. IL BORSELLINO, moneta d'oro e saldo.
              SegnoDelBorsellino(
                compatta: !aperta,
                monetaDOro: true,
                senzaVeste: true,
                contestoDelFoglio: aperta
                    ? NavigazioneDellaBarra.contestoDelNavigatore
                    : null,
                suTocco: aperta ? null : suTocco,
              ),
              const Spacer(),
              // 3. IL SEGNO e 4. L'ASCENDENTE, che si mostra SOLO quando la
              // carta natale l'ha dato: finche' manca non compare nulla, mai
              // un segnaposto.
              _SegnoEAscendente(
                misura: glifo,
                aperta: aperta,
                suTocco: aperta
                    ? () {
                        suChiusura();
                        NavigazioneDellaBarra.alPassport(context);
                      }
                    : suTocco,
              ),
              const SizedBox(width: SpacingTokens.sm),
            ],
          ),
        ),
      ),
    );
  }
}

/// Il segno solare e l'Ascendente, letti dalle loro fonti vere.
///
/// Il segno viene da `ZodiacController`, l'Ascendente dalla carta natale
/// calcolata (`NatalChartController.chart.ascendant`): in locale non si
/// calcola, arriva dalla callable, e finche' non c'e' non si mostra niente.
class _SegnoEAscendente extends StatelessWidget {
  const _SegnoEAscendente({
    required this.misura,
    required this.aperta,
    required this.suTocco,
  });

  final double misura;
  final bool aperta;
  final VoidCallback suTocco;

  @override
  Widget build(BuildContext context) {
    final palette = MaestroScope.forse(context) ?? MaestroPalette.neutral;
    final segno = context.watch<ZodiacController?>()?.sunSign;
    Zodiac? ascendente;
    try {
      ascendente = context.watch<NatalChartController>().chart?.ascendant;
    } catch (errore) {
      // Senza il controller nell'albero, come in una prova che monta una
      // scena da sola, l'Ascendente semplicemente non c'e'.
      ascendente = null;
    }
    if (segno == null && ascendente == null) return const SizedBox.shrink();

    Widget unSegno(Zodiac z, String etichetta, Key chiave) => Row(
          key: chiave,
          mainAxisSize: MainAxisSize.min,
          children: [
            ZodiacEmblem(
                sign: z, size: misura, art: ZodiacEmblemArt.symbol),
            if (aperta) ...[
              const SizedBox(width: 4),
              Text(
                etichetta,
                style: TypographyTokens.etichetta()
                    .copyWith(color: palette.goldSoft),
              ),
            ],
          ],
        );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: suTocco,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (segno != null)
            unSegno(segno, segno.italianName, const Key('barra_segno')),
          if (ascendente != null) ...[
            SizedBox(width: aperta ? SpacingTokens.sm : 6),
            // L'ASCENDENTE si distingue dal segno solare: da aperta lo dice
            // la parola, da chiusa la sigla, perche' due glifi uguali senza
            // una parola accanto sarebbero due enigmi.
            Row(
              key: const Key('barra_ascendente'),
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Asc',
                  style: TypographyTokens.etichetta()
                      .copyWith(color: ColorTokens.textSecondary),
                ),
                const SizedBox(width: 3),
                ZodiacEmblem(
                    sign: ascendente,
                    size: misura,
                    art: ZodiacEmblemArt.symbol),
                if (aperta) ...[
                  const SizedBox(width: 4),
                  Text(
                    ascendente.italianName,
                    style: TypographyTokens.etichetta()
                        .copyWith(color: palette.goldSoft),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}
