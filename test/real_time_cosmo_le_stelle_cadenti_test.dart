// LE STELLE CADENTI. Ordine FH parte 12.
//
// 12.1: i sette sciami dell'ordine, con la data di massimo dell'ordine.
// 12.2: la frequenza cala allontanandosi dal massimo; fuori dagli sciami
// restano le sporadiche. 12.3: una meteora parte dal radiante, dura meno di un
// secondo e si spegne. 12.4 (Riduci Movimento) la sorveglia l'anteprima della
// schermata.

import 'dart:math' as math;

import 'package:esoteric_circle/core/astro/celestial.dart';
import 'package:esoteric_circle/core/astro/real_time_cosmo/gli_sciami_di_meteore.dart';
import 'package:esoteric_circle/core/astro/real_time_cosmo/il_cielo_in_un_istante.dart';
import 'package:esoteric_circle/core/astro/real_time_cosmo/la_camera_del_cielo.dart';
import 'package:esoteric_circle/features/real_time_cosmo/le_meteore_in_scena.dart';
import 'package:flutter_test/flutter_test.dart';

import 'real_time_cosmo_la_densita_del_cielo_test.dart' show catalogoDalDisco;

void main() {
  test('i sette sciami dell\'ordine, con le loro date', () {
    final date = {
      for (final s in kSciamiDiMeteore) s.nome: '${s.giorno}/${s.mese}',
    };
    expect(date, {
      'Quadrantidi': '3/1',
      'Liridi': '22/4',
      'Eta Aquaridi': '6/5',
      'Perseidi': '12/8',
      'Orionidi': '21/10',
      'Leonidi': '17/11',
      'Geminidi': '13/12',
    });
  });

  test('la frequenza cala allontanandosi dal massimo', () {
    final perseidi = kSciamiDiMeteore.firstWhere((s) => s.nome == 'Perseidi');
    expect(perseidi.frequenzaIl(DateTime.utc(2026, 8, 12)), 100);
    expect(perseidi.frequenzaIl(DateTime.utc(2026, 8, 14, 12)),
        closeTo(100 / math.e, 1e-6));
    expect(sciameDelGiorno(DateTime.utc(2026, 8, 12))!.sciame.nome, 'Perseidi');
    // Il 20 marzo nessuno sciame supera le sporadiche.
    expect(sciameDelGiorno(DateTime.utc(2026, 3, 20)), isNull);
    // Le Quadrantidi del 3 gennaio si vedono gia' il 2 gennaio, e la notte
    // di San Silvestro conta il massimo dell'anno dopo.
    final q = kSciamiDiMeteore.first;
    expect(q.frequenzaIl(DateTime.utc(2026, 12, 31)),
        closeTo(q.frequenzaIl(DateTime.utc(2027, 1, 6)), 1e-6));
  });

  test('una meteora parte dal radiante, dura meno di un secondo e si spegne',
      () {
    final catalogo = catalogoDalDisco();
    // Il 12 agosto 2026 alle 23 UTC da Napoli: il Perseo e' alto a nord-est.
    final cielo = CieloInUnIstante.calcola(catalogo,
        jd: Celestial.julianDay(DateTime.utc(2026, 8, 12, 23)),
        latitudine: 40.85,
        longitudine: 14.27);
    final o =
        OrientamentoDellaCamera.daAngoli(azimutGradi: 45, altezzaGradi: 45);
    final p = ProiezioneDelCielo(larghezza: 360, altezza: 797, campoGradi: 70);
    final perseidi = kSciamiDiMeteore.firstWhere((s) => s.nome == 'Perseidi');
    final m = MeteoreInScena();
    m.configura(
        raGradi: perseidi.raGradi, decGradi: perseidi.decGradi, frequenza: 0);
    // Senza frequenza non nasce niente.
    for (var i = 0; i < 120; i++) {
      m.prepara(o, p, cielo.assi, 1 / 60);
    }
    expect(m.nate, 0);
    expect(m.vertici, 0);
    // Con la nascita forzata, una meteora che si vede e poi si spegne.
    m.prossimaSubito = true;
    var visto = 0;
    var fotogrammi = 0;
    for (var i = 0; i < 90; i++) {
      m.prepara(o, p, cielo.assi, 1 / 60);
      if (m.vertici > 0) {
        visto = math.max(visto, m.vertici);
        fotogrammi++;
      }
    }
    expect(m.nate, 1);
    expect(visto, greaterThan(0));
    // Meno di un secondo: al piu' 0,9 secondi, 54 fotogrammi.
    expect(fotogrammi, lessThanOrEqualTo(54));
    expect(m.vertici, 0);
  });
}
