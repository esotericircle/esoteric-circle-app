import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../sigilli/regia_del_cammino.dart';

import '../../core/astro/zodiac.dart';
import '../../core/maestro/maestro.dart';
import '../../core/synastry/vip_catalog.dart';
import '../../design_system/components/cosmos_background.dart';
import '../../design_system/components/vip_frame.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../core/identity/birth_identity.dart';
import '../../core/synastry/cielo_della_sinastria.dart';
import '../../core/synastry/gemello_astrale.dart';
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

  String _query = '';
  String _categoria = _tutti;

  /// **IL GEMELLO ASTRALE, ordine BO voce 10.** Si calcola al tocco e non
  /// all'apertura: cinquanta responsi costano poco, ma calcolarli per chi non
  /// li ha chiesti sarebbe lavoro buttato a ogni apertura della galleria.
  GemelloAstrale? _gemello;

  late final math.Random _rng = widget.random ?? math.Random();

  void _aCaso() {
    const vips = VipCatalog.vips;
    _apri(vips[_rng.nextInt(vips.length)]);
  }

  /// **SI SCEGLIE IL PRIMO VIP, non lo sceglie l'app.** Parole del fondatore
  /// del 28 agosto 2026: "il confronto tra 2 vip lo da' sempre con Angelina
  /// Jolie e non ha senso". Era vero e la causa stava in una riga: il
  /// pulsante chiamava `_sostituisciLaPrimaCasella(VipCatalog.first)`, cioe'
  /// il primo del catalogo, che e' Angelina Jolie. Adesso il tocco apre la
  /// SCELTA del primo, e la persona tocca la carta che vuole.
  bool _scegliIlPrimo = false;

  /// **DOVE COMINCIA LA LISTA**, per portarci lo sguardo dal segnaposto della
  /// carta da scegliere. Ordine BZ voce 09.
  final GlobalKey _inizioDellaLista = GlobalKey();

  Future<void> _portamiAllaLista() async {
    final ctx = _inizioDellaLista.currentContext;
    if (ctx == null) return;
    await Scrollable.ensureVisible(ctx,
        duration: const Duration(milliseconds: 400), alignment: 0.05);
  }

  /// Rimette il proprio cielo al posto del primo VIP: e' la via del ritorno
  /// che mancava del tutto.
  void _tornaATe() {
    if (widget.primoVip != null) {
      // Questa galleria e' la seconda, aperta sopra la prima: si torna
      // indietro, e sotto c'e' la galleria di se stessi.
      Navigator.of(context).maybePop();
      return;
    }
    setState(() => _scegliIlPrimo = false);
  }

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

  /// Cosa fa il tocco su una carta: aprire quel VIP, oppure sceglierlo come
  /// primo dei due quando la persona ha chiesto il confronto fra due VIP.
  void _tocca(Vip vip) {
    if (_scegliIlPrimo) {
      setState(() => _scegliIlPrimo = false);
      _sostituisciLaPrimaCasella(vip);
      return;
    }
    _apri(vip);
  }

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
                      // **LA SINASTRIA VIP PARTE DAL CONFRONTO. Ordine BZ
                      // voce 09.** Parole del fondatore: "LA SINASTRIA VIP
                      // DEVE PARTIRE con la schermata dove ci sono le 2 carte
                      // in alto dove l'utente puo' scegliere il VIP a destra e
                      // a sinistra c'e' la carta dell'utente con titolo sopra
                      // La Tua Compatibilita' con un VIP".
                      //
                      // Prima si apriva sulla ricerca e sulla tendina: chi
                      // entrava vedeva un catalogo e doveva capire da solo
                      // cosa ci si facesse. Adesso la prima cosa in scena e'
                      // il confronto, con la propria carta gia' al suo posto.
                      _IntestazioneDelConfronto(
                        palette: palette,
                        userSign: widget.userSign,
                        userName: widget.userName,
                        userBirth: widget.userBirth,
                        primoVip: widget.primoVip,
                        onScegli: _portamiAllaLista,
                      ),
                      const SizedBox(height: SpacingTokens.lg),
                      Row(
                        children: [
                          Expanded(
                            child: _BarraRicerca(
                              controller: _ricerca,
                              palette: palette,
                              onCambia: (v) => setState(() => _query = v),
                            ),
                          ),
                          // **IL VIP A CASO RESTA, e cambia posto.** Viveva
                          // dentro la sezione "VIP in evidenza" che il
                          // fondatore ha fatto togliere: la sezione se ne va,
                          // la funzione no, perche' toglierla non gliel'ha
                          // chiesto nessuno.
                          IconButton(
                            key: const Key('sinastria_random'),
                            onPressed: _aCaso,
                            tooltip: 'Un VIP a caso',
                            icon: Icon(Icons.casino_rounded,
                                color: palette.goldSoft),
                          ),
                        ],
                      ),
                      const SizedBox(height: SpacingTokens.md),
                      // **UNA TENDINA SOLA AL POSTO DELLA FILA DI PULSANTI.**
                      // Parole del fondatore del 28 agosto 2026: "anziche'
                      // usare un pulsante per ogni categoria, usa un unico
                      // selettore menu' a tendina Categoria VIP con tutte le
                      // opzioni". La fila scorreva e le categorie in fondo non
                      // si vedevano; la tendina le mostra tutte in una volta.
                      _TendinaDelleCategorie(
                        categorie: categorie,
                        attiva: _categoria,
                        palette: palette,
                        onScegli: (c) => setState(() => _categoria = c),
                      ),
                      const SizedBox(height: SpacingTokens.lg),
                      // **VIA LA SEZIONE "VIP IN EVIDENZA".** Parole del
                      // fondatore: "elimina la sezione Vip in evidenza che non
                      // serve a nulla". Prendeva l'altezza di una schermata
                      // sopra la galleria vera.
                      // **LE DUE PORTE CHE DEVONO RISALTARE.** Parole del
                      // fondatore del 28 agosto 2026: il gemello astrale "e'
                      // una funzione potenzialmente virale e deve risaltare",
                      // e il confronto fra due VIP "deve essere anche una
                      // funzione ben visibile". Erano due righe di testo con
                      // un'iconcina, in fondo a una colonna: adesso sono due
                      // porte alte, col fondo del Maestro e il bordo d'oro.
                      if (_gemello == null)
                        _PortaGrande(
                          chiave: const Key('sinastria_cerca_gemello'),
                          titolo: 'Trova il tuo gemello astrale VIP',
                          sotto: 'Il volto famoso che porta il tuo stesso '
                              'cielo',
                          icona: Icons.auto_awesome,
                          palette: palette,
                          onTocco: _cercaIlGemello,
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
                      if (widget.primoVip == null && !_scegliIlPrimo)
                        _PortaGrande(
                          chiave: const Key('sinastria_due_vip'),
                          titolo: 'Confronta 2 VIP',
                          sotto: 'Scegli tu i due volti da mettere uno '
                              'contro l\'altro',
                          icona: Icons.compare_arrows_rounded,
                          palette: palette,
                          onTocco: () =>
                              setState(() => _scegliIlPrimo = true),
                        ),
                      // **E LA VIA DEL RITORNO A SE STESSI.** Domanda del
                      // fondatore: "quando l'utente e' in modalita' confronto
                      // tra 2 VIP, come fa a tornare a mettere se stesso?".
                      // Non poteva: la seconda galleria si apriva col primo
                      // VIP gia' fissato e nessuna riga tornava indietro.
                      if (widget.primoVip != null || _scegliIlPrimo)
                        _PortaGrande(
                          chiave: const Key('sinastria_torna_a_te'),
                          titolo: 'Torna a te',
                          sotto: 'Rimetti il tuo cielo al posto del primo '
                              'VIP',
                          icona: Icons.person_rounded,
                          palette: palette,
                          onTocco: _tornaATe,
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
                          key: _inizioDellaLista,
                          _scegliIlPrimo
                              ? 'Scegli il primo dei due VIP'
                              : widget.primoVip == null
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
                // **LA GRIGLIA ORDINATA TORNA, e SOSTITUISCE il cielo dei
                // volti dell'ordine BO voce 05.** Parole del fondatore del 28
                // agosto 2026: "la visualizzazione dei vip come le carte
                // mischiate senza ordine e con dimensioni diverse non va bene,
                // non si vedono i nomi dei vip, ma non si riconoscono nemmeno
                // i volti". Erano tutte e due vere: i ritratti stavano su tre
                // piani di profondita', quindi tre misure diverse, e il nome
                // scendeva fino al 55 per cento di opacita' sul piano piu'
                // lontano.
                //
                // Qui i ritratti hanno la STESSA misura, stanno in fila e
                // ognuno porta il suo nome pieno sotto.
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(SpacingTokens.lg, 0,
                      SpacingTokens.lg, SpacingTokens.xxxl),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      // **PIU' GRANDI, ordine BZ voce 09.** Parole del
                      // fondatore: "l'elenco delle carte adesso sono in
                      // ordine, ma andrebbero un po' ingrandite". Con 132 di
                      // massimo, su uno schermo da 360 ci stavano TRE colonne
                      // e ogni ritratto usciva a 101 punti; con 168 le colonne
                      // diventano due e il ritratto passa a 152, cioe' meta'
                      // piu' grande. Il numero da cambiare era questo, non la
                      // spaziatura: e' il conto delle colonne a decidere la
                      // misura.
                      maxCrossAxisExtent: 168,
                      mainAxisSpacing: SpacingTokens.md,
                      crossAxisSpacing: SpacingTokens.sm,
                      childAspectRatio: 0.72,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => _CartaDelVip(
                        vip: filtrati[i],
                        palette: palette,
                        onTocco: () => _tocca(filtrati[i]),
                      ),
                      childCount: filtrati.length,
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

/// LE DUE CARTE IN CIMA, E IL TITOLO SOPRA DI LORO. Ordine BZ voce 09.
///
/// **Parole del fondatore:** "LA SINASTRIA VIP DEVE PARTIRE con la schermata
/// dove ci sono le 2 carte in alto dove l'utente puo' scegliere il VIP a
/// destra e a sinistra c'e' la carta dell'utente con titolo sopra La Tua
/// Compatibilità con un VIP".
///
/// **La carta di destra e' un segnaposto e lo dichiara**: non porta un VIP
/// scelto dall'app, perche' l'app che sceglie per te e' esattamente il difetto
/// del confronto che dava sempre Angelina Jolie. Al tocco porta l'occhio alla
/// lista, che e' dove si sceglie.
///
/// **LE DUE FUNZIONI VIRALI RESTANO DOVE ERANO**, cioe' subito sotto questa
/// intestazione: "Trova il tuo gemello astrale VIP" e "Confronta 2 VIP" sono
/// le due porte grandi, e nessuna delle due si e' mossa.
class _IntestazioneDelConfronto extends StatelessWidget {
  const _IntestazioneDelConfronto({
    required this.palette,
    required this.onScegli,
    this.userSign,
    this.userName,
    this.userBirth,
    this.primoVip,
  });

  final MaestroPalette palette;
  final VoidCallback onScegli;
  final Zodiac? userSign;
  final String? userName;
  final DateTime? userBirth;
  final Vip? primoVip;

  String get _dataTua {
    final d = userBirth;
    if (d == null) return '';
    return '${d.day}.${d.month}.${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    // Col primo VIP scelto il titolo dice l'altra cosa vera: non e' piu' la
    // TUA compatibilità, sono due volti messi uno contro l'altro.
    final titolo = primoVip == null
        ? 'La Tua Compatibilità con un VIP'
        : 'La Compatibilità fra ${primoVip!.name} e un VIP';
    return Column(
      children: [
        Text(
          titolo,
          key: const Key('sinastria_titolo_confronto'),
          textAlign: TextAlign.center,
          style: TypographyTokens.display(size: 20)
              .copyWith(color: palette.goldSoft, height: 1.2),
        ),
        const SizedBox(height: SpacingTokens.md),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  primoVip == null
                      ? VipFramedPortrait(
                          key: const Key('sinastria_carta_tua'),
                          palette: palette,
                          name: userName ?? 'Il tuo cielo',
                          date: _dataTua,
                          sign: userSign?.symbol,
                        )
                      : VipFramedPortrait(
                          key: const Key('sinastria_carta_tua'),
                          palette: palette,
                          name: primoVip!.name,
                          date: primoVip!.note,
                          sign: primoVip!.sign.symbol,
                          vipAsset: primoVip!.fullPath,
                        ),
                  const SizedBox(height: SpacingTokens.xs),
                  Text(
                    primoVip == null ? 'Tu' : primoVip!.name,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TypographyTokens.etichetta()
                        .copyWith(color: palette.goldSoft),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 64),
              child: Icon(Icons.favorite_rounded,
                  color: palette.goldSoft, size: 24),
            ),
            Expanded(
              child: GestureDetector(
                key: const Key('sinastria_carta_da_scegliere'),
                onTap: onScegli,
                behavior: HitTestBehavior.opaque,
                child: Column(
                  children: [
                    VipFramedPortrait(
                      palette: palette,
                      name: 'Scegli il VIP',
                      date: '',
                      sign: '?',
                    ),
                    const SizedBox(height: SpacingTokens.xs),
                    Text(
                      'Scegli il VIP',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TypographyTokens.etichetta()
                          .copyWith(color: ColorTokens.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
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




/// LA TENDINA DELLE CATEGORIE, una sola al posto della fila di pulsanti.
///
/// **Parole del fondatore del 28 agosto 2026**: "anziche' usare un pulsante
/// per ogni categoria, usa un unico selettore menu' a tendina Categoria VIP
/// con tutte le opzioni". La fila di prima scorreva in orizzontale, quindi le
/// categorie oltre la terza esistevano solo per chi si accorgeva di poterla
/// trascinare.
class _TendinaDelleCategorie extends StatelessWidget {
  const _TendinaDelleCategorie({
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
    return Container(
      key: const Key('sinastria_categoria'),
      padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.md, vertical: SpacingTokens.xxs),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
        color: palette.deepest.withValues(alpha: 0.55),
        border: Border.all(color: palette.gold.withValues(alpha: 0.45)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: attiva,
          isExpanded: true,
          dropdownColor: palette.surfaceElevated,
          borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
          icon: Icon(Icons.arrow_drop_down_rounded, color: palette.goldSoft),
          style: TypographyTokens.didascalia()
              .copyWith(color: ColorTokens.textPrimary),
          // L'etichetta sta DENTRO la tendina chiusa, sopra il valore: chi la
          // guarda deve sapere cosa sta scegliendo prima di aprirla.
          selectedItemBuilder: (context) => [
            for (final c in categorie)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('CATEGORIA VIP',
                      style: TypographyTokens.etichetta().copyWith(
                          color: palette.goldSoft, letterSpacing: 0.8)),
                  Text(c,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TypographyTokens.didascalia()
                          .copyWith(color: ColorTokens.textPrimary)),
                ],
              ),
          ],
          items: [
            for (final c in categorie)
              DropdownMenuItem<String>(
                value: c,
                key: Key('sinastria_categoria_$c'),
                child: Text(c,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TypographyTokens.didascalia().copyWith(
                        color: c == attiva
                            ? palette.goldSoft
                            : ColorTokens.textPrimary)),
              ),
          ],
          onChanged: (c) {
            if (c != null) onScegli(c);
          },
        ),
      ),
    );
  }
}

/// UNA PORTA CHE SI VEDE: titolo grande, una riga di spiegazione, il fondo del
/// Maestro e il bordo d'oro.
///
/// **Parole del fondatore del 28 agosto 2026**: il gemello astrale "e' una
/// funzione potenzialmente virale e deve risaltare", e il confronto fra due
/// VIP "deve essere anche una funzione ben visibile". Erano due `TextButton`
/// con un'icona da diciotto punti.
class _PortaGrande extends StatelessWidget {
  const _PortaGrande({
    required this.chiave,
    required this.titolo,
    required this.sotto,
    required this.icona,
    required this.palette,
    required this.onTocco,
  });

  final Key chiave;
  final String titolo;
  final String sotto;
  final IconData icona;
  final MaestroPalette palette;
  final VoidCallback onTocco;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: chiave,
          onTap: onTocco,
          borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.md, vertical: SpacingTokens.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
              color: palette.surfaceElevated.withValues(alpha: 0.85),
              border: Border.all(color: palette.gold, width: 1.5),
            ),
            child: Row(
              children: [
                Icon(icona, size: 28, color: palette.goldSoft),
                const SizedBox(width: SpacingTokens.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(titolo,
                          style: TypographyTokens.titoloScheda()
                              .copyWith(color: palette.goldSoft)),
                      const SizedBox(height: 2),
                      Text(sotto,
                          style: TypographyTokens.didascalia()
                              .copyWith(color: ColorTokens.textPrimary)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: palette.goldSoft, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// LA CARTA DI UN VIP NELLA GRIGLIA: stessa misura per tutti, nome leggibile.
///
/// **Parole del fondatore del 28 agosto 2026**: "la visualizzazione dei vip
/// come le carte mischiate senza ordine e con dimensioni diverse non va bene,
/// non si vedono i nomi dei vip, ma non si riconoscono nemmeno i volti".
class _CartaDelVip extends StatelessWidget {
  const _CartaDelVip({
    required this.vip,
    required this.palette,
    required this.onTocco,
  });

  final Vip vip;
  final MaestroPalette palette;
  final VoidCallback onTocco;

  /// Due righe del ruolo didascalia con interlinea 1,15: il nome piu' lungo
  /// e quello piu' corto occupano lo stesso posto, e i volti restano in fila.
  ///
  /// **Trentotto e non trentadue, e la differenza si vedeva.** Il ruolo vale
  /// sedici punti e l'interlinea 1,15, quindi due righe ne chiedono 36,8:
  /// con trentadue la seconda riga di "Chiara Ferragni" e "Leonardo
  /// DiCaprio" restava tagliata a meta' altezza. Il numero viene dal conto,
  /// non dall'occhio, ma e' stato l'occhio a chiederlo.
  static const double _altezzaDelNome = 38;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: Key('vip_${vip.name}'),
      onTap: onTocco,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
                border:
                    Border.all(color: palette.gold.withValues(alpha: 0.45)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
                child: vip.thumbPath != null
                    // La miniatura e non il ritratto pieno: cinquanta ritratti
                    // interi in scena sarebbero un ordine di grandezza di
                    // memoria in piu'.
                    // **INTERA, non adattata al riempimento.** La cornice
                    // di questi ritratti e' arte, e `cover` le tagliava i
                    // bordi: la guardia delle miniature intere lo ha visto,
                    // ed e' la stessa regola che vale per angeli, animali e
                    // tarocchi.
                    ? Image.asset(vip.thumbPath!,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Icon(Icons.auto_awesome,
                            color: palette.goldSoft, size: 24))
                    : Icon(Icons.auto_awesome,
                        color: palette.goldSoft, size: 24),
              ),
            ),
          ),
          const SizedBox(height: SpacingTokens.xxs),
          // **IL NOME A PIENO CONTRASTO**, non al cinquantacinque per cento:
          // era quello il motivo per cui non si leggeva.
          //
          // **E L'ALTEZZA E' FISSA, DUE RIGHE SEMPRE.** Ordine BX voce 06,
          // trovato guardando l'anteprima: col nome libero di stare su una
          // riga o su due, il ritratto sopra prendeva cio' che restava, e
          // "Brad Pitt" veniva piu' alto di "Chiara Ferragni" nella stessa
          // riga della griglia. Il fondatore aveva gia' fermato una galleria
          // per lo stesso motivo, "carte mischiate senza ordine": due nomi
          // di lunghezza diversa non devono spostare i volti.
          SizedBox(
            height: _altezzaDelNome,
            child: Text(
              vip.name,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TypographyTokens.didascalia()
                  .copyWith(color: ColorTokens.textPrimary, height: 1.15),
            ),
          ),
        ],
      ),
    );
  }
}
