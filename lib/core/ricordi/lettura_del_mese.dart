/// LA LETTURA IN PROSA DEL MESE. Ordine CG voce 11.
///
/// **Parole del fondatore, 31 agosto 2026**: "per la 6 la lettura e' a partire
/// dall'abbonamento a 9,90". L'abbonamento a 9,90 al mese e' l'Iniziato, cioe'
/// il Tier 1, e questa voce SUPERA la riga della matrice che metteva la
/// lettura AI dal Tier 2.
///
/// **E' l'unica prosa generata di tutta la funzione.** I quattro livelli della
/// timeline sono conti e fatti; questa riga, in cima al livello MESE, e' un
/// testo scritto dal Maestro dominante di quel mese.
///
/// **SI SCRIVE SUI RIASSUNTI, MAI SUI TESTI PIENI**, e la ragione e' un conto.
/// Un mese di un Adepto a meta' tetto sono millecinquecento voci: mandarne i
/// testi pieni costerebbe un ordine di grandezza in piu' senza dire niente di
/// piu', perche' cio' che una lettura del mese deve sapere e' quante volte hai
/// cercato Caligo e in quali giorni, non ogni parola che vi siete detti.
///
/// **UNA CHIAMATA AL MESE E PER PERSONA, non una per apertura.** La lettura si
/// custodisce col mese a cui appartiene: riaprire la schermata rilegge, non
/// rigenera. Una prova conta le chiamate in un mese simulato.
///
/// **Il runtime resta Google**, cioe' Vertex e Gemini, mai le API Anthropic:
/// e' la regola d'oro dello stack e non si tocca.
library;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../entitlement/tier.dart';
import 'riassunti_del_tempo.dart';

/// Chi scrive la lettura. Iniettabile, cosi' le prove contano le chiamate
/// senza toccare nessun modello.
abstract class PennaDelMese {
  const PennaDelMese();

  /// Scrive la lettura di un mese dai suoi riassunti. Nulla quando non ci
  /// riesce: in quel caso la riga non compare, e non compare nemmeno un
  /// messaggio di errore, perche' una lettura mancata non e' un guasto che la
  /// persona debba gestire.
  Future<String?> scrivi({
    required String mese,
    required RiassuntoDelTempo riassunto,
    required List<RiassuntoDelTempo> settimane,
    required String maestro,
  });
}

/// La penna spenta: non scrive niente e non chiama nessuno.
class PennaSpentaDelMese extends PennaDelMese {
  const PennaSpentaDelMese();

  @override
  Future<String?> scrivi({
    required String mese,
    required RiassuntoDelTempo riassunto,
    required List<RiassuntoDelTempo> settimane,
    required String maestro,
  }) async =>
      null;
}

/// La lettura del mese, col suo cancello e la sua custodia.
class LetturaDelMese extends ChangeNotifier {
  LetturaDelMese({
    PennaDelMese penna = const PennaSpentaDelMese(),
  }) : _penna = penna;

  final PennaDelMese _penna;

  /// **IL PIANO DA CUI LA LETTURA COMPARE.**
  ///
  /// Tier 1, cioe' l'Iniziato, che e' l'abbonamento a 9,90 al mese. La riga
  /// della matrice che metteva l'AI dal Tier 2 e' superata da questa voce, per
  /// decisione del fondatore del 31 agosto 2026.
  static const Tier pianoMinimo = Tier.tier1;

  /// La chiave sta sotto `ricordi.`, gia' in `CioCheETuo`: una lettura del tuo
  /// mese e' tua, e la cancellazione la porta via con tutto il resto.
  static const String _chiave = 'ricordi.lettureDelMese';

  final Map<String, String> _scritte = {};
  bool _caricato = false;

  /// **QUANTE VOLTE SI E' CHIAMATO IL MODELLO**, per le misure.
  int chiamateAlModello = 0;

  /// Vero se questo piano vede la lettura.
  static bool laVede(Tier tier) => tier.level >= pianoMinimo.level;

  String? gia(String mese) => _scritte[mese];

  Future<void> carica() async {
    if (_caricato) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final scritto = prefs.getString(_chiave);
      if (scritto != null) {
        final letto = jsonDecode(scritto);
        if (letto is Map) {
          for (final v in letto.entries) {
            _scritte['${v.key}'] = '${v.value}';
          }
        }
      }
    } catch (errore) {
      debugPrint('Lettura del mese: non si rilegge. $errore');
    }
    _caricato = true;
    notifyListeners();
  }

  /// LA LETTURA DI UN MESE, scritta una volta sola.
  ///
  /// Torna nulla quando il piano non la vede, oppure quando il mese e' vuoto:
  /// **una lettura su un mese in cui non e' successo niente sarebbe prosa su
  /// niente**, cioe' esattamente cio' che l'ordine vieta ai riassunti.
  Future<String?> per({
    required String mese,
    required Tier tier,
    required RiassuntoDelTempo riassunto,
    required List<RiassuntoDelTempo> settimane,
  }) async {
    if (!laVede(tier)) return null;
    if (riassunto.vuoto) return null;
    final gia = _scritte[mese];
    if (gia != null) return gia;

    final maestro = riassunto.maestroDominante;
    if (maestro == null) {
      // **SENZA UN MAESTRO DOMINANTE NON SI SCRIVE**, e non e' una rinuncia:
      // l'ordine dice che la lettura la scrive il Maestro dominante di quel
      // mese. In pareggio quel Maestro non c'e', e sceglierne uno a caso
      // vorrebbe dire far parlare qualcuno al posto di un altro.
      return null;
    }

    final scritta = await _penna.scrivi(
      mese: mese,
      riassunto: riassunto,
      settimane: settimane,
      maestro: maestro,
    );
    chiamateAlModello++;
    if (scritta == null || scritta.trim().isEmpty) return null;
    _scritte[mese] = scritta;
    notifyListeners();
    await _salva();
    return scritta;
  }

  Future<void> _salva() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_chiave, jsonEncode(_scritte));
    } catch (errore) {
      debugPrint('Lettura del mese: non si salva. $errore');
    }
  }

  void dimentica() {
    _scritte.clear();
    _caricato = false;
    chiamateAlModello = 0;
    notifyListeners();
  }

  /// **L'INVITO PER CHI NON HA IL PIANO.**
  ///
  /// Non un testo in grigio ne' un lucchetto sopra la prosa: chi non paga non
  /// deve vedere cio' che gli manca scritto a meta'. Vede una riga che dice
  /// cosa otterrebbe, che e' la regola di casa sugli inviti.
  ///
  /// **Testo provvisorio**: le parole che la persona legge le approva il
  /// fondatore.
  static const String invito =
      'Con l\'Iniziato, ogni mese il tuo Maestro dominante ti racconta dove '
      'sei stato e cosa è cambiato.';
}
