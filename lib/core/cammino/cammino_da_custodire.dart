import '../astro/birth_details.dart';
import '../identity/birth_identity.dart';
import '../identity/birth_place.dart';

/// IL CAMMINO CHE VIAGGIA FRA IL TELEFONO E IL CERCHIO. Ordine AP voce 01.
///
/// **Il fatto che apre quest'ordine.** Mauro ha disinstallato e reinstallato
/// l'app sulla 2183, e' rientrato con lo stesso account Google, e il
/// borsellino e' tornato solo visitando il Passport mentre i traguardi accesi
/// non sono tornati affatto. Il Cerchio ricordava il DENARO e non il CAMMINO:
/// diario dei gesti, Sigilli accesi, identita' di nascita e archetipo
/// vivevano solo in `SharedPreferences`, e con l'app se ne andavano.
///
/// **Questa classe non decide niente**, e la scelta e' voluta: e' solo la
/// forma con cui il cammino si scrive e si rilegge. Chi lo FONDE e' il
/// server, in `functions/src/cammino.ts`, e sta li' in un punto solo: se la
/// regola vivesse anche qui sarebbero due regole, e il giorno che una cambia
/// il cammino di qualcuno si spezzerebbe a meta'. Il telefono manda cio' che
/// ha e adotta cio' che torna.
///
/// **La forma si estende senza rompere chi legge una versione vecchia**: ogni
/// campo e' opzionale e chi non lo conosce lo ignora.
class CamminoDaCustodire {
  const CamminoDaCustodire({
    this.identita,
    this.gesti = const {},
    this.giorni = const {},
    this.oreGiuste = const {},
    this.serie = const {},
    this.sigilli = const {},
    this.archetipoDominante,
    this.archetipoQuando,
    this.artiPreferite = const [],
    this.primoGiorno,
    this.ultimoGiorno,
  });

  /// L'identita' di nascita: cio' che la persona ha DATO, non cio' che si
  /// calcola. La carta natale non viaggia, perche' nasce da questi dati
  /// ogni volta uguale e custodirla sarebbe una seconda verita'.
  final IdentitaDaCustodire? identita;

  /// Quante volte ogni gesto e' stato compiuto: e' il conto su cui maturano
  /// i traguardi, quello che l'ordine AO voce 04 ha visto azzerarsi.
  final Map<String, int> gesti;

  /// In quanti giorni diversi ogni gesto e' stato compiuto.
  final Map<String, int> giorni;

  /// Quante volte ogni gesto e' caduto nella sua ora rituale.
  final Map<String, int> oreGiuste;

  /// I giorni di seguito per rito.
  final Map<String, int> serie;

  /// I Sigilli accesi: id del traguardo, e quando si e' acceso.
  final Map<String, DateTime> sigilli;

  /// L'archetipo e il giorno del test, che governa i tre mesi dell'ordine AO
  /// voce 06: senza la data, chi cambia telefono ricomincerebbe l'attesa.
  final String? archetipoDominante;
  final DateTime? archetipoQuando;

  /// Le arti preferite, nell'ordine scelto dalla persona.
  final List<String> artiPreferite;

  final DateTime? primoGiorno;
  final DateTime? ultimoGiorno;

  /// Vero se non c'e' proprio niente da custodire: si evita di mandare un
  /// guscio vuoto a ogni apertura.
  bool get eVuoto =>
      identita == null &&
      gesti.isEmpty &&
      giorni.isEmpty &&
      oreGiuste.isEmpty &&
      serie.isEmpty &&
      sigilli.isEmpty &&
      archetipoDominante == null &&
      artiPreferite.isEmpty;

  Map<String, Object?> aMappa() => {
        if (identita != null) 'identita': identita!.aMappa(),
        if (gesti.isNotEmpty) 'gesti': gesti,
        if (giorni.isNotEmpty) 'giorni': giorni,
        if (oreGiuste.isNotEmpty) 'oreGiuste': oreGiuste,
        if (serie.isNotEmpty) 'serie': serie,
        if (sigilli.isNotEmpty)
          'sigilli': {
            for (final voce in sigilli.entries)
              voce.key: voce.value.toIso8601String(),
          },
        if (archetipoDominante != null || archetipoQuando != null)
          'archetipo': {
            if (archetipoDominante != null) 'dominante': archetipoDominante,
            if (archetipoQuando != null)
              'quando': archetipoQuando!.toIso8601String(),
          },
        if (artiPreferite.isNotEmpty) 'artiPreferite': artiPreferite,
        if (primoGiorno != null) 'primoGiorno': primoGiorno!.toIso8601String(),
        if (ultimoGiorno != null)
          'ultimoGiorno': ultimoGiorno!.toIso8601String(),
      };

  /// Rilegge il cammino che il Cerchio ha restituito.
  ///
  /// **Non si fida di niente**: una risposta puo' arrivare da un server piu'
  /// nuovo, da uno piu' vecchio o da una rete che ha rotto qualcosa, e cio'
  /// che entra nel diario ci resta.
  static CamminoDaCustodire? daMappa(Object? risposta) {
    if (risposta is! Map) return null;
    Map<String, int> conta(Object? grezzo) {
      final fuori = <String, int>{};
      if (grezzo is Map) {
        for (final voce in grezzo.entries) {
          final valore = voce.value;
          if (valore is num && valore >= 0) {
            fuori['${voce.key}'] = valore.toInt();
          }
        }
      }
      return fuori;
    }

    final sigilli = <String, DateTime>{};
    final grezziSigilli = risposta['sigilli'];
    if (grezziSigilli is Map) {
      for (final voce in grezziSigilli.entries) {
        final quando = DateTime.tryParse('${voce.value}');
        if (quando != null) sigilli['${voce.key}'] = quando;
      }
    }

    final archetipo = risposta['archetipo'];
    String? dominante;
    DateTime? quandoArchetipo;
    if (archetipo is Map) {
      final d = archetipo['dominante'];
      if (d is String && d.isNotEmpty) dominante = d;
      quandoArchetipo = DateTime.tryParse('${archetipo['quando']}');
    }

    final arti = <String>[];
    final grezzeArti = risposta['artiPreferite'];
    if (grezzeArti is List) {
      for (final voce in grezzeArti) {
        if (voce is String && voce.isNotEmpty) arti.add(voce);
      }
    }

    return CamminoDaCustodire(
      identita: IdentitaDaCustodire.daMappa(risposta['identita']),
      gesti: conta(risposta['gesti']),
      giorni: conta(risposta['giorni']),
      oreGiuste: conta(risposta['oreGiuste']),
      serie: conta(risposta['serie']),
      sigilli: sigilli,
      archetipoDominante: dominante,
      archetipoQuando: quandoArchetipo,
      artiPreferite: arti,
      primoGiorno: DateTime.tryParse('${risposta['primoGiorno']}'),
      ultimoGiorno: DateTime.tryParse('${risposta['ultimoGiorno']}'),
    );
  }
}

/// L'IDENTITA' DI NASCITA CUSTODITA: cio' che la persona ha dato.
class IdentitaDaCustodire {
  const IdentitaDaCustodire({
    this.nome,
    this.giorno,
    this.ora,
    this.luogo,
    this.latitudine,
    this.longitudine,
    this.fuso,
    this.scarto,
  });

  final String? nome;

  /// Il giorno di nascita, solo la data.
  final DateTime? giorno;

  /// L'ora di nascita, "HH:MM", assente quando non e' stata data: e' la
  /// stessa distinzione che governa l'Ascendente.
  final String? ora;

  final String? luogo;
  final double? latitudine;
  final double? longitudine;
  final String? fuso;

  /// Lo scarto dal tempo universale in minuti, come lo conosce il luogo.
  final int? scarto;

  /// Vero quando c'e' abbastanza per non rifare l'onboarding da capo.
  bool get bastaPerNonRifarlo => giorno != null;

  /// Vero quando c'e' tutto, ora e luogo compresi.
  bool get eCompleta => giorno != null && ora != null && luogo != null;

  Map<String, Object?> aMappa() => {
        if (nome != null) 'nome': nome,
        if (giorno != null)
          'giorno': giorno!.toIso8601String().substring(0, 10),
        if (ora != null) 'ora': ora,
        if (luogo != null) 'luogo': luogo,
        if (latitudine != null) 'latitudine': latitudine,
        if (longitudine != null) 'longitudine': longitudine,
        if (fuso != null) 'fuso': fuso,
        if (scarto != null) 'scarto': scarto,
      };

  static IdentitaDaCustodire? daMappa(Object? grezzo) {
    if (grezzo is! Map) return null;
    final nome = grezzo['nome'];
    final ora = grezzo['ora'];
    final luogo = grezzo['luogo'];
    final lat = grezzo['latitudine'];
    final lon = grezzo['longitudine'];
    final fuso = grezzo['fuso'];
    final identita = IdentitaDaCustodire(
      nome: nome is String && nome.isNotEmpty ? nome : null,
      giorno: DateTime.tryParse('${grezzo['giorno']}'),
      ora: ora is String && ora.isNotEmpty ? ora : null,
      luogo: luogo is String && luogo.isNotEmpty ? luogo : null,
      latitudine: lat is num ? lat.toDouble() : null,
      longitudine: lon is num ? lon.toDouble() : null,
      fuso: fuso is String && fuso.isNotEmpty ? fuso : null,
      scarto: grezzo['scarto'] is num ? (grezzo['scarto'] as num).toInt() : null,
    );
    final vuota = identita.nome == null &&
        identita.giorno == null &&
        identita.ora == null &&
        identita.luogo == null;
    return vuota ? null : identita;
  }

  /// L'identita' di nascita come la vuole il resto dell'app.
  ///
  /// Torna nullo senza il giorno: senza la data di nascita non c'e' nessuna
  /// identita' da ricostruire, e inventarne una col giorno di oggi darebbe
  /// una carta natale falsa.
  BirthIdentity? aBirthIdentity() {
    final data = giorno;
    if (data == null) return null;
    int? oraH;
    int? oraM;
    final pezzi = ora?.split(':');
    if (pezzi != null && pezzi.length == 2) {
      oraH = int.tryParse(pezzi[0]);
      oraM = int.tryParse(pezzi[1]);
    }
    return BirthIdentity.fromParts(
      birthDate: data,
      birthHour: oraH,
      birthMinute: oraM,
      birthPlace: (luogo == null || latitudine == null || longitudine == null)
          ? null
          : BirthPlace(
              city: luogo!,
              latitude: latitudine!,
              longitude: longitudine!,
              // **IL FUSO E LO SCARTO, quando il Cerchio non li ha.** Senza
              // fuso si mette quello di Roma, che e' il ripiego dichiarato
              // altrove nel progetto, e lo scarto si ricava da li': un luogo
              // senza fuso non si puo' collocare nel tempo, e inventarne uno
              // a zero sposterebbe la carta di due ore.
              timeZoneId: fuso ?? 'Europe/Rome',
              utcOffsetMinutes: scarto ?? 60,
              isApproximate: fuso == null,
            ),
    );
  }

  /// L'identita' da custodire, presa dai DETTAGLI DI NASCITA che il Cerchio
  /// ha raccolto: la data, l'ora quando c'e', il luogo quando c'e'.
  ///
  /// **E' questa la porta che usa il custode**, non quella dell'identita'
  /// completa: `BirthIdentityController` espone i dettagli, ed e' li' che
  /// vive cio' che la persona ha DATO. Passare dalla carta natale sarebbe
  /// passare da cio' che si CALCOLA.
  static IdentitaDaCustodire? daiDettagli(
    BirthDetails? dettagli, {
    String? nome,
  }) {
    if (dettagli == null) return null;
    String due(int n) => n.toString().padLeft(2, '0');
    final ora = dettagli.time;
    return IdentitaDaCustodire(
      nome: nome,
      giorno: DateTime(
          dettagli.date.year, dettagli.date.month, dettagli.date.day),
      ora: ora == null ? null : '${due(ora.hour)}:${due(ora.minute)}',
      // **IL LUOGO DELL'ASTRONOMIA, e non quello dell'identita'.** Nel
      // progetto vivono due `BirthPlace`: quello di `core/astro`, che i
      // dettagli di nascita portano con se', e quello di `core/identity`.
      // Qui si legge il primo, che e' quello che il Cerchio ha raccolto.
      luogo: dettagli.place?.label,
      latitudine: dettagli.place?.latitude,
      longitudine: dettagli.place?.longitude,
      fuso: dettagli.place?.timezone,
    );
  }

  /// L'identita' da custodire, presa da quella dell'app.
  static IdentitaDaCustodire? da(BirthIdentity? identita, {String? nome}) {
    if (identita == null || identita.isExample) return null;
    final m = identita.birthMoment;
    String due(int n) => n.toString().padLeft(2, '0');
    return IdentitaDaCustodire(
      nome: nome,
      giorno: DateTime(m.year, m.month, m.day),
      ora: identita.hasBirthTime ? '${due(m.hour)}:${due(m.minute)}' : null,
      luogo: identita.birthPlace?.city,
      latitudine: identita.birthPlace?.latitude,
      longitudine: identita.birthPlace?.longitude,
      fuso: identita.birthPlace?.timeZoneId,
      scarto: identita.birthPlace?.utcOffsetMinutes,
    );
  }
}
