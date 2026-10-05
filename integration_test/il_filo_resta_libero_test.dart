// ignore_for_file: avoid_print
import 'dart:async';

import 'package:esoteric_circle/core/astro/il_cielo_che_arriva.dart';
import 'package:esoteric_circle/core/astro/prossimi_eventi.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/services/ai/firebase_maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/maestro_persona.dart';
import 'package:esoteric_circle/services/live/porta_del_live.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// **IL FILO RESTA LIBERO, SU UN TELEFONO VERO. Ordine FE voce 21.**
///
/// Gira su Firebase Test Lab e su qualunque Android collegato. Misura sul
/// telefono la catena del crash del Redmi Note 14 Pro 5G (build 2298, stack
/// tradotto in docs/collaudo/FE/lo_stack_del_redmi_tradotto.txt):
///  1. gli eventi in arrivo di 400 giorni calcolati sul filo principale,
///     come nella 2298: quanto tengono fermo il filo su QUESTO telefono;
///  2. la stessa cosa dalla porta [IlCieloCheArriva], fuori dal filo;
///  3. l'istruzione di ogni Maestro con una nascita, dopo la cura;
///  4. il turno vero di ogni Maestro col modello, per una persona col segno:
///     il fermo piu' lungo del filo principale mentre risponde;
///  5. l'apertura del LIVE coi tre Maestri.
/// Ogni misura si stampa con "ORDINE FE VOCE 21".
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  /// Il fermo piu' lungo del filo principale mentre [lavoro] gira: un
  /// orologio batte ogni 10 ms e si tiene il buco piu' grande fra due battiti.
  Future<(T, int)> fermoDurante<T>(FutureOr<T> Function() lavoro) async {
    var ultimo = DateTime.now();
    var peggiore = 0;
    final orologio = Timer.periodic(const Duration(milliseconds: 10), (_) {
      final ora = DateTime.now();
      final buco = ora.difference(ultimo).inMilliseconds;
      if (buco > peggiore) peggiore = buco;
      ultimo = ora;
    });
    try {
      await Future<void>.delayed(const Duration(milliseconds: 30));
      final esito = await lavoro();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      final ora = DateTime.now().difference(ultimo).inMilliseconds;
      if (ora > peggiore) peggiore = ora;
      return (esito, peggiore);
    } finally {
      orologio.cancel();
    }
  }

  testWidgets('il filo principale non resta fermo per il cielo',
      (tester) async {
    await Firebase.initializeApp();
    if (FirebaseAuth.instance.currentUser == null) {
      await FirebaseAuth.instance.signInAnonymously();
    }
    final dati = <String, Object?>{};
    final oggi = DateTime.now();

    // 1. Come nella 2298: 400 giorni sul filo.
    final w = Stopwatch()..start();
    ProssimiEventi.da(adesso: oggi, segno: Zodiac.gemini);
    dati['eventi_sul_filo_ms'] = w.elapsedMilliseconds;
    // 2. Dalla porta, fuori dal filo.
    IlCieloCheArriva.dimentica();
    final (_, fermoPorta) = await fermoDurante(
        () => IlCieloCheArriva.prepara(adesso: oggi, segno: Zodiac.gemini));
    dati['eventi_dalla_porta_fermo_ms'] = fermoPorta;
    print('ORDINE FE VOCE 21: eventi in arrivo di 400 giorni sul filo '
        '${dati['eventi_sul_filo_ms']} ms (la 2298, due volte per ogni '
        'istruzione); dalla porta fuori dal filo, filo fermo al massimo '
        '$fermoPorta ms');

    // 3. L'istruzione dei tre Maestri con una nascita.
    const natal =
        NatalContext(sunSign: 'Gemelli', lifeNumberTitle: 'il Costruttore');
    for (final m in Maestro.values) {
      final w2 = Stopwatch()..start();
      MaestroPersona.systemInstruction(
          maestro: m,
          profile: UserProfile.empty,
          memory: MaestroMemory.empty,
          natal: natal);
      dati['${m.name}_istruzione_ms'] = w2.elapsedMilliseconds;
    }
    print('ORDINE FE VOCE 21: istruzione con una nascita, ms '
        '${[
      for (final m in Maestro.values)
        '${m.name} ${dati['${m.name}_istruzione_ms']}'
    ]}');

    // 4. Il turno vero, per una persona col segno.
    final provider = FirebaseMaestroAiProvider();
    for (final m in [Maestro.medora, Maestro.aura, Maestro.caligo]) {
      try {
        final (risposta, fermo) = await fermoDurante(() => provider.reply(
              maestro: m,
              profile: UserProfile.empty,
              memory: MaestroMemory.empty,
              history: const [],
              userMessage: 'Cosa mi dice il cielo per questo mese?',
              natal: natal,
            ));
        dati['${m.name}_turno_fermo_ms'] = fermo;
        print('ORDINE FE VOCE 21: turno di ${m.name}, filo fermo al massimo '
            '$fermo ms, risposta di ${risposta.length} caratteri');
      } catch (e) {
        print('ORDINE FE VOCE 21: turno di ${m.name} non riuscito: $e');
        dati['${m.name}_errore'] = '$e';
      }
    }

    // 5. Il LIVE coi tre Maestri.
    for (final m in [Maestro.medora, Maestro.aura, Maestro.caligo]) {
      try {
        final s = await PortaDelLive.apri(m);
        print('ORDINE FE VOCE 21: LIVE di ${m.name} aperto');
        dati['${m.name}_live'] = 'aperto';
        if (s.sessione.isNotEmpty) await PortaDelLive.chiudi(s.sessione);
      } on IlLiveNonSiApre catch (e) {
        print('ORDINE FE VOCE 21: LIVE di ${m.name} non si apre: '
            '${e.perche.name}');
        dati['${m.name}_live'] = e.perche.name;
      }
    }
    binding.reportData = dati;
    expect(fermoPorta, lessThan(500));
    for (final m in Maestro.values) {
      expect(dati['${m.name}_istruzione_ms'] as int, lessThan(500));
      final fermo = dati['${m.name}_turno_fermo_ms'];
      if (fermo is int) expect(fermo, lessThan(5000));
    }
  });
}
