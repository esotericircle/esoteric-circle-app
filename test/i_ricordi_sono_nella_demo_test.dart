/// I RICORDI DEL CERCHIO SONO ATTIVI NELLA DEMO. Ordine CG voce 13.
///
/// **Questa voce supera lo scope della Demo congelato**, e va scritto perche'
/// altrimenti la prossima sessione trova due decisioni che si contraddicono.
/// Parole del fondatore, 31 agosto 2026: "la 7 perche' voglio che entri nella
/// demo".
///
/// **E DICHIARA LA DIVERGENZA FRA I TRE ELENCHI**, che l'ordine chiede di
/// verificare. Non sono tre copie della stessa lista: sono tre domande
/// diverse, e la prova le nomina invece di pretendere che coincidano.
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:esoteric_circle/core/arts/art_catalog.dart';
import 'package:esoteric_circle/core/feature_flags/feature_catalog.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/feature_flags/feature_flag.dart';
import 'package:esoteric_circle/core/santuario/function_shelf.dart';

void main() {
  test('CG.13: i Ricordi sono ATTIVI nella Demo, non Coming soon', () {
    final ricordi = FeatureCatalog.byId('ricordi_del_cerchio');
    expect(ricordi, isNotNull,
        reason: 'i Ricordi non sono nel catalogo delle funzioni: nella Demo '
            'non comparirebbero affatto');
    expect(ricordi!.defaultAvailability, RemoteAvailability.enabled,
        reason: 'i Ricordi devono essere attivi e non Coming soon. IL ROSSO '
            'SI DIMOSTRA mettendo comingSoon, e questa prova deve cadere');
    // Il tier di default del catalogo e' `free`, cioe' nessun cancello: e'
    // quello che serve qui. La sola parte che chiede un piano e' la lettura
    // in prosa del mese, che vive nella voce CG.11 e ha il suo cancello li'.
    expect(ricordi.requiredTier, Tier.free,
        reason: 'i Ricordi non sono premium: la timeline, la ricerca e le '
            'Carte sono di tutti');
  });

  test('CG.13: i tre elenchi, contati e la divergenza dichiarata', () {
    final vive = [
      for (final a in ArtCatalog.all)
        if (a.state == ArtState.attiva) a.id,
    ];
    final scaffale = FunctionShelf.functions.map((f) => f.id).toList();
    final manifest =
        jsonDecode(File('docs/stato_funzioni.json').readAsStringSync()) as Map;
    final dichiarate =
        (manifest['funzioni'] as Map).keys.map((k) => '$k').toList();

    final fuoriScaffale = vive.where((id) => !scaffale.contains(id)).toList();

    // ignore: avoid_print
    print('ORDINE CG VOCE 13: arti vive nel catalogo ${vive.length}, '
        'funzioni sullo scaffale del Santuario ${scaffale.length}, '
        'funzioni nel manifest ${dichiarate.length}. '
        'Vive e non sullo scaffale: $fuoriScaffale');

    // **LO SCAFFALE E IL MANIFEST DEVONO COINCIDERE**, perche' il manifest
    // dichiara di essere la fonte macchina dello scaffale.
    expect(dichiarate.toSet(), scaffale.toSet(),
        reason: 'il manifest e lo scaffale divergono: il manifest dichiara di '
            'essere la fonte macchina dello scaffale, quindi due liste '
            'diverse sono due verita\'');

    // **IL CATALOGO PUO' AVERE PIU' ARTI DELLO SCAFFALE, ed e' voluto.** Lo
    // scaffale e' l'elenco sotto l'eroe del Santuario, cioe' una scelta
    // curata: il suo commento dichiara gia' che i Doni ne restano fuori
    // apposta. Le arti che non ci stanno si raggiungono dal dominio del loro
    // Maestro, che e' una porta vera. **Cio' che NON si accetta e' che
    // l'elenco fuori scaffale cresca in silenzio**: qui e' dichiarato per
    // nome, e una prova cade se cambia senza che nessuno lo scriva.
    expect(fuoriScaffale.toSet(), {'rune_draw', 'magic_sigil'},
        reason: 'le arti vive fuori dallo scaffale sono cambiate: adesso sono '
            '$fuoriScaffale. Se e\' voluto si aggiorna questa riga con la '
            'ragione, se non lo e\' si aggiunge l\'arte allo scaffale. IL '
            'ROSSO SI DIMOSTRA rendendo viva un\'arte del catalogo senza '
            'metterla sullo scaffale');
  });
}
