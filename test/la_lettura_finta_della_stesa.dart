import 'package:esoteric_circle/core/responsi/la_forma_del_responso.dart';
import 'package:esoteric_circle/core/tarot/la_lettura_dal_modello.dart';
import 'package:esoteric_circle/core/tarot/tarot_reading.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread.dart';

/// **LA LETTURA FINTA DEL MODELLO, A MISURA.** Ordine GA voci GA.03, GA.05 e
/// GA.07, 20 ottobre 2026: dalla decisione del fondatore "Carte dal corpus"
/// il modello scrive il solo responso principale, e ogni paragrafo sta fra 40
/// e 50 parole. Le prove della stesa non chiamano mai il modello (regola
/// SPESE): ricevono questa, scritta una volta sola qui perche' tutte misurino
/// la stessa cosa.
///
/// La risposta nomina la carta chiave della stesa ([TarotReading.chiaveDi]),
/// come chiede l'istruzione; i nomi delle carte hanno da una a quattro
/// parole, e la risposta va da 47 a 50 parole. Il cosa fare ne ha 47,
/// l'approfondimento 49. [letturaFinta] lo verifica e cade se un testo esce
/// dalla misura: una prova costruita su un testo fuori misura misurerebbe la
/// prova, non il codice.
LetturaDelModello letturaFinta(TarotSpread s,
    {String titolo = '', bool lunga = false}) {
  final chiave = TarotReading.chiaveDi(s).drawn.card.name;
  final l = LetturaDelModello(
    risposta: 'Le carte indicano di sì, a patto di chiarire prima le '
        'condizioni: $chiave dice che la scelta poggia su basi solide e che '
        'hai gli strumenti per farla. Prima di firmare, però, conviene '
        'guardare con calma che cosa ti chiedono davvero e che cosa offri in '
        'cambio.',
    cosaFare: cosaFareFinto,
    approfondimento: lunga ? approfondimentoFinto : '',
    titolo: titolo,
  );
  for (final p in [l.risposta, l.cosaFare, if (lunga) l.approfondimento]) {
    if (!LaFormaDelResponso.aMisura(p)) {
      throw StateError('la lettura finta e\' fuori misura '
          '(${LaFormaDelResponso.parole(p)} parole): $p');
    }
  }
  return l;
}

/// Il cosa fare della lettura finta, 47 parole.
const String cosaFareFinto = 'Questa settimana chiedi per iscritto orari, '
    'compenso e durata del contratto, poi rileggi tutto con calma prima di '
    'rispondere. Non accettare a voce e non lasciarti mettere fretta: una '
    'sera di riflessione in più ti permette di capire se l\'offerta '
    'corrisponde davvero a quello che cerchi adesso.';

/// L'approfondimento della lettura finta, 49 parole.
const String approfondimentoFinto = 'Il punto delicato è la parte '
    'economica: se il compenso proposto non copre le spese che hai già, '
    'chiedi un incontro breve e porta le tue cifre scritte in lettere su un '
    'foglio. Parla prima della durata, poi del resto e annota ogni risposta '
    'che ricevi senza commentarla subito.';
