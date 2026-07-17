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
/// La data e il luogo sono obbligatori; l'ora e il genere sono opzionali.
/// Nessun dato di contatto: la registrazione e' progressiva e anonima, il
/// telefono non entra mai nel form.
@immutable
class BirthDetails {
  const BirthDetails({
    required this.date,
    required this.place,
    this.time,
    this.gender,
  });

  final DateTime date;
  final BirthPlace place;
  final TimeOfDay? time;
  final Gender? gender;

  bool get hasTime => time != null;

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
