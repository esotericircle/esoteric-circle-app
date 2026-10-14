import 'package:esoteric_circle/features/tarot/la_scena_della_stesa_in_video.dart';
import 'package:flutter_test/flutter_test.dart';

/// **DOVE SI FERMA LA SCENA, E CON QUALE RALLENTAMENTO.** Ordine del 14
/// ottobre 2026, dal telefono del fondatore: *"Medora deve fermarsi poco
/// prima della fine del video, quando ha la mano sul petto e non quando la
/// allontana. Cerca di rallentare l'ultimo secondo in modo che non si fermi
/// di botto"*.
///
/// Prova pura su [ScenaDellaStesaInVideo.velocitaA] e
/// [ScenaDellaStesaInVideo.fermo]: nessun lettore, nessun filmato vero
/// (`video_player` non decodifica niente in una prova headless), solo la
/// formula che decide la velocita' a ogni posizione.
void main() {
  test('fermaA sta prima della fine, non alla fine', () {
    expect(
        ScenaDellaStesaInVideo.fermaA, lessThan(ScenaDellaStesaInVideo.durata),
        reason: 'la scena deve fermarsi "poco prima della fine", non alla '
            'fine vera del filmato');
    // Non troppo prima: resta dentro l'ultimo secondo e mezzo del filmato,
    // altrimenti non e' piu' "poco prima".
    expect(ScenaDellaStesaInVideo.durata - ScenaDellaStesaInVideo.fermaA,
        lessThan(const Duration(milliseconds: 1500)));
  });

  test('la velocita resta 1,0 finche manca piu di un rallentamento', () {
    final lontano = ScenaDellaStesaInVideo.fermaA -
        ScenaDellaStesaInVideo.rallentamento -
        const Duration(milliseconds: 1);
    expect(ScenaDellaStesaInVideo.velocitaA(Duration.zero), 1.0);
    expect(ScenaDellaStesaInVideo.velocitaA(lontano), 1.0,
        reason: 'a un millisecondo fuori dal rallentamento la velocita non '
            'e piu intera');
  });

  test('la velocita scende con continuita verso il minimo, mai a zero', () {
    const rallentamento = ScenaDellaStesaInVideo.rallentamento;
    const fermaA = ScenaDellaStesaInVideo.fermaA;
    // ms e' quanto MANCA a fermaA: a ms=0 si e' proprio sul fermo, a
    // ms=rallentamento si e' all'inizio della rampa. Salendo con ms ci si
    // allontana dal fermo, e la velocita' deve salire con lui, mai scendere.
    double prima = ScenaDellaStesaInVideo.velocitaMinima;
    for (var ms = 0; ms <= rallentamento.inMilliseconds; ms += 50) {
      final posizione = fermaA - Duration(milliseconds: ms);
      final v = ScenaDellaStesaInVideo.velocitaA(posizione);
      expect(v, greaterThanOrEqualTo(ScenaDellaStesaInVideo.velocitaMinima),
          reason: 'a $ms ms dal fermo la velocita $v e sotto il minimo');
      expect(v, greaterThanOrEqualTo(prima - 1e-9),
          reason: 'la velocita scende allontanandosi dal fermo, a $ms ms: '
              '$v dopo $prima');
      expect(v, greaterThan(0.0),
          reason: 'la velocita tocca zero a $ms ms dal fermo: il lettore '
              'video non riparte da fermo con setPlaybackSpeed(0)');
      prima = v;
    }
    // Proprio alla fine, la velocita e il minimo: il passo successivo (sulla
    // posizione, non sulla velocita) e la pausa vera, decisa da [fermo].
    expect(ScenaDellaStesaInVideo.velocitaA(fermaA),
        ScenaDellaStesaInVideo.velocitaMinima);
    // A META' della rampa la velocita' deve essere scesa per davvero, non
    // restare ferma a 1,0: senza questo controllo una formula che ritorna
    // sempre 1,0 (tranne il fermo vero e proprio) passa il loop qui sopra,
    // perche' una costante non scende mai sotto se stessa.
    final meta = fermaA - Duration(milliseconds: rallentamento.inMilliseconds ~/ 2);
    expect(ScenaDellaStesaInVideo.velocitaA(meta), lessThan(0.9),
        reason: 'a meta rampa la velocita deve essere scesa visibilmente, '
            'non essere rimasta vicina a 1,0');
  });

  test('fermo diventa vero esattamente a fermaA, mai prima', () {
    expect(
        ScenaDellaStesaInVideo.fermo(
            ScenaDellaStesaInVideo.fermaA - const Duration(milliseconds: 1)),
        isFalse);
    expect(ScenaDellaStesaInVideo.fermo(ScenaDellaStesaInVideo.fermaA), isTrue);
    expect(
        ScenaDellaStesaInVideo.fermo(
            ScenaDellaStesaInVideo.fermaA + const Duration(milliseconds: 1)),
        isTrue,
        reason: 'un fotogramma renderizzato un po oltre fermaA (il lettore '
            'non salta mai con seekTo) deve restare fermo lo stesso');
  });
}
