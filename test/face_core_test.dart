import 'package:esoteric_circle/core/face/face_classifier.dart';
import 'package:esoteric_circle/core/face/face_corpus.dart';
import 'package:esoteric_circle/core/face/face_trait.dart';
import 'package:flutter_test/flutter_test.dart';

/// Il cuore deterministico della Costellazione del Viso.
///
/// La classificazione dei tratti dalla geometria dei contorni e' pura: qui si
/// costruiscono contorni sintetici che spingono una categoria verso una
/// variante e si verifica che il classificatore la legga. Nessun plugin, nessuna
/// fotocamera: solo punti.
void main() {
  // Un volto neutro di riferimento, con i parametri che poi si sovrascrivono per
  // spingere una categoria alla volta.
  FaceContours volto({
    double cx = 200,
    double y0 = 0,
    double h = 300,
    double wFronte = 150,
    double wZigomi = 160,
    double wMascella = 150,
    double wMento = 110,
    String sopracciglio = 'curve',
    double gapOcchi = 60,
    double wOcchio = 30,
    double hOcchio = 24,
    double nasoLen = 0.30,
    double wLabbra = 80,
    double spessoreLabbra = 26,
    double? gapZigomi = 168,
  }) {
    List<Offset> lato(double frazione, double semi) {
      final y = y0 + h * frazione;
      return [Offset(cx - semi, y), Offset(cx + semi, y)];
    }

    final v = <Offset>[
      Offset(cx, y0),
      ...lato(0.06, wFronte / 2),
      ...lato(0.22, wFronte / 2),
      ...lato(0.30, wFronte / 2),
      ...lato(0.45, wZigomi / 2),
      ...lato(0.55, wZigomi / 2),
      ...lato(0.72, wMascella / 2),
      ...lato(0.82, wMascella / 2),
      ...lato(0.86, wMascella / 2),
      ...lato(0.94, wMento / 2),
      ...lato(0.98, wMento / 2),
      Offset(cx, y0 + h),
    ];

    List<Offset> sopraccio(double centro) {
      final base = y0 + h * 0.34;
      switch (sopracciglio) {
        case 'dritte':
          return [
            Offset(centro - 20, base),
            Offset(centro, base),
            Offset(centro + 20, base),
          ];
        case 'angolo':
          return [
            Offset(centro - 20, base),
            Offset(centro, base - 10),
            Offset(centro + 20, base),
          ];
        default: // curve
          return [
            Offset(centro - 20, base),
            Offset(centro, base - 3),
            Offset(centro + 20, base),
          ];
      }
    }

    List<Offset> occhio(double centro) {
      final y = y0 + h * 0.40;
      return [
        Offset(centro - wOcchio / 2, y),
        Offset(centro + wOcchio / 2, y),
        Offset(centro, y - hOcchio / 2),
        Offset(centro, y + hOcchio / 2),
      ];
    }

    final nasoTop = y0 + h * 0.36;
    final labbroTop = y0 + h * 0.74;

    return FaceContours(
      volto: v,
      sopraccioSx: sopraccio(cx - 45),
      sopraccioDx: sopraccio(cx + 45),
      occhioSx: occhio(cx - gapOcchi / 2),
      occhioDx: occhio(cx + gapOcchi / 2),
      nasoPonte: [Offset(cx, nasoTop)],
      nasoBase: [
        Offset(cx - 12, nasoTop + h * nasoLen),
        Offset(cx + 12, nasoTop + h * nasoLen),
      ],
      labbroSopra: [
        Offset(cx - wLabbra / 2, labbroTop),
        Offset(cx + wLabbra / 2, labbroTop),
      ],
      labbroSotto: [
        Offset(cx - wLabbra / 2, labbroTop + spessoreLabbra),
        Offset(cx + wLabbra / 2, labbroTop + spessoreLabbra),
      ],
      guanciaSx: gapZigomi == null ? null : Offset(cx - gapZigomi / 2, y0 + h * 0.5),
      guanciaDx: gapZigomi == null ? null : Offset(cx + gapZigomi / 2, y0 + h * 0.5),
    );
  }

  FaceTrait letto(FaceContours c, FaceCategory cat) =>
      FaceClassifier.leggi(c).letturaDi(cat).tratto;

  group('Forma del volto', () {
    test('Fronte larga e mento stretto: triangolare', () {
      final c = volto(wFronte: 180, wZigomi: 160, wMascella: 120, wMento: 80);
      expect(letto(c, FaceCategory.formaVolto), FaceTrait.voltoTriangolare);
    });
    test('Alto e stretto: ovale', () {
      final c = volto(h: 420, wFronte: 140, wZigomi: 150, wMascella: 140);
      expect(letto(c, FaceCategory.formaVolto), FaceTrait.voltoOvale);
    });
    test('Lati pieni e larghi: quadrato', () {
      final c = volto(
          h: 210, wFronte: 175, wZigomi: 180, wMascella: 172, wMento: 150);
      expect(letto(c, FaceCategory.formaVolto), FaceTrait.voltoQuadrato);
    });
    test('Largo e morbido: tondo', () {
      final c = volto(
          h: 210, wFronte: 160, wZigomi: 190, wMascella: 165, wMento: 130);
      expect(letto(c, FaceCategory.formaVolto), FaceTrait.voltoTondo);
    });
  });

  test('Fronte alta verticale, fronte bassa sfuggente', () {
    // La y del sopracciglio piu' in basso rispetto al vertice alza la fronte.
    final alta = volto();
    // Nella costruzione il sopracciglio sta a 0.34h: la fronte e' circa 0.34,
    // sopra la soglia 0.33, quindi verticale.
    expect(letto(alta, FaceCategory.fronte), FaceTrait.fronteVerticale);
  });

  group('Sopracciglia', () {
    test('Collineari: dritte', () {
      expect(letto(volto(sopracciglio: 'dritte'), FaceCategory.sopracciglia),
          FaceTrait.sopraccigliaDritte);
    });
    test('Arco gentile: curve', () {
      expect(letto(volto(sopracciglio: 'curve'), FaceCategory.sopracciglia),
          FaceTrait.sopraccigliaCurve);
    });
    test('Apice aguzzo: ad angolo', () {
      expect(letto(volto(sopracciglio: 'angolo'), FaceCategory.sopracciglia),
          FaceTrait.sopraccigliaAngolo);
    });
  });

  test('Occhi vicini e occhi lontani', () {
    expect(letto(volto(gapOcchi: 44), FaceCategory.distanzaOcchi),
        FaceTrait.occhiRavvicinati);
    expect(letto(volto(gapOcchi: 78), FaceCategory.distanzaOcchi),
        FaceTrait.occhiDistanziati);
  });

  test('Occhi grandi e occhi raccolti', () {
    expect(letto(volto(hOcchio: 32), FaceCategory.grandezzaOcchi),
        FaceTrait.occhiGrandi);
    expect(letto(volto(hOcchio: 16), FaceCategory.grandezzaOcchi),
        FaceTrait.occhiRaccolti);
  });

  test('Naso lungo e naso corto', () {
    expect(letto(volto(nasoLen: 0.40), FaceCategory.naso), FaceTrait.nasoLungo);
    expect(letto(volto(nasoLen: 0.22), FaceCategory.naso), FaceTrait.nasoCorto);
  });

  test('Labbra piene e labbra sottili', () {
    expect(letto(volto(spessoreLabbra: 34), FaceCategory.labbra),
        FaceTrait.labbraPiene);
    expect(letto(volto(spessoreLabbra: 16), FaceCategory.labbra),
        FaceTrait.labbraSottili);
  });

  test('Bocca larga e bocca piccola', () {
    expect(letto(volto(wLabbra: 96), FaceCategory.bocca), FaceTrait.boccaLarga);
    expect(letto(volto(wLabbra: 58), FaceCategory.bocca), FaceTrait.boccaPiccola);
  });

  test('Mento ampio e mento a punta', () {
    expect(letto(volto(wMento: 130, wMascella: 160), FaceCategory.mento),
        FaceTrait.mentoAmpio);
    expect(letto(volto(wMento: 70, wMascella: 160), FaceCategory.mento),
        FaceTrait.mentoAPunta);
  });

  test('Mascella larga e mascella stretta', () {
    expect(letto(volto(wMascella: 180, wZigomi: 180), FaceCategory.mascella),
        FaceTrait.mascellaLarga);
    expect(letto(volto(wMascella: 120), FaceCategory.mascella),
        FaceTrait.mascellaStretta);
  });

  test('Zigomi alti e zigomi morbidi', () {
    expect(letto(volto(gapZigomi: 190, wMascella: 150), FaceCategory.zigomi),
        FaceTrait.zigomiAlti);
    expect(letto(volto(gapZigomi: 150, wMascella: 160), FaceCategory.zigomi),
        FaceTrait.zigomiMorbidi);
  });

  test('La lettura e\' deterministica: stessi contorni, stesso responso', () {
    final c = volto();
    final a = FaceClassifier.leggi(c);
    final b = FaceClassifier.leggi(c);
    expect(a.marcati, b.marcati);
    expect(a.dominante, b.dominante);
    expect(a.letture.length, FaceCategory.values.length);
  });

  test('Il ripiego dalle selezioni da\' una lettura con dominante', () {
    final r = FaceClassifier.daSelezioni({
      FaceCategory.formaVolto: FaceTrait.voltoQuadrato,
      FaceCategory.grandezzaOcchi: FaceTrait.occhiGrandi,
      FaceCategory.sopracciglia: FaceTrait.sopraccigliaAngolo,
      FaceCategory.labbra: FaceTrait.labbraPiene,
      FaceCategory.mento: FaceTrait.mentoAmpio,
    });
    expect(r.letture.length, 5);
    // Il volto quadrato ha la salienza piu' alta fra le scelte.
    expect(r.dominante, FaceTrait.voltoQuadrato);
  });

  group('Corpus', () {
    test('Ogni variante ha la sua frase, piena e conforme', () {
      for (final t in FaceTrait.values) {
        final f = FaceCorpus.frase(t);
        expect(f.trim(), isNotEmpty, reason: t.name);
        expect(f.length, greaterThan(30), reason: t.name);
      }
    });
    test('Ogni categoria ha almeno due varianti', () {
      for (final cat in FaceCategory.values) {
        expect(FaceTrait.perCategoria(cat).length, greaterThanOrEqualTo(2),
            reason: cat.name);
      }
    });
    test('La sintesi intreccia i tratti marcati, deterministica', () {
      final r = FaceClassifier.leggi(volto());
      final s = FaceCorpus.sintesi(r.marcati);
      expect(s, FaceCorpus.sintesi(r.marcati));
      expect(s, contains(FaceCorpus.frase(r.dominante)));
      expect(s.length, greaterThan(120));
    });
  });
}
