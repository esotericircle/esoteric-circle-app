import '../chat/altre_voci.dart';
import '../chat/testo_del_responso.dart';
import '../maestro/maestro.dart';
import '../maestro/voce_del_maestro.dart';
import '../tempo/confine_del_giorno.dart';

/// L'ECO: la chiusura del Maestro resa PERSISTENTE.
///
/// **Non e' una cosa in piu'.** Ogni Maestro chiude gia' a modo suo: Medora con
/// una direzione nel tempo, Aura con un gesto del corpo, Caligo con un segno da
/// portare. L'Eco e' quella chiusura che non finisce quando chiudi l'app: UNA
/// parola sola, che il Maestro ha nominato lui, si posa nel Cerchio e resta li'
/// fino a mezzanotte.
///
/// **Nessuna seconda chiamata all'AI, nessun costo in piu'.** La parola non si
/// chiede a Gemini: si RICONOSCE in cio' che il Maestro ha gia' detto.
class EcoDelMaestro {
  const EcoDelMaestro({
    required this.maestro,
    required this.parola,
    required this.chiusura,
    required this.domanda,
    required this.giorno,
  });

  /// Chi l'ha lasciata.
  final Maestro maestro;

  /// La parola da portare. Una sola.
  final String parola;

  /// La frase di chiusura da cui viene, per intero.
  ///
  /// Si conserva perche' il pannello "Da dove nasce questo dono" deve poter
  /// mostrare la riga vera invece di dire "viene da una chiusura" e basta: una
  /// provenienza che non si puo' leggere non e' una provenienza.
  final String chiusura;

  /// La domanda della conversazione da cui viene. Il giorno dopo la riga dice
  /// da dove viene, e "da quale conversazione" e' questa.
  final String domanda;

  /// Il giorno d'uso in cui si e' posata, dal confine di mezzanotte.
  final String giorno;

  /// Vero se l'Eco vale ancora a [adesso]. Dopo mezzanotte non vale piu'.
  bool valeA(DateTime adesso) => ConfineDelGiorno.eOggi(giorno, adesso);

  Map<String, Object?> aMappa() => {
        'maestro': maestro.id,
        'parola': parola,
        'chiusura': chiusura,
        'domanda': domanda,
        'giorno': giorno,
      };

  /// Rilegge un'Eco salvata. Torna null su qualunque forma inattesa: una
  /// preferenza corrotta non deve far crollare l'apertura dell'app.
  static EcoDelMaestro? daMappa(Map<String, Object?> m) {
    final maestro = Maestro.fromId(m['maestro'] as String?);
    final parola = m['parola']?.toString().trim() ?? '';
    final giorno = m['giorno']?.toString().trim() ?? '';
    if (maestro == null || parola.isEmpty || giorno.isEmpty) return null;
    return EcoDelMaestro(
      maestro: maestro,
      parola: parola,
      chiusura: m['chiusura']?.toString() ?? '',
      domanda: m['domanda']?.toString() ?? '',
      giorno: giorno,
    );
  }

  /// La riga che dice DA DOVE VIENE, il giorno dopo.
  ///
  /// **Non basta mostrare la parola.** Una parola che ricompare senza dire da
  /// dove viene e' magia inspiegata, ed e' esattamente cio' che questa casa non
  /// ammette. Qui si dicono le due cose che servono: quale Maestro, e quale
  /// conversazione.
  String get daDoveViene {
    final d = domanda.trim();
    if (d.isEmpty) return 'Te l\'ha lasciata ${maestro.displayName}.';
    return 'Te l\'ha lasciata ${maestro.displayName}, quando hai chiesto '
        '«$d».';
  }
}

/// COME NASCE L'ECO, e da che cosa.
///
/// Funzione pura: si prova senza rete, senza schermo e senza orologio di
/// sistema.
class NascitaDellEco {
  const NascitaDellEco._();

  /// L'Eco che nasce da questa risposta, oppure NULL.
  ///
  /// **La parola si cerca nella CHIUSURA, non in un secondo elenco.** La
  /// chiusura e' l'ultima frase della risposta, che la persona di ogni Maestro
  /// gli chiede gia' di mettere li': per Medora una direzione nel tempo, per
  /// Aura un gesto del corpo, per Caligo un segno da portare. Il riconoscimento
  /// passa per due dati che esistono gia' e che non sono stati scritti per
  /// l'Eco:
  ///
  /// 1. i **nomi noti** dell'app, cioe' rune, segni e arcani minori dai
  ///    cataloghi veri, gli stessi che la chat mette in oro;
  /// 2. il **lessico di firma** del Maestro, cioe' le parole sue che gli altri
  ///    due non usano, quelle che reggono il 98,3 per cento di attribuzione.
  ///
  /// **Se la chiusura non porta nessuna delle due, l'Eco non nasce.** Non si
  /// ripiega su una parola qualunque: una parola scelta a caso da portare per
  /// un giorno e' peggio di nessuna parola, ed e' la stessa regola per cui una
  /// battuta del consulto si salta invece di inventarla.
  static EcoDelMaestro? da({
    required Maestro maestro,
    required String risposta,
    required String domanda,
    required DateTime adesso,
  }) {
    final chiusura = AltreVoci.chiusuraDi(risposta).trim();
    if (chiusura.isEmpty) return null;
    final parola = parolaNella(chiusura, maestro);
    if (parola == null) return null;
    return EcoDelMaestro(
      maestro: maestro,
      parola: parola,
      chiusura: chiusura,
      domanda: domanda.trim(),
      giorno: ConfineDelGiorno.chiaveDi(adesso),
    );
  }

  /// La parola da portare dentro [chiusura], oppure null.
  ///
  /// Pubblica apposta: una prova la interroga su una frase sola, senza dover
  /// costruire una conversazione intera.
  static String? parolaNella(String chiusura, Maestro maestro) {
    // I nomi noti prima: un nome proprio come Laguz o Cancro e' una parola da
    // portare piu' forte di un sostantivo comune, e la persona la riconosce.
    for (final pezzo in TestoDelResponso.pezzi(chiusura)) {
      if (pezzo.inOro) return pezzo.testo;
    }
    // Poi il lessico di firma, cercato a parola intera e senza distinguere le
    // maiuscole: "Respiro" a inizio frase e "respiro" in mezzo sono la stessa
    // parola.
    final firma = VoceDelMaestro.di(maestro).lessicoDiFirma;
    for (final parola in _paroleDi(chiusura)) {
      for (final segno in firma) {
        if (parola.toLowerCase() == segno.toLowerCase()) return segno;
      }
    }
    return null;
  }

  /// Le parole di una frase, senza punteggiatura attorno.
  static List<String> _paroleDi(String frase) => frase
      .split(RegExp(r'[^\p{L}]+', unicode: true))
      .where((p) => p.isNotEmpty)
      .toList();
}
