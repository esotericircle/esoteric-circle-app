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
    this.indirizzoDiRipiego = manifestoV1SulBucket,
  })  : _client = client,
        _cartella = cartella ?? getApplicationSupportDirectory;

  /// L'unico, quello dell'app.
  static IVideoDelCamminoScaricati diCasa = IVideoDelCamminoScaricati();

  /// **IL MANIFESTO V2**, 20 ottobre 2026, scritto da
  /// `tool/gli_asset_del_viaggio_v2.py`: porta per ogni animale il pezzo
  /// `volta` (il gesto "si volta", taglio andata e ritorno), l'arrivo del
  /// Cervo dal fotogramma 3 e le uscite che si fermano prima che l'animale
  /// diventi trasparente. Lo pubblica il fondatore.
  static const String manifestoSulBucket =
      'https://storage.googleapis.com/esoteric-circle-assets-cdn/'
      'viaggio_sciamano/manifesto_viaggio_v2.json';

  /// **IL RIPIEGO SULLA V1**, scritto da `tool/gli_asset_dell_ordine_fz.py`:
  /// finche' la v2 non e' sul bucket, il manifesto v2 risponde 404 e l'app
  /// scarica la v1 come prima, invece di restare senza video.
  static const String manifestoV1SulBucket =
      'https://storage.googleapis.com/esoteric-circle-assets-cdn/'
      'viaggio_sciamano/manifesto_viaggio_v1.json';

  /// **LA VERSIONE CHE L'APP VUOLE.** Un animale scaricato con un manifesto
  /// piu' vecchio resta buono senza rete, ma non e' [aggiornato]: alla
  /// prossima occasione con la rete si riscarica (e i file che non cambiano
  /// si riprendono dal telefono, non dalla rete).
  static const int versioneAttuale = 2;

  final http.Client? _client;
  final Future<Directory> Function() _cartella;
  final String indirizzoDelManifesto;

  /// Dove chiedere il manifesto quando [indirizzoDelManifesto] non risponde
  /// 200; nullo, nessun ripiego.
  final String? indirizzoDiRipiego;

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
          // Il segno scritto prima della v2 non porta la versione: e' la 1.
          versione: (dati['versione'] as int?) ?? 1,
        );
      } catch (errore) {
        debugPrint('Segno del video di $nome illeggibile: $errore');
      }
    }
  }

  /// Se [nome] si puo' far girare senza rete.
  bool installato(String nome) => _installati.containsKey(nome);

  /// **SE [nome] E' INSTALLATO CON LA VERSIONE CHE L'APP VUOLE.** Chi decide
  /// se scaricare guarda questo, non [installato]: un animale della v1 non ha
  /// il pezzo `volta`, e "si volta" resterebbe sulla posa per sempre.
  bool aggiornato(String nome) =>
      installato(nome) &&
      (_installati[nome]?.versione ?? versioneAttuale) >= versioneAttuale;

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
  /// Il manifesto porta il nome del file sorgente (`00_SCENA_ULTIMO.jpg` o
  /// `Uccelli/00_SCENA_UCCELLI_ULTIMO.jpg`); qui si legge solo se e'
  /// quello degli uccelli o quello di terra, perche' il pacchetto porta le
  /// due conversioni in WebP sotto nomi suoi (ordine FZ voce FZ.04, vedi
  /// tool/gli_asset_della_carta_fz04.py).
  String? percorsoDellaScenaVuota(String nome) {
    final scena = _installati[nome]?.scenaVuota;
    if (scena == null) return null;
    const cartella = 'assets/img/mondo_di_sotto/scene_vuote';
    return scena.contains('UCCELLI')
        ? '$cartella/00_scena_uccelli_ultimo.webp'
        : '$cartella/00_scena_ultimo.webp';
  }

  /// Il manifest dal bucket: la v2, e se non c'e' ancora la v1
  /// ([indirizzoDiRipiego]).
  Future<Map<String, dynamic>> manifesto() async {
    var r = await _chiedi(indirizzoDelManifesto);
    final ripiego = indirizzoDiRipiego;
    if (r.statusCode != 200 && ripiego != null) {
      r = await _chiedi(ripiego);
    }
    if (r.statusCode != 200) {
      throw HttpException('manifest: ${r.statusCode}');
    }
    return jsonDecode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>;
  }

  Future<http.Response> _chiedi(String indirizzo) {
    richiesteFatte++;
    return _rete.get(Uri.parse(indirizzo)).timeout(const Duration(seconds: 20));
  }

  /// La versione di un manifesto: la v1 non la scrive.
  static int versioneDi(Map<String, dynamic> manifesto) =>
      (manifesto['versione'] as int?) ?? 1;

  /// **SCARICA I PEZZI E LA POSA DI [nome]** (tre con la v1, quattro con la
  /// v2 che aggiunge `volta`), con l'avanzamento in byte.
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
      final versione = versioneDi(m);
      final vecchio = _installati[nomeFile];
      // **NIENTE DA AGGIORNARE**: sul bucket c'e' ancora solo la versione
      // che il telefono ha gia' (la v2 non e' pubblicata). Senza questo, a
      // ogni apertura del segno si riscaricherebbero gli stessi file.
      if (vecchio != null && vecchio.versione >= versione) {
        return EsitoDelDownload.installato;
      }
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
        // **UN FILE CHE IL TELEFONO HA GIA' NON SI RISCARICA**: passando
        // dalla v1 alla v2 i file che non cambiano portano lo stesso nome e
        // la stessa impronta, e si prendono dalla cartella installata.
        if (vecchio != null) {
          final giaQui = File('${vecchio.cartella}/${f.file}');
          if (giaQui.existsSync()) {
            final byte = await giaQui.readAsBytes();
            if (sha256.convert(byte).toString() == f.sha256) {
              await File('${lavoro.path}/${f.file}')
                  .writeAsBytes(byte, flush: true);
              buono = true;
            }
          }
        }
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
            'versione': versione,
          }),
          flush: true);
      _installati[nomeFile] = _AnimaleInstallato(
        cartella: finale.path,
        file: file,
        fineUscita: voce['fine_uscita'] as String?,
        scenaVuota: voce['scena_vuota'] as String?,
        versione: versione,
      );
      return EsitoDelDownload.installato;
    } on _Annullato {
      _pulisci(lavoro);
      return EsitoDelDownload.annullato;
    } catch (e) {
      debugPrint('Il video di $nome non si è scaricato: $e');
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
    this.versione = 1,
  });
  final String cartella;
  final Map<String, String> file;
  final String? fineUscita;
  final String? scenaVuota;

  /// La versione del manifesto con cui si e' scaricato.
  final int versione;
}
