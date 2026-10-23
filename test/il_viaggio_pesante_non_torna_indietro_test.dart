// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

import 'package:esoteric_circle/core/viaggio/il_viaggio_custodito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cardinale_minimo.dart';

/// **IL VIAGGIO PESANTE NON TORNA INDIETRO.** Ordine FZ, trovato dalla
/// simulazione da persona del 20 ottobre 2026 sul Realme 767f596c.
///
/// **Il fatto**: le discese del secondo e del terzo giorno simulati
/// sparivano dal Diario. Provato a video: una discesa fatta senza rete resta
/// sul telefono (`viaggio.quante` 2); riaccesa la rete e riportata l'app in
/// primo piano, trenta secondi dopo il Diario e' tornato alla prima discesa
/// (`viaggio.quante` 1), solchi e celle compresi.
///
/// **La causa, misurata**: il sacchetto del Viaggio pesava 22.218 caratteri,
/// 19.317 di solchi del dito. `leggiCammino` in `functions/src/cammino.ts`
/// scarta in silenzio un Viaggio sopra `PESO_MASSIMO_DEL_DIARIO_DELL_ALBA`
/// (20.000); la fusione vedeva solo la copia custodita e il telefono la
/// adottava sopra la sua. Padre: ordine EE voce 13 (il tetto dell'Alba dato
/// al Viaggio, che col Diario di novanta discese lo passa da solo); aggravato
/// da FZ.04 (i solchi di ogni animale).
///
/// **Cosa misura**: un Viaggio pesante come quello di chi scende da mesi
/// parte sempre sotto il tetto **letto dal server**, con interi il conto, il
/// riconoscimento, il nome, il cammino e le celle; e quando il Cerchio
/// rimanda lo stesso sacchetto il telefono non perde niente, mentre un
/// Viaggio davvero piu' avanti si adotta ancora.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Il tetto vero, dal server: se qualcuno lo cambia li', la prova lo sa.
  int tettoDelServer() {
    final ts = File('functions/src/cammino.ts').readAsStringSync();
    final m =
        RegExp(r'PESO_MASSIMO_DEL_DIARIO_DELL_ALBA\s*=\s*(\d+)').firstMatch(ts);
    expect(m, isNotNull,
        reason: 'il tetto del server non si trova piu in cammino.ts');
    return int.parse(m!.group(1)!);
  }

  /// **UN VIAGGIO DI CHI SCENDE DA MESI**: novanta discese nel Diario,
  /// quaranta segni, sessanta nutrimenti, e i solchi di quattro animali
  /// grattati per intero, con la stessa forma che scrive il telefono.
  Map<String, Object> viaggioPesante() {
    String solchi(int quanti) => [
          for (var s = 0; s < 6; s++)
            [
              for (var i = 0; i < quanti; i++)
                '${(i / quanti).toStringAsFixed(3)},'
                    '${(0.75 + s * 0.04).toStringAsFixed(3)}',
            ].join(';'),
        ].join('|');
    final animali = ['Lince', 'Cavallo', 'Aquila', 'Cervo'];
    return {
      'viaggio.diario': [
        for (var i = 0; i < 90; i++)
          jsonEncode({
            'quando': DateTime(2026, 7, 1).add(Duration(days: i)).toString(),
            'domanda': 'Non so dove sto andando e vorrei una direzione.',
            'tema': 'direzione',
            'pezzi': ['fiume', 'maschera', 'guarda_in_alto', 'pioggia'],
            'animale': animali[i % 4],
            'nitidezza': 1.0,
            'titolo': 'Segui chi vorresti essere',
            'risposta': 'Da un po\' ti porti dietro la direzione. Le '
                'direzioni buone all\'inizio sembrano tutte piccole.',
            'gesto': 'Datti tre giorni. Poi scrivi in una riga che cosa e\' '
                'cambiato.',
            'fonti': {'scena': 'riserva', 'titolo': 'riserva'},
            'strato': i % 4 + 1,
          }),
      ],
      'viaggio.segni': [
        for (var i = 0; i < 40; i++)
          jsonEncode({'quando': '2026-08-${i % 28 + 1}', 'gesto': 'guarda'}),
      ],
      'viaggio.nutrimenti': [
        for (var i = 0; i < 60; i++) '2026-09-${i % 28 + 1}T10:00:00.000',
      ],
      'viaggio.velo': jsonEncode({
        for (final a in animali) a: [for (var c = 0; c < 768; c++) c].join(','),
      }),
      'viaggio.velo.solchi': jsonEncode({
        for (final a in animali) a: solchi(120),
      }),
      'viaggio.quante': 90,
      'viaggio.cammino': '',
      'viaggio.riconosciuto': true,
      'viaggio.animale_riconosciuto': 'Cavallo',
      'viaggio.fz02_migrato': true,
    };
  }

  test(
      'IL SACCHETTO PARTE SEMPRE SOTTO IL TETTO DEL SERVER, con interi '
      'cio\' che decide la fusione', () async {
    final tetto = tettoDelServer();
    final pieno = viaggioPesante();
    // **IL CARDINALE**: il Viaggio di prova deve davvero pesare piu' del
    // tetto, o la prova sarebbe verde senza aver guardato niente.
    final pesoPieno = jsonEncode(pieno).length;
    cardinaleMinimo(pesoPieno, tetto + 1,
        cosa: 'caratteri del Viaggio pesante di prova',
        perche: 'un Viaggio leggero passerebbe anche senza la cura');
    SharedPreferences.setMockInitialValues(pieno);
    final sacchetto = await IlViaggioCustodito.daCustodire();
    expect(sacchetto, isNotNull);
    final peso = jsonEncode(sacchetto).length;
    print('ORDINE FZ: il Viaggio pesa $pesoPieno caratteri sul telefono, '
        'ne partono $peso, tetto del server $tetto');
    expect(peso, lessThanOrEqualTo(tetto),
        reason: 'il sacchetto del Viaggio pesa $peso caratteri, sopra i '
            '$tetto che il server accetta: il server lo scarta, rimanda la '
            'copia vecchia e il telefono perde le discese nuove');
    for (final chiave in const [
      'viaggio.quante',
      'viaggio.riconosciuto',
      'viaggio.animale_riconosciuto',
      'viaggio.cammino',
      'viaggio.velo',
      'viaggio.fz02_migrato',
    ]) {
      expect(sacchetto![chiave], pieno[chiave],
          reason: '$chiave non parte intero: la fusione o il telefono nuovo '
              'vedrebbero un Viaggio diverso da quello vero');
    }
    // **E LE DISCESE PIU' RECENTI PARTONO**: si toglie dal fondo, non dalla
    // cima.
    final diario = sacchetto!['viaggio.diario'] as List;
    expect(diario, isNotEmpty);
    expect(diario.first, (pieno['viaggio.diario'] as List).first,
        reason: 'la discesa piu recente non e partita');
  });

  test(
      'QUANDO IL CERCHIO RIMANDA LO STESSO SACCHETTO, il telefono non perde '
      'ne\' i solchi ne\' le discese che non sono partite', () async {
    final pieno = viaggioPesante();
    SharedPreferences.setMockInitialValues(pieno);
    final sacchetto = await IlViaggioCustodito.daCustodire();
    // Il Cerchio ha dato ragione al telefono e rimanda il suo sacchetto.
    await IlViaggioCustodito.adottaDalCerchio(
        Map<String, Object?>.from(sacchetto!));
    final prefs = await SharedPreferences.getInstance();
    final diario = prefs.getStringList('viaggio.diario') ?? const [];
    print('ORDINE FZ: dopo il giro il telefono ha ${diario.length} discese '
        'nel Diario e i solchi '
        '${prefs.getString('viaggio.velo.solchi') == null ? "persi" : "interi"}');
    expect(diario.length, 90,
        reason: 'il giro della custodia ha tolto dal telefono le discese '
            'che non erano partite');
    expect(prefs.getString('viaggio.velo.solchi'), pieno['viaggio.velo.solchi'],
        reason: 'il giro della custodia ha tolto i solchi dal telefono');
  });

  test(
      'IL TETTO SCRITTO NEL TELEFONO E\' QUELLO DEL SERVER, e il margine sta '
      'sotto', () {
    final tetto = tettoDelServer();
    expect(IlViaggioCustodito.pesoMassimoDelCerchio, tetto,
        reason: 'il tetto del Viaggio nel telefono non e piu quello del '
            'server: uno dei due e cambiato senza l altro');
    expect(IlViaggioCustodito.pesoDaNonSuperare, lessThan(tetto));
  });

  test(
      'UN VIAGGIO CHE NEMMENO ALLEGGERITO PUO\' PARTIRE non parte, e la copia '
      'che il Cerchio rimanda senza averlo visto non lo sostituisce', () async {
    // **DODICI CARTE GRATTATE PER INTERO**: le celle partono sempre intere,
    // e da sole passano il tetto.
    final pieno = viaggioPesante()
      ..['viaggio.velo'] = jsonEncode({
        for (var a = 0; a < 12; a++)
          'Animale$a': [for (var c = 0; c < 768; c++) c].join(','),
      });
    cardinaleMinimo(
        (pieno['viaggio.velo'] as String).length, tettoDelServer() + 1,
        cosa: 'caratteri delle celle di dodici carte',
        perche: 'senza celle piu pesanti del tetto il caso non esiste');
    SharedPreferences.setMockInitialValues(pieno);
    final sacchetto = await IlViaggioCustodito.daCustodire();
    expect(sacchetto, isNull,
        reason: 'un sacchetto sopra il tetto parte lo stesso: il server lo '
            'scarta e rimanda la copia vecchia');
    // Il Cerchio non ha visto il Viaggio di questo telefono e rimanda la
    // copia che custodiva, ferma alla prima discesa.
    await IlViaggioCustodito.adottaDalCerchio(const {
      'viaggio.quante': 1,
      'viaggio.riconosciuto': false,
    });
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('viaggio.quante'), 90,
        reason: 'la copia del Cerchio, decisa senza vedere il Viaggio del '
            'telefono, ha cancellato le discese di questo telefono');
    expect(prefs.getBool('viaggio.riconosciuto'), isTrue);
  });

  test(
      'E UN VIAGGIO DAVVERO PIU\' AVANTI, da un altro telefono, si adotta '
      'ancora', () async {
    SharedPreferences.setMockInitialValues(viaggioPesante());
    await IlViaggioCustodito.daCustodire();
    await IlViaggioCustodito.adottaDalCerchio(const {
      'viaggio.quante': 95,
      'viaggio.riconosciuto': true,
      'viaggio.animale_riconosciuto': 'Cavallo',
    });
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('viaggio.quante'), 95,
        reason: 'il Viaggio piu avanti di un altro telefono non si adotta '
            'piu: la cura ha chiuso anche la porta buona');
  });
}
