import 'dart:typed_data';

import '../maestro/maestro.dart';
import '../../features/maestri/aura/meditation/tone_generator.dart';

/// LA VOCE DEL RESPONSO, una per Maestro. Ordine BX voce 05.
///
/// **Il fatto del fondatore**: "gli effetti sonori ci sono solo su alcune
/// funzioni e mancano sugli altri responsi". Verificato prima di scrivere una
/// riga: degli otto responsi dell'app **uno solo suonava**, l'Oroscopo, che
/// chiamava la rivelazione del catalogo. Gli altri sette avevano la
/// vibrazione e basta.
///
/// **UNA LEGGE DEL PROGETTO E' CAMBIATA, E SI DICHIARA.** Il catalogo dei
/// suoni portava scritto "i tre Maestri NON hanno tre suoni diversi, sarebbe
/// rumore e non identita'", e una guardia lo sorvegliava. L'ordine BX voce 05
/// chiede l'opposto: "ogni responso dell'app ha il suo effetto sonoro,
/// **coerente con il Maestro a cui appartiene**". Comanda l'ordine, del 27
/// agosto 2026, e la vecchia regola resta vera dove e' nata: **la firma
/// dell'apertura resta una sola per tutti**, perche' quella e' la voce
/// dell'app e non di chi parla. Cambia il responso, che e' il momento in cui
/// un Maestro preciso ti sta rispondendo.
///
/// **PERCHE' E' UN SUONO SINTETIZZATO E NON TRE FILE.** Tre file non esistono
/// e non li posso disegnare io: metterli nel catalogo vorrebbe dire tre nomi
/// che puntano al nulla, e il motore ha il ripiego silenzioso, quindi il
/// fondatore avrebbe letto "fatto" e sentito silenzio. **Il tono si genera
/// coi byte**, come gia' fa la Meditazione, quindi si sente da subito e non
/// aspetta nessuna consegna di asset. Il giorno che i tre suoni veri
/// arrivano, questa classe diventa il loro ripiego.
///
/// **Le tre voci, e perche' sono queste.** Una nota tenuta e la sua quinta,
/// che e' l'intervallo piu' consonante dopo l'ottava e non ha colore
/// allegro ne' triste: nessuna delle tre voci giudica il responso che
/// accompagna. Cambia il registro, ed e' li' che sta il Maestro: Medora in
/// alto, il cielo; Aura al mezzo, il corpo e il respiro; Caligo in basso, la
/// pietra e la terra.
class VoceDelResponso {
  const VoceDelResponso._();

  /// Quanto dura una voce. Meno di un secondo, come tutti i suoni del
  /// Cerchio: il silenzio e' cio' che rende un suono importante.
  static const Duration durata = Duration(milliseconds: 900);

  /// La nota fondamentale di ogni Maestro, in hertz.
  static double fondamentaleDi(Maestro maestro) => switch (maestro) {
        Maestro.medora => 528.0,
        Maestro.aura => 432.0,
        Maestro.caligo => 324.0,
      };

  /// La quinta della fondamentale: tre mezzi sopra due, il rapporto che
  /// l'orecchio riconosce come quiete.
  static double quintaDi(Maestro maestro) => fondamentaleDi(maestro) * 1.5;

  static const ToneGenerator _generatore = ToneGenerator();

  /// I byte WAV della voce di quel Maestro, pronti per il motore audio.
  ///
  /// **L'ampiezza e' bassa di proposito**: un responso e' una frase detta a
  /// voce bassa, non un annuncio. Il generatore mette gia' la dissolvenza ai
  /// due capi, quindi non ci sono clic all'attacco.
  static Uint8List byteDi(Maestro maestro) => _generatore.wav(
        leftHz: fondamentaleDi(maestro),
        rightHz: quintaDi(maestro),
        duration: durata,
        amplitude: 0.22,
      );

  /// A quale Maestro appartiene ognuno degli otto responsi dell'app.
  ///
  /// **E' un DATO e non una convenzione scritta nei commenti**, come il
  /// catalogo dei suoni: una prova enumera gli otto responsi e cade se uno di
  /// loro non chiede la voce del proprio Maestro.
  /// **Le chiavi sono i GESTI, coi nomi che il corpus gia' usa**, non nomi
  /// nuovi inventati qui: e' cosi' che ogni responso trova la propria voce
  /// passando dalla regia del cammino, senza otto chiamate sparse.
  ///
  /// **E l'appartenenza non e' una mia opinione**: `sentieroDelGesto`, che
  /// il generatore del corpus scrive, dice gia' di chi e' ogni gesto, e una
  /// prova confronta le due mappe voce per voce.
  static const Map<String, Maestro> deiResponsi = {
    'oroscopo': Maestro.medora,
    'sinastria': Maestro.medora,
    'angelo_custode': Maestro.medora,
    'archetipo': Maestro.aura,
    'alba': Maestro.aura,
    'gettata': Maestro.caligo,
    'animale_guida': Maestro.caligo,
    'sogno': Maestro.caligo,
  };
}
