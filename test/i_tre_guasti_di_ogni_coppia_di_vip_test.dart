// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/synastry/synastry_report.dart';
import 'package:esoteric_circle/core/synastry/testi_della_sinastria.dart';
import 'package:esoteric_circle/core/synastry/vip_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

/// **I TRE GUASTI CHE VALGONO PER OGNI COPPIA DI VIP.** Ordine DR voce 05,
/// 16 settembre 2026.
///
/// Non riguardano lo specchio: si vedono anche accoppiando due personaggi
/// diversi, e si curano insieme perche' stanno nello stesso metodo.
///
/// **1. IL PUNTO FERMO.** `_ilPersonaggio` toglieva il punto a tutte e due le
/// meta' della presentazione. Alla prima serve, perche' dopo arriva
/// *"; dall'altra"*; alla seconda no, perche' dopo arriva un'altra frase con
/// la maiuscola. Sul telefono del fondatore si leggeva *"non cambia mai
/// foglio Un'intesa cosi' andrebbe sprecata"*.
///
/// **2. L'APERTURA CHE DA' DEL TU.** Le aperture di sempre sono scritte per
/// la coppia in cui uno dei due sei tu: con due VIP dicono *"Sei un Ariete"*
/// a chi Ariete non e', e *"quanto vi divertirete"* a chi sta solo
/// guardando.
///
/// **3. IL PRIMO CHE SPARISCE.** La nota, la sfida e la residenza parlavano
/// del solo secondo, e della coppia si vedeva mezza.
void main() {
  const vips = VipCatalog.vips;
  final gaga = vips.firstWhere((v) => v.name == 'Lady Gaga');
  final gates = vips.firstWhere((v) => v.name == 'Bill Gates');

  test('DR.05.1: LA CODA DEL CORPO COMINCIA DOPO UN PUNTO, per ogni coppia '
      'di VIP', () {
    // **LA GRANDEZZA MISURATA E' LA SALDATURA, non una maiuscola qualunque.**
    // La prima stesura di questa prova cercava ogni lettera maiuscola
    // preceduta da una minuscola e uno spazio, e trovava centootto casi che
    // difetti non erano: "il suo Marte", "colleziona Oscar e tramonti",
    // "LeBron". I nomi propri dentro una frase vogliono la maiuscola di
    // diritto, e una guardia che li conta come guasti insegna solo a non
    // guardarla piu'.
    //
    // **Il difetto vero sta in un punto solo**: dove il corpo salda la
    // presentazione del secondo personaggio col pezzo che viene dopo, la
    // stoccata o l'attualita'. Quel pezzo e' un testo del corpus, si
    // conosce, e qui si pretende che davanti a lui ci sia un punto.
    final code = <String>[
      for (final righe in TestiDellaSinastria.stoccate.values) ...righe,
      ...TestiDellaSinastria.memoria,
    ];
    var guardate = 0;
    var saldature = 0;
    final rotte = <String>[];
    for (var i = 0; i < vips.length; i++) {
      final primo = vips[i];
      final secondo = vips[(i + 7) % vips.length];
      if (primo.name == secondo.name) continue;
      final report = SynastryReport.fraDueVip(primo: primo, vip2: secondo);
      guardate++;
      for (final coda in code) {
        final dove = report.reading.indexOf(coda);
        if (dove <= 0) continue;
        saldature++;
        final prima = report.reading.substring(0, dove).trimRight();
        if (!prima.endsWith('.') && !prima.endsWith('!') &&
            !prima.endsWith('?')) {
          final quanto = prima.length < 40 ? prima.length : 40;
          rotte.add('${primo.name} con ${secondo.name}: '
              '"...${prima.substring(prima.length - quanto)}" e poi '
              '"${coda.substring(0, 24)}"');
        }
      }
    }
    print('ORDINE DR VOCE 05: coppie di VIP guardate $guardate, saldature '
        'trovate $saldature, rotte ${rotte.length}');
    expect(guardate, greaterThan(40),
        reason: 'la prova non ha guardato abbastanza coppie');
    expect(saldature, greaterThan(40),
        reason: 'nessuna saldatura trovata: la prova non guarda il punto in '
            'cui il difetto vive');
    expect(rotte, isEmpty,
        reason: 'due frasi appiccicate senza il punto in mezzo: '
            '${rotte.take(4).join(" | ")}');
  });

  test('DR.05.2: LE APERTURE PER DUE VIP NON DANNO DEL TU A NESSUNO', () {
    // **Chi guarda non e' nessuno dei due**, quindi in queste righe non ci
    // sono seconde persone: ne' singolari (sei, hai, tuo) ne' plurali (vi,
    // vostra, vi divertirete).
    final vietate = RegExp(
        r'\b(sei|hai|sai|siete|avete|vi|voi|vostro|vostra|vostri|vostre|'
        r'tuo|tua|tuoi|tue|ti|te|tu)\b|\w+(ete|ate)\b',
        caseSensitive: false);
    var guardate = 0;
    final colpevoli = <String>[];
    for (final righe in TestiDellaSinastria.apertureFraDueVip.values) {
      for (final r in righe) {
        guardate++;
        final trovata = vietate.firstMatch(r);
        if (trovata != null) colpevoli.add('"$r" dice "${trovata.group(0)}"');
      }
    }
    print('ORDINE DR VOCE 05: aperture per due VIP guardate $guardate');
    expect(guardate, TestiDellaSinastria.apertureFraDueVip.length * 3,
        reason: 'ogni relazione deve avere le sue tre aperture');
    expect(guardate, greaterThanOrEqualTo(21));
    expect(colpevoli, isEmpty, reason: colpevoli.join(' | '));
  });

  test('DR.05.2 bis: l\'apertura che il responso usa fra due VIP e\' quella '
      'nuova, non quella di sempre', () {
    var guardate = 0;
    final vecchie = <String>[];
    for (var i = 0; i < vips.length; i++) {
      final primo = vips[i];
      final secondo = vips[(i + 11) % vips.length];
      if (primo.name == secondo.name) continue;
      final report = SynastryReport.fraDueVip(primo: primo, vip2: secondo);
      guardate++;
      for (final righe in TestiDellaSinastria.aperture.values) {
        for (final r in righe) {
          final nuda = r
              .replaceAll('SEGNO_A', primo.sign.italianName)
              .replaceAll('SEGNO_B', secondo.sign.italianName);
          // Alcune righe sono uguali fra i due corpus, e vanno bene: quelle
          // che cadono sono le righe che parlano a chi guarda.
          if (report.reading.contains(nuda) &&
              RegExp(r'\b(Sei|sei|vi|vostra|vostre|divertirete|litigherete)\b')
                  .hasMatch(nuda)) {
            vecchie.add('${primo.name} con ${secondo.name}: "$nuda"');
          }
        }
      }
    }
    print('ORDINE DR VOCE 05: coppie guardate $guardate sull\'apertura');
    expect(guardate, greaterThan(40));
    expect(vecchie, isEmpty,
        reason: 'una coppia di VIP si apre ancora dando del tu a chi guarda: '
            '${vecchie.take(3).join(" | ")}');
  });

  test('DR.05.3: LA SFIDA E LA RESIDENZA PARLANO DI TUTTI E DUE', () {
    final report = SynastryReport.fraDueVip(primo: gaga, vip2: gates);
    print('ORDINE DR VOCE 05: sfida "${report.sfida}"');
    print('ORDINE DR VOCE 05: residenza "${report.luogoDiResidenza}"');
    expect(report.sfida, contains(gaga.name),
        reason: 'la sfida da condividere non nomina il primo');
    expect(report.sfida, contains(gates.name),
        reason: 'la sfida da condividere non nomina il secondo');
    expect(report.luogoDiResidenza, startsWith('Luogo di Residenza:'));
    expect(report.luogoDiResidenza, contains(gaga.name));
    expect(report.luogoDiResidenza, contains(gates.name));
  });

  test('DR.05.3 bis: la nota dice di chi e\', quando c\'e\'', () {
    // Nel catalogo di oggi l'attualita' e' vuota per tutti e cinquanta, e la
    // nota che resta e' quella del luogo ignoto: deve dire di chi.
    var conNota = 0;
    final anonime = <String>[];
    for (var i = 0; i < vips.length; i++) {
      final primo = vips[i];
      final secondo = vips[(i + 13) % vips.length];
      if (primo.name == secondo.name) continue;
      final report = SynastryReport.fraDueVip(primo: primo, vip2: secondo);
      if (report.nota.isEmpty) continue;
      conNota++;
      if (!report.nota.contains(primo.name) &&
          !report.nota.contains(secondo.name)) {
        anonime.add('${primo.name} con ${secondo.name}: "${report.nota}"');
      }
    }
    print('ORDINE DR VOCE 05: coppie con una nota $conNota');
    expect(conNota, greaterThan(0),
        reason: 'nessuna coppia ha una nota: la prova non guarda niente');
    expect(anonime, isEmpty,
        reason: 'una nota non dice di chi parla: ${anonime.take(3).join(" | ")}');
  });
}
