import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **LA MEMORIA NON PUO' ZITTIRE UN MAESTRO.** Ordine DC voce 16,
/// 10 settembre 2026.
///
/// **DA DOVE NASCE, ed e' un difetto mio dell'ordine DB.** La voce DB.08
/// innestava il riassunto del respiro nell'apertura della chat con un
/// `await`. In `flutter test` senza il finto archivio,
/// `SharedPreferences.getInstance()` **non completa mai**: l'apertura restava
/// appesa e il Maestro taceva. **Undici prove di chat sono cadute insieme**, e
/// fra queste proprio quella che pretende che un Maestro non resti mai muto.
///
/// **LA CURA NON E' UN'ATTESA PIU' CORTA.** Ho provato anche quella, mettendo
/// la lettura dentro il `Future.wait` che gia' c'era: **le prove sono rimaste
/// rosse**, perche' il problema non era la latenza, era la dipendenza. La
/// regola giusta e' quella che l'ordine detta: **se il riassunto non arriva,
/// il Maestro parla lo stesso**, e la mancanza finisce nel registro invece
/// che sullo schermo della persona.
///
/// **E VALE PER OGNI SORGENTE DI MEMORIA, presente e futura**, quindi anche
/// per il Diario dei Viaggi che l'ordine DC introduce. Per questo la guardia
/// non cerca il respiro per nome: **cerca la forma del difetto**, cioe' una
/// attesa su una sorgente di memoria dentro il percorso che apre la chat.
void main() {
  final controllore =
      File('lib/features/maestri/chat/maestro_chat_controller.dart');

  /// Il corpo di `init()`, senza commenti: qui i commenti raccontano proprio
  /// il difetto, e una ricerca che li leggesse troverebbe se stessa.
  String corpoDiInit() {
    final righe = [
      for (final r in controllore.readAsLinesSync())
        if (!r.trimLeft().startsWith('//')) r,
    ];
    final testo = righe.join('\n');
    final da = testo.indexOf('Future<void> init() async {');
    expect(da, greaterThan(0),
        reason: 'la chat non ha piu un init: questa guardia sta guardando un '
            'file che non e piu quello');
    // Si legge fino alla prossima dichiarazione allo stesso livello.
    final fine = testo.indexOf('\n  /// ', da);
    return testo.substring(da, fine > da ? fine : testo.length);
  }

  test('NESSUNA MEMORIA SI ASPETTA DENTRO L APERTURA DELLA CHAT', () {
    final init = corpoDiInit();
    cardinaleMinimo(init.length, 400,
        cosa: 'caratteri del corpo di init()',
        perche: 'Su un init svuotato non ci sono attese da trovare, e la '
            'guardia sarebbe verde per non aver letto niente.');
    // **LE SORGENTI DI MEMORIA CHE NON DEVONO ESSERE ATTESE.** L'elenco si
    // allunga quando ne nasce una: e' la stessa regola per tutte.
    const sorgenti = [
      'MemoriaDelRespiro',
      'DiarioDeiViaggi',
      'TracciaDelLoto',
      'SequenzeDiAura',
      'RitrattiDelViso',
      'FaceHistory',
    ];
    final attese = <String>[];
    for (final s in sorgenti) {
      // Si cerca l'attesa, non la presenza: il riassunto PUO' entrare, quello
      // che non puo' fare e' **tenere ferma l'apertura**.
      if (RegExp('await\\s+[_a-zA-Z]*\\.?\\w*$s|await\\s+_\\w+\\.carica\\(\\)')
              .hasMatch(init) &&
          init.contains(s)) {
        attese.add(s);
      }
    }
    // Il caso generale: qualunque `await` su un `carica()` dentro init.
    if (RegExp(r'await\s+_?\w+\.carica\(\)').hasMatch(init)) {
      attese.add('un carica() atteso');
    }
    // ignore: avoid_print
    print('ORDINE DC VOCE 16: caratteri di init guardati ${init.length}, '
        'sorgenti di memoria attese ${attese.length}');
    expect(attese, isEmpty,
        reason: 'l apertura della chat aspetta una sorgente di memoria: '
            '${attese.join(", ")}. Se quell archivio non risponde, il Maestro '
            'resta muto, ed e il difetto che ha fatto cadere undici prove '
            'nell ordine DB');
  });

  test('IL RIASSUNTO ENTRA LO STESSO, ma senza tenere fermo nessuno', () {
    // **REGOLA H: non basta che non si aspetti.** Se il riassunto non entrasse
    // affatto, questa guardia sarebbe verde e la voce DB.08 sarebbe morta.
    final testo = controllore.readAsStringSync();
    expect(testo.contains('riassuntoPerIMaestri'), isTrue,
        reason: 'il riassunto del respiro non entra piu nel contesto dei '
            'Maestri: la voce DB.08 e stata cancellata invece che curata');
    expect(testo.contains('unawaited('), isTrue,
        reason: 'il riassunto non arriva piu per una via che non blocca: '
            'delle due cure e stata scelta quella sbagliata');
  });

  test('REGOLA H: E NESSUN MAESTRO DICHIARA DI OSSERVARE', () {
    // La voce DB.08 lo pretendeva e resta vera: il Maestro deve **sapere**,
    // non deve **dirlo**. Una cura alla memoria che rompesse questo vincolo
    // sarebbe un difetto peggiore di quello curato.
    final testo = controllore.readAsStringSync();
    final righe = [
      for (final r in testo.split('\n'))
        if (!r.trimLeft().startsWith('//')) r,
    ];
    final codice = righe.join('\n').toLowerCase();
    for (final vietata in const [
      'ti osservo',
      'ho notato che',
      'sto monitorando',
      'i tuoi dati mi dicono',
    ]) {
      expect(codice.contains(vietata), isFalse,
          reason: 'il contesto passa al modello la frase "$vietata": il '
              'Maestro deve sapere senza dichiarare di sapere');
    }
  });
}
