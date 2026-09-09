import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'libreria_dei_respiri.dart';

/// **LA SEQUENZA DI AURA: il rito che ti costruisci.** Ordine DB voce 05,
/// 9 settembre 2026.
///
/// **Parole dell'ordine**: *"La persona compone il proprio rito mettendo in
/// fila tre o quattro pratiche della libreria, gli da' un nome, e quella
/// sequenza e' sua e la ritrova. E' la funzione che nella Z-App si chiama 'Il
/// mio Zapp', ed e' la ragione per cui quella app non viene disinstallata: chi
/// ha costruito qualcosa dentro non se ne va."*
///
/// **PERCHE' TRE O QUATTRO E NON QUANTE SI VUOLE.** Una sequenza di dieci
/// pratiche dura quasi un'ora e non la finisce nessuno: la prima volta che si
/// lascia a meta' la sequenza smette di essere un rito e diventa un elenco di
/// cose non fatte. Il minimo di due esiste per la stessa ragione al contrario:
/// una pratica sola non e' una sequenza, e' una pratica.
///
/// **VIVE SUL TELEFONO.** Come la traccia del Loto e la memoria del respiro:
/// e' una cosa che appartiene a chi la costruisce, e non serve a nessun server.
class SequenzeDiAura {
  SequenzeDiAura();

  static const String _chiave = 'loto.sequenze';

  /// **QUANTE PRATICHE PUO' TENERE UNA SEQUENZA.**
  static const int minimo = 2;
  static const int massimo = 4;

  /// Quante sequenze si possono conservare. Sei bastano: chi ne fa di piu'
  /// non le ritrova, e la funzione che doveva legare diventa un archivio.
  static const int quanteSeNeTengono = 6;

  List<Sequenza> _mie = const [];

  List<Sequenza> get mie => List.unmodifiable(_mie);

  Future<void> carica() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final righe = prefs.getStringList(_chiave) ?? const [];
      final lette = <Sequenza>[];
      for (final r in righe) {
        final j = jsonDecode(r);
        if (j is Map<String, dynamic>) {
          final s = Sequenza.fromJson(j);
          if (s != null) lette.add(s);
        }
      }
      _mie = List.unmodifiable(lette);
    } catch (_) {
      // Senza sequenze si respira lo stesso.
    }
  }

  /// Aggiunge una sequenza. Falso quando non e' valida, **col perche'
  /// leggibile**: un rifiuto muto lascia chi compone a chiedersi cosa ha
  /// sbagliato.
  Future<String?> aggiungi(Sequenza quale) async {
    final perche = quale.perCheNonVa;
    if (perche != null) return perche;
    _mie = List.unmodifiable(
        [quale, ..._mie.where((s) => s.nome != quale.nome)]
            .take(quanteSeNeTengono)
            .toList());
    await _scrivi();
    return null;
  }

  Future<void> togli(String nome) async {
    _mie = List.unmodifiable([for (final s in _mie) if (s.nome != nome) s]);
    await _scrivi();
  }

  Future<void> _scrivi() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
          _chiave, [for (final s in _mie) jsonEncode(s.toJson())]);
    } catch (_) {
      // best effort.
    }
  }
}

/// Un rito composto da chi respira.
class Sequenza {
  const Sequenza({required this.nome, required this.pratiche});

  /// Il nome che le ha dato la persona. **E' il pezzo che la rende sua**: una
  /// sequenza senza nome e' una playlist, una con un nome e' un rito.
  final String nome;

  /// Gli id delle pratiche, nell'ordine in cui si fanno.
  final List<String> pratiche;

  /// Quanto dura in tutto, sommando le durate dichiarate.
  Duration get durata {
    var totale = Duration.zero;
    for (final id in pratiche) {
      for (final r in LibreriaDeiRespiri.pronte) {
        if (r.id == id) totale += r.durata;
      }
    }
    return totale;
  }

  /// **PERCHE' NON VA, o nulla se va.** Mai un rifiuto muto.
  String? get perCheNonVa {
    if (nome.trim().isEmpty) {
      return 'Dalle un nome: è quello che la rende tua.';
    }
    if (pratiche.length < SequenzeDiAura.minimo) {
      return 'Mettine almeno ${SequenzeDiAura.minimo}: con una sola non è '
          'una sequenza.';
    }
    if (pratiche.length > SequenzeDiAura.massimo) {
      return 'Al massimo ${SequenzeDiAura.massimo}: più lunga di così non la '
          'finisce nessuno.';
    }
    final note = {for (final r in LibreriaDeiRespiri.pronte) r.id};
    for (final id in pratiche) {
      if (!note.contains(id)) return 'Una delle pratiche non esiste più.';
    }
    return null;
  }

  Map<String, dynamic> toJson() => {'nome': nome, 'pratiche': pratiche};

  static Sequenza? fromJson(Map<String, dynamic> j) {
    final nome = j['nome'];
    final pratiche = j['pratiche'];
    if (nome is! String || pratiche is! List) return null;
    return Sequenza(
      nome: nome,
      pratiche: [for (final p in pratiche) if (p is String) p],
    );
  }

  /// **IL TESTO CON CUI UNA SEQUENZA SI CONDIVIDE**, e passa dal punto unico
  /// come tutto il resto. Ordine DB voce 05: *"non se ne scrive un altro"*.
  String get testoDaCondividere {
    final nomi = <String>[];
    for (final id in pratiche) {
      for (final r in LibreriaDeiRespiri.pronte) {
        if (r.id == id) nomi.add(r.nome);
      }
    }
    return '$nome, il mio rito del respiro: ${nomi.join(", ")}. '
        '${durata.inMinutes} minuti.';
  }
}
