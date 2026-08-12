import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// LE ANTEPRIME MONTANO CIO' CHE L'APP MONTA. Ordine P voce 27.
///
/// **Il criterio, dall'ordine: un'anteprima deve essere montata come e' montato
/// cio' che prova.** Il nome del file e' un buon indizio e non e' il criterio.
///
/// **Il difetto, misurato.** Sedici anteprime in quattro flussi montavano la
/// schermata NUDA, dentro un `MaterialApp` con un `MaestroScope` costruito a
/// mano. L'app le monta dentro `SogliaArte`, che porta tre cose che quelle
/// catture non avevano:
///
/// 1. `MaestroScope(maestro: ...)`, cioe' la palette fissata sul PROPRIETARIO
///    dell'arte dal primo fotogramma, invece di quella del controller;
/// 2. `ArteCorrente`, che dice quale arte si sta vivendo;
/// 3. `ConCuore`, cioe' IL CUORE DELLE ARTI PREFERITE nella barra.
///
/// Il cuore non compariva in nessuna delle sedici, e nell'app c'e' sempre. Le
/// anteprime provavano una barra con un elemento in meno di quella vera.
///
/// **E mancava anche un provider.** Il cuore legge `ArtiPreferiteController`,
/// che le catture non fornivano: anche dentro la soglia, senza lo scaffale il
/// cuore non si disegna. Le due cose insieme sono il difetto.
void main() {
  final corredo = File('test/screenshot_capture_test.dart').readAsStringSync();

  group('La soglia dell\'arte e\' dichiarata in un punto solo', () {
    test('ogni arte dichiara la sua soglia, e la rotta la chiede a lei', () {
      // **UN SOLO PUNTO dichiara chi e' il proprietario di un'arte.** Prima
      // l'identificativo e il Maestro stavano dentro `route`, cioe' in un punto
      // che solo l'app attraversa: chi montava la schermata da un'altra parte,
      // come una cattura, non aveva modo di sapere quali fossero.
      const arti = {
        'lib/features/maestri/aura/face/face_constellation_screen.dart':
            'face_constellation',
        'lib/features/maestri/caligo/animal/guide_animal_screen.dart':
            'guide_animal',
        'lib/features/maestri/caligo/rune/rune_draw_screen.dart': 'rune_draw',
      };
      arti.forEach((percorso, ident) {
        final s = File(percorso).readAsStringSync();
        expect(s, contains('static Widget conLaSoglia('),
            reason: '$percorso non dichiara piu\' la sua soglia, quindi chi la '
                'monta da fuori deve indovinare id e Maestro');
        expect(s, contains('builder: (_) => conLaSoglia('),
            reason: 'la rotta di $percorso non passa dalla soglia dichiarata: '
                'sono tornate due dichiarazioni dello stesso fatto');
        // L'identificativo si DICHIARA una volta sola.
        //
        // **Si cerca la forma della dichiarazione e non la parola nuda.** La
        // parola compare anche nel percorso di un import e nella chiave di un
        // widget: contarla dava quattro dove le dichiarazioni sono una, e una
        // prova che accusa un import non misura quello che crede.
        final quante = "id: '$ident'".allMatches(s).length;
        expect(quante, 1,
            reason: 'in $percorso l\'identificativo "$ident" compare $quante '
                'volte: due dichiarazioni divergono sempre');
      });
    });
  });

  group('Le catture dei quattro flussi passano dalla soglia', () {
    test('gli agganci montano la schermata dentro la sua soglia', () {
      for (final atteso in const [
        'FaceConstellationScreen.conLaSoglia(schermata)',
        '_conLaSuaSoglia(schermata)',
        'RuneDrawScreen.conLaSoglia(schermata)',
        'GuideAnimalScreen.conLaSoglia(schermata)',
      ]) {
        expect(corredo, contains(atteso),
            reason: 'il corredo non monta piu\' le arti dentro la loro soglia: '
                'manca $atteso');
      }
    });

    test('e forniscono lo scaffale, senza cui il cuore non si disegna', () {
      // Dentro la soglia e senza lo scaffale il cuore resta invisibile: la
      // cattura sembrerebbe corretta e mostrerebbe ancora una barra sbagliata.
      expect(corredo, contains('ArtiPreferiteController(maestroAssegnato:'),
          reason: 'lo scaffale personale non arriva alle catture, quindi il '
              'cuore non compare e l\'anteprima mostra una barra con un '
              'elemento in meno di quella vera');
      expect(
          'ArtiPreferiteController(maestroAssegnato:'.allMatches(corredo).length,
          greaterThanOrEqualTo(2),
          reason: 'lo scaffale deve arrivare a tutti e due gli agganci, quello '
              'di Aura e quello di Caligo');
    });

    test('nessun aggancio dei quattro flussi monta la schermata nuda', () {
      // La forma del difetto, cercata per come era scritta: la schermata
      // passata direttamente all'app di prova, senza niente attorno.
      for (final nuda in const [
        'child: faceApp(schermata)',
        'child: caligoApp(schermata)',
      ]) {
        expect(corredo.contains(nuda), isFalse,
            reason: 'un aggancio e\' tornato a montare la schermata nuda: '
                '$nuda');
      }
    });

    test('il Risveglio monta la stessa cosa che la sua rotta monta', () {
      // Il Risveglio non e' un'arte del catalogo e non ha soglia: la sua rotta
      // porta un `MaestroScope` senza Maestro, cioe' quello che segue il Maestro
      // attivo. La cattura fa la stessa cosa, e questa prova tiene le due
      // dichiarazioni allineate.
      final rotta =
          File('lib/features/onboarding/onboarding_screen.dart').readAsStringSync();
      expect(rotta, contains('MaestroScope(child: OnboardingScreen('),
          reason: 'la rotta del Risveglio e\' cambiata: la cattura va '
              'riallineata a lei, non viceversa');
      expect(corredo, contains('MaestroScope(child: child!)'),
          reason: 'la cattura del Risveglio non porta piu\' lo stesso scope '
              'della sua rotta');
    });
  });

  group('Le sedici anteprime esistono e sono state riscattate', () {
    test('i quattro flussi hanno tutte le loro anteprime sul disco', () {
      // Il nome del file e' un buon indizio e non e' il criterio, ma
      // un'anteprima che NON C'E' non prova niente: questa e' la parte del
      // criterio che si puo' contare.
      final mancanti = <String>[];
      for (final nome in const [
        // Risveglio
        'risveglio-accoglienza.png', 'risveglio-data.png', 'risveglio-ora.png',
        'risveglio-luogo.png', 'risveglio-luogo-scelto.png',
        'risveglio-genere.png', 'risveglio-sigillo.png',
        // Costellazione del Viso
        'costellazione-viso-soglia.png', 'costellazione-viso.png',
        'costellazione-viso-card.png', 'costellazione-viso-ripiego.png',
        // Animale Guida
        'guide-animale.png', 'guide-animale-card.png',
        // Estrazione Rune
        'rune-lancio.png', 'rune-card.png', 'rune-croce.png',
      ]) {
        if (!File('docs/preview/$nome').existsSync()) mancanti.add(nome);
      }
      expect(mancanti, isEmpty,
          reason: 'queste anteprime dei quattro flussi non esistono:\n'
              '${mancanti.join("\n")}');
    });
  });
}
