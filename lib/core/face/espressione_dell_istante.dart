import 'package:mediapipe_face_mesh/mediapipe_face_mesh.dart';

/// **L'ESPRESSIONE DELL'ISTANTE.** Ordine CR voce 07, 6 settembre 2026.
///
/// **Parole del fondatore**: *"fornisca un responso del suo umore,
/// personalita' o altro in quel dato momento sulla base dell'espressione
/// rilevata"*.
///
/// **LA DISTINZIONE CHE L'ORDINE IMPONE, e non e' una sfumatura.** I TRATTI
/// sono permanenti e parlano di come sei; l'ESPRESSIONE e' di questo momento e
/// parla di come sei adesso. Sono due letture diverse, si presentano separate e
/// **non si mescolano mai in una frase sola**. Questo file conosce solo la
/// seconda: non sa niente dei tratti e non puo' contaminarli.
///
/// **IL CONFINE CHE NON SI SUPERA.** Non si diagnostica niente. Non si dice a
/// nessuno che e' triste, ansioso o depresso. Si legge **cio' che il volto sta
/// facendo** e lo si restituisce come uno specchio, non come un verdetto: *le
/// tue sopracciglia sono alzate* e' un'osservazione, *sei preoccupato* e' una
/// diagnosi travestita.
///
/// **PERCHE' LE FRASI NON NOMINANO MAI UN'EMOZIONE.** Un volto teso puo' essere
/// un volto concentrato, uno stanco, uno che sta ridendo trattenendosi. Il
/// motore misura muscoli, non stati d'animo, e questa distinzione e' l'unica
/// cosa che separa una funzione seria da un oroscopo con la fotocamera.
class EspressioneDellIstante {
  const EspressioneDellIstante._();

  /// **LE SOGLIE, DICHIARATE E PROVVISORIE.** I coefficienti vanno da zero a
  /// uno. Nessuno li ha tarati su volti veri: valgono la stessa avvertenza
  /// delle soglie della scansione, e si sostituiscono con misure.
  ///
  /// Trenta centesimi e' il punto sotto il quale un muscolo si considera a
  /// riposo: sotto quella soglia i coefficienti oscillano da soli anche su un
  /// volto immobile.
  static const double soglia = 0.30;

  /// La soglia alta, oltre la quale il gesto e' netto e non un accenno.
  static const double sogliaNetta = 0.55;

  /// Legge cosa il volto sta facendo adesso.
  ///
  /// Restituisce **al massimo due segni**, e non e' un limite tecnico: un
  /// responso che elenca sei cose non e' un responso, e la persona non
  /// riconosce se stessa in un inventario.
  static List<SegnoDelVolto> leggi(Map<FaceBlendshape, double> c) {
    if (c.isEmpty) return const [];
    final trovati = <SegnoDelVolto>[];
    for (final s in SegnoDelVolto.values) {
      final valore = s.quanto(c);
      if (valore >= soglia) trovati.add(s);
    }
    trovati.sort((a, b) => b.quanto(c).compareTo(a.quanto(c)));
    return trovati.take(2).toList();
  }

  /// Quanto un segno e' netto, per la scena che ci reagisce.
  static double intensita(Map<FaceBlendshape, double> c, SegnoDelVolto s) =>
      s.quanto(c);
}

/// Un segno che il volto sta facendo adesso.
///
/// **Ogni voce dice quali coefficienti la compongono**, cosi' chi legge il
/// codice puo' rifare il conto, ed e' la stessa disciplina della tavola dei
/// tratti: un segno che non si sa scrivere in questa forma non entra.
enum SegnoDelVolto {
  /// Sopracciglia alzate: `browInnerUp`, `browOuterUpLeft`, `browOuterUpRight`.
  sopraccigliaAlte(
    'Le sopracciglia sono alzate',
    'Qualcosa ti ha appena aperto: è il viso di chi sta guardando una cosa '
        'che non aveva previsto.',
    [
      FaceBlendshape.browInnerUp,
      FaceBlendshape.browOuterUpLeft,
      FaceBlendshape.browOuterUpRight,
    ],
  ),

  /// Sopracciglia abbassate: `browDownLeft`, `browDownRight`.
  sopraccigliaBasse(
    'Le sopracciglia sono raccolte',
    'Il tuo viso sta mettendo a fuoco: è la faccia di chi sta stringendo lo '
        'sguardo su una cosa sola.',
    [FaceBlendshape.browDownLeft, FaceBlendshape.browDownRight],
  ),

  /// Angoli della bocca sollevati: `mouthSmileLeft`, `mouthSmileRight`.
  boccaSollevata(
    'Gli angoli della bocca salgono',
    'C’è un sorriso che sta arrivando, o che se ne sta andando: in questo '
        'istante è a metà strada.',
    [FaceBlendshape.mouthSmileLeft, FaceBlendshape.mouthSmileRight],
  ),

  /// Angoli della bocca abbassati: `mouthFrownLeft`, `mouthFrownRight`.
  boccaAbbassata(
    'Gli angoli della bocca scendono',
    'La tua bocca sta tenendo qualcosa: non è detto che sia peso, spesso è '
        'concentrazione che non vuole essere interrotta.',
    [FaceBlendshape.mouthFrownLeft, FaceBlendshape.mouthFrownRight],
  ),

  /// Occhi socchiusi: `eyeSquintLeft`, `eyeSquintRight`.
  occhiSocchiusi(
    'Gli occhi sono socchiusi',
    'Stai filtrando: il viso lascia entrare meno di quanto potrebbe, per '
        'guardare meglio quel poco.',
    [FaceBlendshape.eyeSquintLeft, FaceBlendshape.eyeSquintRight],
  ),

  /// Occhi spalancati: `eyeWideLeft`, `eyeWideRight`.
  occhiSpalancati(
    'Gli occhi sono spalancati',
    'Stai lasciando entrare tutto: è lo sguardo di chi non vuole '
        'perdersi niente.',
    [FaceBlendshape.eyeWideLeft, FaceBlendshape.eyeWideRight],
  ),

  /// Mascella serrata: `jawForward`, `mouthPressLeft`, `mouthPressRight`.
  mascellaTesa(
    'La mascella è raccolta',
    'C’è una tensione che tieni tu, non che subisci: il viso di chi sta '
        'reggendo qualcosa con le proprie forze.',
    [
      FaceBlendshape.jawForward,
      FaceBlendshape.mouthPressLeft,
      FaceBlendshape.mouthPressRight,
    ],
  );

  const SegnoDelVolto(this.osservazione, this.specchio, this.coefficienti);

  /// **CIO' CHE IL VOLTO STA FACENDO, detto come un fatto.** Questa riga
  /// descrive un muscolo, non una persona.
  final String osservazione;

  /// La restituzione nella voce di Aura: **uno specchio, non un verdetto**.
  /// Nessuna di queste frasi nomina un'emozione, e nessuna dice a chi legge
  /// come si sente.
  final String specchio;

  /// I coefficienti che compongono questo segno.
  final List<FaceBlendshape> coefficienti;

  /// Quanto questo segno e' presente: la media dei suoi coefficienti.
  ///
  /// **La media e non il massimo**, e la differenza conta: un solo
  /// coefficiente alto puo' essere un artefatto del modello su un lato del
  /// viso, mentre la media pretende che il gesto sia sul volto intero.
  double quanto(Map<FaceBlendshape, double> c) {
    if (coefficienti.isEmpty) return 0;
    var somma = 0.0;
    for (final k in coefficienti) {
      somma += c[k] ?? 0;
    }
    return somma / coefficienti.length;
  }
}
