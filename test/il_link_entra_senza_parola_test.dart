// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/identity/account_del_cerchio.dart';
import 'package:esoteric_circle/core/identity/cio_che_e_tuo.dart';
import 'package:esoteric_circle/core/identity/link_di_ingresso.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cardinale_minimo.dart';
import 'sorgenti_di_lib.dart';

/// IL LINK ENTRA, SENZA PAROLA. Ordine EA voce 19, 20 settembre 2026.
///
/// **La scelta del fondatore**: *"Link piu' App Check"*, e la ragione con cui
/// l'ha chiesta: *"la soluzione piu' veloce e che disturba meno l'utente"*.
/// Si scrive l'indirizzo, arriva un messaggio, si tocca il link e si e'
/// dentro: nessuna parola da inventare, nessuna da ricordare, nessuna da
/// perdere. L'indirizzo risulta verificato per costruzione, perche' il link
/// ci e' arrivato davvero.
///
/// **Cosa pretende questa guardia**: che la via dell'email non chieda piu'
/// una parola, che il link sappia dove tornare e in quale app, che l'app
/// dichiari quel dominio come suo su tutti e due i sistemi, e che
/// l'indirizzo a cui il link e' stato mandato se ne vada con chi cancella i
/// propri dati.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('la via dell\'email non chiede piu\' nessuna parola', () {
    final custodia = senzaCommenti(
        File('lib/features/account/custodia_del_cielo.dart')
            .readAsStringSync());
    for (final segno in const [
      'custodia_parola_campo',
      'custodia_parola_persa',
      '_FoglioDellEmail',
    ]) {
      expect(custodia.contains(segno), isFalse,
          reason: 'e\' tornato il foglio con la parola: $segno');
    }
    expect(custodia.contains("Key('custodia_email_campo')"), isTrue,
        reason: 'il campo dell\'indirizzo non c\'e\' piu\'');
    expect(custodia.contains('mandaIlLinkDIngresso'), isTrue,
        reason: 'la via dell\'email non manda nessun link');
  });

  test('il link sa dove tornare, e in quale app', () {
    final dove = impostazioniDelLink();
    print('ORDINE EA VOCE 19: il link torna a ${dove.url}, '
        'app ${dove.androidPackageName} e ${dove.iOSBundleId}');
    expect(dove.url, indirizzoDelRitorno);
    expect(dove.url.startsWith('https://'), isTrue,
        reason: 'un link d\'ingresso su http si potrebbe leggere per strada');
    expect(dove.handleCodeInApp, isTrue,
        reason: 'senza questo il link aprirebbe una pagina web invece '
            'dell\'app, ed e\' tutto il senso della via scelta');
    expect(dove.androidPackageName, pacchettoAndroid);
    expect(dove.iOSBundleId, pacchettoApple);
    // E i due nomi sono quelli veri dei due progetti, non due copie che un
    // giorno divergono.
    final gradle = File('android/app/build.gradle.kts').readAsStringSync();
    expect(gradle.contains('applicationId = "$pacchettoAndroid"'), isTrue,
        reason: 'il nome dell\'app Android non e\' quello del link');
    final xcode =
        File('ios/Runner.xcodeproj/project.pbxproj').readAsStringSync();
    expect(
        xcode.contains('PRODUCT_BUNDLE_IDENTIFIER = $pacchettoApple;'), isTrue,
        reason: 'il nome dell\'app iPhone non e\' quello del link');
  });

  test('i due sistemi dichiarano quel dominio come nostro', () {
    final manifesto =
        File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    expect(manifesto.contains('android:autoVerify="true"'), isTrue,
        reason: 'Android non verifica il dominio, e il link aprirebbe il '
            'browser');
    expect(manifesto.contains('android:host="esotericircle.app"'), isTrue);
    expect(manifesto.contains('android:pathPrefix="/entra"'), isTrue);
    final diritti = File('ios/Runner/Runner.entitlements').readAsStringSync();
    expect(diritti.contains('applinks:esotericircle.app'), isTrue,
        reason: 'iPhone non dichiara il dominio: il link aprirebbe Safari');
  });

  test('l\'indirizzo del link se ne va con chi cancella i propri dati',
      () async {
    expect(MemoriaDellEmailDelLink.chiave.startsWith('ingresso.'), isTrue);
    final prefissi = CioCheETuo.prefissi;
    cardinaleMinimo(prefissi.length, 10,
        cosa: 'prefissi delle chiavi che sono di chi usa l\'app',
        perche: 'Se l\'elenco si svuota, questa prova direbbe di si\' a '
            'qualunque chiave.');
    expect(prefissi.any((p) => MemoriaDellEmailDelLink.chiave.startsWith(p)),
        isTrue,
        reason: 'l\'indirizzo a cui e\' stato mandato il link '
            'sopravvivrebbe a chi se ne va');

    SharedPreferences.setMockInitialValues(const {});
    await MemoriaDellEmailDelLink.segna('  mauro@esempio.it ');
    expect(await MemoriaDellEmailDelLink.letta(), 'mauro@esempio.it',
        reason: 'l\'indirizzo non si ricorda, e al ritorno il link non si '
            'puo\' usare');
    await MemoriaDellEmailDelLink.dimentica();
    expect(await MemoriaDellEmailDelLink.letta(), isNull);
  });

  test('senza Firebase la porta dice di no, e non finge', () async {
    const assente = IdentitaAssente();
    expect(await assente.mandaIlLinkDIngresso('mauro@esempio.it'),
        EsitoDellaCustodia.nonRiuscita);
    expect(
        assente.eUnLinkDIngresso('https://esotericircle.app/entra'), isFalse);
    expect(
        await assente.entraColLink(
            link: 'https://esotericircle.app/entra', email: 'x@y.it'),
        EsitoDellaCustodia.nonRiuscita);
  });
}
