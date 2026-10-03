import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/sensi/catalogo_musiche.dart';
import 'package:esoteric_circle/core/sensi/regia_della_musica.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:esoteric_circle/core/onboarding/onboarding_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **LA MUSICA PARTE DAVVERO, NELL'APP VERA.** Ordine CN, 2 settembre 2026.
///
/// **Questa prova nasce da un difetto consegnato ai fondatori**, ed e' la
/// prova che ieri non ho scritto.
///
/// Ieri la musica aveva la sua guardia, `la_musica_segue_il_luogo_test.dart`,
/// e quella guardia era **verde e inutile**. Prova `cosaSuonaSu(...)`, che e'
/// una funzione pura: le si passano i nomi delle schermate a mano e si guarda
/// se risponde bene. **Rispondeva benissimo. Nell'app nessuno le passava quei
/// nomi.**
///
/// E' la **specie 3** del registro delle guardie, la scollegata: verifica un
/// componente vero e funzionante che nessuno alimenta. Nella build 2218 la
/// musica non e' partita **da nessuna parte**, ne' al Risveglio ne' dopo il
/// login ne' entrando in un dominio, e nessuna delle 4.200 prove se n'e'
/// accorta.
///
/// **Il difetto, per chi legge fra un anno.** Il nome della schermata in cima
/// non si legge da un'etichetta: si ricava camminando l'albero della rotta.
/// Il custode lo chiedeva **nell'istante del push**, quando quella rotta non
/// e' ancora stata costruita: albero vuoto, nome nullo, e la regia decideva
/// "nessuna schermata dichiara niente", cioe' continua quel che suona, cioe'
/// niente.
///
/// **La differenza fra le due guardie e' tutta qui**: quella di ieri chiedeva
/// a una funzione se sapeva rispondere; questa monta l'app e ascolta se
/// qualcuno le ha chiesto qualcosa.
void main() {
  late List<MusicaDelCerchio?> sentite;

  setUp(() {
    sentite = <MusicaDelCerchio?>[];
    RegiaDellaMusica.spia = sentite.add;
    RegiaDellaMusica.sola.dimentica();
  });

  tearDown(() => RegiaDellaMusica.spia = null);

  Future<void> avvia(WidgetTester tester,
      {required bool rispostoAlRisveglio}) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues(const {});
    if (rispostoAlRisveglio) {
      await tester.runAsync(() async {
        await OnboardingController().complete();
      });
    }
    await tester.pumpWidget(
      EsotericCircleApp(conIntro: false, services: AppServices.offline()),
    );
    // Piu' di un giro: il nome della schermata si legge DOPO che la rotta e'
    // stata costruita, ed e' esattamente il punto che questa prova
    // sorveglia. Un pump solo non basterebbe nemmeno col codice giusto.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('appena l\'app si apre, lo Shaman parte', (tester) async {
    await avvia(tester, rispostoAlRisveglio: true);

    expect(sentite, isNotEmpty,
        reason: 'NESSUNO HA CHIESTO ALLA REGIA DI SUONARE. **L\'app e\' muta '
            'e nessuno se ne accorge**: e\' esattamente cio\' che e\' stato '
            'consegnato ai fondatori nella build 2218.\n'
            'Il custode della musica sta sopra il Navigator e reagisce ai '
            'cambi della pila. Se qui non arriva niente, o non e\' montato, '
            'oppure chiede il nome della schermata prima che la rotta sia '
            'stata costruita, e allora quel nome e\' nullo e la regia decide '
            'sempre "continua quel che suona".');
    expect(sentite.last, MusicaDelCerchio.home,
        reason: 'la regia ha ricevuto ${sentite.last} invece dello Shaman: '
            'all\'apertura suona la traccia della home, e prosegue senza '
            'interrompersi dal Risveglio fino alla home compresa');
  });

  testWidgets(
      'al primo avvio, col Risveglio davanti, lo Shaman parte lo '
      'stesso', (tester) async {
    // **E' IL CASO CHE IL FONDATORE HA VISTO ROTTO**: app installata da zero,
    // intro finita, prima schermata del Risveglio, silenzio.
    await avvia(tester, rispostoAlRisveglio: false);

    expect(sentite, isNotEmpty,
        reason: 'al primo avvio nessuno chiede alla regia di suonare, e il '
            'Risveglio comincia in silenzio: e\' il sintomo esatto della '
            'build 2218');
    expect(sentite.last, MusicaDelCerchio.home,
        reason: 'sul Risveglio deve partire lo Shaman, e non interrompersi '
            'fino alla home');
  });
}
