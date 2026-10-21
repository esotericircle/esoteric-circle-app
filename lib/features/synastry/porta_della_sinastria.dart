import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/astro/zodiac.dart';
import '../../core/maestro/maestro.dart';
import '../../core/synastry/vip_catalog.dart';
import '../../design_system/components/vip_frame.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../design_system/components/titolo_che_non_si_rompe.dart';
import '../maestri/rotta_arte.dart';
import '../scene/la_scena_in_video.dart';
import 'il_foglio_del_tuo_volto.dart';
import 'schermata_del_gemello.dart';
import 'sinastria_gallery_screen.dart';
import 'sinastria_vip_screen.dart';
import 'user_photo.dart';
import '../../design_system/transizioni/passaggio_del_cerchio.dart';
import '../../core/entitlement/budget_del_giorno.dart';
import '../../design_system/components/riga_del_residuo.dart';

/// LA PORTA DELLA SINASTRIA VIP. Ordine CA voce 01.
///
/// **Parole del fondatore:** "LA SINASTRIA VIP DEVE PARTIRE con la schermata
/// dove ci sono le 2 carte in alto dove l'utente puo' scegliere il VIP a destra
/// e a sinistra c'e' la carta dell'utente con titolo sopra La Tua
/// Compatibilita' con un VIP", e "le bolle di fai sinastria vip oppure calcola
/// il tuo gemello astrale VIP devono stare nella prima schermata che vede
/// l'utente e non nella schermata di scelta del vip".
///
/// **Cosa c'era prima.** L'arte apriva sulla galleria "Scegli il tuo VIP", e le
/// tre scelte vivevano dentro di lei, sopra il catalogo: chi entrava vedeva un
/// elenco di volti e doveva capire da solo cosa ci si facesse. La voce BZ.09
/// aveva messo le due carte in cima alla galleria; quest'ordine le sposta dove
/// vanno, cioe' in una schermata loro, e la galleria torna a fare una cosa
/// sola: scegliere un volto e restituirlo.
///
/// **LE TRE SCELTE STANNO IN FILA, E LA SCELTA E' DICHIARATA.** L'ordine lascia
/// a me la forma e chiede di dichiararla: il fondatore aveva proposto una
/// tendina "Scegli il tipo di sinastria", l'Architetto le tre voci visibili
/// tutte insieme. **Ho scelto la fila**, con la ragione dell'Architetto, che e'
/// misurabile: il gemello astrale non chiede di scegliere nessuno ed e' la
/// funzione piu' condivisibile dell'app; dietro una tendina costerebbe due
/// gesti e una parola che non promette niente, e una funzione virale che
/// chiede due gesti non e' piu' virale.
///
/// **Si rovescia con una riga**: [leTreScelteInFila] a falso e le stesse tre
/// voci diventano la tendina che il fondatore aveva in mente. Le due forme
/// vivono qui sotto, e nessuna delle due e' scritta due volte: leggono lo
/// stesso elenco.
class PortaDellaSinastria extends StatefulWidget {
  const PortaDellaSinastria({
    super.key,
    this.userSign,
    this.userName,
    this.userBirth,
    this.servizioDelleFoto,
    this.fabbricaDellaScena,
  });

  final Zodiac? userSign;
  final String? userName;
  final DateTime? userBirth;

  /// Da dove arriva la foto della persona: nelle prove una finta, in
  /// produzione la fotocamera e la galleria del telefono.
  final UserPhotoService? servizioDelleFoto;

  /// Il lettore del Sipario delle Stelle: nelle prove una finta, in
  /// produzione il video vero ([IlPalcoDellaSinastriaVip.filmato]).
  final FabbricaDiScena? fabbricaDellaScena;

  /// **LA RIGA CHE ROVESCIA LA FORMA DELLE TRE SCELTE.** Vera: tre porte in
  /// fila, tutte visibili. Falsa: una tendina sola, "Scegli il tipo di
  /// sinastria", come il fondatore aveva proposto.
  static const bool leTreScelteInFila = true;

  static Route<void> route({
    Zodiac? userSign,
    String? userName,
    DateTime? userBirth,
  }) {
    return PassaggioDelCerchio.rotta<void>((_) => SogliaArte(
          id: 'synastry_vip',
          maestro: Maestro.medora,
          child: PortaDellaSinastria(
            userSign: userSign,
            userName: userName,
            userBirth: userBirth,
          ),
        ));
  }

  @override
  State<PortaDellaSinastria> createState() => _PortaDellaSinastriaState();
}

/// I tre modi di fare una sinastria, in un elenco solo: le due forme della
/// schermata lo leggono, e aggiungerne un quarto non chiede di toccare
/// nessuna delle due.
enum ModoDellaSinastria {
  conUnVip(
    'Sinastria con un VIP',
    'Il tuo cielo contro quello di un volto famoso',
    Icons.favorite_rounded,
  ),
  fraDueVip(
    'Confronta 2 VIP',
    'Scegli tu i due volti da mettere uno contro l\'altro',
    Icons.compare_arrows_rounded,
  ),
  gemelloAstrale(
    'Trova il tuo gemello astrale VIP',
    'Il volto famoso che porta il tuo stesso cielo',
    Icons.auto_awesome,
  );

  const ModoDellaSinastria(this.titolo, this.sotto, this.icona);

  final String titolo;
  final String sotto;
  final IconData icona;

  String get chiave => 'sinastria_modo_$name';
}

/// **IL SIPARIO DELLE STELLE, LA GEOMETRIA DEL PALCO.** Ordine FU voce
/// FU.14, 15 ottobre 2026. Il fondatore: *"Si le lasciamo sotto come alone.
/// I volti all'interno delle carte sono già piccoli e servono carte più
/// grandi possibili"*.
///
/// All'apertura della porta Medora apre il sipario, si scioglie in polvere
/// d'oro e due fasci di luce disegnano due cornici col cuore in mezzo.
/// L'ultimo fotogramma resta come sfondo della porta, e le due carte si
/// posano sulle due cornici, centrate su di esse.
///
/// **LE MISURE STANNO NEL FOTOGRAMMA, IN PIXEL DEL VIDEO** (1080 per 1920),
/// prese con Python sul bordo acceso delle cornici di
/// `vip_ultimo_fotogramma_v1.webp` (luminanza sopra 200 a meta' altezza e
/// lungo la colonna del 30 per cento): sinistra da 167 a 465, destra da 614 a
/// 912, tutte e due da 736 a 1232; il cuore dipinto ha il centro a 541, 961.
/// Le prove in `docs/collaudo/FU/fu14_scena_vip.txt`.
///
/// **IL TAGLIO DEL VIDEO SULLO SCHERMO E' `BoxFit.cover` CENTRATO**, quello
/// del lettore comune (`LettoreDiScena.disegna`) e dell'immagine ferma qui
/// sotto: il video 9:16 riempie la schermata, e su un telefono piu' alto di
/// 9:16 perde due strisce uguali a destra e a sinistra. [sulloSchermo]
/// rifa' lo stesso conto, cosi' le carte cadono sulle cornici a ogni misura.
class IlPalcoDellaSinastriaVip {
  IlPalcoDellaSinastriaVip._();

  static const String filmato =
      'brand_assets/vip_scena/medora_sipario_delle_stelle_v1.mp4';
  static const String ultimoFotogramma =
      'assets/img/vip_scena/vip_ultimo_fotogramma_v1.webp';

  /// Il sipario chiuso, cio' che si vede mentre il video si prepara.
  static const String primoFotogramma =
      'assets/img/vip_scena/vip_primo_fotogramma_v1.webp';

  static const Size video = Size(1080, 1920);
  static const Rect corniceSinistra = Rect.fromLTRB(167, 736, 465, 1232);
  static const Rect corniceDestra = Rect.fromLTRB(614, 736, 912, 1232);
  static const Offset cuoreDipinto = Offset(541, 961);

  /// Il cuore dell'interfaccia, la stessa icona di prima, posata sul cuore
  /// dipinto.
  static const double cuore = 24;

  /// Quanto le carte restano lontane dal cuore e dai bordi: il minimo che
  /// si vede, perche' le carte devono essere piu' grandi possibile.
  static const double distacco = SpacingTokens.xxs;

  /// Quanto spazio il titolo e la riga del residuo chiedono sotto la barra:
  /// la carta non sale oltre.
  static const double spazioDelTitolo = 96;

  /// **IL PALCO NON SI ALLUNGA OLTRE IL 40 PER CENTO DEL 9:16.** Sui
  /// telefoni veri lo schermo e' alto da 1,2 a 1,3 volte il 9:16 della sua
  /// larghezza (360 per 797 fa 1,25), e il palco e' lo schermo intero. Su
  /// una finestra molto piu' alta (le prove montano la porta anche a 360 per
  /// 3200) il taglio cover allargherebbe il video fino a portare le cornici
  /// fuori dallo schermo: li' il palco resta alto al massimo 1,4 volte il
  /// 9:16, in cima, e sotto continua il nero del pavimento.
  static const double allungamentoMassimo = 1.4;

  /// Il riquadro del palco, in cima alla schermata: dove stanno il video e
  /// il suo ultimo fotogramma.
  static Size palco(Size schermo) => Size(
      schermo.width,
      math.min(schermo.height,
          schermo.width * video.height / video.width * allungamentoMassimo));

  static double scala(Size schermo) {
    final p = palco(schermo);
    return math.max(p.width / video.width, p.height / video.height);
  }

  static Offset _punto(Offset p, Size schermo) {
    final k = scala(schermo);
    final r = palco(schermo);
    return Offset((r.width - video.width * k) / 2 + p.dx * k,
        (r.height - video.height * k) / 2 + p.dy * k);
  }

  /// Un rettangolo del fotogramma, nei punti dello schermo.
  static Rect sulloSchermo(Rect nelVideo, Size schermo) => Rect.fromPoints(
      _punto(nelVideo.topLeft, schermo), _punto(nelVideo.bottomRight, schermo));

  static Offset cuoreSulloSchermo(Size schermo) =>
      _punto(cuoreDipinto, schermo);

  /// **LA LARGHEZZA DELLE CARTE, LA PIU' GRANDE CHE LO SCHERMO CONSENTE.**
  /// Ogni carta e' centrata sulla sua cornice; cresce finche' non tocca il
  /// bordo dello schermo, il cuore fra le due o, in alto, lo spazio del
  /// titolo che comincia a [cimaDelTitolo]. Vince il limite piu' stretto.
  static double larghezzaDelleCarte(Size schermo,
      {required double cimaDelTitolo}) {
    final s = sulloSchermo(corniceSinistra, schermo).center;
    final d = sulloSchermo(corniceDestra, schermo).center;
    final c = cuoreSulloSchermo(schermo);
    final cimaLibera = cimaDelTitolo + spazioDelTitolo;
    final limite = [
      2 * (s.dx - distacco),
      2 * (schermo.width - distacco - d.dx),
      2 * (c.dx - cuore / 2 - distacco - s.dx),
      2 * (d.dx - (c.dx + cuore / 2 + distacco)),
      // Le carte hanno il centro all'altezza del cuore (FY.12).
      2 * (c.dy - cimaLibera) * VipFrame.aspect,
    ].reduce(math.min);
    // Una finestra impossibile (una barra enorme, uno schermo minuscolo)
    // non deve dare una carta di larghezza negativa.
    return math.max(limite, cartaMinima);
  }

  /// Sotto questa larghezza la carta non scende mai.
  static const double cartaMinima = 64;
}

class _PortaDellaSinastriaState extends State<PortaDellaSinastria> {
  /// La prima casella: nulla vuol dire "sei tu", che e' il modo predefinito.
  Vip? _primo;

  /// La seconda casella, sempre un VIP, finche' non si sceglie e' vuota.
  Vip? _secondo;

  ModoDellaSinastria _modo = ModoDellaSinastria.conUnVip;

  /// Il volto della persona nella sua carta: la foto del profilo, oppure
  /// nulla, cioe' l'avatar a costellazione. Ordine ER voce 04.
  late final UserPhotoController _foto =
      UserPhotoController(service: widget.servizioDelleFoto);
  bool _fotoDalProfilo = false;

  MaestroPalette get _palette =>
      MaestroPalette.forKey(const ThemeKey.of(Maestro.medora));

  /// **IL SIPARIO DELLE STELLE**, ordine FU voce FU.14: la regia comune
  /// delle scene, una per apertura della porta.
  late final RegiaDellaScena _regia;

  @override
  void initState() {
    super.initState();
    _foto.addListener(_fotoCambiata);
    _regia = RegiaDellaScena(widget.fabbricaDellaScena ??
        () => LettoreDiScena.vero(IlPalcoDellaSinastriaVip.filmato));
    _regia.addListener(_scenaCambiata);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Il video parte una volta per apertura: la regia lo sa da se'.
    unawaited(_regia.avvia(context));
    if (_fotoDalProfilo) return;
    _fotoDalProfilo = true;
    _foto.seed(IlFoglioDelTuoVolto.profiloDi(context)?.avatarPhoto);
  }

  @override
  void dispose() {
    _regia.removeListener(_scenaCambiata);
    _regia.dispose();
    _foto.removeListener(_fotoCambiata);
    _foto.dispose();
    super.dispose();
  }

  void _fotoCambiata() {
    if (mounted) setState(() {});
  }

  void _scenaCambiata() {
    if (mounted) setState(() {});
  }

  /// **LA CARTA "TU" APRE IL TUO VOLTO, NON UN VIP.** Ordine ER voce 04.
  /// Quando nella prima casella c'e' un VIP (il confronto fra due VIP,
  /// ordine BO voce 13) la carta e' la sua, e il tocco cambia quel VIP.
  Future<void> _toccaLaPrimaCarta() async {
    if (_primo != null) {
      await _scegli(perLaPrima: true);
      return;
    }
    await IlFoglioDelTuoVolto.scegliERicorda(context,
        palette: _palette, foto: _foto);
  }

  /// Apre la galleria perche' scelga un volto e lo RIPORTI indietro.
  ///
  /// **La galleria non apre piu' il responso da sola** quando la si chiama
  /// cosi': era quello il modo in cui la carta toccata e la carta cambiata
  /// potevano essere due carte diverse (voce CA.02). Qui chi chiede sa quale
  /// casella sta riempiendo, e la riempie lui.
  Future<void> _scegli({required bool perLaPrima}) async {
    final scelto = await Navigator.of(context).push<Vip>(
      SinastriaGalleryScreen.scegliUnVip(
        userSign: widget.userSign,
        userName: widget.userName,
        userBirth: widget.userBirth,
        titolo: perLaPrima
            ? 'Scegli il primo dei due VIP'
            : 'Scegli il VIP da confrontare',
      ),
    );
    if (scelto == null || !mounted) return;
    setState(() {
      if (perLaPrima) {
        _primo = scelto;
        _modo = ModoDellaSinastria.fraDueVip;
      } else {
        _secondo = scelto;
      }
    });
  }

  void _tornaATe() => setState(() {
        _primo = null;
        _modo = ModoDellaSinastria.conUnVip;
      });

  Future<void> _apriIlResponso() async {
    final secondo = _secondo;
    if (secondo == null) {
      await _scegli(perLaPrima: false);
      return;
    }
    if (!mounted) return;
    await Navigator.of(context).push(SinastriaVipScreen.route(
      vip: secondo,
      primoVip: _primo,
      userSign: widget.userSign,
      userName: widget.userName,
      userBirth: widget.userBirth,
    ));
    // Nel responso la persona puo' aver cambiato la foto: la porta la
    // rilegge dal profilo, che e' il posto dove la scelta si scrive.
    if (!mounted) return;
    final profilo = IlFoglioDelTuoVolto.profiloDi(context);
    if (profilo != null) _foto.allinea(profilo.avatarPhoto);
  }

  Future<void> _scegliIlModo(ModoDellaSinastria modo) async {
    switch (modo) {
      case ModoDellaSinastria.conUnVip:
        setState(() {
          _primo = null;
          _modo = modo;
        });
        await _scegli(perLaPrima: false);
      case ModoDellaSinastria.fraDueVip:
        setState(() => _modo = modo);
        await _scegli(perLaPrima: true);
      case ModoDellaSinastria.gemelloAstrale:
        setState(() => _modo = modo);
        // **IL GEMELLO HA UNA SCHERMATA SOLA.** Ordine ER voce 06: qui si
        // apriva la galleria dei VIP, col titolo "Scegli il tuo VIP", la
        // ricerca, la categoria e l'elenco, e il responso arrivava solo
        // toccando la carta del gemello. Adesso si apre la schermata del
        // Gemello, che fa tutto da se'.
        await Navigator.of(context).push(SchermataDelGemello.perLaPersona(
          userSign: widget.userSign,
          userName: widget.userName,
          userBirth: widget.userBirth,
        ));
    }
  }

  String get _dataTua {
    final d = widget.userBirth;
    if (d == null) return '';
    return '${d.day}.${d.month}.${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final palette = _palette;
    // IL TOCCO CHE SALTA IL VIDEO, ordine FU voce FU.15, punto unico: avvolge
    // tutta la schermata, e mentre il Sipario delle Stelle gira prende ogni
    // tocco senza farlo arrivare ai pulsanti.
    return IlToccoCheSalta(
      inCorso: _regia.inCorso,
      onSalta: _regia.salta,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: palette.deepest.withValues(alpha: 0.35),
          elevation: 0,
          scrolledUnderElevation: 0,
          // Nessuna tinta di superficie, in nessuno stato (FY.20).
          surfaceTintColor: Colors.transparent,
          centerTitle: true,
          iconTheme: IconThemeData(color: palette.goldSoft),
          // **NESSUNA MISURA SCRITTA A MANO**, che sarebbe debito: il titolo
          // della barra prende il ruolo del titolo di sezione, e la misura la
          // decide il design system.
          title: TitoloCheNonSiRompe(
              testo: 'Sinastria VIP', stile: TypographyTokens.titoloSezione()),
          actions: const [AngoloDellaBarra()],
        ),
        body: LayoutBuilder(
          // I margini si leggono dal corpo della pagina, dove la barra li ha
          // gia' messi: il titolo resta dove era prima dell'ordine FU.
          builder: (corpo, vincoli) =>
              _ilPalco(palette, vincoli.biggest, MediaQuery.paddingOf(corpo)),
        ),
      ),
    );
  }

  /// **IL PALCO**, ordine FU voce FU.14. Sotto, il fotogramma fermo del
  /// sipario; sopra, finche' gira, il video a schermo intero; e l'interfaccia
  /// di prima, che compare in dissolvenza quando il video finisce o si salta,
  /// e subito quando la scena e' ferma (Riduci Movimento, grafica
  /// alleggerita, video che non si carica).
  ///
  /// **LO SFONDO SCORRE INSIEME ALLE CARTE.** Il fotogramma e' fermo, ma sta
  /// dentro lo scorrimento: sotto le carte ci sono il pulsante e le tre
  /// scelte, che a 360 per 797 non stanno tutte nella prima schermata, e uno
  /// sfondo inchiodato lascerebbe le cornici dove sono mentre le carte
  /// salgono. Cosi' le carte non lasciano mai le loro cornici; sotto il
  /// fotogramma continua il nero del suo pavimento.
  Widget _ilPalco(MaestroPalette palette, Size schermo, EdgeInsets margini) {
    final interfaccia = _regia.ferma;
    // Prima che il video cominci si vede il suo primo fotogramma, il sipario
    // chiuso, e non l'ultimo, che sveglierebbe la scena prima del tempo.
    final fondo = interfaccia || _regia.filmatoInScena
        ? IlPalcoDellaSinastriaVip.ultimoFotogramma
        : IlPalcoDellaSinastriaVip.primoFotogramma;
    return Stack(
      fit: StackFit.expand,
      children: [
        SingleChildScrollView(
          key: const Key('sinastria_porta'),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: schermo.height),
            child: Stack(
              children: [
                const Positioned.fill(
                  child: ColoredBox(color: Color(0xFF000000)),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: IlPalcoDellaSinastriaVip.palco(schermo).height,
                  child: Image.asset(
                    fondo,
                    key: const Key('sinastria_vip_sfondo'),
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                  ),
                ),
                if (interfaccia)
                  LaScenaFermaCheAppare(
                    appare: _regia.filmatoInScena || _regia.saltata,
                    child: _interfaccia(palette, schermo, margini),
                  )
                else
                  SizedBox(width: schermo.width, height: schermo.height),
              ],
            ),
          ),
        ),
        if (_regia.filmatoInScena)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: IlPalcoDellaSinastriaVip.palco(schermo).height,
            child: IlFilmatoCheSfuma(
              key: const Key('sinastria_vip_filmato'),
              saltato: _regia.ferma,
              child: _regia.disegna(),
            ),
          ),
      ],
    );
  }

  /// L'interfaccia di prima, coi suoi testi e i suoi pulsanti; cambiano solo
  /// il posto e la grandezza delle due carte (R10 dell'ordine FU).
  Widget _interfaccia(
      MaestroPalette palette, Size schermo, EdgeInsets margini) {
    final cimaDelTitolo = margini.top + kToolbarHeight;
    final larga = IlPalcoDellaSinastriaVip.larghezzaDelleCarte(schermo,
        cimaDelTitolo: cimaDelTitolo);
    final alta = larga / VipFrame.aspect;
    final sinistra = IlPalcoDellaSinastriaVip.sulloSchermo(
            IlPalcoDellaSinastriaVip.corniceSinistra, schermo)
        .center;
    final destra = IlPalcoDellaSinastriaVip.sulloSchermo(
            IlPalcoDellaSinastriaVip.corniceDestra, schermo)
        .center;
    // **IL CUORE A META' FRA LE DUE CARTE**, ordine FY voce FY.12, 16
    // ottobre 2026. Il fondatore: *"Sinastria VIP devi centrare il cuore tra
    // le due carte"*. Le cornici dipinte hanno il centro a 984 pixel del
    // video e il cuore dipinto a 961: con le carte centrate sulle cornici
    // (FU.14) il cuore stava da 7,7 a 11,3 punti sopra il loro centro. Adesso
    // le carte hanno il centro all'altezza del cuore dipinto, e restano
    // centrate sulle cornici in orizzontale: la cornice, piu' piccola della
    // carta, resta sotto come alone (`fy12_misure.txt`).
    final cuore = IlPalcoDellaSinastriaVip.cuoreSulloSchermo(schermo);
    final cimaDelleCarte = cuore.dy - alta / 2;
    return SizedBox(
      width: schermo.width,
      child: Column(
        key: const Key('sinastria_vip_interfaccia'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: cimaDelleCarte,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: cimaDelTitolo,
                  left: SpacingTokens.lg,
                  right: SpacingTokens.lg,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        _primo == null
                            ? 'La Tua Compatibilità con un VIP'
                            : 'La Compatibilità fra ${_primo!.name} e un VIP',
                        key: const Key('sinastria_titolo_confronto'),
                        textAlign: TextAlign.center,
                        // **L'OMBRA SOTTO IL TITOLO, ordine GA voce GA.10.** Sul
                        // palco i faretti dorati passano dietro le lettere: il
                        // titolo misurava 2,65 a 1 nel punto piu' chiaro, e
                        // l'ombra scura gli toglie il faretto da sotto.
                        style: TypographyTokens.suLaScena(
                            TypographyTokens.titoloSezione().copyWith(
                                color: palette.goldSoft, height: 1.2)),
                      ),
                      // **IL CONTEGGIO STA ANCHE QUI, ED E' LA TERZA VOLTA CHE IL
                      // FONDATORE LO CHIEDE.** Ordine CO voce 09, 3 settembre 2026.
                      //
                      // **Perche' non c'era, dopo due ordini che dicevano di metterlo.**
                      // C'era, ed era montato: la voce BZ.09 l'aveva messo dentro la
                      // lista del VERDETTO, cioe' dopo che il consumo era gia'
                      // avvenuto, e la voce CF.11 lo ha spostato nella GALLERIA dei
                      // volti, che e' dove si sceglie e quindi dove il numero serve.
                      // Tutte e due le volte il ragionamento era giusto e tutte e due
                      // le volte il fondatore non l'ha visto, **perche' questa e' la
                      // schermata che lui chiama "la sinastria vip"**: e' la prima che
                      // si apre, ed e' quella da cui si guarda prima di decidere se
                      // entrare. La galleria e' gia' un passo dentro.
                      //
                      // **La lezione, e vale oltre questa riga:** un numero non si
                      // mette dove il ragionamento dice che serve, si mette dove
                      // l'occhio arriva. Le due cose coincidono spesso e non sempre, e
                      // quando non coincidono vince l'occhio. Adesso sta in tutti e
                      // due i posti, e non e' una duplicazione: e' la stessa riga, la
                      // stessa casa, lo stesso conto, montata due volte.
                      const SizedBox(height: SpacingTokens.sm),
                      const Center(
                        child:
                            RigaDelResiduo(budget: BudgetDelGiorno.sinastrie),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _leDueCarte(palette,
              larga: larga,
              centroSinistra: sinistra.dx,
              centroDestra: destra.dx,
              cima: cimaDelleCarte),
          Padding(
            padding: EdgeInsets.fromLTRB(SpacingTokens.lg, 0, SpacingTokens.lg,
                SpacingTokens.xxxl + margini.bottom),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: SpacingTokens.md),
                _ilBottone(palette),
                const SizedBox(height: SpacingTokens.lg),
                if (PortaDellaSinastria.leTreScelteInFila)
                  _treScelteInFila(palette)
                else
                  _treScelteATendina(palette),
                if (_primo != null) ...[
                  const SizedBox(height: SpacingTokens.md),
                  Center(
                    child: TextButton.icon(
                      key: const Key('sinastria_torna_a_te'),
                      onPressed: _tornaATe,
                      style: TextButton.styleFrom(
                          foregroundColor: palette.goldSoft,
                          minimumSize: const Size.fromHeight(48)),
                      icon: const Icon(Icons.person_rounded, size: 18),
                      // Corpo e non maiuscoletto: una frase che va a capo
                      // in maiuscoletto diventa un muro di lettere larghe.
                      label: Text('Rimetti il tuo cielo al primo posto',
                          style: TypographyTokens.corpo()),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// **LE DUE CARTE SULLE DUE CORNICI**, ordine FU voce FU.14: ognuna
  /// centrata sulla sua cornice di luce, larga [larga] (la piu' grande che lo
  /// schermo consente, [IlPalcoDellaSinastriaVip.larghezzaDelleCarte]), col
  /// cuore posato sul cuore dipinto. Prima dell'ordine le carte dividevano la
  /// riga a meta' col cuore in mezzo.
  Widget _leDueCarte(
    MaestroPalette palette, {
    required double larga,
    required double centroSinistra,
    required double centroDestra,
    required double cima,
  }) {
    final inizioSinistra = centroSinistra - larga / 2;
    final fineSinistra = inizioSinistra + larga;
    final inizioDestra = centroDestra - larga / 2;
    const meta = IlPalcoDellaSinastriaVip.cuore / 2;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: math.max(0, inizioSinistra)),
        SizedBox(
          width: larga,
          child: _Casella(
            chiave: const Key('sinastria_carta_tua'),
            palette: palette,
            // **LA CARTA CHE SI TOCCA E' LA CARTA CHE CAMBIA. Voce CA.02.**
            // Nel responso il tocco su una delle due caselle tornava sempre
            // alla galleria del SECONDO, perche' la scelta la faceva la pila
            // del Navigator invece di chi toccava. Qui ogni casella sa quale
            // e', e chiede il volto per se'.
            //
            // **E IL VOLTO DELLA CARTA "TU" E' IL TUO.** Ordine ER voce 04: la
            // voce CA.02 le aveva dato il tocco che sceglie un VIP, e il
            // fondatore toccando la sua carta si e' visto offrire un volto
            // famoso invece del suo. Adesso apre la foto o l'avatar; il
            // confronto fra due VIP si raggiunge dalla scelta "Confronta 2
            // VIP" qui sotto, e da li' questa carta torna a cambiare il VIP.
            onTocco: _toccaLaPrimaCarta,
            sotto: _primo == null ? 'Tu' : _primo!.name,
            suggerimento: _primo != null
                ? null
                : _foto.hasPhoto
                    ? 'Cambia la tua foto'
                    : 'Aggiungi la tua foto',
            ritratto: _primo == null
                ? VipFramedPortrait(
                    palette: palette,
                    name: widget.userName ?? 'Il tuo cielo',
                    date: _dataTua,
                    sign: widget.userSign?.symbol,
                    photo: _foto.bytes,
                  )
                : VipFramedPortrait(
                    palette: palette,
                    name: _primo!.name,
                    date: _primo!.note,
                    sign: _primo!.sign.symbol,
                    vipAsset: _primo!.fullPath,
                  ),
          ),
        ),
        SizedBox(
          width: math.max(0, inizioDestra - fineSinistra),
          child: Align(
            alignment: Alignment.topLeft,
            child: Padding(
              // **IL CUORE A META' FRA LE DUE CARTE** (FY.12): a meta' dello
              // spazio fra le due, e all'altezza del loro centro, che e'
              // quella del cuore dipinto del palco.
              padding: EdgeInsets.only(
                  left: math.max(0, (inizioDestra - fineSinistra) / 2 - meta),
                  top: math.max(0, larga / VipFrame.aspect / 2 - meta)),
              child: Icon(Icons.favorite_rounded,
                  key: const Key('sinastria_vip_cuore'),
                  color: palette.goldSoft,
                  size: IlPalcoDellaSinastriaVip.cuore),
            ),
          ),
        ),
        SizedBox(
          width: larga,
          child: _Casella(
            chiave: const Key('sinastria_carta_da_scegliere'),
            palette: palette,
            onTocco: () => _scegli(perLaPrima: false),
            sotto: _secondo?.name ?? 'Scegli il VIP',
            ritratto: _secondo == null
                ? VipFramedPortrait(
                    palette: palette,
                    name: 'Scegli il VIP',
                    date: '',
                    sign: '?',
                  )
                : VipFramedPortrait(
                    palette: palette,
                    name: _secondo!.name,
                    date: _secondo!.note,
                    sign: _secondo!.sign.symbol,
                    vipAsset: _secondo!.fullPath,
                  ),
          ),
        ),
      ],
    );
  }

  Widget _ilBottone(MaestroPalette palette) {
    final pronto = _secondo != null;
    return Center(
      child: FilledButton.icon(
        key: const Key('sinastria_fai_il_confronto'),
        onPressed: _apriIlResponso,
        style: FilledButton.styleFrom(
          backgroundColor: pronto ? palette.gold : palette.surfaceElevated,
          foregroundColor: pronto ? palette.deepest : palette.goldSoft,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
            side: BorderSide(color: palette.goldSoft.withValues(alpha: 0.6)),
          ),
        ),
        icon: const Icon(Icons.auto_awesome, size: 18),
        label: Text(
          pronto ? 'Scopri la compatibilità' : 'Scegli il VIP',
          style: TypographyTokens.titoloScheda(),
        ),
      ),
    );
  }

  Widget _treScelteInFila(MaestroPalette palette) {
    return Column(
      key: const Key('sinastria_tre_scelte'),
      children: [
        for (final modo in ModoDellaSinastria.values) ...[
          _PortaDelModo(
            chiave: Key(modo.chiave),
            modo: modo,
            palette: palette,
            attivo: modo == _modo,
            onTocco: () => _scegliIlModo(modo),
          ),
          const SizedBox(height: SpacingTokens.sm),
        ],
      ],
    );
  }

  /// La forma che il fondatore aveva proposto: una tendina sola. Vive qui
  /// accanto all'altra e legge lo stesso elenco, cosi' la scelta della forma
  /// resta una riga e non una riscrittura.
  Widget _treScelteATendina(MaestroPalette palette) {
    return Column(
      key: const Key('sinastria_tre_scelte'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Scegli il tipo di sinastria',
            style: TypographyTokens.etichetta()
                .copyWith(color: palette.goldSoft, letterSpacing: 1.1)),
        const SizedBox(height: SpacingTokens.xs),
        DecoratedBox(
          decoration: BoxDecoration(
            color: palette.surfaceElevated,
            borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
            border: Border.all(color: palette.goldSoft.withValues(alpha: 0.5)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.md),
            child: DropdownButton<ModoDellaSinastria>(
              key: const Key('sinastria_tendina_modo'),
              value: _modo,
              isExpanded: true,
              underline: const SizedBox.shrink(),
              dropdownColor: palette.surfaceElevated,
              iconEnabledColor: palette.goldSoft,
              items: [
                for (final modo in ModoDellaSinastria.values)
                  DropdownMenuItem(
                    key: Key(modo.chiave),
                    value: modo,
                    child: Text(modo.titolo,
                        style: TypographyTokens.corpo()
                            .copyWith(color: ColorTokens.textPrimary)),
                  ),
              ],
              onChanged: (m) => m == null ? null : _scegliIlModo(m),
            ),
          ),
        ),
      ],
    );
  }
}

/// Una delle due caselle: il ritratto, il nome sotto, e il tocco che riempie
/// QUESTA casella e non l'altra.
class _Casella extends StatelessWidget {
  const _Casella({
    required this.chiave,
    required this.palette,
    required this.ritratto,
    required this.sotto,
    required this.onTocco,
    this.suggerimento,
  });

  final Key chiave;
  final MaestroPalette palette;
  final Widget ritratto;
  final String sotto;
  final VoidCallback onTocco;

  /// Una riga piccola sotto il nome, che dice cosa fa il tocco.
  final String? suggerimento;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: chiave,
      onTap: onTocco,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          ritratto,
          const SizedBox(height: SpacingTokens.xs),
          Text(
            sotto,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TypographyTokens.suLaScena(
                TypographyTokens.etichetta().copyWith(color: palette.goldSoft)),
          ),
          if (suggerimento != null)
            // **DUE RIGHE, NON I TRE PUNTINI.** Sulla build 2285 (ordine ER)
            // la riga si leggeva "Aggiungi la tu..." e "Cambia la tua ...":
            // la colonna della carta e' stretta, e una riga sola non basta.
            Text(
              suggerimento!,
              key: const Key('sinastria_suggerimento_tu'),
              textAlign: TextAlign.center,
              maxLines: 2,
              style: TypographyTokens.suLaScena(TypographyTokens.etichetta()
                  .copyWith(color: ColorTokens.textPrimary)),
            ),
        ],
      ),
    );
  }
}

/// Una delle tre porte, alta e col bordo d'oro: la stessa forma che le due
/// funzioni virali avevano nella galleria, portata qui.
class _PortaDelModo extends StatelessWidget {
  const _PortaDelModo({
    required this.chiave,
    required this.modo,
    required this.palette,
    required this.attivo,
    required this.onTocco,
  });

  final Key chiave;
  final ModoDellaSinastria modo;
  final MaestroPalette palette;
  final bool attivo;
  final VoidCallback onTocco;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: chiave,
      onTap: onTocco,
      behavior: HitTestBehavior.opaque,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color:
              palette.surfaceElevated.withValues(alpha: attivo ? 0.95 : 0.65),
          borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
          border: Border.all(
              color: palette.goldSoft.withValues(alpha: attivo ? 0.9 : 0.4),
              width: attivo ? 1.6 : 1),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: SpacingTokens.md, vertical: SpacingTokens.md),
          child: Row(
            children: [
              Icon(modo.icona, color: palette.goldSoft, size: 22),
              const SizedBox(width: SpacingTokens.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(modo.titolo,
                        style: TypographyTokens.titoloScheda()
                            .copyWith(color: palette.goldSoft)),
                    const SizedBox(height: SpacingTokens.xxs),
                    Text(modo.sotto,
                        style: TypographyTokens.etichetta()
                            .copyWith(color: ColorTokens.textSecondary)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: palette.goldSoft.withValues(alpha: 0.7)),
            ],
          ),
        ),
      ),
    );
  }
}
