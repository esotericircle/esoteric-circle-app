/// LO SCRIGNO DEI RESPONSI CUSTODITI. Ordine CG voce 06.
///
/// **Un magazzino solo, e due strade che ci portano.** Il gesto Custodisci
/// sotto il responso, e la custodia automatica quando una condivisione AVVIENE
/// davvero. Due magazzini per la stessa cosa sarebbero la famiglia di difetti
/// piu' numerosa di questo progetto, e la griglia delle Carte della voce CG.07
/// legge da qui e da nessun altro posto.
///
/// **Perche' la condivisione custodisce da sola.** Parole del fondatore:
/// "se uno condivide sui social o invia la card a una persona o anche a se
/// stesso, si tratta cmq di una custodia". Condividere e' gia' la
/// dichiarazione piu' forte che una persona possa fare su un contenuto, quindi
/// chiederle un secondo tocco per confermarla sarebbe chiederle di ripetersi.
///
/// **Solo se la condivisione E' AVVENUTA.** Un foglio aperto e poi chiuso non
/// custodisce niente: `PortaDellaCondivisione.avvenuta` distingue le due cose
/// da sempre, e questa voce si appoggia a quella distinzione invece di
/// rifarla.
///
/// **I CUSTODITI NON SCADONO.** Le scadenze del server e di
/// `scadenze_del_telefono.dart` non li toccano: sono decine e non migliaia,
/// quindi non pesano, e sono esattamente cio' che la persona ha dichiarato di
/// voler tenere. Una prova pretende che nessuna scadenza li nomini.
library;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ricordo_custodito.dart';

/// Chi porta i custoditi al server.
abstract class PortaDelloScrigno {
  const PortaDelloScrigno();

  Future<bool> custodisci(RicordoCustodito ricordo);

  Future<List<RicordoCustodito>> tutti();

  Future<bool> lascia(String chiave);
}

/// La porta spenta, per le prove e per chi non ha rete.
class PortaSpentaDelloScrigno extends PortaDelloScrigno {
  const PortaSpentaDelloScrigno();

  @override
  Future<bool> custodisci(RicordoCustodito ricordo) async => false;

  @override
  Future<List<RicordoCustodito>> tutti() async => const [];

  @override
  Future<bool> lascia(String chiave) async => false;
}

class ScrignoDeiCustoditi extends ChangeNotifier {
  ScrignoDeiCustoditi(
      {PortaDelloScrigno porta = const PortaSpentaDelloScrigno()})
      : _porta = porta;

  final PortaDelloScrigno _porta;

  /// La chiave sta sotto il prefisso `ricordi.`, che e' gia' in `CioCheETuo`:
  /// un custodito e' tuo, e la cancellazione lo porta via con tutto il resto.
  static const String _chiave = 'ricordi.custoditi';

  final Map<String, RicordoCustodito> _dentro = {};
  bool _caricato = false;

  bool get caricato => _caricato;

  /// I custoditi, dal piu' recente al piu' vecchio.
  List<RicordoCustodito> get tutti {
    final righe = _dentro.values.toList()
      ..sort((a, b) => b.quando.compareTo(a.quando));
    return List.unmodifiable(righe);
  }

  int get quanti => _dentro.length;

  bool contiene(String chiave) => _dentro.containsKey(chiave);

  RicordoCustodito? di(String chiave) => _dentro[chiave];

  /// I custoditi di una sola arte.
  List<RicordoCustodito> dellArte(String arte) =>
      tutti.where((r) => r.arte == arte).toList(growable: false);

  Future<void> carica() async {
    if (_caricato) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final scritto = prefs.getString(_chiave);
      if (scritto != null) {
        final letto = jsonDecode(scritto);
        if (letto is List) {
          for (final voce in letto) {
            final r = RicordoCustodito.daMappa(voce);
            if (r != null) _dentro[r.chiave] = r;
          }
        }
      }
    } catch (errore) {
      debugPrint('Scrigno: i custoditi non si leggono. $errore');
    }
    _caricato = true;
    notifyListeners();
  }

  /// **CUSTODISCE, ed e' l'unica porta.**
  ///
  /// Torna vero se il responso e' entrato adesso, falso se c'era gia'. Il
  /// falso non e' un errore: e' il caso della persona che custodisce col gesto
  /// e poi condivide lo stesso responso, e la chiave comune impedisce che
  /// nella griglia compaiano due carte identiche.
  Future<bool> custodisci(RicordoCustodito ricordo) async {
    if (_dentro.containsKey(ricordo.chiave)) return false;
    _dentro[ricordo.chiave] = ricordo;
    notifyListeners();
    await _salva();
    await _porta.custodisci(ricordo);
    return true;
  }

  /// Lascia andare un custodito, quando la persona lo chiede.
  Future<void> lascia(String chiave) async {
    if (_dentro.remove(chiave) == null) return;
    notifyListeners();
    await _salva();
    await _porta.lascia(chiave);
  }

  /// Rilegge dal server e fonde con quello che c'e'.
  ///
  /// **Si fonde e non si sostituisce**: un custodito nato sul telefono e non
  /// ancora arrivato al server non deve sparire perche' il server non lo
  /// conosce ancora.
  Future<void> riprendiDalServer() async {
    final dalServer = await _porta.tutti();
    if (dalServer.isEmpty) return;
    var cambiato = false;
    for (final r in dalServer) {
      if (!_dentro.containsKey(r.chiave)) {
        _dentro[r.chiave] = r;
        cambiato = true;
      }
    }
    if (cambiato) {
      notifyListeners();
      await _salva();
    }
  }

  Future<void> _salva() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _chiave, jsonEncode([for (final r in _dentro.values) r.aMappa()]));
    } catch (errore) {
      debugPrint('Scrigno: i custoditi non si salvano. $errore');
    }
  }

  void dimentica() {
    _dentro.clear();
    _caricato = false;
    notifyListeners();
  }
}
