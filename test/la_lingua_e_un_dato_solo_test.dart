import 'package:esoteric_circle/core/chat/la_marca_del_genere.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/identity/cio_che_e_tuo.dart';
import 'package:esoteric_circle/core/l10n/app_strings.dart';
import 'package:esoteric_circle/core/l10n/la_lingua_del_cerchio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'sorgenti_di_lib.dart';

/// LA LINGUA E' UN DATO SOLO. Ordine DM voci 01 e 05.
///
/// **Il fatto misurato prima di quest'ordine**: la lingua non era un dato, era
/// **tre cose scollegate**. `AppStrings.languageCode` diceva `'it'` e nessuno
/// lo scriveva; `LaMarcaDelGenere.lingua` diceva italiano e **nessun file di
/// `lib` lo scriveva mai**; i widget di sistema non sapevano niente e
/// parlavano inglese.
///
/// **La grandezza misurata non e' che la porta funzioni**, che sarebbe facile:
/// e' che **nessun altro scriva quelle due variabili**. Una porta unica che
/// qualcuno puo' scavalcare non e' una porta unica, e' una convenzione, e le
/// convenzioni in questo progetto durano fino al primo che ha fretta.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(LaLinguaDelCerchio.dimentica);

  test('la lingua scende dove serve, e ci scende da un posto solo', () {
    LaLinguaDelCerchio.faiValere(LinguaDelCerchio.inglese);
    expect(AppStrings.languageCode, 'en');
    expect(LaMarcaDelGenere.lingua, isA<LinguaSenzaGenere>());
    expect(LaLinguaDelCerchio.corrente.value, LinguaDelCerchio.inglese);

    LaLinguaDelCerchio.faiValere(LinguaDelCerchio.italiano);
    expect(AppStrings.languageCode, 'it');
    expect(LaMarcaDelGenere.lingua, isA<LinguaItaliana>());
  });

  test('IN UNA LINGUA SENZA GENERE LA MARCA RENDE IL NEUTRO', () {
    // Ordine DM voce 05. `LinguaSenzaGenere` esisteva dall'ordine DL e non la
    // collegava nessuno: era una porta murata.
    LaLinguaDelCerchio.faiValere(LinguaDelCerchio.inglese);
    LaMarcaDelGenere.formaCorrente = CourtesyForm.feminine;
    addTearDown(() => LaMarcaDelGenere.formaCorrente = CourtesyForm.unknown);
    expect(
      LaMarcaDelGenere.scegli(
          maschile: 'sceso', femminile: 'scesa', neutro: 'qui'),
      'qui',
      reason: 'in inglese la marca ha scelto una forma di genere: quella '
          'lingua le tre forme non le ha',
    );
    LaLinguaDelCerchio.faiValere(LinguaDelCerchio.italiano);
    expect(
      LaMarcaDelGenere.scegli(
          maschile: 'sceso', femminile: 'scesa', neutro: 'qui'),
      'scesa',
      reason: 'in italiano la marca ha smesso di scegliere il femminile',
    );
  });

  test('la lingua si ricorda fra un avvio e l\'altro', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await LaLinguaDelCerchio.scegli(LinguaDelCerchio.inglese, prefs: prefs);
    expect(prefs.getString(LaLinguaDelCerchio.chiave), 'en');

    // Il telefono si spegne: la porta torna al suo valore di partenza.
    LaLinguaDelCerchio.dimentica();
    expect(AppStrings.languageCode, 'it');

    // E si riaccende.
    await LaLinguaDelCerchio.risveglia(prefs: prefs);
    expect(LaLinguaDelCerchio.corrente.value, LinguaDelCerchio.inglese,
        reason: 'la lingua scelta non e sopravvissuta allo spegnimento');
    expect(AppStrings.languageCode, 'en');
  });

  test('L\'ITALIANO RESTA IL DEFAULT, e non lo decide il telefono', () async {
    // **Il comportamento visibile in italiano non cambia di un carattere.**
    // Un'app che al primo avvio dopo l'aggiornamento leggesse la lingua del
    // telefono metterebbe in inglese chi ha sempre letto in italiano, e
    // sarebbe esattamente il cambiamento che quest'ordine vieta.
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await LaLinguaDelCerchio.risveglia(prefs: prefs);
    expect(LaLinguaDelCerchio.corrente.value, LinguaDelCerchio.italiano);
    expect(AppStrings.languageCode, 'it');
  });

  test('e una lingua che non conosciamo non rompe niente', () async {
    SharedPreferences.setMockInitialValues(
        {LaLinguaDelCerchio.chiave: 'klingon'});
    final prefs = await SharedPreferences.getInstance();
    await LaLinguaDelCerchio.risveglia(prefs: prefs);
    expect(LaLinguaDelCerchio.corrente.value, LinguaDelCerchio.italiano,
        reason: 'un codice sconosciuto deve cadere sull italiano, non '
            'sollevare: quel valore puo arrivare da un telefono di ieri');
  });

  test('LA CHIAVE STA NELLA VERITA\' UNICA DI CIO\' CHE E\' SULLA MACCHINA',
      () {
    // Ordine DM voce 01, e vale la lezione dell'ordine DR: una chiave che non
    // e' ne' tua ne' dichiarata non la cancella nessuna via e non la consegna
    // nessuno a chi chiede i propri dati.
    expect(
      CioCheETuo.eTua(LaLinguaDelCerchio.chiave) ||
          CioCheETuo.restano.keys.any(LaLinguaDelCerchio.chiave.startsWith),
      isTrue,
      reason: 'la chiave della lingua, ${LaLinguaDelCerchio.chiave}, non e '
          'dichiarata da nessuna parte in CioCheETuo',
    );
  });

  test('NESSUNO SCRIVE LA LINGUA FUORI DALLA SUA PORTA', () {
    // **E' l'invariante che tiene in piedi tutto il resto.** Le due variabili
    // che la lingua governa sono pubbliche e statiche, quindi chiunque puo'
    // scriverle: se qualcuno lo fa, la lingua torna a essere due verita' e
    // l'app puo' trovarsi con l'interfaccia in una lingua e la marca del
    // genere in un'altra.
    const laPorta = 'lib/core/l10n/la_lingua_del_cerchio.dart';
    final colpevoli = <String>[];
    var guardati = 0;
    for (final f in sorgentiDiLib()) {
      final percorso = f.path.replaceAll('\\', '/');
      guardati++;
      if (percorso.endsWith(laPorta)) continue;
      // Il file che DICHIARA la variabile non la sta scrivendo da fuori.
      final dichiara = percorso.endsWith('la_marca_del_genere.dart') ||
          percorso.endsWith('app_strings.dart');
      final testo = f.readAsStringSync();
      for (final riga in testo.split('\n')) {
        final pulita = riga.trim();
        if (pulita.startsWith('//') || pulita.startsWith('///')) continue;
        if (dichiara) continue;
        if (RegExp(r'AppStrings\.languageCode\s*=').hasMatch(pulita) ||
            RegExp(r'LaMarcaDelGenere\.lingua\s*=').hasMatch(pulita)) {
          colpevoli.add('$percorso: $pulita');
        }
      }
    }
    expect(guardati, greaterThanOrEqualTo(500),
        reason: 'guardati solo $guardati file di lib: questa prova stava per '
            'dire il vero su niente');
    expect(colpevoli, isEmpty,
        reason: 'queste righe scrivono la lingua scavalcando la sua porta, e '
            'da qui la lingua torna a essere due verita:\n  '
            '${colpevoli.join("\n  ")}');
  });
}
