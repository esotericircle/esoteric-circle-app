import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// IL SERVER NON INSTALLA LE LIBRERIE CHE SERVONO SOLO ALLE PROVE.
///
/// **Il difetto, e cosa e' costato.** `functions/package.json` portava fra le
/// dipendenze di sviluppo `@firebase/rules-unit-testing` e il client `firebase`,
/// che servono soltanto alle prove delle regole di Firestore. `firebase deploy`
/// carica la cartella `functions` e la fa installare al server, dove quelle due
/// non hanno niente da fare: **il deploy e' morto su un conflitto di versioni**,
/// perche' `rules-unit-testing` vuole il client `firebase` alla major 11 mentre
/// il progetto era andato alla 12. Mauro lo ha aggirato abbassando la versione,
/// cioe' curando il sintomo: il conflitto tornerebbe alla prossima major.
///
/// **La correzione vera.** Le due librerie vivono nel `package.json` della RADICE
/// del repository, che il deploy non carica mai (`firebase.json` dichiara
/// `"source": "functions"`), e Node e TypeScript le trovano risalendo le
/// cartelle. Il pin alla major 11 resta, ma li' non e' piu' un ripiego: e'
/// esattamente il client che la libreria di prova pretende.
///
/// **E la compilazione non le chiede piu'.** `regole.emulatore.ts` e' uscito dal
/// `tsconfig.json` delle funzioni e ha il suo, `tsconfig.regole.json`: senza
/// questo, `npm run build` cadrebbe su un tipo mancante proprio nel predeploy,
/// cioe' avremmo spostato il guasto invece di toglierlo.
///
/// **Verificato eseguendo, non ragionando**: `npm run build` dentro `functions`
/// compila con le due librerie assenti, e `npm run test:regole` gira 8 prove su
/// 8 sull'emulatore Firestore. Per l'emulatore serve una JVM sul PATH: su questa
/// macchina e' quella di Android Studio, `jbr/bin`.
void main() {
  Map<String, dynamic> manifesto(String percorso) =>
      jsonDecode(File(percorso).readAsStringSync()) as Map<String, dynamic>;

  /// Le librerie che sono solo strumenti di prova, e che il server non deve
  /// vedere: il nome si compone, cosi' questa prova non accusa se stessa.
  final soloDiProva = ['@firebase/' 'rules-unit-testing', 'fire' 'base'];

  test('le funzioni non dipendono dalle librerie di prova', () {
    final j = manifesto('functions/package.json');
    final dichiarate = <String>[
      ...((j['dependencies'] as Map?)?.keys ?? const []).cast<String>(),
      ...((j['devDependencies'] as Map?)?.keys ?? const []).cast<String>(),
    ];
    for (final libreria in soloDiProva) {
      expect(dichiarate, isNot(contains(libreria)),
          reason: 'functions/package.json dichiara "$libreria", quindi il server '
              'la installa quando costruisce le funzioni: e\' li\' che il deploy '
              'e\' morto su un conflitto di versioni. Va nel package.json della '
              'radice, che il deploy non carica');
    }
    // `firebase-admin` e `firebase-functions` sono un'altra cosa e restano: sono
    // le librerie con cui le funzioni girano.
    expect(dichiarate, contains('firebase-admin'));
    expect(dichiarate, contains('firebase-functions'));
  });

  test('le librerie di prova vivono nella radice, non spariscono', () {
    // Toglierle dalle funzioni senza metterle altrove vorrebbe dire spegnere le
    // prove delle regole, che e' il modo piu' facile di far passare questa prova
    // dicendo il falso.
    final j = manifesto('package.json');
    final dev = (j['devDependencies'] as Map?)?.keys.cast<String>().toList() ??
        const <String>[];
    for (final libreria in soloDiProva) {
      expect(dev, contains(libreria),
          reason: 'la radice non porta piu' ' "$libreria": le prove delle regole '
              'di Firestore non hanno piu\' con cosa girare');
    }
  });

  test('la prova delle regole esce dalla compilazione delle funzioni', () {
    final base = File('functions/tsconfig.json').readAsStringSync();
    expect(base, contains('"exclude"'),
        reason: 'il tsconfig delle funzioni non esclude niente, quindi compila '
            'anche la prova delle regole e chiede i tipi delle due librerie '
            'proprio dove non ci sono: nel predeploy');
    expect(base, contains('regole.emulatore.ts'));
    final suo = File('functions/tsconfig.regole.json');
    expect(suo.existsSync(), isTrue,
        reason: 'la prova delle regole non ha piu\' una sua compilazione, quindi '
            'non si compila affatto');
    // L'esclusione del file base si annulla nel suo, altrimenti quella
    // compilazione non avrebbe nessun file dentro.
    expect(suo.readAsStringSync(), contains('"exclude": []'));
    final script =
        (manifesto('functions/package.json')['scripts'] as Map)['test:regole']
            as String;
    expect(script, contains('tsconfig.regole.json'),
        reason: 'lo script delle prove delle regole non usa la sua '
            'compilazione: userebbe quella che il file non contiene piu\'');
  });
}
