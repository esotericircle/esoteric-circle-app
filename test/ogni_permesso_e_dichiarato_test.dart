import 'dart:io';

import 'package:esoteric_circle/core/permissions/app_permission.dart';
import 'package:esoteric_circle/core/permissions/registro_dei_permessi.dart';
import 'package:flutter_test/flutter_test.dart';

/// OGNI PERMESSO CHE L'APP CHIEDE E' DICHIARATO DOVE VA DICHIARATO.
///
/// **Il danno che questa prova impedisce.** Su iOS un permesso chiesto senza
/// la sua chiave in `Info.plist` non da' un errore: il sistema UCCIDE l'app
/// nell'istante della richiesta, senza crash e senza rapporto. E' la stessa
/// famiglia del difetto del pittore del cosmo, che per settimane e' sembrata
/// un'app che spariva da sola. Su Android un permesso non dichiarato nel
/// manifest viene semplicemente negato per sempre, in silenzio.
///
/// La prova ENUMERA il registro e va a leggere i file veri: non visita un
/// permesso alla volta scelto a mano, perche' un permesso che nascera' domani
/// deve cadere qui il giorno che nasce.
void main() {
  final infoPlist = File('ios/Runner/Info.plist').readAsStringSync();
  final manifest =
      File('android/app/src/main/AndroidManifest.xml').readAsStringSync();

  test('il registro copre TUTTI i permessi dell\'app, senza buchi', () {
    // Se qualcuno aggiunge un permesso all'enum e si dimentica il registro,
    // questa cade per prima: il registro e' la porta, e una porta che non
    // conosce una stanza non e' una porta.
    for (final p in AppPermission.values) {
      expect(
          RegistroDeiPermessi.voci.where((v) => v.permesso == p).length, 1,
          reason: 'Il permesso "$p" non ha una voce sola nel registro: '
              'senza di lei nessuno verifica che sia dichiarato.');
    }
  });

  test('ogni permesso ha la sua chiave iOS con un testo che dice a cosa '
      'serve', () {
    final colpe = <String>[];
    for (final v in RegistroDeiPermessi.voci) {
      final chiave = v.chiaveIos;
      if (chiave == null) {
        // Chi non ha chiave deve dire PERCHE': senza la ragione scritta,
        // domani sembra una dimenticanza e qualcuno la "corregge".
        if (v.ragioneSenzaChiave.trim().length < 20) {
          colpe.add('${v.permesso}: nessuna chiave iOS e nessuna ragione '
              'scritta');
        }
        continue;
      }
      final i = infoPlist.indexOf('<key>$chiave</key>');
      if (i < 0) {
        colpe.add('${v.permesso}: manca la chiave "$chiave" in '
            'ios/Runner/Info.plist. Su iOS l\'app viene UCCISA quando chiede '
            'questo permesso.');
        continue;
      }
      // Il testo vero: quello che Apple mostra alla persona.
      final da = infoPlist.indexOf('<string>', i);
      final a = infoPlist.indexOf('</string>', da);
      final testo = (da < 0 || a < 0) ? '' : infoPlist.substring(da + 8, a);
      if (testo.trim().isEmpty) {
        colpe.add('${v.permesso}: la chiave "$chiave" ha un testo vuoto.');
        continue;
      }
      // **NON BASTA CHE CI SIA: DEVE DIRE A COSA SERVE.** Apple rifiuta in
      // revisione le frasi generiche, e una frase generica non serve
      // nemmeno a chi legge. Si pretende una lunghezza da frase vera e che
      // non sia una formula di comodo.
      if (testo.trim().length < 60) {
        colpe.add('${v.permesso}: il testo di "$chiave" e\' lungo '
            '${testo.trim().length} caratteri: troppo corto per spiegare a '
            'cosa serve dentro il rito.');
      }
      for (final formula in const [
        'This app needs',
        'necessario per il funzionamento',
        'per usare l\'app',
      ]) {
        if (testo.toLowerCase().contains(formula.toLowerCase())) {
          colpe.add('${v.permesso}: il testo di "$chiave" e\' una formula '
              'generica ("$formula"): Apple la rifiuta e la persona non '
              'capisce.');
        }
      }
    }
    expect(colpe, isEmpty, reason: colpe.join('\n'));
  });

  test('ogni permesso ha le sue voci nel manifest di Android', () {
    final colpe = <String>[];
    for (final v in RegistroDeiPermessi.voci) {
      for (final voce in v.vociAndroid) {
        if (!manifest.contains('android:name="$voce"')) {
          colpe.add('${v.permesso}: manca "$voce" in AndroidManifest.xml. Su '
              'Android il permesso resta negato per sempre, in silenzio.');
        }
      }
    }
    expect(colpe, isEmpty, reason: colpe.join('\n'));
  });

  test('nel manifest non ci sono permessi che nessuno chiede', () {
    // L'ALTRO DIFETTO, quello opposto e piu' silenzioso: un permesso
    // dichiarato e mai chiesto compare nella scheda dello store e in
    // revisione va giustificato. Si enumerano le voci del manifest e si
    // pretende che ognuna appartenga a un permesso del registro.
    final dichiarati = RegExp(r'uses-permission android:name="([^"]+)"')
        .allMatches(manifest)
        .map((m) => m.group(1)!)
        .toList();
    final nelRegistro =
        RegistroDeiPermessi.voci.expand((v) => v.vociAndroid).toSet();
    final orfani = dichiarati.where((d) => !nelRegistro.contains(d)).toList();
    expect(orfani, isEmpty,
        reason: 'Il manifest dichiara permessi che nessuna voce del registro '
            'rivendica: $orfani. O li chiede qualcuno e il registro non lo '
            'sa, o non li chiede nessuno e vanno tolti.');
  });

  test('il punto che chiede il permesso esiste davvero', () {
    final colpe = <String>[];
    for (final v in RegistroDeiPermessi.voci) {
      if (!File(v.doveSiChiede).existsSync()) {
        colpe.add('${v.permesso}: il registro dice che il permesso si chiede '
            'in "${v.doveSiChiede}", ma quel file non esiste.');
      }
      if (v.ripiego.trim().length < 20) {
        colpe.add('${v.permesso}: il ripiego non e\' dichiarato. Nessun '
            'permesso negato puo\' lasciare la persona senza l\'arte.');
      }
    }
    expect(colpe, isEmpty, reason: colpe.join('\n'));
  });
}
