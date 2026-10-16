import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/tarot/la_lettura_dal_modello.dart';
import 'package:flutter_test/flutter_test.dart';

/// **I DUE PARAGRAFI DELLA LUNGA PASSANO DALLA CURA. Ordine FS, 13 ottobre
/// 2026.**
///
/// Misurato col modello vero sulla Croce Celtica alla profondita' Lunga
/// (`docs/collaudo/FS/la_croce_celtica_lunga.txt`): quando l'ultima lettura
/// cadeva per una frase col genere sbagliato, la cura toglieva quella frase
/// e ricostruiva la lettura senza i due paragrafi, e a video arrivavano i
/// soli tre paragrafi: il fondatore, "la profondita' Lunga non funziona".
void main() {
  test('la lettura curata conserva i due paragrafi della Lunga', () {
    final l = LetturaDelModello(
      risposta: 'Le carte mostrano un passo da fare adesso.',
      carte: [
        'Il Matto apre una strada. Sei pronto a partire.',
        'Il Mago ti mostra gli strumenti che hai.',
        'La Stella indica una speranza concreta.',
      ],
      chiavi: LetturaDelModello.chiaviATre,
      legame: 'Le tre carte vanno dal passo alla speranza.',
      consiglio: 'Scrivi oggi la prima cosa da fare.',
      titolo: 'Un passo concreto adesso',
      approfondimento1: 'Parla stasera con chi lavora con te.',
      approfondimento2: 'Aspettati una resistenza, e rispondi con calma.',
    );
    final curata =
        LaLetturaDellaStesa.senzaLeFrasiColGenere(l, CourtesyForm.neutral);
    expect(curata, isNotNull,
        reason: 'la frase col genere ("Sei pronto") doveva essere tolta e '
            'il resto mostrato');
    expect(curata!.carte.first, isNot(contains('pronto')),
        reason: 'la cura non ha tolto la frase col genere');
    expect(curata.approfondimento1, 'Parla stasera con chi lavora con te.',
        reason: 'la cura ha perso il primo paragrafo della Lunga');
    expect(curata.approfondimento2,
        'Aspettati una resistenza, e rispondi con calma.',
        reason: 'la cura ha perso il secondo paragrafo della Lunga');
  });
}
