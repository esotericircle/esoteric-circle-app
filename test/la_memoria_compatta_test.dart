import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/services/ai/firebase_maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/maestro_persona.dart';
import 'package:flutter_test/flutter_test.dart';

/// **LA MEMORIA COMPATTA. Ordine EX voce 09.**
///
/// La storia che arriva al modello e' di otto messaggi; cio' che la persona
/// ha scritto prima della finestra, fino a venti messaggi indietro, arriva
/// nell'istruzione. Alla prova col modello vero
/// (`tool/la_memoria_compatta_a_confronto.dart`) il dettaglio detto da
/// cinque a nove scambi prima e' stato usato 7 volte su 10, contro 4 su 10
/// con venti messaggi di storia e nessun riassunto.
void main() {
  List<ChatMessage> conversazione(int scambi) => [
        for (var i = 0; i < scambi; i++) ...[
          ChatMessage(
              role: ChatRole.user,
              text: i == 0
                  ? 'Mia figlia Sara compie diciotto anni sabato.'
                  : 'Domanda di mezzo numero $i?'),
          ChatMessage(
              role: ChatRole.maestro,
              autore: Maestro.medora,
              text: 'Risposta del Maestro numero $i.'),
        ]
      ];

  test('il dettaglio fuori dalla finestra arriva nell\'istruzione', () {
    final storia = conversazione(7);
    expect(
        storia.length, greaterThan(FirebaseMaestroAiProvider.kHistoryWindow));
    final prima = FirebaseMaestroAiProvider.scrittoPrimaDellaFinestra(storia);
    expect(prima, contains('Mia figlia Sara compie diciotto anni sabato.'));
    // Solo cio' che ha scritto la persona, mai le risposte del Maestro.
    expect(prima.any((r) => r.startsWith('Risposta del Maestro')), isFalse);
    // E nulla di cio' che la finestra porta gia'.
    final nellaFinestra = storia
        .sublist(storia.length - FirebaseMaestroAiProvider.kHistoryWindow)
        .where((m) => m.isUser)
        .map((m) => m.text);
    for (final t in nellaFinestra) {
      expect(prima, isNot(contains(t)));
    }
    final istruzione = MaestroPersona.systemInstruction(
      maestro: Maestro.medora,
      profile: UserProfile.empty,
      memory: MaestroMemory.empty,
      scrittoPrima: prima,
    );
    expect(
        istruzione, contains('- Mia figlia Sara compie diciotto anni sabato.'));
  });

  test('una conversazione corta non ha riassunto', () {
    expect(
        FirebaseMaestroAiProvider.scrittoPrimaDellaFinestra(conversazione(3)),
        isEmpty);
  });

  test('oltre venti messaggi indietro il riassunto si ferma', () {
    final prima =
        FirebaseMaestroAiProvider.scrittoPrimaDellaFinestra(conversazione(15));
    expect(
        prima, isNot(contains('Mia figlia Sara compie diciotto anni sabato.')));
    expect(
        prima.length,
        (FirebaseMaestroAiProvider.kFinestraDelRiassunto -
                FirebaseMaestroAiProvider.kHistoryWindow) ~/
            2);
  });
}
