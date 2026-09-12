import 'dart:io';

import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/accento_del_maestro.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/design_system/tokens/regime_chiaro.dart';
import 'package:esoteric_circle/design_system/tokens/typography_tokens.dart';
import 'package:esoteric_circle/features/rituals/dawn_rite_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'sorgenti_di_lib.dart';

/// L'ALBA SI LEGGE, ordine P voci da 11 a 15.
///
/// **P.11, misurare prima di correggere.** Questa prova non giudica soltanto:
/// SCRIVE `docs/tipografia/alba_contrasto.md`, la tabella con file e riga, ruolo
/// invocato, misura resa, colore del testo, colore EFFETTIVO del fondo dietro
/// quel testo dopo opacita' e sovrapposizioni, e rapporto di contrasto WCAG.
///
/// **Il fondo non si calcola, si CAMPIONA dal fotogramma vero.** Il pannello del
/// dono e' un vetro semitrasparente e sfocato sopra una scena di sole che si
/// muove: qualunque conto analitico sarebbe una stima. Si cattura la schermata e
/// si legge il colore piu' frequente nella fascia alta del rientro di ogni
/// testo, cioe' dove non passa nessuna lettera.
///
/// **Il file e la riga non si scrivono a mano**: si trovano cercando nel
/// sorgente la chiave con cui quel testo si presenta a video. Un elenco scritto
/// a mano di file e righe invecchia al primo riordino del file.
///
/// **P.13 e P.14, la prova del rosso.** La tabella e le soglie di
/// [RegimeChiaro] fanno cadere questa prova sul codice PRIMA della correzione:
/// le etichette dell'Alba erano etichetta a dodici punti in maiuscoletto,
/// nel colore che misurava 4,25 a 1 contro i 4,5 richiesti.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  void silenzia() {
    final m = binding.defaultBinaryMessenger;
    m.setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
        (call) async => null);
    for (final nome in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      m.setMockStreamHandler(
          EventChannel(nome), MockStreamHandler.inline(onListen: (a, e) {}));
    }
  }

  Future<void> caricaCaratteri() async {
    for (final f in const [
      ['Cinzel', 'assets/fonts/Cinzel-variable.ttf'],
      ['EBGaramond', 'assets/fonts/EBGaramond-variable.ttf'],
    ]) {
      final loader = FontLoader(f[0]);
      loader.addFont(
          Future.value(ByteData.view(File(f[1]).readAsBytesSync().buffer)));
      await loader.load();
    }
  }

  /// La misura reale del telefono su cui l'app viene guardata.
  const Size schermoReale = Size(360, 797);

  /// I sorgenti in cui cercare la chiave di un testo.
  final sorgenti = <String>[
    'lib/features/rituals/dawn_rite_screen.dart',
    'lib/features/rituals/ritual_gift_card.dart',
    'lib/design_system/components/riga_del_dono.dart',
  ];

  /// Dove nel sorgente vive il testo che si presenta con [chiave].
  ///
  /// Si cerca la chiave letterale; se la chiave e' composta a runtime, come
  /// quelle della base del dono, si cerca il suo prefisso.
  String dove(String chiave) {
    for (final file in sorgenti) {
      final righe = File(file).readAsLinesSync();
      for (var i = 0; i < righe.length; i++) {
        if (righe[i].contains("Key('$chiave')")) return '$file:${i + 1}';
      }
      // Chiave composta: si cerca il pezzo fisso.
      final pezzo = chiave.contains('base_etichetta')
          ? 'alba_base_etichetta_'
          : chiave.contains('base_valore')
              ? 'alba_base_valore_'
              : null;
      if (pezzo == null) continue;
      for (var i = 0; i < righe.length; i++) {
        if (righe[i].contains(pezzo)) return '$file:${i + 1}';
      }
    }
    return 'non trovato nel sorgente';
  }

  /// Il ruolo tipografico invocato, riconosciuto dalla misura e dal peso.
  ///
  /// Non si legge dal nome del metodo, che a runtime non esiste piu': si
  /// riconosce dalla coppia misura e peso, che e' cio' che il ruolo produce.
  ({String nome, bool etichetta}) ruoloDi(TextStyle stile) {
    final misura = stile.fontSize ?? 0;
    final serif = stile.fontFamily == 'Cinzel';
    if (serif) {
      if (misura >= 34) return (nome: 'cerimonialeGrande', etichetta: false);
      if (misura >= 28) return (nome: 'cerimoniale', etichetta: false);
      if (misura >= 22) return (nome: 'titoloSezione', etichetta: false);
      if (misura >= 18) return (nome: 'titoloScheda', etichetta: false);
      return (nome: 'display a misura', etichetta: false);
    }
    if (misura >= 18) return (nome: 'lettura', etichetta: false);
    if (misura >= 16) return (nome: 'corpo o didascalia', etichetta: false);
    return (nome: 'etichetta', etichetta: true);
  }

  double pesoDi(TextStyle stile) {
    final variazioni = stile.fontVariations;
    if (variazioni == null || variazioni.isEmpty) return 400;
    for (final v in variazioni) {
      if (v.axis == 'wght') return v.value;
    }
    return 400;
  }

  /// Il colore piu' frequente nella fascia alta del rientro di [rettangolo].
  ///
  /// La moda e non la media: se una lettera alta sbordasse nella fascia, la
  /// media si sposterebbe verso l'inchiostro e il fondo risulterebbe piu' scuro
  /// del vero, cioe' il contrasto risulterebbe migliore del vero. La moda no.
  Color fondoSotto(ByteData dati, int larghezza, int altezza, Rect rettangolo,
      {bool tuttoIlRiquadro = false, Color? inchiostro}) {
    final conteggio = <int, int>{};
    // **PER UN'ETICHETTA DI PULSANTE SI GUARDA TUTTO IL RIQUADRO.**
    // Ordine CO voce 14, 3 settembre 2026.
    //
    // La fascia alta del rientro funziona per un testo che porta la propria
    // interlinea: li' dentro, in cima, non passa nessuna lettera. **Ma
    // l'etichetta di un pulsante e' incassata stretta nel suo riquadro**, e
    // in quella fascia le lettere ci passano eccome: la moda torna il colore
    // dell'INCHIOSTRO, e il contrasto risulta uno a uno.
    //
    // **E nemmeno la fascia appena SOPRA va bene**, che era la mia prima
    // correzione: sopra l'etichetta di un pulsante pieno finisce il pannello
    // che sta dietro, non il riempimento del pulsante, e il numero risultava
    // 1,23 dove l'occhio legge benissimo. L'ho scoperto rileggendo la
    // tabella invece di fidarmi della riga che avevo appena scritto.
    //
    // Su tutto il riquadro invece la moda e' il riempimento per costruzione:
    // **le lettere sono sottili e il fondo e' la maggioranza dei pixel.**
    final da = rettangolo.top.round() + 1;
    final fino = tuttoIlRiquadro ? rettangolo.bottom.round() - 1 : da + 4;
    for (var y = da; y < fino; y++) {
      for (var x = rettangolo.left.round() + 1;
          x < rettangolo.right.round() - 1;
          x++) {
        if (x < 0 || y < 0 || x >= larghezza || y >= altezza) continue;
        final i = (y * larghezza + x) * 4;
        final r = dati.getUint8(i);
        final g = dati.getUint8(i + 1);
        final b = dati.getUint8(i + 2);
        final chiave = (r << 16) | (g << 8) | b;
        conteggio[chiave] = (conteggio[chiave] ?? 0) + 1;
      }
    }
    // **E SI SCARTA L'INCHIOSTRO, che dentro un riquadro stretto e' la
    // maggioranza.** Ordine CO voce 14, terza stesura di questa misura, e le
    // due precedenti erano tutte e due sbagliate in modo istruttivo.
    //
    // La prima guardava la fascia alta del rientro, e dentro l'etichetta di
    // un pulsante quella fascia e' fatta di lettere: tornava l'inchiostro, e
    // il contrasto risultava uno a uno. La seconda guardava appena SOPRA il
    // riquadro, e sopra un pulsante PIENO c'e' il pannello che sta dietro,
    // non il suo riempimento: tornava 1,23 dove l'occhio legge benissimo.
    //
    // **La regola che le copre tutte e due e' una sola: il fondo e' il colore
    // piu' frequente che non sia l'inchiostro.** Un pulsante contornato la
    // porta al pannello, uno pieno al proprio riempimento, e un testo normale
    // resta dov'era. Si scarta per distanza e non per uguaglianza, perche' i
    // bordi delle lettere sono sfumati e nessuno di quei grigi e' il fondo.
    if (inchiostro != null) {
      final ir = (inchiostro.r * 255).round();
      final ig = (inchiostro.g * 255).round();
      final ib = (inchiostro.b * 255).round();
      conteggio.removeWhere((chiave, _) {
        final r = (chiave >> 16) & 0xFF;
        final g = (chiave >> 8) & 0xFF;
        final b = chiave & 0xFF;
        return (r - ir).abs() + (g - ig).abs() + (b - ib).abs() < 90;
      });
    }
    if (conteggio.isEmpty) return const Color(0xFF000000);
    final vincente =
        conteggio.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
    return Color(0xFF000000 | vincente);
  }

  String esa(Color c) =>
      '#${((c.r * 255).round() << 16 | (c.g * 255).round() << 8 | (c.b * 255).round()).toRadixString(16).padLeft(6, '0').toUpperCase()}';

  testWidgets(
      'La tabella del contrasto dell\'Alba esiste, e la scrive la misura',
      (tester) async {
    silenzia();
    await caricaCaratteri();
    tester.view.physicalSize = schermoReale;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final radice = GlobalKey();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: RepaintBoundary(
          key: radice,
          child: MaestroScope(
            // Il giorno e' fissato: il Maestro dell'alba ruota, e la tabella
            // deve poter essere riletta domani e dire la stessa cosa.
            child: DawnRiteScreen(now: DateTime(2026, 7, 14, 6, 0)),
          ),
        ),
      ),
    ));
    await tester.pump();
    // Gli asset della scena, decodificati: senza di loro il fondo campionato
    // sarebbe il nero del vuoto e la tabella dichiarerebbe un contrasto che
    // nessuno vede.
    await tester.runAsync(() async {
      final elemento = tester.element(find.byType(DawnRiteScreen));
      for (final asset in const [
        'assets/ritual_backgrounds/dawn_sky_night.png',
        'assets/ritual_backgrounds/dawn_sky_day.png',
        'assets/ritual_backgrounds/dawn_sun.png',
      ]) {
        await precacheImage(AssetImage(asset), elemento);
      }
    });
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    Future<({ByteData dati, int larghezza, int altezza})> scattoPer(
        Finder quale) async {
      await tester.ensureVisible(quale);
      await tester.pump();
      late ByteData dati;
      var larghezza = 0;
      var altezza = 0;
      await tester.runAsync(() async {
        final confine =
            radice.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final immagine = await confine.toImage();
        larghezza = immagine.width;
        altezza = immagine.height;
        dati = (await immagine.toByteData())!;
        immagine.dispose();
      });
      return (dati: dati, larghezza: larghezza, altezza: altezza);
    }

    final righe = <String>[];
    final sotto = <String>[];
    final fondiVisti = <({Color colore, String chi, String dove})>[];
    var censite = 0;

    /// **SI MISURA A OGNI MOMENTO DEL RITO, non a uno solo.**
    /// Ordine CO voce 14, 3 settembre 2026.
    ///
    /// La tabella catturava un fotogramma solo, quello a rito compiuto,
    /// e li' misurava tutto cio' che trovava. **Ma un rito e' una cosa
    /// che cambia**: l'invito a trascinare vive prima del gesto e
    /// sparisce dopo, e il cielo dietro di lui passa dalla notte al
    /// giorno mentre lui sta fermo. Un testo che esiste solo prima non
    /// entrava in nessuna riga, e la tabella diceva zero sotto soglia
    /// **dicendo il vero su cio' che aveva guardato**.
    ///
    /// E' la stessa cecita' dell'iscrizione volontaria, su un altro
    /// asse: prima si escludeva per NOME, adesso non si esclude piu' per
    /// nome e si escludeva ancora per MOMENTO.
    Future<void> censisci(String momento) async {
          // OGNI TESTO DEL RITO, enumerato dall'albero e non da un elenco scritto.

          // **SI MISURANO TUTTI I TESTI, NON SOLO QUELLI ISCRITTI.**
          // Ordine CO voce 14, 3 settembre 2026.
          //
          // Qui c'era `.where((k) => k.value.startsWith('alba_'))`, cioe' **la
          // tabella guardava soltanto i testi a cui qualcuno aveva dato una chiave
          // che comincia per alba_**. Non era una svista di chi l'ha scritta: era
          // il modo di poter risalire al file e alla riga. Ma il risultato e' una
          // guardia che misura un insieme A ISCRIZIONE VOLONTARIA, e nessuno
          // obbliga nessuno a iscriversi.
          //
          // **Il fondatore ha visto un testo giallo illeggibile in questa
          // schermata mentre questa tabella diceva zero sotto soglia, e diceva il
          // vero**: quel testo non aveva la chiave, quindi per la tabella non
          // esisteva. Dieci righe misurate e tutte promosse sono una prova
          // eccellente di dieci testi, e non dicono niente sull'undicesimo.
          //
          // Adesso si enumerano tutti i `Text` con qualcosa scritto dentro. Chi ha
          // la chiave porta ancora file e riga; chi non ce l'ha porta le prime
          // parole di cio' che dice, che al fondatore basta per riconoscerlo a
          // schermo, ed e' l'informazione che serve davvero.
          final trovati = <(Finder, String, String)>[];
          for (final t in tester.widgetList<Text>(find.byType(Text))) {
            final scritto = (t.data ?? t.textSpan?.toPlainText() ?? '').trim();
            if (scritto.isEmpty) continue;
            // **NON SI SALTA PIU' CHI IL COLORE LO EREDITA. Ordine CO
            // voce 14**, 3 settembre 2026, e questa e' la riga che teneva
            // fuori dalla tabella proprio il testo che il fondatore vedeva.
            //
            // L'etichetta di un pulsante non porta uno stile suo: colore e
            // misura le arrivano dallo stile del pulsante che la contiene,
            // attraverso il `DefaultTextStyle`. Per questa riga quei testi
            // non avevano inchiostro, quindi non si potevano misurare,
            // quindi venivano saltati **in silenzio**. I due pulsanti
            // "Condividi" e "Custodisci" della scheda del Dono scrivevano in
            // oro sul pannello chiaro, **1,30 a uno**, e la tabella diceva
            // zero sotto soglia dicendo il vero su cio' che aveva guardato.
            //
            // Adesso lo stile si compone come lo compone Flutter: quello del
            // `Text`, e per cio' che manca quello ereditato dal contesto.
            if (t.data == null && t.textSpan == null) continue;
            final k = t.key;
            if (k is ValueKey<String> && k.value.startsWith('alba_')) {
              trovati.add((find.byKey(k), '`${k.value}`', dove(k.value)));
            } else {
              final breve =
                  scritto.length > 34 ? '${scritto.substring(0, 31)}...' : scritto;
              // Il testo si ritrova per contenuto: e' l'unica ancora che ha.
              trovati.add((
                find.text(scritto),
                breve.replaceAll('|', '/').replaceAll('\n', ' '),
                'senza chiave'
              ));
            }
          }
          for (final voce in trovati) {
            final trovato = voce.$1;
            if (tester.widgetList(trovato).length != 1) continue;
            final scatto = await scattoPer(trovato);
            final dati = scatto.dati;
            final larghezza = scatto.larghezza;
            final altezza = scatto.altezza;
            final testo = tester.widget<Text>(trovato);
            final rettangolo = tester.getRect(trovato);
            // **LO STILE COMPOSTO, come lo compone Flutter**: quello del
            // `Text` sopra quello ereditato. E' il solo modo di conoscere il
            // colore di un'etichetta di pulsante, che di suo non ne ha.
            final ereditato =
                DefaultTextStyle.of(tester.element(trovato)).style;
            final stile = ereditato.merge(testo.style);
            if (stile.color == null || stile.fontSize == null) continue;
            // Un testo alto zero o largo zero non si vede, e campionarne il fondo
            // vorrebbe dire leggere un punto a caso.
            if (rettangolo.width < 2 || rettangolo.height < 2) continue;
            final misura = stile.fontSize ?? 0;
            final peso = pesoDi(stile);
            final ruolo = ruoloDi(stile);
            final fondo = fondoSotto(dati, larghezza, altezza, rettangolo,
                // Chi il colore lo eredita e' un'etichetta di pulsante:
                // per lei il fondo e' la moda di tutto il riquadro, perche'
                // le lettere sono sottili e il riempimento e' la maggioranza.
                tuttoIlRiquadro: testo.style?.color == null,
                inchiostro: stile.color);
            // **IL FONDO SI PORTA DIETRO CHI CI STA SOPRA. Ordine CQ voce
            // 6.30, 5 settembre 2026.**
            //
            // Questa guardia e\' caduta su Codemagic, dove la build iOS gira
            // su macOS, dicendo soltanto: *questi fondi resi sono piu\' scuri
            // della superficie chiara dichiarata: #989282*. Un colore e
            // nient\'altro. **Con quel colore in mano non si cura niente**: non
            // si sa quale testo ci sta sopra, in quale momento, a quale riga.
            //
            // E\' la Regola C applicata a una guardia invece che a un rapporto:
            // **ogni difetto ha un padre**, e un difetto senza padre torna.
            fondiVisti.add((colore: fondo, chi: voce.$2, dove: voce.$3));
            final inchiostro = Color.alphaBlend(stile.color!, fondo);
            final contrasto = AccentoDelMaestro.contrastoFra(inchiostro, fondo);
            final soglia = RegimeChiaro.sogliaPer(
                etichetta: ruolo.etichetta, misura: misura, peso: peso);
            censite++;
            final passa = contrasto >= soglia;
              righe.add('| ${voce.$2} | $momento | ${voce.$3} | ${ruolo.nome} | '
                '${misura.toStringAsFixed(0)} | ${peso.toStringAsFixed(0)} | '
                '${esa(inchiostro)} | ${esa(fondo)} | '
                '**${contrasto.toStringAsFixed(2)}** | '
                '${soglia.toStringAsFixed(1)} | ${passa ? 'si\'' : '**NO**'} |');
            if (!passa) {
                sotto.add('${voce.$2} ($momento) a ${voce.$3}: '
                  '${contrasto.toStringAsFixed(2)} contro ${soglia.toStringAsFixed(1)} '
                  '(${esa(inchiostro)} su ${esa(fondo)}, ${misura.toStringAsFixed(0)} punti)');
            }
          }

    }

    // **PRIMA DEL GESTO**: qui vive l'invito, sul cielo notturno che
    // gia' si sta schiarendo.
    await censisci('prima del gesto');

    // Il gesto si compie: e' l'unico stato in cui il pannello chiaro esiste.
    await tester.tap(find.byKey(const Key('ritual_gesture')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    // La base del dono si apre, cosi' anche le sue righe entrano nella misura.
    // Si porta in vista prima di toccarla: la scheda scorre, e su uno schermo
    // reale il pulsante della base sta sotto la piega.
    await tester.ensureVisible(find.byKey(const Key('da_dove_nasce_apri')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('da_dove_nasce_apri')),
        warnIfMissed: false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byKey(const Key('gift_base_panel')), findsOneWidget,
        reason: 'la base del dono non si e\' aperta, quindi le sue righe non '
            'entrerebbero nella misura');

    /// UNO SCATTO PER TESTO, e non uno scatto per tutti.
    ///
    /// La scheda del dono SCORRE: alla misura reale il pulsante di condivisione
    /// sta sotto la piega, quindi il suo rettangolo cadeva fuori dal
    /// fotogramma e il fondo campionato risultava nero pieno. Un fondo che non
    /// e' nell'immagine non si misura: si porta in vista e si riscatta.
    await censisci('a rito compiuto');

    File('docs/tipografia/alba_contrasto.md').writeAsStringSync([
      '# Il contrasto del Rito dell\'Alba, misurato',
      '',
      '<!-- TESTI_MISURATI: $censite -->',
      '<!-- SOTTO_LA_SOGLIA: ${sotto.length} -->',
      '<!-- Generato da test/l_alba_si_legge_test.dart. Non si scrive a mano: '
          'si rigenera. -->',
      '',
      'Ordine P voce 11: **nessuna correzione prima che questa tabella '
          'esista.** Ogni riga e\' misurata su un fotogramma vero della '
          'schermata, alla misura reale del telefono, '
          '${schermoReale.width.toInt()} per ${schermoReale.height.toInt()} '
          'punti logici.',
      '',
      '## Come si misura, e perche\' cosi\'',
      '',
      'Il **fondo** non si calcola: si campiona. Il pannello del dono e\' un '
          'vetro semitrasparente e sfocato sopra una scena di sole, quindi il '
          'colore dietro una lettera non e\' quello dichiarato dal vetro ne\' '
          'quello dell\'immagine: e\' cio\' che esce dalla composizione. Si '
          'legge il colore PIU\' FREQUENTE nella fascia alta del rientro di '
          'ogni testo, dove non passa nessuna lettera. La moda e non la media, '
          'perche\' una lettera che sbordasse nella fascia sposterebbe la media '
          'verso l\'inchiostro e il contrasto risulterebbe migliore del vero.',
      '',
      'Il **file e la riga** si trovano cercando nel sorgente la chiave con cui '
          'il testo si presenta a video, non si scrivono a mano.',
      '',
      'Il **contrasto** e\' il rapporto WCAG di luminanza relativa, calcolato da '
          '`AccentoDelMaestro.contrastoFra`, che e\' la stessa porta da cui '
          'passa il colore degli accenti: due copie della stessa formula '
          'divergono.',
      '',
      'Le **soglie** vengono da `RegimeChiaro`: '
          '${RegimeChiaro.sogliaLettura} a 1 per il testo di lettura e di '
          'corpo, ${RegimeChiaro.sogliaTitoli} a 1 per i titoli da '
          '${RegimeChiaro.titoloGrande.toInt()} punti in su o da '
          '${RegimeChiaro.titoloGrandeInGrassetto.toInt()} in grassetto, '
          '${RegimeChiaro.sogliaEtichette} a 1 per le etichette, senza sconti, '
          'perche\' sono le piu\' piccole.',
      '',
      '## La tabella',
      '',
      '| Testo | Momento | File e riga | Ruolo | Misura | Peso | Inchiostro | Fondo reso | '
          'Contrasto | Soglia | Passa |',
      '| --- | --- | --- | --- | ---: | ---: | --- | --- | ---: | ---: | --- |',
      ...righe,
      '',
      if (sotto.isEmpty)
        'Nessun testo sotto la sua soglia.'
      else ...[
        '## Sotto la soglia',
        '',
        for (final s in sotto) '- $s',
      ],
      '',
    ].join('\n'));

    // LA SUPERFICIE DICHIARATA DEVE RESTARE VERA.
    //
    // `RegimeChiaro.superficieChiara` dichiara di essere il fondo PEGGIORE che
    // un testo trova davvero, e da lei discendono tutti gli inchiostri e tutti
    // gli accenti. Se un fondo campionato risultasse piu' scuro, la
    // dichiarazione mentirebbe e i colori calcolati su di lei sarebbero
    // ottimisti: e' esattamente il difetto che la voce 12 chiude.
    // Quanto e' scuro un fondo: piu' contrasta col bianco, piu' e' scuro.
    double quantoEScuro(Color c) =>
        AccentoDelMaestro.contrastoFra(c, Colors.white);
    final sogliaDelChiaro = quantoEScuro(RegimeChiaro.superficieChiara);

    // **I TRE PIU\' SCURI SI STAMPANO SEMPRE**, anche a prova verde: su
    // Windows questa e\' verde e su macOS e\' rossa, e senza questi numeri
    // la differenza fra due macchine non si vede affatto.
    final ordinati = [...fondiVisti]
      ..sort((a, b) => quantoEScuro(b.colore).compareTo(quantoEScuro(a.colore)));
    final iPiuScuri = ordinati
        .take(3)
        .map((f) => '${esa(f.colore)} sotto ${f.chi}')
        .join('; ');
    // ignore: avoid_print
    print('ORDINE CQ VOCE 6.30: superficie chiara dichiarata '
        '${esa(RegimeChiaro.superficieChiara)}, i tre fondi resi piu '
        'scuri: $iPiuScuri');

    final piuScuri = <String>[];
    for (final f in fondiVisti) {
      // **SI SEPARA PER APPARTENENZA, NON PER LUMINANZA. Ordine CQ voce
      // 6.30, 5 settembre 2026.**
      //
      // Qui c\'era un filtro sulla luminanza: *se il fondo contrasta col
      // bianco piu\' di quattro sta sul buio, e non lo guardo*. Era un modo
      // grossolano di dire una cosa vera, e su una macchina diversa si e\'
      // rotto: su macOS un campione e\' caduto su un pixel di cielo IN
      // TRANSIZIONE, #989282, che contrasta col bianco 2,7 e quindi il
      // filtro non lo scartava; confrontato con l\'avorio della carta
      // risultava piu\' scuro, e la guardia gridava a un difetto che non
      // c\'era. Su Windows lo stesso campione cade sul notturno pieno e la
      // prova passa: **la stessa guardia diceva due cose diverse su due
      // macchine**, ed e\' il peggio che possa fare.
      //
      // La superficie chiara riguarda **la carta del Dono e nient\'altro**.
      // Un testo appartiene al regime chiaro se vive li\', non se il suo fondo
      // somiglia a un certo grigio. L\'appartenenza si legge dal posto, che
      // questa stessa prova gia\' scrive in tabella.
      if (!f.dove.contains('ritual_gift_card.dart')) continue;
      if (quantoEScuro(f.colore) > sogliaDelChiaro) {
        piuScuri.add('${esa(f.colore)} sotto ${f.chi}, ${f.dove}');
      }
    }
    expect(piuScuri, isEmpty,
        reason: 'questi fondi resi sono piu\' scuri della superficie chiara '
            'dichiarata, quindi gli inchiostri calcolati su di lei sono '
            'ottimisti: ${piuScuri.join(", ")}');

    // La tabella e' scritta: adesso si giudica.
    expect(censite, greaterThanOrEqualTo(8),
        reason: 'la tabella ha censito solo $censite testi: la misura non ha '
            'visto tutte le righe che contano');
    expect(sotto, isEmpty,
        reason: 'questi testi del Rito dell\'Alba non si leggono sul fondo che '
            'hanno davvero:\n${sotto.join("\n")}');
  });

  group('P.12 il regime chiaro e\' governato dai token', () {
    test('i quattro token esistono e rispettano le proprie soglie', () {
      final letture = <String, double>{
        'testoSuChiaro': AccentoDelMaestro.contrastoFra(
            RegimeChiaro.testoSuChiaro, RegimeChiaro.superficieChiara),
        'testoMutoSuChiaro': AccentoDelMaestro.contrastoFra(
            RegimeChiaro.testoMutoSuChiaro, RegimeChiaro.superficieChiara),
      };
      for (final voce in letture.entries) {
        expect(voce.value, greaterThanOrEqualTo(RegimeChiaro.sogliaEtichette),
            reason: '${voce.key} misura ${voce.value.toStringAsFixed(2)} sul '
                'chiaro, contro i ${RegimeChiaro.sogliaEtichette} che le '
                'etichette chiedono senza sconti');
      }
      // L'accento passa per tutti e tre i Maestri, non per due su tre.
      for (final maestro in Maestro.values) {
        final accento = RegimeChiaro.accentoSuChiaro(maestro);
        expect(
            AccentoDelMaestro.contrastoFra(
                accento, RegimeChiaro.superficieChiara),
            greaterThanOrEqualTo(RegimeChiaro.sogliaLettura),
            reason: 'l\'accento di ${maestro.name} non si legge sul chiaro');
      }
      // Il fondo peggiore e' GIA' quello dichiarato: l'incasso della base e' il
      // punto in cui e' stato misurato, quindi non si compone una seconda volta.
      // La verifica che la dichiarazione resti vera la fa la prova che campiona
      // i fondi resi, non un secondo conto qui.
    });

    test('le soglie non si confondono fra loro', () {
      // Un'etichetta piccola NON prende lo sconto dei titoli, e questo e' il
      // difetto che la voce 12 chiude: la tentazione di trattare una riga
      // maiuscoletta come un titolo.
      expect(RegimeChiaro.sogliaPer(etichetta: true, misura: 12, peso: 700),
          RegimeChiaro.sogliaEtichette);
      expect(RegimeChiaro.sogliaPer(etichetta: false, misura: 16, peso: 400),
          RegimeChiaro.sogliaLettura);
      expect(RegimeChiaro.sogliaPer(etichetta: false, misura: 24, peso: 400),
          RegimeChiaro.sogliaTitoli);
      expect(RegimeChiaro.sogliaPer(etichetta: false, misura: 20, peso: 600),
          RegimeChiaro.sogliaTitoli);
      expect(RegimeChiaro.sogliaPer(etichetta: false, misura: 20, peso: 400),
          RegimeChiaro.sogliaLettura);
    });

    test('ogni superficie chiara e\' dichiarata, e dichiara perche\'', () {
      expect(SuperficieChiara.values, isNotEmpty);
      for (final s in SuperficieChiara.values) {
        expect(File(s.file).existsSync(), isTrue,
            reason: '${s.classe} dichiara un file che non esiste: ${s.file}');
        expect(File(s.file).readAsStringSync(), contains('class ${s.classe}'),
            reason: '${s.file} non contiene piu\' la classe ${s.classe}');
        expect(s.perche.length, greaterThan(40),
            reason: '${s.classe} non dichiara perche\' ha diritto di '
                'schiarire: in un\'app notturna una superficie chiara senza '
                'una ragione narrativa e\' una svista');
      }
    });

    test('nessuna schermata dipinge un fondo chiaro senza dichiararlo', () {
      // SI ENUMERA IL CODICE, non si tiene a mente. Chi usa i token del regime
      // chiaro deve essere una delle superfici dichiarate, oppure il file dei
      // token stesso.
      final dichiarate = SuperficieChiara.values.map((s) => s.file).toSet();
      final colpevoli = <String>[];
      for (final voce in sorgentiDiLib()) {
        final percorso = voce.path.replaceAll('\\', '/');
        if (percorso.endsWith('tokens/regime_chiaro.dart')) continue;
        final sorgente = voce.readAsStringSync();
        final usa = sorgente.contains('RegimeChiaro.testoSuChiaro') ||
            sorgente.contains('RegimeChiaro.testoMutoSuChiaro') ||
            sorgente.contains('RegimeChiaro.velatura');
        if (usa && !dichiarate.contains(percorso)) {
          colpevoli.add(percorso);
        }
      }
      expect(colpevoli, isEmpty,
          reason: 'questi file dipingono il regime chiaro senza essere '
              'dichiarati in SuperficieChiara:\n${colpevoli.join("\n")}');
    });
  });

  group('P.13 le etichette dell\'Alba', () {
    test('nessuna etichetta dell\'Alba resta al pavimento tipografico', () {
      // Si legge il sorgente: le etichette dell'Alba non devono piu' passare
      // dal ruolo `etichetta`, che vale il pavimento di dodici punti, ne'
      // portare il maiuscoletto.
      for (final file in const [
        'lib/features/rituals/ritual_gift_card.dart',
        'lib/design_system/components/riga_del_dono.dart',
      ]) {
        final sorgente = File(file).readAsStringSync();
        expect(sorgente.contains('TypographyTokens.etichetta()'), isFalse,
            reason: '$file usa ancora il ruolo etichetta, che vale il '
                'pavimento di ${TypographyTokens.pavimento.toInt()} punti: la '
                'voce 13 chiede il ruolo didascalia, cioe\' sedici');
        expect(sorgente.contains('.toUpperCase()'), isFalse,
            reason: '$file porta ancora un maiuscoletto');
      }
    });

    test('sul chiaro l\'oro non e\' colore di testo', () {
      // La voce 13 lo dice e lo dice giusto: l'oro non ce la fa sul chiaro.
      // Questa prova lo MISURA invece di crederci, e serve da presidio contro
      // chi domani riportasse l'oro su una didascalia del pannello.
      const oro = Color(0xFFD4AF37);
      final contrasto =
          AccentoDelMaestro.contrastoFra(oro, RegimeChiaro.superficieChiara);
      expect(contrasto, lessThan(RegimeChiaro.sogliaLettura),
          reason: 'se l\'oro passasse, questa prova andrebbe cancellata e non '
              'aggirata');
      final sorgente =
          File('lib/features/rituals/ritual_gift_card.dart').readAsStringSync();
      expect(sorgente.contains('ColorTokens.gold'), isFalse,
          reason: 'il pannello chiaro usa l\'oro come colore, e sul chiaro '
              'l\'oro puo\' essere solo filetto o bordo');
    });
  });
}
