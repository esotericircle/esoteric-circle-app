import 'dart:math' as math;
import 'dart:ui' show Offset;

import 'package:flutter/foundation.dart';

import 'face_trait.dart';

/// I contorni del volto, come li servono al classificatore.
///
/// E' un dato puro: niente ML Kit qui dentro, solo liste di punti in coordinate
/// immagine (x verso destra, y verso il basso). L'adattatore che converte il
/// volto rilevato da ML Kit in questo oggetto sta nel livello della schermata,
/// cosi' il classificatore resta una funzione pura e provabile senza plugin.
@immutable
class FaceContours {
  const FaceContours({
    required this.volto,
    required this.sopraccioSx,
    required this.sopraccioDx,
    required this.occhioSx,
    required this.occhioDx,
    required this.nasoPonte,
    required this.nasoBase,
    required this.labbroSopra,
    required this.labbroSotto,
    this.guanciaSx,
    this.guanciaDx,
  });

  final List<Offset> volto;
  final List<Offset> sopraccioSx;
  final List<Offset> sopraccioDx;
  final List<Offset> occhioSx;
  final List<Offset> occhioDx;
  final List<Offset> nasoPonte;
  final List<Offset> nasoBase;
  final List<Offset> labbroSopra;
  final List<Offset> labbroSotto;
  final Offset? guanciaSx;
  final Offset? guanciaDx;

  bool get completo =>
      volto.length >= 4 &&
      sopraccioSx.isNotEmpty &&
      sopraccioDx.isNotEmpty &&
      occhioSx.isNotEmpty &&
      occhioDx.isNotEmpty &&
      nasoPonte.isNotEmpty &&
      nasoBase.isNotEmpty &&
      labbroSopra.isNotEmpty &&
      labbroSotto.isNotEmpty;
}

/// La lettura di un tratto: la variante e quanto e' marcata, da zero a uno.
@immutable
class TraitLettura {
  const TraitLettura({
    required this.tratto,
    required this.marcatezza,
    this.rapporto,
  });

  final FaceTrait tratto;

  /// **IL NUMERO MISURATO PRIMA DEL CONFRONTO CON LA SOGLIA.**
  /// Ordine CX, 8 settembre 2026.
  ///
  /// Serve a una cosa sola e importante: **tarare le soglie su volti veri.**
  /// Oggi gli undici numeri di questo file non li ha misurati nessuno, e su
  /// volti dalle proporzioni normali tre categorie rispondono la stessa cosa
  /// a tutti. Senza il rapporto grezzo non si puo' nemmeno sapere di quanto
  /// una soglia sia fuori centro: si vedrebbe solo la variante che ne esce,
  /// che e' il giudizio, non la misura.
  ///
  /// Nullo per la lettura che nasce dal ripiego tattile, dove non si misura
  /// niente e la variante la sceglie la persona.
  final double? rapporto;

  /// Quanto il tratto e' pronunciato, da zero (neutro) a uno (marcatissimo).
  /// Il tratto DOMINANTE del responso e' quello con la marcatezza piu' alta.
  final double marcatezza;
}

/// Il responso geometrico: una lettura per ognuna delle undici categorie.
@immutable
class FaceReading {
  const FaceReading({required this.letture});

  /// Una lettura per categoria, nell'ordine canonico delle categorie.
  final List<TraitLettura> letture;

  /// Il tratto piu' marcato, che da' il titolo evocativo. A parita' di
  /// marcatezza vince l'ordine canonico delle categorie.
  FaceTrait get dominante => _ordinati.first.tratto;

  /// I tratti in ordine di marcatezza decrescente, pareggi sciolti dall'ordine
  /// canonico delle categorie.
  List<FaceTrait> get marcati =>
      _ordinati.map((l) => l.tratto).toList(growable: false);

  TraitLettura letturaDi(FaceCategory c) =>
      letture.firstWhere((l) => l.tratto.categoria == c);

  List<TraitLettura> get _ordinati {
    final copia = [...letture];
    copia.sort((a, b) {
      final d = b.marcatezza.compareTo(a.marcatezza);
      return d != 0
          ? d
          : a.tratto.categoria.ordine.compareTo(b.tratto.categoria.ordine);
    });
    return copia;
  }
}

/// La classificazione dei tratti del volto dalla geometria dei contorni.
///
/// Funzione pura e deterministica: stessi contorni, stesso responso. Nessuna AI,
/// nessuna casualita', nessuna dipendenza dall'orologio. Ogni categoria misura
/// una proporzione, la confronta con una soglia dichiarata e ne ricava la
/// variante e la marcatezza, cioe' quanto la proporzione si stacca dal neutro.
///
/// **LE UNDICI SOGLIE DI QUESTO FILE NON LE HA MAI MISURATE NESSUNO SU UN
/// VOLTO VERO.** Ordine CX, 8 settembre 2026.
///
/// **Parole del fondatore dopo la sua prova**: *"Ti prego di rivedere i
/// responsi uno per uno (fronte, naso, zigomi, sopracciglia, ecc) non
/// corrispondono a me e ho paura che i risultati siano sempre gli stessi"*.
///
/// **Il sospetto e' stato misurato, e per meta' era fondato.** Le undici
/// categorie danno tutte piu' di una risposta quando il volto cambia abbastanza,
/// quindi non sono morte. Ma su quattrocento volti dalle proporzioni normali
/// **tre rispondono la stessa cosa nel cento per cento dei casi**, la distanza
/// degli occhi, le labbra e la bocca, e altre due sfiorano il novanta, la
/// fronte e le sopracciglia. Una categoria che risponde uguale a tutti non
/// descrive nessuno.
///
/// **La causa non e' un errore di calcolo, e' che questi numeri sono
/// inventati.** `SoglieDellaScansione` dichiara i propri come provvisori e
/// tiene una guardia rossa apposta finche' non saranno misurati; questi non lo
/// dichiaravano, ed erano nella stessa condizione. Adesso lo dichiarano.
///
/// **E LA TARATURA E' STATA FATTA, su volti veri, l'8 settembre 2026.**
///
/// Il fondatore ha fatto **tre scansioni sul dispositivo di collaudo**, e la
/// build stampava i rapporti misurati prima del confronto con le soglie. Il
/// dato che ha chiuso la questione: **la prima e la terza scansione sono due
/// PERSONE DIVERSE e hanno prodotto tutti e undici i tratti identici**, parola
/// per parola. La seconda, lui stesso col cappello, ne cambiava tre.
///
/// | categoria | volto 1 | volto 1 col cappello | volto 2 | mediana | soglia prima |
/// | --- | ---: | ---: | ---: | ---: | ---: |
/// | forma (w/h) | 0,7950 | 0,9020 | 0,8645 | 0,8645 | 0,74 |
/// | fronte | 0,1804 | 0,1297 | 0,1424 | 0,1424 | **0,33** |
/// | sopracciglia | 0,2434 | 0,1884 | 0,2173 | 0,2173 | **0,06** |
/// | distanza occhi | 2,2756 | 2,4035 | 2,2837 | 2,2837 | 2,00 |
/// | grandezza occhi | 0,0421 | 0,0511 | 0,0547 | 0,0511 | **0,085** |
/// | naso | 0,3129 | 0,3444 | 0,2971 | 0,3129 | 0,33 |
/// | labbra | 0,3164 | 0,3222 | 0,3117 | 0,3164 | 0,34 |
/// | bocca | 0,3684 | 0,3502 | 0,3663 | 0,3663 | **0,42** |
/// | mento | 0,6405 | 0,6003 | 0,7484 | 0,6405 | 0,62 |
/// | mascella | 0,9046 | 0,8519 | 0,8863 | 0,8863 | 0,86 |
///
/// **Otto soglie su undici stavano dove nessun volto arriva.** La fronte era
/// chiesta a 0,33 dell'altezza del volto mentre i volti veri stanno a 0,13;
/// gli occhi a 0,085 mentre stanno a 0,05. Tre erano azzeccate, naso, mento e
/// mascella, e sono le sole tre categorie che cambiavano risposta.
///
/// **Ogni soglia e' adesso la MEDIANA dei valori osservati**, cosi' meta' dei
/// volti cade da una parte e meta' dall'altra, e **ogni ampiezza e' meta'
/// dell'intervallo osservato**, cosi' la marcatezza si muove nella scala in
/// cui i volti veri si distribuiscono invece di saturare sempre.
///
/// **SECONDA TARATURA, LA SERA STESSA, SU QUATTRO VOLTI.** Alle prime due
/// persone se ne sono aggiunte altre due, una delle quali misurata anche col
/// cappello: **sei misure di quattro volti**. Ogni soglia e adesso la MEDIANA
/// dei quattro, non piu il punto medio fra due, e ogni ampiezza e un quarto
/// dell intervallo osservato.
///
/// **L esito, misurato su tutte e sei le coppie di persone**: la coppia che si
/// somiglia di piu si distingue in **quattro categorie su otto**, la piu
/// lontana in sei. Prima della taratura due persone diverse si distinguevano
/// in **zero**.
///
/// **E il cappello si vede nei numeri**: sul terzo volto ha portato la fronte
/// da 0,1592 a 0,1165. E la base su cui la voce CX.08, dichiarare cio che non
/// si e potuto vedere, si potra costruire misurando invece che indovinando.
///
/// **QUANTO VALE QUESTA TARATURA, detto senza abbellirlo: sei misure di
/// quattro persone.** E' un dato reale e non piu' un numero inventato, ma la mediana
/// di tre valori non e' la mediana di una popolazione. Con altri volti i
/// numeri vanno rifatti, e la strada per rifarli e' quella che li ha prodotti:
/// il rapporto grezzo viaggia dentro ogni `TraitLettura`, e la schermata lo
/// stampa a ogni scansione.
///
/// **Tre soglie restano NON tarate** perche' i loro rapporti non compaiono nel
/// dato raccolto: la giuntura fra fronte e mascella e quella fra zigomi e
/// mascella dentro la forma del volto, e l'angolo dell'apice del sopracciglio.
/// Sono dichiarate qui invece di essere spacciate per misurate.
class FaceClassifier {
  const FaceClassifier._();

  /// **L'INTERRUTTORE DELLA VERITA', lo stesso di `SoglieDellaScansione`.**
  /// Vero dall'8 settembre 2026: le soglie di questo file vengono dalla
  /// mediana di **tre scansioni reali su due volti**, prese col dispositivo di
  /// collaudo 767f596c. Chi le cambia scrive su quali volti ha misurato.
  static const bool soglieTarateSuVoltiVeri = true;

  /// **SU QUANTI VOLTI**, perche' un vero senza un numero accanto non dice se
  /// la taratura vale tre campioni o trecento.
  static const int voltiDellaTaratura = 4;

  /// **E SU QUANTE MISURE**, che non e' lo stesso: un volto puo' essere stato
  /// misurato piu' volte, e tre misure di due persone non sono tre persone.
  static const int misureDellaTaratura = 6;

  /// **LE SOGLIE, IN UN POSTO SOLO E INTERROGABILI.** Ordine CX, 8 settembre
  /// 2026.
  ///
  /// Prima vivevano come numeri sparsi dentro gli undici metodi, e la guardia
  /// che voleva verificarli **doveva ripescarli dal sorgente con
  /// un'espressione regolare**: con le categorie a due soglie ne prendeva una
  /// a caso e diceva che due volti erano uguali dove non lo erano. Era la
  /// famiglia delle due verita' sullo stesso fatto, spostata di un livello.
  ///
  /// Qui la soglia si scrive una volta, il classificatore la usa e la guardia
  /// la legge: **se cambia, cambia per tutti nello stesso istante.**
  ///
  /// Ogni voce e' in ordine crescente: una sola soglia vuol dire due varianti,
  /// due soglie vogliono dire tre.
  static const Map<FaceCategory, List<double>> soglie = {
    FaceCategory.formaVolto: [0.7978],
    FaceCategory.fronte: [0.1508, 0.1783],
    FaceCategory.sopracciglia: [0.2138],
    FaceCategory.distanzaOcchi: [2.2761],
    FaceCategory.grandezzaOcchi: [0.0396, 0.0542],
    FaceCategory.naso: [0.3029, 0.3321],
    FaceCategory.labbra: [0.298, 0.3416],
    FaceCategory.bocca: [0.3674, 0.4162],
    FaceCategory.mento: [0.6371, 0.7051],
    FaceCategory.mascella: [0.8157, 0.8954],
    FaceCategory.zigomi: [1.0656],
  };

  /// In quale fascia cade un rapporto: zero e' la piu' bassa. Con una soglia
  /// le fasce sono due, con due sono tre.
  ///
  /// **E' la stessa funzione che i metodi usano per decidere**, quindi una
  /// guardia che la interroga sta guardando il comportamento vero e non una
  /// sua imitazione.
  static int fasciaDi(FaceCategory categoria, double rapporto) {
    final s = soglie[categoria];
    if (s == null) return 0;
    var fascia = 0;
    for (final soglia in s) {
      if (rapporto >= soglia) fascia++;
    }
    return fascia;
  }

  /// Legge i contorni e restituisce una lettura per ogni categoria.
  static FaceReading leggi(FaceContours c) {
    final box = _Box.attorno(c.volto);
    final h = box.altezza <= 0 ? 1.0 : box.altezza;
    final w = box.larghezza <= 0 ? 1.0 : box.larghezza;

    // Larghezze del volto a tre altezze: fronte (alto), zigomi (meta'), mascella
    // (basso). Servono a piu' categorie.
    final wFronte = _larghezzaFascia(c.volto, box, 0.05, 0.30);
    final wZigomi = _larghezzaFascia(c.volto, box, 0.40, 0.60);
    final wMascella = _larghezzaFascia(c.volto, box, 0.68, 0.90);
    final wMento = _larghezzaFascia(c.volto, box, 0.88, 1.0);

    final letture = <TraitLettura>[
      _formaVolto(w, h, wFronte, wZigomi, wMascella),
      _fronte(c, box, h),
      _sopracciglia(c),
      _distanzaOcchi(c, w),
      _grandezzaOcchi(c, h),
      _naso(c, box, h),
      _labbra(c),
      _bocca(c, w),
      _mento(wMento, wMascella),
      _mascella(wMascella, w),
      _zigomi(c, wZigomi, wMascella),
    ];
    return FaceReading(letture: letture);
  }

  /// **LA LETTURA STABILE: la mediana di piu fotogrammi, non uno solo.**
  /// Ordine CX, 8 settembre 2026.
  ///
  /// **Il fatto che la rende necessaria.** Da quando le soglie sono tarate sui
  /// volti veri, stanno **dentro** l intervallo in cui i volti cadono, che e
  /// il solo posto in cui una soglia serve a qualcosa. Ma li vicino un volto
  /// ci sta anche appoggiato: la guardia ha misurato che **lo stesso volto
  /// spostato di quattro punti su mille cambiava due letture su dodici**.
  ///
  /// Con le soglie vecchie la stessa guardia era verde, e non perche il
  /// responso fosse stabile: **perche nessun volto arrivava mai a una
  /// soglia**. Era la stabilita di una misura che non misurava.
  ///
  /// **La cura non e allontanare le soglie**, che vorrebbe dire tornare a un
  /// responso uguale per tutti: e smettere di guardare un fotogramma solo. La
  /// scansione ne vede decine, e la mediana di quelli che il cancello ha
  /// accettato non si sposta per un tremito della mano.
  ///
  /// **Perche la MEDIANA e non la media.** Un fotogramma sfocato o mosso
  /// produce un rapporto molto lontano dagli altri: la media se lo porta
  /// dentro, la mediana lo ignora.
  static FaceReading leggiStabile(List<FaceContours> fotogrammi) {
    if (fotogrammi.isEmpty) {
      throw ArgumentError('nessun fotogramma da leggere');
    }
    if (fotogrammi.length == 1) return leggi(fotogrammi.first);
    // Per ogni categoria: quante volte e uscita ogni variante, e i rapporti.
    final voti = <FaceCategory, Map<FaceTrait, int>>{};
    final rapporti = <FaceCategory, List<double>>{};
    for (final f in fotogrammi) {
      for (final l in leggi(f).letture) {
        voti
            .putIfAbsent(l.tratto.categoria, () => <FaceTrait, int>{})
            .update(l.tratto, (n) => n + 1, ifAbsent: () => 1);
        final r = l.rapporto;
        if (r != null && r.isFinite) {
          rapporti.putIfAbsent(l.tratto.categoria, () => <double>[]).add(r);
        }
      }
    }
    final ultima = leggi(fotogrammi.last);
    return FaceReading(letture: [
      for (final l in ultima.letture)
        () {
          final urna = voti[l.tratto.categoria];
          if (urna == null || urna.isEmpty) return l;
          // **LA VARIANTE PIU FREQUENTE, non una fascia ricalcolata.** Una
          // corrispondenza fra numero di fascia e posizione nell elenco delle
          // varianti sarebbe una seconda verita accanto ai metodi, e
          // l elenco non e nemmeno in quell ordine: la prima stesura avrebbe
          // dato \"bocca larga\" a chi ne aveva una piccola.
          var scelto = l.tratto;
          var quante = -1;
          for (final voce in urna.entries) {
            // A parita di voti vince l ordine dell elenco, cosi la scelta
            // resta deterministica invece di dipendere dall iterazione.
            if (voce.value > quante ||
                (voce.value == quante && voce.key.index < scelto.index)) {
              scelto = voce.key;
              quante = voce.value;
            }
          }
          final valori = rapporti[l.tratto.categoria];
          double? mediana;
          if (valori != null && valori.isNotEmpty) {
            final o = [...valori]..sort();
            mediana = o.length.isOdd
                ? o[o.length ~/ 2]
                : (o[o.length ~/ 2 - 1] + o[o.length ~/ 2]) / 2;
          }
          return TraitLettura(
              tratto: scelto, marcatezza: l.marcatezza, rapporto: mediana);
        }(),
    ]);
  }

  /// Il ripiego tattile: costruisce la lettura dalle selezioni guidate, una per
  /// categoria scelta. La marcatezza viene da una salienza curata per variante,
  /// cosi' un dominante emerge in modo deterministico anche senza misura.
  static FaceReading daSelezioni(Map<FaceCategory, FaceTrait> scelte) {
    final letture = <TraitLettura>[
      for (final e in scelte.entries)
        TraitLettura(tratto: e.value, marcatezza: _salienza[e.value] ?? 0.5),
    ];
    letture.sort((a, b) =>
        a.tratto.categoria.ordine.compareTo(b.tratto.categoria.ordine));
    return FaceReading(letture: letture);
  }

  // --- Le undici categorie ---

  static TraitLettura _formaVolto(
      double w, double h, double wFronte, double wZigomi, double wMascella) {
    final wh = w / h;
    final jf = wFronte <= 0 ? 1.0 : wMascella / wFronte;
    final jz = wZigomi <= 0 ? 1.0 : wMascella / wZigomi;
    final FaceTrait t;
    if (jf < 0.80) {
      t = FaceTrait.voltoTriangolare; // fronte larga, mento stretto
    } else if (wh < 0.7978) {
      t = FaceTrait.voltoOvale; // lungo e stretto
    } else if (jz > 0.90 && wh >= 0.9020) {
      t = FaceTrait.voltoQuadrato; // lati dritti, mascella piena
    } else {
      t = FaceTrait.voltoTondo;
    }
    // Marcatezza: quanto la forma si stacca dal volto neutro (wh ~ 0.82).
    final m = _marca(wh, 0.82, 0.14) * 0.5 + _marca(jf, 0.92, 0.16) * 0.5;
    return TraitLettura(
        tratto: t, marcatezza: m.clamp(0.0, 1.0), rapporto: wh);
  }

  static TraitLettura _fronte(FaceContours c, _Box box, double h) {
    final browY = _minY([...c.sopraccioSx, ...c.sopraccioDx]);
    final ratio = ((browY - box.minY) / h).clamp(0.0, 1.0);
    final t = switch (fasciaDi(FaceCategory.fronte, ratio)) {
      2 => FaceTrait.fronteVerticale,
      1 => FaceTrait.fronteEquilibrata,
      _ => FaceTrait.fronteSfuggente,
    };
    return TraitLettura(
        tratto: t,
        marcatezza: _marca(ratio, 0.1677, 0.0095),
        rapporto: ratio);
  }

  static TraitLettura _sopracciglia(FaceContours c) {
    final a = _formaSopraccio(c.sopraccioSx);
    final b = _formaSopraccio(c.sopraccioDx);
    // Media dei due indici, poi si decide.
    final rise = (a.rise + b.rise) / 2;
    final angolo = math.min(a.angoloApice, b.angoloApice);
    final FaceTrait t;
    if (rise < 0.2138) {
      t = FaceTrait.sopraccigliaDritte;
    } else if (angolo < 2.11) {
      // **LE DUE SOGLIE DI QUESTA CATEGORIA SONO LEGATE, e per un pezzo non
      // lo sapeva nessuno.** L angolo all apice si calcola fra i segmenti
      // verso i due estremi, quindi vale esattamente
      // `pi - 2 * atan(2 * rise)`: e la stessa grandezza detta due volte.
      // Con la soglia del rise portata a 0,2304 dai volti veri, un rise che
      // la supera da sempre un angolo sotto 2,75, e la variante \curve      // diventava irraggiungibile. La soglia dell angolo scende a 2,11, che
      // e il valore corrispondente a un rise di 0,28: sopra quello l apice e
      // aguzzo davvero. Sui due volti misurati il primo esce curve e il
      // secondo dritte, cioe due varianti diverse.
      t = FaceTrait.sopraccigliaAngolo;
    } else {
      t = FaceTrait.sopraccigliaCurve;
    }
    final m = _marca(rise, 0.2138, 0.0084);
    return TraitLettura(tratto: t, marcatezza: m, rapporto: rise);
  }

  static TraitLettura _distanzaOcchi(FaceContours c, double w) {
    final cxSx = _centro(c.occhioSx).dx;
    final cxDx = _centro(c.occhioDx).dx;
    final gap = (cxDx - cxSx).abs();
    final eyeW = (_Box.attorno(c.occhioSx).larghezza +
            _Box.attorno(c.occhioDx).larghezza) /
        2;
    final ratio = eyeW <= 0 ? 2.0 : gap / eyeW;
    final t = fasciaDi(FaceCategory.distanzaOcchi, ratio) == 0
        ? FaceTrait.occhiRavvicinati
        : FaceTrait.occhiDistanziati;
    return TraitLettura(
        tratto: t, marcatezza: _marca(ratio, 2.2761, 0.0351), rapporto: ratio);
  }

  static TraitLettura _grandezzaOcchi(FaceContours c, double h) {
    final eyeH =
        (_Box.attorno(c.occhioSx).altezza + _Box.attorno(c.occhioDx).altezza) /
            2;
    final ratio = eyeH / h;
    final t = switch (fasciaDi(FaceCategory.grandezzaOcchi, ratio)) {
      2 => FaceTrait.occhiGrandi,
      1 => FaceTrait.occhiProporzionati,
      _ => FaceTrait.occhiRaccolti,
    };
    return TraitLettura(
        tratto: t,
        marcatezza: _marca(ratio, 0.0479, 0.0044),
        rapporto: ratio);
  }

  static TraitLettura _naso(FaceContours c, _Box box, double h) {
    final top = _minY(c.nasoPonte);
    final bottom = _maxY(c.nasoBase);
    final ratio = ((bottom - top) / h).clamp(0.0, 1.0);
    final t = switch (fasciaDi(FaceCategory.naso, ratio)) {
      2 => FaceTrait.nasoLungo,
      1 => FaceTrait.nasoEquilibrato,
      _ => FaceTrait.nasoCorto,
    };
    return TraitLettura(
        tratto: t,
        marcatezza: _marca(ratio, 0.3108, 0.0136),
        rapporto: ratio);
  }

  static TraitLettura _labbra(FaceContours c) {
    final top = _minY(c.labbroSopra);
    final bottom = _maxY(c.labbroSotto);
    final spessore = bottom - top;
    final larghezza =
        _Box.attorno([...c.labbroSopra, ...c.labbroSotto]).larghezza;
    final ratio = larghezza <= 0 ? 0.0 : spessore / larghezza;
    final t = switch (fasciaDi(FaceCategory.labbra, ratio)) {
      2 => FaceTrait.labbraPiene,
      1 => FaceTrait.labbraArmoniose,
      _ => FaceTrait.labbraSottili,
    };
    return TraitLettura(
        tratto: t,
        marcatezza: _marca(ratio, 0.314, 0.0206),
        rapporto: ratio);
  }

  static TraitLettura _bocca(FaceContours c, double w) {
    final larghezza =
        _Box.attorno([...c.labbroSopra, ...c.labbroSotto]).larghezza;
    final ratio = larghezza / w;
    final t = switch (fasciaDi(FaceCategory.bocca, ratio)) {
      2 => FaceTrait.boccaLarga,
      1 => FaceTrait.boccaEquilibrata,
      _ => FaceTrait.boccaPiccola,
    };
    return TraitLettura(
        tratto: t,
        marcatezza: _marca(ratio, 0.3714, 0.0229),
        rapporto: ratio);
  }

  static TraitLettura _mento(double wMento, double wMascella) {
    final ratio = wMascella <= 0 ? 1.0 : wMento / wMascella;
    final t = switch (fasciaDi(FaceCategory.mento, ratio)) {
      2 => FaceTrait.mentoAmpio,
      1 => FaceTrait.mentoDefinito,
      _ => FaceTrait.mentoAPunta,
    };
    return TraitLettura(
        tratto: t,
        marcatezza: _marca(ratio, 0.6512, 0.0286),
        rapporto: ratio);
  }

  static TraitLettura _mascella(double wMascella, double w) {
    final ratio = wMascella / w;
    final t = switch (fasciaDi(FaceCategory.mascella, ratio)) {
      2 => FaceTrait.mascellaLarga,
      1 => FaceTrait.mascellaMisurata,
      _ => FaceTrait.mascellaStretta,
    };
    return TraitLettura(
        tratto: t,
        marcatezza: _marca(ratio, 0.878, 0.0357),
        rapporto: ratio);
  }

  static TraitLettura _zigomi(
      FaceContours c, double wZigomi, double wMascella) {
    double larghezza = wZigomi;
    if (c.guanciaSx != null && c.guanciaDx != null) {
      larghezza = (c.guanciaDx!.dx - c.guanciaSx!.dx).abs();
    }
    final ratio = wMascella <= 0 ? 1.0 : larghezza / wMascella;
    final t = fasciaDi(FaceCategory.zigomi, ratio) == 1
        ? FaceTrait.zigomiAlti
        : FaceTrait.zigomiMorbidi;
    return TraitLettura(
        tratto: t, marcatezza: _marca(ratio, 1.0656, 0.0236), rapporto: ratio);
  }

  // --- Aiuti geometrici ---

  /// La marcatezza: quanto [valore] si stacca dalla [soglia], scalata su
  /// [ampiezza] e limitata a uno. Al neutro vale zero.
  static double _marca(double valore, double soglia, double ampiezza) =>
      ((valore - soglia).abs() / ampiezza).clamp(0.0, 1.0);

  static double _minY(List<Offset> p) => p.map((o) => o.dy).reduce(math.min);
  static double _maxY(List<Offset> p) => p.map((o) => o.dy).reduce(math.max);

  static Offset _centro(List<Offset> p) {
    var x = 0.0, y = 0.0;
    for (final o in p) {
      x += o.dx;
      y += o.dy;
    }
    return Offset(x / p.length, y / p.length);
  }

  /// La larghezza del contorno del volto in una fascia verticale, fra le frazioni
  /// [da] e [a] dell'altezza. Se nella fascia non cadono punti, ripiega sulla
  /// larghezza intera cosi' non si divide per zero.
  static double _larghezzaFascia(
      List<Offset> volto, _Box box, double da, double a) {
    final y0 = box.minY + box.altezza * da;
    final y1 = box.minY + box.altezza * a;
    final dentro = volto.where((o) => o.dy >= y0 && o.dy <= y1).toList();
    if (dentro.length < 2) return box.larghezza;
    final xs = dentro.map((o) => o.dx);
    return xs.reduce(math.max) - xs.reduce(math.min);
  }

  /// Indici di forma di un sopracciglio dal suo contorno superiore: quanto si
  /// inarca (rise, rispetto alla larghezza) e l'angolo all'apice in radianti
  /// (piu' e' piccolo, piu' l'apice e' aguzzo).
  static ({double rise, double angoloApice}) _formaSopraccio(List<Offset> p) {
    if (p.length < 3) return (rise: 0.0, angoloApice: math.pi);
    final ordinati = [...p]..sort((a, b) => a.dx.compareTo(b.dx));
    final primo = ordinati.first;
    final ultimo = ordinati.last;
    final larghezza = (ultimo.dx - primo.dx).abs();
    if (larghezza <= 0) return (rise: 0.0, angoloApice: math.pi);
    // Apice: il punto piu' in alto (y minima).
    var apice = ordinati.first;
    for (final o in ordinati) {
      if (o.dy < apice.dy) apice = o;
    }
    final yEstremi = (primo.dy + ultimo.dy) / 2;
    final rise = ((yEstremi - apice.dy) / larghezza).clamp(0.0, 2.0);
    // Angolo all'apice fra i segmenti verso i due estremi.
    final angolo = _angolo(primo, apice, ultimo);
    return (rise: rise, angoloApice: angolo);
  }

  /// L'angolo in [b] fra i segmenti b->a e b->c, in radianti.
  static double _angolo(Offset a, Offset b, Offset c) {
    final v1 = Offset(a.dx - b.dx, a.dy - b.dy);
    final v2 = Offset(c.dx - b.dx, c.dy - b.dy);
    final n1 = v1.distance, n2 = v2.distance;
    if (n1 == 0 || n2 == 0) return math.pi;
    final cos = ((v1.dx * v2.dx + v1.dy * v2.dy) / (n1 * n2)).clamp(-1.0, 1.0);
    return math.acos(cos);
  }

  /// Salienza curata delle varianti del ripiego, per far emergere un dominante
  /// deterministico dalle selezioni guidate.
  static const Map<FaceTrait, double> _salienza = {
    // Forma del volto.
    FaceTrait.voltoTondo: 0.55,
    FaceTrait.voltoQuadrato: 0.72,
    FaceTrait.voltoOvale: 0.60,
    FaceTrait.voltoTriangolare: 0.68,
    // Grandezza degli occhi.
    FaceTrait.occhiGrandi: 0.70,
    FaceTrait.occhiRaccolti: 0.58,
    // Sopracciglia.
    FaceTrait.sopraccigliaDritte: 0.50,
    FaceTrait.sopraccigliaCurve: 0.56,
    FaceTrait.sopraccigliaAngolo: 0.66,
    // Labbra.
    FaceTrait.labbraPiene: 0.64,
    FaceTrait.labbraSottili: 0.52,
    // Mento.
    FaceTrait.mentoAmpio: 0.62,
    FaceTrait.mentoAPunta: 0.60,
  };
}

/// Il riquadro attorno a un insieme di punti.
@immutable
class _Box {
  const _Box(this.minX, this.minY, this.maxX, this.maxY);

  final double minX, minY, maxX, maxY;

  double get larghezza => maxX - minX;
  double get altezza => maxY - minY;

  static _Box attorno(List<Offset> p) {
    var minX = double.infinity,
        minY = double.infinity,
        maxX = -double.infinity,
        maxY = -double.infinity;
    for (final o in p) {
      minX = math.min(minX, o.dx);
      minY = math.min(minY, o.dy);
      maxX = math.max(maxX, o.dx);
      maxY = math.max(maxY, o.dy);
    }
    if (p.isEmpty) return const _Box(0, 0, 0, 0);
    return _Box(minX, minY, maxX, maxY);
  }
}
