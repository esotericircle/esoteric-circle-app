import 'dart:async';
import 'dart:io';

import 'package:ffmpeg_kit_flutter_new_min_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new_min_gpl/return_code.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/condivisione/il_filtro_del_titolo_in_video.dart';
import '../../../../core/condivisione/porta_della_condivisione.dart';
import '../../../../core/rituals/animal_catalog.dart';
import 'card_della_rivelazione.dart';

/// **LA RIVELAZIONE SI CONDIVIDE ANCHE COME VIDEO.** Ordine FZ voce FZ.08,
/// 17 ottobre 2026. *"Il centro del video dell'animale (il verso), con
/// sopra il titolo di oggi ('mi ha trovato' e il nome dell'animale su due
/// righe) e la data, social-story-ready."*
///
/// **FFMPEG, non un'altra via.** Scrivere testo dentro un video ed
/// esportarlo di nuovo non si fa con le porte di Flutter: serve un
/// codificatore vero. Il fondatore ha scelto di aggiungerlo sapendo il
/// costo, vedi il rapporto dell'ordine.
///
/// Chi esegue il comando e' iniettabile: le prove non possono far girare
/// FFmpeg vero (e' codice nativo), e passano una finta che dice se il
/// comando le e' arrivato con la forma giusta.
typedef EsecutoreFFmpeg = Future<bool> Function(String comando);

Future<bool> _esecutoreVero(String comando) async {
  final sessione = await FFmpegKit.execute(comando);
  final codice = await sessione.getReturnCode();
  return ReturnCode.isSuccess(codice);
}

/// **IL FONT, ESTRATTO UNA VOLTA SOLA.** FFmpeg legge un file del disco, non
/// un asset del pacchetto: si copia la prima volta che serve, poi resta.
Future<String> _fontDelTitolo(Directory dir) async {
  final file = File('${dir.path}/cinzel_per_ffmpeg.ttf');
  if (!await file.exists()) {
    final dati = await rootBundle.load('assets/fonts/Cinzel-variable.ttf');
    await file.writeAsBytes(dati.buffer.asUint8List(), flush: true);
  }
  return file.path;
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
  Future<Directory> Function() cartella = getTemporaryDirectory,
}) async {
  try {
    final dir = await cartella();
    final font = await _fontDelTitolo(dir);
    final filtro = IlFiltroDelTitoloInVideo.costruisci(
      percorsoDelFont: font,
      rigaUno: CardDellaRivelazione.primaRiga,
      rigaDue: CardDellaRivelazione.ilNome(animale),
      data: 'mi ha trovato ${CardDellaRivelazione.ilGiorno(quando)}',
    );
    final uscita = File('${dir.path}/rivelazione_${animale.name}.mp4');
    if (await uscita.exists()) await uscita.delete();
    // **AUDIO COPIATO, VIDEO RICODIFICATO**: il filtro tocca solo i
    // fotogrammi, l'audio di Flow (passi, bosco, verso) resta uguale.
    final comando = '-y -i "$percorsoDelCentro" -vf "$filtro" '
        '-c:v libx264 -preset fast -crf 23 -c:a copy "${uscita.path}"';
    final riuscito = await esecutore(comando);
    if (!riuscito || !await uscita.exists()) return false;
    return PortaDellaCondivisione.daFile(uscita.path,
        testo: 'Mi ha trovato ${animale.articolo}${animale.name}.');
  } catch (errore) {
    return false;
  }
}
