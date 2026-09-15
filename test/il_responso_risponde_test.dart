import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/chat/le_forme_del_genere.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/rituals/guide_animal_derivation.dart';
import 'package:esoteric_circle/core/viaggio/diario_dei_viaggi.dart';
import 'package:esoteric_circle/core/viaggio/il_responso_del_viaggio.dart';
import 'package:esoteric_circle/core/viaggio/la_domanda_capita.dart';
import 'package:esoteric_circle/core/viaggio/la_domanda_del_viaggio.dart';
import 'package:esoteric_circle/core/viaggio/la_voce_del_mondo_di_sotto.dart';
import 'package:esoteric_circle/core/viaggio/le_guardie_del_responso.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:esoteric_circle/core/viaggio/la_scena_dal_modello.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/core/viaggio/vocabolario_del_viaggio.dart';
import 'package:esoteric_circle/core/viaggio/scena_del_viaggio.dart';

/// **IL RESPONSO RISPONDE.** Ordine DL voci 07, 08, 10 e 13, 14 settembre
/// 2026.
///
/// Il fondatore ha scritto una domanda personale in tutte e quattro le
/// discese della prova della build 2250, e non ha mai ricevuto una risposta a
/// quella domanda. Da questo ordine il titolo, la risposta e il gesto li
/// scrive il modello, nella stessa chiamata della scena, e passano da guardie
/// che non si negoziano; la ripresa nomina l'oggetto della domanda; il gesto
/// dice un tempo solo.
///
/// **Ogni guardia ha la sua riga che la fa scattare, e una sola**: togliere
/// una guardia fa cadere la sua prova, perche' la riga passa o cade su
/// un'altra. E' cosi' che ciascuna e' stata vista rossa.
void main() {
  const domanda = 'Mia sorella diventerà presto mamma?';
  const neutra = CourtesyForm.neutral;

  MotivoDelloScarto? titolo(String t, {CourtesyForm forma = neutra}) =>
      LeGuardieDelResponso.delTitolo(t, domanda: domanda, forma: forma);
  MotivoDelloScarto? risposta(String r,
          {CourtesyForm forma = neutra,
          String? oggetto = 'tua sorella',
          List<String> scena = const []}) =>
      LeGuardieDelResponso.dellaRisposta(r,
          domanda: domanda,
          forma: forma,
          oggetto: oggetto,
          nomiDellaScena: scena);
  MotivoDelloScarto? azione(String a, {CourtesyForm forma = neutra}) =>
      LeGuardieDelResponso.dellAzione(a, domanda: domanda, forma: forma);

  group('LE GUARDIE DEL TITOLO, DELLA RISPOSTA E DEL GESTO', () {
    test('ogni motivo dello scarto ha una riga che lo fa scattare', () {
      final casi = <MotivoDelloScarto, MotivoDelloScarto?>{
        MotivoDelloScarto.vuota: titolo('  '),
        MotivoDelloScarto.troppoLunga:
            titolo('Il tempo di tua sorella non è il tuo'),
        MotivoDelloScarto.eUnaDomanda: titolo('Tua sorella lo sa già?'),
        MotivoDelloScarto.duePuntiNelTitolo:
            titolo('Tua sorella: il suo tempo'),
        MotivoDelloScarto.dueDuePunti:
            risposta('Una cosa: tua sorella: il suo tempo.'),
        MotivoDelloScarto.trattinoLungo:
            risposta('Tua sorella — quello che cerchi è vicino.'),
        MotivoDelloScarto.virgolaEe:
            risposta('Tua sorella ha il suo tempo, e tu hai il tuo.'),
        MotivoDelloScarto.primaPersona: risposta('Io vedo tua sorella serena.'),
        MotivoDelloScarto.previsioneCerta:
            risposta('Tua sorella avrà un bambino.'),
        MotivoDelloScarto.promessa:
            risposta('La gravidanza di tua sorella ha il suo ritmo.'),
        MotivoDelloScarto.diagnosi: risposta('Tua sorella non ha un disturbo.'),
        MotivoDelloScarto.nomeProprio:
            risposta('Tua sorella e Carla hanno tempi diversi.'),
        MotivoDelloScarto.genereContrario: risposta(
            'Sei pronto ad aspettare tua sorella.',
            forma: CourtesyForm.feminine),
        // Su una domanda senza un terzo: con la sorella, dalla regola in
        // positivo della 2258, la frase cadrebbe prima per il terzo.
        MotivoDelloScarto.nonNominaLaDomanda:
            LeGuardieDelResponso.dellaRisposta(
                'Il tempo delle cose non si comanda.',
                domanda:
                    'Ho una scelta davanti e non so da che parte guardare.',
                forma: neutra),
        MotivoDelloScarto.anticipaLaScena: risposta(
            'La soglia di tua sorella non è tua da attraversare.',
            scena: const ['soglia']),
        MotivoDelloScarto.consiglioDiVita:
            azione('Rifletti su tua sorella stasera.'),
        MotivoDelloScarto.senzaTempo: azione('Scrivi a tua sorella due righe.'),
        MotivoDelloScarto.toccaUnTerzo: azione('Affronta tua sorella stasera.'),
        MotivoDelloScarto.saluteDenaroLegge:
            azione('Compra un regalo per tua sorella entro sabato.'),
        // Il titolo ripetuto lo vede la lettura, che conosce i titoli gia'
        // dati: *"Quello che cerchi è vicino"* era gia' uscito, con un punto.
        MotivoDelloScarto.titoloRipetuto: LeGuardieDelResponso.leggi(
                {'titolo': 'quello che cerchi è vicino'},
                domanda: domanda,
                forma: neutra,
                titoliGiaDati: const ['Quello che cerchi è vicino.'])
            .scarti
            .single
            .motivo,
        // **ORDINE DN**, le righe dei cinque motivi nuovi.
        MotivoDelloScarto.fuoco:
            azione('Stasera brucia il foglio su un piatto.'),
        MotivoDelloScarto.statoDiUnTerzo:
            risposta('Tua sorella è serena e lo sa già.'),
        MotivoDelloScarto.decisioneGrave:
            azione('Entro sabato lascia il lavoro in banca.'),
        MotivoDelloScarto.gergo: risposta('È tempo di vederla in te.'),
        MotivoDelloScarto.tempoNelTitolo: titolo('Guardati attorno ora'),
        MotivoDelloScarto.sgrammaticato: titolo('Ciò che puoi dare è te'),
        MotivoDelloScarto.titoloAnticipaLaScena:
            LeGuardieDelResponso.titoloToccaLaScena(
                    'La porta non è tua', const ['la porta chiusa'])
                ? MotivoDelloScarto.titoloAnticipaLaScena
                : null,
      };
      // **IL CARDINALE**: tutti i motivi hanno la loro riga.
      expect(casi.keys.toSet(), MotivoDelloScarto.values.toSet());
      for (final e in casi.entries) {
        expect(e.value, e.key, reason: 'la riga del motivo ${e.key.name}');
      }
    });

    test(
        '"Tua sorella avrà un bambino" si scarta, "Non tocca a te saperlo '
        'prima di lei" no, come dice l\'ordine', () {
      expect(risposta('Tua sorella avrà un bambino.'),
          MotivoDelloScarto.previsioneCerta);
      // **IL FUTURO DENTRO UN DUBBIO**, dalla misura sulla 2258.
      expect(risposta('Non puoi sapere se tua sorella diventerà mamma.'),
          isNot(MotivoDelloScarto.previsioneCerta));
      expect(risposta('Tua sorella diventerà mamma presto.'),
          MotivoDelloScarto.previsioneCerta);
      // **LA NECESSITA' DI UN EVENTO**, dalla riprova a video della 2256.
      expect(risposta('Per tua sorella qualcosa di diverso deve accadere.'),
          MotivoDelloScarto.previsioneCerta);
      // **OGNI FUTURO**, dalla riprova a video della 2255; i modali restano.
      expect(risposta('Ogni strada con tua sorella ti condurrà lontano.'),
          MotivoDelloScarto.previsioneCerta);
      expect(risposta('Con tua sorella potrai scegliere tu il momento.'),
          isNot(MotivoDelloScarto.previsioneCerta));
      expect(risposta('Non tocca a te saperlo prima di lei.'),
          isNot(MotivoDelloScarto.previsioneCerta));
      expect(risposta('Non tocca a te saperlo prima di tua sorella.'), isNull);
    });

    test('"LASCIALO" TOCCA UN TERZO SOLO QUANDO E\' UNA PERSONA', () {
      expect(
          azione('Stasera scrivi due righe su un foglio. Lascialo sul '
              'comodino.'),
          isNull,
          reason: 'il foglio non e un terzo');
      // **Qui c'era *"Stasera pensa a lui"***: dalla 2259 l'invito a
      // pensare si scarta prima, anche dopo il tempo, e la riga non
      // misurava piu' il terzo.
      expect(azione('Stasera scrivi a lui due righe. Poi lascialo.'),
          MotivoDelloScarto.toccaUnTerzo);
      expect(azione('Entro sabato lasciala perdere, senza spiegazioni.'),
          MotivoDelloScarto.toccaUnTerzo);
      // **ANCHE IL CONFRONTO COME NOME**, dalla riprova della 2254.
      expect(
          azione('Stasera scrivi un messaggio alla tua collega per un '
              'confronto di lavoro.'),
          MotivoDelloScarto.toccaUnTerzo);
      // **RIVELARE SOLO COME ORDINE**, dalla misura dell'ordine DN.
      expect(
          azione('Domani mattina tocca una pietra spaccata. Osserva le crepe '
              'che rivelano.'),
          isNull);
      expect(azione('Stasera rivelale cosa hai capito.'),
          MotivoDelloScarto.toccaUnTerzo);
    });

    test('LE PREVISIONI SENZA FUTURO, dalla sonda col modello vero', () {
      MotivoDelloScarto? casa(String r) => LeGuardieDelResponso.dellaRisposta(r,
          domanda: "Venderò la casa prima dell'inverno?", forma: neutra);
      expect(casa('La casa è già venduta.'), MotivoDelloScarto.previsioneCerta);
      expect(casa('La casa ha già trovato un nuovo proprietario.'),
          MotivoDelloScarto.previsioneCerta);
      expect(
          LeGuardieDelResponso.dellaRisposta(
              'Il lavoro di tuo figlio non ha radici. Non è il momento giusto.',
              domanda: "Mio figlio troverà lavoro entro l'estate?",
              forma: neutra),
          MotivoDelloScarto.previsioneCerta);
      // Il passato della persona non e' una previsione.
      expect(casa('Hai già scelto la casa una volta.'), isNull);
    });

    test('le righe buone passano, nelle tre forme', () {
      for (final f in [
        CourtesyForm.masculine,
        CourtesyForm.feminine,
        CourtesyForm.neutral,
      ]) {
        expect(titolo('Quello che cerchi è vicino', forma: f), isNull);
        expect(
            risposta(
                'Quella notizia non è tua da dare. '
                'Tu puoi solo fare spazio a tua sorella.',
                forma: f),
            isNull);
        expect(
            azione('Stasera scrivi a tua sorella una riga, senza domande.',
                forma: f),
            isNull);
      }
    });

    test('la risposta del modello si legge, e senza domanda non si legge', () {
      final letti = LeGuardieDelResponso.leggi({
        'titolo': 'Quello che cerchi è vicino.',
        'risposta': 'Tua sorella avrà un bambino.',
        'azione': 'Stasera scrivi a tua sorella una riga, senza domande.',
      }, domanda: domanda, forma: neutra, oggetto: 'tua sorella');
      expect(letti.titolo, 'Quello che cerchi è vicino',
          reason: 'il punto in fondo al titolo si toglie');
      expect(letti.risposta, isNull);
      expect(letti.azione, isNotNull);
      expect(letti.scarti.single.motivo, MotivoDelloScarto.previsioneCerta);
      expect(
          LeGuardieDelResponso.leggi({'titolo': 'Il suo tempo'},
                  domanda: '', forma: neutra)
              .vuoti,
          isTrue);
    });
  });

  group('ORDINE DN, IL FUOCO, I TERZI, LE DECISIONI, IL GERGO', () {
    test('col fratello la ripresa di casa nomina la persona, non l oggetto',
        () {
      // **DALLA PROVA A VIDEO DELLA BUILD 2252**: *"La domanda riguardava tuo
      // fratello. Quanto tempo le dedichi"*. Le risposte di casa del tema
      // della persona dicono la, le, lei.
      final animale = GuideAnimalDerivation.forSign(Zodiac.cancer);
      final riprese = <String, List<String>>{};
      for (final o in ['tuo fratello', 'tua sorella']) {
        for (var i = 0; i < 40; i++) {
          final r = IlResponsoDelViaggio.componi(
            dalModello: null,
            domanda: 'Una domanda su $o',
            giorno: DateTime(2026, 9, 14).add(Duration(days: i)),
            nitidezza: 1,
            discesa: i,
            giaOggi: 0,
            animale: animale,
            tema: TemaDellaDomanda.persona,
            storia: const [],
            oggetto: o,
          );
          riprese.putIfAbsent(o, () => []).add(r.paragrafi[0]);
        }
      }
      expect(riprese['tuo fratello']!.where((p) => p.contains('fratello')),
          isEmpty);
      expect(riprese['tua sorella']!.where((p) => p.contains('sorella')),
          hasLength(40));
    });

    test('l oggetto plurale non va col singolare della ripresa', () {
      // **DALLA RIPROVA A VIDEO DELLA BUILD 2256**: *"Il motivo della discesa
      // era le lettere"*.
      final animale = GuideAnimalDerivation.forSign(Zodiac.cancer);
      final riprese = <String>[];
      for (var i = 0; i < 40; i++) {
        final r = IlResponsoDelViaggio.componi(
          dalModello: null,
          domanda: 'Voglio bruciare le lettere di mia nonna',
          giorno: DateTime(2026, 9, 15).add(Duration(days: i)),
          nitidezza: 1,
          discesa: i,
          giaOggi: 0,
          animale: animale,
          tema: TemaDellaDomanda.finito,
          storia: const [],
          oggetto: 'le lettere',
        );
        riprese.add(r.paragrafi[0]);
      }
      expect(riprese.where((p) => p.contains('era le lettere')), isEmpty);
      expect(riprese.where((p) => p.contains('le lettere')), isNotEmpty);
    });

    test('il clitico col verbo che regge un predicativo', () {
      // **DALLA PROVA A VIDEO DELLA BUILD 2252**: un titolo del modello a un
      // profilo neutro.
      expect(
          formeContrarieAllaForma('Cosa ti tiene legata', CourtesyForm.neutral),
          isNotEmpty);
      expect(
          formeContrarieAllaForma(
              'Cosa ti tiene legata', CourtesyForm.feminine),
          isEmpty);
      expect(
          formeContrarieAllaForma('Cosa ti rende forte', CourtesyForm.neutral),
          isEmpty);
      // **DALLA RIPROVA DELLA 2258**: l'infanzia di chi legge.
      expect(
          formeContrarieAllaForma(
              'Cerca qualcosa che ti apparteneva da piccola.',
              CourtesyForm.neutral),
          isNotEmpty);
      expect(
          formeContrarieAllaForma(
              'Cerca qualcosa che ti apparteneva da piccola.',
              CourtesyForm.feminine),
          isEmpty);
      // **DALLA RIPROVA DELLA 2256**: la desinenza, non il dizionario.
      expect(
          formeContrarieAllaForma(
              'Scrivi tre cose che ti rendono fiera.', CourtesyForm.neutral),
          isNotEmpty);
      expect(
          formeContrarieAllaForma(
              'Una sera che ti tiene compagnia.', CourtesyForm.neutral),
          isEmpty);
      // **DALLA RIPROVA DELLA 2254**: dopo *essergli* e *stargli*.
      expect(
          formeContrarieAllaForma(
              'Puoi essergli vicina.', CourtesyForm.neutral),
          isNotEmpty);
      expect(
          formeContrarieAllaForma(
              'Puoi essergli vicino.', CourtesyForm.masculine),
          isEmpty);
      // **DALLA RIPROVA A VIDEO DELLA BUILD 2253**: il participio fuori dal
      // dizionario dopo il riflessivo di chi legge.
      expect(
          formeContrarieAllaForma(
              'Puoi sentirti divisa.', CourtesyForm.neutral),
          isNotEmpty);
      expect(
          formeContrarieAllaForma(
              'Puoi sentirti meglio.', CourtesyForm.neutral),
          isEmpty);
      expect(
          formeContrarieAllaForma(
              'Puoi sentirti divisa.', CourtesyForm.feminine),
          isEmpty);
    });

    test('presto e un avverbio, non un participio', () {
      // **DALLA MISURA DELL'ORDINE DN**: alla domanda sulla sorella che
      // diventera' mamma, a chi ha scelto il femminile.
      expect(
          formeContrarieAllaForma(
              'Il desiderio che tua sorella diventi presto mamma è grande.',
              CourtesyForm.feminine),
          isEmpty);
      expect(formeContrarieAllaForma('Diventi pronto.', CourtesyForm.feminine),
          isNotEmpty);
    });

    test('il clitico col participio segue la forma scelta', () {
      // *"le persone che ti hanno visto arrabbiato"*, dalla sonda, a una
      // persona che ha scelto il femminile.
      expect(
          azione('Stasera scrivi i nomi di chi ti ha visto arrabbiato.',
              forma: CourtesyForm.feminine),
          MotivoDelloScarto.genereContrario);
      expect(
          azione('Stasera scrivi i nomi di chi ti ha visto arrabbiata.',
              forma: CourtesyForm.feminine),
          isNull);
    });

    test('il fuoco resta fuori dal gesto, e le sue alternative passano', () {
      for (final g in [
        'Stasera accendi una candela davanti alla finestra.',
        'Domani mattina dai fuoco alla lettera.',
        'Stasera metti il foglio nel braciere.',
        'Entro sabato brucia la foto e disperdi le ceneri.',
      ]) {
        expect(azione(g), MotivoDelloScarto.fuoco, reason: g);
      }
      for (final g in [
        'Stasera strappa il foglio in quattro pezzi.',
        'Domani mattina seppellisci il foglio sotto una pietra.',
        'Entro sabato getta il foglio nell\'acqua corrente.',
        'Stasera chiudi il foglio in un cassetto e non riaprirlo.',
      ]) {
        expect(azione(g), isNull, reason: g);
      }
      // Negli altri due testi il fuoco come immagine resta, l'invito no.
      expect(risposta('Tua sorella ha un fuoco che tu non vedi.'),
          isNot(MotivoDelloScarto.fuoco));
      expect(risposta('Brucia quello che non serve a tua sorella.'),
          MotivoDelloScarto.fuoco);
    });

    test('i due esempi dell\'ordine: la porta si, il desiderio no', () {
      const sorella = 'Mia sorella diventerà presto mamma?';
      expect(
          LeGuardieDelResponso.statoDiUnTerzo(
              'La porta di tua sorella non è tua da aprire.', sorella),
          isFalse,
          reason: 'dice una cosa su chi legge, non su di lei');
      expect(
          LeGuardieDelResponso.statoDiUnTerzo(
              'Il desiderio di tua sorella è un processo che si sta '
              'sviluppando.',
              sorella),
          isTrue,
          reason: 'afferma un fatto sulla vita di un\'altra persona');
      expect(
          LeGuardieDelResponso.statoDiUnTerzo(
              'Lui è capace di farlo da sé.', 'Mio figlio troverà lavoro?'),
          isTrue);
      expect(
          LeGuardieDelResponso.statoDiUnTerzo(
              'Marco ti vuole bene.', 'Cosa prova davvero Marco per me?'),
          isTrue,
          reason: 'cio che Marco prova l\'app non lo sa');
      expect(
          LeGuardieDelResponso.statoDiUnTerzo(
              'Il tuo rapporto con tuo padre è diventato un copione che non '
                  'ti appartiene.',
              'Perché con mio padre finisce sempre in lite?'),
          isFalse,
          reason: 'e il rapporto di chi legge');
      expect(
          LeGuardieDelResponso.statoDiUnTerzo(
              'Non puoi sapere quando tua sorella diventerà mamma.', sorella),
          isFalse);
      // **DALLA SONDA DELL'ORDINE DN**: il possessivo del terzo come
      // soggetto da' per certo lo stato della madre.
      expect(
          LeGuardieDelResponso.statoDiUnTerzo(
              'La sua rabbia non è la tua.', 'Mia madre è arrabbiata con me?'),
          isTrue);
      // **DALLA RIPROVA A VIDEO DELLA BUILD 2256**: lo stato del terzo dentro
      // il complemento, tranne quando lo ha detto la persona.
      expect(
          LeGuardieDelResponso.statoDiUnTerzo(
              'Non puoi forzare il suo desiderio di stare lontano.',
              'Il mio migliore amico si e allontanato'),
          isTrue);
      expect(
          LeGuardieDelResponso.statoDiUnTerzo(
              'Non puoi cambiare la rabbia di tua madre.',
              'Mia madre è arrabbiata con me'),
          isFalse);
      // **DALLA RIPROVA A VIDEO DELLA BUILD 2254**: ogni frase che nomina il
      // terzo, anche fuori dal soggetto.
      expect(
          LeGuardieDelResponso.statoDiUnTerzo(
              'La paura non è sua', 'Mia madre e arrabbiata con me'),
          isTrue);
      expect(
          LeGuardieDelResponso.statoDiUnTerzo(
              'Non puoi cambiare la rabbia di tua madre.',
              'Mia madre e arrabbiata con me'),
          isFalse);
      // **LA CITTA' NON E' UNA PERSONA**, dalla misura sulla 2258.
      expect(
          LeGuardieDelResponso.parlaDiUnTerzo(
              'Mi trasferisco a Berlino o resto qui'),
          isFalse);
      expect(
          LeGuardieDelResponso.parlaDiUnTerzo(
              'Ho chiuso con Luca dopo sei anni'),
          isTrue);
      // **DALLA RIPROVA A VIDEO DELLA BUILD 2257**: la regola in positivo.
      expect(
          LeGuardieDelResponso.statoDiUnTerzo(
              'Quel trattamento non ha a che fare con te.',
              'Il mio capo mi tratta male'),
          isTrue);
      expect(
          LeGuardieDelResponso.statoDiUnTerzo(
              'Tu non sei quello che vede.', 'Mia suocera non mi accetta'),
          isTrue);
      expect(
          LeGuardieDelResponso.statoDiUnTerzo('Non è tua la gioia',
              'Mia sorella si sposa e io non sono felice'),
          isTrue);
      expect(
          LeGuardieDelResponso.statoDiUnTerzo(
              'Con il tuo capo puoi scegliere tu cosa dire.',
              'Il mio capo mi tratta male'),
          isFalse);
      // **DALLA PROVA A VIDEO DELLA BUILD 2253**: il terzo sottinteso.
      expect(
          LeGuardieDelResponso.statoDiUnTerzo(
              'Non è arrabbiata con te', 'Mia madre e arrabbiata con me'),
          isTrue);
      expect(
          LeGuardieDelResponso.statoDiUnTerzo('Sta vivendo un momento suo.',
              'Mio fratello sta passando un brutto periodo'),
          isTrue);
      expect(
          LeGuardieDelResponso.statoDiUnTerzo(
              'Non è colpa tua.', 'Mia madre e arrabbiata con me'),
          isFalse);
      expect(
          LeGuardieDelResponso.statoDiUnTerzo('Non è arrabbiata con te',
              'Ho una scelta davanti e non so da che parte guardare.'),
          isFalse);
      // **DALLA PROVA A VIDEO DELLA BUILD 2252**: l'articolo davanti al
      // possessivo.
      expect(
          LeGuardieDelResponso.statoDiUnTerzo(
              'Il tuo compagno ti pone davanti a una decisione importante.',
              'Devo lasciare il mio compagno'),
          isTrue);
      expect(
          LeGuardieDelResponso.statoDiUnTerzo(
              'Con il tuo compagno puoi scegliere tu quando parlare.',
              'Devo lasciare il mio compagno'),
          isFalse);
      // **DALLA PROVA A VIDEO DELLA BUILD 2252**: la rabbia della madre,
      // ripresa col dimostrativo.
      const madre = 'Mia madre e arrabbiata con me';
      expect(
          LeGuardieDelResponso.statoDiUnTerzo(
              'Quella rabbia non parla di te ma di lei.', madre),
          isTrue);
      expect(
          LeGuardieDelResponso.statoDiUnTerzo(
              'Quella rabbia la puoi guardare senza farla tua.', madre),
          isFalse);
      // **DALLA MISURA DELL'ORDINE DN**: la decisione che non spetta a chi
      // legge dice cio' che chi legge non puo' fare.
      expect(
          LeGuardieDelResponso.statoDiUnTerzo(
              'La maternità di tua sorella non è una decisione tua.', sorella),
          isFalse);
      expect(
          LeGuardieDelResponso.statoDiUnTerzo(
              'La maternità di tua sorella è un desiderio profondo.', sorella),
          isTrue);
      // **DALLA MISURA DELL'ORDINE DN**: senza un terzo nella domanda, il
      // possessivo e' della cosa di cui si parla.
      expect(
          LeGuardieDelResponso.statoDiUnTerzo(
              'La scelta che hai davanti non è un problema da risolvere. '
                  'Il suo senso apparirà dopo.',
              'Ho una scelta davanti e non so da che parte guardare.'),
          isFalse);
      expect(
          LeGuardieDelResponso.statoDiUnTerzo('Il suo posto è già lì.',
              'C\'è una persona di cui non so che posto ha per me.'),
          isTrue);
      expect(
          LeGuardieDelResponso.statoDiUnTerzo(
              'La sua difficoltà è un passaggio che deve attraversare.',
              'Mio fratello sta passando un brutto periodo?'),
          isTrue);
    });

    test('prendere una parte si puo, ordinare una decisione grave no', () {
      const banca = 'Devo lasciare il lavoro in banca per aprire una bottega?';
      MotivoDelloScarto? r(String t) =>
          LeGuardieDelResponso.dellaRisposta(t, domanda: banca, forma: neutra);
      expect(r('La bottega ti somiglia più della banca.'), isNull);
      expect(r('Lascia la banca e apri la bottega.'),
          MotivoDelloScarto.decisioneGrave);
      expect(r('Devi lasciare il lavoro in banca.'),
          MotivoDelloScarto.decisioneGrave);
      expect(
          LeGuardieDelResponso.dellaRisposta('Trasferisciti dove sei felice.',
              domanda: 'Devo trasferirmi a Milano?', forma: neutra),
          MotivoDelloScarto.decisioneGrave);
      // Il titolo di casa: *posto* da solo non e' il posto di lavoro. Il
      // suo *per ora* lo scarterebbe come tempo nel titolo, se fosse del
      // modello: qui si guarda solo la decisione.
      expect(
          LeGuardieDelResponso.delTitolo('Lascia il posto vuoto per ora',
              domanda: banca, forma: neutra),
          isNot(MotivoDelloScarto.decisioneGrave));
    });

    test('il gesto regge tre frasi corte, non quattro', () {
      // **DALLA MISURA DELL'ORDINE DN**: una cosa sola in tre frasi.
      expect(
          azione('Domani mattina cerca un piccolo sasso. Tienilo in mano '
              'per qualche minuto. Poi mettilo sotto una pietra in giardino.'),
          isNull);
      expect(
          azione('Domani mattina cerca un piccolo sasso. Tienilo in mano. '
              'Poi guardalo. Poi mettilo sotto una pietra in giardino.'),
          MotivoDelloScarto.troppoLunga);
    });

    test('il gergo si scarta perche e vuoto', () {
      for (final g in [
        'È tempo di vederla in te.',
        'Ascolta il tuo cuore sulla bottega.',
        'La bottega è il tuo percorso.',
        'Il tuo vero sé vuole la bottega.',
        'Lascia andare la banca.',
        'La banca è un peso da lasciare andare.',
        'Non ti serve capire la banca per lasciarla andare.',
      ]) {
        expect(
            LeGuardieDelResponso.dellaRisposta(g,
                domanda: 'Devo lasciare la banca per la bottega?',
                forma: neutra),
            MotivoDelloScarto.gergo,
            reason: g);
      }
    });

    test('il titolo del modello che nomina la scena resta, e la scena si rifa',
        () {
      final animale = GuideAnimalDerivation.forSign(Zodiac.cancer);
      PezzoDellaScena tra(List<PezzoDellaScena> l, String id) =>
          l.firstWhere((p) => p.id == id);
      final pezzi = (
        luogo: tra(VocabolarioDelViaggio.luoghi, 'bivio'),
        cosa: tra(VocabolarioDelViaggio.cose, 'porta_chiusa'),
        gesto: GestiDellAnimale.di(animale.name).first,
        momento: VocabolarioDelViaggio.momenti.first,
      );
      final r = IlResponsoDelViaggio.componi(
        dalModello: pezzi,
        domanda: 'Mia sorella non mi parla da due anni e non so se cercarla',
        giorno: DateTime(2026, 9, 14),
        nitidezza: 1,
        discesa: 0,
        giaOggi: 0,
        animale: animale,
        tema: TemaDellaDomanda.persona,
        storia: const [],
        scritti: const TestiDelModello(
            titolo: 'La porta non è tua',
            risposta: 'Tua sorella è al bivio fra parlarti e tacere.'),
      );
      // **IL TITOLO DEL MODELLO E' LA RISPOSTA A COLPO D'OCCHIO**: resta, e
      // la scena del modello cede il posto a quella di riserva, che salta
      // la porta del titolo e il bivio che la risposta gia' dice.
      expect(r.titolo, 'La porta non è tua');
      expect(r.fonti['titolo'], 'modello');
      expect(r.fonti['scena'], 'riserva: titoloAnticipaLaScena');
      expect(r.dalModello, isFalse);
      expect(LaVoceDelMondoDiSotto.nomiDeiPezzi(r.scena),
          isNot(contains('il bivio')));
      expect(
          LeGuardieDelResponso.titoloToccaLaScena(
              r.titolo, LaVoceDelMondoDiSotto.nomiDeiPezzi(r.scena)),
          isFalse);
    });
  });

  group('L\'OGGETTO DELLA DOMANDA, ordine DL voce 08', () {
    test('prende l\'articolo, le maiuscole dei nomi, e mai la prima persona',
        () {
      String? forma(String o, String d) => LaDomandaCapita.oggettoInForma(o, d);
      expect(forma('tuo lavoro', 'Sto sbagliando strada col mio lavoro?'),
          'il tuo lavoro');
      // **IL POSSESSIVO SOLO SE LA DOMANDA DICEVA MIO**: il lavoro e' del
      // figlio, e l'amico senza possessivo prende l'apostrofo.
      expect(forma('il tuo lavoro', 'Mio figlio troverà lavoro?'), 'il lavoro');
      expect(forma('il tuo amico', 'Un amico mi evita da mesi'), "l'amico");
      expect(forma('il tuo studio', 'Riprendo lo studio?'), 'lo studio');
      expect(forma('i tuoi amici', 'Gli amici mi cercano?'), 'gli amici');
      expect(forma('il tuo socio', 'Posso fidarmi del mio nuovo socio?'),
          'il tuo socio');
      expect(
          forma('tue energie', 'Dove metto le mie energie?'), 'le tue energie');
      expect(forma('tua sorella', 'Sua sorella mi scriverà?'), 'la sorella');
      expect(forma('tua sorella', domanda), 'tua sorella',
          reason: 'la parentela al singolare non vuole l\'articolo');
      // **E SE IL MODELLO L'ARTICOLO LO METTE**, cade: la prova a cento
      // discese l'ha trovato quarantanove volte su cento.
      expect(forma('la tua sorella', domanda), 'tua sorella');
      expect(
          forma('i tuoi figli', 'I miei figli mi ascoltano?'), 'i tuoi figli',
          reason: 'al plurale la parentela l\'articolo lo vuole');
      expect(
          forma('giulia nella tua vita', 'Che posto ha Giulia nella mia vita?'),
          'Giulia nella tua vita');
      expect(forma('il trasloco', 'Devo fare il trasloco?'), 'il trasloco');
      expect(forma('dove sto andando', 'Non so più dove sto andando'), isNull,
          reason: 'la prima persona torna in bocca a chi legge');
      expect(forma('niente di tuo', 'Non riesco a finire niente'), isNull,
          reason: 'niente non nomina niente');
      expect(
          forma('trasferimento', 'Accetto il trasferimento a Milano?'), isNull,
          reason: 'senza articolo non si cuce alla preposizione');
      expect(forma('tuo marito', domanda), isNull,
          reason: 'il marito la domanda non lo nomina');
    });

    test('"su" davanti all\'oggetto prende l\'articolo', () {
      expect(LaVoceDelMondoDiSotto.suLOggetto('il trasloco'), 'sul trasloco');
      expect(LaVoceDelMondoDiSotto.suLOggetto("l'estate"), "sull'estate");
      expect(LaVoceDelMondoDiSotto.suLOggetto('gli esami'), 'sugli esami');
      expect(LaVoceDelMondoDiSotto.suLOggetto('la tua casa'), 'sulla tua casa');
      expect(LaVoceDelMondoDiSotto.suLOggetto('tua sorella'), 'su tua sorella');
      expect(LaVoceDelMondoDiSotto.suLOggetto('Giulia'), 'su Giulia');
    });

    test('la ripresa nomina l\'oggetto, e senza oggetto nomina il tema', () {
      final animale = GuideAnimalDerivation.forSign(Zodiac.cancer);
      final storia = <UnViaggio>[];
      var conOggetto = 0;
      for (var i = 0; i < 24; i++) {
        final giorno = DateTime(2026, 9, 14).add(Duration(days: i));
        final r = IlResponsoDelViaggio.componi(
          dalModello: null,
          domanda: 'Devo fare il trasloco?',
          giorno: giorno,
          nitidezza: 1,
          discesa: i,
          giaOggi: 0,
          animale: animale,
          tema: TemaDellaDomanda.scelta,
          storia: storia,
          oggetto: 'il trasloco',
        );
        final p = r.paragrafi.first;
        expect(p, isNot(contains('su il ')), reason: p);
        if (p.contains('il trasloco') || p.contains('sul trasloco')) {
          conOggetto++;
        }
        storia.insert(
            0,
            r.comeSiConserva(
                quando: giorno,
                domanda: 'Devo fare il trasloco?',
                temaDellaDomanda: 'scelta',
                animaleSeguito: animale.name,
                nitidezza: 1));
      }
      expect(conOggetto, 24, reason: 'ogni ripresa nomina il trasloco');
      final senza = IlResponsoDelViaggio.componi(
        dalModello: null,
        domanda: 'Devo fare il trasloco?',
        giorno: DateTime(2026, 9, 14),
        nitidezza: 1,
        discesa: 0,
        giaOggi: 0,
        animale: animale,
        tema: TemaDellaDomanda.scelta,
        storia: const [],
      );
      expect(senza.paragrafi.first, isNot(contains('trasloco')));
    });
  });

  test('LE CURE DELLA RIPROVA A VIDEO DELLA 2259', () {
    // **ORDINE DN VOCE 08**: a *"Devo decidere se operarmi al
    // ginocchio"* il modello ha scritto *"quella che risuona con te"* e
    // *"visualizza entrambe le opzioni. Scegli quella che ti fa sentire
    // piu' leggero"*; a un'altra domanda *"Cio' che puoi dare e' te"*.
    const ginocchio = 'Devo decidere se operarmi al ginocchio';
    MotivoDelloScarto? gesto(String a,
            {String domanda = ginocchio,
            CourtesyForm forma = CourtesyForm.masculine}) =>
        LeGuardieDelResponso.dellAzione(a, domanda: domanda, forma: forma);
    MotivoDelloScarto? risp(String r) => LeGuardieDelResponso.dellaRisposta(r,
        domanda: ginocchio, forma: CourtesyForm.masculine);

    // L'ordine su come scegliere, soltanto a una domanda grave.
    expect(
        gesto('Domani mattina scrivi le due strade su un foglio. '
            'Scegli quella che ti pesa meno.'),
        MotivoDelloScarto.decisioneGrave);
    expect(
        gesto(
            'Stasera scrivi i due nomi su un foglio. '
            'Scegli quello che ti pesa meno.',
            domanda: 'Che nome do al gatto nuovo'),
        isNull);
    expect(
        risp('Fatti operare al ginocchio.'), MotivoDelloScarto.decisioneGrave);
    expect(risp('La decisione di operarti al ginocchio è tua.'), isNull);

    // Il gergo della stessa famiglia.
    expect(risp('Sul ginocchio conta quello che risuona con te.'),
        MotivoDelloScarto.gergo);
    expect(risp('La risposta sul ginocchio è già dentro di te.'),
        MotivoDelloScarto.gergo);

    // Il genere con l'avverbio in mezzo.
    expect(risposta('Guarda cosa ti fa sentire più leggero.'),
        MotivoDelloScarto.genereContrario);
    expect(
        risposta('Puoi sentirti più sollevata.', forma: CourtesyForm.masculine),
        MotivoDelloScarto.genereContrario);

    // L'invito a riflettere dopo il tempo, in ogni frase.
    expect(
        gesto('Domani mattina, prima di alzarti, visualizza le due '
            'strade. Poi scrivile su un foglio.'),
        MotivoDelloScarto.consiglioDiVita);
    expect(
        gesto('Domani mattina, prima di alzarti, scrivi le due strade su '
            'un foglio. Poi rileggile.'),
        isNull);

    // L'italiano che non esiste, e quello che esiste.
    expect(
        LeGuardieDelResponso.delTitolo('Ciò che puoi dare è te',
            domanda: ginocchio, forma: CourtesyForm.masculine),
        MotivoDelloScarto.sgrammaticato);
    expect(
        LeGuardieDelResponso.delTitolo('È te che riguarda',
            domanda: ginocchio, forma: CourtesyForm.masculine),
        isNull);
  });

  test('LE CURE DELLA RIPROVA A VIDEO DELLA 2260', () {
    // **IL TITOLO DI CASA SEGUE IL GENERE DELLA PERSONA**: a chi chiedeva
    // del figlio il telefono ha mostrato *"Chiedile come sta, davvero"*.
    final giorno = DateTime(2026, 9, 15);
    final alFemminile = RegExp(r'(?<![a-z])(?:[Dd]ille|[Cc]hiedile|le lasci|'
        r'tenuta|la pensi|volerle|[Ll]asciale)(?![a-z])');
    List<String> ventiquattro(String domanda) {
      final letti = <ResponsoLetto>[];
      final dati = <String>[];
      for (var i = 0; i < 24; i++) {
        final t = LaVoceDelMondoDiSotto.titoloDelGiorno('persona', giorno,
            letti: letti, domanda: domanda);
        dati.add(t);
        letti.insert(
            0, (tema: 'persona', titolo: t, risposta: null, gesto: null));
      }
      return dati;
    }

    final colFiglio = ventiquattro('Mio figlio non vuole più studiare');
    expect(colFiglio.toSet(), hasLength(24),
        reason: 'il mazzo resta di ventiquattro, anche al maschile');
    expect(colFiglio, contains('Chiedigli come sta, davvero'));
    expect(colFiglio.where(alFemminile.hasMatch), isEmpty);
    final conLaMoglie = ventiquattro('Mia moglie vuole un altro figlio');
    expect(conLaMoglie, contains('Chiedile come sta, davvero'));
    final conUnNome = ventiquattro('Ho litigato con Marco');
    expect(conUnNome.where(alFemminile.hasMatch), isEmpty);
    expect(
        conUnNome
            .where(RegExp(r'Digli|Chiedigli|gli lasci|Non è tenuto|lo pensi|'
                    r'volergli|Lasciagli')
                .hasMatch),
        isEmpty);
    expect(conUnNome.toSet(), hasLength(24),
        reason: 'col genere che non si sa il mazzo resta di ventiquattro');
    expect(conUnNome, contains('Chiedi come sta, davvero'));

    // **LA RISPOSTA CHE NOMINA LA TESTA DI UN PEZZO DELLA SCENA**: *"un
    // seme"* sopra *"il seme"*. La parola della domanda non conta.
    expect(
        LeGuardieDelResponso.dellaRisposta(
            'La paura di invecchiare è un seme che puoi non piantare.',
            domanda: 'Ho paura di invecchiare senza nessuno',
            forma: CourtesyForm.masculine,
            nomiDellaScena: const ['il ponte', 'il seme', "all'alba"]),
        MotivoDelloScarto.anticipaLaScena);
    expect(
        LeGuardieDelResponso.dellaRisposta(
            'Puoi decidere tu cosa tenere della casa.',
            domanda: 'Devo vendere la casa di famiglia',
            forma: CourtesyForm.masculine,
            nomiDellaScena: const [
              'la casa vuota',
              'la chiave',
              'nella notte'
            ]),
        isNull);

    // **LA MINUSCOLA DOPO IL PUNTO**, e i tre puntini che restano.
    expect(
        LeGuardieDelResponso.dellAzione(
            'Oggi pomeriggio. prendi un foglio e disegna una porta.',
            domanda: 'Sto pensando di separarmi',
            forma: CourtesyForm.masculine),
        MotivoDelloScarto.sgrammaticato);
    expect(
        LeGuardieDelResponso.dellAzione(
            'Oggi pomeriggio prendi un foglio e disegna una porta.',
            domanda: 'Sto pensando di separarmi',
            forma: CourtesyForm.masculine),
        isNull);

    // **NELL'ATTESA NESSUNA RISPOSTA DI CASA DICE "LEI"**: dopo la
    // ripresa *"la domanda su tuo figlio"* la si legge su una donna.
    expect(
        LaVoceDelMondoDiSotto.rispostePerTema['attesa']!
            .where(RegExp(r'(?<![a-z])lei(?![a-z])').hasMatch),
        isEmpty);

    // **IL GERGO DEI TITOLI**: *"Cerca il tuo spazio"*.
    expect(
        LeGuardieDelResponso.delTitolo('Cerca il tuo spazio',
            domanda: 'Mi sento ferma nel lavoro da mesi',
            forma: CourtesyForm.feminine),
        MotivoDelloScarto.gergo);

    // **VENDERE LA CASA, CON L'ARTICOLO**, e' una domanda grave.
    expect(
        LeGuardieDelResponso.dellAzione(
            'Stasera scrivi le due strade su un foglio. '
            'Scegli quella che ti pesa meno.',
            domanda: 'Devo vendere la casa dei nonni',
            forma: CourtesyForm.masculine),
        MotivoDelloScarto.decisioneGrave);

    // **LA SCENA DI RISERVA EVITA IL PEZZO CHE LA RISPOSTA NOMINA SENZA
    // L'ARTICOLO**: *"sul ponte"* e il pezzo *"il ponte"*. Il cardinale:
    // senza quella risposta il ponte esce.
    final animale = GuideAnimalDerivation.forSign(Zodiac.cancer);
    int colPonte(TestiDelModello scritti) {
      var n = 0;
      for (var d = 0; d < 40; d++) {
        final r = IlResponsoDelViaggio.componi(
          dalModello: null,
          domanda: 'Non so se accettare quel lavoro',
          giorno: DateTime(2026, 9, 1 + d % 28),
          nitidezza: 1,
          discesa: d,
          giaOggi: 0,
          animale: animale,
          tema: TemaDellaDomanda.scelta,
          storia: const [],
          scritti: scritti,
        );
        if (LaVoceDelMondoDiSotto.nomiDeiPezzi(r.scena).contains('il ponte')) {
          n++;
        }
      }
      return n;
    }

    expect(colPonte(TestiDelModello.nessuno), greaterThan(0));
    expect(
        colPonte(const TestiDelModello(
            risposta: 'Puoi restare un poco sul ponte, prima di scegliere.')),
        0);
  });

  test('LA RICHIESTA DICE AL MODELLO QUANDO LA DOMANDA PARLA DI UN ALTRO', () {
    // **ORDINE DN VOCE 08**: senza, la regola in positivo scartava quasi
    // tutte le risposte del modello sulle domande che parlano di un'altra
    // persona.
    String richiesta(String d) => LaScenaDalModello.richiesta(CioCheSiSa(
          domanda: d,
          tema: null,
          animale: GuideAnimalDerivation.forSign(Zodiac.cancer),
          natale: const NatalContext(),
          memoria: '',
          ultimeScene: const [],
        ));
    expect(richiesta('Mia sorella diventerà presto mamma?'),
        contains("La domanda parla di un'altra persona"));
    expect(richiesta('Mi trasferisco a Berlino o resto qui'),
        isNot(contains("La domanda parla di un'altra persona")));
  });

  test('SENZA OGGETTO LA RICHIESTA NON NE PARLA, e con l\'oggetto lo nomina',
      () {
    // Con *"non noto"* il modello scriveva *"Quel 'non noto' che e'
    // finito"*: la prova a cento discese col modello vero.
    CioCheSiSa s(String? oggetto) => CioCheSiSa(
          domanda: domanda,
          tema: TemaDellaDomanda.attesa.inLettere,
          animale: GuideAnimalDerivation.forSign(Zodiac.cancer),
          natale: const NatalContext(),
          memoria: '',
          ultimeScene: const [],
          oggetto: oggetto,
        );
    final senza = LaScenaDalModello.richiesta(s(null));
    expect(senza, isNot(contains('non noto')));
    expect(senza, isNot(contains('Oggetto della domanda')));
    expect(LaScenaDalModello.richiesta(s('tua sorella')),
        contains('Oggetto della domanda: tua sorella'));
  });

  group('I TESTI DEL MODELLO NEL RESPONSO E NEL DIARIO', () {
    test(
        'prendono il posto di quelli di casa, e il Diario conserva quelli e '
        'la loro fonte', () {
      final animale = GuideAnimalDerivation.forSign(Zodiac.cancer);
      const scritti = TestiDelModello(
        titolo: 'Quello che cerchi è vicino',
        risposta: 'Quella notizia spetta a tua sorella.',
        azione: 'Stasera scrivi a tua sorella una riga, senza domande.',
      );
      final r = IlResponsoDelViaggio.componi(
        dalModello: null,
        domanda: domanda,
        giorno: DateTime(2026, 9, 14),
        nitidezza: 1,
        discesa: 0,
        giaOggi: 0,
        animale: animale,
        tema: TemaDellaDomanda.attesa,
        storia: const [],
        scritti: scritti,
        oggetto: 'tua sorella',
        fontiGiaNote: const {'tema': 'modello'},
      );
      expect(r.titolo, scritti.titolo);
      expect(r.paragrafi[0], scritti.risposta);
      // La cucitura mette la minuscola dopo i due punti dell'apertura.
      expect(r.paragrafi[1],
          endsWith('stasera scrivi a tua sorella una riga, senza domande.'));
      expect(r.fonti, {
        'scena': 'riserva',
        'titolo': 'modello',
        'risposta': 'modello',
        'gesto': 'modello',
        'tema': 'modello',
      });
      final v = r.comeSiConserva(
          quando: DateTime(2026, 9, 14),
          domanda: domanda,
          temaDellaDomanda: 'attesa',
          animaleSeguito: animale.name,
          nitidezza: 1);
      final riletto = UnViaggio.fromJson(v.toJson())!;
      expect(riletto.titolo, scritti.titolo);
      expect(riletto.risposta, scritti.risposta);
      expect(riletto.gesto, scritti.azione);
      expect(riletto.oggetto, 'tua sorella');
      expect(riletto.fonti['gesto'], 'modello');
    });

    test('un testo scartato lascia la riserva, e la fonte dice perché', () {
      final animale = GuideAnimalDerivation.forSign(Zodiac.cancer);
      final letti = LeGuardieDelResponso.leggi({
        'titolo': 'Quello che cerchi è vicino',
        'risposta': 'Tua sorella avrà un bambino.',
        'azione': 'Affronta tua sorella stasera.',
      }, domanda: domanda, forma: neutra);
      final r = IlResponsoDelViaggio.componi(
        dalModello: null,
        domanda: domanda,
        giorno: DateTime(2026, 9, 14),
        nitidezza: 1,
        discesa: 0,
        giaOggi: 0,
        animale: animale,
        tema: TemaDellaDomanda.attesa,
        storia: const [],
        scritti: letti,
      );
      expect(r.fonti['titolo'], 'modello');
      expect(r.fonti['risposta'], 'riserva: previsioneCerta');
      expect(r.fonti['gesto'], 'riserva: toccaUnTerzo');
      expect(r.paragrafi[0], isNot(contains('avrà')));
    });
  });

  test('LE FONTI DEL TEMPO SI CONTANO PER PEZZO', () {
    // **LA GRANDEZZA E' IL PEZZO CHE PORTA IL TEMPO, NON LA PAROLA**: *"nei
    // prossimi tre giorni"* e' un tempo solo e fa due riscontri, e il gesto
    // *"dormici una notte e rileggi domattina"* e' autosufficiente, come lo
    // chiama l'ordine. Il difetto della build 2250 era un tempo nel gesto e
    // un altro nel quando.
    expect(
        _fontiDelTempo(
            'Una cosa sola: esci a camminare. Nei prossimi tre giorni.'),
        1);
    expect(
        _fontiDelTempo(
            'Una cosa sola: dormici una notte e rileggi questa riga domattina.'),
        1);
    expect(
        _fontiDelTempo(
            'Una cosa sola: dormici una notte e rileggi questa riga domattina. Entro stasera.'),
        2);
    expect(_fontiDelTempo('Il passo di oggi: esci a camminare. Entro stasera.'),
        2);
    expect(
        _fontiDelTempo(
            'Il passo di oggi: datti tre giorni. Alla fine scegli comunque.'),
        2);
  });

  test(
      'NESSUN RESPONSO DICE DUE TEMPI, su trecento discese per tema e senza '
      'tema. Ordine DL voce 10 e ordine DN voce 08', () {
    final animale = GuideAnimalDerivation.forSign(Zodiac.cancer);
    final doppi = <String>[];
    final titoliConLaScena = <String>[];
    final sporchi = <String>[];
    var guardati = 0;
    var colTempoProprio = 0;
    for (final tema in [...TemaDellaDomanda.values, null]) {
      final storia = <UnViaggio>[];
      for (var i = 0; i < 300; i++) {
        final giorno = DateTime(2026, 9, 14).add(Duration(days: i));
        final d = tema == null ? '' : 'Una domanda sul tema ${tema.name}';
        final r = IlResponsoDelViaggio.componi(
          dalModello: null,
          domanda: d,
          giorno: giorno,
          nitidezza: 1,
          discesa: i,
          giaOggi: 0,
          animale: animale,
          tema: tema,
          storia: storia,
        );
        final gesto = r.paragrafi[1];
        guardati++;
        if (LaVoceDelMondoDiSotto.gestiColTempo.any((g) =>
            gesto.toLowerCase().contains(g.toLowerCase().substring(1)))) {
          colTempoProprio++;
        }
        // **E NEL RESPONSO INTERO**, ordine DN voce 08, punto 9: la coda
        // della risposta e la scena da dove viene non aggiungono un tempo a
        // quello del gesto. Il titolo e' fuori dal conto: i titoli di casa li
        // ha scritti il fondatore, e gli otto col tempo stanno nel rapporto.
        final coda = LaVoceDelMondoDiSotto.codaDellaRisposta
            .any((c) => r.paragrafi[0].endsWith(c) && _conTempo(c));
        final daDove = _conTempo(r.paragrafi[2]);
        final tempi = _fontiDelTempo(gesto) + (coda ? 1 : 0) + (daDove ? 1 : 0);
        if (tempi > 1) {
          doppi.add('$gesto | ${r.paragrafi[0]} | ${r.paragrafi[2]}');
        }
        // **LA VOCE DI CASA E' PULITA**, ordine DN voce 08, punti 2, 4, 5 e
        // 6: il titolo non nomina un pezzo della scena, e nessun testo
        // accende, fa gergo o ordina una decisione grave.
        if (LeGuardieDelResponso.titoloToccaLaScena(
            r.titolo, LaVoceDelMondoDiSotto.nomiDeiPezzi(r.scena))) {
          titoliConLaScena.add('${r.titolo} | ${r.scena.idDeiPezzi}');
        }
        for (final b in [r.titolo, r.paragrafi[0], r.paragrafi[1]]) {
          final motivo = LeGuardieDelResponso.fuocoGergoDecisione(b);
          if (motivo != null) sporchi.add('${motivo.name}: $b');
        }
        // **DALLA RIPROVA A VIDEO DELLA 2255**: la persona non aspettava
        // nessuno, e la coda non ripete una parola della risposta.
        if (r.paragrafi[0].contains('Giù ti aspettava quella persona')) {
          sporchi.add('la persona che aspetta: ${r.paragrafi[0]}');
        }
        for (final c in LaVoceDelMondoDiSotto.codaDellaRisposta) {
          if (!r.paragrafi[0].endsWith(c)) continue;
          final prima =
              r.paragrafi[0].substring(0, r.paragrafi[0].length - c.length);
          if (_radici5(c).intersection(_radici5(prima)).isNotEmpty) {
            sporchi.add('la coda ripete: ${r.paragrafi[0]}');
          }
        }
        storia.insert(
            0,
            r.comeSiConserva(
                quando: giorno,
                domanda: d,
                temaDellaDomanda: tema?.name ?? '',
                animaleSeguito: animale.name,
                nitidezza: 1));
        if (storia.length > 60) storia.removeLast();
      }
    }
    // **IL CARDINALE**: settecento responsi, e fra loro i gesti che il
    // tempo lo portano dentro, che sono quelli che la voce prende.
    expect(guardati, 2100);
    expect(colTempoProprio, greaterThan(100));
    expect(doppi, isEmpty,
        reason: '${doppi.length} responsi con due tempi, per esempio:\n'
            '${doppi.take(5).join('\n')}');
    expect(titoliConLaScena, isEmpty,
        reason: 'titoli che nominano un pezzo della scena:\n'
            '${titoliConLaScena.take(5).join('\n')}');
    expect(sporchi, isEmpty, reason: sporchi.take(5).join('\n'));
  });
}

Set<String> _radici5(String s) => {
      for (final m in RegExp('[a-zàèéìòù]{5,}').allMatches(s.toLowerCase()))
        m.group(0)!.substring(0, 5),
    };

bool _conTempo(String s) => LeGuardieDelResponso.indicazioneDiTempo.hasMatch(s);

/// **QUANTI PEZZI DEL PARAGRAFO DEL GESTO DICONO UN TEMPO**: l'apertura, il
/// gesto e il quando. Ordine DL voce 10: *"nessun responso ha due
/// indicazioni di tempo"*.
int _fontiDelTempo(String paragrafo) {
  final p = paragrafo.trim();
  final basso = p.toLowerCase();
  String? apre;
  for (final a in LaVoceDelMondoDiSotto.apreIlGesto) {
    final senza = a.substring(0, a.length - 1).toLowerCase();
    if (basso.startsWith(senza)) apre = a;
  }
  String? quando;
  for (final q in LaVoceDelMondoDiSotto.quando) {
    if (basso.endsWith(q.toLowerCase())) quando = q;
  }
  var resto = p.substring(apre == null ? 0 : apre.length);
  if (quando != null) resto = resto.substring(0, resto.length - quando.length);
  bool conTempo(String? s) =>
      s != null && LeGuardieDelResponso.indicazioneDiTempo.hasMatch(s);
  return [conTempo(apre), conTempo(resto), conTempo(quando)]
      .where((x) => x)
      .length;
}
