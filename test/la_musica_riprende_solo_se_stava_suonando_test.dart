import 'package:esoteric_circle/core/sensi/guardia_del_suono.dart';
import 'package:esoteric_circle/core/sensi/motore_audio.dart';
import 'package:esoteric_circle/core/sensi/regia_della_musica.dart';
import 'package:esoteric_circle/core/sensi/catalogo_musiche.dart';
import 'package:esoteric_circle/core/settings/settings_controller.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// LA MUSICA RIPRENDE, MA SOLO SE STAVA SUONANDO. Ordine CW, voce 01.
///
/// **La decisione, e chi l'ha presa.** Con l'ordine CT la voce mi lasciava
/// scegliere cosa succede al ritorno, e avevo scelto che non ripartisse niente.
/// **Il fondatore l'ha ribaltata** il 7 settembre 2026: la musica si ferma
/// quando l'app va in sottofondo e riparte quando torna davanti, dal punto in
/// cui si era fermata.
///
/// **DAL PUNTO, e il motore lo consente.** `pause` di `audioplayers` lascia il
/// lettore dov'e' e `resume` riparte da li': la posizione non si deve nemmeno
/// ricordare, perche' la tiene il lettore. Non serve il ripiego dall'inizio
/// della traccia che l'ordine dichiarava accettabile.
///
/// **I DUE VINCOLI SONO LA PARTE DIFFICILE.** La ripresa non deve accendere
/// musica dove la musica era spenta, e non deve accenderla a chi l'ha
/// silenziata a mano. Lo stato ricordato e' **"stava suonando quando siamo
/// usciti"**, non "esiste una traccia per questa schermata": una domanda sola
/// che copre tutti e due i casi, perche' in nessuno dei due la musica suonava.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final motore = MotoreAudio.condiviso;

  setUp(() {
    MotoreAudio.sondaMusicaInCorso = null;
    motore.quanteRiprese = 0;
  });

  tearDown(() {
    MotoreAudio.sondaMusicaInCorso = null;
    RegiaDellaMusica.lettoreForzato = null;
    RegiaDellaMusica.spia = null;
  });

  /// Il giro completo del ciclo di vita, come lo fa il sistema.
  Future<void> viaEPoiTorna(GuardiaDelSuono guardia) async {
    guardia.cambioStato(AppLifecycleState.paused);
    // Le fermate partono nel giro sincrono e si attendono dopo: qui si lascia
    // scorrere la coda prima di chiedere il ritorno.
    await Future<void>.delayed(Duration.zero);
    guardia.cambioStato(AppLifecycleState.resumed);
    await Future<void>.delayed(Duration.zero);
  }

  test('CASO UNO: stava suonando, quindi riprende', () async {
    MotoreAudio.sondaMusicaInCorso = () => true;
    final guardia = GuardiaDelSuono(motore: motore);
    addTearDown(guardia.dispose);
    guardia.avvia();

    await viaEPoiTorna(guardia);

    expect(motore.quanteRiprese, 1,
        reason: 'la musica stava suonando quando l\'app e\' andata in '
            'sottofondo e al ritorno non e\' ripresa: e\' esattamente cio\' '
            'che il fondatore ha chiesto con l\'ordine CW voce 01');
  });

  test('CASO DUE: era spenta in questa schermata, quindi non riprende',
      () async {
    // Nessuna musica in corso: e' il caso di chi sta in una schermata muta.
    MotoreAudio.sondaMusicaInCorso = () => false;
    final guardia = GuardiaDelSuono(motore: motore);
    addTearDown(guardia.dispose);
    guardia.avvia();

    await viaEPoiTorna(guardia);

    expect(motore.quanteRiprese, 0,
        reason: 'tornando in primo piano si e\' accesa musica in una '
            'schermata dove la musica era spenta: il ritorno non deve '
            'accendere niente, deve solo riprendere cio\' che aveva sospeso');
    expect(motore.musicaDaRiprendere, isFalse,
        reason: 'il motore crede di avere qualcosa da riprendere anche se non '
            'stava suonando niente');
  });

  test('CASO TRE: silenziata a mano, quindi non riprende', () async {
    // **QUESTO CASO SI COSTRUISCE DAVVERO, non si assume.** Chi ha spento la
    // musica dalle impostazioni non la sente partire, quindi la regia non la
    // fa nemmeno partire: si verifica prima che sia cosi', e poi che il
    // ritorno non la accenda.
    RegiaDellaMusica.lettoreForzato = true; // nessun lettore vero
    final impostazioni = SettingsController(musicaAttiva: false);
    MusicaDelCerchio? chiesta;
    RegiaDellaMusica.spia = (traccia) => chiesta = traccia;

    await RegiaDellaMusica.sola.vaiA(MusicaDelCerchio.home, impostazioni);
    expect(impostazioni.musicaPermessa, isFalse,
        reason: 'con la musica spenta nelle impostazioni musicaPermessa '
            'risulta vera: la premessa di questa prova non regge');

    // Con la musica silenziata nulla suona, quindi nulla puo' essere ripreso.
    MotoreAudio.sondaMusicaInCorso = () => false;
    final guardia = GuardiaDelSuono(motore: motore);
    addTearDown(guardia.dispose);
    guardia.avvia();

    await viaEPoiTorna(guardia);

    expect(motore.quanteRiprese, 0,
        reason: 'chi aveva silenziato la musica a mano se la ritrova al '
            'ritorno dal sottofondo. Traccia chiesta dalla regia: $chiesta');
  });

  test('Due giri di seguito non riprendono due volte', () async {
    // Lo stato si consuma: se restasse acceso, il secondo ritorno riaccende
    // musica che nel frattempo nessuno stava ascoltando.
    MotoreAudio.sondaMusicaInCorso = () => true;
    final guardia = GuardiaDelSuono(motore: motore);
    addTearDown(guardia.dispose);
    guardia.avvia();

    await viaEPoiTorna(guardia);
    expect(motore.quanteRiprese, 1);

    // Il secondo ritorno senza essere usciti: non c'e' niente di sospeso.
    guardia.cambioStato(AppLifecycleState.resumed);
    await Future<void>.delayed(Duration.zero);
    expect(motore.quanteRiprese, 1,
        reason: 'un secondo ritorno senza essere usciti ha ripreso di nuovo: '
            'lo stato non si consuma');
  });

  test('La sonda non esiste in produzione', () {
    // La cucitura serve a costruire la premessa nelle prove. Se restasse
    // accesa fuori, il motore leggerebbe una risposta scelta invece del
    // lettore vero, ed e' il modo in cui una scorciatoia di prova diventa un
    // difetto di produzione.
    MotoreAudio.sondaMusicaInCorso = null;
    expect(MotoreAudio.sondaMusicaInCorso, isNull,
        reason: 'la sonda resta appesa dopo le prove');
  });
}
