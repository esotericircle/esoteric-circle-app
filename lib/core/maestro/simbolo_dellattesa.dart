import '../archetypes/archetype.dart';
import '../../design_system/components/zodiac_glyph.dart';
import '../astro/zodiac.dart';
import '../rituals/guide_animal_derivation.dart';
import 'maestro.dart';
import 'natal_context.dart';

/// QUALE SIMBOLO GUARDA OGNI MAESTRO MENTRE ASPETTA, e da quale dato nasce.
///
/// **Cosa c'era, e perche' e' cambiato.** Nella scena dell'attesa si accendeva
/// il VOLTO del Maestro. Era una lettura sbagliata di cio' che il fondatore
/// aveva chiesto: diceva "emblema" e intendeva un SIMBOLO, cioe' una cosa di
/// questa persona, non il ritratto di chi le sta rispondendo. Il volto del
/// Maestro sta gia' nell'intestazione della chat e accanto a ogni sua bolla:
/// ripeterlo grande al centro dello schermo non aggiungeva niente.
///
/// **Il simbolo e' della persona, e il Maestro ne guarda uno suo.**
/// - Medora guarda il SEGNO ZODIACALE.
/// - Caligo guarda l'ANIMALE GUIDA, che dal segno si deriva.
/// - Aura guarda l'EMBLEMA DELL'ARCHETIPO.
///
/// **IL FIORE DI LOTO, e perche' adesso c'e'.** Quando l'archetipo non e'
/// ancora stato scoperto, Aura mostra un loto dorato **disegnato in codice**,
/// piu' la riga che invita al Test. Come asset non esiste, verificato di nuovo
/// il 6 agosto 2026: nessun file con "lot", "loto" o "lotus" in `assets/` ne'
/// in `brand_assets/`, e niente nel `pubspec.yaml`. Percio' e' un disegno
/// vettoriale, non un'immagine.
///
/// **La regola di prima diceva il contrario, ed era giusta per gli emblemi.**
/// Diceva che gli emblemi di archetipo sono dodici e che mostrarne uno a chi
/// non ha fatto il Test sarebbe dichiarargli un archetipo che non ha. Resta
/// vero, e nessuno dei dodici compare qui.
///
/// **Il loto regge perche' NON E' UNO DEI DODICI.** Non e' un archetipo
/// travestito da attesa: e' il fiore che aspetta di aprirsi, quindi non
/// dichiara alla persona nessun archetipo, ne' vero ne' falso. Dice che c'e'
/// qualcosa che deve ancora nascere, che e' esattamente cio' che sta
/// succedendo. Resta invece vietato mettere al posto suo il segno zodiacale o
/// un cristallo, che sarebbe il simbolo di un altro Maestro sotto il nome di
/// Aura.
///
/// Il loto viaggia come [loto], non come [asset], **proprio perche' non e' un
/// file**: chi lo disegna e' il design system, che e' l'unico posto che sa
/// dipingere.
class SimboloDellAttesa {
  const SimboloDellAttesa({this.asset, this.invito, this.loto = false});

  /// Il file da comporre. Nullo quando per questa persona, con questo Maestro,
  /// non esiste ancora un simbolo vero.
  final String? asset;

  /// La riga breve sotto il simbolo, quando c'e' qualcosa da invitare a fare.
  /// Nulla nel caso normale: un invito che compare sempre non e' un invito.
  final String? invito;

  /// IL LOTO CHE ASPETTA DI APRIRSI, disegnato in codice e non caricato.
  ///
  /// Vero solo per Aura, e solo finche' il Test non e' stato fatto. Non e' un
  /// asset: il disegno vive nel design system, che e' l'unico posto che sa
  /// dipingere. Qui si dice CHE COSA mostrare, non come.
  final bool loto;

  bool get ceQualcosa => asset != null || invito != null || loto;

  /// La riga che invita a scoprire il proprio archetipo. Vive qui, che e'
  /// l'unico punto che sa perche' il simbolo di Aura manca.
  static const String invitoAlTest =
      'Fai il Test Archetipo e Aura avrà il tuo simbolo.';

  /// Il simbolo per questo Maestro e questa persona.
  ///
  /// [archetipo] arriva dallo storico del Test: nullo vuol dire "non ancora
  /// scoperto", e non "non ne ha uno".
  static SimboloDellAttesa per(
    Maestro maestro, {
    required NatalContext natal,
    Archetype? archetipo,
  }) {
    final segno = _segnoDi(natal);
    switch (maestro) {
      case Maestro.medora:
        return SimboloDellAttesa(
          asset: segno == null ? null : ZodiacArt.symbolPath(segno),
        );
      case Maestro.caligo:
        if (segno == null) return const SimboloDellAttesa();
        final animale = GuideAnimalDerivation.forSign(segno);
        return SimboloDellAttesa(
          asset: 'assets/img_thumb/animali/${animale.stem}.webp',
        );
      case Maestro.aura:
        if (archetipo != null) {
          return SimboloDellAttesa(asset: archetipo.arteThumb);
        }
        // Il loto piu' l'invito, non l'invito da solo: un vuoto con una riga
        // sotto sembra un guasto, un fiore chiuso con una riga sotto sembra
        // quello che e', cioe' qualcosa che deve ancora aprirsi.
        return const SimboloDellAttesa(loto: true, invito: invitoAlTest);
    }
  }

  /// Il segno solare di questa persona, dal nome italiano che il contesto
  /// natale porta. Nullo quando il cielo non e' ancora arrivato.
  static Zodiac? _segnoDi(NatalContext natal) {
    final nome = natal.sunSign?.trim();
    if (nome == null || nome.isEmpty) return null;
    for (final z in Zodiac.values) {
      if (z.italianName.toLowerCase() == nome.toLowerCase()) return z;
    }
    return null;
  }
}
