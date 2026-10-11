import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'i_mazzi_dei_tarocchi.dart';
import 'tarot_card.dart';

/// **I MAZZI SCARICATI.** Ordine FJ voce 12, 11 ottobre 2026.
///
/// Il Rider-Waite sta nel binario. Marsiglia e Thoth stanno sul bucket
/// pubblico `esoteric-circle-assets-cdn` e si scaricano **solo** quando la
/// persona sceglie quel mazzo: mai all'avvio, mai da soli, mai tutti insieme.
///
/// L'app legge un **manifest** e non indovina i percorsi: per ogni mazzo la
/// versione, il piano che lo apre e, per ogni carta, il file pieno e la
/// miniatura con la loro misura in byte e l'impronta SHA-256. Un mazzo nuovo
/// si pubblica senza una release. L'indirizzo dei file e' la `base` del
/// manifest, cosi' il giorno che davanti al bucket c'e' Cloud CDN cambia il
/// manifest e non l'app.
///
/// Il download va in una cartella di lavoro; ogni file si controlla con la sua
/// impronta e, se non torna, si riscarica una volta sola. Solo quando tutti i
/// file tornano la cartella diventa il mazzo e si scrive `installato.json`.
/// La cartella sta nel supporto dell'applicazione, non nella cache: il
/// sistema non la svuota da solo, e il mazzo resta offline per sempre.
///
/// **Lettura pubblica e non URL firmati**, scelta dichiarata nel rapporto
/// FJ: i file sono l'arte dei mazzi, fatta per essere mostrata, e il bucket
/// e' gia' pubblico per le altre famiglie; gli URL firmati vorrebbero un
/// servizio su Cloud Run da pubblicare per ogni richiesta, senza proteggere
/// niente che non sia gia' a schermo. Nessuna credenziale nell'app.
class IMazziScaricati {
  IMazziScaricati({
    http.Client? client,
    Future<Directory> Function()? cartella,
    this.indirizzoDelManifesto = manifestoSulBucket,
  })  : _client = client,
        _cartella = cartella ?? getApplicationSupportDirectory;

  /// L'unico, quello dell'app.
  static IMazziScaricati diCasa = IMazziScaricati();

  /// Dove sta il manifest dei mazzi.
  static const String manifestoSulBucket =
      'https://storage.googleapis.com/esoteric-circle-assets-cdn/'
      'tarocchi/mazzi/manifest.json';

  final http.Client? _client;
  final Future<Directory> Function() _cartella;
  final String indirizzoDelManifesto;

  /// Quante richieste di rete ha fatto: la guardia pretende zero all'avvio.
  @visibleForTesting
  int richiesteFatte = 0;

  final Map<TarotDeckStyle, _MazzoInstallato> _installati = {};
  bool _letti = false;

  late final http.Client _rete = _client ?? http.Client();

  Future<Directory> _radice() async =>
      Directory('${(await _cartella()).path}/mazzi');

  /// **LEGGE DAL TELEFONO I MAZZI GIA' SCARICATI**, senza rete. Si chiama
  /// quando si apre la stesa; dopo, [arteDi] risponde subito.
  Future<void> leggiIInstallati() async {
    if (_letti) return;
    _letti = true;
    for (final d in TarotDeckStyle.values) {
      if (d.nelBinario) continue;
      try {
        final segno = File('${(await _radice()).path}/${d.sulBucket}/'
            'installato.json');
        if (!segno.existsSync()) continue;
        final dati = jsonDecode(await segno.readAsString()) as Map;
        _installati[d] = _MazzoInstallato(
          cartella: segno.parent.path,
          versione: dati['versione'] as int,
          file: (dati['file'] as Map).cast<String, String>(),
        );
      } catch (errore) {
        // Un segno illeggibile vale un mazzo non installato: alla scelta il
        // mazzo si riscarica, e non c'e' niente da dire a chi legge.
        debugPrint('Segno del mazzo ${d.label} illeggibile: $errore');
      }
    }
  }

  /// Se il mazzo [d] si puo' usare senza rete.
  bool installato(TarotDeckStyle d) =>
      d.nelBinario || _installati.containsKey(d);

  /// L'arte della carta [c] nel mazzo [d], dal telefono; null se il mazzo
  /// non e' scaricato (allora la carta si disegna col Rider-Waite).
  ImageProvider? arteDi(TarotDeckStyle d, TarotCard c,
      {bool miniatura = false}) {
    final m = _installati[d];
    if (m == null) return null;
    final percorso = m.file['${c.stem}|${miniatura ? 'miniatura' : 'piena'}'];
    if (percorso == null) return null;
    return FileImage(File('${m.cartella}/$percorso'));
  }

  /// Il manifest dal bucket.
  Future<Map<String, dynamic>> manifesto() async {
    richiesteFatte++;
    final r = await _rete
        .get(Uri.parse(indirizzoDelManifesto))
        .timeout(const Duration(seconds: 20));
    if (r.statusCode != 200) {
      throw HttpException('manifest: ${r.statusCode}');
    }
    return jsonDecode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>;
  }

  /// **SCARICA IL MAZZO [d]**, con l'avanzamento in byte e la possibilita'
  /// di annullare. Non lancia: dice com'e' andata.
  Future<EsitoDelDownload> scarica(
    TarotDeckStyle d, {
    void Function(int fatti, int totali)? avanzamento,
    AnnullaDownload? annulla,
  }) async {
    if (d.nelBinario) return EsitoDelDownload.installato;
    final radice = await _radice();
    final lavoro = Directory('${radice.path}/${d.sulBucket}.scaricando');
    try {
      final m = await manifesto();
      final voce = (m['mazzi'] as List).cast<Map>().firstWhere(
          (x) => x['id'] == d.sulBucket,
          orElse: () => throw StateError('il manifest non porta ${d.name}'));
      final base = m['base'] as String;
      final versione = voce['versione'] as int;
      final elenco = <_DaScaricare>[];
      for (final f in (voce['file'] as List).cast<Map>()) {
        for (final misura in const ['piena', 'miniatura']) {
          final x = f[misura] as Map?;
          if (x == null) continue;
          elenco.add(_DaScaricare(
            chiave: '${f['carta']}|$misura',
            percorso: x['percorso'] as String,
            byte: x['byte'] as int,
            sha256: x['sha256'] as String,
          ));
        }
      }
      final totali = elenco.fold(0, (a, f) => a + f.byte);
      if (lavoro.existsSync()) lavoro.deleteSync(recursive: true);
      lavoro.createSync(recursive: true);
      var fatti = 0;
      avanzamento?.call(0, totali);
      for (final f in elenco) {
        var buono = false;
        for (var tentativo = 0; tentativo < 2 && !buono; tentativo++) {
          if (annulla?.annullato ?? false) {
            throw const _Annullato();
          }
          richiesteFatte++;
          final r = await _rete
              .get(Uri.parse('$base${f.percorso}'))
              .timeout(const Duration(seconds: 60));
          if (r.statusCode == 200 &&
              sha256.convert(r.bodyBytes).toString() == f.sha256) {
            final dest = File('${lavoro.path}/${f.percorso}');
            dest.parent.createSync(recursive: true);
            await dest.writeAsBytes(r.bodyBytes, flush: true);
            buono = true;
          }
        }
        if (!buono) throw StateError('${f.percorso}: l\'impronta non torna');
        fatti += f.byte;
        avanzamento?.call(fatti, totali);
      }
      if (annulla?.annullato ?? false) throw const _Annullato();
      final finale = Directory('${radice.path}/${d.sulBucket}');
      if (finale.existsSync()) finale.deleteSync(recursive: true);
      lavoro.renameSync(finale.path);
      final file = {for (final f in elenco) f.chiave: f.percorso};
      // Il segno si scrive per ultimo: senza, il mazzo non e' installato.
      await File('${finale.path}/installato.json').writeAsString(
          jsonEncode({'versione': versione, 'file': file}),
          flush: true);
      _installati[d] = _MazzoInstallato(
          cartella: finale.path, versione: versione, file: file);
      return EsitoDelDownload.installato;
    } on _Annullato {
      _pulisci(lavoro);
      return EsitoDelDownload.annullato;
    } catch (e) {
      debugPrint('Il mazzo ${d.label} non si è scaricato: $e');
      _pulisci(lavoro);
      return EsitoDelDownload.nonRiuscito;
    }
  }

  void _pulisci(Directory d) {
    try {
      if (d.existsSync()) d.deleteSync(recursive: true);
    } catch (errore) {
      // Una cartella di lavoro che non si toglie non installa niente: il
      // segno non c'e', e il prossimo download la ricrea da capo.
      debugPrint('Cartella di lavoro dei mazzi non tolta: $errore');
    }
  }
}

/// Com'e' andato un download.
enum EsitoDelDownload { installato, annullato, nonRiuscito }

/// Il gesto che annulla un download in corso.
class AnnullaDownload {
  bool _annullato = false;
  bool get annullato => _annullato;
  void annulla() => _annullato = true;
}

class _Annullato implements Exception {
  const _Annullato();
}

class _DaScaricare {
  const _DaScaricare({
    required this.chiave,
    required this.percorso,
    required this.byte,
    required this.sha256,
  });
  final String chiave;
  final String percorso;
  final int byte;
  final String sha256;
}

class _MazzoInstallato {
  const _MazzoInstallato({
    required this.cartella,
    required this.versione,
    required this.file,
  });
  final String cartella;
  final int versione;
  final Map<String, String> file;
}
