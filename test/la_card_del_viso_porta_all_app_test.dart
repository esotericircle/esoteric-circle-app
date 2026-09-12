import 'package:esoteric_circle/core/brand/brand.dart';
import 'package:esoteric_circle/core/face/face_classifier.dart';
import 'package:esoteric_circle/core/face/face_trait.dart';
import 'package:esoteric_circle/core/face/mian_xiang.dart';
import 'package:esoteric_circle/features/maestri/aura/face/face_constellation.dart';
import 'package:esoteric_circle/features/maestri/aura/face/face_share_card.dart';
import 'package:esoteric_circle/features/maestri/aura/face/face_silhouette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// **LA CARD DEL VISO PORTA ALL'APP, E DICE L'ELEMENTO.** Ordine CR voce 10,
/// 6 settembre 2026.
///
/// **Parole del fondatore, riportate nell'ordine**: *"la card deve portare una
/// via per arrivare all'app, perche' oggi non ce l'ha"*, e sulla card devono
/// stare *"la costellazione composta, protagonista; il volto molto sbiadito
/// sotto; il titolo che e' gia' la risposta; l'elemento dominante; una riga
/// sola di essenza"*.
///
/// **COSA HO MISURATO PRIMA DI SCRIVERE QUESTA GUARDIA.** Il testo che oggi
/// esce dal telefono e' questo, letto sulla funzione e non a memoria:
///
///     La mia Costellazione del Viso dice "...". Scopri la tua con Aura, su
///     Esoteric Circle.
///
/// E' un NOME, non una via: chi lo riceve sa come si chiama l'app e non sa
/// dove andare. Lo stesso vale per l'Oroscopo, i Tarocchi e la Sinastria, e
/// quella e' una voce che non appartiene a questo ordine: qui si cura il Viso,
/// e il resto sta scritto nel referto invece di essere allargato in silenzio.
///
/// **E L'ELEMENTO NON C'ERA PROPRIO.** Il Mian Xiang esisteva in
/// `lib/core/face/mian_xiang.dart` con le sue guardie, ma **nessun file di
/// `lib` lo chiamava**: prodotto, non agganciato. Una guardia che avesse
/// interrogato solo il modulo sarebbe stata verde su codice che non
/// raggiungeva nessuno.
void main() {
  // Una lettura costruita a mano, con una forma di volto dichiarata: cosi' si
  // sa quale elemento DEVE uscire, invece di leggere quello che esce e dargli
  // ragione.
  FaceReading letturaCon(FaceTrait forma) {
    final letture = <TraitLettura>[];
    for (final c in FaceCategory.values) {
      final tratto = c == FaceCategory.formaVolto
          ? forma
          : FaceTrait.perCategoria(c).first;
      letture.add(TraitLettura(
        tratto: tratto,
        marcatezza: c == FaceCategory.formaVolto ? 1.0 : 0.2,
      ));
    }
    return FaceReading(letture: letture);
  }

  test("il testo condiviso porta una via per arrivare all'app", () {
    for (final forma in FaceTrait.perCategoria(FaceCategory.formaVolto)) {
      final lettura = letturaCon(forma);
      final testo = testoDaCondividere(dominante: lettura.dominante);
      expect(testo, contains(Brand.url),
          reason: 'il testo condiviso non porta nessun indirizzo: chi lo '
              'riceve legge un nome e non sa dove andare. Testo: «$testo»');
    }
  });

  testWidgets("la card mostra l'elemento dominante misurato",
      (tester) async {
    for (final forma in FaceTrait.perCategoria(FaceCategory.formaVolto)) {
      final lettura = letturaCon(forma);
      final atteso = MianXiang.elementoDa(forma);
      if (atteso == null) continue;

      await tester.pumpWidget(MaterialApp(
        home: Center(
          child: SingleChildScrollView(
            child: FaceShareCard(
              reading: lettura,
              costellazione:
                  FaceConstellation.da(FaceSilhouette.contorni()),
            ),
          ),
        ),
      ));
      await tester.pump();

      expect(find.textContaining(atteso.nome), findsWidgets,
          reason: 'la card non dice l\'elemento dominante: la forma '
              '${forma.nome} vale ${atteso.nome} e sulla card non compare');
    }
  });

  testWidgets("la card porta l'indirizzo, non solo il nome del brand",
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Center(
        child: SingleChildScrollView(
          child: FaceShareCard(
            reading: letturaCon(FaceTrait.voltoOvale),
            costellazione: FaceConstellation.da(FaceSilhouette.contorni()),
          ),
        ),
      ),
    ));
    await tester.pump();

    // **SI CERCA IL DOMINIO, non l'URL intero**: sulla card un `https://`
    // stampato e' rumore, e cio' che serve a chi guarda una fotografia e' il
    // pezzo che si puo' digitare.
    expect(find.textContaining(Brand.domain), findsWidgets,
        reason: 'la card non porta nessun indirizzo: e\' una fotografia che '
            'gira senza dire dove si va');
  });
}
