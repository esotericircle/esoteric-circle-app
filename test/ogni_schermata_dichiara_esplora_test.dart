import 'dart:io';

import 'package:esoteric_circle/features/shell/esplora_schermate.dart';
import 'package:flutter_test/flutter_test.dart';

/// OGNI SCHERMATA DICHIARA COSA FA ESPLORA, E NESSUNA EREDITA PER CASO.
///
/// **Non un caso: l'elenco intero.** Una prova che verifica una schermata alla
/// volta vale finche' nessuno ne aggiunge un'altra, e chi la aggiunge non ha
/// modo di sapere che esisteva una decisione da prendere. Questa legge i
/// sorgenti, trova tutte le schermate dell'app e pretende che ognuna sia
/// classificata in `presenzaPerSchermata`. Una schermata nuova la fa cadere il
/// giorno stesso in cui nasce, col nome della classe nel messaggio.
///
/// **Chi la fa cadere non deve indovinare:** deve scegliere fra tre stati
/// dichiarati, e ognuno ha la sua ragione scritta accanto alla definizione.
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

  test('ogni schermata dei sorgenti e\' classificata, nessuna esclusa', () {
    final nei = schermateNeiSorgenti();

    // La guardia contro la prova cieca: se il riconoscimento si rompe, l'insieme
    // diventa vuoto e ogni pretesa risulterebbe rispettata.
    expect(nei.length, greaterThanOrEqualTo(25),
        reason: 'Trovate solo ${nei.length} schermate nei sorgenti: il '
            'riconoscimento si e\' rotto e la prova sta nascendo cieca.');

    final nonDichiarate = nei.difference(presenzaPerSchermata.keys.toSet());
    expect(nonDichiarate, isEmpty,
        reason: 'Queste schermate esistono nei sorgenti ma nessuno ha detto '
            'cosa deve farci Esplora: ${nonDichiarate.toList()..sort()}.\n'
            'Scegli in lib/features/shell/esplora_schermate.dart fra '
            'presente, immersiva e soglia. Non e\' una formalita\': una '
            'schermata non dichiarata erediterebbe un comportamento per caso, '
            'ed e\' il modo in cui la striscia comparirebbe dentro un rito.');
  });

  test('l\'elenco non dichiara schermate che non esistono piu\'', () {
    final nei = schermateNeiSorgenti();
    final fantasmi = presenzaPerSchermata.keys.toSet().difference(nei);
    expect(fantasmi, isEmpty,
        reason: 'L\'elenco dichiara schermate che nei sorgenti non ci sono '
            'piu\': ${fantasmi.toList()..sort()}. Una riga che parla di una '
            'schermata cancellata e\' una costante che dichiara il falso.');
  });

  test('le tre immersive dell\'ordine sono classificate immersive', () {
    // LE TRE NOMINATE DALL'ORDINE, scritte qui a mano e non lette dall'elenco
    // che devono sorvegliare. La stesa, i riti e la meditazione sono i tre
    // gesti in cui la striscia non c'e' nemmeno richiusa.
    const stesa = 'StesaTreCarteScreen';
    const riti = ['DawnRiteScreen', 'SunsetRuneScreen', 'DreamRiteScreen'];
    const meditazione = 'MeditationScreen';

    for (final s in [stesa, ...riti, meditazione]) {
      expect(presenzaPerSchermata[s], PresenzaEsplora.immersiva,
          reason: '$s deve essere immersiva: l\'ordine del 6 agosto 2026 dice '
              'che nella stesa, nei riti e nella meditazione Esplora non c\'e\' '
              'nemmeno richiusa.');
    }
  });

  test('le chat dei Maestri hanno Esplora', () {
    // E' la ragione per cui Esplora esiste: da chat, Consiglio e ritorno a un
    // altro Maestro, tornare alla home era lungo.
    expect(esploraSiVede('MaestroChatScreen'), isTrue,
        reason: 'Senza Esplora nella chat sparisce il motivo per cui e\' nata.');
    expect(esploraSiVede('AskMaestriScreen'), isTrue,
        reason: 'Il Consiglio e\' l\'altro capo della catena chat, Consiglio, '
            'chat.');
  });
}
