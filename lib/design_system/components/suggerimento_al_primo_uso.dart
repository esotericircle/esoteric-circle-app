import 'package:flutter/material.dart';

import '../../core/primo_uso/suggerimenti_di_zona.dart';
import '../theme/maestro_scope.dart';
import '../tokens/color_tokens.dart';
import '../tokens/spacing_tokens.dart';
import '../tokens/typography_tokens.dart';

/// IL SUGGERIMENTO AL PRIMO USO DI UNA ZONA. Ordine CE voce 12.
///
/// **NON E' UN POPUP, E' UNA RIGA DELLA ZONA.** I vincoli del fondatore sono
/// tre e nessuno e' negoziabile: si vede una volta sola, non blocca, non si
/// mette in mezzo. Il fondatore ha appena fatto togliere due fogli dal
/// Santuario perche' erano un ostacolo, quindi la forma qui e' l'opposto di un
/// foglio: nessuna barriera, nessun velo, nessun `showModalBottomSheet`.
/// Il suggerimento e' un widget che sta nella colonna della zona, sopra il suo
/// contenuto, e mentre e' li' tutto quello che c'e' sotto si tocca.
///
/// **SI CHIUDE DA SOLO ALLA PRIMA VOLTA, e resta chiuso.** Compare quando
/// esiste, si segna visto nello stesso momento in cui compare, e non torna:
/// non c'e' nessun gesto obbligatorio per farlo sparire, perche' un gesto
/// obbligatorio e' esattamente cio' che il fondatore ha chiamato ostacolo. La
/// crocetta c'e' per chi lo vuole via subito, e non serve a niente altro.
///
/// **NASCE SPENTO E SI ARMA.** Finche' nessuno ha armato i suggerimenti questo
/// widget e' alto zero: e' la stessa protezione del primo approdo, e serve
/// perche' nelle prove e nelle anteprime il disco e' vuoto, cioe' "mai visto"
/// e "appena arrivato" sono la stessa cosa. Senza, centinaia di scene
/// monterebbero con una riga in piu' che nessuna di loro si aspetta.
class SuggerimentoAlPrimoUso extends StatefulWidget {
  const SuggerimentoAlPrimoUso({super.key, required this.zona});

  final ZonaDelCerchio zona;

  /// La chiave con cui una prova, o un'anteprima, lo cerca a video.
  static Key chiaveDi(ZonaDelCerchio zona) =>
      Key('suggerimento_${zona.chiave}');

  @override
  State<SuggerimentoAlPrimoUso> createState() => _SuggerimentoAlPrimoUsoState();
}

class _SuggerimentoAlPrimoUsoState extends State<SuggerimentoAlPrimoUso> {
  bool _mostra = false;

  @override
  void initState() {
    super.initState();
    _chiedi();
  }

  @override
  void didUpdateWidget(SuggerimentoAlPrimoUso vecchio) {
    super.didUpdateWidget(vecchio);
    // **SE CAMBIA LA ZONA, SI RICHIEDE.** Flutter riusa lo stesso elemento
    // quando al suo posto arriva un widget dello stesso tipo, quindi senza
    // questo `initState` non tornerebbe mai e la seconda zona erediterebbe la
    // risposta della prima. Misurato in prova: la zona `dominio` compariva e
    // le altre tre restavano mute.
    if (vecchio.zona != widget.zona) {
      _mostra = false;
      _chiedi();
    }
  }

  Future<void> _chiedi() async {
    final da = await MemoriaDeiSuggerimenti.daMostrare(widget.zona);
    if (!mounted || !da) return;
    // Si segna visto appena compare, non alla chiusura: chi lo legge e se ne
    // va senza toccare niente lo ha comunque avuto, e ritrovarselo al ritorno
    // sarebbe la ripetizione che questa voce esiste per evitare.
    await MemoriaDeiSuggerimenti.segnaVisto(widget.zona);
    if (!mounted) return;
    setState(() => _mostra = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_mostra) return const SizedBox.shrink();
    final palette = context.palette;
    return Padding(
      key: SuggerimentoAlPrimoUso.chiaveDi(widget.zona),
      padding: const EdgeInsets.only(bottom: SpacingTokens.md),
      child: Container(
        padding: const EdgeInsets.all(SpacingTokens.md),
        decoration: BoxDecoration(
          color: palette.surfaceElevated.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
          border: Border.all(color: palette.gold.withValues(alpha: 0.35)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.auto_awesome_outlined,
                color: palette.goldSoft, size: 20),
            const SizedBox(width: SpacingTokens.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.zona.titolo,
                      style: TypographyTokens.titoloDiRiga()
                          .copyWith(color: palette.goldSoft)),
                  const SizedBox(height: SpacingTokens.xxs),
                  Text(widget.zona.testo,
                      style: TypographyTokens.corpo()
                          .copyWith(color: ColorTokens.textSecondary)),
                ],
              ),
            ),
            // La crocetta e' un di piu', non un pedaggio: chi non la tocca ha
            // gia' finito, perche' il suggerimento e' gia' segnato visto.
            IconButton(
              key: Key('suggerimento_via_${widget.zona.chiave}'),
              tooltip: 'Ho capito',
              onPressed: () => setState(() => _mostra = false),
              icon: Icon(Icons.close_rounded,
                  color: palette.goldSoft.withValues(alpha: 0.8), size: 18),
            ),
          ],
        ),
      ),
    );
  }
}
