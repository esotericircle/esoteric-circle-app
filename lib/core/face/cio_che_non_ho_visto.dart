import 'face_classifier.dart';
import 'face_trait.dart';

/// **CIO' CHE NON HO VISTO NON LO DESCRIVO, E LO DICO.**
/// Ordine CX voci 01, 03 e 08, 8 settembre 2026.
///
/// **Parole del fondatore**: *"ho fatto la scansione con cappellino con
/// sopracciglia e fronte occultate... il responso mi descriveva fronte e
/// sopracciglia anche se nascoste"*, e poi: *"nel caso ci siano ugualmente, il
/// responso dovrebbe indicarlo"*.
///
/// **PERCHE' IL MODELLO NON PUO' DIRLO DA SOLO.** MediaPipe posa i suoi punti
/// anche sulle zone coperte: **deduce** la forma del volto, non si rifiuta
/// quando non vede. Sotto un cappello i punti della fronte ci sono lo stesso,
/// plausibili e falsi, e `FaceMeshLandmark` porta solo `x`, `y` e `z`, senza
/// nessun campo di visibilita'. Verificato nel pacchetto prima di progettare
/// qualunque cosa: **la distinzione fra visto e dedotto non si ottiene
/// interrogando la mesh.**
///
/// **ALLORA SI MISURA DALL'EFFETTO, e i numeri veri lo permettono.** Un
/// cappello che copre la fronte non lascia i punti dove erano: li spinge in
/// basso, e il rapporto della fronte crolla. Dalle sei misure prese sul
/// dispositivo di collaudo l'8 settembre 2026:
///
/// | | fronte | sopracciglia |
/// | --- | ---: | ---: |
/// | quattro volti scoperti | 0,1424 - 0,1804 | 0,2100 - 0,2434 |
/// | due volti col cappello | 0,1297 e 0,1165 | 0,1884 e 0,1970 |
///
/// **Le due nuvole non si toccano**, e la soglia sta nel mezzo. Non e' una
/// certezza: e' un sospetto misurato, e come tale si dichiara a chi legge.
///
/// **COSA RESTA FUORI, dichiarato invece che finto.**
/// - **Gli occhiali non si rilevano.** Nelle misure prese la persona con gli
///   occhiali li portava in tutte e tre le scansioni: senza una sua immagine
///   senza occhiali non esiste il confronto che separa le due nuvole, e
///   inventare una soglia su zero dati sarebbe la stessa cosa che ha reso il
///   responso uguale per tutti.
/// - **Piercing e orecchini nemmeno.** Il fondatore li ha nominati con un
///   *"magari"*, e non nascondono nessun tratto: senza un dato non si
///   costruisce un rilevamento, si costruisce una finzione.
class CioCheNonHoVisto {
  const CioCheNonHoVisto._();

  /// Sotto questo rapporto la fronte e' quasi certamente coperta. Sta fra il
  /// piu' basso dei volti scoperti (0,1424) e il piu' alto di quelli col
  /// cappello (0,1297).
  static const double fronteCoperta = 0.136;

  /// Lo stesso per le sopracciglia, fra 0,2100 scoperte e 0,1970 coperte.
  static const double sopraccigliaCoperte = 0.2035;

  /// **QUALI ZONE NON SI SONO VISTE**, dalla lettura appena fatta.
  ///
  /// Vuoto vuol dire che non c'e' nessun sospetto, non che sia tutto certo:
  /// e' la differenza fra *"non ho motivo di dubitare"* e *"garantisco"*, e
  /// questa funzione dice la prima.
  static Set<FaceCategory> quali(FaceReading lettura) {
    final coperte = <FaceCategory>{};
    for (final l in lettura.letture) {
      final r = l.rapporto;
      if (r == null || !r.isFinite) continue;
      if (l.tratto.categoria == FaceCategory.fronte && r < fronteCoperta) {
        coperte.add(FaceCategory.fronte);
      }
      if (l.tratto.categoria == FaceCategory.sopracciglia &&
          r < sopraccigliaCoperte) {
        coperte.add(FaceCategory.sopracciglia);
      }
    }
    return coperte;
  }

  /// **LA RIGA CHE LO DICE A CHI LEGGE**, o nulla se non c'e' niente da dire.
  ///
  /// **Non accusa e non ordina.** Chi si e' scansionato col cappello non ha
  /// sbagliato: gli si dice cosa manca al responso e come averlo intero, e la
  /// scelta resta sua.
  static String? laRiga(Set<FaceCategory> coperte) {
    if (coperte.isEmpty) return null;
    final nomi = <String>[
      if (coperte.contains(FaceCategory.fronte)) 'la fronte',
      if (coperte.contains(FaceCategory.sopracciglia)) 'le sopracciglia',
    ];
    if (nomi.isEmpty) return null;
    final elenco = nomi.length == 1 ? nomi.first : '${nomi.first} e ${nomi.last}';
    return 'Non ho potuto vedere $elenco: qualcosa le copriva. Quella parte '
        'del responso manca, e non la invento. Se togli quello che le nasconde '
        'e rifai la lettura, te la leggo anche.';
  }

  /// **LA LETTURA SENZA CIO' CHE NON SI E' VISTO.**
  ///
  /// E' la meta' che conta davvero: dire *"non ho visto la fronte"* e poi
  /// descriverla lo stesso, due riquadri piu' sotto, sarebbe peggio che
  /// tacere. Qui le categorie coperte escono dal responso.
  static FaceReading senzaLeCoperte(
      FaceReading lettura, Set<FaceCategory> coperte) {
    if (coperte.isEmpty) return lettura;
    final restano = [
      for (final l in lettura.letture)
        if (!coperte.contains(l.tratto.categoria)) l,
    ];
    // **MAI UN RESPONSO VUOTO.** Se per assurdo restasse niente, si tiene la
    // lettura intera: un responso senza righe sarebbe un vicolo cieco, che e'
    // la cosa che questa casa vieta prima di ogni altra.
    if (restano.isEmpty) return lettura;
    return FaceReading(letture: restano);
  }
}
