import 'dart:io';

import 'package:esoteric_circle/features/shell/dove_si_vede_la_barra.dart';
import 'package:flutter_test/flutter_test.dart';

/// LA BARRA SOTTILE NON ESISTE FINO ALLA HOME. Ordine AQ voce 03.
///
/// **Il fatto di Mauro, dalla 2184**: la barra sottile compare durante
/// l'onboarding, per esempio sull'assegnazione dell'Animale Guida, e da li' si
/// puo' uscire dal rito.
///
/// **La causa, trovata e non supposta.** L'ordine AP voce 07 aveva gia'
/// dichiarato il Risveglio fra le soglie, e non bastava: chi guarda la pila
/// visita l'albero della rotta in cima e si ferma al primo widget dal nome
/// CONOSCIUTO, dove conosciuto voleva dire "presente nella mappa della barra
/// storica". Nessuna scena del rito lo era, quindi la risposta era nulla, e
/// per il nulla la barra sottile si vede. La dichiarazione c'era e non
/// arrivava a nessuno.
void main() {
  /// Le scene del rito, enumerate qui e non scena per scena.
  const scenePerNome = <String>[
    'OnboardingScreen',
    'RisveglioJourney',
    'TrionfoAnimale',
    'TrionfoAngeli',
    'NatalChartReveal',
    'SkyOverviewScreen',
    'ResonanceScreen',
    'CustodiaDelCieloStep',
    'SigilloStep',
    'MaestroRevealScreen',
    'ScenaDelRitrovamento',
  ];

  test('in nessuna scena del rito si vede la barra sottile', () {
    final colpevoli =
        scenePerNome.where(barraSottileSiVede).toList(growable: false);
    // ignore: avoid_print
    print('ORDINE AQ VOCE 03: scene del rito che mostrano la barra: '
        '$colpevoli');
    expect(colpevoli, isEmpty,
        reason: 'queste scene del rito mostrano la barra sottile, e da li si '
            'esce dal rito: $colpevoli');
  });

  test('dalla home in poi la barra sottile c e', () {
    // **LA GUARDIA GUARDA ANCHE L ALTRO VERSO.** Una regola che spegne e
    // basta si accontenterebbe di spegnere tutto.
    for (final casa in const [
      'SantuarioScreen',
      'CosmicPassport',
      'DomainScreen',
      'MaestroChatScreen',
    ]) {
      expect(barraSottileSiVede(casa), isTrue,
          reason: 'la barra sottile e sparita anche da $casa');
    }
  });

  test('il guscio RICONOSCE i nomi delle scene del rito', () {
    // **LA RIGA CHE RENDEVA VANA OGNI DICHIARAZIONE.** Senza questa unione i
    // nomi del rito non venivano nemmeno cercati nell'albero, e la scena
    // rispondeva nulla.
    for (final scena in scenePerNome) {
      expect(nomiDiSchermataConosciuti.contains(scena), isTrue,
          reason: '$scena non e fra i nomi che il guscio sa riconoscere: la '
              'pila rispondera nulla e la barra tornera a vedersi');
    }
    final guscio =
        File('lib/features/shell/barra_del_cerchio.dart').readAsStringSync();
    expect(guscio.contains('nomiDiSchermataConosciuti'), isTrue,
        reason: 'il guscio e tornato a cercare solo i nomi della barra '
            'storica: le scene del rito rispondono nulla');
  });

  test('le scene del rito enumerate qui sono quelle dichiarate in lib', () {
    // Due elenchi che dicono la stessa cosa divergono al primo ritocco: qui
    // si pretende che siano lo stesso elenco.
    final mancanti =
        scenePerNome.where((s) => !soglieSenzaBarraSottile.contains(s));
    expect(mancanti, isEmpty,
        reason: 'la prova nomina scene che lib non dichiara: $mancanti');
  });
}
