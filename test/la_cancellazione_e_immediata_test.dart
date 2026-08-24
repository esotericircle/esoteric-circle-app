import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// LA CANCELLAZIONE E' IMMEDIATA, E NIENTE TORNA DA SOLO. Ordine BE voce 07.
///
/// **Sequenza del fondatore sulla 2199**: dati cancellati, app disinstallata,
/// build nuova senza account, e alla fine dell'onboarding 270 Eos e
/// traguardi accesi. **La causa**: il backup di Android escludeva le
/// preferenze di Flutter ma NON quelle di Firebase Auth, l'identita' tornava
/// dal backup e il server le rendeva tutto, perche' l'azzeramento puliva
/// solo il telefono.
///
/// **E la decisione che sostituisce i trenta giorni**: "se l'utente cancella
/// l'account lo cancella subito e con tutti i dati".
void main() {
  test('BE.07: il backup di Android e\' spento del tutto', () {
    final manifesto =
        File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    expect(manifesto.contains('android:allowBackup="false"'), isTrue,
        reason: 'il backup di Android e\' tornato acceso: alla '
            'reinstallazione l\'identita\' tornerebbe da sola e con lei i '
            'dati cancellati (ordine BE voce 07)');
    for (final regole in const [
      'android/app/src/main/res/xml/backup_rules.xml',
      'android/app/src/main/res/xml/data_extraction_rules.xml',
    ]) {
      final testo = File(regole).readAsStringSync();
      expect(testo.contains('path="."'), isTrue,
          reason: '$regole non esclude piu\' tutto: basta un file di '
              'preferenze ripristinato per far tornare l\'identita\'');
    }
  });

  test('BE.07: l\'azzeramento dei dati passa anche dal server', () {
    final schermata =
        File('lib/features/account/account_screen.dart').readAsStringSync();
    // **BH.06**: la porta adesso porta anche il perche' del congedo.
    expect(schermata.contains('porta.azzeraIDatiDicendo(perche)'), isTrue,
        reason: 'la voce "cancella i tuoi dati" e\' tornata a pulire solo '
            'il telefono: il ramo sul server resterebbe e al ritorno '
            'dell\'identita\' renderebbe tutto');
    // E se il server non risponde ci si ferma e lo si dice.
    expect(schermata.contains("Key('azzera_non_riuscito')"), isTrue,
        reason: 'l\'azzeramento fallito sul server non si dice piu\'');
  });

  test('BE.07: prima della cancellazione si guarda se un account esiste', () {
    final schermata =
        File('lib/features/account/account_screen.dart').readAsStringSync();
    expect(schermata.contains("Key('oblio_nessun_account')"), isTrue,
        reason: 'la cancellazione non controlla piu\' se un account '
            'esiste: a chi non ha custodito niente offrirebbe di cancellare '
            'cio\' che non c\'e\'');
  });

  test('BE.07: la cancellazione chiama la porta immediata, non l\'attesa', () {
    final schermata =
        File('lib/features/account/account_screen.dart').readAsStringSync();
    // **BH.06**: la porta adesso porta anche il perche' del congedo.
    expect(schermata.contains('porta.cancellaIlCerchioDicendo(perche)'), isTrue,
        reason: 'la cancellazione non passa piu\' dalla porta immediata');
    expect(schermata.contains('chiediLOblio()'), isFalse,
        reason: 'la schermata chiama ancora la richiesta coi trenta giorni, '
            'che il fondatore ha abolito');
    // E il server non esporta piu\' le porte dell\'attesa.
    final indice = File('functions/src/index.ts').readAsStringSync();
    // Le morte si cercano come VOCI D'EXPORT (due spazi e virgola), non
    // come parole: la lapide nel commento le nomina apposta.
    for (final morta in const [
      '\n  chiediLOblio,',
      '\n  annullaLOblio,',
      'export {cancellaGliOblioScaduti}'
    ]) {
      expect(indice.contains(morta), isFalse,
          reason: 'il server esporta ancora $morta: i trenta giorni sono '
              'stati aboliti');
    }
  });

  test('BE.07: il primo avviso senza account non aspetta i momenti', () {
    final regola =
        File('lib/core/identity/quando_chiedere_la_custodia.dart')
            .readAsStringSync();
    expect(regola.contains('maiAvvisato'), isTrue,
        reason: 'il primo avviso e\' tornato ad aspettare i momenti: chi '
            'entra senza account non lo saprebbe (ordine BE voce 07, '
            'punto 1)');
  });
}
