import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/astro/night_sky.dart';
import '../../core/astro/zodiac.dart';
import '../../core/identity/birth_identity.dart';
import '../../core/identity/profile_controller.dart';
import '../../core/identity/natal_identity.dart';
import '../../core/astro/luogo_attuale.dart';
import '../../core/synastry/cielo_della_sinastria.dart';
import '../../core/synastry/cielo_del_giorno_sulla_coppia.dart';
import '../../core/synastry/possibilita_di_incontro.dart';
import '../../core/synastry/tempi_della_chiamata.dart';
import 'chiamata_del_vip.dart';
import '../../core/entitlement/entitlement_service.dart';
import '../../core/entitlement/question_allowance.dart';
import '../../core/entitlement/tier.dart';
import '../../core/synastry/collezione_delle_coppie.dart';
import '../pricing/upgrade_invite.dart';
import 'mappa_della_distanza.dart';
import 'ritratto_ingrandito.dart';
import '../../core/synastry/synastry_report.dart';
import '../../core/synastry/vip_catalog.dart';
import '../../design_system/components/cosmos_background.dart';
import '../../design_system/components/depth_card.dart';
import '../../design_system/components/vip_frame.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../design_system/typography/paragrafi_di_lettura.dart';
import 'sinastria_share_card.dart';
import 'user_photo.dart';
import '../../core/maestro/maestro.dart';
import '../../../design_system/components/titolo_che_non_si_rompe.dart';
import '../maestri/rotta_arte.dart';
import '../../core/condivisione/premio_della_condivisione.dart';

const List<String> _mesiItaliani = [
  'gennaio', 'febbraio', 'marzo', 'aprile', 'maggio', 'giugno', //
  'luglio', 'agosto', 'settembre', 'ottobre', 'novembre', 'dicembre'
];

/// Data di nascita per esteso, in italiano, per il cartiglio basso.
String italianLongDate(DateTime d) =>
    '${d.day} ${_mesiItaliani[d.month - 1]} ${d.year}';

/// Sinastria VIP: l'affinita' fra il tuo cielo e quello di un VIP.
///
/// Un VIP e' sempre precaricato, cosi' la Demo puo' aprirsi da qui in un tap dal
/// Santuario. Tutto e' deterministico per coppia (elemento, modalita', aspetto):
/// a parita' di segni il responso e le quattro barre non cambiano. E' un gioco
/// simbolico di intrattenimento, non una previsione.
class SinastriaVipScreen extends StatefulWidget {
  const SinastriaVipScreen({
    super.key,
    this.userSign,
    this.userName = 'Tu',
    this.userBirth,
    this.vip,
    this.photoController,
    this.saltaLaChiamata = false,
    this.primoVip,
    this.giaScoperta = false,
  });

  /// **LA PRIMA CASELLA, ordine BO voce 13.** Nulla vuol dire "sei tu", che e'
  /// il modo predefinito; un VIP la sostituisce e nasce il confronto fra due
  /// VIP. La seconda casella e' sempre un VIP.
  final Vip? primoVip;

  /// Vero quando la coppia si sta RIAPRENDO dalla collezione. **In quel caso
  /// non consuma niente**, decisione del fondatore: "no, non deve consumare".
  final bool giaScoperta;

  final Zodiac? userSign;

  /// Il VIP scelto nella galleria di apertura. Se nullo, apre sul primo del
  /// catalogo (per i test isolati che non passano dalla galleria).
  final Vip? vip;

  /// Nome dell'utente nel cartiglio del suo polo.
  final String userName;

  /// Data di nascita dell'utente, per il cartiglio. Se nulla, usa l'esempio.
  final DateTime? userBirth;

  /// Iniettabile nei test, cosi' la scelta foto non tocca camera ne galleria.
  final UserPhotoController? photoController;

  /// **Salta la chiamata e apre direttamente sul verdetto.** Serve alle
  /// anteprime e alle prove che guardano il RISULTATO: la scena della voce
  /// BO.06 ha una prova sua, e farla girare dentro ogni altra prova
  /// vorrebbe dire misurarla cinquanta volte per sbaglio.
  final bool saltaLaChiamata;

  static Route<void> route({
    Zodiac? userSign,
    String? userName,
    DateTime? userBirth,
    Vip? vip,
    Vip? primoVip,
    bool giaScoperta = false,
  }) {
    return MaterialPageRoute<void>(
      builder: (_) => MaestroScope(
        maestro: Maestro.medora,
        child: SinastriaVipScreen(
          userSign: userSign,
          userName: userName ?? 'Tu',
          userBirth: userBirth,
          vip: vip,
          primoVip: primoVip,
          giaScoperta: giaScoperta,
        ),
      ),
    );
  }

  @override
  State<SinastriaVipScreen> createState() => SinastriaVipScreenState();
}

class SinastriaVipScreenState extends State<SinastriaVipScreen>
    with SingleTickerProviderStateMixin {
  /// **IL VIP SEGUE IL WIDGET, e prima non lo faceva.** Era `late final`,
  /// quindi lo State restava sul primo VIP anche se il widget ne portava un
  /// altro. Nell'app non mordeva, perche' la schermata si apre sempre come
  /// rotta nuova; l'ha trovato una prova che rimontava la stessa scena con
  /// due VIP diversi e si vedeva ancora il primo. Un dato che ignora il suo
  /// widget e' un difetto anche quando nessuno ci passa: il giorno che questa
  /// scena diventera' una vista che cambia VIP senza cambiare rotta, sarebbe
  /// stato invisibile.
  Vip _vip = VipCatalog.first;
  late final UserPhotoController _photo =
      widget.photoController ?? UserPhotoController();
  final GlobalKey _cardKey = GlobalKey();
  /// **LA SCENA HA DUE FASI, ordine BO voci 06 e 07.** Prima la chiamata, che
  /// e' il rito; poi il verdetto, che si compone. Un fatto suo e non un
  /// booleano derivato: e' la stessa lezione del responso della stesa, dove
  /// due stati diversi che condividevano un valore facevano lampeggiare il
  /// testo.
  bool _verdettoInScena = false;

  /// **SE QUESTA COPPIA SI PUO' COMPORRE.** Nullo finche' non si e' guardato:
  /// la scena non parte e il verdetto resta coperto, perche' mostrarlo e poi
  /// chiedere di pagarlo sarebbe una porta aperta e richiusa in faccia.
  bool? _permesso;

  late final AnimationController _anim;
  bool _sharing = false;

  /// La card condivisibile vive nell'albero solo l'istante dello scatto, cosi'
  /// non raddoppia i testi a schermo ne pesa a ogni frame.
  bool _renderCard = false;

  Zodiac get _userSign =>
      widget.userSign ?? NightSky.sunSign(BirthIdentity.example.birthMoment);

  DateTime get _userBirth =>
      widget.userBirth ?? BirthIdentity.example.birthMoment;

  String get _userDate => italianLongDate(_userBirth);

  bool _seededFromProfile = false;

  /// **IL CIELO DELLA PERSONA, LETTO UNA VOLTA SOLA E FUORI DA build.**
  ///
  /// Ordine BO voce 02: il responso non nasce piu' dal segno solare ma dal
  /// cielo intero, e il cielo intero vuole data, ora e luogo, cioe' i dati
  /// che vivono in `BirthIdentityController`, nel guscio dell'app. Si legge
  /// in `didChangeDependencies` e non in `build` per la ragione imparata
  /// nell'ordine BN: un `context.watch` fuori da `build` ferma la scena.
  CieloDiSinastria? _cieloTuo;

  /// **DOVE SEI ADESSO, per la possibilita' di incontro.** Ordine BO voce 03.
  ///
  /// E' il luogo DICHIARATO, `LuogoAttuale`, cioe' dove vivi: non il luogo di
  /// nascita, che puo' essere dall'altra parte del mondo. Si legge dal disco
  /// una volta, e finche' non arriva vale il luogo di nascita, che e' meglio
  /// di niente e viene dichiarato nella riga che spiega il numero. Se non c'e'
  /// nemmeno quello, la distanza semplicemente non entra nel conto.
  DoveSei? _doveSei;

  /// **IL GIORNO PIU' ACCESO DEI PROSSIMI SEI MESI, ordine BO voce 12.**
  ///
  /// Si cerca UNA VOLTA e fuori dal disegno: sono centottantatre giorni di
  /// effemeridi, e farlo dentro `build` vorrebbe dire rifarlo a ogni
  /// fotogramma. Finche' non c'e', la riga della data non esiste, e la scena
  /// e' intera lo stesso.
  GiornoPiuAcceso? _giornoPiuAcceso;

  /// Il cielo da usare: quello vero della persona quando c'e', altrimenti
  /// quello dell'esempio, che e' lo stesso ripiego che questa schermata usava
  /// gia' per il segno.
  CieloDiSinastria get _cielo =>
      _cieloTuo ?? cieloDiRipiego(_userBirth, widget.userSign, widget.userName);

  /// **IL CIELO DI RIPIEGO, in una porta sola.** Anteprime e prove montano
  /// questa scena senza il guscio dell'app: qui il cielo nasce dalla data che
  /// la schermata ha in mano, col segno dichiarato perche' il cartiglio del
  /// polo e il calcolo non possano mai dire due segni diversi. E' pubblica
  /// perche' le prove che verificano cosa mostra la schermata devono poter
  /// chiedere lo STESSO cielo, invece di ricostruirne uno somigliante.
  static CieloDiSinastria cieloDiRipiego(
          DateTime nascita, Zodiac? segno, String nome) =>
      CieloDiSinastria.perNascita(
        momentoUtc: DateTime.utc(nascita.year, nascita.month, nascita.day,
            nascita.hour, nascita.minute),
        oraNota: false,
        latitudine: null,
        longitudineDelLuogo: null,
        segnoDichiarato: segno,
        nome: nome,
      );

  @override
  void initState() {
    super.initState();
    _vip = widget.vip ?? VipCatalog.first;
    _verdettoInScena = widget.saltaLaChiamata;
    // **IL VERDETTO SI COMPONE, ordine BO voce 07**: il conteggio, poi le
    // barre sfalsate, poi il titolo della coppia da solo. La durata la
    // dettano i tempi dichiarati, non un numero scritto qui.
    _anim = AnimationController(
      vsync: this,
      duration: TempiDelVerdetto.intera(quanteBarre: 4),
    );
    if (_verdettoInScena) _anim.forward();
    _photo.addListener(_onPhotoChanged);
    unawaited(_leggiDoveSei());
  }

  @override
  void didUpdateWidget(covariant SinastriaVipScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nuovo = widget.vip ?? VipCatalog.first;
    if (nuovo.name != _vip.name) setState(() => _vip = nuovo);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Il precompilato della foto legge l'avatar dal profilo, non solo la memoria
    // di questa schermata: se l'utente ha gia' un suo volto nel Cerchio, parte
    // da quello. Solo se il controller non e' iniettato dai test.
    if (_seededFromProfile || widget.photoController != null) return;
    _seededFromProfile = true;
    // Se il profilo non e' nell'albero (in alcuni test isolati), niente seed:
    // si resta al segnaposto, senza schianti.
    try {
      _photo.seed(context.read<ProfileController>().avatarPhoto);
    } catch (_) {}
    // La scansione dei sei mesi sta fuori dal disegno.
    WidgetsBinding.instance.addPostFrameCallback((_) => _cercaIlGiorno());
    // **IL CANCELLO SI GUARDA DOPO IL PRIMO FOTOGRAMMA**, quando l'albero
    // c'e' e un foglio si puo' aprire. Prima di allora il verdetto resta
    // coperto.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _permesso != null) return;
      setState(() => _permesso = laCoppiaSiPuoComporre());
    });
    // IL CIELO VERO DELLA PERSONA, dalla stessa porta che l'Oroscopo usa.
    // Se il guscio non c'e' (anteprime e prove isolate) resta il ripiego.
    try {
      final dettagli = context.read<BirthIdentityController>().details;
      if (dettagli != null) {
        // IL RIPIEGO DELLA DISTANZA: finche' il luogo dichiarato non arriva
        // dal disco, vale quello di nascita. E' una approssimazione, e la
        // riga che spiega il numero non la spaccia per altro.
        final nato = dettagli.place;
        if (_doveSei == null && nato != null) {
          _doveSei = DoveSei(
              citta: nato.label,
              latitudine: nato.latitude,
              longitudine: nato.longitude);
        }
        _cieloTuo = CieloDiSinastria.perNascita(
          momentoUtc: DateTime.utc(
            dettagli.date.year,
            dettagli.date.month,
            dettagli.date.day,
            dettagli.time?.hour ?? 12,
            dettagli.time?.minute ?? 0,
          ),
          oraNota: dettagli.hasTime,
          latitudine: dettagli.place?.latitude,
          longitudineDelLuogo: dettagli.place?.longitude,
          nome: widget.userName,
        );
      }
    } catch (errore) {
      // **SI IGNORA, E SI DICHIARA PERCHE'.** Il guscio dell'app non c'e' in
      // anteprima e in certe prove isolate, e li' `BirthIdentityController`
      // non e' nell'albero: chiederlo lancia. Non e' un errore da curare, e'
      // l'assenza del guscio, e la scena ha gia' il suo cielo di ripiego.
      // Qualunque altro errore qui vorrebbe dire un dato di nascita rotto, e
      // anche in quel caso la scena deve aprirsi col ripiego invece di
      // schiantarsi in faccia a chi ha toccato un VIP.
    }
  }

  /// Legge il luogo dichiarato dal disco. Se non c'e', resta il ripiego.
  Future<void> _leggiDoveSei() async {
    final luogo = await DoveSonoAdesso.letto();
    if (!mounted || luogo == null) return;
    setState(() => _doveSei = DoveSei(
        citta: luogo.citta,
        latitudine: luogo.lat,
        longitudine: luogo.lon));
  }

  /// La chiamata e' finita, oppure un tocco l'ha saltata: entra il verdetto,
  /// che comincia a comporsi.
  /// Un servizio del guscio, se c'e'. Torna nullo dove non c'e' nessun
  /// guscio, cioe' nelle anteprime e nelle prove che montano questa scena da
  /// sola: e' la stessa tolleranza gia' in uso nella stesa, e non e' un modo
  /// per rendere facoltativo il gating nell'app vera, che una guardia
  /// strutturale sorveglia leggendo `lib/app.dart`.
  T? _forse<T>(BuildContext context) {
    try {
      return context.read<T>();
    } catch (errore) {
      return null;
    }
  }

  void _mostraIlVerdetto() {
    if (!mounted || _verdettoInScena) return;
    setState(() => _verdettoInScena = true);
    _anim.forward(from: 0);
    _segnaLaCoppia();
  }

  /// **LA COPPIA ENTRA IN COLLEZIONE, E CONSUMA UNA VOLTA SOLA.**
  ///
  /// Ordine BO voce 13 punto 3: il consumo avviene alla PRIMA scoperta, quando
  /// il confronto e' compiuto, e mai per tocco. Riaprire una coppia gia'
  /// scoperta non consuma nulla.
  void _segnaLaCoppia() {
    if (widget.giaScoperta) return;
    final collezione = _forse<CollezioneDelleCoppie>(context);
    if (collezione == null) return;
    // **DUE CASELLE, DUE STRADE, UN SOLO RESPONSO.** Quando la prima casella
    // porta un VIP il confronto e' fra due VIP, e la possibilita' di incontro
    // non esiste: al suo posto c'e' quanto i loro mondi si sfiorano.
    final report = widget.primoVip == null
        ? SynastryReport.perCieli(tuo: _cielo, vip: _vip, doveSei: _doveSei)
        : SynastryReport.fraDueVip(primo: widget.primoVip!, vip2: _vip);
    final nuova = collezione.scopri(
      primo: widget.primoVip?.name ?? '',
      secondo: _vip.name,
      punteggio: report.overall,
      quando: DateTime.now(),
    );
    if (!nuova) return;
    final borsa = _forse<QuestionAllowance>(context);
    if (borsa == null) return;
    borsa.registraSinastria(
        _forse<EntitlementService>(context)?.tier ?? Tier.free);
  }

  /// **LE DUE STRADE A RISERVA FINITA, ordine BO voce 13 punto 3.**
  ///
  /// Il tocco non e' mai muto: si apre l'invito, si riscatta una sinastria col
  /// prezzo del server oppure si sale di livello, e a riscatto avvenuto il
  /// confronto riparte da solo. Il testo nomina le SINASTRIE e mai i confronti
  /// nel Cerchio, che sono un'altra cosa e un altro contatore.
  bool laCoppiaSiPuoComporre() {
    if (widget.giaScoperta) return true;
    final borsa = _forse<QuestionAllowance>(context);
    if (borsa == null) return true;
    final collezione = _forse<CollezioneDelleCoppie>(context);
    // Una coppia gia' in collezione si rilegge senza chiedere niente.
    if (collezione != null &&
        collezione.contiene(widget.primoVip?.name ?? '', _vip.name)) {
      return true;
    }
    final piano = _forse<EntitlementService>(context)?.tier ?? Tier.free;
    if (borsa.puoiComporreUnaCoppia(piano)) return true;
    final limite = borsa.limiteSinastrie(piano);
    final riscatto = corredoDelRiscatto(
      context,
      budget: 'sinastrie',
      cosaUna: 'una sinastria',
      onSuccesso: (_) {
        if (mounted) _mostraIlVerdetto();
      },
    );
    showUpgradeInvite(
      context,
      title: 'Le sinastrie di oggi sono finite',
      message: limite == 1
          ? 'La sinastria del giorno è stata fatta. Puoi riscattarne una con '
              'gli Eos, oppure salire di livello nel Cerchio.'
          : 'Le $limite sinastrie del giorno sono state fatte. Puoi '
              'riscattarne una con gli Eos, oppure salire di livello nel '
              'Cerchio.',
      riscattoLabel: riscatto.label,
      onRiscatta: riscatto.azione,
    );
    return false;
  }

  /// Cerca il giorno piu' acceso, una volta sola. Per chi non c'e' piu' non
  /// si cerca niente: la voce 04 resta com'e'.
  void _cercaIlGiorno() {
    if (!mounted || _giornoPiuAcceso != null) return;
    if (_vip.eScomparso || widget.primoVip != null) return;
    final suo = CieloDiSinastria.perVip(_vip);
    final trovato = GiornoPiuAcceso.cerca(
      aspetti: AspettiDiSinastria.fra(_cielo, suo),
      tuo: _cielo,
      suo: suo,
      da: DateTime.now(),
    );
    if (!mounted || trovato == null) return;
    setState(() => _giornoPiuAcceso = trovato);
  }

  void _onPhotoChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _photo.removeListener(_onPhotoChanged);
    // Se il controller e' nostro lo chiudiamo; se e' iniettato lo lascia il test.
    if (widget.photoController == null) _photo.dispose();
    _anim.dispose();
    super.dispose();
  }

  /// **COSA FA IL TOCCO SU UNA CARTA VIP. Ordine del fondatore del 28 agosto
  /// 2026**: "l'utente fa click sulla carta e puo' cambiare il vip", e la
  /// domanda che veniva dopo, "quando l'utente e' in modalita' confronto tra 2
  /// VIP, come fa a tornare a mettere se stesso?".
  ///
  /// Prima il tocco faceva una cosa sola, aprire il ritratto: chi voleva
  /// cambiare il VIP doveva tornare indietro e ricominciare, e chi era finito
  /// nel confronto fra due VIP non aveva nessuna strada per rimettersi al
  /// proprio posto. Adesso il tocco chiede cosa si vuole fare.
  Future<void> _cosaFareCon(Vip quale, {required bool eIlPrimo}) async {
    final palette = MaestroScope.of(context);
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: palette.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(SpacingTokens.radiusLg)),
      ),
      builder: (foglio) => SafeArea(
        child: Column(
          key: const Key('sinastria_scelte_carta'),
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              key: const Key('sinastria_apri_carta'),
              leading: Icon(Icons.zoom_in_rounded, color: palette.goldSoft),
              title: Text('Apri la carta di ${quale.name}',
                  style: TypographyTokens.didascalia()
                      .copyWith(color: ColorTokens.textPrimary)),
              onTap: () {
                Navigator.of(foglio).pop();
                mostraIlRitrattoIngrandito(context,
                    vip: quale, palette: palette);
              },
            ),
            ListTile(
              key: const Key('sinastria_cambia_questo_vip'),
              leading:
                  Icon(Icons.swap_horiz_rounded, color: palette.goldSoft),
              title: Text('Cambia questo VIP',
                  style: TypographyTokens.didascalia()
                      .copyWith(color: ColorTokens.textPrimary)),
              subtitle: Text('Torni alla galleria e ne scegli un altro',
                  style: TypographyTokens.etichetta()
                      .copyWith(color: ColorTokens.textSecondary)),
              onTap: () {
                Navigator.of(foglio).pop();
                Navigator.of(context).maybePop();
              },
            ),
            if (eIlPrimo)
              ListTile(
                key: const Key('sinastria_rimetti_te'),
                leading:
                    Icon(Icons.person_rounded, color: palette.goldSoft),
                title: Text('Rimetti te al posto di ${quale.name}',
                    style: TypographyTokens.didascalia()
                        .copyWith(color: ColorTokens.textPrimary)),
                onTap: () {
                  Navigator.of(foglio).pop();
                  Navigator.of(context).pushReplacement(
                    SinastriaVipScreen.route(
                      userSign: widget.userSign,
                      userName: widget.userName,
                      userBirth: widget.userBirth,
                      vip: _vip,
                      giaScoperta: true,
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    // **DUE CASELLE, DUE STRADE, UN SOLO RESPONSO.** Quando la prima casella
    // porta un VIP il confronto e' fra due VIP, e la possibilita' di incontro
    // non esiste: al suo posto c'e' quanto i loro mondi si sfiorano.
    final report = widget.primoVip == null
        ? SynastryReport.perCieli(tuo: _cielo, vip: _vip, doveSei: _doveSei)
        : SynastryReport.fraDueVip(primo: widget.primoVip!, vip2: _vip);

    return Scaffold(
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
        // **IL TITOLO NON SI ROMPE**, ordine S voce 05: a capo fra le
        // parole, la misura scende solo quanto serve, e non si tronca mai.
        // Col borsellino nella riga delle azioni lo spazio del titolo si e'
        // ristretto, e un `Text` nudo qui torna a mettere i puntini.
        title: TitoloCheNonSiRompe(
            testo: 'Sinastria VIP',
            stile: TypographyTokens.display(size: 20)),
        // IL BORSELLINO, ordine S voce 06: stesso segno, stesso angolo, in
        // ogni schermata della pratica. Un saldo che appare e scompare non
        // si impara.
        actions: const [AngoloDellaBarra()],
      ),
      // Il cosmo profondo avvolge la schermata, senza le figure di costellazione
      // a linee che finivano coperte dalle cornici: qui restano stelle,
      // nebulose, parallasse e stella cadente, un cielo pulito.
      body: CosmosBackground(
        seed: 18,
        showZodiac: false,
        child: SafeArea(
          child: Stack(
            children: [
              // Il verdetto sta sotto: durante la chiamata e' gia' composto
              // in albero ma coperto, cosi' al salto non c'e' nessuna attesa
              // di costruzione e il tocco arriva al risultato in un istante.
              _content(palette, report),
              // **LA CHIAMATA E LA SOVRAPPOSIZIONE, ordine BO voce 06.** Sta
              // sopra la scena e sotto la card dello scatto: e' la prima cosa
              // che accade dopo il tocco su un VIP.
              // Finche' il cancello non ha risposto, e quando ha risposto di
              // no, il verdetto resta coperto.
              if (!_verdettoInScena && _permesso != true)
                Positioned.fill(
                  child: ColoredBox(
                      color: palette.deepest,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(SpacingTokens.xl),
                          child: Text(
                            _permesso == null
                                ? 'Un momento...'
                                : 'Le sinastrie di oggi sono finite. '
                                    'Riscattane una con gli Eos, oppure sali '
                                    'di livello nel Cerchio.',
                            key: const Key('sinastria_riserva_finita'),
                            textAlign: TextAlign.center,
                            style: TypographyTokens.corpo()
                                .copyWith(color: ColorTokens.textSecondary),
                          ),
                        ),
                      )),
                ),
              if (!_verdettoInScena && _permesso == true)
                Positioned.fill(
                  child: ColoredBox(
                    color: palette.deepest.withValues(alpha: 0.92),
                    child: ChiamataDelVip(
                      vip: _vip,
                      tuo: _cielo,
                      aspetti: report.aspetti,
                      palette: palette,
                      riduciMovimento: _riduciMovimento,
                      onFinita: _mostraIlVerdetto,
                    ),
                  ),
                ),
              // La card condivisibile, disegnata fuori campo solo durante lo
              // scatto, cosi' e' pronta da catturare a immagine senza mostrarla.
              if (_renderCard)
                Positioned(
                  left: -3000,
                  top: 0,
                  child: RepaintBoundary(
                    key: _cardKey,
                    child: SinastriaShareCard(
                      report: report,
                      vip: _vip,
                      userSign: _userSign,
                      userName: widget.userName,
                      userDate: _userDate,
                      palette: palette,
                      userPhoto: _photo.bytes,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// **CON RIDUCI MOVIMENTO IL NUMERO APPARE GIA' SCRITTO**, ordine BO voce
  /// 07: non si conta, non si sale, non si sfalsa. La grandezza resta la
  /// stessa, cambia il modo di arrivarci.
  bool get _riduciMovimento => MediaQuery.of(context).disableAnimations;

  /// La frazione del conteggio, da 0 a 1.
  double get _quantoDelConteggio {
    if (_riduciMovimento) return 1;
    final tutto = _anim.duration!.inMilliseconds;
    final fino = TempiDelVerdetto.ilConteggio.inMilliseconds / tutto;
    return Curves.easeOutCubic
        .transform((_anim.value / fino).clamp(0.0, 1.0));
  }

  /// La frazione della barra [i], che parte sfalsata dalle altre.
  double _quantoDellaBarra(int i) {
    if (_riduciMovimento) return 1;
    final tutto = _anim.duration!.inMilliseconds;
    final inizio = (TempiDelVerdetto.ilConteggio +
                TempiDelVerdetto.fraUnaBarraELaltra * i)
            .inMilliseconds /
        tutto;
    final quanto = TempiDelVerdetto.unaBarra.inMilliseconds / tutto;
    return Curves.easeOutCubic
        .transform(((_anim.value - inizio) / quanto).clamp(0.0, 1.0));
  }

  /// La frazione della barra [i], per la prova che verifica lo sfalsamento.
  ///
  /// **Pubblica perche' lo sfalsamento non si vede da fuori.** Una barra a un
  /// decimo e una a due decimi disegnano quasi lo stesso pixel: misurarlo
  /// sull'immagine vorrebbe dire una soglia indovinata. Il fatto e' il
  /// numero, e il numero sta qui.
  @visibleForTesting
  double quantoDellaBarraPerLaProva(int i) => _quantoDellaBarra(i);

  /// La frazione del titolo della coppia, che arriva per ultimo.
  double get _quantoDelTitolo {
    if (_riduciMovimento) return 1;
    final tutto = _anim.duration!.inMilliseconds;
    final inizio =
        (tutto - TempiDelVerdetto.ilTitolo.inMilliseconds) / tutto;
    final quanto = TempiDelVerdetto.ilTitolo.inMilliseconds / tutto;
    return ((_anim.value - inizio) / quanto).clamp(0.0, 1.0);
  }

  Widget _content(MaestroPalette palette, SynastryReport report) {
    return ListView(
      key: const Key('sinastria_list'),
      padding: const EdgeInsets.fromLTRB(SpacingTokens.lg, kToolbarHeight,
          SpacingTokens.lg, SpacingTokens.xxxl),
      children: [
        // I due poli nella cornice VIP col cuore.
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              // **LA PRIMA CASELLA, ordine BO voce 13.** Sei tu in modo
              // predefinito, e un VIP ti puo' sostituire: da qui nascono tre
              // esperienze con una modifica sola.
              child: widget.primoVip == null
                  ? _Pole(
                      key: const Key('sinastria_pole_user'),
                      palette: palette,
                      sign: _userSign,
                      hint: _photo.hasPhoto
                          ? 'Modifica la tua foto'
                          : 'Aggiungi la tua foto',
                      onTap: _openPhotoSheet,
                      portrait: VipFramedPortrait(
                        palette: palette,
                        name: widget.userName,
                        date: _userDate,
                        sign: _userSign.symbol,
                        photo: _photo.bytes,
                      ),
                    )
                  : _Pole(
                      key: const Key('sinastria_pole_primo_vip'),
                      palette: palette,
                      sign: widget.primoVip!.sign,
                      hint: 'Apri o cambia ${widget.primoVip!.name}',
                      onTap: () => _cosaFareCon(widget.primoVip!,
                          eIlPrimo: true),
                      portrait: VipFramedPortrait(
                        palette: palette,
                        name: widget.primoVip!.name,
                        date: widget.primoVip!.note,
                        sign: widget.primoVip!.sign.symbol,
                        vipAsset: widget.primoVip!.fullPath,
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 90),
              child: Icon(Icons.favorite_rounded,
                  color: palette.goldSoft, size: 26),
            ),
            Expanded(
              child: _Pole(
                key: const Key('sinastria_pole_vip'),
                palette: palette,
                sign: _vip.sign,
                // **LA CARTA SI APRE AL TOCCO, ordine BO voce 08.** Era
                // l'unica cosa della scena a non rispondere al dito, ed e' il
                // difetto 2 del fondatore.
                hint: 'Apri o cambia ${_vip.name}',
                onTap: () => _cosaFareCon(_vip, eIlPrimo: false),
                // Il ritratto VIP con la sua cornice originale, senza aggiunte.
                portrait: VipFramedPortrait(
                  palette: palette,
                  name: _vip.name,
                  date: _vip.note,
                  sign: _vip.sign.symbol,
                  vipAsset: _vip.fullPath,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: SpacingTokens.lg),
        // Il cerchio grande con percentuale animata ed etichetta di fascia.
        Center(
          child: SizedBox(
            width: 180,
            height: 180,
            child: AnimatedBuilder(
              animation: _anim,
              builder: (context, _) {
                // **IL NUMERO SI COMPONE CONTANDO, ordine BO voce 07.** Il
                // conteggio prende la sua fetta della scena e finisce SUL
                // numero esatto: la curva arriva a uno, quindi l'ultimo
                // fotogramma non puo' che essere il numero del calcolo. Non
                // sale mai oltre, perche' la curva non supera mai uno.
                final t = _quantoDelConteggio;
                final shown = (report.overall * t).round();
                return CustomPaint(
                  key: const Key('sinastria_gauge'),
                  painter: SynastryGaugePainter(
                      percent: report.overall, palette: palette, progress: t),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('$shown%',
                            key: const Key('sinastria_numero'),
                            style: TypographyTokens.display(size: 36)
                                .copyWith(color: palette.goldSoft)),
                        // **IL TITOLO DELLA COPPIA ARRIVA PER ULTIMO, DA
                        // SOLO.** E' la frase che la persona porta via, e
                        // arriva quando tutto il resto ha finito di muoversi.
                        Opacity(
                          opacity: _quantoDelTitolo,
                          child: Text(report.band,
                              key: const Key('sinastria_fascia'),
                              textAlign: TextAlign.center,
                              style: TypographyTokens.etichetta().copyWith(
                                  color: ColorTokens.textSecondary,
                                  letterSpacing: 0.6)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: SpacingTokens.lg),
        // Il testo del responso, PRIMA delle barre.
        DepthCard(
          raised: true,
          padding: const EdgeInsets.all(SpacingTokens.lg),
          child: Text(report.reading,
              key: const Key('sinastria_reading'),
              style: TypographyTokens.body(size: 16)
                  .copyWith(color: ColorTokens.textPrimary, height: 1.5)),
        ),
        // **IL CIELO DEL GIORNO SU QUESTA COPPIA, ordine BO voce 12.** La
        // geografia dice se un incontro e' possibile, il cielo dice quando.
        // Nessuna di queste righe promette un incontro: dicono quando quel
        // legame e' piu' acceso.
        if (report.incontro.esiste && report.incontro.celeste != null) ...[
          const SizedBox(height: SpacingTokens.sm),
          Text(report.incontro.celeste!.riga,
              key: const Key('sinastria_cielo_del_giorno'),
              textAlign: TextAlign.center,
              style: TypographyTokens.didascalia()
                  .copyWith(color: ColorTokens.textSecondary, height: 1.4)),
          if (_giornoPiuAcceso != null) ...[
            const SizedBox(height: SpacingTokens.xxs),
            Text(_giornoPiuAcceso!.rigaDa(DateTime.now()),
                key: const Key('sinastria_giorno_acceso'),
                textAlign: TextAlign.center,
                style: TypographyTokens.didascalia()
                    .copyWith(color: palette.goldSoft, height: 1.4)),
          ],
        ],
        // **LA MAPPA DELLA DISTANZA, ordine BO voce 09.** C'e' solo quando
        // c'e' un incontro da misurare e si sa dove vivete tutti e due: per
        // chi non c'e' piu' non esiste in albero, come la sua barra.
        if (report.incontro.esiste &&
            report.incontro.sueCoordinate != null &&
            _doveSei != null) ...[
          const SizedBox(height: SpacingTokens.md),
          MappaDellaDistanza(
            incontro: report.incontro,
            doveSei: _doveSei!,
            palette: palette,
            riduciMovimento: _riduciMovimento,
          ),
        ],
        // **LA LETTURA SI ESPLORA, ordine BO voce 08.** I fili che si sono
        // accesi nella chiamata restano qui, toccabili: chi vuole sapere cosa
        // significa quell'aspetto lo tocca, invece di leggere un muro.
        if (report.aspettiPiuForti.isNotEmpty) ...[
          const SizedBox(height: SpacingTokens.md),
          Wrap(
            key: const Key('sinastria_fili_toccabili'),
            spacing: SpacingTokens.sm,
            runSpacing: SpacingTokens.sm,
            children: [
              for (final a in report.aspettiPiuForti)
                GestureDetector(
                  key: Key('sinastria_filo_${a.titolo}'),
                  onTap: () => mostraIlSignificatoDellAspetto(context,
                      aspetto: a, palette: palette),
                  child: Container(
                    // Il bersaglio non scende sotto i 48 punti di altezza,
                    // che e' la misura minima del dito.
                    constraints: const BoxConstraints(minHeight: 48),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(
                        horizontal: SpacingTokens.md),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(SpacingTokens.radiusPill),
                      color: palette.surface.withValues(alpha: 0.5),
                      border: Border.all(
                          color: palette.gold.withValues(alpha: 0.5)),
                    ),
                    child: Text(a.titolo,
                        style: TypographyTokens.etichetta().copyWith(
                            color: palette.goldSoft, letterSpacing: 0.4)),
                  ),
                ),
            ],
          ),
        ],
        // **L'EREDITA', per chi non c'e' piu'. Ordine BO voce 04.**
        //
        // Sta al posto in cui, per chi e' in vita, la scena spinge verso
        // l'incontro. La domanda cambia, e cambia anche il tono: nessuna
        // percentuale, nessuna mappa, nessuna promessa.
        if (report.eredita != null) ...[
          const SizedBox(height: SpacingTokens.md),
          DepthCard(
            padding: const EdgeInsets.all(SpacingTokens.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('QUELLO CHE RESTA',
                    key: const Key('sinastria_eredita_titolo'),
                    style: TypographyTokens.etichetta().copyWith(
                        color: palette.goldSoft, letterSpacing: 1.4)),
                const SizedBox(height: SpacingTokens.xs),
                // Il narrato passa dalla porta comune dei paragrafi, e la
                // misura viene dal RUOLO: una cifra scritta a mano qui
                // sarebbe la duecentoventinovesima dell'app.
                ParagrafiDiLettura(
                    key: const Key('sinastria_eredita'),
                    testo: report.eredita!,
                    stile: TypographyTokens.lettura()
                        .copyWith(color: ColorTokens.textPrimary)),
              ],
            ),
          ),
        ],
        const SizedBox(height: SpacingTokens.md),
        // Le barre infografica animate: quattro per chi c'e', tre per chi non
        // c'e' piu', perche' la barra dell'incontro non esiste proprio.
        DepthCard(
          padding: const EdgeInsets.all(SpacingTokens.lg),
          child: AnimatedBuilder(
            animation: _anim,
            builder: (context, _) {
              final barre = report.bars;
              return Column(
                children: [
                  for (final bar in barre) ...[
                    // **LE BARRE PARTONO SFALSATE, ordine BO voce 07**:
                    // quattro barre che partono insieme sono un'unica
                    // animazione con quattro teste, e l'occhio non sa dove
                    // guardare.
                    SynastryBarRow(
                        bar: bar,
                        palette: palette,
                        progress: _quantoDellaBarra(barre.indexOf(bar)),
                        meetingReport: report),
                    if (bar != report.bars.last)
                      const SizedBox(height: SpacingTokens.sm),
                  ],
                ],
              );
            },
          ),
        ),
        const SizedBox(height: SpacingTokens.lg),
        // Il rilancio e il tasto Condividi.
        Text(SynastryReport.challengeLine(_vip.name),
            textAlign: TextAlign.center,
            style: TypographyTokens.corpo()
                .copyWith(color: ColorTokens.textSecondary, height: 1.4)),
        const SizedBox(height: SpacingTokens.sm),
        Center(
          child: FilledButton.icon(
            key: const Key('sinastria_share'),
            onPressed: _sharing ? null : _onShare,
            style: FilledButton.styleFrom(
              backgroundColor: palette.gold,
              foregroundColor: palette.deepest,
              padding: const EdgeInsets.symmetric(
                  horizontal: SpacingTokens.xl, vertical: SpacingTokens.sm),
            ),
            icon: _sharing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.ios_share_rounded, size: 18),
            label: Text(
            _sharing
                ? 'Preparo la card'
                : PremioDellaCondivisione.etichetta(context),
                style: TypographyTokens.label(size: 13)
                    .copyWith(letterSpacing: 0.6)),
          ),
        ),
        const SizedBox(height: SpacingTokens.lg),
        // Il selettore in fondo non c'e' piu': la scelta del VIP si fa nella
        // galleria di apertura. Da qui un tasto per tornarci e cambiare VIP.
        Center(
          child: OutlinedButton.icon(
            key: const Key('sinastria_change_vip'),
            onPressed: () => Navigator.of(context).maybePop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: palette.goldSoft,
              side: BorderSide(color: palette.gold.withValues(alpha: 0.6)),
              padding: const EdgeInsets.symmetric(
                  horizontal: SpacingTokens.xl, vertical: SpacingTokens.sm),
            ),
            icon: const Icon(Icons.swap_horiz_rounded, size: 18),
            label: Text('Cambia VIP',
                style: TypographyTokens.label(size: 13)
                    .copyWith(letterSpacing: 0.6)),
          ),
        ),
      ],
    );
  }

  Future<void> _onShare() async {
    setState(() {
      _sharing = true;
      _renderCard = true;
    });
    try {
      // Assicura il ritratto del VIP e la cornice decodificati, poi lascia un
      // paio di frame perche' la card fuori campo sia disegnata prima dello scatto.
      if (_vip.fullPath != null) {
        await precacheImage(AssetImage(_vip.fullPath!), context);
      }
      if (mounted) {
        await precacheImage(const AssetImage(VipFrame.asset), context);
      }
      await WidgetsBinding.instance.endOfFrame;
      await Future<void>.delayed(const Duration(milliseconds: 80));
      final andata = await shareSynastryCard(
        boundaryKey: _cardKey,
        text: SynastryReport.challengeLine(_vip.name),
      );
if (andata && mounted) {
  // Ordine BG voce 04: il premio dichiarato sul pulsante si paga qui,
  // a condivisione davvero avvenuta.
  await PremioDellaCondivisione.premia(context,
      cosa: 'Hai condiviso la sinastria');
}
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Non riesco a preparare la card ora.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _sharing = false;
          _renderCard = false;
        });
      }
    }
  }

  // Il foglio di consenso alla foto: scelta esplicita, con la promessa che la
  // foto resta sul dispositivo ed entra solo nella card condivisa.
  Future<void> _openPhotoSheet() async {
    final palette = context.palette;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: palette.surface,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(SpacingTokens.radiusLg)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(SpacingTokens.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('La tua foto nella cornice',
                    style: TypographyTokens.display(size: 18)
                        .copyWith(color: palette.goldSoft)),
                const SizedBox(height: SpacingTokens.sm),
                Text(
                    'La foto resta sul tuo dispositivo. Entra solo nella card che decidi di condividere, senza mai essere caricata da nessuna parte. Se preferisci, resta il tuo avatar a costellazione.',
                    style: TypographyTokens.corpo().copyWith(
                        color: ColorTokens.textSecondary, height: 1.4)),
                const SizedBox(height: SpacingTokens.lg),
                FilledButton.icon(
                  key: const Key('photo_camera'),
                  style: FilledButton.styleFrom(
                      backgroundColor: palette.gold,
                      foregroundColor: palette.deepest),
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    _photo.pickFrom(UserPhotoSource.camera);
                  },
                  icon: const Icon(Icons.photo_camera_rounded, size: 18),
                  label: const Text('Usa la fotocamera'),
                ),
                const SizedBox(height: SpacingTokens.sm),
                OutlinedButton.icon(
                  key: const Key('photo_gallery'),
                  style: OutlinedButton.styleFrom(
                      foregroundColor: palette.goldSoft,
                      side: BorderSide(
                          color: palette.gold.withValues(alpha: 0.6))),
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    _photo.pickFrom(UserPhotoSource.gallery);
                  },
                  icon: const Icon(Icons.photo_library_rounded, size: 18),
                  label: const Text('Scegli dalla galleria'),
                ),
                if (_photo.hasPhoto) ...[
                  const SizedBox(height: SpacingTokens.sm),
                  TextButton.icon(
                    key: const Key('photo_clear'),
                    style: TextButton.styleFrom(
                        foregroundColor: ColorTokens.textSecondary),
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      _photo.clear();
                    },
                    icon: const Icon(Icons.close_rounded, size: 18),
                    label: const Text('Togli la foto, torna alla costellazione'),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Pole extends StatelessWidget {
  const _Pole({
    super.key,
    required this.palette,
    required this.sign,
    required this.portrait,
    this.hint,
    this.onTap,
  });

  final MaestroPalette palette;
  final Zodiac sign;
  final Widget portrait;

  /// Suggerimento sotto il polo dell'utente, per invitare alla foto.
  final String? hint;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          portrait,
          const SizedBox(height: SpacingTokens.sm),
          Text(sign.italianName,
              style: TypographyTokens.etichetta()
                  .copyWith(color: palette.goldSoft, letterSpacing: 0.6)),
          if (hint != null) ...[
            const SizedBox(height: 2),
            Text(hint!,
                textAlign: TextAlign.center,
                style: TypographyTokens.etichetta().copyWith(
                    color: ColorTokens.textSecondary, letterSpacing: 0.3)),
          ],
        ],
      ),
    );
  }
}
