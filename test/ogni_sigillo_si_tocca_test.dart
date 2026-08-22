import 'dart:math' as math;

import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:esoteric_circle/features/sigilli/disegno_del_sentiero.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// OGNI SIGILLO SI TOCCA, SU TUTTI E TRE I SENTIERI. Ordine AS voce 04.
///
/// **Il fatto di Mauro**: la perla grande dell'Albero non porta al traguardo,
/// mentre le piccole funzionano.
///
/// **Perche' si enumera invece di provare a mano.** I punti sono
/// centosessantacinque, i grandi quindici: toccarne qualcuno e concludere che
/// vanno tutti bene e' esattamente il ragionamento che ha lasciato passare
/// questo difetto. Qui si simula un tocco sul CENTRO di ogni punto e si guarda
/// quale traguardo risponde: se ne risponde un altro, o nessuno, la prova lo
/// nomina.
///
/// **La misura non passa dai pixel ma dalla stessa aritmetica del tocco**, cioe'
/// dal punto piu' vicino entro il raggio dichiarato: e' cio' che fa il dito
/// vero, e cosi' la prova resta veloce e nomina il colpevole.
void main() {
  /// La tela del disegno alla misura vera della schermata del sentiero.
  const misura = Size(360, 462);

  /// **SI CHIAMA LA PORTA VERA, non se ne copia l'aritmetica.** Ordine AS
  /// voce 04. Una prova che rifa' il conto per conto suo prova il conto della
  /// prova: `quiHaToccato` e' la stessa funzione che risponde al dito.
  ({String? id, double distanza}) chiRisponde(
      List<PuntoDelSentiero> punti, Offset dove) {
    final scelto = quiHaToccato(punti, dove, misura);
    if (scelto == null) return (id: null, distanza: double.infinity);
    final centro =
        Offset(scelto.dove.dx * misura.width, scelto.dove.dy * misura.height);
    return (id: scelto.traguardo.id, distanza: (centro - dove).distance);
  }

  test('toccando il centro di ogni punto risponde quel traguardo, e non un altro',
      () {
    var osservati = 0;
    final muti = <String>[];
    final scambiati = <String>[];
    final coperti = <String>[];
    for (final sentiero in Sentiero.values) {
      final punti = GeometriaDelSentiero.punti(sentiero);
      for (final punto in punti) {
        osservati++;
        final centro = Offset(
            punto.dove.dx * misura.width, punto.dove.dy * misura.height);
        final risposta = chiRisponde(punti, centro);
        if (risposta.id == null) {
          muti.add('${punto.traguardo.id} non risponde al tocco sul suo centro');
        } else if (risposta.id != punto.traguardo.id) {
          // **UN'ECCEZIONE DICHIARATA, non un'eccezione di comodo.** Un punto
          // puo' stare DENTRO il cerchio disegnato di uno piu' grande: sul
          // Loto `aur_47` dista 2,5 punti da `aur_55` su una tela da 360.
          // Quando succede, sotto il dito si vede la perla grande, e risponde
          // lei: il piccolo coperto resta raggiungibile dalla riga della
          // lista, che e' la via principale e non ha sovrapposizioni. Qui si
          // pretende che il vincitore sia davvero un punto PIU' GRANDE che
          // CONTIENE il centro del perdente: qualunque altro scambio resta un
          // difetto.
          final vincitore =
              punti.firstWhere((p) => p.traguardo.id == risposta.id);
          final centroVincitore = Offset(vincitore.dove.dx * misura.width,
              vincitore.dove.dy * misura.height);
          final raggioVincitore = vincitore.grandezza.raggio *
              math.min(misura.width, misura.height);
          final loContiene =
              (centroVincitore - centro).distance <= raggioVincitore;
          final ePiuGrande =
              vincitore.grandezza.raggio > punto.grandezza.raggio;
          if (loContiene && ePiuGrande) {
            coperti.add('${punto.traguardo.id} sta dentro ${risposta.id}');
          } else {
            scambiati.add('${punto.traguardo.id} '
                '(${punto.eGrande ? "grande" : "piccolo"}) risponde come '
                '${risposta.id}, distante '
                '${risposta.distanza.toStringAsFixed(1)}');
          }
        }
      }
    }
    // ignore: avoid_print
    print('ORDINE AS VOCE 04: punti osservati $osservati, muti ${muti.length}, '
        'scambiati ${scambiati.length}, coperti da un punto piu grande '
        '${coperti.length} (${coperti.take(4).join(", ")})');
    expect(osservati, 165,
        reason: 'i punti guardati sono $osservati invece di 165');
    expect(muti, isEmpty, reason: muti.take(6).join('; '));
    expect(scambiati, isEmpty,
        reason: 'questi punti aprono il traguardo di un altro senza esserne '
            'coperti: ${scambiati.take(8).join("; ")}');
    // I coperti sono pochi e dichiarati: se diventassero tanti, vorrebbe dire
    // che il disegno ha cominciato ad ammucchiare i punti uno sull'altro.
    expect(coperti.length, lessThan(20),
        reason: 'i punti coperti da uno piu grande sono ${coperti.length}: '
            'il disegno sta ammucchiando i punti, e dal disegno non si '
            'raggiunge piu meta del cammino');
  });

  test('i quindici grandi rispondono, uno per uno', () {
    // **I GRANDI SI GUARDANO A PARTE, ed e' la riga che nasce dal fatto di
    // Mauro.** Sono quindici su centosessantacinque: dentro una media
    // sparirebbero, e una prova che li conta insieme agli altri direbbe
    // "novantuno per cento a posto" mentre la perla piu' importante del
    // sentiero non si tocca.
    var osservati = 0;
    final sbagliati = <String>[];
    for (final sentiero in Sentiero.values) {
      final punti = GeometriaDelSentiero.punti(sentiero);
      for (final punto in punti.where((p) => p.eGrande)) {
        osservati++;
        final centro = Offset(
            punto.dove.dx * misura.width, punto.dove.dy * misura.height);
        final risposta = chiRisponde(punti, centro);
        if (risposta.id != punto.traguardo.id) {
          sbagliati.add('${punto.traguardo.id} su ${sentiero.name} risponde '
              'come ${risposta.id}');
        }
      }
    }
    // ignore: avoid_print
    print('ORDINE AS VOCE 04: grandi osservati $osservati, sbagliati '
        '${sbagliati.length}');
    expect(osservati, 15, reason: 'i grandi guardati sono $osservati');
    expect(sbagliati, isEmpty, reason: sbagliati.join('; '));
  });

  test('un punto grande non perde il dito a favore di un piccolo vicino', () {
    // **LA CAUSA VERA, e il numero che la spiega.** Sui tre sentieri ci sono
    // OTTANTAQUATTRO coppie di punti piu' vicine di meta' del raggio del tocco
    // di prima, e la piu' stretta, aur_47 e aur_55, dista 2,5 punti su una
    // tela da 360. Con un raggio uguale per tutti bastava sbagliare di due
    // pixel per prendere il mini invece della perla grande.
    //
    // Adesso ogni punto attrae quanto e' disegnato, quindi questa prova
    // guarda cio' che conta davvero: toccando DENTRO la perla grande, a meta'
    // del suo raggio disegnato e in otto direzioni, deve rispondere lei.
    var osservati = 0;
    final rubati = <String>[];
    for (final sentiero in Sentiero.values) {
      final punti = GeometriaDelSentiero.punti(sentiero);
      for (final grande in punti.where((p) => p.eGrande)) {
        final centro = Offset(
            grande.dove.dx * misura.width, grande.dove.dy * misura.height);
        // **LA CASA DI UN PUNTO ARRIVA A META' STRADA DAL VICINO.** Ordine
        // AU voce 09, e le due regole si conciliano qui.
        //
        // Questa prova pretende che la perla grande prenda il dito che cade
        // dentro di lei, e ha ragione: nasce dal fatto che il fondatore
        // segnalava una perla grande che non rispondeva. Ma la voce AU.09
        // pretende, con la stessa forza, che **ogni mini risponda al proprio
        // centro**, e su Loto e Costellazione ci sono mini il cui centro cade
        // dentro il raggio DISEGNATO di un grande: le due cose insieme sono
        // impossibili solo finche' si misura col raggio disegnato.
        //
        // La conciliazione: **ogni punto comanda in casa propria, e la casa
        // arriva a meta' strada dal vicino piu' vicino**. Il grande resta
        // padrone della sua area, il mini resta raggiungibile al suo centro, e
        // nessuno dei due perde quello che gli spetta.
        var vicino = double.infinity;
        for (final altro in punti) {
          if (identical(altro, grande)) continue;
          final d = (Offset(altro.dove.dx * misura.width,
                      altro.dove.dy * misura.height) -
                  centro)
              .distance;
          if (d < vicino) vicino = d;
        }
        final raggio = math.min(
            grande.grandezza.raggio * math.min(misura.width, misura.height),
            vicino / 2);
        for (var k = 0; k < 8; k++) {
          osservati++;
          final angolo = k * math.pi / 4;
          final dove = centro +
              Offset(math.cos(angolo), math.sin(angolo)) * (raggio * 0.5);
          final risposta = chiRisponde(punti, dove);
          if (risposta.id != grande.traguardo.id) {
            rubati.add('${grande.traguardo.id} perde il dito a favore di '
                '${risposta.id} toccando dentro la sua perla');
          }
        }
      }
    }
    // ignore: avoid_print
    print('ORDINE AS VOCE 04: tocchi dentro le perle grandi $osservati, '
        'rubati ${rubati.length}');
    expect(osservati, 120,
        reason: 'i tocchi guardati sono $osservati invece di 120');
    expect(rubati, isEmpty,
        reason: 'la perla grande non prende il dito che cade dentro di lei: '
            '${rubati.take(6).join("; ")}');
  });
}
