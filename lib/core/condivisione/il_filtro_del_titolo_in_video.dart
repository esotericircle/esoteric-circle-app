/// **IL FILTRO CHE SCRIVE IL TITOLO SOPRA IL VIDEO, PURO.** Ordine FZ voce
/// FZ.08, 17 ottobre 2026.
///
/// *"La card della rivelazione si condivide anche come video verticale: il
/// centro del video dell'animale (il verso), con sopra il titolo di oggi
/// ('mi ha trovato' e il nome dell'animale su due righe) e la data,
/// social-story-ready."*
///
/// Costruisce la stringa del filtro `drawtext` di FFmpeg, senza mai toccare
/// FFmpeg: una guardia la percorre carattere per carattere, cosa che non si
/// potrebbe fare contro un video vero. Chi esegue il filtro vive in
/// `condividi_la_rivelazione_in_video.dart`.
abstract final class IlFiltroDelTitoloInVideo {
  /// **L'ESCAPE DI DRAWTEXT.** Il filtro di FFmpeg legge `:` come separatore
  /// di parametro, `'` come bordo di stringa e `\` come fuga: senza
  /// scapparli, un nome con l'apostrofo (*"l'Aquila"*) romperebbe il filtro
  /// intero, non solo il testo. L'ordine delle sostituzioni conta: la fuga
  /// (`\`) si scappa prima di ogni carattere che la usa, o si scapperebbe
  /// due volte.
  static String escape(String testo) => testo
      .replaceAll('\\', '\\\\')
      .replaceAll(':', '\\:')
      .replaceAll("'", "\\'")
      .replaceAll('%', '\\%');

  /// **UN PEZZO DEL FILTRO, UNA RIGA DI TESTO.** [y] in punti dall'alto del
  /// video (1080 per 1920, come ogni pezzo del Viaggio); [misura] la
  /// grandezza del carattere.
  static String _rigaDiTesto({
    required String testo,
    required String percorsoDelFont,
    required int misura,
    required int y,
    required String colore,
  }) =>
      "drawtext=fontfile='$percorsoDelFont':text='${escape(testo)}':"
      "fontsize=$misura:fontcolor=$colore:x=(w-text_w)/2:y=$y:"
      'box=0:borderw=2:bordercolor=black@0.5';

  /// **IL FILTRO INTERO**, le righe in catena con una virgola: titolo in due
  /// righe, grande e dorato, e la data piu' piccola e piu' chiara, in basso
  /// sotto le due righe del titolo. Le misure sono frazioni di un video
  /// 1080 per 1920 (lo stesso di ogni pezzo del Viaggio), perche' la
  /// guardia le pretenda vere senza decodificare un fotogramma.
  static String costruisci({
    required String percorsoDelFont,
    required String rigaUno,
    required String rigaDue,
    required String data,
  }) {
    const oro = '0xF6E7C0';
    const oroSoft = '0xD6A868';
    return [
      _rigaDiTesto(
          testo: rigaUno,
          percorsoDelFont: percorsoDelFont,
          misura: 64,
          y: 140,
          colore: oroSoft),
      _rigaDiTesto(
          testo: rigaDue,
          percorsoDelFont: percorsoDelFont,
          misura: 88,
          y: 220,
          colore: oro),
      _rigaDiTesto(
          testo: data,
          percorsoDelFont: percorsoDelFont,
          misura: 40,
          y: 340,
          colore: oroSoft),
    ].join(',');
  }
}
