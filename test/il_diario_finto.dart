/// **IL DIARIO COSMICO FINTO, per le prove. Ordine FE voce 22.**
///
/// Dall'ordine FE il Diario sta sul server e il menu' della chat lo legge
/// (FE.22.16): una prova che apre una conversazione passata dal menu' deve
/// prima averla nel Diario, come in app ce l'ha messa il server col primo
/// messaggio. Qui stanno la porta in memoria, che conta letture e scritture
/// come le conterebbe Firestore, e il seme delle righe per l'archivio finto
/// del telefono.
library;

import 'dart:convert';

import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/ricordi/registro_dei_ricordi.dart';
import 'package:esoteric_circle/core/ricordi/voce_del_ricordo.dart';

/// Le righe del Diario sul telefono, nella forma che il registro legge da
/// `SharedPreferences`: da unire ai valori finti dell'archivio.
Map<String, Object> ilDiarioSulTelefono(List<VoceDelRicordo> voci) {
  final perMese = <String, Map<String, Object?>>{};
  for (final v in voci) {
    (perMese[v.mese] ??= {})[v.chiave] = v.aMappa();
  }
  return {
    for (final e in perMese.entries)
      'ricordi.voci.${e.key}': jsonEncode(e.value),
  };
}

/// La riga di una conversazione col suo Maestro, come la scrive il server.
VoceDelRicordo laConversazione(Maestro maestro,
    {String? id, required String titolo, required DateTime quando}) {
  final chiave = RegistroDeiRicordi.chiaveDellaConversazione(maestro.id, id);
  return VoceDelRicordo(
    quando: quando,
    arte: 'chat',
    maestro: maestro.id,
    titolo: titolo,
    tipo: TipoDelRicordo.conversazione,
    riferimento: chiave,
    chiaveDelDiario: chiave,
  );
}

/// **LA PORTA DEL DIARIO IN MEMORIA.** Tiene i mesi, i riassunti degli anni
/// e i contenuti come il server, e conta: una lettura per documento letto,
/// come le fattura Firestore.
class PortaFintaDelDiario extends PortaDeiRicordi {
  PortaFintaDelDiario();

  /// I mesi `AAAA-MM`, con le righe per chiave.
  final Map<String, Map<String, VoceDelRicordo>> mesi = {};

  /// I riassunti degli anni, nella forma del server.
  final Map<String, Map<String, Object?>> anni = {};

  /// I contenuti per chiave, nella forma del server (`{v, c, nota}`).
  final Map<String, Map<String, Object?>> contenuti = {};

  /// Ogni annotazione e ogni stella ricevute, coi loro campi: la prova che
  /// la riga della persona non va a nessun modello guarda anche qui.
  final List<Map<String, Object?>> chiamate = [];

  int letture = 0;
  int scritture = 0;

  /// Mette una voce nel Diario finto, coi conti del riassunto.
  void metti(VoceDelRicordo v, {Map<String, Object?>? contenuto}) {
    (mesi[v.mese] ??= {})[v.chiave] = v;
    final anno = '${v.quando.year}';
    final r = anni[anno] ??= {
      'mesi': <String, Object?>{},
      'stelle': <String, Object?>{}
    };
    final m = (r['mesi'] as Map<String, Object?>).putIfAbsent(
        v.mese.substring(5), () => <String, Object?>{}) as Map<String, Object?>;
    for (final e in RegistroDeiRicordi.etichetteDi(v)) {
      m[e] = ((m[e] as int?) ?? 0) + 1;
    }
    if (v.stella) {
      final s = r['stelle'] as Map<String, Object?>;
      final g = v.giorno.substring(5);
      s[g] = ((s[g] as int?) ?? 0) + 1;
    }
    if (contenuto != null) contenuti[v.chiave] = contenuto;
  }

  @override
  Future<bool> manda(String mese, List<VoceDelRicordo> righe) async => true;

  @override
  Future<List<VoceDelRicordo>> leggi(String mese) async {
    letture++;
    return [...?mesi[mese]?.values];
  }

  @override
  Future<Map<String, Object?>?> leggiAnno(String anno) async {
    letture++;
    return anni[anno];
  }

  @override
  Future<bool> annota({
    required String chiave,
    required DateTime quando,
    required String tipo,
    required String arte,
    required String maestro,
    required String titolo,
    required Map<String, Object?> contenuto,
  }) async {
    scritture++;
    chiamate.add({'annota': chiave, 'contenuto': contenuto});
    if (mesi[VoceDelRicordo.chiaveDelMese(quando)]?.containsKey(chiave) ??
        false) {
      return true;
    }
    metti(
      VoceDelRicordo(
        quando: quando,
        arte: arte,
        maestro: maestro,
        titolo: titolo,
        tipo: tipo == 'conversazione'
            ? TipoDelRicordo.conversazione
            : TipoDelRicordo.responso,
        riferimento: chiave,
        chiaveDelDiario: chiave,
      ),
      contenuto: {'v': 1, 'c': contenuto},
    );
    return true;
  }

  @override
  Future<bool> stella({
    required String chiave,
    required DateTime quando,
    required bool stella,
    String? nota,
  }) async {
    scritture++;
    chiamate.add({'stella': chiave, 'valore': stella, 'nota': nota});
    final mese = mesi[VoceDelRicordo.chiaveDelMese(quando)];
    final v = mese?[chiave];
    if (v != null) mese![chiave] = v.conStella(stella);
    if (nota != null) {
      contenuti[chiave] = {...?contenuti[chiave], 'nota': nota};
    }
    return true;
  }

  @override
  Future<Map<String, Object?>?> leggiVoce(String chiave) async {
    letture++;
    return contenuti[chiave];
  }
}
