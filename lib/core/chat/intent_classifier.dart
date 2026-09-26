import '../maestro/maestro.dart';
import 'immersive_intents.dart';
import 'la_richiesta_di_un_arte.dart';

/// Classificatore d'intento leggero e deterministico, senza AI.
///
/// Trova l'arte di cui il testo parla con le parole chiave dell'allow-list del
/// Maestro, e poi **chiede al cancello se quella e' una richiesta**.
///
/// **LA PAROLA DA SOLA NON BASTA PIU'. Ordine EB voce 03, 21 settembre 2026.**
/// Qui bastava la presenza della parola, e la negazione pesava zero: *"non
/// voglio una stesa"* apriva la Stesa come *"fammi una stesa"*. La lettura
/// della forma vive in `LaRichiestaDiUnArte`, che dice anche **perche' il
/// cancello adesso puo' essere stretto**: un cancello che non scatta non
/// lascia piu' la persona senza risposta.
class IntentClassifier {
  const IntentClassifier();

  /// L'intento immersivo da aprire, oppure null se al testo si risponde.
  ImmersiveIntent? classify(Maestro maestro, String text) {
    final trovato = riconosci(maestro, text);
    if (trovato == null) return null;
    return trovato.modo == ModoDiNominareUnArte.richiesta
        ? trovato.intento
        : null;
  }

  /// L'arte nominata dal testo e **in che modo**, anche quando non si apre.
  ///
  /// Serve a chi deve sapere che un'arte e' stata rifiutata per non
  /// riproporgliela piu' (voce 05): il rifiuto va riconosciuto proprio quando
  /// il pulsante non compare.
  ArteNominata? riconosci(Maestro maestro, String text) {
    final norm = LaRichiestaDiUnArte.normalizza(text);
    if (norm.isEmpty) return null;

    ImmersiveIntent? migliore;
    var chiaveMigliore = '';
    for (final intent in ImmersiveIntents.forMaestro(maestro)) {
      for (final keyword in intent.keywords) {
        final k = LaRichiestaDiUnArte.normalizza(keyword);
        if (k.isEmpty) continue;
        if (LaRichiestaDiUnArte.contieneLaParola(norm, k) &&
            k.length > chiaveMigliore.length) {
          migliore = intent;
          chiaveMigliore = k;
        }
      }
    }
    if (migliore == null) return null;
    return ArteNominata(
      intento: migliore,
      parolaChiave: chiaveMigliore,
      modo: LaRichiestaDiUnArte.modoDi(text, chiaveMigliore),
    );
  }
}

/// Un'arte nominata da un testo, con la parola che l'ha fatta riconoscere e il
/// modo in cui e' stata nominata.
class ArteNominata {
  const ArteNominata({
    required this.intento,
    required this.parolaChiave,
    required this.modo,
  });

  final ImmersiveIntent intento;
  final String parolaChiave;
  final ModoDiNominareUnArte modo;
}
