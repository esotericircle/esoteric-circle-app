import 'dart:io';

import 'package:esoteric_circle/core/chat/altre_voci.dart';
import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/maestro/consult_depth.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_reply.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_controller.dart';
import 'package:esoteric_circle/services/ai/maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/maestro_oracle.dart';
import 'package:esoteric_circle/services/memory/in_memory_maestro_memory_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// LE ALTRE VOCI ARRIVANO UNA ALLA VOLTA.
///
/// **L'ipotesi dell'ordine, verificata prima di correggere, ed E' CADUTA.**
/// L'ordine dava per fatto che "Chiedi anche agli altri" mandasse le chiamate
/// degli altri due Maestri ravvicinate, con lo stesso schema che ha fatto
/// scattare il 429. Cercando in tutto `lib` i punti che chiedono una risposta
/// a un Maestro se ne trovano TRE, e nessuno dei tre le chiede in parallelo:
/// `chiediAgliAltri` aspetta ogni voce dentro il suo ciclo, e la Sintesi
/// comparativa parte dopo, quando le lenti sono gia' arrivate. Il 429 veniva
/// dallo strumento di misura, `tool/risposte_intere.dart`, che ne mandava
/// cinque insieme, ed e' stato corretto il 3 agosto 2026.
///
/// **Allora perche' questo file esiste.** Perche' quella proprieta' non era
/// scritta da nessuna parte: reggeva perche' chi ha scritto quel ciclo ha messo
/// un `await`, e il giorno che qualcuno lo toglie per fare prima, nessuno se ne
/// accorge finche' Vertex non risponde 429 a un utente vero. La prova qui sotto
/// ENUMERA i punti che chiedono risposte e cade se uno le manda insieme.
void main() {
  test('Nessun punto chiede piu\' risposte insieme', () {
    // I MODI DI PARTIRE INSIEME, e cosa non deve esserci dentro.
    //
    // **Qui cercavo la cosa sbagliata, e una prova del rosso me lo ha detto.**
    // Cercavo la chiamata diretta all'AI, `.reply(` e le sue sorelle. Ma il
    // pericolo sta un livello SOPRA: mettendo in parallelo `_generate`, che e'
    // il metodo del controllore, dentro la parentesi non compare nessuna
    // chiamata all'AI, e la prova restava verde mentre le tre voci partivano
    // insieme. Si cerca quindi qualunque parallelo che riguardi un MAESTRO,
    // che e' la forma vera del difetto.
    const insieme = ['Future.wait', 'Future.any', 'unawaited('];
    const chiedono = [
      '.reply(',
      '.consult(',
      '.synthesize(',
      'Maestro',
      'maestro',
    ];

    // LE ECCEZIONI, dichiarate con la ragione accanto e non nascoste.
    //
    // Un parallelo che riguarda un Maestro non e' per forza un parallelo di
    // RISPOSTE: qui si leggono tre cose diverse dello stesso Maestro, e
    // leggerle una alla volta allungherebbe l'apertura della chat senza
    // toccare nessuna quota, perche' non e' Vertex che risponde, e' la
    // memoria locale.
    const eccezioni = <String, String>{
      'lib/features/maestri/chat/maestro_chat_controller.dart riga 192':
          'sono tre LETTURE della memoria per UN Maestro, non tre risposte '
              'chieste a tre Maestri: non passano da Vertex',
    };

    final colpe = <String>[];
    final da = <FileSystemEntity>[Directory('lib')];
    while (da.isNotEmpty) {
      final voce = da.removeLast();
      if (voce is Directory) {
        da.addAll(voce.listSync());
        continue;
      }
      if (voce is! File || !voce.path.endsWith('.dart')) continue;
      final percorso = voce.path.replaceAll(Platform.pathSeparator, '/');
      final righe = voce.readAsLinesSync();

      for (var i = 0; i < righe.length; i++) {
        final riga = righe[i];
        if (riga.trimLeft().startsWith('//')) continue;
        if (!insieme.any(riga.contains)) continue;
        // Il corpo della chiamata: da qui fino alla fine dell'istruzione. Se
        // dentro ci si chiede una risposta a un Maestro, quelle risposte
        // partono insieme.
        final dentro = <String>[];
        for (var j = i; j < righe.length && j < i + 12; j++) {
          dentro.add(righe[j]);
          if (righe[j].contains(');')) break;
        }
        final corpo =
            dentro.where((r) => !r.trimLeft().startsWith('//')).join('\n');
        if (chiedono.any(corpo.contains)) {
          final dove = '$percorso riga ${i + 1}';
          if (eccezioni.containsKey(dove)) continue;
          colpe.add('$dove: ${riga.trim()}');
        }
      }
    }

    expect(
      colpe,
      isEmpty,
      reason: 'qui si chiedono piu\' risposte insieme. Non e\' solo una '
          'questione di quota: tre Maestri che rispondono nello stesso istante '
          'sanno di chiamata multipla, tre voci che arrivano una dopo l\'altra '
          'sanno di cerchio che si consulta.\n${colpe.join("\n")}',
    );
  });

  test('Ogni voce compare quando e\' pronta, non quando sono pronte tutte',
      () async {
    // Se si aspettasse l'ultima per mostrarle tutte, la seconda voce non
    // sarebbe in cronologia mentre la terza sta ancora arrivando.
    final voce = _VoceCheAnnuncia();
    final chat = MaestroChatController(
      maestro: Maestro.medora,
      memory: InMemoryMaestroMemoryRepository(),
      ai: voce,
      attesaMinima: Duration.zero,
    );
    await chat.init();
    await chat.send('Devo cambiare lavoro?');
    expect(chat.messages.length, 2);

    await chat.chiediAgliAltri();

    // Le due altre voci sono arrivate, ognuna col suo autore.
    final autori = chat.messages
        .where((m) => m.isMaestro && m.autore != null)
        .map((m) => m.autore)
        .toSet();
    expect(autori, containsAll(AltreVoci.altriDi(Maestro.medora)));
    // E le chiamate sono partite UNA ALLA VOLTA: la prova sta nel finto, che
    // conta quante ne ha aperte contemporaneamente.
    expect(voce.massimoInVolo, 1,
        reason: 'sono partite ${voce.massimoInVolo} chiamate insieme');
  });

  test('Se una voce fallisce, quelle gia\' arrivate restano', () async {
    final voce = _VoceCheCadeSuUno(chiCade: AltreVoci.altriDi(Maestro.medora).last);
    final chat = MaestroChatController(
      maestro: Maestro.medora,
      memory: InMemoryMaestroMemoryRepository(),
      ai: voce,
      attesaMinima: Duration.zero,
    );
    await chat.init();
    await chat.send('Devo cambiare lavoro?');
    await chat.chiediAgliAltri();

    final primaAltra = AltreVoci.altriDi(Maestro.medora).first;
    final suoTurno =
        chat.messages.where((m) => m.autore == primaAltra).toList();
    expect(suoTurno, hasLength(1),
        reason: 'la voce arrivata bene e\' sparita quando l\'altra e\' caduta');
    expect(suoTurno.single.ripiego, isFalse,
        reason: 'la voce arrivata bene e\' diventata un ripiego');
    // E quella caduta c'e' lo stesso, dichiarata: un guasto non lascia un buco.
    final caduta = chat.messages.where((m) => m.autore == voce.chiCade);
    expect(caduta, hasLength(1));
    expect(caduta.single.ripiego, isTrue);
  });
}

/// Conta quante chiamate sono in volo nello stesso momento.
class _VoceCheAnnuncia implements MaestroAiProvider {
  int inVolo = 0;
  int massimoInVolo = 0;

  @override
  bool get isReady => true;

  @override
  Future<String> reply({
    required Maestro maestro,
    required UserProfile profile,
    required MaestroMemory memory,
    required List<ChatMessage> history,
    required String userMessage,
    NatalContext natal = NatalContext.none,
    bool insistiSullAncoraggio = false,
    bool approfondisci = false,
  }) async {
    inVolo++;
    if (inVolo > massimoInVolo) massimoInVolo = inVolo;
    await Future<void>.delayed(const Duration(milliseconds: 10));
    inVolo--;
    return 'Le stelle di ${maestro.displayName} dicono che il tempo si apre '
        'fra due lune, e che la direzione la scegli tu.';
  }

  @override
  Future<MaestroReply> consult({
    required Maestro maestro,
    required String theme,
    required UserProfile profile,
    MaestroMemory memory = MaestroMemory.empty,
    NatalContext? natal,
    ConsultDepth depth = ConsultDepth.breve,
  }) async =>
      throw UnimplementedError();

  @override
  Future<String> synthesize({
    required String theme,
    required List<MaestroLens> lenses,
    NatalContext? natal,
  }) async =>
      throw UnimplementedError();

  @override
  Future<MemoryDigest?> distill({
    required Maestro maestro,
    required UserProfile profile,
    required MaestroMemory previous,
    required List<ChatMessage> history,
  }) async =>
      null;
}

/// Cade su un Maestro solo, e risponde agli altri.
class _VoceCheCadeSuUno extends _VoceCheAnnuncia {
  _VoceCheCadeSuUno({required this.chiCade});
  final Maestro chiCade;

  @override
  Future<String> reply({
    required Maestro maestro,
    required UserProfile profile,
    required MaestroMemory memory,
    required List<ChatMessage> history,
    required String userMessage,
    NatalContext natal = NatalContext.none,
    bool insistiSullAncoraggio = false,
    bool approfondisci = false,
  }) async {
    if (maestro == chiCade) throw StateError('la rete non risponde');
    return super.reply(
      maestro: maestro,
      profile: profile,
      memory: memory,
      history: history,
      userMessage: userMessage,
      natal: natal,
    );
  }
}
