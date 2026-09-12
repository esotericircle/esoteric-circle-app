import 'dart:io';

import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:flutter_test/flutter_test.dart';

/// UNA CONVERSAZIONE NUOVA NON CANCELLA E NON DIMENTICA. Ordine CI voce 06.
///
/// **Qui si puo' fare un danno grave, e l'ordine lo dice.** Un comando che
/// svuota la chat e' a un passo da un comando che cancella i messaggi, e a due
/// passi da un comando che spegne la memoria del Maestro, cioe' la cosa per
/// cui l'abbonato paga. Queste prove tengono quei due passi chiusi.
///
/// **La marcatura si prova sul MODELLO e non a schermo**, perche' il danno,
/// se c'e', e' nei dati: un messaggio perso non torna guardando un'anteprima.
void main() {
  test('la marcatura viaggia con la copia del messaggio', () {
    const originale = ChatMessage(
      role: ChatRole.user,
      text: 'la mia domanda',
      conversazione: 'c123',
    );
    final copia = originale.copyWith(pending: false, failed: true);
    expect(copia.conversazione, 'c123',
        reason: 'un messaggio che cambia stato ha cambiato conversazione: '
            'da quel momento sparisce dalla sua chat senza essere stato '
            'cancellato da nessuno, che e\' il modo peggiore di perdere un '
            'messaggio');
  });

  test('un messaggio vecchio non ha marcatura, e vuol dire la prima', () {
    const vecchio = ChatMessage(role: ChatRole.user, text: 'scritto ieri');
    expect(vecchio.conversazione, isNull,
        reason: 'i messaggi scritti prima di questa voce devono restare senza '
            'marcatura: e\' il modo in cui questa voce non chiede nessuna '
            'migrazione, che a un milione di persone sarebbero quaranta '
            'milioni di scritture');
  });

  test('la marcatura non entra nell\'uguaglianza per sbaglio', () {
    // Se due messaggi identici in tutto tranne la conversazione risultassero
    // uguali, la chat ne mostrerebbe uno solo e l'altro sembrerebbe perso.
    const a =
        ChatMessage(role: ChatRole.user, text: 'uguale', conversazione: 'c1');
    const b =
        ChatMessage(role: ChatRole.user, text: 'uguale', conversazione: 'c2');
    expect(identical(a, b), isFalse);
    expect(a.conversazione == b.conversazione, isFalse);
  });

  test('il comando esiste a schermo e dice cosa NON fa', () {
    final sorgente =
        _leggi('lib/features/maestri/chat/maestro_chat_screen.dart');
    expect(sorgente.contains("Key('chat_conversazione_nuova')"), isTrue,
        reason: 'il comando per cominciare da capo non c\'e\' piu\'');
    expect(
        sorgente.contains("Key('chat_conferma_conversazione_nuova')"), isTrue,
        reason: 'il comando non chiede piu\' conferma: a schermo la chat si '
            'svuota, e una schermata che si svuota sembra sempre una '
            'cancellazione');
    // **LE TRE COSE CHE LA CONFERMA DEVE DIRE.** Non e' una prova di stile:
    // se la conferma non le dice, la persona crede di aver cancellato.
    for (final pezzo in ['resta dov', 'Ricordi', 'nessuna domanda']) {
      expect(sorgente.contains(pezzo), isTrue,
          reason: 'la conferma non dice "$pezzo": chi la legge non sa che '
              'cosa sta per succedere davvero');
    }
  });

  test('il controllore non cancella e non tocca la memoria', () {
    final sorgente =
        _leggi('lib/features/maestri/chat/maestro_chat_controller.dart');
    final i = sorgente.indexOf('void iniziaUnaConversazioneNuova');
    expect(i, greaterThan(-1), reason: 'il comando non esiste piu\'');
    final corpo = sorgente.substring(i, i + 600);
    // **NESSUNA CANCELLAZIONE.** `_messages.clear()` svuota la lista a
    // schermo, che e' voluto; quello che non deve esserci e' una scrittura
    // che tocca il magazzino.
    for (final vietato in [
      'delete',
      'cancella',
      '_memory.forget',
      '_memoryState = ',
    ]) {
      expect(corpo.contains(vietato), isFalse,
          reason: 'il comando contiene "$vietato": cominciare una '
              'conversazione nuova sta cancellando qualcosa, e non deve');
    }
    expect(corpo.contains('_messages.clear()'), isTrue,
        reason: 'il comando non svuota la conversazione a schermo, quindi non '
            'fa quello che promette');
  });

  // **VINCOLO D: LA CONVERSAZIONE CHIUSA SI RITROVA DAVVERO.**
  //
  // L'ordine chiedeva di verificare che ci arrivi, non che dovrebbe
  // arrivarci. Verificato, e non ci arrivava: nei Ricordi esistevano il tipo
  // `conversazione` e il suo filtro, e **nessuno ci scriveva niente**. La
  // pastiglia era vuota per costruzione, e dopo un "Ricomincia" la
  // conversazione di prima sarebbe stata irraggiungibile.
  test('ogni turno della chat entra nei Ricordi', () {
    final controllore =
        _leggi('lib/features/maestri/chat/maestro_chat_controller.dart');
    expect(controllore.contains('segnaNeiRicordi?.call('), isTrue,
        reason: 'i turni della chat non entrano piu\' nell\'indice dei '
            'Ricordi: la pastiglia Conversazioni torna vuota, e una '
            'conversazione chiusa diventa irraggiungibile');

    final schermata =
        _leggi('lib/features/maestri/chat/maestro_chat_screen.dart');
    expect(schermata.contains('TipoDelRicordo.conversazione'), isTrue,
        reason: 'la schermata non collega piu\' il registro: il gancio del '
            'controllore resta nullo e non scrive niente');
    expect(schermata.contains('RegistroDeiRicordi'), isTrue);
  });
}

String _leggi(String percorso) {
  final f = File(percorso);
  return f.existsSync() ? f.readAsStringSync() : '';
}
