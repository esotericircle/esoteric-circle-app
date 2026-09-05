import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// LA PORTA PICCOLA AVVERTE CHI NON RISULTA. Ordine BH voce 03.
///
/// Parole del fondatore: "se all'inizio l'utente fa click su 'faccio gia'
/// parte del cerchio' e il sistema non rileva l'email, l'utente deve essere
/// avvertito che l'email non risulta registrata e che potra' fare la
/// registrazione poco dopo oppure nel menu utente".
void main() {
  String leggi(String p) => File(p).readAsStringSync();

  test('il neonato riceve un dialogo, non una snackbar che scappa', () {
    final s = leggi('lib/core/cammino/custode_del_cammino.dart');
    expect(s.contains("Key('cerchio_appena_nato')"), isTrue);
    expect(s.contains('Questa email non aveva un Cerchio'), isTrue,
        reason: 'l\'avviso non dice piu\' che l\'email non risultava');
    expect(s.contains("Key('cerchio_appena_nato_capito')"), isTrue,
        reason: 'l\'avviso non si congeda piu\' con un tocco dichiarato: '
            'e\' tornato un avviso che scappa da solo');
    // E si declina sui fatti: la dote quando c'e', la lapide quando ferma.
    expect(s.contains('la dote di benvenuto è tua'), isTrue);
    expect(s.contains('Il benvenuto non si ripete'), isTrue);
  });

  test('a chi non risulta si offre la strada della registrazione', () {
    final s = leggi('lib/features/account/custodia_del_cielo.dart');
    expect(s.contains('potrai farlo '), isTrue,
        reason: 'la strada in avanti per chi non risulta e\' sparita');
    expect(s.contains('oppure dal menu utente'), isTrue,
        reason: 'la via dal menu utente non viene piu\' nominata');
    // Solo sulla porta di chi torna: nel foglio della custodia normale
    // quella frase non avrebbe senso.
    expect(s.contains('widget.perChiTorna &&'), isTrue);
  });
}
