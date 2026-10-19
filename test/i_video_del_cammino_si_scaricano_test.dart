// I VIDEO DEL CAMMINO SI SCARICANO A RICHIESTA. Ordine FZ voce FZ.06, 17
// ottobre 2026.
//
// Stessa forma della guardia dei mazzi (ordine FJ), con un bucket finto e
// una cartella vera:
// - il download riuscito diventa un animale installato che resta (un'altra
//   istanza lo ritrova dal telefono, senza rete);
// - un file con l'impronta sbagliata si riscarica una volta, e se torna
//   l'animale si installa;
// - un file che non torna nemmeno la seconda volta lascia l'animale non
//   installato e nessuna cartella a meta';
// - chi annulla non installa niente;
// - fineUscita e scenaVuota, letti dal manifest, si ritrovano dopo
//   l'installazione.

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:esoteric_circle/core/viaggio/i_video_del_cammino_scaricati.dart';
import 'package:esoteric_circle/core/viaggio/la_sequenza_del_cammino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _manifesto =
    'https://finto.bucket/viaggio_sciamano/manifesto_viaggio_v1.json';
const _base = 'https://finto.bucket/viaggio_sciamano/';

/// Il bucket finto: un manifest col solo Lupo, i suoi tre pezzi e la posa.
class _Bucket {
  _Bucket({this.guasti = const {}});

  final Map<String, int> guasti;
  final Map<String, int> chiamate = {};
  final Map<String, Uint8List> file = {
    for (final n in const [
      'lupo_arrivo_v1.mp4',
      'lupo_centro_v1.mp4',
      'lupo_uscita_v1.mp4',
      'lupo_posa_v1.webp',
    ])
      n: Uint8List.fromList(utf8.encode('byte di $n')),
  };

  Map<String, dynamic> get manifesto => {
        'animali': {
          'lupo': {
            'pezzi': {
              for (final p in const ['arrivo', 'centro', 'uscita'])
                p: {
                  'file': 'lupo_${p}_v1.mp4',
                  'byte': file['lupo_${p}_v1.mp4']!.length,
                  'sha256':
                      sha256.convert(file['lupo_${p}_v1.mp4']!).toString(),
                },
            },
            'posa': {
              'file': 'lupo_posa_v1.webp',
              'byte': file['lupo_posa_v1.webp']!.length,
              'sha256': sha256.convert(file['lupo_posa_v1.webp']!).toString(),
            },
            'fine_uscita': null,
            'scena_vuota': null,
          },
        },
      };

  MockClient get client => MockClient((r) async {
        final u = r.url.toString();
        if (u == _manifesto) {
          return http.Response(jsonEncode(manifesto), 200);
        }
        final percorso = u.substring(_base.length);
        final n = chiamate[percorso] = (chiamate[percorso] ?? 0) + 1;
        final b = file[percorso];
        if (b == null) return http.Response('no', 404);
        if (n <= (guasti[percorso] ?? 0)) {
          return http.Response.bytes(utf8.encode('guasto'), 200);
        }
        return http.Response.bytes(b, 200);
      });
}

void main() {
  late Directory cartella;
  setUp(() => cartella = Directory.systemTemp.createTempSync('video_viaggio_'));
  tearDown(() {
    if (cartella.existsSync()) cartella.deleteSync(recursive: true);
  });

  IVideoDelCamminoScaricati nuovo(http.Client client) =>
      IVideoDelCamminoScaricati(
          client: client,
          cartella: () async => cartella,
          indirizzoDelManifesto: _manifesto);

  test('UN DOWNLOAD RIUSCITO INSTALLA I TRE PEZZI E LA POSA, e resta',
      () async {
    final v = nuovo(_Bucket().client);
    final esito = await v.scaricaAnimale('Lupo');
    expect(esito, EsitoDelDownload.installato);
    expect(v.installato('lupo'), isTrue);
    for (final p in PezzoDelCammino.values) {
      final percorso = v.percorsoDiPezzo('lupo', p);
      expect(percorso, isNotNull, reason: '$p non si trova dopo il download');
      expect(File(percorso!).existsSync(), isTrue);
    }
    expect(v.percorsoDellaPosa('lupo'), isNotNull);

    // Un'altra istanza, senza rete: lo ritrova dal telefono.
    final v2 = IVideoDelCamminoScaricati(
        client:
            MockClient((_) async => http.Response('non doveva chiamare', 500)),
        cartella: () async => cartella);
    await v2.leggiIInstallati();
    expect(v2.installato('lupo'), isTrue);
    expect(v2.richiesteFatte, 0,
        reason: 'un animale gia\' installato non deve chiamare la rete');
  });

  test(
      'UN FILE CON L\'IMPRONTA SBAGLIATA SI RISCARICA UNA VOLTA, e se torna '
      'buono l\'animale si installa', () async {
    final v = nuovo(_Bucket(guasti: const {'lupo_centro_v1.mp4': 1}).client);
    final esito = await v.scaricaAnimale('Lupo');
    expect(esito, EsitoDelDownload.installato);
    expect(v.installato('lupo'), isTrue);
  });

  test(
      'UN FILE CHE NON TORNA NEMMENO LA SECONDA VOLTA NON INSTALLA NIENTE, e '
      'non resta nessuna cartella a meta\'', () async {
    final v = nuovo(_Bucket(guasti: const {'lupo_centro_v1.mp4': 2}).client);
    final esito = await v.scaricaAnimale('Lupo');
    expect(esito, EsitoDelDownload.nonRiuscito);
    expect(v.installato('lupo'), isFalse);
    // Niente scansione: i due soli percorsi che un download di 'lupo' puo'
    // lasciare, la cartella di lavoro e quella finale, non esistono.
    final radice = '${cartella.path}/viaggio_sciamano';
    expect(Directory('$radice/lupo.scaricando').existsSync(), isFalse,
        reason: 'un download fallito ha lasciato la cartella di lavoro');
    expect(Directory('$radice/lupo').existsSync(), isFalse,
        reason: 'un download fallito ha lasciato la cartella finale');
  });

  test('CHI ANNULLA NON INSTALLA NIENTE', () async {
    final annulla = AnnullaDownload()..annulla();
    final v = nuovo(_Bucket().client);
    final esito = await v.scaricaAnimale('Lupo', annulla: annulla);
    expect(esito, EsitoDelDownload.annullato);
    expect(v.installato('lupo'), isFalse);
  });

  test('FINE_USCITA E SCENA_VUOTA SI RITROVANO DOPO L\'INSTALLAZIONE',
      () async {
    final b = _Bucket();
    final conFineUscita = {
      ...b.manifesto,
      'animali': {
        'lupo': {
          ...(b.manifesto['animali'] as Map)['lupo'] as Map,
          'fine_uscita': 'si ferma presto',
          'scena_vuota': '00_SCENA_ULTIMO.jpg',
        },
      },
    };
    final client = MockClient((r) async {
      final u = r.url.toString();
      if (u == _manifesto) {
        return http.Response(jsonEncode(conFineUscita), 200);
      }
      final percorso = u.substring(_base.length);
      return http.Response.bytes(b.file[percorso]!, 200);
    });
    final v = nuovo(client);
    await v.scaricaAnimale('Lupo');
    expect(v.haFineUscita('lupo'), isTrue);
    expect(v.percorsoDellaScenaVuota('lupo'), contains('00_scena_ultimo.webp'));
  });
}
