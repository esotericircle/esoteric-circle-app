// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

import 'package:esoteric_circle/core/horoscope/horoscope.dart';
import 'package:esoteric_circle/core/horoscope/l_annuale.dart';
import 'package:esoteric_circle/core/horoscope/la_rivoluzione_solare.dart';
import 'package:esoteric_circle/features/horoscope/il_pdf_dell_anno.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **IL PDF DELL'ANNO SI LEGGE.** Ordine EU voce 12, 1 ottobre 2026.
///
/// Il fondatore: *"Oroscopo annuale va bene, ma il PDF alla fine mostra una
/// ripetizione "del tuo lavoro"."* Nella sua cattura il PDF e' aperto nella
/// Modalita' Liquida di Acrobat, che ricompone il foglio per lo schermo: in
/// fondo ricompaiono i titoli delle schede gia' lette, senza testo, e
/// accanto a "Il lavoro nel tuo anno" la freccia dell'indice.
///
/// Qui si costruiscono i PDF veri, con la stessa porta che usa l'app, per
/// dodici nascite, e se ne legge il testo **pagina per pagina** dai flussi
/// del file. Si contano tre cose: i titoli che compaiono piu' di una volta,
/// le schede spezzate fra due pagine (l'etichetta, il titolo, l'inizio del
/// testo e l'inizio di "Da dove viene" non stanno sulla stessa pagina) e le
/// pagine che finiscono con un'etichetta o un titolo, cioe' un titolo senza
/// testo sotto. Tutte e tre devono essere zero. Vista rossa col foglio di
/// prima, le righe della scheda figlie dirette della pagina: in due PDF su
/// tre l'etichetta "FORTUNA" restava sola in fondo alla prima pagina.
///
/// Tre PDF si scrivono in `docs/collaudo/EU/pdf/`, e `tool/il_testo_dei_pdf.py`
/// ne estrae il testo.
void main() {
  test(
      'ogni scheda del PDF dell\'anno compare una volta, intera, su una '
      'pagina sola', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final cartella = Directory('docs/collaudo/EU/pdf')
      ..createSync(recursive: true);
    final copertina = File(IlPdfDellAnno.emblema).readAsBytesSync();
    final difetti = <String>[];
    var documenti = 0, schedeViste = 0;
    for (var i = 0; i < 12; i++) {
      final nascita = DateTime.utc(1960 + i * 3, 1 + i, 3 + i * 2, i * 2, 10);
      final ritorno =
          LaRivoluzioneSolare.ritornoInCorso(nascita, DateTime(2026, 10, 1));
      final tema = LaRivoluzioneSolare.tema(ritorno, 41.9, 12.5);
      final schede = LAnnuale.schede(tema);
      // Il titolo e il sottotitolo come li scrive l'app.
      final byte = await IlPdfDellAnno.documento(schede,
          titolo: 'Il tuo anno dal ${ritorno.day} ottobre 2026',
          sottotitolo: 'Rivoluzione Solare del ${ritorno.day} ottobre 2026 '
              'alle 06:30, per Roma',
          copertina: copertina);
      if (i < 3) {
        File('${cartella.path}/anno_esempio_${i + 1}.pdf')
            .writeAsBytesSync(byte);
      }
      documenti++;
      final pagine = _testoDellePagine(byte);
      // **UNA PAGINA SOLA**: su due pagine A4 la Modalita' Liquida di
      // Acrobat ripete in fondo i titoli della prima, senza testo (visto
      // sul Realme, `IlFoglioDellAnno.foglio`).
      if (pagine.length != 1) {
        difetti.add('PDF ${i + 1}: ${pagine.length} pagine invece di una');
      }
      schedeViste += schede.length;
      difetti.addAll(_difetti('PDF ${i + 1}', schede, pagine));
    }
    cardinaleMinimo(documenti, 12, cosa: 'PDF dell\'anno costruiti');
    cardinaleMinimo(schedeViste, 48, cosa: 'schede lette nei PDF');
    print('ORDINE EU VOCE 12: $documenti PDF, $schedeViste schede, difetti '
        '${difetti.length}');
    expect(difetti, isEmpty, reason: difetti.join('\n'));
  });
}

String _piano(String s) => s.replaceAll(RegExp(r'\s+'), ' ').trim();

String _inizio(String s, [int n = 40]) {
  final p = _piano(s);
  return p.length <= n ? p : p.substring(0, n);
}

List<String> _difetti(
    String doc, List<HoroscopeCard> schede, List<List<String>> pagine) {
  final fuori = <String>[];
  final etichette = {for (final s in schede) s.domain.label.toUpperCase()};
  final titoli = {for (final s in schede) _piano(s.title)};
  for (final s in schede) {
    final titolo = _piano(s.title);
    final dove = <int>[];
    for (var p = 0; p < pagine.length; p++) {
      for (final riga in pagine[p]) {
        if (riga == titolo) dove.add(p);
      }
    }
    if (dove.length != 1) {
      fuori.add('$doc: il titolo "$titolo" compare ${dove.length} volte');
      continue;
    }
    final pagina = pagine[dove.single];
    final testo = _piano(pagina.join(' '));
    final parti = <String, String>{
      'l\'etichetta': s.domain.label.toUpperCase(),
      'l\'inizio del testo': _inizio(s.text),
      if (s.rigaDelLivello != null)
        'l\'inizio di "Da dove viene"': _inizio(s.rigaDelLivello!),
    };
    for (final parte in parti.entries) {
      if (!testo.contains(parte.value)) {
        fuori.add('$doc: la scheda "$titolo" e\' spezzata, ${parte.key} non '
            'sta sulla sua pagina (${dove.single + 1})');
      }
    }
  }
  for (var p = 0; p < pagine.length; p++) {
    final righe = pagine[p];
    if (righe.isEmpty) continue;
    final ultima = righe.last;
    if (etichette.contains(ultima) || titoli.contains(ultima)) {
      fuori.add('$doc: la pagina ${p + 1} finisce con "$ultima", senza '
          'testo sotto');
    }
  }
  return fuori;
}

/// Il testo di ogni pagina del PDF, riga per riga, letto dai flussi del file
/// nell'ordine delle pagine. Il foglio scrive ogni parola a parte, con la
/// sua posizione: le parole alla stessa altezza fanno una riga.
List<List<String>> _testoDellePagine(List<int> byte) {
  final pdf = latin1.decode(byte);
  int oggetto(int n) => pdf.indexOf('\n$n 0 obj');
  final kids = RegExp(r'/Type/Pages/Kids\[([^\]]*)\]').firstMatch(pdf)!;
  final pagine = RegExp(r'(\d+) 0 R')
      .allMatches(kids.group(1)!)
      .map((m) => int.parse(m.group(1)!))
      .toList();
  final fuori = <List<String>>[];
  for (final n in pagine) {
    final inizio = oggetto(n);
    final fine = pdf.indexOf('endobj', inizio);
    final contenuti =
        RegExp(r'/Contents (\d+) 0 R').firstMatch(pdf.substring(inizio, fine))!;
    final o = oggetto(int.parse(contenuti.group(1)!));
    final s = pdf.indexOf('stream', o) + 'stream'.length;
    final daqui = pdf[s] == '\r' ? s + 2 : s + 1;
    final finoA = pdf.indexOf('endstream', daqui);
    final flusso = latin1.decode(
        zlib.decode(latin1.encode(pdf.substring(daqui, finoA))),
        allowInvalid: true);
    // Le posizioni sono relative allo spostamento corrente (`cm`), che si
    // salva e si ripristina con `q` e `Q`: un blocco intero della pagina
    // scrive le sue righe dentro uno spostamento suo.
    final righe = <String, List<String>>{};
    final ordine = <String>[];
    final pila = <double>[];
    var dy = 0.0;
    const c = r'(-?[\d.]+)';
    for (final m in RegExp('(?:^|\\s)(q|Q)(?=\\s)|$c $c $c $c $c $c cm'
            '|$c $c Td \\[\\(((?:\\\\.|[^\\\\)])*)\\)\\]TJ')
        .allMatches(flusso)) {
      if (m.group(1) == 'q') {
        pila.add(dy);
      } else if (m.group(1) == 'Q') {
        dy = pila.removeLast();
      } else if (m.group(7) != null) {
        dy += double.parse(m.group(7)!);
      } else {
        final y = (dy + double.parse(m.group(9)!)).toStringAsFixed(1);
        if (!righe.containsKey(y)) ordine.add(y);
        righe.putIfAbsent(y, () => []).add(_parola(m.group(10)!));
      }
    }
    fuori.add([for (final y in ordine) righe[y]!.join(' ')]);
  }
  return fuori;
}

/// Una stringa del PDF: le barre rovesce proteggono le parentesi e le altre
/// barre, e un ottale di tre cifre e' un carattere fuori dall'ASCII.
String _parola(String s) => s.replaceAllMapped(
    RegExp(r'\\([0-7]{3}|.)'),
    (m) => m.group(1)!.length == 3
        ? String.fromCharCode(int.parse(m.group(1)!, radix: 8))
        : m.group(1)!);
