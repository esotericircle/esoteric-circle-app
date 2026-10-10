/// IL CATALOGO DELLE STELLE DEL REAL TIME COSMO. Ordine FG parte 1.
///
/// **Da dove viene.** Dal catalogo HYG v4.1 di astronexus (Hipparcos, Yale,
/// Gliese), licenza CC BY-SA 4.0, tagliato alla magnitudine 6,0 e cotto in
/// `assets/astro/` dal generatore `tool/il_catalogo_delle_stelle_hyg.py`, che
/// lo rifa' identico al byte. Il file derivato porta accanto la sua licenza,
/// `assets/astro/LICENZA_HYG_v41.txt`; il codice dell'app non e' toccato dalla
/// licenza dei dati.
///
/// **IL DEBITO DEI DUE CATALOGHI, dichiarato.** Questo NON e' l'unico catalogo
/// di stelle vere dell'app: il Cielo esistente (`SkyOverviewScreen`) legge
/// `assets/data/bright_stars.json` attraverso `SkyCatalog`
/// (`lib/core/astro/sky.dart`), 106 stelle J2000 da Hipparcos, ESA 1997. I due
/// convivono finche' il fondatore non decide sulla sostituzione: se sostituisce
/// esce Hipparcos con le due rotte vecchie, se non sostituisce esce HYG. Non
/// esiste il terzo caso in cui restano tutti e due. Finche' convivono sono due
/// strade che non si incrociano: il Real Time Cosmo non legge
/// `bright_stars.json` e il Cielo esistente non legge questo file (guardia
/// `test/real_time_cosmo_i_due_cataloghi_non_si_incrociano_test.dart`).
///
/// **Il formato**, little endian. Intestazione di ventiquattro byte: firma
/// `ECHY`, versione (u16), riserva (u16), numero di stelle (u32), taglio in
/// centesimi di magnitudine (i16), riserva (i16), epoca come giorno giuliano
/// (f64, 2451545,0 cioe' J2000). Poi dodici byte per stella: ascensione retta
/// in millesimi di grado (u32), declinazione in millesimi di grado (i32),
/// magnitudine in centesimi (i16), indice di colore B-V in centesimi (i16, con
/// -32768 quando il catalogo non lo conosce). Le stelle sono in ordine di
/// magnitudine crescente: l'indice 0 e' la piu' luminosa, Sirio.
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart' show AssetBundle, rootBundle;

/// Le tre strade del catalogo nel pacchetto. Le dichiara il pubspec
/// (`assets/astro/`).
const String kCatalogoBinario = 'assets/astro/stelle_hyg_v41.bin';
const String kCatalogoNomi = 'assets/astro/stelle_hyg_v41_nomi.json';
const String kCatalogoCostellazioni =
    'assets/astro/stelle_hyg_v41_costellazioni.json';

/// Il catalogo letto: colonne parallele, una riga per stella.
///
/// Colonne e non oggetti, perche' il motore del cielo le scorre tutte a ogni
/// ricalcolo di posizione e cinquemila oggetti costano cinquemila salti in
/// memoria; le colonne tipizzate stanno contigue.
class CatalogoDelleStelle {
  CatalogoDelleStelle._({
    required this.raGradi,
    required this.decGradi,
    required this.magnitudine,
    required this.indiceDiColore,
    required this.taglioDiMagnitudine,
    required this.epocaJd,
    required this.nomi,
    required this.sigle,
    required this.costellazioni,
    required this.perHip,
  });

  static const String firma = 'ECHY';
  static const int versione = 1;
  static const int byteIntestazione = 24;
  static const int byteStella = 12;

  /// Il valore che nel binario dice "indice di colore sconosciuto".
  static const int ciAssente = -32768;

  final Float64List raGradi;
  final Float64List decGradi;
  final Float32List magnitudine;

  /// Indice di colore B-V; `NaN` quando il catalogo non lo conosce.
  final Float32List indiceDiColore;

  final double taglioDiMagnitudine;
  final double epocaJd;

  /// Il nome proprio, per le sole stelle che ce l'hanno: indice -> nome.
  final Map<int, String> nomi;

  /// La sigla di Bayer o di Flamsteed: indice -> "α Leo", "88 Aqr".
  final Map<int, String> sigle;

  /// La costellazione IAU (sigla di tre lettere) -> indici delle sue stelle,
  /// gia' in ordine di magnitudine crescente.
  final Map<String, List<int>> costellazioni;

  /// Il numero HIP -> l'indice nel binario, per le stelle che ce l'hanno.
  /// Ordine FH, fatto 1: le linee delle figure nominano le stelle per HIP, e
  /// la mappa la scrive lo stesso generatore del binario.
  final Map<int, int> perHip;

  int get numeroDiStelle => raGradi.length;

  /// La costellazione di una stella. Nulla se la stella non ne ha (nel
  /// catalogo cotto non succede: le 5.070 ce l'hanno tutte).
  String? costellazioneDi(int indice) => _costellazioneDi[indice];

  late final Map<int, String> _costellazioneDi = {
    for (final e in costellazioni.entries)
      for (final i in e.value) i: e.key,
  };

  /// Legge i byte del binario e i due file di testo. Una firma, una versione
  /// o una lunghezza diverse SOLLEVANO invece di indovinare: un catalogo letto
  /// storto disegnerebbe un cielo falso con l'aria di quello vero.
  factory CatalogoDelleStelle.daiByte(
    ByteData binario, {
    required String nomiJson,
    required String costellazioniJson,
  }) {
    if (binario.lengthInBytes < byteIntestazione) {
      throw FormatException(
          'Catalogo delle stelle troppo corto: ${binario.lengthInBytes} byte, '
          'ne servono almeno $byteIntestazione per l\'intestazione.');
    }
    final letta = String.fromCharCodes(
        [for (var i = 0; i < 4; i++) binario.getUint8(i)]);
    if (letta != firma) {
      throw FormatException(
          'Firma del catalogo delle stelle "$letta", attesa "$firma".');
    }
    final v = binario.getUint16(4, Endian.little);
    if (v != versione) {
      throw FormatException(
          'Versione del catalogo delle stelle $v, questo lettore conosce la '
          '$versione.');
    }
    final n = binario.getUint32(8, Endian.little);
    final attesi = byteIntestazione + n * byteStella;
    if (binario.lengthInBytes != attesi) {
      throw FormatException(
          'Il catalogo dichiara $n stelle, cioè $attesi byte, ma ne ha '
          '${binario.lengthInBytes}.');
    }
    final taglio = binario.getInt16(12, Endian.little) / 100.0;
    final epoca = binario.getFloat64(16, Endian.little);

    final ra = Float64List(n);
    final dec = Float64List(n);
    final mag = Float32List(n);
    final ci = Float32List(n);
    for (var i = 0; i < n; i++) {
      final o = byteIntestazione + i * byteStella;
      ra[i] = binario.getUint32(o, Endian.little) / 1000.0;
      dec[i] = binario.getInt32(o + 4, Endian.little) / 1000.0;
      mag[i] = binario.getInt16(o + 8, Endian.little) / 100.0;
      final c = binario.getInt16(o + 10, Endian.little);
      ci[i] = c == ciAssente ? double.nan : c / 100.0;
    }

    final datiNomi = json.decode(nomiJson) as Map<String, dynamic>;
    final datiCost = json.decode(costellazioniJson) as Map<String, dynamic>;
    for (final (nome, dati) in [('nomi', datiNomi), ('costellazioni', datiCost)]) {
      if (dati['stelle'] != n) {
        throw FormatException(
            'Il file dei $nome parla di ${dati['stelle']} stelle, il binario '
            'di $n: vengono da due cotture diverse.');
      }
    }
    final nomi = <int, String>{
      for (final e in datiNomi['nomi'] as List)
        (e as Map<String, dynamic>)['i'] as int: e['nome'] as String,
    };
    final sigle = <int, String>{
      for (final e in (datiCost['sigle'] as Map<String, dynamic>).entries)
        int.parse(e.key): e.value as String,
    };
    final costellazioni = <String, List<int>>{
      for (final e
          in (datiCost['costellazioni'] as Map<String, dynamic>).entries)
        e.key: List<int>.unmodifiable(
            (e.value as List).map((x) => x as int)),
    };

    final perHip = <int, int>{
      for (final e
          in ((datiCost['hip'] as Map<String, dynamic>?) ?? const {}).entries)
        int.parse(e.key): e.value as int,
    };

    return CatalogoDelleStelle._(
      raGradi: ra,
      decGradi: dec,
      magnitudine: mag,
      indiceDiColore: ci,
      taglioDiMagnitudine: taglio,
      epocaJd: epoca,
      nomi: Map.unmodifiable(nomi),
      sigle: Map.unmodifiable(sigle),
      costellazioni: Map.unmodifiable(costellazioni),
      perHip: Map.unmodifiable(perHip),
    );
  }

  static CatalogoDelleStelle? _inMemoria;

  /// Il catalogo dal pacchetto, letto una volta sola per processo.
  static Future<CatalogoDelleStelle> carica({AssetBundle? bundle}) async {
    final giaLetto = _inMemoria;
    if (giaLetto != null) return giaLetto;
    final b = bundle ?? rootBundle;
    final binario = await b.load(kCatalogoBinario);
    final nomi = await b.loadString(kCatalogoNomi);
    final cost = await b.loadString(kCatalogoCostellazioni);
    return _inMemoria = CatalogoDelleStelle.daiByte(binario,
        nomiJson: nomi, costellazioniJson: cost);
  }
}
