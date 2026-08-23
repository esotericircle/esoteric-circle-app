import 'dart:async';
import '../maestri/aura/archetype/archetype_test_screen.dart';
import '../sigilli/regia_del_cammino.dart';
import '../sigilli/segno_del_sentiero.dart';
import '../sigilli/sentiero_screen.dart';
import '../../core/sigilli/sentieri.dart';
import '../../core/archetypes/archetype_history.dart';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'specchio_dei_dati.dart';
import '../shell/spazio_della_barra.dart';

import '../../core/astro/night_sky.dart';
import '../../core/identity/birth_identity.dart';
import '../../core/identity/birth_moon.dart';
import '../../core/identity/numerology.dart';
import '../../core/identity/profile_controller.dart';
import '../../core/rituals/guide_animal_derivation.dart';
import '../maestri/caligo/animal/guide_animal_screen.dart';
import '../../design_system/components/depth_card.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../core/angels/guardian_angels.dart';
import '../../core/assets/family_image.dart';
import '../angels/angels_screen.dart';
import '../identity/circle_seal_screen.dart';
import '../santuario/sky_overview_screen.dart';
import '../santuario/widgets/moon_widget.dart';
import '../../core/maestro/maestro.dart';
import '../onboarding/natal_chart_reveal.dart';
import '../../design_system/components/immersive_scaffold.dart';
import '../../core/astro/natal_chart_controller.dart';
import '../../design_system/components/miniatura_intera.dart';

/// Schermata del Cosmic Passport.
///
/// I fatti identitari deterministici, quelli che nascono dalla sola data di
/// nascita, sono gia' vivi e mostrano il valore reale calcolato: Numero della
/// vita (numerologia) e Fase lunare di nascita (fase e segno lunare). Le voci
/// che richiedono servizi o asset esterni (carta natale completa, Angelo,
/// Archetipo, Animale guida) restano dietro il velo. Finche' l'onboarding non
/// fornisce la data vera, i fatti attivi usano `BirthIdentity.example`,
/// dichiarato in-world, e si popolano da soli quando arriva il dato reale.
///
/// Non ha un proprio Scaffold, AppBar o sfondo cosmico: e' solo contenuto,
/// destinato a essere inserito in un contenitore che fornisce navigazione e
/// sfondo.
class CosmicPassport extends StatefulWidget {
  const CosmicPassport({super.key, this.identity});

  /// Identita' di nascita da cui nascono i fatti deterministici. Se assente si
  /// usa il dato d'esempio, dichiarato in-world: passando un'identita' reale le
  /// tessere si popolano da sole.
  final BirthIdentity? identity;

  @override
  State<CosmicPassport> createState() => _CosmicPassportState();
}

class _CosmicPassportState extends State<CosmicPassport> {
  /// IL PASSAPORTO ENTRA NEL CAMMINO, ordine P voce 35.
  ///
  /// La Sezione Zero dava il Cosmic Passport per collegato alla regia: la
  /// verifica sui sorgenti dice di no, non lo era. Sono tre pezzi
  /// dell'identita' in un colpo solo, e fra loro c'e' la carta natale, cioe'
  /// il PRIMO dei tre Sigilli di aggancio trasversali.
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // **ALL'APERTURA MATURANO SOLO IL DOCUMENTO E IL NUMERO.** Ordine BD
      // voce 05: qui scattavano in un colpo solo anche la carta, l'ora e il
      // luogo, e i gradini dell'identita' maturavano in blocco alla prima
      // visita. Adesso ogni contenuto matura alla SUA porta: la carta, l'ora
      // e il luogo quando si apre la carta natale, la Luna al portale del
      // cielo di nascita, il Sigillo del Cerchio alla sua schermata. Il
      // numero della vita resta qui perche' la sua tessera non ha una porta:
      // vederla nel documento E' il gesto.
      unawaited(RegiaDelCammino.dopoUnGesto(context, 'passaporto'));
      unawaited(RegiaDelCammino.dopoUnGesto(context, 'numero_della_vita'));
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final id = widget.identity ?? BirthIdentity.example;
    final profile = context.watch<ProfileController>();

    // **LO SPAZIO DELLA BARRA STA DENTRO LO SCROLL.** Decisione di Mauro del
    // 7 agosto 2026, ragione intera su SpazioDellaBarraNelloScroll: il
    // contenuto scorre sotto la barra e l'ultimo elemento risale sopra grazie
    // alla coda in fondo agli sliver.
    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                SpacingTokens.lg,
                SpacingTokens.lg,
                SpacingTokens.lg,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Margine in alto: il titolo non deve mai finire sotto un
                  // eventuale pulsante nell'angolo in alto a sinistra.
                  const SizedBox(height: SpacingTokens.xl),
                  // Header cerimoniale: titolo e ingresso pulito alle
                  // Impostazioni, nell'angolo del documento.
                  // **PORTA E PILLOLA NON VIVONO PIU' QUI, ordine AL voce
                  // 08**: la capsula dell'identita' sta sopra il Navigator,
                  // una per tutta l'app. Il titolo si prende la riga intera
                  // e resta a corpo 26 con due righe possibili: la capsula
                  // gli sta sopra a destra e il margine destro la rispetta.
                  // **LA ROTELLINA NON C'E' PIU', ordine AK voce 03**: le
                  // Impostazioni restano a un tocco, capsula, "Il tuo
                  // account", voce Impostazioni.
                  Text(
                    'Cosmic Passport',
                    maxLines: 2,
                    style: TypographyTokens.display(size: 26),
                  ),
                  const SizedBox(height: SpacingTokens.xs),
                  Text(
                    'La tua identità cosmica, che si compone nel tempo.',
                    style: TypographyTokens.body(size: 16)
                        .copyWith(color: palette.goldSoft),
                  ),
                  const SizedBox(height: SpacingTokens.md),
                  // Testo introduttivo: spiega la natura fissa del documento.
                  // La frase minima dell'ordine AK voce 04: la promessa dei
                  // fatti fissi resta vera per le tessere, e il cammino vivo
                  // ha la sua casa col suo nome, la bolla qui sotto.
                  Text(
                    'Qui vivono i fatti identitari fissi del tuo cammino e, '
                    'in cima, i tuoi traguardi vivi: la carta natale non '
                    'cambia mai, il cammino cresce ogni giorno.',
                    style: TypographyTokens.body(size: 16)
                        .copyWith(color: ColorTokens.textSecondary),
                  ),
                  const SizedBox(height: SpacingTokens.lg),
                ],
              ),
            ),
          ),
          // Le tessere gia' vive: il portale del cielo di nascita e i due fatti
          // deterministici dalla sola data. Le altre restano dietro il velo.
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.lg),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  // I TRE SENTIERI DEI SIGILLI, ordine O: il Cosmic Journal
                  // vive qui, dove la persona viene a vedere chi e' per il
                  // Cerchio. Il cammino e' parte della sua identita', non una
                  // classifica.
                  const _SentieriDelCammino(),
                  const SizedBox(height: SpacingTokens.sm),
                  _BirthSkyPortalCard(birthMoment: id.birthMoment),
                  const SizedBox(height: SpacingTokens.sm),
                  _CircleSealCard(identity: id),
                  const SizedBox(height: SpacingTokens.sm),
                  _LifePathCard(identity: id),
                  const SizedBox(height: SpacingTokens.sm),
                  _BirthMoonCard(identity: id),
                  const SizedBox(height: SpacingTokens.sm),
                  _GuideAnimalCard(identity: id),
                  const SizedBox(height: SpacingTokens.sm),
                  _AngelsCard(identity: id),
                  const SizedBox(height: SpacingTokens.sm),
                  _NatalChartCard(identity: id),
                  const SizedBox(height: SpacingTokens.sm),
                  // LO SPECCHIO DEI DATI, ordine 2169 voce 8. Sta qui e non
                  // nelle impostazioni perche' il Passaporto e' gia' il posto
                  // dove la persona viene a vedere chi e' per il Cerchio: cio'
                  // che il Cerchio ricorda di lei appartiene a questa pagina.
                  const SpecchioDeiDati(),
                  const SizedBox(height: SpacingTokens.sm),
                  // L'ARCHETIPO, VIVO SE IL TEST E' STATO FATTO.
                  //
                  // Restava dietro il velo anche a test completato, e la
                  // causa non era un errore di disegno: questa tessera era
                  // una riga di un elenco FISSO di cose "in arrivo", e non
                  // guardava da nessuna parte. Fra cio' che la persona aveva
                  // fatto e cio' che questa schermata leggeva non c'era
                  // nessun collegamento, perche' lo storico del Test viveva
                  // dentro la schermata del Test e da nessun'altra parte.
                  const _TesseraArchetipo(),
                  const SizedBox(height: SpacingTokens.sm),
                  for (final entry in _passportEntries) ...[
                    _PassportEntryCard(entry: entry),
                    const SizedBox(height: SpacingTokens.sm),
                  ],
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: SpacingTokens.xxxl),
          ),
          // La coda che riporta l'ultima voce sopra la barra.
          const SliverSpazioDellaBarra(),
        ],
      ),
    );
  }
}

/// Il portale gia' attivo del passaporto: apre "Il tuo cielo di nascita", la
/// volta immersiva ancorata alla notte di nascita. Finche' non ci sono nascita
/// e luogo reali (BirthIdentity dalle effemeridi), usa un momento d'esempio,
/// dichiarato in-world nella schermata stessa.
class _BirthSkyPortalCard extends StatelessWidget {
  const _BirthSkyPortalCard({required this.birthMoment});

  final DateTime birthMoment;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return GestureDetector(
      key: const Key('passport_birth_sky'),
      behavior: HitTestBehavior.opaque,
      onTap: () {
        // **LA PORTA DELLA LUNA NATALE**, ordine BD voce 05: la Luna che
        // vegliava alla nascita si scopre guardando quel cielo, non
        // ereditandola dal documento pieno.
        unawaited(RegiaDelCammino.dopoUnGesto(context, 'luna_natale'));
        Navigator.of(context).push(
          SkyOverviewScreen.birthRoute(birthMoment: birthMoment),
        );
      },
      child: DepthCard(
        padding: const EdgeInsets.all(SpacingTokens.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.nights_stay, color: palette.goldSoft, size: 28),
            const SizedBox(width: SpacingTokens.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Il tuo cielo di nascita',
                    style: TypographyTokens.display(size: 18),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'La volta della tua prima notte, da esplorare con Medora.',
                    style: TypographyTokens.corpo()
                        .copyWith(color: ColorTokens.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: SpacingTokens.sm),
            Icon(Icons.chevron_right_rounded, color: palette.goldSoft),
          ],
        ),
      ),
    );
  }
}

/// Tessera del Sigillo del Cerchio: apre l'emblema personale deterministico.
class _CircleSealCard extends StatelessWidget {
  const _CircleSealCard({required this.identity});

  final BirthIdentity identity;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return DepthCard(
      key: const Key('passport_seal'),
      raised: true,
      onTap: () {
        // **LA PORTA DEL SIGILLO DEL CERCHIO**, ordine BD voce 05: si scopre
        // aprendo la sua schermata, non col documento pieno.
        unawaited(RegiaDelCammino.dopoUnGesto(context, 'sigillo_del_cerchio'));
        Navigator.of(context).push(CircleSealScreen.route(
            name: context.read<ProfileController>().vocative,
            identity: identity));
      },
      padding: const EdgeInsets.all(SpacingTokens.lg),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: palette.primary.withValues(alpha: 0.5),
              border: Border.all(color: palette.gold.withValues(alpha: 0.6)),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.workspace_premium_rounded,
                color: palette.goldSoft, size: 24),
          ),
          const SizedBox(width: SpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Il tuo Sigillo del Cerchio',
                    style: TypographyTokens.display(size: 18)),
                const SizedBox(height: 2),
                Text(
                  'Il tuo emblema, dal segno, dal numero e dall\'elemento.',
                  style: TypographyTokens.corpo()
                      .copyWith(color: ColorTokens.textSecondary),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: palette.goldSoft),
        ],
      ),
    );
  }
}

/// Tessera del Numero della vita: numerologia deterministica dalla data, con
/// un emblema a sigillo e una riga di significato.
class _LifePathCard extends StatelessWidget {
  const _LifePathCard({required this.identity});

  final BirthIdentity identity;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final lp = LifePath.forDate(identity.birthMoment);
    return _ActiveFactCard(
      cardKey: const Key('passport_life_path'),
      overline: 'Numero della vita',
      value: '${lp.number} · ${lp.title}',
      meaning: lp.meaning,
      isExample: identity.isExample,
      emblem: SizedBox(
        width: 52,
        height: 52,
        child: CustomPaint(
          painter: _LifePathSigil(number: lp.number, palette: palette),
        ),
      ),
    );
  }
}

/// Tessera della Fase lunare di nascita: fase e segno lunare del giorno di
/// nascita, con l'emblema della Luna gia' esistente e una riga di significato.
class _BirthMoonCard extends StatelessWidget {
  const _BirthMoonCard({required this.identity});

  final BirthIdentity identity;

  @override
  Widget build(BuildContext context) {
    final moon = BirthMoon.forDate(identity.birthMoment);
    return _ActiveFactCard(
      cardKey: const Key('passport_birth_moon'),
      overline: 'Fase lunare di nascita',
      value: moon.label,
      meaning: moon.meaning,
      isExample: identity.isExample,
      emblem: SizedBox(
        width: 52,
        height: 52,
        child: Center(child: MoonWidget(phase: moon.phase, size: 24)),
      ),
    );
  }
}

/// Tessera dell'Animale Guida: il totem deriva dal segno solare, deterministico
/// e fisso, quindi e' un fatto identitario vivo dalla sola data di nascita, come
/// la fase lunare. Emblema con la miniatura del totem, nome e sintesi.
/// Tessera dei tre Angeli: la tradizione ne assegna tre, da tre sorgenti
/// diverse. Toccabile, apre la schermata dedicata dove si vedono tutti e tre
/// con la loro arte e la ragione per cui sono i tuoi.
class _AngelsCard extends StatelessWidget {
  const _AngelsCard({required this.identity});

  final BirthIdentity identity;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final triade = GuardianAngels.forBirth(identity.toBirthDetails());
    final quanti = triade.known.length;
    return _ActiveFactCard(
      cardKey: const Key('passport_angels'),
      overline: 'I tuoi Angeli',
      value: triade.guardian.name,
      meaning: quanti == 3
          ? 'Custode, Cuore e Intelletto: i tre che ti accompagnano.'
          : 'Custode e Cuore. Il terzo arriva con l\'ora di nascita.',
      isExample: identity.isExample,
      onTap: () =>
          Navigator.of(context).push(AngelsScreen.route(identity: identity)),
      // L'angelo e' una CARTA: rettangolare verticale. In un quadrato da 52
      // con `cover` la figura veniva mozzata sui lati, e la cornice sparita.
      emblem: MiniaturaIntera.carta(
        path: FamilyImage.thumb(AssetFamily.angeli, triade.guardian.artStem),
        ripiego: Icons.auto_awesome,
        palette: palette,
        larghezza: 46,
      ),
    );
  }
}

class _GuideAnimalCard extends StatelessWidget {
  const _GuideAnimalCard({required this.identity});

  final BirthIdentity identity;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final segno = NightSky.sunSign(identity.birthMoment);
    final animal = GuideAnimalDerivation.forSign(segno);
    return _ActiveFactCard(
      cardKey: const Key('passport_guide_animal'),
      overline: 'Animale guida',
      value: animal.name,
      meaning: animal.summary,
      isExample: identity.isExample,
      // Al tocco si apre la lettura fissa di identita', chi e' il tuo animale.
      // Il viaggio ripetibile col tamburo sta invece nel dominio di Caligo.
      onTap: () {
        Navigator.of(context).push(GuideAnimalScreen.route(
            userSign: segno, modo: GuideAnimalMode.identita));
      },
      emblem: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: palette.surface.withValues(alpha: 0.5),
          border: Border.all(color: palette.gold.withValues(alpha: 0.5)),
        ),
        clipBehavior: Clip.antiAlias,
        // LA FIGURA CI STA DENTRO INTERA. Con `cover` il totem riempiva il
        // cerchio e ne usciva: zampe e coda tagliate dalla cornice. Si
        // rimpicciolisce l'immagine, non si taglia il soggetto, e per stare
        // dentro un cerchio serve un margine, perche' un quadrato inscritto in
        // un cerchio e' piu' piccolo del cerchio.
        child: Center(
          child: MiniaturaIntera(
            path: animal.thumbPath,
            ripiego: Icons.pets,
            palette: palette,
            larghezza: 38,
          ),
        ),
      ),
    );
  }
}

/// La tessera viva della carta natale.
///
/// Apre la carta calcolata, quella che il Risveglio mostra: la mappa celeste
/// esiste, si calcola sulle effemeridi e si puo' guardare. Prima il passaporto
/// la teneva fra le cose "in arrivo", quindi chi apriva il proprio passaporto
/// concludeva di non averla.
///
/// Non promette la Carta Natale INTERATTIVA coi transiti, che nel catalogo e'
/// dichiarata in arrivo ed e' un'altra cosa.
class _NatalChartCard extends StatelessWidget {
  const _NatalChartCard({required this.identity});

  final BirthIdentity identity;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    // LA TESSERA DICE CIO' CHE LA CARTA E' DAVVERO. Diceva "Calcolata sulle
    // effemeridi" sempre, anche quando la carta in mano era il cielo essenziale
    // del ripiego: l'app dichiarava di aver fatto una cosa che non aveva fatto,
    // ed e' peggio del ripiego stesso, perche' chi se ne accorge smette di
    // fidarsi anche di quello che e' vero.
    //
    // Cambia da sola quando la carta vera arriva, perche' legge lo stato del
    // controller invece di una stringa fissa.
    final carta = context.watch<NatalChartController>();
    final essenziale = carta.ripiego || carta.chart == null;
    return _ActiveFactCard(
      cardKey: const Key('passport_natal_chart'),
      overline: 'La tua carta natale',
      value:
          essenziale ? 'Il tuo cielo essenziale' : 'Calcolata sulle effemeridi',
      meaning: essenziale
          ? 'Per ora il Sole e il suo segno. La mappa dei pianeti arriva '
              'quando il cielo torna raggiungibile.'
          : identity.hasBirthTime
              ? 'Sole, Luna, pianeti, Ascendente e le dodici case.'
              : 'Sole, Luna e pianeti. Con l’ora di nascita arrivano anche '
                  'Ascendente e case.',
      isExample: identity.isExample,
      onTap: () {
        // **LA PORTA VERA DI QUESTI TRE GESTI**, ordine BD voce 05: aprire la
        // propria carta e' il gesto che li compie, non l'apertura del
        // documento. E mai sul dato d'esempio: un traguardo acceso su un
        // esempio sarebbe un traguardo regalato.
        if (!identity.isExample) {
          unawaited(RegiaDelCammino.dopoUnGesto(context, 'carta_natale'));
          unawaited(RegiaDelCammino.dopoUnGesto(context, 'ora_di_nascita'));
          unawaited(RegiaDelCammino.dopoUnGesto(context, 'luogo_di_nascita'));
        }
        Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (ctx) => MaestroScope(
            maestro: Maestro.medora,
            // ImmersiveScaffold e non il nudo widget: senza un antenato
            // Material, Flutter disegna una riga gialla sotto OGNI testo e il
            // fondo resta nero. Erano tre sintomi con una causa sola, e la
            // causa era questa rotta scritta da me senza scaffalatura:
            // sottolineature, fondo nero, cosmo in parallasse perduto.
            child: ImmersiveScaffold(
              seed: 21,
              child: NatalChartReveal(
                // La Risonanza qui e' gia' avvenuta: l'invito del Risveglio non
                // significherebbe niente.
                etichettaAzione: 'Torna al Passport',
                onContinue: () => Navigator.of(ctx).maybePop(),
              ),
            ),
          ),
        ),
      );
      },
      emblem: Icon(Icons.explore_rounded, color: palette.goldSoft, size: 28),
    );
  }
}

/// Tessera viva di un fatto identitario deterministico: emblema, etichetta,
/// valore reale calcolato e riga di significato. Se il dato e' d'esempio lo
/// dichiara in-world, senza il badge "Dietro il velo".
class _ActiveFactCard extends StatelessWidget {
  const _ActiveFactCard({
    required this.cardKey,
    required this.overline,
    required this.value,
    required this.meaning,
    required this.emblem,
    required this.isExample,
    this.onTap,
  });

  final Key cardKey;
  final String overline;
  final String value;
  final String meaning;
  final Widget emblem;
  final bool isExample;

  /// Se la tessera apre qualcosa al tocco, la freccia lo dice.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return DepthCard(
      key: cardKey,
      onTap: onTap,
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          emblem,
          const SizedBox(width: SpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  overline.toUpperCase(),
                  style: TypographyTokens.etichetta().copyWith(
                    color: palette.goldSoft.withValues(alpha: 0.8),
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(value, style: TypographyTokens.display(size: 19)),
                const SizedBox(height: 4),
                Text(
                  meaning,
                  style: TypographyTokens.corpo()
                      .copyWith(color: ColorTokens.textSecondary),
                ),
                if (isExample) ...[
                  const SizedBox(height: SpacingTokens.sm),
                  _ExampleNote(palette: palette),
                ],
              ],
            ),
          ),
          if (onTap != null)
            Icon(Icons.chevron_right_rounded, color: palette.goldSoft),
        ],
      ),
    );
  }
}

/// Nota in-world per i fatti che usano il dato d'esempio: si popolano da soli
/// quando arriva la data vera dall'onboarding.
class _ExampleNote extends StatelessWidget {
  const _ExampleNote({required this.palette});

  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.auto_awesome, size: 12, color: palette.goldSoft),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            'Valore d\'esempio: si compone con la tua data di nascita.',
            style: TypographyTokens.corpo().copyWith(
              color: palette.goldSoft.withValues(alpha: 0.7),
              letterSpacing: 0.4,
            ),
          ),
        ),
      ],
    );
  }
}

/// Emblema a sigillo del Numero della vita: un cerchio dorato con la cifra al
/// centro e una corona di tacche, piu' fitta per i numeri maestri.
class _LifePathSigil extends CustomPainter {
  _LifePathSigil({required this.number, required this.palette});

  final int number;
  final MaestroPalette palette;

  bool get _isMaster => number == 11 || number == 22 || number == 33;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.width / 2;

    // Alone tenue.
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..shader = RadialGradient(colors: [
          palette.goldSoft.withValues(alpha: 0.18),
          Colors.transparent,
        ]).createShader(Rect.fromCircle(center: center, radius: r)),
    );

    // Cerchio esterno.
    canvas.drawCircle(
      center,
      r * 0.86,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = palette.gold.withValues(alpha: 0.8),
    );

    // Corona di tacche: dodici, o ventiquattro per i numeri maestri.
    final ticks = _isMaster ? 24 : 12;
    final tick = Paint()
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round
      ..color = palette.gold.withValues(alpha: 0.55);
    for (var i = 0; i < ticks; i++) {
      final a = 2 * math.pi * i / ticks - math.pi / 2;
      final dir = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(
          center + dir * (r * 0.9), center + dir * (r * 0.99), tick);
    }

    // La cifra al centro, in Cinzel.
    final tp = TextPainter(
      text: TextSpan(
        text: '$number',
        style: TypographyTokens.display(size: _isMaster ? 18 : 22)
            .copyWith(color: palette.goldSoft),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(_LifePathSigil old) =>
      old.number != number || old.palette != palette;
}

/// Descrizione statica di una voce segnaposto del passaporto.
class _PassportEntry {
  const _PassportEntry({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}

/// Voci segnaposto dei fatti identitari che richiedono servizi o asset esterni.
/// Numero della vita e Fase lunare di nascita non sono qui: sono gia' vivi,
/// perche' nascono dalla sola data.
/// Qui restano SOLO i fatti che l'app davvero non ha ancora.
///
/// Ne sono uscite due voci che descrivevano cose gia' vive:
///
/// - **Carta natale**: la carta si calcola sulle effemeridi, si vede nel
///   Risveglio e ora ha la sua tessera viva qui sopra.
/// - **Angelo custode**: la tessera "I tuoi Angeli", poche righe sopra, era
///   gia' viva e apriva la triade calcolata. Erano due tessere per la stessa
///   cosa, una accesa e una spenta.
///
/// Promettere come futuro qualcosa che l'app fa gia' e' peggio di non
/// prometterlo: chi legge conclude che non ce l'ha.
/// **Ne e' uscita una TERZA, ed e' la correzione di questa voce.**
///
/// - **Archetipo**: era qui dentro, cioe' promesso come futuro, mentre il Test
///   Archetipo esiste ed e' vivo da mesi. Chi lo aveva completato tornava nel
///   Passaporto e ritrovava la sua figura profonda dietro il velo. Adesso ha
///   la sua tessera vera, [_TesseraArchetipo], che legge lo storico condiviso.
///
/// L'elenco resta, vuoto: e' il posto dove va cio' che l'app davvero non ha
/// ancora, e cancellarlo vorrebbe dire non avere piu' un posto dove metterlo.
const List<_PassportEntry> _passportEntries = [];

/// LA TESSERA DELL'ARCHETIPO: viva col Test fatto, dietro il velo senza.
///
/// Legge `ArchetypeHistory`, che l'app carica all'avvio e che serve anche al
/// simbolo di Aura nell'attesa della chat. Un dato solo, due porte.
class _TesseraArchetipo extends StatelessWidget {
  const _TesseraArchetipo();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    // L'ESITO INTERO, non il solo dominante: serve anche QUANDO e' stato
    // scoperto. Un passaporto senza data e' un foglio, e la data qui e' anche
    // l'unica cosa che dice alla persona che l'archetipo si puo' rifare.
    final ultimo = context.watch<ArchetypeHistory>().ultimo;
    final dominante = ultimo?.dominante;
    if (dominante == null) {
      // Senza Test non e' "in arrivo", e' "non l'hai ancora fatto": la
      // differenza conta, perche' la prima frase e' falsa e la seconda porta
      // da qualche parte.
      // **E LA CARD PORTA AL TEST, ordine BB voce 05.** Richiesta del
      // fondatore: "nel Passport in fondo, quando manca l'archetipo o un
      // altro elemento della carta natale, dovrebbe esserci un pulsante per
      // portare al test archetipo o alla funzionalita' per sbloccare
      // quell'elemento."
      //
      // **La frase diceva gia' cosa fare e non lo faceva fare.** "Fai il Test
      // Archetipo e la tua figura comparira' qui" e' un'istruzione: chi la
      // legge deve andare a cercarsi il Test da un'altra parte, e la tessera
      // che gliene parla resta muta sotto il dito. **E' un vicolo cieco
      // travestito da spiegazione.**
      //
      // **Lo stesso GestureDetector della card piena**, e per la stessa
      // ragione misurata: il ripple di Material chiede uno shader che in una
      // prova headless puo' non esserci, e ha gia' fermato la suite una volta.
      // **IL TOCCO SCENDE DENTRO LA CARD, e prima la avvolgeva.** Ordine BC
      // voce 03: avvolta da fuori, la card non sapeva di aprire qualcosa e
      // non poteva dirlo. Adesso lo sa, e disegna la freccia da se'.
      return _PassportEntryCard(
        key: const Key('passport_archetipo_vuoto_tocco'),
        onTap: () => Navigator.of(context).push(ArchetypeTestScreen.route()),
        entry: const _PassportEntry(
            icon: Icons.psychology_alt,
            title: 'Archetipo',
            // **LA FRASE DICE DOVE PORTA IL TOCCO**, invece di ordinare di
            // fare qualcosa altrove.
            description: 'Tocca per fare il Test Archetipo: la tua figura '
                'comparirà qui.',
          ),
      );
    }
    // **L'EMBLEMA SI TOCCA E APRE, ordine AO voce 06.** Prima era un'immagine
    // e basta: la figura piu' personale del Passaporto, e l'unica tessera che
    // non portava da nessuna parte. Adesso apre il Test Archetipo, dove chi
    // l'ha gia' fatto trova se stesso e la lettura di oggi.
    // **UN GestureDetector E NON UN InkWell, e la ragione e' misurata.** Il
    // ripple di Material chiede a runtime lo shader `ink_sparkle.frag`, che
    // in una prova headless puo' non esserci: la suite intera si e' fermata
    // una volta con "Asset 'shaders/ink_sparkle.frag' not found" dentro una
    // prova che non c'entrava niente col Passaporto, e isolata era verde.
    // L'ondina qui non aggiungeva nulla, sopra una DepthCard su fondo
    // cosmico, e il tocco funziona identico.
    return GestureDetector(
      key: const Key('passport_archetipo_tocco'),
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).push(ArchetypeTestScreen.route()),
      child: DepthCard(
      key: const Key('passport_archetipo'),
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Il suo emblema vero, non un'icona di sistema: e' una cosa sua.
          ClipRRect(
            borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
            child: Image.asset(
              dominante.arteThumb,
              width: 44,
              height: 44,
              // INTERA, mai adattata al riempimento: e' un'arte di brand, e
              // `cover` le taglia i bordi. Lo dice una prova che enumera tutti
              // i punti dove queste immagini compaiono, e l'ha presa.
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  Icon(Icons.psychology_alt, color: palette.goldSoft, size: 28),
            ),
          ),
          const SizedBox(width: SpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text('Archetipo',
                        maxLines: 1, style: TypographyTokens.display(size: 18)),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dominante.conArticolo,
                  key: const Key('passport_archetipo_nome'),
                  style: TypographyTokens.corpo()
                      .copyWith(color: palette.goldSoft),
                ),
                const SizedBox(height: 2),
                // LA DATA DELL'ULTIMO TEST, in cifre.
                //
                // In cifre e non "3 agosto 2026" perche' nel progetto non
                // esiste nessun posto che sappia scrivere i mesi in italiano, e
                // aprirne uno qui per una riga vorrebbe dire un vocabolario in
                // piu' da tenere allineato. La forma e' la stessa che la
                // piccola timeline del Test usa gia', con l'anno in coda.
                Text(
                  'Scoperto il ${ultimo!.quando.day}/${ultimo.quando.month}/'
                  '${ultimo.quando.year}',
                  key: const Key('passport_archetipo_quando'),
                  style: TypographyTokens.etichetta()
                      .copyWith(color: ColorTokens.textSecondary),
                ),
              ],
            ),
          ),
          // Il segno che si tocca: senza, la tessera aprirebbe qualcosa senza
          // averlo mai detto.
          Icon(Icons.chevron_right_rounded, color: palette.goldSoft, size: 20),
        ],
      ),
      ),
    );
  }
}

/// Tessera "in arrivo" di un singolo fatto identitario del passaporto.
///
/// **E QUANDO INVECE APRE QUALCOSA, LO DICE. Ordine BC voce 03.**
///
/// Fatto del fondatore: "nel Passport adesso la bolla archetipo e' cliccabile
/// anche se in grigio, ma ci vorrebbe una freccettina come per le altre bolle
/// che invita al click."
///
/// **La regola esisteva gia', scritta a due passi da qui**, dentro
/// `_PassportCard`: *"Se la tessera apre qualcosa al tocco, la freccia lo
/// dice"*, con un `if (onTap != null)` che disegna il chevron. Questa card
/// non l'aveva perche' era nata per le voci **dietro il velo**, cioe' per
/// cose che non aprono niente: il badge al posto della freccia era giusto
/// finche' e' stato vero. L'ordine BB voce 05 le ha poi aggiunto un tocco
/// **dall'esterno**, avvolgendola in un `GestureDetector`, e la card non ne
/// ha mai saputo nulla.
///
/// **E CON LA FRECCIA SE NE VA IL VELO, che e' l'altra meta' della stessa
/// bugia.** Una tessera che porta al Test Archetipo non e' "in arrivo": il
/// Test esiste ed e' vivo da mesi. Dire "Dietro il velo" e "Tocca per fare il
/// Test" nella stessa scatola sono due frasi che si smentiscono, e chi legge
/// crede alla piu' scoraggiante. Quindi dove c'e' un tocco la tessera torna
/// piena, e il velo resta a chi lo merita.
class _PassportEntryCard extends StatelessWidget {
  const _PassportEntryCard({super.key, required this.entry, this.onTap});

  final _PassportEntry entry;

  /// Se la tessera apre qualcosa al tocco, la freccia lo dice e il velo se ne
  /// va. Nulla per le voci che davvero non aprono niente.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final apre = onTap != null;

    return DepthCard(
      onTap: onTap,
      opacity: apre ? 1.0 : 0.6,
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(entry.icon, color: palette.goldSoft, size: 28),
          const SizedBox(width: SpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Il titolo si rimpicciolisce invece di rompersi: "Archetipo"
                // in Cinzel maiuscolo andava a capo DENTRO la parola. E' lo
                // stesso rimedio gia' usato per "Meditazione" nella striscia
                // delle arti.
                SizedBox(
                  width: double.infinity,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      entry.title,
                      maxLines: 1,
                      style: TypographyTokens.display(size: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  entry.description,
                  style: TypographyTokens.corpo()
                      .copyWith(color: ColorTokens.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: SpacingTokens.sm),
          if (apre)
            Icon(Icons.chevron_right_rounded, color: palette.goldSoft)
          else
            _VeilBadge(palette: palette),
        ],
      ),
    );
  }
}

/// Piccolo badge testuale con l'etichetta in-world unica, "Dietro il velo",
/// per le voci non ancora pronte. Stessa etichetta del dominio.
class _VeilBadge extends StatelessWidget {
  const _VeilBadge({required this.palette});

  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.xs,
        vertical: SpacingTokens.xxs,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
        border: Border.all(color: palette.gold.withValues(alpha: 0.35)),
      ),
      child: Text(
        'Dietro il velo',
        style: TypographyTokens.etichetta().copyWith(color: palette.goldSoft),
      ),
    );
  }
}

/// LE TRE PORTE DEI SENTIERI: Costellazione, Albero, Loto.
class _SentieriDelCammino extends StatelessWidget {
  const _SentieriDelCammino();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    // IL MATERIAL SOPRA LE TRE PORTE: il Passaporto e' contenuto puro, senza
    // Scaffold, e un ListTile senza Material sopra fa cadere l'intera
    // schermata. Lo ha trovato la cattura del Passport, non una prova di
    // questo lavoro.
    // **LA BOLLA "I TUOI TRAGUARDI", ordine AK voce 04, voce di Mauro.** Le
    // tre porte erano una colonna nuda in cima al corpo: ora vivono in una
    // bolla di sezione nello stile del Passaporto, col loro nome. Restano
    // tre ListTile e aprono ancora i loro sentieri.
    return DepthCard(
      key: const Key('bolla_dei_traguardi'),
      child: Material(
      type: MaterialType.transparency,
      child: Column(
        key: const Key('sentieri_del_cammino'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(SpacingTokens.md,
                SpacingTokens.sm, SpacingTokens.md, 0),
            child: Text('I tuoi traguardi',
                key: const Key('titolo_dei_traguardi'),
                // Il preset di sezione, non una misura scritta a mano: il
                // conto della tipografia nel dato non deve crescere.
                style: TypographyTokens.titoloSezione()
                    .copyWith(color: palette.goldSoft)),
          ),
          for (final sentiero in Sentieri.tutti) ...[
            ListTile(
              key: Key('porta_${sentiero.name}'),
              // **I TRE SEGNI DISEGNATI, NON I GLIFI DI SISTEMA. Ordine AT
              // voce 03.** Qui c'erano `star_rounded`, `spa_rounded` e
              // `local_florist_rounded`, cioe' proprio i tre glifi che
              // l'ordine manda via dalle feste, e per la stessa ragione:
              // **`spa_rounded` E' un fiore di loto**, quindi l'Albero e il
              // Loto portavano lo stesso fiore. Il progetto ha gia' le tre
              // forme disegnate da noi, nate con l'ordine AQ voce 02: si usano
              // anche qui, e i glifi di sistema escono dal Cammino per intero.
              leading: SegnoDelSentiero(
                sentiero: sentiero,
                colore: ColorTokens.goldLight,
                misura: 24,
              ),
              title:
                  Text(sentiero.titolo, style: TypographyTokens.titoloScheda()),
              // LA FRASE INTERA, ordine P voce 38. Qui si leggeva "I tuoi
              // Stella: cinquanta piccoli con cinque grandi": il nome
              // singolare incollato dentro una frase al plurale, e un
              // inventario al posto di una ragione per entrare. La promessa
              // del sentiero e' scritta per intero nel dato, non composta
              // qui incollando pezzi.
              subtitle: Text(
                sentiero.promessa,
                style: TypographyTokens.didascalia()
                    .copyWith(color: ColorTokens.textSecondary),
              ),
              trailing: const Icon(Icons.chevron_right_rounded,
                  color: ColorTokens.goldLight),
              onTap: () =>
                  Navigator.of(context).push(SentieroScreen.route(sentiero)),
            ),
          ],
        ],
      ),
      ),
    );
  }
}
