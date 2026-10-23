// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/rituals/avvisi_del_rito.dart';
import 'package:esoteric_circle/core/rituals/daily_elements.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **UNA SOLA NOTIFICA PER DONO, COL NOME GIUSTO.** Ordine ES voce 17, 29
/// settembre 2026.
///
/// **Il fatto del fondatore**: il 28 settembre alle 22:30 la notifica del
/// Sigillo del Sogno, alle 22:40 due volte la stessa di "Caligo". Tre
/// notifiche per un Dono, a nome di un Maestro che non e' quello del Dono.
///
/// **Il padre**: l'ordine CG voce 16, che dava alla push il tag `dono_1104`
/// credendo che sostituisse la chiamata locale 1104. Adesso la push arriva
/// come dato e la mostra l'app, dalla porta sola degli avvisi, con
/// l'identificativo della locale, e una sola volta al giorno. Qui si
/// provano i tre casi, col servizio degli avvisi finto che conta cosa mostra
/// e cosa programma.
class _Telefono extends ServizioAvvisi {
  final mostrate = <(int, String, String)>[];
  final programmate = <(int, DateTime)>[];
  final annullate = <int>[];

  /// Gli avvisi ancora in coda: una locale che suona esce dalla coda.
  final inCoda = <int>{};

  /// La locale suona, come fa il sistema alla sua ora.
  void suona(int id) => inCoda.remove(id);

  @override
  bool get disponibile => true;
  @override
  Future<bool> chiediPermesso() async => true;
  @override
  Future<bool> permessoConcesso() async => true;
  @override
  Future<void> programma({
    required int id,
    required DateTime quando,
    required String titolo,
    required String testo,
    String canale = 'rito_alba',
    String carico = '',
  }) async {
    programmate.add((id, quando));
    inCoda.add(id);
  }

  @override
  Future<void> annulla(int id) async {
    annullate.add(id);
    inCoda.remove(id);
  }

  @override
  Future<List<int>> inAttesa() async => inCoda.toList();
  @override
  Future<void> mostraAdesso(
      {required String titolo, required String testo}) async {}
  @override
  Future<void> mostraDelDono({
    required int id,
    required String titolo,
    required String testo,
    required String canale,
    String carico = '',
  }) async =>
      mostrate.add((id, titolo, testo));
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  const notte = DailyElement.night;
  final idNotte = AvvisiDelRito.idDelDono(notte);

  test('la push che arriva prima della locale la sostituisce, una volta',
      () async {
    final telefono = _Telefono();
    // La regia del giorno programma la locale del Sigillo per le 22:30.
    await AvvisiDelRito.programmaLeChiamateDelGiorno(
        servizio: telefono,
        adesso: DateTime(2026, 9, 28, 20),
        doniAccesi: const [notte]);
    // La push arriva alle 22:30 in punto, prima che il telefono suoni la
    // locale, che e' approssimata.
    final esito = await AvvisiDelRito.allaPushDelDono(
        servizio: telefono, dono: notte, adesso: DateTime(2026, 9, 28, 22, 30));
    // E poi ne arriva una seconda, come la sera del fondatore.
    final seconda = await AvvisiDelRito.allaPushDelDono(
        servizio: telefono, dono: notte, adesso: DateTime(2026, 9, 28, 22, 43));
    print('ORDINE ES VOCE 17: prima push $esito, seconda $seconda, notifiche '
        'mostrate ${telefono.mostrate.length}');
    expect(esito, EsitoDellaPush.mostrata);
    expect(seconda, EsitoDellaPush.giaMostrata,
        reason: 'la seconda push dello stesso Dono ha portato una seconda '
            'notifica');
    expect(telefono.mostrate, hasLength(1));
    expect(telefono.mostrate.single.$1, idNotte,
        reason: 'la push non usa l\'identificativo della locale: non la '
            'sostituisce, le affianca');
    expect(telefono.annullate, contains(idNotte),
        reason: 'la locale di stasera resta in coda e suonera\' dopo la push');
    expect(telefono.programmate.last.$2, DateTime(2026, 9, 29, 22, 30),
        reason: 'la locale di domani, la rete di sicurezza, non e\' tornata');
  });

  test('la push che arriva dopo la locale non ne aggiunge un\'altra', () async {
    final telefono = _Telefono();
    await AvvisiDelRito.programmaLeChiamateDelGiorno(
        servizio: telefono,
        adesso: DateTime(2026, 9, 28, 20),
        doniAccesi: const [notte]);
    // La locale suona alle 22:30; il giro del server arriva alle 22:43.
    telefono.suona(idNotte);
    final esito = await AvvisiDelRito.allaPushDelDono(
        servizio: telefono, dono: notte, adesso: DateTime(2026, 9, 28, 22, 43));
    expect(esito, EsitoDellaPush.localeGiaArrivata);
    expect(telefono.mostrate, isEmpty,
        reason: 'la locale e\' gia\' arrivata alle 22:30, e la push ne ha '
            'mostrata un\'altra');
  });

  test('senza locale di oggi la push si mostra', () async {
    final telefono = _Telefono();
    // L'app non si apre da giorni: nessuna locale per stasera.
    final esito = await AvvisiDelRito.allaPushDelDono(
        servizio: telefono, dono: notte, adesso: DateTime(2026, 9, 28, 22, 30));
    expect(esito, EsitoDellaPush.mostrata);
    expect(telefono.mostrate, hasLength(1));
  });

  test('il Sigillo del Sogno porta il nome di Medora, ogni Dono il suo', () {
    final righe = <String>[];
    for (final d in DailyElement.values) {
      final maestro = DailyElements.maestroFor(d, DateTime(2026, 9, 28));
      final titolo = AvvisiDelRito.titoloDelDono(d, DateTime(2026, 9, 28));
      righe.add('${d.name}: $titolo');
      expect(titolo, startsWith(maestro.displayName),
          reason: 'la notifica del Dono ${d.name} non porta il nome del suo '
              'Maestro: "$titolo"');
    }
    print('ORDINE ES VOCE 17: ${righe.join("; ")}');
    expect(AvvisiDelRito.titoloDelDono(notte, DateTime(2026, 9, 28)),
        startsWith('Medora'));
  });
}
