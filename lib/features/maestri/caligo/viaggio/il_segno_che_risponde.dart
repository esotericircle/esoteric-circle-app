import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/rituals/animal_catalog.dart';
import '../../../../core/viaggio/i_video_del_cammino_scaricati.dart';
import '../../../../core/viaggio/il_segno_dell_animale.dart';
import '../../../../core/viaggio/la_sequenza_del_cammino.dart';
import '../../../../design_system/theme/maestro_palette.dart';
import '../../../../design_system/tokens/color_tokens.dart';
import '../../../../design_system/tokens/spacing_tokens.dart';
import '../../../../design_system/tokens/typography_tokens.dart';
import '../../../../design_system/typography/paragrafi_di_lettura.dart';
import 'il_cammino_dell_animale.dart';

/// **IL SEGNO CHE RISPONDE.** Ordine DI voce 14, 12 settembre 2026; i gesti
/// diventano pezzi del video con l'ordine FZ voce FZ.05, 17 ottobre 2026.
///
/// *"La persona scrive una domanda in una riga. L'animale risponde con un
/// gesto, non con un discorso. La risposta e' una immagine o una animazione
/// breve dell'animale piu' una riga sola di testo che dice cosa ha fatto e
/// cosa vuol dire per la domanda posta."*
///
/// **IL GESTO E' IL VIDEO DELL'ANIMALE, A PEZZI**, ordine FZ voce FZ.05: si
/// avvicina gioca arrivo e centro poi resta in posa, si volta il solo
/// centro, si allontana la sola uscita. **Escono gli zoom avanti, indietro e
/// la rotazione dell'illustrazione** (ordine DJ voce 08) e i trentasei
/// disegni dei gesti: il video e' la sola risposta visiva, e la posa (il
/// fotogramma della carta da grattare, sempre nel pacchetto) resta finche'
/// il video non e' pronto, senza rete o con Riduci Movimento.
class IlSegnoCheRisponde extends StatefulWidget {
  const IlSegnoCheRisponde({
    super.key,
    required this.animale,
    required this.palette,
    required this.siPuoChiedere,
    required this.quandoTorna,
    required this.chiedi,
    required this.quandoTorni,
    required this.quandoNutri,
    this.videoScaricati,
  });

  final GuideAnimal animale;
  final MaestroPalette palette;

  /// Se il piano consente un segno adesso. Se no, si dice quando torna e si
  /// offre il nutrimento: *"non si mostra un muro"*.
  final bool siPuoChiedere;

  /// La riga che dice quando torna un segno, gia' composta dai tetti.
  final String quandoTorna;

  /// Chiede il segno, col modello o con la riserva: non fallisce mai.
  final Future<UnSegno> Function(String domanda) chiedi;

  final VoidCallback quandoTorni;
  final VoidCallback quandoNutri;

  /// Dove stanno i video scaricati: iniettabile nelle prove.
  final IVideoDelCamminoScaricati? videoScaricati;

  /// La lunghezza massima della domanda: una riga.
  static const int domandaAlMassimo = 120;

  /// La carta (il fotogramma della posa) di [animale], sempre nel
  /// pacchetto: ordine FZ voce FZ.04/FZ.06.
  static String posaDi(GuideAnimal animale) =>
      'assets/img/mondo_di_sotto/carte/'
      '${animale.stem.substring(4, animale.stem.length - 3)}'
      '_carta_da_grattare_v1.webp';

  @override
  State<IlSegnoCheRisponde> createState() => _IlSegnoCheRispondeState();
}

class _IlSegnoCheRispondeState extends State<IlSegnoCheRisponde> {
  final TextEditingController _domanda = TextEditingController();
  UnSegno? _segno;
  bool _inAttesa = false;
  bool _gestoFinito = false;

  IVideoDelCamminoScaricati get _video =>
      widget.videoScaricati ?? IVideoDelCamminoScaricati.diCasa;

  @override
  void initState() {
    super.initState();
    // **SI SCARICA QUANDO SERVE**, ordine FZ voce FZ.06: la persona e'
    // davanti a questo animale, e il suo video (se non c'e' gia') si
    // scarica ora, senza bloccare la domanda. Un guasto resta silenzioso:
    // la posa basta.
    if (!_video.installato(widget.animale.name.toLowerCase())) {
      unawaited(_video.scaricaAnimale(widget.animale.name));
    }
  }

  @override
  void dispose() {
    _domanda.dispose();
    super.dispose();
  }

  Future<void> _chiedi() async {
    final testo = _domanda.text.trim();
    if (testo.isEmpty || _inAttesa) return;
    FocusScope.of(context).unfocus();
    setState(() => _inAttesa = true);
    final segno = await widget.chiedi(testo);
    if (!mounted) return;
    setState(() {
      _segno = segno;
      _inAttesa = false;
      _gestoFinito = false;
    });
  }

  String get _conArticolo => '${widget.animale.articolo}${widget.animale.name}';

  /// *al Lupo*, *alla Volpe*, *all'Aquila*.
  String get _alNome {
    final a = widget.animale.articolo;
    if (a == 'il ') return 'al ${widget.animale.name}';
    if (a == 'la ') return 'alla ${widget.animale.name}';
    // L'articolo elide davanti a vocale, e la preposizione con lui.
    return 'al$a${widget.animale.name}';
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    final segno = _segno;
    final nomeFile = widget.animale.name.toLowerCase();
    final posa = IlSegnoCheRisponde.posaDi(widget.animale);
    return Stack(
      fit: StackFit.expand,
      children: [
        if (segno == null)
          Image.asset(posa,
              key: const Key('viaggio_posa_del_segno'),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink())
        else
          Builder(builder: (context) {
            final sequenza = LaSequenzaDelCammino.perIlGesto(segno.gesto,
                haFineUscita: _video.haFineUscita(nomeFile));
            return IlCamminoDellAnimale(
              key: ValueKey(segno),
              sequenza: sequenza,
              percorsi: {
                for (final p in sequenza.pezzi)
                  if (_video.percorsoDiPezzo(nomeFile, p) != null)
                    p: _video.percorsoDiPezzo(nomeFile, p)!,
              },
              posa: posa,
              scenaVuota: _video.percorsoDellaScenaVuota(nomeFile),
              quandoFinisce: () {
                if (mounted) setState(() => _gestoFinito = true);
              },
            );
          }),
        Align(
          alignment: Alignment.bottomCenter,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(SpacingTokens.lg),
              child: _ilPannello(palette, segno),
            ),
          ),
        ),
      ],
    );
  }

  Widget _ilPannello(MaestroPalette palette, UnSegno? segno) {
    final torna = TextButton(
      key: const Key('viaggio_torna_dal_segno'),
      onPressed: widget.quandoTorni,
      child: Text('Torna',
          style:
              TypographyTokens.etichetta().copyWith(color: palette.goldSoft)),
    );
    if (!widget.siPuoChiedere && segno == null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // **IL TESTO DA LEGGERE PASSA DALLA SUA PORTA**, ordine DI: la
          // guardia della lettura ha trovato qui un Text diretto.
          ParagrafiDiLettura(
            key: const Key('viaggio_quando_torna_un_segno'),
            testo: widget.quandoTorna,
            textAlign: TextAlign.center,
            stile: TypographyTokens.lettura().copyWith(color: palette.goldSoft),
          ),
          const SizedBox(height: SpacingTokens.md),
          FilledButton(
            key: const Key('viaggio_nutri_dal_segno'),
            onPressed: widget.quandoNutri,
            style: FilledButton.styleFrom(
              backgroundColor: palette.primary,
              foregroundColor: palette.onPrimary,
              minimumSize: const Size.fromHeight(52),
            ),
            child: Text(_nutriLo, style: TypographyTokens.etichetta()),
          ),
          torna,
        ],
      );
    }
    if (segno != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // **LA RIGA ARRIVA A GESTO FINITO**: prima si guarda cosa fa, poi si
          // legge cosa vuol dire.
          Opacity(
            opacity: _gestoFinito ? 1 : 0,
            child: ParagrafiDiLettura(
              key: const Key('viaggio_riga_del_segno'),
              testo: segno.riga,
              textAlign: TextAlign.center,
              stile: TypographyTokens.lettura()
                  .copyWith(color: ColorTokens.textPrimary, height: 1.5),
            ),
          ),
          const SizedBox(height: SpacingTokens.md),
          torna,
        ],
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Chiedi un segno $_alNome',
          key: const Key('viaggio_chiedi_un_segno_titolo'),
          textAlign: TextAlign.center,
          style: TypographyTokens.titoloScheda()
              .copyWith(color: ColorTokens.textPrimary),
        ),
        const SizedBox(height: SpacingTokens.xs),
        Text(
          '${_maiuscola(_conArticolo)} non parla: risponde con un gesto.',
          textAlign: TextAlign.center,
          style: TypographyTokens.didascalia()
              .copyWith(color: ColorTokens.textSecondary),
        ),
        const SizedBox(height: SpacingTokens.md),
        TextField(
          key: const Key('viaggio_domanda_del_segno'),
          controller: _domanda,
          maxLines: 1,
          maxLength: IlSegnoCheRisponde.domandaAlMassimo,
          textInputAction: TextInputAction.send,
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) => unawaited(_chiedi()),
          style:
              TypographyTokens.corpo().copyWith(color: ColorTokens.textPrimary),
          decoration: InputDecoration(
            hintText: 'Una domanda, in una riga',
            hintStyle: TypographyTokens.corpo()
                .copyWith(color: ColorTokens.textSecondary),
            filled: true,
            fillColor: Colors.black.withValues(alpha: 0.35),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
              borderSide:
                  BorderSide(color: palette.gold.withValues(alpha: 0.3)),
            ),
          ),
        ),
        const SizedBox(height: SpacingTokens.sm),
        FilledButton(
          key: const Key('viaggio_chiedi_il_segno'),
          // **SPENTO FINCHE' NON C'E' UNA DOMANDA**, ordine DN voce 06: col
          // campo vuoto il tocco non faceva niente, ed era un comando che non
          // risponde, la regola L dell'ordine DD.
          onPressed: _inAttesa || _domanda.text.trim().isEmpty
              ? null
              : () => unawaited(_chiedi()),
          style: FilledButton.styleFrom(
            backgroundColor: palette.primary,
            foregroundColor: palette.onPrimary,
            minimumSize: const Size.fromHeight(52),
          ),
          child: Text(_inAttesa ? 'Ti sta guardando' : 'Chiedi',
              style: TypographyTokens.etichetta()),
        ),
        torna,
      ],
    );
  }

  String get _nutriLo => widget.animale.femminile ? 'Nutrila' : 'Nutrilo';

  static String _maiuscola(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
