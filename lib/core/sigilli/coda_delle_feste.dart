import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'sentieri.dart';

/// LA CODA DELLE FESTE, ordine P voce 34.
///
/// **Perche' esiste.** Un traguardo puo' accendersi in un momento in cui
/// nessuna schermata puo' ospitare la sovrimpressione: l'app appena aperta,
/// una rotta in transizione, un gesto compiuto mentre si esce da una scena. In
/// quel caso la vecchia regia usciva in silenzio sul controllo di
/// `context.mounted`, e la festa non arrivava mai. **Un Sigillo che si accende
/// in silenzio e' un premio che non esiste.**
///
/// **Perche' sopravvive alla chiusura.** Se la coda vivesse in memoria, un
/// traguardo maturato un attimo prima che l'app venga chiusa sparirebbe con
/// lei, e la persona non saprebbe mai di averlo preso. Qui la coda sta su
/// disco: al primo momento utile, anche domani, la festa arriva.
///
/// **Cosa NON e'.** Non e' il registro dei Sigilli: quello e'
/// `DiarioDelCammino`, e il Sigillo si accende li' comunque, subito, sempre.
/// Questa coda ricorda soltanto quali feste devono ancora essere mostrate.
class CodaDelleFeste extends ChangeNotifier {
  CodaDelleFeste();

  static const String _chiave = 'cammino.feste_in_attesa';

  final List<String> _inAttesa = [];

  /// Gli identificativi dei traguardi che attendono la loro festa, in ordine
  /// di arrivo: si celebra nell'ordine in cui il cammino li ha accesi.
  List<String> get inAttesa => List.unmodifiable(_inAttesa);

  bool get vuota => _inAttesa.isEmpty;

  Future<void> carica() async {
    final disco = await SharedPreferences.getInstance();
    _inAttesa
      ..clear()
      ..addAll(disco.getStringList(_chiave) ?? const []);
    notifyListeners();
  }

  /// Mette una festa in attesa. Non si accoda due volte lo stesso traguardo:
  /// una festa ripetuta e' peggio di una festa mancata.
  Future<void> accoda(String idTraguardo) async {
    if (_inAttesa.contains(idTraguardo)) return;
    _inAttesa.add(idTraguardo);
    await _salva();
    notifyListeners();
  }

  /// **NESSUNO PRENDE PIU' LA CODA INTERA.** Ordine AU voce 06: una card
  /// celebra un solo traguardo, quindi chi celebra chiama `prendiLaProssima`.
  /// Questa resta perche' serve a svuotare la coda quando la si azzera, e
  /// perche' toglierla vorrebbe dire riscriverla il giorno che serve.
  /// Un identificativo che non esiste piu' si scarta, come sempre.
  Future<List<Traguardo>> prendiTutte() async {
    final id = List<String>.from(_inAttesa);
    _inAttesa.clear();
    await _salva();
    final trovati = <Traguardo>[
      for (final uno in id)
        if (_cerca(uno) != null) _cerca(uno)!,
    ];
    notifyListeners();
    return trovati;
  }

  /// Toglie la prima festa in attesa e la restituisce, gia' risolta nel suo
  /// traguardo. Nullo quando non c'e' niente da celebrare.
  Future<Traguardo?> prendiLaProssima() async {
    while (_inAttesa.isNotEmpty) {
      final id = _inAttesa.removeAt(0);
      await _salva();
      final traguardo = _cerca(id);
      // Un identificativo che non esiste piu' non blocca la coda: si scarta e
      // si va avanti, invece di riprovare la stessa festa per sempre.
      if (traguardo != null) {
        notifyListeners();
        return traguardo;
      }
    }
    notifyListeners();
    return null;
  }

  static Traguardo? _cerca(String id) {
    for (final traguardo in Sentieri.tuttiITraguardi) {
      if (traguardo.id == id) return traguardo;
    }
    return null;
  }

  Future<void> _salva() async {
    final disco = await SharedPreferences.getInstance();
    await disco.setStringList(_chiave, _inAttesa);
  }
}
