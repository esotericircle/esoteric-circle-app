import 'dart:convert';
import 'dart:io';

import 'package:esoteric_circle/core/rituals/animal_catalog.dart';
import 'package:esoteric_circle/core/viaggio/i_video_del_cammino_scaricati.dart';
import 'package:esoteric_circle/core/viaggio/il_segno_dell_animale.dart';
import 'package:esoteric_circle/core/viaggio/la_sequenza_del_cammino.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **"SI VOLTA" FA GIRARE IL PEZZO VOLTA, E IL MANIFESTO LO PORTA PER TUTTI
/// E DODICI.** 20 ottobre 2026.
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
/// **La v3, lo stesso 20 ottobre 2026 sera.** Il taglio andata e ritorno
/// della v2 era buono per Gufo, Aquila, Falco, Corvo e Serpente, debole per
/// i sette animali di terra (fra 0,46 e 1,2 s: il capo girava di pochi
/// fotogrammi prima del passo). L'Architetto ha consegnato per loro un video
/// nuovo del "si volta"; `tool/gli_asset_del_viaggio_v3.py` ne fa il pezzo
/// `volta` v3, dall'inizio alla fine del gesto, con la dissolvenza di 0,3 s
/// verso la posa in testa e in coda. Padre del difetto: ordine GA voce 11,
/// la v2 (commit fb2b74fb), che per gli animali di terra prendeva il voltarsi
/// dall'uscita.
///
/// **Cosa misura**:
/// - il gesto "si volta" fa girare il solo pezzo `volta`, mai il centro;
/// - il manifesto v3 (la copia nel repo, `docs/collaudo/viaggio_volta/v3/`,
///   identica byte per byte a quella che lo strumento scrive in `_pronti_v3`
///   accanto ai video: le impronte dei file si rileggono dal disco prima di
///   caricarli, non qui, perche' i video non stanno nel repo e una prova non
///   si salta) porta per i sette animali di terra un pezzo `volta` nuovo
///   (`<animale>_volta_v3.mp4`, la sua impronta, diversa da quella della v2 e
///   del centro, il gesto intero fra 5 e 7 secondi, il primo e l'ultimo
///   fotogramma sulla posa con lo scarto sotto 6 su 255), e per Gufo, Aquila,
///   Falco, Corvo e Serpente il pezzo della v2 com'e'; e tutto il resto
///   identico alla v2;
/// - le cure D3, D4 e D5: l'arrivo del Cervo dal fotogramma 3, l'uscita che
///   finisce prima della trasparenza con la dissolvenza sulla scena vuota per
///   tutti e dodici, la riga dell'uscita che dice quello che il video mostra.
///
/// **Cardinale proprio**: i dodici animali del catalogo, i sette pezzi volta
/// nuovi e i cinque rimasti della v2.
const _copia = 'docs/collaudo/viaggio_volta/v3/manifesto_viaggio_v3.json';
const _copiaV2 = 'docs/collaudo/viaggio_volta/manifesto_viaggio_v2.json';

/// Gli animali di terra la cui uscita diventava trasparente (D4).
const _trasparentiSulSentiero = {
  'Cavallo', 'Cervo', 'Lince', 'Lupo', 'Orso', 'Serpente', 'Volpe', //
};

/// I sette animali di terra col video nuovo del "si volta" (v3).
const _diTerra = {
  'Lince', 'Volpe', 'Orso', 'Lupo', 'Cavallo', 'Cervo', 'Tartaruga', //
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
      'IL MANIFESTO V3 PORTA PER I SETTE ANIMALI DI TERRA IL PEZZO VOLTA '
      'NUOVO COL SUO SHA, e per gli uccelli e il Serpente quello della v2', () {
    cardinaleMinimo(nomi.length, 12, cosa: 'animali del catalogo');
    final m = _manifesto(_copia);
    expect(m['versione'], IVideoDelCamminoScaricati.versioneAttuale,
        reason:
            'il manifesto della copia non e\' la versione che l\'app vuole');
    final animali = m['animali'] as Map;
    final v2 = _manifesto(_copiaV2)['animali'] as Map;
    var nuovi = 0;
    var rimasti = 0;
    for (final nome in nomi) {
      final chiave = nome.toLowerCase();
      final voce = animali[chiave] as Map?;
      expect(voce, isNotNull, reason: 'il manifesto v3 non porta $nome');
      final pezzi = voce!['pezzi'] as Map;
      final volta = pezzi['volta'] as Map?;
      expect(volta, isNotNull, reason: '$nome non ha il pezzo volta');
      final voltaV2 = (v2[chiave] as Map)['pezzi']['volta'] as Map;
      if (_diTerra.contains(nome)) {
        expect(volta!['file'], '${chiave}_volta_v3.mp4',
            reason: '$nome ha ancora il taglio della v2');
        expect(volta['sha256'], matches(RegExp(r'^[0-9a-f]{64}$')),
            reason: '$nome: il pezzo volta senza la sua impronta');
        expect(volta['sha256'], isNot(voltaV2['sha256']),
            reason: '$nome: il pezzo volta e\' quello della v2');
        expect(volta['sha256'], isNot((pezzi['centro'] as Map)['sha256']),
            reason: '$nome: il pezzo volta e\' il centro con un altro nome');
        expect(volta['byte'] as int, greaterThan(1000000));
        expect(volta['sorgente'], '${chiave}_si_volta_v1.mp4');
        final da = volta['da_fotogramma'] as int;
        final girata = volta['girata_completa'] as int;
        final ritorno = volta['ritorno_inizio'] as int;
        final a = volta['a_fotogramma'] as int;
        expect(da < girata && girata < ritorno && ritorno < a, isTrue,
            reason: '$nome: i punti del gesto fuori ordine');
        expect(volta['fotogrammi'], a - da + 1,
            reason: '$nome: il pezzo non e\' il gesto intero');
        expect(volta['durata_s'] as num, inInclusiveRange(5.0, 7.0),
            reason: '$nome: il gesto dura ${volta['durata_s']} s');
        expect(volta['dissolvenza_con_la_posa'], 7,
            reason: '$nome: la dissolvenza con la posa non e\' 0,3 s');
        nuovi++;
      } else {
        expect(volta, voltaV2,
            reason: '$nome: il pezzo volta della v2 e\' cambiato');
        rimasti++;
      }
      for (final chi in [
        'scarto_primo_dalla_posa',
        'scarto_ultimo_dalla_posa'
      ]) {
        expect(volta![chi] as num, lessThan(6),
            reason: '$nome: $chi ${volta[chi]} su 255, il pezzo non '
                'comincia o non finisce sulla posa');
      }
      // Tutto il resto e' la v2: i file che non cambiano si riprendono dal
      // telefono.
      final senzaVolta = {...voce}..remove('pezzi');
      final v2SenzaVolta = {...v2[chiave] as Map}..remove('pezzi');
      expect(senzaVolta, v2SenzaVolta, reason: nome);
      for (final p in ['arrivo', 'centro', 'uscita']) {
        expect(pezzi[p], (v2[chiave] as Map)['pezzi'][p],
            reason: '$nome: il pezzo $p e\' cambiato dalla v2');
      }
    }
    cardinaleMinimo(nuovi, 7, cosa: 'pezzi volta nuovi nel manifesto v3');
    cardinaleMinimo(rimasti, 5, cosa: 'pezzi volta della v2 nel manifesto v3');
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

  test(
      'L\'APP CHIEDE LA V3 E, FINCHE\' NON C\'E\', RIPIEGA SULLA V2 E POI SULLA V1',
      () {
    expect(IVideoDelCamminoScaricati.manifestoSulBucket,
        endsWith('viaggio_sciamano/manifesto_viaggio_v3.json'));
    expect(IVideoDelCamminoScaricati.manifestoV2SulBucket,
        endsWith('viaggio_sciamano/manifesto_viaggio_v2.json'));
    expect(IVideoDelCamminoScaricati.manifestoV1SulBucket,
        endsWith('viaggio_sciamano/manifesto_viaggio_v1.json'));
    final casa = IVideoDelCamminoScaricati();
    expect(casa.indirizziDiRipiego, [
      IVideoDelCamminoScaricati.manifestoV2SulBucket,
      IVideoDelCamminoScaricati.manifestoV1SulBucket,
    ]);
  });
}
