// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/cerchio/i_segni_del_cerchio.dart';
import 'package:esoteric_circle/core/cerchio/il_cerchio_sociale.dart';
import 'package:esoteric_circle/core/cerchio/l_arte_di_adesso.dart';
import 'package:esoteric_circle/core/cerchio/le_icone_del_cerchio.dart';
import 'package:esoteric_circle/core/entitlement/listino_degli_eos.dart';
import 'package:esoteric_circle/core/entitlement/plan_catalog.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **I NUMERI DEL CERCHIO SOCIALE DETTI DUE VOLTE DICONO LO STESSO, ordine
/// EY.** Il telefono promette (matrice dei piani, listino, elenchi dei
/// segni), il server impone (`functions/src/sociale.ts`, `budget.ts`,
/// `borsellino.ts`). Due copie della stessa promessa divergono sempre: questa
/// prova le legge tutte e due, numero per numero.
void main() {
  final sociale = File('functions/src/sociale.ts').readAsStringSync();
  const ordine = [Tier.free, Tier.tier1, Tier.tier2, Tier.tier3];

  Map<String, int> tabella(String nome) {
    final blocco = RegExp('$nome[^{]*\\{([^}]*)\\}', dotAll: true)
        .firstMatch(sociale)!
        .group(1)!;
    return {
      for (final m in RegExp(r'(\w+):\s*(\d+)').allMatches(blocco))
        m.group(1)!: int.parse(m.group(2)!),
    };
  }

  test('EY.07 ed EY.10: posti e segni del server sono quelli della matrice',
      () {
    final posti = tabella('POSTI_DEL_LEGAME');
    final segni = tabella('SEGNI_AL_GIORNO');
    for (var i = 0; i < 4; i++) {
      final t = ordine[i];
      expect(
          posti[t.name], PlanCatalog.limiteGiornaliero(RigaDelPiano.legami, t),
          reason: 'posti del legame, ${t.name}');
      expect(segni[t.name],
          PlanCatalog.limiteGiornaliero(RigaDelPiano.segniDelCerchio, t),
          reason: 'segni al giorno, ${t.name}');
    }
    // NESSUN SENZA LIMITE nei posti del legame, nemmeno all'Illuminato.
    for (final t in ordine) {
      expect(PlanCatalog.limiteGiornaliero(RigaDelPiano.legami, t), isNotNull);
    }
    print('EY.07 POSTI: $posti; EY.10 SEGNI: $segni');
  });

  test('EY.13: i confronti del cielo del server e il loro riscatto a 30 Eos',
      () {
    final budget = File('functions/src/budget.ts').readAsStringSync();
    final riga = RegExp(r'cieli: \[([^\]]*)\]').firstMatch(budget)!.group(1)!;
    final celle = riga.split(',').map((c) => int.parse(c.trim())).toList();
    for (var i = 0; i < 4; i++) {
      expect(celle[i],
          PlanCatalog.limiteGiornaliero(RigaDelPiano.cieli, ordine[i]));
      expect(celle[i],
          ListinoDegliEos.confrontoDelCieloInPiu.gratisAlGiorno[ordine[i]]);
    }
    final borsellino = File('functions/src/borsellino.ts').readAsStringSync();
    expect(borsellino.contains('cieli: 30,'), isTrue);
    expect(ListinoDegliEos.confrontoDelCieloInPiu.costo, 30);
  });

  test('EY.12: i prezzi dei doni stanno nel listino e sono quelli del server',
      () {
    final prezzi = tabella('PREZZI_DEI_DONI');
    expect(prezzi, {'cenno': 0, 'scintilla': 30, 'sigillo': 80});
    expect(ListinoDegliEos.scintilla.costo, prezzi['scintilla']);
    expect(ListinoDegliEos.sigilloDaDonare.costo, prezzi['sigillo']);
    // Il posto in piu' costa quanto la voce che esiste gia'.
    expect(sociale.contains('EOS_DEL_POSTO_IN_PIU = 100'), isTrue);
    expect(ListinoDegliEos.amicoInPiu.costo, 100);
    // Nessun prezzo scritto nelle schermate sociali: li dice il listino.
    final fileSociali = Directory('lib/features/cerchio')
        .listSync(recursive: true)
        .whereType<File>()
        .toList();
    cardinaleMinimo(fileSociali.length, 8,
        cosa: 'file delle schermate sociali',
        perche: 'Su una cartella vuota nessun prezzo sarebbe scritto a mano.');
    final schermate = fileSociali.map((f) => f.readAsStringSync()).join();
    expect(RegExp(r"'\d+ Eos").hasMatch(schermate), isFalse);
  });

  test(
      'EY.10 ed EY.11: i segni e le reazioni del telefono sono quelli del '
      'server, con le loro risposte', () {
    final risposte = tabella('RISPOSTE_PER_SEGNO');
    final telefono = {
      for (final s in ISegniDelCerchio.tutti) s.id: s.risposte.length,
    };
    expect(telefono, risposte);
    for (final c in CategoriaDelSegno.values) {
      expect(ISegniDelCerchio.di(c).length, greaterThanOrEqualTo(6),
          reason: 'la categoria ${c.name} ha meno di sei segni');
    }
    for (final s in ISegniDelCerchio.tutti) {
      expect(s.risposte.length, inInclusiveRange(2, 4), reason: s.id);
      expect(s.categoria == CategoriaDelSegno.richieste, s.apre != null,
          reason: 'la richiesta ${s.id} non apre niente');
    }
    final reazioni = RegExp(r'REAZIONI = \{([^}]*)\}', dotAll: true)
        .firstMatch(sociale)!
        .group(1)!;
    final delServer = {
      for (final m in RegExp(r'(\w+): "(\w+)"').allMatches(reazioni))
        m.group(1)!: m.group(2)!,
    };
    expect({for (final r in Reazione.values) r.name}, delServer.keys.toSet());
    for (final r in Reazione.values) {
      expect(r.negativa, delServer[r.name] == 'negativa', reason: r.name);
    }
    print('EY.10 SEGNI: ${telefono.length}, per categoria '
        '${CategoriaDelSegno.values.map((c) => ISegniDelCerchio.di(c).length).toList()}; '
        'EY.11 REAZIONI: ${Reazione.values.length}, negative '
        '${Reazione.values.where((r) => r.negativa).length}');
  });

  test('EY.08: le arti della presenza del telefono sono quelle del server', () {
    final blocco = RegExp(r'ARTI_DELLA_PRESENZA = \[([^\]]*)\]', dotAll: true)
        .firstMatch(sociale)!
        .group(1)!;
    final delServer = [
      for (final m in RegExp(r'"(\w+)"').allMatches(blocco)) m.group(1)!,
    ];
    expect([for (final a in ArteDellaPresenza.values) a.name], delServer);
  });

  test('EY.03: le icone sono i quattro set disegnati, contati come il server',
      () {
    final quante = tabella('QUANTE_ICONE');
    expect(
        {for (final f in FamigliaDelleIcone.values) f.name: f.quante}, quante);
    for (final f in FamigliaDelleIcone.values) {
      for (final i in IconaDelProfilo.di(f)) {
        expect(File(i.asset).existsSync(), isTrue,
            reason: 'l\'icona ${i.codice} non ha la sua arte: ${i.asset}');
      }
    }
  });

  test('EY.09: la maggiore eta\' dalla data di nascita, senza chiedere altro',
      () {
    final oggi = DateTime(2026, 10, 4);
    BirthIdentity nato(DateTime d) => BirthIdentity(birthMoment: d);
    expect(IlCerchioSociale.maggiorenne(nato(DateTime(2008, 10, 4)), oggi),
        isTrue);
    expect(IlCerchioSociale.maggiorenne(nato(DateTime(2008, 10, 5)), oggi),
        isFalse);
    expect(IlCerchioSociale.maggiorenne(null, oggi), isFalse);
    // Nessuna etichetta che dica che una persona e' minorenne.
    final fileSociali = Directory('lib/features/cerchio')
        .listSync(recursive: true)
        .whereType<File>()
        .toList();
    cardinaleMinimo(fileSociali.length, 8,
        cosa: 'file delle schermate sociali',
        perche: 'Su una cartella vuota nessuna etichetta sarebbe trovata.');
    final schermate =
        fileSociali.map((f) => f.readAsStringSync()).join().toLowerCase();
    expect(RegExp(r"'[^']*minorenn[^']*'").hasMatch(schermate), isFalse);
  });
}
