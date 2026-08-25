import 'dart:math' as math;

import '../astro/celestial.dart';
import '../astro/effemeridi.dart';
import '../astro/natal_chart.dart';
import '../astro/zodiac.dart';
import '../identity/birth_identity.dart';
import 'vip_catalog.dart';

/// I PUNTI CHE ENTRANO NELLA SINASTRIA, e perche' sono questi.
///
/// L'ordine BO voce 02 ne nomina cinque, Sole, Luna, Venere, Marte e
/// Ascendente. **Qui ce n'e' un sesto, Mercurio, ed e' una scelta dichiarata**:
/// la schermata mostra da sempre una barra che si chiama "Intesa mentale", e
/// Mercurio e' il pianeta che nella tradizione la regge. Calcolarla senza di
/// lui avrebbe voluto dire misurare la testa con i pianeti del cuore.
/// `Effemeridi` lo da' gia', quindi non costa niente in piu'.
enum PuntoDelCielo {
  sole('Sole', '☉', CorpoCeleste.sole, femminile: false),
  luna('Luna', '☽', CorpoCeleste.luna, femminile: true),
  mercurio('Mercurio', '☿', CorpoCeleste.mercurio, femminile: false),
  venere('Venere', '♀', CorpoCeleste.venere, femminile: true),
  marte('Marte', '♂', CorpoCeleste.marte, femminile: false),

  /// L'Ascendente non e' un corpo: nasce dall'ora e dal luogo, e senza quelli
  /// non esiste. Chi non li ha non lo porta, e la lettura lo dichiara.
  ascendente('Ascendente', 'Asc', null, femminile: false);

  const PuntoDelCielo(this.nome, this.glifo, this.corpo,
      {required this.femminile});

  final String nome;
  final String glifo;

  /// Il corpo delle effemeridi, oppure nullo per l'Ascendente.
  final CorpoCeleste? corpo;

  /// **IL GENERE DEL PUNTO, e non e' un vezzo.** La prima stesura del responso
  /// scriveva "il suo Luna in sestile al tuo Marte": una lingua che si accorda
  /// da sola non esiste, o si dichiara come si declina o si scrive male. E'
  /// la stessa lezione gia' imparata dal residuo dei budget.
  final bool femminile;

  /// "il suo Marte", "la sua Luna".
  String get ilSuo => femminile ? 'la sua' : 'il suo';

  /// "al tuo Marte", "alla tua Luna".
  String get alTuo => femminile ? 'alla tua' : 'al tuo';

  /// "il tuo Marte", "la tua Luna".
  String get ilTuo => femminile ? 'la tua' : 'il tuo';

  /// "al suo Marte", "alla sua Luna". Serve al confronto fra due VIP, dove
  /// nessuno dei due lati sei tu.
  String get alSuo => femminile ? 'alla sua' : 'al suo';
}

/// IL CIELO DI UNA PERSONA per la Sinastria: le longitudini dei punti che
/// contano, e niente altro.
///
/// **Nasce in locale, senza rete.** `Effemeridi` e' aritmetica pura, quindi il
/// cielo di un VIP si calcola sul dispositivo alla velocita' di una moltiplicazione
/// e cinquanta cieli costano quanto uno. Non c'e' nessuna chiamata, nessuna
/// chiave, nessuna cache da tenere allineata.
class CieloDiSinastria {
  const CieloDiSinastria({
    required this.longitudini,
    required this.segnoSolare,
    required this.oraNota,
    this.nome = '',
  });

  /// Longitudine eclittica di ogni punto presente. L'Ascendente c'e' solo con
  /// ora e luogo.
  final Map<PuntoDelCielo, double> longitudini;

  final Zodiac segnoSolare;

  /// Se l'ora di nascita e' nota. Quando e' falsa **l'Ascendente non c'e'** e
  /// la lettura lo dice, invece di inventarne uno.
  final bool oraNota;

  final String nome;

  bool get haAscendente => longitudini.containsKey(PuntoDelCielo.ascendente);

  /// Il cielo di un VIP dal suo dossier.
  factory CieloDiSinastria.perVip(Vip vip) => CieloDiSinastria.perNascita(
        momentoUtc: vip.momentoDiNascita,
        oraNota: vip.ora.eNota,
        latitudine: vip.luogoDiNascita?.latitudine,
        longitudineDelLuogo: vip.luogoDiNascita?.longitudine,
        segnoDichiarato: vip.sign,
        nome: vip.name,
      );

  /// Il cielo della persona dalla sua identita' di nascita.
  ///
  /// Il momento e' locale: si porta a tempo universale con l'offset del luogo,
  /// che e' quello che `BirthPlace` gia' dichiara. Senza luogo si prende il
  /// momento com'e', e in cambio non si calcola nessun Ascendente: sono le
  /// stesse due condizioni, e non e' un caso.
  factory CieloDiSinastria.perIdentita(BirthIdentity identita,
      {String nome = ''}) {
    final luogo = identita.birthPlace;
    final momento = luogo == null
        ? DateTime.utc(
            identita.birthMoment.year,
            identita.birthMoment.month,
            identita.birthMoment.day,
            identita.birthMoment.hour,
            identita.birthMoment.minute,
          )
        : DateTime.utc(
            identita.birthMoment.year,
            identita.birthMoment.month,
            identita.birthMoment.day,
            identita.birthMoment.hour,
            identita.birthMoment.minute,
          ).subtract(Duration(minutes: luogo.utcOffsetMinutes));
    return CieloDiSinastria.perNascita(
      momentoUtc: momento,
      oraNota: identita.hasBirthTime,
      latitudine: luogo?.latitude,
      longitudineDelLuogo: luogo?.longitude,
      nome: nome,
    );
  }

  /// IL CIELO DAI PEZZI NUDI, che e' la porta che tutti gli altri usano.
  ///
  /// **Prende numeri e non classi, ed e' voluto.** Nel progetto convivono due
  /// modelli del luogo di nascita, `core/identity/birth_place.dart` e
  /// `core/astro/birth_place.dart`, con campi diversi. Legare il cielo a uno
  /// dei due avrebbe costretto l'altro a una conversione, e le conversioni
  /// fra modelli quasi uguali sono il posto dove i dati si perdono. Qui
  /// entrano il momento in tempo universale, se l'ora e' nota e le due
  /// coordinate: chiunque li abbia puo' chiedere il proprio cielo.
  factory CieloDiSinastria.perNascita({
    required DateTime momentoUtc,
    required double? latitudine,
    required double? longitudineDelLuogo,
    Zodiac? segnoDichiarato,
    String nome = '',
    bool oraNota = false,
  }) {
    final jd = Celestial.julianDay(momentoUtc);
    final tutte = Effemeridi.tutte(jd);
    final punti = <PuntoDelCielo, double>{};
    for (final p in PuntoDelCielo.values) {
      final corpo = p.corpo;
      if (corpo == null) continue;
      final lon = tutte[corpo];
      if (lon != null) punti[p] = lon;
    }
    // **L'ASCENDENTE SOLO CON ORA E LUOGO, mai per ripiego.** Servono tutti e
    // due: senza ora si sposta di quindici gradi ogni ora, senza latitudine
    // non si puo' proprio calcolare. Costruirne uno a mezzogiorno darebbe un
    // numero esatto e falso, che e' il difetto peggiore di tutti.
    if (oraNota && latitudine != null && longitudineDelLuogo != null) {
      punti[PuntoDelCielo.ascendente] =
          ascendenteDi(jd, latitudine, longitudineDelLuogo);
    }
    final sole = punti[PuntoDelCielo.sole] ?? 0;
    return CieloDiSinastria(
      longitudini: punti,
      segnoSolare: segnoDichiarato ?? segnoDiLongitudine(sole),
      oraNota: oraNota,
      nome: nome,
    );
  }

  /// **IL CIELO COME CARTA NATALE, per la ruota che l'app disegna gia'.**
  ///
  /// Ordine BO voce 06: la ruota e' `NatalWheel`, e vuole un `NatalChart`.
  /// Questa non e' una seconda carta: e' lo stesso cielo detto nella forma che
  /// il disegno capisce, con i sei punti che la Sinastria calcola e niente
  /// altro. L'Ascendente entra come orientamento solo quando c'e' davvero.
  NatalChart get comeCarta => NatalChart(
        sunSign: segnoSolare,
        hasTime: haAscendente,
        ascendantLongitude: longitudini[PuntoDelCielo.ascendente],
        ascendant: longitudini[PuntoDelCielo.ascendente] == null
            ? null
            : segnoDiLongitudine(longitudini[PuntoDelCielo.ascendente]!),
        planets: [
          for (final p in PuntoDelCielo.values)
            if (p.corpo != null && longitudini[p] != null)
              PlanetPosition(
                id: p.corpo!.id,
                name: p.nome,
                glyph: p.glifo,
                longitude: longitudini[p]!,
                sign: segnoDiLongitudine(longitudini[p]!),
              ),
        ],
      );

  /// Il segno in cui cade una longitudine eclittica.
  static Zodiac segnoDiLongitudine(double longitudine) {
    final l = ((longitudine % 360) + 360) % 360;
    return Zodiac.values[(l ~/ 30) % 12];
  }

  /// L'ASCENDENTE, dal tempo siderale locale e dalla latitudine.
  ///
  /// E' la formula classica: l'Ascendente e' il punto dell'eclittica che sorge
  /// all'orizzonte est, e si ricava dall'arco siderale locale, dall'obliquita'
  /// dell'eclittica e dalla latitudine del luogo. Il tempo siderale locale e
  /// l'obliquita' li da' gia' `Celestial`, che li usa per il cielo del giorno:
  /// qui non ne nasce una seconda definizione.
  static double ascendenteDi(double jd, double latitudine, double longitudine) {
    const grad = math.pi / 180.0;
    final lst = Celestial.localSiderealDegrees(jd, longitudine);
    final eps = Celestial.obliquitaEclittica(jd) * grad;
    final ramc = lst * grad;
    final lat = latitudine * grad;
    // tan(Asc) = cos(RAMC) / ( -sin(RAMC) cos(eps) - tan(lat) sin(eps) )
    final y = math.cos(ramc);
    final x = -math.sin(ramc) * math.cos(eps) - math.tan(lat) * math.sin(eps);
    var asc = math.atan2(y, x) / grad;
    asc = ((asc % 360) + 360) % 360;
    return asc;
  }
}

/// Un aspetto fra un punto del cielo di uno e un punto del cielo dell'altro.
class AspettoDiSinastria {
  const AspettoDiSinastria({
    required this.tuo,
    required this.suo,
    required this.tipo,
    required this.orbo,
  });

  /// Il punto della persona che guarda.
  final PuntoDelCielo tuo;

  /// Il punto del VIP.
  final PuntoDelCielo suo;

  final AspectType tipo;

  /// Di quanto l'aspetto e' lontano dall'angolo esatto, in gradi.
  final double orbo;

  /// Quanto e' forte: uno all'angolo esatto, zero al limite dell'orbo.
  double forzaCon(double orboAmmesso) =>
      orboAmmesso <= 0 ? 0 : (1 - orbo / orboAmmesso).clamp(0.0, 1.0);

  /// **IL FATTO VERO, DETTO IN UNA RIGA.** E' cio' che l'ordine chiede al
  /// responso: quale pianeta di lui tocca quale punto tuo, e con che angolo.
  String get fatto => '${suo.ilSuo} ${suo.nome} '
      'in ${tipo.italianName.toLowerCase()} ${tuo.alTuo} ${tuo.nome}';

  /// Come si nomina in una lista, col grado di scarto.
  String get titolo => '${suo.nome} ${tipo.italianName} ${tuo.nome}';

  /// Lo scarto dall'angolo esatto, come si scrive in italiano.
  String get gradi =>
      '${orbo.toStringAsFixed(1).replaceAll('.', ',')} gradi';

  /// **COSA SIGNIFICA QUESTO ASPETTO, in una frase. Ordine BO voce 08.**
  ///
  /// Non e' un testo generato: e' composto da due pezzi dichiarati, cosa
  /// dicono i due punti messi insieme e cosa fa quell'angolo fra loro. La
  /// tradizione sinastrica dice esattamente questo, e la stessa coppia da'
  /// sempre la stessa frase.
  ///
  /// **La fonte e' una sola**: sia la bolla che si apre al tocco sul filo, sia
  /// il responso, leggono da qui. Due testi scritti in due posti per la
  /// stessa cosa divergono al primo che ne cambia uno.
  String get significato {
    final campo = _campiDelContatto[{suo, tuo}.length == 1
            ? _CampoDelContatto.specchio
            : _campoFra(suo, tuo)] ??
        'due parti di voi che si riconoscono';
    final angolo = _angoli[tipo]!;
    return 'Qui $campo. L\'angolo $angolo.';
  }

  static _CampoDelContatto _campoFra(PuntoDelCielo a, PuntoDelCielo b) {
    final due = {a, b};
    if (due.contains(PuntoDelCielo.venere) &&
        due.contains(PuntoDelCielo.marte)) {
      return _CampoDelContatto.attrazione;
    }
    if (due.contains(PuntoDelCielo.venere) ||
        due.contains(PuntoDelCielo.luna)) {
      return _CampoDelContatto.affetto;
    }
    if (due.contains(PuntoDelCielo.mercurio)) {
      return _CampoDelContatto.parola;
    }
    if (due.contains(PuntoDelCielo.marte)) {
      return _CampoDelContatto.spinta;
    }
    if (due.contains(PuntoDelCielo.ascendente)) {
      return _CampoDelContatto.presenza;
    }
    return _CampoDelContatto.identita;
  }

  static const Map<_CampoDelContatto, String> _campiDelContatto = {
    _CampoDelContatto.attrazione:
        'si toccano il desiderio di uno e il modo di amare dell\'altro',
    _CampoDelContatto.affetto: 'si toccano l\'affetto e la cura',
    _CampoDelContatto.parola: 'si tocca il modo di pensare e di dirsi le cose',
    _CampoDelContatto.spinta: 'si tocca la spinta a fare, con l\'urto che ne viene',
    _CampoDelContatto.presenza:
        'si tocca il modo in cui uno appare all\'altro la prima volta',
    _CampoDelContatto.identita: 'si toccano due modi di essere se stessi',
    _CampoDelContatto.specchio:
        'lo stesso punto di uno guarda quello dell\'altro, come in uno specchio',
  };

  static const Map<AspectType, String> _angoli = {
    AspectType.conjunction: 'li fonde, nel bene e nel troppo',
    AspectType.sextile: 'li fa collaborare, se qualcuno comincia',
    AspectType.square: 'li mette in attrito: un attrito che insegna',
    AspectType.trine: 'li fa scorrere senza sforzo',
    AspectType.opposition: 'li mette uno di fronte all\'altro',
  };
}

/// Il campo della vita che due punti, messi insieme, toccano.
enum _CampoDelContatto {
  attrazione,
  affetto,
  parola,
  spinta,
  presenza,
  identita,
  specchio,
}

/// GLI ASPETTI FRA DUE CIELI.
class AspettiDiSinastria {
  const AspettiDiSinastria._();

  /// GLI ORBI DELLA SINASTRIA, e non sono quelli dei transiti.
  ///
  /// **La differenza e' di natura, non di gusto.** Un transito descrive una
  /// finestra che si apre e si chiude in giorni, quindi `AspettiDiOggi` la
  /// tiene stretta a cinque gradi e a due per la Luna. Un aspetto di sinastria
  /// descrive un rapporto che non cambia: e' della stessa famiglia degli
  /// aspetti natali, che le tavole portano fino a otto e dieci gradi. La
  /// scelta di questo progetto, dentro quella forbice e dichiarata come
  /// scelta: **sei gradi sugli aspetti maggiori, quattro sul sestile**, che in
  /// ogni tavola prende meno degli altri.
  static const Map<AspectType, double> orbo = {
    AspectType.conjunction: 6.0,
    AspectType.opposition: 6.0,
    AspectType.square: 6.0,
    AspectType.trine: 6.0,
    AspectType.sextile: 4.0,
  };

  /// Gli aspetti fra i due cieli, dal piu' stretto al piu' largo.
  ///
  /// L'ordine e' per orbo crescente perche' nella tradizione un aspetto e'
  /// tanto piu' forte quanto piu' e' vicino all'angolo esatto. A parita' di
  /// orbo vince l'ordine dei punti, cosi' due esecuzioni danno sempre la
  /// stessa lista: **il responso e' deterministico e non contiene nessuna
  /// casualita'**.
  static List<AspettoDiSinastria> fra(
      CieloDiSinastria tuo, CieloDiSinastria suo) {
    final trovati = <AspettoDiSinastria>[];
    for (final a in PuntoDelCielo.values) {
      final la = tuo.longitudini[a];
      if (la == null) continue;
      for (final b in PuntoDelCielo.values) {
        final lb = suo.longitudini[b];
        if (lb == null) continue;
        for (final tipo in AspectType.values) {
          final candidato =
              ChartAspect(aLongitude: la, bLongitude: lb, type: tipo);
          if (candidato.orbe <= orbo[tipo]!) {
            trovati.add(AspettoDiSinastria(
                tuo: a, suo: b, tipo: tipo, orbo: candidato.orbe));
            // Due aspetti diversi non possono valere fra la stessa coppia di
            // punti: gli angoli tolemaici distano almeno trenta gradi e
            // l'orbo piu' largo e' sei.
            break;
          }
        }
      }
    }
    trovati.sort((x, y) {
      final perOrbo = x.orbo.compareTo(y.orbo);
      if (perOrbo != 0) return perOrbo;
      final perSuo = x.suo.index.compareTo(y.suo.index);
      if (perSuo != 0) return perSuo;
      return x.tuo.index.compareTo(y.tuo.index);
    });
    return trovati;
  }
}
