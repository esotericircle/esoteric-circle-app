import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'face_classifier.dart';
import 'ritratti_del_viso.dart';
import 'face_trait.dart';
import '../identity/scadenze_del_telefono.dart';

/// Una Costellazione del Viso gia' letta, con la sua data e la lettura intera.
@immutable
class FaceEsito {
  const FaceEsito({
    required this.quando,
    required this.reading,
    this.ritratto,
  });

  final DateTime quando;
  final FaceReading reading;

  /// **DOVE STA LA FOTOGRAFIA DI QUESTA LETTURA, sul telefono e in nessun
  /// altro posto.** Ordine CX, 8 settembre 2026.
  ///
  /// Nullo per le letture piu' vecchie di dodici, che tengono il testo e
  /// perdono il ritratto, e per quelle in cui lo scatto non si e' potuto
  /// conservare. **Un percorso, non un immagine**: i byte stanno in un file
  /// che la persona puo' cancellare, non dentro le preferenze.
  final String? ritratto;

  FaceEsito senzaRitratto() =>
      FaceEsito(quando: quando, reading: reading);

  Map<String, dynamic> toJson() => {
        'quando': quando.toIso8601String(),
        'letture': [
          for (final l in reading.letture)
            {'tratto': l.tratto.name, 'marcatezza': l.marcatezza},
        ],
        // **IL PERCORSO SI SALVA, L'IMMAGINE NO.** La differenza non e'
        // formale: nelle preferenze finisce una riga di testo, i pixel
        // stanno in un file che si cancella da solo quando la persona lo
        // chiede o quando la lettura scade.
        if (ritratto != null) 'ritratto': ritratto,
      };

  static FaceEsito? fromJson(Map<String, dynamic> j) {
    final quando = DateTime.tryParse(j['quando'] as String? ?? '');
    if (quando == null) return null;
    final grezze = j['letture'];
    if (grezze is! List) return null;
    final letture = <TraitLettura>[];
    for (final r in grezze) {
      if (r is! Map) continue;
      final nome = r['tratto'];
      final marc = r['marcatezza'];
      FaceTrait? t;
      for (final v in FaceTrait.values) {
        if (v.name == nome) t = v;
      }
      if (t != null && marc is num) {
        letture.add(TraitLettura(tratto: t, marcatezza: marc.toDouble()));
      }
    }
    if (letture.isEmpty) return null;
    final ritratto = j['ritratto'];
    return FaceEsito(
      quando: quando,
      reading: FaceReading(letture: letture),
      ritratto: ritratto is String && ritratto.isNotEmpty ? ritratto : null,
    );
  }
}

/// Lo storico delle letture del viso, SOLO in locale sul dispositivo.
///
/// Serve a mostrare le letture passate e a contare quelle del giorno.
///
/// **DA OGGI CONSERVA ANCHE IL RITRATTO, ed e' una decisione del fondatore.**
/// Ordine CX, 8 settembre 2026: *"quando andro' a vedere le scorse scansioni e
/// risultati vorro' vedere la foto del viso"*, e *"puoi tenerle memorizzate
/// solo sul telefono e dare l'opportunita' all'utente di gestirle?"*.
///
/// Fino a ieri qui c'era scritto *"nessuna immagine e nessuna foto"*, ed era
/// vero: la fotografia viveva quanto la schermata. **Il perimetro nuovo sta in
/// `RitrattiDelViso`**, in numeri e non in parole: dodici letture, seicento
/// quaranta punti di larghezza, stessa scadenza del testo, cancellazione una
/// alla volta o tutta insieme.
///
/// **Cio' che NON cambia**: nelle preferenze finisce un percorso, mai dei
/// pixel, e niente esce dal telefono.
class FaceHistory extends ChangeNotifier {
  FaceHistory({DateTime Function()? clock, int massimo = 40})
      : _clock = clock ?? DateTime.now,
        _massimo = massimo;

  static const String _chiave = 'viso.storico';

  final DateTime Function() _clock;
  final int _massimo;

  List<FaceEsito> _esiti = const [];

  List<FaceEsito> get esiti => List.unmodifiable(_esiti);

  FaceEsito? get ultimo => _esiti.isEmpty ? null : _esiti.first;

  int get fattiOggi {
    final oggi = _clock();
    return _esiti
        .where((e) =>
            e.quando.year == oggi.year &&
            e.quando.month == oggi.month &&
            e.quando.day == oggi.day)
        .length;
  }

  /// **IL VOLTO E' CAMBIATO DAVVERO? Ordine BX voce 11.**
  ///
  /// Il corpus chiede "la Costellazione del Viso ti rilegge a distanza di un
  /// mese e trova un tratto diverso": due condizioni insieme, la distanza e
  /// la differenza. Si guarda la lettura piu' RECENTE fra quelle vecchie di
  /// almeno un mese, e si confronta il tratto dominante di allora con quello
  /// di adesso.
  ///
  /// **Perche' vive qui e non nella schermata.** Stava dentro `_concludi`,
  /// in mezzo alla fotocamera e allo stato della scena, e nessuna prova
  /// poteva chiedergli niente: la guardia del mese passava anche togliendo
  /// il mese, perche' misurava la reazione del diario a un dettaglio scritto
  /// a mano invece della regola. **La grandezza misurata e' cambiata, non la
  /// soglia**: adesso e' la regola stessa a rispondere, e con le date vere.
  ///
  /// **Meno di un mese non basta**, e non e' pedanteria: due letture fatte
  /// nello stesso pomeriggio possono dare tratti diversi solo per la luce, e
  /// il gradino direbbe che il volto e' cambiato quando non e' cambiato
  /// niente.
  bool ilTrattoECambiatoInUnMese(FaceReading adesso) {
    final ora = _clock();
    final vecchie =
        _esiti.where((e) => ora.difference(e.quando).inDays >= 30).toList();
    if (vecchie.isEmpty) return false;
    final piuRecente =
        vecchie.reduce((a, b) => a.quando.isAfter(b.quando) ? a : b);
    return piuRecente.reading.dominante != adesso.dominante;
  }

  Future<void> carica() async {
    try {
      final p = await SharedPreferences.getInstance();
      final grezzo = p.getStringList(_chiave) ?? const [];
      final letti = <FaceEsito>[];
      for (final riga in grezzo) {
        final j = jsonDecode(riga);
        if (j is Map<String, dynamic>) {
          final e = FaceEsito.fromJson(j);
          if (e != null) letti.add(e);
        }
      }
      // **LA POTATURA DI CIO' CHE E' SCADUTO. Ordine CB voce 05.**
      //
      // La lista si limitava per NUMERO, quaranta righe, e non per tempo: chi
      // ne fa una al mese si porta dietro tre anni di letture. Il tempo lo
      // decide `ScadenzeDelTelefono`, che porta anche la ragione scritta.
      //
      // **Si pota leggendo, non con un lavoro a parte**, perche' questo e'
      // l'unico momento in cui la lista viene aperta davvero: un servizio che
      // girasse all'avvio farebbe lo stesso lavoro in un momento in cui alla
      // persona serve la scena, non la pulizia.
      final vivi = [
        for (final e in letti)
          if (!ScadenzeDelTelefono.viso.scaduta(e.quando, _clock())) e
      ];
      // **E I RITRATTI DELLE SCADUTE SE NE VANNO COL LORO TESTO.** Ordine CX:
      // due scadenze diverse sullo stesso ricordo sarebbero due verita', e
      // quella che resta piu' a lungo sarebbe proprio l'immagine del volto.
      for (final e in letti) {
        if (!vivi.contains(e)) await RitrattiDelViso.cancella(e.ritratto);
      }
      if (vivi.length != letti.length) {
        await p.setStringList(
            _chiave, [for (final e in vivi) jsonEncode(e.toJson())]);
      }
      vivi.sort((a, b) => b.quando.compareTo(a.quando));
      _esiti = vivi;
      notifyListeners();
    } catch (_) {
      // Memoria non disponibile: si continua senza storico, mai un errore.
    }
  }

  Future<FaceEsito> registra(FaceReading reading,
      {String? scatto}) async {
    // **IL RITRATTO SI CONSERVA PRIMA DI SCRIVERE LA RIGA**, cosi' la riga
    // non promette un file che non esiste. Se lo scatto non si puo'
    // conservare, la lettura si registra lo stesso senza ritratto: il
    // responso vale, la fotografia e' un di piu'.
    final quando = _clock();
    final ritratto = scatto == null
        ? null
        : await RitrattiDelViso.conserva(scatto, quando: quando);
    final esito =
        FaceEsito(quando: quando, reading: reading, ritratto: ritratto);
    final tutti = [esito, ..._esiti].take(_massimo).toList();
    // **LE FOTO OLTRE LA DODICESIMA SI CANCELLANO DAL DISCO, non solo dalla
    // riga.** Una riga senza ritratto e un file che resta sono la stessa
    // cosa vista da due parti, e la parte che occupa lo spazio e' quella che
    // nessuno guarda piu'.
    for (var i = RitrattiDelViso.quanteNeTengono; i < tutti.length; i++) {
      if (tutti[i].ritratto != null) {
        await RitrattiDelViso.cancella(tutti[i].ritratto);
        tutti[i] = tutti[i].senzaRitratto();
      }
    }
    _esiti = List.unmodifiable(tutti);
    notifyListeners();
    await _scrivi();
    return esito;
  }

  /// **CANCELLA UNA SOLA LETTURA**, il suo ritratto compreso. Ordine CX: la
  /// persona gestisce cio' che l'app tiene di lei, e gestire vuol dire anche
  /// togliere una cosa alla volta invece di dover buttare tutto.
  Future<void> dimentica(FaceEsito quale) async {
    await RitrattiDelViso.cancella(quale.ritratto);
    _esiti = List.unmodifiable(
        [for (final e in _esiti) if (e.quando != quale.quando) e]);
    notifyListeners();
    await _scrivi();
  }

  /// **CANCELLA TUTTE LE LETTURE E TUTTI I RITRATTI.**
  Future<void> dimenticaTutto() async {
    await RitrattiDelViso.cancellaTutti();
    _esiti = const [];
    notifyListeners();
    await _scrivi();
  }

  Future<void> _scrivi() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setStringList(
          _chiave, [for (final e in _esiti) jsonEncode(e.toJson())]);
    } catch (_) {
      // best effort: lo storico in memoria resta buono per la sessione.
    }
  }
}
