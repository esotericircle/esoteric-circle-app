import 'package:flutter/material.dart';

import '../../core/arts/art_catalog.dart';
import '../../core/arts/gli_sfondi_delle_schede.dart';
import '../../core/maestro/maestro.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import 'la_luce_delle_schede.dart';
import 'la_scheda_dell_arte.dart';

/// **UNA RIGA DI SCHEDE CHE SCORRE IN ORIZZONTALE.** Ordine EO voci 07 e 09,
/// 26 settembre 2026.
///
/// Il fondatore: ogni categoria scorre in orizzontale e la pagina in
/// verticale, come Netflix. E *"4 ok"*, sulla proposta *"scorrendo una riga,
/// la scheda al centro si ingrandisce appena e prende luce, le altre restano
/// un poco in ombra"*. **Con la riduzione del movimento non si solleva
/// niente**, come per il riflesso della voce EO.06.
class LaRigaDelleSchede extends StatefulWidget {
  const LaRigaDelleSchede({
    super.key,
    required this.chiave,
    required this.titolo,
    required this.arti,
    required this.formato,
    this.maestroDi,
    this.azione,
    this.chiaveDelTitolo,
    this.onTieni,
    this.sfondoDelMaestro = false,
  });

  /// La chiave della riga, per le prove e per le catture: `riga_<chiave>`.
  final String chiave;

  final String titolo;
  final List<ArtEntry> arti;
  final FormatoDellaScheda formato;

  /// Il Maestro di un'arte; se manca, lo cerca la scheda nel catalogo.
  final Maestro Function(ArtEntry art)? maestroDi;

  /// Un comando accanto al titolo, come la matita delle arti preferite.
  final Widget? azione;

  /// La chiave del titolo, se la riga ne ha una sua: quella delle arti
  /// preferite tiene `tue_arti_titolo`, che le guardie della home gia'
  /// cercano da prima dell'ordine EO.
  final Key? chiaveDelTitolo;

  /// La pressione lunga su una scheda, se la riga la prevede.
  final void Function(ArtEntry art)? onTieni;

  /// La riga "In arrivo" dei domini: lo sfondo del Maestro e l'icona.
  final bool sfondoDelMaestro;

  /// **Quanto si solleva la scheda al centro**, e quanta ombra resta sulle
  /// altre.
  static const double sollevamento = 1.05;
  static const double ombra = 0.32;

  /// Quanto la scheda [indice] e' al centro, fra 0 e 1, con lo scorrimento
  /// [pixel] in una vista larga [vista].
  static double quantoAlCentro(
      {required int indice,
      required double pixel,
      required double passo,
      required double larghezza,
      required double vista}) {
    final centro = SpacingTokens.lg + indice * passo + larghezza / 2 - pixel;
    final distanza = (centro - vista / 2).abs();
    return (1 - distanza / (vista / 2)).clamp(0.0, 1.0);
  }

  /// Lo spazio fra una scheda e l'altra.
  static const double spazio = SpacingTokens.md;

  @override
  State<LaRigaDelleSchede> createState() => _LaRigaDelleSchedeState();
}

class _LaRigaDelleSchedeState extends State<LaRigaDelleSchede> {
  final ScrollController _scorri = ScrollController();
  final ValueNotifier<double> _scorrimento = ValueNotifier<double>(0);

  @override
  void initState() {
    super.initState();
    _scorri.addListener(() {
      final p = _scorri.position;
      _scorrimento.value = p.maxScrollExtent <= 0
          ? 0
          : (p.pixels / p.maxScrollExtent).clamp(0, 1);
    });
  }

  @override
  void dispose() {
    _scorri.dispose();
    _scorrimento.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.arti.isEmpty) return const SizedBox.shrink();
    final scala = MediaQuery.textScalerOf(context).scale(1);
    final larghezza =
        LaSchedaDellArte.larghezzaPer(widget.formato, scalaDelTesto: scala);
    final riduci = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    // L'altezza della riga: l'immagine, un poco di sollevamento, due righe
    // di titolo (o le tre del Viaggio), e il respiro.
    final titolo = TextPainter(
      text: TextSpan(text: 'A', style: LaSchedaDellArte.stileDelTitolo()),
      textDirection: TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    final altezzaTitolo = titolo.height * 3;
    titolo.dispose();
    final altezza = larghezza /
            widget.formato.proporzione *
            LaRigaDelleSchede.sollevamento +
        SpacingTokens.xs +
        altezzaTitolo +
        SpacingTokens.sm;
    return Column(
      key: Key('riga_${widget.chiave}'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              SpacingTokens.lg, SpacingTokens.lg, SpacingTokens.lg, 0),
          child: Row(
            children: [
              Flexible(
                child: Text(
                  widget.titolo,
                  key: widget.chiaveDelTitolo ??
                      Key('riga_titolo_${widget.chiave}'),
                  style: TypographyTokens.titoloDiSchermata()
                      .copyWith(color: ColorTokens.textPrimary),
                ),
              ),
              if (widget.azione != null) ...[
                const SizedBox(width: SpacingTokens.xs),
                widget.azione!,
              ],
            ],
          ),
        ),
        const SizedBox(height: SpacingTokens.sm),
        SizedBox(
          height: altezza,
          child: LoScorrimentoDellaRiga(
            scorrimento: _scorrimento,
            child: LayoutBuilder(builder: (context, spazio) {
              final vista = spazio.maxWidth;
              return ListView.separated(
                key: Key('riga_scorre_${widget.chiave}'),
                controller: _scorri,
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                padding:
                    const EdgeInsets.symmetric(horizontal: SpacingTokens.lg),
                itemCount: widget.arti.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: LaRigaDelleSchede.spazio),
                itemBuilder: (context, i) {
                  final art = widget.arti[i];
                  final scheda = LaSchedaDellArte(
                    key: Key('riga_${widget.chiave}_${art.id}'),
                    art: art,
                    maestro: widget.maestroDi?.call(art) ??
                        maestroDiArte(context, art.id),
                    formato: widget.formato,
                    larghezza: larghezza,
                    sfondoDelMaestro: widget.sfondoDelMaestro,
                    onTieni: widget.onTieni == null
                        ? null
                        : () => widget.onTieni!(art),
                  );
                  if (riduci) return scheda;
                  return _AlCentro(
                    scorri: _scorri,
                    indice: i,
                    passo: larghezza + LaRigaDelleSchede.spazio,
                    larghezza: larghezza,
                    vista: vista,
                    child: scheda,
                  );
                },
              );
            }),
          ),
        ),
      ],
    );
  }
}

/// **LA SCHEDA AL CENTRO SI SOLLEVA E PRENDE LUCE.** Ordine EO voce 07.
class _AlCentro extends StatelessWidget {
  const _AlCentro({
    required this.scorri,
    required this.indice,
    required this.passo,
    required this.larghezza,
    required this.vista,
    required this.child,
  });

  final ScrollController scorri;
  final int indice;
  final double passo;
  final double larghezza;
  final double vista;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: scorri,
      builder: (context, figlio) {
        final pixel = scorri.hasClients ? scorri.position.pixels : 0.0;
        final t = LaRigaDelleSchede.quantoAlCentro(
            indice: indice,
            pixel: pixel,
            passo: passo,
            larghezza: larghezza,
            vista: vista);
        return Transform.scale(
          alignment: Alignment.topCenter,
          scale: 1 + (LaRigaDelleSchede.sollevamento - 1) * t,
          child: Stack(
            children: [
              figlio!,
              Positioned.fill(
                child: IgnorePointer(
                  child: ColoredBox(
                    key: Key('scheda_ombra_$indice'),
                    color: Colors.black
                        .withValues(alpha: LaRigaDelleSchede.ombra * (1 - t)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      child: child,
    );
  }
}
