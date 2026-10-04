import 'dart:convert';

import 'package:flutter/services.dart';

/// **LE REGOLE DEL NOME NEL CERCHIO, ordine EY voce 01**, dal lato del
/// telefono.
///
/// **Il dato e' uno solo**: `functions/src/il_nome_del_cerchio.json`, lo
/// stesso file che legge il server. Il telefono lo porta come asset (la riga
/// sta in `pubspec.yaml`) e qui ne rifa' le tre domande per rispondere mentre
/// la persona scrive: ha la forma giusta, e' un nome del Cerchio, e' un
/// insulto. **Il server resta sovrano**: questa risposta e' un'anticipazione,
/// e la decisione la prende `scegliIlNome`. Una prova pretende che le due
/// implementazioni diano lo stesso verdetto sugli stessi nomi.
class LeRegoleDelNome {
  LeRegoleDelNome._(this._dati);

  /// Il percorso del dato, uguale per il server e per il telefono.
  static const String percorso = 'functions/src/il_nome_del_cerchio.json';

  final Map<String, dynamic> _dati;

  static LeRegoleDelNome? _caricate;

  /// Le regole gia' caricate, o nessuna finche' l'asset non e' arrivato.
  static LeRegoleDelNome? get caricate => _caricate;

  /// Carica il dato una volta sola.
  static Future<LeRegoleDelNome> carica([AssetBundle? bundle]) async {
    final gia = _caricate;
    if (gia != null) return gia;
    final testo = await (bundle ?? rootBundle).loadString(percorso);
    return _caricate = LeRegoleDelNome.da(testo);
  }

  /// Dal testo del dato, per le prove che lo leggono dal disco.
  factory LeRegoleDelNome.da(String testo) =>
      LeRegoleDelNome._(jsonDecode(testo) as Map<String, dynamic>);

  int get lunghezzaMinima => _dati['lunghezzaMinima'] as int;
  int get lunghezzaMassima => _dati['lunghezzaMassima'] as int;
  List<String> get riservati => _lista('riservati');
  List<String> get offensiveContenute => _lista('offensiveContenute');
  List<String> get offensiveParola => _lista('offensiveParola');

  List<String> _lista(String nome) =>
      [for (final v in _dati[nome] as List<dynamic>) v as String];

  Map<String, String> _mappa(String nome) => {
        for (final e in (_dati[nome] as Map<String, dynamic>).entries)
          e.key: e.value as String,
      };

  late final Map<String, String> _confondibili = _mappa('confondibili');
  late final Map<String, String> _cifre = _mappa('cifreComeLettere');
  late final List<String> _riservatiRidotti = [
    for (final r in riservati) _riduci(r, 'i'),
  ];
  late final List<String> _testaOCoda = [
    for (final r in _lista('riservatiInTestaOInCoda')) _riduci(r, 'i'),
  ];

  /// La forma ammessa: lettere latine anche accentate, cifre, spazio, punto
  /// e trattino basso. Tutto il resto cade, compresi i caratteri invisibili.
  static final RegExp _ammessi = RegExp(r'^[A-Za-z0-9 ._À-ÖØ-öø-ÿ]+$');

  /// Le forme di confronto, come in `formeDiConfronto` del server.
  List<String> formeDiConfronto(String nome) {
    final forme = <String>[_riduci(nome, 'i')];
    if (_dati['unoAncheComeElle'] == true && nome.contains('1')) {
      forme.add(_riduci(nome, 'l'));
    }
    forme.add(_riduci(nome.replaceAll(RegExp('[0-9]'), ''), 'i'));
    return {
      for (final f in forme)
        if (f.isNotEmpty) f,
    }.toList();
  }

  String _riduci(String nome, String uno) {
    final fuori = StringBuffer();
    for (final carattere in nome.toLowerCase().split('')) {
      if (carattere == '1') {
        fuori.write(uno);
        continue;
      }
      final cifra = _cifre[carattere];
      if (cifra != null) {
        fuori.write(cifra);
        continue;
      }
      final simile = _confondibili[carattere];
      if (simile != null) {
        fuori.write(simile);
        continue;
      }
      fuori.write(_senzaAccento(carattere));
    }
    return fuori.toString().replaceAll(RegExp('[^a-z0-9]'), '');
  }

  /// Gli accenti latini tolti a mano: Dart non ha la scomposizione NFKD.
  /// La tavola copre le lettere che la forma ammessa accetta.
  static String _senzaAccento(String c) {
    const tavola = {
      'à': 'a', 'á': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a', 'å': 'a', //
      'ç': 'c', 'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e', 'ì': 'i', //
      'í': 'i', 'î': 'i', 'ï': 'i', 'ñ': 'n', 'ò': 'o', 'ó': 'o', //
      'ô': 'o', 'õ': 'o', 'ö': 'o', 'ù': 'u', 'ú': 'u', 'û': 'u', //
      'ü': 'u', 'ý': 'y', 'ÿ': 'y', 'ð': 'd',
    };
    return tavola[c] ?? c;
  }

  List<List<String>> _paroleDi(String nome) => [
        for (final p in nome.split(RegExp(r'[ ._]+')))
          if (p.isNotEmpty) formeDiConfronto(p),
      ];

  bool eRiservato(String nome) {
    for (final forma in formeDiConfronto(nome)) {
      if (_riservatiRidotti.contains(forma)) return true;
      for (final r in _testaOCoda) {
        if (forma.startsWith(r) || forma.endsWith(r)) return true;
      }
    }
    for (final parola in _paroleDi(nome)) {
      for (final forma in parola) {
        if (_riservatiRidotti.contains(forma)) return true;
      }
    }
    return false;
  }

  bool eOffensivo(String nome) {
    for (final forma in formeDiConfronto(nome)) {
      for (final radice in offensiveContenute) {
        if (forma.contains(radice)) return true;
      }
      if (offensiveParola.contains(forma)) return true;
    }
    for (final parola in _paroleDi(nome)) {
      for (final forma in parola) {
        if (offensiveParola.contains(forma)) return true;
      }
    }
    return false;
  }

  /// Il verdetto, nello stesso ordine del server.
  PercheNoAlNome? verdetto(String proposto) {
    final nome = proposto.trim();
    final lunghezza = nome.runes.length;
    if (lunghezza < lunghezzaMinima) return PercheNoAlNome.corto;
    if (lunghezza > lunghezzaMassima) return PercheNoAlNome.lungo;
    if (!_ammessi.hasMatch(nome)) return PercheNoAlNome.caratteri;
    if (nome.contains('  ')) return PercheNoAlNome.spazi;
    if (eRiservato(nome)) return PercheNoAlNome.riservato;
    if (eOffensivo(nome)) return PercheNoAlNome.offensivo;
    return null;
  }
}

/// Perche' un nome non passa, con la riga che la persona legge. Le righe
/// sono le stesse di `RIGHE_DEL_RIFIUTO` del server.
enum PercheNoAlNome {
  corto('Il nome vuole almeno tre caratteri.'),
  lungo('Il nome sta in venti caratteri al massimo.'),
  caratteri(
      'Il nome si scrive con lettere, cifre, spazio, punto e trattino basso.'),
  spazi('Un solo spazio fra una parola e l’altra.'),
  riservato('Questo nome è del Cerchio: scegline un altro.'),
  offensivo('Questo nome non può stare nel Cerchio.'),
  lasciato(
      'Questo nome è stato lasciato da poco: torna libero fra qualche settimana.'),
  cadenza('Il nome si cambia una volta ogni trenta giorni.');

  const PercheNoAlNome(this.riga);
  final String riga;

  static PercheNoAlNome? daNome(String? nome) {
    for (final p in values) {
      if (p.name == nome) return p;
    }
    return null;
  }
}
