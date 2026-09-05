import 'package:flutter/foundation.dart';

import '../../core/maestro/maestro.dart';
import '../../core/sensi/catalogo_musiche.dart';

/// QUALE MUSICA SUONA DOVE, dichiarato in un posto solo.
/// Ordine CN voce 03, 1 settembre 2026.
///
/// **La decisione non vive dentro le schermate.** E' la stessa ragione scritta
/// per la barra: se ogni schermata scegliesse la propria traccia, la regola
/// avrebbe tante porte quante sono le schermate, e nessuno saprebbe piu' dove
/// si decide un passaggio. Qui c'e' l'elenco, e sopra il Navigator c'e' il solo
/// punto che lo legge.
///
/// **Tre risposte, non due.** Una schermata puo' volere una traccia, puo'
/// volere il SILENZIO, oppure puo' non avere nulla da dire e lasciare che
/// continui quel che gia' suona. La terza risposta e' la piu' importante:
/// **i Doni del Giorno non hanno una traccia loro e non ne vogliono una**, e
/// spegnere quella che c'e' farebbe del Dono un buco di silenzio.
enum CosaSuonaQui {
  /// La schermata vuole una traccia sua.
  unaTraccia,

  /// La schermata vuole silenzio, e non e' la stessa cosa di "non mi importa".
  silenzio,

  /// La schermata non decide: continua cio' che gia' suona.
  cioCheGiaSuona,
}

/// Cosa deve suonare su una schermata, e quale traccia se ne vuole una.
typedef VoceDellaMusica = ({CosaSuonaQui cosa, MusicaDelCerchio? traccia});

/// **LE SCHERMATE CHE HANNO QUALCOSA DA DIRE SULLA MUSICA.**
///
/// Per nome di classe, come per la barra: cosi' una schermata nuova non eredita
/// un comportamento per caso.
const Map<String, VoceDellaMusica> musicaPerSchermata = {
  // --- IL LUOGO DI CASA ---------------------------------------------------
  //
  // Lo Shaman parte con la PRIMA schermata del Risveglio e non si interrompe
  // fino alla home compresa: sono due schermate diverse, stessa traccia,
  // quindi il passaggio non produce nessuna dissolvenza. Dalle sessioni dopo
  // e' semplicemente la traccia della home.
  'OnboardingScreen': (
    cosa: CosaSuonaQui.unaTraccia,
    traccia: MusicaDelCerchio.home
  ),
  'SantuarioScreen': (
    cosa: CosaSuonaQui.unaTraccia,
    traccia: MusicaDelCerchio.home
  ),
  'CosmicPassport': (
    cosa: CosaSuonaQui.unaTraccia,
    traccia: MusicaDelCerchio.home
  ),

  // --- LA MEDITAZIONE, E QUI IL SILENZIO E' UNA REGOLA -------------------
  //
  // **Volume della musica a ZERO nella Meditazione**, prescrizione del 31
  // agosto 2026, confermata dal fondatore il 1 settembre. Protegge il battito
  // binaurale a 7 Hz che il telefono genera: un tappeto sopra un battito di
  // sette cicli al secondo copre proprio la cosa che si e' andati ad
  // ascoltare. **Il bambu' di Aura suona nel suo dominio, non qui.**
  'MeditationScreen': (cosa: CosaSuonaQui.silenzio, traccia: null),

  // --- E L'INTRO NON STA QUI, PERCHE' NON E' UNA ROTTA ---------------------
  //
  // **Qui c'era una riga per `SequenzaIntro`, e non ha mai potuto valere
  // niente.** Ordine CN voce 03, corretto dall'ordine CO voce 01 il 3
  // settembre 2026. Questa mappa si legge col nome della schermata IN CIMA
  // ALLA PILA del Navigator, e l'intro non e' una schermata della pila: e'
  // un velo che AVVOLGE il Navigator intero, montato in `app.dart` sopra di
  // esso. Il nome `SequenzaIntro` non arriva mai a questa mappa, quindi la
  // riga era verde, leggibile, sensata e **morta**: mentre l'intro suonava,
  // il custode leggeva `OnboardingScreen` di sotto e faceva partire lo
  // Shaman all'istante. E' il difetto che il fondatore ha sentito sul
  // telefono, due voci sopra la stessa apertura.
  //
  // Cio' che avvolge non si dichiara per nome di rotta: si dichiara alzando
  // il velo qui sotto.
};

/// **IL VELO CHE ZITTISCE, ed e' il modo giusto di dirlo per cio' che non e'
/// una rotta.**
///
/// Ordine CO voce 01, 3 settembre 2026. L'intro sta SOPRA il Navigator, e
/// finche' si vede nessuna schermata di sotto ha voce in capitolo sulla
/// musica: quella nera con la voce del principio e' l'unica cosa che si sta
/// guardando. La voce del principio ha la schermata tutta per se', perche'
/// due suoni che si contendono la stessa apertura non fanno un'apertura piu'
/// ricca.
///
/// **Perche' un notificatore e non un semplice booleano.** Quando il velo
/// cade, nessuna rotta viene spinta: la pila non cambia, il custode non
/// verrebbe svegliato da niente e la musica resterebbe zitta fino al primo
/// tocco. La caduta del velo **e' essa stessa un cambiamento**, e va detta.
final ValueNotifier<bool> veloCheZittisce = ValueNotifier<bool>(false);

/// **Cosa deve suonare, date la schermata in cima e il Maestro che dichiara.**
///
/// L'ordine dei controlli conta: prima cio' che la schermata dice di se',
/// perche' la Meditazione sta nel dominio di Aura e senza questa precedenza si
/// prenderebbe il bambu' che deve invece tacere.
VoceDellaMusica cosaSuonaSu(String? schermata, Maestro? maestro) {
  // **IL VELO VINCE SU TUTTO, e viene per primo.** Cio' che copre lo schermo
  // intero conta piu' di qualunque cosa dichiari la schermata di sotto:
  // mentre l'intro si vede, la home sotto di essa non e' la cosa che si sta
  // guardando, e la sua traccia non e' la cosa che si deve ascoltare.
  if (veloCheZittisce.value) {
    return (cosa: CosaSuonaQui.silenzio, traccia: null);
  }

  final dichiarata = musicaPerSchermata[schermata];
  if (dichiarata != null) return dichiarata;

  if (maestro != null) {
    return (
      cosa: CosaSuonaQui.unaTraccia,
      traccia: switch (maestro) {
        Maestro.medora => MusicaDelCerchio.medora,
        Maestro.aura => MusicaDelCerchio.aura,
        Maestro.caligo => MusicaDelCerchio.caligo,
      }
    );
  }

  // Tutto il resto, e sono i Doni del Giorno, le arti, le letture: continua
  // cio' che gia' suona.
  return (cosa: CosaSuonaQui.cioCheGiaSuona, traccia: null);
}
