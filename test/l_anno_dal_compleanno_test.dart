// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/astro/meeus/il_cielo_di_meeus.dart';
import 'dart:io';

import 'package:esoteric_circle/core/entitlement/listino_degli_eos.dart';
import 'package:esoteric_circle/core/horoscope/horoscope.dart';
import 'package:esoteric_circle/core/horoscope/l_annuale.dart';
import 'package:esoteric_circle/core/horoscope/la_rivoluzione_solare.dart';
import 'package:esoteric_circle/core/horoscope/le_parti_del_responso.dart';
import 'package:esoteric_circle/core/horoscope/oroscopo_annuale_data.dart';
import 'package:esoteric_circle/features/horoscope/il_pdf_dell_anno.dart';
import 'package:esoteric_circle/core/horoscope/i_testi_eu.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **L'ANNO DAL COMPLEANNO. Ordine ES voce 04, 29 settembre 2026.**
///
/// Il fondatore approva l'annuale dell'Architetto: "Rivoluzione Solare dal
/// compleanno, notifica e card, dall'Adepto in su, 300 Eos, PDF
/// all'Illuminato", "Per il resto approvo tutto". Qui si pretende:
/// - ogni scheda dice la frase del suo caso (segno dell'Ascendente, casa del
///   Sole, della Luna, di Venere, di Saturno, di Giove, segno del Medio
///   Cielo), dal tema calcolato;
/// - il livello dalla regola dell'angolarita' scritta nella prova;
/// - due anni di fila con lo stesso caso leggono frasi diverse;
/// - 300 Eos nel listino; il corpus uguale al codice.
void main() {
  // Dieci nascite, ognuna con dieci anni di Rivoluzioni: cento temi veri.
  final nascite = [
    for (var i = 0; i < 10; i++)
      DateTime.utc(1960 + i * 5, 1 + i, 3 + i * 2, 6 + i, 15),
  ];
  const lat = 41.9;
  const lon = 12.5;

  // Dal 30 settembre 2026 ogni frase del corpus ha due parti, "TESTO || DA
  // DOVE VIENE": il testo va nella lettura, il da dove viene nella riga sotto
  // ([LePartiDelResponso]).
  RegExp daDove(List<String> v) => RegExp(
      v.map((f) => RegExp.escape(LePartiDelResponso.di(f).$2)).join('|'));

  test('ogni scheda dice la frase del suo caso, col livello della regola', () {
    var temi = 0;
    final fuori = <String>[];
    for (final n in nascite) {
      final sole = LaRivoluzioneSolare.soleNatale(n);
      for (var anno = 2021; anno <= 2030; anno++) {
        final t = LaRivoluzioneSolare.tema(
            LaRivoluzioneSolare.ritorno(sole, anno, n.month, n.day), lat, lon);
        temi++;
        final s = LAnnuale.schede(t);
        // La regola scritta qui: angolare 1, 4, 7, 10; succedente 2, 5, 8,
        // 11; cadente le altre. Livello 2 piu' la forza, Saturno al rovescio.
        int forza(int c) => const [1, 4, 7, 10].contains(c)
            ? 3
            : const [2, 5, 8, 11].contains(c)
                ? 2
                : 1;
        final casa = {
          for (final c in CorpoCeleste.values)
            if (t.longitudini.containsKey(c)) c: t.casaDi(c),
        };
        final attesi = [
          (
            'generale',
            [
              OroscopoAnnualeData.ascendente[t.segnoDellAscendente],
              OroscopoAnnualeData.sole[casa[CorpoCeleste.sole]! - 1],
              OroscopoAnnualeData.luna[casa[CorpoCeleste.luna]! - 1],
            ],
            2 + forza(casa[CorpoCeleste.sole]!),
          ),
          (
            'amore',
            [OroscopoAnnualeData.venere[casa[CorpoCeleste.venere]! - 1]],
            2 + forza(casa[CorpoCeleste.venere]!),
          ),
          (
            'carriera',
            [
              OroscopoAnnualeData.medioCielo[t.segnoDelMedioCielo],
              OroscopoAnnualeData.saturno[casa[CorpoCeleste.saturno]! - 1],
            ],
            6 - forza(casa[CorpoCeleste.saturno]!),
          ),
          (
            'fortuna',
            [OroscopoAnnualeData.giove[casa[CorpoCeleste.giove]! - 1]],
            2 + forza(casa[CorpoCeleste.giove]!),
          ),
        ];
        for (var i = 0; i < 4; i++) {
          final (nome, gruppi, livello) = attesi[i];
          // LAPIDE, EU Aggiunta, 1 ottobre 2026: qui si pretendeva che la
          // lettura fosse la frase del caso dal corpus annuale di prima.
          // Adesso la lettura e' la voce del corpus dell'Anno occidentale
          // dell'Architetto, nella fascia del livello, e la voce e' (numero
          // dell'anno + scarto) modulo due; il "da dove viene" del caso resta.
          final voce = ITestiEu.voce(
              TradizioneEu.occidentale,
              PeriodoEu.anno,
              HoroscopeDomain.values[i],
              FasciaEu.di(livello.clamp(2, 5)),
              ITestiEu.indiceDellAnno(t.istante.year, 0));
          if (s[i].text != voce.testo(lunga: true) ||
              s[i].title != voce.titolo) {
            fuori.add('$nome $n $anno');
          }
          for (final g in gruppi) {
            if (!daDove(g).hasMatch(s[i].rigaDelLivello!)) {
              fuori.add('da dove $nome $n $anno');
            }
            // Il simbolo non apre mai: sta nella riga, non nella lettura.
            if (daDove(g).hasMatch(s[i].text)) {
              fuori.add('simbolo nella lettura $nome $n $anno');
            }
          }
          if (s[i].indicator != livello.clamp(2, 5)) {
            fuori.add('livello $nome $n $anno: ${s[i].indicator}, $livello');
          }
        }
      }
    }
    cardinaleMinimo(temi, 100, cosa: 'temi dell\'anno');
    print('ORDINE ES VOCE 04: schede dell\'anno fuori dal loro caso o dal '
        'loro livello ${fuori.length} su ${temi * 4}');
    expect(fuori, isEmpty, reason: fuori.take(6).join('\n'));
  });

  test('lo stesso caso in due anni di fila ha l\'altra frase', () {
    // L'Ascendente dell'anno cambia segno quasi ogni anno: qui si prende la
    // stessa scheda con lo stesso tema spostato di un anno.
    var coppie = 0;
    var uguali = 0;
    for (final n in nascite) {
      final sole = LaRivoluzioneSolare.soleNatale(n);
      final t = LaRivoluzioneSolare.tema(
          LaRivoluzioneSolare.ritorno(sole, 2026, n.month, n.day), lat, lon);
      final dopo = TemaDellaRivoluzione(
        istante: t.istante.add(const Duration(days: 365)),
        ascendente: t.ascendente,
        medioCielo: t.medioCielo,
        longitudini: t.longitudini,
      );
      final a = LAnnuale.schede(t);
      final b = LAnnuale.schede(dopo);
      for (var i = 0; i < 4; i++) {
        coppie++;
        if (a[i].text == b[i].text) uguali++;
      }
    }
    print('ORDINE ES VOCE 04: schede uguali per lo stesso caso in due anni di '
        'fila $uguali su $coppie');
    expect(uguali, 0);
  });

  test('l\'anno costa 300 Eos e il corpus e\' quello del codice', () {
    expect(ListinoDegliEos.oroscopoAnnuale.costo, 300);
    final corpus = File('docs/corpus/oroscopo_annuale.md')
        .readAsStringSync()
        .replaceAll('\r\n', '\n');
    final dalCorpus = RegExp(r'^\d+\.\s+(.+)$', multiLine: true)
        .allMatches(corpus)
        .map((m) => m.group(1)!.trim())
        .where((f) => !f.startsWith('"'))
        .toSet();
    final dalCodice = {
      for (final g in [
        ...OroscopoAnnualeData.ascendente,
        ...OroscopoAnnualeData.sole,
        ...OroscopoAnnualeData.venere,
        ...OroscopoAnnualeData.giove,
        ...OroscopoAnnualeData.saturno,
        ...OroscopoAnnualeData.medioCielo,
        ...OroscopoAnnualeData.luna,
      ])
        ...g,
    };
    cardinaleMinimo(dalCodice.length, 252, cosa: 'frasi dell\'anno');
    print('ORDINE ES VOCE 04: frasi del corpus ${dalCorpus.length}, del codice '
        '${dalCodice.length}');
    expect(dalCodice, dalCorpus,
        reason: 'rigenerare con python tool/_gen_oroscopo_annuale.py');
    // La nota del metodo dice che le case sono equali.
    expect(OroscopoAnnualeData.notaTutte, contains('equali'));
    // Il dominio della scheda del lavoro e' la carriera.
    expect(HoroscopeDomain.carriera.label, isNotEmpty);
  });

  test('il PDF dell\'Illuminato porta le quattro schede e l\'emblema',
      () async {
    // **L'EMBLEMA DELL'ANNO IN COPERTINA, voce ES.05.** Il PDF e' compresso,
    // quindi l'immagine non si cerca nel testo: si misura quanto pesa il
    // foglio con l'emblema contro lo stesso foglio senza. Un emblema che non
    // entrasse lascerebbe i due pesi uguali.
    final n = nascite.first;
    final t = LaRivoluzioneSolare.tema(
        LaRivoluzioneSolare.ritorno(
            LaRivoluzioneSolare.soleNatale(n), 2026, n.month, n.day),
        lat,
        lon);
    final schede = LAnnuale.schede(t);
    final emblema = File(IlPdfDellAnno.emblema).readAsBytesSync();
    final conLEmblema = await IlPdfDellAnno.documento(schede,
        titolo: 'Il tuo anno', sottotitolo: 'prova', copertina: emblema);
    final senza = await IlPdfDellAnno.documento(schede,
        titolo: 'Il tuo anno', sottotitolo: 'prova', copertina: const []);
    print('ORDINE ES VOCE 04: il PDF dell\'anno pesa ${conLEmblema.length} '
        'byte con l\'emblema e ${senza.length} senza');
    expect(String.fromCharCodes(conLEmblema.take(5)), '%PDF-');
    expect(conLEmblema.length - senza.length, greaterThan(20000),
        reason: 'l\'emblema dell\'anno non e\' entrato nel PDF');
    // E non lo gonfia: col WebP decodificato pesava 1,3 MB, che e' troppo
    // per un foglio da mandare in una chat.
    expect(conLEmblema.length, lessThan(300000),
        reason: 'il PDF dell\'anno pesa ${conLEmblema.length} byte');
    expect(schede, hasLength(4));
  });
}
