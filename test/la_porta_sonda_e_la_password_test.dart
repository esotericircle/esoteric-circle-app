import 'dart:io';

import 'package:esoteric_circle/features/account/custodia_del_cielo.dart';
import 'package:flutter_test/flutter_test.dart';

/// LA PORTA CHE SONDA, LA PASSWORD DI TUTTI, IL RICORDO DETTO GIUSTO.
/// Ordine BI, voci 01, 02, 03 e 04: le guardie delle cure nate dal
/// collaudo della 2203.
void main() {
  String leggi(String p) => File(p).readAsStringSync();

  test('la regola della Password e\' quella del fondatore, e parla', () {
    // Otto caratteri, una maiuscola, un numero, un carattere speciale.
    expect(guaioDellaPassword(''), isNotNull);
    expect(guaioDellaPassword('Ab1!'), contains('8 caratteri'));
    expect(guaioDellaPassword('abcdefg1!'), contains('maiuscola'));
    expect(guaioDellaPassword('Abcdefgh!'), contains('numero'));
    expect(guaioDellaPassword('Abcdefg1'), contains('speciale'));
    expect(guaioDellaPassword('Abcdef1!'), isNull,
        reason: 'una password che rispetta la regola viene rifiutata');
    // E la regola sta SCRITTA sotto il campo, come chiede il fondatore.
    expect(regolaDellaPassword, contains('8 caratteri'));
    expect(regolaDellaPassword, contains('maiuscola'));
  });

  test('il foglio dell\'email parla come tutti, con l\'occhiolino', () {
    final s = leggi('lib/features/account/custodia_del_cielo.dart');
    expect(s.contains("labelText: 'Password'"), isTrue,
        reason: 'il campo non si chiama piu\' Password');
    expect(s.contains('Hai perso la Password?'), isTrue,
        reason: 'la via della password persa non parla come tutti');
    expect(s.contains("'Ho perso la parola'"), isFalse,
        reason: 'la vecchia frase e\' tornata');
    expect(s.contains("Key('custodia_occhiolino')"), isTrue,
        reason: 'l\'occhiolino per rivelare la password e\' sparito');
    expect(s.contains('AutofillGroup('), isTrue,
        reason: 'senza il gruppo di autofill il gestore password del '
            'dispositivo non offre di salvare');
    expect(s.contains('AutofillHints.newPassword'), isTrue);
    expect(s.contains('TextInput.finishAutofillContext()'), isTrue,
        reason: 'senza il segnale di chiusura il gestore non salva');
    expect(s.contains('helperText: regolaDellaPassword'), isTrue,
        reason: 'la regola non sta piu\' scritta sotto il campo');
    // I bottoni del foglio coi colori di casa, mai il blu del tema.
    expect(s.contains('foregroundColor: palette.goldSoft'), isTrue,
        reason: 'l\'azione che conferma e\' tornata del colore del tema');
  });

  test('la porta di chi torna sonda, e chi non risulta prosegue il rito', () {
    final s = leggi('lib/features/account/custodia_del_cielo.dart');
    expect(s.contains('if (widget.perChiTorna)'), isTrue,
        reason: 'la porta di chi torna non si distingue piu\' dal foglio '
            'della registrazione');
    for (final chiave in const [
      "Key('sonda_email_campo')",
      "Key('sonda_controlla')",
      "Key('sonda_non_registrata')",
      "Key('sonda_prosegui')",
      "Key('sonda_registrata')",
      "Key('sonda_server_muto')",
    ]) {
      expect(s.contains(chiave), isTrue,
          reason: 'la sonda ha perso il pezzo $chiave');
    }
    expect(s.contains('Prosegui il rito'), isTrue,
        reason: 'chi non risulta non riceve piu\' la strada obbligata '
            'dell\'onboarding');
    // E il server ha la callable con il suo tetto anti enumerazione.
    final server = leggi('functions/src/cerchio.ts');
    expect(server.contains('export const esisteIlCerchio'), isTrue);
    expect(server.contains('SONDE_AL_GIORNO'), isTrue,
        reason: 'la sonda ha perso il tetto: enumerazione libera');
  });

  test('il ricordo si dice giusto', () {
    final s = leggi('lib/features/onboarding/scena_del_ritrovamento.dart');
    expect(s.contains("'Il Cerchio si ricorda di te.'"), isTrue,
        reason: 'la frase del fondatore e\' sparita dal ritrovamento');
    expect(s.contains("'Il Cerchio ti aveva tenuto tutto.'"), isFalse,
        reason: 'la frase del possesso e\' tornata');
  });

  test('il secondo fattore esiste, col codice che verifica davvero', () {
    final server = leggi('functions/src/secondo_fattore.ts');
    expect(server.contains('emailVerified: true'), isTrue,
        reason: 'il codice giusto non rende piu\' verificata l\'email: il '
            'benvenuto resterebbe appeso');
    expect(server.contains('mittente_non_configurato'), isTrue,
        reason: 'senza mittente il server deve dichiararlo, non tacere');
    expect(server.contains('TENTATIVI_PER_CODICE'), isTrue);
    expect(server.contains('improntaDelCodice'), isTrue,
        reason: 'il codice viaggia o si conserva in chiaro');
    final indice = leggi('functions/src/index.ts');
    expect(indice.contains('export {secondoFattore}'), isTrue);
    final client = leggi('lib/features/account/festa_della_registrazione.dart');
    expect(client.contains("Key('foglio_del_codice')"), isTrue,
        reason: 'il foglio del codice e\' sparito dal client');
    expect(client.contains("operazione: 'manda'"), isTrue);
    expect(client.contains('AutofillHints.oneTimeCode'), isTrue,
        reason: 'il codice non si autocompila dal sistema');
  });
}
