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
/// **IL FIORE DI LOTO NON ESISTE.** L'ordine chiedeva che Aura, quando
/// l'archetipo non e' ancora stato scoperto, mostrasse un fiore di loto con
/// una riga che invita al Test Archetipo. Cercato in tutte le cartelle degli
/// asset il 4 agosto 2026: non c'e', in nessuna forma. E non c'e' nemmeno un
/// altro simbolo del dominio di Aura, che e' Chakra, Energia, Archetipi:
/// esistono dodici emblemi di archetipo, ma dirne uno a chi non ha fatto il
/// test sarebbe dichiarargli un archetipo che non ha. Mettere al posto suo il
/// segno zodiacale o un cristallo vorrebbe dire mostrare il simbolo di un
/// altro Maestro sotto il nome di Aura.
///
/// Quindi in quel caso il simbolo NON C'E', e resta l'invito: la scena dice
/// che manca qualcosa e come farla nascere, invece di far finta che ci sia.
class SimboloDellAttesa {
  const SimboloDellAttesa({this.asset, this.invito});

  /// Il file da comporre. Nullo quando per questa persona, con questo Maestro,
  /// non esiste ancora un simbolo vero.
  final String? asset;

  /// La riga breve sotto il simbolo, quando c'e' qualcosa da invitare a fare.
  /// Nulla nel caso normale: un invito che compare sempre non e' un invito.
  final String? invito;

  bool get ceQualcosa => asset != null || invito != null;

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
        return const SimboloDellAttesa(invito: invitoAlTest);
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
