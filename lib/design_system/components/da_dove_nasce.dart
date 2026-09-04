import 'package:flutter/material.dart';

import '../theme/maestro_palette.dart';
import '../tokens/color_tokens.dart';
import '../tokens/spacing_tokens.dart';
import '../tokens/typography_tokens.dart';
import 'collasso.dart';

/// **DA DOVE NASCE: la porta unica dell'approfondimento.**
/// Ordine CQ voce 6.24, 4 settembre 2026.
///
/// **Il mood del Cerchio, dettato dal fondatore.** *"Io farei risposte e
/// responsi con grandi titoli diretti e un solo paragrafo diretto, ma
/// inserirei i dettagli in una sezione nascosta con un pulsante 'mostra di
/// piu'' o 'approfondisci' in modo da soddisfare gli utenti piu' interessati."*
/// E prima, il perche': *"l'utente non cerca informazioni, cerca risposte e
/// vuole essere guidato. non gliene frega niente di transiti, pianeti, ecc.
/// non dico di non scrivere da dove arrivano le risposte, ma non all'inizio."*
///
/// **Tre strati, e questo componente e' il terzo.** Il titolo che e' gia' una
/// risposta, il paragrafo che dice cosa significa e cosa fare, e qui sotto
/// tutto il resto: la fonte, il transito, la tradizione, il metodo.
///
/// **PERCHE' UN COMPONENTE SOLO E NON UNO PER ARTE.** Questa porta comparira'
/// in cinque Doni, nei Tarocchi, nelle Rune, nell'Oroscopo e nella Sinastria.
/// Scritta nove volte diventerebbe nove porte che divergono al primo
/// cambiamento, ed e' la famiglia di difetti che questo progetto insegue da
/// sempre: due conti della stessa cosa. Qui la parola, la misura, l'aria e il
/// verso della freccia stanno in un posto solo.
///
/// **La parola sul pulsante non e' "approfondisci".** Il fondatore ha proposto
/// quella o "mostra di piu'", e sono tutte e due parole di sistema: dicono
/// cosa fa il pulsante, non cosa trovi dietro. **"Da dove nasce" dice il
/// contenuto**, ed e' anche la promessa che questa app fa da sempre, cioe' che
/// nulla e' inventato. Chi cerca professionalita' riconosce quella riga; chi
/// cerca una risposta la scavalca senza inciampare.
class DaDoveNasce extends StatefulWidget {
  const DaDoveNasce({
    super.key,
    required this.palette,
    required this.children,
    this.etichetta = 'Da dove nasce',
  });

  final MaestroPalette palette;

  /// Cio' che sta dietro la porta. Vuoto, la porta non compare affatto: un
  /// pulsante che apre sul nulla e' peggio di nessun pulsante.
  final List<Widget> children;

  /// La riga del pulsante. **Si cambia solo con una ragione scritta**: nove
  /// arti che si aprono con nove parole diverse sono nove porte.
  final String etichetta;

  @override
  State<DaDoveNasce> createState() => _DaDoveNasceState();
}

class _DaDoveNasceState extends State<DaDoveNasce> {
  bool _aperto = false;

  @override
  Widget build(BuildContext context) {
    if (widget.children.isEmpty) return const SizedBox.shrink();
    final palette = widget.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: SpacingTokens.md),
        // **IL PULSANTE NON GRIDA.** Chi e' venuto per la risposta l'ha gia'
        // letta sopra: questa riga deve farsi trovare da chi la cerca, non
        // contendere l'occhio al responso.
        Semantics(
          button: true,
          expanded: _aperto,
          label: _aperto
              ? '${widget.etichetta}, aperto'
              : '${widget.etichetta}, chiuso',
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
            child: InkWell(
              key: const Key('da_dove_nasce_apri'),
              // **IL RITORNO DI SISTEMA RESTA SPENTO**, ordine CQ voce 1.08:
              // il click di Android non e' un suono che il fondatore ha
              // scelto, e ogni comando lo chiama di suo se non gli si dice
              // di no.
              enableFeedback: false,
              borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
              onTap: () => setState(() => _aperto = !_aperto),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: SpacingTokens.md, vertical: SpacingTokens.sm),
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(SpacingTokens.radiusPill),
                  border: Border.all(
                      color: palette.gold.withValues(alpha: 0.35)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.etichetta,
                      key: const Key('da_dove_nasce_etichetta'),
                      style: TypographyTokens.etichetta().copyWith(
                          color: palette.goldSoft, letterSpacing: 1.1),
                    ),
                    const SizedBox(width: SpacingTokens.xs),
                    // La freccia dice da sola cosa succede: giu' si apre,
                    // su si chiude. Nessuna delle due ha bisogno di parole.
                    AnimatedRotation(
                      turns: _aperto ? 0.5 : 0,
                      duration: const Duration(milliseconds: 180),
                      child: Icon(Icons.keyboard_arrow_down_rounded,
                          size: 18, color: palette.goldSoft),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Collassabile(
          aperto: _aperto,
          child: Padding(
            padding: const EdgeInsets.only(top: SpacingTokens.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.children,
            ),
          ),
        ),
      ],
    );
  }
}

/// Una riga di dietro la porta: la fonte, il transito, il metodo.
///
/// **Sta qui e non nelle schermate** per la stessa ragione della porta: nove
/// arti che vestono la propria fonte in nove modi sono nove modi che
/// divergono. La misura e' quella della prosa, perche' **anche dietro la porta
/// si legge**, e il fondatore ha chiesto tre volte di smettere di rimpicciolire
/// i testi.
class RigaDellaFonte extends StatelessWidget {
  const RigaDellaFonte({super.key, required this.testo, this.titolo});

  final String testo;

  /// Il cappello della riga, quando serve distinguere due fonti.
  final String? titolo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (titolo != null) ...[
            Text(titolo!,
                style: TypographyTokens.etichetta()
                    .copyWith(color: ColorTokens.textSecondary,
                        letterSpacing: 1.0)),
            const SizedBox(height: SpacingTokens.xxs),
          ],
          Text(testo,
              style: TypographyTokens.lettura()
                  .copyWith(color: ColorTokens.textSecondary)),
        ],
      ),
    );
  }
}
