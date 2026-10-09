/// I BERSAGLI DELL'INDICATORE DEL REAL TIME COSMO. Ordine FH parti 5 e 10.
///
/// Un bersaglio sa due cose: dove sta nel cielo calcolato (un versore
/// dell'orizzonte) e a che altezza sta in un istante qualunque, che serve a
/// dire quando sorge. Tutte e due passano dalle porte uniche del cielo:
/// `Celestial.equatorialToHorizontal` per la conversione, `IlCieloDiMeeus`
/// per il Sole, la Luna e i pianeti. L'ora di levata e' la regola del Cielo
/// esistente, in un posto solo: `primoIstanteSopra` (voce 7.4).
library;

import 'dart:math' as math;

import '../celestial.dart';
import '../il_primo_istante_sopra.dart';
import '../meeus/il_cielo_di_meeus.dart';
import '../sky.dart' show kAltezzaOrizzonte;
import '../zodiac.dart';
import 'catalogo_delle_stelle.dart';
import 'il_cielo_in_un_istante.dart';
import 'le_linee_delle_figure.dart';

/// Le cinque categorie del menu (voce 5.3), nell'ordine del menu.
enum CategoriaDelBersaglio {
  ilTuoCielo('Il tuo cielo'),
  lunaESole('Luna e Sole'),
  pianeti('Pianeti'),
  costellazioni('Costellazioni'),
  nebuloseEGalassie('Nebulose e galassie');

  const CategoriaDelBersaglio(this.nome);
  final String nome;
}

typedef Versore = ({double x, double y, double z});

Versore _versore(double raDeg, double decDeg, double latDeg, double lstDeg) {
  final h = Celestial.equatorialToHorizontal(
      raDeg: raDeg, decDeg: decDeg, latDeg: latDeg, lstDeg: lstDeg);
  final alt = h.altDeg * math.pi / 180, az = h.azDeg * math.pi / 180;
  return (
    x: math.cos(alt) * math.sin(az),
    y: math.cos(alt) * math.cos(az),
    z: math.sin(alt),
  );
}

double _altezza(
        double raDeg, double decDeg, double jd, double lat, double lon) =>
    Celestial.equatorialToHorizontal(
      raDeg: raDeg,
      decDeg: decDeg,
      latDeg: lat,
      lstDeg: Celestial.localSiderealDegrees(jd, lon),
    ).altDeg;

abstract class BersaglioDelCielo {
  const BersaglioDelCielo(this.id, this.nome, this.categoria);

  final String id;

  /// Il nome a schermo: "I tuoi Gemelli", "La Luna", "Le Pleiadi".
  final String nome;
  final CategoriaDelBersaglio categoria;

  Versore versore(CieloInUnIstante cielo);
  double altezzaAllIstante(double jd, double lat, double lon);

  /// Vero se e' il Sole: la riga dell'indicatore porta il suo avviso
  /// (voce 5.7).
  bool get eIlSole => false;
}

/// Un punto fisso del cielo, alle sue coordinate J2000: il centro di una
/// figura, un oggetto del cielo profondo.
class BersaglioFisso extends BersaglioDelCielo {
  const BersaglioFisso(super.id, super.nome, super.categoria,
      {required this.raGradi, required this.decGradi});
  final double raGradi, decGradi;

  @override
  Versore versore(CieloInUnIstante cielo) =>
      _versore(raGradi, decGradi, cielo.latitudine, cielo.tempoSideraleLocale);

  @override
  double altezzaAllIstante(double jd, double lat, double lon) =>
      _altezza(raGradi, decGradi, jd, lat, lon);
}

/// Il Sole, la Luna o un pianeta, dove sono davvero.
class BersaglioCorpo extends BersaglioDelCielo {
  const BersaglioCorpo(super.id, super.nome, super.categoria, this.corpo);
  final CorpoCeleste corpo;

  @override
  bool get eIlSole => corpo == CorpoCeleste.sole;

  @override
  Versore versore(CieloInUnIstante cielo) {
    final c = cielo.corpo(corpo);
    return (x: c.x, y: c.y, z: c.z);
  }

  @override
  double altezzaAllIstante(double jd, double lat, double lon) {
    if (corpo == CorpoCeleste.luna) {
      final e = Celestial.moonEquatorial(jd);
      return _altezza(e.raDeg, e.decDeg, jd, lat, lon);
    }
    final e = IlCieloDiMeeus.equatoriali(IlCieloDiMeeus.longitudine(corpo, jd),
        IlCieloDiMeeus.latitudine(corpo, jd), jd);
    return _altezza(e.ascensioneRetta, e.declinazione, jd, lat, lon);
  }
}

/// Un pianeta della carta natale: il punto dell'eclittica dove stava alla
/// nascita, cioe' il suo grado dello zodiaco, cercato nel cielo di adesso.
class BersaglioNatale extends BersaglioDelCielo {
  const BersaglioNatale(String id, String nome, this.corpo, this.longitudine)
      : super(id, nome, CategoriaDelBersaglio.ilTuoCielo);
  final CorpoCeleste corpo;

  /// La longitudine eclittica alla nascita, in gradi.
  final double longitudine;

  @override
  Versore versore(CieloInUnIstante cielo) {
    final e = IlCieloDiMeeus.equatoriali(longitudine, 0, cielo.jd);
    return _versore(e.ascensioneRetta, e.declinazione, cielo.latitudine,
        cielo.tempoSideraleLocale);
  }

  @override
  double altezzaAllIstante(double jd, double lat, double lon) {
    final e = IlCieloDiMeeus.equatoriali(longitudine, 0, jd);
    return _altezza(e.ascensioneRetta, e.declinazione, jd, lat, lon);
  }
}

// ---------------------------------------------------------------------------
// IL CIELO PROFONDO (voce 10.1)
// ---------------------------------------------------------------------------

/// Un oggetto del cielo profondo, coi dati della voce 10.1.
class OggettoProfondo {
  const OggettoProfondo({
    required this.id,
    required this.nome,
    required this.sigla,
    required this.raGradi,
    required this.decGradi,
    required this.magnitudine,
    required this.larghezzaInPrimi,
    required this.asset,
  });
  final String id;
  final String nome;
  final String sigla;
  final double raGradi, decGradi, magnitudine, larghezzaInPrimi;

  /// Il nome del suo asset in `assets/img/cosmo/`.
  final String asset;

  BersaglioFisso get comeBersaglio =>
      BersaglioFisso(id, nome, CategoriaDelBersaglio.nebuloseEGalassie,
          raGradi: raGradi, decGradi: decGradi);
}

const List<OggettoProfondo> kCieloProfondo = [
  OggettoProfondo(
      id: 'm45',
      nome: 'Le Pleiadi',
      sigla: 'M45',
      raGradi: 56.75,
      decGradi: 24.12,
      magnitudine: 1.6,
      larghezzaInPrimi: 110,
      asset: 'pleiadi'),
  OggettoProfondo(
      id: 'm42',
      nome: 'La Nebulosa di Orione',
      sigla: 'M42',
      raGradi: 83.82,
      decGradi: -5.39,
      magnitudine: 4.0,
      larghezzaInPrimi: 65,
      asset: 'orione'),
  OggettoProfondo(
      id: 'm31',
      nome: 'La Galassia di Andromeda',
      sigla: 'M31',
      raGradi: 10.68,
      decGradi: 41.27,
      magnitudine: 3.4,
      larghezzaInPrimi: 178,
      asset: 'andromeda'),
  OggettoProfondo(
      id: 'm8',
      nome: 'La Nebulosa Laguna',
      sigla: 'M8',
      raGradi: 270.90,
      decGradi: -24.38,
      magnitudine: 6.0,
      larghezzaInPrimi: 90,
      asset: 'laguna'),
  OggettoProfondo(
      id: 'h_chi',
      nome: 'Il Doppio Ammasso del Perseo',
      sigla: 'NGC 869 e 884',
      raGradi: 34.75,
      decGradi: 57.13,
      magnitudine: 4.3,
      larghezzaInPrimi: 60,
      asset: 'doppio_ammasso'),
];

// ---------------------------------------------------------------------------
// L'ELENCO DEI BERSAGLI
// ---------------------------------------------------------------------------

/// Il centro di una figura in coordinate J2000: il baricentro dei versori
/// delle sue stelle pesato per luminosita', come il centro del velo.
BersaglioFisso bersaglioDellaFigura(
    FiguraDelCielo figura, CatalogoDelleStelle catalogo,
    {String? nome, CategoriaDelBersaglio? categoria}) {
  var x = 0.0, y = 0.0, z = 0.0;
  for (final i in figura.stelle) {
    final p = math.pow(10, -0.4 * catalogo.magnitudine[i]).toDouble();
    final ra = catalogo.raGradi[i] * math.pi / 180;
    final dec = catalogo.decGradi[i] * math.pi / 180;
    x += math.cos(dec) * math.cos(ra) * p;
    y += math.cos(dec) * math.sin(ra) * p;
    z += math.sin(dec) * p;
  }
  var ra = math.atan2(y, x) * 180 / math.pi;
  if (ra < 0) ra += 360;
  final dec = math.atan2(z, math.sqrt(x * x + y * y)) * 180 / math.pi;
  return BersaglioFisso('figura_${figura.iau}', nome ?? figura.nome,
      categoria ?? CategoriaDelBersaglio.costellazioni,
      raGradi: ra, decGradi: dec);
}

const Map<CorpoCeleste, String> _nomiNatali = {
  CorpoCeleste.sole: 'Il tuo Sole di nascita',
  CorpoCeleste.luna: 'La tua Luna di nascita',
  CorpoCeleste.mercurio: 'Il tuo Mercurio di nascita',
  CorpoCeleste.venere: 'La tua Venere di nascita',
  CorpoCeleste.marte: 'Il tuo Marte di nascita',
  CorpoCeleste.giove: 'Il tuo Giove di nascita',
  CorpoCeleste.saturno: 'Il tuo Saturno di nascita',
  CorpoCeleste.urano: 'Il tuo Urano di nascita',
  CorpoCeleste.nettuno: 'Il tuo Nettuno di nascita',
  CorpoCeleste.plutone: 'Il tuo Plutone di nascita',
};

/// Tutti i bersagli del menu, per categoria. [segno] e [jdNascita] mancano
/// a chi non ha dato la nascita: allora "Il tuo cielo" e' vuoto.
Map<CategoriaDelBersaglio, List<BersaglioDelCielo>> iBersagliDelCielo({
  required LeLineeDelleFigure linee,
  required CatalogoDelleStelle catalogo,
  Zodiac? segno,
  double? jdNascita,
}) {
  final ilTuo = <BersaglioDelCielo>[];
  if (segno != null) {
    final f = linee.indiceDi(segno.sigleIau);
    if (f != null) {
      ilTuo.add(bersaglioDellaFigura(linee.figure[f], catalogo,
          nome: segno.ilTuo, categoria: CategoriaDelBersaglio.ilTuoCielo));
    }
  }
  if (jdNascita != null && IlCieloDiMeeus.verificato(jdNascita)) {
    for (final c in CorpoCeleste.values) {
      ilTuo.add(BersaglioNatale('natale_${c.name}', _nomiNatali[c]!, c,
          IlCieloDiMeeus.longitudine(c, jdNascita)));
    }
  }
  return {
    CategoriaDelBersaglio.ilTuoCielo: ilTuo,
    CategoriaDelBersaglio.lunaESole: const [
      BersaglioCorpo('luna', 'La Luna', CategoriaDelBersaglio.lunaESole,
          CorpoCeleste.luna),
      BersaglioCorpo('sole', 'Il Sole', CategoriaDelBersaglio.lunaESole,
          CorpoCeleste.sole),
    ],
    CategoriaDelBersaglio.pianeti: const [
      BersaglioCorpo('mercurio', 'Mercurio', CategoriaDelBersaglio.pianeti,
          CorpoCeleste.mercurio),
      BersaglioCorpo('venere', 'Venere', CategoriaDelBersaglio.pianeti,
          CorpoCeleste.venere),
      BersaglioCorpo(
          'marte', 'Marte', CategoriaDelBersaglio.pianeti, CorpoCeleste.marte),
      BersaglioCorpo(
          'giove', 'Giove', CategoriaDelBersaglio.pianeti, CorpoCeleste.giove),
      BersaglioCorpo('saturno', 'Saturno', CategoriaDelBersaglio.pianeti,
          CorpoCeleste.saturno),
    ],
    CategoriaDelBersaglio.costellazioni: [
      for (final f in linee.figure) bersaglioDellaFigura(f, catalogo),
    ],
    CategoriaDelBersaglio.nebuloseEGalassie: [
      for (final o in kCieloProfondo) o.comeBersaglio,
    ],
  };
}

/// Quando il bersaglio sorge, nelle ventiquattro ore dopo [da]; [da] se e'
/// gia' sopra, nullo se non sorge. La regola e' `primoIstanteSopra`.
DateTime? quandoSorgeIlBersaglio(
    BersaglioDelCielo b, DateTime da, double lat, double lon) {
  return primoIstanteSopra(
    (t) =>
        b.altezzaAllIstante(Celestial.julianDay(t.toUtc()), lat, lon) >
        kAltezzaOrizzonte,
    da,
  );
}

/// La scelta dentro una categoria (voce 5.4): il bersaglio piu' alto sopra
/// l'orizzonte; se nessuno e' sopra, quello che sorge prima, e allora
/// [primoASorgere] e' vero perche' la riga lo dichiari.
({BersaglioDelCielo? bersaglio, bool primoASorgere}) sceltaNellaCategoria(
    List<BersaglioDelCielo> elenco, DateTime adesso, double lat, double lon) {
  final jd = Celestial.julianDay(adesso.toUtc());
  BersaglioDelCielo? piuAlto;
  var hMax = kAltezzaOrizzonte;
  for (final b in elenco) {
    final h = b.altezzaAllIstante(jd, lat, lon);
    if (h > hMax) {
      hMax = h;
      piuAlto = b;
    }
  }
  if (piuAlto != null) return (bersaglio: piuAlto, primoASorgere: false);
  BersaglioDelCielo? primo;
  DateTime? quando;
  for (final b in elenco) {
    final t = quandoSorgeIlBersaglio(b, adesso, lat, lon);
    if (t != null && (quando == null || t.isBefore(quando))) {
      quando = t;
      primo = b;
    }
  }
  return (bersaglio: primo, primoASorgere: primo != null);
}
