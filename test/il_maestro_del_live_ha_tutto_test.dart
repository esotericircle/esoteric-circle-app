// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/features/maestri/live/stato_della_schermata_live.dart';
import 'package:esoteric_circle/services/live/porta_del_live.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **IL MAESTRO DEL LIVE HA TUTTO, O NON SI APRE. Ordine FE voce 03.**
///
/// Enumera i tre Maestri e, per ciascuno, ogni risorsa che il collegamento
/// vocale usa: nel telefono il busto che si vede mentre il volto arriva e il
/// saluto detto a voce, nel server l'avatar, la voce di partenza, il genere,
/// il modo, la frase di prova e le voci candidate (le tabelle di
/// `functions/src/live.ts`, provate anche da `live.test.ts`). E prova che una
/// sessione arrivata a meta' non si apre: la persona legge che il Maestro non
/// e' raggiungibile, invece di vedere l'app chiudersi.
void main() {
  final live = File('functions/src/live.ts').readAsStringSync();

  /// Le chiavi di una tabella `const NOME: Record<string, ...> = { ... };`.
  Set<String> chiaviDi(String nome) {
    final inizio = live.indexOf(RegExp('(const|let) $nome\\b[^=]*= \\{'));
    expect(inizio, greaterThan(0), reason: 'la tabella $nome non c\'e\'');
    final apre = live.indexOf('{', live.indexOf('=', inizio));
    var profondita = 0, fine = apre;
    for (var i = apre; i < live.length; i++) {
      if (live[i] == '{' || live[i] == '[') profondita++;
      if (live[i] == '}' || live[i] == ']') profondita--;
      if (profondita == 0) {
        fine = i;
        break;
      }
    }
    // Le chiavi al primo livello: via le stringhe (i modi portano i due
    // punti), i commenti e i blocchi annidati, poi `nome:`.
    var corpo = live
        .substring(apre + 1, fine)
        .replaceAll(RegExp(r'//[^\n]*'), '')
        .replaceAll(RegExp(r'"(?:[^"\\]|\\.)*"'), '""');
    while (RegExp(r'\{[^{}]*\}').hasMatch(corpo)) {
      corpo = corpo.replaceAll(RegExp(r'\{[^{}]*\}'), '');
    }
    return {
      for (final m in RegExp(r'(\w+)\s*:').allMatches(corpo)) m.group(1)!,
    };
  }

  test('ogni Maestro ha ogni risorsa del collegamento vocale', () {
    final maestri = Maestro.values.map((m) => m.name).toSet();
    cardinaleMinimo(maestri.length, 3, cosa: 'Maestri del LIVE');
    final mancanze = <String, List<String>>{};
    const tabelle = [
      'AVATAR',
      'LE_VOCI_DI_PARTENZA',
      'IL_GENERE',
      'I_MODI',
      'LA_FRASE_DI_PROVA',
      // LE_CANDIDATE nasce da IL_GENERE: la prova del server
      // (`leMancanzeDelMaestro`) la guarda per ogni Maestro.
    ];
    final pubspec = File('pubspec.yaml').readAsStringSync();
    for (final m in Maestro.values) {
      final manca = <String>[];
      final busto = File(m.avatarAsset);
      if (!busto.existsSync() || busto.lengthSync() == 0) manca.add('busto');
      final cartella =
          m.avatarAsset.substring(0, m.avatarAsset.lastIndexOf('/') + 1);
      if (!pubspec.contains(cartella) && !pubspec.contains(m.avatarAsset)) {
        manca.add('busto non dichiarato');
      }
      if (ilSalutoDellaVoceViva(m).trim().isEmpty) manca.add('saluto');
      for (final t in tabelle) {
        if (!chiaviDi(t).contains(m.name)) manca.add(t);
      }
      mancanze[m.name] = manca;
    }
    print('ORDINE FE VOCE 03: risorse mancanti per Maestro $mancanze '
        '(${tabelle.length} tabelle del server, busto, saluto)');
    for (final e in mancanze.entries) {
      expect(e.value, isEmpty, reason: 'a ${e.key} manca ${e.value}');
    }
    final delServer = RegExp(r'I_MAESTRI_DEL_LIVE = \[([^\]]*)\]')
        .firstMatch(live)!
        .group(1)!;
    expect(
        RegExp(r'"(\w+)"').allMatches(delServer).map((x) => x.group(1)).toSet(),
        maestri,
        reason: 'il server e l\'app non servono gli stessi Maestri');
  });

  test('una sessione a meta\' non si apre: il Maestro non e\' raggiungibile',
      () async {
    final prima = PortaDelLive.chiama;
    addTearDown(() => PortaDelLive.chiama = prima);
    final piena = {
      'url': 'wss://stanza',
      'gettone': 'g',
      'sessione': 's',
      'avatar': 'av_1',
    };
    for (final pezzo in piena.keys) {
      PortaDelLive.chiama = (porta, dati) async => {...piena}..remove(pezzo);
      await expectLater(
          PortaDelLive.apri(Maestro.medora),
          throwsA(isA<IlLiveNonSiApre>().having((e) => e.perche, 'perche',
              PerchePerILiveNonSiApre.configurazioneIncompleta)),
          reason: 'senza $pezzo la sessione si apre');
    }
    PortaDelLive.chiama = (porta, dati) async => piena;
    expect((await PortaDelLive.apri(Maestro.medora)).avatar, 'av_1');
    expect(perchePerIlCodice('failed-precondition'),
        PerchePerILiveNonSiApre.configurazioneIncompleta);
    final quadro = QuadroDelLive(
      momento: MomentoDelLive.nonSiApre,
      maestro: Maestro.medora,
      perche: PerchePerILiveNonSiApre.configurazioneIncompleta,
    );
    expect(quadro.laFraseDelRifiuto(),
        'Questo Maestro non è raggiungibile adesso. Riprova fra poco.');
  });
}
