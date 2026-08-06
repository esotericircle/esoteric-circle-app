import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// IL PROGETTO IOS DICHIARA FIREBASE, ED E' L'UNICA COSA CHE CI PROTEGGE.
///
/// **Perche' questa prova esiste.** Su iOS un file finisce dentro l'app solo se
/// il progetto Xcode lo dichiara, e un progetto Xcode rotto non si vede fino
/// alla compilazione. Qui la compilazione non si puo' fare: si gira su Windows,
/// e la prima build vera la fara' una macchina Mac in cloud. Fra la modifica e
/// la verifica c'e' quindi questa prova, e nient'altro.
///
/// **Tre cose INSIEME, non una.** Una prova che cercasse il solo nome del file
/// passerebbe anche con un progetto rotto: il caso peggiore e' il file
/// dichiarato e messo nel gruppo ma NON nella fase di copia delle risorse,
/// perche' li' l'app si costruisce, parte, e crolla appena tocca Firebase.
/// Servono percio' tutte e tre: il riferimento di file, l'appartenenza al
/// target Runner, e la fase di copia.
void main() {
  final pbx = File('ios/Runner.xcodeproj/project.pbxproj');
  const nome = 'GoogleService-Info.plist';

  /// Il corpo di una sezione del pbxproj, per nome.
  String sezione(String testo, String quale) {
    final da = testo.indexOf('/* Begin $quale section */');
    final a = testo.indexOf('/* End $quale section */');
    expect(da, greaterThanOrEqualTo(0),
        reason: 'La sezione $quale non esiste nel pbxproj: il file e\' rotto '
            'o ha cambiato forma.');
    expect(a, greaterThan(da));
    return testo.substring(da, a);
  }

  /// Il blocco di un oggetto del pbxproj, dal suo identificativo alla fine
  /// della sua graffa. Serve a leggere una fase o un gruppo per intero.
  String blocco(String testo, String identificativo) {
    final da = testo.indexOf(identificativo);
    expect(da, greaterThanOrEqualTo(0),
        reason: 'L\'oggetto $identificativo non esiste piu\' nel pbxproj.');
    final a = testo.indexOf('};', da);
    return testo.substring(da, a);
  }

  test('il pbxproj esiste e si legge', () {
    expect(pbx.existsSync(), isTrue,
        reason: 'Senza il progetto Xcode non c\'e\' nessuna app iOS.');
  });

  test('UNO: il file e\' un riferimento di file del progetto', () {
    final testo = pbx.readAsStringSync();
    final riferimenti = sezione(testo, 'PBXFileReference');
    expect(riferimenti.contains(nome), isTrue,
        reason: '$nome non compare fra i riferimenti di file: Xcode non sa '
            'che quel file esista, e non lo copiera\' mai da nessuna parte.');
  });

  test('DUE: il file appartiene al gruppo Runner', () {
    // Il gruppo dice DOVE sta il file nel progetto. Senza, il riferimento
    // esisterebbe ma non apparterrebbe a niente: Xcode lo mostra come orfano e
    // chi apre il progetto non lo trova.
    final testo = pbx.readAsStringSync();
    final gruppoRunner =
        blocco(testo, '97C146F01CF9000F007C117D /* Runner */ = {');
    expect(gruppoRunner.contains(nome), isTrue,
        reason: '$nome non sta nel gruppo Runner: il riferimento e\' orfano.');
  });

  test('TRE: il file sta nella fase di copia delle risorse del target Runner',
      () {
    // **E' LA PIU' IMPORTANTE DELLE TRE.** Senza questa, l'app si costruisce
    // e parte, e crolla appena tocca Firebase, perche' il plist non e' dentro
    // il pacchetto. E' anche la sola che una prova sul nome non prenderebbe.
    final testo = pbx.readAsStringSync();
    final risorseRunner =
        blocco(testo, '97C146EC1CF9000F007C117D /* Resources */ = {');
    expect(risorseRunner.contains('$nome in Resources'), isTrue,
        reason: '$nome non e\' nella fase di copia delle risorse del target '
            'Runner: l\'app si costruisce, parte, e crolla appena tocca '
            'Firebase.');
  });

  test('la fase e\' quella di Runner, non quella di RunnerTests', () {
    // Il plist serve all'app, non alle prove unitarie: metterlo nella fase
    // sbagliata soddisfa una lettura distratta e non risolve niente.
    final testo = pbx.readAsStringSync();
    final risorseTest =
        blocco(testo, '331C807F294A63A400263BE5 /* Resources */ = {');
    expect(risorseTest.contains(nome), isFalse,
        reason: '$nome sta nella fase di copia di RunnerTests: li\' non serve '
            'a nessuno, e l\'app resta senza.');
  });

  test('il riferimento e la copia parlano dello STESSO file', () {
    // Due identificativi scollegati sono il difetto piu' silenzioso: ogni
    // controllo di presenza passerebbe, e la copia punterebbe al vuoto.
    final testo = pbx.readAsStringSync();
    final riga = RegExp(
            r'([0-9A-F]{24}) /\* GoogleService-Info\.plist in Resources \*/ = \{isa = PBXBuildFile; fileRef = ([0-9A-F]{24})')
        .firstMatch(testo);
    expect(riga, isNotNull,
        reason: 'Non esiste una voce PBXBuildFile per $nome: la fase di copia '
            'nomina qualcosa che non e\' legato a nessun file.');
    final idFile = riga!.group(2)!;
    expect(
        testo.contains('$idFile /* GoogleService-Info.plist */ = {isa = '
            'PBXFileReference'),
        isTrue,
        reason: 'La copia punta a $idFile, che non e\' il riferimento di '
            '$nome: i due identificativi si sono scollegati.');
  });

  test('la versione minima di iOS e\' quella che Firebase pretende', () {
    // Non e' una scelta di gusto: con 13.0 il `pod install` fallisce prima
    // ancora di compilare. La ragione sta scritta accanto al numero.
    final testo = pbx.readAsStringSync();
    expect(testo.contains('IPHONEOS_DEPLOYMENT_TARGET = 13.0'), isFalse,
        reason: 'Il progetto dichiara ancora iOS 13.0 da qualche parte: i pod '
            'di Firebase pretendono 15.0 e il pod install cadra\'.');
    final quanti =
        RegExp('IPHONEOS_DEPLOYMENT_TARGET = 15.0').allMatches(testo).length;
    expect(quanti, 3,
        reason: 'La versione minima e\' dichiarata in $quanti punti invece di '
            'tre: le tre configurazioni del progetto devono dire lo stesso '
            'numero.');
  });

  test('il pbxproj e\' rimasto strutturalmente sano', () {
    // **IL RISCHIO VERO DELLO SCRIVERE A MANO.** Su Windows non esiste uno
    // strumento che manipoli un progetto Xcode: niente gem `xcodeproj`, niente
    // pacchetto `pbxproj`, niente `plutil`. Le quattro righe sono state
    // inserite a mano, simmetriche a quelle gia' presenti, e un file
    // sbilanciato non si vedrebbe fino alla compilazione, che qui non si puo'
    // fare.
    //
    // Non e' un parser: e' un controllo di simmetria, che e' quanto basta a
    // prendere una graffa persa o una sezione lasciata aperta.
    final testo = pbx.readAsStringSync();

    final aperte = '{'.allMatches(testo).length;
    final chiuse = '}'.allMatches(testo).length;
    expect(aperte, chiuse,
        reason: 'Le graffe non tornano: $aperte aperte e $chiuse chiuse. Il '
            'progetto Xcode non si aprira\'.');

    final inizi = RegExp(r'/\* Begin (\w+) section \*/').allMatches(testo);
    final fini = RegExp(r'/\* End (\w+) section \*/').allMatches(testo);
    expect(inizi.length, fini.length,
        reason: 'Le sezioni non tornano: ${inizi.length} aperte e '
            '${fini.length} chiuse.');
    expect(inizi.map((m) => m.group(1)).toList(),
        fini.map((m) => m.group(1)).toList(),
        reason: 'Le sezioni si aprono e si chiudono in ordine diverso: il file '
            'e\' stato modificato male.');

    // Gli identificativi di Xcode sono ventiquattro caratteri esadecimali
    // maiuscoli: uno scritto male non collide con niente e il progetto perde
    // il riferimento in silenzio.
    for (final id in ['E5F0C7A12F0100000E51C0DE', 'E5F0C7A22F0100000E51C0DE']) {
      expect(RegExp(r'^[0-9A-F]{24}$').hasMatch(id), isTrue);
      expect(testo.contains(id), isTrue,
          reason: 'L\'identificativo $id non c\'e\' piu\' nel progetto.');
    }
  });

  test('il plist NON e\' tracciato da Git, e la regola vive qui', () {
    // **La decisione e' di Mauro, del 6 agosto 2026, e il repository e'
    // PUBBLICO.** La configurazione Firebase per piattaforma non si versiona:
    // la scrive la macchina di build da una variabile cifrata, come
    // `android-build.yml` fa gia' col google-services.json.
    //
    // Una riga di `.gitignore` protegge finche' nessuno la tocca e finche'
    // nessuno aggiunge il file con `git add -f`: questa prova protegge anche
    // da quello, perche' guarda cosa Git TRACCIA davvero.
    final elenco = Process.runSync('git', ['ls-files', '--', 'ios/Runner/$nome',
      'android/app/google-services.json', 'lib/firebase_options.dart']);
    final tracciati = (elenco.stdout as String)
        .split('\n')
        .map((r) => r.trim())
        .where((r) => r.isNotEmpty)
        .toList();
    expect(tracciati, isEmpty,
        reason: 'Questi file di configurazione sono finiti sotto Git: '
            '$tracciati. Portano chiavi e identificativi del progetto, e il '
            'repository e\' pubblico: si iniettano in build da una variabile '
            'cifrata, non si versionano.');
  });
}
