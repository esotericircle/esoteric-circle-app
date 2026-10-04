import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../entitlement/plan_catalog.dart';
import '../entitlement/tier.dart';

/// Un amico degli "amici offline": nome e nascita, niente di piu'.
class Amico {
  const Amico({
    required this.id,
    required this.nome,
    required this.nascita,
    this.ora,
    this.luogo,
    this.lat,
    this.lon,
    this.fuso,
  });

  final String id;
  final String nome;

  /// La data di nascita (il giorno civile del luogo).
  final DateTime nascita;

  /// L'ora e i minuti di nascita, "HH:mm", se si sanno.
  final String? ora;

  /// Il luogo di nascita, se si sa.
  final String? luogo;
  final double? lat;
  final double? lon;
  final String? fuso;

  bool get oraNota => ora != null;

  /// La nascita con l'ora, quando c'e'; a mezzogiorno altrimenti.
  DateTime get momento {
    final p = (ora ?? '12:00').split(':');
    return DateTime(nascita.year, nascita.month, nascita.day, int.parse(p[0]),
        int.parse(p[1]));
  }

  Map<String, Object?> toJson() => {
        'id': id,
        'nome': nome,
        'nascita': '${nascita.year.toString().padLeft(4, '0')}-'
            '${nascita.month.toString().padLeft(2, '0')}-'
            '${nascita.day.toString().padLeft(2, '0')}',
        if (ora != null) 'ora': ora,
        if (luogo != null) 'luogo': luogo,
        if (lat != null) 'lat': lat,
        if (lon != null) 'lon': lon,
        if (fuso != null) 'fuso': fuso,
      };

  static Amico? fromJson(Object? j) {
    if (j is! Map) return null;
    final nascita = DateTime.tryParse('${j['nascita']}');
    final nome = j['nome'];
    final id = j['id'];
    if (nascita == null || nome is! String || id is! String) return null;
    return Amico(
      id: id,
      nome: nome,
      nascita: nascita,
      ora: j['ora'] as String?,
      luogo: j['luogo'] as String?,
      lat: (j['lat'] as num?)?.toDouble(),
      lon: (j['lon'] as num?)?.toDouble(),
      fuso: j['fuso'] as String?,
    );
  }
}

/// **GLI AMICI OFFLINE, ordine ES voce 12.**
///
/// Il fondatore: *"servirà che l'utente inserisca i dati e il nome
/// dell'amico che verranno memorizzati in un contenitore "amici offline" che
/// potranno essere richiamati nelle altre funzionalità di compatibilità"*.
/// Stanno sul telefono, e se ne vanno con l'account (`CioCheETuo`, prefisso
/// `amici_offline`) e nello scarico dei dati.
///
/// **Quanti**, dal fondatore: il Viandante nessuno ("lo vede e se fa click,
/// viene invitato a sottoscrivere abbonamento"), l'Iniziato tre, l'Adepto
/// dieci, l'Illuminato senza limite; un posto in piu' costa 100 Eos. Dal 4
/// ottobre 2026 (ordine EZ voce 06) anche l'Illuminato ha un numero,
/// cinquanta, perche' l'illimitato esponeva all'abuso e ai bot; chi ne aveva
/// gia' di piu' le tiene tutte e non ne aggiunge.
class AmiciOffline extends ChangeNotifier {
  static const String _chiave = 'amici_offline';
  static const String _chiavePosti = 'amici_offline_posti';

  final List<Amico> _amici = [];
  int _postiComprati = 0;
  bool _caricati = false;

  List<Amico> get tutti => List.unmodifiable(_amici);
  int get postiComprati => _postiComprati;
  bool get caricati => _caricati;

  /// Quanti amici tiene il piano [tier], posti comprati compresi. Null vuol
  /// dire senza limite.
  ///
  /// **Il numero lo dice il listino dei piani**, riga `RigaDelPiano.amici`:
  /// "No" vale zero, un numero vale quel numero, il resto vale senza limite.
  /// Scritto qui una seconda volta, al primo ritocco i due direbbero numeri
  /// diversi.
  int? posti(Tier tier) {
    final riga =
        PlanCatalog.matrix.where((r) => r.chiave == RigaDelPiano.amici);
    if (riga.isEmpty) return 0;
    const ordine = [Tier.free, Tier.tier1, Tier.tier2, Tier.tier3];
    final cella = riga.first.values[ordine.indexOf(tier)];
    if (cella.toLowerCase() == 'no') return 0;
    final n = int.tryParse(cella);
    return n == null ? null : n + _postiComprati;
  }

  /// Se col piano [tier] si puo' aggiungere un amico adesso.
  ///
  /// **Il Viandante non ha un caso a parte**: i suoi posti sono zero perche'
  /// la sua cella dice "No", e i posti comprati non si sommano a un "No". Un
  /// controllo in piu' qui era ridondante, e la Regola A lo ha mostrato:
  /// toglierlo non faceva cadere nessuna prova.
  bool siPuoAggiungere(Tier tier) {
    final p = posti(tier);
    return p == null || _amici.length < p;
  }

  Future<void> carica() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final grezzo = prefs.getString(_chiave);
      _amici
        ..clear()
        ..addAll([
          if (grezzo != null)
            for (final j in jsonDecode(grezzo) as List)
              if (Amico.fromJson(j) != null) Amico.fromJson(j)!,
        ]);
      _postiComprati = prefs.getInt(_chiavePosti) ?? 0;
    } catch (errore) {
      // Senza preferenze gli amici non si ricordano: la lista resta vuota.
    }
    _caricati = true;
    notifyListeners();
  }

  Future<void> _salva() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _chiave, jsonEncode([for (final a in _amici) a.toJson()]));
      await prefs.setInt(_chiavePosti, _postiComprati);
    } catch (errore) {
      // Il disco che non scrive non toglie l'amico a video: resta finche'
      // la schermata e' aperta.
    }
  }

  /// Aggiunge [amico] se c'e' posto. Torna falso se il piano non lo tiene.
  Future<bool> aggiungi(Amico amico, Tier tier) async {
    if (!siPuoAggiungere(tier)) return false;
    _amici.add(amico);
    notifyListeners();
    await _salva();
    return true;
  }

  Future<void> togli(String id) async {
    _amici.removeWhere((a) => a.id == id);
    notifyListeners();
    await _salva();
  }

  /// Un posto in piu', dopo la spesa di 100 Eos andata a buon fine.
  Future<void> unPostoInPiu() async {
    _postiComprati++;
    notifyListeners();
    await _salva();
  }
}
