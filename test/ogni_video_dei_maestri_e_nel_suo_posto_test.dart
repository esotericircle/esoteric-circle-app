import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:esoteric_circle/core/maestro/la_scena_del_maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:flutter_test/flutter_test.dart';

/// **OGNI VIDEO STA NEL SUO POSTO, ordine FW voce FW.05.** Il fondatore, 15
/// ottobre 2026, sullo scambio di Caligo: *"l'ultimo video di Caligo dove lo
/// avvolge il fuoco, io lo userei per il suo dominio essendo di forte
/// impatto e l'altro per la chat"*. Le due cartelle del PC portavano i nomi
/// di prima dello scambio (`caligo_il_vortice_v1.mp4` stava in "Caligo Chat
/// Scena\" ma va nel dominio); lo script `tool/gli_asset_dell_ordine_fw.py`
/// l'ha gia' fatto, verificato misurando lo scarto (il fotogramma giusto
/// molto piu' vicino del fotogramma sbagliato: 9,78 contro 18,67 per il
/// dominio, 12,01 contro 18,59 per la chat; docs/collaudo/FW/fw01_asset.txt).
///
/// Questa guardia lega ogni file alla sua impronta, cosi' uno scambio futuro
/// (una sostituzione col nome giusto ma il contenuto sbagliato) cade subito,
/// senza dover rimisurare lo scarto ogni volta.
///
/// **LO SCAMBIO TORNA INDIETRO, ordine GD voce GD.02, 23 ottobre 2026.** Il
/// fondatore: *"Per Caligo bisogna scambiare il video introduttivo della chat
/// con quello del dominio"*. Il cerchio di fuoco col palmo aperto (la runa
/// della sera, `5965a25b...`) apre adesso il dominio, dove nel palmo compare
/// la runa del tramonto; il vortice (`05b6636e...`) apre la chat. Le due
/// impronte di Caligo si sono scambiate di posto insieme ai file, coi loro
/// ultimi fotogrammi: scarto rimisurato 12,18 contro 18,96 per il dominio,
/// 9,62 contro 18,69 per la chat (docs/collaudo/GD/parte_a.md).
void main() {
  const impronte = {
    'medora_dominio':
        '31cf6e27d00522cfa1965fa70b5fa63edd85e3abe6d7e41498a3ee3bb1e7d97a',
    'medora_chat':
        '7c620d62104be7092117f16f139ccfd7f1b3666c9ed67ca910d4644af42a4f17',
    'caligo_dominio':
        '5965a25bf8dddd388f2e9194025e8aa586d5c667a7845a0d2f5ca463da6b0b65',
    'caligo_chat':
        '05b6636e90b647c8e409104f1f8af5d98fe3952229d7ae74bb86c1c72fb18660',
    'aura_dominio':
        '72c8c8bc403974785b04ed5698bcb810884b655f4f625d20363c575ff39d341b',
    'aura_chat':
        '4600921484d6d4061b2b73eef162517668711c115b4fbd7d1adc8476677634c2',
  };

  test('ogni video ha l\'impronta misurata, nessuno scambiato', () {
    final colpe = <String>[];
    for (final e in impronte.entries) {
      final f = File('brand_assets/maestri_scena/${e.key}_v1.mp4');
      if (!f.existsSync()) {
        colpe.add('${e.key}: il file non esiste');
        continue;
      }
      final vera = sha256.convert(f.readAsBytesSync()).toString();
      if (vera != e.value) {
        colpe.add('${e.key}: impronta $vera, attesa ${e.value}');
      }
    }
    expect(colpe, isEmpty,
        reason: 'questi video non sono piu\' quelli misurati nella Regola A '
            '(o manca il file, o il contenuto e\' cambiato, e con lui forse '
            'la coppia video/fotogramma):\n${colpe.join('\n')}');
  });

  test('LaScenaDelMaestro porta ogni Maestro al suo posto, mai scambiato', () {
    for (final m in Maestro.values) {
      final dominio = LaScenaDelMaestro.delDominio(m);
      final chat = LaScenaDelMaestro.dellaChat(m);
      expect(dominio.video, 'brand_assets/maestri_scena/${m.id}_dominio_v1.mp4',
          reason: '${m.id}: il video del dominio non e\' quello atteso');
      expect(chat.video, 'brand_assets/maestri_scena/${m.id}_chat_v1.mp4',
          reason: '${m.id}: il video della chat non e\' quello atteso');
      expect(dominio.video, isNot(equals(chat.video)),
          reason: '${m.id}: dominio e chat userebbero lo stesso video');
      for (final f in [
        dominio.video,
        dominio.primoFotogramma,
        dominio.ultimoFotogramma,
        chat.video,
        chat.primoFotogramma,
        chat.ultimoFotogramma,
      ]) {
        expect(File(f).existsSync(), isTrue,
            reason: '${m.id}: manca il file $f');
      }
    }
  });
}
