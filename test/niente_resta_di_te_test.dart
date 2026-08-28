import 'dart:io';

import 'package:esoteric_circle/core/identity/cio_che_e_tuo.dart';
import 'package:esoteric_circle/core/identity/dimenticanza_del_telefono.dart';
import 'package:esoteric_circle/core/identity/profile_store.dart';
import 'package:esoteric_circle/core/identity/scarico_dei_tuoi_dati.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// NIENTE RESTA DI TE. Ordine BZ voce 01.
///
/// **PERCHE' QUESTA PROVA E' FATTA COSI', ed e' la parte che conta piu' della
/// cura.** Due prove prima di questa elencavano i nomi delle chiavi di oggi:
/// l'ordine BE voce 07 ne trovo' otto scoperte, l'ordine BX voce 11 ne trovo'
/// altre due, e la volta dopo ne restavano tredici. **Un elenco a mano non
/// fallisce perche' chi lo scrive e' distratto**: fallisce perche' una
/// funzione nuova nasce con la sua memoria, e chi la scrive non pensa a una
/// lista che vive in un altro file.
///
/// Questa prova non elenca niente: **legge il codice**. Cerca in tutto `lib/`
/// ogni chiave che l'app scrive o legge nelle preferenze, la risolve anche
/// quando e' una costante o una funzione, e pretende che `CioCheETuo` la
/// copra. **Il giorno che nasce uno spazio di memoria nuovo, questa prova
/// diventa rossa da sola**, senza che nessuno debba ricordarsi di aggiungerlo
/// a un elenco.
///
/// **Cosa NON puo' fare, dichiarato invece che taciuto.** Una chiave che
/// nascesse da una stringa composta a runtime senza nessun pezzo scritto nel
/// sorgente sarebbe invisibile a qualunque lettura statica. Per questo la
/// prova pretende anche l'altra meta': ogni espressione usata come chiave
/// deve essere LEGGIBILE, cioe' una stringa, una costante o una funzione con
/// dentro una stringa. Se un giorno qualcuno scrivera' una chiave illeggibile,
/// la prova cadra' su quella, e non passera' in silenzio.
void main() {
  /// I file che IMPLEMENTANO la memoria: qui le chiavi sono variabili per
  /// mestiere, perche' questi sono i punti che scorrono tutte le chiavi.
  /// Dichiarati uno per uno con la ragione, non esclusi in blocco.
  const macchinari = <String, String>{
    'lib/core/identity/dimenticanza_del_telefono.dart':
        'e\' la dimenticanza stessa: scorre le chiavi di tutti',
    'lib/core/identity/scarico_dei_tuoi_dati.dart':
        'e\' lo scarico: legge le chiavi di tutti',
    'lib/core/identity/profile_store.dart':
        'tiene le otto chiavi del profilo e le scorre in un giro solo',
    'lib/core/identity/inventario_dell_utente.dart':
        'fotografa cio\' che c\'e\', quindi legge chiavi che non sceglie',
    'lib/core/settings/settings_controller.dart':
        'scrive le sue quattro chiavi passando dal proprio metodo _persist',
    'lib/core/astro/natal_chart_controller.dart':
        'porta via le chiavi vecchie della carta, che sono di forma libera',
  };

  /// I metodi delle preferenze che prendono una chiave come primo argomento.
  const metodi = [
    'setBool', 'setInt', 'setDouble', 'setString', 'setStringList',
    'getBool', 'getInt', 'getDouble', 'getString', 'getStringList',
    'remove', 'containsKey',
  ];

  /// I sorgenti di `lib/`, **IN ORDINE DICHIARATO E NON IN ORDINE DI DISCO.**
  ///
  /// Ordine BZ voce 02, integrazione del 28 agosto. `listSync` torna i file
  /// nell'ordine che il filesystem preferisce, e non e' lo stesso su NTFS e su
  /// APFS: la mappa globale delle costanti si costruisce scorrendo i file, e
  /// per una costante definita con lo stesso nome in due file diversi **vince
  /// l'ultimo letto**. Cinque nomi sono in questo caso, fra cui `_chiave` con
  /// tre valori diversi e `chiave` con due. Oggi tutti e cinque i valori sono
  /// coperti, quindi l'esito non cambia; ma una prova che dipende dall'ordine
  /// del disco puo' dire il vero sul PC e il falso sulla macchina che
  /// costruisce, e quella e' la peggior forma di prova. Si ordina.
  List<File> sorgenti() {
    final fuori = <File>[];
    for (final voce in Directory('lib').listSync(recursive: true)) {
      if (voce is! File || !voce.path.endsWith('.dart')) continue;
      fuori.add(voce);
    }
    fuori.sort((a, b) => a.path
        .replaceAll(Platform.pathSeparator, '/')
        .compareTo(b.path.replaceAll(Platform.pathSeparator, '/')));
    return fuori;
  }

  String percorsoDi(File f) => f.path.replaceAll(Platform.pathSeparator, '/');

  /// Tutte le costanti stringa di `lib/`, per nome: servono a risolvere le
  /// chiavi scritte come `_chiave` o `SunsetRune.chiaveCerniera`.
  /// Le costanti stringa di UN file solo. **Si guardano prima di quelle di
  /// tutti**: due file possono avere una costante che si chiama `chiave`, e
  /// con una mappa sola vince l'ultimo letto. Misurato: iniettando una
  /// memoria nuova con una costante chiamata `chiave`, la prova la risolveva
  /// con la costante omonima di un altro file, che era coperta, e restava
  /// verde.
  Map<String, String> costantiDelFile(String testo) {
    final mappa = <String, String>{};
    final regola = RegExp(
        r'''const\s+(?:String\s+)?(\w+)\s*=\s*(?:'([^']*)'|"([^"]*)")''');
    for (final m in regola.allMatches(testo)) {
      mappa[m.group(1)!] = m.group(2) ?? m.group(3) ?? '';
    }
    return mappa;
  }

  Map<String, String> costantiStringa() {
    final mappa = <String, String>{};
    final regola = RegExp(
        r'''const\s+(?:String\s+)?(\w+)\s*=\s*(?:'([^']*)'|"([^"]*)")''');
    // **GLI ALIAS SI SEGUONO**: `const _chiaveUltimoInvito =
    // QuandoChiedereLaCustodia.chiaveUltimoInvito;` non e' una stringa, ma
    // porta a una stringa, e senza seguirlo la chiave restava illeggibile.
    final alias = <String, String>{};
    final regolaAlias =
        RegExp(r'''const\s+(?:String\s+)?(\w+)\s*=\s*([\w.]+)\s*;''');
    for (final f in sorgenti()) {
      final testo = f.readAsStringSync();
      for (final m in regola.allMatches(testo)) {
        mappa[m.group(1)!] = m.group(2) ?? m.group(3) ?? '';
      }
      for (final m in regolaAlias.allMatches(testo)) {
        alias[m.group(1)!] = m.group(2)!.split('.').last;
      }
    }
    for (final voce in alias.entries) {
      final valore = mappa[voce.value];
      if (valore != null) mappa.putIfAbsent(voce.key, () => valore);
    }
    return mappa;
  }

  /// Le stringhe scritte dentro cio' che COMPONE una chiave: una funzione,
  /// un getter, o una variabile locale. Da `String _chiaveDi(x) =>
  /// 'permesso.$x.gia_chiesto';` si prende `permesso.`.
  ///
  /// **Il corpo si ferma al punto e virgola, non alla graffa**: una chiave
  /// interpolata contiene `$...}`, e fermandosi alla graffa la stringa
  /// restava senza apice di chiusura e non si leggeva piu'.
  Map<String, List<String>> cioCheCompone() {
    final mappa = <String, List<String>>{};
    final regole = [
      // funzione: String nome(...) => ... ;   oppure { ... }
      RegExp(r'''String\s+(\w+)\([^)]*\)\s*=>([^;]*);''', dotAll: true),
      // getter: String get nome => ... ;
      RegExp(r'''String\s+get\s+(\w+)\s*=>([^;]*);''', dotAll: true),
      // variabile locale: final nome = '...';
      RegExp(r'''final\s+(\w+)\s*=\s*('[^;]*)'\s*;'''),
    ];
    for (final f in sorgenti()) {
      final testo = f.readAsStringSync();
      for (final regola in regole) {
        for (final m in regola.allMatches(testo)) {
          final pezzi = RegExp(r"'([^']*)").allMatches(m.group(2)!);
          final letterali = [
            for (final p in pezzi)
              if (p.group(1)!.isNotEmpty) p.group(1)!
          ];
          if (letterali.isNotEmpty) {
            mappa.putIfAbsent(m.group(1)!, () => letterali);
          }
        }
      }
    }
    return mappa;
  }

  /// I nomi delle variabili che TENGONO le preferenze in un file: solo le
  /// chiamate su di loro sono chiavi. Senza questo, `lista.remove(x)` e
  /// `mappa.containsKey(y)` finivano nel conto, e non sono chiavi di niente.
  Set<String> portatoriDiPreferenze(String testo) {
    final nomi = <String>{};
    for (final m in RegExp(
            r'(?:final|var)\s+(\w+)\s*=\s*await\s+SharedPreferences\.getInstance\(\)')
        .allMatches(testo)) {
      nomi.add(m.group(1)!);
    }
    for (final m in RegExp(r'SharedPreferences\s+(\w+)').allMatches(testo)) {
      nomi.add(m.group(1)!);
    }
    return nomi;
  }

  /// La parte FISSA di una chiave: cio' che sta prima della prima
  /// interpolazione. E' quella che un prefisso puo' coprire.
  String parteFissa(String grezza) => grezza.split(r'$').first;

  test('ogni chiave che l\'app scrive e\' coperta dalla verita\' unica', () {
    final costanti = costantiStringa();
    final funzioni = cioCheCompone();
    final scoperte = <String>[];
    final illeggibili = <String>[];
    final trovate = <String, String>{};

    for (final f in sorgenti()) {
      final percorso = percorsoDi(f);
      final testo = f.readAsStringSync();
      // **IL FILTRO GUARDA IL NOME DELLA CLASSE, non l'import.** Con
      // `shared_preferences` si perdeva ogni file che riceve le preferenze
      // gia' aperte, per esempio `Future<void> scrivi(SharedPreferences p)`:
      // e' il modo in cui una memoria nuova nasce dentro un file che non
      // importa niente. Misurato: iniettando una chiave cosi', la prova
      // restava verde.
      if (!testo.contains('SharedPreferences')) continue;
      if (macchinari.containsKey(percorso)) continue;
      final portatori = portatoriDiPreferenze(testo);
      if (portatori.isEmpty) continue;
      for (final metodo in metodi) {
        final regola = RegExp(
            r'\b(' + portatori.join('|') + r')\.' +
                RegExp.escape(metodo) +
                r'\(\s*([^,)]+)');
        for (final m in regola.allMatches(testo)) {
          final arg = m.group(2)!.trim();
          String? chiave;
          if (arg.startsWith("'") || arg.startsWith('"')) {
            chiave = parteFissa(arg.substring(1));
          } else {
            final nome = arg.split('(').first.split('.').last.trim();
            final locali = costantiDelFile(testo);
            if (locali.containsKey(nome)) {
              chiave = parteFissa(locali[nome]!);
            } else if (costanti.containsKey(nome)) {
              chiave = parteFissa(costanti[nome]!);
            } else if (funzioni.containsKey(nome)) {
              // **UNA LOCALE PUO' COMINCIARE CON UNA COSTANTE**: `final key =
              // '$_kRotationPrefix${...}'` non ha nessun pezzo fisso davanti,
              // e la parte fissa sarebbe vuota. Si sostituisce la costante e
              // si rilegge. **E' cosi' che questa prova ha trovato la
              // quarantaseiesima chiave**, quella del benvenuto dei Maestri,
              // che nessuna via cancellava.
              var grezza = funzioni[nome]!.first;
              for (final costante in costanti.entries) {
                grezza = grezza.replaceAll('\$${costante.key}', costante.value);
              }
              chiave = parteFissa(grezza);
            }
          }
          if (chiave == null || chiave.isEmpty) {
            illeggibili.add('$percorso: $arg');
            continue;
          }
          trovate[chiave] = percorso;
          if (CioCheETuo.eTua(chiave) || CioCheETuo.resta(chiave)) continue;
          scoperte.add('$chiave (in $percorso)');
        }
      }
    }

    // ignore: avoid_print
    print('ORDINE BZ VOCE 1: chiavi lette dal codice ${trovate.length}, '
        'scoperte ${scoperte.length}, illeggibili ${illeggibili.length}');
    expect(trovate.length, greaterThan(30),
        reason: 'la prova ha trovato solo ${trovate.length} chiavi: non sta '
            'leggendo il codice, e una prova che non legge niente e\' verde '
            'per sbaglio');
    expect(illeggibili, isEmpty,
        reason: 'queste chiavi non si riescono a leggere dal sorgente, quindi '
            'nessuno puo\' dire se la cancellazione le copre. Scrivile come '
            'costante o come funzione con dentro la stringa, oppure dichiara '
            'il file fra i macchinari con la sua ragione:\n'
            '${illeggibili.join("\n")}');
    expect(scoperte, isEmpty,
        reason: 'QUESTE CHIAVI NON LE CANCELLA NESSUNA VIA, e nessuno le '
            'consegna a chi chiede i propri dati. Aggiungile a CioCheETuo, '
            'oppure dichiarale fra quelle che restano con la ragione '
            'scritta:\n${scoperte.join("\n")}');
  });

  test('le due vie di cancellazione leggono la stessa verita\'', () {
    // **Non e' un confronto di liste scritte a mano**: si guarda che i due
    // punti dell'app che dicono "cosa e' tuo" siano lo stesso oggetto.
    expect(DimenticanzaDelTelefono.prefissiDaDimenticare,
        same(CioCheETuo.prefissi),
        reason: 'la dimenticanza del telefono tiene di nuovo una lista sua');
    expect(ProfileStore.personalPrefixes, same(CioCheETuo.prefissi),
        reason: 'il profilo tiene di nuovo una lista sua: e\' cosi\' che le '
            'due vie promettevano la stessa cosa e ne mantenevano due diverse');
    expect(ProfileStore.personalKeys, isEmpty,
        reason: 'sono tornate chiavi personali fuori dalla verita\' unica');
  });

  test('la via delle Impostazioni passa dalla dimenticanza', () {
    // La schermata non si puo' montare qui senza mezza app: si guarda il
    // punto del sorgente, che e' la cosa che era mancata.
    final testo =
        File('lib/features/settings/settings_screen.dart').readAsStringSync();
    expect(testo.contains('DimenticanzaDelTelefono.dimentica()'), isTrue,
        reason: 'la via "Cancella i miei dati" delle Impostazioni non passa '
            'piu\' dalla dimenticanza del telefono: torna a cancellare '
            'secondo una lista sua, e promette il cammino intero');
  });

  test('nessun dato di nascita vive nel NOME di una chiave', () {
    // **IL TERZO RILIEVO, ed era il piu' grave.** La chiave della carta
    // natale portava nel nome data, ora, minuto, latitudine, longitudine e
    // fuso. Qui si pretende che nessuna chiave si componga con pezzi
    // dell'identita' di nascita.
    final sospette = <String>[];
    const pezziDiNascita = [
      'toIso8601String', 'latitude', 'longitude', 'timezone', 'birthDate',
      'd.date', 'details.date',
    ];
    for (final f in sorgenti()) {
      final percorso = percorsoDi(f);
      final testo = f.readAsStringSync();
      if (!testo.contains('SharedPreferences')) continue;
      final portatori = portatoriDiPreferenze(testo);
      if (portatori.isEmpty) continue;
      for (final metodo in metodi) {
        final regola = RegExp(
            r'\b(' + portatori.join('|') + r')\.' +
                RegExp.escape(metodo) +
                r'\(\s*([^,)]+)');
        for (final m in regola.allMatches(testo)) {
          final arg = m.group(2)!;
          if (pezziDiNascita.any(arg.contains)) {
            sospette.add('$percorso: $arg');
          }
        }
      }
    }
    // ignore: avoid_print
    print('ORDINE BZ VOCE 1: chiavi che nominano la nascita: '
        '${sospette.length}');
    expect(sospette, isEmpty,
        reason: 'queste chiavi si compongono con dati di nascita, quindi il '
            'loro NOME rivela quando e dove e\' nata la persona anche dopo '
            'la cancellazione:\n${sospette.join("\n")}');
  });

  group('le due vie non lasciano niente', () {
    /// Le chiavi che una persona vera si lascia dietro, una per famiglia.
    Map<String, Object> ilTelefonoDiUnaPersona() => {
          'profile.name': 'Sofia',
          'profile.birthDate': '1990-04-12',
          'cammino.gesti': '{"oroscopo":3}',
          'borsellino.movimenti': '[]',
          'sigilli.accesi': '[]',
          'sogni.annotati': '["un bosco"]',
          'viso.storico': '[]',
          'santuario.greeted': true,
          'onboarding.done': true,
          'account.rimandi': 2,
          'allowance.saldoEos': 270,
          'archetipo.storico': '[]',
          'arti_preferite_v1': '["oroscopo"]',
          'avvisi.alba.giaChiesto': true,
          'carta.natale.conservata': '{"impronta":"ab12"}',
          'carta_natale_1990-04-12T00:00:00.000|7|30|45.46|9.19|Europe/Rome':
              '{"vecchia":true}',
          'cielo_posizione_concessa_v1': true,
          'filo.parola_del_giorno': 'soglia',
          'luogo.attuale': 'Milano',
          'natal.chart.v1': '{}',
          'oroscopo_riflessione_piena_v1': 'letto',
          'permesso.camera.gia_chiesto': true,
          'ritual.dawn.streak': 6,
          'rituale.avviso.alba': true,
          'sentiero.mappa_vista.costellazione': true,
          'sinastria.collezione': '[]',
          'sunset_rune.settimana': '[]',
          'sunset_rune_last': 'uruz',
          'device.id': 'abc',
          // E le due che NON sono di nessuno: devono restare.
          'settings.suonoEVibrazione': false,
          'app_check_debug_token': 'xyz',
        };

    test('la via dell\'Account non lascia niente di tuo', () async {
      SharedPreferences.setMockInitialValues(ilTelefonoDiUnaPersona());
      final quante = await DimenticanzaDelTelefono.dimentica();
      final prefs = await SharedPreferences.getInstance();
      final restate = prefs.getKeys().toList()..sort();
      // ignore: avoid_print
      print('ORDINE BZ VOCE 1: la via dell\'Account ha cancellato $quante '
          'spazi, restano $restate');
      final tue = restate.where(CioCheETuo.eTua).toList();
      expect(tue, isEmpty,
          reason: 'dopo la cancellazione restano spazi tuoi: $tue');
      expect(restate, ['app_check_debug_token', 'settings.suonoEVibrazione'],
          reason: 'la cancellazione ha portato via anche cio\' che non e\' di '
              'nessuno, oppure ha lasciato qualcosa');
    });

    test('la via delle Impostazioni non lascia niente di tuo', () async {
      SharedPreferences.setMockInitialValues(ilTelefonoDiUnaPersona());
      // La via delle Impostazioni cancella il profilo, e il profilo adesso
      // chiama la stessa dimenticanza.
      await const ProfileStore().clear();
      final prefs = await SharedPreferences.getInstance();
      final restate = prefs.getKeys().toList()..sort();
      // ignore: avoid_print
      print('ORDINE BZ VOCE 1: la via delle Impostazioni lascia $restate');
      final tue = restate.where(CioCheETuo.eTua).toList();
      expect(tue, isEmpty,
          reason: 'la via delle Impostazioni lascia ancora spazi tuoi: $tue');
    });

    test('lo scarico consegna tutto cio\' che la cancellazione porta via',
        () async {
      SharedPreferences.setMockInitialValues(ilTelefonoDiUnaPersona());
      final albero = await ScaricoDeiTuoiDati.raccogli();
      final dati = (albero['dati'] as Map).cast<String, Object?>();
      final consegnate = <String>{};
      for (final gruppo in dati.values) {
        consegnate.addAll((gruppo as Map).keys.cast<String>());
      }
      final tue = ilTelefonoDiUnaPersona().keys.where(CioCheETuo.eTua).toSet();
      final mancanti = tue.difference(consegnate).toList()..sort();
      // ignore: avoid_print
      print('ORDINE BZ VOCE 1: lo scarico consegna ${consegnate.length} '
          'chiavi su ${tue.length} tue, mancanti $mancanti');
      expect(mancanti, isEmpty,
          reason: 'questi dati si cancellano e non si scaricano: chi li '
              'chiede non li riceve:\n$mancanti');
      expect(consegnate.contains('settings.suonoEVibrazione'), isFalse,
          reason: 'lo scarico consegna anche cio\' che non e\' della persona');
    });
  });
}
