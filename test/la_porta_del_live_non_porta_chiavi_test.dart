// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/services/live/porta_del_live.dart';
import 'package:flutter_test/flutter_test.dart';

import 'sorgenti_di_lib.dart';

/// **LA PORTA DEL LIVE NON PORTA CHIAVI, E TRADUCE I TRE RIFIUTI.**
/// Ordine EG voci 01, 04 e 06.
///
/// ## LE DUE COSE CHE QUESTA PROVA GUARDA, E PERCHE' PROPRIO QUESTE
///
/// **La prima e' una regola di casa che vale piu' di tutto il resto**: i
/// segreti non scendono sul telefono. Il segreto di LiveKit apre **qualunque
/// stanza di chiunque**: chi lo avesse potrebbe entrare nella sessione di
/// un'altra persona. Per questo il telefono riceve solo un gettone gia' fatto,
/// buono per una stanza sola, e la guardia cerca le chiavi in tutto `lib`.
///
/// **La seconda e' che un rifiuto non e' un errore.** Il LIVE puo' non aprirsi
/// per tre ragioni diverse, e le tre vogliono tre risposte diverse a video:
/// chi non ha il diritto va invitato, chi ha finito i minuti va salutato dal
/// Maestro, chi trova un guasto torna alla chat scritta senza perdere niente.
/// **Un errore solo per tutte e tre porterebbe a un vicolo cieco**, che
/// `CLAUDE.md` vieta per ogni funzione.
void main() {
  tearDown(() {
    PortaDelLive.chiama = (porta, dati) async => const {};
  });

  test('nessuna chiave del LIVE vive in lib', () {
    // **I nomi si cercano tutti**, perche' basta che ne scenda uno.
    const chiaviCheNonDevonoScendere = [
      'PROTOFACE_API_KEY',
      'LIVEKIT_API_SECRET',
      'LIVEKIT_API_KEY',
      'api.protoface.com',
    ];
    final colpe = <String>[];
    var guardati = 0;
    for (final f in sorgentiDiLib()) {
      guardati++;
      final testo = f.readAsStringSync();
      for (final c in chiaviCheNonDevonoScendere) {
        if (testo.contains(c)) colpe.add('${f.path}: nomina $c');
      }
    }
    print('ORDINE EG VOCE 01: file di lib guardati $guardati');
    expect(guardati, greaterThan(100),
        reason: 'questa prova ha guardato solo $guardati file: o si sono '
            'spostati, o la porta comune non li trova piu\'');
    expect(colpe, isEmpty,
        reason: 'una chiave del LIVE e\' scesa sul telefono, e chi ha il '
            'segreto di LiveKit entra in qualunque stanza di chiunque: '
            '$colpe');
  });

  test('la sessione si legge per intero da cio\' che manda il server', () {
    final s = SessioneLive.daMappa(const {
      'url': 'wss://esoteric.livekit.cloud',
      'gettone': 'un-gettone-qualunque',
      'stanza': 'live_medora_abc',
      'sessione': 'sess_01M35EYZ9REM14BFYN64SK3S6S',
      'avatar': 'av_01M0N4GC9M1791PVH6NDD4FMMG',
      'minutiRimasti': 97,
      'durataMassimaSecondi': 1200,
    });
    expect(s.stanza, 'live_medora_abc');
    expect(s.minutiRimasti, 97);
    expect(s.durataMassimaSecondi, 1200);

    // **E una risposta monca non fa esplodere la schermata.** Il server e' un
    // altro programma: il giorno che tornasse meno campi, il LIVE deve poter
    // dire "non si apre", non morire nel mezzo.
    final vuota = SessioneLive.daMappa(const {});
    expect(vuota.gettone, isEmpty);
    expect(vuota.durataMassimaSecondi, 1200,
        reason: 'senza il tetto dal server si perde il limite dei venti '
            'minuti, e una sessione potrebbe non finire mai');
  });

  test('i tre rifiuti del server diventano tre ragioni diverse', () {
    // **Il server sceglie il codice apposta**, e qui si misura che arrivi
    // distinto fino allo schermo. Se tutti e tre diventassero "guasto", chi
    // ha finito i minuti vedrebbe un errore invece del saluto del Maestro.
    //
    // **Si misura la funzione pura, non il `catch`**, e la ragione e' che un
    // `FirebaseFunctionsException` vero al banco non si costruisce: una finta
    // eccezione sarebbe caduta nel ramo del guasto e la prova avrebbe detto
    // sempre di si' senza guardare niente.
    const attesi = <String, PerchePerILiveNonSiApre>{
      'permission-denied': PerchePerILiveNonSiApre.nonEPerTe,
      'resource-exhausted': PerchePerILiveNonSiApre.minutiFiniti,
      'internal': PerchePerILiveNonSiApre.guasto,
      'unavailable': PerchePerILiveNonSiApre.guasto,
      'deadline-exceeded': PerchePerILiveNonSiApre.guasto,
    };
    final sbagliati = <String>[];
    for (final a in attesi.entries) {
      final avuto = perchePerIlCodice(a.key);
      if (avuto != a.value) {
        sbagliati.add('${a.key}: atteso ${a.value.name}, arrivato '
            '${avuto.name}');
      }
    }
    print('ORDINE EG VOCE 04: rifiuti del server tradotti ${attesi.length}');
    expect(attesi.length, 5);
    expect(sbagliati, isEmpty, reason: sbagliati.join('; '));

    // **E i due rifiuti che non sono guasti devono restare distinti fra
    // loro**: se un domani qualcuno li unisse, questa riga cade.
    expect(perchePerIlCodice('permission-denied'),
        isNot(perchePerIlCodice('resource-exhausted')));
  });

  test('un guasto nel chiedere lo stato non spegne la sessione', () async {
    // **La sessione vive su LiveKit, non qui.** Se questa domanda non
    // risponde, si dice soltanto che il volto non e' ancora arrivato: far
    // cadere la sessione per una domanda andata storta butterebbe via minuti
    // che la persona ha pagato.
    PortaDelLive.chiama = (porta, dati) async => throw StateError('rete giu');
    final s = await PortaDelLive.stato('sess_qualunque');
    expect(s.ilVoltoEArrivato, isFalse);
    expect(s.secondiFatturati, 0);
  });

  test('la prova della fetta verticale resta scritta su disco', () {
    final b = StringBuffer()
      ..writeln('LA PORTA DEL LIVE: COSA SCENDE SUL TELEFONO E COSA NO')
      ..writeln('Ordine EG voci 01, 04 e 06.')
      ..writeln()
      ..writeln('COSA NON SCENDE MAI, cercato in tutto lib:')
      ..writeln('    PROTOFACE_API_KEY, LIVEKIT_API_SECRET, LIVEKIT_API_KEY,')
      ..writeln('    e perfino l\'indirizzo api.protoface.com.')
      ..writeln()
      ..writeln('    Chi ha il segreto di LiveKit entra in QUALUNQUE stanza di')
      ..writeln('    chiunque: per questo il telefono riceve solo un gettone')
      ..writeln('    gia\' fatto, buono per una stanza sola.')
      ..writeln()
      ..writeln('COSA SCENDE, dal server e per una sessione sola:')
      ..writeln('    url della stanza, gettone della persona, nome della')
      ..writeln('    stanza, identificativo della sessione, avatar del')
      ..writeln('    Maestro, minuti rimasti, durata massima.')
      ..writeln()
      ..writeln('I TRE RIFIUTI, che non sono errori:')
      ..writeln('    permission-denied  -> non e\' per te, e si invita')
      ..writeln('    resource-exhausted -> minuti finiti, e saluta il Maestro')
      ..writeln(
          '    tutto il resto     -> guasto, e si torna alla chat scritta')
      ..writeln()
      ..writeln('    Un errore solo per tutte e tre sarebbe un vicolo cieco.');
    final cartella = Directory('docs/collaudo/EG')..createSync(recursive: true);
    final f = File('${cartella.path}/la_porta_del_live.txt')
      ..writeAsStringSync(b.toString());
    expect(f.lengthSync(), greaterThan(600));
  });
}
