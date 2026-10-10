import 'package:esoteric_circle/core/chat/la_marca_del_genere.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

/// **IL RISOLUTORE DELLA MARCA DEL GENERE.** Ordine DL voce 02.
///
/// La sintassi e' dell'ordine: tre campi fra quadre, maschile, femminile e
/// neutro, e una quadra letterale si raddoppia. Queste prove la fissano su
/// esempi, compresi quelli che un risolutore scritto in fretta sbaglia: la
/// quadra raddoppiata dentro un campo, due marche attaccate, la marca rotta.
void main() {
  setUp(() {
    LaMarcaDelGenere.severa = true;
    LaMarcaDelGenere.lingua = const LinguaItaliana();
  });
  tearDown(() => LaMarcaDelGenere.severa = false);

  const frase = '[Sei arrivato|Sei arrivata|Sei qui] fin qui, e [solo|sola|in '
      'pace] con te.';

  test('ogni forma prende il suo campo, e la sconosciuta prende il neutro', () {
    expect(LaMarcaDelGenere.risolvi(frase, forma: CourtesyForm.masculine),
        'Sei arrivato fin qui, e solo con te.');
    expect(LaMarcaDelGenere.risolvi(frase, forma: CourtesyForm.feminine),
        'Sei arrivata fin qui, e sola con te.');
    expect(LaMarcaDelGenere.risolvi(frase, forma: CourtesyForm.neutral),
        'Sei qui fin qui, e in pace con te.');
    expect(LaMarcaDelGenere.risolvi(frase, forma: CourtesyForm.unknown),
        'Sei qui fin qui, e in pace con te.');
  });

  test('senza forma dichiarata vale quella della persona', () {
    final prima = LaMarcaDelGenere.formaCorrente;
    addTearDown(() => LaMarcaDelGenere.formaCorrente = prima);
    LaMarcaDelGenere.formaCorrente = CourtesyForm.feminine;
    expect(LaMarcaDelGenere.risolvi('[o|a|]'), 'a');
    expect(CourtesyForm.masculine.risolvi('[o|a|]'), 'o');
  });

  test('il campo vuoto e la desinenza sola', () {
    expect(LaMarcaDelGenere.risolvi('car[o|a|]',
        forma: CourtesyForm.feminine), 'cara');
    expect(LaMarcaDelGenere.risolvi('car[o|a|]', forma: CourtesyForm.neutral),
        'car');
  });

  test('la quadra raddoppiata e\' una quadra, anche dentro un campo', () {
    expect(
        LaMarcaDelGenere.risolvi('la nota [[1]] dice [[o]]',
            forma: CourtesyForm.masculine),
        'la nota [1] dice [o]');
    expect(
        LaMarcaDelGenere.risolvi('[vedi [[a]]|vedi [[b]]|vedi]',
            forma: CourtesyForm.feminine),
        'vedi [b]');
  });

  test('due marche attaccate e un testo senza marche', () {
    expect(LaMarcaDelGenere.risolvi('[a|b|c][d|e|f]',
        forma: CourtesyForm.feminine), 'be');
    const piano = 'Nessuna marca, nessuna quadra.';
    expect(identical(LaMarcaDelGenere.risolvi(piano), piano), isTrue,
        reason: 'un testo senza quadre non si ricostruisce');
  });

  test('la marca rotta si ferma nelle prove e passa intatta in produzione', () {
    for (final rotta in const ['[a|b]', '[a|b|c|d]', '[a|b|c', 'x [a[b|c|d] y']) {
      expect(() => LaMarcaDelGenere.risolvi(rotta), throwsA(isA<MarcaMalformata>()),
          reason: '"$rotta" e\' una marca rotta');
    }
    LaMarcaDelGenere.severa = false;
    expect(LaMarcaDelGenere.risolvi('[a|b]'), '[a|b]');
  });

  test('una lingua senza genere tiene il campo neutro e la marca sparisce', () {
    LaMarcaDelGenere.lingua = const LinguaSenzaGenere();
    expect(LaMarcaDelGenere.risolvi('[He is here|She is here|You are here]',
        forma: CourtesyForm.feminine), 'You are here');
  });

  test('agree e il risolutore decidono nello stesso posto', () {
    for (final f in CourtesyForm.values) {
      expect(f.agree(masculine: 'm', feminine: 'f', neutral: 'n'),
          LaMarcaDelGenere.risolvi('[m|f|n]', forma: f));
    }
  });
}
