import 'dart:io';

import 'package:esoteric_circle/core/legal/fonti_dei_dati.dart';
import 'package:flutter_test/flutter_test.dart';

/// IL CATALOGO COPRE IL MONDO. Ordine CC voce 07.
///
/// **Cosa difende questa prova.** Che il numero dei luoghi per paese non
/// scenda mai piu': chi nasce fuori dall'Italia e non trova la sua citta'
/// dichiara un luogo di nascita falso, e da coordinate false nasce una carta
/// natale che non e' la sua. **Il numero segue il dato**: quando il catalogo
/// si rigenera i pavimenti si alzano, e da quel momento in poi si difende il
/// nuovo, mai il vecchio.
///
/// E difende anche l'obbligo della licenza: GeoNames sta sotto Creative
/// Commons Attribution 4.0, e l'attribuzione deve essere raggiungibile
/// dall'app, non sepolta in un commento.
void main() {
  /// I luoghi, per paese, letti dal file vero come lo legge l'app.
  Map<String, int> perPaese() {
    final righe = File('assets/data/luoghi.csv').readAsLinesSync();
    final conti = <String, int>{};
    // Le prime due righe sono la versione del formato e la tabella dei fusi.
    for (final r in righe.skip(2)) {
      final campi = r.split(';');
      if (campi.length < 3) continue;
      final area = campi[2];
      if (area.isEmpty) continue;
      // Le righe italiane portano la sigla della provincia, due lettere
      // maiuscole; le estere portano il nome della nazione in italiano.
      final italiana = area.length == 2 && area == area.toUpperCase();
      conti[italiana ? 'Italia' : area] =
          (conti[italiana ? 'Italia' : area] ?? 0) + 1;
    }
    return conti;
  }

  test('il catalogo non perde luoghi, ne in tutto ne per paese', () {
    final conti = perPaese();
    final totale = conti.values.fold<int>(0, (a, b) => a + b);
    final fuori = totale - (conti['Italia'] ?? 0);
    final soli = conti.entries.where((e) => e.value == 1).length;
    // ignore: avoid_print
    print('ORDINE CC VOCE 07: luoghi $totale, fuori dall\'Italia $fuori, '
        'paesi ${conti.length - 1}, paesi con una sola citta\' $soli');

    // **I PAVIMENTI SONO QUELLI MISURATI SUL RAMO DOPO LA RIGENERAZIONE**,
    // non numeri desiderati: 40.846 luoghi, 32.408 fuori dall'Italia, 241
    // paesi. Prima erano 11.546, 3.108 e 241. Un pavimento che resta basso
    // dopo una crescita non difende piu' niente.
    expect(totale, greaterThanOrEqualTo(40846),
        reason: 'il catalogo ha perso luoghi rispetto a com\'era');
    expect(fuori, greaterThanOrEqualTo(32408),
        reason: 'il catalogo ha perso luoghi fuori dall\'Italia, e chi nasce '
            'li\' torna a dichiarare una citta\' che non e\' la sua');
    expect(conti.length - 1, greaterThanOrEqualTo(241),
        reason: 'un paese e\' sparito dal catalogo');
  });

  test('i paesi grandi non sono rappresentati da una citta\' sola', () {
    final conti = perPaese();
    // **Questi otto sono i paesi da cui arriva chi parla italiano**, cioe' i
    // paesi confinanti e quelli della grande emigrazione: se il catalogo e'
    // povero qui, e' povero dove fa male. Il pavimento e' quello misurato
    // oggi, e sale con la rigenerazione.
    const guardati = <String, int>{
      'Francia': 691,
      'Svizzera': 95,
      'Germania': 1135,
      'Regno Unito': 860,
      'Spagna': 731,
      'Albania': 25,
      'Romania': 134,
      'Argentina': 314,
    };
    final poveri = <String>[];
    for (final g in guardati.entries) {
      final quanti = conti[g.key] ?? 0;
      if (quanti < g.value) poveri.add('${g.key} $quanti');
    }
    final detto = guardati.keys.map((p) => '$p ${conti[p] ?? 0}').join(', ');
    // ignore: avoid_print
    print('ORDINE CC VOCE 07: $detto');
    expect(poveri, isEmpty,
        reason: 'questi paesi hanno meno luoghi di prima: $poveri');
  });

  test('la soglia del mondo e\' dichiarata nel generatore', () {
    final gen = File('tool/genera_luoghi.py').readAsStringSync();
    expect(gen.contains('SOGLIA_DEL_MONDO = 15000'), isTrue,
        reason: 'la soglia che decide chi entra nel catalogo e\' tornata un '
            'numero scritto a mano dentro una condizione');
    expect(gen.contains('pop < 200000'), isFalse,
        reason: 'la vecchia potatura a duecentomila abitanti e\' tornata, e '
            'con lei i 116 paesi con una citta\' sola');
  });

  test('ogni fonte dichiara chi la pubblica e con quale licenza', () {
    final mute = <String>[];
    for (final f in fontiDeiDati) {
      if (f.cosa.isEmpty ||
          f.chi.isEmpty ||
          f.licenza.isEmpty ||
          f.dove.isEmpty) {
        mute.add(f.cosa);
      }
    }
    expect(mute, isEmpty, reason: 'fonti senza licenza scritta: $mute');
    // GeoNames sta sotto CC BY 4.0, e quella licenza pretende l'attribuzione:
    // e' il vincolo scritto nella voce.
    final geo = fontiDeiDati.where((f) => f.chi.contains('GeoNames'));
    expect(geo, hasLength(1),
        reason: 'la fonte dei luoghi di nascita non e\' piu\' dichiarata');
    expect(geo.single.licenza.contains('Attribution'), isTrue,
        reason: 'la licenza di GeoNames non e\' scritta com\'e\'');
  });

  test('l\'attribuzione e\' raggiungibile dall\'app, non solo dal codice', () {
    // **HA CAMBIATO POSTO, NON E' SPARITA. Ordine CE voce 03.** Il fondatore
    // ha fatto spostare tutto il blocco della privacy in un sotto menu'
    // dedicato: l'elenco delle fonti vive li' dentro, e le Impostazioni ci
    // portano con una riga. La licenza CC BY 4.0 pretende che
    // l'attribuzione sia RAGGIUNGIBILE, non che stia in prima pagina: due
    // tocchi da una schermata di sistema sono il modo in cui ogni app
    // assolve questo obbligo.
    // **E ADESSO LA RIGA STA NEL MENU' UTENTE. Ordine CF voce 16.** Il
    // fondatore ha fatto togliere dalle Impostazioni la sezione "Privacy e
    // dati", perche' il menu' utente ne aveva gia' una col nome quasi
    // identico e la stessa icona. La via c'e' ancora, e sta in un posto
    // solo: quello che la licenza pretende e' che sia raggiungibile.
    final menu =
        File('lib/features/account/account_screen.dart').readAsStringSync();
    expect(menu.contains('PrivacyEPermessiScreen.route()'), isTrue,
        reason: 'nessuna riga del menu\' utente porta al sotto menu\', quindi '
            'l\'attribuzione non e\' piu\' raggiungibile');
    final sotto = File('lib/features/settings/privacy_e_permessi_screen.dart')
        .readAsStringSync();
    expect(sotto.contains('fontiDeiDati'), isTrue,
        reason: 'il sotto menu\' non mostra l\'elenco vero, quindi mostrerebbe '
            'una seconda copia scritta a mano');
  });
}
