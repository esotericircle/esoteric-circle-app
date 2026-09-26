import 'package:flutter/material.dart';

import '../../../../core/astro/data_italiana.dart';
import '../../../../core/magic/intention_sigil.dart';
import '../../../../design_system/theme/maestro_palette.dart';
import '../../../../design_system/transizioni/velo_del_cerchio.dart';
import '../../../../design_system/tokens/color_tokens.dart';
import '../../../../design_system/tokens/spacing_tokens.dart';
import '../../../../design_system/tokens/typography_tokens.dart';
import '../../../../services/lo_sfondo_del_telefono.dart';
import 'il_segno_del_sigillo.dart';

/// I pezzi che la schermata del Sigillo e il Libro dei Sigilli hanno in
/// comune. Ordine DO, 15 settembre 2026.

/// **IL PULSANTE PIENO DEL SIGILLO**, oro con la scritta del fondo.
class PulsanteDelSigillo extends StatelessWidget {
  const PulsanteDelSigillo({
    super.key,
    required this.testo,
    required this.onPressed,
    required this.palette,
  });

  final String testo;
  final VoidCallback? onPressed;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: palette.gold,
          disabledBackgroundColor: palette.gold.withValues(alpha: 0.3),
          foregroundColor: palette.deepest,
          padding: const EdgeInsets.symmetric(vertical: SpacingTokens.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
          ),
        ),
        onPressed: onPressed,
        child: Text(testo,
            textAlign: TextAlign.center,
            style: TypographyTokens.corpo(weight: 600)
                .copyWith(color: palette.deepest)),
      ),
    );
  }
}

/// **IL PULSANTE LEGGERO DEL SIGILLO**, bordo d'oro e scritta d'oro.
class PulsanteLeggeroDelSigillo extends StatelessWidget {
  const PulsanteLeggeroDelSigillo({
    super.key,
    required this.testo,
    required this.onPressed,
    required this.palette,
  });

  final String testo;
  final VoidCallback? onPressed;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.goldSoft,
          side: BorderSide(color: palette.gold.withValues(alpha: 0.6)),
          padding: const EdgeInsets.symmetric(
              vertical: SpacingTokens.sm, horizontal: SpacingTokens.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
          ),
        ),
        onPressed: onPressed,
        child: Text(testo,
            textAlign: TextAlign.center,
            style: TypographyTokens.corpo(weight: 600)
                .copyWith(color: palette.goldSoft)),
      ),
    );
  }
}

/// **QUANTO VIVE UN SIGILLO**, le scelte della data. Voce DO.08: la data la
/// sceglie la persona nel momento in cui traccia.
enum TempoDelSigillo {
  settimana('Fra una settimana'),
  mese('Fra un mese'),
  treMesi('Fra tre mesi'),
  altra('Un\'altra data');

  const TempoDelSigillo(this.etichetta);
  final String etichetta;

  /// Il giorno della scadenza da [oggi], per le tre scelte fisse.
  DateTime? da(DateTime oggi) {
    final g = DateTime(oggi.year, oggi.month, oggi.day);
    return switch (this) {
      TempoDelSigillo.settimana => g.add(const Duration(days: 7)),
      TempoDelSigillo.mese => DateTime(g.year, g.month + 1, g.day),
      TempoDelSigillo.treMesi => DateTime(g.year, g.month + 3, g.day),
      TempoDelSigillo.altra => null,
    };
  }
}

/// **LA SCELTA DELLA DATA**, quattro gettoni e il calendario.
class LaDataDelSigillo extends StatefulWidget {
  const LaDataDelSigillo({
    super.key,
    required this.oggi,
    required this.scadenza,
    required this.onScelta,
    required this.palette,
    this.iniziale = TempoDelSigillo.mese,
  });

  final DateTime oggi;
  final DateTime scadenza;
  final ValueChanged<DateTime> onScelta;
  final MaestroPalette palette;
  final TempoDelSigillo iniziale;

  @override
  State<LaDataDelSigillo> createState() => _LaDataDelSigilloState();
}

class _LaDataDelSigilloState extends State<LaDataDelSigillo> {
  late TempoDelSigillo _scelto = widget.iniziale;

  Future<void> _tocca(TempoDelSigillo t) async {
    final fissa = t.da(widget.oggi);
    if (fissa != null) {
      setState(() => _scelto = t);
      widget.onScelta(fissa);
      return;
    }
    final domani =
        DateTime(widget.oggi.year, widget.oggi.month, widget.oggi.day + 1);
    final scelta = await showDatePicker(
      context: context,
      initialDate: widget.scadenza.isBefore(domani) ? domani : widget.scadenza,
      firstDate: domani,
      lastDate:
          DateTime(widget.oggi.year + 2, widget.oggi.month, widget.oggi.day),
      helpText: 'Il giorno in cui Caligo ti chiede com\'è andata',
    );
    if (scelta == null || !mounted) return;
    setState(() => _scelto = t);
    widget.onScelta(scelta);
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: SpacingTokens.sm,
          runSpacing: SpacingTokens.sm,
          children: [
            for (final t in TempoDelSigillo.values)
              ChoiceChip(
                key: Key('sigillo_data_${t.name}'),
                label: Text(t.etichetta,
                    style: TypographyTokens.corpo().copyWith(
                        color: _scelto == t
                            ? palette.deepest
                            : ColorTokens.textSecondary)),
                selected: _scelto == t,
                showCheckmark: false,
                selectedColor: palette.gold,
                backgroundColor: Colors.transparent,
                side: BorderSide(color: palette.gold.withValues(alpha: 0.5)),
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(SpacingTokens.radiusPill)),
                onSelected: (_) => _tocca(t),
              ),
          ],
        ),
        const SizedBox(height: SpacingTokens.xs),
        Text('Il giorno: ${dataItalianaEstesa(widget.scadenza)}',
            key: const Key('sigillo_data_scelta'),
            style: TypographyTokens.corpo()
                .copyWith(color: ColorTokens.textSecondary)),
      ],
    );
  }
}

/// **IL SIGILLO SUL TELEFONO.** Ordine DO voce 07: la risposta a *"cosa me
/// ne faccio"*.
///
/// Su Android il pulsante dice **"Imposta come sfondo"** e offre la
/// schermata Home, quella di blocco o entrambe. Su iPhone dice **"Salva
/// nelle foto"**, e sotto compaiono due righe che spiegano il passaggio
/// dalle impostazioni. **Il Condividi resta assente**: qui non si manda
/// niente a nessuno, la persona si porta il proprio segno sotto gli occhi.
class IlSigilloSulTelefono extends StatefulWidget {
  const IlSigilloSulTelefono({
    super.key,
    required this.via,
    required this.cammino,
    required this.palette,
    this.porta = const PortaDelloSfondo(),
  });

  final ViaMagica via;
  final List<Offset> cammino;
  final MaestroPalette palette;
  final PortaDelloSfondo porta;

  /// Le due righe di iPhone.
  static const String rigaIosUno =
      'iPhone non lascia a nessuna app cambiare lo sfondo: il sigillo si '
      'salva nelle tue foto.';
  static const String rigaIosDue =
      'Poi apri Impostazioni, Sfondo, Aggiungi nuovo sfondo: lì scegli la '
      'foto del sigillo.';

  @override
  State<IlSigilloSulTelefono> createState() => _IlSigilloSulTelefonoState();
}

class _IlSigilloSulTelefonoState extends State<IlSigilloSulTelefono> {
  bool _alLavoro = false;
  String? _esito;

  Future<void> _android() async {
    final dove = await foglioDelCerchio<DoveVaLoSfondo>(
      context: context,
      backgroundColor: widget.palette.deepest,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(SpacingTokens.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Dove lo metti?',
                  style: TypographyTokens.titoloSezione()
                      .copyWith(color: widget.palette.goldSoft)),
              const SizedBox(height: SpacingTokens.md),
              for (final (d, testo) in const [
                (DoveVaLoSfondo.home, 'Schermata Home'),
                (DoveVaLoSfondo.blocco, 'Schermata di blocco'),
                (DoveVaLoSfondo.entrambe, 'Entrambe'),
              ]) ...[
                PulsanteLeggeroDelSigillo(
                  key: Key('sigillo_sfondo_${d.name}'),
                  testo: testo,
                  palette: widget.palette,
                  onPressed: () => Navigator.of(ctx).pop(d),
                ),
                const SizedBox(height: SpacingTokens.sm),
              ],
            ],
          ),
        ),
      ),
    );
    if (dove == null || !mounted) return;
    setState(() {
      _alLavoro = true;
      _esito = null;
    });
    final png =
        await LoSfondoDelSigillo.png(via: widget.via, cammino: widget.cammino);
    final ok = await widget.porta.imposta(png, dove);
    if (!mounted) return;
    setState(() {
      _alLavoro = false;
      _esito = ok
          ? 'Fatto: il sigillo è sul tuo telefono.'
          : 'Il telefono non ha accettato lo sfondo. Riprova tra poco.';
    });
  }

  Future<void> _ios() async {
    setState(() {
      _alLavoro = true;
      _esito = null;
    });
    final png =
        await LoSfondoDelSigillo.png(via: widget.via, cammino: widget.cammino);
    final ok = await widget.porta.salvaNelleFoto(png);
    if (!mounted) return;
    setState(() {
      _alLavoro = false;
      _esito = ok
          ? 'Salvato nelle tue foto.'
          : 'Le foto non si sono aperte: il permesso si concede da '
              'Impostazioni, Privacy, Foto.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final android = widget.porta.puoImpostare;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PulsanteLeggeroDelSigillo(
          key: const Key('sigillo_sfondo'),
          testo: _alLavoro
              ? 'Preparo il sigillo...'
              : android
                  ? 'Imposta come sfondo'
                  : 'Salva nelle foto',
          palette: widget.palette,
          onPressed: _alLavoro ? null : (android ? _android : _ios),
        ),
        if (!android) ...[
          const SizedBox(height: SpacingTokens.xs),
          Text(IlSigilloSulTelefono.rigaIosUno,
              key: const Key('sigillo_sfondo_ios'),
              textAlign: TextAlign.center,
              style: TypographyTokens.corpo()
                  .copyWith(color: ColorTokens.textSecondary, height: 1.4)),
          Text(IlSigilloSulTelefono.rigaIosDue,
              textAlign: TextAlign.center,
              style: TypographyTokens.corpo()
                  .copyWith(color: ColorTokens.textSecondary, height: 1.4)),
        ],
        if (_esito != null) ...[
          const SizedBox(height: SpacingTokens.xs),
          Text(_esito!,
              key: const Key('sigillo_sfondo_esito'),
              textAlign: TextAlign.center,
              style: TypographyTokens.corpo()
                  .copyWith(color: widget.palette.goldSoft, height: 1.4)),
        ],
      ],
    );
  }
}
