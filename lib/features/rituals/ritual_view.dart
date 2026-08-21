
import 'package:flutter/material.dart';

import '../../core/rituals/daily_elements.dart';
import '../../core/sensi/ascoltatore_scuotimento.dart';
import '../../design_system/components/le_tre_righe_del_rito.dart';
import '../../design_system/components/ritual_backdrop.dart';
import '../tarot/stesa_senses.dart' show TiltListener;
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';

/// Come si compie un rituale: con un gesto tattile universale, oppure con un
/// sensore che sul device lo arricchisce.
enum RitualGesture {
  tap,
  hold,
  swipe,
  shake,

  /// IL GIROSCOPIO, ordine P voce 16.
  ///
  /// **Il difetto che questo valore chiude.** L'Oracolo del Giorno dichiarava,
  /// nel suo commento e nella riga a schermo, che la rivelazione arriva
  /// inclinando il telefono. Il giroscopio non era collegato a niente: questo
  /// enum aveva quattro valori e nessuno di loro leggeva l'inclinazione, e
  /// `_listenShake` partiva solo su [shake]. Chi inclinava non otteneva nulla e
  /// non poteva capire perche', perche' l'app gli aveva appena detto di farlo.
  ///
  /// Il ripiego tattile resta OBBLIGATORIO: il tocco svela sempre, sensore o no.
  tilt,
}

/// Impalcatura condivisa dei rituali del giorno: livello visivo prima del testo,
/// un gesto per rivelare il responso e, sempre, un ripiego tattile universale.
///
/// Il visualizzatore sta in alto e occupa la scena; il responso si rivela sotto
/// dopo il gesto. Ogni sensore (microfono, giroscopio) e' un di piu' sul device:
/// qui il gesto tattile basta da solo, cosi' nessuno resta fuori.
class RitualView extends StatefulWidget {
  const RitualView({
    super.key,
    required this.title,
    required this.palette,
    required this.gesture,
    required this.prompt,
    required this.sensorHint,
    required this.visualBuilder,
    this.cosaEIlVisivo,
    required this.revealed,
    this.rito,
    this.cosaRicevi,
    this.ripiego,
    this.footnote,
    this.onReveal,
    this.backgroundAsset,
  });

  /// Quale dei cinque doni e' questo rito. Serve alle tre righe in testa,
  /// ordine P voce 17: cosa fai, perche', cosa ti resta.
  final DailyElement? rito;

  /// LA RIGA CHE DICE COSA STAI PER RICEVERE, prima del gesto.
  ///
  /// Ordine P voce 16: nessuno compie un gesto senza sapere cosa ne esce. Il
  /// COSA E' LA COSA CHE SI VEDE. Ordine S voce 12.
  ///
  /// **Il difetto: il disco dell'Oracolo non diceva cosa fosse.** Funzionava, il
  /// cielo reagiva al movimento del telefono, e chi lo guardava non capiva ne'
  /// cosa stesse guardando ne' cosa ottenesse muovendolo. La riga del gesto
  /// compariva solo PRIMA della rivelazione e la riga del sensore stava in fondo,
  /// dopo il responso: dopo il gesto il disco restava li', nudo.
  ///
  /// **Delle due strade dell'ordine si e' presa la (a):** il disco resta e acquista
  /// un senso. Buttarlo perche' non era spiegato sarebbe stato risolvere un
  /// problema di parole togliendo l'unico punto dell'app in cui il cielo reagisce
  /// al movimento del telefono.
  ///
  /// Nullo per i riti il cui livello visivo si spiega da se': il sole che si
  /// solleva non ha bisogno di una didascalia.
  final String? cosaEIlVisivo;

  /// [prompt] dice come si fa, questa dice cosa si ottiene, e sono due cose
  /// diverse: "Inclina o scorri per rivelare" non dice niente a nessuno.
  final String? cosaRicevi;

  /// IL RIPIEGO, quando il responso non c'e'.
  ///
  /// Ordine P voce 16, nessuno stato senza uscita. Quando e' non nullo, al
  /// posto del responso compare questa etichetta con un Riprova, mai una
  /// schermata muta.
  final ({String etichetta, VoidCallback riprova})? ripiego;

  final String title;
  final MaestroPalette palette;
  final RitualGesture gesture;

  /// Slot del fondale condiviso. Percorso di un asset PNG di fondale quando
  /// disponibile; null ripiega sul fondo procedurale coerente col cosmo della
  /// home. Ogni rito lo predispone: quando arriva il PNG definitivo basta
  /// cablarlo qui, senza toccare scena, stati e interazioni.
  final String? backgroundAsset;

  /// Invito al gesto, mostrato prima della rivelazione.
  final String prompt;

  /// Riga che spiega il sensore e il ripiego tattile.
  final String sensorHint;

  /// Il visualizzatore, dato lo stato di rivelazione, un valore d'animazione e
  /// L'INCLINAZIONE DEL TELEFONO sui due assi.
  ///
  /// L'inclinazione arriva fin qui perche' la voce 16 chiede che il cielo
  /// REAGISCA al giroscopio: un sensore che serve solo a far scattare la
  /// rivelazione e' un pulsante scomodo, non un cielo che risponde. A zero, cioe'
  /// senza sensore, la scena resta composta e non manca niente.
  final Widget Function(
      BuildContext context, bool revealed, double t, Offset inclinazione)
      visualBuilder;

  /// Il responso, mostrato dopo il gesto.
  final Widget revealed;

  /// Nota onesta in coda (per esempio segnaposto d'arte o cornice culturale).
  final String? footnote;

  final VoidCallback? onReveal;

  @override
  State<RitualView> createState() => _RitualViewState();
}

class _RitualViewState extends State<RitualView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  bool _revealed = false;
  AscoltatoreScuotimento? _scuotimento;

  /// L'ASCOLTATORE DELL'INCLINAZIONE, la porta unica del giroscopio in questa
  /// app: la stessa che inclina le carte posate della Stesa e la costellazione
  /// del Sigillo del Sogno. Un secondo ascoltatore sarebbe la terza porta.
  TiltListener? _inclinazione;

  /// Quanta inclinazione svela il responso, in radianti.
  ///
  /// [TiltListener] limita a 0,06 radianti: la meta' e' un gesto deciso e non
  /// un tremolio della mano. Piu' in alto sarebbe irraggiungibile, perche' oltre
  /// il massimo il valore non sale.
  static const double _bastaCosi = 0.03;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    if (widget.gesture == RitualGesture.shake) _listenShake();
    if (widget.gesture == RitualGesture.tilt) _ascoltaLInclinazione();
  }

  /// IL CIELO REAGISCE AL GIROSCOPIO, e a un certo punto si scopre.
  void _ascoltaLInclinazione() {
    final ascoltatore = TiltListener()..start();
    ascoltatore.addListener(() {
      if (!mounted) return;
      // Il cielo si muove a ogni notifica, rivelato o no.
      setState(() {});
      if (_revealed) return;
      if (ascoltatore.x.abs() >= _bastaCosi ||
          ascoltatore.y.abs() >= _bastaCosi) {
        _reveal();
      }
    });
    _inclinazione = ascoltatore;
  }

  // Scuotimento: un picco netto dell'accelerazione svela. Se il sensore manca,
  // resta il tocco come ripiego tattile universale.
  void _listenShake() {
    // LA PORTA UNICA: soglia, antirimbalzo e niente samplingPeriod stanno
    // in AscoltatoreScuotimento, con le loro ragioni scritte accanto.
    _scuotimento = AscoltatoreScuotimento(onScuotimento: _reveal)..start();
  }

  @override
  void dispose() {
    _scuotimento?.dispose();
    _inclinazione?.dispose();
    _pulse.dispose();
    super.dispose();
  }

  void _reveal() {
    if (_revealed) return;
    setState(() => _revealed = true);
    widget.onReveal?.call();
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;

    Widget gestureWrap(Widget child) {
      switch (widget.gesture) {
        case RitualGesture.tap:
          return GestureDetector(
              key: const Key('ritual_gesture'),
              behavior: HitTestBehavior.opaque,
              onTap: _reveal,
              child: child);
        case RitualGesture.hold:
          return GestureDetector(
              key: const Key('ritual_gesture'),
              behavior: HitTestBehavior.opaque,
              onLongPress: _reveal,
              onTap: _reveal,
              child: child);
        case RitualGesture.swipe:
          return GestureDetector(
              key: const Key('ritual_gesture'),
              behavior: HitTestBehavior.opaque,
              onHorizontalDragEnd: (_) => _reveal(),
              onTap: _reveal,
              child: child);
        case RitualGesture.shake:
          // Lo scuotimento arriva dal sensore; il tocco e' il ripiego tattile.
          return GestureDetector(
              key: const Key('ritual_gesture'),
              behavior: HitTestBehavior.opaque,
              onTap: _reveal,
              child: child);
        case RitualGesture.tilt:
          // L'inclinazione arriva dal giroscopio; IL RIPIEGO TATTILE E'
          // OBBLIGATORIO, quindi qui ci sono sia il tocco sia lo scorrimento:
          // chi non ha il sensore, o lo ha negato, compie il rito uguale.
          return GestureDetector(
              key: const Key('ritual_gesture'),
              behavior: HitTestBehavior.opaque,
              onHorizontalDragEnd: (_) => _reveal(),
              onTap: _reveal,
              child: child);
      }
    }

    return Scaffold(
      backgroundColor: ColorTokens.neutralDeepest,
      appBar: AppBar(
        backgroundColor: palette.deepest.withValues(alpha: 0.4),
        elevation: 0,
        iconTheme: IconThemeData(color: palette.goldSoft),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Indietro',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(widget.title, style: TypographyTokens.display(size: 20)),
      ),
      body: RitualBackdrop(
        palette: palette,
        assetPath: widget.backgroundAsset,
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              // Livello visivo, prima del testo.
              Expanded(
                flex: 5,
                child: gestureWrap(
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned.fill(
                        child: AnimatedBuilder(
                          animation: _pulse,
                          builder: (context, _) => widget.visualBuilder(
                            context,
                            _revealed,
                            _pulse.value,
                            Offset(_inclinazione?.x ?? 0,
                                _inclinazione?.y ?? 0),
                          ),
                        ),
                      ),
                      if (!_revealed)
                        Positioned(
                          bottom: SpacingTokens.lg,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // COSA STAI PER RICEVERE, prima del gesto.
                              if (widget.cosaRicevi != null) ...[
                                Text(
                                  widget.cosaRicevi!,
                                  key: const Key('rito_cosa_ricevi'),
                                  textAlign: TextAlign.center,
                                  style: TypographyTokens.didascalia().copyWith(
                                      color: palette.goldSoft, height: 1.35),
                                ),
                                const SizedBox(height: SpacingTokens.sm),
                              ],
                              _PromptPill(
                                  label: widget.prompt, palette: palette),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // **COSA E' QUELLO CHE SI VEDE, E COSA FA MUOVERLO.** Ordine S voce
              // 12: sta SOTTO il livello visivo. La riga del sensore e' salita
              // da sotto il responso a qui: dice cosa succede muovendo, e la
              // sua casa e' accanto alla cosa che si muove.
              //
              // **MA SPARISCE DOPO LA RIVELAZIONE. Ordine AS voce 08.** La
              // voce S.12 lo faceva restare perche' il disco restava li' anche
              // dopo; adesso il livello visivo e' la CARTA, cioe' la risposta
              // stessa, e sotto di lei non serve piu' sapere come si scopre una
              // cosa gia' scoperta. Vale la regola trasversale di quest'ordine:
              // due righe di istruzioni fra la carta e il suo responso sono
              // due righe che allontanano la risposta.
              if (widget.cosaEIlVisivo != null && !_revealed)
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: SpacingTokens.lg),
                  child: Column(
                    children: [
                      Text(
                        widget.cosaEIlVisivo!,
                        key: const Key('rito_cosa_e_il_visivo'),
                        textAlign: TextAlign.center,
                        style: TypographyTokens.didascalia().copyWith(
                            color: palette.goldSoft, height: 1.35),
                      ),
                      const SizedBox(height: SpacingTokens.xs),
                      _HintRow(
                          icon: Icons.touch_app_outlined,
                          text: widget.sensorHint,
                          palette: palette),
                    ],
                  ),
                ),
              // Responso, rivelato dopo il gesto.
              Expanded(
                flex: 4,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                      SpacingTokens.lg, 0, SpacingTokens.lg, SpacingTokens.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // LE TRE RIGHE DEL RITO, ordine P voce 17, in testa.
                      if (widget.rito != null) ...[
                        LeTreRigheDelRito(
                          rito: widget.rito!,
                          inchiostro: ColorTokens.textPrimary,
                          accento: palette.goldSoft,
                        ),
                        const SizedBox(height: SpacingTokens.md),
                      ],
                      // NESSUNO STATO SENZA USCITA, ordine P voce 16: se il
                      // responso non c'e', compare il ripiego con la sua
                      // etichetta e il suo Riprova, mai una schermata muta.
                      if (_revealed && widget.ripiego != null)
                        Column(
                          key: const Key('rito_ripiego'),
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.ripiego!.etichetta,
                                style: TypographyTokens.corpo().copyWith(
                                    color: ColorTokens.textPrimary,
                                    height: 1.4)),
                            const SizedBox(height: SpacingTokens.sm),
                            OutlinedButton.icon(
                              key: const Key('rito_riprova'),
                              onPressed: widget.ripiego!.riprova,
                              icon: const Icon(Icons.refresh_rounded, size: 16),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: palette.goldSoft,
                                side: BorderSide(
                                    color: palette.gold
                                        .withValues(alpha: 0.55)),
                              ),
                              label: Text('Riprova',
                                  style: TypographyTokens.didascalia()
                                      .copyWith(color: palette.goldSoft)),
                            ),
                          ],
                        )
                      else if (_revealed)
                        Container(
                            key: const Key('ritual_content'),
                            child: widget.revealed),
                      const SizedBox(height: SpacingTokens.md),
                      // **LA RIGA DEL SENSORE NON SI RIPETE.** Ordine S voce 12:
                      // per i riti che dichiarano cosa e' il loro visivo, e'
                      // salita accanto al disco. Per gli altri resta qui, che e'
                      // la sua casa di sempre.
                      if (widget.cosaEIlVisivo == null)
                        _HintRow(
                            icon: Icons.touch_app_outlined,
                            text: widget.sensorHint,
                            palette: palette),
                      if (widget.footnote != null) ...[
                        const SizedBox(height: SpacingTokens.sm),
                        _HintRow(
                            icon: Icons.auto_awesome,
                            text: widget.footnote!,
                            palette: palette),
                      ],
                    ],
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

class _PromptPill extends StatelessWidget {
  const _PromptPill({required this.label, required this.palette});

  final String label;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.md, vertical: SpacingTokens.sm),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
        color: palette.deepest.withValues(alpha: 0.5),
        border: Border.all(color: palette.gold.withValues(alpha: 0.5)),
      ),
      child: Text(label,
          style: TypographyTokens.label(size: 12)
              .copyWith(color: palette.goldSoft, letterSpacing: 0.8)),
    );
  }
}

class _HintRow extends StatelessWidget {
  const _HintRow(
      {required this.icon, required this.text, required this.palette});

  final IconData icon;
  final String text;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 13, color: palette.goldSoft),
        const SizedBox(width: 6),
        Expanded(
          child: Text(text,
              style: TypographyTokens.etichetta().copyWith(
                color: palette.goldSoft.withValues(alpha: 0.7),
                letterSpacing: 0.3,
                height: 1.4,
              )),
        ),
      ],
    );
  }
}
