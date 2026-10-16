import 'dart:ui' show Color, Rect;

import '../entitlement/plan_catalog.dart';
import '../entitlement/tier.dart';
import 'tarot_card.dart';

/// **I MAZZI DEI TAROCCHI.** Il mazzo con cui si legge, dall'ordine FI voce 32
/// (la matrice dei piani) e dall'ordine FJ voci 9-12 (dove sta ogni mazzo).
///
/// Il Rider-Waite e' il predefinito: e' il mazzo su cui e' costruito tutto il
/// corpus, sta nel binario e funziona senza rete. Marsiglia e Thoth stanno sul
/// bucket dietro CDN e si scaricano solo quando la persona li sceglie
/// (`IMazziScaricati`); finche' non sono scaricati la stesa resta sul
/// Rider-Waite.
///
/// Ogni mazzo ha la sua cornice, e quindi le sue due targhe: i cartigli si
/// scrivono a runtime dentro quelle (le misure di Marsiglia e Thoth sono prese
/// sulle cornici con la finestra trasparente, `tar_mar_cornice_v3` e
/// `tar_tho_cornice_v1`, ordine FJ). E ha i suoi nomi e i suoi numeri di
/// tradizione: il Bagatto e la Casa di Dio nel Marsiglia, l'Aggiustamento e la
/// Lussuria nel Thoth.
enum TarotDeckStyle {
  riderWaite(
    'Rider-Waite',
    placcaNumero: Rect.fromLTRB(0.393, 0.031, 0.604, 0.069),
    placcaNome: Rect.fromLTRB(0.321, 0.918, 0.679, 0.966),
  ),
  marsiglia(
    'Marsiglia',
    riga: RigaDelPiano.mazzoDiMarsiglia,
    sulBucket: 'marsiglia',
    // Le due targhe di rame martellato, dentro la modanatura.
    placcaNumero: Rect.fromLTRB(0.331, 0.031, 0.668, 0.068),
    placcaNome: Rect.fromLTRB(0.173, 0.936, 0.829, 0.978),
    // Inciso scuro sul rame: l'oro del Maestro sul rame non si legge.
    coloreDelTesto: Color(0xFF1C0C06),
  ),
  thoth(
    'Thoth',
    riga: RigaDelPiano.mazzoThoth,
    sulBucket: 'thoth',
    // La targa d'ottone in alto e quella larga in basso.
    placcaNumero: Rect.fromLTRB(0.386, 0.057, 0.613, 0.122),
    placcaNome: Rect.fromLTRB(0.178, 0.829, 0.823, 0.900),
    coloreDelTesto: Color(0xFF2B1D0C),
  );

  const TarotDeckStyle(
    this.label, {
    this.riga,
    this.sulBucket,
    required this.placcaNumero,
    required this.placcaNome,
    this.coloreDelTesto,
  });

  final String label;

  /// La riga della matrice dei piani che lo apre (ordine FI voce 32).
  final RigaDelPiano? riga;

  /// Il nome del mazzo nel manifest del bucket; null per il mazzo nel binario.
  final String? sulBucket;

  /// Le due targhe della cornice, in frazioni della carta (853 per 1280).
  final Rect placcaNumero;
  final Rect placcaNome;

  /// Il colore dei cartigli; null vuol dire l'oro del Maestro sul blu.
  final Color? coloreDelTesto;

  /// Il mazzo della Demo e del corpus, sempre nel binario.
  static const TarotDeckStyle predefinito = TarotDeckStyle.riderWaite;

  /// Se sta nel binario, senza bisogno di scaricarlo.
  bool get nelBinario => sulBucket == null;

  /// Se si puo' scegliere. Dall'ordine FJ tutti e tre: due si scaricano.
  bool get available => true;

  /// Se questo piano puo' scegliere questo mazzo.
  bool apribileDa(Tier tier) {
    final r = riga;
    return r == null || PlanCatalog.apre(r, tier);
  }

  /// **IL POSTO DELLA CARTA NEL MAZZO NUOVO**, da 0 a 77, l'ordine dei file di
  /// Marsiglia e Thoth: i ventidue Maggiori col loro numero, poi Coppe,
  /// Denari, Spade e Bastoni, quattordici per seme (asso, da due a dieci,
  /// poi le quattro corti). La Forza e la Giustizia stanno all'ottavo e
  /// all'undicesimo posto al contrario del Rider-Waite: nel Marsiglia per
  /// tradizione, nel Thoth come Lussuria (XI) e Aggiustamento (VIII).
  static int postoDi(TarotCard c) {
    final maggiore = c.majorNumber;
    if (maggiore != null) {
      return switch (maggiore) { 8 => 11, 11 => 8, _ => maggiore };
    }
    const semi = [
      TarotSeme.coppe,
      TarotSeme.denari,
      TarotSeme.spade,
      TarotSeme.bastoni,
    ];
    return 22 + semi.indexOf(c.seme!) * 14 + (c.number! - 1);
  }

  /// Il nome della carta come lo scrive questo mazzo.
  String nomeDi(TarotCard c) {
    switch (this) {
      case TarotDeckStyle.riderWaite:
        return c.name;
      case TarotDeckStyle.marsiglia:
        final m = c.majorNumber;
        if (m != null) return _maggioriDiMarsiglia[m];
        return c.name;
      case TarotDeckStyle.thoth:
        final m = c.majorNumber;
        if (m != null) return _maggioriDelThoth[m];
        final seme =
            c.seme == TarotSeme.denari ? 'Dischi' : c.seme!.italianName;
        final corte = switch (c.number) {
          11 => 'Principessa',
          12 => 'Principe',
          13 => 'Regina',
          14 => 'Cavaliere',
          _ => null,
        };
        if (corte != null) return '$corte di $seme';
        return c.name.replaceAll('Denari', 'Dischi');
    }
  }

  /// Il numerale del cartiglio superiore come lo scrive questo mazzo. Nel
  /// Marsiglia alla maniera antica (IIII, VIIII), e il Matto senza numero.
  String numeraleDi(TarotCard c) {
    final m = c.majorNumber;
    if (m == null) return c.numeral;
    switch (this) {
      case TarotDeckStyle.riderWaite:
        return c.numeral;
      case TarotDeckStyle.marsiglia:
        return _numeriDiMarsiglia[m];
      case TarotDeckStyle.thoth:
        // L'Aggiustamento e' l'VIII e la Lussuria l'XI: il numero segue la
        // carta del Thoth, non il posto del Rider-Waite.
        return _romani[postoDi(c)];
    }
  }

  static const List<String> _romani = [
    '0', 'I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X', //
    'XI', 'XII', 'XIII', 'XIV', 'XV', 'XVI', 'XVII', 'XVIII', 'XIX', 'XX', 'XXI'
  ];

  /// Indicizzati col numero del Rider-Waite (la Forza all'8).
  static const List<String> _numeriDiMarsiglia = [
    '', 'I', 'II', 'III', 'IIII', 'V', 'VI', 'VII', 'XI', 'VIIII', 'X', //
    'VIII', 'XII', 'XIII', 'XIIII', 'XV', 'XVI', 'XVII', 'XVIII', 'XVIIII',
    'XX', 'XXI'
  ];

  /// Indicizzati col numero del Rider-Waite. L'arcano XIII nel Marsiglia non
  /// ha nome: la targa resta vuota per tradizione.
  static const List<String> _maggioriDiMarsiglia = [
    'Il Matto', 'Il Bagatto', 'La Papessa', 'L’Imperatrice', //
    'L’Imperatore', 'Il Papa', 'Gli Amanti', 'Il Carro', 'La Forza',
    'L’Eremita', 'La Ruota della Fortuna', 'La Giustizia', 'L’Appeso', '',
    'La Temperanza', 'Il Diavolo', 'La Casa di Dio', 'La Stella', 'La Luna',
    'Il Sole', 'Il Giudizio', 'Il Mondo'
  ];

  /// Indicizzati col numero del Rider-Waite (la Forza all'8 e' la Lussuria).
  static const List<String> _maggioriDelThoth = [
    'Il Matto', 'Il Mago', 'La Sacerdotessa', 'L’Imperatrice', //
    'L’Imperatore', 'Il Ierofante', 'Gli Amanti', 'Il Carro', 'La Lussuria',
    'L’Eremita', 'La Fortuna', 'L’Aggiustamento', 'L’Appeso', 'La Morte',
    'L’Arte', 'Il Diavolo', 'La Torre', 'La Stella', 'La Luna', 'Il Sole',
    'L’Eone', 'L’Universo'
  ];
}
