import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../sigilli/regia_del_cammino.dart';

import '../../core/astro/zodiac.dart';
import '../../core/maestro/maestro.dart';
import '../../core/synastry/vip_catalog.dart';
import '../../design_system/components/cosmos_background.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../core/identity/birth_identity.dart';
import '../../core/synastry/cielo_della_sinastria.dart';
import '../../core/synastry/gemello_astrale.dart';
import 'cielo_dei_volti.dart';
import '../../core/synastry/collezione_delle_coppie.dart';
import 'collezione_screen.dart';
import 'rivelazione_del_gemello.dart';
import 'sinastria_vip_screen.dart';
import '../maestri/rotta_arte.dart';
import '../../design_system/components/titolo_che_non_si_rompe.dart';
import '../sigilli/celebrazione.dart';

/// La galleria di apertura della Sinastria VIP: si sceglie il VIP, poi si vede
/// il responso. E' l'apertura vera dell'arte.
///
/// Ricerca dal vivo per nome, filtri per categoria costruiti dal catalogo, una
/// fascia "In evidenza" con un tasto "A caso", e la griglia di tutti i VIP col
/// volto nella cornice. Tutto deterministico, tranne il tasto "A caso" che pesca
/// con `Random`. Il segno, la data e il nome dell'utente scorrono da qui fino al
/// responso, cosi' la card resta personale.
class SinastriaGalleryScreen extends StatefulWidget {
  const SinastriaGalleryScreen({
    super.key,
    this.userSign,
    this.userName,
    this.userBirth,
    this.random,
    this.primoVip,
  });

  /// **LA PRIMA CASELLA, ordine BO voce 13.** Quando la galleria si apre per
  /// scegliere il SECONDO lato di un confronto fra due VIP, qui c'e' il primo.
  final Vip? primoVip;

  final Zodiac? userSign;
  final String? userName;
  final DateTime? userBirth;

  /// Iniettabile nei test, cosi' il tasto "A caso" e' verificabile. In
  /// produzione resta nullo e si usa un `Random` vero.
  final math.Random? random;

  static Route<void> route({
    Zodiac? userSign,
    String? userName,
    DateTime? userBirth,
  }) {
    return MaterialPageRoute<void>(
      builder: (_) => SogliaArte(
        id: 'synastry_vip',
        maestro: Maestro.medora,
        child: SinastriaGalleryScreen(
          userSign: userSign,
          userName: userName,
          userBirth: userBirth,
        ),
      ),
    );
  }

  @override
  State<SinastriaGalleryScreen> createState() => _SinastriaGalleryScreenState();
}

class _SinastriaGalleryScreenState extends State<SinastriaGalleryScreen> {
  static const String _tutti = 'Tutti';

  final TextEditingController _ricerca = TextEditingController();
  late final math.Random _rng = widget.random ?? math.Random();

  String _query = '';
  String _categoria = _tutti;

  /// **IL GEMELLO ASTRALE, ordine BO voce 10.** Si calcola al tocco e non
  /// all'apertura: cinquanta responsi costano poco, ma calcolarli per chi non
  /// li ha chiesti sarebbe lavoro buttato a ogni apertura della galleria.
  GemelloAstrale? _gemello;

  @override
  void dispose() {
    _ricerca.dispose();
    super.dispose();
  }

  List<Vip> get _filtrati {
    final q = _query.trim().toLowerCase();
    return VipCatalog.vips.where((v) {
      final okCat = _categoria == _tutti || v.category == _categoria;
      final okNome = q.isEmpty || v.name.toLowerCase().contains(q);
      return okCat && okNome;
    }).toList(growable: false);
  }

  /// Vero mentre la schermata di un VIP e' aperta: da quel momento la scena
  /// sta raccontando, e nessuna festa ci si dipinge sopra. Ordine BV voce 02.
  bool _unVipEAperto = false;

  void _apri(Vip vip) {
    // **LA SCENA SI DICHIARA OCCUPATA PRIMA DEL GESTO, ordine BV voce 02.**
    // Il gesto qui sotto puo' far maturare un traguardo, e la festa si
    // aprirebbe nell'istante fra il tocco e la comparsa della chiamata: e' lo
    // stesso difetto che la stesa aveva, visto da un'altra scena.
    //
    // **Qui l'annuncio copre l'intera schermata del VIP e non la sola
    // chiamata**, e la ragione e' che questa scena non sa quando l'animazione
    // finisce: il gesto si registra qui, l'animazione vive nella rotta
    // spinta, e legare l'annuncio alla sola animazione avrebbe lasciato la
    // festa in coda senza nessuno che la faccia ripartire. Cosi' invece la
    // festa arriva appena si torna indietro, e la riga qui sotto svuota la
    // coda proprio li'.
    _unVipEAperto = true;
    RiflessioniInCorso.entra(() => mounted && _unVipEAperto);
    // LA SINASTRIA ENTRA NEL CAMMINO, ordine P voce 35: il confronto fra due
    // carte e' il gesto, e qui e' scelto.
    // **CON CHI, ordine AR voce 11.** La scena sa quale ritratto e' stato
    // scelto: e' il dettaglio che distingue "tre sinastrie" da "tre
    // sinastrie con tre persone diverse".
    unawaited(RegiaDelCammino.dopoUnGesto(
      context,
      'sinastria',
      dettagli: {'vip': vip.name},
    ));
    unawaited(Navigator.of(context)
        .push(SinastriaVipScreen.route(
      vip: vip,
      userSign: widget.userSign,
      userName: widget.userName,
      userBirth: widget.userBirth,
      primoVip: widget.primoVip,
    ))
        .then((_) {
      _unVipEAperto = false;
      if (mounted) {
        unawaited(
            RegiaDelCammino.svuotaLaCoda(context, appenaChiusaUna: true));
      }
    }));
  }

  /// Calcola il gemello e lo rivela.
  void _cercaIlGemello() {
    final cielo = CieloDiSinastria.perNascita(
      momentoUtc: DateTime.utc(
        (widget.userBirth ?? BirthIdentity.example.birthMoment).year,
        (widget.userBirth ?? BirthIdentity.example.birthMoment).month,
        (widget.userBirth ?? BirthIdentity.example.birthMoment).day,
        12,
      ),
      oraNota: false,
      latitudine: null,
      longitudineDelLuogo: null,
      segnoDichiarato: widget.userSign,
    );
    setState(() => _gemello = GemelloAstrale.per(cielo));
  }

  /// Apre la collezione. **Riaprire una coppia da li' non consuma niente.**
  void _apriLaCollezione() {
    Navigator.of(context).push(CollezioneScreen.route(onApri: (coppia) {
      final secondo = VipCatalog.conNome(coppia.secondo);
      if (secondo == null) return;
      Navigator.of(context).push(SinastriaVipScreen.route(
        vip: secondo,
        primoVip:
            coppia.primo.isEmpty ? null : VipCatalog.conNome(coppia.primo),
        userSign: widget.userSign,
        userName: widget.userName,
        userBirth: widget.userBirth,
        giaScoperta: true,
      ));
    }));
  }

  /// Mette un VIP nella prima casella, al posto della persona: la galleria si
  /// riapre per scegliere il secondo.
  void _sostituisciLaPrimaCasella(Vip primo) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => MaestroScope(
        maestro: Maestro.medora,
        child: SinastriaGalleryScreen(
          primoVip: primo,
          userSign: widget.userSign,
          userName: widget.userName,
          userBirth: widget.userBirth,
        ),
      ),
    ));
  }

  void _aCaso() {
    const vips = VipCatalog.vips;
    _apri(vips[_rng.nextInt(vips.length)]);
  }

  @override
  Widget build(BuildContext context) {
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.medora));
    final categorie = [_tutti, ...VipCatalog.categorie];
    final filtrati = _filtrati;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: palette.deepest.withValues(alpha: 0.35),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: palette.goldSoft),
        // **NIENTE FittedBox, ordine S voce 05.** Rimpiccioliva il titolo
        // senza fondo per tenerlo su una riga, quindi poteva scendere sotto il
        // pavimento tipografico dell'app, e non andava a capo mai. La regola e'
        // un'altra: a capo FRA le parole, e la misura scende solo quanto serve,
        // entro un minimo dichiarato.
        title: TitoloCheNonSiRompe(
            testo: 'Scegli il tuo VIP',
            stile: TypographyTokens.display(size: 19)),
        // IL BORSELLINO, ordine S voce 06: stesso segno, stesso angolo, in
        // ogni schermata della pratica. Un saldo che appare e scompare non
        // si impara.
        actions: const [AngoloDellaBarra()],
      ),
      body: CosmosBackground(
        seed: 17,
        showZodiac: false,
        child: SafeArea(
          child: CustomScrollView(
            key: const Key('sinastria_gallery'),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(SpacingTokens.lg,
                      kToolbarHeight, SpacingTokens.lg, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _BarraRicerca(
                        controller: _ricerca,
                        palette: palette,
                        onCambia: (v) => setState(() => _query = v),
                      ),
                      const SizedBox(height: SpacingTokens.md),
                      _FiltriCategoria(
                        categorie: categorie,
                        attiva: _categoria,
                        palette: palette,
                        onScegli: (c) => setState(() => _categoria = c),
                      ),
                      const SizedBox(height: SpacingTokens.lg),
                      _InEvidenza(
                        palette: palette,
                        onApri: _apri,
                        onACaso: _aCaso,
                      ),
                      const SizedBox(height: SpacingTokens.lg),
                      // **IL GEMELLO ASTRALE, ordine BO voce 10.**
                      if (_gemello == null)
                        Center(
                          child: OutlinedButton.icon(
                            key: const Key('sinastria_cerca_gemello'),
                            onPressed: _cercaIlGemello,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: palette.goldSoft,
                              side: BorderSide(
                                  color:
                                      palette.gold.withValues(alpha: 0.6)),
                              minimumSize: const Size.fromHeight(48),
                            ),
                            icon: const Icon(Icons.auto_awesome, size: 18),
                            label: Text('Trova il tuo gemello astrale',
                                style: TypographyTokens.etichetta()
                                    .copyWith(letterSpacing: 0.6)),
                          ),
                        )
                      else
                        GestureDetector(
                          onTap: () => _apri(_gemello!.vip),
                          child: RivelazioneDelGemello(
                              gemello: _gemello!, palette: palette),
                        ),
                      const SizedBox(height: SpacingTokens.md),
                      // **METTI UN VIP AL TUO POSTO, ordine BO voce 13.** La
                      // prima casella sei tu in modo predefinito, e da qui si
                      // sostituisce: la galleria si riapre per scegliere chi
                      // gli mettere contro.
                      if (widget.primoVip == null)
                        Center(
                          child: TextButton.icon(
                            key: const Key('sinastria_due_vip'),
                            onPressed: () =>
                                _sostituisciLaPrimaCasella(VipCatalog.first),
                            style: TextButton.styleFrom(
                                foregroundColor: palette.goldSoft,
                                minimumSize: const Size.fromHeight(48)),
                            icon: const Icon(Icons.compare_arrows_rounded,
                                size: 18),
                            label: Text('Metti due VIP uno contro l\'altro',
                                style: TypographyTokens.etichetta()),
                          ),
                        ),
                      const SizedBox(height: SpacingTokens.md),
                      Center(
                        child: TextButton.icon(
                          key: const Key('sinastria_apri_collezione'),
                          onPressed: _apriLaCollezione,
                          style: TextButton.styleFrom(
                              foregroundColor: palette.goldSoft,
                              minimumSize: const Size.fromHeight(48)),
                          icon: const Icon(Icons.collections_bookmark_outlined,
                              size: 18),
                          label: Text(
                              context
                                  .watch<CollezioneDelleCoppie>()
                                  .riepilogo,
                              style: TypographyTokens.etichetta()),
                        ),
                      ),
                      const SizedBox(height: SpacingTokens.lg),
                      Text(
                          widget.primoVip == null
                              ? 'Tutti i VIP'
                              : 'Scegli chi mettere contro '
                                  '${widget.primoVip!.name}',
                          style: TypographyTokens.display(size: 18)
                              .copyWith(color: palette.goldSoft)),
                      const SizedBox(height: SpacingTokens.sm),
                    ],
                  ),
                ),
              ),
              if (filtrati.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(SpacingTokens.xl),
                    child: Center(
                      child: Text('Nessun VIP con questo nome.',
                          key: const Key('sinastria_gallery_empty'),
                          style: TypographyTokens.corpo().copyWith(
                              color: ColorTokens.textSecondary)),
                    ),
                  ),
                )
              else
                // **IL CIELO DEI VOLTI AL POSTO DELLA GRIGLIA, ordine BO voce
                // 05.** Era una `SliverGrid` di mattonelle tutte uguali e
                // ferme: cinquanta ritratti in fila come un catalogo di
                // prodotti. Adesso i volti stanno sospesi su tre profondita' e
                // si muovono con la parallasse gia' esistente.
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(SpacingTokens.lg, 0,
                      SpacingTokens.lg, SpacingTokens.xxxl),
                  sliver: SliverToBoxAdapter(
                    child: CieloDeiVolti(
                      vips: filtrati,
                      // La larghezza la sa questa schermata: e' quella dello
                      // schermo meno i due margini della lista. Chiederla a
                      // un LayoutBuilder costava un rilayout per fotogramma.
                      larghezza: MediaQuery.sizeOf(context).width -
                          SpacingTokens.lg * 2,
                      palette: palette,
                      onApri: _apri,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// LA COSTELLAZIONE DI UNA CATEGORIA, disegnata dal suo nome.
///
/// **Cinque stelle su un cerchio, unite in fila.** Le posizioni nascono dai
/// caratteri del nome con la stessa dispersione a moltiplicatore usata nel
/// cielo dei volti: nessuna casualita', nessun asset, nessuna tabella da
/// tenere allineata. Il giorno che nasce una categoria nuova, la sua
/// costellazione esiste gia'.
class CostellazioneDellaCategoria extends CustomPainter {
  const CostellazioneDellaCategoria({required this.nome, required this.colore});

  final String nome;
  final Color colore;

  /// Quante stelle. Cinque e' il minimo perche' una figura si legga come
  /// figura e non come tre punti in fila.
  static const int stelle = 5;

  /// I punti della costellazione, dentro un riquadro unitario. Pubblico
  /// perche' la prova possa contarli senza dipingere.
  static List<Offset> puntiDi(String nome) {
    var seme = 2166136261;
    for (final u in nome.codeUnits) {
      seme = (seme ^ u) * 16777619 & 0x7fffffff;
    }
    final punti = <Offset>[];
    for (var i = 0; i < stelle; i++) {
      final a = 2 * math.pi * (i / stelle) + (seme % 360) * math.pi / 180;
      final raggio = 0.28 + ((seme >> (i * 3)) % 100) / 100 * 0.18;
      punti.add(Offset(0.5 + math.cos(a) * raggio, 0.5 + math.sin(a) * raggio));
    }
    return punti;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final punti = [
      for (final p in puntiDi(nome)) Offset(p.dx * size.width, p.dy * size.height)
    ];
    final filo = Paint()
      ..color = colore.withValues(alpha: 0.45)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
    final tracciato = Path()..moveTo(punti.first.dx, punti.first.dy);
    for (final p in punti.skip(1)) {
      tracciato.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(tracciato, filo);
    final stella = Paint()..color = colore;
    for (var i = 0; i < punti.length; i++) {
      canvas.drawCircle(punti[i], i == 0 ? 1.6 : 1.1, stella);
    }
  }

  @override
  bool shouldRepaint(CostellazioneDellaCategoria vecchio) =>
      vecchio.nome != nome || vecchio.colore != colore;
}

/// La barra di ricerca che filtra i VIP per nome, dal vivo.
class _BarraRicerca extends StatelessWidget {
  const _BarraRicerca({
    required this.controller,
    required this.palette,
    required this.onCambia,
  });

  final TextEditingController controller;
  final MaestroPalette palette;
  final ValueChanged<String> onCambia;

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: const Key('sinastria_search'),
      controller: controller,
      onChanged: onCambia,
      style: TypographyTokens.corpo()
          .copyWith(color: ColorTokens.textPrimary),
      cursorColor: palette.goldSoft,
      decoration: InputDecoration(
        hintText: 'Cerca un VIP per nome',
        hintStyle: TypographyTokens.corpo()
            .copyWith(color: ColorTokens.textSecondary),
        prefixIcon: Icon(Icons.search_rounded, color: palette.goldSoft),
        filled: true,
        fillColor: palette.surface.withValues(alpha: 0.4),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 0, horizontal: SpacingTokens.md),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
          borderSide: BorderSide(color: palette.gold.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
          borderSide: BorderSide(color: palette.gold.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
          borderSide: BorderSide(color: palette.goldSoft),
        ),
      ),
    );
  }
}

/// La riga dei filtri per categoria, con "Tutti" davanti.
class _FiltriCategoria extends StatelessWidget {
  const _FiltriCategoria({
    required this.categorie,
    required this.attiva,
    required this.palette,
    required this.onScegli,
  });

  final List<String> categorie;
  final String attiva;
  final MaestroPalette palette;
  final ValueChanged<String> onScegli;

  @override
  Widget build(BuildContext context) {
    // Un Wrap, non una lista orizzontale: tutte le categorie sono sempre a
    // vista, nessuna resta nascosta oltre il bordo.
    return Wrap(
      spacing: SpacingTokens.sm,
      runSpacing: SpacingTokens.sm,
      children: [
        for (final c in categorie)
          GestureDetector(
            key: Key('sinastria_filter_$c'),
            onTap: () => onScegli(c),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: SpacingTokens.md, vertical: SpacingTokens.xs),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
                color: c == attiva
                    ? palette.primary.withValues(alpha: 0.5)
                    : palette.surface.withValues(alpha: 0.35),
                border: Border.all(
                    color: c == attiva
                        ? palette.goldSoft
                        : palette.gold.withValues(alpha: 0.3),
                    width: c == attiva ? 1.5 : 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // **LA CATEGORIA E' UNA COSTELLAZIONE, ordine BO voce 05.**
                  // Non un'icona presa da un repertorio: un disegno di stelle
                  // che nasce dal NOME, quindi ogni categoria ha il suo e due
                  // categorie non possono averne uno uguale per distrazione.
                  SizedBox(
                    width: 22,
                    height: 22,
                    child: CustomPaint(
                      painter: CostellazioneDellaCategoria(
                        nome: c,
                        colore: c == attiva
                            ? palette.goldSoft
                            : palette.gold.withValues(alpha: 0.55),
                      ),
                    ),
                  ),
                  const SizedBox(width: SpacingTokens.xs),
                  Text(c,
                      style: TypographyTokens.label(size: 12).copyWith(
                          color: c == attiva
                              ? palette.goldSoft
                              : ColorTokens.textPrimary,
                          letterSpacing: 0.4)),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// La fascia "In evidenza": una selezione curata piu' il tasto "A caso".
class _InEvidenza extends StatelessWidget {
  const _InEvidenza({
    required this.palette,
    required this.onApri,
    required this.onACaso,
  });

  final MaestroPalette palette;
  final ValueChanged<Vip> onApri;
  final VoidCallback onACaso;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('In evidenza',
                  style: TypographyTokens.display(size: 18)
                      .copyWith(color: palette.goldSoft)),
            ),
            FilledButton.icon(
              key: const Key('sinastria_random'),
              onPressed: onACaso,
              style: FilledButton.styleFrom(
                  backgroundColor: palette.primary,
                  foregroundColor: palette.onPrimary,
                  padding: const EdgeInsets.symmetric(
                      horizontal: SpacingTokens.md, vertical: SpacingTokens.xs)),
              icon: const Icon(Icons.casino_rounded, size: 18),
              label: Text('A caso',
                  style: TypographyTokens.label(size: 12)
                      .copyWith(letterSpacing: 0.4)),
            ),
          ],
        ),
        const SizedBox(height: SpacingTokens.sm),
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: VipCatalog.inEvidenza.length,
            separatorBuilder: (_, __) => const SizedBox(width: SpacingTokens.md),
            itemBuilder: (context, i) {
              final vip = VipCatalog.inEvidenza[i];
              return SizedBox(
                width: 96,
                child: _VipTile(
                  key: Key('vip_evidenza_${vip.name}'),
                  vip: vip,
                  palette: palette,
                  onTap: () => onApri(vip),
                  compatta: true,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Una tessera VIP: il volto nella cornice, sotto il nome e il segno.
class _VipTile extends StatelessWidget {
  const _VipTile({
    super.key,
    required this.vip,
    required this.palette,
    required this.onTap,
    this.compatta = false,
  });

  final Vip vip;
  final MaestroPalette palette;
  final VoidCallback onTap;
  final bool compatta;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      palette.surfaceElevated.withValues(alpha: 0.7),
                      palette.deepest.withValues(alpha: 0.7),
                    ],
                  ),
                  border:
                      Border.all(color: palette.gold.withValues(alpha: 0.6)),
                ),
                clipBehavior: Clip.antiAlias,
                child: vip.hasImage
                    ? Image.asset(vip.thumbPath!,
                        // Un ritratto e' un soggetto: con cover il volto veniva
                        // tagliato dal riquadro. Trovato da una prova che
                        // enumera, non da una segnalazione.
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Icon(Icons.auto_awesome,
                            color: palette.goldSoft, size: 28))
                    : Icon(Icons.auto_awesome,
                        color: palette.goldSoft, size: 28),
              ),
            ),
          ),
          const SizedBox(height: SpacingTokens.xs),
          Text(vip.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TypographyTokens.display(size: compatta ? 12 : 13)
                  .copyWith(color: ColorTokens.textPrimary)),
          Text(vip.sign.italianName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TypographyTokens.etichetta()
                  .copyWith(color: palette.goldSoft, letterSpacing: 0.4)),
        ],
      ),
    );
  }
}
