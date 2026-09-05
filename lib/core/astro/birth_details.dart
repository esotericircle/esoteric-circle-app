import 'package:flutter/material.dart';

import 'birth_place.dart';

/// Genere, opzionale e non discriminante.
enum Gender {
  female('Femmina'),
  male('Maschio'),
  nonBinary('Non binario'),
  unspecified('Preferisco non dirlo');

  const Gender(this.label);
  final String label;
}

/// I dati raccolti dall'onboarding Il Risveglio.
///
/// Solo la data e' obbligatoria; l'ora, il luogo e il genere sono opzionali.
/// Nessun dato di contatto: la registrazione e' progressiva e anonima, il
/// telefono non entra mai nel form.
///
/// Il luogo e' nullo quando la persona lo salta, e nullo deve restare. Prima
/// veniva fabbricato un ripiego a latitudine zero, longitudine zero e fuso UTC,
/// cioe' un punto in mezzo al Golfo di Guinea, e la carta natale veniva chiesta
/// per quel punto: Ascendente e dodici case che ne uscivano erano di un altro
/// luogo, mentre la schermata prometteva il cielo autentico della propria
/// notte. Senza luogo quei valori non sono calcolabili, e lo si dichiara.
@immutable
class BirthDetails {
  const BirthDetails({
    required this.date,
    this.place,
    this.time,
    this.gender,
  });

  final DateTime date;
  final BirthPlace? place;
  final TimeOfDay? time;
  final Gender? gender;

  bool get hasTime => time != null;

  /// Vero se il luogo c'e': solo allora Ascendente e case hanno un senso.
  bool get hasPlace => place != null;

  /// DateTime combinato di data e ora (mezzogiorno se l'ora manca, scelta
  /// neutra per il calcolo del solo Sole).
  DateTime get dateTime => DateTime(
        date.year,
        date.month,
        date.day,
        time?.hour ?? 12,
        time?.minute ?? 0,
      );
}
