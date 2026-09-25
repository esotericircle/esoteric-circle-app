// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:math' as math;

import 'package:esoteric_circle/features/maestri/live/il_giudizio_della_frase.dart';
import 'package:esoteric_circle/features/maestri/live/il_silenzio_vero.dart';
import 'package:esoteric_circle/services/voce/l_orecchio_del_live.dart';
import 'package:flutter_test/flutter_test.dart';

/// **LA TELEVISIONE NON TIENE APERTA LA FRASE.** Ordine EM voce 04, secondo
/// giro, 25 settembre 2026.
///
/// Il fondatore: *"Io uso "Ok Google" giornalmente con TV accesa e gemini
/// riconosce la mia voce Senza problemi. Ho bisogno dello stesso livello di
/// accuratezza e tolleranza"*. Sul Realme, con un notiziario e una musica
/// dalle casse del PC, la prima stesura della regola ha tenuto aperta una
/// frase per 141,6 secondi. Qui la televisione e' fatta con i numeri di quel
/// giro, pezzi di cinquanta millesimi: sillabe di voce con la mediana a -30
/// dB, il novantesimo percentile a -25 e il massimo a -21, code a -45 fra una
/// sillaba e l'altra, pause fra le frasi vicine al fondo.
void main() {
  const pezzo = Duration(milliseconds: 50);

  double gauss(math.Random caso) {
    final u = 1 - caso.nextDouble(), v = caso.nextDouble();
    return math.sqrt(-2 * math.log(u)) * math.cos(2 * math.pi * v);
  }

  /// Una voce fatta di sillabe, col livello di ogni sillaba dato da
  /// [livelloDellaSillaba]; code a [coda] fra le sillabe e pause a [pausa]
  /// fra le frasi.
  List<Pezzo> parlato(
    int ms, {
    required int seme,
    required double Function(math.Random caso) livelloDellaSillaba,
    double coda = -45,
    double pausa = -64,
  }) {
    final caso = math.Random(seme);
    final pezzi = <Pezzo>[];
    while (pezzi.length * 50 < ms) {
      final sillabe = 6 + caso.nextInt(9);
      for (var i = 0; i < sillabe; i++) {
        final livello = livelloDellaSillaba(caso);
        for (var k = 0; k < 3 + caso.nextInt(3); k++) {
          pezzi.add((db: livello, voce: 0.85));
        }
        for (var k = 0; k < 1 + caso.nextInt(2); k++) {
          pezzi.add((db: coda, voce: 0.3));
        }
      }
      for (var k = 0; k < 6 + caso.nextInt(5); k++) {
        pezzi.add((db: pausa, voce: 0.2));
      }
    }
    return pezzi.sublist(0, ms ~/ 50);
  }

  /// **La televisione misurata sul Realme**: ogni sillaba prende il livello
  /// di un pezzo di voce vero della scena, scelto a caso fra i 243 del
  /// registro.
  List<Pezzo> televisione(int ms, {int seme = 3}) => parlato(ms,
      seme: seme,
      livelloDellaSillaba: (caso) =>
          televisioneDelRealme[caso.nextInt(televisioneDelRealme.length)]
              .toDouble());

  /// Chi parla al telefono, con la televisione sotto: le due energie si
  /// sommano. Sul Realme la domanda stava fra -13 e -23 dB.
  List<Pezzo> persona(int ms, {int seme = 11, int semeTv = 5}) {
    final lei = parlato(ms,
        seme: seme,
        livelloDellaSillaba: (caso) =>
            (-18 + 3 * gauss(caso)).clamp(-26, -12).toDouble(),
        coda: -40,
        pausa: -40);
    final tv = televisione(ms, seme: semeTv);
    return [
      for (var i = 0; i < lei.length; i++)
        (
          db: 10 *
              math.log(
                  math.pow(10, lei[i].db / 10) + math.pow(10, tv[i].db / 10)) /
              math.ln10,
          voce: math.max(lei[i].voce, tv[i].voce),
        ),
    ];
  }

  /// Fa sentire [pezzi]; torna quanti millesimi sono passati quando la
  /// frase si e' chiusa, o null se non si e' chiusa.
  int? senti(IlSilenzioVero s, List<Pezzo> pezzi) {
    for (var i = 0; i < pezzi.length; i++) {
      s.senti(pezzi[i].db, pezzo, voce: pezzi[i].voce);
      if (s.fraseChiusa) return (i + 1) * 50;
    }
    return null;
  }

  /// Un secondo di stanza silenziosa, come quando il microfono si apre prima
  /// che la televisione parli: la scena del Realme.
  final silenzioIniziale = [
    for (var i = 0; i < 20; i++) (db: -80.0, voce: 0.2),
  ];

  /// La stanza dopo il primo controllo: la frase di sola televisione aperta
  /// all'inizio, scartata, e i suoi livelli imparati.
  LaStanza stanzaCheConosceLaTelevisione() {
    final stanza = LaStanza();
    final prima = IlSilenzioVero(stanza: stanza);
    senti(prima, [...silenzioIniziale, ...televisione(5000)]);
    expect(prima.haParlato, isTrue,
        reason: 'senza stanza la televisione apre una frase: e\' il giro '
            'di partenza del Realme');
    stanza.imparaTutte(prima.vociSentite);
    return stanza;
  }

  test('LA TELEVISIONE DELLA PROVA E\' QUELLA DEL REALME', () {
    final ordinati = [...televisioneDelRealme]..sort();
    int percentile(int p) =>
        ordinati[((ordinati.length - 1) * p / 100).round()];
    expect(ordinati.length, 243);
    expect(percentile(50), -30);
    expect(percentile(90), -25);
    expect(ordinati.last, -21);
  });

  test(
      'UNA FRASE APERTA DALLA TELEVISIONE CHIEDE UN CONTROLLO ENTRO TRE '
      'SECONDI E MEZZO DA QUANDO SI APRE', () {
    final s = IlSilenzioVero();
    final tv = [...silenzioIniziale, ...televisione(6000)];
    int? aperta, primoControllo;
    for (var i = 0; i < tv.length; i++) {
      s.senti(tv[i].db, pezzo, voce: tv[i].voce);
      if (s.haParlato && aperta == null) aperta = i * 50;
      if (s.controlli > 0 && primoControllo == null) primoControllo = i * 50;
    }
    print('ORDINE EM VOCE 04: la frase di televisione si apre a $aperta ms e '
        'chiede il primo controllo a $primoControllo ms');
    expect(aperta, isNotNull,
        reason: 'la televisione non apre la frase: non e\' la scena del '
            'Realme');
    expect(s.fraseChiusa, isFalse);
    expect(primoControllo, isNotNull,
        reason: 'la frase di televisione non chiede mai un controllo: '
            'resta aperta come sul Realme, 141,6 secondi');
    expect(primoControllo! - aperta!, lessThanOrEqualTo(3500));
  });

  test(
      'IMPARATA LA TELEVISIONE, VENTI SECONDI DI TELEVISIONE NON APRONO '
      'NESSUNA FRASE', () {
    final stanza = stanzaCheConosceLaTelevisione();
    for (final seme in [21, 22, 23, 24, 25]) {
      final s = IlSilenzioVero(stanza: stanza);
      senti(s, televisione(20000, seme: seme));
      expect(s.haParlato, isFalse,
          reason: 'con la televisione imparata (sottofondo '
              '${stanza.sottofondo?.round()} dB) la televisione del seme '
              '$seme apre ancora una frase');
    }
  });

  test(
      'CON LA TELEVISIONE ACCESA CHI PARLA AL TELEFONO APRE LA FRASE, E '
      'QUANDO SMETTE LA FRASE SI CHIUDE', () {
    final chiusure = <int>[];
    for (final seme in [31, 32, 33, 34, 35, 36, 37, 38]) {
      final stanza = stanzaCheConosceLaTelevisione();
      final s = IlSilenzioVero(stanza: stanza);
      senti(s, televisione(2000, seme: seme + 100));
      expect(s.haParlato, isFalse);
      expect(senti(s, persona(4000, seme: seme)), isNull);
      expect(s.haParlato, isTrue,
          reason: 'con la televisione accesa la persona del seme $seme non '
              'viene sentita');
      final chiusa = senti(s, televisione(10000, seme: seme + 200));
      expect(chiusa, isNotNull,
          reason: 'la persona del seme $seme ha smesso e la televisione ha '
              'tenuto aperta la frase per dieci secondi');
      chiusure.add(chiusa!);
    }
    print('ORDINE EM VOCE 04: chiusura dopo la fine della persona, con la '
        'televisione sotto: $chiusure ms');
    for (final c in chiusure) {
      expect(c, lessThanOrEqualTo(2600),
          reason: 'la televisione ha allungato la chiusura: $chiusure');
    }
  });

  test('CON LA TELEVISIONE ACCESA UNA PAUSA DI PENSIERO NON TRONCA', () {
    // Il vincolo dell'ordine EJ voce 01.
    final stanza = stanzaCheConosceLaTelevisione();
    final s = IlSilenzioVero(stanza: stanza);
    senti(s, persona(3000, seme: 41));
    expect(s.haParlato, isTrue);
    expect(senti(s, televisione(1500, seme: 42)), isNull,
        reason: 'un secondo e mezzo per pensare, con la televisione, ha '
            'chiuso la frase');
    expect(senti(s, persona(2500, seme: 43)), isNull);
    expect(senti(s, televisione(3000, seme: 44)), isNotNull);
  });

  test('UNA PERSONA CHE PENSA IN UNA STANZA SILENZIOSA NON CHIEDE CONTROLLI',
      () {
    final s = IlSilenzioVero();
    for (var giro = 0; giro < 6; giro++) {
      // "Ehm": mezzo secondo di voce, poi un secondo e mezzo di silenzio.
      for (var t = 0; t < 500; t += 50) {
        s.senti(-25, pezzo, voce: 0.9);
      }
      for (var t = 0; t < 1500; t += 50) {
        s.senti(-80, pezzo, voce: 0.2);
      }
    }
    expect(s.haParlato, isTrue);
    expect(s.fraseChiusa, isFalse);
    expect(s.controlli, 0,
        reason: 'le pause di pensiero sono state prese per un suono '
            'continuo: il giudizio potrebbe chiudere la frase a meta\'');
  });

  test('LA STANZA DIMENTICA LA TELEVISIONE SPENTA', () {
    final stanza = LaStanza();
    stanza.imparaTutte(List.filled(50, -28.0));
    expect(stanza.sottofondo, -28);
    stanza.passa(const Duration(seconds: 9));
    expect(stanza.sottofondo, -28);
    stanza.passa(const Duration(seconds: 2));
    expect(stanza.sottofondo, isNull,
        reason: 'dieci secondi di stanza senza voce e la televisione spenta '
            'alza ancora la soglia');
  });

  test('UNA PAROLA DETTA PIANO NON DIVENTA SOTTOFONDO', () {
    // La prima stesura bastava con dieci pezzi: una parola sotto la soglia
    // diventava sottofondo, e la persona doveva parlare sei decibel sopra se
    // stessa.
    final stanza = LaStanza();
    final s = IlSilenzioVero(stanza: stanza);
    for (var t = 0; t < 1000; t += 50) {
      s.senti(-80, pezzo, voce: 0.2);
    }
    // Una parola a -60: sopra il fondo, sotto la soglia d'inizio.
    for (var t = 0; t < 600; t += 50) {
      s.senti(-60, pezzo, voce: 0.9);
    }
    for (var t = 0; t < 1000; t += 50) {
      s.senti(-80, pezzo, voce: 0.2);
    }
    expect(stanza.sottofondo, isNull,
        reason: 'una parola di seicento millesimi e\' diventata sottofondo');
  });

  group('LA VOCE VICINA NON DIVENTA MAI SOTTOFONDO', () {
    // Sul Realme, scena tv4: il controllo ha trovato vuota la domanda vera,
    // la frase e' stata scartata e la stanza ha imparato la voce della
    // persona, da -26 a -19 dB.
    test('CON LA TELEVISIONE IMPARATA, LA DOMANDA NON SEMBRA SOTTOFONDO', () {
      final stanza = stanzaCheConosceLaTelevisione();
      final s = IlSilenzioVero(stanza: stanza);
      senti(s, televisione(2000, seme: 51));
      senti(s, persona(5000, seme: 52));
      expect(s.haParlato, isTrue);
      print('ORDINE EM VOCE 04: sottofondo ${stanza.sottofondo?.round()} dB, '
          'la domanda sembra sottofondo: '
          '${stanza.sembraSottofondo(s.vociSentite)}');
      expect(stanza.sembraSottofondo(s.vociSentite), isFalse,
          reason: 'una trascrizione vuota farebbe imparare la voce della '
              'persona alla stanza');
      // E la televisione, invece, lo sembra.
      final tv = IlSilenzioVero(stanza: stanza);
      senti(tv, televisione(5000, seme: 53));
      final livelliTv = [
        for (final p in televisione(5000, seme: 53))
          if (p.voce > 0.55) p.db,
      ];
      expect(stanza.sembraSottofondo(livelliTv), isTrue);
    });

    test('SENZA UN SOTTOFONDO CONOSCIUTO, DECIDE LA TRASCRIZIONE', () {
      expect(LaStanza().sembraSottofondo([-20, -18, -15]), isTrue);
    });

    test('L\'ORECCHIO NON SCARTA E NON IMPARA LA VOCE VICINA', () {
      final orecchio =
          File('lib/services/voce/l_orecchio_del_live.dart').readAsStringSync();
      final scarta = orecchio.substring(orecchio.indexOf('bool scarta('));
      final guardia = scarta
          .indexOf('if (!_stanza.sembraSottofondo(_silenzio.vociSentite)) '
              'return false;');
      // La prima stesura confrontava solo le due posizioni: senza la
      // guardia `indexOf` vale -1, che viene prima di tutto, e la prova
      // restava verde. Vista cosi' alla Regola A.
      expect(guardia, greaterThanOrEqualTo(0),
          reason: 'lo scarto non si chiede se la frase era sottofondo');
      expect(guardia < scarta.indexOf('_stanza.imparaTutte('), isTrue,
          reason: 'lo scarto impara prima di chiedersi se era sottofondo');
      final era = orecchio.substring(orecchio.indexOf('void eraSottofondo('));
      expect(
          era
              .substring(0, era.indexOf('\n  }'))
              .contains('_stanza.sembraSottofondo(voci)'),
          isTrue,
          reason: 'una frase chiusa e trovata vuota insegna alla stanza la '
              'voce della persona');
    });
  });

  group('UNA DOMANDA VERA NON SI PERDE', () {
    // Sul Realme, stanza silenziosa, build finale della 2281: "Sono dello
    // Scorpione con ascendente Sagittario e la Luna in Capricorno" e' tornata
    // vuota dalla trascrizione anticipata, la domanda si e' persa e il LIVE si
    // e' chiuso per silenzio ventun secondi dopo.
    test('LA FRASE SA QUANTA VOCE VERA HA SENTITO', () {
      final s = IlSilenzioVero();
      for (var t = 0; t < 500; t += 50) {
        s.senti(-70, pezzo, voce: 0.2);
      }
      for (var t = 0; t < 1000; t += 50) {
        s.senti(-25, pezzo, voce: 0.9);
      }
      // Un respiro dopo la voce non e' voce.
      for (var t = 0; t < 500; t += 50) {
        s.senti(-40, pezzo, voce: 0.2);
      }
      expect(s.voceDellaFrase, const Duration(milliseconds: 1000));
    });

    test(
        'SENZA SOTTOFONDO LA STANZA NON IMPARA UNA FRASE VUOTA, E NON SCARTA '
        'AL PRIMO CONTROLLO', () {
      final orecchio =
          File('lib/services/voce/l_orecchio_del_live.dart').readAsStringSync();
      final scarta = orecchio.substring(orecchio.indexOf('bool scarta('));
      final dueVolte = scarta
          .indexOf('if (_stanza.sottofondo == null && ++_scartiChiesti < 2) '
              'return false;');
      expect(dueVolte, greaterThanOrEqualTo(0),
          reason: 'senza sottofondo il primo controllo vuoto scarta la frase');
      expect(dueVolte < scarta.indexOf('_stanza.imparaTutte('), isTrue);
      final era = orecchio.substring(orecchio.indexOf('void eraSottofondo('));
      expect(
          era
              .substring(0, era.indexOf('\n  }'))
              .contains('_stanza.sottofondo != null &&'),
          isTrue,
          reason: 'nella stanza silenziosa una domanda vera tornata vuota '
              'diventa la soglia');
    });

    test(
        'UNA FRASE DI VOCE VERA TORNATA VUOTA SI TRASCRIVE DI NUOVO, POI IL '
        'MAESTRO CHIEDE DI RIPETERE', () {
      final schermata = File('lib/features/maestri/live/schermata_live.dart')
          .readAsStringSync();
      final frase = schermata.substring(
          schermata.indexOf('Future<void> _unaFrase('),
          schermata.indexOf('Future<void> _nonHoSentito()'));
      final seconda = frase
          .indexOf('if (detto.isEmpty && _orecchio.voceDellaFrase(frase) >= '
              'laVoceChiara) {');
      expect(seconda, greaterThanOrEqualTo(0),
          reason: 'una trascrizione vuota di una frase con voce vera non si '
              'riprova');
      expect(
          frase
              .substring(seconda)
              .startsWith(RegExp(r'[^}]*detto = await _trascrivi\(')),
          isTrue,
          reason: 'la seconda prova non trascrive di nuovo');
      expect(frase.contains('await _nonHoSentito();'), isTrue,
          reason: 'dopo due trascrizioni vuote il Maestro tace, e il LIVE si '
              'chiude per silenzio');
      final non = schermata
          .substring(schermata.indexOf('Future<void> _nonHoSentito()'));
      final corpo = non.substring(0, non.indexOf('\n  }\n'));
      final ordine = [
        corpo.indexOf('await _orecchio.ferma();'),
        corpo.indexOf('_cePresenza();'),
        corpo.indexOf('await _dillo(nonHoSentito);'),
        corpo.indexOf('await _ascoltaLaPersona();'),
      ];
      expect(ordine.every((i) => i >= 0), isTrue,
          reason: 'manca un passo di "non ho sentito": $ordine');
      expect([...ordine]..sort(), ordine,
          reason: 'i passi di "non ho sentito" sono fuori ordine: $ordine');
    });
  });

  group('LA FRASE COMINCIA DALLA VOCE VICINA', () {
    // Sul Realme, con la televisione sotto, il secondo di audio di prima
    // portava le parole della televisione attaccate al nome del Maestro: la
    // trascrizione ha perso "Aura" cinque volte su cinque, e la stessa frase
    // cominciata duecento millesimi prima della voce le ha date tutte.
    const pezzo = 2048; // 64 millesimi a 16 kHz, come sul telefono

    test('SI TENGONO QUATTROCENTO MILLESIMI PRIMA DEL PRIMO PEZZO PARLATO', () {
      final parla = [for (var i = 0; i < 16; i++) i >= 11];
      final da =
          LOrecchioDelLive.inizioDellaVoceVicina(List.filled(16, pezzo), parla);
      expect(da, 4, reason: 'sette pezzi, 448 millesimi, prima della voce');
    });

    test('UN PICCO ISOLATO DELLA TELEVISIONE NON SPOSTA L\'INIZIO', () {
      // Un pezzo parlato al terzo pezzo, poi settecento millesimi di
      // silenzio: la voce vicina e' quella degli ultimi due.
      final parla = [for (var i = 0; i < 16; i++) i == 2 || i >= 14];
      final da =
          LOrecchioDelLive.inizioDellaVoceVicina(List.filled(16, pezzo), parla);
      expect(da, 7);
    });

    test('SENZA PEZZI PARLATI, O TUTTI PARLATI, SI TIENE TUTTO', () {
      expect(
          LOrecchioDelLive.inizioDellaVoceVicina(
              List.filled(16, pezzo), List.filled(16, false)),
          0);
      expect(
          LOrecchioDelLive.inizioDellaVoceVicina(
              List.filled(16, pezzo), List.filled(16, true)),
          0);
    });

    test('SI TAGLIA SOLO CON UN SOTTOFONDO, MAI SUBITO DOPO UNO SCARTO', () {
      final orecchio =
          File('lib/services/voce/l_orecchio_del_live.dart').readAsStringSync();
      expect(
          orecchio.contains('_stanza.sottofondo != null && '
              '_primaMassima == _unSecondo'),
          isTrue,
          reason: 'la frase si taglia anche nella stanza silenziosa, dove '
              'servono gli attacchi deboli dell\'ordine EJ');
    });
  });

  group('IL GIUDIZIO DELLA FRASE', () {
    test('SENZA PAROLE SI SCARTA', () {
      final g = IlGiudizioDellaFrase();
      expect(g.giudica(frase: 1, controllo: 1, testo: ''),
          CosaFareDellaFrase.scarta);
    });

    test('LE PAROLE CHE CRESCONO ASPETTANO, QUELLE FERME CHIUDONO', () {
      final g = IlGiudizioDellaFrase();
      expect(g.giudica(frase: 1, controllo: 1, testo: 'Aura, sento'),
          CosaFareDellaFrase.aspetta);
      expect(g.giudica(frase: 1, controllo: 2, testo: 'Aura, sento un blocco'),
          CosaFareDellaFrase.aspetta);
      expect(g.giudica(frase: 1, controllo: 3, testo: 'Aura, sento un blocco.'),
          CosaFareDellaFrase.chiudi);
    });

    test('UNA FRASE NUOVA RICOMINCIA, E UN CONTROLLO VECCHIO NON CONTA', () {
      final g = IlGiudizioDellaFrase();
      expect(g.giudica(frase: 1, controllo: 1, testo: 'Aura'),
          CosaFareDellaFrase.aspetta);
      expect(g.giudica(frase: 2, controllo: 2, testo: 'Aura'),
          CosaFareDellaFrase.aspetta);
      expect(g.giudica(frase: 2, controllo: 3, testo: 'Aura, sento un blocco'),
          CosaFareDellaFrase.aspetta);
      // Il controllo 2 torna dopo il 3, con meno parole: non e' la persona
      // che ha finito.
      expect(g.giudica(frase: 2, controllo: 2, testo: 'Aura'),
          CosaFareDellaFrase.aspetta);
    });
  });

  group('IL SEGNO DEL SILENZIO NON E\' UNA PAROLA', () {
    test('SI TOGLIE ANCHE DENTRO UNA FRASE CON PAROLE', () {
      // Tornata cosi' sul Realme, con la televisione accesa.
      expect(
          LaTrascrizione.pulita('[SILENZIO] Ah, io sento un blocco ad '
              'Anahata.'),
          'Ah, io sento un blocco ad Anahata.');
      expect(LaTrascrizione.pulita('[SILENZIO]'), '');
      expect(LaTrascrizione.pulita('[SILENZIO].'), '');
      expect(LaTrascrizione.pulita('Prima riga\nSeconda riga'),
          'Prima riga Seconda riga');
      expect(LaTrascrizione.pulita('Caligo, ciao'), 'Calìgo, ciao');
    });
  });

  test('LA SCHERMATA FA I CONTROLLI E LA STANZA IMPARA DALLE FRASI VUOTE', () {
    final schermata = File('lib/features/maestri/live/schermata_live.dart')
        .readAsStringSync();
    for (final pezzo in [
      '_orecchio.suControllo = _alControllo;',
      '_giudizio.giudica(',
      'if (_orecchio.scarta(frase)) {\n            _frasi.dimentica();',
      'if (!_orecchio.chiudi(frase)) _anticipata = null;',
      'if (trascritta && detto.isEmpty) _orecchio.eraSottofondo(frase);',
    ]) {
      expect(schermata.contains(pezzo), isTrue,
          reason: 'nella schermata manca "$pezzo"');
    }
    final orecchio =
        File('lib/services/voce/l_orecchio_del_live.dart').readAsStringSync();
    expect(
        orecchio.contains('suControllo?.call(_parlato.toBytes(), _frase, '
            '_silenzio.controlli);'),
        isTrue,
        reason: 'l\'orecchio non chiede i controlli');
    expect(orecchio.contains('return pulita(risposta.text ?? \'\');'), isTrue,
        reason: 'la trascrizione di Gemini non passa dalla pulizia');
  });
}

/// Un pezzo: il livello in decibel e quanto e' voce.
typedef Pezzo = ({double db, double voce});

/// **I pezzi di voce della televisione finta come li ha sentiti il Realme**,
/// 25 settembre 2026, scena `tv1` del banco dell'ordine EM: 243 righe del
/// registro ORECCHIO con la voce sopra 0,55, fuori dalla domanda. Mediana
/// -30 dB, novantesimo percentile -25, massimo -21.
final televisioneDelRealme = <int>[
  -68, -65, -64, -64, -61, -60, -58, -56, -56, -55, -52, -50, -49, -47, -47, //
  -46, -44, -44, -42, -42, -41, -41, -41, -41, -40, -40, -40, -40, -40, -40,
  -39, -39, -38, -38, -38, -38, -38, -38, -38, -37, -37, -36, -36, -36,
  ...[for (var i = 0; i < 14; i++) -35],
  ...[for (var i = 0; i < 8; i++) -34],
  ...[for (var i = 0; i < 12; i++) -33],
  ...[for (var i = 0; i < 16; i++) -32],
  ...[for (var i = 0; i < 14; i++) -31],
  ...[for (var i = 0; i < 19; i++) -30],
  ...[for (var i = 0; i < 22; i++) -29],
  ...[for (var i = 0; i < 21; i++) -28],
  ...[for (var i = 0; i < 23; i++) -27],
  ...[for (var i = 0; i < 14; i++) -26],
  ...[for (var i = 0; i < 20; i++) -25],
  ...[for (var i = 0; i < 6; i++) -24],
  ...[for (var i = 0; i < 7; i++) -23],
  -22, -22, -21,
];
