import 'dart:io';
import 'dart:math';

import 'package:esoteric_circle/core/arts/art_catalog.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/horoscope/horoscope.dart';
import 'package:esoteric_circle/core/horoscope/horoscope_data.dart';
import 'package:esoteric_circle/core/responsi/anatomia_del_responso.dart';
import 'package:esoteric_circle/core/responsi/confine_del_responso.dart';
import 'package:esoteric_circle/core/responsi/legge_del_responso.dart';
import 'package:esoteric_circle/core/rituals/daily_rituals.dart';
import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:esoteric_circle/core/rituals/rune_presage.dart';
import 'package:esoteric_circle/core/tarot/tarot_reading.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread.dart';
import 'package:esoteric_circle/core/tarot/tarot_topic.dart';
import 'package:esoteric_circle/services/ai/maestro_persona.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:flutter_test/flutter_test.dart';

/// IL CONFINE, LA LEGGE E L'ANATOMIA. Ordine S voci 15, 16 e 17.
///
/// **Il confine va presidiato proprio adesso**, perche' il registro dei responsi
/// diventa molto piu' diretto: si parla in seconda persona, si indica un'azione.
/// Un registro diretto avvicina il confine, e un confine lasciato al buon senso
/// di chi scrive la prossima riga di corpus e' un confine che prima o poi
/// qualcuno attraversa senza accorgersene.
///
/// **LE PROVE ENUMERANO I RESPONSI COMPOSTI, non le costanti.** Un corpus e'
/// fatto di pezzi che si uniscono a runtime: una previsione certa puo' nascere
/// dall'unione di due pezzi innocenti, e guardare i mattoni non la vedrebbe.
void main() {
  /// La stessa battuta della voce S.18, che e' quella dichiarata.
  const giorniDellAnno = 366;
  const semiDelleGettate = 60;

  Map<String, List<String>> tuttiIResponsi() {
    final tutto = <String, List<String>>{};
    for (final gettata in gettate) {
      tutto['Rune, presagio «${gettata.id}»'] = [
        for (var seme = 0; seme < semiDelleGettate; seme++)
          RunePresagio.componi(RuneCast.getta(gettata, random: Random(seme))),
      ];
    }
    final tarocchi = <String>[];
    for (final argomento in TarotTopic.values) {
      for (var seme = 0; seme < 8; seme++) {
        final lettura =
            TarotReading.of(TarotSpread.draw(seed: seme), argomento);
        tarocchi
          ..add(lettura.sintesi)
          ..add(lettura.consiglio)
          ..add(lettura.domanda);
        for (final p in lettura.posizioni) {
          tarocchi.add(p.testo);
        }
      }
    }
    tutto['Tarocchi, tutte le bolle'] = tarocchi;
    final oroscopo = <String>[];
    for (final dominio in HoroscopeDomain.values) {
      for (final segno in Zodiac.values) {
        for (var giorno = 1; giorno <= giorniDellAnno; giorno += 7) {
          oroscopo.add(Horoscope.cardFor(
            sign: segno,
            dayOfYear: giorno,
            year: 2026,
            domain: dominio,
          ).text);
        }
      }
    }
    tutto['Oroscopo, le quattro schede'] = oroscopo;
    final giornalieri = <String>[];
    for (var giorno = 0; giorno < giorniDellAnno; giorno++) {
      final quando = DateTime(2026, 1, 1).add(Duration(days: giorno));
      giornalieri
        ..add(DailyRituals.dayOracle(quando))
        ..add(DailyRituals.nightMessage(quando))
        ..add(DailyRituals.dawnMessage(quando));
    }
    tutto['Riti del giorno, le righe'] = giornalieri;
    return tutto;
  }

  test('nessun responso del corpus supera il confine', () {
    final tutto = tuttiIResponsi();
    final fuori = <String>[];
    var quanti = 0;
    for (final voce in tutto.entries) {
      for (final testo in voce.value) {
        quanti++;
        final violazioni = ConfineDelResponso.violazioni(testo);
        for (final v in violazioni) {
          fuori.add('${voce.key} -> $v');
        }
      }
    }
    // ignore: avoid_print
    print('CONFINE: $quanti responsi composti e guardati, '
        '${fuori.length} violazioni');
    expect(quanti, greaterThan(1000),
        reason: 'la battuta e\' troppo piccola: con $quanti responsi questa '
            'prova non sta guardando il corpus');
    expect(fuori, isEmpty,
        reason: 'questi responsi superano il confine:\n${fuori.take(20).join("\n")}');
  });

  test('il confine RICONOSCE cio\' che deve riconoscere', () {
    // **Una guardia che non ha mai visto un colpevole non e' una guardia.** Qui
    // si mostrano al confine le frasi dell'ordine, quella ammessa e quella
    // vietata, e si pretende che sappia distinguerle.
    final ammessa = ConfineDelResponso.violazioni(
        'questa runa ti chiede di rimandare la decisione di qualche giorno');
    expect(ammessa, isEmpty,
        reason: 'il confine accusa una frase che l\'ordine dichiara AMMESSA: '
            '$ammessa');

    final vietata = ConfineDelResponso.violazioni(
        'nei prossimi giorni perderai il lavoro');
    expect(vietata, isNotEmpty,
        reason: 'il confine non riconosce "perderai", che e\' la frase che '
            'l\'ordine porta come esempio di cio\' che non si puo\' dire');

    for (final caso in const [
      'ti dico che guarirai presto',
      'una malattia ti aspetta',
      'sicuramente arrivera\' il momento giusto',
      'e\' certo che cambierai casa',
    ]) {
      expect(ConfineDelResponso.violazioni(caso), isNotEmpty,
          reason: 'il confine lascia passare «$caso»');
    }
  });

  test('la legge e il confine arrivano al modello da un punto solo', () {
    // **Le istruzioni di sistema non riscrivono le regole con parole loro.** Due
    // copie della stessa regola divergono al primo ritocco, e da quel momento il
    // corpus e il modello obbediscono a due leggi diverse.
    for (final maestro in Maestro.values) {
      final istruzioni = MaestroPersona.systemInstruction(
        maestro: maestro,
        profile: UserProfile(),
        memory: const MaestroMemory(),
      );
      expect(istruzioni, contains(LeggeDelResponso.primo),
          reason: 'le istruzioni di ${maestro.name} non portano la legge del '
              'responso');
      expect(istruzioni, contains(ConfineDelResponso.nonSiPuoMai.first),
          reason: 'le istruzioni di ${maestro.name} non portano il confine');
      // UNA VOLTA SOLA: due copie sono due regole.
      final quanteVolte =
          LeggeDelResponso.primo.allMatches(istruzioni).length;
      expect(quanteVolte, 1,
          reason: 'la legge del responso compare $quanteVolte volte nelle '
              'istruzioni di ${maestro.name}: una regola scritta due volte e\' '
              'due regole');
    }
  });

  test('il disclaimer e\' quello gia\' in uso, e non uno nuovo', () {
    // Ordine S voce 17: ogni responso porta il disclaimer GIA' in uso. Il
    // confine non ne scrive un secondo: dichiara dove vive quello vero.
    expect(ConfineDelResponso.doveViveIlDisclaimer,
        'ArtCatalog.disclaimerCornice');
    expect(ArtCatalog.disclaimerCornice, contains('non cura medica'));
    expect(ArtCatalog.disclaimerCornice, contains('previsione certa'));
    // E il confine non porta un testo di disclaimer suo: se lo portasse,
    // sarebbero due promesse diverse sulla stessa cosa.
    final sorgente =
        File('lib/core/responsi/confine_del_responso.dart').readAsStringSync();
    expect(sorgente.contains('Cornice di intrattenimento'), isFalse,
        reason: 'il confine si e\' scritto un disclaimer suo: quello dell\'app '
            'e\' uno solo');
  });

  test('l\'anatomia ha quattro parti, e la tradizione non sta nel responso', () {
    expect(ParteDelResponso.values.length, 4);
    expect(ParteDelResponso.nelResponso.length, 3,
        reason: 'il responso porta tre parti: la tradizione scende nel pannello '
            'delle fonti, e ci sta gia\'');
    expect(ParteDelResponso.tradizione.dentroIlResponso, isFalse);
    // L'ORDINE E' LA FORMA DELL'OGGETTO: chi ha un Responso non puo' mettere il
    // simbolo per primo nemmeno volendo.
    expect(
        ParteDelResponso.nelResponso.map((p) => p.numero).toList(), [1, 2, 3]);
    const responso = Responso(
      risposta: 'La lettura vede una soglia.',
      cosaPuoiFare: 'Scrivi la decisione e rileggila domani.',
      daDoveViene: 'Lo dice Uruz, che parla di forza da incanalare.',
    );
    expect(responso.eIntero, isTrue);
    final parole = responso.inParole;
    expect(parole.indexOf('soglia'), lessThan(parole.indexOf('Uruz')),
        reason: 'il simbolo compare prima della risposta: e\' esattamente cio\' '
            'che la legge vieta');
    expect(responso.parte(ParteDelResponso.tradizione), isEmpty,
        reason: 'il responso ha cominciato a portarsi la tradizione dentro');
  });

  test('il confine arriva al MODELLO, e in un punto solo', () {
    // **PUNTO 5 DELLA DECISIONE D5.** Prima di questa riga il confine viveva solo
    // nel corpus deterministico e nelle prove che lo setacciano: al modello non lo
    // diceva nessuno. Sono le due porte della stessa arte con due confini
    // diversi, e la persona lo vedrebbe, perche' il registro cambierebbe a meta'
    // schermata.
    //
    // **E DEVE ESSERCI UNA VOLTA SOLA.** Due copie della stessa regola dentro la
    // stessa istruzione divergono al primo ritocco, e da quel momento nessuno sa
    // quale delle due obbedisce il modello.
    final apertura = ConfineDelResponso.perIlModello.split(':').first;
    for (final maestro in Maestro.values) {
      final istruzione = MaestroPersona.systemInstruction(
        maestro: maestro,
        profile: UserProfile.empty,
        memory: MaestroMemory.empty,
      );
      final quante = istruzione.split(apertura).length - 1;
      expect(quante, 1,
          reason: 'il confine compare $quante volte nell\'istruzione di '
              '${maestro.id}: deve comparire una volta sola');
      // E ci sono anche i divieti veri, non solo il titolo.
      for (final r in ConfineDelResponso.nonSiPuoMai) {
        expect(istruzione, contains(r),
            reason: 'manca il divieto "$r" nell\'istruzione di ${maestro.id}');
      }
    }

    // Il consulto passa dalla stessa porta: se un giorno smettesse, questa riga
    // cadrebbe invece di lasciare una superficie senza confine.
    final consulto = MaestroPersona.consultInstruction(
      maestro: Maestro.caligo,
      profile: UserProfile.empty,
      memory: MaestroMemory.empty,
    );
    expect(consulto.split(apertura).length - 1, 1);
  });
}
