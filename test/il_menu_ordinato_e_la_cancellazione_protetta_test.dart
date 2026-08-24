import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// IL MENU UTENTE ORDINATO, E LA CANCELLAZIONE PROTETTA. Ordine BH voce 06.
///
/// Parole del fondatore: "il menu utente in modo che sia ordinato e
/// completo [...] la cancellazione dell'account e dati e anche privacy
/// policy siano in fondo o magari in sotto menu [...] chiedere piu' volte
/// se l'utente e' sicuro e chiedergli perche'".
void main() {
  final sorgente = File('lib/features/account/account_screen.dart')
      .readAsStringSync();

  test('l\'ordine delle voci e\' quello dichiarato, e Privacy sta in fondo',
      () {
    // Si guarda la LISTA MADRE (prima della classe del sottomenu), cosi'
    // le voci del sottomenu non confondono il conto.
    final madre =
        sorgente.substring(0, sorgente.indexOf('class PrivacyEDatiScreen'));
    const ordine = [
      "id: 'profilo'",
      "id: 'nascita'",
      "id: 'custodia'",
      "id: 'verifica_email'",
      "id: 'cambia_parola'",
      "id: 'abbonamento'",
      "id: 'notifiche'",
      "id: 'impostazioni'",
      "id: 'esci'",
      "id: 'privacy_e_dati'",
    ];
    var da = 0;
    for (final voce in ordine) {
      final dove = madre.indexOf(voce, da);
      expect(dove, greaterThanOrEqualTo(0),
          reason: 'la voce $voce non sta piu\' al suo posto nell\'ordine '
              'del menu (o e\' sparita dalla lista madre)');
      da = dove;
    }
    // E le voci delicate NON stanno nella lista madre.
    for (final delicata in const ["id: 'azzera'", "id: 'oblio'"]) {
      expect(madre.contains(delicata), isFalse,
          reason: 'la voce $delicata e\' tornata nella lista madre: il '
              'fondatore la vuole nel sottomenu, lontana dai tocchi '
              'accidentali');
    }
  });

  test('il sottomenu Privacy e dati porta le quattro voci', () {
    final sotto =
        sorgente.substring(sorgente.indexOf('class PrivacyEDatiScreen'));
    for (final voce in const [
      "id: 'policy'",
      "id: 'scarica'",
      "id: 'azzera'",
      "id: 'oblio'",
    ]) {
      expect(sotto.contains(voce), isTrue,
          reason: 'il sottomenu ha perso la voce $voce');
    }
    // E il sottotitolo dell'oblio non promette piu' trenta giorni che
    // non esistono (tolti da BE.07).
    expect(sorgente.contains('Trenta giorni per ripensarci'), isFalse,
        reason: 'il sottotitolo dell\'oblio promette di nuovo trenta '
            'giorni di ripensamento che BE.07 ha tolto');
  });

  test('le due cancellazioni passano dai tre passi e portano il perche\'',
      () {
    // Passo 1: la spiegazione (i dialoghi storici restano). Passo 2: il
    // perche'. Passo 3: l'ultima conferma. Poi la porta col perche'.
    expect(sorgente.contains('_chiediIlPerche(context)'), isTrue);
    expect(sorgente.contains('_neSeiDavveroSicuro(context'), isTrue);
    expect(sorgente.contains('azzeraIDatiDicendo(perche)'), isTrue,
        reason: 'l\'azzera non porta piu\' il perche\' al server');
    expect(sorgente.contains('cancellaIlCerchioDicendo(perche)'), isTrue,
        reason: 'l\'oblio non porta piu\' il perche\' al server');
    // Il no e' sempre possibile e il perche' e' facoltativo per davvero.
    expect(sorgente.contains('Preferisco non dirlo'), isTrue);
    // E l'oblio dice la verita' della lapide prima di cancellare.
    expect(sorgente.contains('il dono di benvenuto non si'), isTrue,
        reason: 'l\'oblio non avverte piu\' che il benvenuto non si ripete');
  });

  test('il congedo si scrive sul server prima di cancellare, anonimo', () {
    final server =
        File('functions/src/cerchio.ts').readAsStringSync();
    expect(server.contains('scriviIlCongedo(request, "dati")'), isTrue);
    expect(server.contains('scriviIlCongedo(request, "account")'), isTrue);
    final congedo = server.substring(
        server.indexOf('async function scriviIlCongedo'),
        server.indexOf('export const azzeraIDatiDelCerchio'));
    expect(congedo.contains('uid'), isFalse,
        reason: 'il congedo scrive l\'uid: il feedback deve restare anonimo');
  });

  test('cancellare i dati non cancella piu\' l\'account', () {
    // Il difetto trovato dalla ricognizione BH: deleteAllData passava da
    // cancellaIlCerchio, quindi TUTTE le strade che promettevano "l'account
    // resta tuo" cancellavano anche l'accesso.
    final memoria =
        File('lib/services/memory/firestore_maestro_memory_repository.dart')
            .readAsStringSync();
    expect(memoria.contains('_porta.azzeraIDati()'), isTrue,
        reason: 'deleteAllData non azzera piu\' dal server');
    expect(memoria.contains('_porta.cancellaIlCerchio()'), isFalse,
        reason: 'deleteAllData cancella di nuovo l\'ACCOUNT: le strade che '
            'promettono di tenerlo tornano a mentire');
  });
}
