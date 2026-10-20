import 'package:flutter/material.dart';

import '../../core/responsi/la_forma_del_responso.dart';
import '../theme/maestro_palette.dart';
import '../theme/maestro_scope.dart';
import '../tokens/color_tokens.dart';
import '../tokens/spacing_tokens.dart';
import '../tokens/typography_tokens.dart';
import 'riquadro_arancione.dart';
import 'riquadro_in_evidenza.dart';
import 'titolo_del_responso.dart';

/// **IL RESPONSO INTERPRETATO, la forma di GA.03 in un punto solo.** Ordine
/// GA, 20 ottobre 2026. La regola e le parole del fondatore stanno in
/// `lib/core/responsi/la_forma_del_responso.dart`.
///
/// Dall'alto: il titolo (da [TitoloDelResponso], che e' gia' la risposta);
/// il paragrafo della risposta; il riquadro dorato "Cosa fare adesso"; nella
/// Lunga il paragrafo che approfondisce e il riquadro arancione del rito
/// propiziatorio col titolo dell'arte (l'arancio e' il colore di cio' che
/// solo la Lunga aggiunge, ordine FN); in fondo il "Da dove viene" in
/// corsivo. Le quattro arti (Oroscopo, Stesa di Tarocchi, Oracolo degli
/// Angeli, Rune) disegnano qui il responso principale e le singole carte o
/// rune: nessuna ricompone i riquadri a mano.
///
/// [chiave] fa da prefisso alle chiavi dei pezzi, cosi' una schermata con piu'
/// responsi (le carte di una stesa e il responso principale) le tiene
/// distinte: `<chiave>_titolo`, `<chiave>_risposta`, `<chiave>_cosa_fare`,
/// `<chiave>_approfondimento`, `<chiave>_rito`, `<chiave>_da_dove_viene`.
class IlResponsoInterpretato extends StatelessWidget {
  const IlResponsoInterpretato({
    super.key,
    required this.responso,
    required this.stileDelTitolo,
    required this.stile,
    this.palette,
    this.chiave = 'responso',
    this.allineamentoDelTitolo = TextAlign.start,
    this.mostraIlTitolo = true,
    this.paragrafo,
    this.paragrafiVisibili,
    this.distanza,
  });

  final ResponsoInterpretato responso;
  final TextStyle stileDelTitolo;
  final TextStyle stile;
  final MaestroPalette? palette;
  final String chiave;
  final TextAlign allineamentoDelTitolo;

  /// Falso solo dove il titolo sta gia' sopra, nella testata dell'arte, e
  /// passa comunque da [TitoloDelResponso].
  final bool mostraIlTitolo;

  /// **COME SI DIPINGE IL TESTO DI UN PARAGRAFO**, per l'arte che lo scrive
  /// lettera per lettera (l'Oroscopo, ordine A). La forma resta qui: quali
  /// paragrafi, in che ordine, in quale riquadro e con quale titolo; l'arte
  /// decide solo come compare il testo. [indice] conta i paragrafi da zero
  /// nell'ordine di [ResponsoInterpretato.paragrafi]. Senza, un `Text`.
  final Widget Function(int indice, String testo, TextStyle stile)? paragrafo;

  /// Quanti paragrafi si vedono, mentre si scrivono uno dopo l'altro: quelli
  /// dopo non stanno in albero, e nemmeno i loro riquadri. Senza, tutti.
  final int? paragrafiVisibili;

  /// La distanza fra i pezzi; senza, una volta e un quinto la misura del
  /// testo.
  final double? distanza;

  @override
  Widget build(BuildContext context) {
    final p = palette ?? MaestroScope.forse(context) ?? MaestroPalette.neutral;
    final distanza =
        this.distanza ?? (stile.fontSize ?? TypographyTokens.pavimento) * 1.2;
    final visibili = paragrafiVisibili ?? responso.paragrafi.length;
    Widget testo(int indice, String t, String nome) => KeyedSubtree(
          key: Key('${chiave}_$nome'),
          child: paragrafo?.call(indice, t, stile) ?? Text(t, style: stile),
        );
    final etichetta = TypographyTokens.etichetta()
        .copyWith(color: p.gold, letterSpacing: 1.1);
    Widget riquadro(String titolo, Widget corpo, String nome,
        {required bool arancione}) {
      final colonna = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titolo,
              key: Key('${chiave}_titolo_$nome'),
              style: arancione
                  ? etichetta.copyWith(color: ColorTokens.arancioDellaCarta)
                  : etichetta),
          const SizedBox(height: SpacingTokens.xs),
          corpo,
        ],
      );
      return arancione
          ? RiquadroArancione(child: colonna)
          : RiquadroInEvidenza(palette: p, child: colonna);
    }

    // I pezzi nell'ordine di [ResponsoInterpretato.paragrafi]: l'indice del
    // paragrafo e' quello che riceve [paragrafo].
    final pezzi = <Widget>[];
    var indice = 0;
    void aggiungi(Widget w) {
      if (pezzi.isNotEmpty) pezzi.add(SizedBox(height: distanza));
      pezzi.add(w);
    }

    if (indice < visibili) {
      aggiungi(testo(indice, responso.risposta, 'risposta'));
    }
    indice++;
    if (indice < visibili) {
      aggiungi(riquadro(LaFormaDelResponso.titoloDelConsiglio,
          testo(indice, responso.cosaFare, 'cosa_fare'), 'cosa_fare',
          arancione: false));
    }
    indice++;
    if (responso.approfondimento != null) {
      if (indice < visibili) {
        aggiungi(testo(indice, responso.approfondimento!, 'approfondimento'));
      }
      indice++;
    }
    if (responso.rito != null) {
      if (indice < visibili) {
        aggiungi(riquadro(LaFormaDelResponso.titoloDelRito(responso.arte),
            testo(indice, responso.rito!, 'rito'), 'rito',
            arancione: true));
      }
      indice++;
    }
    final fonte = responso.daDoveViene;
    // Il "Da dove viene" arriva quando il responso e' intero.
    if (visibili >= indice && fonte != null && fonte.trim().isNotEmpty) {
      aggiungi(Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(LaFormaDelResponso.etichettaDellaFonte,
              style: TypographyTokens.etichetta().copyWith(
                  color: ColorTokens.textSecondary, letterSpacing: 1.2)),
          const SizedBox(height: SpacingTokens.xxs),
          Text(fonte,
              key: Key('${chiave}_da_dove_viene'),
              style: TypographyTokens.didascalia().copyWith(
                  color: ColorTokens.textSecondary,
                  height: 1.35,
                  fontStyle: FontStyle.italic)),
        ],
      ));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (mostraIlTitolo) ...[
          TitoloDelResponso(
            testo: responso.titolo,
            stile: stileDelTitolo,
            allineamento: allineamentoDelTitolo,
            chiaveDelTesto: Key('${chiave}_titolo'),
          ),
          SizedBox(height: distanza),
        ],
        ...pezzi,
      ],
    );
  }
}
