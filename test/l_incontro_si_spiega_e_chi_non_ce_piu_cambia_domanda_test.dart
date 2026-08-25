import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/core/synastry/cielo_della_sinastria.dart';
import 'package:esoteric_circle/core/synastry/possibilita_di_incontro.dart';
import 'package:esoteric_circle/core/synastry/synastry_report.dart';
import 'package:esoteric_circle/core/synastry/vip_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

/// L'INCONTRO SI SPIEGA, E CHI NON C'E' PIU' CAMBIA DOMANDA.
/// Ordine BO voci 03 e 04.
///
/// **I due difetti del fondatore, parole sue.** "la possibilita' di incontro e'
/// sempre bassa, mentre se un vip abita nella mia citta' o sotto casa o nel mio
/// paese dovrebbe avere maggiori probabilita' di incontro"; e "alcuni VIP, come
/// Giorgio Armani, sono morti. come gestiamo i vip che nel frattempo passano a
/// miglior vita?".
void main() {
  final tuo = CieloDiSinastria.perIdentita(
      BirthIdentity.fromParts(birthDate: DateTime(1988, 3, 14)));

  const milano = DoveSei(citta: 'Milano', latitudine: 45.4642, longitudine: 9.1920);
  const losAngeles =
      DoveSei(citta: 'Los Angeles', latitudine: 34.0522, longitudine: -118.2437);

  /// Due VIP identici in tutto tranne la citta': e' il solo modo di misurare
  /// "a parita' di tutto il resto" senza confondere l'effetto della distanza
  /// con quello dell'esposizione.
  Vip gemelloA(String citta, double lat, double lon) => Vip(
        name: 'Prova $citta',
        sign: VipCatalog.first.sign,
        annoDiNascita: 1980,
        meseDiNascita: 6,
        giornoDiNascita: 15,
        statoInVita: StatoInVita.inVita,
        esposizione: EsposizionePubblica.alta,
        luogoDiNascita: LuogoDelVip(
            nome: citta, nazione: 'X', latitudine: lat, longitudine: lon),
        luogoDiOggi: LuogoDelVip(
            nome: citta, nazione: 'X', latitudine: lat, longitudine: lon),
        fonti: const {},
      );

  test('nella tua stessa città vale almeno cinque volte un altro continente',
      () {
    final vicino = PossibilitaDiIncontro.per(
        vip: gemelloA('Milano', 45.4642, 9.1920), doveSei: milano);
    final lontano = PossibilitaDiIncontro.per(
        vip: gemelloA('Sydney', -33.8678, 151.2073), doveSei: milano);
    // ignore: avoid_print
    print('ORDINE BO VOCE 03: stessa città ${vicino.etichetta}, '
        'altro continente ${lontano.etichetta}, '
        'rapporto ${(vicino.percento / lontano.percento).toStringAsFixed(1)}');
    expect(vicino.percento / lontano.percento, greaterThanOrEqualTo(5.0),
        reason: 'chi vive sotto casa tua non ha una possibilità sensibilmente '
            'maggiore di chi vive dall\'altra parte del mondo');
  });

  test('due VIP dello stesso segno in città diverse danno numeri diversi', () {
    // Era il difetto: gli indici dei segni erano gli stessi, quindi il numero
    // era lo stesso, e la città non contava niente.
    final numeri = {
      for (final citta in const [
        ('Milano', 45.4642, 9.1920),
        ('Roma', 41.9004, 12.4957),
        ('Londra', 51.5085, -0.1257),
        ('New York', 40.7143, -74.0060),
      ])
        PossibilitaDiIncontro.per(
                vip: gemelloA(citta.$1, citta.$2, citta.$3), doveSei: milano)
            .etichetta
    };
    expect(numeri.length, 4,
        reason: 'quattro città diverse danno solo ${numeri.length} numeri '
            'distinti: la distanza non sta entrando nel conto');
  });

  test('la riga che spiega nomina sempre almeno un fatto vero', () {
    for (final v in VipCatalog.vips) {
      final i = PossibilitaDiIncontro.per(vip: v, doveSei: milano);
      expect(i.perche, isNotEmpty, reason: v.name);
      final nominaUnFatto = (v.luogoDiOggi != null &&
              i.perche.contains(v.luogoDiOggi!.nome)) ||
          i.perche.contains(v.esposizione.comeSiDice) ||
          (v.eScomparso && i.perche.contains('${v.annoDellaScomparsa}'));
      expect(nominaUnFatto, isTrue,
          reason: '${v.name}: la riga "${i.perche}" non nomina nessuno dei '
              'fatti da cui il numero nasce');
    }
  });

  test('senza sapere dove sei, la distanza non entra e si dichiara', () {
    final i = PossibilitaDiIncontro.per(
        vip: VipCatalog.conNome('Elon Musk')!, doveSei: null);
    expect(i.chilometri, isNull);
    expect(i.perche, contains('la distanza non entra nel conto'));
  });

  test('la distanza calcolata e\' quella vera, entro l\'uno per cento', () {
    // Milano-Roma, 477 km in linea d'aria secondo le coordinate del catalogo
    // dei luoghi gia' nel repository.
    final km = PossibilitaDiIncontro.chilometriFra(
        45.4642, 9.1920, 41.9004, 12.4957);
    expect(km, closeTo(477, 5), reason: 'la formula della distanza sbaglia');
    // E il verso opposto da' lo stesso numero: la distanza e' simmetrica.
    final inverso = PossibilitaDiIncontro.chilometriFra(
        41.9004, 12.4957, 45.4642, 9.1920);
    expect(inverso, closeTo(km, 0.001));
  });

  test('per chi non c\'è più l\'incontro non esiste, e la barra nemmeno', () {
    for (final nome in const ['Giorgio Armani', 'Steve Jobs']) {
      final v = VipCatalog.conNome(nome)!;
      final r = SynastryReport.perCieli(tuo: tuo, vip: v, doveSei: milano);
      expect(r.incontro.esiste, isFalse, reason: nome);
      expect(r.eScomparso, isTrue, reason: nome);
      // **LA BARRA NON ESISTE IN ALBERO**: non e' a zero, non c'e'.
      expect(r.bars, hasLength(3), reason: nome);
      expect(r.bars.any((b) => b.label.contains('incontro')), isFalse,
          reason: '$nome: la barra dell\'incontro è ancora nelle barre');
      // E nessuna parola del responso promette un incontro.
      final tutto = '${r.reading} ${r.eredita} '
          '${r.bars.map((b) => "${b.label} ${b.quip}").join(" ")}';
      expect(tutto.toLowerCase().contains('incontro'), isFalse,
          reason: '$nome: qualcosa promette ancora un incontro: $tutto');
    }
  });

  test('l\'eredità nomina un aspetto vero, e c\'è solo per chi non c\'è più',
      () {
    for (final v in VipCatalog.vips) {
      final r = SynastryReport.perCieli(tuo: tuo, vip: v, doveSei: milano);
      if (!v.eScomparso) {
        expect(r.eredita, isNull, reason: '${v.name} è vivo e ha un\'eredità');
        continue;
      }
      expect(r.eredita, isNotNull, reason: v.name);
      expect(r.eredita, contains('${v.annoDellaScomparsa}'), reason: v.name);
      if (r.aspetti.isNotEmpty) {
        expect(r.eredita, contains(r.aspetti.first.fatto),
            reason: '${v.name}: l\'eredità non nomina nessun aspetto vero');
      }
    }
  });

  test('chi è in vita ha ancora le sue quattro barre', () {
    final r = SynastryReport.perCieli(
        tuo: tuo, vip: VipCatalog.conNome('Zendaya')!, doveSei: losAngeles);
    expect(r.bars, hasLength(4));
    expect(r.bars.last.label, contains('incontro'));
    expect(r.bars.last.quip, isNotEmpty,
        reason: 'sotto la barra deve esserci la riga che spiega il numero');
  });

  test('il numero resta dentro il tetto e sopra il pavimento', () {
    for (final v in VipCatalog.vips) {
      for (final dove in [milano, losAngeles, null]) {
        final i = PossibilitaDiIncontro.per(vip: v, doveSei: dove);
        if (!i.esiste) {
          expect(i.percento, 0, reason: v.name);
          continue;
        }
        expect(i.percento,
            inInclusiveRange(
                PossibilitaDiIncontro.pavimento, PossibilitaDiIncontro.tetto),
            reason: v.name);
      }
    }
  });

  test('lo stesso VIP nello stesso posto da\' sempre lo stesso numero', () {
    for (final v in VipCatalog.vips.take(10)) {
      final a = PossibilitaDiIncontro.per(vip: v, doveSei: milano);
      final b = PossibilitaDiIncontro.per(vip: v, doveSei: milano);
      expect(a.percento, b.percento, reason: v.name);
      expect(a.perche, b.perche, reason: v.name);
    }
  });
}
