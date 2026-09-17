// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/arts/art_catalog.dart';
import 'package:esoteric_circle/core/chat/immersive_intents.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/features/maestri/art_navigation.dart';
import 'package:esoteric_circle/features/maestri/immersive_navigation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'codice_senza_testo.dart';

/// **OGNI PULSANTE DELLA CHAT APRE LA FUNZIONE CHE PROMETTE.** Ordine DS voce
/// 07, 17 settembre 2026.
///
/// **Il fatto, visto dal fondatore**: nella chat con Caligo si chiede
/// l'estrazione delle rune, compare il pulsante, e il pulsante apre la Runa
/// del Tramonto, che e' il dono del giorno. La regola che quel pulsante
/// tradiva e' scritta in `chat_suggestions.dart`: *"la regola del vero, mai
/// un titolo che apre il nulla"*.
///
/// **La causa non era un pulsante, era una mappa.** La chat aveva la SUA
/// tavola delle destinazioni, `immersiveRouteFor`, scritta accanto a quella
/// dello scaffale, `artRouteFor`: due porte per le stesse funzioni, e le due
/// si erano separate. Contati tutti e quattordici i pulsanti dei tre
/// Maestri, **sei erano sbagliati**: le rune; la Stesa, la Costellazione del
/// Viso e il Sigillo, che la chat dichiarava *"Arriva presto"* mentre dallo
/// scaffale si aprivano; l'oroscopo del giorno, che apriva l'Arcano.
///
/// **Adesso la porta e' una.** Ogni pulsante nomina un'arte del catalogo, e la
/// destinazione la decide la stessa funzione dello scaffale: un pulsante che
/// apre una cosa diversa da quella che dice non si puo' piu' scrivere senza
/// cambiare anche lo scaffale.
void main() {
  final nascita = DateTime(1990, 6, 15, 10, 30);

  /// **I pulsanti che non aprono nessuna arte, ognuno col suo perche'.**
  const senzaArteDichiarati = <ImmersiveTarget, String>{
    ImmersiveTarget.ritualeCandela:
        'il rito della candela non e nel catalogo delle arti: la chat dice che '
            'arriva presto, ed e vero',
  };

  /// Il nome della funzione, quando non sta nel catalogo delle arti.
  const nomiFuoriCatalogo = <String, String>{
    'day_oracle': 'Arcano del Giorno',
  };

  String nomeDi(String id) {
    final dalCatalogo = ArtCatalog.all.where((a) => a.id == id);
    if (dalCatalogo.isNotEmpty) return dalCatalogo.first.title;
    return nomiFuoriCatalogo[id] ?? '';
  }

  String piano(String s) => s
      .toLowerCase()
      .replaceAll("'", ' ')
      .replaceAll('’', ' ')
      .replaceAll(RegExp(r'\s+'), ' ');

  test('la chat non ha una mappa sua: apre dalla porta dello scaffale', () {
    final codice = codiceSenzaTesto(
        File('lib/features/maestri/immersive_navigation.dart')
            .readAsStringSync());
    final schermate =
        RegExp(r'\b[A-Z]\w*Screen\b').allMatches(codice).map((m) => m[0]);
    expect(schermate.toSet(), isEmpty,
        reason: 'la navigazione della chat nomina delle schermate sue: e la '
            'seconda porta che ha mandato le rune sulla Runa del Tramonto');
    expect(codice.contains('artRouteFor('), isTrue,
        reason: 'la chat non apre dalla porta dello scaffale');
  });

  test(
      'ogni pulsante nomina la funzione che apre, e apre se la funzione e '
      'viva', () {
    var controllati = 0;
    final sbagliati = <String>[];
    final righe = <String>[];
    for (final intento in ImmersiveIntents.all) {
      controllati++;
      final id = artDellIntento[intento.target];
      final Maestro chi = intento.maestro;
      if (id == null) {
        // **Un pulsante senza arte si dichiara, col perche'.** Era proprio
        // cosi' che la Stesa, il Viso e il Sigillo dicevano "arriva presto":
        // nessuna arte nominata, quindi nessuno controllava.
        righe.add('${chi.name} "${intento.buttonLabel}" -> nessuna arte');
        if (!senzaArteDichiarati.containsKey(intento.target)) {
          sbagliati.add('${intento.id}: non nomina nessuna arte e non e '
              'dichiarato fra i pulsanti senza arte');
        }
        continue;
      }
      final nome = nomeDi(id);
      if (nome.isEmpty) {
        sbagliati.add('${intento.id}: $id non e nel catalogo');
        continue;
      }
      final perLaChat = immersiveRouteFor(intento.target, userBirth: nascita);
      final perLoScaffale = artRouteFor(id, userBirth: nascita);
      righe.add('${chi.name} "${intento.buttonLabel}" -> $id ($nome), '
          '${perLaChat == null ? "arriva presto" : "si apre"}');
      if (!piano(intento.buttonLabel).contains(piano(nome))) {
        sbagliati.add('${intento.id}: il pulsante dice '
            '"${intento.buttonLabel}" e apre "$nome"');
      }
      if ((perLaChat == null) != (perLoScaffale == null)) {
        sbagliati.add('${intento.id}: dalla chat '
            '${perLaChat == null ? "arriva presto" : "si apre"}, dallo '
            'scaffale ${perLoScaffale == null ? "arriva presto" : "si apre"}');
      }
      final arte = ArtCatalog.all.where((a) => a.id == id);
      if (arte.isNotEmpty &&
          arte.first.state == ArtState.attiva &&
          perLaChat == null) {
        sbagliati.add('${intento.id}: "$nome" e attiva e la chat dice che '
            'arriva presto');
      }
    }
    print('ORDINE DS VOCE 07: pulsanti controllati $controllati, sbagliati '
        '${sbagliati.length}\n  ${righe.join("\n  ")}');
    expect(controllati, greaterThanOrEqualTo(14),
        reason: 'i pulsanti della chat sono almeno quattordici');
    for (final m in Maestro.values) {
      expect(ImmersiveIntents.all.where((i) => i.maestro == m), isNotEmpty,
          reason: 'nessun pulsante per ${m.name}');
    }
    expect(sbagliati, isEmpty, reason: sbagliati.join('\n'));
  });

  test('le rune di Caligo aprono l\'Estrazione, non la Runa del Tramonto', () {
    final rune = ImmersiveIntents.all
        .firstWhere((i) => i.target == ImmersiveTarget.lancioRune);
    expect(rune.maestro, Maestro.caligo);
    expect(artDellIntento[ImmersiveTarget.lancioRune], 'rune_draw');
  });

  test('l oroscopo del giorno apre l Oroscopo, non l Arcano', () {
    expect(artDellIntento[ImmersiveTarget.oroscopoGiorno], 'horoscope');
  });
}
