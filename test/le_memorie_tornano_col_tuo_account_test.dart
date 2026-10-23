// ignore_for_file: avoid_print
import 'dart:convert';

import 'package:esoteric_circle/core/cammino/le_memorie_custodite.dart';
import 'package:esoteric_circle/core/identity/cio_che_e_tuo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **LE MEMORIE TORNANO COL TUO ACCOUNT.** Ordine EV, il fondatore: *"non mi
/// ha riaccreditato [...] gli storici del dono "runa del tramonto" [...] Se
/// c'è una tipologia di problema, probabilmente c'è lo stesso problema con
/// altre funzionalità, per logica. È tuo compito controllare dipendenze
/// simili!"*
///
/// Due pretese. **Ogni memoria della persona ha una strada decisa**: ogni
/// prefisso di `CioCheETuo.prefissi` torna con `LeMemorieCustodite`, o con
/// una porta sua, o resta del telefono con la ragione scritta; un prefisso
/// nuovo che nessuno ha deciso fa cadere la prova. **E la strada funziona**:
/// le chiavi di un telefono partono, e su un telefono vuoto tornano.
void main() {
  test('ogni memoria della persona ha una strada decisa', () {
    final decise = <String>{
      for (final p in LeMemorieCustodite.famiglie.values) ...p,
      ...LeMemorieCustodite.conUnaPortaSua.keys,
      ...LeMemorieCustodite.delTelefono.keys,
    };
    final senzaStrada = [
      for (final p in CioCheETuo.prefissi)
        if (!decise.contains(p)) p,
    ];
    final tornano = [
      for (final p in CioCheETuo.prefissi)
        if (LeMemorieCustodite.famiglie.values.any((l) => l.contains(p))) p,
    ];
    print('ORDINE EV, MEMORIE: prefissi della persona '
        '${CioCheETuo.prefissi.length}, tornano con le memorie '
        '${tornano.length}, con una porta loro '
        '${LeMemorieCustodite.conUnaPortaSua.length}, del telefono '
        '${LeMemorieCustodite.delTelefono.length}, senza strada '
        '${senzaStrada.length} $senzaStrada');
    expect(senzaStrada, isEmpty,
        reason: 'queste memorie della persona non hanno una strada decisa: '
            'dopo una reinstallazione si perderebbero senza che nessuno '
            'l\'abbia scelto');
    // Le memorie del telefono hanno la loro ragione scritta.
    for (final r in LeMemorieCustodite.delTelefono.values) {
      expect(r.length, greaterThan(10));
    }
  });

  test('le chiavi partono, e su un telefono vuoto tornano', () async {
    final tramonto = jsonEncode([
      for (final g in ['2026-09-26', '2026-09-27', '2026-09-28', '2026-09-29',
        '2026-09-30'])
        {'giorno': g, 'runa': 'Algiz'},
    ]);
    SharedPreferences.setMockInitialValues({
      'sunset_rune.settimana': tramonto,
      'sigilli.libro': '[{"intenzione":"Trovo la calma"}]',
      'loto.sessioni': <String>['una sessione'],
      'device.id': 'questo-telefono',
      'permesso.microfono': true,
    });
    final partite = await LeMemorieCustodite.daCustodire();
    expect(partite, isNotNull);
    final famiglie = partite!.keys.toSet();
    final chiavi = {
      for (final f in partite.values) ...(f! as Map).keys,
    };
    print('ORDINE EV, MEMORIE: famiglie partite $famiglie, chiavi $chiavi');
    expect(chiavi, contains('sunset_rune.settimana'));
    expect(chiavi, contains('sigilli.libro'));
    expect(chiavi, isNot(contains('device.id')),
        reason: 'l\'identita\' del telefono non viaggia');
    expect(chiavi, isNot(contains('permesso.microfono')),
        reason: 'un permesso si chiede di nuovo sul telefono nuovo');

    // Il telefono reinstallato: vuoto. Il Cerchio rimanda cio' che ha.
    SharedPreferences.setMockInitialValues(const {});
    final cambiate = await LeMemorieCustodite.adottaDalCerchio(
        jsonDecode(jsonEncode(partite)) as Map<String, Object?>);
    final prefs = await SharedPreferences.getInstance();
    print('ORDINE EV, MEMORIE: famiglie tornate $cambiate; sere del Tramonto '
        '${(jsonDecode(prefs.getString('sunset_rune.settimana') ?? '[]') as List).length}');
    expect(prefs.getString('sunset_rune.settimana'), tramonto);
    expect(prefs.getString('sigilli.libro'), contains('Trovo la calma'));
    expect(prefs.getStringList('loto.sessioni'), ['una sessione']);
    expect(prefs.getString('device.id'), isNull);
  });
}
