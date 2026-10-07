// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/il_filo_del_consulto.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/services/ai/maestro_persona.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **IL FILO DEL CONSULTO. Ordine FE voci 08-14.**
///
/// Il tester: a piu' domande di fila il Maestro dava pareri nuovi e
/// scollegati, e se riprendeva una frase che il Maestro gli aveva appena
/// suggerito, il Maestro rispondeva un'altra cosa. Questa prova misura la
/// memoria unica del consulto: la scheda dei punti fermi scritta dal codice,
/// la legge della coerenza in un punto solo, il parere del primo Maestro che
/// arriva al secondo, la frase ripresa riconosciuta, l'ora di vita, e
/// l'istruzione di base che non cambia senza un consulto.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  var ora = DateTime(2026, 10, 6, 10);

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    IlFiloDelConsulto.dimentica();
    ora = DateTime(2026, 10, 6, 10);
    IlFiloDelConsulto.adesso = () => ora;
  });

  const rispostaDiMedora = 'Il cielo di questo mese ti chiede pazienza: '
      'Saturno rallenta le decisioni sul lavoro. Prima di chiedere la '
      'promozione, prepara con cura i tuoi risultati.\n'
      '✦ Aspetta la fine del mese prima di chiedere il colloquio.';

  test('il primo turno apre la scheda: tema e parere scritti dal codice', () {
    IlFiloDelConsulto.annota(
        maestro: Maestro.medora,
        domanda: 'Quando riceverò una promozione?',
        risposta: rispostaDiMedora);
    final s = IlFiloDelConsulto.scheda!;
    expect(s.tema, 'Quando riceverò una promozione?');
    expect(s.daMaestro, Maestro.medora);
    // Lapide dell'ordine FE voce 17: il nucleo porta la prima frase (la
    // risposta col suo tempo) e la riga del consiglio; prima solo la riga.
    expect(
        s.pareri.single.parere,
        'Il cielo di questo mese ti chiede pazienza: Saturno rallenta le '
        'decisioni sul lavoro. Aspetta la fine del mese prima di chiedere il '
        'colloquio.');
  });

  test("col tema gia' nella storia lo stesso Maestro non riceve la scheda", () {
    // Ordine FE voce 20: le righe ripeterebbero cio' che il modello legge.
    IlFiloDelConsulto.annota(
        maestro: Maestro.medora,
        domanda: 'Quando riceverò una promozione?',
        risposta: rispostaDiMedora);
    final storia = [
      const ChatMessage(
          role: ChatRole.user, text: 'Quando riceverò una promozione?'),
      const ChatMessage(role: ChatRole.maestro, text: rispostaDiMedora),
    ];
    final stesso = IlFiloDelConsulto.bloccoPer(Maestro.medora, storia: storia);
    expect(stesso, isNot(contains('IL FILO DEL CONSULTO')));
    expect(stesso, contains(LaLeggeDellaCoerenza.testo));
    // Ordine FE voce 17, percorso E: Calìgo estraeva una runa nuova a ogni
    // domanda e il consiglio si rovesciava con lei.
    expect(stesso, contains('non ne estrai uno nuovo a ogni domanda'));
    // Senza la storia la scheda serve, e parte.
    expect(IlFiloDelConsulto.bloccoPer(Maestro.medora),
        contains('IL FILO DEL CONSULTO'));
    // Un altro Maestro la riceve sempre, anche con la storia.
    expect(IlFiloDelConsulto.bloccoPer(Maestro.caligo, storia: storia),
        contains('Medora ha detto'));
    print('ORDINE FE VOCE 20: blocco del filo con la storia '
        '${(stesso.length / 4).round()} token, senza '
        '${(IlFiloDelConsulto.bloccoPer(Maestro.medora).length / 4).round()}');
  });

  test('una digressione non cancella il parere sul tema', () {
    // Ordine FE voce 17, il percorso D del banco.
    IlFiloDelConsulto.annota(
        maestro: Maestro.aura,
        domanda: 'La mia relazione si è raffreddata: posso salvarla?',
        risposta: 'Il legame respira ancora.\n'
            '✦ Stasera parlale per dieci minuti senza telefono.');
    IlFiloDelConsulto.annota(
        maestro: Maestro.aura,
        domanda: 'Cambiando discorso: che cristallo per dormire meglio?',
        risposta: 'L\'ametista sul comodino.\n'
            '✦ Metti un\'ametista accanto al cuscino.');
    final s = IlFiloDelConsulto.scheda!;
    expect(
        s.pareri.single.parere,
        'Il legame respira ancora. Stasera parlale per dieci minuti senza '
        'telefono.');
    expect(
        IlFiloDelConsulto.bloccoPer(Maestro.aura), isNot(contains('ametista')));
  });

  test('il secondo Maestro riceve la scheda, la legge e la regola del primo',
      () {
    IlFiloDelConsulto.annota(
        maestro: Maestro.medora,
        domanda: 'Quando riceverò una promozione?',
        risposta: rispostaDiMedora);
    final perMedora = IlFiloDelConsulto.bloccoPer(Maestro.medora);
    final perCaligo = IlFiloDelConsulto.bloccoPer(Maestro.caligo);
    expect(perMedora, contains(LaLeggeDellaCoerenza.testo));
    expect(perMedora, isNot(contains('PRIMA DI TE HA GIÀ PARLATO')));
    expect(
        perCaligo,
        contains(
            'Medora ha detto: «Il cielo di questo mese ti chiede pazienza'));
    expect(
        perCaligo, contains(LaLeggeDellaCoerenza.ilSecondoMaestro(['Medora'])));
    expect(perCaligo, contains('comincia con il nome di Medora'));
    expect(perCaligo, contains('«Quando riceverò una promozione?»'));
    // Il parere di Caligo si aggiunge, quello di Medora resta.
    IlFiloDelConsulto.annota(
        maestro: Maestro.caligo,
        domanda: 'E le rune cosa dicono?',
        risposta: 'Le rune parlano di un passaggio.\n'
            '✦ Prima del colloquio scrivi su un foglio cosa vuoi ottenere.');
    expect(IlFiloDelConsulto.scheda!.maestri, [Maestro.medora, Maestro.caligo]);
    expect(IlFiloDelConsulto.scheda!.tema, 'Quando riceverò una promozione?');
    // **Il peso della scheda**, con due pareri e la frase ripresa.
    final blocco = IlFiloDelConsulto.bloccoPer(Maestro.aura,
        fraseRipresa: 'Prima di chiedere la promozione, prepara con cura i '
            'tuoi risultati.');
    final token = (blocco.length / 4).round();
    print('ORDINE FE VOCE 09: la scheda con due pareri e la frase ripresa '
        'pesa ${blocco.length} caratteri, circa $token token');
    expect(token, lessThan(450));
  });

  test('oltre l\'ora il consulto e\' nuovo e il Maestro non finge', () {
    IlFiloDelConsulto.annota(
        maestro: Maestro.medora,
        domanda: 'Quando riceverò una promozione?',
        risposta: rispostaDiMedora);
    ora = ora.add(const Duration(minutes: 59));
    expect(IlFiloDelConsulto.scheda, isNotNull);
    ora = ora.add(const Duration(minutes: 2));
    expect(IlFiloDelConsulto.scheda, isNull);
    expect(IlFiloDelConsulto.bloccoPer(Maestro.aura), isEmpty);
    IlFiloDelConsulto.annota(
        maestro: Maestro.aura,
        domanda: 'Mi sento stanca',
        risposta: 'Respira.');
    expect(IlFiloDelConsulto.scheda!.tema, 'Mi sento stanca');
  });

  test('senza consulto l\'istruzione di base non cambia di un carattere', () {
    for (final m in Maestro.values) {
      final senza = MaestroPersona.systemInstruction(
          maestro: m, profile: UserProfile.empty, memory: MaestroMemory.empty);
      final colFiloVuoto = MaestroPersona.systemInstruction(
          maestro: m,
          profile: UserProfile.empty,
          memory: MaestroMemory.empty,
          filo: IlFiloDelConsulto.bloccoPer(m));
      expect(colFiloVuoto, senza, reason: m.name);
    }
    // E con un consulto in corso il filo entra davvero nell'istruzione.
    IlFiloDelConsulto.annota(
        maestro: Maestro.medora,
        domanda: 'Quando riceverò una promozione?',
        risposta: rispostaDiMedora);
    final conFilo = MaestroPersona.systemInstruction(
        maestro: Maestro.aura,
        profile: UserProfile.empty,
        memory: MaestroMemory.empty,
        filo: IlFiloDelConsulto.bloccoPer(Maestro.aura));
    expect(conFilo, contains(LaLeggeDellaCoerenza.testo));
    expect(conFilo, contains('Medora ha detto'));
    // Ordine FE voce 17: il controllo del consulto sta in fondo, dopo il
    // controllo delle parole, e c'e' solo dentro un consulto.
    final controllo = conFilo.indexOf(LaLeggeDellaCoerenza.controlloFinale);
    expect(controllo, greaterThan(conFilo.indexOf('ULTIMO CONTROLLO DELLE')),
        reason: 'il controllo del consulto deve stare accanto al controllo '
            'finale, in fondo all\'istruzione');
    expect(
        MaestroPersona.systemInstruction(
            maestro: Maestro.aura,
            profile: UserProfile.empty,
            memory: MaestroMemory.empty),
        isNot(contains('ULTIMO CONTROLLO DEL CONSULTO')));
  });

  test('la frase ripresa si riconosce, una domanda nuova no', () {
    expect(
        LaFraseRipresa.trova(
            'Prepara con cura i tuoi risultati prima di chiedere la promozione?',
            rispostaDiMedora),
        'Prima di chiedere la promozione, prepara con cura i tuoi risultati.');
    // La persona la riprende a modo suo, con circa due terzi delle parole.
    expect(
        LaFraseRipresa.trova(
            'Come preparo con cura i miei risultati per la promozione?',
            rispostaDiMedora),
        'Prima di chiedere la promozione, prepara con cura i tuoi risultati.');
    expect(LaFraseRipresa.trova('E in amore come andrà?', rispostaDiMedora),
        isNull);
    expect(LaFraseRipresa.trova('Grazie', rispostaDiMedora), isNull);
  });

  test('la chat, il LIVE e il Consiglio leggono lo stesso filo', () {
    final p = File('lib/services/ai/firebase_maestro_ai_provider.dart')
        .readAsStringSync();
    expect(RegExp(r'filo: IlFiloDelConsulto\.bloccoPer\(').allMatches(p).length,
        greaterThanOrEqualTo(2),
        reason: 'il turno o il Consiglio non ricevono il filo');
    final c = File('lib/features/maestri/chat/maestro_chat_controller.dart')
        .readAsStringSync();
    expect(c, contains('IlFiloDelConsulto.annota('),
        reason: 'i turni non entrano nel filo');
  });
  // **IL CONTROLLO FINALE MIRATO**, ordine FE del 7 ottobre 2026. Al banco
  // del filo sul commit 297da8e7 Medora spostava "mercoledì" a "la
  // prossima settimana" e a "E se le cose non vanno come speri?" tre
  // risposte su dieci consolavano e basta. Il controllo porta il gesto vero
  // da tenere, e il fondatore non accetta aumenti di costo.
  group('il controllo finale mirato', () {
    const gestoDiMedora = '✦ Prepara un piccolo riassunto dei tuoi successi '
        'recenti e presentalo al tuo superiore nella giornata di mercoledì.';
    const promozione = [
      ChatMessage(role: ChatRole.user, text: 'Riceverò la promozione?'),
      ChatMessage(
          role: ChatRole.maestro,
          text: 'Il tuo cielo pende verso la promozione.\n\n$gestoDiMedora',
          autore: Maestro.medora),
    ];
    const conIlCristallo = [
      ...promozione,
      ChatMessage(
          role: ChatRole.user,
          text: 'Cambiando discorso: che cristallo mi consigli per dormire?'),
      ChatMessage(
          role: ChatRole.maestro,
          text: 'Non è la mia arte.\n\n✦ Guarda la Luna stasera.',
          autore: Maestro.medora),
    ];

    test('porta il gesto vero del Maestro, e lo sceglie sul tema giusto', () {
      expect(
          LaLeggeDellaCoerenza.controlloFinalePer(
              domanda: 'E in pratica, cosa faccio questa settimana?',
              storia: promozione),
          contains('«Prepara un piccolo riassunto dei tuoi successi recenti '
              'e presentalo al tuo superiore nella giornata di mercoledì.»'),
          reason: 'il controllo non dice quale gesto tenere: e\' la regola '
              'generica che al banco non bastava');
      expect(
          LaLeggeDellaCoerenza.ilTuoGesto(
              'Torniamo alla mia prima domanda. Cosa mi consigli?',
              conIlCristallo),
          contains('mercoledì'),
          reason: 'tornando al tema il gesto da tenere e\' quello di prima '
              'del cambio di discorso, non quello del cristallo');
      expect(
          LaLeggeDellaCoerenza.ilTuoGesto(
              'E quante volte a settimana?', conIlCristallo),
          'Guarda la Luna stasera.',
          reason: 'dopo il cambio di discorso il tema e\' quello nuovo');
      expect(
          LaLeggeDellaCoerenza.ilTuoGesto(
              'Cambiando discorso: e il mio cane?', conIlCristallo),
          isNull,
          reason: 'su un tema nuovo non c\'e\' un gesto da tenere');
    });

    test('le parole del ritorno al tema, e quelle che non lo sono', () {
      for (final torna in [
        'Torniamo alla mia prima domanda. Allora, cosa mi consigli di fare?',
        'torniamo al lavoro: cosa faccio?',
        'Tornando alla promozione, quando chiedo?',
        "Torno all'argomento di prima: che faccio?",
        'Riprendiamo il discorso sulla casa.',
        'Come dicevi, devo aspettare?',
        'Quello che mi hai detto vale anche per lei?',
        'E per il tema di prima?',
      ]) {
        expect(LaLeggeDellaCoerenza.tornaAlTema(torna), isTrue,
            reason: '«$torna» torna al tema e il filo non lo vede');
      }
      for (final nuova in [
        'Cambiando discorso: che cristallo mi consigli per dormire meglio?',
        'E in pratica, cosa faccio questa settimana?',
        'E se le cose non vanno come speri?',
        'Eccomi di nuovo, ci ho pensato. Da dove comincio, allora?',
        'Devo trasferirmi in un\'altra città per ricominciare?',
        'Il ritornello della canzone mi parla?',
      ]) {
        expect(LaLeggeDellaCoerenza.tornaAlTema(nuova), isFalse,
            reason: '«$nuova» non torna a un tema');
      }
    });

    test('le frasi di un turno solo partono solo in quel turno', () {
      final semplice = LaLeggeDellaCoerenza.controlloFinalePer(
          domanda: 'E in pratica, cosa faccio?', storia: promozione);
      expect(semplice, isNot(contains('non una consolazione generica')));
      expect(semplice, isNot(contains('io leggo diversamente')));
      final seVaMale = LaLeggeDellaCoerenza.controlloFinalePer(
          domanda: 'E se le cose non vanno come speri?', storia: promozione);
      expect(seVaMale, contains('non una consolazione generica'),
          reason: 'chi chiede cosa fare se va male non riceve la regola');
      expect(seVaMale, contains('rispondi dal tuo gesto'));
      expect(
          LaLeggeDellaCoerenza.controlloFinalePer(
              domanda: 'E tu cosa ne pensi?', conAltri: true),
          contains('io leggo diversamente'));
      for (final d in [
        'E se le cose non vanno come speri?',
        'E se non funziona?',
        'Se va male cosa faccio?',
        'E se mi dice di no?',
      ]) {
        expect(LaLeggeDellaCoerenza.chiedeSeVaMale(d), isTrue, reason: d);
      }
      for (final d in [
        'E in pratica, cosa faccio questa settimana?',
        'Se vado a Roma va bene?',
        'Non va bene il lunedì?',
      ]) {
        expect(LaLeggeDellaCoerenza.chiedeSeVaMale(d), isFalse, reason: d);
      }
    });

    test('nessun aumento di costo: il controllo non e\' piu\' lungo di prima',
        () {
      // **LAPIDE**: il controllo finale fino al 6 ottobre 2026, uguale a
      // ogni turno di ogni consulto. Il fondatore, 7 ottobre 2026: nessun
      // aumento di costo.
      const diPrima = 'ULTIMO CONTROLLO DEL CONSULTO: '
          'rileggi i punti fermi. La tua risposta non dice un tempo, una fase '
          'del cielo o una risposta diversi da quelli già dati senza dirlo: '
          'un tempo già indicato («entro la fine del mese», «stasera») resta '
          'quello, non lo anticipi e non lo sposti senza dire perché. Lo '
          'stesso per il gesto già consigliato: il mezzo (scrivere, chiamare, '
          'parlare di persona) e l’oggetto (il sigillo, la lettera, il dono) '
          'restano quelli; se ne aggiungi un altro lo presenti come il passo '
          'dopo, se lo cambi dici perché. Se la persona chiede che cosa fare '
          'se l’esito non è quello sperato, rispondi dal passo già dato: cosa '
          'fa dopo quel passo se va diversamente, non una consolazione '
          'generica. Se un altro Maestro ha parlato e tu leggi diversamente, '
          'la riga col suo nome lo dice con «io leggo diversamente» e il '
          'perché.';
      final conGesto = LaLeggeDellaCoerenza.controlloFinalePer(
          domanda: 'E in pratica, cosa faccio questa settimana?',
          storia: promozione);
      // Il turno normale peggiore: un gesto e un tempo lunghi quanto i loro
      // tetti (ordine FE, 7 ottobre 2026: il tempo entra nel controllo).
      final lungo = 'Scrivi ${'una parola ' * 40}'.trim();
      final rinvio = 'Non è ancora il momento ${'di una cosa ' * 20}'.trim();
      // E l'elemento uscito per nome, dal 7 ottobre 2026.
      const carte = 'L\'Arcano della Forza e il Due di Coppe.';
      final peggiore = LaLeggeDellaCoerenza.controlloFinalePer(
          domanda: 'E in pratica?',
          storia: [
            const ChatMessage(role: ChatRole.user, text: 'Devo partire?'),
            ChatMessage(
                role: ChatRole.maestro,
                text: '$rinvio. $carte\n\n✦ $lungo',
                autore: Maestro.medora),
          ]);
      print('ORDINE FE, il controllo finale: prima ${diPrima.length} '
          'caratteri a ogni turno, adesso ${conGesto.length} col gesto di '
          'Medora, ${peggiore.length} col gesto e il tempo piu\' lunghi');
      expect(peggiore, contains('Il tempo che hai dato'),
          reason: 'il caso peggiore deve portare anche il tempo');
      expect(peggiore.length, lessThanOrEqualTo(diPrima.length),
          reason: 'il controllo col gesto costa piu\' di quello di prima');
    });

    // **IL MAESTRO NON NEGA LA MEMORIA**, ordine FE del 7 ottobre 2026: al
    // banco Medora rispondeva "non ho la tua risposta precedente" con la
    // risposta li' nella conversazione.
    test('chi nega la memoria si riconosce e si corregge, nell\'app e al banco',
        () {
      for (final nega in [
        'Mi dispiace, ma non ho la tua risposta precedente. Se vuoi, puoi '
            'riscrivermela.',
        'CHIEDO\nMi dispiace, ma non ho la memoria della risposta precedente.',
        'Potresti riscrivermi l\'ultima parte della nostra conversazione?',
        'Non ricordo cosa ti ho detto prima.',
      ]) {
        expect(LaLeggeDellaCoerenza.negaLaMemoria(nega), isTrue,
            reason: '«$nega» nega la memoria e la rete non lo vede');
      }
      for (final buona in [
        'Come ti ho già detto, aspetta la fine del mese.',
        'La memoria del tuo cuore conserva la pace.',
        'Non ho dubbi: presentalo mercoledì.',
        'Riscrivi la lettera con calma.',
      ]) {
        expect(LaLeggeDellaCoerenza.negaLaMemoria(buona), isFalse,
            reason: '«$buona» non nega la memoria');
      }
      expect(LaLeggeDellaCoerenza.correzioneDellaMemoria('Scrivile oggi.'),
          contains('«Scrivile oggi.»'));
      final controllore =
          File('lib/features/maestri/chat/maestro_chat_controller.dart')
              .readAsStringSync();
      expect(controllore,
          contains('if (LaLeggeDellaCoerenza.negaLaMemoria(reply)'),
          reason: 'il turno della chat non passa piu\' dalla rete della '
              'memoria');
      final banco = File('tool/banchi_col_modello/'
              'il_filo_del_consulto_col_modello_test.dart')
          .readAsStringSync();
      expect(banco, contains('LaLeggeDellaCoerenza.negaLaMemoria(risposta)'),
          reason: 'il banco del filo non misura piu\' cio\' che fa l\'app');
    });

    // **L'ELEMENTO GIA' USCITO RESTA QUELLO**, ordine FE del 7 ottobre 2026:
    // al giro finale dei banchi Calìgo ha estratto Nauthiz al posto di Isa.
    // **SI PREVIENE, NON SI CORREGGE**, decisione del fondatore dello stesso
    // giorno: la rete che correggeva e' tolta (le risposte corrette erano
    // bocciate nel 27 per cento dei casi contro il 6), l'elemento arriva per
    // nome nel controllo finale, e il banco conta i cambi.
    test('la runa o la carta cambiata si conta, e si previene', () {
      const relazione = [
        ChatMessage(
            role: ChatRole.user,
            text: 'La mia relazione si è raffreddata: posso ancora salvarla?'),
        ChatMessage(
            role: ChatRole.maestro,
            text: 'Recupera la passione. La runa Isa indica una fase di '
                'stasi. Non temere la quiete.\n✦ Dì una parola che non hai '
                'mai avuto il coraggio di dire, entro domani.',
            autore: Maestro.caligo),
      ];
      final c = LaLeggeDellaCoerenza.elementoCambiato(
          domanda: 'E cosa devo evitare?',
          risposta: 'Evita l\'inerzia. La runa Nauthiz ti avverte contro '
              'l\'attesa passiva.',
          storia: relazione);
      expect(c, isNotNull,
          reason: 'Calìgo cambia la runa del consulto e nessuno lo vede');
      expect(c!.prima, {'Isa'});
      expect(c.adesso, {'Nauthiz'});
      expect(
          LaLeggeDellaCoerenza.controlloFinalePer(
              domanda: 'E cosa devo evitare?', storia: relazione),
          contains('L’elemento uscito qui è Isa: lo rileggi'),
          reason: 'il Maestro non sa quale runa e\' uscita e ne estrae '
              'un\'altra: si previene dicendogliela');
      expect(
          LaLeggeDellaCoerenza.elementoCambiato(
              domanda: 'E cosa devo evitare?',
              risposta: 'Isa ti chiede di non forzare il ghiaccio.',
              storia: relazione),
          isNull,
          reason: 'la runa riletta non e\' un cambio');
      // Le carte di Medora, e il suo cielo che non e' una carta.
      const promozione = [
        ChatMessage(role: ChatRole.user, text: 'Riceverò la promozione?'),
        ChatMessage(
            role: ChatRole.maestro,
            text: 'L\'Arcano della Forza ti chiede pazienza. Il Sole in '
                'Gemelli ti aiuta.\n✦ Scrivi tre successi.',
            autore: Maestro.medora),
      ];
      expect(
          LaLeggeDellaCoerenza.elementoCambiato(
                  domanda: 'E in pratica?',
                  risposta: 'Il Due di Coppe ti invita a cercare alleati.',
                  storia: promozione)
              ?.adesso,
          {'Due di Coppe'});
      expect(
          LaLeggeDellaCoerenza.elementoCambiato(
              domanda: 'E in pratica?',
              risposta: 'La Forza resta la tua carta: la Luna in Bilancia '
                  'ti dice di parlarne venerdì.',
              storia: promozione),
          isNull,
          reason: 'il cielo di Medora non e\' una carta estratta');
      expect(LaLeggeDellaCoerenza.elementiIn('Il Sole in Gemelli, la Luna'),
          isEmpty);
      final controllore =
          File('lib/features/maestri/chat/maestro_chat_controller.dart')
              .readAsStringSync();
      expect(controllore, isNot(contains('elementoCambiato(')),
          reason: 'il turno della chat corregge di nuovo l\'elemento: la '
              'rete e\' stata tolta perche\' peggiorava le risposte');
      final banco = File('tool/banchi_col_modello/'
              'il_filo_del_consulto_col_modello_test.dart')
          .readAsStringSync();
      expect(banco, contains('elemento cambiato in \$cambiati risposte su '),
          reason: 'il banco del filo non conta piu\' i cambi di elemento');
    });

    // **IL TEMPO GIA' DATO**, ordine FE del 7 ottobre 2026: cinque
    // contraddizioni su otto nei giri del filo erano un tempo anticipato.
    test('il tempo dato prima arriva nel controllo, e il cielo di oggi no', () {
      const progetto = [
        ChatMessage(role: ChatRole.user, text: 'Avvio il mio progetto?'),
        ChatMessage(
            role: ChatRole.maestro,
            text: 'Avviare un progetto richiede una visione chiara. Non è '
                'ancora il momento di gettare le basi, ma di pianificare.\n'
                '✦ Scrivi un elenco dei materiali, questo pomeriggio.',
            autore: Maestro.medora),
      ];
      expect(LaLeggeDellaCoerenza.ilTuoTempo('Da dove comincio?', progetto),
          'Non è ancora il momento di gettare le basi, ma di pianificare.');
      final controllo = LaLeggeDellaCoerenza.controlloFinalePer(
          domanda: 'Da dove comincio?', storia: progetto);
      expect(
          controllo,
          contains('«Non è ancora il momento di gettare le basi, ma di '
              'pianificare.»: resta quello'),
          reason: 'il Maestro non sa quale tempo tenere e lo anticipa');
      expect(controllo, startsWith(LaLeggeDellaCoerenza.controlloCorto));
      for (final rimanda in [
        'Aspetta la fine del mese.',
        'Tra due giorni scrivile.',
        'Presentalo al prossimo plenilunio.',
        'Chiedi un incontro il prossimo mercoledì.',
      ]) {
        expect(
            LaLeggeDellaCoerenza.ilTuoTempo('E poi?', [
              const ChatMessage(role: ChatRole.user, text: 'Che faccio?'),
              ChatMessage(
                  role: ChatRole.maestro,
                  text: rimanda,
                  autore: Maestro.medora),
            ]),
            isNotNull,
            reason: '«$rimanda» rimanda e il controllo non lo vede');
      }
      expect(
          LaLeggeDellaCoerenza.ilTuoTempo('E poi?', [
            const ChatMessage(role: ChatRole.user, text: 'Che faccio?'),
            const ChatMessage(
                role: ChatRole.maestro,
                text: 'Il Sole in Gemelli ti aiuta. Scrivile oggi.',
                autore: Maestro.medora),
          ]),
          isNull);
    });
  });
}
