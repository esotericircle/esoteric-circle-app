import 'package:esoteric_circle/core/astro/sky_location.dart';
import 'package:esoteric_circle/core/rituals/avvisi_del_rito.dart';
import 'package:esoteric_circle/core/rituals/daily_elements.dart';
import 'package:esoteric_circle/core/rituals/rito_alba.dart';
import 'package:esoteric_circle/core/rituals/scelta_degli_avvisi.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **UNA SOLA ORA PER L'ALBA.** Ordine CZ, voce 11, coda.
///
/// **MISURATO SUL TELEFONO 767f596c**, 8 settembre 2026 alle 04:30. Il menu
/// delle notifiche dichiarava **07:00** e nella coda delle sveglie del sistema
/// c'era **06:00**. Due porte scrivono lo stesso identificativo con due ore
/// diverse, e chi legge il menu non sa a che ora sara' chiamato.
///
/// **LE DUE PORTE.** `RegiaDelleChiamate` programma tutti e cinque i Doni alle
/// ore che la persona ha scelto; poi il Rito dell'Alba chiama
/// `programmaProssimo`, che riscrive lo stesso id e **non guarda l'ora
/// scelta**: con una posizione usa il sorgere vero, e senza posizione usa
/// `SunsetTime.oraMediaAlba`, cioe' le 06:00. **Quel numero non lo ha scelto
/// nessuno.**
///
/// **LA REGOLA CHE VALE, ordine BC voce 05, coda**: *"l'utente deve poter
/// cambiare anche l'orario di ogni notifica"*, e un'ora scelta a mano vale
/// piu' del sorgere del Sole. `programmaLeChiamateDelGiorno` la rispetta gia';
/// `programmaProssimo` no.
///
/// **REGOLA H**: non basta provare che l'ora scelta viene usata. Si prova
/// anche che **nessun'altra ora** finisce in coda, perche' il difetto era
/// esattamente un secondo numero che arrivava dopo.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('L\'ora scelta dalla persona vince sul sorgere e sull\'ora media',
      () async {
    SharedPreferences.setMockInitialValues(const {});
    final scelta = SceltaDegliAvvisi();
    await scelta.carica();
    // La persona sposta l'Alba alle 08:15: un'ora che non e' ne' l'ancora
    // delle 07:00, ne' il sorgere, ne' l'ora media.
    await scelta.scegliLOra(DailyElement.dawn, ora: 8, minuto: 15);

    final finto = _AvvisiCheRicordano();
    await AvvisiDelRito.programmaProssimo(
      servizio: finto,
      adesso: DateTime(2026, 9, 8, 4, 30),
      posizione: PosizioneDiStamattina.da(
        const SkyPlace(latitude: 45.4642, longitude: 9.19),
        const Duration(hours: 2),
      ),
      minutiScelti: scelta.minutiDi(DailyElement.dawn),
    );

    expect(finto.quando, isNotNull,
        reason: 'il rito non ha programmato niente: questa prova non ha '
            'guardato nessuna ora');
    final ora = finto.quando!;
    expect(ora.hour * 60 + ora.minute, 8 * 60 + 15,
        reason: 'la persona ha scelto le 08:15 e il rito ha programmato le '
            '${ora.hour}:${ora.minute.toString().padLeft(2, '0')}: e\' la '
            'seconda ora che il menu non dichiara, ed e\' il difetto visto '
            'sul telefono');
  });

  test('REGOLA H: senza posizione non compare nessuna ora media', () async {
    // **L'ASSENZA, non solo la presenza.** Senza luogo il rito ripiegava su
    // `SunsetTime.oraMediaAlba`, le 06:00: un numero che nessuno ha scelto e
    // che il menu non mostra da nessuna parte. Qui si prova che non c'e'.
    SharedPreferences.setMockInitialValues(const {});
    final finto = _AvvisiCheRicordano();
    await AvvisiDelRito.programmaProssimo(
      servizio: finto,
      adesso: DateTime(2026, 9, 8, 4, 30),
      posizione: null,
      minutiScelti: DailyElement.dawn.anchorMinutes,
    );
    final ora = finto.quando;
    expect(ora, isNotNull, reason: 'niente programmato, niente misurato');
    expect(ora!.hour * 60 + ora.minute, DailyElement.dawn.anchorMinutes,
        reason: 'senza luogo il rito ha programmato le '
            '${ora.hour}:${ora.minute.toString().padLeft(2, '0')} invece '
            'dell\'ora che il menu dichiara: e\' l\'ora media, e non l\'ha '
            'scelta nessuno');
  });

  test('Col sorgere vero e l\'ora d\'ancora, il Sole vince ancora', () async {
    // **LA PROMESSA DELL'APP RESTA IN PIEDI**: "quando il sole sorge da te".
    // Vale finche' nessuno ha cambiato l'ora, ed e' la regola dell'ordine BC
    // voce 05. Senza questa prova la cura di sopra spegnerebbe il sorgere
    // vero per tutti, che sarebbe curare un difetto rompendo una promessa.
    SharedPreferences.setMockInitialValues(const {});
    final finto = _AvvisiCheRicordano();
    await AvvisiDelRito.programmaProssimo(
      servizio: finto,
      adesso: DateTime(2026, 9, 8, 4, 30),
      posizione: PosizioneDiStamattina.da(
        const SkyPlace(latitude: 45.4642, longitude: 9.19),
        const Duration(hours: 2),
      ),
      minutiScelti: DailyElement.dawn.anchorMinutes,
    );
    final ora = finto.quando;
    expect(ora, isNotNull);
    expect(ora!.hour * 60 + ora.minute,
        isNot(DailyElement.dawn.anchorMinutes),
        reason: 'con la posizione e l\'ora d\'ancora il rito ha programmato '
            'proprio l\'ancora: il sorgere vero non arriva piu\' a nessuno, e '
            'la promessa "quando il sole sorge da te" e\' spenta');
  });
}

class _AvvisiCheRicordano extends ServizioAvvisi {
  DateTime? quando;

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
    this.quando = quando;
  }

  @override
  Future<void> annulla(int id) async {}

  @override
  Future<List<int>> inAttesa() async => const [];

  @override
  Future<void> mostraAdesso({
    required String titolo,
    required String testo,
  }) async {}
}
