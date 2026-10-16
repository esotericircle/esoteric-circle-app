// IL SENSO DEL RESPIRO, DETTO A CHI RESPIRA. Ordine FX voce FXA.07, 16
// ottobre 2026.
//
// Il fondatore: "l'utente cosa ottiene facendo il Respiro della luna. Quale
// è il suo beneficio? E viene informato di questo?". Queste guardie tengono
// vero il corpus di `IlSensoDelRespiro`: le righe cambiano davvero da un
// giorno al successivo, ognuna dice da dove viene, e nessuna sconfina nella
// salute o nel gioco.

import 'package:esoteric_circle/features/maestri/widgets/foglio_delle_fonti.dart';
import 'package:esoteric_circle/features/respiro_della_luna/il_senso_del_respiro.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cardinale_minimo.dart';

/// Tutte le righe del corpus, coi loro nomi per il messaggio di caduta.
List<(String, RigaDelSenso)> _tutteLeRighe() => [
      for (var g = 1; g <= 30; g++)
        ('prima del giorno $g', IlSensoDelRespiro.rigaPrima(g)),
      for (var g = 1; g <= 30; g++)
        ('dopo del giorno $g', IlSensoDelRespiro.rigaDopo(g)),
    ];

void main() {
  test('due giorni consecutivi del ciclo non danno mai la stessa riga', () {
    cardinaleMinimo(IlSensoDelRespiro.righePrima.length, 30,
        cosa: 'righe prima del respiro',
        perche: 'una per ciascun giorno del ciclo, dal primo al trentesimo: '
            'con meno righe due giorni consecutivi finirebbero sulla stessa.');
    cardinaleMinimo(IlSensoDelRespiro.righeDopo.length, 30,
        cosa: 'righe dopo il respiro',
        perche: 'una per ciascun giorno del ciclo, dal primo al trentesimo.');
    final uguali = <String>[];
    // Dal giorno 1 al 30, e il passaggio dal 30 al primo del ciclo dopo.
    for (var g = 1; g <= 30; g++) {
      final dopoG = g == 30 ? 1 : g + 1;
      if (IlSensoDelRespiro.rigaPrima(g).testo ==
          IlSensoDelRespiro.rigaPrima(dopoG).testo) {
        uguali.add('prima: giorni $g e $dopoG');
      }
      if (IlSensoDelRespiro.rigaDopo(g).testo ==
          IlSensoDelRespiro.rigaDopo(dopoG).testo) {
        uguali.add('dopo: giorni $g e $dopoG');
      }
    }
    expect(uguali, isEmpty,
        reason: 'la stessa persona leggerebbe le stesse parole due giorni di '
            'fila: $uguali');
  });

  test('ogni riga porta una fonte vera o la dicitura chiave di Medora', () {
    final senza = <String>[];
    var citate = 0;
    for (final (nome, riga) in _tutteLeRighe()) {
      if (riga.testo.trim().isEmpty) senza.add('$nome: testo vuoto');
      if (riga.fonte == IlSensoDelRespiro.chiaveDiMedora) continue;
      if (IlSensoDelRespiro.fontiCitate.contains(riga.fonte)) {
        citate++;
        continue;
      }
      senza.add('$nome: "${riga.fonte}"');
    }
    expect(senza, isEmpty,
        reason: 'queste righe non dicono da dove vengono, o citano una fonte '
            'che non sta fra quelle verificate: $senza');
    // Le fonti verificate devono essere usate davvero: una fonte dichiarata
    // e mai citata e' un elenco che non dice niente.
    final usate = {for (final (_, r) in _tutteLeRighe()) r.fonte};
    for (final f in IlSensoDelRespiro.fontiCitate) {
      expect(usate, contains(f), reason: 'fonte dichiarata e mai citata: $f');
    }
    cardinaleMinimo(citate, 8,
        cosa: 'righe con una fonte citata',
        perche: 'il corpus cita le fonti dove una tradizione documenta la '
            'fase; se scendessero a zero tutto sarebbe chiave di Medora '
            'senza che nessuno lo decida.');
  });

  test('nessuna riga parla di salute, di corpo o di gioco', () {
    // Il vocabolario vietato, per radici: si cercano all'inizio di ogni
    // parola, cosi' "cura" non scatta dentro "sicura".
    const vietate = [
      'salute',
      'guari',
      'curar',
      'cura',
      'cure',
      'terapi',
      'terapeut',
      'malatti',
      'dolor',
      'sintom',
      'ansia',
      'ansie',
      'ansios',
      'stress',
      'sonno',
      'dormi',
      'insonni',
      'rilass',
      'corpo',
      'ossigen',
      'pression',
      'battito',
      'benesser',
      'medic',
      'gioco',
      'giochi',
      'sfida',
      'sfide',
      'punteggi',
      'vinci',
      'premio',
    ];
    final testi = <(String, String)>[
      for (final (nome, r) in _tutteLeRighe()) (nome, r.testo),
      for (var i = 0; i < IlSensoDelRespiro.primaApertura.length; i++)
        ('prima apertura ${i + 1}', IlSensoDelRespiro.primaApertura[i]),
      ('foglio delle fonti', TestiDelleFonti.respiroDellaLuna),
    ];
    cardinaleMinimo(testi.length, 63,
        cosa: 'testi del senso del Respiro guardati',
        perche: 'sessanta righe, le due della prima apertura e il foglio: '
            'su un insieme vuoto la guardia sarebbe verde senza guardare.');
    final parola = RegExp(r'[a-zàèéìòù]+');
    final colpevoli = <String>[];
    for (final (nome, testo) in testi) {
      for (final m in parola.allMatches(testo.toLowerCase())) {
        final p = m.group(0)!;
        for (final v in vietate) {
          final intera = v == 'cura' || v == 'cure';
          if (intera ? p == v : p.startsWith(v)) {
            colpevoli.add('$nome: "$p"');
          }
        }
      }
      if (testo.contains('—') || testo.contains('–')) {
        colpevoli.add('$nome: trattino lungo');
      }
    }
    expect(colpevoli, isEmpty,
        reason: 'il respiro è un rito, mai una terapia né un gioco: '
            '$colpevoli');
  });

  test('il foglio delle fonti si apre con le due righe della prima apertura',
      () {
    expect(IlSensoDelRespiro.primaApertura, hasLength(2));
    expect(
        TestiDelleFonti.respiroDellaLuna,
        startsWith('${IlSensoDelRespiro.primaRiga}\n\n'
            '${IlSensoDelRespiro.secondaRiga}'));
  });

  test('la fase segue il giorno del ciclo', () {
    expect(IlSensoDelRespiro.faseDelGiorno(1), FaseDelSenso.nuova);
    expect(IlSensoDelRespiro.faseDelGiorno(7), FaseDelSenso.crescente);
    expect(IlSensoDelRespiro.faseDelGiorno(15), FaseDelSenso.piena);
    expect(IlSensoDelRespiro.faseDelGiorno(22), FaseDelSenso.calante);
    expect(IlSensoDelRespiro.faseDelGiorno(30), FaseDelSenso.nuova);
    // Fuori dal contratto 1..30 si riporta dentro, senza cadere.
    expect(IlSensoDelRespiro.rigaPrima(31).testo,
        IlSensoDelRespiro.rigaPrima(1).testo);
    expect(IlSensoDelRespiro.rigaDopo(0).testo,
        IlSensoDelRespiro.rigaDopo(30).testo);
  });

  test('il giorno del ciclo viene dal motore lunare, da 1 a 30', () {
    for (var d = 0; d < 60; d++) {
      final g = IlSensoDelRespiro.giornoDelCiclo(
          DateTime(2026, 10, 1).add(Duration(days: d)));
      expect(g, inInclusiveRange(1, 30));
    }
  });

  test('la prima apertura si ricorda sulla sua chiave', () async {
    SharedPreferences.setMockInitialValues({});
    expect(await IlSensoDelRespiro.primaAperturaGiaVista(), isFalse);
    await IlSensoDelRespiro.segnaPrimaAperturaVista();
    expect(await IlSensoDelRespiro.primaAperturaGiaVista(), isTrue);
    final p = await SharedPreferences.getInstance();
    expect(p.getBool('respiro.primaAperturaVista'), isTrue);
    expect(IlSensoDelRespiro.chiavePrimaApertura, startsWith('respiro.'));
  });
}
