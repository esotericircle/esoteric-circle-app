import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/diagnosi/briciole.dart';
import '../../core/cammino/cammino_da_custodire.dart';
import '../../core/cammino/ritrovamento.dart';
import '../../core/cammino/custode_del_cammino.dart';
import '../account/custodia_del_cielo.dart';
import '../../core/astro/birth_details.dart';
import '../../core/astro/birth_place.dart' as astro;
import '../../core/astro/city_catalog.dart';
import '../../core/astro/night_sky.dart';
import '../../core/astro/zodiac.dart';
import '../../core/chat/user_profile.dart';
import '../../core/identity/birth_identity.dart';
import '../../core/identity/birth_place.dart';
import '../../core/identity/account_del_cerchio.dart';
import '../../core/identity/circle_seal.dart';
import '../../core/identity/identity_controller.dart';
import '../../core/identity/profile_controller.dart';
import '../../design_system/components/cosmos_background.dart';
import '../../design_system/components/zodiac_wheel.dart' show drawZodiacGlyph;
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import 'anteprima_tono.dart';
import 'astrolabio.dart';
import 'orologio_dinamico.dart';
import 'planisfero.dart';
import 'risveglio_ignitions.dart';
import 'sigillo_step.dart';
import 'risveglio_journey.dart';

/// "Il Risveglio": la primissima soglia del cerchio, un rituale a passi sul
/// cosmo, mostrato una sola volta al primo avvio prima del Santuario.
///
/// Non piu' un semplice saluto: il Cerchio accoglie, poi la persona attraversa i
/// passi che compongono il suo cielo. La data, e nasce il Sole nel segno (reale,
/// dalla tavola tropicale). L'ora, e sorge l'Ascendente (calcolato dal motore:
/// il calcolo vero arrivera' dal motore a effemeridi); se non la sa, si salta con
/// grazia. Il luogo, e il cielo si ancora alla Terra. Il nome. Il vocativo.
/// Infine il sigillo, che pulsa come un cuore. Ogni passo ha la sua accensione
/// disegnata dal codice, ridotta sotto Riduci Movimento.
///
/// Nessun Maestro compare qui: al Risveglio non e' ancora stato scelto, quindi
/// nessun colore di Maestro. La base e' la tavolozza cosmica neutra del Cerchio
/// (fondo nero, oro, nebulose viola): il Maestro si rivela solo alla fine.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, this.clock, this.ritrovata});

  /// **CIO' CHE IL CERCHIO AVEVA GIA', ordine AP voce 05.** Chi rientra col
  /// suo account non deve ridare cio' che ha gia' dato: i passi che il
  /// Cerchio conosce si trovano compilati e il rito comincia dal primo che
  /// manca davvero. Con tutto ritrovato questa schermata non si monta
  /// affatto, e a deciderlo e' `Ritrovamento`, in un punto solo.

  /// Orologio iniettabile per i test. Di default l'ora locale.
  final DateTime Function()? clock;
  final IdentitaDaCustodire? ritrovata;

  static Route<void> route({
    DateTime Function()? clock,
    IdentitaDaCustodire? ritrovata,
  }) {
    // Il cosmo di fondo legge la palette dal MaestroScope: la rotta lo porta con
    // se', cosi' vive anche fuori dalla home (dove sta l'altro MaestroScope).
    return MaterialPageRoute<void>(
      builder: (_) => MaestroScope(
          child: OnboardingScreen(clock: clock, ritrovata: ritrovata)),
      fullscreenDialog: false,
    );
  }

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

/// LA PORTA PICCOLA PER CHI TORNA. Ordine AP voce 04.
///
/// **I testi sono di Mauro, e stanno qui perche' si possano cambiare senza
/// toccare altro.** La riga principale dice chi sei, quella di servizio dice
/// cosa succede: la seconda e' piu' smorzata, perche' la prima e' la
/// domanda e la seconda e' solo la risposta.
class _PortaPerChiTorna extends StatelessWidget {
  const _PortaPerChiTorna({
    required this.palette,
    required this.onTap,
    this.riconosciuto = false,
  });

  final MaestroPalette palette;
  final VoidCallback onTap;

  /// **IL TELEFONO PROPONE GIA' UN ACCOUNT.** Ordine AZ voce 02.
  ///
  /// Quando e' vero, chi sta guardando questo schermo con ogni probabilita'
  /// **non e' un ospite nuovo**: e' qualcuno che ha reinstallato. Vedi il
  /// perche' del risalto sul commento di `build`.
  final bool riconosciuto;

  static const String riga = 'Faccio già parte del Cerchio';
  static const String rigaDiServizio = 'Accedi e ritrova il tuo cammino';

  @override
  Widget build(BuildContext context) {
    // **LA PORTA PER CHI TORNA E' UN PULSANTE, sempre.** Ordine AZ voce 02,
    // e la prima stesura era sbagliata: si dava risalto solo quando il
    // telefono proponeva gia' un account.
    //
    // **Quel risalto non poteva scattare proprio nel caso che doveva
    // servire**, ed e' stato misurato sul telefono del fondatore, due volte,
    // anche su installazione pulita. Il nome proposto arriva da
    // `GoogleSignIn().signInSilently()`, che **si appoggia a un accesso
    // precedente di QUESTA installazione**: dopo una disinstallazione quella
    // memoria non c'e' piu', quindi risponde nulla. Chi reinstalla, cioe'
    // esattamente chi deve rientrare, non vedeva mai il bentornato.
    //
    // Non si puo' indovinare chi e'. **Si puo' pero' non nascondergli la
    // porta**: prima era una scritta smorzata sotto il richiamo del rito, e
    // chi reinstallava prendeva la strada grande, rifaceva il rito, e per
    // finirlo inventava dei dati. Adesso e' un pulsante con la sua cornice,
    // che resta secondario rispetto a "Inizia il rito" ma **si vede che si
    // puo' toccare**.
    //
    // Col bentornato, quando c'e', il pulsante si riempie: chi viene
    // riconosciuto merita di piu' di chi viene solo accolto.
    if (riconosciuto) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton(
          key: const Key('onboarding_porta_per_chi_torna'),
          onPressed: onTap,
          style: FilledButton.styleFrom(
            backgroundColor: palette.surfaceElevated,
            foregroundColor: palette.goldSoft,
            side: BorderSide(color: palette.gold.withValues(alpha: 0.55)),
            padding: const EdgeInsets.symmetric(vertical: SpacingTokens.md),
          ),
          child: _corpo(),
        ),
      );
    }
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        key: const Key('onboarding_porta_per_chi_torna'),
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.goldSoft,
          side: BorderSide(color: palette.gold.withValues(alpha: 0.40)),
          padding: const EdgeInsets.symmetric(vertical: SpacingTokens.sm),
        ),
        child: _corpo(),
      ),
    );
  }

  /// Le due righe della porta, uguali in tutti e due i casi: cambia la
  /// cornice, non cio' che si legge.
  Widget _corpo() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          riga,
          textAlign: TextAlign.center,
          style: TypographyTokens.etichetta().copyWith(color: palette.goldSoft),
        ),
        const SizedBox(height: 2),
        Text(
          rigaDiServizio,
          textAlign: TextAlign.center,
          style: TypographyTokens.didascalia()
              .copyWith(color: ColorTokens.textSecondary),
        ),
      ],
    );
  }
}

/// I passi del rituale, in ordine. L'accoglienza apre, il sigillo chiude.
enum _Step { accoglienza, data, ora, luogo, nome, vocativo, sigillo }

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ignite;

  // La tavolozza cosmica neutra del Cerchio: nessun accento di Maestro, che al
  // Risveglio non e' ancora scelto. Fondo nero, oro, alone viola desaturato.
  static const MaestroPalette _palette = MaestroPalette.neutral;

  _Step _step = _Step.accoglienza;

  /// **DA DOVE COMINCIA IL RITO, ordine AP voce 05.** Con niente di
  /// ritrovato si comincia dall'accoglienza, come sempre. Con qualcosa di
  /// ritrovato i passi gia' noti restano indietro: chi ha dato il giorno ma
  /// non l'ora si vede chiedere l'ora, non tutto da capo.
  void _riprendiCioCheIlCerchioSapeva() {
    final ritrovata = widget.ritrovata;
    if (ritrovata == null) return;
    final giorno = ritrovata.giorno;
    if (giorno != null) _birthDate = giorno;
    final ora = ritrovata.ora?.split(':');
    if (ora != null && ora.length == 2) {
      _hour = int.tryParse(ora[0]);
      _minute = int.tryParse(ora[1]);
      _timeKnown = _hour != null;
    }
    if (ritrovata.nome != null) _nameCtrl.text = ritrovata.nome!;
    final mancanti = Ritrovamento.da(
      CamminoDaCustodire(identita: ritrovata),
    ).passiDaChiedere;
    if (mancanti.isEmpty) return;
    // Il primo passo che manca davvero, nell'ordine del rito.
    _step = switch (mancanti.first) {
      PassoDelRito.data => _Step.data,
      PassoDelRito.ora => _Step.ora,
      PassoDelRito.luogo => _Step.luogo,
      PassoDelRito.nome => _Step.nome,
    };
  }

  // I dati raccolti lungo il rituale.
  DateTime _birthDate = DateTime(1990, 6, 15);
  // Nessuna delle due strade e' preselezionata, e nulla e' vero finche' la
  // persona non sceglie. Prima l'ora arrivava gia' compilata, quindi si dava
  // per scontato che la sapesse; poi era preselezionato "Non la so", quindi
  // si dava per scontato il contrario, che e' lo stesso errore ribaltato.
  // Null vuol dire "non ha ancora detto".
  bool? _timeKnown;
  // Nulli finche' non si sceglie: cosi' la pillola mostra l'invito "Ora" e
  // "Minuti" invece di dichiarare 12 e 00, che e' un'ora che nessuno ha
  // scelto e che finiva dritta nella carta natale.
  int? _hour;
  int? _minute;
  BirthPlace? _place;
  final TextEditingController _placeCtrl = TextEditingController();
  final FocusNode _luogoFocus = FocusNode();
  /// Dove sta l'elenco dei suggerimenti nell'albero, per poterlo portare sotto
  /// gli occhi quando la tastiera lo spinge fuori.
  final GlobalKey _luogoElenco = GlobalKey();
  List<City> _placeResults = const [];
  final TextEditingController _nameCtrl = TextEditingController();
  CourtesyForm? _courtesy;

  @override
  void initState() {
    super.initState();
    Briciole.lascia('onboarding_entrato');
    _riprendiCioCheIlCerchioSapeva();
    _chiediSeIlTelefonoPropone();
    _ignite = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    // L'elenco dei luoghi si carica una volta sola, in sottofondo: sono
    // undicimila righe e non devono far aspettare l'accoglienza. Chi digita
    // prima che sia pronto cerca nel seme, e appena l'elenco pieno arriva la
    // ricerca si rifa' da sola, cosi' nessuna battuta va persa.
    CityCatalog.ensureLoaded().then((_) {
      if (!mounted) return;
      if (_placeCtrl.text.trim().isNotEmpty) _searchPlace(_placeCtrl.text);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _playIgnition();
  }

  @override
  void dispose() {
    _ignite.dispose();
    _luogoFocus.dispose();
    _placeCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  bool get _reduceMotion => MediaQuery.of(context).disableAnimations;

  void _playIgnition() {
    if (_reduceMotion) {
      _ignite.value = 1.0; // gia' accesa, senza moto
    } else {
      _ignite
        ..reset()
        ..forward();
    }
  }

  Zodiac get _sunSign => NightSky.sunSign(_birthDate);

  BirthIdentity get _identity => BirthIdentity.fromParts(
        birthDate: _birthDate,
        birthHour: _timeKnown == true ? _hour : null,
        birthMinute: _timeKnown == true ? _minute : null,
        birthPlace: _place,
      );

  String get _name =>
      _nameCtrl.text.trim().isEmpty ? 'Anima del Cerchio' : _nameCtrl.text.trim();

  /// Torna al passo precedente, per correggere un dato sbagliato.
  ///
  /// Il rito andava in una direzione sola: chi sbagliava data, ora o luogo non
  /// aveva modo di rimediare. Un dato di nascita sbagliato resta sbagliato in
  /// tutte le letture che ne discendono, quindi tornare indietro non e' una
  /// comodita', e' parte del rito.
  void _goBack() {
    final i = _step.index;
    if (i > 0) {
      setState(() => _step = _Step.values[i - 1]);
      _playIgnition();
    }
  }

  void _goNext() {
    const order = _Step.values;
    final i = _step.index;
    if (i < order.length - 1) {
      setState(() => _step = order[i + 1]);
      _playIgnition();
    }
  }

  /// Sigilla il rito: salva il profilo (fonte unica), costruisce il ponte verso
  /// il motore della carta natale e apre la coda del Risveglio (cielo reale,
  /// carta, risonanza, rivelazione del Maestro).
  void _finish() {
    final courtesy = _courtesy ?? CourtesyForm.neutral;
    final name = _nameCtrl.text.trim();

    // Fonte unica d'identita': il Risveglio scrive nel ProfileController e nel
    // IdentityController (nome e forma), senza raccogliere nulla due volte.
    final profile = context.read<ProfileController>();
    profile.setProfile(UserProfile(
      displayName: name.isEmpty ? null : name,
      courtesyForm: courtesy,
    ));
    profile.setIdentity(_identity);

    final ident = context.read<IdentityController>();
    ident.setName(name);
    ident.setForm(_addressForm(courtesy));

    // Ponte: dai dati raccolti nasce il BirthDetails che alimenta la carta.
    final details = BirthDetails(
      date: _birthDate,
      // L'ora conta solo se e' stata davvero scelta. I minuti non scelti
      // valgono zero, che e' il modo in cui si dice "alle sette" intendendo
      // le sette in punto.
      time: _timeKnown == true && _hour != null
          ? TimeOfDay(hour: _hour!, minute: _minute ?? 0)
          : null,
      place: _placeForChart(),
      gender: _genderFor(courtesy),
    );
    Navigator.of(context)
        .pushReplacement(RisveglioJourney.route(details: details));
  }

  // Il luogo per la carta: quello scelto, oppure nessuno.
  //
  // Qui prima si fabbricava un ripiego a latitudine zero, longitudine zero e
  // fuso UTC, cioe' un punto in mezzo al Golfo di Guinea, e la carta natale
  // veniva chiesta per quel punto: l'Ascendente e le dodici case che la persona
  // leggeva come proprie erano di quel punto, mentre la schermata prometteva il
  // cielo autentico della sua notte. Chi salta il luogo non riceve piu' numeri
  // presi altrove, riceve quel che dalla sola data si calcola davvero.
  astro.BirthPlace? _placeForChart() {
    final p = _place;
    if (p == null) return null;
    return astro.BirthPlace(
      label: p.city,
      latitude: p.latitude,
      longitude: p.longitude,
      timezone: p.timeZoneId,
    );
  }

  static AddressForm _addressForm(CourtesyForm c) {
    switch (c) {
      case CourtesyForm.feminine:
        return AddressForm.feminine;
      case CourtesyForm.masculine:
        return AddressForm.masculine;
      case CourtesyForm.neutral:
      case CourtesyForm.unknown:
        return AddressForm.neutral;
    }
  }

  static Gender _genderFor(CourtesyForm c) {
    switch (c) {
      case CourtesyForm.feminine:
        return Gender.female;
      case CourtesyForm.masculine:
        return Gender.male;
      case CourtesyForm.neutral:
      case CourtesyForm.unknown:
        return Gender.unspecified;
    }
  }

  void _searchPlace(String query) {
    // **UN SOLO CANDIDATO NON E' UNA SCELTA, E' GIA' LA RISPOSTA.** Chi scrive
    // per intero il nome della propria citta' ha gia' detto tutto: se in
    // catalogo quel nome e' unico, il luogo si sceglie da solo e nessuno gli
    // chiede di confermare cio' che ha appena scritto. Se il nome e' ambiguo
    // qui non succede niente, perche' quale sia delle due lo sa solo lei.
    final unica = CityCatalog.unicaEsatta(query);
    if (unica != null) {
      setState(() {
        _place = unica.toPlace();
        _placeResults = const [];
      });
      return;
    }
    setState(() {
      _placeResults = CityCatalog.search(query);
      // Se stava riscrivendo, la scelta di prima non vale piu': tenerla
      // farebbe partire un cielo calcolato su una citta' che nel campo non
      // c'e' piu'.
      if (_place != null && _placeCtrl.text.trim() != _place!.city) {
        _place = null;
      }
    });
  }

  /// Cosa dice il pulsante al passo del luogo, e cosa fa.
  ///
  /// **QUI STAVA LA TRAPPOLA.** L'etichetta guardava solo se il luogo era
  /// stato scelto, quindi a chi aveva scritto per intero il nome della propria
  /// citta' senza toccare l'elenco diceva "Salta per ora". La persona la
  /// premeva credendo di confermare, e restava senza luogo per mesi. Adesso
  /// l'etichetta guarda anche il CAMPO: con del testo scritto non si parla mai
  /// di saltare, perche' chi ha scritto non sta saltando.
  ///
  /// Saltare resta possibile in tutti i casi, ma come gesto voluto: o il campo
  /// e' vuoto, o il luogo scritto non esiste in elenco e il pulsante lo dice.
  ({String etichetta, VoidCallback azione}) _invitoDelLuogo() {
    if (_place != null) {
      return (etichetta: 'Continua', azione: _goNext);
    }
    final scritto = _placeCtrl.text.trim();
    if (scritto.isEmpty) {
      return (etichetta: 'Salta per ora', azione: _goNext);
    }
    if (_placeResults.isEmpty) {
      // Il luogo scritto non e' in elenco: proseguire e' l'unica strada che
      // resta, e il pulsante dice esattamente cosa succede invece di
      // chiamarlo un salto.
      return (etichetta: 'Prosegui senza il luogo', azione: _goNext);
    }
    // Ci sono candidati: il pulsante porta alla scelta, non oltre.
    return (
      etichetta: 'Scegli la città',
      azione: () {
        _luogoFocus.requestFocus();
        _mostraISuggerimenti();
      }
    );
  }

  /// Porta l'elenco dei suggerimenti dentro la parte di schermo che la persona
  /// vede davvero, cioe' sopra la tastiera e sopra il pulsante.
  void _mostraISuggerimenti() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _luogoElenco.currentContext;
      if (ctx == null) return;
      Scrollable.ensureVisible(
        ctx,
        alignment: 0.5,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _pickCity(City city) {
    setState(() {
      _place = city.toPlace();
      _placeCtrl.text = city.label;
      _placeResults = const [];
    });
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Il gesto Indietro di sistema NON butta fuori dal rito: retrocede di un
      // passo, esattamente come la freccia, e dal primo passo non fa nulla,
      // sempre come la freccia.
      //
      // Prima qui c'era `canPop: _step == _Step.accoglienza`, che dal primo
      // passo lasciava uscire. Sembrava innocuo, perche' al primo passo non
      // c'e' ancora niente da perdere, ma l'onboarding e' una rotta spinta
      // SOPRA lo shell: uscirne non chiude l'app, rivela la home che sta gia'
      // sotto. Bastava quindi retrocedere fino al primo passo e insistere una
      // volta per entrare nel Cerchio senza carta natale, con tutto quello che
      // la persona aveva appena inserito buttato via.
      //
      // L'unica uscita e' la fine del rito, che non e' un pop: e' il
      // pushReplacement verso il Risveglio.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goBack();
      },
      child: Scaffold(
      backgroundColor: ColorTokens.neutralDeepest,
      // Il fondo di tutto e' il cosmo profondo, neutro al Risveglio: nessun
      // colore di Maestro, che si sceglie solo alla risonanza. Le costellazioni
      // zodiacali restano spente qui, per non affollare i passi del rito.
      body: CosmosBackground(
        seed: 13,
        showZodiac: false,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.xl),
            child: Column(
              key: const Key('onboarding_risveglio'),
              children: [
                const SizedBox(height: SpacingTokens.lg),
                if (_step != _Step.accoglienza)
                  Row(
                    children: [
                      // La freccia vive nella riga dei puntini, a sinistra:
                      // e' dove l'occhio la cerca, e non ruba spazio al passo.
                      IconButton(
                        key: const Key('onboarding_indietro'),
                        onPressed: _goBack,
                        tooltip: 'Torna al passo precedente',
                        visualDensity: VisualDensity.compact,
                        icon: Icon(Icons.arrow_back_rounded,
                            size: 20, color: _palette.goldSoft),
                      ),
                      Expanded(
                        child: StepDots(
                          total: _Step.values.length - 1,
                          current: _step.index - 1,
                          palette: _palette,
                        ),
                      ),
                      // Simmetria: uno spazio pari alla freccia, cosi' i
                      // puntini restano centrati sulla larghezza vera.
                      const SizedBox(width: 48),
                    ],
                  ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: Duration(
                        milliseconds: _reduceMotion ? 0 : 260),
                    child: KeyedSubtree(
                      key: ValueKey(_step),
                      child: _buildStep(),
                    ),
                  ),
                ),
                const SizedBox(height: SpacingTokens.md),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case _Step.accoglienza:
        return _accoglienza();
      case _Step.data:
        return _dataStep();
      case _Step.ora:
        return _oraStep();
      case _Step.luogo:
        return _luogoStep();
      case _Step.nome:
        return _nomeStep();
      case _Step.vocativo:
        return _vocativoStep();
      case _Step.sigillo:
        return _sigilloStep();
    }
  }

  // --- Passo 0: l'accoglienza del Cerchio, senza Maestro ---
  Widget _accoglienza() {
    return _StepBody(
      // L'astrolabio che si costruisce, al posto del cerchio anonimo: il
      // testo sotto promette di comporre il cielo un passo alla volta, e un
      // cerchio fermo non promette niente.
      visual: Astrolabio(palette: _palette, reduceMotion: _reduceMotion),
      title: 'Il Risveglio',
      subtitle:
          'Sei sulla soglia del Cerchio. Comporremo insieme il tuo cielo, un '
          'passo alla volta.',
      content: Text(
        'Nulla di inventato: quel che non si può ancora calcolare resta '
        'marcato. La tua Guida si rivelerà solo alla fine.',
        textAlign: TextAlign.center,
        style: TypographyTokens.didascalia().copyWith(
          color: ColorTokens.textSecondary,
          height: 1.5,
        ),
      ),
      cta: _Cta(label: 'Inizia il rito', palette: _palette, onTap: _goNext),
      // **LA PORTA PICCOLA PER CHI TORNA, ordine AP voce 04.** Non e' un
      // muro: chi arriva per la prima volta prosegue senza notarla, perche'
      // il richiamo principale resta "Inizia il rito" e questa sta sotto, in
      // un tono smorzato. Chi torna, invece, la trova subito, e non deve
      // rifare un rito che ha gia' fatto per scoprire che il Cerchio lo
      // conosceva.
      sottoLaCta: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_bentornato != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                'Bentornato, $_bentornato',
                key: const Key('onboarding_bentornato'),
                textAlign: TextAlign.center,
                style: TypographyTokens.didascalia()
                    .copyWith(color: _palette.goldSoft),
              ),
            ),
          _PortaPerChiTorna(
            palette: _palette,
            onTap: _entraDaChiGiaCE,
            riconosciuto: _bentornato != null,
          ),
        ],
      ),
    );
  }

  /// **IL BENTORNATO, ordine AP voce 08, e il silenzio se non c'e'.** Se il
  /// telefono propone da solo l'account gia' usato, chi torna si sente
  /// chiamare per nome davanti alla porta piccola. Se non propone niente non
  /// compare nulla e la porta resta com'e': un saluto a un nome che non si
  /// sa sarebbe peggio del silenzio, e comunque nessuno entra da solo.
  String? _bentornato;

  Future<void> _chiediSeIlTelefonoPropone() async {
    final AccountDelCerchio account;
    try {
      account = context.read<AccountDelCerchio>();
    } on ProviderNotFoundException {
      // Fuori dall'app viva (anteprime e prove mirate) non c'e' nessun
      // account da interrogare, e non c'e' niente da salutare.
      return;
    }
    await account.chiediIlBentornato();
    if (!mounted || account.bentornato == null) return;
    setState(() => _bentornato = account.bentornato);
  }

  /// **CHI TORNA PASSA DA QUI, e da qui in poi la strada e' una sola.** Il
  /// riconoscimento porta al giro del Custode, lo stesso del "Continua come"
  /// della voce 06: il cammino torna, il rito non si rifa' se non serve, e
  /// cio' che e' stato ritrovato si vede.
  Future<void> _entraDaChiGiaCE() async {
    final riconosciuto = await mostraLaPortaPerChiTorna(context);
    if (!mounted || !riconosciuto) return;
    // Da qui in poi la strada e' una sola, la stessa del "Continua come"
    // della voce 06: il cammino torna, il rito non si rifa' se non serve, e
    // cio' che e' stato ritrovato si vede.
    final ritrovato = await CustodeDelCammino.dopoIlRiconoscimento(context);
    if (!mounted) return;
    // **SI ESCE DAL RITO SOLO SE NON RESTA NIENTE DA CHIEDERE.** Con
    // un'identita' parziale il rito prosegue dai passi che mancano, e non si
    // torna in home a meta' strada.
    if (ritrovato != null && ritrovato.siSalta) {
      // **SI ESCE CON `pop`, NON CON `maybePop`.** Ordine AZ, fatto F2, ed e'
      // la causa che ha resistito a piu' giri di collaudo.
      //
      // Il rito e' chiuso apposta contro la fuga: alla riga 507 c'e' un
      // `PopScope(canPop: false)`, messo perche' nessuno esca dal Risveglio
      // col gesto indietro lasciando l'app a meta'. **E `maybePop` quella
      // guardia la rispetta**: chiede il permesso, si sente dire di no, e non
      // fa niente. Il chiamante non se ne accorgeva, perche' `maybePop` non
      // lancia e non risponde niente.
      //
      // Cosi' chi rientrava con un'identita' intera restava dentro il rito
      // **anche quando non c'era piu' niente da chiedergli**: e' il fatto F2.
      // Qui l'uscita e' voluta e dichiarata, quindi si usa `pop`, che la
      // guardia non governa: la guardia esiste contro il gesto della persona,
      // non contro il codice che ha appena finito il lavoro.
      Navigator.of(context).pop();
      return;
    }
    // **E SE QUALCOSA MANCA, SI RIPRENDE INVECE DI RICOMINCIARE.** Ordine AZ,
    // fatto F2, **visto sul telefono del fondatore il 22 agosto 2026**: il
    // Cerchio lo riconosceva, gli restituiva settecentoquindici Eos, e subito
    // dopo il rito ripartiva dall'accoglienza.
    //
    // **La logica per riprendere esisteva gia' e funzionava**, in
    // `_riprendiCioCheIlCerchioSapeva`: precompila cio' che si sa e comincia
    // dal primo passo che manca davvero. Ma vive nell'`initState`, quindi si
    // applica **solo a uno schermo costruito con l'identita' ritrovata**. Chi
    // rientrava trovava questo schermo gia' montato senza, e quella logica non
    // girava mai. Qui lo schermo si rimonta con cio' che il Cerchio sapeva.
    final identita = ritrovato?.identita;
    if (identita == null) return;
    Navigator.of(context).pushReplacement(
      OnboardingScreen.route(clock: widget.clock, ritrovata: identita),
    );
  }

  // --- Passo 1: la data, e nasce il Sole nel segno ---
  Widget _dataStep() {
    return _StepBody(
      visual: AnimatedBuilder(
        animation: _ignite,
        builder: (_, __) => CustomPaint(
          painter: SunInSignPainter(
            sign: _sunSign,
            t: _ignite.value,
            color: _palette.goldSoft,
          ),
        ),
      ),
      title: 'Quando hai visto la luce',
      subtitle:
          'Dalla tua data nasce il Sole nel segno. Questo è reale, dalla '
          'tavola dei segni.',
      content: Column(
        children: [
          _DatePicker(
            date: _birthDate,
            palette: _palette,
            onChanged: (d) => setState(() => _birthDate = d),
          ),
          const SizedBox(height: SpacingTokens.md),
          _SignBadge(sign: _sunSign, palette: _palette),
        ],
      ),
      cta: _Cta(label: 'Continua', palette: _palette, onTap: _goNext),
    );
  }

  // --- Passo 2: l'ora, e sorge l'Ascendente ---
  Widget _oraStep() {
    return _StepBody(
      // Un orologio vero al posto dell'orizzonte disegnato: quello era bello
      // ma muto, e girando i selettori non cambiava nulla, quindi la scelta
      // non aveva riscontro. Le lancette dicono sempre che ora hai scelto.
      visual: OrologioDinamico(
        ora: _hour ?? 12,
        minuto: _minute ?? 0,
        palette: _palette,
        // Spento SOLO dopo un "Non la so" esplicito. Prima era spento anche
        // all'arrivo, quando la persona non aveva ancora detto nulla.
        attivo: _timeKnown != false,
        reduceMotion: _reduceMotion,
      ),
      title: 'A che ora, se lo sai',
      subtitle:
          'Con l\'ora sorge l\'Ascendente all\'orizzonte, il punto che stava '
          'nascendo mentre nascevi tu.',
      content: Column(
        children: [
          AnimatedOpacity(
            // Pieni all'arrivo: si sbiadiscono solo dopo un "Non la so".
            opacity: _timeKnown == false ? 0.35 : 1,
            duration: const Duration(milliseconds: 200),
            child: _TimePicker(
              hour: _hour,
              minute: _minute,
              // SEMPRE usabili. Qui c'era `_timeKnown == true`, e siccome
              // _timeKnown parte nullo, cioe' ne' saputa ne' ignota, i due
              // selettori nascevano spenti: per scegliere l'ora bisognava
              // passare da "Non la so" e poi tornare indietro. Regressione
              // nostra, nata quando abbiamo tolto la preselezione.
              enabled: true,
              palette: _palette,
              onChanged: (h, m) => setState(() {
                _hour = h;
                _minute = m;
                // Toccare un selettore E' dire "l'ora la so": non serve
                // dichiararlo anche altrove.
                _timeKnown = true;
              }),
            ),
          ),
          const SizedBox(height: SpacingTokens.sm),
          _SkipTimeToggle(
            skipped: _timeKnown == false,
            palette: _palette,
            onChanged: (skip) => setState(() {
              _timeKnown = !skip;
              _playIgnition();
            }),
          ),
          if (_timeKnown == false) ...[
            const SizedBox(height: SpacingTokens.sm),
            const _NotaGentile(
              text:
                  'Va bene così. Senza l\'ora l\'Ascendente si salta: il resto '
                  'del tuo cielo resta saldo.',
            ),
          ],
        ],
      ),
      cta: _Cta(label: 'Continua', palette: _palette, onTap: _goNext),
    );
  }

  // --- Passo 3: il luogo, e il cielo si ancora alla Terra ---
  Widget _luogoStep() {
    return _StepBody(
      // Un planisfero a punti al posto del cerchio anonimo: la mappa del
      // mondo resa come una costellazione, che si accende dove sei nato.
      // Non il logo, deciso da Mauro: mettere il proprio marchio nel punto in
      // cui si chiede alla persona dove e' nata sarebbe parlare di se' mentre
      // si sta ascoltando.
      visual: Planisfero(
        palette: _palette,
        reduceMotion: _reduceMotion,
        luogo: _place == null
            ? null
            : (lat: _place!.latitude, lon: _place!.longitude),
      ),
      title: 'Dove hai visto la luce',
      subtitle:
          'Il luogo ancora il cielo alla Terra e dispone la ruota delle case.',
      content: Column(
        children: [
          _PlaceField(
            controller: _placeCtrl,
            fuoco: _luogoFocus,
            chiaveElenco: _luogoElenco,
            results: _placeResults,
            chosen: _place,
            palette: _palette,
            onChanged: (q) {
              _searchPlace(q);
              // L'elenco che compare deve trovarsi sotto gli occhi, non sotto
              // la tastiera: e' il motivo per cui la persona non lo vedeva.
              if (_placeResults.isNotEmpty) _mostraISuggerimenti();
            },
            onPick: _pickCity,
          ),
          // Chi salta deve sapere cosa lascia, detto una volta e senza colpa.
          // L'Ascendente e le case dipendono dal punto della Terra: senza
          // quello non si calcolano, e non si inventano.
          //
          // Mentre l'elenco dei suggerimenti e' aperto la nota tace: li' la
          // persona sta scegliendo, non saltando, e con otto risultati sopra
          // finirebbe comunque fuori dallo schermo, cioe' detta a nessuno.
          // Il luogo scritto non e' in elenco: si dice, invece di lasciare la
          // persona davanti a un campo che non risponde. Il catalogo e'
          // offline e non contiene tutto il mondo (voce 2 dell'ordine 2169).
          if (_place == null &&
              _placeResults.isEmpty &&
              _placeCtrl.text.trim().length >= 2) ...[
            const SizedBox(height: SpacingTokens.sm),
            const _NotaGentile(
              key: Key('risveglio_luogo_non_trovato'),
              text: 'Questo luogo non è nel nostro elenco. Puoi proseguire '
                  'senza: restano fuori l\'Ascendente e le case, il resto del '
                  'tuo cielo resta saldo.',
            ),
          ],
          if (_place == null &&
              _placeResults.isEmpty &&
              _placeCtrl.text.trim().length < 2) ...[
            const SizedBox(height: SpacingTokens.sm),
            const _NotaGentile(
              key: Key('risveglio_luogo_nota'),
              text: 'Puoi saltare. Senza il luogo restano fuori l\'Ascendente '
                  'e le case: il resto del tuo cielo resta saldo.',
            ),
          ],
        ],
      ),
      cta: Builder(builder: (_) {
        final invito = _invitoDelLuogo();
        return _Cta(
          label: invito.etichetta,
          palette: _palette,
          onTap: invito.azione,
        );
      }),
    );
  }

  // --- Passo 4: il nome ---
  Widget _nomeStep() {
    return _StepBody(
      visual: _NameGlow(
        name: _nameCtrl.text.trim(),
        palette: _palette,
        ignite: _ignite,
      ),
      title: 'Come ti chiami',
      subtitle: 'Il cerchio ti chiamerà per nome, non con un\'etichetta.',
      content: TextField(
        key: const Key('risveglio_nome_field'),
        controller: _nameCtrl,
        textAlign: TextAlign.center,
        onChanged: (_) => setState(() {}),
        style: TypographyTokens.titoloSezione()
            .copyWith(color: _palette.goldSoft),
        cursorColor: _palette.goldSoft,
        decoration: InputDecoration(
          hintText: 'Il tuo nome',
          hintStyle: TypographyTokens.corpo()
              .copyWith(color: ColorTokens.textSecondary),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
                color: _palette.gold.withValues(alpha: 0.4)),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: _palette.goldSoft),
          ),
        ),
      ),
      cta: _Cta(
        label: 'Continua',
        palette: _palette,
        enabled: _nameCtrl.text.trim().isNotEmpty,
        onTap: _goNext,
      ),
    );
  }

  // --- Passo 5: il vocativo ---
  Widget _vocativoStep() {
    return _StepBody(
      // Onde di voce al posto del cerchio anonimo: il colore dice la scelta
      // prima delle parole. Blu il maschile, rosa il femminile, arcobaleno il
      // neutro, per decisione di Mauro.
      visual: OndeDellaVoce(tono: _courtesy, reduceMotion: _reduceMotion),
      altezzaVisivo: 250,
      title: 'Come vuoi che ti parli',
      subtitle:
          // "Vocativo" e' un termine di grammatica, e nessuno si rivolge a se'
          // stesso con un termine di grammatica. Questa era la SECONDA porta:
          // in un ordine precedente ne avevo corretta un'altra e lasciata
          // questa, ed e' la stessa forma di difetto del nome minuscolo.
          'Dimmi come rivolgermi a te: accorderemo ogni frase come preferisci.',
      content: Column(
        children: [
          _VocativoChoice(
            selected: _courtesy,
            palette: _palette,
            onChanged: (c) => setState(() => _courtesy = c),
          ),
          const SizedBox(height: SpacingTokens.lg),
          // Si sceglieva al buio: un'etichetta grammaticale senza mai sentire
          // come suona. Qui la stessa frase viene detta in tutti i modi, e la
          // differenza si sente invece di doverla immaginare.
          AnteprimaTono(
            tono: _courtesy,
            palette: _palette,
            reduceMotion: _reduceMotion,
          ),
        ],
      ),
      cta: _Cta(
        label: 'Continua',
        palette: _palette,
        enabled: _courtesy != null,
        onTap: _goNext,
      ),
    );
  }

  // --- Passo 6: il sigillo, che pulsa come un cuore ---
  Widget _sigilloStep() {
    // Non usa l'impalcatura comune: quella tiene il visivo in una scatola alta
    // 190 in cima, ed e' proprio lei a spingere il Sigillo in alto lasciando
    // mezzo schermo vuoto sotto. Il Sigillo non compila niente, e' un gesto:
    // sta al centro, e la sua schermata se la costruisce da se'.
    return SigilloStep(
      seal: CircleSeal.from(name: _name, identity: _identity),
      palette: _palette,
      reduceMotion: _reduceMotion,
      onComplete: _finish,
    );
  }
}

// ------------------------------------------------------------------
// Impalcatura comune di un passo: visivo in alto, titolo, sottotitolo,
// corpo, e l'invito a proseguire.
// ------------------------------------------------------------------
class _StepBody extends StatelessWidget {
  const _StepBody({
    required this.visual,
    this.altezzaVisivo = 190,
    required this.title,
    required this.subtitle,
    required this.content,
    required this.cta,
    this.sottoLaCta,
  });

  final Widget visual;

  /// Quanto spazio prende il visivo. Un passo che ha molto da dire in alto
  /// ne chiede di piu', invece di lasciare un vuoto sotto i puntini.
  final double altezzaVisivo;
  final String title;
  final String subtitle;
  final Widget content;
  final Widget? cta;

  /// **CIO' CHE STA SOTTO IL RICHIAMO PRINCIPALE, ordine AP voce 04.** E' il
  /// posto della porta piccola per chi torna: sta sotto, e' piu' smorzata, e
  /// chi arriva per la prima volta prosegue senza notarla.
  final Widget? sottoLaCta;

  @override
  Widget build(BuildContext context) {
    // Il contenuto scorre, l'invito a proseguire resta fisso in basso e sempre
    // raggiungibile: nessun passo finisce sotto il bordo.
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: SpacingTokens.md),
                // L'altezza del visivo la decide il passo, non una costante
                // per tutti: le onde della voce in 190 px restavano piccole e
                // in basso, lasciando sopra un vuoto pari al 22,4 per cento
                // dell'altezza, sopra il criterio del venti.
                SizedBox(
                  height: altezzaVisivo,
                  width: double.infinity,
                  child: RepaintBoundary(child: visual),
                ),
                const SizedBox(height: SpacingTokens.md),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TypographyTokens.cerimoniale()
                      .copyWith(color: const Color(0xFFE8C463)),
                ),
                const SizedBox(height: SpacingTokens.sm),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TypographyTokens.didascalia().copyWith(
                    color: ColorTokens.textPrimary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: SpacingTokens.lg),
                content,
                const SizedBox(height: SpacingTokens.lg),
              ],
            ),
          ),
        ),
        if (cta != null)
          Padding(
            padding: const EdgeInsets.only(top: SpacingTokens.sm),
            child: cta,
          ),
        if (sottoLaCta != null)
          Padding(
            padding: const EdgeInsets.only(top: SpacingTokens.xs),
            child: sottoLaCta,
          ),
      ],
    );
  }
}

/// I pallini di avanzamento del rituale.
///
/// Pubblici perche' sono la sola lettura onesta di 'a che passo sono':
/// un test che si appoggia ai testi delle singole schermate misura
/// un'altra cosa.
class StepDots extends StatelessWidget {
  const StepDots({
    super.key,
    required this.total,
    required this.current,
    required this.palette,
  });

  final int total;
  final int current;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < total; i++)
          Container(
            width: i == current ? 18 : 7,
            height: 7,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: i <= current
                  ? palette.goldSoft
                  : palette.gold.withValues(alpha: 0.25),
            ),
          ),
      ],
    );
  }
}

class _NameGlow extends StatelessWidget {
  const _NameGlow({
    required this.name,
    required this.palette,
    required this.ignite,
  });

  final String name;
  final MaestroPalette palette;
  final Animation<double> ignite;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: ignite,
        builder: (_, __) => Text(
          name.isEmpty ? '...' : name,
          textAlign: TextAlign.center,
          style: TypographyTokens.cerimonialeGrande().copyWith(
            color: palette.goldSoft,
            shadows: [
              Shadow(
                color: palette.glow.withValues(alpha: 0.6 * ignite.value),
                blurRadius: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// L'invito a proseguire, in fondo al passo.
class _Cta extends StatelessWidget {
  const _Cta({
    required this.label,
    required this.palette,
    required this.onTap,
    this.enabled = true,
  });

  final String label;
  final MaestroPalette palette;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: SizedBox(
        width: double.infinity,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            key: const Key('onboarding_continue'),
            onTap: enabled ? onTap : null,
            borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(vertical: SpacingTokens.md),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
                gradient: LinearGradient(colors: [
                  palette.primary.withValues(alpha: 0.85),
                  palette.surfaceElevated.withValues(alpha: 0.85),
                ]),
                border:
                    Border.all(color: palette.gold.withValues(alpha: 0.7)),
              ),
              child: Text(label,
                  style: TypographyTokens.titoloScheda()
                      .copyWith(color: palette.goldSoft)),
            ),
          ),
        ),
      ),
    );
  }
}

/// Selettore di data a tre ruote: giorno, mese, anno.
class _DatePicker extends StatelessWidget {
  const _DatePicker({
    required this.date,
    required this.palette,
    required this.onChanged,
  });

  final DateTime date;
  final MaestroPalette palette;
  final ValueChanged<DateTime> onChanged;

  static const _mesi = [
    'Gen', 'Feb', 'Mar', 'Apr', 'Mag', 'Giu',
    'Lug', 'Ago', 'Set', 'Ott', 'Nov', 'Dic',
  ];

  int get _daysInMonth => DateTime(date.year, date.month + 1, 0).day;

  @override
  Widget build(BuildContext context) {
    final years = [for (var y = DateTime.now().year; y >= 1920; y--) y];
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _wheel<int>(
          key: const Key('risveglio_giorno'),
          value: date.day.clamp(1, _daysInMonth),
          items: [for (var d = 1; d <= _daysInMonth; d++) d],
          label: (d) => d.toString().padLeft(2, '0'),
          onChanged: (d) =>
              onChanged(DateTime(date.year, date.month, d)),
        ),
        _wheel<int>(
          key: const Key('risveglio_mese'),
          value: date.month,
          items: [for (var m = 1; m <= 12; m++) m],
          label: (m) => _mesi[m - 1],
          onChanged: (m) {
            final maxDay = DateTime(date.year, m + 1, 0).day;
            onChanged(DateTime(date.year, m, date.day.clamp(1, maxDay)));
          },
        ),
        _wheel<int>(
          key: const Key('risveglio_anno'),
          value: date.year,
          items: years,
          label: (y) => y.toString(),
          onChanged: (y) {
            final maxDay = DateTime(y, date.month + 1, 0).day;
            onChanged(DateTime(y, date.month, date.day.clamp(1, maxDay)));
          },
        ),
      ],
      ),
    );
  }

  Widget _wheel<T>({
    required Key key,
    required T value,
    required List<T> items,
    required String Function(T) label,
    required ValueChanged<T> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: SpacingTokens.sm),
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.sm),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
        border: Border.all(color: palette.gold.withValues(alpha: 0.35)),
        color: palette.deepest.withValues(alpha: 0.4),
      ),
      child: DropdownButton<T>(
        key: key,
        value: value,
        dropdownColor: palette.deepest,
        underline: const SizedBox.shrink(),
        iconEnabledColor: palette.goldSoft,
        style: TypographyTokens.titoloScheda()
            .copyWith(color: palette.goldSoft),
        items: [
          for (final it in items)
            DropdownMenuItem<T>(value: it, child: Text(label(it))),
        ],
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }
}

/// Selettore d'ora: ore e minuti.
class _TimePicker extends StatelessWidget {
  const _TimePicker({
    required this.hour,
    required this.minute,
    required this.enabled,
    required this.palette,
    required this.onChanged,
  });

  final int? hour;
  final int? minute;
  final bool enabled;
  final MaestroPalette palette;
  /// Nullabili: si puo' scegliere l'ora senza aver ancora scelto i minuti.
  final void Function(int? hour, int? minute) onChanged;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _wheel(
            key: const Key('risveglio_ora'),
            value: hour,
            invito: 'Ora',
            items: [for (var h = 0; h < 24; h++) h],
            onChanged: (h) => onChanged(h, minute),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.sm),
            child: Text(':',
                style: TypographyTokens.titoloSezione()
                    .copyWith(color: palette.goldSoft)),
          ),
          _wheel(
            key: const Key('risveglio_minuto'),
            value: minute,
            invito: 'Minuti',
            items: [for (var m = 0; m < 60; m++) m],
            onChanged: (m) => onChanged(hour, m),
          ),
        ],
      ),
    );
  }

  Widget _wheel({
    required Key key,
    required int? value,
    required String invito,
    required List<int> items,
    required ValueChanged<int> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.sm),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
        border: Border.all(color: palette.gold.withValues(alpha: 0.35)),
        color: palette.deepest.withValues(alpha: 0.4),
      ),
      child: DropdownButton<int>(
        key: key,
        value: value,
        // L'invito, quando non si e' ancora scelto: prima la pillola era muta,
        // col solo triangolino, e nessuno sapeva se fosse l'ora o il minuto.
        hint: Text(invito,
            style: TypographyTokens.etichetta()
                .copyWith(color: ColorTokens.textSecondary)),
        dropdownColor: palette.deepest,
        underline: const SizedBox.shrink(),
        iconEnabledColor: palette.goldSoft,
        style: TypographyTokens.titoloScheda()
            .copyWith(color: palette.goldSoft),
        items: [
          for (final it in items)
            DropdownMenuItem<int>(
              value: it,
              child: Text(it.toString().padLeft(2, '0')),
            ),
        ],
        onChanged: enabled ? (v) => v == null ? null : onChanged(v) : null,
      ),
    );
  }
}

/// L'opzione "Non la so" per l'ora di nascita.
class _SkipTimeToggle extends StatelessWidget {
  const _SkipTimeToggle({
    required this.skipped,
    required this.palette,
    required this.onChanged,
  });

  final bool skipped;
  final MaestroPalette palette;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      key: const Key('risveglio_ora_skip'),
      onPressed: () => onChanged(!skipped),
      icon: Icon(
        skipped ? Icons.check_circle_rounded : Icons.circle_outlined,
        size: 18,
        color: palette.goldSoft,
      ),
      label: Text(
        'Non la so',
        style: TypographyTokens.didascalia()
            .copyWith(color: palette.goldSoft),
      ),
    );
  }
}

/// Una nota gentile che spiega cosa comporta saltare un dato.
///
/// Prima si chiamava nota provvisoria e portava il distintivo "Provvisorio":
/// aveva senso quando l'Ascendente era davvero un segnaposto. Col motore vivo
/// quella parola e' diventata falsa, mentre il contenuto della nota resta vero
/// e utile, quindi resta la nota e sparisce il distintivo.
class _NotaGentile extends StatelessWidget {
  const _NotaGentile({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFE8C463);
    return Container(
      key: const Key('risveglio_nota_gentile'),
      padding: const EdgeInsets.all(SpacingTokens.sm),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
        border: Border.all(color: gold.withValues(alpha: 0.3)),
        color: gold.withValues(alpha: 0.06),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: gold.withValues(alpha: 0.18),
            ),
            child: const Icon(Icons.auto_awesome, size: 13, color: gold),
          ),
          const SizedBox(width: SpacingTokens.sm),
          Expanded(
            child: Text(text,
                style: TypographyTokens.didascalia().copyWith(
                    color: ColorTokens.textSecondary, height: 1.4)),
          ),
        ],
      ),
    );
  }
}

/// Il campo di ricerca del luogo, con i suggerimenti dell'elenco offline.
class _PlaceField extends StatelessWidget {
  const _PlaceField({
    required this.controller,
    required this.fuoco,
    required this.chiaveElenco,
    required this.results,
    required this.chosen,
    required this.palette,
    required this.onChanged,
    required this.onPick,
  });

  final TextEditingController controller;

  /// Il fuoco del campo, per riaprire la tastiera quando il pulsante riporta
  /// la persona alla scelta invece di portarla oltre.
  final FocusNode fuoco;

  /// La chiave dell'elenco, che serve a portarlo sotto gli occhi.
  final GlobalKey chiaveElenco;
  final List<City> results;
  final BirthPlace? chosen;
  final MaestroPalette palette;
  final ValueChanged<String> onChanged;
  final ValueChanged<City> onPick;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          key: const Key('risveglio_luogo_field'),
          controller: controller,
          focusNode: fuoco,
          textAlign: TextAlign.center,
          onChanged: onChanged,
          style: TypographyTokens.lettura()
              .copyWith(color: palette.goldSoft),
          cursorColor: palette.goldSoft,
          decoration: InputDecoration(
            hintText: 'Cerca la tua città',
            hintStyle: TypographyTokens.corpo()
                .copyWith(color: ColorTokens.textSecondary),
            prefixIcon: Icon(Icons.search_rounded, color: palette.goldSoft),
            enabledBorder: UnderlineInputBorder(
              borderSide:
                  BorderSide(color: palette.gold.withValues(alpha: 0.4)),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: palette.goldSoft),
            ),
          ),
        ),
        if (results.isNotEmpty)
          Container(
            // Due chiavi per due mestieri: la globale porta l'elenco sotto gli
            // occhi quando la tastiera lo spinge fuori, la nominata lo rende
            // cercabile dalla prova che ne misura la posizione.
            key: chiaveElenco,
            margin: const EdgeInsets.only(top: SpacingTokens.sm),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
              border: Border.all(color: palette.gold.withValues(alpha: 0.3)),
              color: palette.deepest.withValues(alpha: 0.6),
            ),
            child: Material(
              color: Colors.transparent,
              child: Column(
                children: [
                  for (final c in results)
                    InkWell(
                      // La chiave porta anche l'area: Newcastle esiste in Australia e in
                      // Sudafrica, e due chiavi uguali in una lista sono uno
                      // schianto (Duplicate keys found), non un dettaglio.
                      key: Key('citta_${c.name}_${c.country}'),
                      onTap: () => onPick(c),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: SpacingTokens.md,
                            vertical: SpacingTokens.sm),
                        child: Row(
                          children: [
                            Icon(Icons.place_outlined,
                                size: 16, color: palette.goldSoft),
                            const SizedBox(width: SpacingTokens.sm),
                            Expanded(
                              child: Text(c.label,
                                  style: TypographyTokens.didascalia()
                                      .copyWith(
                                          color: ColorTokens.textPrimary)),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        if (chosen != null && results.isEmpty) ...[
          const SizedBox(height: SpacingTokens.sm),
          Row(
            key: const Key('risveglio_luogo_scelto'),
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.public_rounded, size: 16, color: palette.goldSoft),
              const SizedBox(width: SpacingTokens.sm),
              Text('${chosen!.city} · ${chosen!.timeZoneId}',
                  style: TypographyTokens.didascalia()
                      .copyWith(color: ColorTokens.textSecondary)),
            ],
          ),
        ],
        // Citta' non in elenco: si guida verso la piu' vicina fra le grandi,
        // cosi' non e' mai un vicolo cieco.
        if (chosen == null &&
            results.isEmpty &&
            controller.text.trim().length >= 2) ...[
          const SizedBox(height: SpacingTokens.sm),
          Text(
            'Non è in elenco? Scegli la città grande più vicina: '
            'il cielo si ancora comunque.',
            textAlign: TextAlign.center,
            style: TypographyTokens.didascalia()
                .copyWith(color: ColorTokens.textSecondary, height: 1.4),
          ),
        ],
      ],
    );
  }
}

/// La scelta del vocativo: Lui, Lei, Neutro.
class _VocativoChoice extends StatelessWidget {
  const _VocativoChoice({
    required this.selected,
    required this.palette,
    required this.onChanged,
  });

  final CourtesyForm? selected;
  final MaestroPalette palette;
  final ValueChanged<CourtesyForm> onChanged;

  @override
  Widget build(BuildContext context) {
    const options = [
      (CourtesyForm.masculine, 'Lui', 'lui'),
      (CourtesyForm.feminine, 'Lei', 'lei'),
      (CourtesyForm.neutral, 'Neutro', 'neutro'),
    ];
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (final (form, label, keyId) in options)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: SpacingTokens.sm),
              child: _chip(form, label, keyId),
            ),
        ],
      ),
    );
  }

  Widget _chip(CourtesyForm form, String label, String keyId) {
    final on = selected == form;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: Key('vocativo_$keyId'),
        onTap: () => onChanged(form),
        borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: SpacingTokens.lg, vertical: SpacingTokens.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
            gradient: on
                ? LinearGradient(colors: [
                    palette.primary.withValues(alpha: 0.9),
                    palette.surfaceElevated.withValues(alpha: 0.9),
                  ])
                : null,
            border: Border.all(
                color: palette.gold.withValues(alpha: on ? 0.9 : 0.35)),
          ),
          child: Text(label,
              style: TypographyTokens.titoloScheda().copyWith(
                  color: on ? palette.goldSoft : ColorTokens.textSecondary)),
        ),
      ),
    );
  }
}

/// Il distintivo del segno solare, ricavato in modo reale dalla data.
class _SignBadge extends StatelessWidget {
  const _SignBadge({required this.sign, required this.palette});

  final Zodiac sign;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.md, vertical: SpacingTokens.sm),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
        color: palette.deepest.withValues(alpha: 0.4),
        border: Border.all(color: palette.gold.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wb_sunny_rounded, size: 18, color: palette.goldSoft),
          const SizedBox(width: SpacingTokens.sm),
          Text('Sole in ${sign.italianName}',
              style: TypographyTokens.titoloScheda()
                  .copyWith(color: palette.goldSoft)),
          const SizedBox(width: SpacingTokens.sm),
          // Il simbolo del segno, tracciato a vettori dal codice, non un glifo
          // di font: si rende identico ovunque.
          SizedBox(
            width: 20,
            height: 20,
            child: CustomPaint(
              painter: _GlyphPainter(sign: sign, color: palette.goldSoft),
            ),
          ),
        ],
      ),
    );
  }
}

/// Il simbolo di un segno, tracciato a vettori dal codice.
class _GlyphPainter extends CustomPainter {
  _GlyphPainter({required this.sign, required this.color});

  final Zodiac sign;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color;
    drawZodiacGlyph(
        canvas, sign, size.center(Offset.zero), size.shortestSide * 0.42, paint);
  }

  @override
  bool shouldRepaint(_GlyphPainter old) =>
      old.sign != sign || old.color != color;
}

/// Il Sigillo che pulsa come un cuore sotto il dito; tenuto premuto, sigilla il
