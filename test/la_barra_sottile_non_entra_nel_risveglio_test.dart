import 'dart:io';

import 'package:esoteric_circle/features/shell/barra_dell_identita.dart';
import 'package:esoteric_circle/features/shell/dove_si_vede_la_barra.dart';
import 'package:flutter_test/flutter_test.dart';

/// LA BARRA SOTTILE STA FUORI DALL'ONBOARDING. Ordine AP voce 07.
///
/// **La decisione di Mauro del 18 agosto**: la barra sottile non compare
/// durante l'onboarding, compare dalla home in poi e resta visibile in ogni
/// schermata come adesso.
///
/// **La misura della premessa P8, che ha corretto l'idea di partenza.** Le
/// soglie c'erano gia', e alla PRIMA apertura la barra infatti non si vede:
/// `OnboardingScreen` e' fra loro. Ma il Risveglio prosegue in
/// `RisveglioJourney`, che e' una rotta a se' spinta con `pushReplacement`, e
/// quella NON era fra le soglie: da li' in poi, cioe' per la carta natale,
/// la custodia del cielo e il Sigillo, la barra compariva. Chi non ha ancora
/// un volto, un saldo ne' un cammino si vedeva una barra dell'identita'
/// sopra il rito d'ingresso.
///
/// **L'elenco vive in UN punto solo**, e adesso e' lo stesso della barra
/// storica: `dove_si_vede_la_barra.dart`. Prima le due barre avevano due
/// elenchi in due file, e due elenchi sulla stessa domanda sono due verita'.
void main() {
  /// Le scene del Risveglio, enumerate: sono le rotte che il rito attraversa
  /// dalla prima apertura fino alla home.
  const scenoDelRisveglio = <String>[
    'OnboardingScreen',
    'RisveglioJourney',
    'MaestroRevealScreen',
  ];

  /// Dove la barra sottile DEVE esserci: la home e le schermate che vengono
  /// dopo, dove la persona ha gia' un volto, un saldo e un cammino.
  // **I NOMI SONO QUELLI VERI DELLE CLASSI, riletti nella casa unica**: il
  // Passaporto si chiama `CosmicPassport` e il Consiglio `AskMaestriScreen`,
  // dal nome che la funzione aveva prima. Una prova che inventa un nome
  // interroga una schermata che non esiste e passa sempre.
  const scenoDopoLaHome = <String>[
    'SantuarioScreen',
    'CosmicPassport',
    'MaestroChatScreen',
    'AskMaestriScreen',
    'StesaTreCarteScreen',
  ];

  test('durante il Risveglio la barra sottile non c\'e\'', () {
    final colpe = <String>[];
    for (final scena in scenoDelRisveglio) {
      if (BarraDellIdentita.siVede(scena)) colpe.add(scena);
    }
    // ignore: avoid_print
    print('ORDINE AP VOCE 07: scene del Risveglio con la barra addosso: '
        '$colpe');
    expect(colpe, isEmpty,
        reason: 'in queste scene del rito d\'ingresso compare la barra '
            'dell\'identita\', e chi le attraversa non ha ancora ne\' volto '
            'ne\' saldo ne\' cammino: $colpe');
  });

  test('dalla home in poi la barra sottile c\'e\'', () {
    // **E la prova guarda anche il verso opposto**, altrimenti si potrebbe
    // spegnere la barra ovunque e passare.
    final spente = <String>[];
    for (final scena in scenoDopoLaHome) {
      if (!BarraDellIdentita.siVede(scena)) spente.add(scena);
    }
    // ignore: avoid_print
    print('ORDINE AP VOCE 07: scene dopo la home senza barra: $spente');
    expect(spente, isEmpty,
        reason: 'la barra e\' sparita anche dove deve esserci: $spente');
  });

  test('l\'elenco vive in UN punto solo, insieme a quello della barra '
      'storica', () {
    // **L'ENUMERAZIONE sui sorgenti.** La domanda "dove si vede la barra" ha
    // una casa sola: se ricompare un elenco dentro il file della barra
    // sottile, tornano due verita' sulla stessa cosa.
    final barra =
        File('lib/features/shell/barra_dell_identita.dart').readAsStringSync();
    expect(barra.contains('static const Set<String> soglie'), isFalse,
        reason: 'la barra sottile si e\' ripresa un elenco suo delle scene '
            'dove non si vede: la domanda ha una casa sola');
    final casa = File('lib/features/shell/dove_si_vede_la_barra.dart')
        .readAsStringSync();
    expect(casa.contains('RisveglioJourney'), isTrue,
        reason: 'la casa unica non conosce il Risveglio');
  });

  test('la barra storica non ha cambiato idea su nessuna scena', () {
    // Le due barre hanno regole DIVERSE e vivono nella stessa casa: questa
    // prova tiene ferma quella storica mentre la voce 07 muove l'altra.
    expect(barraSiVede('SantuarioScreen'), isTrue);
    expect(barraSiVede('CosmicPassport'), isTrue);
    expect(barraSiVede('StesaTreCarteScreen'), isFalse);
    expect(barraSiVede('OnboardingScreen'), isFalse);
  });
}
