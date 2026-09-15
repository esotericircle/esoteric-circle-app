import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// NESSUN INVITO A UN PERMESSO E' MUTO. Ordine BB, voci 08 e 10.
///
/// **Due fatti del fondatore, e sono la stessa famiglia.** "Quando appare
/// Attiva la posizione non funziona il collegamento con l'autorizzazione a
/// usare il sensore, al click non succede nulla." E: "le notifiche agli orari
/// di ogni dono del giorno non funzionano e nemmeno il pulsante nel menu
/// utente."
///
/// **IL CENSIMENTO CHE L'ORDINE CHIEDE**, contato leggendo il codice. I punti
/// che invitano ad attivare un permesso sono **SEI**:
///
/// | dove | permesso | chiedeva davvero |
/// |---|---|---|
/// | Rivelazione del Maestro | microfono | si' |
/// | Soffio del Destino | microfono | si' |
/// | Rito dell'Alba | notifiche | si' |
/// | Dove sei adesso | posizione | si' |
/// | Runa del Tramonto | posizione | **si', ma taceva** |
/// | Account, voce Notifiche | notifiche | **NO, era un anticipo** |
///
/// **Quanti erano muti: DUE.**
///
/// **Il primo taceva senza essere rotto**, ed e' il caso piu' insidioso: alla
/// Runa del Tramonto il permesso era gia' negato per sempre, quindi il sistema
/// non mostra piu' nessuna finestra, e il codice si limitava a **cambiare la
/// scritta sotto il dito che la stava coprendo**. Chi tocca vede il proprio
/// dito, non due parole che cambiano.
///
/// **Il secondo non esisteva proprio**: la voce Notifiche dell'account era un
/// `teaser`, cioe' una voce che al tocco racconta cosa arrivera'. Prometteva
/// "qui sceglierai" e non faceva scegliere niente.
void main() {
  String soloCodice(String percorso) =>
      File(percorso).readAsLinesSync().where((r) {
        final p = r.trimLeft();
        return !p.startsWith('//') && !p.startsWith('///');
      }).join('\n');

  test('BB.08: il no per sempre della posizione si SENTE, non si legge', () {
    final tramonto = soloCodice('lib/features/rituals/sunset_rune_screen.dart');
    // ignore: avoid_print
    print('ORDINE BB VOCE 08: il messaggio del no per sempre compare '
        '${"sunset_posizione_negata_per_sempre".allMatches(tramonto).length} '
        'volte');
    expect(
        tramonto.contains("Key('sunset_posizione_negata_per_sempre')"), isTrue,
        reason: 'col permesso negato per sempre il tocco cambia solo la '
            'scritta, e la scritta sta sotto il dito che la copre: e il fatto '
            'del fondatore, "al click non succede nulla"');
  });

  test('BB.08: e i tre esiti restano tre, non due', () {
    final tramonto = soloCodice('lib/features/rituals/sunset_rune_screen.dart');
    for (final ramo in const [
      'EsitoPosizione.negataPerSempre',
      'sunset_posizione_negata',
      'apriImpostazioni',
    ]) {
      expect(tramonto.contains(ramo), isTrue,
          reason: 'manca il ramo "$ramo": i tre esiti del permesso sono '
              'concesso, negato e negato per sempre, e appiattirli vuol dire '
              'mandare alle impostazioni chi puo ancora dire di si, o '
              'richiedere in eterno a chi ha gia chiuso la porta');
    }
  });

  test('BB.10: la voce Notifiche dell account fa qualcosa', () {
    // **IL PERMESSO SI CHIEDE ANCORA, MA UN PIANO PIU' IN LA'.**
    // Ordine BC voce 05: la voce dell'account non decide piu' per la persona,
    // apre il menu' dove i cinque appuntamenti si accendono uno per uno. Il
    // permesso e la riprogrammazione vivono li' dentro, dove c'e' anche la
    // riga che li spiega.
    final account = soloCodice('lib/features/account/account_screen.dart');
    final menu = soloCodice('lib/features/account/notifiche_screen.dart');
    // ignore: avoid_print
    print('ORDINE BB VOCE 10, poi BC VOCE 05: la voce apre il menu '
        '${"NotificheScreen.route()".allMatches(account).length} volte, e nel '
        'menu il permesso si chiede '
        '${"requestPermissionWithPrelude".allMatches(menu).length} volte');
    expect(account.contains('NotificheScreen.route()'), isTrue,
        reason: 'la voce Notifiche non porta al menu delle notifiche: era un '
            'anticipo, poi un interruttore unico, e adesso deve essere una '
            'porta');
    expect(menu.contains('requestPermissionWithPrelude'), isTrue,
        reason: 'nel menu delle notifiche il permesso non passa dal foglio che '
            'lo spiega: un permesso chiesto di colpo si nega, e su Android si '
            'nega PER SEMPRE dopo due volte');
    expect(menu.contains('RegiaDelleChiamate.riprogramma'), isTrue,
        reason: 'il menu accende gli interruttori e non riscrive l agenda: '
            'direbbe acceso senza chiamare, o spento chiamando lo stesso');
  });

  test('BC.05: e chi nega il permesso non resta senza risposta', () {
    // **I RAMI SI SONO SPOSTATI COL PERMESSO.** Stavano nella voce
    // dell'account finche' era li' che si chiedeva; adesso stanno nel menu',
    // e quello che conta e' che ci siano: chi nega deve sentirselo dire e
    // sapere dove si cambia idea.
    final menu = soloCodice('lib/features/account/notifiche_screen.dart');
    for (final ramo in const [
      "Key('notifiche_permesso_negato')",
      'openAppSettings',
      "Key('notifiche_permesso_manca')",
    ]) {
      expect(menu.contains(ramo), isTrue,
          reason: 'manca il ramo "$ramo" nel menu delle notifiche');
    }
  });

  test('il censimento: sei punti chiedono un permesso, e nessuno tace', () {
    // **ENUMERATI, non campionati.** Ogni riga e' un punto in cui l'app
    // invita ad attivare qualcosa.
    const punti = <String, String>{
      'lib/features/onboarding/maestro_reveal_screen.dart': 'microfono',
      'lib/features/rituals/breath_destiny_screen.dart': 'microfono',
      'lib/features/rituals/dawn_rite_screen.dart': 'notifiche',
      'lib/features/rituals/dove_sei_adesso.dart': 'posizione',
      'lib/features/rituals/sunset_rune_screen.dart': 'posizione',
      'lib/features/account/notifiche_screen.dart': 'notifiche',
    };
    final muti = <String>[];
    punti.forEach((percorso, permesso) {
      final codice = soloCodice(percorso);
      // **Chiede davvero** se passa dal prelude o dalla porta della
      // posizione: sono le due sole strade che arrivano al sistema.
      final chiede = codice.contains('requestPermissionWithPrelude') ||
          codice.contains('location.chiedi()') ||
          codice.contains('PortaDelPermesso.chiedi');
      if (!chiede) muti.add('$percorso ($permesso)');
    });
    // ignore: avoid_print
    print('ORDINE BB VOCI 08 e 10: punti censiti ${punti.length}, muti '
        '${muti.length}${muti.isEmpty ? '' : ': $muti'}');
    expect(muti, isEmpty,
        reason: 'questi punti invitano ad attivare un permesso e non lo '
            'chiedono a nessuno: $muti');
  });
}
