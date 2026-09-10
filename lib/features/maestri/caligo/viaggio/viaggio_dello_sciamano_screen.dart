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
import '../../../../design_system/typography/paragrafi_di_lettura.dart';
import '../../../maestri/rotta_arte.dart';
import '../../../sigilli/regia_del_cammino.dart';
import '../../widgets/foglio_delle_fonti.dart';
import '../../../../core/maestro/maestro.dart';
import 'il_tunnel_che_scende.dart';
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
  String _temaScelto = '';

  ScenaDelViaggio? _scena;
  String? _seguito;
  bool _caricato = false;

  /// **QUANTO DURA LA DISCESA.** Ordine DC voce 07: fra i quaranta e i novanta
  /// secondi, e **non si puo' saltare al primo viaggio**. Dal secondo in poi
  /// e' piu' rapida, perche' la strada e' conosciuta.
  Duration get _quantoDura =>
      _diario.quanteDiscese == 0
          ? const Duration(seconds: 45)
          : const Duration(seconds: 20);

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

  /// **SI SEGUE UN'OMBRA**, e la scelta si deposita.
  Future<void> _segui(String nome) async {
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
      _seguito = nome;
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
        title: Text('Il Viaggio dello Sciamano',
            style: TypographyTokens.titoloScheda()
                .copyWith(color: palette.goldSoft)),
        actions: [
          FoglioDelleFonti.bottone(context,
              palette: palette,
              testo: _fonti,
              chiave: 'viaggio_fonti'),
          const AngoloDellaBarra(),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: SafeArea(
        top: false,
        child: switch (_fase) {
          FaseDelViaggio.soglia => _laSoglia(palette),
          FaseDelViaggio.discesa => _laDiscesa(palette),
          FaseDelViaggio.nebbia => _laNebbia(palette),
          FaseDelViaggio.incontro => _lIncontro(palette),
          FaseDelViaggio.risalita => _laRisalita(palette),
        },
      ),
    );
  }

  /// **LA SOGLIA: la domanda, e la porta da cui si scende.**
  Widget _laSoglia(MaestroPalette palette) {
    final primo = _diario.quanteDiscese == 0;
    final perche = LaDomandaDelViaggio.perCheNonVa(_domanda.text,
        primoViaggio: primo);
    final siPuo = _caricato &&
        _diario.siPuoScendereOggi(giaRiconosciuto: _riconosciuto);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(SpacingTokens.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: SpacingTokens.xxl),
          ParagrafiDiLettura(
            key: const Key('viaggio_a_che_punto'),
            testo: IQuattroViaggi.aChePunto(_diario.quanteDiscese),
            textAlign: TextAlign.center,
            stile: TypographyTokens.lettura().copyWith(color: palette.goldSoft),
          ),
          const SizedBox(height: SpacingTokens.md),
          ParagrafiDiLettura(
            testo: 'Scendi con una domanda, risali con una risposta.',
            textAlign: TextAlign.center,
            stile: TypographyTokens.lettura()
                .copyWith(color: ColorTokens.textPrimary),
          ),
          const SizedBox(height: SpacingTokens.lg),
          TextField(
            key: const Key('viaggio_domanda'),
            controller: _domanda,
            maxLength: LaDomandaDelViaggio.quantoPuoEssereLunga,
            onChanged: (_) => setState(() => _temaScelto = ''),
            style: TypographyTokens.corpo()
                .copyWith(color: ColorTokens.textPrimary),
            decoration: InputDecoration(
              hintText: primo
                  ? 'La tua domanda, se ne hai una'
                  : 'La tua domanda',
              hintStyle: TypographyTokens.corpo()
                  .copyWith(color: ColorTokens.textSecondary),
            ),
          ),
          for (final d in LaDomandaDelViaggio.gliaScritte)
            TextButton(
              key: Key('viaggio_domanda_${d.id}'),
              onPressed: () => setState(() {
                _domanda.text = d.testo;
                _temaScelto = d.tema;
              }),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(d.tema,
                    style: TypographyTokens.didascalia()
                        .copyWith(color: palette.goldSoft)),
              ),
            ),
          TextButton(
            key: const Key('viaggio_solo_incontro'),
            onPressed: () => setState(() {
              _domanda.text = '';
              _temaScelto = LaDomandaDelViaggio.idSoloPerIncontrarlo;
            }),
            child: Text(LaDomandaDelViaggio.soloPerIncontrarlo,
                style: TypographyTokens.didascalia()
                    .copyWith(color: palette.goldSoft)),
          ),
          if (perche != null && _temaScelto.isEmpty) ...[
            Text(perche,
                key: const Key('viaggio_perche_non_si_scende'),
                style: TypographyTokens.didascalia()
                    .copyWith(color: palette.goldSoft)),
          ],
          if (!siPuo && _caricato) ...[
            const SizedBox(height: SpacingTokens.sm),
            ParagrafiDiLettura(
              key: const Key('viaggio_non_oggi'),
              testo: IQuattroViaggi.percheSiAspetta,
              stile: TypographyTokens.didascalia()
                  .copyWith(color: ColorTokens.textSecondary),
            ),
          ],
          const SizedBox(height: SpacingTokens.md),
          OutlinedButton(
            key: const Key('viaggio_scendi'),
            onPressed: siPuo &&
                    (perche == null || _temaScelto.isNotEmpty)
                ? () => setState(() => _fase = FaseDelViaggio.discesa)
                : null,
            style: OutlinedButton.styleFrom(
                foregroundColor: palette.goldSoft,
                minimumSize: const Size.fromHeight(52),
                side: BorderSide(color: palette.gold.withValues(alpha: 0.6))),
            child: Text('Scendi', style: TypographyTokens.etichetta()),
          ),
        ],
      ),
    );
  }

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
        Expanded(
          child: Row(
            children: [
              for (final a in ombre)
                Expanded(
                  child: GestureDetector(
                    key: Key('viaggio_ombra_${a.name}'),
                    onTap: () => unawaited(_segui(a.name)),
                    child: CustomPaint(
                      painter: PittoreDellAnimale(
                        discesa: quale,
                        quantaLuce: 0.35 + 0.2 * quale,
                        seme: a.name.hashCode,
                      ),
                    ),
                  ),
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
            Text(NitidezzaDellaScena.laRiga(scena.nitidezza)!,
                key: const Key('viaggio_nitidezza'),
                textAlign: TextAlign.center,
                style: TypographyTokens.didascalia()
                    .copyWith(color: palette.goldSoft)),
          ],
          const SizedBox(height: SpacingTokens.lg),
          // **IL NOME SOLO ALLA QUARTA**, ordine DC voce 04.
          if (nome != null)
            ParagrafiDiLettura(
              key: const Key('viaggio_il_nome'),
              testo: 'È il $nome. Adesso lo conosci.',
              textAlign: TextAlign.center,
              stile: TypographyTokens.lettura().copyWith(color: palette.gold),
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
      'incontra un animale, e lo si riconosce quando si è mostrato almeno '
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
