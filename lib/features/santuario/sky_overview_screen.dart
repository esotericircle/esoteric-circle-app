import 'dart:math' as math;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/astro/moon_phase.dart';
import '../../core/astro/night_sky.dart';
import '../../core/astro/sky_catalog.dart';
import '../../core/astro/sky_location.dart';
import '../../core/astro/zodiac.dart';
import '../../core/identity/profile_controller.dart';
import '../../core/motion/parallax_controller.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import 'sky_postcard.dart';
import 'widgets/moon_widget.dart';
import '../../core/maestro/maestro.dart';
import '../../core/astro/birth_place.dart' as astro;
import '../../core/astro/sky.dart';

/// QUANDO: l'avverbio di tempo della schermata del cielo, in un punto solo.
///
/// La schermata sa quale dei due cieli descrive, e OGNI testo che nomina il
/// tempo legge questa fonte. Prima ogni frase se lo ricordava per conto suo: la
/// nota in fondo era stata declinata al passato e la riga del calcolo era
/// rimasta al presente, quindi il cielo di NASCITA diceva "Adesso sale verso il
/// culmine" parlando di una notte di cinquant'anni prima. Due frasi che
/// descrivono lo stesso istante, e ne era stata corretta una.
///
/// **NON DICE PIU' "ADESSO".** La schermata del cielo mostra la mezzanotte
/// della notte che viene, non l'istante presente: un avverbio al presente
/// sopra un dato della notte e' la contraddizione che il fondatore ha
/// fotografato. Il punto solo ha fatto il suo mestiere: cambiata questa riga,
/// si sono adeguate tutte le frasi che la leggono.
String quando(bool birth) => birth ? 'Quella notte' : 'Stanotte';

/// "Il cielo sopra di te": il cielo del momento, immersivo ed esplorabile.
///
/// Non uno schema, ma una volta stellata densa: centinaia di stelle su tre
/// piani che si muovono a velocita' diverse col giroscopio e col trascinamento
/// del dito, un accenno di Via Lattea, e le costellazioni immerse nel campo con
/// le loro forme reali. La tela e' piu' ampia dello schermo: scorrendo o
/// inclinando si rivela altro cielo ai lati e in alto. La Luna e le
/// costellazioni alte stanotte (`NightSky`, dalla posizione reale del Sole) sono
/// distribuite su questa tela, toccabili, con etichetta e riga breve nella voce
/// di Medora. Riduci Movimento appiattisce o ferma la parallasse. Freccia
/// Indietro al Santuario.
class SkyOverviewScreen extends StatefulWidget {
  const SkyOverviewScreen({
    super.key,
    this.now,
    this.location = const DisabledSkyLocation(),
    this.birth = false,
    this.ctaLabel,
    this.onCta,
    this.showBack = true,
    this.nascitaRegistrata,
    this.luogoIniziale,
  });

  /// Il luogo da cui guardare, quando lo si conosce gia'.
  ///
  /// **Perche' esiste.** Senza di lui il luogo entra in un modo solo, il
  /// dialogo di consenso, che richiede un tocco: nessuna prova poteva quindi
  /// misurare il cielo POSIZIONATO, e infatti il difetto e' vissuto indisturbato
  /// mentre la sorveglianza restava verde. Un dato che si puo' ottenere in un
  /// modo solo, e quel modo richiede una mano umana, e' un dato che nessuna
  /// misura raggiunge.

  /// Momento del cielo, iniettabile per i test; di default l'ora di adesso.
  /// Per il cielo di nascita e' il momento fisso della nascita.
  final DateTime? now;

  /// Sorgente della posizione, per orientare il cielo sul luogo reale. Di
  /// default e' spenta, cosi' test e anteprime non chiedono nulla; l'ingresso
  /// dal Santuario passa quella vera. Il pre-avviso appare solo quando il
  /// momento e' l'adesso reale (`now` nullo) e la sorgente e' disponibile.
  final SkyLocation location;

  /// Se e' il cielo di nascita: stesso motore immersivo, ma ancorato alla
  /// notte di nascita e fisso (identita'). Cambia titolo e voce, e non chiede
  /// mai la posizione: il luogo e' quello della nascita, non l'adesso.
  final bool birth;

  /// Azione in fondo, quando questo cielo vive dentro un flusso: l'onboarding
  /// la usa per proseguire verso la carta. Nulli fuori dai flussi, dove basta
  /// la freccia della barra.
  final String? ctaLabel;
  final VoidCallback? onCta;

  /// Falso quando la schermata sta dentro un flusso che non ha un indietro,
  /// come il Risveglio: la freccia sparisce invece di portare nel vuoto.
  final bool showBack;

  /// Se la nascita mostrata e' quella dichiarata dalla persona.
  ///
  /// Nullo significa "chiedilo al profilo", che e' giusto ovunque tranne
  /// dentro il Risveglio: li' la persona ha appena inserito data, ora e luogo
  /// ma il profilo non e' ancora stato scritto, quindi il profilo direbbe di
  /// no e la bolla darebbe dell'esempio al dato appena battuto a mano.
  final bool? nascitaRegistrata;

  /// Vedi sopra: il luogo noto in partenza, senza passare dal consenso.
  final SkyPlace? luogoIniziale;

  static Route<void> route({DateTime? now, SkyLocation? location}) {
    return MaterialPageRoute<void>(
      builder: (_) => MaestroScope(
        maestro: Maestro.medora,
        child: SkyOverviewScreen(
          now: now,
          location: location ?? const GeolocatorSkyLocation(),
        ),
      ),
    );
  }

  /// Il cielo di nascita, ancorato alla notte di nascita e fisso. Riusa il
  /// motore immersivo del cielo di adesso, con la voce di Medora sull'identita'.
  static Route<void> birthRoute({required DateTime birthMoment}) {
    return MaterialPageRoute<void>(
      builder: (_) => MaestroScope(
        maestro: Maestro.medora,
        child: SkyOverviewScreen(now: birthMoment, birth: true),
      ),
    );
  }

  @override
  State<SkyOverviewScreen> createState() => _SkyOverviewScreenState();
}

class _SkyOverviewScreenState extends State<SkyOverviewScreen> {
  Offset _cam = Offset.zero;
  String? _selectedKey;

  // Luogo risolto per orientare la volta, e se il pre-avviso e' gia' stato
  // proposto in questa visita (una sola volta).
  SkyPlace? _place;
  bool _askedLocation = false;

  /// L'istantanea del cielo, calcolata dal motore a effemeridi.
  ///
  /// Prima non c'era. La schermata disegnava una volta procedurale e, quando
  /// arrivava la posizione, spostava il disegno di un offset grafico: ecco
  /// perche' concedere il permesso non cambiava niente di astronomico. Il
  /// motore `buildSkyFor` esisteva gia' e non era chiamato da nessuno.
  SkySnapshot? _cielo;

  /// Da dove vengono le coordinate del calcolo, per poterlo dichiarare.
  OrigineCoordinate _origine = OrigineCoordinate.nessuna;

  /// Vero solo quando il cielo e' stato RICALCOLATO sulle coordinate del
  /// dispositivo. Il banner poggia su questo e non sulla concessione del
  /// permesso: prima diceva "cielo orientato" per il solo fatto che il permesso
  /// fosse stato dato, cioe' dichiarava un esito che non era avvenuto.
  bool _ricalcolatoSulDispositivo = false;

  /// Ricorda che la posizione e' gia' stata concessa, fra un ingresso e l'altro.
  static const String _chiaveConsenso = 'cielo_posizione_concessa_v1';

  /// Se il consenso risulta gia' dato. Si aggiorna quando la lettura arriva.
  ///
  /// Non e' un Future atteso dal flusso: attenderlo davanti all'invito e'
  /// esattamente l'errore che avevo introdotto, perche' una memoria che non
  /// risponde impediva del tutto di chiedere la posizione. Nel caso peggiore la
  /// lettura arriva tardi e si chiede una volta in piu', che e' senza danno.
  bool _consensoNoto = false;

  @override
  void initState() {
    super.initState();
    _place = widget.luogoIniziale;
    // Il pre-avviso vale solo per il cielo di adesso, non per il cielo di
    // nascita ne per i test o le anteprime, che passano un momento fisso o una
    // sorgente spenta.
    // La richiesta della posizione parte DENTRO l'esito della lettura, cosi'
    // l'ordine e' garantito: chi ha gia' concesso non si rivede l'invito.
    //
    // La lettura ha un ripiego a "non ricordato" in caso di errore, quindi
    // arriva sempre a destinazione: se la memoria non risponde si chiede la
    // posizione come al primo ingresso, che e' molto meglio del non chiederla.
    _leggiConsenso().then((noto) {
      if (!mounted) return;
      _consensoNoto = noto;
      if (widget.now == null && widget.location.available) _avviaPosizione();
    });
    // Il cielo si calcola subito, col luogo che si ha: quello di nascita, se
    // c'e'. Senza questo passo la schermata non chiedeva NIENTE al motore.
    WidgetsBinding.instance.addPostFrameCallback((_) => _calcolaCielo());
  }

  /// Se il consenso alla posizione risulta gia' dato in una visita precedente.
  /// La lettura parte una volta, in initState, e non blocca nessuno.
  ///
  /// Con un timeout breve e un ripiego a "non ricordato": se la memoria non
  /// risponde si chiede la posizione come al primo ingresso, che e' molto meglio
  /// del restare in attesa e non chiederla affatto. Era il difetto che ho
  /// introdotto io mettendo la lettura davanti all'invito.
  Future<bool> _leggiConsenso() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_chiaveConsenso) ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Ricorda il consenso. Se non si riesce, pazienza: si richiedera'.
  Future<void> _ricordaConsenso() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_chiaveConsenso, true);
    } catch (_) {
      // Nessun rimedio utile: il rito non si interrompe per questo.
    }
  }

  /// L'ISTANTE UNICO DELLA SCHERMATA: la mezzanotte della notte che viene.
  ///
  /// **Perche' non e' l'adesso.** Il fondatore ha fotografato la scheda della
  /// Bilancia alle 18:04 del 1 agosto 2026: diceva dodici gradi a sud-est,
  /// mentre alle 18:04 la Bilancia stava a ventinove gradi e a mezzanotte a
  /// tredici. Un numero della notte e una direzione dell'istante nella stessa
  /// riga, sotto un titolo che diceva "adesso". La schermata era nata come "le
  /// costellazioni alte a mezzanotte stanotte", ed e' quello che il motore
  /// calcola: la parola "adesso" e' arrivata dopo.
  ///
  /// Ora l'istante e' UNO, viene da `mezzanotteDellaNotteCheViene`, ed e' un
  /// dato che si legge, non una deduzione ripetuta in tre punti. Tutto quello
  /// che la schermata mostra, posizioni, altezze, direzioni e fase, discende
  /// da qui.
  DateTime get _istante =>
      mezzanotteDellaNotteCheViene(widget.now ?? DateTime.now());

  /// Calcola il cielo col luogo migliore disponibile.
  ///
  /// Ordine di preferenza: la posizione del dispositivo se concessa, poi il
  /// luogo di nascita del profilo. Senza nessuno dei due non si calcola e non si
  /// finge: la schermata lo dichiara nel riquadro del metodo.
  Future<void> _calcolaCielo() async {
    if (!mounted) return;
    final dispositivo = _place;
    final nascita = _luogoDiNascita();
    final scelto = dispositivo ?? nascita;
    if (scelto == null) {
      setState(() => _origine = OrigineCoordinate.nessuna);
      return;
    }
    // Il calcolo non deve poter rompere la schermata: se il catalogo delle
    // stelle non si carica, il cielo resta senza istantanea e il riquadro del
    // metodo lo dichiara, invece di far cadere tutto il resto.
    final SkyCatalog catalogo;
    try {
      catalogo = await SkyCatalog.load();
    } catch (_) {
      return;
    }
    if (!mounted) return;
    final cielo = buildSkyFor(
      catalogo,
      _istante,
      astro.BirthPlace(
        label: dispositivo != null ? 'Dove ti trovi' : 'Luogo di nascita',
        latitude: scelto.latitude,
        longitude: scelto.longitude,
        timezone: 'locale',
      ),
    );
    setState(() {
      _cielo = cielo;
      _origine = dispositivo != null
          ? OrigineCoordinate.dispositivo
          : OrigineCoordinate.nascita;
    });
  }

  /// Fonti e metodo, coi VALORI usati per il calcolo.
  ///
  /// Non e' una schermata di debug: e' la trasparenza che il progetto
  /// prescrive, resa utile. Chiunque puo' confrontare questi numeri con una
  /// qualunque effemeride e dire in trenta secondi se il motore funziona,
  /// invece di fidarsi.
  void _mostraFontiEMetodo() {
    final palette = context.palette;
    final cielo = _cielo;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        key: const Key('sky_fonti_foglio'),
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
        padding: const EdgeInsets.fromLTRB(SpacingTokens.lg, SpacingTokens.md,
            SpacingTokens.lg, SpacingTokens.xl),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [palette.surfaceElevated, palette.deepest],
          ),
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(SpacingTokens.lg)),
          border: Border.all(color: palette.gold.withValues(alpha: 0.35)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Fonti e metodo',
                  style: TypographyTokens.display(size: 22)
                      .copyWith(color: palette.textPrimary)),
              const SizedBox(height: SpacingTokens.xs),
              Text(
                'Le posizioni vengono da un motore a effemeridi che gira sul '
                'telefono, senza rete. Qui sotto ci sono i valori che ha usato '
                'davvero: confrontali con qualunque effemeride.',
                style: TypographyTokens.body(size: 13)
                    .copyWith(color: palette.textSecondary),
              ),
              const SizedBox(height: SpacingTokens.md),
              if (cielo == null)
                Text(
                  'Il cielo non risulta calcolato: manca un luogo da cui '
                  'guardarlo. Concedi la posizione, oppure registra il tuo '
                  'luogo di nascita.',
                  key: const Key('sky_fonti_nessun_calcolo'),
                  style: TypographyTokens.body(size: 14)
                      .copyWith(color: palette.goldSoft),
                )
              else
                Column(
                  key: const Key('sky_fonti_valori'),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _rigaValore(palette, 'Latitudine',
                        cielo.latitude.toStringAsFixed(4)),
                    _rigaValore(palette, 'Longitudine',
                        cielo.longitude.toStringAsFixed(4)),
                    _rigaValore(palette, 'Coordinate da', _origine.etichetta),
                    _rigaValore(palette, 'Istante locale',
                        _formattaIstante(cielo.istanteLocale)),
                    _rigaValore(palette, 'Istante in UT',
                        '${_formattaIstante(cielo.istanteUtc)} UTC'),
                    _rigaValore(
                        palette,
                        'Luna illuminata',
                        '${(cielo.moonPhase.fraction * 100).toStringAsFixed(1)} '
                            'per cento'),
                    _rigaValore(palette, 'Fase', cielo.nomeFaseLunare),
                    _rigaValore(palette, 'Luna nel segno',
                        NightSky.moonSign(cielo.istanteLocale).italianName),
                    _rigaValore(
                        palette,
                        'Luna sopra il suolo',
                        cielo.moon == null
                            ? 'sotto il suolo'
                            : '${cielo.moon!.altDeg.toStringAsFixed(1)} gradi'),
                    const SizedBox(height: SpacingTokens.sm),
                    Text('Costellazioni sopra il suolo a mezzanotte',
                        style: TypographyTokens.label(size: 12)
                            .copyWith(color: palette.goldSoft)),
                    const SizedBox(height: 2),
                    Text(
                      cielo.nomiVisibili.isEmpty
                          ? 'nessuna'
                          : cielo.nomiVisibili.join(', '),
                      key: const Key('sky_fonti_costellazioni'),
                      style: TypographyTokens.body(size: 13)
                          .copyWith(color: palette.textPrimary),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _rigaValore(MaestroPalette palette, String nome, String valore) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(nome,
                style: TypographyTokens.label(size: 12)
                    .copyWith(color: palette.goldSoft)),
          ),
          Expanded(
            child: Text(valore,
                key: Key('sky_valore_$nome'),
                style: TypographyTokens.body(size: 13)
                    .copyWith(color: palette.textPrimary)),
          ),
        ],
      ),
    );
  }

  static String _formattaIstante(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/${d.year} '
      '${d.hour.toString().padLeft(2, '0')}:'
      '${d.minute.toString().padLeft(2, '0')}';

  /// Il luogo di nascita dal profilo, quando c'e' e non e' d'esempio.
  SkyPlace? _luogoDiNascita() {
    ProfileController? profilo;
    try {
      profilo = context.read<ProfileController?>();
    } catch (_) {
      // Nessun profilo nell'albero: si resta senza luogo di nascita.
      return null;
    }
    final id = profilo?.identity;
    if (id == null || id.isExample) return null;
    final p = id.birthPlace;
    if (p == null) return null;
    return SkyPlace(latitude: p.latitude, longitude: p.longitude);
  }

  /// Chiede la posizione, saltando l'invito se il consenso e' gia' stato dato.
  ///
  /// Prima l'invito si riproponeva a OGNI ingresso, perche' `_askedLocation` e'
  /// un campo di stato che nasce falso ogni volta che la schermata si monta. Chi
  /// aveva gia' concesso si rivedeva la stessa richiesta, stavolta senza la
  /// finestra di sistema, col banner che ricompariva e nulla che cambiava.
  Future<void> _avviaPosizione() async {
    if (!mounted || _askedLocation) return;
    _askedLocation = true;

    // La memoria del consenso e' una comodita', non una condizione: se non si
    // riesce a leggerla si procede come al primo ingresso. Senza questa cautela
    // un errore nella lettura impediva del tutto di chiedere la posizione, che
    // e' molto peggio del chiederla una volta di troppo.
    final giaConcesso = _consensoNoto;

    if (!giaConcesso) {
      final accettato = await _askLocationConsent();
      if (accettato != true || !mounted) return;
    }

    final risposta = await widget.location.chiedi();
    if (!mounted) return;
    if (risposta.concessa) {
      // Prima l'effetto visibile, poi la memoria. Averli in ordine inverso e'
      // stato un mio errore: la scrittura delle preferenze stava DAVANTI
      // all'orientamento del cielo, quindi se quella scrittura non si
      // completava il cielo non si orientava affatto. Un effetto che si vede
      // non sta mai dietro un'attesa di scrittura.
      final primaLat = _cielo?.latitude;
      setState(() => _place = risposta.luogo);
      // La memoria del consenso viaggia da sola: se non arriva, al massimo la
      // posizione verra' richiesta un'altra volta.
      _ricordaConsenso();
      // Il cielo si RICALCOLA sulle coordinate nuove: questo era il passo che
      // mancava del tutto.
      await _calcolaCielo();
      if (!mounted) return;
      // Da qui in avanti la dichiarazione, che dipende dal ricalcolo.
      final cambiato = _cielo != null && _cielo!.latitude != primaLat;
      _ricalcolatoSulDispositivo = _origine == OrigineCoordinate.dispositivo;
      // Il banner solo se il cielo e' DAVVERO cambiato. Prima si mostrava per
      // il solo fatto che il permesso fosse stato concesso, quindi dichiarava
      // un esito che non era avvenuto.
      if (_ricalcolatoSulDispositivo && (cambiato || primaLat == null)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            key: Key('sky_location_concessa'),
            content: Text('Cielo ricalcolato sul luogo dove ti trovi.'),
          ),
        );
      }
      return;
    }
    // Negato o spento: si dichiara COSA si sta mostrando al posto suo, e si
    // offre la via giusta. Mai un vicolo cieco, mai un silenzio.
    final spento = risposta.esito == EsitoPosizione.servizioSpento;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        key: const Key('sky_location_negata'),
        duration: const Duration(seconds: 6),
        content: Text(spento
            ? 'La posizione del telefono è spenta: resto sul cielo della tua '
                'nascita.'
            : 'Resto sul cielo della tua nascita, senza il luogo dove ti '
                'trovi.'),
        action: SnackBarAction(
          label: spento ? 'Impostazioni' : 'Permessi',
          onPressed: () => spento
              ? Geolocator.openLocationSettings()
              : Geolocator.openAppSettings(),
        ),
      ),
    );
  }

  // Il pre-avviso gentile, nel tono di Medora: spiega a cosa serve la posizione
  // prima che il sistema mostri la sua richiesta secca.
  Future<bool?> _askLocationConsent() {
    final palette = context.palette;
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => Dialog(
        key: const Key('sky_location_prompt'),
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(SpacingTokens.lg),
        child: Container(
          padding: const EdgeInsets.all(SpacingTokens.lg),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [palette.surfaceElevated, palette.deepest],
            ),
            borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
            border: Border.all(color: palette.gold.withValues(alpha: 0.35)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.public_rounded, color: palette.goldSoft, size: 22),
                  const SizedBox(width: SpacingTokens.sm),
                  Expanded(
                    child: Text('Oriento il cielo sul tuo luogo?',
                        style: TypographyTokens.display(size: 18)
                            .copyWith(color: palette.goldSoft)),
                  ),
                ],
              ),
              const SizedBox(height: SpacingTokens.sm),
              Text(
                'Con il tuo permesso leggo dove ti trovi, così la volta sopra di '
                'te si dispone come la vedi davvero da lì. La posizione resta sul '
                'dispositivo: serve solo a orientare le stelle. La posizione '
                'esatta di ogni astro nel cielo arriva col motore a effemeridi.',
                style: TypographyTokens.body(size: 14)
                    .copyWith(color: ColorTokens.textSecondary),
              ),
              const SizedBox(height: SpacingTokens.md),
              // Wrap, non Row: se le etichette non stanno su una riga vanno a
              // capo, senza mai sforare il bordo del riquadro.
              Wrap(
                alignment: WrapAlignment.end,
                spacing: SpacingTokens.sm,
                children: [
                  TextButton(
                    key: const Key('sky_location_decline'),
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    child: Text('Non ora',
                        style: TypographyTokens.label(size: 13)
                            .copyWith(color: ColorTokens.textSecondary)),
                  ),
                  TextButton(
                    key: const Key('sky_location_accept'),
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    child: Text('Orienta il cielo',
                        style: TypographyTokens.label(size: 13)
                            .copyWith(color: palette.goldSoft)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // La longitudine sposta il centro della volta in orizzontale, la latitudine
  // alza o abbassa l'orizzonte: un orientamento simbolico sul luogo reale. La
  // volta piena in alt-azimut resta al motore a effemeridi, come dichiarato.
  Offset _orientOffset(Size size) {
    final p = _place;
    if (p == null) return Offset.zero;
    return Offset(
      (p.longitude / 180.0) * size.width * 0.32,
      (p.latitude / 90.0) * size.height * 0.14,
    );
  }

  // Slot prominenti dei corpi alti stanotte, sempre raggiungibili.
  //
  // Tutti nella meta' ALTA: la scheda in basso occupa circa un terzo dello
  // schermo, e il terzo slot a 0,64 finiva sotto di lei. A schermo si vedeva
  // il nome della costellazione sparire dietro il riquadro, che e' come non
  // averla messa: un corpo toccabile che non si vede non lo tocca nessuno.
  /// Quanto puo' essere alta la scheda, al massimo.
  ///
  /// Con la scheda ridotta a due sole cose questo tetto quasi non morde piu',
  /// e resta come rete: se un testo cresce, scorre dentro invece di mangiare il
  /// cielo.
  static double altezzaMassimaScheda(double altezzaSchermo) =>
      altezzaSchermo * 0.24;

  /// Quanto sporge l'etichetta sotto il disegno del corpo.
  static const double _sporgenzaEtichetta = 36;

  /// Quanto occupa in fondo il pulsante che porta oltre, col suo margine.
  static const double _altezzaPulsanteInFondo = 76;

  /// I QUATTRO POSTI DEI CORPI, in frazione dello SPAZIO LIBERO.
  ///
  /// **Decisione del fondatore del 31 luglio 2026.** Si e' smesso di inseguire
  /// la posizione visivamente esatta dei corpi: non serviva al prodotto e stava
  /// costando giri. I corpi stanno in posti scelti da noi, e cio' che resta
  /// esatto e' il DATO, non il pixel: la scheda porta altezza e direzione vere,
  /// calcolate dal motore, e quelle non si toccano.
  ///
  /// Le frazioni sono dello spazio libero e non dello schermo, quindi valgono a
  /// qualunque misura, e sono le stesse per il cielo di adesso e per quello di
  /// nascita: la scena resta riconoscibile.
  ///
  /// La seconda costellazione sta piu' in basso al centro, dove lo spazio
  /// verticale c'e'. Se i corpi sono meno di quattro gli slot avanzati restano
  /// vuoti e gli altri non si spostano.
  static const Offset _moonSlot = Offset(0.5, 0.10);
  static const List<Offset> _highSlots = [
    Offset(0.17, 0.40),
    Offset(0.5, 0.66),
    Offset(0.83, 0.40),
  ];

  // Ancore sparse delle costellazioni ambientali, su una tela piu' ampia dello
  // schermo (coordinate normalizzate, fuori da [0,1] verso i bordi).
  static const Map<String, Offset> _ambientAnchors = {
    'aries': Offset(-0.14, 0.22),
    'taurus': Offset(0.16, -0.1),
    'gemini': Offset(0.46, -0.12),
    'cancer': Offset(0.82, -0.06),
    'leo': Offset(1.16, 0.16),
    'virgo': Offset(1.2, 0.52),
    'libra': Offset(1.12, 0.86),
    'scorpio': Offset(0.86, 1.12),
    'sagittarius': Offset(0.5, 1.16),
    'capricorn': Offset(0.16, 1.12),
    'aquarius': Offset(-0.14, 0.86),
    'pisces': Offset(-0.2, 0.52),
    'orion': Offset(0.26, 0.76),
    'ursa_major': Offset(0.76, 0.74),
    'cassiopeia': Offset(0.32, 0.14),
    'cygnus': Offset(0.7, 0.2),
  };

  void _onPan(DragUpdateDetails d, Size size) {
    setState(() {
      final limit = Offset(size.width * 0.4, size.height * 0.35);
      _cam = Offset(
        (_cam.dx + d.delta.dx).clamp(-limit.dx, limit.dx),
        (_cam.dy + d.delta.dy).clamp(-limit.dy, limit.dy),
      );
    });
  }

  // Offre il formato (Storia verticale o Feed quadrato), genera la cartolina
  // costruita apposta e apre il foglio di condivisione del sistema con
  // l'immagine e un testo con hashtag. Su Instagram l'immagine va nelle Storie,
  // altrove passa il testo. Solo su device: qui e' best effort.
  Future<void> _share(BuildContext context, DateTime now, MoonPhase moon,
      List<Zodiac> high, MaestroPalette palette) async {
    final format = await _chooseFormat(context, palette);
    if (format == null || !context.mounted) return;
    try {
      final bytes = await SkyPostcard.render(
          now: now,
          moon: moon,
          high: high,
          palette: palette,
          format: format,
          birth: widget.birth);
      final dir = await getTemporaryDirectory();
      final kind = widget.birth ? 'nascita' : 'cielo';
      final file = File('${dir.path}/esoteric_${kind}_${format.name}.png');
      await file.writeAsBytes(bytes);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'image/png')],
          text: SkyPostcard.shareText(now, birth: widget.birth),
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Non è stato possibile condividere ora.')),
      );
    }
  }

  Future<PostcardFormat?> _chooseFormat(
      BuildContext context, MaestroPalette palette) {
    return showModalBottomSheet<PostcardFormat>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.fromLTRB(SpacingTokens.lg, SpacingTokens.md,
            SpacingTokens.lg, SpacingTokens.xl),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [palette.surfaceElevated, palette.deepest],
          ),
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(SpacingTokens.radiusXl)),
          border: Border.all(color: palette.gold.withValues(alpha: 0.3)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Condividi il tuo cielo',
                  style: TypographyTokens.display(size: 18)
                      .copyWith(color: palette.goldSoft)),
              const SizedBox(height: SpacingTokens.md),
              _FormatOption(
                itemKey: const Key('share_story'),
                icon: Icons.crop_portrait_rounded,
                title: 'Storia',
                subtitle: 'Verticale, per le Storie.',
                palette: palette,
                onTap: () =>
                    Navigator.of(sheetContext).pop(PostcardFormat.story),
              ),
              _FormatOption(
                itemKey: const Key('share_feed'),
                icon: Icons.crop_square_rounded,
                title: 'Feed',
                subtitle: 'Quadrato, per il feed.',
                palette: palette,
                onTap: () =>
                    Navigator.of(sheetContext).pop(PostcardFormat.feed),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final now = widget.now ?? DateTime.now();
    final moon = MoonPhase.forDate(now);
    final high = NightSky.constellationsHighTonight(now);
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final parallax = context.watch<ParallaxController>();

    // Deriva del giroscopio; con Riduci Movimento si ferma. Il trascinamento
    // del dito resta sempre. La camera e' pan piu' tilt.
    final tilt = reduceMotion ? Offset.zero : parallax.layerOffset(1.0);
    final cam = _cam + tilt;
    // Con Riduci Movimento i piani si muovono insieme (parallasse piatta), cosi'
    // la tela resta esplorabile ma senza effetto di profondita'.
    double depth(double d) => reduceMotion ? 0.9 : d;

    final highKeys = high.map((z) => z.id).toSet();
    final ambient = <(Asterism, Offset)>[
      for (final e in kZodiacAsterisms.entries)
        if (!highKeys.contains(e.value.id))
          (e.value, _ambientAnchors[e.value.id]!),
      for (final a in kBrightAsterisms) (a, _ambientAnchors[a.id]!),
    ];

    // LO SPAZIO LIBERO DEL CIELO, calcolato e non fatto di margini sparsi.
    //
    // Sopra: la barra del titolo piu' l'area sicura di sistema, cioe' orologio e
    // icone del telefono. Sotto: la scheda quando e' aperta, col suo tetto
    // dichiarato, altrimenti solo il margine di respiro.
    //
    // L'etichetta di un corpo sta SOTTO il suo disegno e sporge di 36 punti: il
    // campo si stringe di altrettanto in fondo, altrimenti il corpo starebbe
    // dentro e il suo nome no.
    final schermo = MediaQuery.of(context).size;
    final sicuro = MediaQuery.of(context).padding;
    final cimaLibera = kToolbarHeight + sicuro.top + SpacingTokens.md;
    // SI SOTTRAE TUTTO CIO' CHE COPRE IL CIELO, non solo la scheda.
    //
    // Nel cielo di NASCITA sotto la scheda c'e' anche il pulsante "Leggi la tua
    // carta": lo spazio occupato in fondo e' quindi piu' grande, e sottraendo
    // la sola scheda i corpi finivano sotto cio' che sta ancora piu' in basso.
    // Era la seconda porta della stessa schermata, che e' la stessa classe con
    // `birth` vero, e nessuno l'aveva guardata.
    //
    // Se domani si aggiunge un altro piede, il conto lo deve prendere per
    // costruzione: si somma qui, non si spera che qualcuno se ne ricordi.
    final piede = SpacingTokens.lg +
        sicuro.bottom +
        (_selectedKey != null ? altezzaMassimaScheda(schermo.height) : 0.0) +
        (widget.ctaLabel != null ? _altezzaPulsanteInFondo : 0.0);
    final fondoLibero = schermo.height - piede - _sporgenzaEtichetta;
    final campo = Rect.fromLTRB(
        0, cimaLibera, schermo.width, math.max(cimaLibera + 120, fondoLibero));

    final bodies = <_SkyBody>[
      _SkyBody.moon(moon, _moonSlot, birth: widget.birth, cielo: _cielo),
      for (var i = 0; i < high.length && i < _highSlots.length; i++)
        _SkyBody.constellation(high[i], _highSlots[i],
            cielo: _cielo, birth: widget.birth),
    ];
    final selected = bodies.where((b) => b.key == _selectedKey).firstOrNull;

    return Scaffold(
      key: const Key('sky_overview_screen'),
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: ColorTokens.neutralDeepest,
      appBar: AppBar(
        backgroundColor: palette.deepest.withValues(alpha: 0.35),
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: palette.goldSoft),
        automaticallyImplyLeading: false,
        leading: widget.showBack
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                tooltip: 'Indietro',
                onPressed: () => Navigator.of(context).maybePop(),
              )
            : null,
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(SkyPostcard.titleFor(birth: widget.birth),
              style: TypographyTokens.display(size: 20)),
        ),
        actions: [
          IconButton(
            key: const Key('sky_fonti_apri'),
            tooltip: 'Fonti e metodo',
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: _mostraFontiEMetodo,
          ),
          IconButton(
            key: const Key('sky_share'),
            icon: const Icon(Icons.ios_share_rounded),
            tooltip: 'Condividi il tuo cielo',
            onPressed: () => _share(context, now, moon, high, palette),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          // La camera vista: pan del dito, deriva del giroscopio e, se il luogo
          // e' noto, l'orientamento sul luogo reale dell'utente.
          final camView = cam + _orientOffset(size);
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanUpdate: (d) => _onPan(d, size),
            onTap: () => setState(() => _selectedKey = null),
            child: Stack(
              children: [
                // Fondo immersivo: Via Lattea, tre piani di stelle dense, le
                // costellazioni ambientali immerse nel campo.
                Positioned.fill(
                  child: CustomPaint(
                    painter: _SkyFieldPainter(
                      cam: camView,
                      depth: depth,
                      palette: palette,
                      ambient: ambient,
                    ),
                  ),
                ),

                // I corpi alti stanotte, toccabili, sul piano delle
                // costellazioni.
                // I CORPI NON PASSANO PIU' DA UN Transform. La deriva della
                // camera li traslava DOPO il calcolo, quindi li portava fuori
                // dal campo libero: il limite applicato prima non teneva. Qui
                // la deriva si somma e poi si taglia dentro il campo, cosi' il
                // cielo si muove ma nessun corpo esce.
                Stack(
                  children: [
                      for (final b in bodies)
                        AnimatedPositioned(
                          // IL CIELO SI COMPONE DENTRO LO SPAZIO LIBERO, non su
                          // tutta l'altezza. Prima i corpi si disponevano su
                          // `size.height` intero, quindi la Luna finiva sotto la
                          // barra del titolo, tagliata dall'orologio di sistema,
                          // e le costellazioni basse finivano sotto la scheda,
                          // leggibili in trasparenza sotto il vetro.
                          duration: reduceMotion
                              ? Duration.zero
                              : const Duration(milliseconds: 420),
                          curve: Curves.easeOutCubic,
                          left: b.slot.dx * size.width -
                              b.size / 2 +
                              (camView * depth(0.42)).dx,
                          top: (campo.top +
                                  b.slot.dy * campo.height -
                                  b.size / 2 +
                                  (camView * depth(0.42)).dy)
                              .clamp(
                                  campo.top,
                                  math.max(
                                      campo.top,
                                      campo.bottom -
                                          b.size -
                                          _sporgenzaEtichetta)),
                          width: b.size,
                          height: b.size + 36,
                          child: _BodyView(
                            body: b,
                            selected: b.key == _selectedKey,
                            palette: palette,
                            onTap: () =>
                                setState(() => _selectedKey = b.key),
                          ),
                        ),
                  ],
                ),

                // Scheda in basso: cosa e', nella voce di Medora. Sta sotto
                // l'orizzonte della scena, coi corpi toccabili nella meta'
                // alta della volta: non li copre mai.
                Positioned(
                  left: SpacingTokens.lg,
                  right: SpacingTokens.lg,
                  bottom: SpacingTokens.lg,
                  child: SafeArea(
                    top: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: altezzaMassimaScheda(schermo.height),
                          ),
                          child: SingleChildScrollView(
                            child: _SkyInfoCard(
                            selected: selected,
                            palette: palette,
                            oriented: _place != null,
                            birth: widget.birth,
                            // Il tratto che nessuno percorreva: la schermata
                            // non aveva mai letto il profilo, quindi la nota
                            // mentiva proprio a chi aveva registrato tutto.
                            registrata: widget.nascitaRegistrata ??
                                (context
                                        .watch<ProfileController?>()
                                        ?.identity
                                        .isExample ==
                                    false)),
                          ),
                        ),
                        if (widget.ctaLabel != null) ...[
                          const SizedBox(height: SpacingTokens.md),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              key: const Key('sky_cta'),
                              style: FilledButton.styleFrom(
                                backgroundColor: palette.gold,
                                foregroundColor: palette.deepest,
                                padding: const EdgeInsets.symmetric(
                                    vertical: SpacingTokens.md),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      SpacingTokens.radiusPill),
                                ),
                              ),
                              onPressed: widget.onCta,
                              child: Text(widget.ctaLabel!,
                                  style: TypographyTokens.body(
                                          size: 17, weight: 600)
                                      .copyWith(color: palette.deepest)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Un corpo celeste toccabile: la Luna oppure una costellazione alta.
class _SkyBody {
  const _SkyBody({
    required this.key,
    required this.label,
    required this.description,
    required this.slot,
    required this.size,
    this.moon,
    this.asterism,
    this.datoDiAdesso,
    this.coordinate,
  });

  /// Lo stesso corpo in un altro posto sullo schermo. Serve alla disposizione,
  /// che sposta i corpi per leggibilita' senza toccare nient'altro di loro.
  _SkyBody conSlot(Offset nuovo) => _SkyBody(
        key: key,
        label: label,
        description: description,
        slot: nuovo,
        size: size,
        moon: moon,
        asterism: asterism,
        datoDiAdesso: datoDiAdesso,
        coordinate: coordinate,
      );

  /// La Luna della veduta. Con [birth] vero la didascalia parla della notte in
  /// cui la persona e' nata, non di stanotte: la schermata e' la stessa per i
  /// due cieli, il tempo del racconto no.
  factory _SkyBody.moon(MoonPhase moon, Offset slot,
          {bool birth = false, SkySnapshot? cielo}) =>
      _SkyBody(
        key: 'moon',
        label: 'Luna',
        description: NightSky.describeMoon(moon, birth: birth),
        // DOVE STA DAVVERO, quando il cielo e' stato calcolato. Prima qui
        // c'era solo `slot`, una costante grafica: la posizione entrava nel
        // TESTO della scheda e non in dove il corpo si disegna, quindi
        // concedendo il permesso la scena restava identica.
        slot: slot,
        // CENTOTTO, risalita da 78. Il massimo che tiene verdi le dodici prove
        // insieme alle costellazioni a 118: a 124 il campo non basta piu' e
        // l'Acquario finisce sotto la scheda.
        size: 108,
        moon: moon,
        datoDiAdesso: _datoDellaLuna(moon, cielo, birth: birth),
        coordinate: _coordinateDellaLuna(moon, cielo),
      );

  /// Sotto questa altezza un corpo e' oltre l'orizzonte e non si mostra. E' la
  /// stessa soglia con cui il motore filtra le stelle, cosi' i due concordano.
  static const double _altezzaMinima = kAltezzaOrizzonte;

  factory _SkyBody.constellation(Zodiac sign, Offset slot,
          {SkySnapshot? cielo, bool birth = false}) =>
      _SkyBody(
        key: sign.id,
        label: sign.italianName,
        // Anche la costellazione sta dove sta: il suo posto si prende dalla
        // stella piu' luminosa fra quelle che il motore le ha calcolato.
        slot: slot,
        description: NightSky.describe(sign),
        // CENTODICIOTTO, risalite da 104. Il fondatore le voleva verso 130: a
        // 130 quattro prove cadono, perche' con lo slot centrale abbastanza in
        // basso da non lasciare la fascia vuota il corpo finisce sotto la
        // scheda. Centodiciotto e' il massimo che tiene, ed e' un numero
        // misurato e non deciso a priori.
        size: 118,
        asterism: kZodiacAsterisms[sign]!,
        datoDiAdesso: _datoDellaCostellazione(sign, cielo, birth: birth),
        coordinate: _coordinateDellaCostellazione(sign, cielo),
      );

  /// Nome, altezza in gradi e direzione della Luna, piu' la sua fase.
  static String? _coordinateDellaLuna(MoonPhase moon, SkySnapshot? cielo) {
    final astro = cielo?.moon;
    final percento = (moon.illumination * 100).toStringAsFixed(0);
    if (astro == null) {
      // STESSA FORMA DELLE COSTELLAZIONI anche quando sta sotto: dire solo la
      // fase, senza dire dove sta, lasciava la Luna l'unico corpo senza
      // posizione in una schermata che di posizioni parla.
      return 'Luna, sotto il suolo a mezzanotte. ${moon.italianName}, '
          'illuminata al $percento per cento.';
    }
    return 'Luna, ${astro.altDeg.toStringAsFixed(0)} gradi sopra il suolo, '
        '${direzione(astro.azDeg)}, a mezzanotte. ${moon.italianName}, '
        'illuminata al $percento per cento.';
  }

  /// Nome, altezza in gradi e direzione di una costellazione.
  static String? _coordinateDellaCostellazione(
      Zodiac sign, SkySnapshot? cielo) {
    if (cielo == null) return null;
    for (final c in cielo.constellations) {
      final nome = sign.italianName.toLowerCase();
      final suo = c.name.toLowerCase();
      if (!suo.contains(nome) && !nome.contains(suo)) continue;
      final migliore = puntoDellaFigura(c.stars);
      if (migliore == null) {
        return '${sign.italianName}, sotto il suolo: stanotte da qui non si '
            'vedrà.';
      }
      // L'ORA E' PARTE DEL DATO. Senza, quel numero non e' verificabile da
      // nessuno, ed e' esattamente cio' che ha costretto il fondatore a
      // chiedere una verifica esterna.
      return '${sign.italianName}, '
          '${migliore.altDeg.toStringAsFixed(0)} gradi sopra il suolo, '
          '${direzione(migliore.azDeg)}, a mezzanotte.';
    }
    return null;
  }

  /// Il dato calcolato della Luna in questo momento.
  ///
  /// Prima la scheda portava due righe generiche che non nominavano ne' gli
  /// astri di oggi ne' un transito: un cielo che si dichiara "adesso" e poi
  /// parla in generale e' un fondale. Qui c'e' la fase con la percentuale di
  /// illuminazione, il segno in cui la Luna si trova ORA e la sua altezza sopra
  /// il suolo.
  static String? _datoDellaLuna(MoonPhase moon, SkySnapshot? cielo,
      {bool birth = false}) {
    final percento = (moon.illumination * 100).toStringAsFixed(0);
    final base = '${moon.italianName}, illuminata al $percento per cento';
    if (cielo == null) {
      // Verita' prima di ricchezza: senza istantanea non si inventa un'altezza.
      return '$base. Il segno e la posizione sul suolo arrivano quando il '
          'cielo risulta calcolato su un luogo.';
    }
    final segno = NightSky.moonSign(cielo.istanteLocale).italianName;
    final alt = cielo.moon?.altDeg;
    // Due difetti stavano in queste tre righe. Il dollaro era ESCAPATO, quindi
    // a video si leggeva il codice invece del numero. E il frammento diceva
    // gia' "adesso" mentre la frase lo rimetteva davanti: "Adesso adesso sta
    // a ...". Ora il frammento porta il fatto e la frase la sua cornice.
    // LA LUNA MOSTRA ANCHE LA SUA DIREZIONE, come le costellazioni: la sua
    // scheda dava fase e illuminazione e si fermava, mentre di ogni figura si
    // diceva gradi E direzione. Stessa forma per tutti, piu' la fase che e'
    // sua e resta.
    final az = cielo.moon?.azDeg;
    final dove = alt == null
        ? 'sta sotto il suolo'
        : 'sta a ${alt.toStringAsFixed(0)} gradi sopra il suolo, '
            '${direzione(az!)}';
    return '$base, in $segno. ${quando(birth)} $dove.';
  }

  /// Dove sta una costellazione adesso: se sorge, culmina o tramonta.
  ///
  /// Se il motore non ha quella costellazione fra le sue, lo DICHIARA invece di
  /// riempire con una frase generica.
  static String? _datoDellaCostellazione(Zodiac sign, SkySnapshot? cielo,
      {bool birth = false}) {
    if (cielo == null) {
      return 'La sua posizione sopra il suolo arriva quando il cielo '
          'risulta calcolato su un luogo.';
    }
    final nome = sign.italianName.toLowerCase();
    SkyConstellation? trovata;
    for (final c in cielo.constellations) {
      if (c.name.toLowerCase().contains(nome) ||
          nome.contains(c.name.toLowerCase())) {
        trovata = c;
        break;
      }
    }
    if (trovata == null) {
      // Non dovrebbe piu' accadere per le dodici zodiacali: il catalogo che
      // risponde le ha tutte, e una prova cade se una torna a mancare. Resta
      // per le figure fuori zodiaco che il motore non segue.
      return 'Questa costellazione non sta fra quelle che il motore segue, '
          'quindi la sua altezza sul suolo non la posso calcolare.';
    }
    // La stessa soglia del motore, non una sua. Con meno cinque qui e meno
    // due nel filtro, chi stava in mezzo veniva tolto dal motore e cercato da
    // qui: il messaggio giusto non usciva mai.
    final alte =
        trovata.stars.where((s) => s.altDeg > kAltezzaOrizzonte).toList();
    if (alte.isEmpty) {
      // NEL CIELO DI NASCITA NON SI DICE "ADESSO": quella schermata descrive
      // l'istante in cui la persona e' nata, non questo momento.
      return birth
          ? 'Quella notte stava sotto il suolo: da li non si vedeva.'
          : 'Stanotte sta sotto il suolo: da qui non si vedrà.';
    }
    // DUE STELLE DIVERSE NELLA STESSA FRASE, ed era un difetto vero: l'altezza
    // era il MASSIMO fra le stelle alte, la direzione quella della PRIMA
    // dell'elenco, che e' un'altra stella. Ora parlano tutte e due della
    // stella piu' luminosa, la stessa che usa la scheda: un punto solo, quello
    // dichiarato in [kPuntoDellaFigura].
    final riferimento = puntoDellaFigura(alte)!;
    final alt = riferimento.altDeg;
    final az = riferimento.azDeg;
    final fase = alt < 10
        ? (az < 180 ? 'sta sorgendo a est' : 'sta tramontando a ovest')
        : alt > 55
            ? 'sta culminando alta nel cielo'
            : (az < 180 ? 'sale verso il culmine' : 'scende verso il suolo');
    return '${quando(birth)} $fase, a ${alt.toStringAsFixed(0)} gradi '
        'sopra il suolo.';
  }

  final String key;
  final String label;
  final String description;
  final Offset slot;
  final double size;
  final MoonPhase? moon;
  final Asterism? asterism;

  /// Il dato calcolato di questo momento, quando c'e'. Nullo mai in pratica:
  /// quando un dato non e' calcolabile la stringa lo dichiara.
  final String? datoDiAdesso;

  /// LE COORDINATE DEL CORPO, che sono l'unica cosa esatta rimasta a schermo.
  ///
  /// Nome, altezza in gradi sull'orizzonte e direzione cardinale dall'azimut.
  /// Con gli slot fissi la posizione a video non e' piu' quella reale, quindi
  /// il vero sta qui: il dato resta esatto anche quando il pixel non lo e'.
  final String? coordinate;

  /// La direzione cardinale da un azimut in gradi.
  static String direzione(double azDeg) {
    const nomi = [
      'a nord',
      'a nord-est',
      'a est',
      'a sud-est',
      'a sud',
      'a sud-ovest',
      'a ovest',
      'a nord-ovest',
    ];
    final giro = azDeg % 360;
    return nomi[(((giro + 22.5) % 360) ~/ 45).clamp(0, 7)];
  }
}

/// Rende un corpo con la sua etichetta sotto, evidenziato quando selezionato.
class _BodyView extends StatelessWidget {
  const _BodyView({
    required this.body,
    required this.selected,
    required this.palette,
    required this.onTap,
  });

  final _SkyBody body;
  final bool selected;
  final MaestroPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Widget visual = body.moon != null
        ? MoonWidget(phase: body.moon, size: body.size * 0.5)
        : CustomPaint(
            size: Size(body.size, body.size),
            painter: _AsterismPainter(
              figure: body.asterism!,
              color: selected ? palette.goldSoft : palette.gold,
              highlighted: true,
              emphasis: selected ? 1.0 : 0.82,
            ),
          );

    return GestureDetector(
      key: Key('sky_body_${body.key}'),
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
              width: body.size,
              height: body.size,
              child: Center(child: visual)),
          const SizedBox(height: 2),
          Text(
            body.label,
            maxLines: 1,
            style: TypographyTokens.label(size: 11).copyWith(
              color: selected ? palette.goldSoft : ColorTokens.textSecondary,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Disegna un asterismo dentro il riquadro del corpo, con le stelle piu'
/// brillanti piu' grandi e le linee dorate.
class _AsterismPainter extends CustomPainter {
  _AsterismPainter({
    required this.figure,
    required this.color,
    required this.highlighted,
    this.emphasis = 1.0,
  });

  final Asterism figure;
  final Color color;
  final bool highlighted;
  final double emphasis;

  @override
  void paint(Canvas canvas, Size size) {
    final pad = size.width * 0.1;
    final rect =
        Rect.fromLTWH(pad, pad, size.width - pad * 2, size.height - pad * 2);
    Offset map(Offset p) =>
        Offset(rect.left + p.dx * rect.width, rect.top + p.dy * rect.height);
    final pts = figure.stars.map(map).toList();

    if (highlighted) {
      final glow = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.4
        ..strokeCap = StrokeCap.round
        ..color = color.withValues(alpha: 0.28 * emphasis)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
      for (final (a, b) in figure.lines) {
        canvas.drawLine(pts[a], pts[b], glow);
      }
    }

    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: 0.72 * emphasis);
    for (final (a, b) in figure.lines) {
      canvas.drawLine(pts[a], pts[b], line);
    }

    for (var i = 0; i < pts.length; i++) {
      final m = figure.mag[i];
      canvas.drawCircle(
        pts[i],
        1.4 + m * 2.0,
        Paint()..color = Colors.white.withValues(alpha: (0.55 + 0.45 * m) * emphasis),
      );
      if (m >= 0.9) {
        canvas.drawCircle(
          pts[i],
          3.0 + m * 3.0,
          Paint()
            ..color = color.withValues(alpha: 0.35 * emphasis)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_AsterismPainter old) =>
      old.figure != figure ||
      old.color != color ||
      old.emphasis != emphasis ||
      old.highlighted != highlighted;
}

/// Il fondo immersivo: Via Lattea, tre piani di stelle e le costellazioni
/// ambientali, tutti mossi dalla camera con profondita' diversa.
class _SkyFieldPainter extends CustomPainter {
  _SkyFieldPainter({
    required this.cam,
    required this.depth,
    required this.palette,
    required this.ambient,
  });

  final Offset cam;
  final double Function(double) depth;
  final MaestroPalette palette;
  final List<(Asterism, Offset)> ambient;

  @override
  void paint(Canvas canvas, Size size) {
    _milkyWay(canvas, size, cam * depth(0.06));
    _stars(canvas, size, cam * depth(0.12), seed: 11, count: 260, rMin: 0.3, rMax: 1.1, alpha: 0.55);
    _stars(canvas, size, cam * depth(0.28), seed: 29, count: 120, rMin: 0.5, rMax: 1.7, alpha: 0.7);
    _ambient(canvas, size, cam * depth(0.42));
    _stars(canvas, size, cam * depth(0.55), seed: 71, count: 44, rMin: 0.9, rMax: 2.4, alpha: 0.9);
  }

  void _milkyWay(Canvas canvas, Size size, Offset off) {
    // Una fascia soffusa in diagonale, appena percepibile.
    canvas.save();
    canvas.translate(off.dx, off.dy);
    final rng = math.Random(3);
    final start = Offset(size.width * 0.12, -size.height * 0.1);
    final end = Offset(size.width * 0.9, size.height * 1.12);
    const steps = 26;
    for (var i = 0; i <= steps; i++) {
      final t = i / steps;
      final base = Offset.lerp(start, end, t)!;
      final jitter = Offset(
        (rng.nextDouble() - 0.5) * size.width * 0.14,
        (rng.nextDouble() - 0.5) * size.height * 0.06,
      );
      final radius = size.width * (0.16 + rng.nextDouble() * 0.12);
      canvas.drawCircle(
        base + jitter,
        radius,
        Paint()
          ..color = (i.isEven ? palette.glow : Colors.white)
              .withValues(alpha: 0.03)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, size.width * 0.09),
      );
    }
    canvas.restore();
  }

  void _stars(
    Canvas canvas,
    Size size,
    Offset off, {
    required int seed,
    required int count,
    required double rMin,
    required double rMax,
    required double alpha,
  }) {
    final rng = math.Random(seed);
    final paint = Paint()..style = PaintingStyle.fill;
    for (var i = 0; i < count; i++) {
      // Campo generato su un'area piu' ampia dello schermo, cosi' scorrendo non
      // compaiono bordi vuoti.
      final x = (-0.5 + rng.nextDouble() * 2.0) * size.width + off.dx;
      final y = (-0.4 + rng.nextDouble() * 1.8) * size.height + off.dy;
      final m = rng.nextDouble();
      final r = rMin + m * (rMax - rMin);
      final a = (alpha * (0.4 + 0.6 * m)).clamp(0.0, 1.0);
      paint.color = Colors.white.withValues(alpha: a);
      canvas.drawCircle(Offset(x, y), r, paint);
      // Qualche stella piu' brillante ha un piccolo alone caldo.
      if (m > 0.94) {
        canvas.drawCircle(
          Offset(x, y),
          r * 2.6,
          Paint()
            ..color = palette.goldSoft.withValues(alpha: 0.12)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
        );
      }
    }
  }

  void _ambient(Canvas canvas, Size size, Offset off) {
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..strokeCap = StrokeCap.round
      ..color = palette.gold.withValues(alpha: 0.16);
    final scale = size.width * 0.2;
    for (final (fig, anchor) in ambient) {
      final center = Offset(anchor.dx * size.width, anchor.dy * size.height) + off;
      Offset map(Offset p) =>
          center + Offset((p.dx - 0.5) * scale, (p.dy - 0.5) * scale);
      final pts = fig.stars.map(map).toList();
      for (final (a, b) in fig.lines) {
        canvas.drawLine(pts[a], pts[b], line);
      }
      for (var i = 0; i < pts.length; i++) {
        final m = fig.mag[i];
        canvas.drawCircle(
          pts[i],
          0.9 + m * 1.4,
          Paint()..color = Colors.white.withValues(alpha: 0.28 + 0.4 * m),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_SkyFieldPainter old) =>
      old.cam != cam || old.palette != palette;
}

/// Scheda in basso: se un corpo e' scelto ne mostra etichetta e riga; altrimenti
/// invita a toccare il cielo. In coda, la nota in-world sui pianeti.
class _SkyInfoCard extends StatelessWidget {
  const _SkyInfoCard({
    required this.selected,
    required this.palette,
    this.oriented = false,
    this.birth = false,
    this.registrata = false,
  });

  final _SkyBody? selected;
  final MaestroPalette palette;

  /// Se il cielo e' orientato sul luogo reale dell'utente.
  final bool oriented;

  /// Se e' il cielo di nascita: la voce di Medora parla dell'identita'.
  final bool birth;

  /// Se la nascita mostrata e' quella REGISTRATA dalla persona.
  ///
  /// La nota diceva sempre "veduta d'esempio finche' non registri nascita e
  /// luogo", anche a chi aveva appena registrato tutti e due: la frase era
  /// scritta a mano e non guardava mai il profilo. Adesso lo guarda.
  final bool registrata;

  @override
  Widget build(BuildContext context) {
    final s = selected;
    return Container(
      key: const Key('sky_scheda'),
      padding: const EdgeInsets.all(SpacingTokens.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            palette.surfaceElevated.withValues(alpha: 0.88),
            palette.deepest.withValues(alpha: 0.88),
          ],
        ),
        borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
        border: Border.all(color: palette.gold.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. UNA RIGA CHE DICE COS'E'.
          //
          // Il fondatore aveva proposto "questa e' la posizione esatta del
          // cielo alla tua nascita". Con gli slot fissi quella frase sarebbe
          // FALSA, perche' la disposizione a schermo non e' piu' quella reale,
          // e la trasparenza metodologica vieta di dichiarare cio' che non si
          // fa. Questa dice il vero e non toglie niente: i corpi sono quelli
          // veri, l'altezza e' quella vera, la disposizione e' per leggibilita'.
          Text(
            birth
                ? 'Il cielo della tua nascita: i corpi che c\'erano davvero, '
                    'con la loro altezza vera su quell\'orizzonte.'
                : 'Il cielo di stanotte: i corpi che ci saranno davvero a '
                    'mezzanotte, con la loro altezza vera sul tuo orizzonte.',
            style: TypographyTokens.body(size: 13)
                .copyWith(color: ColorTokens.textSecondary, height: 1.35),
          ),
          // 2. LE COORDINATE DEL CORPO TOCCATO, che cambiano a ogni tocco.
          if (s != null) ...[
            const SizedBox(height: SpacingTokens.sm),
            Text(
              s.coordinate ?? s.label,
              key: const Key('sky_coordinate'),
              style: TypographyTokens.display(size: 17)
                  .copyWith(color: palette.goldSoft, height: 1.3),
            ),
          ],
        ],
      ),
    );
  }
}

/// Una scelta di formato nel foglio di condivisione.
class _FormatOption extends StatelessWidget {
  const _FormatOption({
    required this.itemKey,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.palette,
    required this.onTap,
  });

  final Key itemKey;
  final IconData icon;
  final String title;
  final String subtitle;
  final MaestroPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: itemKey,
      borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.sm, vertical: SpacingTokens.sm),
        child: Row(
          children: [
            Icon(icon, color: palette.goldSoft, size: 26),
            const SizedBox(width: SpacingTokens.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TypographyTokens.display(size: 17)),
                  Text(
                    subtitle,
                    style: TypographyTokens.body(size: 13)
                        .copyWith(color: ColorTokens.textSecondary),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: palette.goldSoft),
          ],
        ),
      ),
    );
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final it = iterator;
    return it.moveNext() ? it.current : null;
  }
}
