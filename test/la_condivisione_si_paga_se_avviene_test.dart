import 'dart:io';

import 'package:esoteric_circle/core/condivisione/porta_della_condivisione.dart';
import 'package:esoteric_circle/core/sigilli/bonus_della_condivisione.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:share_plus/share_plus.dart';

/// LA CONDIVISIONE SI PAGA SOLO SE AVVIENE DAVVERO. Ordine AN voce 08.
///
/// **Il difetto misurato sulla testa**: tutte e tre le vie della porta
/// tornavano VERO appena `SharePlus.share` non sollevava, cioe' appena il
/// foglio di sistema si apriva. Bastava aprirlo e premere indietro perche' il
/// Cerchio credesse a una condivisione mai partita e accreditasse il bonus.
/// share_plus l'esito lo dice, e ora si legge.
///
/// **E la frase lo dice PRIMA**: ogni pulsante dichiara cosa fa arrivare i
/// suoi Eos. Per l'invito, il cui premio dipende dal download dell'amico e
/// quindi da un'attribuzione che nel progetto non esiste, si dichiara anche
/// l'attesa: la promessa mostrata resta vera nel codice.
void main() {
  test('avvenuta e\' vero SOLO sul successo', () {
    expect(
        PortaDellaCondivisione.avvenuta(
            const ShareResult('ok', ShareResultStatus.success)),
        isTrue);
    expect(
        PortaDellaCondivisione.avvenuta(
            const ShareResult('', ShareResultStatus.dismissed)),
        isFalse,
        reason: 'chi apre il foglio e preme indietro NON ha condiviso: '
            'pagarlo sarebbe un premio per un gesto mai avvenuto');
    expect(PortaDellaCondivisione.avvenuta(ShareResult.unavailable), isFalse,
        reason: 'non sapere se e\' avvenuta non e\' saperlo: si sceglie la '
            'via prudente e il bonus resta in attesa, incassabile dopo');
  });

  test('nessuna via della porta torna vero senza guardare l\'esito', () {
    // **L'ENUMERAZIONE, perche' le vie sono la stessa famiglia.** Se ne
    // nascesse una che dimentica l'esito, questa prova la trova: si cerca il
    // ritorno cieco subito dopo la chiamata a share.
    //
    // **E DA TRE SONO PASSATE A QUATTRO. Ordine BC voce 02.** La quarta manda
    // PIU' FILE insieme, e serve allo scarico dei propri dati, che sono due:
    // l'archivio e il riepilogo in italiano. Mandarli in due condivisioni
    // separate vorrebbe dire far scegliere due volte dove metterli, e chi
    // sbaglia la seconda si ritrova meta' dei suoi dati.
    //
    // **La prova ha fatto il suo mestiere**: e' caduta col numero, e la via
    // nuova legge l'esito come le altre tre.
    final sorgente = File('lib/core/condivisione/porta_della_condivisione.dart')
        .readAsStringSync();
    final chiamate = 'SharePlus.instance.share('.allMatches(sorgente).length;
    final letture = 'return avvenuta(esito);'.allMatches(sorgente).length;
    // ignore: avoid_print
    print('ORDINE AN VOCE 08: vie della porta $chiamate, esiti letti '
        '$letture');
    expect(chiamate, 4, reason: 'le vie della porta non sono piu\' quattro');
    expect(letture, chiamate,
        reason: 'una via chiama il foglio di sistema e non legge il suo '
            'esito: torna vero appena il foglio si apre');
    expect(sorgente.contains('      return true;'), isFalse,
        reason: 'e\' tornato un ritorno cieco dopo la condivisione');
  });

  test('ogni modo dice quando arriva il suo premio', () {
    for (final modo in ModoDellaCondivisione.values) {
      expect(modo.quandoArriva.trim(), isNotEmpty,
          reason: '${modo.motivo} non dice quando arrivano i suoi Eos');
      // **LA PAROLA "EOS" E\' USCITA DALLA FRASE, ordine BX.** Stava dentro
      // il testo del modo, e la riga si componeva come "$quanti Eos ...":
      // quando il numero mancava, a schermo si leggeva "Eos quando il tuo
      // amico entra nel Cerchio", che comincia col nulla. Adesso la parola
      // la mette chi compone la riga, insieme al numero, e la frase del modo
      // dice il QUANDO e basta.
      expect(modo.quandoArriva, isNot(contains('Eos')),
          reason: '${modo.motivo} torna a portarsi dentro la parola Eos: '
              'senza numero la riga ricomincia da quella parola');
      expect(modo.quandoArriva.trim().split(' ').length, greaterThan(2),
          reason: '${modo.motivo} non dice quando arriva il premio');
    }
    // ignore: avoid_print
    print('ORDINE AN VOCE 08: frasi ${[
      for (final m in ModoDellaCondivisione.values) m.quandoArriva
    ]}');
  });

  test('l\'invito e\' dichiarato in attesa, gli altri due si pagano subito',
      () {
    expect(ModoDellaCondivisione.invitoConDownload.subitoPagato, isFalse,
        reason: 'l\'invito si accrediterebbe alla condivisione mentre il '
            'pulsante dichiara che arriva col download dell\'amico: e\' una '
            'bugia a schermo, perche\' l\'attribuzione non esiste');
    expect(ModoDellaCondivisione.socialPubblico.subitoPagato, isTrue);
    expect(ModoDellaCondivisione.condivisionePrivata.subitoPagato, isTrue);

    // E il codice della condivisione rispetta la regola invece di ignorarla.
    final flusso =
        File('lib/features/sigilli/celebrazione.dart').readAsStringSync();
    expect(flusso.contains('if (!modo.subitoPagato) return;'), isTrue,
        reason: 'il flusso incassa anche cio\' che ha dichiarato in attesa');
  });

  test('i valori del server e il tetto restano intatti', () {
    // Il client chiede il premio per NOME e mai per importo: i tre motivi
    // sono quelli che il server conosce.
    expect(ModoDellaCondivisione.values.map((m) => m.motivo).toSet(),
        {'invito_con_download', 'social_pubblico', 'condivisione_privata'},
        reason: 'i motivi non combaciano piu\' con quelli del server');
    final server = File('functions/src/borsellino.ts').readAsStringSync();
    // **L'INVITO NON STA PIU' IN QUESTO LISTINO, ordine BX voce 02.** Il
    // premio non si paga alla condivisione, perche' bastava mandare il link
    // a se stessi: lo paga riscattaLInvito quando una persona invitata entra
    // davvero. Il valore vive in EOS_DELL_INVITO_ACCOLTO e vale sempre
    // sessanta. La grandezza misurata cambia col fatto: qui si pretende che
    // NON ci sia, e che ci sia dove adesso vive.
    expect(
        RegExp(r'^\s*invito_con_download\s*:', multiLine: true).hasMatch(
            RegExp(r'BONUS_DELLA_CONDIVISIONE[^}]*}', dotAll: true)
                    .firstMatch(server)
                    ?.group(0) ??
                ''),
        isFalse,
        reason: 'il listino della condivisione paga di nuovo l\'invito');
    expect(server.contains('EOS_DELL_INVITO_ACCOLTO = 60'), isTrue,
        reason: 'il premio dell\'invito accolto non vale piu\' sessanta Eos');
    expect(server.contains('social_pubblico: 30'), isTrue);
    expect(server.contains('condivisione_privata: 15'), isTrue);
    expect(server.contains('TETTO_CONDIVISIONI_PREMIATE = 3'), isTrue,
        reason: 'il tetto di tre al giorno contro il farming e\' sparito');
  });
}
