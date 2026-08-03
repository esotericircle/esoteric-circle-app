import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/chat/maestro_memory.dart';
import '../../core/maestro/frasi_dell_attesa.dart';
import '../../core/maestro/maestro.dart';
import '../../core/maestro/natal_context.dart';
import '../../core/maestro/tempi_dell_attesa.dart';
import '../../core/quality/quality_tier.dart';
import '../../features/maestri/widgets/maestro_bust.dart';
import '../theme/maestro_scope.dart';
import '../tokens/spacing_tokens.dart';
import '../tokens/typography_tokens.dart';

/// L'ATTESA SI DEVE POTER LEGGERE.
///
/// Vive nel design system e non dentro la chat perche' le superfici che
/// aspettano una risposta sono DUE, la chat e il Consulta.
///
/// **Cosa c'era prima, e perche' e' cambiato.** La scena mostrava il corpo
/// celeste che il Maestro stava guardando, un emblema di segno oppure il disco
/// lunare, e le righe si succedevano ogni 1,6 secondi. Il fondatore lo ha
/// guardato sul telefono: le frasi sono scritte per essere lette e non se ne
/// aveva il tempo, sembravano sei difetti di seguito. E l'emblema cambiava con
/// la riga, quindi la scena non aveva un centro.
///
/// **La scena adesso.** Un emblema solo, quello del MAESTRO, fermo al centro,
/// che si colora da monocromo a colore pieno in tre secondi e poi resta pieno.
/// Sotto, una frase alla volta, due secondi netti ciascuna. Il minimo garantito
/// e' di due frasi intere: se la risposta arriva prima, la scena finisce
/// comunque il suo minimo. Se tarda, le frasi ricominciano dalla prima SENZA
/// che l'emblema si scolori, perche' un caricamento che riparte da zero dice
/// che qualcosa e' andato storto, mentre non e' andato storto niente.
///
/// **Le frasi dicono il vero.** Nascono da [FrasiDellAttesa], che le lascia
/// passare solo quando il dato che nominano e' davvero nel contesto che parte
/// verso il modello.
///
/// Con Riduci Movimento o Quality Tier basso l'emblema c'e' ed e' GIA' a
/// colori, e nessun controllore viene creato: non uno lasciato fermo, proprio
/// nessuno.
class ConsultoDelCieloView extends StatefulWidget {
  const ConsultoDelCieloView({
    super.key,
    required this.natal,
    this.maestro,
    this.memoria = MaestroMemory.empty,
    this.rotazione = 0,
    this.durataFrase = TempiDellAttesa.durataBattuta,
  });

  /// I dati di questa persona. Decidono QUALI frasi si possono dire.
  final NatalContext natal;

  /// Chi sta consultando. Le frasi sono sue, dal suo mestiere: nessuna riga e'
  /// condivisa fra i tre.
  final Maestro? maestro;

  /// La memoria del Maestro con questa persona. Anche lei decide una frase.
  final MaestroMemory memoria;

  /// Quale giro di frasi. Cresce a ogni domanda, cosi' due attese vicine non
  /// aprono sulla stessa riga.
  final int rotazione;

  /// Quanto resta a schermo ogni frase. Il valore vive in [TempiDellAttesa]:
  /// qui c'e' solo il modo di scavalcarlo in una prova.
  final Duration durataFrase;

  /// Il lato dell'emblema quando lo spazio abbonda.
  static const double tettoDelCorpo = 220;

  /// Il lato sotto il quale non si stringe: piu' giu' l'emblema diventa una
  /// macchia, e una macchia non dice niente a nessuno.
  static const double pavimentoDelCorpo = 72;

  /// Gli stacchi fra le righe della colonna, piu' il rientro verticale.
  static const double stacchiERientri = 12 + 16 + 16;

  /// Quanto chiede la riga sotto l'emblema, MISURATA sulla frase vera.
  ///
  /// Non e' una costante, e non lo e' per un motivo pagato: una costante
  /// peggiore-caso era gia' stata scritta, valeva 130 e sforava lo stesso,
  /// perche' basta una frase nuova o una lingua nuova e smette di essere il
  /// peggiore senza che nessuno lo dica.
  static double riservaPer(String frase, double larghezza) {
    final utile = larghezza - SpacingTokens.lg * 2;
    final tp = TextPainter(
      text: TextSpan(text: frase, style: TypographyTokens.display(size: 18)),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: utile > 0 ? utile : larghezza);
    return tp.height + stacchiERientri;
  }

  /// Quanto e' grande l'emblema dato lo spazio libero.
  static double corpoPer(double altezzaLibera, double riserva) =>
      (altezzaLibera - riserva).clamp(pavimentoDelCorpo, tettoDelCorpo);

  @override
  State<ConsultoDelCieloView> createState() => _ConsultoDelCieloViewState();
}

class _ConsultoDelCieloViewState extends State<ConsultoDelCieloView>
    with SingleTickerProviderStateMixin {
  /// La colorazione. NULLA a moto fermo, e non creata e lasciata ferma: un
  /// controllore che nessuno fa girare resta un ticker registrato nell'albero.
  AnimationController? _colore;

  Timer? _passo;
  int _corrente = 0;
  List<String> _frasi = const [];
  bool _avviata = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_avviata) return;
    _avviata = true;

    _frasi = FrasiDellAttesa.per(
      widget.maestro ?? Maestro.medora,
      natal: widget.natal,
      memoria: widget.memoria,
    );
    // La rotazione sposta il punto di partenza, non l'ordine.
    if (_frasi.isNotEmpty) _corrente = widget.rotazione % _frasi.length;

    if (_fermo) return;
    _colore = AnimationController(
      vsync: this,
      duration: TempiDellAttesa.colorazioneDellEmblema,
    )..forward();
    _passo = Timer.periodic(widget.durataFrase, (_) {
      if (!mounted || _frasi.isEmpty) return;
      // SI RICOMINCIA DALLA PRIMA, e l'emblema non si scolora: il controllore
      // della colorazione non viene toccato qui.
      setState(() => _corrente = (_corrente + 1) % _frasi.length);
    });
  }

  /// Vero quando il moto e' spento, per scelta di sistema o per qualita' bassa.
  bool get _fermo =>
      MediaQuery.of(context).disableAnimations ||
      context.read<QualityTierController>().tier == QualityTier.low;

  @override
  void dispose() {
    _passo?.cancel();
    _colore?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final maestro = widget.maestro ?? Maestro.medora;
    final frase = _frasi.isEmpty ? '' : _frasi[_corrente % _frasi.length];

    return LayoutBuilder(builder: (context, vincoli) {
      final libero = vincoli.maxHeight.isFinite && vincoli.maxHeight > 0
          ? vincoli.maxHeight
          : MediaQuery.of(context).size.height;
      final larghezza = vincoli.maxWidth.isFinite && vincoli.maxWidth > 0
          ? vincoli.maxWidth
          : MediaQuery.of(context).size.width;
      final riserva = ConsultoDelCieloView.riservaPer(frase, larghezza);
      // TRE GRADINI, E IL TERZO E' IL VUOTO.
      //
      // Con la conversazione piena lo spazio libero misurato nella chat vera
      // scende a 48,3 punti mentre la riga ne chiede oltre cento: una riga
      // schiacciata sotto un emblema schiacciato non e' una scena piu'
      // piccola, e' un guasto. La bolla in attesa sotto dice gia' che il
      // Maestro sta rispondendo.
      if (libero < riserva) return const SizedBox.shrink();
      final ciSta = libero >= ConsultoDelCieloView.pavimentoDelCorpo + riserva;
      final lato = ConsultoDelCieloView.corpoPer(libero, riserva);

      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.lg,
          vertical: SpacingTokens.md,
        ),
        child: Column(
          key: const Key('consulto_del_cielo'),
          mainAxisSize: MainAxisSize.min,
          children: [
            if (ciSta) ...[
              _EmblemaCheSiColora(
                key: const Key('consulto_corpo'),
                maestro: maestro,
                lato: lato,
                colorazione: _colore,
              ),
              const SizedBox(height: SpacingTokens.sm),
            ],
            // UNA FRASE ALLA VOLTA, e senza dissolvenza incrociata: due righe
            // sovrapposte a meta' transizione erano illeggibili, e l'anteprima
            // del 3 agosto 2026 le mostrava accavallate.
            Text(
              frase,
              key: ValueKey('consulto_frase_$_corrente'),
              textAlign: TextAlign.center,
              style: TypographyTokens.display(size: 18)
                  .copyWith(color: palette.textPrimary),
            ),
          ],
        ),
      );
    });
  }
}

/// L'emblema del Maestro che passa da monocromo a colore pieno.
///
/// Con [colorazione] nulla e' gia' pieno e non si muove: e' il ramo di Riduci
/// Movimento, dove non esiste nessun controllore da far girare.
class _EmblemaCheSiColora extends StatelessWidget {
  const _EmblemaCheSiColora({
    super.key,
    required this.maestro,
    required this.lato,
    required this.colorazione,
  });

  final Maestro maestro;
  final double lato;
  final Animation<double>? colorazione;

  /// La matrice che toglie il colore. A `quanto` zero e' grigia piena, a uno
  /// e' l'identita', cioe' il colore vero dell'arte.
  static ColorFilter filtro(double quanto) {
    const r = 0.2126, g = 0.7152, b = 0.0722;
    final q = 1 - quanto.clamp(0.0, 1.0);
    return ColorFilter.matrix(<double>[
      r * q + quanto, g * q, b * q, 0, 0, //
      r * q, g * q + quanto, b * q, 0, 0, //
      r * q, g * q, b * q + quanto, 0, 0, //
      0, 0, 0, 1, 0, //
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final busto = MaestroBust(maestro: maestro, ring: lato, popOut: false);
    final vivo = colorazione;
    if (vivo == null) return SizedBox(width: lato, height: lato, child: busto);
    return SizedBox(
      width: lato,
      height: lato,
      child: AnimatedBuilder(
        animation: vivo,
        builder: (context, figlio) => ColorFiltered(
          colorFilter: filtro(vivo.value),
          child: figlio,
        ),
        child: busto,
      ),
    );
  }
}
