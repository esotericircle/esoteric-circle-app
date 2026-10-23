import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/rituals/guide_animal_derivation.dart';
import 'package:esoteric_circle/core/viaggio/diario_dei_viaggi.dart';
import 'package:esoteric_circle/core/viaggio/il_responso_del_viaggio.dart';
import 'package:esoteric_circle/core/viaggio/la_domanda_del_viaggio.dart';
import 'package:esoteric_circle/core/viaggio/la_voce_del_mondo_di_sotto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cardinale_minimo.dart';

/// **LA VOCE SI RICORDA DI CIO' CHE LA PERSONA HA LETTO.** Ordine DJ voce 02,
/// 13 settembre 2026.
///
/// *"Aumentare i titoli sposta la ripetizione piu' in la', non la toglie [...]
/// Quello che la toglie e' ricordarsi cosa quella persona ha gia' letto."*
///
/// **La prova a cento discese non lo vede**, e non per un difetto suo: scende
/// ogni giorno sullo stesso tema, e per chi scende cosi' i cicli della voce
/// bastano da soli. La memoria serve a chi scende in un altro modo: sullo
/// stesso tema ogni dodici giorni, che coi cicli contati sui giorni ritrovava
/// la stessa risposta ogni volta, o alternando i temi. **Qui si scende cosi',
/// dalla strada vera**: un Diario vero, `IlResponsoDelViaggio.componi` e
/// `comeSiConserva`, le stesse chiamate della schermata.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  final animale = GuideAnimalDerivation.forSign(Zodiac.cancer);

  /// Scende nei [giorni] dati, ognuno col suo tema, e rende cio' che si e'
  /// letto, dal primo all'ultimo.
  Future<List<UnViaggio>> scendi(
      List<(DateTime, TemaDellaDomanda)> discese) async {
    var oggi = discese.first.$1;
    final diario = DiarioDeiViaggi(orologio: () => oggi);
    for (final (giorno, tema) in discese) {
      oggi = giorno;
      final domanda = LaDomandaDelViaggio.gliaScritte
          .firstWhere((d) => d.chiave == tema)
          .testo;
      final responso = IlResponsoDelViaggio.componi(
        dalModello: null,
        domanda: domanda,
        giorno: giorno,
        nitidezza: 1,
        discesa: diario.quanteDiscese,
        giaOggi: diario.quanteOggi,
        animale: animale,
        tema: tema,
        storia: diario.viaggi,
      );
      await diario.segna(responso.comeSiConserva(
        quando: giorno,
        domanda: domanda,
        temaDellaDomanda: tema.name,
        animaleSeguito: animale.name,
        nitidezza: 1,
      ));
    }
    return diario.viaggi.reversed.toList();
  }

  final inizio = DateTime(2026, 9, 14, 12);

  /// **OGNI UNDICI GIORNI E OGNI DODICI.** Undici e' il passo che la voce
  /// senza memoria sbaglia: la risposta salta avanti di un posto ogni undici
  /// giorni, e chi scende con quel passo la ritrovava identica ogni volta. Il
  /// primo rosso di questa prova, con la memoria spenta, e' stato verde sulla
  /// risposta ogni dodici giorni: una prova con un passo solo era cieca.
  ///
  /// **E OGNI VENTI**, per la coppia: con venti giorni fra una discesa e
  /// l'altra l'azione e' sempre la stessa del ciclo, e la coppia torna appena
  /// torna la risposta.
  for (final passo in [11, 12, 20]) {
    test(
        'SULLO STESSO TEMA OGNI $passo GIORNI: la risposta non e fra le ultime '
        'sei, e ventiquattro titoli in ogni finestra di ventiquattro',
        () async {
      final letti = await scendi([
        for (var i = 0; i < 60; i++)
          (inizio.add(Duration(days: passo * i)), TemaDellaDomanda.scelta),
      ]);
      cardinaleMinimo(letti.length, 60,
          cosa: 'discese ogni $passo giorni',
          perche: 'Senza discese nessuna risposta si ripete.');
      final ripetute = <String>[];
      for (var i = 0; i < letti.length; i++) {
        final prima =
            letti.sublist(i < 6 ? 0 : i - 6, i).map((v) => v.risposta);
        if (prima.contains(letti[i].risposta)) {
          ripetute.add('discesa ${i + 1}: ${letti[i].risposta}');
        }
      }
      final coppie = <String>[];
      final viste = <String>{};
      for (final v in letti) {
        if (!viste.add('${v.risposta}|${v.gesto}')) {
          coppie.add('${v.risposta} con ${v.gesto}');
        }
      }
      final finestre = <int>[];
      for (var i = 0; i + 24 <= letti.length; i++) {
        final titoli = letti.sublist(i, i + 24).map((v) => v.titolo).toSet();
        if (titoli.length < 24) finestre.add(i + 1);
      }
      // ignore: avoid_print
      print('ORDINE DJ VOCE 02, ogni $passo giorni: risposte ripetute fra le '
          'ultime sei ${ripetute.length}, finestre di ventiquattro con un titolo '
          'ripetuto ${finestre.length} su ${letti.length - 23}, coppie '
          'ripetute ${coppie.length}');
      expect(ripetute, isEmpty, reason: ripetute.take(4).join('\n'));
      expect(coppie, isEmpty, reason: coppie.take(4).join('\n'));
      expect(finestre, isEmpty,
          reason: 'finestre che cominciano alle discese $finestre');
    });
  }

  test(
      'ALTERNANDO I TEMI OGNI GIORNO: la stessa azione non torna fra le '
      'ultime dieci, e nessun tema ripete una coppia', () async {
    const temi = TemaDellaDomanda.values;
    final letti = await scendi([
      for (var i = 0; i < 90; i++)
        (inizio.add(Duration(days: i)), temi[i % 3 == 2 ? 2 : i % 2]),
    ]);
    cardinaleMinimo(letti.length, 90,
        cosa: 'discese a temi alternati',
        perche: 'Senza discese nessuna azione si ripete.');
    final azioni = <String>[];
    final coppie = <String>[];
    final viste = <String>{};
    for (var i = 0; i < letti.length; i++) {
      final prima = letti.sublist(i < 10 ? 0 : i - 10, i).map((v) => v.gesto);
      if (prima.contains(letti[i].gesto)) {
        azioni.add('discesa ${i + 1}: ${letti[i].gesto}');
      }
      final coppia =
          '${letti[i].temaDellaDomanda}|${letti[i].risposta}|${letti[i].gesto}';
      if (!viste.add(coppia)) coppie.add('discesa ${i + 1}: $coppia');
    }
    // ignore: avoid_print
    print('ORDINE DJ VOCE 02, temi alternati: azioni ripetute fra le ultime '
        'dieci ${azioni.length}, coppie ripetute ${coppie.length}');
    expect(azioni, isEmpty, reason: azioni.take(4).join('\n'));
    expect(coppie, isEmpty, reason: coppie.take(4).join('\n'));
  });

  test('IL MAZZO FINITO SI AZZERA, e ricomincia nello stesso ordine', () async {
    final letti = await scendi([
      for (var i = 0; i < 49; i++)
        (inizio.add(Duration(days: i)), TemaDellaDomanda.finito),
    ]);
    final primo = letti.take(24).map((v) => v.titolo).toList();
    final secondo = letti.skip(24).take(24).map((v) => v.titolo).toList();
    expect(primo.toSet(), hasLength(24),
        reason: 'il primo mazzo ha ripetuto un titolo');
    expect(
        primo.toSet(), LaVoceDelMondoDiSotto.titoliPerTema['finito']!.toSet(),
        reason: 'il primo mazzo non ha usato i ventiquattro titoli del tema');
    expect(secondo, primo,
        reason: 'il secondo mazzo non ricomincia nello stesso ordine, e un '
            'titolo della fine del primo puo tornare in testa al secondo');
    expect(letti[48].titolo, primo.first);
  });

  test(
      'LA DISCESA RIAPERTA MOSTRA LO STESSO TITOLO: si conserva, non si '
      'ricalcola', () async {
    final letti = await scendi([
      (inizio, TemaDellaDomanda.attesa),
      (inizio.add(const Duration(days: 1)), TemaDellaDomanda.attesa),
    ]);
    for (final v in letti) {
      expect(v.titolo, isNotNull);
      expect(v.risposta, isNotNull);
      expect(v.gesto, isNotNull);
      final riletta = UnViaggio.fromJson(v.toJson())!;
      expect(riletta.titolo, v.titolo);
      expect(riletta.risposta, v.risposta);
      expect(riletta.gesto, v.gesto);
    }
    // **E UN DIARIO SCRITTO PRIMA DELL'ORDINE DJ**, senza titoli, si legge
    // lo stesso: le sue discese restano nulle e la voce le salta.
    final vecchio = UnViaggio.fromJson({
      'quando': inizio.toIso8601String(),
      'domanda': 'x',
      'tema': 'attesa',
      'pezzi': letti.first.pezzi,
      'animale': animale.name,
      'nitidezza': 1.0,
    })!;
    expect(vecchio.titolo, isNull);
    final responso = IlResponsoDelViaggio.componi(
      dalModello: null,
      domanda: 'x',
      giorno: inizio.add(const Duration(days: 1)),
      nitidezza: 1,
      discesa: 1,
      giaOggi: 0,
      animale: animale,
      tema: TemaDellaDomanda.attesa,
      storia: [vecchio],
    );
    expect(LaVoceDelMondoDiSotto.titoliPerTema['attesa'],
        contains(responso.titolo));
  });
}
