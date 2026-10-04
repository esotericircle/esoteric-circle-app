// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/cerchio/il_cerchio_sociale.dart';
import 'package:esoteric_circle/core/cerchio/le_icone_del_cerchio.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/services/server/porta_del_cerchio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cardinale_minimo.dart';
import 'porta_finta_del_cerchio_sociale.dart';

/// **GLI ARCANI ESCONO DALLE ICONE DEL PROFILO, ordine FA voce 01.**
///
/// Il fondatore: "Io eviterei gli arcani e qualunque carta come profilo
/// utente, starebbero irriconoscibili". Tre famiglie, trentasei icone; chi
/// aveva un Arcano riceve l'emblema del SUO segno, non l'Ariete per
/// chiunque; l'Arcano personale resta nel Passaporto.
void main() {
  test('FA.01: tre famiglie, trentasei icone, nessun Arcano', () {
    final famiglie = [for (final f in FamigliaDelleIcone.values) f.name];
    final icone = [
      for (final f in FamigliaDelleIcone.values) ...IconaDelProfilo.di(f),
    ];
    print('FA.01 LE ICONE: famiglie $famiglie, icone ${icone.length}');
    expect(famiglie, ['segno', 'animale', 'archetipo']);
    expect(icone, hasLength(36));
    expect(IconaDelProfilo.eValida('arcano:1'), isFalse);
  });

  test('FA.01: un codice che non vale piu\' ricade sul segno della persona',
      () {
    expect(
        IconaDelProfilo.valida('arcano:1', segno: Zodiac.pisces), 'segno:11');
    expect(IconaDelProfilo.valida('arcano:1'), 'segno:0',
        reason: 'senza segno, e solo allora, il primo della lista');
    expect(
        IconaDelProfilo.valida('animale:6', segno: Zodiac.pisces), 'animale:6');
    final amico = PersonaDelCerchio.da(const {
      'uid': 'u',
      'nome': 'Luce',
      'icona': 'arcano:3',
      'segno': 'leo'
    });
    expect(amico.icona, 'segno:4');
  });

  test('FA.01: il mio profilo con un Arcano diventa il mio segno', () async {
    SharedPreferences.setMockInitialValues({});
    final sociale = IlCerchioSociale(porta: _ConUnArcano());
    await sociale.sincronizza(
        identita: BirthIdentity(birthMoment: DateTime(1990, 3, 5, 10)));
    print('FA.01 IL PROFILO DI CHI AVEVA UN ARCANO, dei Pesci: '
        '${sociale.profilo?.icona}');
    expect(sociale.profilo?.icona, 'segno:11');
  });

  test('FA.01: i dati di prova col codice di un Arcano, contati', () {
    // Il rapporto dice quante persone dei dati di prova avevano un codice
    // non piu' valido: qui si contano, nei file delle prove.
    final codici = <String, int>{};
    var guardati = 0;
    for (final f in Directory('test').listSync().whereType<File>()) {
      if (!f.path.endsWith('.dart')) continue;
      guardati++;
      final n = RegExp(r"'icona': 'arcano:\d+'")
          .allMatches(f.readAsStringSync())
          .length;
      if (n > 0) codici[f.uri.pathSegments.last] = n;
    }
    cardinaleMinimo(guardati, 500,
        cosa: 'file delle prove',
        perche: 'Il 4 ottobre 2026 la cartella test porta piu\' di mille file: '
            'su una cartella vuota nessuna persona avrebbe un Arcano.');
    print('FA.01 I DATI DI PROVA CON UN ARCANO, in $guardati file: $codici');
  });
}

class _ConUnArcano extends PortaFintaDelCerchioSociale {
  @override
  Future<EsitoSociale?> sociale(String porta,
      [Map<String, Object?> corpo = const {}]) async {
    final e = await super.sociale(porta, corpo);
    if (e == null || porta != 'ilMioProfiloNelCerchio') return e;
    return EsitoSociale(dati: {...e.dati, 'icona': 'arcano:1'});
  }
}
