/// UN RESPONSO CUSTODITO. Ordine CG voce 06.
///
/// **Cosa si custodisce, e perche' non l'immagine.** Il TESTO del responso e i
/// dati che servono a ridisegnarlo, mai il PNG. La ragione e' il peso: un
/// testo con i suoi dati sta in qualche centinaio di byte, un PNG in qualche
/// centinaio di chilobyte, cioe' mille volte tanto. Una persona che custodisce
/// cento responsi in due anni occuperebbe trenta megabyte di immagini e ne
/// occupa trenta di kilobyte.
///
/// **Le due strade, e portano allo stesso magazzino.** Il gesto Custodisci
/// sotto il responso, e la custodia automatica quando una condivisione AVVIENE
/// davvero. Due magazzini per la stessa cosa sarebbero la famiglia di difetti
/// piu' numerosa di questo progetto, quindi ce n'e' uno.
///
/// **I custoditi NON SCADONO.** Le scadenze del server e del telefono non li
/// toccano: sono decine e non migliaia, quindi non pesano, e sono esattamente
/// cio' che la persona ha dichiarato di voler tenere. Una prova pretende che
/// nessuna scadenza li nomini.
library;

import 'dart:convert';

/// Da dove viene un custodito.
enum ComeENato {
  /// La persona ha toccato Custodisci.
  gesto('g'),

  /// La condivisione e' AVVENUTA, e condividere e' gia' la dichiarazione piu'
  /// forte che una persona possa fare su un contenuto.
  condivisione('c');

  const ComeENato(this.sigla);

  final String sigla;

  static ComeENato? dallaSigla(String s) {
    for (final c in ComeENato.values) {
      if (c.sigla == s) return c;
    }
    return null;
  }
}

/// Un responso tenuto per sempre.
class RicordoCustodito {
  RicordoCustodito({
    required this.quando,
    required this.arte,
    required this.maestro,
    required this.titolo,
    required this.testo,
    required this.comeENato,
    this.dati = const {},
  });

  final DateTime quando;

  /// L'arte o il Dono che ha prodotto il responso: la stessa parola che
  /// `ContiDelleArti` gia' usa, perche' due nomi per la stessa arte sarebbero
  /// due conteggi.
  final String arte;

  final String maestro;

  /// Il titolo del responso, quello che si legge nella griglia delle Carte.
  final String titolo;

  /// Il testo del responso, per intero.
  final String testo;

  /// **I DATI PER RIDISEGNARLO, e non l'immagine.** Le carte di una stesa, i
  /// nomi delle rune di una gettata, la percentuale di una sinastria: cio' che
  /// serve alla scena per rifare il disegno che c'era.
  final Map<String, String> dati;

  final ComeENato comeENato;

  /// IL TETTO DI PESO DI UN CUSTODITO, in byte, dichiarato dall'ordine.
  static const int pesoMassimo = 1000;

  /// L'IDENTITA' DI UN CUSTODITO, e serve a non tenerne due copie.
  ///
  /// **Il caso che la rende necessaria**: una persona custodisce un responso
  /// col gesto e poi lo condivide. Sono due strade verso lo stesso magazzino,
  /// e senza una chiave comune il responso finirebbe dentro due volte, cioe'
  /// due carte identiche nella griglia. La chiave nasce dal minuto e
  /// dall'arte, che e' cio' che identifica un responso: nello stesso minuto
  /// la stessa arte non produce due responsi diversi.
  String get chiave {
    final minuti = quando.millisecondsSinceEpoch ~/ 60000;
    return '$minuti.$arte';
  }

  Map<String, Object?> aMappa() => {
        'q': quando.millisecondsSinceEpoch ~/ 60000,
        'a': arte,
        'm': maestro,
        'i': titolo,
        's': testo,
        'n': comeENato.sigla,
        if (dati.isNotEmpty) 'd': dati,
      };

  static RicordoCustodito? daMappa(Object? grezzo) {
    if (grezzo is! Map) return null;
    final minuti = grezzo['q'];
    final arte = grezzo['a'];
    final maestro = grezzo['m'];
    final nato = ComeENato.dallaSigla('${grezzo['n']}');
    if (minuti is! int || arte is! String || maestro is! String) return null;
    if (nato == null) return null;
    final dati = grezzo['d'];
    return RicordoCustodito(
      quando: DateTime.fromMillisecondsSinceEpoch(minuti * 60000),
      arte: arte,
      maestro: maestro,
      titolo: '${grezzo['i'] ?? ''}',
      testo: '${grezzo['s'] ?? ''}',
      comeENato: nato,
      dati: dati is Map
          ? {for (final e in dati.entries) '${e.key}': '${e.value}'}
          : const {},
    );
  }

  /// Quanto pesa davvero, in byte della codifica UTF-8.
  int get peso => utf8.encode(jsonEncode(aMappa())).length;
}
