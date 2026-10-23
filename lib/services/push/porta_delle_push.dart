/// IL CANALE DELLE PUSH. Ordine CG voce 16.
///
/// **Il fatto che ha aperto la voce**, parole del fondatore del 30 agosto
/// 2026: "da quando ho iniziato a installare le varie build dell'APP NON HO
/// MAI RICEVUTO ALCUNA NOTIFICA PUSH PER I DONI, MAI!". La ragione era che il
/// canale non esisteva: tutte le notifiche del Cerchio erano LOCALI,
/// programmate sul telefono, e nessun server mandava niente.
///
/// **IL TOKEN E' UN DATO NUOVO E VA CUSTODITO ACCANTO AL CERCHIO.** Sta sotto
/// il prefisso `push.` che e' gia' in `CioCheETuo`, quindi se ne va con la
/// cancellazione, ed e' nominato nella privacy policy.
///
/// **LA CURA DEL TOKEN CHE SCADE, che e' la parte che tutti dimenticano.** Un
/// token non e' per sempre: il sistema lo rigenera quando l'app si
/// reinstalla, quando si ripristina un backup, e ogni tanto per conto suo.
/// `onTokenRefresh` lo dice, e qui si ascolta: senza, dopo la prima
/// rigenerazione il server spingerebbe verso un indirizzo morto e la persona
/// smetterebbe di ricevere le push senza che nessuno se ne accorga, cioe'
/// esattamente il difetto da cui questa voce nasce.
library;

import 'package:flutter/foundation.dart';

/// Cosa il server deve sapere per spingere all'ora giusta.
///
/// **Non e' il token e basta.** Il server deve sapere QUALI Doni la persona
/// ha acceso, a CHE ORA li vuole, e in quale FUSO vive: senza le tre cose
/// insieme spingerebbe a tutti alla stessa ora, cioe' alle sette del mattino
/// di Roma anche a chi sta a Tokyo.
@immutable
class ScelteDaMandare {
  const ScelteDaMandare({
    required this.token,
    required this.fuso,
    required this.doni,
  });

  final String token;

  /// Il nome IANA del fuso, per esempio `Europe/Rome`.
  final String fuso;

  /// Per ogni Dono acceso, i minuti dalla mezzanotte a cui lo vuole.
  final Map<String, int> doni;

  Map<String, Object?> aMappa() => {
        'token': token,
        'fuso': fuso,
        'doni': doni,
      };

  @override
  bool operator ==(Object other) =>
      other is ScelteDaMandare &&
      other.token == token &&
      other.fuso == fuso &&
      _stesseScelte(other.doni, doni);

  @override
  int get hashCode => Object.hash(
      token,
      fuso,
      Object.hashAllUnordered(
          [for (final e in doni.entries) '${e.key}:${e.value}']));

  static bool _stesseScelte(Map<String, int> a, Map<String, int> b) {
    if (a.length != b.length) return false;
    for (final e in a.entries) {
      if (b[e.key] != e.value) return false;
    }
    return true;
  }
}

/// Chi porta le scelte al server.
abstract class PortaDelleScelte {
  const PortaDelleScelte();

  /// Manda le scelte. Torna vero se il server le ha prese.
  Future<bool> manda(ScelteDaMandare scelte);

  /// Toglie il token, quando la persona spegne tutto oppure se ne va.
  Future<bool> togli();
}

/// La porta spenta: non manda niente.
class PortaSpentaDelleScelte extends PortaDelleScelte {
  const PortaSpentaDelleScelte();

  @override
  Future<bool> manda(ScelteDaMandare scelte) async => false;

  @override
  Future<bool> togli() async => false;
}
