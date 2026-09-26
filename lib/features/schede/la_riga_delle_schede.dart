import 'package:flutter/material.dart';

import '../../core/arts/art_catalog.dart';
import '../../core/arts/gli_sfondi_delle_schede.dart';
import '../../core/config/app_flags.dart';
import '../../core/maestro/maestro.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import 'la_luce_delle_schede.dart';
import 'la_scheda_dell_arte.dart';

/// **UNA RIGA DI SCHEDE CHE SCORRE IN ORIZZONTALE.** Ordine EO voci 07 e 09,
/// 26 settembre 2026.
///
/// Il fondatore: ogni categoria scorre in orizzontale e la pagina in
/// verticale, come Netflix. E *"4 ok"*, sulla proposta *"scorrendo una riga,
/// la scheda al centro si ingrandisce appena e prende luce, le altre restano
/// un poco in ombra"*. **Dall'ordine EP voce 09 si solleva anche con la
/// riduzione del movimento**, come il riflesso: *"Luce sempre accesa"*.
class LaRigaDelleSchede extends StatefulWidget {
  const LaRigaDelleSchede({
    super.key,
    required this.chiave,
    required this.titolo,
    required this.arti,
    required this.formato,
    this.maestroDi,
    this.azione,
    this.chiaveDelTitolo,
    this.onTieni,
    this.sfondoDelMaestro = false,
    this.mostraFase = AppFlags.isDemo,
    this.inCasa = false,
    this.onVediTutto,
  });

  /// **La riga della home**, con le misure dell'ordine EP: schede all'88 per
  /// cento (voce 02), margini 16 e 12 (voce 03), 24 punti fra una riga e
  /// l'altra e 8 fra il titolo e le schede (voce 04). Nei domini resta falso
  /// e le misure restano quelle dell'ordine EO.
  final bool inCasa;

  /// "Vedi tutto" accanto al titolo (ordine EP voce 07): se c'e', la riga lo
  /// mostra e il tocco lo chiama.
  final VoidCallback? onVediTutto;

  /// La chiave della riga, per le prove e per le catture: `riga_<chiave>`.
  final String chiave;

  final String titolo;
  final List<ArtEntry> arti;
  final FormatoDellaScheda formato;

  /// Il Maestro di un'arte; se manca, lo cerca la scheda nel catalogo.
  final Maestro Function(ArtEntry art)? maestroDi;

  /// Un comando accanto al titolo, come la matita delle arti preferite.
  final Widget? azione;

  /// La chiave del titolo, se la riga ne ha una sua: quella delle arti
  /// preferite tiene `tue_arti_titolo`, che le guardie della home gia'
  /// cercano da prima dell'ordine EO.
  final Key? chiaveDelTitolo;

  /// La pressione lunga su una scheda, se la riga la prevede.
  final void Function(ArtEntry art)? onTieni;

  /// La riga "In arrivo" dei domini: lo sfondo del Maestro e l'icona.
  final bool sfondoDelMaestro;

  /// La fase delle arti in arrivo si dice solo nella Demo.
  final bool mostraFase;

  /// **Quanto si solleva la scheda al centro**, e quanta ombra resta sulle
  /// altre.
  static const double sollevamento = 1.05;
  static const double ombra = 0.32;

  /// Quanto la scheda [indice] e' al centro, fra 0 e 1, con lo scorrimento
  /// [pixel] in una vista larga [vista].
  static double quantoAlCentro(
      {required int indice,
      required double pixel,
      required double passo,
      required double larghezza,
      required double vista,
      double margine = SpacingTokens.lg}) {
    final centro = margine + indice * passo + larghezza / 2 - pixel;
    final distanza = (centro - vista / 2).abs();
    return (1 - distanza / (vista / 2)).clamp(0.0, 1.0);
  }

  /// Lo spazio fra una scheda e l'altra, nei domini.
  static const double spazio = SpacingTokens.md;

  /// **I MARGINI DELLA HOME.** Ordine EP voce 03. Il fondatore, sui consigli
  /// presi dagli streaming: *"Margini 16 e 12"*, *"La terza scheda si vede
  /// tagliata sul bordo e fa capire che la riga scorre."* A sinistra della
  /// prima scheda 16 punti invece di 24, fra una scheda e l'altra 12 invece
  /// di 16.
  static const double margineInCasa = 16;
  static const double spazioInCasa = 12;

  /// **LO SPAZIO FRA LE RIGHE DELLA HOME.** Ordine EP voce 04. Il fondatore:
  /// *"Ridurre lo spazio verticale tra le file di categorie"*, e sulla
  /// domanda del vuoto *"24 punti"*, *"Come Disney+ e Prime. Il titolo di
  /// riga dista 8 punti dalle schede."* Sul Realme dell'ordine EO fra la fine
  /// di una riga e il titolo della successiva ce n'erano circa 90: la riga
  /// teneva il posto per tre righe di titolo anche quando ne usava una.
  static const double fraLeRigheInCasa = 24;
  static const double sottoIlTitoloInCasa = 8;

  static double margineDi(bool inCasa) =>
      inCasa ? margineInCasa : SpacingTokens.lg;
  static double spazioDi(bool inCasa) => inCasa ? spazioInCasa : spazio;

  /// **IL COLORE DEI TITOLI DI RIGA.** Ordine EP voce 08. Il fondatore: *"I
  /// titoli delle categorie in giallo oro."*, e sulla domanda se valga anche
  /// nei domini *"Home e domini"*. E' l'oro del design system.
  static const Color coloreDelTitolo = ColorTokens.gold;

  @override
  State<LaRigaDelleSchede> createState() => _LaRigaDelleSchedeState();
}

class _LaRigaDelleSchedeState extends State<LaRigaDelleSchede> {
  final ScrollController _scorri = ScrollController();
  final ValueNotifier<double> _scorrimento = ValueNotifier<double>(0);

  @override
  void initState() {
    super.initState();
    _scorri.addListener(() {
      // **L'ULTIMA POSIZIONE, non `position`.** Quando la riga cambia chiave
      // nello stesso posto (un dominio montato dopo l'altro), per un
      // fotogramma il controller ha due viste attaccate e `position`
      // solleva un'asserzione: si legge quella nuova.
      if (!_scorri.hasClients) return;
      final p = _scorri.positions.last;
      _scorrimento.value = p.maxScrollExtent <= 0
          ? 0
          : (p.pixels / p.maxScrollExtent).clamp(0, 1);
    });
  }

  @override
  void dispose() {
    _scorri.dispose();
    _scorrimento.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.arti.isEmpty) return const SizedBox.shrink();
    final scaler = MediaQuery.textScalerOf(context);
    final scala = scaler.scale(1);
    final inCasa = widget.inCasa;
    final larghezza = LaSchedaDellArte.larghezzaPer(widget.formato,
        scalaDelTesto: scala, inCasa: inCasa);
    final margine = LaRigaDelleSchede.margineDi(inCasa);
    final spazioFra = LaRigaDelleSchede.spazioDi(inCasa);
    final riduci = LaLuceDelleSchede.spenta(context);
    final double altezza;
    if (inCasa) {
      // **La riga finisce dove finiscono i suoi titoli** (ordine EP voce
      // 04): l'immagine, lo spazio, il titolo piu' alto della riga, tutto
      // alla misura della scheda al centro, che si solleva dall'alto. Il
      // vuoto fino al titolo della riga dopo e' il suo margine di 24 punti.
      altezza = (larghezza / widget.formato.proporzione +
              SpacingTokens.xs +
              LaSchedaDellArte.altezzaDeiTitoli(
                  widget.arti, larghezza, scaler)) *
          LaRigaDelleSchede.sollevamento;
    } else {
      // L'altezza della riga nei domini: l'immagine, un poco di
      // sollevamento, due righe di titolo (o le tre del Viaggio), e il
      // respiro.
      final titolo = TextPainter(
        text: TextSpan(text: 'A', style: LaSchedaDellArte.stileDelTitolo()),
        textDirection: TextDirection.ltr,
        textScaler: scaler,
      )..layout();
      final altezzaTitolo = titolo.height * 3;
      titolo.dispose();
      altezza = larghezza /
              widget.formato.proporzione *
              LaRigaDelleSchede.sollevamento +
          SpacingTokens.xs +
          altezzaTitolo +
          SpacingTokens.sm;
    }
    return Column(
      key: Key('riga_${widget.chiave}'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // **LA TESTATA DELLA RIGA.** Nella prima stesura "Vedi tutto" stava
        // dopo uno `Spacer`, che col titolo flessibile si divideva a meta' la
        // riga: sul Realme "Le arti preferite" si spezzava a meta' parola e
        // "Trova una risposta" andava su tre righe. E la sua area di tocco,
        // alta 48 punti, allungava la testata: il vuoto sopra il titolo
        // passava da 24 a 40. Ora il titolo e la matita prendono tutto lo
        // spazio meno quello di "Vedi tutto", e "Vedi tutto" sta in basso a
        // destra con la sua area di tocco che sale nel vuoto sopra il titolo,
        // senza allungare niente.
        Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                  margine,
                  inCasa ? LaRigaDelleSchede.fraLeRigheInCasa : SpacingTokens.lg,
                  margine +
                      (widget.onVediTutto == null
                          ? 0
                          : _VediTutto.larghezza(scaler)),
                  0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      widget.titolo,
                      key: widget.chiaveDelTitolo ??
                          Key('riga_titolo_${widget.chiave}'),
                      style: TypographyTokens.titoloDiSchermata().copyWith(
                          color: LaRigaDelleSchede.coloreDelTitolo),
                    ),
                  ),
                  if (widget.azione != null) ...[
                    const SizedBox(width: SpacingTokens.xs),
                    widget.azione!,
                  ],
                ],
              ),
            ),
            if (widget.onVediTutto != null)
              Positioned(
                right: margine,
                bottom: 0,
                height: _VediTutto.altezza,
                child: _VediTutto(
                    chiave: widget.chiave, onTap: widget.onVediTutto!),
              ),
          ],
        ),
        SizedBox(
            height: inCasa
                ? LaRigaDelleSchede.sottoIlTitoloInCasa
                : SpacingTokens.sm),
        SizedBox(
          height: altezza,
          child: LoScorrimentoDellaRiga(
            scorrimento: _scorrimento,
            child: LayoutBuilder(builder: (context, spazio) {
              final vista = spazio.maxWidth;
              return ListView.separated(
                key: Key('riga_scorre_${widget.chiave}'),
                controller: _scorri,
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                padding: EdgeInsets.symmetric(horizontal: margine),
                itemCount: widget.arti.length,
                separatorBuilder: (_, __) => SizedBox(width: spazioFra),
                itemBuilder: (context, i) {
                  final art = widget.arti[i];
                  final scheda = LaSchedaDellArte(
                    key: Key('riga_${widget.chiave}_${art.id}'),
                    art: art,
                    maestro: widget.maestroDi?.call(art) ??
                        maestroDiArte(context, art.id),
                    formato: widget.formato,
                    larghezza: larghezza,
                    sfondoDelMaestro: widget.sfondoDelMaestro,
                    mostraFase: widget.mostraFase,
                    onTieni: widget.onTieni == null
                        ? null
                        : () => widget.onTieni!(art),
                  );
                  if (riduci) return scheda;
                  return _AlCentro(
                    scorri: _scorri,
                    indice: i,
                    passo: larghezza + spazioFra,
                    margine: margine,
                    larghezza: larghezza,
                    altezzaImmagine: larghezza / widget.formato.proporzione,
                    vista: vista,
                    child: scheda,
                  );
                },
              );
            }),
          ),
        ),
      ],
    );
  }
}

/// **LA SCHEDA AL CENTRO SI SOLLEVA E PRENDE LUCE.** Ordine EO voce 07.
class _AlCentro extends StatelessWidget {
  const _AlCentro({
    required this.scorri,
    required this.indice,
    required this.passo,
    required this.larghezza,
    required this.altezzaImmagine,
    required this.vista,
    required this.margine,
    required this.child,
  });

  /// Il margine a sinistra della prima scheda.
  final double margine;

  final ScrollController scorri;
  final int indice;
  final double passo;
  final double larghezza;

  /// L'altezza dell'immagine della scheda: l'ombra copre solo lei.
  final double altezzaImmagine;
  final double vista;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: scorri,
      builder: (context, figlio) {
        final pixel = scorri.hasClients ? scorri.positions.last.pixels : 0.0;
        final t = LaRigaDelleSchede.quantoAlCentro(
            indice: indice,
            pixel: pixel,
            passo: passo,
            larghezza: larghezza,
            vista: vista,
            margine: margine);
        return Transform.scale(
          alignment: Alignment.topCenter,
          scale: 1 + (LaRigaDelleSchede.sollevamento - 1) * t,
          child: Stack(
            children: [
              figlio!,
              // **L'OMBRA STA SULLA SOLA IMMAGINE.** La prima stesura copriva
              // tutto il riquadro della scheda, titolo e aria sotto compresi,
              // e con le animazioni accese si vedeva un rettangolo scuro
              // sotto i titoli: visto sul Realme con la build di misura.
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: altezzaImmagine,
                child: IgnorePointer(
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(SpacingTokens.radiusSm + 4),
                    child: ColoredBox(
                      key: Key('scheda_ombra_$indice'),
                      color: Colors.black
                          .withValues(alpha: LaRigaDelleSchede.ombra * (1 - t)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      child: child,
    );
  }
}

/// **"VEDI TUTTO".** Ordine EP voce 07. Il fondatore, sui consigli presi
/// dagli streaming: *"Vedi tutto"*, *"Accanto al titolo della riga, apre la
/// categoria intera in griglia."*
class _VediTutto extends StatelessWidget {
  const _VediTutto({required this.chiave, required this.onTap});

  final String chiave;
  final VoidCallback onTap;

  /// L'area di tocco: 48 punti di altezza, come ogni comando dell'app.
  static const double altezza = 48;

  /// **La spaziatura delle lettere e' scritta qui.** Senza, il pulsante la
  /// prendeva dal tema, la larghezza riservata non la contava, e sul Realme
  /// si leggeva "Vedi tutt".
  static TextStyle get _stile => TypographyTokens.didascalia(weight: 600)
      .copyWith(color: ColorTokens.goldLight, letterSpacing: 0.3);

  /// La larghezza: la scritta e un poco d'aria, mai meno di 48 punti.
  static double larghezza(TextScaler scala) {
    final p = TextPainter(
      text: TextSpan(text: 'Vedi tutto', style: _stile),
      textDirection: TextDirection.ltr,
      textScaler: scala,
    )..layout();
    final w = p.width + 2 * SpacingTokens.xxs + 2;
    p.dispose();
    return w < altezza ? altezza : w;
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      key: Key('riga_vedi_tutto_$chiave'),
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: ColorTokens.goldLight,
        minimumSize: const Size(48, 48),
        alignment: Alignment.bottomRight,
        padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.xxs),
        visualDensity: VisualDensity.compact,
      ),
      // **IN TONDO E NON IN MAIUSCOLETTO.** In maiuscoletto "Vedi tutto"
      // prendeva 98 punti e i titoli delle righe andavano a capo gia' a
      // testo normale ("Trova una risposta" 229 punti, a 360 ne restavano
      // 214); in tondo ne prende 62, e a 360 punti tutti i titoli stanno
      // su una riga.
      child: Text('Vedi tutto', maxLines: 1, softWrap: false, style: _stile),
    );
  }
}
