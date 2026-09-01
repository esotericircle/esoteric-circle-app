import 'package:esoteric_circle/core/arts/art_catalog.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/feature_flags/feature_catalog.dart';
import 'package:esoteric_circle/core/feature_flags/feature_flag_service.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/components/titolo_che_non_si_spezza.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/design_system/tokens/typography_tokens.dart';
import 'package:esoteric_circle/features/maestri/domain_screen.dart';
import 'package:esoteric_circle/features/maestri/maestro_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// I TITOLI SI MISURANO DIPINTI. Ordine CE voce 11.
///
/// **IL FATTO DELL'ORDINE CD:** i titoli gialli erano stati CONTATI, 119, e mai
/// misurati. Alla misura sono risultati quindici grandezze diverse, dal sedici
/// al sessantaquattro, ognuna scritta a mano nel punto in cui serviva.
///
/// **UN CONTEGGIO NON E' UNA MISURA, e nemmeno una dichiarazione lo e'.** Un
/// titolo puo' dichiarare venti punti e finire dipinto a quattordici, perche'
/// un `FittedBox` lo rimpicciolisce invece di spezzarlo: e' successo davvero,
/// col titolo della sottocategoria "Numerologia", e il fondatore lo ha visto
/// prima di ogni prova. Qui la grandezza si legge DIPINTA, cioe' moltiplicata
/// per la scala che il ramo del disegno le applica, e non dichiarata.
///
/// **PAROLE DEL FONDATORE, 30 agosto 2026:** "ma bisogna controllare quando e
/// se va a capo in modo che sia eleganteolo". Quindi non basta la grandezza:
/// si guarda anche DOVE si spezza, alla larghezza vera che quel titolo ha
/// davvero addosso nell'app, non a una larghezza scelta qui.
void main() {
  /// Le sei grandezze della scala. Un testo che ne porta una e' un titolo, e
  /// il numero si legge dai ruoli, non si ricopia: il giorno che la scala
  /// cambia, cambia anche questa prova.
  final misureDeiRuoli = <double>{
    TypographyTokens.titoloDiRiga().fontSize!,
    TypographyTokens.titoloScheda().fontSize!,
    TypographyTokens.titoloDiSchermata().fontSize!,
    TypographyTokens.titoloSezione().fontSize!,
    TypographyTokens.cerimoniale().fontSize!,
    TypographyTokens.cerimonialeGrande().fontSize!,
  };

  final famigliaDeiTitoli = TypographyTokens.titoloScheda().fontFamily;

  /// Sotto tredici punti un titolo non si legge piu': e' la stessa soglia
  /// che la piastrella di un\'arte usa nel dominio del Maestro.
  const pavimentoLeggibile = 13.0;

  /// Un titolo trovato nell'albero del disegno, con la sua verita' misurata.
  final trovati = <_Titolo>[];

  void fruga(WidgetTester tester, String dove) {
    void scendi(RenderObject r) {
      if (r is RenderParagraph) {
        final misura = r.text.style?.fontSize;
        // **LA MISURA DA SOLA NON BASTA A DIRE "TITOLO".** La prima stesura
        // guardava solo il numero, e sedici punti li porta anche `corpo()`:
        // finiva per misurare gli anticipi delle arti come se fossero titoli.
        // Un titolo e' la famiglia del display E una misura della scala.
        final famiglia = r.text.style?.fontFamily;
        // **UN TITOLO CHE SI E\' GIA\' ABBASSATO NON PORTA PIU\' LA MISURA
        // DEL RUOLO.** Provato: stretta la piastrella a centotto punti,
        // il nome si spezzava davvero e la prova restava verde, perche'
        // `TitoloCheNonSiSpezza` disegna un `Text` con una misura sua,
        // che nella scala non c'e'. Il rosso non scattava, quindi si e'
        // allargata la grandezza misurata: si riconosce anche chi e'
        // nato da quel rimedio, e li' la misura promessa e' quella dello
        // stile che gli e' stato dato.
        final abbassato = _nasceDaUnRimedio(r);
        if (misura != null &&
            famiglia == famigliaDeiTitoli &&
            (abbassato || misureDeiRuoli.contains(misura))) {
          trovati.add(_Titolo(
            dove: dove,
            testo: r.text.toPlainText(),
            dichiarata: misura,
            // **LA SCALA SI PRENDE DAI RIQUADRI, NON DALLA TRASFORMAZIONE.**
            // La prima stesura leggeva `getTransformTo(null)`, ed e' la via
            // che sembra giusta: solo che, misurata, torna 1,0 anche
            // dentro un `FittedBox` che sta scalando a un ottavo. Provato
            // a mano, `SizedBox(width: 40)` attorno a un testo da venti
            // punti: la trasformazione dice 1,0 e il riquadro dice 0,125.
            // Il rosso non scattava, quindi e' cambiata la grandezza
            // misurata, non la soglia.
            scala: _scalaDipinta(r),
            larghezza: r.constraints.maxWidth,
            righe: _righeDi(r),
          )..catena = _catenaDi(r));
        }
      }
      r.visitChildren(scendi);
    }

    scendi(tester.binding.rootElement!.renderObject!);
  }

  Widget dominio(Maestro m) => MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (_) => MaestroController(initial: ThemeKey.of(m))),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => EntitlementService()),
          ChangeNotifierProvider(create: (_) => ProfileController()),
          ChangeNotifierProvider(create: (_) => BirthIdentityController()),
          ChangeNotifierProvider(
            create: (ctx) =>
                FeatureFlagService(entitlement: ctx.read<EntitlementService>())
                  ..initialize(),
          ),
        ],
        child: MaterialApp(
          home: MaestroScope(
            child: Scaffold(body: MaestroScreen(maestro: m, demo: true)),
          ),
        ),
      );

  Widget arti(Maestro m) => MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (_) => MaestroController(initial: ThemeKey.of(m))),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => EntitlementService()),
          ChangeNotifierProvider(create: (_) => ProfileController()),
          ChangeNotifierProvider(create: (_) => BirthIdentityController()),
          ChangeNotifierProvider(
            create: (ctx) =>
                FeatureFlagService(entitlement: ctx.read<EntitlementService>())
                  ..initialize(),
          ),
        ],
        child: MaterialApp(
          home: MaestroScope(child: DomainScreen(maestro: m)),
        ),
      );

  setUp(trovati.clear);

  Future<void> percorriITreDomini(WidgetTester tester) async {
    // **LA FINESTRA SI PIANTA A 390 PER 844.** Il default della prova e'
    // 800 per 600, cioe' un telefono che non esiste, e a quella larghezza
    // nessun titolo andrebbe mai a capo: la prova passerebbe senza guardare
    // niente.
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    for (final m in Maestro.values) {
      await tester.pumpWidget(dominio(m));
      await tester.pump();
      fruga(tester, 'dominio di ${m.name}');
      await tester.pumpWidget(arti(m));
      await tester.pump();
      fruga(tester, 'arti di ${m.name}');
    }
  }

  testWidgets('nessun titolo viene dipinto sotto il pavimento leggibile',
      (tester) async {
    // **NON SI CHIEDE CHE NESSUNO SI ABBASSI, SI CHIEDE FIN DOVE.** Un
    // titolo che scende ha una ragione: la parola piu' lunga non ci sta, e
    // scendere e' meglio che spezzarla. Quello che non ha nessuna ragione
    // e' scendere SENZA FONDO, ed e' cio' che faceva un `FittedBox` nudo:
    // "Oroscopo Personalizzato" dichiarava sedici punti e ne veniva
    // dipinto otto e sei, sulla piastrella di un\'arte nel dominio.
    await percorriITreDomini(tester);
    final illeggibili =
        trovati.where((t) => t.dipinta < pavimentoLeggibile - 0.01).toList();
    final abbassati = trovati.where((t) => t.scala < 0.999).length;
    // ignore: avoid_print
    print('ORDINE CE VOCE 11: titoli misurati dipinti ${trovati.length}, '
        'abbassati dal disegno $abbassati, scesi sotto il pavimento di '
        '$pavimentoLeggibile punti ${illeggibili.length}');
    expect(illeggibili, isEmpty,
        reason: 'questi titoli finiscono dipinti sotto la soglia in cui si '
            'leggono ancora: ${illeggibili.map((t) => t.racconto).toList()}');
  });

  testWidgets('e nessuno si spezza a meta\' parola', (tester) async {
    await percorriITreDomini(tester);
    final spezzati = trovati.where((t) => t.spezzaAMetaParola).toList();
    // ignore: avoid_print
    print('ORDINE CE VOCE 11: titoli su piu\' righe '
        '${trovati.where((t) => t.righe.length > 1).length}, spezzati a meta\' '
        'parola ${spezzati.length}');
    expect(spezzati, isEmpty,
        reason: 'questi titoli spezzano una parola a meta\': '
            '${spezzati.map((t) => t.racconto).toList()}');
  });

  testWidgets('ogni nome del catalogo entra elegante dove quel ruolo vive',
      (tester) async {
    // **IL NOME PIU\' LUNGO E\' UN RILEVATORE GRATUITO.** Il precedente
    // dell\'ordine CC: il difetto stava li' da sempre e la parola corta lo
    // teneva nascosto. Qui si provano TUTTI i nomi del catalogo, non uno.
    //
    // **LE LARGHEZZE NON SI INVENTANO, SI RACCOLGONO.** La prima stesura
    // provava ogni ruolo a quattro larghezze scelte a mano e trovava tre
    // colpe a duecentodieci punti: solo che a duecentodieci punti, in
    // quest\'app, ci vive il titolo di una riga, non quello di una sezione.
    // Era una prova su un\'app che non esiste. Adesso le coppie di ruolo e
    // larghezza si prendono dall\'albero vero, percorrendo i tre domini.
    //
    // Il limite di questa prova sta scritto: copre i punti che i tre
    // domini montano, non ogni schermata dell\'app.
    await percorriITreDomini(tester);
    final coppie = <String, List<double>>{};
    for (final t in trovati) {
      // Un paragrafo vuoto ha una larghezza qualunque, e la sua non e' una
      // larghezza di titolo: nel dominio ce n'e' uno da ventidue punti.
      if (t.testo.trim().isEmpty) continue;
      if (!t.larghezza.isFinite || t.larghezza <= 0) continue;
      coppie['${t.dichiarata}@${t.larghezza}'] = <double>[
        t.dichiarata,
        t.larghezza
      ];
    }
    final titoli = <String>{
      ...ArtCatalog.all.map((a) => a.title),
      ...FeatureCatalog.all.map((f) => f.title),
    }.toList();
    // **LA DOMANDA GIUSTA NON E\' "SI SPEZZA A SEDICI PUNTI".** Sei nomi
    // del catalogo si spezzerebbero a sedici punti su centotrentotto, e
    // sarebbe una prova che condanna l\'app per una cosa che l\'app non fa:
    // in quel punto il titolo passa da `TitoloCheNonSiSpezza`, che scende
    // di corpo prima di spezzare. La domanda vera e\' se ESISTE una misura
    // leggibile a cui quel nome non si spezza. Se non esiste, nessun
    // rimedio salva quel punto e il nome va accorciato.
    final colpe = <String>[];
    for (final c in coppie.values) {
      for (final t in titoli) {
        final stile = TypographyTokens.display(size: c[0]);
        final corpo = TitoloCheNonSiSpezza.corpoCheEntra(t, stile, c[1],
            minimo: pavimentoLeggibile);
        final righe =
            _righeConPittore(t, stile.copyWith(fontSize: corpo), c[1]);
        for (var k = 0; k < righe.length - 1; k++) {
          if (righe[k].isNotEmpty && !righe[k].endsWith(' ')) {
            colpe.add('$t su ${c[1]} punti: nemmeno a $corpo '
                'entra senza spezzarsi -> $righe');
          }
        }
      }
    }
    // ignore: avoid_print
    print('ORDINE CE VOCE 11: coppie ruolo e larghezza raccolte '
        '${coppie.length}, nomi del catalogo provati ${titoli.length}, '
        'senza una misura leggibile che non spezzi ${colpe.length}');
    expect(colpe, isEmpty,
        reason: 'per questi nomi non esiste nessuna misura leggibile che '
            'non li spezzi dentro una parola: $colpe');
  });

  test('la scala dei titoli non ha due gradini alla stessa altezza', () {
    // Sei ruoli, sei grandezze diverse: se due coincidono, uno dei due non
    // serve e il giorno dopo qualcuno ne inventa un settimo a meta' strada.
    // ignore: avoid_print
    print('ORDINE CE VOCE 11: gradini della scala dei titoli '
        '${misureDeiRuoli.length}, dal ${misureDeiRuoli.reduce(
      (a, b) => a < b ? a : b,
    )} al ${misureDeiRuoli.reduce((a, b) => a > b ? a : b)}');
    expect(misureDeiRuoli.length, 6);
  });
}

/// Un titolo come e' stato DIPINTO, non come si dichiarava.
class _Titolo {
  _Titolo({
    required this.dove,
    required this.testo,
    required this.dichiarata,
    required this.scala,
    required this.larghezza,
    required this.righe,
  });

  final String dove;
  final String testo;
  final double dichiarata;
  final double scala;
  final double larghezza;
  final List<String> righe;

  double get dipinta => dichiarata * scala;

  bool get spezzaAMetaParola {
    for (var i = 0; i < righe.length - 1; i++) {
      if (righe[i].isNotEmpty && !righe[i].endsWith(' ')) return true;
    }
    return false;
  }

  /// La catena dei genitori, per sapere CHI sta rimpicciolendo.
  String catena = '';

  String get racconto => '$dove: "$testo" dichiara $dichiarata e viene '
      'dipinto a ${dipinta.toStringAsFixed(1)} su $larghezza punti $righe';
}

/// Le righe di un titolo alla larghezza che ha DAVVERO addosso nell'app.
///
/// `RenderParagraph` non sa dire dove si e' spezzato, quindi la stessa
/// campitura si rifa' con un pittore: stesso testo, stesso stile, e la
/// larghezza presa dai vincoli veri di quel punto dell'albero. Dentro un
/// `FittedBox` la larghezza e' infinita, perche' li' il testo non va a capo,
/// viene scalato: e' il caso che la prima prova qui sopra prende.
List<String> _righeDi(RenderParagraph r) {
  final testo = r.text.toPlainText();
  if (testo.isEmpty) return const [];
  final larghezza = r.constraints.maxWidth.isFinite
      ? r.constraints.maxWidth
      : double.infinity;
  final p = TextPainter(
    text: r.text,
    textDirection: r.textDirection,
    maxLines: r.maxLines,
  )..layout(maxWidth: larghezza);
  return _righeDaConfine(
      testo, (i) => p.getLineBoundary(TextPosition(offset: i)));
}

List<String> _righeConPittore(String testo, TextStyle stile, double larghezza) {
  final p = TextPainter(
    text: TextSpan(text: testo, style: stile),
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: larghezza);
  return _righeDaConfine(
      testo, (i) => p.getLineBoundary(TextPosition(offset: i)));
}

/// Le righe vere di un testo gia' impaginato, prese una alla volta dal confine
/// di riga: e' l'unico modo di sapere DOVE si e' spezzato, e non solo quante
/// righe sono venute fuori.
List<String> _righeDaConfine(String testo, TextRange Function(int) confine) {
  final righe = <String>[];
  var cur = 0;
  while (cur < testo.length && righe.length < 40) {
    final r = confine(cur);
    if (r.end <= cur) break;
    righe.add(testo.substring(r.start, r.end));
    cur = r.end;
  }
  return righe;
}

/// **DI QUANTO IL DISEGNO RIMPICCIOLISCE QUESTO TESTO.**
///
/// Si risale la catena dei genitori e, per ogni `FittedBox` incontrato,
/// si chiede a `applyBoxFit` quanto sta comprimendo il proprio figlio: e'
/// lo stesso conto che poi fa il disegno. Le scale si moltiplicano, perche'
/// due adattatori annidati si compongono.
double _scalaDipinta(RenderObject partenza) {
  var scala = 1.0;
  RenderObject? r = partenza;
  while (r != null) {
    final padre = r.parent;
    if (padre is RenderFittedBox && padre.child != null) {
      final figlio = padre.child!.size;
      if (figlio.width > 0 && figlio.height > 0) {
        final f = applyBoxFit(padre.fit, figlio, padre.size);
        if (f.source.width > 0) {
          scala *= f.destination.width / f.source.width;
        }
      }
    }
    r = padre;
  }
  return scala;
}

String _catenaDi(RenderObject r) {
  final nomi = <String>[];
  RenderObject? c = r.parent;
  var n = 0;
  while (c != null && n < 14) {
    nomi.add(c.runtimeType.toString());
    c = c.parent;
    n++;
  }
  return nomi.join(' < ');
}

/// Vero se questo testo e' nato da `TitoloCheNonSiSpezza`, cioe' se ha gia'
/// scelto una misura sua per non spezzare una parola.
bool _nasceDaUnRimedio(RenderObject r) =>
    _creatoreDi(r).contains('TitoloCheNonSiSpezza');

String _creatoreDi(RenderObject r) {
  RenderObject? c = r;
  var n = 0;
  while (c != null && n < 20) {
    final d = c.debugCreator;
    if (d is DebugCreator) {
      final chain = d.element.debugGetCreatorChain(8);
      if (chain.contains('TitoloCheNonSiSpezza')) return chain;
    }
    c = c.parent;
    n++;
  }
  return 'ignoto';
}
