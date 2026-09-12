import 'package:esoteric_circle/core/maestro/il_respiro_di_oggi.dart';
import 'package:esoteric_circle/core/maestro/libreria_dei_respiri.dart';
import 'package:esoteric_circle/core/maestro/memoria_del_respiro.dart';
import 'package:esoteric_circle/core/maestro/ora_del_respiro.dart';
import 'package:esoteric_circle/core/rituals/daily_elements.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **LA MEDITAZIONE SI ADATTA A CHI RESPIRA.** Ordine DA voci 04, 05 e 06,
/// 10 settembre 2026.
///
/// **DA DOVE NASCONO, e non da una prova.** Nel manifesto dell'ordine DB, alla
/// voce 12, avevo scritto tre cose che la memoria del respiro poteva gia' fare
/// e che nessuno usava. Il fondatore ha detto di procedere, e questa guardia
/// e' la misura di tutte e tre.
///
/// **REGOLA H, e qui vale il doppio.** Ogni cosa che questa guardia dimostra
/// presente deve essere dimostrata **assente quando non e' vera**: l'avviso
/// non si sposta senza abitudine, la pratica breve non si propone a chi
/// finisce le sessioni, e il Sigillo non parla del respiro a chi oggi non ha
/// respirato. **Una funzione che si accende sempre non e' attenzione, e'
/// rumore.**
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  final ancora = DailyElement.breath.anchorMinutes;

  Future<MemoriaDelRespiro> conSessioni(List<SessioneDiRespiro> quali) async {
    final m = MemoriaDelRespiro();
    for (final s in quali) {
      await m.segna(s);
    }
    return m;
  }

  SessioneDiRespiro sessione({
    required DateTime quando,
    int centro = 3,
    int minuti = 5,
    bool compiuta = true,
  }) =>
      SessioneDiRespiro(
        quando: quando,
        centro: centro,
        durata: Duration(minutes: minuti),
        compiuta: compiuta,
        guidato: false,
      );

  group('DA.04, l ora del Soffio segue chi respira', () {
    test('CON UNA ABITUDINE VERA L AVVISO SI SPOSTA', () async {
      // Quattro sessioni alle 22, che e' un'abitudine dichiarabile.
      final m = await conSessioni([
        for (var g = 0; g < 4; g++)
          sessione(quando: DateTime(2026, 9, 1 + g, 22, 10)),
      ]);
      final suggeriti = OraDelRespiro.minutiSuggeriti(m,
          minutiDiPartenza: ancora, minutiScelti: ancora);
      // ignore: avoid_print
      print('ORDINE DA VOCE 04: ora di partenza ${ancora ~/ 60}, suggerita '
          '${suggeriti == null ? "nessuna" : suggeriti ~/ 60}');
      expect(suggeriti, isNotNull,
          reason: 'quattro sessioni alla stessa ora non spostano l avviso: '
              'la memoria sa dove torna quella persona e l app non la usa');
      expect(suggeriti! ~/ 60, 22);
    });

    test('REGOLA H: SENZA ABITUDINE NON SI SPOSTA NIENTE', () async {
      // Tre sessioni a tre ore diverse: nessuna fascia si stacca.
      final m = await conSessioni([
        sessione(quando: DateTime(2026, 9, 1, 7)),
        sessione(quando: DateTime(2026, 9, 2, 14)),
        sessione(quando: DateTime(2026, 9, 3, 21)),
      ]);
      expect(
          OraDelRespiro.minutiSuggeriti(m,
              minutiDiPartenza: ancora, minutiScelti: ancora),
          isNull,
          reason: 'l avviso si sposta su un ora che non e un abitudine: e '
              'rumore travestito da attenzione');
    });

    test('REGOLA H: UN ORA SCELTA A MANO NON SI TOCCA', () async {
      final m = await conSessioni([
        for (var g = 0; g < 5; g++)
          sessione(quando: DateTime(2026, 9, 1 + g, 22, 10)),
      ]);
      // La persona ha messo l avviso alle 9 dal menu delle Notifiche.
      expect(
          OraDelRespiro.minutiSuggeriti(m,
              minutiDiPartenza: ancora, minutiScelti: 9 * 60),
          isNull,
          reason: 'una scelta della persona e stata sovrascritta: e la legge '
              'dell ordine BC voce 05, e vale piu di qualunque deduzione');
    });

    test('REGOLA H: NON SI INSEGUE OLTRE IL CONFINE DICHIARATO', () async {
      // Quattro sessioni alle tre di notte. La memoria le vede, ma spostare
      // li un avviso di meta mattina non e seguire, e inseguire.
      final m = await conSessioni([
        for (var g = 0; g < 4; g++)
          sessione(quando: DateTime(2026, 9, 1 + g, 3, 5)),
      ]);
      final suggeriti = OraDelRespiro.minutiSuggeriti(m,
          minutiDiPartenza: ancora, minutiScelti: ancora);
      // ignore: avoid_print
      print('ORDINE DA VOCE 04: con le sessioni alle 3 di notte la proposta e '
          '${suggeriti == null ? "nessuna" : suggeriti ~/ 60}, e la notte '
          'comincia alle ${OraDelRespiro.nonPrimaDelle ~/ 60}');
      expect(suggeriti, isNull,
          reason: 'l avviso e finito nel cuore della notte: il confine fra le '
              '${OraDelRespiro.nonPrimaDelle ~/ 60} e l una non sta reggendo');
    });

    test('E LA PERSONA LO SA, perche una riga glielo dice', () {
      expect(OraDelRespiro.laRiga(22 * 60), contains('22'));
      expect(OraDelRespiro.laRiga(null), isNull,
          reason: 'si annuncia uno spostamento che non e avvenuto');
    });
  });

  group('DA.05, la pratica piu breve a chi lascia a meta', () {
    test('CHI LASCIA A META TROVA UNA PRATICA CHE STA NEL SUO TEMPO', () async {
      // Cinque sessioni da due minuti, quattro delle quali interrotte.
      final m = await conSessioni([
        for (var g = 0; g < 5; g++)
          sessione(
              quando: DateTime(2026, 9, 1 + g, 22),
              minuti: 2,
              compiuta: g == 0),
      ]);
      // ignore: avoid_print
      print('ORDINE DA VOCE 05: durano davvero '
          '${m.quantoDuraDavvero?.inMinutes} minuti, lasciate a meta '
          '${((m.quanteSiLascianoAMeta ?? 0) * 100).toStringAsFixed(0)} per '
          'cento, l app chiede troppo ${m.chiedeTroppo}');
      expect(m.chiedeTroppo, isTrue,
          reason: 'quattro sessioni su cinque lasciate a meta e l app non se '
              'ne accorge: aspetta che la persona smetta');
      final quanto = m.quantoDuraDavvero!;
      final piuCorta = LibreriaDeiRespiri.piuCortaDi(quanto);
      expect(piuCorta, isNotNull,
          reason: 'non c e nessuna pratica che stia in ${quanto.inMinutes} '
              'minuti: allora la libreria non ha niente per chi ha poco tempo');
      expect(piuCorta!.durata, lessThanOrEqualTo(quanto),
          reason: 'la pratica proposta dura piu di quanto quella persona '
              'riesca a stare');
    });

    test('REGOLA H: A CHI FINISCE LE SESSIONI NON SI PROPONE NIENTE', () async {
      final m = await conSessioni([
        for (var g = 0; g < 6; g++)
          sessione(quando: DateTime(2026, 9, 1 + g, 22), minuti: 7),
      ]);
      expect(m.chiedeTroppo, isFalse,
          reason: 'a chi porta a termine tutte le sessioni viene proposta una '
              'pratica piu corta: e un giudizio, non un aiuto');
    });

    test('REGOLA H: SOTTO LE QUATTRO SESSIONI NON SI MISURA NIENTE', () async {
      final m = await conSessioni([
        sessione(quando: DateTime(2026, 9, 1, 22), minuti: 1, compiuta: false),
        sessione(quando: DateTime(2026, 9, 2, 22), minuti: 1, compiuta: false),
      ]);
      expect(m.quantoDuraDavvero, isNull,
          reason: 'due sessioni bastano a dichiarare quanto dura una sessione: '
              'non e un abitudine, e quello che e successo l altro ieri');
      expect(m.chiedeTroppo, isFalse);
    });

    test('SI GUARDA LA MEDIANA, non la media', () async {
      // Cinque sessioni da due minuti e una da un'ora: la media direbbe dodici
      // minuti, la mediana due.
      final m = await conSessioni([
        for (var g = 0; g < 5; g++)
          sessione(quando: DateTime(2026, 9, 1 + g, 22), minuti: 2),
        sessione(quando: DateTime(2026, 9, 6, 22), minuti: 60),
      ]);
      final mediana = m.quantoDuraDavvero!;
      // ignore: avoid_print
      print('ORDINE DA VOCE 05: con cinque sessioni da 2 minuti e una da 60, '
          'la mediana e ${mediana.inMinutes} minuti');
      expect(mediana.inMinutes, lessThanOrEqualTo(3),
          reason: 'una sola sessione lunga ha spostato la misura: si guarda '
              'la mediana proprio per questo');
    });
  });

  group('DA.06, il Sigillo del Sogno legge il respiro di oggi', () {
    test('CHI HA RESPIRATO OGGI TROVA UN FATTO DELLA SUA GIORNATA', () async {
      final oggi = DateTime(2026, 9, 10, 22, 30);
      final m = await conSessioni([
        sessione(quando: DateTime(2026, 9, 10, 21), centro: 3),
      ]);
      final riga = IlRespiroDiOggi.laRiga(m, oggi);
      // ignore: avoid_print
      print('ORDINE DA VOCE 06: il Sigillo dice "$riga"');
      expect(riga, isNotNull,
          reason: 'chi ha respirato stasera non trova niente nel rito che '
              'chiude la giornata');
      // **E non promette e non chiede**, che e la legge dei testi di casa.
      for (final vietata in const ['sarà', 'otterrai', 'vedrai che', 'devi']) {
        expect(riga!.toLowerCase().contains(vietata), isFalse,
            reason: 'la riga del respiro promette con "$vietata"');
      }
    });

    test('REGOLA H: CHI NON HA RESPIRATO OGGI NON TROVA NIENTE', () async {
      final m = await conSessioni([
        sessione(quando: DateTime(2026, 9, 3, 21)),
      ]);
      expect(IlRespiroDiOggi.laRiga(m, DateTime(2026, 9, 10, 22, 30)), isNull,
          reason: 'il Sigillo racconta un respiro di una settimana fa come se '
              'fosse di oggi: e una giornata inventata');
    });

    test('REGOLA H: A MEMORIA VUOTA NON NASCE NESSUNA RIGA', () async {
      final m = MemoriaDelRespiro();
      await m.carica();
      expect(IlRespiroDiOggi.laRiga(m, DateTime(2026, 9, 10, 22)), isNull);
    });

    test('CHI SI E FERMATO A META NON VIENE CORRETTO', () async {
      final oggi = DateTime(2026, 9, 10, 22, 30);
      final m = await conSessioni([
        sessione(
            quando: DateTime(2026, 9, 10, 21), centro: 3, compiuta: false),
      ]);
      final riga = IlRespiroDiOggi.laRiga(m, oggi)!;
      // ignore: avoid_print
      print('ORDINE DA VOCE 06: a chi si e fermato dice "$riga"');
      for (final rimprovero in const [
        'non hai finito',
        'interrott',
        'a metà',
        'riprova',
      ]) {
        expect(riga.toLowerCase().contains(rimprovero), isFalse,
            reason: 'la riga rimprovera con "$rimprovero": chi si e fermato '
                'ha comunque respirato');
      }
    });
  });
}
