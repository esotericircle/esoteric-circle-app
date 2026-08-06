import 'dart:io';

import 'package:esoteric_circle/features/shell/dove_si_vede_la_barra.dart';
import 'package:flutter_test/flutter_test.dart';

/// OGNI SCHERMATA DICHIARA SE PORTA LA BARRA, E NESSUNA EREDITA PER CASO.
///
/// **Non un caso: l'elenco intero.** Una prova che verifica una schermata alla
/// volta vale finche' nessuno ne aggiunge un'altra, e chi la aggiunge non ha
/// modo di sapere che esisteva una decisione da prendere. Questa legge i
/// sorgenti, trova tutte le schermate dell'app e pretende che ognuna sia
/// classificata in `presenzaPerSchermata`. Una schermata nuova la fa cadere il
/// giorno stesso in cui nasce, col nome della classe nel messaggio.
///
/// **Chi la fa cadere non deve indovinare:** la regola e' chiusa e sta scritta
/// accanto all'elenco. Cinque schermate portano la barra, tutto il resto no.
void main() {
  /// Le schermate si riconoscono dal nome della classe. La convenzione della
  /// casa e' il suffisso `Screen`; `CosmicPassport` e' l'unica che non lo porta
  /// e vive nel guscio insieme al Santuario, quindi si nomina qui.
  const eccezioniCheSonoSchermate = {'CosmicPassport'};

  /// I nomi privati non sono schermate: sono pezzi interni di una schermata.
  bool privata(String nome) => nome.startsWith('_');

  Set<String> schermateNeiSorgenti() {
    final trovate = <String>{};
    final righe = RegExp(r'^class\s+([A-Za-z0-9_]+)\s+extends', multiLine: true);
    for (final f in Directory('lib').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      final sorgente = f.readAsStringSync();
      for (final m in righe.allMatches(sorgente)) {
        final nome = m.group(1)!;
        if (privata(nome)) continue;
        if (nome.endsWith('Screen') || eccezioniCheSonoSchermate.contains(nome)) {
          trovate.add(nome);
        }
      }
    }
    return trovate;
  }

  test('ogni schermata dell\'app e\' classificata', () {
    final schermate = schermateNeiSorgenti();
    expect(schermate, isNotEmpty,
        reason: 'Nessuna schermata trovata nei sorgenti: il riconoscimento si '
            'e\' rotto, e una prova che non trova niente e\' verde per '
            'cecita\'.');
    final senzaDecisione =
        schermate.where((s) => !presenzaPerSchermata.containsKey(s)).toList()
          ..sort();
    expect(senzaDecisione, isEmpty,
        reason: 'Queste schermate non dicono se portano la barra: '
            '$senzaDecisione. La regola e\' chiusa: la barra si vede nella '
            'home, nel Passport, nel dominio di un Maestro, nella sua chat e '
            'nel Consiglio del Cerchio. Tutto il resto va dichiarato assente.');
  });

  test('l\'elenco non parla di schermate che non esistono', () {
    final schermate = schermateNeiSorgenti();
    final fantasmi = presenzaPerSchermata.keys
        .where((s) => !schermate.contains(s))
        .toList()
      ..sort();
    expect(fantasmi, isEmpty,
        reason: 'L\'elenco classifica schermate che nei sorgenti non ci sono '
            'piu\': $fantasmi. Un elenco che parla di cose morte smette di '
            'essere una fonte.');
  });

  test('sono cinque, e sono quelle decise da Mauro', () {
    final conBarra = presenzaPerSchermata.entries
        .where((e) => e.value == PresenzaDellaBarra.presente)
        .map((e) => e.key)
        .toList()
      ..sort();
    expect(
        conBarra,
        equals([
          'AskMaestriScreen',
          'CosmicPassport',
          'DomainScreen',
          'MaestroChatScreen',
          'SantuarioScreen',
        ]),
        reason: 'Le schermate con la barra sono cambiate: $conBarra. '
            'L\'elenco e\' una decisione di Mauro del 6 agosto 2026, non una '
            'conseguenza del codice.');
  });

  test('nessun Dono del giorno e nessuna immersiva porta la barra', () {
    // Nominati uno per uno perche' l'ordine li nomina uno per uno: se domani
    // qualcuno li spostasse fra le presenti, questa cadrebbe prima di ogni
    // altra.
    const maiLaBarra = [
      'DawnRiteScreen',
      'BreathDestinyScreen',
      'DayOracleScreen',
      'SunsetRuneScreen',
      'DreamRiteScreen',
      'StesaTreCarteScreen',
      'MeditationScreen',
      'RuneDrawScreen',
    ];
    for (final nome in maiLaBarra) {
      expect(presenzaPerSchermata[nome], PresenzaDellaBarra.assente,
          reason: '$nome porta la barra: i Doni del giorno e le esperienze '
              'immersive si compiono con un gesto, e una via d\'uscita sempre '
              'a vista lo interrompe.');
    }
  });
}
