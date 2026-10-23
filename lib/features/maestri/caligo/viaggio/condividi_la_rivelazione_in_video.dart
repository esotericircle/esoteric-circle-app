import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:ffmpeg_kit_flutter_new_min_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new_min_gpl/return_code.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/condivisione/il_titolo_in_immagine.dart';
import '../../../../core/condivisione/porta_della_condivisione.dart';
import '../../../../core/rituals/animal_catalog.dart';
import 'card_della_rivelazione.dart';

/// **LA RIVELAZIONE SI CONDIVIDE ANCHE COME VIDEO.** Ordine FZ voce FZ.08,
/// 17 ottobre 2026. *"Il centro del video dell'animale (il verso), con
/// sopra il titolo di oggi ('mi ha trovato' e il nome dell'animale su due
/// righe) e la data, social-story-ready."*
///
/// **FFMPEG, non un'altra via.** Unire un titolo a un video ed esportarlo di
/// nuovo non si fa con le porte di Flutter: serve un codificatore vero. Il
/// fondatore ha scelto di aggiungerlo sapendo il costo, vedi il rapporto
/// dell'ordine.
///
/// **IL TITOLO E' UN'IMMAGINE, NON UN FILTRO DI TESTO**, dalla simulazione da
/// persona del 20 ottobre 2026: vedi `IlTitoloInImmagine`, dove sta il
/// perche' (il filtro `drawtext` non c'e' nella libreria Android in uso, e il
/// pulsante non faceva niente).
///
/// Chi esegue il comando e' iniettabile: le prove non possono far girare
/// FFmpeg vero (e' codice nativo), e passano una finta che dice se il
/// comando le e' arrivato con la forma giusta.
typedef EsecutoreFFmpeg = Future<bool> Function(String comando);

/// Chi disegna l'immagine del titolo: iniettabile per le prove.
typedef PittoreDelTitolo = Future<Uint8List> Function({
  required String rigaUno,
  required String rigaDue,
  required String data,
});

Future<bool> _esecutoreVero(String comando) async {
  final sessione = await FFmpegKit.execute(comando);
  final codice = await sessione.getReturnCode();
  return ReturnCode.isSuccess(codice);
}

/// **CONDIVIDE LA RIVELAZIONE COME VIDEO VERTICALE.**
///
/// [percorsoDelCentro] e' il pezzo "centro" del video dell'animale (il suo
/// verso), gia' scaricato (ordine FZ voce FZ.06): senza di lui questa
/// funzione non si chiama, la card immagine resta la via di sempre.
/// Non lancia: dice com'e' andata, come [condividiLaRivelazione].
///
/// [cartella] e' iniettabile: le prove non hanno un vero `path_provider`,
/// che e' un canale di piattaforma.
Future<bool> condividiLaRivelazioneInVideo({
  required GuideAnimal animale,
  required DateTime quando,
  required String percorsoDelCentro,
  EsecutoreFFmpeg esecutore = _esecutoreVero,
  PittoreDelTitolo titolo = IlTitoloInImmagine.png,
  Future<Directory> Function() cartella = getTemporaryDirectory,
  Future<bool> Function(String percorso, String testo)? condividi,
}) async {
  try {
    final dir = await cartella();
    final immagine = File('${dir.path}/rivelazione_titolo.png');
    await immagine.writeAsBytes(
        await titolo(
          rigaUno: CardDellaRivelazione.primaRiga,
          rigaDue: CardDellaRivelazione.ilNome(animale),
          // **SOLO LA DATA**: "mi ha trovato" sta gia' nella prima riga, e
          // ripeterlo sotto (com'era fino al 20 ottobre 2026) si leggeva come
          // un errore nel video vero.
          data: CardDellaRivelazione.laData(quando),
        ),
        flush: true);
    final uscita = File('${dir.path}/rivelazione_${animale.name}.mp4');
    if (await uscita.exists()) await uscita.delete();
    // **AUDIO COPIATO, VIDEO RICODIFICATO**: il titolo tocca solo i
    // fotogrammi, l'audio di Flow (passi, bosco, verso) resta uguale. Il
    // `yuv420p` e' il formato che ogni storia dei social legge.
    final comando = '-y -i "$percorsoDelCentro" -i "${immagine.path}" '
        '-filter_complex "${IlTitoloInImmagine.filtro}" '
        '-c:v libx264 -preset fast -crf 23 -pix_fmt yuv420p -c:a copy '
        '"${uscita.path}"';
    final riuscito = await esecutore(comando);
    if (!riuscito || !await uscita.exists() || await uscita.length() == 0) {
      return false;
    }
    final testo = 'Mi ha trovato ${animale.articolo}${animale.name}.';
    if (condividi != null) return condividi(uscita.path, testo);
    // **L'AIUTANTE RESTITUISCE L'ESITO VERO DELLA PORTA**, e il premio lo
    // paga il chiamante a condivisione avvenuta (`RegiaDelCammino`): la
    // guardia `ogni_condivisione_dichiara_gli_eos` riconosce gli aiutanti da
    // questa forma.
    return PortaDellaCondivisione.daFile(uscita.path, testo: testo);
  } catch (errore) {
    return false;
  }
}
