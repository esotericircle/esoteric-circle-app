import 'dart:ui' show Color;

import '../astro/night_sky.dart';
import '../astro/zodiac.dart';
import 'birth_identity.dart';
import 'numerology.dart';

/// Gli elementi dello zodiaco, con il loro colore.
enum SealElement {
  fuoco(Color(0xFFD9563B)),
  terra(Color(0xFF3FA07A)),
  aria(Color(0xFFE8C463)),
  acqua(Color(0xFF3B6EA5));

  const SealElement(this.color);
  final Color color;

  String get label {
    switch (this) {
      case SealElement.fuoco:
        return 'Fuoco';
      case SealElement.terra:
        return 'Terra';
      case SealElement.aria:
        return 'Aria';
      case SealElement.acqua:
        return 'Acqua';
    }
  }

  /// Una riga sulla natura dell'elemento, per il pannello "Cosa significa".
  String get meaning {
    switch (this) {
      case SealElement.fuoco:
        return 'La tua natura è slancio e calore: agisci, accendi, apri strade.';
      case SealElement.terra:
        return 'La tua natura è radice e concretezza: costruisci, curi, dai basi.';
      case SealElement.aria:
        return 'La tua natura è pensiero e movimento: colleghi, comunichi, respiri.';
      case SealElement.acqua:
        return 'La tua natura è sentire e profondità: intuisci, accogli, trasformi.';
    }
  }

  static SealElement of(Zodiac sign) {
    switch (sign) {
      case Zodiac.aries:
      case Zodiac.leo:
      case Zodiac.sagittarius:
        return SealElement.fuoco;
      case Zodiac.taurus:
      case Zodiac.virgo:
      case Zodiac.capricorn:
        return SealElement.terra;
      case Zodiac.gemini:
      case Zodiac.libra:
      case Zodiac.aquarius:
        return SealElement.aria;
      case Zodiac.cancer:
      case Zodiac.scorpio:
      case Zodiac.pisces:
        return SealElement.acqua;
    }
  }
}

/// Il Sigillo del Cerchio: un emblema personale deterministico dai dati di
/// nascita. Nasce dal segno solare, dal Numero della vita e dal colore
/// dell'elemento. Deterministico, quindi a costo zero: lo stesso dato genera
/// sempre lo stesso sigillo. Il disegno e' procedurale, base sostituibile con
/// l'arte definitiva.
class CircleSeal {
  const CircleSeal({
    required this.name,
    required this.sign,
    required this.lifePath,
    required this.element,
  });

  /// Il nome dell'utente, inciso sul sigillo.
  final String name;
  final Zodiac sign;

  /// Il Numero della vita, da 1 a 9 oppure un maestro 11, 22, 33.
  final int lifePath;
  final SealElement element;

  Color get color => element.color;

  factory CircleSeal.from({required String name, required BirthIdentity identity}) {
    final sign = NightSky.sunSign(identity.birthMoment);
    return CircleSeal(
      name: name,
      sign: sign,
      lifePath: LifePath.forDate(identity.birthMoment).number,
      element: SealElement.of(sign),
    );
  }
}
