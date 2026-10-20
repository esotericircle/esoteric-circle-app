import 'dart:convert';
import 'dart:io';

import 'package:esoteric_circle/core/rituals/animal_catalog.dart';
import 'package:esoteric_circle/core/viaggio/i_video_del_cammino_scaricati.dart';
import 'package:esoteric_circle/core/viaggio/il_segno_dell_animale.dart';
import 'package:esoteric_circle/core/viaggio/la_sequenza_del_cammino.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **"SI VOLTA" FA GIRARE IL PEZZO VOLTA, E IL MANIFESTO V2 LO PORTA PER
/// TUTTI E DODICI.** 20 ottobre 2026.
///
/// **Il fatto**: la verifica fotogramma per fotogramma dei dodici animali
/// del Viaggio dello Sciamano ha trovato che il pezzo "centro", quello che
/// l'app faceva girare per il gesto "si volta", mostra il verso dell'animale
/// e non il voltarsi; la riga diceva *"si volta a guardare dietro di sé"* e
/// il video no. Il fondatore: *"Certo che devi controllare che il gufo si
/// giri, ma anche gli altri animali devono comportarsi allo stesso modo."*
/// La cura scelta da lui: *"Taglio andata e ritorno"*. Padre: ordine FZ voce
/// FZ.05 (la sequenza dei gesti) e FZ.06 (i tagli dei video).
///
/// **Cosa misura**:
/// - il gesto "si volta" fa girare il solo pezzo `volta`, mai il centro;
/// - il manifesto v2 (la copia nel repo, `docs/collaudo/viaggio_volta/`,
///   identica byte per byte a quella che `tool/gli_asset_del_viaggio_v2.py`
///   scrive in `_pronti_v2` accanto ai video: le impronte dei file si
///   rileggono dal disco prima di caricarli, non qui, perche' i video non
///   stanno nel repo e una prova non si salta) porta per ognuno dei dodici
///   animali del catalogo il pezzo `volta` col suo SHA-256, diverso da quello
///   del centro, che
///   comincia dove comincia l'uscita e il cui primo e ultimo fotogramma
///   stanno sulla posa (scarto misurato sotto 6 su 255: senza il raccordo
///   sarebbe stato fra 9 e 13);
/// - le cure D3, D4 e D5: l'arrivo del Cervo dal fotogramma 3, l'uscita che
///   finisce prima della trasparenza con la dissolvenza sulla scena vuota per
///   tutti e dodici, la riga dell'uscita che dice quello che il video mostra.
///
/// **Cardinale proprio**: i dodici animali del catalogo, e i dodici pezzi
/// volta trovati nel manifesto.
const _copia = 'docs/collaudo/viaggio_volta/manifesto_viaggio_v2.json';

/// Gli animali di terra la cui uscita diventava trasparente (D4).
const _trasparentiSulSentiero = {
  'Cavallo', 'Cervo', 'Lince', 'Lupo', 'Orso', 'Serpente', 'Volpe', //
};

Map<String, dynamic> _manifesto(String percorso) =>
    jsonDecode(File(percorso).readAsStringSync()) as Map<String, dynamic>;

void main() {
  final nomi = [for (final a in AnimalCatalog.animals) a.name];

  test('SI VOLTA FA GIRARE IL SOLO PEZZO VOLTA, MAI IL CENTRO', () {
    for (final fine in [false, true]) {
      final s = LaSequenzaDelCammino.perIlGesto(GestoDelSegno.siVolta,
          haFineUscita: fine);
      expect(s.pezzi, [PezzoDelCammino.volta],
          reason: '"si volta" fa girare ${s.pezzi}: il centro mostra il verso, '
              'non il voltarsi');
      expect(s.esito, EsitoDelCammino.restaInPosa);
    }
    // La riga resta quella, perche' adesso il video la mostra.
    for (final a in AnimalCatalog.animals) {
      expect(GestoDelSegno.siVolta.descrizione(a),
          'si volta a guardare dietro di sé');
    }
  });

  test(
      'IL MANIFESTO V2 PORTA PER OGNI ANIMALE IL PEZZO VOLTA COL SUO SHA, che '
      'comincia e finisce sulla posa', () {
    cardinaleMinimo(nomi.length, 12, cosa: 'animali del catalogo');
    final m = _manifesto(_copia);
    expect(m['versione'], IVideoDelCamminoScaricati.versioneAttuale,
        reason:
            'il manifesto della copia non e\' la versione che l\'app vuole');
    final animali = m['animali'] as Map;
    var visti = 0;
    for (final nome in nomi) {
      final voce = animali[nome.toLowerCase()] as Map?;
      expect(voce, isNotNull, reason: 'il manifesto v2 non porta $nome');
      final pezzi = voce!['pezzi'] as Map;
      final volta = pezzi['volta'] as Map?;
      expect(volta, isNotNull, reason: '$nome non ha il pezzo volta');
      expect(volta!['file'], '${nome.toLowerCase()}_volta_v2.mp4');
      expect(volta['sha256'], matches(RegExp(r'^[0-9a-f]{64}$')),
          reason: '$nome: il pezzo volta senza la sua impronta');
      expect(volta['byte'] as int, greaterThan(100000));
      expect(volta['sha256'], isNot((pezzi['centro'] as Map)['sha256']),
          reason: '$nome: il pezzo volta e\' il centro con un altro nome');
      expect(volta['da_fotogramma'], (pezzi['uscita'] as Map)['da_fotogramma'],
          reason: '$nome: il voltarsi e\' il primo tratto dell\'uscita');
      expect(volta['a_fotogramma'] as int,
          greaterThan(volta['da_fotogramma'] as int));
      for (final chi in [
        'scarto_primo_dalla_posa',
        'scarto_ultimo_dalla_posa'
      ]) {
        expect(volta[chi] as num, lessThan(6),
            reason: '$nome: $chi ${volta[chi]} su 255, il pezzo non '
                'comincia o non finisce sulla posa');
      }
      visti++;
    }
    cardinaleMinimo(visti, 12, cosa: 'pezzi volta nel manifesto v2');
  });

  test(
      'D3, D4: L\'ARRIVO DEL CERVO DAL FOTOGRAMMA 3, E PER TUTTI E DODICI '
      'L\'USCITA CHE FINISCE NELLA SCENA VUOTA', () {
    final animali = _manifesto(_copia)['animali'] as Map;
    final cervo = (animali['cervo'] as Map)['pezzi'] as Map;
    expect((cervo['arrivo'] as Map)['da_fotogramma'], 3);
    expect((cervo['arrivo'] as Map)['file'], 'cervo_arrivo_v2.mp4');
    for (final nome in nomi) {
      final voce = animali[nome.toLowerCase()] as Map;
      expect(voce['fine_uscita'], isNotNull,
          reason: '$nome: l\'uscita non chiude sulla scena vuota');
      expect(voce['scena_vuota'], isNotNull);
      if (_trasparentiSulSentiero.contains(nome)) {
        final uscita = (voce['pezzi'] as Map)['uscita'] as Map;
        expect(uscita['file'], '${nome.toLowerCase()}_uscita_v2.mp4',
            reason: '$nome: l\'uscita e\' ancora quella che diventa '
                'trasparente');
        expect(uscita['a_fotogramma'] as int, lessThan(233));
      }
    }
  });

  test('D5: LA RIGA DELL\'USCITA DICE QUELLO CHE IL VIDEO MOSTRA', () {
    for (final a in AnimalCatalog.animals) {
      final riga = GestoDelSegno.siAllontana.descrizione(a);
      if (GestiDelSegno.uccelli.contains(a.name)) {
        expect(riga, 'si allontana in volo');
      } else if (a.name == 'Serpente') {
        expect(riga, 'si allontana strisciando fra gli alberi');
      } else {
        expect(riga, 'si allontana fra gli alberi', reason: a.name);
      }
    }
  });

  test('L\'APP CHIEDE LA V2 E, FINCHE\' NON C\'E\', RIPIEGA SULLA V1', () {
    expect(IVideoDelCamminoScaricati.manifestoSulBucket,
        endsWith('viaggio_sciamano/manifesto_viaggio_v2.json'));
    expect(IVideoDelCamminoScaricati.manifestoV1SulBucket,
        endsWith('viaggio_sciamano/manifesto_viaggio_v1.json'));
    final casa = IVideoDelCamminoScaricati();
    expect(casa.indirizzoDiRipiego,
        IVideoDelCamminoScaricati.manifestoV1SulBucket);
  });
}
