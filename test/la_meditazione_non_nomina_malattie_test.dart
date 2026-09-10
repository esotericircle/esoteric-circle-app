import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';
import 'sorgenti_di_lib.dart';

/// **IL CONFINE, CHE NON E' UN DISCLAIMER.** Ordine DB voce 11, 9 settembre
/// 2026.
///
/// **Parole dell'ordine**: *"Non e' una nota legale in fondo a una schermata:
/// e' una regola di prodotto, e vale su ogni testo di questa funzione, tooltip,
/// notifiche e risposte dei Maestri comprese."*
///
/// **LA RAGIONE NON E' LA PRUDENZA, ed e' scritta nell'ordine.** Le linee guida
/// di Apple al punto 1.4.1 colpiscono le applicazioni che offrono trattamenti
/// inaccurati, e **questa app ha gia' subito un rifiuto su iOS**. Una schermata
/// di benessere che elenca condizioni da trattare e' un dispositivo medico non
/// certificato.
///
/// **REGOLA H, ed e' l'ordine a chiederla per nome**: *"monta una guardia sotto
/// la Regola H che cade se una parola di un vocabolario clinico dichiarato
/// compare in un testo di questa funzione, e che dimostra l'assenza in tutti i
/// punti invece della presenza in uno"*. Per questo la guardia non guarda un
/// file: **scopre tutti i file della funzione** e dichiara quanti ne ha
/// guardati, cosi' un file nuovo entra nella rete da solo.
///
/// **IL VOCABOLARIO E' DICHIARATO**, come l'ordine pretende, e sta nella
/// costante qui sotto: sono le parole con cui questa materia promette di
/// solito, piu' le parti del corpo che una app di frequenze elenca sempre.
/// **REGOLA D, E IL VOCABOLARIO SI E' ACCORCIATO DI TRE PAROLE.** Ordine DD
/// voce 12, 10 settembre 2026: `sintomo`, `sintomi` e `insonnia` non sono piu'
/// vietate, per decisione del fondatore, perche' **il confine sta nel verbo e
/// non nel sostantivo**. La ragione per esteso sta dentro il vocabolario, dove
/// chi legge una caduta la trova.
///
/// **E la prova in fondo pretende che quelle tre parole ci siano davvero dove
/// l'ordine le vuole**: un permesso concesso e non usato sarebbe un buco
/// aperto per niente.
void main() {
  /// **IL VOCABOLARIO CLINICO.** Diviso per famiglie, cosi' chi legge una
  /// caduta capisce subito di che tipo di sconfinamento si tratta.
  const vocabolario = <String, List<String>>{
    'promesse di guarigione': [
      'guarisc', 'guarigione', 'guarire', 'curare', 'cura del', 'terapia',
      'terapeutic', 'risana', 'risanare', 'sana il', 'rimedio',
    ],
    // **IL CONFINE SI E' SPOSTATO DAL SOSTANTIVO AL VERBO.** Ordine DD voce
    // 12, 10 settembre 2026, decisione del fondatore scritta per esteso:
    // *"il confine sta nel verbo, non nel sostantivo. Si scrive 'per le sere
    // in cui il sonno non arriva', non 'cura l'insonnia'. Si scrive 'per
    // quando la testa non si ferma', non 'elimina l'ansia'. Insonnia e ansia
    // vanno bene"*.
    //
    // **Perche' il cambio non allarga il permesso, lo stringe.** Vietare i
    // sostantivi teneva la libreria muta su cio' che la persona cerca, e la
    // costringeva a girare fra nomi sanscriti. **Il rischio davanti ad Apple
    // non e' nominare l'insonnia: e' promettere di curarla**, e il punto
    // 1.4.1 colpisce i trattamenti inaccurati, non le parole comuni.
    //
    // **COSA E' USCITO DA QUESTO ELENCO, e va detto per nome**: `sintomo`,
    // `sintomi` e `insonnia`. Sono le tre parole che l'ordine DD voce 12
    // ammette: la libreria si apre con **SCEGLI SINTOMO E FREQUENZA** e la
    // pratica dei due toni risponde al sintomo **Insonnia**.
    //
    // **COSA NON E' USCITO**, ed e' la parte che regge: `malattia`,
    // `disturbo`, `diagnosi`, `patologia`, e tutte le promesse di guarigione
    // qui sopra. Nominare uno stato e' lecito; **dire che lo si cura, no**.
    'condizioni e sintomi': [
      'malattia', 'malattie', 'disturbo', 'disturbi',
      'diagnosi', 'patologia', 'infiammazion', 'depression',
      'ansia patologica', 'emicrania', 'dolore cronico',
    ],
    'parti del corpo da trattare': [
      'fegato', 'reni', 'intestino', 'tiroide', 'pressione sanguigna',
      'sistema immunitario', 'ossa', 'articolazion',
    ],
    'effetti fisiologici promessi': [
      'ripara il dna', 'riparazione del dna', 'abbassa la pressione',
      'toglie il dolore', 'riduce il dolore', 'effetto sul corpo',
      'battito cardiaco scende', 'rallenta il battito',
    ],
  };

  /// **I FILE DELLA FUNZIONE**, scoperti e non elencati a mano: la Meditazione
  /// vive in due cartelle, e i testi che la riguardano stanno in tutte e due.
  List<File> fileDellaMeditazione() {
    final trovati = <File>[];
    for (final cartella in const [
      'lib/features/maestri/aura/meditation',
      'lib/core/sensi',
    ]) {
      final d = Directory(cartella);
      if (!d.existsSync()) continue;
      for (final f in d.listSync(recursive: true)) {
        if (f is File && f.path.endsWith('.dart')) trovati.add(f);
      }
    }
    // E i file del cuore che parlano di respiro e di centri, ovunque stiano.
    for (final nome in const [
      'lib/core/maestro/memoria_del_respiro.dart',
      'lib/core/maestro/cio_che_aura_ricorda.dart',
      'lib/core/maestro/frequenza_del_giorno.dart',
      'lib/core/maestro/chakra_del_giorno.dart',
      'lib/core/maestro/colore_del_centro.dart',
      'lib/core/maestro/traccia_del_loto.dart',
    ]) {
      final f = File(nome);
      if (f.existsSync()) trovati.add(f);
    }
    return trovati;
  }

  test('NESSUN TESTO DELLA MEDITAZIONE NOMINA UNA MALATTIA', () {
    final file = fileDellaMeditazione();
    cardinaleMinimo(file.length, 6,
        cosa: 'file della Meditazione guardati',
        perche: 'Se la scoperta trovasse pochi file questa guardia sarebbe '
            'verde per non aver guardato quasi niente, ed e proprio la '
            'famiglia che l ordine CM ha reso vietata.');

    final sconfinamenti = <String>[];
    var stringheGuardate = 0;
    for (final f in file) {
      final sorgente = f.readAsStringSync();
      // **SI GUARDANO LE STRINGHE MOSTRATE, non i commenti.** In un commento
      // la parola "guarigione" puo' comparire proprio per spiegare che non si
      // promette: accusarla sarebbe l asserzione che pesca il proprio
      // commento, la famiglia che questo progetto ha gia' pagato undici volte.
      final codice = senzaCommenti(sorgente);
      for (final riga in codice.split('\n')) {
        if (!riga.contains("'")) continue;
        stringheGuardate++;
        final basso = riga.toLowerCase();
        for (final famiglia in vocabolario.entries) {
          for (final parola in famiglia.value) {
            if (basso.contains(parola)) {
              sconfinamenti.add(
                  '${f.path}: "$parola" (${famiglia.key}) nella riga '
                  '${riga.trim()}');
            }
          }
        }
      }
    }
    // ignore: avoid_print
    print('ORDINE DB VOCE 11: file guardati ${file.length}, righe con testo '
        '$stringheGuardate, sconfinamenti ${sconfinamenti.length}');
    cardinaleMinimo(stringheGuardate, 40,
        cosa: 'righe con testo nella Meditazione',
        perche: 'Con poche righe la guardia direbbe che il confine e '
            'rispettato per non aver letto quasi nessun testo.');
    expect(sconfinamenti, isEmpty,
        reason: 'la Meditazione nomina condizioni o promette effetti: '
            '${sconfinamenti.join(" | ")}. Le linee guida di Apple al punto '
            '1.4.1 colpiscono le app che offrono trattamenti inaccurati, e '
            'questa app ha gia subito un rifiuto su iOS');
  });

  test('REGOLA H: e il vocabolario funziona davvero', () {
    // **L ALTRA META.** Un vocabolario scritto male passerebbe qualunque
    // testo: qui si prova che le parole vietate vengano davvero riconosciute,
    // altrimenti la prova di sopra e verde perche non cerca niente.
    const finti = [
      'Questa pratica guarisce l insonnia.',
      'Abbassa la pressione sanguigna in dieci minuti.',
      'Ripara il DNA e toglie il dolore.',
      'Agisce sul fegato e sui reni.',
    ];
    for (final testo in finti) {
      final basso = testo.toLowerCase();
      var presa = false;
      for (final famiglia in vocabolario.values) {
        for (final parola in famiglia) {
          if (basso.contains(parola)) presa = true;
        }
      }
      expect(presa, isTrue,
          reason: 'il vocabolario non riconosce "$testo": la guardia di sopra '
              'e verde perche non sa cosa cercare');
    }
  });

  test('REGOLA H: LE TRE PAROLE AMMESSE SONO USATE DOVE L ORDINE LE VUOLE', () {
    // **Il permesso si e ristretto a tre parole, e serve a due punti precisi.**
    // Se domani sparissero da li, il vocabolario resterebbe piu corto senza
    // che nessuno ne abbia piu bisogno: un buco aperto per niente.
    final pannello = File('lib/features/maestri/aura/meditation/'
            'pannello_della_libreria.dart')
        .readAsStringSync();
    final libreria =
        File('lib/core/maestro/libreria_dei_respiri.dart').readAsStringSync();
    // ignore: avoid_print
    print('ORDINE DD VOCE 12: il pulsante nomina il sintomo '
        '${pannello.contains('SCEGLI SINTOMO E FREQUENZA')}, la libreria '
        'nomina l insonnia ${libreria.contains('Insonnia')}');
    expect(pannello.contains('SCEGLI SINTOMO E FREQUENZA'), isTrue,
        reason: 'il pulsante della libreria non nomina piu il sintomo: la '
            'parola e stata ammessa nel vocabolario e non la usa nessuno');
    expect(libreria.contains('Insonnia'), isTrue,
        reason: 'nessun sintomo si chiama piu Insonnia: la parola e stata '
            'ammessa e non la usa nessuno');
  });
}
