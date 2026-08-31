import 'dart:async';
import '../maestri/chat/chat_openers.dart';
import '../ricordi/azioni_del_responso.dart';

import 'package:flutter/material.dart';
import '../sigilli/regia_del_cammino.dart';
import 'package:provider/provider.dart';

import '../../core/entitlement/entitlement_service.dart';
import '../../core/entitlement/plan_catalog.dart';

import '../../core/astro/zodiac.dart';
import '../../core/config/app_flags.dart';
import '../../core/horoscope/astro_tradition.dart';
import '../../core/horoscope/cielo_di_oggi.dart';
import '../../core/horoscope/corrente_del_cielo.dart';
import '../../core/horoscope/horoscope.dart';
import '../../core/horoscope/riflessione_del_cielo.dart';
import '../../core/identity/natal_identity.dart';
import '../../core/identity/profile_controller.dart';
import '../../core/maestro/maestro.dart';
import '../../core/sensi/catalogo_suoni.dart';
import '../../core/sensi/palette_sensoriale.dart';
import '../../design_system/components/cosmos_background.dart';
import '../../design_system/components/testo_che_si_scrive.dart';
import '../../design_system/components/entrance_cascade.dart';
import '../../design_system/components/zodiac_glyph.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../design_system/typography/paragrafi_di_lettura.dart';
import 'answer_depth.dart';
import '../pricing/upgrade_invite.dart';
import 'horoscope_visuals.dart';
import 'oroscopo_colors.dart';
import 'oroscopo_share_card.dart';
import 'riflessione_del_cielo_view.dart';
import 'tradition_glyph.dart';
import '../maestri/rotta_arte.dart';
import '../../core/condivisione/premio_della_condivisione.dart';
import '../sigilli/celebrazione.dart';
import '../../design_system/transizioni/passaggio_del_cerchio.dart';
import 'corsa_dello_zodiaco.dart';

const List<String> _mesiItaliani = [
  'gennaio', 'febbraio', 'marzo', 'aprile', 'maggio', 'giugno', //
  'luglio', 'agosto', 'settembre', 'ottobre', 'novembre', 'dicembre'
];

/// Data locale per esteso, in italiano.
String italianLongDate(DateTime d) =>
    '${d.day} ${_mesiItaliani[d.month - 1]} ${d.year}';

/// I tre periodi dell'Oroscopo. Per la Demo solo il Giorno e' attivo: Settimana
/// e Mese restano visibili ma bloccati dietro l'abbonamento, mai un vicolo
/// cieco.
enum HoroscopePeriod {
  giorno('Giorno', unlocked: true),
  settimana('Settimana', unlocked: false),
  mese('Mese', unlocked: false);

  const HoroscopePeriod(this.label, {required this.unlocked});

  final String label;
  final bool unlocked;

  /// IL SOTTOTITOLO CHE SEGUE LA SCELTA, ordine 2171 voce 5.
  ///
  /// Diceva "del giorno" sempre, anche a chi aveva scelto la settimana o il
  /// mese: una riga che non guarda la scelta della persona e' una riga che
  /// prima o poi dice il falso.
  String get sottotitolo => switch (this) {
        HoroscopePeriod.giorno => 'Oroscopo Personalizzato del giorno',
        HoroscopePeriod.settimana => 'Oroscopo Personalizzato della settimana',
        HoroscopePeriod.mese => 'Oroscopo Personalizzato del mese',
      };
}

/// Oroscopo Personalizzato, la headline di Medora.
///
/// Quattro schede per il segno di nascita della persona (Generale, Amore,
/// Carriera, Fortuna), ognuna con la sua forma a tema e il livello da 1 a 5,
/// deterministiche dal giorno: stesso segno stesso giorno, stesso responso. Il
/// giorno si legge una sola volta qui e si passa come intero ai calcoli, cosi'
/// l'hash resta puro. Contenuto su dispositivo, senza backend.
class OroscopoScreen extends StatefulWidget {
  const OroscopoScreen({super.key, required this.userSign, this.now});

  final Zodiac userSign;
  final DateTime? now;

  static Route<void> route({required Zodiac userSign, DateTime? now}) {
    return PassaggioDelCerchio.rotta<void>((_) => SogliaArte(
          id: 'horoscope',
          maestro: Maestro.medora,
          child: OroscopoScreen(userSign: userSign, now: now)));
  }

  @override
  State<OroscopoScreen> createState() => _OroscopoScreenState();
}

class _OroscopoScreenState extends State<OroscopoScreen>
    with SingleTickerProviderStateMixin {
  // Il giorno per l'oroscopo, letto una sola volta a livello di schermata.
  late final DateTime _date = widget.now ?? DateTime.now();
  late final int _dayOfYear = Horoscope.dayOfYear(_date);
  late final int _year = _date.year;

  HoroscopePeriod _period = HoroscopePeriod.giorno;

  /// IL CIELO SI INTERROGA, NON SI APRE GIA' PRONTO. Ordine 2171, voce 5.
  ///
  /// Prima la schermata mostrava l'oroscopo dal primo fotogramma: sembrava
  /// uscito da una macchina, senza studio ne' interpretazione. Adesso c'e' un
  /// gesto, e i testi si compongono dopo.
  /// **LA FASE DEL CONSULTO, ordine BK voci 02 e 03.**
  ///
  /// Prima erano DUE booleani, `_interrogato` e `_interrogazione`, e il
  /// difetto stava proprio li': diventavano veri nello stesso istante, quindi
  /// le quattro schede montavano al tocco mentre `scrivendo` valeva falso, e
  /// con `scrivendo` falso il responso si costruisce INTERO. La pausa esisteva
  /// e non era mai visibile. Due booleani indipendenti possono trovarsi in
  /// quattro combinazioni, e una sola era quella giusta: una fase sola non ha
  /// combinazioni sbagliate da assumere.
  _FaseDelConsulto _fase = _FaseDelConsulto.attesa;

  /// **IL SEGNO SU CUI LA CORSA SI FERMA. Ordine CC voce 03.**
  ///
  /// Non si va a cercarlo da nessuna parte: la schermata dell'Oroscopo lo ha
  /// gia' in mano, perche' e' il segno con cui e' stata aperta. Una seconda
  /// via per lo stesso dato sarebbe la solita seconda porta.
  Zodiac get _segnoDiChiGuarda => widget.userSign;

  /// **LA CORSA RESTA IN SCENA MENTRE SI DISSOLVE. Ordine CC voce 03.**
  ///
  /// Il fondatore ha scritto "poi in dissolvenza torni a mostrare la schermata
  /// di responso": la dissolvenza deve avvenire SOPRA il responso, non prima.
  /// Legandola ai due momenti della riflessione, la scena sparirebbe
  /// nell'istante in cui il responso nasce, e il responso comparirebbe di
  /// botto sotto un velo gia' tolto: cioe' il difetto che questa voce chiude.
  bool _corsaInScena = false;

  /// Il tempo che la corsa resta sopra il responso mentre si dissolve.
  Timer? _fineDellaCorsa;

  /// Quanto dura la sola dissolvenza, dentro il tempo della corsa.
  static const Duration _dissolvenzaDellaCorsa = Duration(milliseconds: 700);

  /// Vero mentre uno dei due momenti della riflessione e' a schermo.
  bool get _riflettendo =>
      _fase == _FaseDelConsulto.raccolta || _fase == _FaseDelConsulto.nomina;

  /// Quale scheda sta scrivendo adesso: le altre, dopo di lei, non sono
  /// ancora nate. Meno uno vuol dire che non ne e' nata nessuna.
  int _turnoDiScrittura = -1;

  /// La cascata delle schede, ordine BK voce 03.
  Timer? _cascata;

  /// Se l'attesa piena e' gia' stata spesa oggi, letta dal disco all'apertura.
  /// Ordine BK voce 05.
  bool _attesaPienaGiaSpesa = false;

  /// Se QUESTO consulto ha avuto la riflessione piena: decide anche quanto
  /// dura la raccolta dei corpi attorno all'emblema, cosi' la corona finisce
  /// di comporsi quando il momento finisce, breve o pieno che sia.
  bool _pienaQuestoConsulto = true;

  /// Quante schede compone il responso. Dal dato, non da un numero battuto
  /// qui: se domani i domini diventano cinque, la cascata li segue.
  static final int _quanteSchede = HoroscopeDomain.values.length;

  Future<void> _interrogaIlCielo() async {
    if (_fase != _FaseDelConsulto.attesa) return;
    // **L'ATTESA PIENA UNA VOLTA AL GIORNO, ordine BK voce 05.** La prima
    // interrogazione del giorno ha la riflessione intera; le successive la
    // stessa scena, compressa. Il giorno lo decide `ConfineDelGiorno`, che e'
    // l'autorita' del confine in tutta l'app, e il conteggio sta sul disco.
    final piena = !_attesaPienaGiaSpesa;
    _pienaQuestoConsulto = piena;
    _attesaPienaGiaSpesa = true;
    unawaited(MemoriaDellaRiflessione.segnaSpesaOggi(_date));
    // **LA FESTA ASPETTA CHE LA RIFLESSIONE FINISCA, ordine BU voce 03.** La
    // domanda che la tiene viva e' la fase: finche' e' raccolta o nomina, il
    // cielo sta ancora parlando e nessuna festa ci si dipinge sopra.
    RiflessioniInCorso.entra(() => mounted && _riflettendo);
    setState(() {
      _fase = _FaseDelConsulto.raccolta;
      _corsaInScena = true;
    });
    // **LA SOGLIA, ordine BK voce 04.** Vibrazione leggera e suono di soglia,
    // dalla porta unica: l'interruttore che governa suono e vibrazione e'
    // quello che c'e' gia', e non ne nasce un secondo.
    unawaited(PaletteSensoriale.momento(
      context,
      aptica: SchemaAptico.tocco,
      suono: SuonoDelCerchio.soglia,
    ));
    // L'OROSCOPO ENTRA NEL CAMMINO, ordine P voce 35. Il gesto e'
    // l'interrogazione del cielo, non l'apertura della scena: una scena si
    // apre anche per sbaglio, un'interrogazione no.
    // **QUALE PERIODO, ordine AR voce 11.** La scena sa se si sta
    // interrogando il giorno, la settimana o il mese: e' il dettaglio che
    // distingue chi legge sempre l'oggi da chi guarda piu' lontano.
    unawaited(RegiaDelCammino.dopoUnGesto(
      context,
      'oroscopo',
      dettagli: {'periodo': _period.name},
    ));
    // **QUI C'ERA IL RITORNO ANTICIPATO, e l'ordine BK lo vieta.** Con Riduci
    // Movimento la funzione tornava subito e la riflessione non avveniva
    // affatto: chi ha tolto le animazioni non aveva chiesto di saltare il
    // rito, aveva chiesto che non si muovesse. I due momenti restano, fermi e
    // dichiarati, con la stessa durata; cambia solo che non c'e' movimento
    // dentro, e che il responso non si scrive a macchina.
    final passo = RiflessioneDelCielo.momento(piena: piena);
    await Future<void>.delayed(passo);
    if (!mounted) return;
    setState(() => _fase = _FaseDelConsulto.nomina);
    await Future<void>.delayed(passo);
    if (!mounted) return;
    setState(() {
      _fase = _FaseDelConsulto.responso;
      _turnoDiScrittura = 0;
    });
    // La corsa non sparisce col cambio di fase: resta sopra il responso il
    // tempo della sua dissolvenza, ed e' quella dissolvenza a scoprirlo.
    //
    // **UN TIMER CHE SI PUO' SPEGNERE, non un Future.** Un Future in volo
    // sopravvive alla schermata chiusa: la guardia `mounted` evita il guasto,
    // ma la prova cade lo stesso con "A Timer is still pending". Chi apre e
    // chiude in fretta l'Oroscopo lascerebbe indietro un pezzo di scena.
    _fineDellaCorsa?.cancel();
    _fineDellaCorsa = Timer(_dissolvenzaDellaCorsa, () {
      if (!mounted) return;
      setState(() => _corsaInScena = false);
      // Scena libera: la festa che ha aspettato la riflessione riparte adesso.
      unawaited(RegiaDelCammino.svuotaLaCoda(context, appenaChiusaUna: true));
    });
    // **LA FESTA ASPETTA CHE LA SCENA SI SIA TOLTA. Ordine CC voce 03.**
    //
    // La festa di un traguardo e' una rotta spinta sopra tutto: partendo qui,
    // copriva la corsa dello zodiaco proprio mentre si dissolveva, e
    // l'anteprima del terzo momento mostrava un cielo di stelle al posto della
    // dissolvenza. Chi legge il suo primo oroscopo vedeva la scena sparire
    // sotto una festa invece che scoprire il responso.
    //
    // Adesso parte quando la corsa se n'e' andata, insieme alla riga che la
    // toglie: e' lo stesso istante, scritto in un posto solo.
    // **LA RIVELAZIONE, ordine BK voce 04.** Parte alla comparsa del responso,
    // cioe' almeno un'intera riflessione dopo la soglia: i due suoni non si
    // sovrappongono mai, e ciascuno parte una volta sola per consulto.
    unawaited(PaletteSensoriale.suona(context, SuonoDelCerchio.rivelazione));
    _avviaLaCascata();
  }

  /// **LA CASCATA DELLE SCHEDE, ordine BK voce 03.**
  ///
  /// L'ordine pone due tetti diversi, la prima scheda entro 3,5 secondi dal
  /// tocco e l'ultima entro 6,0: due numeri diversi hanno senso solo se le
  /// schede non finiscono tutte insieme. Chi apre l'Oroscopo legge la Generale
  /// mentre le altre si compongono, invece di aspettare fermo che appaia
  /// tutto.
  void _avviaLaCascata() {
    _cascata?.cancel();
    // Senza movimento non c'e' scrittura da scaglionare: le schede nascono
    // tutte insieme, gia' intere.
    if (MediaQuery.of(context).disableAnimations) {
      setState(() => _turnoDiScrittura = _quanteSchede - 1);
      return;
    }
    _cascata = Timer.periodic(RiflessioneDelCielo.passoFraLeSchede, (t) {
      if (!mounted || _turnoDiScrittura >= _quanteSchede - 1) {
        t.cancel();
        return;
      }
      setState(() => _turnoDiScrittura++);
    });
  }

  // La tradizione scelta e il micro messaggio del Maestro sull'ultima
  // tradizione ancora chiusa che e' stata toccata.
  AstroTradition _tradition = AstroTradition.predefinita;
  AstroTradition? _traditionMessage;

  // Rivelazione una volta sola: la prima volta il messaggio entra in
  // dissolvenza, dalla seconda in poi compare gia' posato.
  final Set<AstroTradition> _traditionRevealed = <AstroTradition>{};

  // Pulsazione lenta condivisa: respiro dell'emblema e delle forme a tema.
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2800),
  )..repeat();

  final GlobalKey _cardKey = GlobalKey();
  bool _sharing = false;
  bool _renderCard = false;

  /// Profondita' scelta per ogni scheda. Nel gratuito resta la profondita'
  /// libera, Breve: la Profonda e' del Cerchio Premium.
  ///
  /// **E LA SCELTA NON ARRIVAVA QUI.** Il selettore riceveva `current` e
  /// `onLockedTap`, ma non `onSelect`: chi aveva pagato apriva il menu, sceglieva
  /// Profonda, e non succedeva niente, perche' la scelta non aveva un posto
  /// dove andare. Una funzione venduta e mai consegnata due volte di fila,
  /// prima col lucchetto sbagliato e poi col filo staccato.
  final Map<HoroscopeDomain, AnswerDepth> _depth = {
    for (final d in HoroscopeDomain.values) d: AnswerDepth.free,
  };

  void _scegliProfondita(HoroscopeDomain dominio, AnswerDepth scelta) {
    if (_depth[dominio] == scelta) return;
    setState(() => _depth[dominio] = scelta);
  }

  /// I TESTI GIA' SCRITTI, ordine L voce 1. Lo stato del "gia' scritto" vive
  /// QUI, accanto alla risposta, con la chiave scheda piu' profondita' piu'
  /// giorno: viveva dentro lo State del widget della scheda, e la lista
  /// smonta le schede fuori dalla finestra di cache, quindi ogni ritorno le
  /// faceva rinascere vergini e la macchina da scrivere ripartiva da capo.
  /// Chi rinasce ora chiede a questo insieme e trova il testo gia' finito.
  final Set<String> _testiScritti = {};

  String _chiaveDelTesto(HoroscopeDomain dominio) =>
      '${dominio.name}|${_depth[dominio]!.name}|$_year-$_dayOfYear';

  @override
  void initState() {
    super.initState();
    // **L'ATTESA PIENA SI CHIEDE AL DISCO ALL'APERTURA, ordine BK voce 05.**
    // Si legge qui e non al tocco, perche' un `await` fra il dito e il primo
    // momento sarebbe un vuoto proprio nell'istante che questo ordine esiste
    // per riempire. Finche' il disco non ha risposto vale la riflessione
    // PIENA: nel dubbio si aspetta di piu', mai di meno, e saltare il rito e'
    // l'unico esito che l'ordine vieta.
    unawaited(MemoriaDellaRiflessione.giaSpesaOggi(_date).then((spesa) {
      if (mounted) _attesaPienaGiaSpesa = spesa;
    }));
  }

  @override
  void dispose() {
    _fineDellaCorsa?.cancel();
    _cascata?.cancel();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // L'Oroscopo e' di Medora: blu e oro suoi, sempre, anche se il Maestro
    // attivo altrove fosse un altro. Lo sfondo resta il cosmo ambientale.
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.medora));
    final profile = context.watch<ProfileController>();
    final vocative = Horoscope.vocativeFor(profile.vocative, profile.courtesy);
    final opening = Horoscope.openingFor(
        sign: widget.userSign,
        dayOfYear: _dayOfYear,
        year: _year,
        vocative: vocative);
    // IL CIELO VERO DI QUESTA PERSONA, quando c'e' una carta da interrogare.
    //
    // **Qui muore l'hash.** La corrente del giorno usciva da un pool di frasi
    // generiche scelte da una hash su segno, giorno e anno: cambiava tutti i
    // giorni senza che in cielo fosse cambiato niente, ed era identica per due
    // persone dello stesso segno nate a vent'anni di distanza. Adesso, con la
    // carta natale, la scrive il cielo. Senza carta si torna alla hash, e la
    // nota qui sotto lo dichiara invece di lasciarlo credere.
    // IL CIELO VERO, non il ripiego, ordine 2169 voce 4. `chart` torna anche
    // la carta essenziale, che ha il solo Sole: i transiti su un cielo di un
    // astro non sono transiti. Il livello a valle ripiegava gia' sul pool a
    // hash quando la carta era essenziale, ma lo capiva guardando dentro
    // l'oggetto: adesso la distinzione la fa la porta, una volta per tutti.
    final cielo = CieloDiOggi.perIlGiorno(
        adesso: _date,
        carta: context.watch<BirthIdentityController>().cartaCompleta);
    final notaDelCielo = CorrenteDelCielo.notaDelLivello(cielo);
    final cards = Horoscope.forSign(
        sign: widget.userSign,
        dayOfYear: _dayOfYear,
        year: _year,
        opening: opening,
        cielo: cielo,
        profonde: {
          for (final voce in _depth.entries)
            voce.key: voce.value == AnswerDepth.profonda,
        });

    return Stack(
      children: [
        Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: palette.goldSoft),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Indietro',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        // IL BORSELLINO, ordine S voce 06: stesso segno, stesso angolo, in ogni
        // schermata della pratica. Un saldo che appare e scompare non si impara.
        actions: const [AngoloDellaBarra()],
      ),
      body: CosmosBackground(
        seed: 5,
        showZodiac: false,
        child: SafeArea(
          child: Stack(
            children: [
              EntranceCascade(
                listKey: const Key('oroscopo_list'),
                // Nessun vuoto sopra l'eroe: il segno parte in alto.
                padding: const EdgeInsets.fromLTRB(
                    SpacingTokens.lg, 0, SpacingTokens.lg, SpacingTokens.lg),
                hero: Column(
                  children: [
                    // IL NOME DEL SEGNO, GRANDE, SOPRA L'EMBLEMA: e' la prima
                    // cosa che la persona cerca, e stava sotto la figura.
                    Text(widget.userSign.italianName,
                        key: const Key('oroscopo_sign_name'),
                        style: TypographyTokens.cerimonialeGrande()
                            .copyWith(color: palette.goldSoft)),
                    const SizedBox(height: SpacingTokens.xs),
                    _Hero(
                      sign: widget.userSign,
                      palette: palette,
                      pulse: _pulse,
                      // L'EMBLEMA PULSA MENTRE IL CIELO SI INTERROGA: e' il
                      // segno che qualcosa sta accadendo, e dura quanto la
                      // pausa dichiarata.
                      interrogazione: _riflettendo,
                      // I CORPI VERI ATTORNO ALL'EMBLEMA, e restano per
                      // TUTTA la riflessione (ordine BZ voce 06).
                      //
                      // **Prima stavano nel solo primo momento**, e al
                      // secondo la corona spariva: restavano una riga di testo
                      // e due pallini, cioe' la scena si svuotava a meta'
                      // proprio mentre nominava il fatto del giorno. E' la
                      // stessa forma di difetto della voce BZ.07, dove fra
                      // l'ultima carta e la riflessione restava Medora da
                      // sola. I corpi si compongono nel primo momento e
                      // restano composti nel secondo.
                      corona: _riflettendo,
                      adesso: _date,
                      durataDelMomento: RiflessioneDelCielo.momento(
                          piena: _pienaQuestoConsulto),
                    ),
                  ],
                ),
                items: [
                  _Heading(periodo: _period, date: _date, palette: palette),
                  const SizedBox(height: SpacingTokens.md),
                  _PeriodTabs(
                    current: _period,
                    palette: palette,
                    onSelect: _selectPeriod,
                  ),
                  const SizedBox(height: SpacingTokens.sm),
                  // Accanto al periodo, la tradizione: lo stesso cielo letto con
                  // occhi diversi. Aperta l'Occidentale, le altre col lucchetto.
                  _TraditionTabs(
                    current: _tradition,
                    palette: palette,
                    onSelect: _selectTradition,
                  ),
                  _TraditionInvite(
                    tradition: _traditionMessage,
                    maestro: Maestro.medora,
                    palette: palette,
                    // Rivelazione una volta sola per tradizione.
                    animate: _traditionMessage != null &&
                        !_traditionRevealed.contains(_traditionMessage),
                  ),
                  const SizedBox(height: SpacingTokens.md),
                  // IL GESTO CHE APRE IL CONSULTO. Prima del tocco l'oroscopo
                  // non si vede: il cielo si interroga.
                  if (_fase == _FaseDelConsulto.attesa)
                    _InterrogaIlCielo(
                      palette: palette,
                      onTap: _interrogaIlCielo,
                    ),
                  // I DUE MOMENTI DELLA RIFLESSIONE, ordine BK voce 03. Stanno
                  // dove staranno le schede, cosi' lo sguardo non si sposta
                  // quando il responso arriva.
                  if (_riflettendo)
                    RigaDellaRiflessione(
                      momento: _fase == _FaseDelConsulto.raccolta
                          ? MomentoDellaRiflessione.raccolta
                          : MomentoDellaRiflessione.nomina,
                      cielo: cielo,
                      palette: palette,
                    ),
                  // **LE SCHEDE NASCONO DOPO LA RIFLESSIONE, E UNA ALLA
                  // VOLTA.** Ordine BK voci 02 e 03. Prima montavano al tocco,
                  // ed e' per questo che il responso si vedeva intero: una
                  // scheda che esiste mentre la scrittura non e' cominciata
                  // mostra tutto il suo testo. Qui, finche' non e' il suo
                  // turno, la scheda non e' in albero affatto: i caratteri del
                  // responso presenti durante la riflessione sono ZERO, e non
                  // per un'opacita' che li nasconde.
                  if (_fase == _FaseDelConsulto.responso)
                    for (var i = 0; i < cards.length; i++)
                      if (i <= _turnoDiScrittura) ...[
                        _HoroscopeCardView(
                          scrivendo: true,
                          durataScrittura:
                              RiflessioneDelCielo.scritturaDiUnaScheda,
                          card: cards[i],
                          palette: palette,
                          pulse: _pulse,
                          depth: _depth[cards[i].domain]!,
                          // Il "gia' scritto" abita la schermata: la scheda lo
                          // legge quando nasce e lo dichiara quando finisce.
                          // LETTURA VIVA, non un booleano catturato: i widget
                          // della lista vengono costruiti una volta e rinascono
                          // dopo, quindi un valore fissato alla costruzione
                          // sarebbe sempre vecchio. Il gancio legge il registro
                          // nel momento della rinascita.
                          giaScritto: () => _testiScritti
                              .contains(_chiaveDelTesto(cards[i].domain)),
                          onScritto: () => _testiScritti
                              .add(_chiaveDelTesto(cards[i].domain)),
                          onDepthSelected: (depth) =>
                              _scegliProfondita(cards[i].domain, depth),
                          onDepthLocked: (depth) =>
                              _showDepthLocked(cards[i].domain, depth),
                          premiumUnlocked: PlanCatalog.haProfondita(
                              context.watch<EntitlementService>().tier),
                        ),
                        const SizedBox(height: SpacingTokens.md),
                      ],
                  // LA NOTA CHE DICHIARA IL RIPIEGO, quando il cielo non c'e'.
                  //
                  // Una riga generica scritta con lo stesso carattere di una
                  // vera si legge come vera: qui si dice a parole che senza
                  // ora e luogo di nascita quella lettura parla al segno, non
                  // al cielo di questa persona, e si dice come rimediare.
                  if (notaDelCielo != null) ...[
                    _NotaDelCielo(
                        testo: notaDelCielo,
                        palette: palette,
                        completa: cielo.ceCieloVero),
                    const SizedBox(height: SpacingTokens.md),
                  ],
                  // SI PORTA CON SE' SOLO CIO' CHE SI E' LETTO. Prima del
                  // consulto la schermata offriva di condividere un oroscopo
                  // che nessuno aveva ancora chiesto, e la card che ne usciva
                  // portava testi mai comparsi a video: e' lo stesso difetto
                  // che il gesto Interroga il cielo esiste per togliere.
                  if (_fase == _FaseDelConsulto.responso)
                    _ShareBlock(
                      palette: palette,
                      sharing: _sharing,
                      onShare: _onShare,
                      segno: widget.userSign.italianName,
                      // **IL TESTO CHE SI CUSTODISCE E' QUELLO CHE SI E'
                      // LETTO**, cioe' le schede del cielo di oggi in fila:
                      // custodire un testo diverso da quello a video sarebbe
                      // riaprire domani un responso che non e' mai comparso.
                      testoDelResponso: cards
                          .map((c) => '${c.title}\n${c.text}')
                          .join('\n\n'),
                    ),
                  // IL DISCLAIMER E' USCITO DA QUI, ed era uno di SETTE.
                  //
                  // Le linee guida dicevano da sempre "una volta sola", e per
                  // sette volte ognuno ha pensato che il proprio fosse quella
                  // volta. Un disclaimer ripetuto smette di essere letto e
                  // diventa un modo di scaricare la responsabilita' invece di
                  // dirla. Adesso sta in un posto solo, nell'area privacy.
                ],
              ),

              if (_renderCard)
                Positioned(
                  left: -3000,
                  top: 0,
                  child: RepaintBoundary(
                    key: _cardKey,
                    child: OroscopoShareCard(
                        sign: widget.userSign, cards: cards, palette: palette),
                  ),
                ),
            ],
          ),
        ),
      ),
        ),
        // **LA CORSA DELLO ZODIACO STA SOPRA TUTTO. Ordine CC voce 03.**
        //
        // Parole del fondatore: "VOGLIO che ci sia una schermata nuova sopra
        // tutto con tutti i simboli dello zodiaco grandi che velocemente si
        // succedono uno dopo l'altro e poi si ferma sul segno zodiacale
        // dell'utente".
        //
        // **Sta FUORI dallo Scaffold, e me l'ha insegnato l'anteprima.** Prima
        // stava dentro il corpo, e restavano scoperte la freccia Indietro e il
        // cuore della barra: una schermata nuova che lascia visibili i comandi
        // di quella vecchia non e' una schermata nuova. Prima ancora stava
        // dentro la colonna dell'eroe, dove un `Positioned.fill` non ha
        // significato e Flutter lo dice con un errore.
        //
        // **Restano fuori le due barre sottili dell'app**, e lo dichiaro:
        // quelle vivono sopra il Navigator, cioe' sopra ogni rotta, e per
        // coprirle bisognerebbe portare questa scena fuori dalla schermata che
        // la possiede, cioe' aprire una seconda porta sullo stesso momento.
        if (_corsaInScena)
          CorsaDelloZodiaco(
            key: const Key('corsa_dello_zodiaco'),
            segno: _segnoDiChiGuarda,
            palette: palette,
            durata: RiflessioneDelCielo.momento(piena: _pienaQuestoConsulto) *
                    2 +
                _dissolvenzaDellaCorsa,
            riduciMovimento: MediaQuery.of(context).disableAnimations,
          ),
      ],
    );
  }

  void _showDepthLocked(HoroscopeDomain domain, AnswerDepth depth) {
    // LA BOLLA DEL MAESTRO, non una SnackBar di sistema, ordine L voce 1c:
    // l'avviso col fondo bianco e' sparito, e al tocco sul lucchetto sale
    // dal basso l'invito gia' esistente, nel blu di Medora.
    showUpgradeInvite(
      context,
      title: 'La profondità ${depth.label} è del Cerchio Premium',
      message: 'Col piano superiore scegli quanto approfondire ogni scheda, '
          '${domain.label} compresa: la lettura ti segue in profondità.',
    );
  }

  void _selectPeriod(HoroscopePeriod period) {
    if (period.unlocked) {
      setState(() => _period = period);
      return;
    }
    // Mai un vicolo cieco: il periodo bloccato invita all'abbonamento, con
    // la bolla del Maestro e non con una SnackBar di sistema.
    showUpgradeInvite(
      context,
      title: 'L\'oroscopo della ${period.label.toLowerCase()} è del Cerchio '
          'Premium',
      message:
          'Col piano superiore leggi anche la ${period.label.toLowerCase()}, '
          'oltre il giorno.',
    );
  }

  /// La tradizione: se e' aperta si sceglie, se e' chiusa risponde il Maestro.
  ///
  /// Al posto del solito lucchetto muto compare un micro messaggio di Medora in
  /// prima persona, che racconta cosa sara' quella tradizione. La prima volta
  /// entra in dissolvenza, poi resta posato: e' la rivelazione una volta sola.
  void _selectTradition(AstroTradition tradition) {
    if (tradition.unlocked) {
      setState(() {
        _tradition = tradition;
        _traditionMessage = null;
      });
      return;
    }
    setState(() => _traditionMessage = tradition);
    // Segna la rivelazione dopo il frame in cui l'animazione e' partita.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _traditionRevealed.add(tradition);
    });
  }

  /// **TORNA L\'ESITO invece di ingoiarlo, ordine CG voce 06.** Il vero che
  /// esce di qui e\' quello su cui scatta la custodia automatica.
  Future<bool> _onShare() async {
    setState(() {
      _sharing = true;
      _renderCard = true;
    });
    try {
      await WidgetsBinding.instance.endOfFrame;
      await Future<void>.delayed(const Duration(milliseconds: 80));
      final andata = await shareOroscopoCard(
        boundaryKey: _cardKey,
        text:
            'Il mio oroscopo di oggi, ${widget.userSign.italianName}. Esoteric Circle.',
      );
      if (andata && mounted) {
        // Ordine BG voce 04: il premio dichiarato sul pulsante si paga qui,
        // a condivisione davvero avvenuta.
        await PremioDellaCondivisione.premia(context,
            cosa: 'Hai condiviso il tuo oroscopo');
      }
      return andata;
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Non riesco a preparare la card ora.')),
        );
      }
      // **UN ERRORE NON \' UNA CONDIVISIONE AVVENUTA**, quindi non custodisce
      // niente: e\' la stessa regola del foglio aperto e poi chiuso.
      return false;
    } finally {
      if (mounted) {
        setState(() {
          _sharing = false;
          _renderCard = false;
        });
      }
    }
  }
}

/// Lo stile del responso, in un punto solo.
///
/// Serve a due cose che devono restare d'accordo: dipingere il testo e MISURARE
/// quante righe occupa. Se lo stile vivesse in due posti, la divisione in
/// blocchi si calcolerebbe su un carattere e la resa userebbe l'altro, e la
/// regola delle righe direbbe il falso senza che nessuno se ne accorga.
final TextStyle stileDelResponso =
    TypographyTokens.lettura().copyWith(color: ColorTokens.textPrimary);

/// L'eroe: l'emblema 3D del segno della persona, grande, dentro un alone che
/// respira. Nessun altro segno, l'oroscopo e' personalizzato.
/// IL RESPONSO CHE SI SCRIVE, e che un tocco completa.
///
/// Ordine 2171, voce 5. Il testo si compone a macchina da scrivere, con la
/// velocita' dichiarata dalla schermata. Con Riduci Movimento compare intero:
/// l'informazione non dipende dal moto.
///
/// Ordine A. Il responso non e' piu' un muro: si legge nel ruolo [lettura],
/// diciotto punti con interlinea larga, spezzato in paragrafi da tre o quattro
/// righe, distanti fra loro il DOPPIO della misura del testo. I paragrafi si
/// scrivono in fila, uno dopo l'altro, non tutti insieme: la macchina da
/// scrivere sarebbe diventata quattro macchine che battono in coro.
class _ResponsoCheSiScrive extends StatefulWidget {
  const _ResponsoCheSiScrive({
    super.key,
    required this.testo,
    required this.durataScrittura,
    required this.scrivendo,
    required this.giaScritto,
    required this.onScritto,
  });

  final String testo;
  final Duration durataScrittura;
  final bool scrivendo;

  /// Se questo testo e' gia' stato scritto: si mostra intero e fermo. Lo
  /// dice la schermata, che tiene il registro accanto alla risposta: tenerlo
  /// qui dentro non basta, perche' la lista smonta e rimonta. Gancio vivo,
  /// letto a ogni build.
  final bool Function() giaScritto;

  /// La dichiarazione di fine scrittura, verso il registro della schermata.
  final VoidCallback onScritto;

  @override
  State<_ResponsoCheSiScrive> createState() => _ResponsoCheSiScriveState();
}

class _ResponsoCheSiScriveState extends State<_ResponsoCheSiScrive> {
  late List<String> _paragrafi =
      spezzaInParagrafi(widget.testo, stile: stileDelResponso);
  late List<GlobalKey<TestoCheSiScriveState>> _chiavi = _nuoveChiavi();
  int _inScrittura = 0;
  Timer? _passaggio;

  List<GlobalKey<TestoCheSiScriveState>> _nuoveChiavi() => List.generate(
      _paragrafi.length, (_) => GlobalKey<TestoCheSiScriveState>());

  /// Il termine della scrittura, dichiarato al registro. Parte quando la
  /// scrittura comincia, per l'intero budget dichiarato: le fette dei
  /// paragrafi sommano esattamente a quel budget, quindi allo scadere il
  /// testo e' intero. Il tocco che completa dichiara subito.
  Timer? _fine;

  void _armaLaFine() {
    _fine?.cancel();
    _fine =
        Timer(widget.durataScrittura + const Duration(milliseconds: 50), () {
      if (mounted) widget.onScritto();
    });
  }

  @override
  void didUpdateWidget(_ResponsoCheSiScrive vecchio) {
    super.didUpdateWidget(vecchio);
    if (vecchio.testo != widget.testo) {
      _passaggio?.cancel();
      // **IL TIMER TORNA NULLO, ordine I voce 2.** Cancellarlo non basta: la
      // build riarma il passaggio solo quando `_passaggio == null`, e un
      // timer cancellato ma ancora in mano teneva il turno fermo al primo
      // paragrafo per sempre. Era la causa della scheda Profonda vista da
      // Mauro: testo cancellato, un paragrafo solo, il vuoto sotto.
      _passaggio = null;
      _paragrafi = spezzaInParagrafi(widget.testo, stile: stileDelResponso);
      _chiavi = _nuoveChiavi();
      _inScrittura = 0;
      // Il testo nuovo e' un responso nuovo: anche il tocco che aveva
      // completato il vecchio non vale piu', e la fine si riarma.
      _completato = false;
      _fine?.cancel();
      _fine = null;
    }
  }

  @override
  void dispose() {
    _passaggio?.cancel();
    _fine?.cancel();
    super.dispose();
  }

  /// La fetta di tempo del paragrafo che sta scrivendo, in proporzione alla sua
  /// lunghezza: cosi' il responso intero resta dentro il budget dichiarato dalla
  /// schermata, comunque lo si spezzi.
  Duration _durataDi(int indice) {
    final totale = _paragrafi.fold<int>(0, (s, p) => s + p.length);
    if (totale == 0) return Duration.zero;
    return widget.durataScrittura * (_paragrafi[indice].length / totale);
  }

  void _programmaIlPassaggio() {
    if (_inScrittura >= _paragrafi.length - 1) return;
    _passaggio?.cancel();
    _passaggio = Timer(_durataDi(_inScrittura), () {
      if (!mounted) return;
      setState(() => _inScrittura++);
      _programmaIlPassaggio();
    });
  }

  /// Il tocco completa TUTTO il responso, non il solo paragrafo in corso: chi
  /// tocca vuole leggere adesso, e lasciargli tre paragrafi ancora da aspettare
  /// sarebbe la stessa gabbia con tre porte.
  void _completaTutto() {
    _passaggio?.cancel();
    // PRIMA si spegne la scrittura, POI si completa. Al contrario non
    // funzionava, ed e' un difetto che la prova ha preso: portando il turno
    // all'ultimo paragrafo, quello passava da fermo a attivo e RIPARTIVA da
    // zero, quindi il tocco che doveva chiudere il responso ne riapriva un
    // pezzo.
    if (!_completato) setState(() => _completato = true);
    for (final chiave in _chiavi) {
      chiave.currentState?.completa();
    }
    // Chi completa col tocco ha il testo intero adesso: si dichiara subito.
    _fine?.cancel();
    widget.onScritto();
  }

  /// Vero dal tocco in poi: nessun paragrafo batte piu' e tutti si vedono.
  bool _completato = false;

  @override
  Widget build(BuildContext context) {
    // Un testo GIA' SCRITTO non si riscrive: nasce intero e fermo, anche se
    // questo State e' appena rinato dopo uno scorrimento.
    final attiva = widget.scrivendo &&
        !widget.giaScritto() &&
        !_completato &&
        !MediaQuery.of(context).disableAnimations;
    final stile = stileDelResponso;

    if (attiva && _fine == null) {
      _armaLaFine();
    }
    // Il doppio della misura del testo, presa dallo stile e non riscritta a
    // mano: se domani il ruolo cambia misura, la distanza lo segue.
    final distanza = (stile.fontSize ?? TypographyTokens.pavimento) * 2;

    if (attiva && _passaggio == null && _paragrafi.length > 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _passaggio == null) _programmaIlPassaggio();
      });
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _completaTutto,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // L'ALTEZZA SEGUE IL TESTO CHE C'E' DAVVERO, ordine I voce 2b. I
          // paragrafi non ancora scritti stavano in albero trasparenti per
          // riservare il posto: quel posto era il vuoto sotto la scheda, e il
          // ramo e' stato tolto. Mentre si scrive la scheda cresce paragrafo
          // dopo paragrafo, e a scrittura finita non c'e' nessuna riserva.
          for (var i = 0; i < _paragrafi.length; i++)
            if (!attiva || i <= _inScrittura) ...[
              if (i > 0) SizedBox(height: distanza),
              TestoCheSiScrive(
                key: _chiavi[i],
                testo: _paragrafi[i],
                stile: stile,
                durataMassima: _durataDi(i),
                attiva: attiva && i == _inScrittura,
              ),
            ],
        ],
      ),
    );
  }
}

/// IL GESTO CHE APRE IL CONSULTO.
///
/// Ordine 2171, voce 5. Prima la schermata si apriva con l'oroscopo gia'
/// scritto: sembrava uscito da una macchina, senza studio ne' interpretazione.
/// Un consulto comincia quando qualcuno lo chiede.
class _InterrogaIlCielo extends StatelessWidget {
  const _InterrogaIlCielo({required this.palette, required this.onTap});

  final MaestroPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: const Key('oroscopo_interroga'),
          onTap: onTap,
          borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.lg, vertical: SpacingTokens.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
              gradient: LinearGradient(colors: [
                palette.primary.withValues(alpha: 0.85),
                palette.surfaceElevated.withValues(alpha: 0.85),
              ]),
              border: Border.all(color: palette.gold.withValues(alpha: 0.7)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome, size: 18, color: palette.goldSoft),
                const SizedBox(width: SpacingTokens.sm),
                Text('Interroga il cielo',
                    style: TypographyTokens.titoloScheda()
                        .copyWith(color: palette.goldSoft)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({
    required this.sign,
    required this.palette,
    required this.pulse,
    this.interrogazione = false,
    this.corona = false,
    required this.adesso,
    this.durataDelMomento = RiflessioneDelCielo.momentoPieno,
  });

  final Zodiac sign;
  final MaestroPalette palette;
  final Animation<double> pulse;

  /// Se attorno all'emblema si raccolgono i corpi veri del giorno. Ordine BK
  /// voce 03, primo momento.
  final bool corona;

  /// Il giorno da cui vengono le posizioni dei corpi: lo stesso della
  /// schermata, quindi la corona mostra il cielo del responso e non quello
  /// dell'istante in cui si guarda.
  final DateTime adesso;

  /// Quanto dura il momento, cosi' i corpi finiscono di raccogliersi quando il
  /// momento finisce, sia nella riflessione piena sia in quella breve.
  final Duration durataDelMomento;

  /// Vero mentre il cielo si interroga: l'alone si accende di piu', perche' si
  /// capisca che c'e' un'elaborazione in corso e non un'attesa vuota.
  ///
  /// Con Riduci Movimento il respiro non c'e', ma il bagliore resta acceso e
  /// fermo: chi ha tolto le animazioni deve vedere lo stesso che sta
  /// succedendo qualcosa.
  final bool interrogazione;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 268,
      child: AnimatedBuilder(
        animation: pulse,
        builder: (context, _) {
          final riduciMovimento = MediaQuery.of(context).disableAnimations;
          final respiro = 0.5 + 0.5 * (1 - (pulse.value - 0.5).abs() * 2);
          // Mentre si interroga il cielo il respiro si fa piu' ampio; fermo,
          // ma acceso, quando le animazioni sono spente.
          final breathe = interrogazione
              ? (riduciMovimento ? 1.0 : 0.6 + 0.4 * respiro)
              : respiro;
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                key: interrogazione
                    ? const Key('oroscopo_emblema_pulsa')
                    : const Key('oroscopo_emblema'),
                width: 250 + (interrogazione ? 44 : 28) * breathe,
                height: 250 + (interrogazione ? 44 : 28) * breathe,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    palette.gold.withValues(alpha: 0.12 + 0.16 * breathe),
                    palette.glow.withValues(alpha: 0.08 * breathe),
                    Colors.transparent,
                  ], stops: const [
                    0.0,
                    0.55,
                    1.0
                  ]),
                ),
              ),
              ZodiacEmblem(
                  key: const Key('oroscopo_emblem'),
                  sign: sign,
                  size: 264,
                  art: ZodiacEmblemArt.emblem),
              if (corona)
                CoronaDeiCorpi(
                  key: const Key('oroscopo_corona_dei_corpi'),
                  adesso: adesso,
                  palette: palette,
                  raggio: 122,
                  durata: durataDelMomento,
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Intestazione: nome del segno, titolo e data locale.
class _Heading extends StatelessWidget {
  const _Heading(
      {required this.periodo, required this.date, required this.palette});

  final HoroscopePeriod periodo;
  final DateTime date;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(periodo.sottotitolo,
            key: const Key('oroscopo_heading'),
            textAlign: TextAlign.center,
            style: TypographyTokens.etichetta().copyWith(
                color: ColorTokens.textSecondary, letterSpacing: 1.2)),
        Text(italianLongDate(date),
            key: const Key('oroscopo_date'),
            textAlign: TextAlign.center,
            style: TypographyTokens.didascalia()
                .copyWith(color: ColorTokens.textSecondary)),
      ],
    );
  }
}

/// Il selettore del periodo: Giorno attivo, Settimana e Mese visibili ma
/// bloccati col lucchetto e l'invito all'abbonamento.
class _PeriodTabs extends StatelessWidget {
  const _PeriodTabs(
      {required this.current, required this.palette, required this.onSelect});

  final HoroscopePeriod current;
  final MaestroPalette palette;
  final ValueChanged<HoroscopePeriod> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
        color: palette.surfaceElevated.withValues(alpha: 0.45),
        border: Border.all(color: palette.gold.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          for (final period in HoroscopePeriod.values)
            Expanded(
              child: _PeriodTab(
                period: period,
                selected: period == current,
                palette: palette,
                onTap: () => onSelect(period),
              ),
            ),
        ],
      ),
    );
  }
}

/// Il selettore della tradizione: Occidentale aperta, le altre col lucchetto.
///
/// Le astrologie non occidentali non hanno una card nel dominio ne' una
/// schermata propria: vivono qui, come modo diverso di leggere lo stesso cielo.
/// Ogni voce porta il suo glifo disegnato, cosi' si riconosce prima di leggerla.
class _TraditionTabs extends StatelessWidget {
  const _TraditionTabs(
      {required this.current, required this.palette, required this.onSelect});

  final AstroTradition current;
  final MaestroPalette palette;
  final ValueChanged<AstroTradition> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const Key('oroscopo_tradition_tabs'),
      // Alta quanto serve al glifo, al nome e al badge "In arrivo", che sulla
      // voce bloccata sta su una terza riga.
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: AstroTradition.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: SpacingTokens.xs),
        itemBuilder: (context, i) {
          final t = AstroTradition.values[i];
          return _TraditionChip(
            tradition: t,
            selected: t == current,
            palette: palette,
            onTap: () => onSelect(t),
          );
        },
      ),
    );
  }
}

class _TraditionChip extends StatelessWidget {
  const _TraditionChip({
    required this.tradition,
    required this.selected,
    required this.palette,
    required this.onTap,
  });

  final AstroTradition tradition;
  final bool selected;
  final MaestroPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final locked = !tradition.unlocked;
    // Alla persona si dice soltanto "In arrivo": la fase e' un dato di piano e
    // resta nella sola vista Demo per gli investitori.
    final fase = AppFlags.isDemo && tradition.phase != null
        ? ', ${tradition.phase}'
        : '';
    return GestureDetector(
      key: Key('oroscopo_tradition_${tradition.name}'),
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.sm, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
          // L'accento del Maestro solo su quella scelta e viva: le altre
          // restano su una superficie sobria, comunque ben leggibile.
          gradient: selected
              ? LinearGradient(colors: [
                  palette.primary.withValues(alpha: 0.85),
                  palette.surfaceElevated.withValues(alpha: 0.85),
                ])
              : null,
          color:
              selected ? null : palette.surfaceElevated.withValues(alpha: 0.35),
          border: Border.all(
            color: palette.gold.withValues(alpha: selected ? 0.6 : 0.25),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TraditionGlyph(
              tradition: tradition,
              color: palette.goldSoft.withValues(alpha: locked ? 0.7 : 1.0),
              size: 22,
            ),
            const SizedBox(height: 3),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tradition.label,
                  style: TypographyTokens.etichetta().copyWith(
                    color: selected
                        ? palette.goldSoft
                        : ColorTokens.textSecondary
                            .withValues(alpha: locked ? 0.75 : 1.0),
                    letterSpacing: 0.5,
                  ),
                ),
                if (locked) ...[
                  const SizedBox(width: 3),
                  Icon(Icons.lock_rounded,
                      key: Key('oroscopo_tradition_lock_${tradition.name}'),
                      size: 10,
                      color: palette.goldSoft.withValues(alpha: 0.65)),
                ],
              ],
            ),
            if (locked)
              Text(
                'In arrivo$fase',
                key: Key('oroscopo_tradition_soon_${tradition.name}'),
                style: TypographyTokens.etichetta().copyWith(
                  color: palette.goldSoft.withValues(alpha: 0.6),
                  letterSpacing: 0.3,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Il micro messaggio del Maestro su una tradizione ancora chiusa.
///
/// Al posto del lucchetto muto risponde Medora in prima persona. Con Riduci
/// Movimento compare gia' posato, e dalla seconda volta in poi anche.
class _TraditionInvite extends StatelessWidget {
  const _TraditionInvite({
    required this.tradition,
    required this.maestro,
    required this.palette,
    required this.animate,
  });

  final AstroTradition? tradition;
  final Maestro maestro;
  final MaestroPalette palette;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final t = tradition;
    if (t == null) return const SizedBox.shrink();
    final immobile = MediaQuery.of(context).disableAnimations || !animate;
    final riga = Container(
      key: Key('tradition_invite_${t.name}'),
      margin: const EdgeInsets.only(top: SpacingTokens.sm),
      padding: const EdgeInsets.all(SpacingTokens.sm),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
        color: palette.surfaceElevated.withValues(alpha: 0.5),
        border: Border.all(color: palette.gold.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TraditionGlyph(tradition: t, color: palette.goldSoft, size: 20),
          const SizedBox(width: SpacingTokens.sm),
          Expanded(
            child: Text(
              t.invito,
              style: TypographyTokens.didascalia().copyWith(
                color: ColorTokens.textPrimary,
                height: 1.35,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
    if (immobile) return riga;
    return TweenAnimationBuilder<double>(
      key: ValueKey('tradition_invite_anim_${t.name}'),
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      builder: (context, v, child) => Opacity(
        opacity: v,
        child:
            Transform.translate(offset: Offset(0, (1 - v) * 8), child: child),
      ),
      child: riga,
    );
  }
}

class _PeriodTab extends StatelessWidget {
  const _PeriodTab({
    required this.period,
    required this.selected,
    required this.palette,
    required this.onTap,
  });

  final HoroscopePeriod period;
  final bool selected;
  final MaestroPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final locked = !period.unlocked;
    final tab = GestureDetector(
      key: Key('oroscopo_period_${period.name}'),
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
          gradient: selected
              ? LinearGradient(colors: [
                  palette.primary.withValues(alpha: 0.85),
                  palette.surfaceElevated.withValues(alpha: 0.85),
                ])
              : null,
          border: selected
              ? Border.all(color: palette.gold.withValues(alpha: 0.6))
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(period.label,
                style: TypographyTokens.etichetta().copyWith(
                  color: selected
                      ? palette.goldSoft
                      : ColorTokens.textSecondary
                          .withValues(alpha: locked ? 0.6 : 1.0),
                  letterSpacing: 0.6,
                )),
            if (locked) ...[
              const SizedBox(width: 4),
              Icon(Icons.lock_rounded,
                  key: Key('oroscopo_lock_${period.name}'),
                  size: 12,
                  color: palette.goldSoft.withValues(alpha: 0.65)),
            ],
          ],
        ),
      ),
    );
    if (!locked) return tab;
    return Tooltip(
      message:
          'L\'oroscopo della ${period.label.toLowerCase()} è del Cerchio Premium. Abbonati per aprirlo.',
      child: tab,
    );
  }
}

class _HoroscopeCardView extends StatelessWidget {
  const _HoroscopeCardView({
    required this.scrivendo,
    required this.durataScrittura,
    required this.card,
    required this.palette,
    required this.pulse,
    required this.depth,
    required this.onDepthSelected,
    required this.onDepthLocked,
    required this.premiumUnlocked,
    required this.giaScritto,
    required this.onScritto,
  });

  /// Se questo testo e' gia' stato scritto una volta: la macchina da
  /// scrivere non riparte, il testo nasce intero e fermo. E' un gancio e non
  /// un booleano: si legge alla rinascita, non alla costruzione.
  final bool Function() giaScritto;

  /// Chiamato quando la scrittura di questo testo finisce, per intero o per
  /// tocco: la schermata se lo segna accanto alla risposta.
  final VoidCallback onScritto;

  /// Se il responso si sta componendo adesso, a macchina da scrivere.
  ///
  /// Ordine 2171 voce 5: i testi non compaiono interi, si scrivono. Con
  /// Riduci Movimento compaiono interi lo stesso, perche' l'informazione non
  /// dipende dal moto.
  final bool scrivendo;

  /// Quanto ci mette un responso a scriversi per intero. La velocita' vive
  /// nella schermata e arriva qui dichiarata: chi la cambia la vede.
  final Duration durataScrittura;

  final HoroscopeCard card;
  final MaestroPalette palette;
  final Animation<double> pulse;
  final AnswerDepth depth;

  /// La scelta della profondita', che prima non aveva dove andare.
  final ValueChanged<AnswerDepth> onDepthSelected;
  final ValueChanged<AnswerDepth> onDepthLocked;

  /// Se la persona ha diritto alla profondita' Profonda. Arriva da chi
  /// conosce il piano, perche' una card non deve leggere l'abbonamento.
  final bool premiumUnlocked;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key('oroscopo_card_${card.domain.name}'),
      padding: const EdgeInsets.all(SpacingTokens.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
        // Blu e oro di Medora, come la card di condivisione.
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            palette.surfaceElevated.withValues(alpha: 0.95),
            Color.lerp(palette.surface, palette.deepest, 0.35)!
                .withValues(alpha: 0.92),
          ],
        ),
        border: Border.all(color: palette.gold.withValues(alpha: 0.32)),
        boxShadow: [
          BoxShadow(
            color: palette.glow.withValues(alpha: 0.16),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // In alto a sinistra titolo e categoria, in alto a destra la
          // profondita' della risposta.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(card.title,
                        style: TypographyTokens.titoloScheda()
                            .copyWith(color: palette.goldSoft, height: 1.1)),
                    Text(card.domain.label.toUpperCase(),
                        style: TypographyTokens.etichetta().copyWith(
                            color: ColorTokens.textSecondary,
                            letterSpacing: 1.4)),
                  ],
                ),
              ),
              const SizedBox(width: SpacingTokens.sm),
              // Menu a tendina compatto: ora le etichette sono corte, quindi
              // resta leggibile senza rubare spazio al titolo.
              AnswerDepthSelector(
                key: Key('oroscopo_depth_${card.domain.name}'),
                current: depth,
                palette: palette,
                // Chi ha pagato deve poter aprire la Profonda. Questo
                // parametro non veniva passato da nessuno in tutta l'app,
                // quindi restava falso e il lucchetto valeva anche per chi
                // l'aveva comprata: una funzione venduta e mai consegnata.
                premiumUnlocked: premiumUnlocked,
                onSelect: onDepthSelected,
                onLockedTap: onDepthLocked,
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.sm),
          // Poi l'infografica a cinque icone col numero, sotto il titolo.
          DomainLevel(
            domain: card.domain,
            value: card.indicator,
            palette: palette,
            pulse: pulse,
          ),
          const SizedBox(height: SpacingTokens.md),
          // L'apertura personalizzata col nome, prima del testo della Generale.
          if (card.opening != null) ...[
            Text(card.opening!,
                key: const Key('oroscopo_opening'),
                style: TypographyTokens.lettura().copyWith(
                    color: palette.goldSoft,
                    height: 1.5,
                    fontStyle: FontStyle.italic)),
            const SizedBox(height: SpacingTokens.sm),
          ],
          // IL RESPONSO SI COMPONE, ordine 2171 voce 5. **Un tocco sul testo
          // lo completa subito**: un'animazione da cui non si puo' uscire e'
          // una gabbia, e chi ha fretta non deve aspettare il rito.
          _ResponsoCheSiScrive(
            key: Key('oroscopo_testo_${card.domain.name}'),
            testo: card.text,
            durataScrittura: durataScrittura,
            scrivendo: scrivendo,
            giaScritto: giaScritto,
            onScritto: onScritto,
          ),
          if (card.domain == HoroscopeDomain.fortuna) ...[
            const SizedBox(height: SpacingTokens.md),
            _FortunaFooter(card: card, palette: palette),
          ],
        ],
      ),
    );
  }
}

/// La riga che dichiara da dove viene il testo, quando non viene dal cielo.
class _NotaDelCielo extends StatelessWidget {
  const _NotaDelCielo(
      {required this.testo, required this.palette, required this.completa});

  final String testo;
  final MaestroPalette palette;

  /// Vero quando qualche transito vero c'e' comunque: cambia solo l'icona,
  /// perche' "manca l'ora" e "manca tutto" non sono la stessa mancanza.
  final bool completa;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('oroscopo_nota_del_cielo'),
      padding: const EdgeInsets.all(SpacingTokens.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
        color: palette.deepest.withValues(alpha: 0.45),
        border: Border.all(color: palette.gold.withValues(alpha: 0.28)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(completa ? Icons.schedule_rounded : Icons.info_outline_rounded,
              size: 16, color: palette.goldSoft),
          const SizedBox(width: SpacingTokens.sm),
          Expanded(
            child: Text(testo,
                style: TypographyTokens.didascalia()
                    .copyWith(color: ColorTokens.textSecondary, height: 1.45)),
          ),
        ],
      ),
    );
  }
}

/// **LE TRE AZIONI SOTTO IL RESPONSO DELL\'OROSCOPO, ordine CG voci 06 e 08.**
///
/// Prima qui c\'era il solo Condividi, in oro pieno, con la sua attesa: quella
/// forma resta, perche\' e\' l\'invito che chiude il responso e non un accidente.
/// Accanto sono nati il Custodisci e il Parlane con Medora, e vengono dalla
/// porta sola che vale per tutte e tredici le arti col responso.
class _ShareBlock extends StatelessWidget {
  const _ShareBlock(
      {required this.palette,
      required this.sharing,
      required this.onShare,
      required this.segno,
      required this.testoDelResponso});

  final MaestroPalette palette;
  final bool sharing;
  final Future<bool> Function() onShare;
  final String segno;

  /// Il testo che si custodisce: le schede del cielo di oggi, in fila.
  final String testoDelResponso;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Porta il tuo cielo di oggi con te',
            textAlign: TextAlign.center,
            style: TypographyTokens.didascalia()
                .copyWith(color: ColorTokens.textSecondary)),
        const SizedBox(height: SpacingTokens.sm),
        AzioniDelResponso(
          palette: palette,
          maestro: Maestro.medora,
          dorato: true,
          responso: ResponsoDaCustodire(
            arte: 'oroscopo',
            titolo: 'Il tuo oroscopo, $segno',
            testo: testoDelResponso,
            dati: {'segno': segno},
          ),
          condividi: onShare,
          aperturaDellaChat: ChatOpeners.oroscopo(segno),
        ),
      ],
    );
  }
}

/// Il piede della scheda Fortuna: numero fortunato e colore del giorno.
class _FortunaFooter extends StatelessWidget {
  const _FortunaFooter({required this.card, required this.palette});

  final HoroscopeCard card;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Pill(
          label: 'Numero',
          palette: palette,
          child: Text('${card.luckyNumber}',
              style: TypographyTokens.titoloScheda()
                  .copyWith(color: palette.goldSoft)),
        ),
        const SizedBox(width: SpacingTokens.sm),
        Expanded(
          child: _Pill(
            label: 'Colore del giorno',
            palette: palette,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: oroscopoColor(card.dayColor) ?? palette.goldSoft,
                    border:
                        Border.all(color: palette.gold.withValues(alpha: 0.6)),
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(card.dayColor ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TypographyTokens.didascalia()
                          .copyWith(color: ColorTokens.textPrimary)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(
      {required this.label, required this.child, required this.palette});

  final String label;
  final Widget child;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.sm, vertical: SpacingTokens.xs),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusSm),
        color: palette.primary.withValues(alpha: 0.4),
        border: Border.all(color: palette.gold.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label.toUpperCase(),
              style: TypographyTokens.etichetta().copyWith(
                  color: ColorTokens.textSecondary, letterSpacing: 0.8)),
          const SizedBox(height: 2),
          child,
        ],
      ),
    );
  }
}

/// LE FASI DEL CONSULTO, ordine BK voci 02 e 03.
///
/// Una fase sola al posto di due booleani indipendenti. Il difetto che l'ha
/// resa necessaria: `_interrogato` e `_interrogazione` diventavano veri
/// insieme, e la combinazione "schede montate mentre la scrittura non e'
/// ancora cominciata" mostrava il responso intero. Qui quella combinazione non
/// esiste, perche' le schede appartengono a una fase che viene DOPO.
enum _FaseDelConsulto {
  /// Il cielo non e' stato ancora interrogato: c'e' il gesto, e nient'altro.
  attesa,

  /// Primo momento: il cielo si raccoglie, coi corpi veri attorno all'emblema.
  raccolta,

  /// Secondo momento: il fatto vero del giorno viene nominato.
  nomina,

  /// Il responso si compone, una scheda dopo l'altra.
  responso,
}
