import 'package:esoteric_circle/core/identity/identity_controller.dart';
import 'package:flutter_test/flutter_test.dart';

/// Il nome si normalizza ALLA FONTE, una volta sola.
///
/// Chi scriveva "mauro" in minuscolo se lo ritrovava minuscolo in ogni bolla,
/// in ogni saluto e in ogni responso, per sempre. Correggerlo nel punto in cui
/// si mostra vorrebbe dire correggerlo in venti punti e dimenticarne uno:
/// si corregge dove entra.
void main() {
  test('Il minuscolo diventa maiuscolo appena entra', () {
    final c = IdentityController();
    c.setName('mauro');
    expect(c.name, 'Mauro');
  });

  test('Il maiuscolo urlato si ammorbidisce', () {
    final c = IdentityController();
    c.setName('MAURO');
    expect(c.name, 'Mauro');
  });

  test('I nomi composti mantengono ogni iniziale', () {
    final c = IdentityController();
    c.setName('maria  grazia');
    expect(c.name, 'Maria Grazia');

    c.setName('jean-luc');
    expect(c.name, 'Jean-Luc');

    c.setName("d'angelo");
    expect(c.name, "D'Angelo");
  });

  test('Gli spazi di troppo spariscono', () {
    final c = IdentityController();
    c.setName('   anna   ');
    expect(c.name, 'Anna');
  });

  test('Un nome gia\' scritto bene non viene toccato', () {
    final c = IdentityController();
    c.setName('Mauro');
    expect(c.name, 'Mauro');
    // Le maiuscole interne volute restano: McDonald non diventa Mcdonald.
    c.setName('McDonald');
    expect(c.name, 'McDonald');
  });

  test('Il saluto usa il nome gia\' normalizzato', () {
    final c = IdentityController();
    c.setName('mauro');
    expect(c.welcome(), contains('Mauro'));
    expect(c.welcome(), isNot(contains('mauro,')));
  });

  test('Il vuoto resta vuoto, senza inventare niente', () {
    final c = IdentityController();
    c.setName('   ');
    expect(c.name, '');
    expect(c.hasName, isFalse);
  });
}
