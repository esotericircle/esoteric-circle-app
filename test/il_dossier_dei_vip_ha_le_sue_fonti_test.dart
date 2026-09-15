import 'package:esoteric_circle/core/astro/data_italiana.dart';
import 'package:esoteric_circle/core/astro/night_sky.dart';
import 'package:esoteric_circle/core/synastry/vip_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

/// IL DOSSIER DEI CINQUANTA HA LE SUE FONTI. Ordine BO voce 01.
///
/// **Il vincolo V4 dell'ordine non e' una formalita': e' cio' che separa un
/// dato da una congettura.** Finche' del VIP si sapeva solo il segno solare
/// non c'era niente da verificare; adesso il catalogo dichiara luogo, citta',
/// stato in vita ed esposizione, e ognuno di questi puo' essere inventato da
/// chi aggiunge una riga di fretta. Questa prova legge il catalogo e cade se
/// un campo compilato non porta la sua fonte, o se lo stato in vita manca.
void main() {
  test('cinquanta su cinquanta dichiarano se la persona e\' in vita', () {
    expect(VipCatalog.vips, hasLength(50));
    // Lo stato in vita e' obbligatorio nel costruttore, quindi non puo'
    // mancare per distrazione; cio' che questa riga difende e' che la sua
    // FONTE ci sia, perche' quella si puo' dimenticare.
    final senzaFonte = [
      for (final v in VipCatalog.vips)
        if (!v.fonti.containsKey(CampoDelVip.statoInVita)) v.name,
    ];
    expect(senzaFonte, isEmpty,
        reason: 'questi VIP dichiarano se sono in vita senza dire da dove '
            'viene il dato: $senzaFonte');
  });

  test('ogni campo compilato porta la sua fonte', () {
    final orfani = <String>[];
    for (final v in VipCatalog.vips) {
      for (final campo in v.campiCompilati) {
        if (!v.fonti.containsKey(campo)) {
          orfani.add('${v.name}: ${campo.name}');
        }
      }
    }
    expect(orfani, isEmpty,
        reason: 'questi campi sono compilati e non dicono da dove vengono, '
            'cioe\' sono indistinguibili da una congettura:\n'
            '${orfani.join("\n")}');
  });

  test('nessuna fonte dichiarata per un campo che non c\'e\'', () {
    // Il verso opposto, ed e' altrettanto sporco: una fonte che cita un campo
    // vuoto racconta un dato che non esiste.
    final vuoti = <String>[];
    for (final v in VipCatalog.vips) {
      for (final campo in v.fonti.keys) {
        if (!v.campiCompilati.contains(campo)) {
          vuoti.add('${v.name}: ${campo.name}');
        }
      }
    }
    expect(vuoti, isEmpty,
        reason: 'questi VIP citano una fonte per un campo vuoto:\n'
            '${vuoti.join("\n")}');
  });

  test('i due scomparsi noti risultano tali, con il loro anno', () {
    final armani = VipCatalog.conNome('Giorgio Armani');
    final jobs = VipCatalog.conNome('Steve Jobs');
    expect(armani, isNotNull);
    expect(jobs, isNotNull);
    expect(armani!.eScomparso, isTrue,
        reason: 'l\'app promette un incontro a chi sceglie Giorgio Armani');
    expect(jobs!.eScomparso, isTrue,
        reason: 'l\'app promette un incontro a chi sceglie Steve Jobs');
    expect(armani.annoDellaScomparsa, isNotNull);
    expect(jobs.annoDellaScomparsa, isNotNull);
    // E chi e' in vita non porta un anno di scomparsa.
    for (final v in VipCatalog.vips) {
      if (!v.eScomparso) {
        expect(v.annoDellaScomparsa, isNull, reason: v.name);
      }
    }
  });

  test('il luogo di nascita c\'e\' per tutti, con coordinate possibili', () {
    for (final v in VipCatalog.vips) {
      final l = v.luogoDiNascita;
      expect(l, isNotNull, reason: '${v.name} non ha luogo di nascita');
      expect(l!.latitudine, inInclusiveRange(-90, 90), reason: v.name);
      expect(l.longitudine, inInclusiveRange(-180, 180), reason: v.name);
      expect(l.nome, isNotEmpty, reason: v.name);
      expect(l.nazione, isNotEmpty, reason: v.name);
    }
  });

  test('la data del dossier e\' quella che il segno promette', () {
    // **La prova che il dossier non ha spostato nessuna nascita.** La data
    // viveva come stringa e adesso vive come tre numeri: se la conversione
    // avesse sbagliato anche un solo giorno, il segno solare calcolato dalla
    // data non combacerebbe piu' con quello dichiarato.
    for (final v in VipCatalog.vips) {
      expect(NightSky.sunSign(v.momentoDiNascita), v.sign,
          reason: '${v.name}: la data ${v.note} non da\' il segno '
              '${v.sign.name} dichiarato nel catalogo');
    }
  });

  test('la data per esteso passa dalla porta comune', () {
    final v = VipCatalog.conNome('Angelina Jolie')!;
    expect(v.note, dataItalianaEstesa(DateTime(1975, 6, 4)));
    expect(v.note, '4 giugno 1975');
  });

  test('l\'ora non nota non finge di essere nota', () {
    // Oggi sono cinquanta su cinquanta, e sta scritto nel manifesto perche'.
    // Cio' che questa prova difende non e' il numero ma la coerenza: un'ora
    // dichiarata ignota non deve portare cifre, e un'ora con cifre deve
    // portare una fonte.
    for (final v in VipCatalog.vips) {
      if (!v.ora.eNota) {
        expect(v.ora.ore, isNull, reason: '${v.name} ha un\'ora e la nega');
        expect(v.fonti.containsKey(CampoDelVip.ora), isFalse,
            reason: '${v.name} cita una fonte per un\'ora che non ha');
        // E il momento si ancora a mezzogiorno, come per chi non ha dato la
        // propria ora.
        expect(v.momentoDiNascita.hour, 12, reason: v.name);
      } else {
        expect(v.fonti[CampoDelVip.ora], isNotNull, reason: v.name);
        expect(v.ora.affidabilita, isNot(AffidabilitaDellOra.ignota),
            reason: v.name);
      }
    }
  });

  test('la citta\' di oggi c\'e\' per chi la dichiara, e mai per gli scomparsi',
      () {
    final conCitta = VipCatalog.vips.where((v) => v.luogoDiOggi != null);
    expect(conCitta.length, greaterThanOrEqualTo(20),
        reason: 'senza abbastanza citta\' note la voce BO.03 non avrebbe '
            'niente da misurare: se il numero scende, e\' perche\' qualcuno '
            'ha tolto dei dati, non perche\' la funzione e\' migliorata');
    for (final v in VipCatalog.vips) {
      if (v.eScomparso) {
        expect(v.luogoDiOggi, isNull,
            reason: '${v.name} non c\'e\' piu\' e il catalogo dice dove vive');
      }
    }
  });
}
