import 'dart:io';

import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:flutter_test/flutter_test.dart';

import 'sorgenti_di_lib.dart';

/// IL NOME DICHIARA LA SUA FORMA, ordine P voce 38.
///
/// **Il difetto.** Nel Cosmic Passport si leggeva "I tuoi Stella: cinquanta
/// piccoli con cinque grandi", e cosi' "I tuoi Frutto" e "I tuoi Petalo".
/// Singolare dentro una frase al plurale, e una riga che si legge come un
/// segnaposto invece che come italiano. Nessuna prova poteva accorgersene,
/// perche' il nome era una stringa nuda che non diceva che forma fosse: chi
/// la incollava dentro una frase non aveva niente da sbagliare e niente da
/// dichiarare.
///
/// **La regola che questa prova sorveglia.** Un nome di traguardo si legge
/// solo attraverso una forma dichiarata, `.singolare` oppure `.plurale`. Una
/// stringa composta che pesca un nome senza dichiarare la forma cade qui, col
/// nome del file e la riga.
///
/// E' la stessa famiglia gia' chiusa a inizio agosto con "Ne hai uno oggi"
/// contro "Ne hai una oggi": allora si era risolta con una formula unica che
/// non doveva concordare, qui il nome porta la concordanza come dato.
void main() {
  /// Le espressioni che pescano un nome di traguardo. Chi ne usa una dentro
  /// una stringa sta componendo una frase attorno a un nome.
  ///
  /// I confini di parola servono davvero: senza, `pronomeDellAspetto` del
  /// corpus dell'Oroscopo veniva accusato per la sola presenza di "nomeDell"
  /// dentro un'altra parola, e una prova che accusa gli innocenti si finisce
  /// per allentarla.
  final pescanoUnNome = [
    RegExp(r'\.mini\b'),
    RegExp(r'\.grande\b'),
    RegExp(r'\bnomeDe[li][A-Z]'),
  ];

  /// Le sole forme dichiarate: leggere un nome vuol dire chiedere una di
  /// queste due.
  const formeDichiarate = ['.singolare', '.plurale'];

  List<File> sorgenti() => sorgentiDiLib()
      .toList();

  test('un nome di traguardo espone solo le due forme, e nessun accesso nudo',
      () {
    final dato = File('lib/core/sigilli/traguardo.dart').readAsStringSync();
    final classe = dato.substring(dato.indexOf('class NomeDelTraguardo'));
    final corpo = classe.substring(0, classe.indexOf('\n}'));
    final campi = RegExp(r'final\s+String\s+(\w+);')
        .allMatches(corpo)
        .map((m) => m.group(1)!)
        .toList()
      ..sort();
    expect(campi, ['plurale', 'singolare'],
        reason: 'NomeDelTraguardo espone $campi: se esiste un modo di leggere '
            'il nome che non dichiara la forma, il difetto "I tuoi Stella" '
            'puo\' ripartire da li\'');

    // E il sentiero non deve tenere un nome nudo accanto alle due forme: era
    // proprio `nomeDelMini`, una stringa senza forma, a rendere possibile la
    // composizione a mano. Vale sia per un campo sia per un getter: durante la
    // prova del rosso il nome nudo e' tornato come getter e il primo giro di
    // questa prova, che guardava i soli campi, non lo ha visto.
    final nudi = RegExp(r'String\s+(?:get\s+)?(nomeDe[li]\w+)\s*[;=]')
        .allMatches(dato)
        .map((m) => m.group(1)!)
        .toList();
    expect(nudi, isEmpty,
        reason: 'il sentiero porta ancora nomi nudi $nudi, cioe\' stringhe di '
            'nome che non dichiarano la forma');
  });

  test('ogni stringa composta che pesca un nome dichiara la forma che usa', () {
    final colpe = <String>[];
    // Le interpolazioni dentro una stringa: e' li' che un nome viene
    // incollato dentro una frase.
    final interpolazione = RegExp(r'\$\{([^{}]*)\}');
    for (final file in sorgenti()) {
      final righe = file.readAsLinesSync();
      for (var i = 0; i < righe.length; i++) {
        for (final trovata in interpolazione.allMatches(righe[i])) {
          final espressione = trovata.group(1)!;
          if (!pescanoUnNome.any((r) => r.hasMatch(espressione))) continue;
          if (formeDichiarate.any(espressione.trimRight().endsWith)) continue;
          colpe.add('${file.path}:${i + 1}  \${$espressione}');
        }
      }
    }
    expect(colpe, isEmpty,
        reason: 'queste frasi incollano dentro di se\' un nome di traguardo '
            'senza dichiarare se lo vogliono al singolare o al plurale, ed e\' '
            'esattamente cosi\' che nasceva "I tuoi Stella":\n'
            '${colpe.join("\n")}');
  });

  test('i tre sentieri portano le due forme, e sono davvero diverse', () {
    for (final sentiero in Sentieri.tutti) {
      for (final nome in [sentiero.mini, sentiero.grande]) {
        expect(nome.singolare.trim(), isNotEmpty,
            reason: 'il singolare di ${sentiero.name} e\' vuoto');
        expect(nome.plurale.trim(), isNotEmpty,
            reason: 'il plurale di ${sentiero.name} e\' vuoto');
        expect(nome.plurale, isNot(nome.singolare),
            reason: 'su ${sentiero.name} il plurale "${nome.plurale}" e\' '
                'identico al singolare: una forma copiata non e\' una forma '
                'dichiarata, e la frase tornerebbe sbagliata');
      }
    }
  });

  test('la promessa del sentiero e\' una frase intera, non un inventario', () {
    for (final sentiero in Sentieri.tutti) {
      final promessa = sentiero.promessa;
      // Una frase vera: comincia in maiuscolo e finisce col punto.
      expect(promessa.endsWith('.'), isTrue,
          reason: 'la promessa di ${sentiero.name} non finisce come una frase: '
              '"$promessa"');
      expect(promessa.split(' ').length, greaterThan(8),
          reason: 'la promessa di ${sentiero.name} e\' troppo corta per dire a '
              'cosa serve il sentiero: "$promessa"');
      // E non conta i pezzi: "cinquanta piccoli con cinque grandi" era un
      // inventario, e nessuno torna domani per un inventario.
      for (final inventario in ['cinquanta', 'cinque grandi', '50', '55']) {
        expect(promessa.toLowerCase().contains(inventario), isFalse,
            reason: 'la promessa di ${sentiero.name} conta i pezzi invece di '
                'dire a cosa serve il sentiero: "$promessa"');
      }
      // Nessun trattino lungo nei testi a video, regola di casa.
      expect(promessa.contains('—'), isFalse,
          reason: 'trattino lungo nella promessa di ${sentiero.name}');
    }
  });
}
