// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/astro/celestial.dart';
import 'package:esoteric_circle/core/astro/effemeridi.dart';
import 'package:esoteric_circle/core/astro/il_cielo_detto.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:flutter_test/flutter_test.dart';

/// **I PIANETI DETTI SONO I PIANETI CALCOLATI.** Ordine ET voce 01, 28
/// settembre 2026.
///
/// Il fondatore, sulle domande da farsi su ogni funzione: *"c'è qualcosa di
/// inventato?"*. Nella sonda del banco delle trenta domande Medora diceva
/// *"il transito di Giove in Toro, ti invita alla pazienza"*, *"Il transito
/// di Venere in Capricorno"*, *"il transito di Mercurio retrogrado"*: il
/// modello riceveva la sola Luna di oggi e i pianeti li inventava, e la rete
/// del cielo detto (ordine DS voce 08) guardava la sola Luna.
///
/// Qui: il cielo di oggi per il modello porta i pianeti calcolati dalle
/// effemeridi dell'app; la rete smentisce un pianeta detto in un segno dove
/// oggi non e', o detto retrogrado quando non lo e'; il cielo di nascita
/// della persona ("il tuo Sole in Scorpione") non si smentisce; e dopo aver
/// tolto una frase nessuna riga comincia con uno spazio.
void main() {
  final adesso = DateTime(2026, 9, 28, 12);
  final jd = Celestial.julianDay(adesso.toUtc());

  String segnoDi(CorpoCeleste c) => Zodiac
      .values[(Effemeridi.longitudineEclittica(c, jd) / 30).floor() % 12]
      .italianName;

  String altroSegno(CorpoCeleste c) => Zodiac.values
      .firstWhere((z) => z.italianName != segnoDi(c))
      .italianName;

  test('il cielo di oggi per il modello porta i pianeti calcolati', () {
    final cielo = IlCieloDetto.oggiPerIlModello(adesso);
    print('ORDINE ET VOCE 1: $cielo');
    for (final c in [
      CorpoCeleste.mercurio,
      CorpoCeleste.venere,
      CorpoCeleste.marte,
      CorpoCeleste.giove,
      CorpoCeleste.saturno,
    ]) {
      expect(cielo, contains('${c.nome} in ${segnoDi(c)}'),
          reason: 'il modello non riceve ${c.nome} di oggi');
    }
  });

  test('le frasi della sonda sui pianeti inventati si smentiscono', () {
    // Le frasi vere della sonda, del 28 settembre 2026: Giove oggi non e' in
    // Toro, Venere non e' in Capricorno.
    final sonda = [
      if (segnoDi(CorpoCeleste.giove) != 'Toro')
        'Il transito di Giove in Toro, ti invita alla pazienza e alla '
            'costruzione.',
      if (segnoDi(CorpoCeleste.venere) != 'Capricorno')
        'Il transito di Venere in Capricorno ti invita a riflettere sui '
            'valori.',
      'Marte in ${altroSegno(CorpoCeleste.marte)} ti spinge a un passo '
          'coraggioso.',
    ];
    final prese = [
      for (final f in sonda)
        if (IlCieloDetto.smentite(f, adesso: adesso).isNotEmpty) f,
    ];
    print('ORDINE ET VOCE 1: frasi sui pianeti inventati smentite '
        '${prese.length} su ${sonda.length}');
    expect(prese, hasLength(sonda.length),
        reason: 'passano ancora: ${sonda.where((f) => !prese.contains(f))}');
  });

  test('un pianeta detto retrogrado quando non lo e\' si smentisce', () {
    for (final c in [
      CorpoCeleste.mercurio,
      CorpoCeleste.venere,
      CorpoCeleste.marte,
    ]) {
      final frase = 'Il transito di ${c.nome} retrogrado ti chiede di '
          'rivedere le parole non dette.';
      final retro = Effemeridi.retrogrado(c, jd);
      expect(IlCieloDetto.smentite(frase, adesso: adesso).isNotEmpty, !retro,
          reason: '${c.nome} ${retro ? 'e\'' : 'non e\''} retrogrado oggi');
    }
  });

  test('il cielo vero e quello di nascita non si smentiscono', () {
    final veri = [
      'Giove in ${segnoDi(CorpoCeleste.giove)} ti invita alla pazienza.',
      'Oggi Venere in ${segnoDi(CorpoCeleste.venere)} addolcisce le parole.',
    ];
    for (final f in veri) {
      expect(IlCieloDetto.smentite(f, adesso: adesso), isEmpty, reason: f);
    }
    // Il Sole della persona, dal suo cielo di nascita: e' vero, anche se oggi
    // il Sole sta altrove.
    const diNascita = {'Sole': 'Scorpione', 'Luna': 'Pesci'};
    for (final f in [
      'Il tuo Sole in Scorpione ti rende profonda.',
      'Il Sole in Scorpione e la Luna in Pesci indicano una profondità di '
          'sentimenti.',
    ]) {
      expect(
          IlCieloDetto.smentite(f, adesso: adesso, diNascita: diNascita),
          isEmpty,
          reason: f);
    }
  });

  test('tolta una frase, nessuna riga comincia con uno spazio', () {
    final falsa = 'Il transito di Giove in '
        '${altroSegno(CorpoCeleste.giove)} ti invita alla pazienza.';
    final testo = 'Apriti a queste possibilità.\n\n$falsa Il tuo compito è '
        'di aprirti.\n\n✦ Prepara uno spazio nella tua casa.';
    final pulito = IlCieloDetto.senzaLeSmentite(testo, adesso: adesso);
    expect(pulito, isNot(contains(falsa)));
    expect(RegExp(r'^[ \t]', multiLine: true).hasMatch(pulito), isFalse,
        reason: 'una riga comincia con uno spazio: «$pulito»');
  });
}
