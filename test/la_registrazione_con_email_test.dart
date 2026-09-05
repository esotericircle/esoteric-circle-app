import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// LA REGISTRAZIONE CON EMAIL: DUE PORTE E IL VINCOLO DELLA VERIFICA.
/// Ordine BH voce 04. Parole del fondatore: possibile "sia come adesso,
/// alla fine dell'onboarding e sia successivamente dal menu utente",
/// e "vincolata" alla verifica dell'indirizzo.
void main() {
  String leggi(String p) => File(p).readAsStringSync();

  test('le due porte della registrazione esistono, enumerate', () {
    // La componente unica delle vie (Google, Apple, email) e' montata sia
    // dal passo dell'onboarding sia dal foglio che il menu utente apre.
    final vie = leggi('lib/features/account/custodia_del_cielo.dart');
    expect(vie.contains("Key('custodia_email')"), isTrue,
        reason: 'la via dell\'email e\' sparita dalle vie della custodia');
    final passo = leggi('lib/features/onboarding/custodia_del_cielo_step.dart');
    expect(passo.contains('VieDellaCustodia'), isTrue,
        reason: 'il passo dell\'onboarding non monta piu\' le vie');
    final menu = leggi('lib/features/account/account_screen.dart');
    expect(menu.contains('mostraInvitoACustodire'), isTrue,
        reason: 'dal menu utente non si apre piu\' la registrazione');
  });

  test('la verifica parte da sola quando l\'email si registra', () {
    final s = leggi('lib/core/identity/account_del_cerchio.dart');
    expect(s.contains('sendEmailVerification'), isTrue);
    // E parte DENTRO l'elevazione con email, non solo dalla voce del menu.
    final eleva = s.substring(s.indexOf('Future<EsitoDellaCustodia> eleva'),
        s.indexOf('on FirebaseAuthException'));
    expect(eleva.contains('sendEmailVerification'), isTrue,
        reason: 'la registrazione con email non manda piu\' la verifica da '
            'sola: il vincolo del fondatore resta appeso a una voce di menu');
  });

  test('la ricarica rinfresca il gettone, o il server non vede la verifica',
      () {
    final s = leggi('lib/core/identity/account_del_cerchio.dart');
    expect(s.contains('getIdToken(true)'), isTrue,
        reason: 'senza il rinfresco del gettone il server legge la verifica '
            'vecchia fino a un\'ora, e il benvenuto sbloccato non arriva');
  });

  test('il compimento della verifica passa dalla festa', () {
    final s = leggi('lib/features/account/account_screen.dart');
    expect(s.contains("Key('verifica_ho_verificato')"), isTrue,
        reason: 'la strada "ho verificato" e\' sparita dal menu');
    expect(s.contains('FestaDellaRegistrazione.dopoLaCustodia'), isTrue,
        reason: 'la verifica compiuta non passa dalla festa: il premio '
            'arriverebbe muto');
    expect(s.contains("Key('verifica_non_ancora')"), isTrue,
        reason: 'a chi non risulta verificato non si dice piu\' niente');
  });
}
