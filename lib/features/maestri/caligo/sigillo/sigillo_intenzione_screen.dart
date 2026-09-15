import 'dart:async';
import '../../widgets/foglio_delle_fonti.dart';
import '../../chat/chat_openers.dart';
import '../../../ricordi/azioni_del_responso.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../sigilli/regia_del_cammino.dart';

import '../../../../core/astro/data_italiana.dart';
import '../../../../core/chat/la_marca_del_genere.dart';
import '../../../../core/entitlement/entitlement_service.dart';
import '../../../../core/entitlement/tier.dart';
import '../../../../core/magic/il_sigillo_dal_modello.dart';
import '../../../../core/magic/il_sigillo_vivo.dart';
import '../../../../core/magic/intention_sigil.dart';
import '../../../../core/magic/la_voce_del_sigillo.dart';
import '../../../../core/magic/libro_dei_sigilli.dart';
import '../../../../core/maestro/maestro.dart';
import '../../../../design_system/components/cosmos_background.dart';
import '../../../../design_system/components/depth_card.dart';
import '../../../../design_system/theme/maestro_palette.dart';
import '../../../../design_system/theme/maestro_scope.dart';
import '../../../../design_system/tokens/color_tokens.dart';
import '../../../../design_system/tokens/spacing_tokens.dart';
import '../../../../design_system/tokens/typography_tokens.dart';
import '../../../../services/il_libro_del_cerchio.dart';
import '../../../../services/lo_sfondo_del_telefono.dart';
import '../../rotta_arte.dart';
import '../../../../../design_system/components/titolo_che_non_si_rompe.dart';
import '../../../../design_system/transizioni/passaggio_del_cerchio.dart';
import '../../../../design_system/typography/paragrafi_di_lettura.dart';
import 'i_pezzi_del_sigillo.dart';
import 'il_segno_del_sigillo.dart';
import 'libro_dei_sigilli_screen.dart';

/// Il Sigillo dell'Intenzione, terza arte distintiva di Caligo.
///
/// Si sceglie la via, si scrive una intenzione in una frase, e ne nasce un
/// glifo unico. Il metodo e' quello di Austin Osman Spare per le lettere e la
/// Rosa dei Petali della Golden Dawn per la ruota: il calcolo vive in
/// `IntentionSigil`, qui c'e' solo la messa in scena.
///
/// **DALL'ORDINE DO IL SIGILLO E' UN OGGETTO CHE VIVE**, 15 settembre 2026.
/// Parole del fondatore: alla fine della funzione ci si chiedeva *"e adesso?
/// cosa mi rimane? cosa ho ottenuto? cosa me ne faccio? cosa devo fare?"*.
/// Qui il tracciare resta il primo momento, e non piu' l'unico: il sigillo
/// tracciato entra nel Libro dei Sigilli vivo e spento, con la data scelta
/// dalla persona, e da li' si carica, si mette come sfondo, e alla data si
/// chiude.
///
/// **Perche' non somiglia alla bindrune** (regola 21). La bindrune
/// dell'Estrazione Rune intreccia tratti su un'ASTA VERTICALE centrale e nasce
/// da un lancio; questo e' un CAMMINO SPEZZATO su una ruota di lettere e nasce
/// da una frase scritta. Nessuna asta, nessun ramo, nessuna simmetria attorno
/// a un centro: un percorso poligonale che si legge come un tragitto. Le due
/// cose sono diverse per costruzione, non per accorgimento.
class SigilloIntenzioneScreen extends StatefulWidget {
  const SigilloIntenzioneScreen({
    super.key,
    this.libro,
    this.chiamata,
    this.porta = const PortaDelloSfondo(),
  });

  /// Il Libro dove il sigillo entra: quello dell'app se nullo.
  final LibroDeiSigilli? libro;

  /// La chiamata al modello: quella vera se nulla. Le prove ne passano una
  /// finta.
  final ChiamataDelSigillo? chiamata;

  final PortaDelloSfondo porta;

  static Route<void> route() =>
      PassaggioDelCerchio.rotta<void>((_) => const SogliaArte(
            id: 'magic_sigil',
            maestro: Maestro.caligo,
            child: SigilloIntenzioneScreen(),
          ));

  /// Quanto dura il tracciamento del cammino, tratto dopo tratto.
  static const Duration tracciamento = Duration(milliseconds: 2400);

  @override
  State<SigilloIntenzioneScreen> createState() =>
      _SigilloIntenzioneScreenState();
}

enum _Fase { soglia, scrittura, tracciamento, rivelazione }

class _SigilloIntenzioneScreenState extends State<SigilloIntenzioneScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _campo = TextEditingController();
  late final AnimationController _traccia;
  _Fase _fase = _Fase.soglia;

  LibroDeiSigilli get _libro => widget.libro ?? libroDelCerchio;

  /// La via, scelta dalla persona PRIMA di scrivere. Voce DO.09: e' una
  /// dichiarazione di intento, non una classificazione, e dedurla vorrebbe
  /// dire dire alla persona che cosa sta chiedendo.
  ViaMagica? _via;

  late DateTime _scadenza;

  /// **LE RIFORMULAZIONI DI CALIGO**, al massimo tre per sigillo.
  int _riformulazioni = 0;
  bool _riformulando = false;
  String? _proposta;
  bool _propostaMancata = false;

  /// Vero quando la frase chiedeva di agire sulla volonta' di un altro: non
  /// si traccia, si riscrive su chi scrive.
  bool _suUnTerzo = false;

  /// Il testo da cui nasce il segno.
  String _testoDelSegno = '';
  SigilloVivo? _sigillo;
  TestiDelSigillo? _testi;
  Future<TestiDelSigillo>? _scrittura;

  /// Gli inviti tappabili, due per via: chi non sa da dove cominciare vede
  /// subito che si puo' chiedere, e nella via che ha scelto.
  static const Map<ViaMagica, List<String>> _suggerimenti = {
    ViaMagica.rossa: [
      'Trovo il coraggio di dire quello che sento',
      'Apro il mio cuore a un legame vero',
    ],
    ViaMagica.bianca: [
      'Chiedo chiarezza sulla mia strada',
      'Proteggo la quiete della mia casa',
    ],
    ViaMagica.verde: [
      'Metto radici dove sono adesso',
      'Faccio crescere il mio lavoro con pazienza',
    ],
  };

  @override
  void initState() {
    super.initState();
    _scadenza = TempoDelSigillo.mese.da(_libro.adesso)!;
    _traccia = AnimationController(
      vsync: this,
      duration: SigilloIntenzioneScreen.tracciamento,
    )..addStatusListener((s) {
        if (s == AnimationStatus.completed) _rivela();
      });
    _libro.addListener(_cambiato);
    if (!_libro.aperto) unawaited(_libro.apri());
  }

  void _cambiato() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _libro.removeListener(_cambiato);
    _campo.dispose();
    _traccia.dispose();
    super.dispose();
  }

  bool get _riduciMoto => MediaQuery.of(context).disableAnimations;

  Tier _tier() {
    try {
      return context.read<EntitlementService>().tier;
    } catch (senzaProvider) {
      // Senza il piano nell'albero vale il piu' prudente, il Viandante.
      return Tier.free;
    }
  }

  /// IL SIGILLO ENTRA NEL CAMMINO, ordine P voce 35: alla rivelazione, cioe'
  /// quando il segno e' compiuto e non quando si comincia a scriverlo.
  void _entraNelCammino() {
    unawaited(RegiaDelCammino.dopoUnGesto(context, 'sigillo'));
  }

  Future<void> _riformula() async {
    final testo = _campo.text.trim();
    if (_riformulando ||
        _riformulazioni >= IlSigilloDalModello.riformulazioniPerSigillo ||
        IntentionSigil.cammino(testo).length < 2) {
      return;
    }
    setState(() {
      _riformulando = true;
      _propostaMancata = false;
      _riformulazioni++;
    });
    final r = await IlSigilloDalModello.riformula(
      intenzione: testo,
      via: _via!,
      forma: LaMarcaDelGenere.formaCorrente,
      chiamata: widget.chiamata,
    );
    if (!mounted) return;
    setState(() {
      _riformulando = false;
      // Una frase su un terzo non resta mai senza proposta: se il modello
      // non risponde, vale quella di casa.
      _proposta =
          r ?? (_suUnTerzo ? LettoreIntenzione.leggi(testo).riformulata : null);
      _propostaMancata = _proposta == null;
    });
  }

  void _usaLaProposta() {
    final p = _proposta;
    if (p == null) return;
    setState(() {
      _campo.text = p;
      _campo.selection = TextSelection.collapsed(offset: p.length);
      _proposta = null;
      _suUnTerzo = false;
    });
  }

  void _traccia_() {
    final testo = _campo.text.trim();
    if (IntentionSigil.cammino(testo).length < 2 || _via == null) return;
    if (ILimitiDelSigillo.puoTracciare(_tier(), _libro) !=
        EsitoDelTracciamento.si) {
      setState(() => _fase = _Fase.soglia);
      return;
    }
    // **UNA FRASE SULLA VOLONTA' DI UN ALTRO NON SI TRACCIA.** Si riscrive
    // su chi scrive, e la persona vede la frase nuova prima di tracciarla.
    if (LettoreIntenzione.leggi(testo).eStataRiformulata) {
      setState(() => _suUnTerzo = true);
      if (_riformulazioni < IlSigilloDalModello.riformulazioniPerSigillo) {
        unawaited(_riformula());
      } else {
        setState(() => _proposta = LettoreIntenzione.leggi(testo).riformulata);
      }
      return;
    }
    final nascita = _libro.adesso;
    final via = _via!;
    setState(() {
      _testoDelSegno = testo;
      _sigillo = SigilloVivo(
        id: idDelSigillo(nascita),
        intenzione: testo,
        riformulata: testo,
        via: via,
        nascita: nascita,
        scadenza: _scadenza,
      );
      _testi = null;
      _fase = _Fase.tracciamento;
    });
    // Il modello scrive mentre il segno si traccia: la persona sta gia'
    // guardando qualcosa, e l'attesa si nasconde dentro il gesto.
    _scrittura = IlSigilloDalModello.scrivi(
      intenzione: testo,
      via: via,
      forma: LaMarcaDelGenere.formaCorrente,
      chiamata: widget.chiamata,
    );
    if (_riduciMoto) {
      _traccia.value = 1;
      // RIDUCI MOVIMENTO NON TOGLIE IL TRAGUARDO: senza animazione il
      // listener non scatta, e senza questa riga il Sigillo non entrerebbe
      // mai nel cammino per chi tiene il moto spento.
      _rivela();
    } else {
      _traccia
        ..value = 0
        ..forward();
    }
  }

  /// **LA RIVELAZIONE, E IL SIGILLO ENTRA NEL LIBRO.** Voce DO.02: nasce
  /// vivo e spento, con la carica a zero.
  Future<void> _rivela() async {
    // Una volta sola: con Riduci Movimento il valore messo a uno fa scattare
    // anche l'ascoltatore, e senza questa riga il sigillo entrava due volte.
    if (_fase == _Fase.rivelazione) return;
    setState(() => _fase = _Fase.rivelazione);
    _entraNelCammino();
    final testi = await _scrittura!;
    if (!mounted) return;
    setState(() => _testi = testi);
    await _libro.aggiungi(_sigillo!.conITesti(testi.titolo, testi.responso));
  }

  void _apriIlLibro() {
    Navigator.of(context).push(LibroDeiSigilliScreen.route(
        libro: widget.libro, chiamata: widget.chiamata, porta: widget.porta));
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Scaffold(
      backgroundColor: ColorTokens.neutralDeepest,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: palette.goldSoft),
        // **IL TITOLO NON SI ROMPE**, ordine S voce 05: a capo fra le
        // parole, la misura scende solo quanto serve, e non si tronca mai.
        // Col borsellino nella riga delle azioni lo spazio del titolo si e'
        // ristretto, e un `Text` nudo qui torna a mettere i puntini.
        title: TitoloCheNonSiRompe(
            testo: 'Il Sigillo dell\'Intenzione',
            stile: TypographyTokens.titoloDiSchermata()
                .copyWith(color: palette.goldSoft)),
        // IL BORSELLINO, ordine S voce 06: stesso segno, stesso angolo, in
        // ogni schermata della pratica. Un saldo che appare e scompare non
        // si impara.
        // **LA FONTE ARRIVA A CHI LEGGE.** Ordine CS, voce S2 della
        // scansione: il metodo di Spare e la Rosa dei Petali erano
        // nominati nel commento in testa a questo file e mai a video.
        actions: [
          FoglioDelleFonti.bottone(context,
              palette: palette,
              testo: TestiDelleFonti.sigillo,
              chiave: 'sigillo_fonti'),
          const AngoloDellaBarra(),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: CosmosBackground(
        seed: 23,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.lg),
            child: switch (_fase) {
              _Fase.soglia => _soglia(palette),
              _Fase.scrittura => _scritturaDellaFrase(palette),
              _Fase.tracciamento || _Fase.rivelazione => _scena(palette),
            },
          ),
        ),
      ),
    );
  }

  Widget _soglia(MaestroPalette palette) {
    final esito = ILimitiDelSigillo.puoTracciare(_tier(), _libro);
    final arrivati = _libro.scaduti.length;
    return ListView(
      key: const Key('sigillo_soglia'),
      children: [
        const SizedBox(height: SpacingTokens.lg),
        // **COSA STAI PER FARE**, sotto il titolo. Voce DO.01.
        Text(
          LaVoceDelSigillo.cosaStaiPerFare,
          key: const Key('sigillo_cosa_stai_per_fare'),
          textAlign: TextAlign.center,
          style: TypographyTokens.corpo()
              .copyWith(color: ColorTokens.textPrimary, height: 1.5),
        ),
        if (arrivati > 0) ...[
          const SizedBox(height: SpacingTokens.lg),
          // **LA DOMANDA ASPETTA**, voce DO.08: se la chiamata non e'
          // arrivata, chi apre il Sigillo la trova qui.
          DepthCard(
            key: const Key('sigillo_arrivati'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(LaVoceDelSigillo.titoloDellAvviso,
                    style: TypographyTokens.titoloSezione()
                        .copyWith(color: palette.goldSoft)),
                const SizedBox(height: SpacingTokens.xs),
                Text(LaVoceDelSigillo.testoDellAvviso,
                    style: TypographyTokens.corpo()
                        .copyWith(color: ColorTokens.textSecondary)),
                const SizedBox(height: SpacingTokens.sm),
                PulsanteDelSigillo(
                    testo: 'Apri il Libro dei Sigilli',
                    palette: palette,
                    onPressed: _apriIlLibro),
              ],
            ),
          ),
        ],
        const SizedBox(height: SpacingTokens.xl),
        if (esito == EsitoDelTracciamento.si) ...[
          Text('SCEGLI LA VIA',
              textAlign: TextAlign.center,
              style: TypographyTokens.etichetta()
                  .copyWith(color: palette.goldSoft, letterSpacing: 2)),
          const SizedBox(height: SpacingTokens.xs),
          Text(
            'Prima di scrivere: la via dice che cosa vuoi muovere.',
            textAlign: TextAlign.center,
            style: TypographyTokens.corpo()
                .copyWith(color: ColorTokens.textSecondary, height: 1.4),
          ),
          const SizedBox(height: SpacingTokens.md),
          for (final via in ViaMagica.values) ...[
            _SceltaDellaVia(
              via: via,
              scelta: _via == via,
              palette: palette,
              onTap: () => setState(() => _via = via),
            ),
            const SizedBox(height: SpacingTokens.sm),
          ],
          const SizedBox(height: SpacingTokens.md),
          PulsanteDelSigillo(
            key: const Key('sigillo_inizia'),
            testo: 'Scrivi la tua intenzione',
            palette: palette,
            onPressed: _via == null
                ? null
                : () => setState(() => _fase = _Fase.scrittura),
          ),
        ] else
          // **IL LIMITE NON E' UN MURO**, voce DO.11: si dice come fare, e si
          // porta la persona al Libro.
          DepthCard(
            key: const Key('sigillo_limite'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ParagrafiDiLettura(
                  testo: esito == EsitoDelTracciamento.pieno
                      ? LaVoceDelSigillo.pieno(
                          ILimitiDelSigillo.viviInsiemePer(_tier()))
                      : LaVoceDelSigillo.tettoTecnico,
                  stile: TypographyTokens.lettura().copyWith(height: 1.45),
                ),
                if (esito == EsitoDelTracciamento.pieno) ...[
                  const SizedBox(height: SpacingTokens.md),
                  PulsanteDelSigillo(
                      key: const Key('sigillo_limite_libro'),
                      testo: 'Apri il Libro dei Sigilli',
                      palette: palette,
                      onPressed: _apriIlLibro),
                ],
              ],
            ),
          ),
        if (_libro.tutti.isNotEmpty && esito == EsitoDelTracciamento.si) ...[
          const SizedBox(height: SpacingTokens.sm),
          TextButton(
            key: const Key('sigillo_apri_libro_soglia'),
            onPressed: _apriIlLibro,
            child: Text('Apri il Libro dei Sigilli',
                style:
                    TypographyTokens.corpo().copyWith(color: palette.goldSoft)),
          ),
        ],
        const SizedBox(height: SpacingTokens.xl),
        // **DA DOVE VIENE**, riga breve e verso il basso, come chiede la
        // gerarchia dettata dal fondatore il 3 settembre. Voce DO.01.
        Text(
          LaVoceDelSigillo.daDoveViene,
          key: const Key('sigillo_da_dove_viene'),
          textAlign: TextAlign.center,
          style: TypographyTokens.corpo()
              .copyWith(color: ColorTokens.textMuted, height: 1.45),
        ),
        const SizedBox(height: SpacingTokens.lg),
      ],
    );
  }

  Widget _scritturaDellaFrase(MaestroPalette palette) {
    final testo = _campo.text.trim();
    final abbastanza = IntentionSigil.cammino(testo).length >= 2;
    final restano =
        _riformulazioni < IlSigilloDalModello.riformulazioniPerSigillo;
    final via = _via!;
    return ListView(
      key: const Key('sigillo_scrittura'),
      children: [
        const SizedBox(height: SpacingTokens.lg),
        Text(via.nome,
            textAlign: TextAlign.center,
            style: TypographyTokens.titoloSezione()
                .copyWith(color: coloreDellaVia(via))),
        Text(via.dominio,
            textAlign: TextAlign.center,
            style: TypographyTokens.corpo()
                .copyWith(color: ColorTokens.textSecondary)),
        const SizedBox(height: SpacingTokens.md),
        // **COSA TI RESTERA'**, prima del campo dove si scrive. Voce DO.01.
        Text(
          LaVoceDelSigillo.cosaTiRestera,
          key: const Key('sigillo_cosa_ti_restera'),
          textAlign: TextAlign.center,
          style: TypographyTokens.corpo()
              .copyWith(color: ColorTokens.textPrimary, height: 1.5),
        ),
        const SizedBox(height: SpacingTokens.md),
        DepthCard(
          reveal: false,
          child: TextField(
            key: const Key('sigillo_campo'),
            controller: _campo,
            maxLines: 3,
            minLines: 2,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (_) => setState(() {
              _proposta = null;
              _propostaMancata = false;
              _suUnTerzo = false;
            }),
            style: TypographyTokens.lettura()
                .copyWith(color: ColorTokens.textPrimary, height: 1.4),
            cursorColor: palette.goldSoft,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Scrivo qui cosa voglio, al presente...',
              hintStyle: TypographyTokens.corpo()
                  .copyWith(color: ColorTokens.textMuted),
            ),
          ),
        ),
        const SizedBox(height: SpacingTokens.md),
        Text('Oppure parti da qui',
            style: TypographyTokens.etichetta()
                .copyWith(color: palette.goldSoft, letterSpacing: 2)),
        const SizedBox(height: SpacingTokens.sm),
        Wrap(
          spacing: SpacingTokens.sm,
          runSpacing: SpacingTokens.sm,
          children: [
            for (final (i, s) in _suggerimenti[via]!.indexed)
              GestureDetector(
                key: Key('sigillo_invito_$i'),
                onTap: () => setState(() {
                  _campo.text = s;
                  _campo.selection = TextSelection.collapsed(offset: s.length);
                  _proposta = null;
                  _suUnTerzo = false;
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: SpacingTokens.md, vertical: SpacingTokens.xs),
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(SpacingTokens.radiusPill),
                    border:
                        Border.all(color: palette.gold.withValues(alpha: 0.4)),
                  ),
                  child: Text(s,
                      style: TypographyTokens.corpo()
                          .copyWith(color: ColorTokens.textSecondary)),
                ),
              ),
          ],
        ),
        const SizedBox(height: SpacingTokens.lg),
        // **LA RIFORMULAZIONE DI CALIGO**, voce DO.09: su richiesta, tre
        // volte al massimo; oltre, la frase resta come la persona l'ha
        // scritta.
        if (_suUnTerzo)
          Padding(
            padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
            child: Text(
              'Avevi scritto di qualcun altro. Un sigillo agisce su chi '
              'lo traccia, mai sulla volontà di un terzo: Caligo la riporta '
              'su di te, che è dove ha forza.',
              key: const Key('sigillo_riformulata'),
              style: TypographyTokens.corpo()
                  .copyWith(color: ColorTokens.textSecondary, height: 1.45),
            ),
          ),
        if (_riformulando)
          Text('Caligo la riscrive nella forma del metodo...',
              key: const Key('sigillo_riformulando'),
              textAlign: TextAlign.center,
              style: TypographyTokens.corpo()
                  .copyWith(color: ColorTokens.textSecondary))
        else if (_proposta != null)
          DepthCard(
            key: const Key('sigillo_proposta'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('NELLA FORMA DEL METODO',
                    style: TypographyTokens.etichetta()
                        .copyWith(color: palette.goldSoft, letterSpacing: 2)),
                const SizedBox(height: SpacingTokens.xs),
                ParagrafiDiLettura(
                    testo: _proposta!,
                    stile: TypographyTokens.lettura().copyWith(height: 1.45)),
                const SizedBox(height: SpacingTokens.sm),
                PulsanteLeggeroDelSigillo(
                  key: const Key('sigillo_usa_proposta'),
                  testo: 'Usa questa',
                  palette: palette,
                  onPressed: _usaLaProposta,
                ),
              ],
            ),
          )
        else if (abbastanza && IlSigilloDalModello.temaDelicato(testo))
          // **SUI TEMI DELICATI CALIGO NON RISCRIVE**, voce DO.10: la frase
          // del metodo, detta come gia' vera, su salute, figli, cause e
          // denaro diventa una promessa. Si dice, invece di tacerlo.
          Text(
            'Su salute, figli, denaro e cause legali Caligo non riscrive la '
            'frase: resta la tua.',
            key: const Key('sigillo_tema_delicato'),
            textAlign: TextAlign.center,
            style: TypographyTokens.corpo()
                .copyWith(color: ColorTokens.textMuted, height: 1.4),
          )
        else if (abbastanza && restano && !_suUnTerzo)
          PulsanteLeggeroDelSigillo(
            key: const Key('sigillo_riformula'),
            testo: _riformulazioni == 0
                ? 'Chiedi a Caligo di riscriverla'
                : 'Chiedi un\'altra forma',
            palette: palette,
            onPressed: _riformula,
          ),
        if (_propostaMancata && !_riformulando)
          Padding(
            padding: const EdgeInsets.only(top: SpacingTokens.xs),
            // Vale sia per la rete che manca sia per la riga scartata dalle
            // guardie: *"non ha risposto"* sarebbe falso nel secondo caso.
            child: Text(
                'Caligo non ha trovato una forma migliore: la frase resta la '
                'tua.',
                textAlign: TextAlign.center,
                style: TypographyTokens.corpo()
                    .copyWith(color: ColorTokens.textMuted)),
          ),
        if (!restano && _proposta == null && !_riformulando)
          Padding(
            padding: const EdgeInsets.only(top: SpacingTokens.xs),
            child: Text('La frase resta come l\'hai scritta.',
                key: const Key('sigillo_riformulazioni_finite'),
                textAlign: TextAlign.center,
                style: TypographyTokens.corpo()
                    .copyWith(color: ColorTokens.textMuted)),
          ),
        const SizedBox(height: SpacingTokens.lg),
        Text('QUANDO TI CERCO',
            style: TypographyTokens.etichetta()
                .copyWith(color: palette.goldSoft, letterSpacing: 2)),
        const SizedBox(height: SpacingTokens.sm),
        LaDataDelSigillo(
          oggi: _libro.adesso,
          scadenza: _scadenza,
          palette: palette,
          onScelta: (d) => setState(() => _scadenza = d),
        ),
        const SizedBox(height: SpacingTokens.xl),
        PulsanteDelSigillo(
          key: const Key('sigillo_traccia'),
          testo: 'Traccia il sigillo',
          palette: palette,
          onPressed: abbastanza && !_riformulando && _proposta == null
              ? _traccia_
              : null,
        ),
        if (!abbastanza) ...[
          const SizedBox(height: SpacingTokens.sm),
          Text(
            'Servono almeno due lettere diverse: il sigillo è un cammino, '
            'quindi ha bisogno di due punti.',
            textAlign: TextAlign.center,
            style: TypographyTokens.corpo()
                .copyWith(color: ColorTokens.textMuted, height: 1.4),
          ),
        ],
        const SizedBox(height: SpacingTokens.lg),
      ],
    );
  }

  Widget _scena(MaestroPalette palette) {
    final sigillo = _sigillo!;
    final colore = coloreDellaVia(sigillo.via);
    final finito = _fase == _Fase.rivelazione;
    final cammino = IntentionSigil.cammino(_testoDelSegno);
    final testi = _testi;

    return ListView(
      key: const Key('sigillo_scena'),
      children: [
        const SizedBox(height: SpacingTokens.lg),
        AspectRatio(
          aspectRatio: 1,
          child: AnimatedBuilder(
            animation: _traccia,
            builder: (context, _) => CustomPaint(
              key: const Key('sigillo_ruota'),
              painter: RuotaSigilloPainter(
                cammino: cammino,
                lettere: IntentionSigil.lettereUniche(_testoDelSegno),
                avanzamento: _riduciMoto ? 1.0 : _traccia.value,
                colore: colore,
                oro: palette.goldSoft,
                mostraRuota: !finito,
              ),
            ),
          ),
        ),
        const SizedBox(height: SpacingTokens.lg),
        if (finito) ...[
          Text(sigillo.via.nome,
              key: const Key('sigillo_via'),
              textAlign: TextAlign.center,
              style: TypographyTokens.titoloSezione().copyWith(color: colore)),
          const SizedBox(height: SpacingTokens.xxs),
          Text(sigillo.via.dominio,
              textAlign: TextAlign.center,
              style: TypographyTokens.corpo()
                  .copyWith(color: ColorTokens.textSecondary)),
          const SizedBox(height: SpacingTokens.md),
          DepthCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (testi == null)
                  Text('Caligo scrive il tuo responso...',
                      key: const Key('sigillo_scrive'),
                      style: TypographyTokens.corpo()
                          .copyWith(color: ColorTokens.textSecondary))
                else ...[
                  // **IL TITOLO E IL RESPONSO SULL'INTENZIONE VERA**, voce
                  // DO.10: dal modello se reggono alle guardie, di casa
                  // altrimenti.
                  Text(testi.titolo,
                      key: const Key('sigillo_titolo'),
                      style: TypographyTokens.titoloSezione()
                          .copyWith(color: palette.goldSoft)),
                  const SizedBox(height: SpacingTokens.xs),
                  ParagrafiDiLettura(
                      key: const Key('sigillo_responso'),
                      testo: testi.responso,
                      stile: TypographyTokens.lettura().copyWith(height: 1.45)),
                ],
                const SizedBox(height: SpacingTokens.md),
                Text('LA TUA INTENZIONE',
                    style: TypographyTokens.etichetta()
                        .copyWith(color: palette.goldSoft, letterSpacing: 2)),
                const SizedBox(height: SpacingTokens.xxs),
                ParagrafiDiLettura(
                    testo: '"${sigillo.intenzione}"',
                    stile: TypographyTokens.lettura().copyWith(
                        color: ColorTokens.textSecondary, height: 1.45)),
              ],
            ),
          ),
          const SizedBox(height: SpacingTokens.lg),
          // **E ADESSO?** Voce DO.04: una riga sola, e il giorno in cui
          // l'app si fara' viva.
          Text(
            LaVoceDelSigillo.lasciaLavorare,
            key: const Key('sigillo_lascialo_lavorare'),
            textAlign: TextAlign.center,
            style: TypographyTokens.corpo()
                .copyWith(color: ColorTokens.textPrimary, height: 1.5),
          ),
          const SizedBox(height: SpacingTokens.xs),
          Text(
            'La data: ${dataItalianaEstesa(sigillo.scadenza)}.',
            key: const Key('sigillo_quando'),
            textAlign: TextAlign.center,
            style: TypographyTokens.corpo()
                .copyWith(color: palette.goldSoft, height: 1.4),
          ),
          const SizedBox(height: SpacingTokens.lg),
          PulsanteDelSigillo(
            key: const Key('sigillo_apri_libro'),
            testo: 'Apri il Libro dei Sigilli',
            palette: palette,
            onPressed: testi == null ? null : _apriIlLibro,
          ),
          const SizedBox(height: SpacingTokens.sm),
          // **COSA ME NE FACCIO?** Voce DO.07.
          IlSigilloSulTelefono(
            via: sigillo.via,
            cammino: cammino,
            palette: palette,
            porta: widget.porta,
          ),
          const SizedBox(height: SpacingTokens.lg),
          // **LE AZIONI DA UNA PORTA SOLA, ordine CG voci 06 e 08.** Qui
          // il Condividi non c'e' e non e' una dimenticanza: il Sigillo
          // produce un segno tracciato col dito, non una carta da
          // mandare. Restano il Custodisci e il Parlane, che di
          // un'immagine non hanno bisogno. L'ordine DO voce 07 non lo
          // contraddice: lo sfondo non manda niente a nessuno.
          AzioniDelResponso(
            palette: palette,
            maestro: Maestro.caligo,
            responso: ResponsoDaCustodire(
              arte: 'sigillo',
              titolo: testi?.titolo ?? 'Il tuo sigillo: ${sigillo.via.nome}',
              testo: sigillo.intenzione,
              dati: {'via': sigillo.via.nome},
            ),
            aperturaDellaChat: ChatOpeners.sigillo(sigillo.intenzione),
          ),
          const SizedBox(height: SpacingTokens.lg),
        ] else
          Text(
            'Traccio il tuo cammino sulle lettere...',
            textAlign: TextAlign.center,
            style: TypographyTokens.corpo()
                .copyWith(color: ColorTokens.textSecondary),
          ),
      ],
    );
  }
}

/// Una delle tre vie, da scegliere prima di scrivere.
class _SceltaDellaVia extends StatelessWidget {
  const _SceltaDellaVia({
    required this.via,
    required this.scelta,
    required this.palette,
    required this.onTap,
  });

  final ViaMagica via;
  final bool scelta;
  final MaestroPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colore = coloreDellaVia(via);
    return Semantics(
      button: true,
      selected: scelta,
      child: GestureDetector(
        key: Key('sigillo_via_${via.name}'),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(SpacingTokens.md),
          decoration: BoxDecoration(
            color: scelta
                ? colore.withValues(alpha: 0.14)
                : ColorTokens.neutralDeepest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
            border: Border.all(
                color: scelta ? colore : colore.withValues(alpha: 0.35),
                width: scelta ? 2 : 1),
          ),
          child: Row(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration:
                    BoxDecoration(color: colore, shape: BoxShape.circle),
              ),
              const SizedBox(width: SpacingTokens.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(via.nome,
                        style: TypographyTokens.titoloDiRiga()
                            .copyWith(color: ColorTokens.textPrimary)),
                    Text(via.dominio,
                        style: TypographyTokens.corpo()
                            .copyWith(color: ColorTokens.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// La ruota delle lettere col cammino che si traccia sopra.
///
/// Pubblico perche' l'avanzamento del tracciamento e' l'unica cosa che un test
/// possa leggere senza guardare i pixel.
class RuotaSigilloPainter extends CustomPainter {
  RuotaSigilloPainter({
    required this.cammino,
    required this.lettere,
    required this.avanzamento,
    required this.colore,
    required this.oro,
    this.mostraRuota = true,
  });

  /// I punti da unire, in coordinate normalizzate.
  final List<Offset> cammino;

  /// Le lettere corrispondenti, per scriverle sui petali toccati.
  final List<String> lettere;

  /// Da 0 (niente) a 1 (cammino completo).
  final double avanzamento;

  /// Il colore della via.
  final Color colore;
  final Color oro;

  /// Se disegnare la ruota di sfondo. A rivelazione avvenuta si spegne, e
  /// resta il solo segno: e' quello il sigillo, non la ruota.
  final bool mostraRuota;

  @override
  void paint(Canvas canvas, Size size) {
    Offset p(Offset n) => Offset(n.dx * size.width, n.dy * size.height);

    if (mostraRuota) {
      // I ventuno petali, ciascuno col suo pallino. La ruota si vede mentre
      // si traccia, cosi' si capisce da dove nasce il segno.
      final tenue = Paint()..color = oro.withValues(alpha: 0.22);
      for (var i = 0; i < IntentionSigil.petali; i++) {
        final l = IntentionSigil.alfabeto[i];
        final q = p(IntentionSigil.posizioneDi(l));
        final toccata = lettere.contains(l);
        canvas.drawCircle(q, toccata ? 3.4 : 2.0,
            toccata ? (Paint()..color = oro.withValues(alpha: 0.8)) : tenue);
        _lettera(
            canvas, l, q, size, toccata ? oro : oro.withValues(alpha: 0.3));
      }
      // Il cerchio che tiene insieme i petali, appena accennato.
      canvas.drawCircle(
        Offset(size.width / 2, size.height / 2),
        size.width * 0.38,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8
          ..color = oro.withValues(alpha: 0.15),
      );
    }

    if (cammino.length < 2) return;

    // Il cammino: una spezzata che si rivela per lunghezza. NON un intreccio
    // su un'asta, che e' la bindrune: qui ogni segmento va da una lettera alla
    // successiva, e il tragitto si legge come un percorso.
    final punti = [for (final n in cammino) p(n)];
    var totale = 0.0;
    for (var i = 0; i + 1 < punti.length; i++) {
      totale += (punti[i + 1] - punti[i]).distance;
    }
    var percorsa = totale * avanzamento.clamp(0.0, 1.0);

    final tratto = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = colore;
    final alone = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = colore.withValues(alpha: 0.25);

    final path = Path()..moveTo(punti.first.dx, punti.first.dy);
    for (var i = 0; i + 1 < punti.length; i++) {
      final seg = (punti[i + 1] - punti[i]).distance;
      if (percorsa <= 0) break;
      if (percorsa >= seg) {
        path.lineTo(punti[i + 1].dx, punti[i + 1].dy);
        percorsa -= seg;
      } else {
        final k = percorsa / seg;
        final q = Offset.lerp(punti[i], punti[i + 1], k)!;
        path.lineTo(q.dx, q.dy);
        percorsa = 0;
      }
    }
    canvas.drawPath(path, alone);
    canvas.drawPath(path, tratto);

    // Il capo e la coda del cammino: un cerchietto dove parte, una barra
    // dove finisce. E' la convenzione dei sigilli di Spare, e serve a dire in
    // che verso si legge.
    canvas.drawCircle(
      punti.first,
      4.5,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = colore,
    );
    if (avanzamento >= 1) {
      final a = punti[punti.length - 2];
      final b = punti.last;
      final d = (b - a).distance;
      if (d > 0) {
        final n = Offset(-(b.dy - a.dy) / d, (b.dx - a.dx) / d);
        canvas.drawLine(b - n * 6, b + n * 6, tratto);
      }
    }
  }

  void _lettera(
      Canvas canvas, String testo, Offset centro, Size size, Color colore) {
    final tp = TextPainter(
      text: TextSpan(
        text: testo,
        // ORDINE B: era 11, sotto il pavimento dell'app. Dipinta su tela e non
        // in albero, questa lettera non passa dai token e nessun assert la
        // vedeva: adesso la misura viene dal pavimento, che e' il numero da cui
        // dipende, invece che da una costante che lo ignora.
        style: TextStyle(
          color: colore,
          fontSize: TypographyTokens.pavimento,
          // **IL CARATTERE E' EBGaramond, e la scelta e' del fondatore.**
          // Ordine BT voce 01, sulla build 2207: davanti alle tre anteprime
          // dell'ordine BM voce 02 ha detto "ok per la (b), chiudiamo BM.02".
          // EBGaramond il pacchetto lo dichiara gia' e l'app lo carica gia',
          // quindi non entra un byte di asset in piu'. Prima qui c'era
          // CormorantGaramond, che nel pacchetto non c'e' mai stato: la ruota
          // si disegnava col carattere di sistema, cioe' con uno diverso su
          // ogni telefono.
          fontFamily: 'EBGaramond',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    // La lettera sta appena fuori dal suo pallino, verso l'esterno.
    final centroRuota = Offset(size.width / 2, size.height / 2);
    final v = centro - centroRuota;
    final l = v.distance;
    final fuori = l == 0 ? centro : centro + v / l * 14;
    tp.paint(canvas, fuori - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(RuotaSigilloPainter old) =>
      old.avanzamento != avanzamento ||
      old.cammino != cammino ||
      old.mostraRuota != mostraRuota;
}
