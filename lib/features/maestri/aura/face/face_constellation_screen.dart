import 'dart:async';
import '../../../ricordi/azioni_del_responso.dart';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../../../sigilli/regia_del_cammino.dart';
import '../../../../core/face/motore_del_volto.dart';
import '../../../../core/face/motore_mediapipe.dart';
import '../../../../core/face/scansione_a_pose.dart';
import 'package:mediapipe_face_mesh/mediapipe_face_mesh.dart';
import 'fascio_di_scansione.dart';
import '../../../../core/face/espressione_dell_istante.dart';
import '../../../../core/face/storico_degli_istanti.dart';
import '../../../../core/face/tenuta_di_fronte.dart';
import '../../../../core/face/mian_xiang.dart';
import 'colore_dell_elemento.dart';
import 'lo_specchio_dell_istante.dart';
import 'maschera_che_segue.dart';
import 'package:provider/provider.dart';

import '../../../../core/archetypes/archetype_allowance.dart';
import '../../../../core/archetypes/archetype_sky.dart';
import '../../../../core/archetypes/archetype_transits.dart' show Pianeta;
import '../../../../core/entitlement/entitlement_service.dart';
import '../../../../core/entitlement/tier.dart';
import '../../../../core/face/cancello_della_scansione.dart';
import '../../../../core/face/face_classifier.dart';
import '../../../../core/face/face_corpus.dart';
import '../../../../core/face/face_history.dart';
import '../../../../core/face/face_trait.dart';
import '../../../../core/face/face_transits.dart';
import '../../../../core/maestro/maestro.dart';
import '../../../../design_system/components/cosmos_background.dart';
import '../../../../design_system/components/depth_card.dart';
import '../../../../design_system/components/scroll_reveal.dart';
import '../../../../design_system/theme/maestro_palette.dart';
import '../../../../design_system/tokens/color_tokens.dart';
import '../../../../design_system/tokens/spacing_tokens.dart';
import '../../../../design_system/tokens/typography_tokens.dart';
import '../../../../design_system/typography/paragrafi_di_lettura.dart';
import '../../chat/chat_openers.dart';
import 'face_constellation.dart';
import 'face_constellation_painter.dart';
import 'face_share_card.dart';
import 'face_silhouette.dart';
import '../../rotta_arte.dart';
import '../../../../design_system/components/interruttore_del_cerchio.dart';
import '../../../../design_system/components/titolo_che_non_si_rompe.dart';
import '../../../../core/condivisione/premio_della_condivisione.dart';
import '../../../../design_system/transizioni/passaggio_del_cerchio.dart';
import '../../../../design_system/transizioni/velo_del_cerchio.dart';

/// La Costellazione del Viso, dominio Aura.
///
/// La lettura dei tratti e' tutta nel cuore deterministico (`FaceClassifier`,
/// `FaceCorpus`): qui c'e' la messa in scena, nessuna AI, nessuna casualita'. Il
/// volto si rileva on-device coi contorni di ML Kit; nessuna immagine lascia il
/// dispositivo. Chi non ha fotocamera o nega il permesso passa dal ripiego
/// tattile, che alimenta lo stesso motore e porta allo stesso responso.
class FaceConstellationScreen extends StatefulWidget {
  const FaceConstellationScreen({
    super.key,
    this.clock,
    this.pianetiDelGiorno,
    this.readingIniziale,
    this.partiDalRipiego = false,
  });

  final DateTime Function()? clock;
  final Set<Pianeta> Function(DateTime)? pianetiDelGiorno;

  /// Una lettura gia' pronta, per i test e le anteprime: salta la cattura e va
  /// al responso in modo deterministico.
  final FaceReading? readingIniziale;

  /// Apre direttamente sul ripiego tattile, per le anteprime del ripiego.
  final bool partiDalRipiego;

  /// LA SOGLIA DI QUESTA ARTE, dichiarata una volta sola. Ordine P voce 27.
  ///
  /// **Perche' esiste.** L'identificativo dell'arte e il suo Maestro erano
  /// scritti dentro `route`, cioe' in un punto che solo l'app attraversa. Le
  /// anteprime montavano la schermata NUDA, con un `MaestroScope` costruito a
  /// mano: senza `ArteCorrente` e senza `ConCuore`, quindi senza il cuore delle
  /// arti preferite nella barra, e con la palette presa dal controller invece
  /// che dichiarata dal proprietario. Provavano una scena che l'app non monta.
  ///
  /// Adesso la soglia si chiede da qui, e la chiedono tutti e due: la rotta
  /// dell'app e la cattura dell'anteprima. Un solo punto dichiara chi e' il
  /// proprietario di quest'arte.
  static Widget conLaSoglia(Widget schermata) => SogliaArte(
        id: 'face_constellation',
        maestro: Maestro.aura,
        child: schermata,
      );

  static Route<void> route({
    DateTime Function()? clock,
    Set<Pianeta> Function(DateTime)? pianetiDelGiorno,
  }) {
    return PassaggioDelCerchio.rotta<void>(
        (_) => conLaSoglia(FaceConstellationScreen(
              clock: clock,
              pianetiDelGiorno: pianetiDelGiorno,
            )));
  }

  @override
  State<FaceConstellationScreen> createState() =>
      _FaceConstellationScreenState();
}

enum _Fase { soglia, cattura, risultato, ripiego, momento }

/// **I DUE MOMENTI DELLA FUNZIONE. Ordine CR voce 08.**
///
/// La prima volta si misura la geometria, e per misurarla bisogna girare
/// la testa. I ritorni non la misurano affatto, perche' i tratti sono
/// gia' letti e non cambiano da un giorno all'altro: chiedere di nuovo
/// quattro movimenti sarebbe far pagare a chi torna il prezzo di una
/// misura che nessuno rifara'.
enum ModoDiCattura {
  /// La scansione piena a quattro pose: produce i tratti, e si conserva.
  piena,

  /// La tenuta breve di fronte: produce soltanto la lettura dell'istante.
  ritorno,
}

class _FaceConstellationScreenState extends State<FaceConstellationScreen> {
  late final DateTime Function() _clock = widget.clock ?? DateTime.now;
  late final FaceHistory _storico = FaceHistory(clock: _clock);

  _Fase _fase = _Fase.soglia;

  /// **I COEFFICIENTI DELL'ISTANTE DELLO SCATTO. Ordine CR voce 07.**
  ///
  /// Vivono in memoria per la durata della schermata e non toccano il
  /// disco: sono dati derivati dal volto, e l'ordine chiede che sia
  /// dichiarato dove stanno. Sul ripiego tattile restano vuoti, perche'
  /// senza fotocamera non c'e' nessun istante da leggere.
  Map<FaceBlendshape, double> _espressione = const {};

  /// La propria linea degli istanti, che da' senso al confronto dei
  /// ritorni. Sul disco ci finiscono solo una data e dei nomi di segni.
  late final StoricoDegliIstanti _linea =
      StoricoDegliIstanti(clock: _clock);

  /// Cosa si e' venuti a fare: la prima volta o un ritorno.
  ModoDiCattura _modo = ModoDiCattura.piena;

  /// Cosa la propria linea dice dell'istante appena letto.
  ConfrontoConLaLinea? _confronto;
  bool _conCielo = false;
  bool _pronto = false;

  FaceReading? _reading;

  /// **IL SECONDO VOLTO, e non esce mai da questo telefono. Ordine BX voce
  /// 03.**
  ///
  /// La condizione del corpus e' "confronti la tua Costellazione del Viso con
  /// quella di un'altra persona". Il minimo che quella condizione richiede e'
  /// un'altra persona QUI, che si fa leggere adesso: nessun dato di nessuno
  /// viene mandato, salvato o chiesto a un server, e la lettura del secondo
  /// volto vive quanto vive questa schermata.
  ///
  /// **E' il minimo dell'ordine BX voce 03 preso alla lettera**: se la porta
  /// si puo' costruire senza mostrare l'identita' di nessuno, si costruisce
  /// cosi', e questa si puo'.
  FaceReading? _secondoVolto;

  /// Vero mentre si sta leggendo il volto dell'altra persona.
  bool _leggoLAltro = false;
  FaceConstellation? _costellazione;
  String? _fotoPath;

  @override
  void initState() {
    super.initState();
    _linea.carica();
    _storico.carica().then((_) {
      if (!mounted) return;
      setState(() {
        _pronto = true;
        if (widget.readingIniziale != null) {
          _reading = widget.readingIniziale;
          _costellazione = FaceConstellation.da(FaceSilhouette.contorni());
          _fase = _Fase.risultato;
        } else if (widget.partiDalRipiego) {
          _fase = _Fase.ripiego;
        }
      });
    });
  }

  @override
  void dispose() {
    _storico.dispose();
    super.dispose();
  }

  Tier get _tier => context.read<EntitlementService>().tier;

  bool get _consentito => ArchetypeAllowance.consentito(
        fattiOggi: _storico.fattiOggi,
        tier: _tier,
      );

  Set<Pianeta> get _pianeti {
    final f = widget.pianetiDelGiorno ?? ArchetypeSky.pianetiDelGiorno;
    return f(_clock());
  }

  /// Il secondo volto e' stato letto: si confronta e si dice al cammino che
  /// due volti sono stati messi nello stesso Cerchio.
  Future<void> _concludiIlSecondo(FaceReading reading) async {
    if (!mounted) return;
    setState(() {
      _secondoVolto = reading;
      _leggoLAltro = false;
      _fase = _Fase.risultato;
    });
    // Alla regia va il FATTO, non i due volti: che un confronto e' avvenuto.
    unawaited(RegiaDelCammino.dopoUnGesto(context, 'due_volti'));
  }

  /// **IL RITORNO SI CHIUDE QUI. Ordine CR voce 08.**
  ///
  /// Non nasce nessuna lettura dei tratti, e non si tocca il tetto delle
  /// letture piene: **il tetto esiste per la lettura permanente**, e un
  /// ritorno non ne produce nessuna. La scelta e' dichiarata perche' sia
  /// possibile ribaltarla: e' una decisione, non una conseguenza.
  ///
  /// **IL CONFRONTO SI FA PRIMA DI SEGNARE.** Segnare per primo
  /// metterebbe l'istante di oggi dentro la propria linea, e il confronto
  /// direbbe sempre che tutto e' gia' stato visto.
  Future<void> _concludiIlMomento(
      Map<FaceBlendshape, double> espressione) async {
    if (!mounted) return;
    final segni = EspressioneDellIstante.leggi(espressione);
    final confronto = _linea.confronta(segni);
    setState(() {
      _espressione = espressione;
      _confronto = confronto;
      _fase = _Fase.momento;
    });
    if (segni.isNotEmpty) await _linea.segna(segni);
  }

  Future<void> _concludi(FaceReading reading, FaceConstellation cost,
      {String? fotoPath,
      Map<FaceBlendshape, double> espressione = const {}}) async {
    _espressione = espressione;
    // Quando si sta leggendo l'altra persona il risultato non sostituisce il
    // proprio: si affianca.
    if (_leggoLAltro) {
      await _concludiIlSecondo(reading);
      return;
    }
    // **IL VOLTO CHE CAMBIA, ordine BX voci 10 e 11.** Il corpus chiede "la
    // Costellazione del Viso ti rilegge a distanza di un mese e trova un
    // tratto diverso", e quel gradino dormiva perche' nessuno confrontava due
    // letture. La memoria con la data c'era gia', `FaceHistory` tiene ogni
    // esito col suo istante: mancava soltanto la domanda.
    //
    // **Si guarda la lettura piu' RECENTE fra quelle vecchie di almeno un
    // mese**: se il tratto dominante di allora e' diverso da quello di
    // adesso, il volto e' cambiato davvero, e non e' l'oscillazione di due
    // letture fatte nello stesso pomeriggio.
    // **LA REGOLA STA NELLO STORICO, non qui.** Stava in questa riga, e
    // nessuna prova poteva interrogarla: la guardia del mese restava verde
    // anche togliendo il mese. Adesso risponde `FaceHistory`, che ha le date
    // e si puo' misurare da sola.
    final tratoCambiato = _storico.ilTrattoECambiatoInUnMese(reading);
    await _storico.registra(reading);
    if (!mounted) return;
    setState(() {
      _reading = reading;
      _costellazione = cost;
      _fotoPath = fotoPath;
      _fase = _Fase.risultato;
    });
    // LA COSTELLAZIONE DEL VISO ENTRA NEL CAMMINO, ordine P voce 35.
    unawaited(RegiaDelCammino.dopoUnGesto(context, 'viso', dettagli: {
      'tratto': [reading.dominante.name],
      if (tratoCambiato) 'tratto_cambiato': const ['si'],
    }));
  }

  @override
  Widget build(BuildContext context) {
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.aura));
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: BarraArte(
        // **NIENTE FittedBox.** Rimpiccioliva il titolo senza fondo per
        // tenerlo su una riga, quindi poteva scendere sotto il pavimento
        // tipografico dell'app, e non andava a capo mai. La regola e'
        // un'altra: a capo FRA le parole, e la misura scende solo quanto
        // serve, entro un minimo dichiarato.
        titolo: TitoloCheNonSiRompe(
            testo: 'Costellazione del Viso',
            stile: TypographyTokens.titoloScheda()),
        azioni: [
          IconButton(
            key: const Key('face_sources'),
            icon: const Icon(Icons.info_outline_rounded),
            tooltip: 'Fonti e metodo',
            onPressed: () => _mostraFonti(context, palette),
          ),
        ],
      ),
      body: CosmosBackground(
        seed: 8,
        showZodiac: false,
        child: SafeArea(
          child: !_pronto
              ? const SizedBox.shrink()
              : switch (_fase) {
                  _Fase.soglia => _Soglia(
                      palette: palette,
                      consentito: _consentito,
                      rimanenti: ArchetypeAllowance.rimanenti(
                          fattiOggi: _storico.fattiOggi, tier: _tier),
                      ultimo: _storico.ultimo,
                      conCielo: _conCielo,
                      onCielo: (v) => setState(() => _conCielo = v),
                      onInizia: () => setState(() {
                        _modo = ModoDiCattura.piena;
                        _fase = _Fase.cattura;
                      }),
                      onRitorno: () => setState(() {
                        _modo = ModoDiCattura.ritorno;
                        _fase = _Fase.cattura;
                      }),
                      onRipiego: () => setState(() => _fase = _Fase.ripiego),
                    ),
                  _Fase.cattura => _Cattura(
                      palette: palette,
                      modo: _modo,
                      onFatto: _concludi,
                      onIstante: _concludiIlMomento,
                      onRipiego: () => setState(() => _fase = _Fase.ripiego),
                    ),
                  _Fase.momento => _IlMomento(
                      palette: palette,
                      espressione: _espressione,
                      confronto: _confronto,
                      tratti: _storico.ultimo?.reading,
                      onRileggiITratti: () => setState(() {
                        _modo = ModoDiCattura.piena;
                        _fase = _Fase.cattura;
                      }),
                    ),
                  _Fase.ripiego => _Ripiego(
                      palette: palette,
                      onFatto: (reading) => _concludi(reading,
                          FaceConstellation.da(FaceSilhouette.contorni())),
                    ),
                  _Fase.risultato => Column(
                      children: [
                        Expanded(
                          child: _Risultato(
                            palette: palette,
                            reading: _reading!,
                            costellazione: _costellazione!,
                            fotoPath: _fotoPath,
                            conCielo: _conCielo,
                            pianeti: _pianeti,
                            espressione: _espressione,
                            onCielo: (v) => setState(() => _conCielo = v),
                          ),
                        ),
                        _DueVolti(
                          palette: palette,
                          mio: _reading!,
                          altro: _secondoVolto,
                          onLeggiLAltro: () => setState(() {
                            _leggoLAltro = true;
                            _fase = _Fase.cattura;
                          }),
                          // **IL CONFRONTO SI PUO' CHIUDERE.** Segnalato dal
                          // fondatore l'8 settembre 2026: *"nel responso resta
                          // in primo piano un riquadro due volti nello stesso
                          // cerchio che non posso togliere"*. Il riquadro sta
                          // fuori dall'area che scorre, quindi da quando
                          // compare si mangia un terzo di schermo per sempre e
                          // taglia il responso a meta'. Chiuderlo riporta il
                          // pulsante, cioe' il confronto resta a un tocco.
                          onChiudi: () =>
                              setState(() => _secondoVolto = null),
                        ),
                      ],
                    ),
                },
        ),
      ),
    );
  }

  void _mostraFonti(BuildContext context, MaestroPalette palette) {
    foglioDelCerchio<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheet) => Container(
        key: const Key('face_sources_sheet'),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Fonti e metodo',
                  style: TypographyTokens.titoloScheda()
                      .copyWith(color: palette.goldSoft)),
              const SizedBox(height: SpacingTokens.sm),
              Text(FaceCorpus.fontiEMetodo,
                  style: TypographyTokens.didascalia()
                      .copyWith(color: ColorTokens.textPrimary, height: 1.45)),
              const SizedBox(height: SpacingTokens.lg),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(sheet).pop(),
                  child: Text('Va bene',
                      style: TypographyTokens.etichetta()
                          .copyWith(color: palette.goldSoft)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// La soglia: si entra da qui, si sceglie il cielo di oggi PRIMA di iniziare, e
/// c'e' l'ingresso alternativo al ripiego tattile.
class _Soglia extends StatelessWidget {
  const _Soglia({
    required this.palette,
    required this.consentito,
    required this.rimanenti,
    required this.ultimo,
    required this.conCielo,
    required this.onCielo,
    required this.onInizia,
    required this.onRitorno,
    required this.onRipiego,
  });

  final MaestroPalette palette;
  final bool consentito;
  final int? rimanenti;
  final FaceEsito? ultimo;
  final bool conCielo;
  final ValueChanged<bool> onCielo;
  final VoidCallback onInizia;

  /// Il ritorno: la tenuta breve di fronte, solo l'istante.
  final VoidCallback onRitorno;

  final VoidCallback onRipiego;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(SpacingTokens.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: SpacingTokens.xl),
          Text('I tratti del tuo volto, una costellazione',
              style: TypographyTokens.cerimoniale()
                  .copyWith(color: palette.goldSoft)),
          const SizedBox(height: SpacingTokens.sm),
          Text(
            'La fotocamera legge la geometria del tuo viso e la unisce in una '
            'costellazione. I significati sono la Personologia, la fisiognomica '
            'di Jones e Tickle, con la nostra curatela.',
            style: TypographyTokens.corpo()
                .copyWith(color: ColorTokens.textPrimary, height: 1.5),
          ),
          const SizedBox(height: SpacingTokens.md),
          // La rassicurazione sulla privacy.
          DepthCard(
            padding: const EdgeInsets.all(SpacingTokens.md),
            child: Row(
              children: [
                Icon(Icons.lock_outline_rounded,
                    size: 20, color: palette.goldSoft),
                const SizedBox(width: SpacingTokens.sm),
                Expanded(
                  child: Text(
                    'Tutto resta sul tuo dispositivo: nessuna immagine viene '
                    'inviata, nessuna foto viene salvata oltre l\'uso del momento.',
                    key: const Key('face_privacy'),
                    style: TypographyTokens.didascalia().copyWith(
                        color: ColorTokens.textSecondary, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: SpacingTokens.lg),
          // La scelta del cielo, PRIMA della cattura, come nel Test Archetipo.
          DepthCard(
            padding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.md, vertical: SpacingTokens.xs),
            child: InterruttoreDelCerchio(
              key: const Key('face_sky_setting'),
              acceso: conCielo,
              onCambia: onCielo,
              titolo: 'Lega al cielo di oggi',
              sottotitolo:
                  'I transiti del giorno si accostano alla tua lettura, come '
                  'sincronicità.',
            ),
          ),
          const SizedBox(height: SpacingTokens.lg),
          // **SI AVVERTE PRIMA, NON DOPO. Ordine CX voce 07.**
          //
          // **Parole del fondatore**: *"la lettura dovrebbe avvertire
          // inizialmente di togliere cappelli o occhiali o altri accessori
          // che potrebbero nascondere i tratti"*. Nasce dalla sua prova: ha
          // fatto la scansione col cappellino, fronte e sopracciglia
          // nascoste, e il responso gliele ha descritte lo stesso.
          //
          // **Perche' l'avviso e' necessario e non e' un di piu'.** MediaPipe
          // posa i suoi punti anche dove non vede: e' un modello che DEDUCE
          // la forma del volto, non un misuratore che si rifiuta. Sotto un
          // cappello i punti della fronte ci sono lo stesso, plausibili e
          // falsi, e `FaceMeshLandmark` non porta nessun campo di visibilita'
          // con cui distinguerli. **Cio' che il modello non puo' dire, lo
          // deve sapere chi si inquadra.**
          Container(
            key: const Key('face_avviso_accessori'),
            padding: const EdgeInsets.all(SpacingTokens.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
              color: palette.surfaceElevated.withValues(alpha: 0.6),
              border: Border.all(color: palette.gold.withValues(alpha: 0.35)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.visibility_outlined,
                    size: 20, color: palette.goldSoft),
                const SizedBox(width: SpacingTokens.sm),
                Expanded(
                  child: ParagrafiDiLettura(
                    testo: 'Prima di cominciare togli cappello e occhiali, e '
                        'scosta i capelli dalla fronte. Quello che resta '
                        'coperto non lo posso leggere, e preferisco dirtelo '
                        'adesso invece di indovinarlo dopo.',
                    stile: TypographyTokens.didascalia()
                        .copyWith(color: ColorTokens.textPrimary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: SpacingTokens.lg),
          // **I DUE MOMENTI, E QUALE VIENE PRIMA. Ordine CR voce 08.**
          //
          // Chi non ha mai fatto la lettura piena vede una porta sola,
          // perche' il ritorno senza una prima volta non ha niente a cui
          // tornare. Chi ce l'ha vede prima il RITORNO, che e' il gesto
          // di ogni giorno, e sotto la lettura piena, che si rifa' quando
          // si vuole: mettere per prima quella lunga vorrebbe dire
          // chiedere quattro pose a chi voleva solo guardarsi un momento.
          if (ultimo != null) ...[
            FilledButton.icon(
              key: const Key('face_return_start'),
              style: FilledButton.styleFrom(
                  backgroundColor: palette.primary,
                  foregroundColor: palette.onPrimary),
              onPressed: onRitorno,
              icon: const Icon(Icons.auto_awesome_rounded),
              label: const Text('Leggi il tuo momento'),
            ),
            const SizedBox(height: SpacingTokens.xs),
            Text(
                'I tuoi tratti li ho già: guardo solo cosa sta facendo '
                'il tuo viso adesso. Basta un momento di fronte.',
                key: const Key('face_didascalia_ritorno'),
                style: TypographyTokens.didascalia()
                    .copyWith(color: ColorTokens.textSecondary)),
            const SizedBox(height: SpacingTokens.md),
          ],
          if (consentito) ...[
            FilledButton.icon(
              key: const Key('face_start'),
              style: ultimo != null
                  ? FilledButton.styleFrom(
                      backgroundColor: palette.surfaceElevated,
                      foregroundColor: palette.goldSoft)
                  : FilledButton.styleFrom(
                      backgroundColor: palette.primary,
                      foregroundColor: palette.onPrimary),
              onPressed: onInizia,
              icon: const Icon(Icons.camera_front_rounded),
              label: Text(ultimo != null
                  ? 'Rifai la lettura piena'
                  : 'Inquadra il tuo volto'),
            ),
            // **ANCHE QUESTO PULSANTE HA LA SUA RIGA, e la ragione e' un
            // equivoco vero.** Il fondatore ha letto questa schermata e ha
            // creduto che l'app gli negasse la scansione: *"non mi fa piu'
            // fare la scansione e mi avverte: i tuoi tratti li ho gia'"*.
            //
            // La scansione c'era, e questo pulsante la apre. Ma la riga *"I
            // tuoi tratti li ho gia'"* descrive il pulsante DI SOPRA ed era
            // stampata subito prima di questo: chi legge dall'alto in basso
            // la attacca a cio' che viene dopo, e riceve il messaggio
            // opposto. **Una didascalia sola fra due pulsanti appartiene a
            // tutti e due**, quindi ognuno ha la sua.
            const SizedBox(height: SpacingTokens.xs),
            Text(
                ultimo != null
                    ? 'Quattro pose, e i tuoi tratti si rimisurano da capo.'
                    : 'Quattro pose guidate: destra, sinistra, alto, basso.',
                key: const Key('face_didascalia_piena'),
                style: TypographyTokens.didascalia()
                    .copyWith(color: ColorTokens.textSecondary)),
            const SizedBox(height: SpacingTokens.sm),
            TextButton.icon(
              key: const Key('face_fallback_entry'),
              onPressed: onRipiego,
              icon: Icon(Icons.touch_app_outlined, color: palette.goldSoft),
              label: Text('Non hai la fotocamera? Tocca qui',
                  style: TypographyTokens.corpo()
                      .copyWith(color: palette.goldSoft)),
            ),
            if (rimanenti != null) ...[
              const SizedBox(height: SpacingTokens.xs),
              Text(
                  rimanenti == 1
                      ? 'Ne hai una oggi.'
                      : 'Ne hai $rimanenti oggi.',
                  style: TypographyTokens.etichetta()
                      .copyWith(color: ColorTokens.textSecondary)),
            ],
          ] else
            _Bloccato(palette: palette, ultimo: ultimo, onRipiego: onRipiego),
        ],
      ),
    );
  }
}

/// Limite raggiunto: mai un vicolo cieco, si mostra l'ultima lettura salvata.
class _Bloccato extends StatelessWidget {
  const _Bloccato(
      {required this.palette, required this.ultimo, required this.onRipiego});

  final MaestroPalette palette;
  final FaceEsito? ultimo;
  final VoidCallback onRipiego;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('face_blocked'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.lock_rounded, size: 18, color: palette.goldSoft),
            const SizedBox(width: SpacingTokens.xs),
            Expanded(
              child: Text(
                'Per oggi hai già guardato il tuo volto. Il Cerchio ne apre di più.',
                style: TypographyTokens.didascalia()
                    .copyWith(color: ColorTokens.textPrimary, height: 1.4),
              ),
            ),
          ],
        ),
        if (ultimo != null) ...[
          const SizedBox(height: SpacingTokens.lg),
          Text('La tua ultima lettura',
              style: TypographyTokens.etichetta()
                  .copyWith(color: palette.goldSoft, letterSpacing: 0.6)),
          const SizedBox(height: SpacingTokens.sm),
          DepthCard(
            key: const Key('face_last_saved'),
            padding: const EdgeInsets.all(SpacingTokens.md),
            child: Row(
              children: [
                Icon(Icons.auto_awesome, color: palette.goldSoft, size: 28),
                const SizedBox(width: SpacingTokens.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ultimo!.reading.dominante.titoloEvocativo,
                          style: TypographyTokens.titoloScheda()
                              .copyWith(color: palette.goldSoft)),
                      const SizedBox(height: 2),
                      Text(ultimo!.reading.dominante.nome,
                          style: TypographyTokens.didascalia()
                              .copyWith(color: ColorTokens.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// La cattura dal vivo: anteprima della fotocamera frontale coi contorni, oppure
/// la sagoma neutra quando la fotocamera non c'e' o nega il permesso. Al tocco
/// dello scatto la costellazione si congela e si va al responso.
class _Cattura extends StatefulWidget {
  const _Cattura({
    required this.palette,
    required this.modo,
    required this.onFatto,
    required this.onIstante,
    required this.onRipiego,
  });

  final MaestroPalette palette;
  final void Function(FaceReading, FaceConstellation,
      {String? fotoPath,
      Map<FaceBlendshape, double> espressione}) onFatto;
  final VoidCallback onRipiego;

  /// La prima volta o un ritorno. Ordine CR voce 08.
  final ModoDiCattura modo;

  /// Il ritorno non produce tratti: risale solo l'istante letto.
  final void Function(Map<FaceBlendshape, double>) onIstante;

  @override
  State<_Cattura> createState() => _CatturaState();
}

class _CatturaState extends State<_Cattura>
    with SingleTickerProviderStateMixin {
  /// **IL BATTITO NASCE SUBITO, NON ALLA PRIMA OCCHIATA.**
  /// Ordine CR voce 09, seconda stesura.
  ///
  /// Era `late final`, cioe' costruito la prima volta che qualcuno lo
  /// guardava. Finche' sopra l'anteprima si disegnava una costellazione
  /// animata, qualcuno lo guardava sempre in costruzione. Tolta quella
  /// costellazione, chi apre la cattura e se ne va **senza mai farsi
  /// inquadrare** non lo tocca mai, e allora il primo a toccarlo e'
  /// `dispose`: si finiva a creare un Ticker mentre l'albero delle viste
  /// sta gia' morendo, che Flutter vieta.
  late final AnimationController _battito;

  CameraController? _camera;

  /// **IL MOTORE PASSA DALLA PORTA UNICA.** Ordine CR voce 02: la schermata
  /// non conosce il nome del pacchetto, conosce solo la porta. Il giorno che
  /// il motore si sostituisce, qui non cambia una riga.
  final MotoreDelVolto _motore = MotoreMediaPipe();

  /// La scansione guidata a quattro pose, CR voce 03. Vive qui perche' e'
  /// legata a questa sessione di cattura e muore con lei.
  final ScansioneAPose _scansione = ScansioneAPose();

  /// La tenuta breve del ritorno, ordine CR voce 08. Vive accanto alla
  /// scansione piena e non al posto suo: quale delle due comanda lo dice
  /// il modo, e cosi' nessuna delle due puo' essere scavalcata.
  final TenutaDiFronte _tenuta = TenutaDiFronte();

  bool get _ritorno => widget.modo == ModoDiCattura.ritorno;

  /// Vero quando cio' che questo momento chiede e' stato fatto.
  bool get _pronta => _ritorno ? _tenuta.compiuta : _scansione.compiuta;

  /// Quanto manca, per il fascio.
  double get _progresso =>
      _ritorno ? _tenuta.progresso : _scansione.progresso;

  /// Falso finche' non c'e' niente da misurare.
  bool get _agganciato =>
      _ritorno ? _lettura != null : _scansione.agganciato;

  /// L'ultima lettura vera del motore, o nulla se nessun volto e' in scena.
  LetturaDelVolto? _lettura;

  /// **QUANDO L'ULTIMA LETTURA E' ARRIVATA.** Ordine CR voce 01, seconda
  /// stesura: il cancello guardava l'ultima lettura senza chiedersi di
  /// quando fosse, e una lettura vecchia non e' una lettura.
  DateTime? _letturaQuando;

  /// Larghezza diviso altezza del fotogramma che il motore ha appena
  /// letto. Serve alla maschera per rifare lo STESSO ritaglio
  /// dell'anteprima: senza, i punti scivolano via dal viso proprio
  /// mentre la testa gira, che e' il momento in cui devono convincere.
  double? _proporzioneFotogramma;

  /// Quando e' arrivato il fotogramma precedente: serve a dire alla
  /// scansione quanto tempo e' passato davvero, invece di contare i
  /// fotogrammi come se durassero tutti uguale.
  DateTime? _fotogrammaPrecedente;

  FaceContours? get _contorniVivi => _lettura?.contorni;

  /// Cosa dire quando la scansione non trova nessun volto. Nullo vuol
  /// dire che non c'e' niente da dire, non che va tutto bene.
  String? _rifiuto;
  bool _occupato = false;

  @override
  void initState() {
    super.initState();
    _battito = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _prepara();
  }

  Future<void> _prepara() async {
    try {
      final camere = await availableCameras();
      final frontale = camere.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => camere.first,
      );
      final controller = CameraController(
        frontale,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.nv21,
      );
      await controller.initialize();
      await _motore.avvia();
      await controller.startImageStream(_analizza);
      if (!mounted) return;
      setState(() => _camera = controller);
    } catch (_) {
      // Nessuna fotocamera o permesso negato: resta la sagoma neutra, mai un
      // vicolo cieco. La build mostra gia' la sagoma quando la fotocamera e'
      // assente, quindi non serve altro stato.
    }
  }

  Future<void> _analizza(CameraImage image) async {
    if (_occupato || _camera == null) return;
    _occupato = true;
    try {
      final piano = image.planes.isEmpty ? null : image.planes.first;
      if (piano == null) return;
      final lettura = await _motore.leggi(
        byte: piano.bytes,
        larghezza: image.width,
        altezza: image.height,
        // **I BYTE DI RIGA VENGONO DALLA FOTOCAMERA**, non dalla larghezza:
        // molti telefoni allineano le righe a un multiplo, e dedurli
        // porterebbe a leggere un'immagine storta in cui nessun volto si
        // trova. Ordine CR voce 02.
        byteDiRiga: piano.bytesPerRow,
        rotazione: _camera!.description.sensorOrientation,
        specchiata: _camera!.description.lensDirection ==
            CameraLensDirection.front,
      );
      if (!mounted) return;
      final adesso = DateTime.now();
      final trascorso = _fotogrammaPrecedente == null
          ? Duration.zero
          : adesso.difference(_fotogrammaPrecedente!);
      _fotogrammaPrecedente = adesso;
      // **LA PROPORZIONE VIENE DAL FOTOGRAMMA VERO.** Ordine CR voce 09:
      // la maschera deve rifare lo stesso ritaglio dell'anteprima, e la
      // forma del fotogramma la sa solo chi lo ha appena letto. La
      // rotazione del sensore scambia i lati, e su un telefono in piedi
      // sono scambiati quasi sempre.
      final giroDispari =
          (_camera!.description.sensorOrientation ~/ 90).isOdd;
      final largo = giroDispari ? image.height : image.width;
      final alto = giroDispari ? image.width : image.height;
      setState(() {
        _proporzioneFotogramma = alto == 0 ? null : largo / alto;
        _lettura = lettura;
        _letturaQuando = lettura == null ? null : adesso;
        if (lettura != null) {
          _rifiuto = null;
          // **LA SCANSIONE AVANZA SOLO CON UN VOLTO IN SCENA.** Senza
          // volto non si passa nemmeno il tempo: una posa non puo'
          // maturare mentre la persona e' fuori campo.
          // **UNA SOLA DELLE DUE MACCHINE RICEVE IL FOTOGRAMMA.** Ordine
          // CR voce 08: alimentarle tutte e due vorrebbe dire che una
          // scansione piena maturerebbe anche in un ritorno, e il
          // comando dello scatto guarderebbe una macchina compiuta da
          // un movimento che nessuno ha chiesto.
          if (_ritorno) {
            _tenuta.passo(
              yaw: lettura.yaw,
              pitch: lettura.pitch,
              trascorso: trascorso,
            );
          } else {
            _scansione.passo(
              yaw: lettura.yaw,
              pitch: lettura.pitch,
              trascorso: trascorso,
            );
          }
        }
      });
    } catch (_) {
      // Un frame illeggibile non ferma il flusso.
    } finally {
      _occupato = false;
    }
  }
  Future<void> _scatta() async {
    // **IL CANCELLO. Ordine CR voce 01, 6 settembre 2026.**
    //
    // Qui c'era `_contorniVivi ?? FaceSilhouette.contorni()`, e quel `??`
    // e' tutto il difetto: davanti a un muro il rilevatore non trova mai
    // un volto, `_contorniVivi` resta nullo, e al suo posto entrava **la
    // sagoma disegnata a mano** nata per il ripiego tattile. Da li' la
    // lettura proseguiva identica a quella di un volto vero.
    //
    // Parole del fondatore: *ho provato a fare una foto a un muro e cmq
    // la funzionalita' mi ha dato un responso come se avessi fotografato
    // un viso*.
    // **E LA SCANSIONE DEVE ESSERE COMPIUTA.** Ordine CR voci 03 e 04: le
    // quattro pose non sono una messa in scena, sono la prova che davanti
    // alla fotocamera c'e' una persona viva. Una fotografia stampata non
    // gira la testa.
    // **IL RITORNO ESCE DI QUI PRIMA. Ordine CR voce 08.**
    //
    // Chiede la sua tenuta di fronte, e non produce NESSUNA lettura dei
    // tratti: non passa dal classificatore, non tocca la memoria delle
    // letture piene, non salva nessuna fotografia. Legge l'istante e se
    // ne va.
    if (_ritorno) {
      if (!_tenuta.compiuta) {
        if (mounted) {
          setState(() => _rifiuto =
              'Resta di fronte ancora un momento, senza girare la testa.');
        }
        return;
      }
      // **ANCHE IL RITORNO PASSA DAL CANCELLO.** Ordine CR voce 01,
      // seconda stesura: se il ritorno si accontentasse di una lettura
      // qualunque, sarebbe la porta di servizio del muro.
      final quandoBreve = _letturaQuando;
      final esitoBreve = CancelloDellaScansione.giudica(
        contorniVivi: _contorniVivi,
        eta: quandoBreve == null
            ? null
            : DateTime.now().difference(quandoBreve),
      );
      if (esitoBreve is NessunVolto) {
        if (mounted) setState(() => _rifiuto = esitoBreve.perche);
        return;
      }
      final viva = _lettura!;
      widget.onIstante(viva.espressione);
      return;
    }
    if (!_scansione.compiuta) {
      if (mounted) {
        setState(() => _rifiuto =
            'Completa la scansione: mancano ancora ${ScansioneAPose.ordine.length - _scansione.compiute} pose.');
      }
      return;
    }
    final quando = _letturaQuando;
    final esito = CancelloDellaScansione.giudica(
      contorniVivi: _contorniVivi,
      eta: quando == null ? null : DateTime.now().difference(quando),
    );
    if (esito is NessunVolto) {
      if (mounted) setState(() => _rifiuto = esito.perche);
      return;
    }
    final contorni = (esito as VoltoTrovato).contorni;
    final reading = FaceClassifier.leggi(contorni);
    final cost = FaceConstellation.da(contorni);
    // **I RAPPORTI MISURATI SI STAMPANO, ed e' il ponte per tarare le
    // soglie.** Ordine CX, 8 settembre 2026.
    //
    // Le undici soglie del classificatore non le ha misurate nessuno su un
    // volto vero, e su volti sintetici dalle proporzioni normali tre
    // categorie rispondono la stessa cosa a chiunque. **Tararle contro un
    // modello sintetico sarebbe tarare una misura su se stessa**: servono i
    // numeri di volti veri, e questa riga li mette dove si possono leggere.
    //
    // **Non esce niente dal dispositivo**: e' una riga nel registro locale,
    // che si legge col cavo. Non contiene immagini ne' identita', solo
    // rapporti fra lunghezze.
    _stampaIRapporti(reading);
    // **LA FOTOGRAFIA SI GIUDICA, NON SI CONSERVA E BASTA.** Ordine CX voci
    // 02 e 04.
    //
    // Il cancello ha certificato i CONTORNI VIVI. La fotografia si scatta
    // adesso, cioe' in un istante successivo, da una fotocamera che nel
    // frattempo puo' essersi spostata: **il responso era suo, la foto era un
    // muro**, e questa e' la finestra da cui e' passato. Nessuna guardia
    // l'aveva mai vista perche' tutte guardavano i contorni, che erano il
    // pezzo sano accanto al pezzo rotto.
    String? foto;
    var fotoSenzaVolto = false;
    try {
      if (_camera != null) {
        await _camera!.stopImageStream();
        final x = await _camera!.takePicture();
        foto = await _laFotoTieneUnVolto(x.path) ? x.path : null;
        fotoSenzaVolto = foto == null;
      }
    } catch (_) {
      foto = null;
    }
    if (fotoSenzaVolto) {
      // **NIENTE RESPONSO E NIENTE RICORDO**, parole del fondatore: *"che
      // dovrebbe essere vietato"*. Si dice cosa e' successo e si resta dove
      // si e', perche' rifare la posa costa pochi secondi e un ricordo col
      // muro dentro resta per sempre.
      if (mounted) {
        setState(() => _rifiuto =
            'Nello scatto non c\'era piu\' un volto: tieni il viso davanti '
            'alla fotocamera anche nell\'istante dello scatto.');
      }
      return;
    }
    // **L'ESPRESSIONE DELL'ISTANTE SALE COL RESPONSO. Ordine CR voce
    // 07.** Si prendono i coefficienti dell'ultima lettura viva, cioe'
    // quelli del momento in cui la persona ha scattato: leggerli dopo
    // vorrebbe dire leggere un altro istante.
    widget.onFatto(reading, cost,
        fotoPath: foto,
        espressione: _lettura?.espressione ?? const {});
  }

  /// **I RAPPORTI MISURATI, UNO PER CATEGORIA, nel registro del telefono.**
  /// Ordine CX, 8 settembre 2026.
  ///
  /// Una riga sola, riconoscibile, da leggere col cavo mentre qualcuno si
  /// scansiona davvero. Serve a raccogliere i numeri con cui centrare le
  /// undici soglie del classificatore, che oggi sono scelte a tavolino.
  void _stampaIRapporti(FaceReading lettura) {
    final pezzi = <String>[
      for (final l in lettura.letture)
        '${l.tratto.categoria.name}='
            '${l.rapporto?.toStringAsFixed(4) ?? "nullo"}'
            '(${l.tratto.nome})',
    ];
    debugPrint('RAPPORTI DEL VISO: ${pezzi.join(" ")}');
  }

  /// **DENTRO LA FOTOGRAFIA C'E' UN VOLTO?** Ordine CX voci 02 e 04.
  ///
  /// Decodifica lo scatto e lo passa al rilevatore, che e' lo stesso che
  /// giudica i fotogrammi vivi e con la stessa soglia. **Si decodifica a
  /// larghezza ridotta**: uno scatto pieno da dodici megapixel diventerebbe
  /// quasi cinquanta megabyte di RGBA in memoria per una domanda che a
  /// seicentoquaranta punti ha la stessa risposta.
  ///
  /// **Falso quando qualcosa non torna**, mai vero per comodita': un ripiego
  /// ottimista qui riaprirebbe la porta del muro, che e' la sola ragione per
  /// cui questa funzione esiste.
  Future<bool> _laFotoTieneUnVolto(String percorso) async {
    try {
      final byte = await File(percorso).readAsBytes();
      final codec = await ui.instantiateImageCodec(byte, targetWidth: 640);
      final fotogramma = await codec.getNextFrame();
      final immagine = fotogramma.image;
      final dati =
          await immagine.toByteData(format: ui.ImageByteFormat.rawRgba);
      final larghezza = immagine.width;
      final altezza = immagine.height;
      immagine.dispose();
      codec.dispose();
      if (dati == null) return false;
      return _motore.laFotoHaUnVolto(
        rgba: dati.buffer.asUint8List(),
        larghezza: larghezza,
        altezza: altezza,
      );
    } catch (_) {
      return false;
    }
  }

  @override
  void dispose() {
    _battito.dispose();
    _camera?.dispose();
    _motore.spegni();
    super.dispose();
  }

  /// Cosa chiedere adesso, in una frase sola.
  ///
  /// **Una posa alla volta e nell'ordine**: l'ordine CR voce 03 dice che non
  /// si passa alla successiva prima che la corrente sia compiuta, e la riga
  /// a video deve dire la stessa cosa che la macchina sta aspettando, o la
  /// persona insegue una richiesta che non e' quella vera.
  String _cosaChiedere() {
    if (_lettura == null) return 'Centra il viso nel cerchio, sguardo dritto.';
    // **IL RITORNO CHIEDE UNA COSA SOLA.** Ordine CR voce 08: qui non si
    // gira la testa, si resta fermi. Una riga che chiedesse una posa in un
    // ritorno manderebbe la persona a inseguire un movimento che nessuna
    // macchina sta misurando.
    if (_ritorno) {
      return _tenuta.compiuta
          ? 'Ci siamo. Quando vuoi, leggi il tuo momento.'
          : 'Resta di fronte, senza muoverti.';
    }
    if (!_scansione.agganciato) return 'Guarda dritto verso lo schermo.';
    final posa = _scansione.posaCorrente;
    if (posa == null) return 'Scansione completa. Quando sei pronto, cattura.';
    return posa.richiesta;
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    // **LA SAGOMA E' UNA GUIDA, NON UN RILEVAMENTO.** Ordine CR voce 01.
    //
    // Anche qui c'era lo stesso `??`, e faceva una cosa diversa ma della
    // stessa famiglia: disegnava la costellazione **sopra il muro**, coi
    // punti della sagoma inventata, e chi guardava vedeva la macchina
    // che sembrava misurare qualcosa.
    //
    // Adesso i due casi si vedono e non si somigliano: col volto
    // rilevato la maschera dei punti misurati e' accesa sul viso; senza,
    // sopra l'anteprima non c'e' NIENTE, e il comando dello scatto e'
    // spento.
    //
    // **QUI SPARIVA IL RESTO DELLA BUGIA. Ordine CR voce 09.** Fino a
    // poco fa questa riga costruiva una costellazione dai contorni, con
    // la sagoma disegnata a mano come ripiego, e la disegnava sopra
    // l'anteprima: davanti a un muro si vedeva una figura accesa sopra il
    // nulla. Era il gemello grafico del `??` che il cancello ha tolto dal
    // responso, ed e' giusto che se ne vada insieme a lui.
    return Padding(
      padding: const EdgeInsets.all(SpacingTokens.lg),
      child: Column(
        children: [
          const SizedBox(height: SpacingTokens.sm),
          // **LA RIGA DICE LA VERITA' DEL MOMENTO**: se un volto c'e' lo
          // dice, e se non c'e' dice quello e perche'. Prima diceva sempre
          // la stessa cosa, e sopra un muro sembrava che andasse tutto
          // bene.
          // **LA RIGA GUIDA LA SCANSIONE, ordine CR voce 03.** Non dice
          // sempre la stessa cosa: dice cosa manca adesso, una posa alla
          // volta, perche' chiedere quattro movimenti insieme vuol dire non
          // farne compiere nessuno.
          Text(
              _rifiuto ?? _cosaChiedere(),
              key: const Key('face_guide'),
              textAlign: TextAlign.center,
              style: TypographyTokens.didascalia()
                  .copyWith(color: ColorTokens.textPrimary)),
          const SizedBox(height: SpacingTokens.md),
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 3 / 4,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(SpacingTokens.radiusXl),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (_camera != null && _camera!.value.isInitialized)
                        FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: _camera!.value.previewSize?.height ?? 300,
                            height: _camera!.value.previewSize?.width ?? 400,
                            child: CameraPreview(_camera!),
                          ),
                        )
                      else
                        _FondoSagoma(palette: palette),
                      // **LA MASCHERA CHE SEGUE, ordine CR voce 09.**
                      //
                      // Qui prima stava una `FaceConstellationPainter`
                      // costruita dai CONTORNI, cioe' una figura che
                      // esisteva anche senza volto: davanti a un muro si
                      // vedeva una costellazione accesa sopra il nulla, e
                      // quella era la stessa bugia del responso, disegnata.
                      //
                      // Adesso si disegnano i punti che il motore ha
                      // misurato in QUESTO fotogramma: se il volto esce,
                      // spariscono. Non c'e' modo di farla sembrare viva
                      // davanti a una parete.
                      if (_lettura != null)
                        CustomPaint(
                          key: const Key('face_maschera'),
                          painter: MascheraCheSegue(
                            punti: _lettura!.punti,
                            colore: palette.gold,
                            quota: _scansione.compiuta
                                ? 1.0
                                : _progresso,
                            scorre: !ScrollReveal.motionOff(context),
                            proporzioneFotogramma: _proporzioneFotogramma,
                          ),
                        ),
                      // **IL FASCIO CHE MISURA, ordine CR voce 09.** Non e'
                      // un'animazione decorativa: scorre solo mentre una
                      // posa e' in corso, e la sua altezza segue il tempo di
                      // tenuta. Chi guarda vede che la macchina sta
                      // misurando davvero, perche' il fascio si ferma quando
                      // la posa si perde.
                      if (_lettura != null && !_pronta)
                        AnimatedBuilder(
                          animation: _battito,
                          builder: (context, _) => CustomPaint(
                            key: const Key('face_fascio'),
                            painter: FascioDiScansione(
                              quota: _progresso,
                              colore: palette.gold,
                              acceso: _agganciato,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: SpacingTokens.sm),
          // **LE QUATTRO POSE SI VEDONO TUTTE**, e si vede quante ne mancano.
          // Una scansione che chiede un movimento alla volta senza dire
          // quanti ne restano sembra non finire mai.
          // **LA STRISCIA DELLE POSE NON COMPARE NEL RITORNO.** Ordine CR
          // voce 08: mostrare quattro caselle a chi non deve fare quattro
          // pose e' promettere un lavoro che nessuno gli chiedera'.
          if (!_ritorno)
            Row(
              key: const Key('face_pose_strip'),
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < ScansioneAPose.ordine.length; i++) ...[
                if (i > 0) const SizedBox(width: SpacingTokens.xs),
                Container(
                  width: 34,
                  height: 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: i < _scansione.compiute
                        ? palette.gold
                        : palette.gold.withValues(alpha: 0.22),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: SpacingTokens.md),
          FilledButton.icon(
            key: const Key('face_shutter'),
            style: FilledButton.styleFrom(
                backgroundColor: palette.primary,
                foregroundColor: palette.onPrimary),
            // **SPENTO FINCHE' UN VOLTO NON C'E'.** Il comando resta in
            // campo, spento: sparire sarebbe un vicolo cieco, e chi
            // guarda deve vedere cosa potra' fare appena si inquadra.
            // **SI ACCENDE A SCANSIONE COMPIUTA**, non appena si vede un
            // volto: premere prima produrrebbe un rifiuto, e un comando che
            // si puo' premere solo per essere respinti e' un comando che
            // mente.
            onPressed: _pronta ? _scatta : null,
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Cattura la costellazione'),
          ),
          const SizedBox(height: SpacingTokens.xs),
          TextButton(
            onPressed: widget.onRipiego,
            child: Text('Preferisci scegliere a mano? Tocca qui',
                style: TypographyTokens.etichetta()
                    .copyWith(color: palette.goldSoft)),
          ),
        ],
      ),
    );
  }

}

/// Il fondo con la sagoma neutra del volto, quando non c'e' la fotocamera.
class _FondoSagoma extends StatelessWidget {
  const _FondoSagoma({required this.palette});

  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            palette.surfaceElevated.withValues(alpha: 0.6),
            palette.deepest.withValues(alpha: 0.9),
          ],
        ),
      ),
      child: CustomPaint(painter: FaceSilhouettePainter(palette: palette)),
    );
  }
}

/// Il responso, stesso impianto del Test Archetipo.
class _Risultato extends StatefulWidget {
  const _Risultato({
    required this.palette,
    required this.reading,
    required this.costellazione,
    required this.fotoPath,
    required this.conCielo,
    required this.pianeti,
    required this.onCielo,
    this.espressione = const {},
  });

  final MaestroPalette palette;
  final FaceReading reading;
  final FaceConstellation costellazione;
  final String? fotoPath;
  final bool conCielo;
  final Set<Pianeta> pianeti;
  final ValueChanged<bool> onCielo;

  /// I coefficienti dell'istante dello scatto, vuoti sul ripiego.
  final Map<FaceBlendshape, double> espressione;

  @override
  State<_Risultato> createState() => _RisultatoState();
}

class _RisultatoState extends State<_Risultato>
    with SingleTickerProviderStateMixin {
  late final AnimationController _battito = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  );

  final GlobalKey _cardBoundary = GlobalKey();
  bool _renderCard = false;

  /// **L'ELEMENTO DOMINANTE, dalla forma misurata del volto.**
  /// Ordine CR voci 06 e 09. Nullo quando la forma non e' fra quelle che
  /// sappiamo tradurre: il Metallo non ha una forma sua nel nostro
  /// impianto e non gliene inventiamo una.
  ElementoDelVolto? get _elemento => MianXiang.elementoDa(
      widget.reading.letturaDi(FaceCategory.formaVolto).tratto);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Il respiro delle stelle, spento con Riduci Movimento o Quality Tier basso.
    if (ScrollReveal.motionOff(context)) {
      _battito.value = 1.0;
    } else if (!_battito.isAnimating) {
      _battito.repeat();
    }
  }

  @override
  void dispose() {
    _battito.dispose();
    super.dispose();
  }

  /// **TORNA L\'ESITO invece di ingoiarlo, ordine CG voce 06.** Il vero
  /// che esce di qui e\' quello su cui scatta la custodia automatica:
  /// prima restava dentro questo metodo e nessuno poteva sapere, da
  /// fuori, se la condivisione fosse avvenuta o se il foglio fosse
  /// stato solo aperto.
  Future<bool> _condividi() async {
    setState(() => _renderCard = true);
    try {
      await WidgetsBinding.instance.endOfFrame;
      await Future<void>.delayed(const Duration(milliseconds: 80));
      final andata = await shareFaceCard(
          boundaryKey: _cardBoundary, dominante: widget.reading.dominante);
      if (andata && mounted) {
        // Ordine BG voce 04: il premio dichiarato sul pulsante si paga qui,
        // a condivisione davvero avvenuta.
        await PremioDellaCondivisione.premia(context,
            cosa: 'Hai condiviso la tua Costellazione del Viso');
      }
      return andata;
    } finally {
      if (mounted) setState(() => _renderCard = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    final reading = widget.reading;
    final dom = reading.dominante;
    final riga =
        widget.conCielo ? FaceTransits.riga(dom, widget.pianeti) : null;

    return Stack(
      children: [
        SingleChildScrollView(
          key: const Key('face_result'),
          padding: const EdgeInsets.all(SpacingTokens.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Text(
                  widget.conCielo
                      ? 'legato ai transiti astrologici di oggi'
                      : 'non legato ai transiti astrologici',
                  key: const Key('face_mode_subtitle'),
                  textAlign: TextAlign.center,
                  style: TypographyTokens.etichetta()
                      .copyWith(color: palette.goldSoft, letterSpacing: 1.0),
                ),
              ),
              const SizedBox(height: SpacingTokens.md),
              // IL VOLTO con la costellazione sovrapposta, protagonista.
              ScrollReveal(
                child: Center(
                  child: _VoltoCostellazione(
                    palette: palette,
                    costellazione: widget.costellazione,
                    fotoPath: widget.fotoPath,
                    battito: _battito,
                    lato: 300,
                    elemento: _elemento == null
                        ? null
                        : ColoreDellElemento.di(_elemento!),
                  ),
                ),
              ),
              const SizedBox(height: SpacingTokens.md),
              // IL TITOLO evocativo del tratto dominante, poi il nome del tratto.
              Center(
                child: Text(dom.titoloEvocativo,
                    key: const Key('face_title'),
                    textAlign: TextAlign.center,
                    style: TypographyTokens.cerimoniale()
                        .copyWith(color: palette.goldSoft)),
              ),
              Center(
                child: Text(dom.nome,
                    key: const Key('face_dominant_name'),
                    textAlign: TextAlign.center,
                    style: TypographyTokens.corpo().copyWith(
                        color: ColorTokens.textSecondary,
                        fontStyle: FontStyle.italic)),
              ),
              const SizedBox(height: SpacingTokens.lg),
              // LA SINTESI calda, intrecciata dai tratti piu' marcati.
              ScrollReveal(
                depth: 1,
                child: DepthCard(
                  key: const Key('face_synthesis'),
                  raised: true,
                  padding: const EdgeInsets.all(SpacingTokens.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('La tua sintesi',
                          style: TypographyTokens.etichetta().copyWith(
                              color: palette.goldSoft, letterSpacing: 0.6)),
                      const SizedBox(height: SpacingTokens.xs),
                      // La sintesi del volto e' il responso della funzione:
                      // ruolo lettura e regola comune dei paragrafi.
                      ParagrafiDiLettura(
                          testo: FaceCorpus.sintesi(reading.marcati),
                          stile: TypographyTokens.lettura()
                              .copyWith(color: ColorTokens.textPrimary)),
                    ],
                  ),
                ),
              ),

              // **L'ELEMENTO SI LEGGE, non si deduce dal colore.**
              // Ordine CR voce 09: il colore vince sulla scena, e la voce
              // 06 vuole la tradizione dichiarata. Chi non distingue i
              // colori deve ricevere la stessa lettura di tutti gli altri,
              // quindi il nome e la ragione stanno scritti.
              if (_elemento case final e?) ...[
                const SizedBox(height: SpacingTokens.lg),
                Container(
                  key: const Key('face_elemento'),
                  padding: const EdgeInsets.all(SpacingTokens.md),
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(SpacingTokens.radiusMd),
                    border: Border.all(
                        color: ColoreDellElemento.di(e)
                            .withValues(alpha: 0.65)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: ColoreDellElemento.di(e),
                          ),
                        ),
                        const SizedBox(width: SpacingTokens.sm),
                        Text('Elemento ${e.nome}',
                            style: TypographyTokens.etichetta().copyWith(
                                color: palette.goldSoft,
                                letterSpacing: 0.6)),
                      ]),
                      const SizedBox(height: SpacingTokens.xs),
                      // Da cosa si riconosce: chi legge deve poter
                      // verificare da se' che la forma corrisponde.
                      Text(e.comeSiRiconosce,
                          style: TypographyTokens.didascalia().copyWith(
                              color: ColorTokens.textSecondary)),
                      const SizedBox(height: SpacingTokens.xs),
                      Text(e.lettura,
                          style: TypographyTokens.corpo().copyWith(
                              color: ColorTokens.textPrimary, height: 1.5)),
                      const SizedBox(height: SpacingTokens.xs),
                      Text(
                          'Mian Xiang, la fisiognomica cinese. La forma del '
                          'volto è una misura, la lettura è simbolica.',
                          style: TypographyTokens.didascalia().copyWith(
                              color: ColorTokens.textSecondary)),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: SpacingTokens.lg),
              // L'ELENCO dei tratti letti, ognuno con la sua stella e la frase.
              Text('I tratti del tuo volto',
                  style: TypographyTokens.etichetta()
                      .copyWith(color: palette.goldSoft, letterSpacing: 0.6)),
              const SizedBox(height: SpacingTokens.sm),
              for (final t in reading.marcati)
                _RigaTratto(tratto: t, palette: palette),

              // **L'ESPRESSIONE STA DOPO I TRATTI E IN UN RIQUADRO SUO.**
              // Ordine CR voce 07: le due letture non si mescolano mai in
              // una frase sola. Sul ripiego tattile i coefficienti sono
              // vuoti e il riquadro non compare affatto.
              LoSpecchioDellIstante(
                  coefficienti: widget.espressione, palette: palette),

              const SizedBox(height: SpacingTokens.lg),
              // L'interruttore vivo dei transiti.
              _Transiti(
                palette: palette,
                acceso: widget.conCielo,
                onCambia: widget.onCielo,
                riga: riga,
              ),

              const SizedBox(height: SpacingTokens.lg),
              // **LE TRE AZIONI DA UNA PORTA SOLA, ordine CG voci 06
              // e 08.** Prima qui c\'erano due pulsanti scritti a mano e
              // nessun Custodisci: adesso Condividi, Custodisci e
              // Parlane vivono in un punto solo, e una guardia enumera
              // le arti e chiede a ognuna se lo monta.
              AzioniDelResponso(
                palette: palette,
                maestro: Maestro.aura,
                responso: ResponsoDaCustodire(
                  arte: 'viso',
                  titolo: 'La tua Costellazione del Viso',
                  testo: FaceCorpus.sintesi(widget.reading.marcati),
                  dati: {'tratto': dom.nome, 'categoria': dom.categoria.name},
                ),
                condividi: _condividi,
                aperturaDellaChat:
                    ChatOpeners.viso(dom.categoria.name, dom.nome),
              ),
              const SizedBox(height: SpacingTokens.xxxl),
            ],
          ),
        ),
        if (_renderCard)
          Positioned(
            left: -3000,
            top: 0,
            child: RepaintBoundary(
              key: _cardBoundary,
              child: FaceShareCard(
                reading: widget.reading,
                costellazione: widget.costellazione,
                fotoPath: widget.fotoPath,
              ),
            ),
          ),
      ],
    );
  }
}


/// **IL RESPONSO DEL RITORNO. Ordine CR voce 08.**
///
/// Qui non compaiono i tratti, e non e' una dimenticanza: il ritorno legge
/// **soltanto l'istante**, e mostrarli accanto rifarebbe la confusione che
/// la voce 07 vieta, cioe' il permanente e il passeggero nella stessa
/// schermata come se avessero lo stesso peso. I tratti restano a un tocco
/// di distanza, dichiarati come conservati.
class _IlMomento extends StatelessWidget {
  const _IlMomento({
    required this.palette,
    required this.espressione,
    required this.confronto,
    required this.tratti,
    required this.onRileggiITratti,
  });

  final MaestroPalette palette;
  final Map<FaceBlendshape, double> espressione;
  final ConfrontoConLaLinea? confronto;
  final FaceReading? tratti;
  final VoidCallback onRileggiITratti;

  @override
  Widget build(BuildContext context) {
    final segni = EspressioneDellIstante.leggi(espressione);
    final c = confronto;
    return SingleChildScrollView(
      key: const Key('face_momento'),
      padding: const EdgeInsets.all(SpacingTokens.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: SpacingTokens.lg),
          Text('Il tuo momento',
              style: TypographyTokens.cerimoniale()
                  .copyWith(color: palette.goldSoft)),
          const SizedBox(height: SpacingTokens.sm),
          if (segni.isEmpty)
            // **IL NULLA E' UNA RISPOSTA ONESTA**, la stessa del cancello:
            // un viso a riposo non ha niente da dire, e inventarglielo
            // sarebbe la bugia del muro spostata di una schermata.
            Text(
                'Il tuo viso adesso è a riposo: nessun gesto abbastanza '
                'netto da leggere. Riprova fra un momento.',
                key: const Key('face_momento_vuoto'),
                style: TypographyTokens.corpo()
                    .copyWith(color: ColorTokens.textPrimary, height: 1.5))
          else
            LoSpecchioDellIstante(
                coefficienti: espressione, palette: palette),
          if (c != null && segni.isNotEmpty) ...[
            const SizedBox(height: SpacingTokens.lg),
            Container(
              key: const Key('face_confronto_linea'),
              padding: const EdgeInsets.all(SpacingTokens.md),
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(SpacingTokens.radiusMd),
                border:
                    Border.all(color: palette.gold.withValues(alpha: 0.45)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Le tue ultime letture',
                      style: TypographyTokens.etichetta().copyWith(
                          color: palette.goldSoft, letterSpacing: 0.6)),
                  const SizedBox(height: SpacingTokens.xs),
                  // **SI DICE SU QUANTO SI REGGE IL CONFRONTO.** Un
                  // paragone su una lettura sola non e' una linea, e chi
                  // legge ha diritto di sapere quanto pesa.
                  Text(
                      c.quanteLetture == 1
                          ? 'Ti ho letto una volta sola finora, quindi '
                              'questo paragone vale poco: diventerà vero '
                              'con qualche ritorno.'
                          : 'Ti ho letto ${c.quanteLetture} volte finora.',
                      style: TypographyTokens.didascalia()
                          .copyWith(color: ColorTokens.textSecondary)),
                  const SizedBox(height: SpacingTokens.sm),
                  for (final n in c.nuovi)
                    Text('Nuovo per te: ${n.osservazione.toLowerCase()}.',
                        style: TypographyTokens.corpo()
                            .copyWith(color: palette.goldSoft)),
                  for (final r in c.ricorrenti)
                    Text('Torna: ${r.osservazione.toLowerCase()}.',
                        style: TypographyTokens.corpo()
                            .copyWith(color: ColorTokens.textPrimary)),
                ],
              ),
            ),
          ],
          const SizedBox(height: SpacingTokens.lg),
          if (tratti != null)
            Text(
                'I tuoi tratti restano quelli che ho già letto: '
                '${tratti!.dominante.titoloEvocativo}.',
                key: const Key('face_tratti_conservati'),
                style: TypographyTokens.corpo()
                    .copyWith(color: ColorTokens.textSecondary)),
          const SizedBox(height: SpacingTokens.sm),
          OutlinedButton.icon(
            key: const Key('face_rileggi_tratti'),
            onPressed: onRileggiITratti,
            style: OutlinedButton.styleFrom(
                foregroundColor: palette.goldSoft,
                side: BorderSide(color: palette.gold.withValues(alpha: 0.6)),
                minimumSize: const Size.fromHeight(48)),
            icon: const Icon(Icons.camera_front_rounded, size: 18),
            label: Text('Rifai la lettura piena',
                style: TypographyTokens.etichetta()),
          ),
          const SizedBox(height: SpacingTokens.xxxl),
        ],
      ),
    );
  }
}

/// Il volto con la costellazione sovrapposta: la foto quando c'e', altrimenti la
/// sagoma neutra. La costellazione respira.
class _VoltoCostellazione extends StatelessWidget {
  const _VoltoCostellazione({
    required this.palette,
    required this.costellazione,
    required this.fotoPath,
    required this.battito,
    required this.lato,
    this.elemento,
  });

  final MaestroPalette palette;
  final FaceConstellation costellazione;
  final String? fotoPath;
  final Animation<double> battito;
  final double lato;

  /// Il colore dell'elemento dominante, ordine CR voce 09.
  final Color? elemento;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const Key('face_portrait'),
      width: lato,
      height: lato,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusXl),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (fotoPath != null)
              Image.file(File(fotoPath!),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _FondoSagoma(palette: palette))
            else
              _FondoSagoma(palette: palette),
            AnimatedBuilder(
              animation: battito,
              builder: (context, _) => CustomPaint(
                painter: FaceConstellationPainter(
                  costellazione: costellazione,
                  palette: palette,
                  pulsazione: battito.value,
                  elemento: elemento,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Una riga di tratto letto: la sua stella e la sua frase dal corpus.
class _RigaTratto extends StatelessWidget {
  const _RigaTratto({required this.tratto, required this.palette});

  final FaceTrait tratto;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: Key('face_trait_${tratto.name}'),
      padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Icon(Icons.star_rounded, size: 16, color: palette.goldSoft),
          ),
          const SizedBox(width: SpacingTokens.sm),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TypographyTokens.didascalia()
                    .copyWith(color: ColorTokens.textPrimary, height: 1.4),
                children: [
                  TextSpan(
                      text: '${tratto.nome}. ',
                      style: TextStyle(
                          color: palette.goldSoft,
                          fontWeight: FontWeight.w600)),
                  TextSpan(text: FaceCorpus.frase(tratto)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// L'interruttore vivo dei transiti sul responso.
class _Transiti extends StatelessWidget {
  const _Transiti({
    required this.palette,
    required this.acceso,
    required this.onCambia,
    required this.riga,
  });

  final MaestroPalette palette;
  final bool acceso;
  final ValueChanged<bool> onCambia;
  final String? riga;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InterruttoreDelCerchio(
          key: const Key('face_transits_switch'),
          acceso: acceso,
          onCambia: onCambia,
          titolo: 'Lega ai transiti',
          sottotitolo: 'Il cielo di oggi si accosta alla tua lettura.',
        ),
        if (riga != null) ...[
          Text(FaceTransits.cornice,
              style: TypographyTokens.didascalia().copyWith(
                  color: ColorTokens.textSecondary,
                  height: 1.4,
                  fontStyle: FontStyle.italic)),
          const SizedBox(height: SpacingTokens.sm),
          Row(
            key: const Key('face_transit_line'),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.brightness_1, size: 7, color: palette.goldSoft),
              const SizedBox(width: SpacingTokens.sm),
              Expanded(
                child: Text(riga!,
                    style: TypographyTokens.didascalia()
                        .copyWith(color: ColorTokens.textPrimary, height: 1.4)),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Il ripiego tattile: un selettore guidato dei tratti, che alimenta lo stesso
/// motore e porta allo stesso responso.
class _Ripiego extends StatefulWidget {
  const _Ripiego({required this.palette, required this.onFatto});

  final MaestroPalette palette;
  final ValueChanged<FaceReading> onFatto;

  @override
  State<_Ripiego> createState() => _RipiegoState();
}

class _RipiegoState extends State<_Ripiego> {
  // Le categorie che il ripiego chiede, con l'icona per ciascuna variante.
  static const List<FaceCategory> _categorie = [
    FaceCategory.formaVolto,
    FaceCategory.grandezzaOcchi,
    FaceCategory.sopracciglia,
    FaceCategory.labbra,
    FaceCategory.mento,
  ];

  final Map<FaceCategory, FaceTrait> _scelte = {};

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    final completo = _scelte.length == _categorie.length;
    return SingleChildScrollView(
      key: const Key('face_fallback'),
      padding: const EdgeInsets.all(SpacingTokens.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: SpacingTokens.sm),
          Text('Scegli a mano',
              style: TypographyTokens.titoloSezione()
                  .copyWith(color: palette.goldSoft)),
          const SizedBox(height: SpacingTokens.xs),
          Text(
            'Guarda il tuo viso allo specchio e scegli, per ogni tratto, la '
            'forma che ti somiglia di più. Alimenta la stessa lettura.',
            style: TypographyTokens.didascalia()
                .copyWith(color: ColorTokens.textPrimary, height: 1.45),
          ),
          const SizedBox(height: SpacingTokens.lg),
          for (final cat in _categorie) ...[
            Text(cat.titolo,
                style: TypographyTokens.etichetta()
                    .copyWith(color: palette.goldSoft, letterSpacing: 0.6)),
            const SizedBox(height: SpacingTokens.xs),
            Wrap(
              spacing: SpacingTokens.sm,
              runSpacing: SpacingTokens.sm,
              children: [
                for (final t in FaceTrait.perCategoria(cat))
                  _Scelta(
                    key: Key('face_pick_${t.name}'),
                    tratto: t,
                    scelto: _scelte[cat] == t,
                    palette: palette,
                    onTap: () => setState(() => _scelte[cat] = t),
                  ),
              ],
            ),
            const SizedBox(height: SpacingTokens.md),
          ],
          const SizedBox(height: SpacingTokens.sm),
          FilledButton.icon(
            key: const Key('face_fallback_done'),
            style: FilledButton.styleFrom(
                backgroundColor: palette.primary,
                foregroundColor: palette.onPrimary,
                disabledBackgroundColor:
                    palette.surface.withValues(alpha: 0.5)),
            onPressed: completo
                ? () => widget.onFatto(FaceClassifier.daSelezioni(_scelte))
                : null,
            icon: const Icon(Icons.auto_awesome),
            label: Text(completo
                ? 'Vedi la tua costellazione'
                : 'Scegli tutti i tratti'),
          ),
          const SizedBox(height: SpacingTokens.xxxl),
        ],
      ),
    );
  }
}

/// Una scelta illustrata del ripiego: l'icona del tratto e il suo nome.
class _Scelta extends StatelessWidget {
  const _Scelta({
    super.key,
    required this.tratto,
    required this.scelto,
    required this.palette,
    required this.onTap,
  });

  final FaceTrait tratto;
  final bool scelto;
  final MaestroPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.md, vertical: SpacingTokens.sm),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
          color: scelto
              ? palette.primary.withValues(alpha: 0.3)
              : palette.surface.withValues(alpha: 0.4),
          border: Border.all(
            color:
                scelto ? palette.goldSoft : palette.gold.withValues(alpha: 0.3),
            width: scelto ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_icona(tratto.categoria),
                size: 16,
                color: scelto ? palette.goldSoft : ColorTokens.textSecondary),
            const SizedBox(width: SpacingTokens.xs),
            Text(tratto.nome,
                style: TypographyTokens.didascalia().copyWith(
                    color:
                        scelto ? palette.goldSoft : ColorTokens.textPrimary)),
          ],
        ),
      ),
    );
  }

  IconData _icona(FaceCategory c) {
    switch (c) {
      case FaceCategory.formaVolto:
        return Icons.face_outlined;
      case FaceCategory.grandezzaOcchi:
        return Icons.remove_red_eye_outlined;
      case FaceCategory.sopracciglia:
        return Icons.waves_rounded;
      case FaceCategory.labbra:
        return Icons.sentiment_satisfied_outlined;
      case FaceCategory.mento:
        return Icons.change_history_rounded;
      default:
        return Icons.star_outline_rounded;
    }
  }
}

/// DUE VOLTI NELLO STESSO CERCHIO. Ordine BX voce 03.
///
/// **Il minimo che la condizione richiede, e niente di piu'.** Il corpus
/// chiede "confronti la tua Costellazione del Viso con quella di un'altra
/// persona": l'altra persona e' QUI e si fa leggere adesso. Nessun dato esce
/// da questo telefono, nessuno viene salvato, nessuna identita' viene chiesta:
/// la lettura del secondo volto vive quanto vive la schermata.
class _DueVolti extends StatelessWidget {
  const _DueVolti({
    required this.palette,
    required this.mio,
    required this.altro,
    required this.onLeggiLAltro,
    required this.onChiudi,
  });

  final MaestroPalette palette;
  final FaceReading mio;
  final FaceReading? altro;
  final VoidCallback onLeggiLAltro;

  /// Chiude il confronto e riporta il pulsante. Senza questo il riquadro,
  /// che vive fuori dall'area scorrevole, resta a schermo per sempre.
  final VoidCallback onChiudi;

  @override
  Widget build(BuildContext context) {
    final secondo = altro;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          SpacingTokens.lg, 0, SpacingTokens.lg, SpacingTokens.lg),
      child: secondo == null
          ? OutlinedButton.icon(
              key: const Key('face_leggi_altro'),
              onPressed: onLeggiLAltro,
              style: OutlinedButton.styleFrom(
                  foregroundColor: palette.goldSoft,
                  side: BorderSide(color: palette.gold.withValues(alpha: 0.6)),
                  minimumSize: const Size.fromHeight(48)),
              icon: const Icon(Icons.group_outlined, size: 18),
              // **PIU' CORTA DI DUE PAROLE. Ordine CQ voce 2.11**: le
              // etichette sono salite da dodici a quattordici punti, e a
              // quattordici questa andava a capo. Un maiuscoletto su due
              // righe e' un muro di lettere larghe, e la guardia delle
              // etichette lo vieta: si accorcia la frase, non si riabbassa
              // la misura. Il confronto lo dice la schermata che si apre.
              label: Text('Leggi un altro volto',
                  style: TypographyTokens.etichetta()),
            )
          : Container(
              key: const Key('face_due_volti'),
              padding: const EdgeInsets.all(SpacingTokens.md),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
                color: palette.surfaceElevated.withValues(alpha: 0.85),
                border: Border.all(color: palette.gold.withValues(alpha: 0.6)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // **IL TITOLO E LA VIA D'USCITA SULLA STESSA RIGA.** La
                  // chiusura sta accanto al titolo e non in fondo, perche' in
                  // fondo la si trova solo dopo aver letto tutto il riquadro
                  // che si vuole togliere.
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text('Due volti nello stesso Cerchio',
                            style: TypographyTokens.titoloScheda()
                                .copyWith(color: palette.goldSoft)),
                      ),
                      IconButton(
                        key: const Key('face_due_volti_chiudi'),
                        onPressed: onChiudi,
                        visualDensity: VisualDensity.compact,
                        tooltip: 'Chiudi il confronto',
                        icon: Icon(Icons.close_rounded,
                            size: 20, color: palette.goldSoft),
                      ),
                    ],
                  ),
                  const SizedBox(height: SpacingTokens.xs),
                  // **DALLA PORTA UNICA, non un Text diretto.** La regola
                  // di casa vuole che il testo che si legge passi da
                  // `ParagrafiDiLettura`: un Text nel ruolo lettura e\' la
                  // famiglia da cui il muro di testo torna, e la guardia di
                  // casa lo ha visto.
                  ParagrafiDiLettura(
                    testo: mio.dominante == secondo.dominante
                        ? 'Vi accompagna lo stesso tratto: '
                            '${mio.dominante.nome}.'
                        : 'Il tuo tratto è ${mio.dominante.nome}, il '
                            'suo è ${secondo.dominante.nome}.',
                    stile: TypographyTokens.lettura()
                        .copyWith(color: ColorTokens.textPrimary),
                  ),
                  const SizedBox(height: SpacingTokens.xs),
                  // **NON IN MAIUSCOLETTO.** L'etichetta e\' un segnale, non
                  // un testo: questa frase va a capo, e in maiuscoletto
                  // diventava un muro di lettere larghe.
                  Text(
                      'Niente di questa lettura esce dal tuo telefono: vive '
                      'quanto questa schermata.',
                      style: TypographyTokens.didascalia()
                          .copyWith(color: ColorTokens.textSecondary)),
                ],
              ),
            ),
    );
  }
}
