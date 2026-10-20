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
//
// E dal 20 ottobre 2026, il manifesto v2 col pezzo `volta` (taglio andata e
// ritorno, scelta del fondatore):
// - finche' la v2 non e' sul bucket l'app ripiega sulla v1;
// - un animale della v1 non e' aggiornato, e passando alla v2 riprende dal
//   telefono i file che non cambiano;
// - con la sola v1 sul bucket un animale della v1 non si riscarica.
//
// E dal 20 ottobre 2026 sera, il manifesto v3 col pezzo `volta` nuovo dei
// sette animali di terra (il video del "si volta" dell'Architetto):
// - l'app chiede la v3, poi la v2, poi la v1;
// - un animale di terra della v2 passa alla v3 chiedendo alla rete il solo
//   pezzo volta nuovo;
// - un uccello o il Serpente, il cui pezzo volta non cambia, passa alla v3
//   senza chiedere alla rete nessun file.

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
    'https://finto.bucket/viaggio_sciamano/manifesto_viaggio_v3.json';
const _manifestoV2 =
    'https://finto.bucket/viaggio_sciamano/manifesto_viaggio_v2.json';
const _manifestoV1 =
    'https://finto.bucket/viaggio_sciamano/manifesto_viaggio_v1.json';
const _base = 'https://finto.bucket/viaggio_sciamano/';

/// I file del Lupo nella v1, nella v2 e nella v3: la v2 aggiunge il pezzo
/// volta e cambia l'uscita, la v3 cambia il solo pezzo volta; arrivo, centro
/// e posa restano quelli della v1.
const _fileV1 = {
  'arrivo': 'lupo_arrivo_v1.mp4',
  'centro': 'lupo_centro_v1.mp4',
  'uscita': 'lupo_uscita_v1.mp4',
};
const _fileV2 = {
  'arrivo': 'lupo_arrivo_v1.mp4',
  'centro': 'lupo_centro_v1.mp4',
  'volta': 'lupo_volta_v2.mp4',
  'uscita': 'lupo_uscita_v2.mp4',
};
const _fileV3 = {
  'arrivo': 'lupo_arrivo_v1.mp4',
  'centro': 'lupo_centro_v1.mp4',
  'volta': 'lupo_volta_v3.mp4',
  'uscita': 'lupo_uscita_v2.mp4',
};

/// Il bucket finto: i manifesti col solo Lupo, i suoi pezzi e la posa.
/// Con [voltaNuovoNellaV3] falso la v3 tiene il pezzo volta della v2, come
/// per Gufo, Aquila, Falco, Corvo e Serpente.
class _Bucket {
  _Bucket({
    this.guasti = const {},
    this.v3Pubblicata = true,
    this.v2Pubblicata = true,
    this.voltaNuovoNellaV3 = true,
  });

  final Map<String, int> guasti;
  final bool v3Pubblicata;
  final bool v2Pubblicata;
  final bool voltaNuovoNellaV3;
  final Map<String, int> chiamate = {};
  final Map<String, Uint8List> file = {
    for (final n in {
      ..._fileV1.values,
      ..._fileV2.values,
      ..._fileV3.values,
      'lupo_posa_v1.webp',
    })
      n: Uint8List.fromList(utf8.encode('byte di $n')),
  };

  Map<String, dynamic> _voce(Map<String, String> pezzi) => {
        'pezzi': {
          for (final p in pezzi.entries)
            p.key: {
              'file': p.value,
              'byte': file[p.value]!.length,
              'sha256': sha256.convert(file[p.value]!).toString(),
            },
        },
        'posa': {
          'file': 'lupo_posa_v1.webp',
          'byte': file['lupo_posa_v1.webp']!.length,
          'sha256': sha256.convert(file['lupo_posa_v1.webp']!).toString(),
        },
        'fine_uscita': null,
        'scena_vuota': null,
      };

  Map<String, dynamic> get manifestoV1 => {
        'animali': {'lupo': _voce(_fileV1)},
      };

  Map<String, dynamic> get manifestoV2 => {
        'versione': 2,
        'animali': {'lupo': _voce(_fileV2)},
      };

  Map<String, dynamic> get manifesto => {
        'versione': 3,
        'animali': {'lupo': _voce(voltaNuovoNellaV3 ? _fileV3 : _fileV2)},
      };

  MockClient get client => MockClient((r) async {
        final u = r.url.toString();
        if (u == _manifesto) {
          return v3Pubblicata
              ? http.Response(jsonEncode(manifesto), 200)
              : http.Response('no', 404);
        }
        if (u == _manifestoV2) {
          return v2Pubblicata
              ? http.Response(jsonEncode(manifestoV2), 200)
              : http.Response('no', 404);
        }
        if (u == _manifestoV1) {
          return http.Response(jsonEncode(manifestoV1), 200);
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
          indirizzoDelManifesto: _manifesto,
          indirizziDiRipiego: const [_manifestoV2, _manifestoV1]);

  test('UN DOWNLOAD RIUSCITO INSTALLA I QUATTRO PEZZI E LA POSA, e resta',
      () async {
    final v = nuovo(_Bucket().client);
    final esito = await v.scaricaAnimale('Lupo');
    expect(esito, EsitoDelDownload.installato);
    expect(v.installato('lupo'), isTrue);
    expect(v.aggiornato('lupo'), isTrue);
    for (final p in PezzoDelCammino.values) {
      final percorso = v.percorsoDiPezzo('lupo', p);
      expect(percorso, isNotNull, reason: '$p non si trova dopo il download');
      expect(File(percorso!).existsSync(), isTrue);
    }
    expect(v.percorsoDiPezzo('lupo', PezzoDelCammino.volta),
        endsWith('lupo_volta_v3.mp4'));
    expect(v.percorsoDellaPosa('lupo'), isNotNull);

    // Un'altra istanza, senza rete: lo ritrova dal telefono.
    final v2 = IVideoDelCamminoScaricati(
        client:
            MockClient((_) async => http.Response('non doveva chiamare', 500)),
        cartella: () async => cartella);
    await v2.leggiIInstallati();
    expect(v2.installato('lupo'), isTrue);
    expect(v2.aggiornato('lupo'), isTrue,
        reason: 'la versione scaricata non si e\' riletta dal telefono');
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

  test(
      'FINCHE\' LA V3 NON E\' SUL BUCKET SI RIPIEGA SULLA V2: l\'animale si '
      'installa col pezzo volta della v2, e non e\' aggiornato', () async {
    final v = nuovo(_Bucket(v3Pubblicata: false).client);
    final esito = await v.scaricaAnimale('Lupo');
    expect(esito, EsitoDelDownload.installato,
        reason: 'senza la v3 sul bucket l\'app installata resta senza video');
    expect(v.percorsoDiPezzo('lupo', PezzoDelCammino.volta),
        endsWith('lupo_volta_v2.mp4'));
    expect(v.aggiornato('lupo'), isFalse);
  });

  test(
      'SENZA LA V3 E SENZA LA V2 SUL BUCKET SI RIPIEGA SULLA V1: l\'animale si '
      'installa, senza il pezzo volta e non aggiornato', () async {
    final v = nuovo(_Bucket(v3Pubblicata: false, v2Pubblicata: false).client);
    final esito = await v.scaricaAnimale('Lupo');
    expect(esito, EsitoDelDownload.installato,
        reason: 'senza la v2 sul bucket l\'app installata resta senza video');
    expect(v.installato('lupo'), isTrue);
    expect(v.percorsoDiPezzo('lupo', PezzoDelCammino.centro),
        endsWith('lupo_centro_v1.mp4'));
    expect(v.percorsoDiPezzo('lupo', PezzoDelCammino.volta), isNull);
    expect(v.aggiornato('lupo'), isFalse);
  });

  test(
      'CON LA SOLA V1 SUL BUCKET UN ANIMALE DELLA V1 NON SI RISCARICA: tre '
      'manifesti chiesti, nessun file', () async {
    final b = _Bucket(v3Pubblicata: false, v2Pubblicata: false);
    final v = nuovo(b.client);
    await v.scaricaAnimale('Lupo');
    final prima = v.richiesteFatte;
    final esito = await v.scaricaAnimale('Lupo');
    expect(esito, EsitoDelDownload.installato);
    expect(v.richiesteFatte - prima, 3,
        reason: 'la v1 gia\' sul telefono si e\' riscaricata');
  });

  test(
      'UN ANIMALE DELLA V1 PASSA ALLA V3: chiede alla rete solo i file nuovi '
      '(volta e uscita), gli altri li riprende dal telefono', () async {
    final soloV1 = _Bucket(v3Pubblicata: false, v2Pubblicata: false);
    final v = nuovo(soloV1.client);
    await v.scaricaAnimale('Lupo');
    expect(v.aggiornato('lupo'), isFalse);

    final conV2 = _Bucket();
    final v2 = nuovo(conV2.client);
    await v2.leggiIInstallati();
    expect(v2.aggiornato('lupo'), isFalse);
    final esito = await v2.scaricaAnimale('Lupo');
    expect(esito, EsitoDelDownload.installato);
    expect(v2.aggiornato('lupo'), isTrue);
    expect(v2.percorsoDiPezzo('lupo', PezzoDelCammino.volta),
        endsWith('lupo_volta_v3.mp4'));
    expect(conV2.chiamate.keys.toSet(),
        {'lupo_volta_v3.mp4', 'lupo_uscita_v2.mp4'},
        reason: 'i file che non cambiano si sono riscaricati dalla rete');
    for (final p in PezzoDelCammino.values) {
      expect(File(v2.percorsoDiPezzo('lupo', p)!).existsSync(), isTrue,
          reason: '$p manca dopo il passaggio alla v3');
    }
  });

  /// Un animale installato con la v2, poi la v3 sul bucket: [voltaNuovo]
  /// dice se la v3 gli porta un pezzo volta nuovo (gli animali di terra) o
  /// tiene quello della v2 (gli uccelli e il Serpente).
  Future<(IVideoDelCamminoScaricati, _Bucket)> dallaV2AllaV3(
      {required bool voltaNuovo}) async {
    final v = nuovo(_Bucket(v3Pubblicata: false).client);
    await v.scaricaAnimale('Lupo');
    expect(v.percorsoDiPezzo('lupo', PezzoDelCammino.volta),
        endsWith('lupo_volta_v2.mp4'));
    final conV3 = _Bucket(voltaNuovoNellaV3: voltaNuovo);
    final v3 = nuovo(conV3.client);
    await v3.leggiIInstallati();
    expect(v3.aggiornato('lupo'), isFalse,
        reason: 'un animale della v2 sul telefono si crede aggiornato');
    final esito = await v3.scaricaAnimale('Lupo');
    expect(esito, EsitoDelDownload.installato);
    expect(v3.aggiornato('lupo'), isTrue);
    for (final p in PezzoDelCammino.values) {
      expect(File(v3.percorsoDiPezzo('lupo', p)!).existsSync(), isTrue,
          reason: '$p manca dopo il passaggio alla v3');
    }
    return (v3, conV3);
  }

  test(
      'UN ANIMALE DI TERRA DELLA V2 PASSA ALLA V3: chiede alla rete il solo '
      'pezzo volta nuovo, il resto lo riprende dal telefono', () async {
    final (v3, bucket) = await dallaV2AllaV3(voltaNuovo: true);
    expect(v3.percorsoDiPezzo('lupo', PezzoDelCammino.volta),
        endsWith('lupo_volta_v3.mp4'));
    expect(bucket.chiamate.keys.toSet(), {'lupo_volta_v3.mp4'},
        reason: 'i file con la stessa impronta si sono riscaricati');
  });

  test(
      'UN UCCELLO O IL SERPENTE DELLA V2 PASSA ALLA V3 SENZA CHIEDERE FILE: '
      'il suo pezzo volta non cambia', () async {
    final (v3, bucket) = await dallaV2AllaV3(voltaNuovo: false);
    expect(v3.percorsoDiPezzo('lupo', PezzoDelCammino.volta),
        endsWith('lupo_volta_v2.mp4'));
    expect(bucket.chiamate, isEmpty,
        reason: 'un pezzo volta che non cambia si e\' riscaricato');
  });
}
