import 'dart:typed_data';

import 'package:esoteric_circle/features/maestri/live/le_frasi_della_persona.dart';
import 'package:flutter_test/flutter_test.dart';

/// **LE FRASI DELLA PERSONA SI UNISCONO QUANDO RIPRENDE A PARLARE.** Ordine
/// EJ voce 01, 24 settembre 2026.
///
/// Sul Realme la domanda arrivava senza l'inizio e senza la fine: il
/// microfono si chiudeva per trascrivere ogni frase, e chi riprendeva a
/// parlare dopo una pausa non era ascoltato. Qui si prova la regola che
/// decide quando una frase diventa domanda, su quattro situazioni vere.
void main() {
  Uint8List pezzo(int quale, int byte) =>
      Uint8List.fromList(List.filled(byte, quale));

  test('UNA PAUSA LUNGA NON SPEZZA LA DOMANDA: i pezzi si uniscono', () {
    final f = LeFrasiDellaPersona();
    final primo = f.chiusa(pezzo(1, 100));
    // Mentre il primo pezzo si trascrive, la persona riprende a parlare.
    expect(
        f.trascritta(primo.biglietto, 'Da qualche mese penso di cambiare',
            parlaDiNuovo: true),
        isNull,
        reason: 'la persona stava ancora parlando e la domanda e\' partita '
            'a meta\'');
    final secondo = f.chiusa(pezzo(2, 60));
    expect(secondo.pcm.length, 160,
        reason: 'il secondo pezzo non porta con se\' il primo: la domanda '
            'arriverebbe senza il suo inizio');
    expect(
        f.trascritta(secondo.biglietto,
            'Da qualche mese penso di cambiare lavoro. Cosa mi consigli?',
            parlaDiNuovo: false),
        'Da qualche mese penso di cambiare lavoro. Cosa mi consigli?');
  });

  test('IL RUMORE SI BUTTA, E NON RESTA ATTACCATO ALLA DOMANDA DOPO', () {
    final f = LeFrasiDellaPersona();
    final rumore = f.chiusa(pezzo(9, 50));
    expect(f.trascritta(rumore.biglietto, '', parlaDiNuovo: false), isNull,
        reason: 'un rumore trascritto vuoto e\' partito come domanda');
    expect(f.pezziInAttesa, 0);
    final voce = f.chiusa(pezzo(1, 80));
    expect(voce.pcm.length, 80,
        reason: 'il rumore di prima e\' rimasto attaccato alla domanda');
    expect(f.trascritta(voce.biglietto, 'Ciao Medora', parlaDiNuovo: false),
        'Ciao Medora');
  });

  test('UNA TRASCRIZIONE SUPERATA DA UN PEZZO NUOVO NON CONTA', () {
    final f = LeFrasiDellaPersona();
    final primo = f.chiusa(pezzo(1, 10));
    final secondo = f.chiusa(pezzo(2, 10));
    expect(f.trascritta(primo.biglietto, 'mezza domanda', parlaDiNuovo: false),
        isNull,
        reason: 'la trascrizione del primo pezzo e\' partita anche se il '
            'secondo, che la contiene, era gia\' in viaggio');
    expect(
        f.trascritta(secondo.biglietto, 'domanda intera', parlaDiNuovo: false),
        'domanda intera');
  });

  test('DOPO LA RISPOSTA SI RICOMINCIA DA CAPO', () {
    final f = LeFrasiDellaPersona();
    final vecchio = f.chiusa(pezzo(1, 10));
    f.dimentica();
    expect(
        f.trascritta(vecchio.biglietto, 'vecchia', parlaDiNuovo: false), isNull,
        reason: 'una frase di prima della risposta e\' arrivata dopo');
    expect(f.chiusa(pezzo(2, 10)).pcm.length, 10);
  });
}
