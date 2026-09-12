import 'dart:io';

import 'package:esoteric_circle/core/rituals/avvisi_del_rito.dart';
import 'package:esoteric_circle/core/rituals/daily_elements.dart';
import 'package:esoteric_circle/core/rituals/scelta_degli_avvisi.dart';
import 'package:esoteric_circle/services/avvisi_locali.dart';
import 'package:esoteric_circle/core/identity/cio_che_e_tuo.dart';
import 'package:esoteric_circle/core/identity/dimenticanza_del_telefono.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// CINQUE AVVISI, UNO PER DONO, E OGNUNO SI SPEGNE DA SOLO.
/// Ordine BC voce 05.
///
/// **Parole del fondatore, maiuscole sue**: "BISOGNA ATTIVARE LE NOTIFICHE
/// VERAMENTE e ne voglio 5, ovvero una per ogni dono con orario che avevamo
/// gia' concordato. Sara' proprio l'utente che potra' gestire e attivare o
/// disattivare i singoli orari delle notifiche nel menu' notifiche."
///
/// **Cosa c'era prima, contato nel codice.** Tre chiamate, e nessuna legata a
/// un Dono: la sera per la Runa del Tramonto, il mattino per le gettate
/// tornate oppure per il cielo di oggi, e il traguardo a un passo dieci ore
/// dopo. Si accendevano tutte insieme col permesso di sistema, e per
/// spegnerne una sola bisognava uscire dall'app e cercarne il canale nelle
/// impostazioni di Android.
///
/// **Gli orari erano gia' scritti nei Doni**, e sono quelli concordati: Alba
/// 7:00, Soffio 10:30, Arcano 13:00, Tramonto 18:30, Notte 22:30.
class _AvvisiFinti extends ServizioAvvisi {
  @override
  Future<void> mostraAdesso({
    required String titolo,
    required String testo,
  }) async {
    suonateSubito.add(titolo);
  }

  /// I titoli suonati subito, ordine CF voce 04.
  final List<String> suonateSubito = <String>[];

  _AvvisiFinti({this.permesso = true});

  bool permesso;
  final Map<int, ({DateTime quando, String titolo, String canale})>
      programmati = {};
  final List<int> annullati = [];

  @override
  bool get disponibile => true;

  @override
  Future<bool> chiediPermesso() async => permesso;

  @override
  Future<bool> permessoConcesso() async => permesso;

  @override
  Future<void> programma({
    required int id,
    required DateTime quando,
    required String titolo,
    required String testo,
    String canale = 'rito_alba',
    String carico = '',
  }) async {
    programmati[id] = (quando: quando, titolo: titolo, canale: canale);
  }

  @override
  Future<void> annulla(int id) async {
    annullati.add(id);
    programmati.remove(id);
  }

  @override
  Future<List<int>> inAttesa() async => programmati.keys.toList();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues(const {}));

  test('BC.05: cinque Doni accesi fanno cinque chiamate, ognuna alla sua ora',
      () async {
    final finti = _AvvisiFinti();
    // Mezzanotte e un minuto: nessuna delle cinque ore e' ancora passata,
    // quindi si vedono tutte cadere nello stesso giorno.
    final adesso = DateTime(2026, 8, 23, 0, 1);
    final ids = await AvvisiDelRito.programmaLeChiamateDelGiorno(
      servizio: finti,
      adesso: adesso,
      doniAccesi: DailyElement.values,
    );
    expect(ids, hasLength(5),
        reason: 'con tutti e cinque i Doni accesi le chiamate sono '
            '${ids.length} invece di cinque');

    final righe = <String>[];
    for (final d in DailyElement.values) {
      final p = finti.programmati[AvvisiDelRito.idDelDono(d)];
      expect(p, isNotNull, reason: 'il Dono ${d.name} non ha nessuna chiamata');
      righe.add('${d.name} alle '
          '${p!.quando.hour.toString().padLeft(2, '0')}:'
          '${p.quando.minute.toString().padLeft(2, '0')}');
      expect(p.quando.hour, d.anchorHour,
          reason: '${d.name} chiama alle ${p.quando.hour} invece che alle '
              '${d.anchorHour}');
      expect(p.quando.minute, d.anchorMinute);
      // **UN CANALE PER CIASCUNO**, se no spegnerne uno dalle impostazioni di
      // Android li spegne tutti.
      expect(p.canale, AvvisiDelRito.canaleDelDono(d));
    }
    // ignore: avoid_print
    print('ORDINE BC VOCE 05: $righe');

    // **CINQUE CANALI DISTINTI, contati.**
    final canali = DailyElement.values
        .map((d) => finti.programmati[AvvisiDelRito.idDelDono(d)]!.canale)
        .toSet();
    expect(canali, hasLength(5),
        reason: 'i canali distinti sono ${canali.length}: due Doni si '
            'spengono insieme dalle impostazioni di sistema');
  });

  test('BC.05: un Dono spento non chiama, e il suo avviso viene annullato',
      () async {
    final finti = _AvvisiFinti();
    final adesso = DateTime(2026, 8, 23, 0, 1);
    // Prima tutti e cinque.
    await AvvisiDelRito.programmaLeChiamateDelGiorno(
      servizio: finti,
      adesso: adesso,
      doniAccesi: DailyElement.values,
    );
    expect(finti.programmati, hasLength(5));

    // Poi solo l'Alba.
    finti.annullati.clear();
    final ids = await AvvisiDelRito.programmaLeChiamateDelGiorno(
      servizio: finti,
      adesso: adesso,
      doniAccesi: const [DailyElement.dawn],
    );
    // ignore: avoid_print
    print('ORDINE BC VOCE 05: spenti quattro Doni, restano '
        '${finti.programmati.length} chiamate e ne sono state annullate '
        '${finti.annullati.length}');
    expect(ids, hasLength(1));
    expect(
        finti.programmati.keys, [AvvisiDelRito.idDelDono(DailyElement.dawn)]);
    // **SPEGNERE DEVE ANNULLARE, non solo smettere di riprogrammare.**
    //
    // Un Dono appena spento ha un avviso gia' in coda dentro il sistema:
    // riprogrammare i soli accesi non lo toglierebbe, e la persona
    // spegnerebbe l'interruttore ricevendo lo stesso la chiamata. E' il modo
    // piu' sicuro di far spegnere tutto dalle impostazioni di Android.
    for (final d in DailyElement.values) {
      expect(finti.annullati, contains(AvvisiDelRito.idDelDono(d)),
          reason: 'la chiamata di ${d.name} non e stata annullata prima di '
              'riscrivere l agenda');
    }
  });

  test('BC.05: senza permesso non parte niente', () async {
    final finti = _AvvisiFinti(permesso: false);
    final ids = await AvvisiDelRito.programmaLeChiamateDelGiorno(
      servizio: finti,
      adesso: DateTime(2026, 8, 23, 0, 1),
      doniAccesi: DailyElement.values,
    );
    expect(ids, isEmpty);
    expect(finti.programmati, isEmpty);
  });

  test('BC.05: un ora gia passata si programma per domani', () async {
    final finti = _AvvisiFinti();
    // Le 23:00: tutte e cinque le ore di oggi sono passate.
    final adesso = DateTime(2026, 8, 23, 23, 0);
    await AvvisiDelRito.programmaLeChiamateDelGiorno(
      servizio: finti,
      adesso: adesso,
      doniAccesi: DailyElement.values,
    );
    final giorni = <int>{};
    for (final d in DailyElement.values) {
      giorni.add(finti.programmati[AvvisiDelRito.idDelDono(d)]!.quando.day);
    }
    // ignore: avoid_print
    print('ORDINE BC VOCE 05: alle 23 del 23 agosto, le cinque chiamate '
        'cadono nei giorni $giorni');
    expect(giorni, {24},
        reason: 'una chiamata e stata messa a un ora gia passata: resterebbe '
            'muta fino al giorno dopo');
  });

  test('BC.05: le chiamate vecchie si spengono, e sono quattro', () {
    // **SU UN TELEFONO CHE AGGIORNA L APP, le tre chiamate di prima sono gia
    // in coda dentro il sistema**: nessuno le annulla da solo, e resterebbero
    // a suonare accanto alle cinque nuove. Gli id nuovi partono da 1100
    // apposta, per non sovrascriverne una a caso lasciando le altre vive.
    // ignore: avoid_print
    print('ORDINE BC VOCE 05: gli id di prima sono '
        '${AvvisiDelRito.idDelleChiamateDiPrima}, quelli dei Doni vanno da '
        '${AvvisiDelRito.idDelDono(DailyElement.values.first)} a '
        '${AvvisiDelRito.idDelDono(DailyElement.values.last)}');
    for (final vecchio in AvvisiDelRito.idDelleChiamateDiPrima) {
      for (final d in DailyElement.values) {
        expect(AvvisiDelRito.idDelDono(d), isNot(vecchio),
            reason: 'l id del Dono ${d.name} e lo stesso di una chiamata '
                'vecchia: aggiornando l app una delle due sparirebbe e l '
                'altra resterebbe a suonare per sempre');
      }
    }
    final regia =
        File('lib/services/regia_delle_chiamate.dart').readAsStringSync();
    expect(regia.contains('idDelleChiamateDiPrima'), isTrue,
        reason: 'nessuno spegne le chiamate di prima: chi aggiorna l app le '
            'riceverebbe accanto alle nuove');
  });

  test('BC.05: la scelta parte con TUTTI E CINQUE accesi', () async {
    // **DECISIONE DEL FONDATORE**: "tutte le notifiche devono essere attive
    // di default".
    //
    // **La prima stesura ne accendeva uno solo, e la ragione era buona**:
    // cinque avvisi al giorno a chi ne ha accettato uno sono il modo piu
    // rapido di far spegnere tutto dalle impostazioni di Android e non
    // tornare piu. Il fondatore ha deciso diversamente, ed e una scelta di
    // prodotto che gli appartiene: i cinque Doni sono l appuntamento
    // quotidiano attorno a cui l app e costruita.
    //
    // **Cio che rende la scelta sostenibile e che spegnerli e facile**, e lo
    // misurano le prove qui sopra: ognuno ha il suo interruttore, l ora si
    // sposta, e la spiegazione del permesso li nomina tutti e cinque prima
    // che il sistema chieda.
    final scelta = SceltaDegliAvvisi();
    await scelta.carica();
    // ignore: avoid_print
    print('ORDINE BC VOCE 05: di partenza chiamano '
        '${scelta.quelliCheChiamano.map((d) => d.name).toList()}');
    expect(scelta.quelliCheChiamano, hasLength(5));
    for (final d in DailyElement.values) {
      expect(scelta.chiama(d), isTrue,
          reason: 'il Dono ${d.name} non chiama di partenza');
    }
  });

  test('BC.05: e ogni interruttore vale per il suo Dono soltanto', () async {
    final scelta = SceltaDegliAvvisi();
    await scelta.carica();
    // **SI SPEGNE, e non si accende**: con tutti e cinque accesi di partenza
    // il gesto che conta e' l'altro, e provare ad accendere cio' che e' gia'
    // acceso non direbbe niente.
    await scelta.scegli(DailyElement.dawn, false);
    expect(scelta.chiama(DailyElement.dawn), isFalse);
    // **E GLI ALTRI QUATTRO NON SI TOCCANO**: e' la richiesta del fondatore,
    // che ognuno si gestisca per conto suo.
    for (final d in const [
      DailyElement.breath,
      DailyElement.oracle,
      DailyElement.rune,
      DailyElement.night,
    ]) {
      expect(scelta.chiama(d), isTrue,
          reason: 'spegnendo l Alba si e spento anche ${d.name}');
    }
    // E si riaccende.
    await scelta.scegli(DailyElement.dawn, true);
    expect(scelta.chiama(DailyElement.dawn), isTrue);
    await scelta.scegli(DailyElement.night, false);

    // **E LA SCELTA SOPRAVVIVE ALLA CHIUSURA DELL APP.**
    final riletta = SceltaDegliAvvisi();
    await riletta.carica();
    // ignore: avoid_print
    print('ORDINE BC VOCE 05: dopo un giro di disco chiamano '
        '${riletta.quelliCheChiamano.map((d) => d.name).toList()}');
    expect(riletta.chiama(DailyElement.night), isFalse,
        reason: 'la scelta non e stata scritta: riaprendo l app tornerebbe '
            'come prima');
    expect(riletta.chiama(DailyElement.dawn), isTrue);
  });

  test('BC.05 coda: l ora si cambia, e la chiamata la segue', () async {
    // **Richiesta del fondatore, arrivata dopo l ordine**: "nel menu
    // notifiche, l utente deve poter cambiare anche l orario di ogni
    // notifica."
    final scelta = SceltaDegliAvvisi();
    await scelta.carica();
    expect(
        scelta.minutiDi(DailyElement.oracle), DailyElement.oracle.anchorMinutes,
        reason: 'di partenza vale l ora concordata');
    expect(scelta.eLOraDiCasa(DailyElement.oracle), isTrue);

    await scelta.scegliLOra(DailyElement.oracle, ora: 9, minuto: 5);
    expect(scelta.minutiDi(DailyElement.oracle), 9 * 60 + 5);
    expect(scelta.eLOraDiCasa(DailyElement.oracle), isFalse);

    // **E LA CHIAMATA VA ALL ORA NUOVA**, se no l interruttore direbbe una
    // cosa e l agenda ne farebbe un altra.
    final finti = _AvvisiFinti();
    await AvvisiDelRito.programmaLeChiamateDelGiorno(
      servizio: finti,
      adesso: DateTime(2026, 8, 23, 0, 1),
      doniAccesi: const [DailyElement.oracle],
      oreScelte: {DailyElement.oracle: scelta.minutiDi(DailyElement.oracle)},
    );
    final quando =
        finti.programmati[AvvisiDelRito.idDelDono(DailyElement.oracle)]!.quando;
    // ignore: avoid_print
    print('ORDINE BC VOCE 05 coda: l Arcano spostato alle 09:05 chiama alle '
        '${quando.hour.toString().padLeft(2, '0')}:'
        '${quando.minute.toString().padLeft(2, '0')}');
    expect(quando.hour, 9);
    expect(quando.minute, 5);

    // **E SI TORNA INDIETRO.** Chi sposta un ora per prova deve poter
    // rimettere quella di casa senza ricordarsela a memoria.
    await scelta.rimettiLOraDiCasa(DailyElement.oracle);
    expect(scelta.minutiDi(DailyElement.oracle),
        DailyElement.oracle.anchorMinutes);

    // **E LA SCELTA SOPRAVVIVE ALLA CHIUSURA DELL APP.**
    await scelta.scegliLOra(DailyElement.night, ora: 21, minuto: 30);
    final riletta = SceltaDegliAvvisi();
    await riletta.carica();
    expect(riletta.minutiDi(DailyElement.night), 21 * 60 + 30,
        reason: 'l ora scelta non e stata scritta: riaprendo l app tornerebbe '
            'quella di prima');
  });

  test('BC.05 coda: e un ora scritta male si butta invece di indovinarla',
      () async {
    // Un dato fuori dal giorno non e' una scelta della persona: indovinare
    // cosa volesse dire e' peggio che tornare all ora di casa.
    SharedPreferences.setMockInitialValues({
      SceltaDegliAvvisi.chiaveDellOraDi(DailyElement.dawn): 5000,
    });
    final scelta = SceltaDegliAvvisi();
    await scelta.carica();
    // ignore: avoid_print
    print('ORDINE BC VOCE 05 coda: con 5000 minuti scritti sul disco, l Alba '
        'chiama a ${scelta.minutiDi(DailyElement.dawn)} minuti');
    expect(scelta.minutiDi(DailyElement.dawn), DailyElement.dawn.anchorMinutes);
  });

  test('BC.05: le chiavi della scelta si dimenticano con l account', () async {
    // **IL PREFISSO E `rituale.`, e non e un dettaglio**: e uno di quelli che
    // la cancellazione dell account dimentica. Senza, chi se ne va lascia le
    // proprie sveglie sul telefono di chi arriva dopo.
    for (final d in DailyElement.values) {
      expect(SceltaDegliAvvisi.chiaveDi(d), startsWith('rituale.'),
          reason: 'la chiave di ${d.name} non ha il prefisso che la '
              'cancellazione dimentica');
    }
    // **SI CHIEDE ALLA VERITA', NON AL FILE. Ordine BZ voce 02.** Qui si
    // leggeva il testo di dimenticanza_del_telefono.dart cercandoci dentro la
    // stringa: dalla voce BZ.01 l'elenco vive in CioCheETuo e quel file lo
    // rimanda, quindi la prova e' diventata rossa mentre il prefisso era
    // ancora dimenticato. Una prova che legge un file invece del dato dice il
    // falso il giorno che il dato trasloca.
    expect(DimenticanzaDelTelefono.prefissiDaDimenticare, contains('rituale.'),
        reason: 'il prefisso rituale non e piu fra quelli dimenticati');
    expect(
        CioCheETuo.eTua(SceltaDegliAvvisi.chiaveDi(DailyElement.values.first)),
        isTrue,
        reason: 'la chiave della scelta degli avvisi non risulta della '
            'persona, quindi nessuna delle due vie la cancella');
  });

  test('BC.05: ogni Dono ha il suo canale di sistema, con un nome leggibile',
      () {
    final mancanti = <String>[];
    for (final d in DailyElement.values) {
      final canale = AvvisiDelRito.canaleDelDono(d);
      if (!AvvisiLocali.canali.containsKey(canale)) mancanti.add(canale);
    }
    // ignore: avoid_print
    print('ORDINE BC VOCE 05: canali dichiarati '
        '${AvvisiLocali.canali.length}, mancanti ${mancanti.length}');
    expect(mancanti, isEmpty,
        reason: 'questi canali non sono dichiarati, quindi su Android '
            'arriverebbero senza nome: $mancanti');
  });

  test('BC.05: e il testo del permesso non promette piu un avviso solo', () {
    // **Il fondatore lo ha letto**: "Posso avvisarti una volta al giorno... Un
    // avviso solo, nessun altro." Con cinque Doni quella frase e una bugia
    // detta nel momento peggiore, mentre si chiede un permesso.
    // ignore: avoid_print
    print('ORDINE BC VOCE 05: la spiegazione dice "'
        '${AvvisiDelRito.spiegazione.substring(0, 60)}..."');
    expect(AvvisiDelRito.spiegazione, isNot(contains('Un avviso solo')));
    expect(AvvisiDelRito.spiegazione, isNot(contains('una volta al giorno')));
    // **DICE IL NUMERO VERO PRIMA CHE IL SISTEMA CHIEDA.** Con tutti e cinque
    // accesi di partenza, chi accetta deve sapere che sono cinque: e la
    // differenza fra un consenso informato e una sorpresa il giorno dopo.
    expect(AvvisiDelRito.spiegazione, contains('cinque avvisi al giorno'),
        reason: 'la spiegazione non dice quanti avvisi arriveranno');
    expect(AvvisiDelRito.spiegazione, contains('spegnere'),
        reason: 'la spiegazione non dice che si possono spegnere');
    expect(AvvisiDelRito.spiegazione, contains('spostare'),
        reason: 'la spiegazione non dice che l ora si puo spostare');
  });
}
