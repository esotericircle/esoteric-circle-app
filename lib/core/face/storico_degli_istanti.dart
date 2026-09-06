import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'espressione_dell_istante.dart';

/// **LA PROPRIA LINEA DEGLI ISTANTI.** Ordine CR voce 08, 6 settembre 2026.
///
/// **Parole dell'ordine**: i ritorni *"producono soltanto la lettura
/// dell'istante, confrontata con la propria linea"*.
///
/// **COSA VUOL DIRE "LA PROPRIA LINEA", e perche' senza questo file non
/// esisterebbe.** Un'osservazione da sola non dice niente: sapere che oggi hai
/// le sopracciglia raccolte vale poco, sapere che le hai avute raccolte le
/// ultime quattro volte vale molto di piu', e sapere che oggi c'e' un segno che
/// non ti si era mai visto vale ancora di piu'. Il confronto ha bisogno di una
/// memoria, e questa e' la memoria.
///
/// **COSA SI SCRIVE SU DISCO, DICHIARATO PER INTERO. Ordine CR voce 11.** Qui
/// finiscono soltanto **la data e i nomi dei segni**, cioe' due parole per
/// lettura. Non i coefficienti, non i punti della mesh, non un'immagine:
/// **niente da cui si possa ricostruire un volto**. La chiave vive sotto il
/// prefisso `viso.`, che e' gia' nell'elenco di `CioCheETuo`, quindi se ne va
/// con la cancellazione dei propri dati senza che si debba aggiungere niente.
class StoricoDegliIstanti {
  StoricoDegliIstanti({DateTime Function()? clock, int massimo = 30})
      : _clock = clock ?? DateTime.now,
        _massimo = massimo;

  static const String chiave = 'viso.istanti';

  final DateTime Function() _clock;
  final int _massimo;

  List<IstanteSegnato> _istanti = const [];

  List<IstanteSegnato> get istanti => List.unmodifiable(_istanti);

  IstanteSegnato? get ultimo => _istanti.isEmpty ? null : _istanti.first;

  Future<void> carica() async {
    final p = await SharedPreferences.getInstance();
    final grezzo = p.getString(chiave);
    if (grezzo == null) return;
    try {
      final decodificato = jsonDecode(grezzo);
      if (decodificato is! List) return;
      _istanti = [
        for (final r in decodificato)
          if (r is Map<String, dynamic>) ...[
            if (IstanteSegnato.fromJson(r) case final i?) i,
          ],
      ];
    } catch (_) {
      // Una memoria illeggibile si tratta come una memoria vuota: cadere
      // all'avvio per un file storto sarebbe peggio del dato perso.
      _istanti = const [];
    }
  }

  Future<void> segna(List<SegnoDelVolto> segni) async {
    final i = IstanteSegnato(quando: _clock(), segni: segni);
    _istanti = [i, ..._istanti].take(_massimo).toList(growable: false);
    final p = await SharedPreferences.getInstance();
    await p.setString(
        chiave, jsonEncode([for (final x in _istanti) x.toJson()]));
  }

  /// **COSA DIRE DI QUESTO ISTANTE, GUARDANDO LA PROPRIA LINEA.**
  ///
  /// Si guardano le letture PRECEDENTI, cioe' non questa: confrontare una
  /// lettura con se stessa direbbe sempre che tutto e' ricorrente, ed e' il
  /// modo piu' rapido di costruire un confronto che non confronta.
  ///
  /// Restituisce nullo quando non c'e' abbastanza linea per dire qualcosa:
  /// **il silenzio e' una risposta onesta**, e la scena sa cosa farne.
  ConfrontoConLaLinea? confronta(List<SegnoDelVolto> oggi) {
    if (oggi.isEmpty) return null;
    final passate = _istanti;
    if (passate.isEmpty) return null;
    final visti = <SegnoDelVolto>{for (final i in passate) ...i.segni};
    final nuovi = oggi.where((s) => !visti.contains(s)).toList();
    final ricorrenti = oggi.where(visti.contains).toList();
    return ConfrontoConLaLinea(
      nuovi: nuovi,
      ricorrenti: ricorrenti,
      quanteLetture: passate.length,
    );
  }
}

/// Una lettura dell'istante, ridotta a cio' che si puo' scrivere.
class IstanteSegnato {
  const IstanteSegnato({required this.quando, required this.segni});

  final DateTime quando;
  final List<SegnoDelVolto> segni;

  Map<String, dynamic> toJson() => {
        'quando': quando.toIso8601String(),
        'segni': [for (final s in segni) s.name],
      };

  static IstanteSegnato? fromJson(Map<String, dynamic> j) {
    final quando = DateTime.tryParse(j['quando'] as String? ?? '');
    if (quando == null) return null;
    final grezzi = j['segni'];
    if (grezzi is! List) return null;
    final segni = <SegnoDelVolto>[];
    for (final n in grezzi) {
      for (final s in SegnoDelVolto.values) {
        if (s.name == n) segni.add(s);
      }
    }
    return IstanteSegnato(quando: quando, segni: segni);
  }
}

/// Cosa la propria linea dice di questo istante.
class ConfrontoConLaLinea {
  const ConfrontoConLaLinea({
    required this.nuovi,
    required this.ricorrenti,
    required this.quanteLetture,
  });

  /// I segni di oggi che non erano mai comparsi prima.
  final List<SegnoDelVolto> nuovi;

  /// I segni di oggi che si erano gia' visti.
  final List<SegnoDelVolto> ricorrenti;

  /// Su quante letture passate si e' fatto il confronto. **Si dice a chi
  /// legge**: un confronto su una lettura sola non e' una linea, ed e' giusto
  /// che chi legge sappia quanto pesa.
  final int quanteLetture;
}
