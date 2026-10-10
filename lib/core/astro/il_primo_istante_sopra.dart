/// IL PRIMO ISTANTE SOPRA L'ORIZZONTE, la regola del "quando sorge" in un
/// posto solo. Ordine FH voce 7.4.
///
/// La regola e' quella del Cielo esistente (`quandoSorge` in `sky.dart`, che
/// adesso chiama questa funzione): si cerca nelle ventiquattro ore dopo [da]
/// a passi di dieci minuti, poi si affina al minuto dentro l'intervallo
/// trovato; e' un attraversamento di orizzonte, non un'effemeride, e dieci
/// minuti non lo mancano mai. Torna [da] se il corpo e' gia' sopra, e nullo
/// se non sorge affatto nelle ventiquattro ore (alle nostre latitudini: mai
/// visibile). Il Real Time Cosmo la usa coi suoi bersagli, il Cielo esistente
/// col suo catalogo: la regola e' una, le domande ("e' sopra adesso?") sono
/// di chi chiama.
library;

DateTime? primoIstanteSopra(bool Function(DateTime) sopra, DateTime da) {
  if (sopra(da)) return da;
  var precedente = da;
  for (var m = 10; m <= 24 * 60; m += 10) {
    final t = da.add(Duration(minutes: m));
    if (!sopra(t)) {
      precedente = t;
      continue;
    }
    for (var k = 1; k <= 10; k++) {
      final f = precedente.add(Duration(minutes: k));
      if (sopra(f)) return f;
    }
    return t;
  }
  return null;
}
