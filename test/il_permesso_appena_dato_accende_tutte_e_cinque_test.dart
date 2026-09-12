import 'package:esoteric_circle/core/rituals/avvisi_del_rito.dart';
import 'package:esoteric_circle/core/rituals/daily_elements.dart';
import 'package:esoteric_circle/features/rituals/dawn_rite_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// IL PERMESSO APPENA DATO ACCENDE TUTTE E CINQUE. Ordine CW, voce 06, coda.
///
/// **Da dove viene questa guardia: dal telefono, non dal banco.**
///
/// La voce 06 era chiusa sul manifest, e il manifest era una causa vera. Poi
/// la verifica sul dispositivo 767f596c ha misurato la coda del sistema con
/// `dumpsys alarm`, e ha trovato **una sveglia sola** invece di cinque, dopo
/// aver concesso il permesso dentro il Rito dell'Alba. Al riavvio dell'app le
/// cinque comparivano tutte, alle ore giuste: 22:30, 7:00, 10:30, 13:00,
/// 18:30.
///
/// **La causa, in una riga.** All'avvio, `RegiaDelleChiamate.riprogramma`
/// guarda il permesso, non lo trova, e torna con la lista vuota. Poi il rito
/// chiede il permesso, lo ottiene, e programma **solo l'Alba**, perche' il suo
/// `_programmaAvviso` chiama `programmaProssimo`, che di Doni ne conosce uno.
/// Le altre quattro chiamate restano fuori dalla coda **fino all'apertura
/// successiva dell'app**.
///
/// Chi installa e prova subito riceve una notifica su cinque quel giorno. E'
/// la stessa specie del difetto principale della voce, cioe' una coda che si
/// svuota e nessuno la rimette: qui pero' non si svuota, non si e' mai
/// riempita.
///
/// **Cosa misura questa prova.** Quanti Doni distinti arrivano al servizio
/// degli avvisi nella sessione in cui il permesso viene concesso. Non guarda
/// quale metodo viene chiamato ne' da dove: guarda il fatto, cioe' la coda.
void main() {
  testWidgets('Chi concede il permesso nel rito riceve tutte e cinque',
      (tester) async {
    SharedPreferences.setMockInitialValues(const {});
    final finto = _AvvisiCheContano();

    // **LA FINESTRA SI FISSA.** Il difetto 800x600 fa morire i tocchi nelle
    // scene che occupano tutto lo schermo, e questa prova tocca un pulsante.
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(
      home: DawnRiteScreen(now: DateTime(2026, 9, 7, 9, 15), avvisi: finto),
    ));
    // **NIENTE `pumpAndSettle` QUI.** La scena dell'alba respira di continuo:
    // aspettare la quiete vuol dire aspettare per sempre, e la prova cadrebbe
    // per un motivo che non c'entra con cio' che misura.
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // Il preludio si apre da solo alla prima apertura del rito. Il suo
    // pulsante d'accordo porta il testo del rito, non quello generico.
    final accetta = find.text('Avvisami all\'alba');
    expect(accetta, findsOneWidget,
        reason: 'la spiegazione del permesso non si e\' aperta: senza di lei '
            'questa prova non misura niente');
    await tester.tap(accetta);
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(finto.concesso, isTrue,
        reason: 'il permesso non risulta concesso: la prova sta misurando un '
            'rifiuto, non una concessione');

    // **IL CARDINALE MINIMO E' CINQUE, e si dichiara.** I Doni sono cinque e
    // di partenza chiamano tutti: chi arriva qui con meno ha una coda
    // incompleta, e la persona quel giorno resta senza.
    expect(finto.doni.length, DailyElement.values.length,
        reason: 'nella sessione in cui il permesso viene concesso arrivano '
            '${finto.doni.length} chiamate su ${DailyElement.values.length}. '
            'Le altre aspettano la prossima apertura dell\'app, e quel giorno '
            'non suonano: ${finto.doni.map((d) => d.shortLabel).toList()}');
  });
}

/// Un servizio che concede il permesso quando glielo si chiede, e che tiene il
/// conto dei Doni che gli sono stati affidati.
class _AvvisiCheContano extends ServizioAvvisi {
  bool concesso = false;

  /// I Doni arrivati, riconosciuti dal loro id: e' l'unico dato che il
  /// servizio riceve e che dice DI CHI e' la chiamata.
  final Set<DailyElement> doni = {};

  @override
  bool get disponibile => true;

  @override
  Future<bool> chiediPermesso() async {
    concesso = true;
    return true;
  }

  @override
  Future<bool> permessoConcesso() async => concesso;

  @override
  Future<void> programma({
    required int id,
    required DateTime quando,
    required String titolo,
    required String testo,
    String canale = 'rito_alba',
    String carico = '',
  }) async {
    for (final d in DailyElement.values) {
      if (AvvisiDelRito.idDelDono(d) == id) doni.add(d);
    }
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
