import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'archetype.dart';
import 'archetype_scoring.dart';
import '../identity/scadenze_del_telefono.dart';

/// Un test archetipo gia' fatto, con la sua data e il profilo intero.
///
/// Si salva il profilo COMPLETO e non il solo dominante, cosi' il confronto nel
/// tempo puo' dire anche di quanto una corda si e' mossa, non solo quale ha
/// vinto.
@immutable
class ArchetypeEsito {
  const ArchetypeEsito({
    required this.quando,
    required this.percentuali,
    required this.dominante,
    this.secondo,
  });

  final DateTime quando;
  final Map<Archetype, double> percentuali;
  final Archetype dominante;
  final Archetype? secondo;

  ArchetypeProfile get profilo => ArchetypeProfile(
        percentuali: percentuali,
        dominante: dominante,
        secondo: secondo,
      );

  Map<String, dynamic> toJson() => {
        'quando': quando.toIso8601String(),
        'dominante': dominante.name,
        if (secondo != null) 'secondo': secondo!.name,
        'percentuali': {
          for (final e in percentuali.entries) e.key.name: e.value,
        },
      };

  static ArchetypeEsito? fromJson(Map<String, dynamic> j) {
    Archetype? perNome(Object? v) {
      if (v is! String) return null;
      for (final a in Archetype.values) {
        if (a.name == v) return a;
      }
      return null;
    }

    final quando = DateTime.tryParse(j['quando'] as String? ?? '');
    final dom = perNome(j['dominante']);
    if (quando == null || dom == null) return null;
    final grezze = j['percentuali'];
    final perc = <Archetype, double>{for (final a in Archetype.values) a: 0.0};
    if (grezze is Map) {
      grezze.forEach((k, v) {
        final a = perNome(k);
        if (a != null && v is num) perc[a] = v.toDouble();
      });
    }
    return ArchetypeEsito(
      quando: quando,
      percentuali: perc,
      dominante: dom,
      secondo: perNome(j['secondo']),
    );
  }
}

/// Lo storico dei test, tenuto SOLO in locale sul dispositivo.
///
/// Il conteggio del giorno per il limite di livello si ricava da qui e non da
/// un contatore a parte: una sola verita', e cancellare lo storico non regala
/// tentativi in piu' del dovuto perche' azzera anche i test del giorno.
class ArchetypeHistory extends ChangeNotifier {
  /// **DIMENTICA CHI SE NE VA. Ordine BC voce 02.** Vedi
  /// `DimenticanzaDellaMemoriaViva`: i controller vivono per tutta la
  /// sessione, e cancellare l'account senza svuotarli lascia a schermo i dati
  /// di chi se n'e' appena andato. **Questo l'ha trovato la prova che enumera
  /// i provider di `app.dart`**, non l'occhio: era uno dei cinque che nessuno
  /// aveva contato.
  void dimenticaChiSeNeVa() {
    _esiti = const [];
    notifyListeners();
  }

  ArchetypeHistory({DateTime Function()? clock, int massimo = 40})
      : _clock = clock ?? DateTime.now,
        _massimo = massimo;

  static const String _chiave = 'archetipo.storico';

  final DateTime Function() _clock;
  final int _massimo;

  List<ArchetypeEsito> _esiti = const [];

  /// Dal piu' recente al piu' vecchio.
  List<ArchetypeEsito> get esiti => List.unmodifiable(_esiti);

  ArchetypeEsito? get ultimo => _esiti.isEmpty ? null : _esiti.first;

  /// Quanti test sono stati fatti nel giorno LOCALE corrente.
  int get fattiOggi {
    final oggi = _clock();
    return _esiti
        .where((e) =>
            e.quando.year == oggi.year &&
            e.quando.month == oggi.month &&
            e.quando.day == oggi.day)
        .length;
  }

  /// I dominanti nel tempo, dal piu' vecchio al piu' recente: e' la timeline.
  List<ArchetypeEsito> get timeline => _esiti.reversed.toList(growable: false);

  /// Quante volte questo storico e' stato SCRITTO. Serve a `carica` per
  /// accorgersi che il mondo e' cambiato mentre leggeva il disco.
  int _scritture = 0;

  Future<void> carica() async {
    // LA LETTURA NON CALPESTA CHI HA SCRITTO NEL FRATTEMPO.
    //
    // L'app fa partire `carica()` all'avvio, e la lettura del disco impiega
    // qualche istante. Chi in quegli istanti finiva il Test Archetipo vedeva
    // il proprio esito entrare in memoria e poi SPARIRE, sostituito dalla
    // lista vuota che la lettura stava riportando da un disco ancora vergine.
    // Non capitava spesso, e proprio per questo era il difetto peggiore: si
    // presentava una volta ogni tanto e sembrava un capriccio.
    //
    // Il conteggio delle scritture e' l'unica cosa che distingue "non c'era
    // niente" da "e' arrivato qualcosa mentre leggevo".
    final atteso = _scritture;
    try {
      final p = await SharedPreferences.getInstance();
      final grezzo = p.getStringList(_chiave) ?? const [];
      final letti = <ArchetypeEsito>[];
      for (final riga in grezzo) {
        final j = jsonDecode(riga);
        if (j is Map<String, dynamic>) {
          final e = ArchetypeEsito.fromJson(j);
          if (e != null) letti.add(e);
        }
      }
      if (_scritture != atteso) return;
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
          if (!ScadenzeDelTelefono.archetipo.scaduta(e.quando, _clock())) e
      ];
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

  /// Registra un esito nuovo e lo mette in testa.
  Future<ArchetypeEsito> registra(ArchetypeProfile profilo) async {
    final esito = ArchetypeEsito(
      quando: _clock(),
      percentuali: Map.of(profilo.percentuali),
      dominante: profilo.dominante,
      secondo: profilo.secondo,
    );
    _scritture++;
    _esiti = [esito, ..._esiti].take(_massimo).toList(growable: false);
    notifyListeners();
    try {
      final p = await SharedPreferences.getInstance();
      await p.setStringList(
          _chiave, [for (final e in _esiti) jsonEncode(e.toJson())]);
    } catch (_) {
      // best effort: lo storico in memoria resta comunque buono per la sessione
    }
    return esito;
  }

  /// La riga di confronto con la volta prima, oppure null se e' la prima volta.
  ///
  /// Il testo e' deterministico e non passa da nessuna AI.
  String? confrontoCon(ArchetypeEsito precedente, ArchetypeProfile adesso) {
    if (precedente.dominante == adesso.dominante) {
      return 'L\'ultima volta eri soprattutto ${precedente.dominante.nome}, '
          'lo sei ancora: la tua corda principale tiene.';
    }
    return 'L\'ultima volta eri soprattutto ${precedente.dominante.nome}, '
        'oggi emerge ${adesso.dominante.nome}.';
  }
}
