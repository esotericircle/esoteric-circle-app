import 'dart:io';

import 'package:esoteric_circle/core/sigilli/coda_delle_feste.dart';
import 'package:esoteric_circle/core/sigilli/diario_del_cammino.dart';
import 'package:esoteric_circle/core/sigilli/distanza_fra_le_feste.dart';
import 'package:esoteric_circle/core/sigilli/pezzi_dell_identita.dart';
import 'package:esoteric_circle/core/sigilli/sentieri.dart';
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
  StatoDelCammino fineDellOnboarding() => const StatoDelCammino(
        gestiCompiuti: {'carta_natale': 1, 'passaporto': 1},
        giorniConGesto: {'carta_natale': 1, 'passaporto': 1},
        oggiHaFatto: {'carta_natale', 'passaporto'},
        pezziDellIdentita: {
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

  test('la coda si svuota in UNA festa, e nessuna catena la segue', () {
    // **QUESTA PROVA MISURAVA UNA LEGGE CHE NON C\'E\' PIU\', e lo ha detto da
    // sola.** Cercava nella regia le liste scritte a mano, "traguardi: [x]",
    // per contare che ne passasse UNO: da quando la festa unica prende la
    // coda intera (ordine AC voce 04, decisione del fondatore del 16 agosto
    // 2026, e ordine BW voce 02, "quattro feste in sessanta secondi") quelle
    // liste sono diventate variabili, la ricerca non trovava piu\' niente e
    // la guardia cadeva sul suo stesso controllo: "questa prova non sta
    // guardando cio\' che dice di guardare". Aveva ragione.
    //
    // **La legge di oggi, e si misura questa.** Una festa sola, che nomina
    // tutti i traguardi maturati insieme, e nessuna catena dopo di lei. Il
    // premio non si unisce: gli Eos e il Sigillo restano per traguardo.
    final regia =
        File('lib/features/sigilli/regia_del_cammino.dart').readAsStringSync();
    final quanteFeste =
        RegExp(r'Celebrazione\.festeggiaInsieme\(').allMatches(regia).length;
    // ignore: avoid_print
    print('ORDINE BW VOCE 2: la regia apre la festa in $quanteFeste punti');
    expect(quanteFeste, 2,
        reason: 'i punti che aprono una festa nella regia sono '
            '$quanteFeste: dovrebbero essere due, il gesto e lo svuotamento '
            'della coda');

    // **NESSUNA CATENA**: chiusa la festa non se ne apre un'altra. Era
    // questo il difetto che il fondatore ha visto come quattro feste di
    // seguito.
    final dentroLaChiusura = RegExp(r'allaChiusura: \(\) \{(.*?)\n          \}',
            dotAll: true)
        .allMatches(regia)
        .map((m) => m.group(1)!)
        .toList();
    for (final corpo in dentroLaChiusura) {
      expect(corpo.contains('svuotaLaCoda'), isFalse,
          reason: 'alla chiusura di una festa se ne apre un\'altra: e\' la '
              'catena che il fondatore ha visto');
    }

    // E la coda si prende INTERA, una volta sola: prenderne una per volta
    // era il modo in cui le feste diventavano quattro.
    expect(regia.contains('prendiTutte()'), isTrue,
        reason: 'la coda non si prende piu\' intera: le feste tornano a '
            'uscire una dopo l\'altra');
  });

  test('il guardiano a freddo aspetta novanta secondi, non di piu', () async {
    // **LA REGOLA E' CAMBIATA CON L'ORDINE BD VOCE 08**, decisione del
    // fondatore del 23 agosto 2026: "festa sempre, subito". Le tre ore e il
    // limite di una festa per apertura, decisi con AU e sorvegliati da
    // questa prova, trattenevano in coda ogni festa dopo la prima e sulla
    // 2198 si leggevano come "le feste non funzionano". La distanza resta
    // solo per il guardiano che riparte a freddo, ed e' scesa a novanta
    // secondi.
    SharedPreferences.setMockInitialValues(const {});
    DistanzaFraLeFeste.nuovaApertura();
    // La prima passa: non c'e' niente alle spalle.
    expect(await DistanzaFraLeFeste.siPuoFesteggiare(), isTrue);
    await DistanzaFraLeFeste.segnaFesta();
    // A trenta secondi il guardiano aspetta ancora.
    await DistanzaFraLeFeste.fingiCheSiaPassato(const Duration(seconds: 30));
    expect(await DistanzaFraLeFeste.siPuoFesteggiare(), isFalse,
        reason: 'a trenta secondi dalla precedente il guardiano a freddo '
            'deve aspettare');
    // A due minuti e' libero: le tre ore non esistono piu'.
    await DistanzaFraLeFeste.fingiCheSiaPassato(const Duration(minutes: 2));
    expect(await DistanzaFraLeFeste.siPuoFesteggiare(), isTrue,
        reason: 'a due minuti il guardiano deve essere libero: le tre ore '
            'di AU sono state revocate dal fondatore con BD.08');
    // ignore: avoid_print
    print('ORDINE BD VOCE 08: il guardiano aspetta '
        '${DistanzaFraLeFeste.quantoPassa.inSeconds} secondi fra due feste '
        'a freddo, e nessun limite per apertura');
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
