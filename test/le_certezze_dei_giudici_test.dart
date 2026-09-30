// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

import 'package:esoteric_circle/core/chat/le_certezze_del_maestro.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **LA RETE DELLE CERTEZZE CONTRO I GIUDICI ALLA CIECA. Ordine ES voce 19,
/// 30 settembre 2026.**
///
/// L'ordine: le certezze devono essere zero. Alla lettura alla cieca del
/// giro nuovo del banco delle trenta domande le risposte con una certezza
/// sono salite da 23 a 33 su 360, perche' la prima stesura della ES.19 aveva
/// esentato il futuro detto sotto *"le carte dicono che"*: i giudici lo
/// contano come certezza, ed e' il loro metro quello del 30 su 30. Qui la
/// rete si misura sulle frasi che gli stessi giudici hanno citato come
/// certezze e sulle frasi delle risposte che hanno dato senza certezze
/// (`docs/collaudo/ES/certezze_giudicate.json`, `tool/le_certezze_giudicate.py`).
/// Sul codice di prima la rete prendeva 12 certezze dei giudici su 61 (le
/// risposte giudicate erano gia' passate da lei); su questo ne prende 51, e
/// le 10 che restano sono forme dichiarate qui sotto. La prova del rosso sta
/// in `docs/collaudo/ES/regola_a_certezze_dei_giudici.txt`.
void main() {
  test('la rete prende le certezze dei giudici e lascia le frasi buone', () {
    final dati = jsonDecode(
            File('docs/collaudo/ES/certezze_giudicate.json').readAsStringSync())
        as Map<String, dynamic>;
    final certe = (dati['certe'] as List).cast<Map<String, dynamic>>();
    final buone = (dati['buone'] as List).cast<Map<String, dynamic>>();
    cardinaleMinimo(certe.length, 50, cosa: 'certezze citate dai giudici');
    cardinaleMinimo(buone.length, 1500, cosa: 'frasi senza certezze');
    final mancate = <String>[];
    for (final c in certe) {
      if (LeCertezzeDelMaestro.inQuesteFrasi(c['frase'] as String).isEmpty) {
        mancate.add(c['frase'] as String);
      }
    }
    final prese = <String>[];
    for (final b in buone) {
      if (LeCertezzeDelMaestro.inQuesteFrasi(b['frase'] as String).isNotEmpty) {
        prese.add(b['frase'] as String);
      }
    }
    print('ORDINE ES VOCE 19: certezze dei giudici prese '
        '${certe.length - mancate.length} su ${certe.length}; frasi buone '
        'prese per certe ${prese.length} su ${buone.length}');
    print('ORDINE ES VOCE 19: mancate ${mancate.take(12).toList()}');
    print('ORDINE ES VOCE 19: buone prese ${prese.take(12).toList()}');
    // **LA GRANDEZZA E' L'ELENCO, NON LA QUOTA.** La prima stesura
    // pretendeva due terzi delle certezze prese: alla prova del rosso il
    // difetto che aveva fatto salire le certezze da 23 a 33 (il futuro dopo
    // ogni "che" di nuovo esente) toglieva quattro prese su cinquantuno e la
    // prova restava verde. Adesso ogni certezza dei giudici che la rete non
    // prende deve stare fra queste, le forme che una rete di parole non puo'
    // riconoscere: un'immagine detta come fatto (*"Il sigillo della
    // creazione è su di te"*), un legame o un sentimento descritti al
    // presente senza un soggetto riconoscibile.
    const nonRiconoscibili = {
      "Il cammino è bloccato, non c'è ritorno immediato.",
      'Il sigillo della creazione è su di te.',
      'percepisci questa riserva come una mancanza, ma non è così.',
      'Questo legame è forte.',
      'che lo porta a riconsiderare i legami passati, ma non a ripristinarli '
          'tali e quali',
      'È un sentimento che si manifesta con gesti, non con parole facili.',
      'Non è un allontanamento da te, quanto una ricerca interiore di nuovi '
          'stimoli.',
      'la forza di questo legame è già presente',
      'Il sigillo che vi lega è di Lealtà, anche se ora è messo alla prova.',
      'Il Toro lunare lo ancora alla stabilità del legame.',
    };
    expect(mancate.where((m) => !nonRiconoscibili.contains(m)), isEmpty,
        reason: 'la rete lascia passare certezze che sapeva prendere');
    expect(prese.length, lessThanOrEqualTo(buone.length ~/ 20),
        reason: 'la rete scambia per certe troppe frasi buone');
  });
}
