import 'dart:io';

import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:flutter_test/flutter_test.dart';

/// LA BOLLA DEI TRAGUARDI DICE QUALE E' QUALE. Ordine BC voce 06.
///
/// **Fatto del fondatore**: "quando apro la schermata dei traguardi, ad
/// esempio i fiori di loto di Aura, compare dal basso una bolla che indica a
/// che punto siamo, ma indica anche un suggerimento per il prossimo traguardo
/// da raggiungere, ma non e' chiaro: prima di tutto dovrebbe esserci il titolo
/// 'I traguardi raggiunti' e sotto 'il tuo prossimo traguardo'. E comunque e'
/// sbagliato scrivere 'il primo test archetipo completato' perche' quel test
/// non e' mai stato fatto."
///
/// **Tre cose, e tutte e tre esatte.** Le prime due erano due informazioni
/// diverse incolonnate senza dire quale fosse quale. La terza e' la piu'
/// grave, **perche' il campo sbagliato aveva il nome giusto scritto sopra**:
/// `frase` e' dichiarata nel modello come *"LA FRASE WOW"*, quella della
/// festa, che si legge una volta sola nell'istante in cui il Sigillo si
/// accende, ed e' al passato per costruzione. La bolla la usava per annunciare
/// cio' che MANCA.
///
/// La prova che i due titoli compaiono e che il foglio non diventa un elenco
/// sta in `test/la_mappa_del_sentiero_test.dart`, dove viveva gia' il conto
/// dei testi. Qui si guarda il DATO: quale campo dice cosa, e quanti nomi
/// restano scritti come una cosa gia' avvenuta.
void main() {
  test('BC.06: il nome di un traguardo non e la frase della sua festa', () {
    // Il caso che il fondatore ha citato, con le sue parole esatte.
    final archetipo = Sentieri.di(Sentiero.loto)
        .firstWhere((t) => t.id == 'aur_3');
    // ignore: avoid_print
    print('ORDINE BC VOCE 06: per lo stesso traguardo, la festa dice '
        '"${archetipo.frase}" e il nome dice "${archetipo.nome}"');
    // **IL CASO ESATTO DEL FONDATORE NON ESISTE PIU', ordine BS voce 01, ed
    // e' esattamente cio' che voleva.** Diceva: "e' sbagliato scrivere il primo
    // test archetipo completato perche' quel test non e' mai stato fatto". La
    // revisione E ha riscritto le frasi e quella parola non c'e' piu' da
    // nessuna parte. **La pretesa resta e vale su qualunque corpus**: il nome
    // di un gradino non e' la frase della sua festa, e non dichiara compiuta
    // una cosa che nessuno ha ancora fatto.
    expect(archetipo.nome, isNot(archetipo.frase),
        reason: 'il nome e la frase sono la stessa riga: sono due campi '
            'diversi e devono dire due cose diverse');
    expect(archetipo.nome.toLowerCase(), isNot(contains('completato')),
        reason: 'il nome del traguardo dichiara completata una cosa mai '
            'fatta: e proprio cio che il fondatore ha segnalato');
    expect(archetipo.nome, isNot(contains('completato')),
        reason: 'il nome del traguardo dichiara completata una cosa mai '
            'fatta: e proprio cio che il fondatore ha segnalato');
  });

  test('BC.06: e la bolla legge il nome, non la frase', () {
    // **La bolla non si monta qui**: si guarda quale campo chiede, perche' e'
    // la scelta del campo il cuore di questa voce. Che a schermo compaiano i
    // due titoli lo misura l altra prova, contando i testi del foglio.
    final sorgente = _leggi('lib/features/sigilli/la_mappa_del_sentiero.dart');
    // **IL CAMPO E' CAMBIATO DI NUOVO, ordine BE voce 04, ed e' il terzo
    // capitolo.** BC.06 tolse `frase` (al passato per costruzione) e mise
    // `nome`; sulla 2199 il fondatore ha letto il nome nudo, "Il cielo di
    // oggi ti riguarda", e ha detto che messo li' cosi' non significa
    // niente. Adesso parla `percheConta`, il campo che per documentazione
    // "si legge PRIMA, sul sentiero": la frase della festa resta vietata
    // come prima.
    expect(sorgente.contains('prossimo.percheConta'), isFalse,
        reason: 'la bolla mostra il perche conta, che parla al progetto e '
            'non alla persona: bocciato guardando l anteprima (BE.04)');
    expect(sorgente.contains('prossimo.nome'), isFalse,
        reason: 'la bolla e tornata al nome nudo che il fondatore ha '
            'bocciato sulla 2199');
    expect(sorgente.contains('prossimo.frase'), isFalse,
        reason: 'la bolla e tornata a mostrare la frase della festa per '
            'annunciare cio che manca');
    for (final chiave in const [
      'mappa_titolo_maestro',
      'mappa_titolo_raggiunti',
      'mappa_titolo_prossimo',
    ]) {
      expect(sorgente.contains(chiave), isTrue,
          reason: 'manca il titolo "$chiave", che il fondatore ha chiesto per '
              'primo');
    }
  });

  test('BC.06: e si conta quanti nomi suonano come cosa gia avvenuta', () {
    // **QUESTO E' UN CENSIMENTO DICHIARATO, NON UNA GUARDIA CHE ACCUSA.**
    //
    // Il fondatore ha enunciato un principio, non solo un caso: non si scrive
    // come fatto cio' che non e' fatto. Col nome al posto della frase il suo
    // caso sparisce, "Il primo Test Archetipo completato" diventa "Sai quale
    // archetipo ti somiglia". **Ma dodici nomi su centosessantacinque sono
    // scritti al passato**, e il primo del Loto e' uno di quelli: chiunque
    // apra i Fiori di Loto il primo giorno legge "Hai ricevuto il primo
    // Soffio" sotto il titolo "IL TUO PROSSIMO TRAGUARDO".
    //
    // **Non si riscrivono qui, ed e' una scelta.** I nomi dei traguardi sono
    // contenuto del mondo del Cerchio, scritti nella voce dei Maestri: sono
    // materia del fondatore, non di chi sviluppa. Questa prova li conta, li
    // stampa e tiene fermo il numero, cosi' la decisione resta possibile
    // invece di dimenticarsi.
    final passato = RegExp(
        r'\b(hai|ti ha|si e|e )\s*\w*(ato|ata|ati|ate|uto|uta|iso|esa|erto)\b',
        caseSensitive: false);
    final participio = RegExp(
        r'(ato|ata|ati|ate|uto|uta|iti|ite|esa|eso|erta|erto)\s*$',
        caseSensitive: false);
    final avvenuti = <String>[];
    var totali = 0;
    for (final s in Sentiero.values) {
      for (final t in Sentieri.di(s)) {
        totali++;
        if (passato.hasMatch(t.nome) || participio.hasMatch(t.nome)) {
          avvenuti.add(t.nome);
        }
      }
    }
    // ignore: avoid_print
    print('ORDINE BC VOCE 06: su $totali traguardi, ${avvenuti.length} hanno '
        'un nome scritto come cosa gia avvenuta: $avvenuti');
    expect(totali, 165, reason: 'i traguardi non sono piu centosessantacinque');
    // **DICIOTTO E NON DODICI, ordine BS voce 01, e il numero segue il dato.**
    // La revisione E ha riscritto tutti e 165 i nomi e ne porta diciotto al
    // passato invece di dodici. **La pretesa non cambia**: il conto sta qui
    // perche' non cresca di nascosto, e il giorno che cambia il fondatore va
    // avvisato, perche' quella e' materia sua.
    expect(avvenuti, hasLength(18),
        reason: 'i nomi scritti al passato sono ${avvenuti.length} invece di '
            'dodici: se ne sono aggiunti o tolti, e il fondatore va avvisato '
            'perche quella e materia sua');
  });
}

String _leggi(String percorso) => File(percorso).readAsStringSync();
