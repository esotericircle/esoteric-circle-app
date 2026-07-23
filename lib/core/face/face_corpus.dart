import 'face_trait.dart';

/// Le letture dei tratti del volto, la tradizione con la nostra curatela.
///
/// Ogni variante ha la sua frase, fedele alla Personologia di Edward Vincent
/// Jones nella divulgazione di Naomi Tickle. La geometria la misura il
/// classificatore; qui ci sono solo i significati, in italiano, senza inventare
/// tratti nuovi. La sintesi del responso si costruisce da qui in modo
/// deterministico, intrecciando i tratti piu' marcati: nessuna AI, nessun
/// generatore a runtime.
class FaceCorpus {
  const FaceCorpus._();

  /// La frase di lettura di ciascuna variante, una riga per il responso.
  static const Map<FaceTrait, String> _frasi = {
    FaceTrait.voltoTondo:
        'Sei socievole e caloroso, attento agli altri e a metterli a proprio agio.',
    FaceTrait.voltoQuadrato:
        'Hai forza interiore e determinazione, con un piglio pratico che va al sodo.',
    FaceTrait.voltoOvale:
        'La tua mente è analitica e riflessiva, diplomatica nel tenere insieme le parti.',
    FaceTrait.voltoTriangolare:
        'Vivi di idee e immaginazione, con una vena creativa che cerca il nuovo.',
    FaceTrait.fronteSfuggente:
        'Pensi in fretta e punti dritto al risultato, senza girarci intorno.',
    FaceTrait.fronteVerticale:
        'Sei metodico: analizzi prima di decidere e costruisci un passo alla volta.',
    FaceTrait.sopraccigliaDritte:
        'Ragioni per logica sui fatti, ti fidi di quello che si può verificare.',
    FaceTrait.sopraccigliaCurve:
        'Il tuo pensiero va prima alle persone, a come stanno e a cosa sentono.',
    FaceTrait.sopraccigliaAngolo:
        'Hai una mente organizzatrice, che mette ordine e struttura le cose.',
    FaceTrait.occhiRavvicinati:
        'Hai una grande messa a fuoco, sensibile ai tempi e poco indulgente con gli errori.',
    FaceTrait.occhiDistanziati:
        'Guardi largo, con una visione ampia e tollerante che non si fa incastrare.',
    FaceTrait.occhiGrandi:
        'Sei espressivo e aperto alle emozioni, che leggi e lasci passare.',
    FaceTrait.occhiRaccolti:
        'Sei concentrato e intuitivo, con uno sguardo che va in profondità.',
    FaceTrait.nasoLungo:
        'Pianifichi e valuti, misuri le conseguenze prima di muoverti.',
    FaceTrait.nasoCorto:
        'Vivi il presente e agisci, senza rimandare quello che si può fare adesso.',
    FaceTrait.labbraPiene:
        'Sei generoso nel dare e nel parlare, caldo nel condividere.',
    FaceTrait.labbraSottili:
        'Sei essenziale e misurato, scegli poche parole e le scegli bene.',
    FaceTrait.boccaLarga:
        'Sei generoso e aperto, comunichi con slancio e allarghi il cerchio.',
    FaceTrait.boccaPiccola:
        'Sei raccolto, tieni per te quello che conta finché non è il momento.',
    FaceTrait.mentoAmpio:
        'Sei costante e fermo, tieni la rotta anche quando intorno cambia tutto.',
    FaceTrait.mentoAPunta:
        'Sei rapido e adattabile, cambi passo appena serve senza irrigidirti.',
    FaceTrait.mascellaLarga:
        'Hai una volontà salda e tenace, che non molla quando ha deciso.',
    FaceTrait.mascellaStretta:
        'Sei flessibile, ti pieghi senza spezzarti e trovi la via che passa.',
    FaceTrait.zigomiAlti:
        'Ami la sfida e l\'avventura, cerchi il rischio che ti fa sentire vivo.',
    FaceTrait.zigomiMorbidi:
        'Cerchi calore più che conquista, il legame prima del traguardo.',
  };

  /// La frase di lettura di un tratto. C'e' sempre, per ogni variante.
  static String frase(FaceTrait t) => _frasi[t]!;

  /// La sintesi calda del responso, intrecciata dai tratti piu' marcati, in
  /// ordine di marcatezza. Deterministica: stessi tratti, stesso testo. Prende
  /// fino ai primi quattro, cosi' restano quattro o cinque righe.
  static String sintesi(List<FaceTrait> marcati) {
    if (marcati.isEmpty) return '';
    final b = StringBuffer('Il tuo volto ti racconta a più voci. ');
    b.write(frase(marcati.first));
    for (var i = 1; i < marcati.length && i < 4; i++) {
      b.write(' ');
      b.write(frase(marcati[i]));
    }
    b.write(
        ' Tratti diversi che insieme disegnano il tuo modo di stare al mondo.');
    return b.toString();
  }

  /// Il testo del pannello "Fonti e metodo", che dichiara la tradizione e i suoi
  /// limiti. Non e' una diagnosi: e' lettura simbolica su base tradizionale.
  static const String fontiEMetodo =
      'La Costellazione del Viso poggia sulla Personologia, la fisiognomica '
      'sistematica di Edward Vincent Jones, giudice e studioso, resa popolare '
      'da Naomi Tickle. La geometria del volto si misura davvero dai contorni '
      'rilevati sul dispositivo: le proporzioni, le distanze, gli angoli. I '
      'significati sono la tradizione con la nostra curatela, non un verdetto. '
      'Non è una diagnosi né una previsione: è una lettura simbolica, uno '
      'specchio per guardarti con curiosità. Le tue scelte restano tue. Nessuna '
      'immagine lascia il dispositivo, nessuna foto viene salvata oltre l\'uso '
      'del momento.';
}
