import 'package:esoteric_circle/core/rituals/filo_del_giorno.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cardinale_minimo.dart';

/// **LA PAROLA DELL'ALBA TORNA LA SERA, ANCHE A CHI SI ALZA PRESTO.**
/// Ordine CY, voce rimasta aperta, 9 settembre 2026.
///
/// **Parole del fondatore**: *"l'alba dichiara che la parola verra' ripresa la
/// sera nel sigillo del sogno, ma a me non sembra proprio che accada"*.
///
/// **LA CAUSA, e non e' dove sembrava.** Il filo del giorno segna e rilegge col
/// **giorno rituale**, che prima delle cinque del mattino punta al giorno
/// precedente. La ragione di quel confine e' giusta e sta scritta nel codice:
/// *"le cinque fasce dei doni finiscono col Sigillo del Sogno alle 22:30; chi
/// arriva dopo la mezzanotte e prima delle cinque sta ancora vivendo quella
/// sera"*.
///
/// **Ma quel confine e' pensato per chi va a dormire tardi, non per chi si
/// alza presto.** L'Alba e' il rito che APRE la giornata: chi la compie alle
/// due o alle quattro del mattino non sta chiudendo ieri, sta cominciando
/// oggi. La sua parola finiva sotto il giorno prima, e la sera dello stesso
/// giorno il Sigillo la cercava sotto oggi e **non la trovava**.
///
/// **REGOLA H.** Non basta provare che la parola torna a chi si alza presto:
/// si prova anche che **il confine delle cinque continua a funzionare** per il
/// caso per cui esiste, cioe' il Sigillo compiuto dopo la mezzanotte. Curare
/// un caso rompendo l'altro sarebbe scambiare un difetto con un altro.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// I casi veri, con l'ora dell'Alba e l'ora del Sigillo.
  final casi = <String, (DateTime, DateTime, bool)>{
    'alba alle 7, sigillo alle 22:30 dello stesso giorno': (
      // Il caso normale: deve funzionare e funzionava.
      _alba7,
      _sera,
      true,
    ),
    'alba alle 7, sigillo alle 00:30 del giorno dopo': (
      // Il caso per cui il confine delle cinque esiste: chi chiude la
      // giornata dopo la mezzanotte sta ancora vivendo quella sera.
      _alba7,
      _dopoMezzanotte,
      true,
    ),
    'ALBA ALLE 2 DI NOTTE, sigillo alle 22:30 dello stesso giorno': (
      // **IL CASO ROTTO.** Chi si alza alle due sta cominciando oggi, non
      // chiudendo ieri, e la sera la sua parola deve tornare.
      _alba2,
      _sera,
      true,
    ),
    'ALBA ALLE 4 DI NOTTE, sigillo alle 23 dello stesso giorno': (
      _alba4,
      _seraTardi,
      true,
    ),
  };

  for (final voce in casi.entries) {
    test('la parola torna: ${voce.key}', () async {
      SharedPreferences.setMockInitialValues(const {});
      final (quandoAlba, quandoSera, deveTornare) = voce.value;
      await FiloDelGiorno.segnaLaParola('SOGLIA', quandoAlba);
      final letta = await FiloDelGiorno.parolaDiStamattina(quandoSera);
      // ignore: avoid_print
      print('ORDINE CY: alba ${quandoAlba.hour}:00 del ${quandoAlba.day}, '
          'sigillo ${quandoSera.hour}:${quandoSera.minute.toString().padLeft(2, "0")} '
          'del ${quandoSera.day}, parola ritrovata ${letta ?? "NESSUNA"}');
      if (deveTornare) {
        expect(letta, 'SOGLIA',
            reason: 'la parola presa all\'alba delle ${quandoAlba.hour} non '
                'torna nel Sigillo delle ${quandoSera.hour}: l\'Alba promette '
                'che la sera verra\' ripresa, e non accade');
      } else {
        expect(letta, isNull,
            reason: 'torna una parola che non e\' di questa giornata');
      }
    });
  }

  test('LA LENTE DICE COSA FARSENE, e non manda a caccia', () {
    // **La domanda del fondatore, ripetuta piu volte**: *"COSA DEVE FARSENE
    // L UTENTE DELLA PAROLA DEL GIORNO? DEVE CERCARLA NELLE ATTIVITA
    // QUOTIDIANE? O IL DESTINO E LE STELLE GLIELA METTERANNO DAVANTI?"*
    //
    // **Nessuna delle due**, ed e la risposta approvata: la parola e una
    // lente, non una caccia al tesoro e non un'attesa del destino.
    final lente = FiloDelGiorno.laLente('SOGLIA');
    // ignore: avoid_print
    print('ORDINE CY: la lente dice "$lente"');
    expect(lente.toLowerCase(), contains('non cercarla'),
        reason: 'la lente non dice che la parola NON si cerca: chi legge la '
            'mette in una caccia al tesoro, la trova ovunque, e trovarla '
            'ovunque vale quanto non trovarla mai');
    expect(lente.toLowerCase(), contains('riconoscere'),
        reason: 'la lente non dice a cosa serve davvero la parola');
    // **REGOLA H: e non promette il destino.** Promettere che le stelle la
    // mettano davanti e una promessa che questa app non puo mantenere.
    for (final vietata in const [
      'destino ti', 'le stelle ti', 'la troverai', 'ti apparira',
      'ti verra incontro', 'segno che',
    ]) {
      expect(lente.toLowerCase().contains(vietata), isFalse,
          reason: 'la lente promette con "$vietata": e una promessa che '
              'nessuno puo mantenere, e la parola diventa un oroscopo');
    }
  });

  test('IL SIGILLO CHIEDE, invece di constatare', () {
    // **Il giro si chiude con una domanda.** Prima diceva *"ha attraversato
    // il giorno con te: adesso si chiude qui"*, che e un fatto: chi lo legge
    // annuisce e passa oltre. **Una lente serve a riconoscere qualcosa**, e
    // la sera la domanda giusta e dove l hai riconosciuta, non se l hai
    // trovata: alla prima si puo rispondere, la seconda e un compito da
    // superare.
    final richiamo = FiloDelGiorno.richiamoDellaParola('SOGLIA');
    // ignore: avoid_print
    print('ORDINE CY: il Sigillo dice "$richiamo"');
    expect(richiamo, contains('SOGLIA'),
        reason: 'il Sigillo non richiama la parola del mattino');
    expect(richiamo.contains('?'), isTrue,
        reason: 'il Sigillo constata invece di chiedere: chi legge annuisce e '
            'passa oltre, e il giro non si chiude su niente');
    expect(richiamo.toLowerCase(), contains('riconosciut'),
        reason: 'il Sigillo non chiede DOVE la parola e stata riconosciuta, '
            'che e la domanda a cui la lente del mattino prepara');
  });

  test('REGOLA H: e una parola di IERI non torna oggi', () {
    // L'altra meta'. Se il filo accettasse qualunque parola recente, il
    // Sigillo di stasera richiamerebbe quella di ieri mattina, e chi la legge
    // vedrebbe una parola che non ha ricevuto oggi.
    cardinaleMinimo(casi.length, 4,
        cosa: 'casi di orario provati',
        perche: 'Con pochi casi la prova direbbe che il filo regge senza aver '
            'guardato le ore in cui si rompe.');
  });

  test('REGOLA H, il seguito: la parola di ieri NON arriva stasera', () async {
    SharedPreferences.setMockInitialValues(const {});
    // Alba di ieri mattina.
    await FiloDelGiorno.segnaLaParola('IERI', DateTime(2026, 9, 8, 7));
    // Sigillo di stasera, un giorno dopo.
    final letta =
        await FiloDelGiorno.parolaDiStamattina(DateTime(2026, 9, 9, 22, 30));
    // ignore: avoid_print
    print('ORDINE CY: parola di ieri richiamata stasera: ${letta ?? "nessuna"}');
    expect(letta, isNull,
        reason: 'il Sigillo di stasera richiama la parola di IERI mattina: '
            'chi la legge vede una parola che oggi non ha mai ricevuto');
  });
}

final _alba7 = DateTime(2026, 9, 9, 7);
final _alba2 = DateTime(2026, 9, 9, 2);
final _alba4 = DateTime(2026, 9, 9, 4);
final _sera = DateTime(2026, 9, 9, 22, 30);
final _seraTardi = DateTime(2026, 9, 9, 23);
final _dopoMezzanotte = DateTime(2026, 9, 10, 0, 30);
