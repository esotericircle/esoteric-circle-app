import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/astro/natal_chart.dart';
import '../../core/astro/natal_chart_controller.dart';
import '../../core/astro/natal_poetics.dart';
import '../../core/identity/natal_identity.dart';
import '../../design_system/components/depth_card.dart';
import '../../design_system/components/natal_wheel.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../identity/completa_il_luogo.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../identity/widgets/identity_widgets.dart';
import '../identity/widgets/birth_companions.dart';
import 'widgets/nature_emblem.dart';
import '../../core/sensi/palette_sensoriale.dart';

/// La carta natale a due livelli: prima il colpo d'occhio (frase poetica e tre
/// aure intrecciate), poi la ruota elegante con gli aspetti attivabili e la
/// legenda viva, una tessera per pianeta collegata alla ruota.
class NatalChartReveal extends StatefulWidget {
  const NatalChartReveal({
    super.key,
    required this.onContinue,
    this.etichettaAzione,
  });

  final VoidCallback onContinue;

  /// Cosa dice il pulsante in fondo.
  ///
  /// Nel Risveglio invita alla Risonanza, che deve ancora avvenire. Aperta dal
  /// Passport la Risonanza e' gia' avvenuta da un pezzo, quindi quell'invito
  /// non significa piu' niente: chi arriva da li' vuole tornare da dove e'
  /// venuto.
  final String? etichettaAzione;

  @override
  State<NatalChartReveal> createState() => _NatalChartRevealState();
}

class _NatalChartRevealState extends State<NatalChartReveal> {
  /// LA SCHERMATA GARANTISCE IL PROPRIO DATO.
  ///
  /// Dal Passport si apriva la Carta natale e restava sul cerchio con "Traccio
  /// il tuo cielo..." per sempre: il fondatore ha aspettato oltre un minuto. Non
  /// era la rete, la chiamata non partiva mai. Il calcolo era invocato in UN
  /// SOLO punto di tutto il progetto, alla fine del Risveglio: chi arrivava da
  /// qualunque altra porta trovava uno stato mai avviato e un caricamento senza
  /// fine.
  ///
  /// La garanzia sta QUI e non nelle porte, perche' le porte sono piu' d'una e
  /// domani saranno di piu': una regola messa in una porta vale per quella porta
  /// soltanto, ed e' la famiglia di difetto che questo progetto ha gia'
  /// incontrato otto volte.
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _garantisciLaCarta());
  }

  void _garantisciLaCarta() {
    if (!mounted) return;
    final dettagli = context.read<BirthIdentityController>().details;
    // Senza dati di nascita non c'e' cielo da tracciare, e non si finge di
    // tracciarlo: il caso lo dichiara il build, non un cerchio che gira.
    if (dettagli == null) return;
    context.read<NatalChartController>().assicura(dettagli);
  }

  final _scroll = ScrollController();
  final _tileKeys = <String, GlobalKey>{};
  String? _selectedId;
  // Gli aspetti sono SEMPRE accesi: sono il contenuto della carta, non un
  // extra da accendere. Il pulsante che li spegneva e' stato tolto, perche'
  // nascondere di suo la parte piu' ricca della ruota non ha mai avuto senso.

  void _selectPlanet(String id, {bool scrollToTile = false}) {
    setState(() => _selectedId = _selectedId == id ? null : id);
    PaletteSensoriale.eseguiSchema(SchemaAptico.tocco);
    if (scrollToTile && _selectedId == id) {
      final key = _tileKeys[id];
      final ctx = key?.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(ctx,
            duration: const Duration(milliseconds: 400),
            alignment: 0.3,
            curve: Curves.easeOut);
      }
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<NatalChartController>();
    final identity = context.watch<BirthIdentityController>();
    final palette = context.palette;

    // UN CARICAMENTO SENZA USCITA NON E' UNO STATO AMMESSO. Se non ci sono dati
    // di nascita non c'e' niente da tracciare e lo si dice, invece di girare per
    // sempre su un cerchio che promette una carta che non arrivera' mai.
    if (identity.details == null) {
      return _SenzaDati(palette: palette, onContinue: widget.onContinue);
    }
    if (controller.status != ChartStatus.ready || controller.chart == null) {
      return const _Loading();
    }
    final chart = controller.chart!;

    return SingleChildScrollView(
      controller: _scroll,
      padding: const EdgeInsets.all(SpacingTokens.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: SpacingTokens.sm),
          Text('IL TUO CIELO',
              style: TypographyTokens.etichetta()
                  .copyWith(color: palette.goldSoft, letterSpacing: 3)),
          const SizedBox(height: SpacingTokens.md),
          // LA NOTA DEL RIPIEGO, che prima non leggeva nessuno: era scritta nel
          // controller e questa schermata non la mostrava mai. Chi riceveva il
          // cielo essenziale non sapeva ne che fosse essenziale ne perche', e
          // non aveva modo di riprovare quando la rete tornava.
          if (controller.ripiego && controller.note != null)
            _NotaDelRipiego(
              testo: controller.note!,
              palette: palette,
              // DUE CASI DIVERSI, DUE GESTI DIVERSI, ordine 2169 voce 3.
              // Quando manca il luogo, riprovare non serve a niente: si
              // riotterrebbe lo stesso ripiego all'infinito. Il gesto giusto
              // e' completare il dato, e adesso da qui si puo' fare.
              mancaIlLuogo: controller.mancaIlLuogo,
              onCompleta: () => CompletaIlLuogo.chiedi(context),
              onRiprova: () => context
                  .read<NatalChartController>()
                  .riprova(identity.details!),
            ),
          // --- Portale al cielo reale della nascita (al posto del vecchio
          //     bagliore), sempre riapribile a tutto schermo. ---
          if (identity.details != null)
            BirthSkyPortal(
              details: identity.details!,
              moonPhase: identity.facts?.moonPhase,
            ),
          const SizedBox(height: SpacingTokens.md),
          // --- Colpo d'occhio: frase poetica ---
          Text(
            NatalPoetics.glanceSummary(chart),
            textAlign: TextAlign.center,
            style: TypographyTokens.titoloSezione().copyWith(height: 1.4),
          ),
          const SizedBox(height: SpacingTokens.sm),
          _AscendantNote(chart: chart),
          const SizedBox(height: SpacingTokens.lg),
          // --- Fatti identitari: fase lunare di nascita e numero della vita ---
          if (identity.facts != null) ...[
            IdentityFactsSection(facts: identity.facts!),
            const SizedBox(height: SpacingTokens.lg),
          ],
          // --- Chi ti accompagna dalla nascita: Animale Guida e i tre Angeli.
          //     L'identita' di nascita e' una cosa sola: Sole, Luna, Ascendente
          //     e Numero della Vita stanno gia' qui, e questi stavano altrove.
          if (identity.details != null) ...[
            BirthCompanions(details: identity.details!),
            const SizedBox(height: SpacingTokens.lg),
          ],
          // LA RUOTA DICHIARA IL PROPRIO STATO quando il cielo e' quello
          // essenziale. Prima disegnava una ruota completa di aspetti con
          // dentro un solo astro, e sembrava un difetto grafico invece che una
          // carta ridotta: la stessa immagine diceva "ecco la tua carta" e
          // "manca tutto". Il cielo essenziale resta il tuo cielo, quindi non si
          // nasconde: si dice cos'e'.
          NatalWheel(
            chart: chart,
            size: 320,
            showAspects: !controller.ripiego,
            highlightPlanetId: _selectedId,
            onPlanetTap: (id) => _selectPlanet(id, scrollToTile: true),
          ),
          if (controller.ripiego) ...[
            const SizedBox(height: SpacingTokens.sm),
            Text(
              'Il tuo cielo essenziale: il Sole e il suo segno. I pianeti, le '
              'case e gli aspetti arrivano con la mappa completa.',
              key: const Key('carta_natale_ruota_ridotta'),
              textAlign: TextAlign.center,
              style: TypographyTokens.didascalia()
                  .copyWith(color: ColorTokens.textSecondary),
            ),
          ],

          const SizedBox(height: SpacingTokens.lg),
          _LegendHeader(),
          const SizedBox(height: SpacingTokens.sm),
          // --- Legenda viva ---
          for (final p in chart.planets)
            _PlanetTile(
              key: _tileKeys.putIfAbsent(p.id, () => GlobalKey()),
              planet: p,
              selected: _selectedId == p.id,
              onTap: () => _selectPlanet(p.id),
            ),
          const SizedBox(height: SpacingTokens.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: palette.gold,
                foregroundColor: palette.deepest,
                padding: const EdgeInsets.symmetric(vertical: SpacingTokens.md),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(SpacingTokens.radiusPill),
                ),
              ),
              onPressed: widget.onContinue,
              child: Text(widget.etichettaAzione ?? 'Scopri chi risuona con te',
                  style: TypographyTokens.lettura(weight: 600)
                      .copyWith(color: palette.deepest)),
            ),
          ),
          const SizedBox(height: SpacingTokens.lg),
        ],
      ),
    );
  }

}

class _AscendantNote extends StatelessWidget {
  const _AscendantNote({required this.chart});
  final NatalChart chart;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    if (chart.hasTime && chart.ascendant != null) {
      // Con l'ora, l'Ascendente si celebra.
      return Container(
        padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.md, vertical: SpacingTokens.xs),
        decoration: BoxDecoration(
          color: palette.gold.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
          border: Border.all(color: palette.gold.withValues(alpha: 0.5)),
        ),
        child: Text(
          'Ascendente in ${chart.ascendant!.italianName}: la soglia da cui ti mostri al mondo.',
          textAlign: TextAlign.center,
          style: TypographyTokens.lettura()
              .copyWith(color: palette.goldSoft, height: 1.4),
        ),
      );
    }
    // Solo senza ora, il messaggio velato.
    return Text(
      'Senza l\'ora di nascita l\'Ascendente e le Case restano velati. Potrai aggiungerla per completare il cielo.',
      textAlign: TextAlign.center,
      style: TypographyTokens.lettura()
          .copyWith(color: ColorTokens.textPrimary, height: 1.4),
    );
  }
}

class _LegendHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(width: 20, height: 1, color: palette.gold.withValues(alpha: 0.6)),
        const SizedBox(width: SpacingTokens.xs),
        Text('LA LEGENDA VIVA',
            style: TypographyTokens.etichetta().copyWith(
                color: palette.goldSoft, letterSpacing: 2)),
        const SizedBox(width: SpacingTokens.xs),
        Container(width: 20, height: 1, color: palette.gold.withValues(alpha: 0.6)),
      ],
    );
  }
}

class _PlanetTile extends StatelessWidget {
  const _PlanetTile({
    super.key,
    required this.planet,
    required this.selected,
    required this.onTap,
  });

  final PlanetPosition planet;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final dignity = NatalPoetics.dignityOf(planet.id, planet.sign);

    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.xs),
      child: DepthCard(
        onTap: onTap,
        padding: const EdgeInsets.all(SpacingTokens.sm),
        borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(
              color: selected
                  ? palette.gold
                  : Colors.transparent,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(SpacingTokens.radiusSm),
          ),
          child: Padding(
            padding: const EdgeInsets.all(SpacingTokens.xs),
            child: Row(
              children: [
                NatureEmblem(
                  element: planet.sign.element,
                  dignity: dignity,
                  retrograde: planet.retrograde,
                  size: 42,
                ),
                const SizedBox(width: SpacingTokens.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Wrap, non Row: su schermo stretto la riga va a capo
                      // invece di sforare, senza cambiare gli elementi.
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        runSpacing: 2,
                        children: [
                          _sym(planet.glyph, palette.goldSoft, 16),
                          Text(planet.name,
                              style: TypographyTokens.titoloScheda()),
                          _sym(planet.sign.symbol, palette.goldSoft, 14),
                          Text(planet.sign.italianName,
                              style: TypographyTokens.didascalia().copyWith(
                                  color: ColorTokens.textSecondary)),
                          if (planet.retrograde)
                            Text('R',
                                style: TypographyTokens.didascalia().copyWith(
                                    color: const Color(0xFFE0733A),
                                    fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(NatalPoetics.meaningOf(planet.id),
                          style: TypographyTokens.lettura()
                              .copyWith(color: ColorTokens.textPrimary)),
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

  Widget _sym(String glyph, Color color, double size) {
    // Il glifo del Sole non e' nel font simboli: si disegna.
    if (glyph == '☉') {
      return SizedBox(
        width: size,
        height: size,
        child: CustomPaint(painter: _SunGlyphPainter(color)),
      );
    }
    return Text(
      glyph,
      style: TextStyle(
          fontFamily: 'NotoSansSymbols', color: color, fontSize: size),
    );
  }
}

class _SunGlyphPainter extends CustomPainter {
  _SunGlyphPainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width * 0.42;
    canvas.drawCircle(c, r,
        Paint()..style = PaintingStyle.stroke..strokeWidth = 1.4..color = color);
    canvas.drawCircle(c, size.width * 0.09, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_SunGlyphPainter old) => old.color != color;
}

/// La nota che spiega perche' il cielo e' essenziale, con la via d'uscita.
class _NotaDelRipiego extends StatelessWidget {
  const _NotaDelRipiego({
    required this.testo,
    required this.palette,
    required this.onRiprova,
    required this.mancaIlLuogo,
    required this.onCompleta,
  });

  final String testo;
  final MaestroPalette palette;
  final VoidCallback onRiprova;

  /// Se cio' che manca e' il LUOGO, cioe' un dato che la persona ha e noi no.
  final bool mancaIlLuogo;

  /// Il gesto che porta a darcelo.
  final VoidCallback onCompleta;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('carta_natale_nota'),
      margin: const EdgeInsets.only(bottom: SpacingTokens.md),
      padding: const EdgeInsets.all(SpacingTokens.md),
      decoration: BoxDecoration(
        color: palette.goldSoft.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: palette.goldSoft.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(testo,
              style: TypographyTokens.lettura()
                  .copyWith(color: ColorTokens.textSecondary)),
          const SizedBox(height: SpacingTokens.sm),
          Align(
            alignment: Alignment.centerRight,
            child: mancaIlLuogo
                // Il dato manca: si offre di darlo, non di riprovare. Il
                // testo dice cosa succede, perche' un pulsante che non
                // dichiara il proprio effetto e' cio' che ha lasciato senza
                // luogo di nascita chi il luogo credeva di averlo dato.
                ? TextButton(
                    key: const Key('carta_natale_completa_luogo'),
                    onPressed: onCompleta,
                    child: Text('Aggiungi il luogo di nascita',
                        style: TypographyTokens.etichetta()
                            .copyWith(color: palette.goldSoft)),
                  )
                : TextButton(
                    key: const Key('carta_natale_riprova'),
                    onPressed: onRiprova,
                    child: Text('Riprova',
                        style: TypographyTokens.etichetta()
                            .copyWith(color: palette.goldSoft)),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Quando i dati di nascita non ci sono, e quindi non c'e' cielo da tracciare.
///
/// Prima questo caso finiva nel caricamento eterno: il cerchio girava promettendo
/// una carta che nessuno stava calcolando. Un caricamento senza uscita non e' uno
/// stato ammesso, e mai un vicolo cieco.
class _SenzaDati extends StatelessWidget {
  const _SenzaDati({required this.palette, required this.onContinue});

  final MaestroPalette palette;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const Key('carta_natale_senza_dati'),
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome_outlined, color: palette.goldSoft, size: 38),
            const SizedBox(height: SpacingTokens.md),
            Text(
              'Il tuo cielo aspetta la tua data di nascita.',
              textAlign: TextAlign.center,
              style: TypographyTokens.lettura()
                  .copyWith(color: ColorTokens.textPrimary),
            ),
            const SizedBox(height: SpacingTokens.sm),
            Text(
              'Senza il giorno in cui sei nato non posso tracciare niente. '
              'Preferisco dirtelo invece di farti aspettare.',
              textAlign: TextAlign.center,
              style: TypographyTokens.lettura()
                  .copyWith(color: ColorTokens.textSecondary),
            ),
            const SizedBox(height: SpacingTokens.lg),
            TextButton(
              onPressed: onContinue,
              child: Text('Torna indietro',
                  style: TypographyTokens.etichetta()
                      .copyWith(color: palette.goldSoft)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();
  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 42,
            height: 42,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(palette.goldSoft),
            ),
          ),
          const SizedBox(height: SpacingTokens.md),
          Text('Traccio il tuo cielo...',
              style: TypographyTokens.lettura()
                  .copyWith(color: ColorTokens.textSecondary)),
        ],
      ),
    );
  }
}
