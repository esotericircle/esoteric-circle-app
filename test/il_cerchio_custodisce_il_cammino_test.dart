import 'dart:io';

import 'package:esoteric_circle/core/cammino/cammino_da_custodire.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/core/identity/birth_place.dart';
import 'package:flutter_test/flutter_test.dart';

/// IL CERCHIO CUSTODISCE IL CAMMINO, NON SOLO IL DENARO. Ordine AP voce 01.
///
/// **Il fatto che apre quest'ordine**, misurato da Mauro sul telefono vero:
/// disinstallata e reinstallata l'app, rientrato con lo stesso account
/// Google, il borsellino e' tornato solo visitando il Passport e i traguardi
/// accesi non sono tornati affatto. Il Cerchio ricordava il denaro e non il
/// cammino.
///
/// **Cosa prova questo file, e cosa NON prova.** Qui si guarda il lato
/// telefono: che esista una forma con cui il cammino viaggia, che sappia
/// andare e tornare senza perdere niente per strada, e che viaggi dentro la
/// chiamata che gia' parte invece di aprirsi un canale suo. La FUSIONE non si
/// prova qui perche' non vive qui: sta sul server, in
/// `functions/src/cammino.ts`, ed e' provata da `functions/src/cammino.test.ts`
/// con `npm test`. Due implementazioni della stessa regola sarebbero due
/// regole.
void main() {
  test('il cammino va e torna senza perdere niente', () {
    final partenza = CamminoDaCustodire(
      identita: IdentitaDaCustodire(
        nome: 'Sofia',
        giorno: DateTime(1990, 4, 12),
        ora: '07:30',
        luogo: 'Roma',
        latitudine: 41.9,
        longitudine: 12.5,
        fuso: 'Europe/Rome',
        scarto: 60,
      ),
      gesti: const {'stesa': 5, 'gettata': 2},
      giorni: const {'stesa': 3},
      oreGiuste: const {'alba@dawn': 1},
      serie: const {'alba': 4},
      sigilli: {'med_1': DateTime(2026, 8, 1, 10)},
      archetipoDominante: 'mago',
      archetipoQuando: DateTime(2026, 5, 1, 9),
      artiPreferite: const ['horoscope', 'tarot_spread_three'],
      primoGiorno: DateTime(2026, 7, 1, 8),
      ultimoGiorno: DateTime(2026, 8, 12, 22),
    );

    final tornato = CamminoDaCustodire.daMappa(partenza.aMappa());
    // ignore: avoid_print
    print('ORDINE AP VOCE 01: partito con ${partenza.gesti.length} gesti e '
        '${partenza.sigilli.length} sigilli, tornato con '
        '${tornato?.gesti.length} e ${tornato?.sigilli.length}');
    expect(tornato, isNotNull);
    expect(tornato!.gesti, partenza.gesti);
    expect(tornato.giorni, partenza.giorni);
    expect(tornato.oreGiuste, partenza.oreGiuste);
    expect(tornato.serie, partenza.serie);
    expect(tornato.sigilli.keys, partenza.sigilli.keys);
    expect(tornato.sigilli['med_1'], partenza.sigilli['med_1']);
    expect(tornato.archetipoDominante, 'mago');
    expect(tornato.archetipoQuando, partenza.archetipoQuando);
    expect(tornato.artiPreferite, partenza.artiPreferite);
    expect(tornato.identita?.nome, 'Sofia');
    expect(tornato.identita?.ora, '07:30');
    expect(tornato.identita?.luogo, 'Roma');
  });

  test('l\'identita\' di nascita torna a essere quella dell\'app', () {
    // **LA CARTA NATALE NON VIAGGIA, e non e' una dimenticanza**: nasce da
    // questi dati ogni volta uguale, e custodirla sarebbe una seconda verita'
    // sullo stesso cielo. Quello che deve tornare intero e' cio' che la
    // persona ha DATO.
    final originale = BirthIdentity.fromParts(
      birthDate: DateTime(1990, 4, 12),
      birthHour: 7,
      birthMinute: 30,
      birthPlace: const BirthPlace(
        city: 'Roma',
        latitude: 41.9,
        longitude: 12.5,
        timeZoneId: 'Europe/Rome',
        utcOffsetMinutes: 60,
      ),
    );
    final custodita = IdentitaDaCustodire.da(originale, nome: 'Sofia');
    expect(custodita, isNotNull);
    final rifatta = IdentitaDaCustodire.daMappa(custodita!.aMappa())
        ?.aBirthIdentity();
    // ignore: avoid_print
    print('ORDINE AP VOCE 01: nascita ${originale.birthMoment} tornata come '
        '${rifatta?.birthMoment}, ora nota ${rifatta?.hasBirthTime}');
    expect(rifatta, isNotNull);
    expect(rifatta!.birthMoment, originale.birthMoment);
    expect(rifatta.hasBirthTime, isTrue);
    expect(rifatta.birthPlace?.city, 'Roma');
    expect(rifatta.birthPlace?.latitude, 41.9);
  });

  test('senza ora di nascita non se ne inventa una', () {
    final senzaOra = BirthIdentity.fromParts(birthDate: DateTime(1990, 4, 12));
    final custodita = IdentitaDaCustodire.da(senzaOra);
    expect(custodita?.ora, isNull,
        reason: 'l\'ora e\' comparsa dal nulla: e\' la distinzione che decide '
            'se l\'Ascendente si puo\' calcolare');
    final rifatta =
        IdentitaDaCustodire.daMappa(custodita!.aMappa())?.aBirthIdentity();
    expect(rifatta?.hasBirthTime, isFalse);
  });

  test('l\'identita\' d\'esempio non si custodisce mai', () {
    // Custodire il dato d'esempio vorrebbe dire scrivere nel Cerchio una
    // nascita che non e' di nessuno, e ritrovarsela addosso al rientro.
    expect(IdentitaDaCustodire.da(BirthIdentity.example), isNull);
  });

  test('una risposta rotta non porta niente dentro', () {
    expect(CamminoDaCustodire.daMappa(null), isNull);
    expect(CamminoDaCustodire.daMappa('tutto il cammino'), isNull);
    final storto = CamminoDaCustodire.daMappa({
      'gesti': {'stesa': 'molte', 'rune': -3, 'buono': 4},
      'sigilli': {'med_1': 'non una data'},
      'artiPreferite': ['horoscope', 42],
    });
    expect(storto?.gesti, {'buono': 4},
        reason: 'un conteggio che non e\' un numero e\' entrato lo stesso');
    expect(storto?.sigilli, isEmpty);
    expect(storto?.artiPreferite, ['horoscope']);
  });

  test('un cammino vuoto si riconosce, e non si manda', () {
    expect(const CamminoDaCustodire().eVuoto, isTrue);
    expect(
        const CamminoDaCustodire(gesti: {'stesa': 1}).eVuoto, isFalse);
  });

  test('IL CAMMINO VIAGGIA DENTRO LA CHIAMATA CHE GIA\' PARTE', () {
    // **L'ENUMERAZIONE, e guarda due cose.** La prima: la porta del Cerchio
    // non ha guadagnato un metodo nuovo per il cammino, perche' un secondo
    // canale sullo stesso momento e' la seconda porta sullo stesso dato. La
    // seconda: sul server non e' nata una callable nuova, e le sei restano
    // sei.
    // **GLI SPAZI SI APPIATTISCONO PRIMA DI GUARDARE.** La pretesa e' che il
    // cammino viaggi dentro `stato`, non che la firma stia su una riga sola:
    // quando l'ordine AR voce 06 le ha aggiunto l'azzeramento, il
    // formattatore e' andato a capo e questa riga e' caduta senza che niente
    // di vero fosse cambiato. E' lo stesso difetto gia' visto nell'ordine AQ.
    final porta = File('lib/services/server/porta_del_cerchio.dart')
        .readAsStringSync()
        .replaceAll(RegExp(r'\s+'), '');
    expect(porta.contains('Future<StatoDelCerchio?>stato({'), isTrue,
        reason: 'lo stato non porta piu\' il cammino con se\'');
    for (final inventata in const [
      'custodisciIlCammino',
      'salvaIlCammino',
      'leggiIlCammino',
    ]) {
      expect(porta.contains(inventata), isFalse,
          reason: 'e\' comparso un secondo canale per il cammino: $inventata');
    }

    final callable = <String>[];
    for (final f in const [
      'functions/src/cerchio.ts',
      'functions/src/index.ts',
      // **BI.04**: il secondo fattore vive in un file suo, e la guardia lo
      // guarda, o una callable nata li' sfuggirebbe al conto.
      'functions/src/secondo_fattore.ts',
    ]) {
      final testo = File(f).readAsStringSync();
      for (final riga in testo.split('\n')) {
        final trovato =
            RegExp(r'^export const (\w+) = onCall').firstMatch(riga.trim());
        if (trovato != null) callable.add(trovato.group(1)!);
      }
    }
    // ignore: avoid_print
    print('ORDINE AP VOCE 01: le callable sono ${callable.length}: $callable');
    // **DA SEI A OTTO. Ordine BC voce 02**, e si dichiara qui come la prova
    // chiede. Le due nuove sono `chiediLOblio`, che segna la data della
    // cancellazione invece di eseguirla, e `annullaLOblio`, che e' la meta'
    // che rendeva i trenta giorni di ripensamento una promessa. **E POI I
    // TRENTA GIORNI SONO STATI ABOLITI, ordine BE voce 07**: chiediLOblio e
    // annullaLOblio sono uscite, ed e' entrata azzeraIDatiDelCerchio, che
    // porta l'azzeramento dei dati anche sul server (era il ritorno dei 270
    // Eos visto dal fondatore). Il conto scende da otto a sette, e ognuna
    // delle sette ha il suo perche' nel manifesto dell'ordine BE.
    // **DA SETTE A NOVE, ordine BI**, e si dichiara qui come la prova
    // chiede. Le due nuove: `esisteIlCerchio` (voce 01, la sonda della
    // porta d'ingresso: il fondatore vuole che la porta controlli l'email
    // e comunichi, invece di creare account in silenzio; col tetto di
    // dieci sonde al giorno per account) e `secondoFattore` (voce 04, il
    // codice numerico via email chiesto dal fondatore, una callable sola
    // con le due operazioni manda e verifica).
    expect(callable.length, 9,
        reason: 'le callable non sono piu\' nove: $callable. Se ne serviva '
            'una nuova andava dichiarata e motivata nel rapporto');
  });

  test('la forma dice la sua versione, per chi la leggera\' domani', () {
    final server = File('functions/src/cammino.ts').readAsStringSync();
    expect(server.contains('VERSIONE_DEL_CAMMINO'), isTrue,
        reason: 'la forma non porta una versione: chi legge un cammino '
            'scritto da un\'app piu\' nuova non sapra\' quanto e\' vecchio '
            'cio\' che ha in mano');
  });
}
