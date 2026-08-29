import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/core/synastry/cielo_del_giorno_sulla_coppia.dart';
import 'package:esoteric_circle/core/synastry/cielo_della_sinastria.dart';
import 'package:esoteric_circle/core/synastry/possibilita_di_incontro.dart';
import 'package:esoteric_circle/core/synastry/synastry_report.dart';
import 'package:esoteric_circle/core/synastry/vip_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

/// IL CIELO DEL GIORNO ENTRA NELLA POSSIBILITA' DI INCONTRO.
/// Ordine BO voce 12.
///
/// **Parole del fondatore**: "ma non sarebbe piu' giusto che siano le stelle e
/// i transiti del giorno a decidere?". Il principio in una riga: la geografia
/// dice se un incontro e' possibile, il cielo dice quando.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final tuo = CieloDiSinastria.perIdentita(
      BirthIdentity.fromParts(birthDate: DateTime(1988, 3, 14)));
  final oggi = DateTime.utc(2026, 8, 25);

  MoltiplicatoreCeleste moltiplicatore(Vip v, DateTime giorno) {
    final suo = CieloDiSinastria.perVip(v);
    return MoltiplicatoreCeleste.per(
      aspetti: AspettiDiSinastria.fra(tuo, suo),
      tuo: tuo,
      suo: suo,
      giorno: giorno,
    );
  }

  test('nello stesso giorno i cinquanta VIP danno moltiplicatori diversi', () {
    // **LA TRAPPOLA CHE QUESTA MISURA ESISTE PER PRENDERE.** Se il
    // moltiplicatore nascesse da un transito del solo UTENTE, quel giorno
    // tutti e cinquanta avrebbero lo stesso numero: sarebbero le 93 coppie
    // identiche della voce 02 in una forma nuova.
    final distinti = <String>{
      for (final v in VipCatalog.vips)
        moltiplicatore(v, oggi).valore.toStringAsFixed(4)
    };
    // ignore: avoid_print
    print('ORDINE BO VOCE 12: nello stesso giorno i moltiplicatori distinti '
        'sono ${distinti.length} su ${VipCatalog.vips.length}');
    expect(distinti.length, greaterThanOrEqualTo(40),
        reason: 'solo ${distinti.length} moltiplicatori distinti: il cielo '
            'non sta guardando la COPPIA, sta guardando una carta sola');
  });

  test('lo stesso VIP cambia col passare dei giorni', () {
    final v = VipCatalog.conNome('Zendaya')!;
    final distinti = <String>{
      for (var i = 0; i < 30; i++)
        moltiplicatore(v, oggi.add(Duration(days: i)))
            .valore
            .toStringAsFixed(4)
    };
    // ignore: avoid_print
    print('ORDINE BO VOCE 12: in trenta giorni lo stesso VIP dà '
        '${distinti.length} valori distinti');
    expect(distinti.length, greaterThanOrEqualTo(10),
        reason: 'in trenta giorni il moltiplicatore prende solo '
            '${distinti.length} valori: il cielo non sta passando');
  });

  test('la finestra non si sfonda mai, su un anno intero', () {
    for (final v in VipCatalog.vips) {
      for (var i = 0; i < 365; i += 7) {
        final m = moltiplicatore(v, oggi.add(Duration(days: i)));
        expect(
            m.valore,
            inInclusiveRange(
                MoltiplicatoreCeleste.minimo, MoltiplicatoreCeleste.massimo),
            reason: '${v.name} al giorno $i: ${m.valore}');
      }
    }
  });

  test('la geografia non si ribalta: diecimila km restano sotto il due', () {
    // Un VIP a diecimila chilometri, con l'esposizione massima, nel giorno
    // migliore E in quello peggiore dei sei mesi.
    const milano = DoveSei(
        citta: 'Milano', latitudine: 45.4642, longitudine: 9.1920);
    final lontano = Vip(
      name: 'Prova lontana',
      sign: VipCatalog.first.sign,
      annoDiNascita: 1980,
      meseDiNascita: 6,
      giornoDiNascita: 15,
      statoInVita: StatoInVita.inVita,
      esposizione: EsposizionePubblica.altissima,
      luogoDiNascita: const LuogoDelVip(
          nome: 'Sydney', nazione: 'Australia',
          latitudine: -33.8678, longitudine: 151.2073),
      luogoDiOggi: const LuogoDelVip(
          nome: 'Sydney', nazione: 'Australia',
          latitudine: -33.8678, longitudine: 151.2073),
      fonti: const {},
    );
    final suo = CieloDiSinastria.perVip(lontano);
    final aspetti = AspettiDiSinastria.fra(tuo, suo);
    var massimo = 0.0;
    var minimo = 100.0;
    for (var i = 0; i < GiornoPiuAcceso.giorniDaGuardare; i++) {
      final p = PossibilitaDiIncontro.per(
        vip: lontano,
        doveSei: milano,
        aspetti: aspetti,
        tuo: tuo,
        suo: suo,
        quando: oggi.add(Duration(days: i)),
      );
      if (p.percento > massimo) massimo = p.percento;
      if (p.percento < minimo) minimo = p.percento;
    }
    // ignore: avoid_print
    print('ORDINE BO VOCE 12: a diecimila km, sui sei mesi, la possibilità '
        'sta fra ${minimo.toStringAsFixed(2)} e '
        '${massimo.toStringAsFixed(2)} per cento');
    expect(massimo, lessThan(2.0),
        reason: 'il cielo ha ribaltato la geografia: un VIP dall\'altra parte '
            'del mondo arriva a $massimo per cento');
  });

  test('la data dichiarata è davvero il massimo del periodo', () {
    final v = VipCatalog.conNome('Drake')!;
    final suo = CieloDiSinastria.perVip(v);
    final aspetti = AspettiDiSinastria.fra(tuo, suo);
    final trovato = GiornoPiuAcceso.cerca(
        aspetti: aspetti, tuo: tuo, suo: suo, da: oggi)!;
    // **La verifica indipendente**: si rifà la scansione per intero e si
    // guarda che nessun giorno batta quello dichiarato.
    for (var i = 0; i < GiornoPiuAcceso.giorniDaGuardare; i++) {
      final g = oggi.add(Duration(days: i));
      final m = MoltiplicatoreCeleste.per(
          aspetti: aspetti, tuo: tuo, suo: suo, giorno: g);
      expect(m.valore,
          lessThanOrEqualTo(trovato.moltiplicatore.valore + 1e-9),
          reason: 'il ${g.day}/${g.month} batte il giorno dichiarato');
    }
    expect(trovato.giorno.difference(oggi).inDays,
        inInclusiveRange(0, GiornoPiuAcceso.giorniDaGuardare));
  });

  test('la scansione dei sei mesi sta sotto i 300 millesimi', () {
    final v = VipCatalog.conNome('Drake')!;
    final suo = CieloDiSinastria.perVip(v);
    final aspetti = AspettiDiSinastria.fra(tuo, suo);
    // Un giro a vuoto, poi il piu' veloce di cinque: il piu' lento misura la
    // macchina, non la scansione.
    GiornoPiuAcceso.cerca(aspetti: aspetti, tuo: tuo, suo: suo, da: oggi);
    var minimo = const Duration(days: 1);
    for (var i = 0; i < 5; i++) {
      final o = Stopwatch()..start();
      GiornoPiuAcceso.cerca(aspetti: aspetti, tuo: tuo, suo: suo, da: oggi);
      o.stop();
      if (o.elapsed < minimo) minimo = o.elapsed;
    }
    // ignore: avoid_print
    print('ORDINE BO VOCE 12: la scansione dei sei mesi costa '
        '${minimo.inMicroseconds / 1000} millesimi');
    expect(minimo.inMilliseconds, lessThan(300),
        reason: 'la scansione costa ${minimo.inMilliseconds} millesimi');
  });

  test('senza aspetti da attivare il moltiplicatore vale uno, e tace', () {
    final m = MoltiplicatoreCeleste.per(
      aspetti: const [],
      tuo: tuo,
      suo: CieloDiSinastria.perVip(VipCatalog.first),
      giorno: oggi,
    );
    expect(m.valore, MoltiplicatoreCeleste.neutro);
    expect(m.transito, isNull);
    expect(m.aspettoAcceso, isNull);
    expect(m.riga.contains('nessun pianeta'), isTrue);
    // E la ricerca del giorno migliore non inventa una data.
    expect(
        GiornoPiuAcceso.cerca(
            aspetti: const [],
            tuo: tuo,
            suo: CieloDiSinastria.perVip(VipCatalog.first),
            da: oggi),
        isNull);
  });

  test('con l\'ora dei VIP ignota si guarda ai pianeti, e si dichiara', () {
    // Cinquanta su cinquanta non hanno l'ora, quindi nessuno dei due cieli
    // porta l'Ascendente e il conto lo dice.
    final v = VipCatalog.conNome('Zendaya')!;
    final m = moltiplicatore(v, oggi);
    expect(CieloDiSinastria.perVip(v).haAscendente, isFalse);
    expect(m.soloPianeti, isTrue);
    // **LA CODA SULL'ORA IGNOTA NON C'E' PIU', ordine CC voce 06g**, e la
    // pretesa segue la decisione del fondatore invece di difendere il testo
    // che lui ha tolto: "quando non si conosce l'orario di nascita del vip
    // c'e' sempre un testo che dice non si finge cio' che non si conosce ecc.
    // eliminalo!". Al suo posto ogni responso porta due righe, e la prima dice
    // ORA DI NASCITA: SCONOSCIUTO. Qui si difende che la coda **non** ci sia
    // piu': se qualcuno la rimette, questa prova cade.
    if (m.transito != null) {
      expect(m.riga.contains('non si conosce l\'ora di nascita'), isFalse,
          reason: 'la coda sull\'ora ignota e\' tornata dentro la riga del '
              'cielo, e il fondatore l\'ha fatta togliere');
    }
  });

  test('per chi non c\'è più non c\'è nessun moltiplicatore né data', () {
    for (final nome in const ['Giorgio Armani', 'Steve Jobs']) {
      final r = SynastryReport.perCieli(
          tuo: tuo, vip: VipCatalog.conNome(nome)!, quando: oggi);
      expect(r.incontro.esiste, isFalse, reason: nome);
      expect(r.incontro.celeste, isNull,
          reason: '$nome: la voce 04 dice che per chi non c\'è più questa '
              'voce non esiste');
      expect(r.incontro.giornoPiuAcceso, isNull, reason: nome);
    }
  });

  test('la base geografica resta visibile accanto al risultato', () {
    // **La voce 03 è chiusa e non si riapre**: il suo calcolo resta la base, e
    // questa voce lo moltiplica. Qui si verifica che il rapporto fra il
    // risultato e la base sia esattamente il moltiplicatore.
    const milano = DoveSei(
        citta: 'Milano', latitudine: 45.4642, longitudine: 9.1920);
    for (final v in VipCatalog.vips) {
      if (v.eScomparso) continue;
      final suo = CieloDiSinastria.perVip(v);
      final p = PossibilitaDiIncontro.per(
        vip: v,
        doveSei: milano,
        aspetti: AspettiDiSinastria.fra(tuo, suo),
        tuo: tuo,
        suo: suo,
        quando: oggi,
      );
      final base = p.baseGeografica!;
      final atteso = (base * p.celeste!.valore)
          .clamp(PossibilitaDiIncontro.pavimento,
              PossibilitaDiIncontro.tetto)
          .toDouble();
      expect(p.percento, closeTo(atteso, 1e-9), reason: v.name);
    }
  });

  test('nessuna riga promette un incontro, e la prova cerca il PROMETTERE',
      () {
    // **Non una lista di parole scelte a mano**: si cercano le FORME del
    // promettere, cioe' il futuro indicativo italiano e le formule di
    // certezza, dentro qualunque frase che nomini l'incontro o il vedersi.
    final futuro = RegExp(
        r'\b\w+(er[àaio]|ir[àaio]|eranno|iranno|emo|iremo|ete|irete)\b',
        caseSensitive: false);
    final certezza = RegExp(
        r'\b(sicuramente|di certo|certamente|senza dubbio|garantit\w+|'
        r'avverr\w+|succeder\w+|accadr\w+|vi incontrer\w+|lo incontrer\w+)\b',
        caseSensitive: false);
    const milano = DoveSei(
        citta: 'Milano', latitudine: 45.4642, longitudine: 9.1920);
    var frasi = 0;
    for (final v in VipCatalog.vips) {
      final suo = CieloDiSinastria.perVip(v);
      final aspetti = AspettiDiSinastria.fra(tuo, suo);
      final r = SynastryReport.perCieli(
          tuo: tuo, vip: v, doveSei: milano, quando: oggi);
      final righe = <String>[
        r.incontro.perche,
        if (r.incontro.celeste != null) r.incontro.celeste!.riga,
        r.reading,
        for (final b in r.bars) '${b.label} ${b.quip}',
      ];
      final migliore =
          GiornoPiuAcceso.cerca(aspetti: aspetti, tuo: tuo, suo: suo, da: oggi);
      if (migliore != null) righe.add(migliore.rigaDa(oggi));
      for (final riga in righe) {
        frasi++;
        expect(certezza.hasMatch(riga), isFalse,
            reason: '${v.name}: "$riga" promette');
        // Il futuro e' ammesso solo dove non si parla di incontrarsi: qui si
        // pretende che le due cose non stiano mai nella stessa frase.
        final parlaDiIncontro = RegExp(
                r'incontr|veder(si|vi)|conoscer(si|vi)', caseSensitive: false)
            .hasMatch(riga);
        if (parlaDiIncontro) {
          expect(futuro.hasMatch(riga), isFalse,
              reason: '${v.name}: "$riga" mette un futuro accanto a un '
                  'incontro, cioè lo promette');
        }
      }
    }
    // ignore: avoid_print
    print('ORDINE BO VOCE 12: controllate $frasi frasi, nessuna promette');
    expect(frasi, greaterThan(200));
  });
}
