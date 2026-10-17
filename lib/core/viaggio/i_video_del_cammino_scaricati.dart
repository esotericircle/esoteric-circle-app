import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'la_sequenza_del_cammino.dart';

/// **I VIDEO DEL CAMMINO, SCARICATI A RICHIESTA.** Ordine FZ voce FZ.06, 17
/// ottobre 2026: *"I video non entrano nel pacchetto dell'app: si scaricano
/// [...] solo quando servono, cioè il video dell'animale della persona e
/// quelli delle carte che sta scoprendo; poi restano in cache."*
///
/// Stessa forma di `IMazziScaricati` (ordine FJ voce 12), per la stessa
/// ragione: un manifest sul bucket, mai indovinato, con l'impronta SHA-256
/// di ogni file; un download per volta in una cartella di lavoro, rinominata
/// solo quando tutto torna; un segno `installato.json` perche' il prossimo
/// avvio legga senza rete. **La granularita' e' l'animale, non il pezzo
/// solo**: i tre pezzi e la posa di un animale si scaricano insieme, perche'
/// l'ordine parla di "il video dell'animale", non di un suo terzo.
class IVideoDelCamminoScaricati {
  IVideoDelCamminoScaricati({
    http.Client? client,
    Future<Directory> Function()? cartella,
    this.indirizzoDelManifesto = manifestoSulBucket,
  })  : _client = client,
        _cartella = cartella ?? getApplicationSupportDirectory;

  /// L'unico, quello dell'app.
  static IVideoDelCamminoScaricati diCasa = IVideoDelCamminoScaricati();

  /// Dove sta il manifest dei video, scritto da
  /// `tool/gli_asset_dell_ordine_fz.py` e pubblicato sul bucket.
  static const String manifestoSulBucket =
      'https://storage.googleapis.com/esoteric-circle-assets-cdn/'
      'viaggio_sciamano/manifesto_viaggio_v1.json';

  final http.Client? _client;
  final Future<Directory> Function() _cartella;
  final String indirizzoDelManifesto;

  /// Quante richieste di rete ha fatto: le prove pretendono zero all'avvio.
  @visibleForTesting
  int richiesteFatte = 0;

  final Map<String, _AnimaleInstallato> _installati = {};
  bool _letti = false;

  late final http.Client _rete = _client ?? http.Client();

  Future<Directory> _radice() async =>
      Directory('${(await _cartella()).path}/viaggio_sciamano');

  /// **LEGGE DAL TELEFONO GLI ANIMALI GIA' SCARICATI**, senza rete.
  Future<void> leggiIInstallati() async {
    if (_letti) return;
    _letti = true;
    final radice = await _radice();
    if (!radice.existsSync()) return;
    for (final cartella in radice.listSync().whereType<Directory>()) {
      final nome = cartella.path.split(Platform.pathSeparator).last;
      try {
        final segno = File('${cartella.path}/installato.json');
        if (!segno.existsSync()) continue;
        final dati = jsonDecode(await segno.readAsString()) as Map;
        _installati[nome] = _AnimaleInstallato(
          cartella: cartella.path,
          file: (dati['file'] as Map).cast<String, String>(),
          fineUscita: dati['fineUscita'] as String?,
          scenaVuota: dati['scenaVuota'] as String?,
        );
      } catch (errore) {
        debugPrint('Segno del video di $nome illeggibile: $errore');
      }
    }
  }

  /// Se [nome] si puo' far girare senza rete.
  bool installato(String nome) => _installati.containsKey(nome);

  /// Il percorso scaricato del pezzo [pezzo] di [nome], o nullo se
  /// l'animale non e' installato: chi chiama ripiega sulla posa, mai su un
  /// riquadro vuoto.
  String? percorsoDiPezzo(String nome, PezzoDelCammino pezzo) {
    final a = _installati[nome];
    if (a == null) return null;
    final f = a.file[pezzo.name];
    return f == null ? null : '${a.cartella}/$f';
  }

  /// Il percorso scaricato della posa di [nome], o nullo.
  String? percorsoDellaPosa(String nome) {
    final a = _installati[nome];
    if (a == null) return null;
    final f = a.file['posa'];
    return f == null ? null : '${a.cartella}/$f';
  }

  /// Vero per Tartaruga, Gufo, Falco, Aquila, Corvo: l'uscita dissolve nella
  /// scena vuota invece di restare in posa (ordine FZ voce FZ.05).
  bool haFineUscita(String nome) => _installati[nome]?.fineUscita != null;

  /// Il percorso della scena vuota per [nome] (terra o uccelli), gia' nel
  /// pacchetto: non e' un pezzo scaricato, l'ordine dice che resta dove sta.
  String? percorsoDellaScenaVuota(String nome) {
    final scena = _installati[nome]?.scenaVuota;
    return scena == null
        ? null
        : 'assets/img/viaggio_sciamano/scene_vuote/$scena';
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

  /// **SCARICA I TRE PEZZI E LA POSA DI [nome]**, con l'avanzamento in byte.
  /// Non lancia: dice com'e' andata.
  Future<EsitoDelDownload> scaricaAnimale(
    String nome, {
    void Function(int fatti, int totali)? avanzamento,
    AnnullaDownload? annulla,
  }) async {
    final nomeFile = nome.toLowerCase();
    final radice = await _radice();
    final lavoro = Directory('${radice.path}/$nomeFile.scaricando');
    try {
      final m = await manifesto();
      final voce = (m['animali'] as Map)[nomeFile] as Map?;
      if (voce == null) {
        throw StateError('il manifest non porta $nomeFile');
      }
      final pezzi = (voce['pezzi'] as Map).cast<String, dynamic>();
      final posa = voce['posa'] as Map;
      final elenco = <_DaScaricare>[
        for (final entry in pezzi.entries)
          _DaScaricare(
            chiave: entry.key,
            file: (entry.value as Map)['file'] as String,
            byte: (entry.value as Map)['byte'] as int,
            sha256: (entry.value as Map)['sha256'] as String,
          ),
        _DaScaricare(
          chiave: 'posa',
          file: posa['file'] as String,
          byte: posa['byte'] as int,
          sha256: posa['sha256'] as String,
        ),
      ];
      final totali = elenco.fold(0, (a, f) => a + f.byte);
      if (lavoro.existsSync()) lavoro.deleteSync(recursive: true);
      lavoro.createSync(recursive: true);
      var fatti = 0;
      avanzamento?.call(0, totali);
      for (final f in elenco) {
        var buono = false;
        for (var tentativo = 0; tentativo < 2 && !buono; tentativo++) {
          if (annulla?.annullato ?? false) throw const _Annullato();
          richiesteFatte++;
          final r = await _rete
              .get(Uri.parse('${_baseDelBucket(indirizzoDelManifesto)}'
                  'viaggio_sciamano/${f.file}'))
              .timeout(const Duration(seconds: 60));
          if (r.statusCode == 200 &&
              sha256.convert(r.bodyBytes).toString() == f.sha256) {
            await File('${lavoro.path}/${f.file}')
                .writeAsBytes(r.bodyBytes, flush: true);
            buono = true;
          }
        }
        if (!buono) throw StateError('${f.file}: l\'impronta non torna');
        fatti += f.byte;
        avanzamento?.call(fatti, totali);
      }
      if (annulla?.annullato ?? false) throw const _Annullato();
      final finale = Directory('${radice.path}/$nomeFile');
      if (finale.existsSync()) finale.deleteSync(recursive: true);
      lavoro.renameSync(finale.path);
      final file = {for (final f in elenco) f.chiave: f.file};
      await File('${finale.path}/installato.json').writeAsString(
          jsonEncode({
            'file': file,
            'fineUscita': voce['fine_uscita'],
            'scenaVuota': voce['scena_vuota'],
          }),
          flush: true);
      _installati[nomeFile] = _AnimaleInstallato(
        cartella: finale.path,
        file: file,
        fineUscita: voce['fine_uscita'] as String?,
        scenaVuota: voce['scena_vuota'] as String?,
      );
      return EsitoDelDownload.installato;
    } on _Annullato {
      _pulisci(lavoro);
      return EsitoDelDownload.annullato;
    } catch (e) {
      debugPrint('Il video di $nome non si e\' scaricato: $e');
      _pulisci(lavoro);
      return EsitoDelDownload.nonRiuscito;
    }
  }

  /// La base del bucket, cioe' il manifest senza il suo percorso: lo stesso
  /// bucket serve il manifest e i file.
  static String _baseDelBucket(String manifesto) =>
      manifesto.substring(0, manifesto.indexOf('viaggio_sciamano/'));

  void _pulisci(Directory d) {
    try {
      if (d.existsSync()) d.deleteSync(recursive: true);
    } catch (errore) {
      debugPrint('Cartella di lavoro dei video non tolta: $errore');
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
    required this.file,
    required this.byte,
    required this.sha256,
  });
  final String chiave;
  final String file;
  final int byte;
  final String sha256;
}

class _AnimaleInstallato {
  const _AnimaleInstallato({
    required this.cartella,
    required this.file,
    this.fineUscita,
    this.scenaVuota,
  });
  final String cartella;
  final Map<String, String> file;
  final String? fineUscita;
  final String? scenaVuota;
}
