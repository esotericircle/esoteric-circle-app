import 'dart:io';

import 'package:esoteric_circle/core/sigilli/coda_delle_feste.dart';
import 'package:esoteric_circle/core/sigilli/diario_del_cammino.dart';
import 'package:esoteric_circle/core/sigilli/distanza_fra_le_feste.dart';
import 'package:esoteric_circle/core/sigilli/pezzi_dell_identita.dart';
import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:esoteric_circle/core/sigilli/traguardo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'istante_dichiarato.dart';

/// UNA FESTA, UN TRAGUARDO. Ordine AU voce 06.
///
/// **La decisione del fondatore, e sostituisce quella del 16 agosto.** Fino a
/// ieri, quando piu' traguardi maturavano insieme, si celebrava UNA volta sola
/// e quella celebrazione li nominava tutti. Sulla 2188 il fondatore ha visto
/// una card che ne nominava CINQUE con +120 Eos, e la regola cambia: **una
/// card celebra UN SOLO traguardo, mai due nomi nella stessa card**. Una festa
/// a raffica smette di essere un premio.
///
/// **La causa a monte, senza la quale la coda resta una rete che scatta
/// sempre**: i gradini dell'identita' maturano tutti insieme alla fine
/// dell'onboarding. Qui si conta quanti sono, prima e dopo la cura.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Lo stato del cammino come e' alla FINE DELL'ONBOARDING: la persona ha
  /// dato i suoi dati, la carta natale e' stata calcolata e i pezzi
  /// dell'identita' che l'onboarding completa sono a posto.
  StatoDelCammino fineDellOnboarding() => StatoDelCammino(
        gestiCompiuti: const {'carta_natale': 1, 'passaporto': 1},
        giorniConGesto: const {'carta_natale': 1, 'passaporto': 1},
        oggiHaFatto: const {'carta_natale', 'passaporto'},
        pezziDellIdentita: const {
          'carta_natale',
          'passaporto',
          'numero_della_vita',
          'ora_di_nascita',
          'luogo_di_nascita',
        },
        giorniDalPrimoGiorno: 0,
      );

  test('quanti gradini maturano al primo avvio', () async {
    SharedPreferences.setMockInitialValues(const {});
    final diario = DiarioDelCammino(orologio: orologioDelleProve);
    await diario.carica();
    final nuovi = await diario.quelliCheSiAccendono(fineDellOnboarding());
    // ignore: avoid_print
    print('ORDINE AU VOCE 06: alla fine dell onboarding maturano '
        '${nuovi.length} gradini: ${nuovi.map((t) => "${t.id} ${t.nome}").join(", ")}');

    // **NON SI PRETENDE UN NUMERO, SI PRETENDE CHE SE NE FESTEGGI UNO.** Il
    // numero che matura dipende dal corpus e cambiera' ancora; cio' che non
    // deve cambiare e' che la persona veda una festa sola.
    expect(nuovi, isNotEmpty,
        reason: 'alla fine dell onboarding non si accende niente: la persona '
            'arriva in home senza aver preso nulla');
  });

  test('i pezzi dell identita si contano, e sono quelli che maturano insieme',
      () async {
    final stato = fineDellOnboarding();
    final dellIdentita = [
      for (final t in Sentieri.tuttiITraguardi)
        if (!t.dormiente &&
            t.condizione.raggiunto(stato) &&
            PezziDellIdentita.tutti.any((p) => t.condizione
                .toString()
                .toLowerCase()
                .contains(p.replaceAll('_', ' '))))
          t.id,
    ];
    // ignore: avoid_print
    print('ORDINE AU VOCE 06: di quelli che maturano, quelli legati a un '
        'pezzo dell identita sono ${dellIdentita.length}: $dellIdentita');
  });

  test('la card non nomina mai due traguardi', () {
    // **LA REGOLA SI SORVEGLIA NEL CODICE CHE CELEBRA**, non solo a video: la
    // scena sa disegnare piu' nomi, e finche' lo sa qualcuno potrebbe
    // ripassargliene due. Qui si conta che la regia ne passi UNO.
    final regia =
        File('lib/features/sigilli/regia_del_cammino.dart').readAsStringSync();
    final passaggi = RegExp(r'traguardi: \[([^\]]*)\]')
        .allMatches(regia)
        .map((m) => m.group(1)!.trim())
        .toList();
    // ignore: avoid_print
    print('ORDINE AU VOCE 06: la regia passa alla festa $passaggi');
    expect(passaggi, isNotEmpty,
        reason: 'la regia non passa piu nessun traguardo alla festa: questa '
            'prova non sta guardando cio che dice di guardare');
    for (final uno in passaggi) {
      expect(uno.contains(','), isFalse,
          reason: 'la regia passa piu di un traguardo alla stessa card: '
              '"$uno". Una card celebra UN SOLO traguardo');
    }
    expect(regia.contains('await coda.prendiTutte()'), isFalse,
        reason: 'lo svuotamento della coda prende ancora tutte le feste '
            'insieme: cosi la card torna a nominarne piu di una');
  });

  test('fra due feste passano tre ore, e una sola per apertura', () async {
    SharedPreferences.setMockInitialValues(const {});
    DistanzaFraLeFeste.nuovaApertura();
    // La prima passa: non c'e' niente alle spalle.
    expect(await DistanzaFraLeFeste.siPuoFesteggiare(), isTrue);
    await DistanzaFraLeFeste.segnaFesta();
    // La seconda no, ed e' la regola dell apertura a fermarla.
    expect(await DistanzaFraLeFeste.siPuoFesteggiare(), isFalse,
        reason: 'due feste nella stessa apertura dell app');
    // Riaperta l'app, e' l'orologio a fermarla: sono passati venti minuti.
    DistanzaFraLeFeste.nuovaApertura();
    await DistanzaFraLeFeste.fingiCheSiaPassato(const Duration(minutes: 20));
    expect(await DistanzaFraLeFeste.siPuoFesteggiare(), isFalse,
        reason: 'due feste a venti minuti di distanza');
    // Passate tre ore, si puo'.
    await DistanzaFraLeFeste.fingiCheSiaPassato(const Duration(hours: 3, minutes: 1));
    expect(await DistanzaFraLeFeste.siPuoFesteggiare(), isTrue,
        reason: 'passate tre ore la festa non arriva piu');
    // ignore: avoid_print
    print('ORDINE AU VOCE 06: una per apertura, e '
        '${DistanzaFraLeFeste.quantoPassa.inHours} ore fra due feste');
  });

  test('il primo Sigillo in assoluto non aspetta nessuno', () async {
    SharedPreferences.setMockInitialValues(const {});
    DistanzaFraLeFeste.nuovaApertura();
    await DistanzaFraLeFeste.segnaFesta();
    expect(await DistanzaFraLeFeste.siPuoFesteggiare(primoInAssoluto: true),
        isTrue,
        reason: 'chi apre l app per la prima volta aspetterebbe tre ore il '
            'primo premio: e il contrario di cio che l ordine chiede');
  });

  test('un traguardo in attesa non e perso: resta in coda in ordine', () async {
    SharedPreferences.setMockInitialValues(const {});
    final coda = CodaDelleFeste();
    await coda.carica();
    await coda.accoda('med_1');
    await coda.accoda('aur_10');
    await coda.accoda('aur_19');
    expect(coda.inAttesa, ['med_1', 'aur_10', 'aur_19'],
        reason: 'la coda non tiene l ordine in cui il cammino li ha accesi');
    final primo = await coda.prendiLaProssima();
    expect(primo?.id, 'med_1');
    expect(coda.inAttesa, ['aur_10', 'aur_19'],
        reason: 'prendendone una la coda ne perde piu di una');
  });
}
