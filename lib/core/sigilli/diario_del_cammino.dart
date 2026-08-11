import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../astro/natal_chart.dart';
import '../astro/zodiac.dart';
import '../tempo/confine_del_giorno.dart';
import 'eventi_del_cielo.dart';
import 'sentieri.dart';

/// IL DIARIO DEL CAMMINO: cio' che hai fatto, quando lo hai fatto.
///
/// **Perche' nasce.** Prima dell'ordine O l'app sapeva pochissimo del tempo
/// passato dentro: la continuita' di due riti, i budget del giorno, tre
/// storici sparsi. Due terzi dei traguardi non sarebbero stati verificabili,
/// e un traguardo che non si puo' verificare e' una promessa. Questo e' il
/// registro, in un punto solo: i gesti compiuti, in che giorni, e quante
/// volte sono caduti nell'ora rituale giusta.
///
/// **Non e' una seconda porta dei contatori.** I budget del giorno restano
/// del server, con le loro regole: qui si registra la STORIA, che serve solo
/// a decidere se un Sigillo si accende. Sono due cose diverse, e tenerle
/// separate evita che un traguardo consumi una gettata.
class DiarioDelCammino extends ChangeNotifier {
  DiarioDelCammino({DateTime Function()? orologio})
      : _orologio = orologio ?? DateTime.now;

  final DateTime Function() _orologio;

  static const _kGesti = 'cammino.gesti';
  static const _kGiorni = 'cammino.giorni';
  static const _kOggi = 'cammino.oggi';
  static const _kGiornoDiOggi = 'cammino.giornoDiOggi';
  static const _kOre = 'cammino.ore';
  static const _kPrimoGiorno = 'cammino.primoGiorno';
  static const _kUltimoGiorno = 'cammino.ultimoGiorno';
  static const _kAccesi = 'cammino.accesi';
  static const _kCondivisi = 'cammino.condivisi';

  final Map<String, int> _gestiCompiuti = {};
  final Map<String, int> _giorniConGesto = {};
  final Map<String, int> _gestiNellOraGiusta = {};
  final Set<String> _oggiHaFatto = {};
  String _giornoDiOggi = '';
  String? _primoGiorno;
  String? _ultimoGiorno;
  int _giorniDiAssenza = 0;

  /// I traguardi gia' accesi, per id. Un Sigillo acceso non si spegne mai.
  final Set<String> _accesi = {};

  /// I traguardi la cui card e' gia' stata condivisa: serve a sapere se il
  /// bonus in Eos e' ancora in sospeso.
  final Set<String> _condivisi = {};

  Set<String> get accesi => Set.unmodifiable(_accesi);
  Set<String> get condivisi => Set.unmodifiable(_condivisi);
  int get giorniDiAssenzaPrimaDiOggi => _giorniDiAssenza;

  bool eAcceso(String id) => _accesi.contains(id);
  bool eStatoCondiviso(String id) => _condivisi.contains(id);

  /// Quanti giorni sono passati dal primo giorno nel Cerchio.
  int get giorniDalPrimoGiorno {
    if (_primoGiorno == null) return 0;
    final primo = DateTime.tryParse(_primoGiorno!);
    if (primo == null) return 0;
    return _orologio().difference(primo).inDays;
  }

  Future<void> carica() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _leggiMappa(prefs.getString(_kGesti), _gestiCompiuti);
      _leggiMappa(prefs.getString(_kGiorni), _giorniConGesto);
      _leggiMappa(prefs.getString(_kOre), _gestiNellOraGiusta);
      _giornoDiOggi = prefs.getString(_kGiornoDiOggi) ?? '';
      _oggiHaFatto
        ..clear()
        ..addAll(prefs.getStringList(_kOggi) ?? const []);
      _primoGiorno = prefs.getString(_kPrimoGiorno);
      _ultimoGiorno = prefs.getString(_kUltimoGiorno);
      _accesi
        ..clear()
        ..addAll(prefs.getStringList(_kAccesi) ?? const []);
      _condivisi
        ..clear()
        ..addAll(prefs.getStringList(_kCondivisi) ?? const []);
      _apriIlGiorno();
      notifyListeners();
    } catch (errore) {
      // Si ignora: un diario illeggibile vale come diario vuoto. Il cammino
      // riparte, e i Sigilli gia' accesi che il server conosce torneranno
      // quando la sincronia col Cerchio li riportera'.
    }
  }

  /// APRE IL GIORNO: se e' cambiato, svuota cio' che si e' fatto oggi e
  /// calcola quanti giorni di silenzio ci sono stati.
  void _apriIlGiorno() {
    final oggi = ConfineDelGiorno.chiaveDi(_orologio());
    if (_giornoDiOggi == oggi) return;
    _giornoDiOggi = oggi;
    _oggiHaFatto.clear();
    final ultimo = _ultimoGiorno == null ? null : DateTime.tryParse(_ultimoGiorno!);
    _giorniDiAssenza =
        ultimo == null ? 0 : _orologio().difference(ultimo).inDays - 1;
    if (_giorniDiAssenza < 0) _giorniDiAssenza = 0;
  }

  /// REGISTRA UN GESTO. E' l'unico modo di scrivere nel diario, e le schermate
  /// lo chiamano dal punto in cui il gesto e' davvero compiuto: non
  /// all'apertura di una scena, che si apre anche per sbaglio.
  Future<void> segna(String gesto, {String? oraRituale}) async {
    _apriIlGiorno();
    _gestiCompiuti[gesto] = (_gestiCompiuti[gesto] ?? 0) + 1;
    if (_oggiHaFatto.add(gesto)) {
      _giorniConGesto[gesto] = (_giorniConGesto[gesto] ?? 0) + 1;
    }
    if (oraRituale != null) {
      final chiave = '$gesto@$oraRituale';
      _gestiNellOraGiusta[chiave] = (_gestiNellOraGiusta[chiave] ?? 0) + 1;
    }
    final oggi = ConfineDelGiorno.chiaveDi(_orologio());
    _primoGiorno ??= _orologio().toIso8601String();
    _ultimoGiorno = _orologio().toIso8601String();
    _giornoDiOggi = oggi;
    notifyListeners();
    await _salva();
  }

  /// Accende un Sigillo. Torna vero se si e' acceso adesso, cosi' chi chiama
  /// sa se deve celebrare: accendere due volte lo stesso Sigillo non
  /// celebrerebbe niente, festeggerebbe un ricordo.
  Future<bool> accendi(String id) async {
    if (!_accesi.add(id)) return false;
    notifyListeners();
    await _salva();
    return true;
  }

  Future<void> segnaCondiviso(String id) async {
    if (!_condivisi.add(id)) return;
    notifyListeners();
    await _salva();
  }

  /// LA FOTOGRAFIA su cui si misurano i traguardi.
  StatoDelCammino statoDelCammino({
    NatalChart? carta,
    Zodiac? segno,
    Map<String, int> seriePerRito = const {},
    Set<String> pezziDellIdentita = const {},
    Map<String, int> memoria = const {},
  }) {
    _apriIlGiorno();
    return StatoDelCammino(
      gestiCompiuti: Map.unmodifiable(_gestiCompiuti),
      giorniConGesto: Map.unmodifiable(_giorniConGesto),
      oggiHaFatto: Set.unmodifiable(_oggiHaFatto),
      seriePerRito: seriePerRito,
      gestiNellOraGiusta: Map.unmodifiable(_gestiNellOraGiusta),
      eventiDelCieloDiOggi: EventiDelCielo.diOggi(
        adesso: _orologio(),
        carta: carta,
        segno: segno,
      ),
      pezziDellIdentita: pezziDellIdentita,
      memoria: memoria,
      giorniDiAssenzaPrimaDiOggi: _giorniDiAssenza,
      giorniDalPrimoGiorno: giorniDalPrimoGiorno,
    );
  }

  /// I TRAGUARDI CHE SI SONO APPENA ACCESI, in ordine di posizione.
  ///
  /// Si guarda tutto in un colpo solo dopo un gesto: valutare un traguardo
  /// alla volta, ognuno col suo controllo sparso, sarebbe il modo sicuro di
  /// dimenticarne qualcuno.
  Future<List<Traguardo>> quelliCheSiAccendono(StatoDelCammino stato) async {
    final nuovi = <Traguardo>[];
    for (final traguardo in Sentieri.tuttiITraguardi) {
      if (_accesi.contains(traguardo.id)) continue;
      if (!traguardo.condizione.raggiunto(stato)) continue;
      nuovi.add(traguardo);
    }
    nuovi.sort((a, b) => a.posizione.compareTo(b.posizione));
    return nuovi;
  }

  /// Il prossimo traguardo di un sentiero, cioe' il primo non ancora acceso.
  /// Serve alla celebrazione, che non finisce mai col punto.
  Traguardo? prossimoDi(Sentiero sentiero) {
    for (final t in Sentieri.miniDi(sentiero)) {
      if (!_accesi.contains(t.id)) return t;
    }
    for (final t in Sentieri.grandiDi(sentiero)) {
      if (!_accesi.contains(t.id)) return t;
    }
    return null;
  }

  /// Quanti traguardi accesi su un sentiero.
  int quantiAccesiDi(Sentiero sentiero) =>
      Sentieri.di(sentiero).where((t) => _accesi.contains(t.id)).length;

  void _leggiMappa(String? testo, Map<String, int> dentro) {
    dentro.clear();
    if (testo == null || testo.isEmpty) return;
    try {
      final letto = jsonDecode(testo);
      if (letto is! Map) return;
      for (final voce in letto.entries) {
        final valore = voce.value;
        if (valore is num) dentro['${voce.key}'] = valore.toInt();
      }
    } catch (errore) {
      // Si ignora: una voce illeggibile vale zero, e il cammino continua.
    }
  }

  Future<void> _salva() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kGesti, jsonEncode(_gestiCompiuti));
      await prefs.setString(_kGiorni, jsonEncode(_giorniConGesto));
      await prefs.setString(_kOre, jsonEncode(_gestiNellOraGiusta));
      await prefs.setStringList(_kOggi, _oggiHaFatto.toList());
      await prefs.setString(_kGiornoDiOggi, _giornoDiOggi);
      await prefs.setStringList(_kAccesi, _accesi.toList());
      await prefs.setStringList(_kCondivisi, _condivisi.toList());
      if (_primoGiorno != null) {
        await prefs.setString(_kPrimoGiorno, _primoGiorno!);
      }
      if (_ultimoGiorno != null) {
        await prefs.setString(_kUltimoGiorno, _ultimoGiorno!);
      }
    } catch (errore) {
      // Si ignora: senza disco il cammino vale per questa sessione. Meglio
      // un Sigillo che vive un giorno di un\'app che cade mentre festeggia.
    }
  }
}
