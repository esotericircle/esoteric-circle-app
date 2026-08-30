import 'dart:io';

import 'package:esoteric_circle/core/astro/city_catalog.dart';
import 'package:esoteric_circle/core/cammino/cammino_da_custodire.dart';
import 'package:esoteric_circle/core/cammino/ritrovamento.dart';
import 'package:flutter_test/flutter_test.dart';

/// CHI RIENTRA ARRIVA IN HOME. Ordine CF voce 06.
///
/// **Il fatto del fondatore, verbatim**: "sono rimasto alla piena schermata
/// del risveglio anziche' portarmi alla home." E' successo dopo aver
/// reinstallato e riscritto un'email gia' registrata.
///
/// **La causa, misurata sul ramo.** L'uscita dal rito passa da
/// `Ritrovamento.siSalta`, che e' vero solo quando non resta niente da
/// chiedere. In quell'elenco c'era l'ORA, che nel Cerchio e' un dato
/// facoltativo per costruzione: chi al rito aveva risposto "non la so" aveva
/// `ora` nulla per sempre, quindi non c'era nessuna risposta che potesse
/// liberarlo, e a ogni reinstallazione rifaceva il rito intero.
///
/// **La prova monta il caso vero e non un caso comodo**: un'identita'
/// custodita completa tranne l'ora, che e' esattamente la forma in cui la
/// custodia torna per chi l'ora non l'ha data.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    CityCatalog.adotta(
        CityCatalog.parse(File('assets/data/luoghi.csv').readAsStringSync()));
  });

  Ritrovamento conIdentita(IdentitaDaCustodire identita) => Ritrovamento.da(
        CamminoDaCustodire(identita: identita, sigilli: const {}),
        saldoEos: 715,
      );

  test('senza l\'ora il rito si salta lo stesso', () {
    final r = conIdentita(IdentitaDaCustodire(
      nome: 'Mauro',
      giorno: DateTime(1972, 5, 20),
      luogo: 'Roma, Italia',
      latitudine: 41.9,
      longitudine: 12.5,
      fuso: 'Europe/Rome',
    ));
    // ignore: avoid_print
    print('ORDINE CF VOCE 06: senza l\'ora restano da chiedere '
        '${r.passiDaChiedere} e il rito si salta ${r.siSalta}');
    expect(r.siSalta, isTrue,
        reason: 'con giorno, luogo e nome custoditi il rito non si salta: chi '
            'rientra resta dentro il Risveglio invece di arrivare in home, e '
            'per chi l\'ora non la sa non c\'e\' nessuna risposta che lo '
            'liberi');
  });

  test('senza il giorno il rito NON si salta', () {
    // **LA CONTROPROVA, e senza di lei la prima si otterrebbe svuotando
    // l'elenco.** Cio' che trattiene deve continuare a trattenere: senza il
    // giorno non c'e' nessuna carta natale da calcolare.
    final r = conIdentita(const IdentitaDaCustodire(
      nome: 'Mauro',
      luogo: 'Roma, Italia',
    ));
    // ignore: avoid_print
    print('ORDINE CF VOCE 06: senza il giorno restano da chiedere '
        '${r.passiDaChiedere}');
    expect(r.siSalta, isFalse,
        reason: 'senza il giorno di nascita il rito si salta: la persona '
            'entra senza carta natale e nessuno gliela chiede piu\'');
    expect(r.passiDaChiedere, contains(PassoDelRito.data));
  });

  test('senza il luogo il rito NON si salta', () {
    final r = conIdentita(IdentitaDaCustodire(
      nome: 'Mauro',
      giorno: DateTime(1972, 5, 20),
    ));
    expect(r.siSalta, isFalse,
        reason: 'senza il luogo il rito si salta: il cielo si ancora a un '
            'posto che nessuno ha dato');
    expect(r.passiDaChiedere, contains(PassoDelRito.luogo));
  });

  test('il luogo custodito non si richiede piu\' a chi rientra', () {
    // **ORDINE CF VOCE 07, e la prova guarda il sorgente perche' e' li' che
    // il dato si perdeva.** La ripresa del rito riprendeva giorno, ora e
    // nome, e il luogo no: il campo arrivava vuoto e la persona doveva
    // riscrivere cio' che il Cerchio aveva custodito.
    final sorgente = File('lib/features/onboarding/onboarding_screen.dart')
        .readAsStringSync();
    final da = sorgente.indexOf('void _riprendiCioCheIlCerchioSapeva()');
    expect(da, greaterThan(0),
        reason: 'la ripresa del rito non si chiama piu\' cosi\': questa prova '
            'insegue un nome che non c\'e\'');
    final corpo = sorgente.substring(da, sorgente.indexOf('\n  }', da));
    final ripresi = <String, bool>{
      'giorno': corpo.contains('_birthDate = giorno'),
      'ora': corpo.contains('_hour ='),
      'nome': corpo.contains('_nameCtrl.text'),
      'luogo': corpo.contains('_placeCtrl.text'),
    };
    // ignore: avoid_print
    print('ORDINE CF VOCE 07: la ripresa del rito riprende $ripresi');
    final persi = ripresi.entries.where((e) => !e.value).map((e) => e.key);
    expect(persi, isEmpty,
        reason: 'la ripresa del rito non riprende $persi: cio' ' che il '
            'Cerchio ha custodito la persona deve riscriverlo');
  });
}
