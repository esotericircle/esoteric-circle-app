import 'dart:io';

import 'package:esoteric_circle/core/astro/natal_chart.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/sigilli/diario_del_cammino.dart';
import 'package:esoteric_circle/features/sigilli/regia_del_cammino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// I GRADINI DELL'IDENTITA' MATURANO ALLE LORO PORTE. Ordine BD voce 05.
///
/// **Il difetto dichiarato dal responso AU**: i gradini dell'identita'
/// maturavano tutti nello stesso istante, perche' la prima visita del
/// Passaporto segnava in un colpo solo carta, ora, luogo e numero, e il
/// documento pieno derivava Sigillo e Luna. La coda li mostrava uno per
/// volta, ma la maturazione era un blocco.
///
/// **L'effetto voluto dal fondatore**: una sola festa alla fine
/// dell'onboarding, e le altre legate a gesti veri successivi. Le porte:
/// la carta si calcola alla fine del Risveglio (med_1), il nome matura al
/// primo saluto (aur_5), il numero all'apertura del documento (aur_10),
/// l'ora e il luogo aprendo la propria carta (med_7, aur_19), la Luna al
/// portale del cielo di nascita (aur_6), il Sigillo alla sua schermata
/// (cal_6).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const carta = NatalChart(
    sunSign: Zodiac.aries,
    planets: [],
    ascendantLongitude: 205.0,
    midheavenLongitude: 115.0,
    houses: [],
    hasTime: true,
  );

  Future<DiarioDelCammino> diarioVergine() async {
    SharedPreferences.setMockInitialValues(const {'onboarding.done': true});
    final diario =
        DiarioDelCammino(orologio: () => DateTime(2026, 8, 23, 12));
    await diario.carica();
    return diario;
  }

  Future<List<String>> siAccendonoDopo(
      DiarioDelCammino diario, List<String> gesti) async {
    for (final g in gesti) {
      await diario.segna(g);
    }
    final stato = diario.statoDelCammino(
      carta: carta,
      segno: Zodiac.aries,
      seriePerRito: diario.seriePerRito,
      pezziDellIdentita: RegiaDelCammino.pezziDellIdentitaMaturi(diario, true),
    );
    final nuovi = await diario.quelliCheSiAccendono(stato);
    for (final t in nuovi) {
      diario.accendi(t.id);
    }
    return nuovi.map((t) => t.id).toList();
  }

  test('BD.05: alla fine dell\'onboarding matura UN gradino solo', () async {
    final diario = await diarioVergine();
    final accesi = await siAccendonoDopo(diario, ['carta_natale']);
    // ignore: avoid_print
    print('ORDINE BD VOCE 05: alla fine dell\'onboarding si accende $accesi');
    expect(accesi, ['med_1'],
        reason: 'alla fine dell\'onboarding devono accendersi la carta nata '
            'e NIENT\'ALTRO: si e\' acceso $accesi');
  });

  test('BD.05: aprire il documento non matura piu\' il blocco', () async {
    final diario = await diarioVergine();
    await siAccendonoDopo(diario, ['carta_natale']);
    final accesi =
        await siAccendonoDopo(diario, ['passaporto', 'numero_della_vita']);
    // ignore: avoid_print
    print('ORDINE BD VOCE 05: aprendo il documento si accende $accesi');
    expect(accesi, isNot(contains('med_7')),
        reason: 'la nascita completa matura aprendo la PROPRIA CARTA, non il '
            'documento');
    expect(accesi, isNot(contains('aur_6')),
        reason: 'la Luna natale matura al portale del cielo, non col '
            'documento');
    expect(accesi, isNot(contains('cal_6')),
        reason: 'il Sigillo del Cerchio matura alla sua schermata, non col '
            'documento');
  });

  test('BD.05: ogni porta accende il suo gradino', () async {
    final diario = await diarioVergine();
    await siAccendonoDopo(diario, ['carta_natale']);
    final porte = <String, (List<String>, String)>{
      'aur_5': (['nome_proprio'], 'il primo saluto per nome'),
      'aur_10': (['passaporto', 'numero_della_vita'], 'il documento aperto'),
      'med_7': (
        ['carta_natale', 'ora_di_nascita', 'luogo_di_nascita'],
        'la propria carta aperta'
      ),
      'aur_6': (['luna_natale'], 'il portale del cielo di nascita'),
      'cal_6': (['sigillo_del_cerchio'], 'la schermata del Sigillo'),
    };
    for (final voce in porte.entries) {
      final accesi = await siAccendonoDopo(diario, voce.value.$1);
      // ignore: avoid_print
      print('ORDINE BD VOCE 05: ${voce.value.$2} accende $accesi');
      expect(accesi, contains(voce.key),
          reason: '${voce.value.$2} non accende ${voce.key}: la porta si e\' '
              'chiusa');
    }
  });

  test('BD.05: le porte del passaporto segnano i gesti giusti nel codice', () {
    // **LE PORTE VIVONO NELLE SCHERMATE**, e questa prova le tiene li':
    // se domani qualcuno riportasse carta, ora e luogo all'apertura del
    // documento, il blocco tornerebbe senza che nessun conto se ne accorga.
    final passaporto =
        File('lib/features/passport/cosmic_passport_screen.dart')
            .readAsStringSync();
    final apertura = passaporto.substring(
        0, passaporto.indexOf('Widget build(BuildContext context)'));
    for (final vietato in const [
      "'carta_natale'",
      "'ora_di_nascita'",
      "'luogo_di_nascita'"
    ]) {
      expect(apertura.contains(vietato), isFalse,
          reason: 'l\'apertura del documento segna di nuovo $vietato: i '
              'gradini tornerebbero a maturare in blocco');
    }
    expect(passaporto.contains("'luna_natale'"), isTrue,
        reason: 'il portale del cielo non segna piu\' la Luna natale');
    expect(passaporto.contains("'sigillo_del_cerchio'"), isTrue,
        reason: 'la schermata del Sigillo non segna piu\' il suo gesto');
    final saluto = File('lib/features/santuario/greeting_banner.dart')
        .readAsStringSync();
    expect(saluto.contains("'nome_proprio'"), isTrue,
        reason: 'il saluto non segna piu\' il nome custodito');
    final risveglio = File('lib/features/onboarding/risveglio_journey.dart')
        .readAsStringSync();
    expect(risveglio.contains("'carta_natale'"), isTrue,
        reason: 'la fine del Risveglio non segna piu\' la carta nata: '
            'nessuna festa alla fine dell\'onboarding');
  });
}
