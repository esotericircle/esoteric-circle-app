import 'package:esoteric_circle/core/sigilli/diario_del_cammino.dart';
import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **L'EVENTO CHE ARMA UN GRADINO E' ESATTAMENTE CIO' CHE LA SUA CONDIZIONE
/// DESCRIVE.** Ordine CP voce 07, 3 settembre 2026.
///
/// Parole dell'ordine: *"non e' una verifica a campione: e' una riga per
/// gradino"*. Qui ogni gradino dei 165 viene provato due volte, con lo stato
/// che la sua condizione chiede e con lo stato che ne ha **uno di meno**: se
/// il primo non lo accende, il gradino e' irraggiungibile; se il secondo lo
/// accende, la soglia scritta non e' la soglia che l'app misura.
///
/// **Perche' non basta la revisione F.** La revisione F ha chiuso la fessura
/// dal lato del TESTO: la frase si compone dalla condizione, quindi non puo'
/// piu' contraddirla. Resta l'altro lato, quello del CONTO: la condizione
/// dice "dieci giorni" e il diario potrebbe contarne nove, o contare aperture
/// invece di giorni. Questa prova misura quello.
///
/// La seconda parte prova la catena intera, dal gesto al gradino, per ogni
/// specie di condizione che il corpus usa: li' non si costruisce uno stato a
/// mano, si compiono gesti veri su un diario vero.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Lo stato che soddisfa ESATTAMENTE questa condizione, con la quantita'
  /// [quanto] al posto della soglia. Con `quanto` uguale alla soglia il
  /// gradino deve accendersi, con uno di meno deve restare spento.
  StatoDelCammino statoPer(CondizioneDelTraguardo c, {required int meno}) {
    switch (c) {
      case GestiCompiuti(:final gesto, :final quanti, :final inGiorniDiversi):
        final n = quanti - meno;
        return inGiorniDiversi
            ? StatoDelCammino(giorniConGesto: {gesto: n})
            : StatoDelCammino(gestiCompiuti: {gesto: n});
      case GiorniDentroUnArco(:final rito, :final quanti, :final arco):
        return StatoDelCammino(costanzeLarghe: {'$rito:$arco': quanti - meno});
      case GiorniDiSeguito(:final rito, :final quanti):
        return StatoDelCammino(seriePerRito: {rito: quanti - meno});
      case StessaOraPerGiorni(:final gesto, :final quantiGiorni):
        return StatoDelCammino(
            oraFedelePerGesto: {gesto: quantiGiorni - meno});
      case GestoNellOraGiusta(:final gesto, :final ora, :final quanteVolte):
        return StatoDelCammino(
            gestiNellOraGiusta: {'$gesto@$ora': quanteVolte - meno});
      case GiornateInsieme(:final chiave, :final quantiGiorni):
        return StatoDelCammino(
            giornateInsieme: {chiave: quantiGiorni - meno});
      case PezzoDellIdentita(:final pezzo):
        // **IL MENO, per un pezzo che si ha o non si ha, e' non averlo.**
        return StatoDelCammino(
            pezziDellIdentita: meno == 0 ? {pezzo} : const <String>{});
      case FinestraDelCielo(:final evento, :final conGesto):
        // **IL MENO, per una finestra del cielo, e' il gesto senza
        // l'evento**: e' il caso che conta, perche' un gradino che si
        // accendesse col solo gesto avrebbe promesso il cielo e dato un
        // tocco. Il caso opposto, l'evento senza il gesto, si prova sotto.
        return StatoDelCammino(
          eventiDelCieloDiOggi: meno == 0 ? {evento} : const <String>{},
          oggiHaFatto: conGesto == null ? const <String>{} : {conGesto},
        );
      default:
        throw StateError('specie senza stato di prova: ${c.runtimeType}');
    }
  }

  test('ogni gradino si accende con la quantita che dichiara', () {
    var provati = 0;
    final muti = <String>[];
    for (final t in Sentieri.tuttiITraguardi) {
      provati++;
      if (!t.condizione.raggiunto(statoPer(t.condizione, meno: 0))) {
        muti.add('${t.id} (${t.condizione.firma}) non si accende nemmeno con '
            'lo stato che la sua condizione chiede');
      }
    }
    // ignore: avoid_print
    print('ORDINE CP VOCE 07: gradini provati in accensione $provati');
    expect(provati, 165);
    expect(muti, isEmpty, reason: muti.join('\n'));
  });

  test('nessun gradino si accende con uno di meno', () {
    // **LA META\' CHE MANCAVA SEMPRE.** Le guardie di questa casa provavano
    // che una condizione si accende, quasi mai che TRATTIENE: e' la cecita'
    // trovata il 3 settembre 2026 sull'ora fedele, dove sostituire la soglia
    // con uno zero lasciava verdi tutte e tre le prove.
    var provati = 0;
    final generosi = <String>[];
    for (final t in Sentieri.tuttiITraguardi) {
      provati++;
      if (t.condizione.raggiunto(statoPer(t.condizione, meno: 1))) {
        generosi.add('${t.id} (${t.condizione.firma}) si accende con uno di '
            'meno di quello che dichiara');
      }
    }
    // ignore: avoid_print
    print('ORDINE CP VOCE 07: gradini provati in ritenuta $provati');
    expect(provati, 165);
    expect(generosi, isEmpty, reason: generosi.join('\n'));
  });

  test('una finestra del cielo non si apre col solo evento, senza il gesto',
      () {
    // Il contrario del caso di sopra: il cielo c'e', il gesto no. Un gradino
    // che si accendesse cosi' premierebbe l'aver aperto l'app nel giorno
    // giusto, che non e' quello che promette.
    var provati = 0;
    final regalati = <String>[];
    for (final t in Sentieri.tuttiITraguardi) {
      final c = t.condizione;
      if (c is! FinestraDelCielo || c.conGesto == null) continue;
      provati++;
      final soloCielo = StatoDelCammino(eventiDelCieloDiOggi: {c.evento});
      if (c.raggiunto(soloCielo)) {
        regalati.add('${t.id} si accende col solo ${c.evento}, senza '
            '${c.conGesto}');
      }
    }
    // ignore: avoid_print
    print('ORDINE CP VOCE 07: finestre del cielo provate senza gesto '
        '$provati');
    expect(provati, 48);
    expect(regalati, isEmpty, reason: regalati.join('\n'));
  });

  group('CP.07, la catena intera dal gesto al gradino', () {
    ({DiarioDelCammino diario, void Function(DateTime) sposta}) conOrologio(
        DateTime partenza) {
      var adesso = partenza;
      final diario = DiarioDelCammino(orologio: () => adesso);
      return (diario: diario, sposta: (DateTime q) => adesso = q);
    }

    /// Compie [gesto] in [giorni] giornate diverse, una al giorno, e torna il
    /// diario. **Non si costruisce nessuno stato a mano**: si passa dalla
    /// porta che le schermate usano.
    Future<StatoDelCammino> dopoGiorniDiGesto(String gesto, int giorni,
        {int ora = 8, int saltaOgni = 0}) async {
      SharedPreferences.setMockInitialValues(const {});
      final o = conOrologio(DateTime(2026, 1, 1, ora));
      await o.diario.carica();
      var quando = DateTime(2026, 1, 1, ora);
      for (var i = 0; i < giorni; i++) {
        o.sposta(quando);
        await o.diario.segna(gesto, oraRituale: 'alba');
        quando = quando.add(Duration(days: saltaOgni > 0 && i % saltaOgni == 0
            ? 2
            : 1));
      }
      return o.diario.statoDelCammino();
    }

    test('GestiCompiuti: dieci giorni di gettata accendono cal_14', () async {
      final t = Sentieri.tuttiITraguardi.firstWhere((t) => t.id == 'cal_14');
      expect(t.condizione, isA<GestiCompiuti>());
      final quanti = (t.condizione as GestiCompiuti).quanti;
      final quasi = await dopoGiorniDiGesto('gettata', quanti - 1);
      expect(t.condizione.raggiunto(quasi), isFalse,
          reason: '${t.id} si accende con ${quanti - 1} giorni di gettata, e '
              'ne dichiara $quanti');
      final giusto = await dopoGiorniDiGesto('gettata', quanti);
      // ignore: avoid_print
      print('ORDINE CP VOCE 07: con $quanti giorni di gettata, ${t.id} si '
          'accende? ${t.condizione.raggiunto(giusto)}');
      expect(t.condizione.raggiunto(giusto), isTrue);
    });

    test('GiorniDentroUnArco: sei Arcani in otto giorni accendono med_10',
        () async {
      final t = Sentieri.tuttiITraguardi.firstWhere((t) => t.id == 'med_10');
      final c = t.condizione as GiorniDentroUnArco;
      final quasi = await dopoGiorniDiGesto(c.rito, c.quanti - 1);
      expect(t.condizione.raggiunto(quasi), isFalse);
      final giusto = await dopoGiorniDiGesto(c.rito, c.quanti);
      // ignore: avoid_print
      print('ORDINE CP VOCE 07: con ${c.quanti} giorni di ${c.rito} dentro '
          '${c.arco}, ${t.id} si accende? ${t.condizione.raggiunto(giusto)}');
      expect(t.condizione.raggiunto(giusto), isTrue);
    });

    test('StessaOraPerGiorni: quattordici mattine accendono med_15', () async {
      final t = Sentieri.tuttiITraguardi.firstWhere((t) => t.id == 'med_15');
      final c = t.condizione as StessaOraPerGiorni;
      final quasi = await dopoGiorniDiGesto(c.gesto, c.quantiGiorni - 1);
      expect(t.condizione.raggiunto(quasi), isFalse);
      final giusto = await dopoGiorniDiGesto(c.gesto, c.quantiGiorni);
      // ignore: avoid_print
      print('ORDINE CP VOCE 07: con ${c.quantiGiorni} mattine alla stessa '
          'ora, ${t.id} si accende? ${t.condizione.raggiunto(giusto)}');
      expect(t.condizione.raggiunto(giusto), isTrue);
    });

    test('GiornateInsieme: quattro giornate col cielo e le carte accendono '
        'med_6', () async {
      final t = Sentieri.tuttiITraguardi.firstWhere((t) => t.id == 'med_6');
      final c = t.condizione as GiornateInsieme;
      SharedPreferences.setMockInitialValues(const {});
      final o = conOrologio(DateTime(2026, 1, 1, 8));
      await o.diario.carica();
      for (var i = 0; i < c.quantiGiorni; i++) {
        o.sposta(DateTime(2026, 1, 1 + i, 8));
        if (i == 0) {
          // **UNA GIORNATA MONCA NON CONTA**: il primo giorno si fa un gesto
          // solo dei due, e la giornata non deve valere.
          await o.diario.segna(c.gesti.first);
        } else {
          for (final gesto in c.gesti) {
            await o.diario.segna(gesto);
          }
        }
      }
      final quasi = o.diario.statoDelCammino();
      expect(t.condizione.raggiunto(quasi), isFalse,
          reason: 'una giornata in cui e\' stato fatto un gesto solo dei due '
              'ha contato come giornata chiusa');
      o.sposta(DateTime(2026, 1, 1 + c.quantiGiorni, 8));
      for (final gesto in c.gesti) {
        await o.diario.segna(gesto);
      }
      final giusto = o.diario.statoDelCammino();
      // ignore: avoid_print
      print('ORDINE CP VOCE 07: giornate con ${c.gesti.join(" e ")} insieme '
          '${giusto.giornateInsieme[c.chiave]}, ne chiede ${c.quantiGiorni}');
      expect(t.condizione.raggiunto(giusto), isTrue);
    });

    test('GestoNellOraGiusta: nove Arcani all\'alba accendono med_12',
        () async {
      final t = Sentieri.tuttiITraguardi.firstWhere((t) => t.id == 'med_12');
      final c = t.condizione as GestoNellOraGiusta;
      final quasi = await dopoGiorniDiGesto(c.gesto, c.quanteVolte - 1);
      expect(t.condizione.raggiunto(quasi), isFalse);
      final giusto = await dopoGiorniDiGesto(c.gesto, c.quanteVolte);
      // ignore: avoid_print
      print('ORDINE CP VOCE 07: con ${c.quanteVolte} Arcani nell\'ora '
          '${c.ora}, ${t.id} si accende? ${t.condizione.raggiunto(giusto)}');
      expect(t.condizione.raggiunto(giusto), isTrue);
    });

    test('PezzoDellIdentita: la carta natale accende med_1', () async {
      final t = Sentieri.tuttiITraguardi.firstWhere((t) => t.id == 'med_1');
      SharedPreferences.setMockInitialValues(const {});
      final o = conOrologio(DateTime(2026, 1, 1, 8));
      await o.diario.carica();
      // **I PEZZI DELL'IDENTITA' ENTRANO NELLA FOTOGRAFIA DA FUORI**, e non
      // e' una scorciatoia della prova: la regia li legge dal profilo, non
      // dal diario, perche' la carta natale puo' arrivare anche senza che
      // nessun gesto sia stato compiuto.
      expect(t.condizione.raggiunto(o.diario.statoDelCammino()), isFalse,
          reason: 'med_1 si accende con un profilo vuoto');
      final conCarta =
          o.diario.statoDelCammino(pezziDellIdentita: const {'carta_natale'});
      // ignore: avoid_print
      print('ORDINE CP VOCE 07: con la carta natale nel profilo, med_1 si '
          'accende? ${t.condizione.raggiunto(conCarta)}');
      expect(t.condizione.raggiunto(conCarta), isTrue);
    });
  });
}
