import 'package:flutter/foundation.dart';

import 'archetype.dart';

/// Una risposta possibile, col suo peso sugli archetipi.
///
/// I pesi non si mostrano MAI: la persona legge solo il testo. Vederli
/// cambierebbe la risposta, che e' il modo piu' semplice di rompere un test.
@immutable
class ArchetypeRisposta {
  const ArchetypeRisposta(this.testo, this.pesi);

  final String testo;
  final Map<Archetype, int> pesi;
}

/// Una domanda del questionario, con le sue quattro risposte.
@immutable
class ArchetypeDomanda {
  const ArchetypeDomanda({
    required this.id,
    required this.testo,
    required this.risposte,
  });

  /// L'identificativo stabile, da D1 a D12: lo usano la memoria e i test, cosi'
  /// riordinare le domande a video non falsa uno storico gia' salvato.
  final String id;
  final String testo;
  final List<ArchetypeRisposta> risposte;
}

/// Le dodici domande del Test Archetipo, come dati.
class ArchetypeQuiz {
  const ArchetypeQuiz._();

  /// Quante domande, e quante risposte per domanda. Un test li verifica, cosi'
  /// una svista nella codifica dei dati non arriva a video.
  static const int domande = 12;
  static const int rispostePerDomanda = 4;

  static const List<ArchetypeDomanda> tutte = [
    ArchetypeDomanda(
      id: 'D1',
      testo: 'Davanti a un ostacolo inatteso, cosa fai?',
      risposte: [
        ArchetypeRisposta('Lo affronto di petto',
            {Archetype.eroe: 2, Archetype.ribelle: 1}),
        ArchetypeRisposta('Mi fermo a capirlo',
            {Archetype.saggio: 2, Archetype.realista: 1}),
        ArchetypeRisposta('Contesto chi l\'ha creato', {Archetype.ribelle: 2}),
        ArchetypeRisposta('Penso a chi ne è colpito',
            {Archetype.custode: 2, Archetype.amante: 1}),
      ],
    ),
    ArchetypeDomanda(
      id: 'D2',
      testo: 'Una giornata libera davanti a te: come la vivi?',
      risposte: [
        ArchetypeRisposta('Parto senza meta', {Archetype.esploratore: 2}),
        ArchetypeRisposta('Risate e leggerezza', {Archetype.giullare: 2}),
        ArchetypeRisposta('Creo o costruisco qualcosa',
            {Archetype.creatore: 2, Archetype.mago: 1}),
        ArchetypeRisposta('Cose semplici, con serenità',
            {Archetype.innocente: 2}),
      ],
    ),
    ArchetypeDomanda(
      id: 'D3',
      testo: 'In un gruppo, tu sei:',
      risposte: [
        ArchetypeRisposta('Chi dà la direzione',
            {Archetype.sovrano: 2, Archetype.eroe: 1}),
        ArchetypeRisposta('Chi tiene su il morale', {Archetype.giullare: 2}),
        ArchetypeRisposta('Chi include gli esclusi',
            {Archetype.custode: 2, Archetype.amante: 1}),
        ArchetypeRisposta('Chi riporta al concreto', {Archetype.realista: 2}),
      ],
    ),
    ArchetypeDomanda(
      id: 'D4',
      testo: 'Quando decidi, di cosa ti fidi?',
      risposte: [
        ArchetypeRisposta('Della ragione e delle informazioni',
            {Archetype.saggio: 2}),
        ArchetypeRisposta('Del coraggio: agisco', {Archetype.eroe: 2}),
        ArchetypeRisposta('Dell\'intuito: cambio', {Archetype.mago: 2}),
        ArchetypeRisposta('Del buon senso e dell\'esperienza',
            {Archetype.realista: 2, Archetype.saggio: 1}),
      ],
    ),
    ArchetypeDomanda(
      id: 'D5',
      testo: 'In amore, cosa cerchi prima di tutto?',
      risposte: [
        ArchetypeRisposta('Passione totale', {Archetype.amante: 2}),
        ArchetypeRisposta('Cura quotidiana', {Archetype.custode: 2}),
        ArchetypeRisposta('Fiducia pulita', {Archetype.innocente: 2}),
        ArchetypeRisposta('Libertà senza catene',
            {Archetype.ribelle: 2, Archetype.esploratore: 1}),
      ],
    ),
    ArchetypeDomanda(
      id: 'D6',
      testo: 'Un cambiamento improvviso: come lo leggi?',
      risposte: [
        ArchetypeRisposta('Un\'occasione per esplorare',
            {Archetype.esploratore: 2}),
        ArchetypeRisposta('Con pragmatismo, riparto', {Archetype.realista: 2}),
        ArchetypeRisposta('Una trasformazione, una rinascita',
            {Archetype.mago: 2, Archetype.creatore: 1}),
        ArchetypeRisposta('Reagisco subito', {Archetype.eroe: 2}),
      ],
    ),
    ArchetypeDomanda(
      id: 'D7',
      testo: 'Cosa temi di più?',
      risposte: [
        ArchetypeRisposta('Perdere la fiducia', {Archetype.innocente: 2}),
        ArchetypeRisposta('Perdere controllo e ordine', {Archetype.sovrano: 2}),
        ArchetypeRisposta('Restare solo',
            {Archetype.amante: 2, Archetype.custode: 1}),
        ArchetypeRisposta('Essere ingabbiato', {Archetype.ribelle: 2}),
      ],
    ),
    ArchetypeDomanda(
      id: 'D8',
      testo: 'Un problema al lavoro: qual è la tua mossa?',
      risposte: [
        ArchetypeRisposta('Organizzo e guido', {Archetype.sovrano: 2}),
        ArchetypeRisposta('Invento una soluzione nuova',
            {Archetype.creatore: 2, Archetype.mago: 1}),
        ArchetypeRisposta('Analizzo a fondo', {Archetype.saggio: 2}),
        ArchetypeRisposta('Sdrammatizzo', {Archetype.giullare: 2}),
      ],
    ),
    ArchetypeDomanda(
      id: 'D9',
      testo: 'Cosa ti ricarica davvero?',
      risposte: [
        ArchetypeRisposta('La quiete e le piccole gioie',
            {Archetype.innocente: 2}),
        ArchetypeRisposta('Un viaggio', {Archetype.esploratore: 2}),
        ArchetypeRisposta('Un momento profondo con una persona',
            {Archetype.amante: 2}),
        ArchetypeRisposta('Creare', {Archetype.creatore: 2}),
      ],
    ),
    ArchetypeDomanda(
      id: 'D10',
      testo: 'Davanti a un\'ingiustizia:',
      risposte: [
        ArchetypeRisposta('Mi ribello', {Archetype.ribelle: 2}),
        ArchetypeRisposta('Combatto per rimettere a posto',
            {Archetype.eroe: 2, Archetype.sovrano: 1}),
        ArchetypeRisposta('Proteggo chi è colpito', {Archetype.custode: 2}),
        ArchetypeRisposta('Ristabilisco un ordine giusto',
            {Archetype.sovrano: 2}),
      ],
    ),
    ArchetypeDomanda(
      id: 'D11',
      testo: 'I tuoi sogni e i tuoi progetti:',
      risposte: [
        ArchetypeRisposta('Ho sempre qualcosa da creare',
            {Archetype.creatore: 2}),
        ArchetypeRisposta('Immagino possibilità nuove', {Archetype.mago: 2}),
        ArchetypeRisposta('Sogno mete lontane', {Archetype.esploratore: 2}),
        ArchetypeRisposta('Progetti realistici', {Archetype.realista: 2}),
      ],
    ),
    ArchetypeDomanda(
      id: 'D12',
      testo: 'Come ti vedono gli altri?',
      risposte: [
        ArchetypeRisposta('Un saggio a cui chiedere', {Archetype.saggio: 2}),
        ArchetypeRisposta('Caloroso e appassionato', {Archetype.amante: 2}),
        ArchetypeRisposta('Spiritoso', {Archetype.giullare: 2}),
        ArchetypeRisposta('Affascinante e misterioso', {Archetype.mago: 2}),
      ],
    ),
  ];
}
