import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// UNA PROVA CHE LEGGE IL CIELO DICHIARA IL SUO ISTANTE. Ordine U voce 00.
///
/// **Il fatto.** Tre prove passavano il 14 agosto 2026 e fallivano il 15 senza
/// che il codice fosse cambiato. Misurato: una `gettata` sola accende `cal_6`
/// solo quando il cielo del giorno porta la luna nuova, finestra aperta il 13 e
/// il 14 e chiusa il 15. **Una suite che cambia colore col giorno non e' una
/// suite: e' un oroscopo**, e la sua parola verde smette di valere per tutti.
///
/// **Questa non e' una pulizia, e' un vincolo**, ed e' la differenza fra un
/// filtro e una regola: una prova NUOVA che pesca dall'orologio fa cadere questa
/// riga, quindi la famiglia si chiude invece di essere ripulita una volta sola.
void main() {
  const mioNome = 'una_prova_dichiara_il_suo_istante_test.dart';

  /// **CHI PUO' LEGGERE L'OROLOGIO, e perche'.** Non e' una lista di
  /// esenzioni comode: sono i due punti dove l'ora vera E' l'oggetto della
  /// prova, e accanto a ognuno sta scritto cosa sorveglia.
  const dichiarate = <String, String>{
    'istante_dichiarato.dart':
        'e\' il file che DICHIARA l\'istante: qui la data si scrive, non si legge',
    'la_striscia_delle_arti_anche_in_home_test.dart':
        'misura la striscia delle arti, e la sua data serve solo a comporre una '
            'chiave che non entra in nessun confronto col cielo',
    'screenshot_capture_test.dart':
        'e\' la porta unica delle catture, e le catture hanno gia\' il loro '
            'istante fisso dichiarato dentro',
  };

  test('nessuna prova costruisce il Diario senza dichiarare il suo istante',
      () {
    var osservate = 0;
    final colpevoli = <String>[];
    for (final f in Directory('test').listSync()) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      final nome = f.uri.pathSegments.last;
      // **LA GUARDIA NON PUO' ESSERE IL PROPRIO SOGGETTO.** Questo file porta
      // le parole che cerca dentro i messaggi che scrive: guardarsi vorrebbe
      // dire accusarsi sempre, e una riga che cade sempre non dice niente.
      if (nome == mioNome) continue;
      osservate++;
      final testo = f.readAsStringSync();
      // **IL DIARIO SENZA OROLOGIO PESCA DAL GIORNO VERO**, e con lui il cielo:
      // e' da li' che passava la dipendenza dalla data.
      if (testo.contains('DiarioDelCammino()')) {
        colpevoli.add('$nome: costruisce DiarioDelCammino() senza orologio');
      }
    }
    // **QUANTE OSSERVAZIONI, e cade se sono zero.**
    // ignore: avoid_print
    print('ORDINE U VOCE 00: file di prova osservati $osservate');
    expect(osservate, greaterThan(0),
        reason: 'la prova non ha guardato nessun file: gira a vuoto');
    expect(colpevoli, isEmpty,
        reason: 'queste prove pescano il giorno vero dal Diario, quindi sono '
            'verdi o rosse a seconda di quando le lanci. Passa '
            'orologio: orologioDelleProve da test/istante_dichiarato.dart, '
            'oppure un istante tuo scritto dentro la prova. '
            '${colpevoli.join(" | ")}');
  });

  test('nessuna prova chiama DateTime.now senza essere dichiarata', () {
    var osservate = 0;
    final colpevoli = <String>[];
    for (final f in Directory('test').listSync()) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      final nome = f.uri.pathSegments.last;
      if (nome == mioNome || dichiarate.containsKey(nome)) continue;
      osservate++;
      if (f.readAsStringSync().contains('DateTime.now')) {
        colpevoli.add(nome);
      }
    }
    // ignore: avoid_print
    print('ORDINE U VOCE 00: file non dichiarati osservati $osservate');
    expect(osservate, greaterThan(0));
    expect(colpevoli, isEmpty,
        reason: 'queste prove leggono l\'orologio vero: dichiara il tuo istante '
            'dentro la prova, oppure aggiungi il file all\'elenco dichiarato '
            'SCRIVENDO ACCANTO cosa sorveglia. ${colpevoli.join(", ")}');
  });

  test('le dichiarazioni sono vive, non righe rimaste indietro', () {
    // **UNA DICHIARAZIONE PER UN FILE CHE NON ESISTE PIU' non protegge niente**,
    // e nasconde che l'elenco non lo guarda piu' nessuno.
    var osservate = 0;
    final morte = <String>[];
    for (final voce in dichiarate.entries) {
      osservate++;
      if (!File('test/${voce.key}').existsSync()) {
        morte.add('${voce.key}: dichiarata ma il file non esiste piu\'');
      }
      if (voce.value.length < 30) {
        morte.add('${voce.key}: la ragione e\' troppo corta per essere una '
            'ragione');
      }
    }
    // ignore: avoid_print
    print('ORDINE U VOCE 00: dichiarazioni controllate $osservate');
    expect(osservate, greaterThan(0));
    expect(morte, isEmpty, reason: morte.join(' | '));
  });
}
