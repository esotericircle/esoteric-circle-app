import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/astro/zodiac.dart';
import '../../../../core/rituals/animal_catalog.dart';
import '../../../../core/rituals/guide_animal_derivation.dart';
import '../../../../core/sensi/palette_sensoriale.dart';
import '../../../../core/viaggio/diario_dei_viaggi.dart';
import '../../../../core/viaggio/i_quattro_viaggi.dart';
import '../../../../core/viaggio/la_domanda_del_viaggio.dart';
import '../../../../core/viaggio/scena_del_viaggio.dart';
import '../../../../design_system/theme/maestro_palette.dart';
import '../../../../design_system/tokens/color_tokens.dart';
import '../../../../design_system/tokens/spacing_tokens.dart';
import '../../../../design_system/tokens/typography_tokens.dart';
import '../../../../design_system/transizioni/passaggio_del_cerchio.dart';
import '../../../../design_system/components/depth_card.dart';
import '../../../../design_system/typography/paragrafi_di_lettura.dart';
import '../../../../design_system/components/titolo_che_non_si_rompe.dart';
import '../../../maestri/rotta_arte.dart';
import '../../../sigilli/regia_del_cammino.dart';
import '../../widgets/foglio_delle_fonti.dart';
import '../../../../core/maestro/maestro.dart';
import 'il_tunnel_che_scende.dart';
import 'la_girandola_degli_animali.dart';
import 'sfondo_del_mondo_di_sotto.dart';
import 'la_lente_che_scopre.dart';
import 'la_nebbia_e_l_animale.dart';

/// **IL VIAGGIO DELLO SCIAMANO.** Ordine DC voci 01, 04, 05, 06 e 07,
/// 10 settembre 2026.
///
/// **Sostituisce l'Animale Guida**, che il fondatore ha giudicato *"una
/// funzionalita' buttata li': rivela un animale, da' un messaggio, e
/// finisce"*. La causa e' una sola: **oggi l'Animale e' un risultato, e nella
/// tradizione e' un rapporto.**
///
/// Nel core shamanism l'animale di potere non si scopre con un test: si
/// incontra viaggiando, si riconosce dopo che si e' mostrato piu' volte, si
/// nutre perche' resti, e soprattutto **si consulta**: si scende con una
/// domanda e si risale con una risposta.
///
/// **LE FONTI**: Michael Harner, *The Way of the Shaman*, 1980, per il metodo;
/// Mircea Eliade, *Le Chamanisme et les techniques archaiques de l'extase*,
/// 1951, per la cosmologia dei tre mondi.
class ViaggioDelloSciamanoScreen extends StatefulWidget {
  const ViaggioDelloSciamanoScreen({
    super.key,
    required this.userSign,
    this.now,
    this.diario,
  });

  final Zodiac userSign;

  /// L'istante da cui si guarda, dichiarato nelle prove.
  final DateTime? now;

  /// Il diario, iniettabile: **le prove non aspettano nessun archivio**, che
  /// e' la regola della voce DC.16.
  final DiarioDeiViaggi? diario;

  static Route<void> route({required Zodiac userSign, DateTime? now}) {
    return PassaggioDelCerchio.rotta<void>((_) => SogliaArte(
          id: 'guide_animal',
          maestro: Maestro.caligo,
          child: ViaggioDelloSciamanoScreen(userSign: userSign, now: now),
        ));
  }

  @override
  State<ViaggioDelloSciamanoScreen> createState() =>
      _ViaggioDelloSciamanoScreenState();
}

/// **LE TRE VIE CON CUI SI SCENDE.** Ordine DC voce 05, forma rifatta il 10
/// settembre 2026.
///
/// L'ordine ne detta tre e dice che **nessuna e' la via povera**. Fino a
/// questa stesura erano montate tutte e tre e nessuna era dichiarata: un
/// campo di testo, sei pulsanti e una settima riga, tutti allo stesso
/// livello. Adesso sono un selettore, e chi guarda vede che sono tre.
enum ViaDellaDomanda {
  /// Una delle sei gia' scritte.
  scelta,

  /// La propria, scritta a mano.
  scritta,

  /// Nessuna: si scende soltanto per incontrarlo.
  incontro,
}

/// I momenti del viaggio, in fila.
enum FaseDelViaggio {
  /// Si sceglie la porta e si scrive la domanda.
  soglia,

  /// Il dito preme e si scende.
  discesa,

  /// La nebbia, che la mano apre.
  nebbia,

  /// L'incontro, e la scelta fra le tre ombre.
  incontro,

  /// **LA LENTE: si e' seguita un'ombra, e adesso la si scopre.**
  /// Ordine DE voce 03.
  lente,

  /// La scena che si riporta su.
  risalita,
}

class _ViaggioDelloSciamanoScreenState
    extends State<ViaggioDelloSciamanoScreen> {
  late final DiarioDeiViaggi _diario =
      widget.diario ?? DiarioDeiViaggi(orologio: () => _adesso);

  DateTime get _adesso => widget.now ?? DateTime.now();

  FaseDelViaggio _fase = FaseDelViaggio.soglia;

  /// **QUANTO SI E' SCESI**, da 0 a 1, e **la muove il dito**.
  double _scesi = 0;
  Timer? _discesa;

  /// I varchi aperti nella nebbia dalla mano.
  final List<VarcoNellaNebbia> _varchi = [];

  final TextEditingController _domanda = TextEditingController();

  /// **CON CHE COSA SI SCENDE**, e le tre vie sono dichiarate come tre.
  ViaDellaDomanda _via = ViaDellaDomanda.scelta;
  String _temaScelto = '';

  ScenaDelViaggio? _scena;
  String? _seguito;
  bool _caricato = false;

  /// **QUANTO DURA LA DISCESA. VENTI SECONDI, POI NOVE.** Ordine DE voce 06.
  ///
  /// **CHE COSA C'ERA PRIMA, sotto la Regola D.** Quarantacinque secondi la
  /// prima volta e venti dal secondo viaggio in poi, scritti dalla voce
  /// DC.07. Il fondatore: *"la discesa da quaranta a novanta secondi e' troppo
  /// lunga e la colpa e' dell'ordine precedente"*.
  ///
  /// **PERCHE' VENTI E NON QUARANTACINQUE.** Venti secondi col dito premuto
  /// **senza mai staccarlo** sono gia' un impegno: nessuno tiene un dito fermo
  /// per venti secondi per sbaglio. Quarantacinque erano il doppio del tempo
  /// in cui la galleria ha finito di dire cio' che ha da dire, e la seconda
  /// meta' era attesa pura.
  ///
  /// **PERCHE' NOVE E NON OTTO NE' DIECI.** L'ordine concede otto o dieci, e
  /// nove sta in mezzo: e' **meno della meta'** della prima discesa, che e' il
  /// segnale che la strada e' conosciuta, e resta sopra gli otto secondi
  /// perche' sotto quel tempo il punto di fuga non fa in tempo ad aprirsi e la
  /// galleria si legge come una dissolvenza.
  static const Duration primaDiscesa = Duration(seconds: 20);
  static const Duration discesaConosciuta = Duration(seconds: 9);

  Duration get _quantoDura =>
      _diario.quanteDiscese == 0 ? primaDiscesa : discesaConosciuta;

  @override
  void initState() {
    super.initState();
    // **NON SI ASPETTA L'ARCHIVIO.** Ordine DC voce 16: se il diario non
    // risponde, si scende lo stesso e questa e' la prima discesa.
    unawaited(_diario.carica().then((_) {
      if (mounted) setState(() => _caricato = true);
    }));
  }

  @override
  void dispose() {
    _discesa?.cancel();
    _domanda.dispose();
    super.dispose();
  }

  /// **LE FASI IN CUI LA SCENA OCCUPA TUTTO.**
  ///
  /// La discesa e la nebbia sono immagini continue, senza niente da leggere
  /// in cima, e una striscia di pagina sopra le smentisce.
  ///
  /// **L'INCONTRO NO, ed e' un difetto visto sul telefono 767f596c il 10
  /// settembre 2026**: le tre ombre stanno in tre righe, e con la barra sopra
  /// **la prima delle tre finiva mezza dietro il titolo**. L'incontro non e'
  /// una scena da guardare, e' una scelta fra tre, e una scelta nascosta non
  /// e' una scelta. La soglia e la risalita sono testo, e li' la barra ha il
  /// suo posto da sempre.
  bool get _laScenaEPiena =>
      _fase == FaseDelViaggio.discesa ||
      _fase == FaseDelViaggio.nebbia ||
      // **LA LENTE E' UNA SCENA PIENA, ordine DE voce 03**: l'immagine
      // dell'animale occupa tutto, e una striscia di pagina sopra la
      // smentirebbe.
      _fase == FaseDelViaggio.lente;

  bool get _riconosciuto =>
      IQuattroViaggi.seguitoDaLeQuattroScelte(_diario.scelteInOrdine) != null;

  /// **IL DITO PREME: si scende.** Ordine DC voce 07.
  void _premi() {
    _discesa?.cancel();
    const passo = Duration(milliseconds: 60);
    _discesa = Timer.periodic(passo, (t) {
      if (!mounted) return t.cancel();
      setState(() {
        _scesi = (_scesi +
                passo.inMilliseconds / _quantoDura.inMilliseconds)
            .clamp(0.0, 1.0);
        if (_scesi >= 1.0) {
          t.cancel();
          _fase = FaseDelViaggio.nebbia;
          unawaited(PaletteSensoriale.vibra(context, SchemaAptico.tocco));
        }
      });
    });
  }

  /// **IL DITO SI ALZA: ci si ferma.** Non si torna su: si resta dove si e'.
  void _lascia() {
    _discesa?.cancel();
    _discesa = null;
  }

  /// **LA MANO APRE UN VARCO NELLA NEBBIA**, che si richiude piano.
  void _apriIlVarco(Offset dove) {
    setState(() => _varchi.add(VarcoNellaNebbia(dove: dove, quantoEAperto: 1)));
    // Tre varchi bastano ad arrivare all'incontro: la nebbia non e' un muro.
    if (_varchi.length >= 3) {
      setState(() => _fase = FaseDelViaggio.incontro);
    }
  }

  /// **SI SEGUE UN'OMBRA, E SI VA A GUARDARLA DA VICINO.**
  /// Ordine DE voce 03.
  ///
  /// **Prima la scelta si depositava subito e si risaliva**: seguivi un'ombra
  /// e ti ritrovavi il testo del ritorno. Adesso fra le due cose c'e' la
  /// lente, che e' il momento in cui quell'ombra smette di essere una massa
  /// scura e diventa **zampe, manto, collo**, un pezzo per discesa.
  void _segui(String nome) {
    setState(() {
      _seguito = nome;
      _fase = FaseDelViaggio.lente;
    });
  }

  /// **L'ILLUSTRAZIONE VERA DI UN NOME**, o nulla se quel nome non ha arte.
  GuideAnimal? _animale(String? nome) {
    if (nome == null) return null;
    for (final a in AnimalCatalog.animals) {
      if (a.name == nome) return a;
    }
    return null;
  }

  /// **SI RISALE, E SOLO ADESSO LA SCELTA SI DEPOSITA.**
  ///
  /// **La discesa vale quando e' finita**, ed e' la stessa legge che la
  /// Meditazione ha imparato nell'ordine DD: fermarsi a meta' non e'
  /// compiere. Chi chiude l'app davanti alla lente non ha bruciato la sua
  /// discesa del giorno.
  Future<void> _risaliDallaLente() async {
    final nome = _seguito;
    if (nome == null) return;
    final quante = _diario.quanteDiscese;
    final nitidezza = NitidezzaDellaScena.dopoGiorni(
        _diario.giorniDallUltima ?? 0);
    final domanda =
        LaDomandaDelViaggio.oppureIlMomento(_domanda.text);
    // **LA VIA DI SOTTO, e per adesso e' l'unica montata.** Ordine DC voce 06:
    // la scelta dei tre elementi la fa Gemini, e quando non arriva si cade su
    // questa composizione deterministica. **La porta al modello non e' ancora
    // aperta**, ed e' dichiarato nel manifesto: quello che c'e' oggi e' il
    // ripiego, che l'ordine vuole comunque esistente e provato.
    final scena = ScenaSenzaModello.componi(
      domanda: domanda,
      giorno: _adesso,
      nitidezza: nitidezza,
    );
    await _diario.segna(UnViaggio(
      quando: _adesso,
      domanda: domanda,
      temaDellaDomanda: _temaScelto,
      pezzi: scena.idDeiPezzi,
      animaleSeguito: nome,
      nitidezza: nitidezza,
    ));
    if (!mounted) return;
    setState(() {
      _scena = scena;
      _fase = FaseDelViaggio.risalita;
    });
    // **IL CAMMINO SE NE ACCORGE**, e il gesto porta il suo dettaglio: e' la
    // stessa porta che la Meditazione usa dall'ordine DC voce 06.
    if (mounted) {
      unawaited(RegiaDelCammino.dopoUnGesto(context, 'animale_guida',
          dettagli: {'animale': nome, 'discesa': quante + 1}));
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.caligo));
    return Scaffold(
      backgroundColor: PittoreDelTunnel.bluProfondo,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        // **IL TITOLO NON SI TRONCA.** Difetto visto sul telefono 767f596c:
        // la barra mostrava "IL VIAGGIO DELL...". Il componente di casa lo
        // manda a capo invece di tagliarlo, e non lo rimpicciolisce sotto il
        // pavimento tipografico.
        title: TitoloCheNonSiRompe(
          testo: 'Il Viaggio dello Sciamano',
          stile: TypographyTokens.titoloScheda()
              .copyWith(color: palette.goldSoft),
        ),
        actions: [
          FoglioDelleFonti.bottone(context,
              palette: palette,
              testo: _fonti,
              chiave: 'viaggio_fonti'),
          const AngoloDellaBarra(),
        ],
      ),
      // **LA BARRA STA SOPRA LA SCENA SOLO DOVE LA SCENA E' UNA SCENA.**
      //
      // Due difetti visti sul telefono 767f596c il 10 settembre 2026, e il
      // secondo l'ha fatto la cura del primo. Prima: la barra stava sempre
      // sopra il corpo, e la prima riga della soglia, "Non sei ancora
      // sceso.", finiva **sopra il titolo**. Poi, tolto lo sconfinamento
      // dappertutto, **il tunnel ha perso la sua fascia in alto**: sopra la
      // galleria c'era una striscia di pagina alta quanto la barra.
      //
      // Il confine non e' lo schermo, e' **la fase**: dove si legge un testo
      // la barra ha il suo posto, dove si sta dentro una scena il corpo
      // passa sotto.
      extendBodyBehindAppBar: _laScenaEPiena,
      body: SafeArea(
        top: false,
        child: switch (_fase) {
          FaseDelViaggio.soglia => _laSoglia(palette),
          FaseDelViaggio.discesa => _laDiscesa(palette),
          FaseDelViaggio.nebbia => _laNebbia(palette),
          FaseDelViaggio.incontro => _lIncontro(palette),
          FaseDelViaggio.lente => _laLente(palette),
          FaseDelViaggio.risalita => _laRisalita(palette),
        },
      ),
    );
  }

  /// **LA SOGLIA: il colpo d'occhio, la promessa, la domanda.**
  ///
  /// **RIFATTA IL 10 SETTEMBRE 2026, e la causa e' una frase del fondatore
  /// davanti alla fotografia della voce DC.21**: *"l'utente e' gia' scappato
  /// prima ancora di leggere. Solo testo da leggere, nessuna vena artistica,
  /// nessuna immagine o riquadro che metta in evidenza o guidi l'utente.
  /// Niente di attraente a primo impatto, niente che faccia capire di cosa si
  /// tratta a primo impatto. Le domande buttate li'."*
  ///
  /// **Aveva ragione su tre leggi di casa insieme.** L'anatomia del responso a
  /// quattro strati vuole **il livello visivo PRIMA del testo**, e qui il
  /// primo strato era un paragrafo. La regola dell'ordine AS vuole **meno
  /// testo e piu' diretto**, e qui c'erano tre paragrafi prima di qualunque
  /// cosa si potesse toccare. E le sei domande erano **sei pulsanti di testo
  /// in colonna**, senza un riquadro, senza uno stato acceso, senza niente
  /// che dicesse che erano una scelta.
  ///
  /// **La forma nuova, in quattro pezzi.**
  ///
  /// **Uno, la bocca del tunnel.** La prima cosa che si vede e' la scena, non
  /// una frase: il pittore della discesa a quota zero, che e' esattamente
  /// l'apertura nella terra da cui si scende, con dentro l'occhiello e la
  /// promessa. **La stessa immagine che si vedra' scendendo**, cosi' il colpo
  /// d'occhio non e' una decorazione: e' un'anticipazione vera.
  ///
  /// **Due, i quattro segni.** A che punto si e' non e' piu' una frase in
  /// cima: sono quattro tacche sotto la bocca, accese quante sono le discese.
  /// La frase resta, sotto, per chi legge.
  ///
  /// **Tre, le tre vie, dichiarate come tre.** Scegli una domanda, scrivila
  /// tu, scendi soltanto per incontrarlo. Prima erano un campo di testo, sei
  /// pulsanti e una settima riga, tutti allo stesso livello: chi guardava non
  /// poteva sapere che erano tre strade diverse.
  ///
  /// **Quattro, il pulsante pieno.** Era un contorno in fondo a una colonna
  /// lunga, e a colonna scorsa non si vedeva nemmeno.
  Widget _laSoglia(MaestroPalette palette) {
    final primo = _diario.quanteDiscese == 0;
    final perche = LaDomandaDelViaggio.perCheNonVa(_domanda.text,
        primoViaggio: primo);
    final siPuo = _caricato &&
        _diario.siPuoScendereOggi(giaRiconosciuto: _riconosciuto);
    final pronto = siPuo && (perche == null || _temaScelto.isNotEmpty);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(SpacingTokens.lg, SpacingTokens.md,
          SpacingTokens.lg, SpacingTokens.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ilBoscoDellaSoglia(palette),
          const SizedBox(height: SpacingTokens.lg),
          // **A CHE PUNTO SEI, in quattro segni prima che in una frase.**
          _iQuattroSegni(palette),
          const SizedBox(height: SpacingTokens.sm),
          Text(
            IQuattroViaggi.aChePunto(_diario.quanteDiscese),
            key: const Key('viaggio_a_che_punto'),
            textAlign: TextAlign.center,
            style: TypographyTokens.didascalia()
                .copyWith(color: ColorTokens.textSecondary),
          ),
          const SizedBox(height: SpacingTokens.xl),
          _leTreVie(palette, primo: primo),
          if (perche != null && _temaScelto.isEmpty) ...[
            const SizedBox(height: SpacingTokens.sm),
            Text(perche,
                key: const Key('viaggio_perche_non_si_scende'),
                textAlign: TextAlign.center,
                style: TypographyTokens.didascalia()
                    .copyWith(color: palette.goldSoft)),
          ],
          if (!siPuo && _caricato) ...[
            const SizedBox(height: SpacingTokens.md),
            DepthCard(
              padding: const EdgeInsets.all(SpacingTokens.md),
              child: ParagrafiDiLettura(
                key: const Key('viaggio_non_oggi'),
                testo: IQuattroViaggi.percheSiAspetta,
                // La spiegazione dell attesa si legge per intero, quindi
                // porta la misura del responso.
                stile: TypographyTokens.lettura()
                    .copyWith(color: ColorTokens.textSecondary),
              ),
            ),
          ],
          const SizedBox(height: SpacingTokens.lg),
          FilledButton.icon(
            key: const Key('viaggio_scendi'),
            onPressed:
                pronto ? () => setState(() => _fase = FaseDelViaggio.discesa) : null,
            style: FilledButton.styleFrom(
              backgroundColor: palette.primary,
              foregroundColor: palette.onPrimary,
              minimumSize: const Size.fromHeight(56),
            ),
            icon: const Icon(Icons.south_rounded),
            label: Text('Scendi', style: TypographyTokens.etichetta()),
          ),
        ],
      ),
    );
  }

  /// **IL BOSCO, I DODICI CHE PASSANO, E LA PROMESSA.**
  ///
  /// **E' il colpo d'occhio che mancava**, e sono tre cose in una immagine.
  ///
  /// **Il bosco al crepuscolo** dice dove si e', e non e' una decorazione:
  /// porta gli stessi due colori della galleria, quindi chi guarda la soglia
  /// sta gia' guardando il Mondo di Sotto da fuori. In mezzo c'e' l'apertura
  /// nella terra, che e' il punto piu' chiaro della scena e il posto dove
  /// l'occhio va per primo.
  ///
  /// **I dodici totem che passano in ombra** dicono chi aspetta la' sotto.
  /// Sono gli asset gia' fatti della famiglia `animali`, che fino a oggi si
  /// vedevano soltanto **dopo** aver conosciuto il proprio animale.
  ///
  /// **La promessa in due righe** dice cosa si ottiene, ed e' l'unica cosa
  /// da leggere prima di poter toccare qualcosa.
  Widget _ilBoscoDellaSoglia(MaestroPalette palette) => ClipRRect(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
        child: SizedBox(
          width: double.infinity,
          child: AspectRatio(
            aspectRatio: 1.15,
            child: LayoutBuilder(
              builder: (context, vincoli) => Stack(
                fit: StackFit.expand,
                children: [
                  // **LO SLOT DELLO SFONDO**: l'immagine vera quando c'e',
                  // il bosco dipinto finche' non c'e'. Vedi
                  // `SfondoDelMondoDiSotto`.
                  const SfondoDelMondoDiSotto(key: Key('viaggio_bosco')),
                  // **I DODICI PASSANO ALL'ALTEZZA DELL'APERTURA**, cioe'
                  // davanti alla luce: e' li' che una sagoma si vede.
                  Align(
                    // **PIU' IN ALTO DEL TESTO, e non dietro.** Difetto visto
                    // sul telefono 767f596c: la promessa cadeva sopra il
                    // cervo e il cavallo, e nessuna delle due cose si
                    // leggeva. Un velo non basta quando sotto passa una
                    // figura: le due cose devono stare in due fasce diverse.
                    alignment: const Alignment(0, -0.34),
                    child: GirandolaDegliAnimali(
                        altezza: vincoli.maxHeight * 0.42),
                  ),
                  // Il velo dal basso: il testo chiaro sopra una scena
                  // dipinta ha bisogno di un fondo che non cambi.
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.transparent,
                          const Color(0xFF090610).withValues(alpha: 0.72),
                          const Color(0xFF070510).withValues(alpha: 0.96),
                        ],
                        stops: const [0.0, 0.34, 0.56, 1.0],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(SpacingTokens.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'IL MONDO DI SOTTO',
                            style: TypographyTokens.etichetta().copyWith(
                                color: palette.goldSoft, letterSpacing: 2.4),
                          ),
                          const SizedBox(height: SpacingTokens.xs),
                          Text(
                            'Scendi con una domanda, risali con una risposta.',
                            key: const Key('viaggio_promessa'),
                            style: TypographyTokens.titoloScheda()
                                .copyWith(color: ColorTokens.textPrimary),
                          ),
                          const SizedBox(height: SpacingTokens.xs),
                          Text(
                            'Dodici ti aspettano. Uno verrà con te.',
                            key: const Key('viaggio_i_dodici'),
                            style: TypographyTokens.didascalia()
                                .copyWith(color: palette.goldSoft),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  /// **I QUATTRO SEGNI DEL RICONOSCIMENTO.**
  ///
  /// Quattro tacche, accese quante sono le discese fatte. Ordine DC voce 04:
  /// *"chi guarda vede che manca poco"*, e una tacca lo dice prima e meglio
  /// di una frase.
  Widget _iQuattroSegni(MaestroPalette palette) {
    final quante =
        IQuattroViaggi.contorniDellaSagoma(_diario.quanteDiscese);
    return Row(
      key: const Key('viaggio_i_quattro_segni'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < IQuattroViaggi.quanteDiscese; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Container(
              width: 34,
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: i < quante
                    ? palette.gold
                    : palette.gold.withValues(alpha: 0.22),
              ),
            ),
          ),
      ],
    );
  }

  /// **LE TRE VIE, dichiarate come tre.**
  ///
  /// Un selettore in cima dice quante sono e quale si sta usando, e sotto si
  /// apre soltanto quella scelta. Prima erano un campo, sei pulsanti di testo
  /// e una settima riga, tutti allo stesso livello: **chi guardava non poteva
  /// sapere che erano tre strade diverse**, e infatti il fondatore le ha viste
  /// come domande buttate li'.
  Widget _leTreVie(MaestroPalette palette, {required bool primo}) {
    final vie = [
      (ViaDellaDomanda.scelta, 'Scegli'),
      (ViaDellaDomanda.scritta, 'Scrivila tu'),
      (ViaDellaDomanda.incontro, 'Solo incontro'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'CON CHE COSA SCENDI',
          style: TypographyTokens.etichetta()
              .copyWith(color: palette.goldSoft, letterSpacing: 2.0),
        ),
        if (!primo) ...[
          const SizedBox(height: 2),
          Text(
            'Dal secondo viaggio la domanda è la porta.',
            style: TypographyTokens.didascalia()
                .copyWith(color: ColorTokens.textSecondary),
          ),
        ],
        const SizedBox(height: SpacingTokens.sm),
        SegmentedButton<ViaDellaDomanda>(
          key: const Key('viaggio_le_tre_vie'),
          segments: [
            for (final v in vie)
              ButtonSegment<ViaDellaDomanda>(
                  value: v.$1,
                  label: Text(v.$2, style: TypographyTokens.didascalia())),
          ],
          selected: {_via},
          showSelectedIcon: false,
          // **IL SELETTORE HA IL COLORE DEL MAESTRO.** Con lo stile di
          // fabbrica la voce scelta era grigio lavanda su un dominio rosso e
          // oro: sul telefono si leggeva come un pezzo di un'altra app.
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith((stati) =>
                stati.contains(WidgetState.selected)
                    ? palette.gold.withValues(alpha: 0.34)
                    : Colors.transparent),
            foregroundColor: WidgetStateProperty.resolveWith((stati) =>
                stati.contains(WidgetState.selected)
                    ? palette.gold
                    : palette.goldSoft.withValues(alpha: 0.75)),
            side: WidgetStatePropertyAll(
                BorderSide(color: palette.gold.withValues(alpha: 0.45))),
          ),
          onSelectionChanged: (scelte) => setState(() {
            _via = scelte.first;
            _domanda.clear();
            _temaScelto = _via == ViaDellaDomanda.incontro
                ? LaDomandaDelViaggio.idSoloPerIncontrarlo
                : '';
          }),
        ),
        const SizedBox(height: SpacingTokens.md),
        switch (_via) {
          ViaDellaDomanda.scelta => _leSeiDomande(palette),
          ViaDellaDomanda.scritta => _ilCampoLibero(palette, primo: primo),
          ViaDellaDomanda.incontro => DepthCard(
              key: const Key('viaggio_solo_incontro'),
              padding: const EdgeInsets.all(SpacingTokens.md),
              child: ParagrafiDiLettura(
                testo: 'Scendo soltanto per incontrarlo. La scena parlerà '
                    'del momento che stai vivendo.',
                stile: TypographyTokens.lettura()
                    .copyWith(color: ColorTokens.textSecondary),
              ),
            ),
        },
      ],
    );
  }

  /// **LE SEI DOMANDE, come sei riquadri toccabili.**
  ///
  /// Quello scelto si accende. Prima erano sei righe di testo identiche a
  /// qualunque altra riga di testo della schermata.
  Widget _leSeiDomande(MaestroPalette palette) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final d in LaDomandaDelViaggio.gliaScritte) ...[
            _unaDomanda(palette, d),
            const SizedBox(height: SpacingTokens.xs),
          ],
        ],
      );

  Widget _unaDomanda(MaestroPalette palette, DomandaScritta d) {
    final scelta = _temaScelto == d.tema;
    return Material(
      color: scelta
          ? palette.gold.withValues(alpha: 0.16)
          : Colors.white.withValues(alpha: 0.04),
      borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
      child: InkWell(
        key: Key('viaggio_domanda_${d.id}'),
        // **NIENTE CLICK DI SISTEMA.** Ordine CQ voce 1.08: il Cerchio ha le
        // sue voci, e il tocco di fabbrica di Android non e' una di quelle.
        enableFeedback: false,
        borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
        onTap: () => setState(() {
          _domanda.text = d.testo;
          _temaScelto = d.tema;
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: SpacingTokens.md, vertical: SpacingTokens.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
            border: Border.all(
                color: scelta
                    ? palette.gold
                    : palette.gold.withValues(alpha: 0.22)),
          ),
          child: Row(
            children: [
              Icon(
                scelta
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                size: 18,
                color: scelta
                    ? palette.gold
                    : palette.goldSoft.withValues(alpha: 0.5),
              ),
              const SizedBox(width: SpacingTokens.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(d.tema,
                        style: TypographyTokens.corpo()
                            .copyWith(color: ColorTokens.textPrimary)),
                    if (scelta) ...[
                      const SizedBox(height: 2),
                      Text(d.testo,
                          style: TypographyTokens.didascalia()
                              .copyWith(color: palette.goldSoft)),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// **IL CAMPO LIBERO, con una cornice sua.**
  Widget _ilCampoLibero(MaestroPalette palette, {required bool primo}) =>
      TextField(
        key: const Key('viaggio_domanda'),
        controller: _domanda,
        maxLength: LaDomandaDelViaggio.quantoPuoEssereLunga,
        maxLines: 2,
        minLines: 2,
        onChanged: (_) => setState(() => _temaScelto = ''),
        style:
            TypographyTokens.corpo().copyWith(color: ColorTokens.textPrimary),
        decoration: InputDecoration(
          hintText: primo
              ? 'Che cosa vuoi chiedere, se hai una domanda'
              : 'Che cosa vuoi chiedere',
          hintStyle: TypographyTokens.corpo()
              .copyWith(color: ColorTokens.textSecondary),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.04),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
            borderSide:
                BorderSide(color: palette.gold.withValues(alpha: 0.22)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
            borderSide:
                BorderSide(color: palette.gold.withValues(alpha: 0.22)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
            borderSide: BorderSide(color: palette.gold),
          ),
        ),
      );

  /// **LA DISCESA: il tunnel, e risponde alla mano.**
  Widget _laDiscesa(MaestroPalette palette) => GestureDetector(
        key: const Key('viaggio_dito'),
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _premi(),
        onTapUp: (_) => _lascia(),
        onTapCancel: _lascia,
        child: Stack(
          children: [
            Positioned.fill(
              child: TunnelCheScende(
                  quantoSiEScesi: _scesi, senzaMoto: false),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(SpacingTokens.xl),
                child: Text(
                  _discesa == null
                      ? 'Tieni premuto per scendere'
                      : 'Scendi',
                  key: const Key('viaggio_istruzione_discesa'),
                  style: TypographyTokens.etichetta()
                      .copyWith(color: palette.goldSoft, letterSpacing: 1.4),
                ),
              ),
            ),
          ],
        ),
      );

  /// **LA NEBBIA, che la mano apre.**
  Widget _laNebbia(MaestroPalette palette) => GestureDetector(
        key: const Key('viaggio_nebbia'),
        behavior: HitTestBehavior.opaque,
        onTapDown: (d) => _apriIlVarco(d.localPosition),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                // Qui il vincolo e' gia' stretto e la misura non servirebbe.
                // Si scrive lo stesso: la regola vale per il componente, e
                // una regola con un'eccezione tacita e' una regola che
                // qualcuno copiera' nel posto sbagliato.
                size: Size.infinite,
                painter: PittoreDellaNebbia(
                  varchi: _varchi,
                  senzaMoto: false,
                  densita: NitidezzaDellaScena.dopoGiorni(
                      _diario.giorniDallUltima ?? 0),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(SpacingTokens.xl),
                child: Text('Apri la nebbia con la mano',
                    key: const Key('viaggio_istruzione_nebbia'),
                    style: TypographyTokens.etichetta()
                        .copyWith(color: palette.goldSoft, letterSpacing: 1.4)),
              ),
            ),
          ],
        ),
      );

  /// **L'INCONTRO: tre ombre, e se ne segue una.**
  Widget _lIncontro(MaestroPalette palette) {
    final dalCielo = GuideAnimalDerivation.forSign(widget.userSign);
    final ombre = IQuattroViaggi.treOmbre(dalCielo);
    final quale = _diario.quanteDiscese;
    return Column(
      children: [
        // **LE TRE OMBRE STANNO UNA SOTTO L'ALTRA, e non una accanto
        // all'altra.**
        //
        // Difetto visto sul telefono 767f596c il 10 settembre 2026:
        // affiancate, ognuna aveva a disposizione **un terzo di larghezza**
        // in una finestra alta il doppio di quanto e' larga, e un animale,
        // che e' piu' largo che alto, in quella colonna diventa minuscolo. In
        // riga, invece, ogni ombra ha una scena larga quanto lo schermo, che
        // e' la forma di un animale.
        Expanded(
          child: Column(
            children: [
              for (final a in ombre)
                Expanded(
                  child: GestureDetector(
                    key: Key('viaggio_ombra_${a.name}'),
                    onTap: () => _segui(a.name),
                    // **LA SCENA DELL'OMBRA HA UNA MISURA.**
                    //
                    // Difetto visto sul telefono 767f596c il 10 settembre
                    // 2026, e visto **due volte**: la prima l'ho dato al
                    // contrasto, e la seconda, con la luce dietro gia'
                    // aggiunta, l'incontro era ancora uno schermo vuoto.
                    //
                    // **Un CustomPaint senza figlio e senza `size` si misura
                    // con `constraints.constrain(Size.zero)`.** Dentro una
                    // Column il vincolo trasversale e' largo, non stretto,
                    // quindi la larghezza diventava zero e il pittore
                    // dipingeva su una tela di area nulla. Prima, in Row, era
                    // l'altezza a essere zero. **Le tre ombre non erano
                    // scure: non c'erano.**
                    //
                    // `Size.infinite`, che il tunnel usava fin dal principio,
                    // prende tutto lo spazio concesso.
                    // **L'OMBRA E' LA SAGOMA VERA DI QUELL'ANIMALE.**
                    // Ordine DE voce 03: prima la disegnava una formula, e la
                    // formula faceva **sempre un quadrupede**. Chi seguiva
                    // l'ombra dell'aquila stava seguendo il disegno di un
                    // lupo.
                    child: OmbraDellAnimale(
                      key: Key('viaggio_sagoma_${a.name}'),
                      immagine: a.fullPath,
                      quantaLuce: 0.35 + 0.2 * quale,
                    )                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(SpacingTokens.lg),
          child: ParagrafiDiLettura(
            key: const Key('viaggio_come_si_mostra'),
            testo: IQuattroViaggi.comeSiMostraAlla(quale),
            textAlign: TextAlign.center,
            stile: TypographyTokens.lettura().copyWith(color: palette.goldSoft),
          ),
        ),
      ],
    );
  }

  /// **LA LENTE: SPOSTA E SCOPRI.** Ordine DE voce 03.
  ///
  /// L'animale occupa la scena piena sotto un velo scuro e sfocato, e il dito
  /// muove una lente che rivela in chiaro **solo cio' che copre** e **solo
  /// dentro l'area concessa a questa discesa**.
  ///
  /// **La testa non si vede prima della quarta**, e non per una regola scritta
  /// qui: per costruzione. Tutte e tre le aree stanno sotto il punto piu'
  /// basso della testa di quell'animale, e il centro della lente e' tenuto
  /// dentro l'area rientrato del proprio raggio. Vedi `DoveStaLaTesta`.
  Widget _laLente(MaestroPalette palette) {
    final quale = _diario.quanteDiscese;
    final animale = _animale(_seguito);
    if (animale == null) {
      // **UN NOME SENZA ARTE NON BLOCCA LA DISCESA**, ordine DC voce 16: si
      // risale e basta, e la scena del ritorno arriva lo stesso.
      WidgetsBinding.instance.addPostFrameCallback(
          (_) => unawaited(_risaliDallaLente()));
      return const SizedBox.shrink();
    }
    return Stack(
      children: [
        Positioned.fill(
          child: LenteCheScopre(
            key: Key('viaggio_lente_${animale.name}'),
            nome: animale.name,
            immagine: animale.fullPath,
            discesa: quale,
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(SpacingTokens.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  quale >= IQuattroViaggi.quanteDiscese - 1
                      ? 'Il velo è caduto.'
                      : 'Passa il dito: la lente scopre solo dove può, oggi.',
                  key: const Key('viaggio_istruzione_lente'),
                  textAlign: TextAlign.center,
                  style: TypographyTokens.etichetta()
                      .copyWith(color: palette.goldSoft, letterSpacing: 1.2),
                ),
                const SizedBox(height: SpacingTokens.md),
                FilledButton.icon(
                  key: const Key('viaggio_risali'),
                  onPressed: () => unawaited(_risaliDallaLente()),
                  style: FilledButton.styleFrom(
                    backgroundColor: palette.primary,
                    foregroundColor: palette.onPrimary,
                    minimumSize: const Size.fromHeight(52),
                  ),
                  icon: const Icon(Icons.north_rounded),
                  label:
                      Text('Risali', style: TypographyTokens.etichetta()),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// **LA RISALITA: la scena che si riporta su.**
  Widget _laRisalita(MaestroPalette palette) {
    final scena = _scena;
    if (scena == null) return const SizedBox.shrink();
    final nome = IQuattroViaggi.seguitoDaLeQuattroScelte(
        _diario.scelteInOrdine);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(SpacingTokens.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // **LA SCENA CHE SI RIPORTA SU HA DENTRO L'ANIMALE.**
          //
          // Difetto visto sul telefono 767f596c il 10 settembre 2026: al
          // ritorno c'era **solo testo**, e l'animale che si era appena
          // seguito non compariva da nessuna parte. La regola di casa vuole
          // il livello visivo prima del testo in ogni responso che conti, e
          // questo e' il responso del viaggio.
          //
          // **QUI VIVE LA PIENA LUCE DELLA QUARTA DISCESA**, e qui la guardia
          // misura il sessanta per cento dell'altezza: nella scena del
          // ritorno l'animale e' uno, non uno di tre.
          // **LA SCENA CHE SI RIPORTA SU HA DENTRO L'ANIMALE VERO.**
          // Ordine DE voce 03: prima era la sagoma della formula, e non era
          // il ritratto di nessuno. Adesso e' l'illustrazione, velata finche'
          // non lo si e' riconosciuto e **in piena luce alla quarta**.
          if (_animale(_seguito) != null)
            SizedBox(
              width: double.infinity,
              child: AspectRatio(
                aspectRatio: 1.35,
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(SpacingTokens.radiusLg),
                  child: _riconosciuto
                      ? Image.asset(_animale(_seguito)!.fullPath,
                          key: const Key('viaggio_animale_del_ritorno'),
                          fit: BoxFit.contain)
                      : OmbraDellAnimale(
                          key: const Key('viaggio_animale_del_ritorno'),
                          immagine: _animale(_seguito)!.fullPath,
                          quantaLuce:
                              0.35 + 0.2 * (_diario.quanteDiscese - 1)
                                  .clamp(0, 3),
                        ),
                ),
              ),
            ),
          const SizedBox(height: SpacingTokens.xxl),
          ParagrafiDiLettura(
            key: const Key('viaggio_scena'),
            testo: scena.testo,
            textAlign: TextAlign.center,
            stile: TypographyTokens.lettura()
                .copyWith(color: ColorTokens.textPrimary, height: 1.5),
          ),
          if (NitidezzaDellaScena.laRiga(scena.nitidezza) != null) ...[
            const SizedBox(height: SpacingTokens.sm),
            // **UN TESTO DA LEGGERE PER INTERO PORTA LA MISURA DEL
            // RESPONSO**, e non quella della didascalia: due misure per lo
            // stesso genere di testo si leggono come due voci diverse.
            ParagrafiDiLettura(
                testo: NitidezzaDellaScena.laRiga(scena.nitidezza)!,
                key: const Key('viaggio_nitidezza'),
                textAlign: TextAlign.center,
                stile: TypographyTokens.lettura()
                    .copyWith(color: palette.goldSoft)),
          ],
          const SizedBox(height: SpacingTokens.lg),
          // **IL NOME SOLO ALLA QUARTA**, ordine DC voce 04.
          if (nome != null)
            ParagrafiDiLettura(
              key: const Key('viaggio_il_nome'),
              testo: 'È il $nome. Adesso lo conosci.',
              textAlign: TextAlign.center,
              // **ORO CHIARO E NON ORO PIENO**, e lo ha chiesto il censimento
              // dei grigi: su un fondo di Maestro l'oro pieno arriva a 5,42
              // contro i 7,0 che il corpo di lettura pretende.
              stile: TypographyTokens.lettura()
                  .copyWith(color: palette.goldSoft),
            )
          else
            ParagrafiDiLettura(
              key: const Key('viaggio_ancora_no'),
              testo: IQuattroViaggi.aChePunto(_diario.quanteDiscese),
              textAlign: TextAlign.center,
              stile: TypographyTokens.lettura()
                  .copyWith(color: ColorTokens.textSecondary),
            ),
          if (_seguito != null) const SizedBox(height: SpacingTokens.md),
        ],
      ),
    );
  }

  /// **LE FONTI, tutte e due nominate.** Ordine DC voce 01.
  static const String _fonti =
      'Il metodo del viaggio viene dal core shamanism di Michael Harner, The '
      'Way of the Shaman, 1980: si scende da un\'apertura nella terra, si '
      'incontra un animale. Lo si riconosce quando si è mostrato almeno '
      'quattro volte.\n\n'
      'La cosmologia dei tre mondi, con il Mondo di Sotto raggiunto per un '
      'tunnel, è documentata da Mircea Eliade in Le Chamanisme et les '
      'techniques archaiques de l\'extase, 1951.\n\n'
      'Il viaggio è un\'esperienza di immaginazione guidata dentro una '
      'cornice di crescita personale. Non è una pratica clinica e non '
      'sostituisce nessuna cura.';
}

/// Il catalogo degli animali, per chi legge questa schermata: sta qui solo
/// come promemoria del fatto che le ombre vengono da li' e non da un elenco
/// scritto a mano.
List<GuideAnimal> get animaliDelCerchio => AnimalCatalog.animals;
