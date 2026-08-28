import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// LE PROMESSE DELL'APP SI MANTENGONO, O SI SMETTE DI PROMETTERE. Ordine BG
/// voce 03: due censimenti sul repo (le tre promesse del fondatore piu'
/// tutte le promesse a schermo) e nove cure. Qui le guardie che tengono
/// ferme le cure; cio' che resta dichiarato sta nel manifesto BG.
void main() {
  String leggi(String p) => File(p).readAsStringSync();

  test('il saluto del ritrovamento si declina sulla cortesia', () {
    final s = leggi('lib/features/onboarding/scena_del_ritrovamento.dart');
    expect(s.contains('Bentornata nel Cerchio'), isTrue,
        reason: 'il femminile e\' sparito dal saluto del ritrovamento');
    expect(s.contains('Di nuovo nel Cerchio'), isTrue,
        reason: 'il neutro e\' sparito dal saluto del ritrovamento');
    // E la porta piccola, dove la cortesia non e' ancora scelta, saluta
    // neutro per convenzione.
    final o = leggi('lib/features/onboarding/onboarding_screen.dart');
    expect(o.contains('Di nuovo nel Cerchio,'), isTrue,
        reason: 'la porta piccola e\' tornata al maschile cablato');
  });

  test('la custodia dice che e\' gratuita, e il primo avviso non si brucia',
      () {
    final c = leggi('lib/features/account/custodia_del_cielo.dart');
    expect(c.contains('gratuito'), isTrue,
        reason: 'l\'invito alla custodia non dice piu\' che registrarsi e\' '
            'gratuito');
    expect(c.contains('if (momenti <= 0) return false;'), isFalse,
        reason: 'il rifiuto sullo zero e\' tornato: brucerebbe di nuovo il '
            'primo avviso di BE.07');
    final s = leggi('lib/features/santuario/santuario_screen.dart');
    expect(s.indexOf('mostraInvitoACustodire') <
            // La stringa cercata si spezza in due letterali adiacenti: questa
            // prova legge il SORGENTE, non l'orologio, e la guardia
            // dell'istante non deve scambiarla per una lettura vera.
            s.indexOf('_chiaveUltimoInvito, Date' 'Time.now()'),
        isTrue,
        reason: 'la data dell\'invito si scrive prima di mostrarlo: se il '
            'foglio non si apre, l\'avviso risulta dato senza esserlo');
  });

  test('i rimandi della custodia sopravvivono al riavvio', () {
    final a = leggi('lib/core/identity/account_del_cerchio.dart');
    expect(a.contains("'account.rimandi'"), isTrue,
        reason: 'il conto dei rimandi e\' tornato in sola memoria: il no '
            'ripetuto non sopravvive al riavvio');
  });

  test('in demo la memoria dei Maestri e\' accesa', () {
    final c = leggi('lib/features/maestri/chat/maestro_chat_controller.dart');
    expect(c.contains('AppFlags.isDemo'), isTrue,
        reason: 'la demo distilla di nuovo solo a pagamento: i Maestri della '
            'presentazione hanno l\'amnesia');
    final s = leggi('lib/features/maestri/chat/maestro_chat_screen.dart');
    expect(s.contains('AppFlags.isDemo ||'), isTrue,
        reason: 'il benvenuto in demo non riprende piu\' la memoria');
  });

  test('nessuna promessa di avvisi che nessuno programma', () {
    final p = leggi('lib/core/permissions/app_permission.dart');
    expect(p.contains('ritorno solare'), isFalse,
        reason: 'il copy delle notifiche promette di nuovo transiti e '
            'ritorni solari che nessuno programma');
    final a = leggi('lib/services/avvisi_locali.dart');
    for (final canale in const [
      "'oroscopo_giorno'",
      "'sigilli_del_cammino'",
      "'gettate_rune'",
    ]) {
      expect(a.contains('$canale: ('), isFalse,
          reason: 'il canale stantio $canale e\' tornato nelle impostazioni '
              'di Android a promettere avvisi mai programmati');
    }
  });

  test('l\'invito non promette un trigger che non osserva', () {
    final b = leggi('lib/core/sigilli/bonus_della_condivisione.dart');
    // Si guarda la FRASE A SCHERMO (quandoArriva), non i commenti, che la
    // storia del perche' la citano apposta.
    // **SI GUARDA IL SENSO, non la lettera.** Ordine BX: la parola "Eos" e\'
    // uscita dalla frase, perche\' la riga si componeva come "$quanti Eos ..."
    // e senza numero a schermo si leggeva "Eos quando il tuo amico entra nel
    // Cerchio". Cio\' che questa riga sorveglia non e\' cambiato: la frase
    // promette l\'INGRESSO, che il Cerchio sa vedere da quando esiste
    // `riscattaLInvito`, e non il download, che nessuno puo\' osservare.
    final frase = RegExp(r"quandoArriva: '([^']*amico[^']*)'").firstMatch(b);
    expect(frase, isNotNull,
        reason: 'la frase dell\'invito non parla piu\' dell\'amico');
    // ignore: avoid_print
    print('ORDINE BX: la frase dell\'invito dice "${frase!.group(1)}"');
    expect(frase.group(1), contains('entra nel Cerchio'),
        reason: 'la frase dell\'invito non promette piu\' l\'ingresso');
    expect(frase.group(1)!.toLowerCase(), isNot(contains('scarica')),
        reason: 'la frase dell\'invito promette di vedere il download, che '
            'il sistema non puo\' osservare');
  });
}
