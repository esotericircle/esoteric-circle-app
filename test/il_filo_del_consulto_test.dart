// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/chat/il_filo_del_consulto.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/services/ai/maestro_persona.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **IL FILO DEL CONSULTO. Ordine FE voci 08-14.**
///
/// Il tester: a piu' domande di fila il Maestro dava pareri nuovi e
/// scollegati, e se riprendeva una frase che il Maestro gli aveva appena
/// suggerito, il Maestro rispondeva un'altra cosa. Questa prova misura la
/// memoria unica del consulto: la scheda dei punti fermi scritta dal codice,
/// la legge della coerenza in un punto solo, il parere del primo Maestro che
/// arriva al secondo, la frase ripresa riconosciuta, l'ora di vita, e
/// l'istruzione di base che non cambia senza un consulto.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  var ora = DateTime(2026, 10, 6, 10);

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    IlFiloDelConsulto.dimentica();
    ora = DateTime(2026, 10, 6, 10);
    IlFiloDelConsulto.adesso = () => ora;
  });

  const rispostaDiMedora = 'Il cielo di questo mese ti chiede pazienza: '
      'Saturno rallenta le decisioni sul lavoro. Prima di chiedere la '
      'promozione, prepara con cura i tuoi risultati.\n'
      '✦ Aspetta la fine del mese prima di chiedere il colloquio.';

  test('il primo turno apre la scheda: tema e parere scritti dal codice', () {
    IlFiloDelConsulto.annota(
        maestro: Maestro.medora,
        domanda: 'Quando riceverò una promozione?',
        risposta: rispostaDiMedora);
    final s = IlFiloDelConsulto.scheda!;
    expect(s.tema, 'Quando riceverò una promozione?');
    expect(s.daMaestro, Maestro.medora);
    expect(s.pareri.single.parere,
        'Aspetta la fine del mese prima di chiedere il colloquio.');
  });

  test('il secondo Maestro riceve la scheda, la legge e la regola del primo',
      () {
    IlFiloDelConsulto.annota(
        maestro: Maestro.medora,
        domanda: 'Quando riceverò una promozione?',
        risposta: rispostaDiMedora);
    final perMedora = IlFiloDelConsulto.bloccoPer(Maestro.medora);
    final perCaligo = IlFiloDelConsulto.bloccoPer(Maestro.caligo);
    expect(perMedora, contains(LaLeggeDellaCoerenza.testo));
    expect(perMedora, isNot(contains(LaLeggeDellaCoerenza.ilSecondoMaestro)));
    expect(perCaligo, contains('Medora ha detto: «Aspetta la fine del mese'));
    expect(perCaligo, contains(LaLeggeDellaCoerenza.ilSecondoMaestro));
    expect(perCaligo, contains('«Quando riceverò una promozione?»'));
    // Il parere di Caligo si aggiunge, quello di Medora resta.
    IlFiloDelConsulto.annota(
        maestro: Maestro.caligo,
        domanda: 'E le rune cosa dicono?',
        risposta: 'Le rune parlano di un passaggio.\n'
            '✦ Prima del colloquio scrivi su un foglio cosa vuoi ottenere.');
    expect(IlFiloDelConsulto.scheda!.maestri, [Maestro.medora, Maestro.caligo]);
    expect(IlFiloDelConsulto.scheda!.tema, 'Quando riceverò una promozione?');
    // **Il peso della scheda**, con due pareri e la frase ripresa.
    final blocco = IlFiloDelConsulto.bloccoPer(Maestro.aura,
        fraseRipresa: 'Prima di chiedere la promozione, prepara con cura i '
            'tuoi risultati.');
    final token = (blocco.length / 4).round();
    print('ORDINE FE VOCE 09: la scheda con due pareri e la frase ripresa '
        'pesa ${blocco.length} caratteri, circa $token token');
    expect(token, lessThan(450));
  });

  test('oltre l\'ora il consulto e\' nuovo e il Maestro non finge', () {
    IlFiloDelConsulto.annota(
        maestro: Maestro.medora,
        domanda: 'Quando riceverò una promozione?',
        risposta: rispostaDiMedora);
    ora = ora.add(const Duration(minutes: 59));
    expect(IlFiloDelConsulto.scheda, isNotNull);
    ora = ora.add(const Duration(minutes: 2));
    expect(IlFiloDelConsulto.scheda, isNull);
    expect(IlFiloDelConsulto.bloccoPer(Maestro.aura), isEmpty);
    IlFiloDelConsulto.annota(
        maestro: Maestro.aura,
        domanda: 'Mi sento stanca',
        risposta: 'Respira.');
    expect(IlFiloDelConsulto.scheda!.tema, 'Mi sento stanca');
  });

  test('senza consulto l\'istruzione di base non cambia di un carattere', () {
    for (final m in Maestro.values) {
      final senza = MaestroPersona.systemInstruction(
          maestro: m, profile: UserProfile.empty, memory: MaestroMemory.empty);
      final colFiloVuoto = MaestroPersona.systemInstruction(
          maestro: m,
          profile: UserProfile.empty,
          memory: MaestroMemory.empty,
          filo: IlFiloDelConsulto.bloccoPer(m));
      expect(colFiloVuoto, senza, reason: m.name);
    }
    // E con un consulto in corso il filo entra davvero nell'istruzione.
    IlFiloDelConsulto.annota(
        maestro: Maestro.medora,
        domanda: 'Quando riceverò una promozione?',
        risposta: rispostaDiMedora);
    final conFilo = MaestroPersona.systemInstruction(
        maestro: Maestro.aura,
        profile: UserProfile.empty,
        memory: MaestroMemory.empty,
        filo: IlFiloDelConsulto.bloccoPer(Maestro.aura));
    expect(conFilo, contains(LaLeggeDellaCoerenza.testo));
    expect(conFilo, contains('Medora ha detto'));
  });

  test('la frase ripresa si riconosce, una domanda nuova no', () {
    expect(
        LaFraseRipresa.trova(
            'Prepara con cura i tuoi risultati prima di chiedere la promozione?',
            rispostaDiMedora),
        'Prima di chiedere la promozione, prepara con cura i tuoi risultati.');
    // La persona la riprende a modo suo, con circa due terzi delle parole.
    expect(
        LaFraseRipresa.trova(
            'Come preparo con cura i miei risultati per la promozione?',
            rispostaDiMedora),
        'Prima di chiedere la promozione, prepara con cura i tuoi risultati.');
    expect(LaFraseRipresa.trova('E in amore come andrà?', rispostaDiMedora),
        isNull);
    expect(LaFraseRipresa.trova('Grazie', rispostaDiMedora), isNull);
  });

  test('la chat, il LIVE e il Consiglio leggono lo stesso filo', () {
    final p = File('lib/services/ai/firebase_maestro_ai_provider.dart')
        .readAsStringSync();
    expect(RegExp(r'filo: IlFiloDelConsulto\.bloccoPer\(').allMatches(p).length,
        greaterThanOrEqualTo(2),
        reason: 'il turno o il Consiglio non ricevono il filo');
    final c = File('lib/features/maestri/chat/maestro_chat_controller.dart')
        .readAsStringSync();
    expect(c, contains('IlFiloDelConsulto.annota('),
        reason: 'i turni non entrano nel filo');
  });
}
