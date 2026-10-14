import '../astro/natal_chart.dart';
import '../chat/la_marca_del_genere.dart';
import '../l10n/numero_del_cerchio.dart';
import 'cielo_approfondito.dart';
import 'legame_e_eta.dart';

/// Il corpus come lo legge il motore: chiave "<file>|<cella>|<campo>",
/// valore le varianti. In produzione e' `corpusDellaSinastriaApprofondita`
/// (generato da `tool/il_corpus_della_sinastria.py`); le prove ne passano uno
/// loro.
typedef CorpusDellaSinastria = Map<String, List<String>>;

/// **I CINQUE CAPITOLI.** Ordine FT voce FT.06 (Briefing Operativo V13
/// sezione 58.4): l'attrazione, le emozioni, la mente, la durata, il
/// destino. Ogni capitolo legge le sue tre coppie di punti, dalla
/// tradizione della sinastria; lo schedario che le spiega sta in
/// `docs/corpus/sinastria_approfondita/LEGGIMI.md`, e lo strumento del
/// corpus ha la stessa tabella (una prova pretende che coincidano).
enum Capitolo {
  attrazione('L\'attrazione', 'capitolo_attrazione_v1', [
    (PuntoDelCieloApprofondito.venere, PuntoDelCieloApprofondito.marte),
    (PuntoDelCieloApprofondito.sole, PuntoDelCieloApprofondito.venere),
    (PuntoDelCieloApprofondito.marte, PuntoDelCieloApprofondito.marte),
  ]),
  emozioni('Le emozioni', 'capitolo_emozioni_v1', [
    (PuntoDelCieloApprofondito.luna, PuntoDelCieloApprofondito.luna),
    (PuntoDelCieloApprofondito.sole, PuntoDelCieloApprofondito.luna),
    (PuntoDelCieloApprofondito.luna, PuntoDelCieloApprofondito.venere),
  ]),
  mente('La mente', 'capitolo_mente_v1', [
    (PuntoDelCieloApprofondito.mercurio, PuntoDelCieloApprofondito.mercurio),
    (PuntoDelCieloApprofondito.sole, PuntoDelCieloApprofondito.mercurio),
    (PuntoDelCieloApprofondito.mercurio, PuntoDelCieloApprofondito.luna),
  ]),
  durata('La durata', 'capitolo_durata_v1', [
    (PuntoDelCieloApprofondito.saturno, PuntoDelCieloApprofondito.sole),
    (PuntoDelCieloApprofondito.saturno, PuntoDelCieloApprofondito.luna),
    (PuntoDelCieloApprofondito.saturno, PuntoDelCieloApprofondito.venere),
  ]),
  destino('Il destino', 'capitolo_destino_v1', [
    (PuntoDelCieloApprofondito.nodoNord, PuntoDelCieloApprofondito.sole),
    (PuntoDelCieloApprofondito.nodoNord, PuntoDelCieloApprofondito.luna),
    (PuntoDelCieloApprofondito.nodoNord, PuntoDelCieloApprofondito.venere),
  ]);

  const Capitolo(this.nome, this.medaglione, this.coppie);

  final String nome;

  /// Il nome del medaglione in `assets/img/sinastria/`.
  final String medaglione;

  /// Le coppie di punti del capitolo: non ordinate, valgono nelle due
  /// direzioni (la tua Venere col suo Marte e il tuo Marte con la sua
  /// Venere).
  final List<(PuntoDelCieloApprofondito, PuntoDelCieloApprofondito)> coppie;

  /// Vero se l'aspetto tocca una coppia di questo capitolo.
  bool tocca(AspettoApprofondito a) => coppie.any((c) =>
      (a.tuo == c.$1 && a.suo == c.$2) || (a.tuo == c.$2 && a.suo == c.$1));
}

/// **I QUATTRO TONI**, dal contatto piu' stretto fra le coppie del capitolo.
enum Tono {
  /// Congiunzione: due energie che si sommano.
  fuso,

  /// Trigono o sestile: scorre senza sforzo.
  armonico,

  /// Quadratura od opposizione: un attrito che insegna.
  teso,

  /// Nessun aspetto fra le coppie del capitolo.
  silenzio;

  static Tono di(AspectType? tipo) => switch (tipo) {
        null => Tono.silenzio,
        AspectType.conjunction => Tono.fuso,
        AspectType.trine || AspectType.sextile => Tono.armonico,
        AspectType.square || AspectType.opposition => Tono.teso,
      };
}

/// Il nome di un punto nelle celle del corpus.
String nomeNelCorpus(PuntoDelCieloApprofondito p) =>
    p == PuntoDelCieloApprofondito.nodoNord ? 'nodo' : p.name;

/// Il nome di un aspetto nelle celle del corpus.
String aspettoNelCorpus(AspectType t) => t.italianName.toLowerCase();

/// Un capitolo composto, pronto per la schermata: il formato di casa
/// (Linee Guida V13 sezione 26), titolo, tre paragrafi col secondo nel
/// riquadro, "Da dove viene".
class CapitoloLetto {
  const CapitoloLetto({
    required this.capitolo,
    required this.tono,
    required this.aspetto,
    required this.titolo,
    required this.paragrafi,
    required this.daDoveViene,
  });

  final Capitolo capitolo;
  final Tono tono;

  /// Il contatto che decide il tono; nullo nel silenzio.
  final AspettoApprofondito? aspetto;

  final String titolo;

  /// Sempre tre: apertura, contatto (o, nel silenzio, il fatto che non c'e'
  /// nessun contatto), che cosa fare.
  final List<String> paragrafi;

  final String daDoveViene;
}

/// **LA LETTURA APPROFONDITA.** Ordine FT voci FT.06 e FT.12.
///
/// **Tutto deterministico, nessun modello**: dati i due cieli e il legame,
/// la lettura e' sempre la stessa. Le varianti del corpus si scelgono da un
/// numero che nasce dai due cieli: la stessa coppia rilegge le stesse
/// parole (il responso non cambia sotto gli occhi di chi lo riapre), due
/// coppie diverse leggono parole diverse anche nella stessa cella.
abstract final class LetturaApprofondita {
  /// Le fonti, una per capitolo, nel "Da dove viene".
  static const String fonteDellaSinastria =
      'La sinastria confronta i pianeti di due nascite coi cinque aspetti di '
      'Tolomeo (Tetrabiblos, libro I) nei significati raccolti da Ronald '
      'Davison (Synastry, 1977).';
  static const String fonteDelNodo =
      'Il Nodo Nord, calcolato con Meeus come il resto del cielo, si legge '
      'come direzione di crescita del legame secondo Martin Schulman '
      '(Karmic Relationships, 1984).';

  /// I capitoli della coppia [tuo] e [suo] per il [legame].
  static List<CapitoloLetto> componi({
    required CieloApprofondito tuo,
    required CieloApprofondito suo,
    required String nomeSuo,
    required Legame legame,
    required CorpusDellaSinastria corpus,
  }) {
    final aspetti = AspettiApprofonditi.fra(tuo, suo);
    final seme = semeDellaCoppia(tuo, suo);
    final usati = <String>{};
    return [
      for (final c in Capitolo.values)
        _capitolo(c, aspetti, legame, nomeSuo, corpus, seme, usati),
    ];
  }

  /// Le prime due parole di un testo: l'attacco.
  static String attacco(String testo) =>
      testo.toLowerCase().split(RegExp(r'\s+')).take(2).join(' ');

  /// **LA VARIANTE SENZA ATTACCHI RIPETUTI.** Nella stessa lettura cinque
  /// capitoli che cominciano tutti con "Fra te e Giulia" suonerebbero come
  /// un modulo: si parte dalla variante della coppia e, se il suo attacco e'
  /// gia' stato usato in un capitolo di prima, si prende la successiva.
  /// Sempre deterministico: stessa coppia, stesse parole.
  static String scegliSenzaRipetere(
      List<String> varianti, int partenza, Set<String> usati) {
    for (var k = 0; k < varianti.length; k++) {
      final v = varianti[(partenza + k) % varianti.length];
      if (usati.add(attacco(v))) return v;
    }
    return varianti[partenza % varianti.length];
  }

  /// **IL SEME DELLA COPPIA**: il grado intero del Sole dei due, sommato.
  /// Stessa coppia, stesso seme; ed e' simmetrico, quindi la lettura e' la
  /// stessa da tutti e due i telefoni.
  static int semeDellaCoppia(CieloApprofondito tuo, CieloApprofondito suo) {
    final a = (tuo.longitudini[PuntoDelCieloApprofondito.sole] ?? 0).floor();
    final b = (suo.longitudini[PuntoDelCieloApprofondito.sole] ?? 0).floor();
    return a + b;
  }

  /// La variante, fra [quante], per il capitolo [c] della coppia [seme].
  static int variante(int seme, int indice, int quante) =>
      (seme + indice * 7) % quante;

  static CapitoloLetto _capitolo(
      Capitolo c,
      List<AspettoApprofondito> tutti,
      Legame legame,
      String nomeSuo,
      CorpusDellaSinastria corpus,
      int seme,
      Set<String> usati) {
    // Gli aspetti sono gia' ordinati dal piu' stretto: il primo che tocca il
    // capitolo decide il tono.
    AspettoApprofondito? deciso;
    for (final a in tutti) {
      if (c.tocca(a)) {
        deciso = a;
        break;
      }
    }
    final tono = Tono.di(deciso?.tipo);
    final file = 'capitolo_${c.name}';
    final cella = '${legame.name} ${tono.name}';
    String scegli(String campo, String chiave, int indice) {
      final varianti = corpus[chiave]!;
      // Gli attacchi si confrontano per campo: un titolo con un titolo.
      final perCampo = usati
          .where((u) => u.startsWith('$campo|'))
          .map((u) => u.substring(campo.length + 1))
          .toSet();
      final v = scegliSenzaRipetere(
          varianti, variante(seme, indice, varianti.length), perCampo);
      usati.add('$campo|${attacco(v)}');
      return _pulito(v, nomeSuo);
    }

    final String contatto;
    if (deciso == null) {
      contatto = _silenzio(c, nomeSuo);
    } else {
      final fileDelContatto = c.index <= Capitolo.mente.index
          ? 'contatti_cuore_e_mente'
          : 'contatti_durata_e_destino';
      contatto = scegli(
          'contatto',
          '$fileDelContatto|${_cellaDelContatto(c, deciso)}|testo',
          c.index + 5);
    }
    return CapitoloLetto(
      capitolo: c,
      tono: tono,
      aspetto: deciso,
      titolo: scegli('titolo', '$file|$cella|titolo', c.index),
      paragrafi: [
        scegli('apertura', '$file|$cella|apertura', c.index),
        contatto,
        scegli('fare', '$file|$cella|fare', c.index),
      ],
      daDoveViene: _daDoveViene(c, deciso, nomeSuo),
    );
  }

  /// La cella del contatto: la coppia come la scrive il corpus (nell'ordine
  /// del capitolo, non in quello di chi ha cosa) e l'aspetto.
  static String _cellaDelContatto(Capitolo c, AspettoApprofondito a) {
    final coppia = c.coppie.firstWhere((x) =>
        (a.tuo == x.$1 && a.suo == x.$2) || (a.tuo == x.$2 && a.suo == x.$1));
    return '${nomeNelCorpus(coppia.$1)}-${nomeNelCorpus(coppia.$2)} '
        '${aspettoNelCorpus(a.tipo)}';
  }

  /// Nel silenzio il secondo paragrafo dice il fatto: fra le coppie del
  /// capitolo non c'e' nessun contatto.
  static String _silenzio(Capitolo c, String nomeSuo) {
    final coppie = [
      for (final x in c.coppie)
        x.$1 == x.$2 ? _iDue(x.$1) : '${x.$1.nome} e ${x.$2.nome}',
    ];
    final elenco = '${coppie.sublist(0, coppie.length - 1).join(', ')} '
        'o ${coppie.last}';
    return 'Fra il tuo cielo e quello di $nomeSuo, in questo campo, i punti '
        'che di solito parlano ($elenco) non si guardano: nessuno dei cinque '
        'aspetti li lega. Il vostro legame non si accende qui da solo: ciò '
        'che qui non viene da sé si può costruire per scelta.';
  }

  /// Lo stesso punto nelle due nascite, al plurale giusto.
  static String _iDue(PuntoDelCieloApprofondito p) => switch (p) {
        PuntoDelCieloApprofondito.sole => 'i due Soli',
        PuntoDelCieloApprofondito.luna => 'le due Lune',
        PuntoDelCieloApprofondito.venere => 'le due Veneri',
        _ => 'i due ${p.nome}',
      };

  static String _daDoveViene(
      Capitolo c, AspettoApprofondito? a, String nomeSuo) {
    final fonte = c == Capitolo.destino
        ? '$fonteDellaSinastria $fonteDelNodo'
        : fonteDellaSinastria;
    if (a == null) return fonte;
    final gradi = NumeroDelCerchio.gradi(a.orbo);
    return '${a.frase(nomeSuo)}, a $gradi dall\'angolo esatto. $fonte';
  }

  /// Il nome dell'altra persona al posto di `{nome}` e la marca del genere
  /// di chi legge risolta (`LaMarcaDelGenere`): il testo arriva a video
  /// senza segnaposto e senza quadre.
  static String _pulito(String testo, String nomeSuo) =>
      LaMarcaDelGenere.risolvi(testo.replaceAll('{nome}', nomeSuo));
}
