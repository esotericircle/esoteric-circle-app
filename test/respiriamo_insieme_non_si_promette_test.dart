import 'dart:io';

import 'package:esoteric_circle/core/entitlement/listino_degli_eos.dart';
import 'package:esoteric_circle/core/entitlement/plan_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';
import 'le_parole_di_chi_legge.dart' show letteraliDi;
import 'sorgenti_di_lib.dart';

/// **RESPIRIAMO INSIEME NON SI PROMETTE.** Ordine GA, decisione del
/// fondatore del 20 ottobre 2026, alla lettera:
///
/// *"Strada (a): togli dalle card di Adepto e Illuminato la riga "Respiriamo
/// insieme, con la collana a due" e ogni altro punto dell'app che promette
/// "Respiriamo insieme" (matrice dei piani, paywall, schermata dei prezzi,
/// Respiro della Luna). Le funzioni del Respiro non si pubblicano. Una
/// guardia cade se la promessa ricompare."*
///
/// Le porte del server del Respiro condiviso (il respiro collettivo, la
/// collana a due, la ricucitura di una perla) sono scritte in
/// `functions/src` e non pubblicate (ordine FX, R3; ordine GA voce 11,
/// `una_porta_non_pubblicata_dice_il_vero_test.dart`): l'app non le
/// promette nei piani e nel listino, e nessuna schermata le apre.
///
/// Padre della promessa (Regola C): ordine FX voci FX.09 e FX.10 (la riga
/// della card dell'Adepto, la riga della matrice, le due voci del listino) e
/// FXA.03 (la ricucitura a video).
///
/// **Tre prove, tre grandezze diverse.** Le stringhe di `lib` (la promessa
/// scritta a mano dovunque, anche in una schermata nuova); i dati che le
/// schermate dei piani e dei prezzi leggono (card, righe dell'annuale,
/// matrice, listino); le chiamate alle porte non pubblicate fuori dal client
/// del Cerchio, cioe' le porte a video.
void main() {
  /// La promessa, in ogni forma in cui l'app l'ha scritta.
  final promessa = RegExp(
      r'respiriamo\s+insieme|respiro\s+insieme|respirare\s+insieme|'
      r'collan[ae]\s+a\s+due',
      caseSensitive: false);

  test('nessuna stringa di lib promette Respiriamo insieme o la collana a due',
      () {
    final colpe = <String>[];
    var letterali = 0;
    for (final f in sorgentiDiLib()) {
      final percorso = f.path.replaceAll(r'\', '/');
      for (final l in letteraliDi(f.readAsStringSync())) {
        letterali++;
        if (promessa.hasMatch(l.testo)) {
          colpe.add('$percorso:${l.riga} «${l.testo}»');
        }
      }
    }
    // ignore: avoid_print
    print('ORDINE GA, RESPIRIAMO INSIEME: letterali guardati $letterali, '
        'con la promessa ${colpe.length}');
    cardinaleMinimo(letterali, 18000,
        cosa: 'letterali di stringa in lib',
        perche: 'il 20 ottobre 2026 erano piu\' di settantamila: sotto '
            'diciottomila il lettore dei sorgenti ha smesso di leggere');
    expect(colpe, isEmpty,
        reason: 'queste stringhe promettono una funzione del Respiro che il '
            'server non ha:\n${colpe.join('\n')}');
  });

  test('la matrice, le card, l\'annuale e il listino non la promettono', () {
    final righe = [for (final r in PlanCatalog.matrix) r.label];
    final card = [
      for (final p in PlanCatalog.plans) ...[
        ...p.highlights,
        ...p.nellAnnuale.values,
      ],
    ];
    final listino = [
      for (final v in ListinoDegliEos.tutte) '${v.id} ${v.nome}',
    ];
    cardinaleMinimo(righe.length, 60,
        cosa: 'righe della matrice dei piani',
        perche: 'il 20 ottobre 2026 erano 66');
    cardinaleMinimo(card.length, 50,
        cosa: 'righe delle card dei piani',
        perche: 'il 20 ottobre 2026 erano piu\' di settanta');
    cardinaleMinimo(listino.length, 15,
        cosa: 'voci del listino degli Eos',
        perche: 'il 20 ottobre 2026 erano 18');
    final colpe = [
      for (final r in righe)
        if (promessa.hasMatch(r)) 'matrice: $r',
      for (final c in card)
        if (promessa.hasMatch(c)) 'card: $c',
      // Le voci a Eos del Respiro condiviso hanno l'identificativo
      // `respiro_`: si comprerebbero funzioni senza server.
      for (final v in listino)
        if (promessa.hasMatch(v) || v.startsWith('respiro_')) 'listino: $v',
    ];
    expect(colpe, isEmpty, reason: colpe.join('\n'));
  });

  test('nessuna schermata apre una porta del Respiro non pubblicata', () {
    const client = 'lib/core/cerchio/il_cerchio_sociale.dart';
    const porte = [
      'respiroInsiemeEntra',
      'respiroInsiemeConteggio',
      'invitaCollanaADue',
      'rispondiCollanaADue',
      'segnalaRespiroDelGiornoPerLaCollanaADue',
      'ricuciUnaPerlaDelRespiro',
      'leCollaneADue',
    ];
    // Le porte esistono nel client del Cerchio: se un nome cambiasse,
    // questa prova cercherebbe un nome che nessuno scrive piu'.
    final delClient = File(client).readAsStringSync();
    for (final p in porte) {
      expect(delClient.contains(' $p('), isTrue,
          reason: 'la porta $p non e\' piu\' nel client del Cerchio: la '
              'prova va aggiornata col nome nuovo');
    }
    final chiamata = RegExp(r'\.(' + porte.join('|') + r')\s*\(');
    final colpe = <String>[];
    var guardati = 0;
    for (final (:percorso, :righe) in righeDiLib()) {
      if (percorso.endsWith(client)) continue;
      guardati++;
      for (var i = 0; i < righe.length; i++) {
        final r = righe[i].trimLeft();
        if (r.startsWith('//')) continue;
        if (chiamata.hasMatch(r)) colpe.add('$percorso:${i + 1} $r');
      }
    }
    // ignore: avoid_print
    print('ORDINE GA, RESPIRIAMO INSIEME: sorgenti guardati $guardati, '
        'chiamate alle porte non pubblicate ${colpe.length}');
    cardinaleMinimo(guardati, quantiFileHaLib,
        cosa: 'sorgenti di lib fuori dal client del Cerchio');
    expect(colpe, isEmpty,
        reason: 'queste righe aprono a video una porta del Respiro che il '
            'server non ha pubblicato:\n${colpe.join('\n')}');
  });
}
