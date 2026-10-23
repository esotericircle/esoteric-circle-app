import 'package:esoteric_circle/core/archetypes/archetype.dart';
import 'package:esoteric_circle/core/archetypes/archetype_history.dart';
import 'package:esoteric_circle/core/archetypes/archetype_sky.dart';
import 'package:esoteric_circle/core/archetypes/archetype_transits.dart';
import 'package:esoteric_circle/core/archetypes/lettura_del_giorno.dart';
import 'package:esoteric_circle/core/archetypes/ripetizione_del_test.dart';
import 'package:flutter_test/flutter_test.dart';

/// L'ARCHETIPO SI RILEGGE, E SI RIFA' DOPO TRE MESI. Ordine AO voce 06.
///
/// **Il difetto, dal collaudo della 2182**: il Test Archetipo riaperto non
/// permetteva di fare piu' nulla. Chi lo aveva gia' fatto trovava una soglia
/// che gli chiedeva di ricominciare, e nient'altro.
///
/// **Le tre cose di questa voce, e nessuna tocca la carta natale**:
///   1. chi lo ha gia' fatto vede il suo EMBLEMA e la LETTURA DI OGGI,
///      composta dai transiti correnti e diversa ogni giorno;
///   2. si puo' RIFARE dopo tre mesi, col tempo e la data dichiarati;
///   3. dal Passaporto l'emblema si tocca e apre la stessa scena.
///
/// Qui stanno le prove del CUORE, che non ha bisogno di una schermata: la
/// lettura del giorno e la regola dei tre mesi. La parte a schermo, cioe' che
/// la soglia mostri davvero l'emblema e che l'emblema del Passaporto apra,
/// vive in `test/l_archetipo_si_apre_dal_passport_test.dart`.
void main() {
  group('la lettura del giorno', () {
    test('cambia col cielo, e non con l\'ora', () {
      // **DUE GIORNI DIVERSI DEVONO DIRE COSE DIVERSE**, altrimenti la
      // "lettura di oggi" e' una frase fissa con un nome ingannevole. Si
      // cercano due giorni in cui i pianeti attivi differiscono, e non si
      // presume che due date qualunque bastino.
      final letture = <String, String>{};
      for (var i = 0; i < 40; i++) {
        final giorno = DateTime(2026, 8, 1 + i);
        final lettura = LetturaDelGiorno.per(
          Archetype.mago,
          ArchetypeSky.pianetiDelGiorno(giorno),
          quando: giorno,
        );
        letture['${giorno.month}-${giorno.day}'] = lettura.righe.join(' | ');
      }
      final diverse = letture.values.toSet();
      // ignore: avoid_print
      print('ORDINE AO VOCE 06: su 40 giorni, letture diverse '
          '${diverse.length}');
      expect(diverse.length, greaterThan(1),
          reason: 'in quaranta giorni la lettura del Mago non e\' mai '
              'cambiata: non e\' una lettura di oggi, e\' una frase fissa');

      // E NON cambia con l'ora: due momenti dello stesso giorno dicono la
      // stessa cosa, come promette la modalita' legata ai transiti.
      final mattina = LetturaDelGiorno.per(
        Archetype.mago,
        ArchetypeSky.pianetiDelGiorno(DateTime(2026, 8, 18, 7)),
        quando: DateTime(2026, 8, 18, 7),
      );
      final sera = LetturaDelGiorno.per(
        Archetype.mago,
        ArchetypeSky.pianetiDelGiorno(DateTime(2026, 8, 18, 23)),
        quando: DateTime(2026, 8, 18, 23),
      );
      expect(mattina.righe, sera.righe,
          reason: 'la lettura cambia dentro lo stesso giorno');
    });

    test('parla dell\'archetipo giusto, e solo dei pianeti che lo toccano', () {
      // Il cielo pieno: tutti e dieci i pianeti attivi.
      final tutti = ArchetypeTransits.tabella.keys.toSet();
      final lettura = LetturaDelGiorno.per(Archetype.amante, tutti);
      // ignore: avoid_print
      print('ORDINE AO VOCE 06: col cielo pieno, l\'Amante ha '
          '${lettura.pianetiInGioco.length} pianeti: '
          '${lettura.pianetiInGioco.map((p) => p.nome).toList()}');
      for (final pianeta in lettura.pianetiInGioco) {
        expect(ArchetypeTransits.tabella[pianeta], contains(Archetype.amante),
            reason: '${pianeta.nome} non tocca l\'Amante e compare lo stesso');
      }
      // Le righe sono quelle dei pianeti PIU' la riga della Luna, che c'e'
      // sempre: e' il secondo strato, dichiarato nella lettura.
      expect(lettura.righe, hasLength(lettura.pianetiInGioco.length + 1));
      for (final riga in lettura.righe) {
        expect(riga, contains(Archetype.amante.nome),
            reason: 'una riga non nomina l\'archetipo di cui parla: $riga');
      }
    });

    test('quando il cielo guarda altrove resta la Luna, e non un vuoto', () {
      final lettura = LetturaDelGiorno.per(Archetype.eroe, const {},
          quando: DateTime(2026, 8, 18));
      // ignore: avoid_print
      print('ORDINE AO VOCE 06: cielo vuoto -> "${lettura.righe.first}"');
      expect(lettura.ilCieloGuardaAltrove, isTrue);
      expect(lettura.righe, hasLength(1),
          reason: 'senza pianeti resta UNA riga vera, quella della Luna: non '
              'zero, e non tre inventate su pianeti che non sappiamo '
              'calcolare');
      expect(lettura.righe.first, contains(Archetype.eroe.nome));
      expect(lettura.righe.first, contains('Luna'));
    });

    test('la cornice della sincronicita\' resta quella del test', () {
      expect(LetturaDelGiorno.cornice, ArchetypeTransits.corniceSincronicita,
          reason: 'la lettura si e\' scritta una cornice sua: sarebbe la '
              'seconda verita\' su cosa il cielo fa e non fa');
    });
  });

  group('la ripetizione dopo tre mesi', () {
    test('il primo test non aspetta nessuno', () {
      expect(
          RipetizioneDelTest.siPuoRifare(
              ultimo: null, adesso: DateTime(2026, 8, 18)),
          isTrue);
      expect(
          RipetizioneDelTest.giorniAncora(
              ultimo: null, adesso: DateTime(2026, 8, 18)),
          0);
    });

    test('il giorno dopo il test non si rifa\', e la data si dichiara', () {
      final ultimo = DateTime(2026, 8, 18, 15, 30);
      final domani = DateTime(2026, 8, 19, 9);
      expect(RipetizioneDelTest.siPuoRifare(ultimo: ultimo, adesso: domani),
          isFalse,
          reason: 'il test si rifaceva il giorno dopo: e\' la slot machine '
              'che la decisione del 18 agosto ha escluso');
      final frase = RipetizioneDelTest.frase(ultimo: ultimo, adesso: domani);
      // ignore: avoid_print
      print('ORDINE AO VOCE 06: il giorno dopo si legge "$frase"');
      expect(frase, contains('16 novembre 2026'),
          reason: 'la frase non porta la data vera: "$frase"');
      expect(frase, contains('89'),
          reason: 'la frase non dice quanti giorni mancano: "$frase"');
    });

    test('al novantesimo giorno si puo\', e la frase lo dice', () {
      final ultimo = DateTime(2026, 8, 18, 15, 30);
      final ilGiorno = RipetizioneDelTest.quandoSiPotra(ultimo);
      // ignore: avoid_print
      print('ORDINE AO VOCE 06: si potra\' dal $ilGiorno');
      expect(RipetizioneDelTest.siPuoRifare(ultimo: ultimo, adesso: ilGiorno),
          isTrue);
      // **LA MATTINA DEL GIORNO BUONO, e non e' un dettaglio.** Chi apre
      // l'app alle nove del giorno in cui scade l'attesa deve leggere che
      // puo' farlo, non "mancano ancora sedici ore": i giorni si contano
      // civili, come li conta una persona.
      final mattina = DateTime(ilGiorno.year, ilGiorno.month, ilGiorno.day, 9);
      expect(
          RipetizioneDelTest.giorniAncora(ultimo: ultimo, adesso: mattina), 0,
          reason: 'la mattina del giorno buono l\'attesa non e\' ancora zero');
    });

    test('tre mesi sono novanta giorni, dichiarati', () {
      expect(RipetizioneDelTest.attesa, const Duration(days: 90));
    });
  });

  test('l\'esito salvato porta la data, che e\' cio\' su cui si conta', () {
    // Senza la data dell'ultimo test la regola dei tre mesi non avrebbe su
    // cosa poggiare: questa prova la lega al dato che gia' esiste.
    final esito = ArchetypeEsito(
      quando: DateTime(2026, 8, 18),
      percentuali: const {Archetype.mago: 100},
      dominante: Archetype.mago,
      secondo: null,
    );
    expect(esito.quando, DateTime(2026, 8, 18));
  });
}
