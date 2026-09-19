import 'package:esoteric_circle/core/sensi/motore_audio.dart';
import 'package:flutter_test/flutter_test.dart';

/// **LA SENTINELLA DORME IN SECONDO PIANO.** Ordine CY, voce 02,
/// 8 settembre 2026.
///
/// **Parole del fondatore, sulla build 2232**: *"la musica NON SI FERMA SE
/// METTO L'APP IN BACKGROUND"*.
///
/// **LA VOCE CW.01 AVEVA RIPARATO META' DEL DIFETTO.** L'ordine delle attese
/// era sbagliato davvero, e sul telefono ho misurato la pausa arrivare alla
/// piattaforma un secondo dopo il tasto Home: `player state:paused`. Quella
/// misura era vera, **e non bastava a dire che la musica taceva**.
///
/// **La seconda meta' e' una sentinella che disfa la cura due secondi dopo.**
/// `RegiaDellaMusica` tiene un `Timer.periodic` da due secondi che esiste per
/// una ragione buona: nella 2219 il tappeto risultava chiesto e non suonava, e
/// la regia credeva alla propria memoria invece di guardare il lettore. Quel
/// guardiano pero' **non sa niente del secondo piano**: vede la musica ferma,
/// conclude che si e' persa, e la fa ripartire mentre l'app e' fuori.
///
/// **PERCHE' NON L'HO VISTO SUL DISPOSITIVO DI COLLAUDO.** Su quel telefono il
/// tappeto non e' mai entrato in `state:started`, e l'ho dichiarato nel referto
/// dell'ordine CW. Con la musica che non parte, `_corrente` resta nullo e la
/// sentinella non ha niente da far ripartire: **il caso che rompe non si
/// presentava**. La misura che avevo era giusta e parziale, e la parte che
/// mancava era proprio quella che il fondatore sente.
///
/// **Cosa misura questa prova.** Che il motore sappia dire, a chiunque glielo
/// chieda, se siamo in secondo piano. E' la porta unica su cui la sentinella si
/// ferma: senza un fatto dichiarato, chi vuole sapere se l'app e' fuori se lo
/// deve indovinare, e chi indovina prima o poi sbaglia.
void main() {
  setUp(() {
    // Nessun lettore vero: qui si misura il governo, non il suono.
    MotoreAudio.lettoriForzati = false;
    MotoreAudio.sondaMusicaInCorso = null;
  });

  tearDown(() {
    MotoreAudio.lettoriForzati = null;
    MotoreAudio.sondaMusicaInCorso = null;
  });

  test('Di partenza il motore non e\' in secondo piano', () {
    expect(MotoreAudio.condiviso.inSecondoPiano, isFalse,
        reason: 'il motore nasce credendo di essere fuori: allora la '
            'sentinella non ripartirebbe mai, e il difetto sarebbe il '
            'contrario di quello che si sta curando');
  });

  test('Fermare tutto dichiara il secondo piano, riprendere lo toglie',
      () async {
    final motore = MotoreAudio.condiviso;
    await motore.fermaTutto();
    expect(motore.inSecondoPiano, isTrue,
        reason: 'dopo `fermaTutto` il motore non dichiara il secondo piano: '
            'la sentinella non ha modo di sapere che deve dormire, e due '
            'secondi dopo rimette la musica che l\'app aveva appena spento');
    await motore.riprendi();
    expect(motore.inSecondoPiano, isFalse,
        reason: 'dopo `riprendi` il motore resta convinto di essere fuori: '
            'la sentinella dormirebbe per sempre, e il guardiano che esiste '
            'per far ripartire un tappeto perso non ripartirebbe mai piu\'');
  });

  test('Il secondo piano non dipende dal fatto che la musica suonasse',
      () async {
    // **E' LA DIFFERENZA FRA I DUE FATTI, e vale la prova.** `riprendi` non
    // riaccende niente se la musica non stava suonando, ed e' giusto cosi'.
    // Ma il secondo piano e' un altro fatto: vale anche per chi era in una
    // schermata muta, perche' la sentinella non deve svegliarsi comunque.
    final motore = MotoreAudio.condiviso;
    MotoreAudio.sondaMusicaInCorso = () => false;
    await motore.fermaTutto();
    expect(motore.musicaDaRiprendere, isFalse,
        reason: 'la musica non suonava e il motore vuole riprenderla');
    expect(motore.inSecondoPiano, isTrue,
        reason: 'con la musica gia\' ferma il motore non dichiara il secondo '
            'piano: la sentinella si sveglierebbe e farebbe partire il '
            'tappeto MENTRE L\'APP E\' FUORI, che e\' il caso peggiore di '
            'tutti perche\' la musica nasce dal nulla');
    await motore.riprendi();
    expect(motore.inSecondoPiano, isFalse);
  });
}
