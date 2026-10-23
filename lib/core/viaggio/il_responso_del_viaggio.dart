import '../chat/la_posizione_della_lettura.dart';
import '../responsi/filo_della_voce.dart';
import '../rituals/animal_catalog.dart';
import 'diario_dei_viaggi.dart';
import 'i_quattro_viaggi.dart';
import 'la_domanda_del_viaggio.dart';
import 'la_scena_dal_modello.dart';
import 'la_voce_del_mondo_di_sotto.dart';
import 'scena_del_viaggio.dart';
import 'le_guardie_del_responso.dart';
import 'vocabolario_del_viaggio.dart';

/// **IL RESPONSO DEL VIAGGIO, in un posto solo.** Ordine DI voce 16,
/// 13 settembre 2026.
///
/// La scena, il titolo, i tre paragrafi e il richiamo: tutto cio' che la
/// persona legge quando risale. **Fino all'ordine DI li metteva insieme la
/// schermata**, pezzo per pezzo dentro la risalita e dentro il disegno. La
/// prova a cento discese della voce DI.16 avrebbe dovuto rifare gli stessi
/// passi a mano: una copia che puo' divergere dall'originale senza che nessuno
/// se ne accorga. Allora la prova misurerebbe la copia. Adesso la schermata
/// e la prova chiamano questa funzione: la prova misura cio' che si legge.
///
/// **E il primo difetto l'ha trovato proprio spostandolo qui.** La schermata
/// calcolava il richiamo **dopo** aver segnato nel Diario la discesa di oggi:
/// fra le scene di prima c'era anche quella appena composta. La sua cosa
/// risultava quindi sempre gia' vista. Il richiamo compariva **in cento discese su
/// cento, anche alla prima**: *"Ti era gia' capitato di vedere la chiave"* a
/// chi scendeva per la prima volta. Veniva dall'ordine DE voce 11. Qui
/// [precedenti] sono per contratto le discese di **prima**.
class IlResponsoDelViaggio {
  /// **LA RISERVA CHE PRENDE POSIZIONE.** Ordine ET voce 08. Il fondatore
  /// ha confermato la proposta del rapporto ER: *"una riserva che dica la
  /// posizione che il modello aveva scelto sull'oggetto della domanda,
  /// anche quando la sua risposta è stata scartata"*. La frase dice la
  /// posizione come lettura dei segni del viaggio e rimanda al gesto, che
  /// sta subito sotto: non nomina niente che la domanda non abbia.
  ///
  /// **Solo quando il modello ha scelto una posizione.** Senza modello (la
  /// rete manca, il tetto e' raggiunto) resta la voce di casa, che ricorda
  /// le ultime risposte e nomina l'oggetto della domanda: la prima stesura
  /// metteva questa frase anche li', uguale a ogni discesa, e le guardie
  /// della voce che si ricorda e del tema che arriva alla risposta l'hanno
  /// presa. Le varianti, scelte col numero della discesa, fanno si' che due
  /// riserve di fila non dicano la stessa frase.
  static const Map<String, List<String>> _riserve = {
    'sì': [
      'I segni del viaggio dicono di sì: il primo passo è quello qui sotto.',
      'Il viaggio pende verso il sì. Il passo per cominciare è qui sotto.',
      'I segni del viaggio dicono di sì: comincia dal gesto qui sotto.',
    ],
    'no': [
      'I segni del viaggio dicono di no, per ora: il passo di oggi è quello '
          'qui sotto.',
      'Il viaggio pende verso il no, per adesso. Il passo da fare oggi è qui '
          'sotto.',
      'I segni del viaggio dicono di no, per ora: parti dal gesto qui sotto.',
    ],
    'sì a una condizione': [
      'I segni del viaggio dicono di sì, se il primo passo lo fai tu: è '
          'quello qui sotto.',
      'Il viaggio dice di sì a una condizione: che tu cominci dal passo qui '
          'sotto.',
      'I segni del viaggio dicono di sì, a patto di cominciare dal gesto qui '
          'sotto.',
    ],
    'un gesto da fare': [
      'I segni del viaggio indicano un passo da fare: è quello qui sotto.',
      'Il viaggio risponde con un gesto: è quello qui sotto.',
      'I segni del viaggio chiedono un passo concreto: lo trovi qui sotto.',
    ],
  };

  /// La frase della riserva per la [posizione] scelta dal modello, o null
  /// se il modello non ne ha scelta una fra quelle con una frase.
  static String? rispostaCheSiSchiera(String? posizione,
      {int seme = 0, String domanda = ''}) {
    // **ALLA DOMANDA APERTA SI RISPONDE COL PASSO.** Dalla lettura alla
    // cieca: a *"Cosa pensa di me la mia collega?"* il modello aveva scelto
    // "no", e la riserva diceva *"I segni del viaggio dicono di no, per
    // ora"*, che a quella domanda non risponde.
    final aperta = domanda.trim().isNotEmpty &&
        LaPosizioneDellaLettura.tipo(domanda) == TipoDellaDomanda.aperta;
    final frasi =
        _riserve[aperta && posizione != null ? 'un gesto da fare' : posizione];
    if (frasi == null) return null;
    return frasi[seme.abs() % frasi.length];
  }

  const IlResponsoDelViaggio._({
    required this.scena,
    required this.titolo,
    required this.paragrafi,
    required this.richiamo,
    required this.dalModello,
    required this.risposta,
    required this.gesto,
    required this.fonti,
    required this.oggetto,
  });

  final ScenaDelViaggio scena;
  final String titolo;
  final List<String> paragrafi;

  /// La risposta e l'azione come stanno nei loro elenchi: il Diario le
  /// conserva perche' la voce se le ricordi. Ordine DJ voce 02.
  final String risposta;
  final String gesto;

  /// La riga del richiamo, o nulla quando la scena non riprende niente.
  final String? richiamo;

  /// Se i quattro pezzi li ha scelti il modello.
  final bool dalModello;

  /// **DA QUALE VIA E' NATO OGNI PEZZO**, ordine DL voce 14: vedi
  /// `UnViaggio.fonti`.
  final Map<String, String> fonti;

  /// L'oggetto della domanda, ordine DL voce 08, o nulla.
  final String? oggetto;

  /// **I BLOCCHI COME SI LEGGONO**, dall'alto: titolo, risposta, gesto, da dove
  /// viene; poi il richiamo quando c'e'.
  List<String> get blocchi =>
      [titolo, ...paragrafi, if (richiamo != null) richiamo!];

  /// **LA DISCESA COME SI CONSERVA NEL DIARIO**, coi pezzi della scena e con
  /// cio' che la voce deve ricordarsi: il titolo, la risposta e l'azione.
  /// Ordine DJ voce 02. **La chiamano la schermata e la prova a cento
  /// discese**, e non una copia per ciascuna: se una delle due dimenticasse
  /// un campo, la memoria della voce non lo vedrebbe.
  UnViaggio comeSiConserva({
    required DateTime quando,
    required String domanda,
    required String temaDellaDomanda,
    required String animaleSeguito,
    required double nitidezza,
    String? cammino,
    int? strato,
  }) =>
      UnViaggio(
        quando: quando,
        domanda: domanda,
        temaDellaDomanda: temaDellaDomanda,
        pezzi: scena.idDeiPezzi,
        animaleSeguito: animaleSeguito,
        nitidezza: nitidezza,
        titolo: titolo,
        risposta: risposta,
        gesto: gesto,
        oggetto: oggetto,
        fonti: fonti,
        cammino: cammino,
        strato: strato,
      );

  /// **QUANTE FORME HA LA FRASE CHE CUCE LA SCENA** per ogni grado di
  /// nitidezza: sedici dall'ordine DJ voce 06, e il numero lo dicono gli
  /// elenchi, `ScenaDelViaggio.quanteForme`.
  static int get quanteForme => ScenaDelViaggio.quanteForme;

  /// **LA FORMA DELLA SCENA DI OGGI**, dalla storia. Ordine DI voce 16.
  ///
  /// **Una scena che somiglia a una di prima non si racconta con la stessa
  /// frase.** Simile vuol dire con la stessa cosa, che e' il pezzo che torna,
  /// oppure con due pezzi in comune. La prova a cento discese ha trovato
  /// coppie con la stessa cosa, o lo stesso luogo nello stesso momento,
  /// raccontate con la stessa forma: *"Sotto la pioggia arrivi al bivio
  /// insieme al Lupo"* due volte, e la somiglianza sopra il quaranta per
  /// cento. Adesso ogni scena prende la forma la cui scena simile piu'
  /// somigliante e' la meno somigliante, e a parita' quella usata piu'
  /// lontano. La prima stesura trattava tutte le somiglianze allo stesso
  /// modo: con molte scene simili riciclava la forma di una scena con la
  /// stessa cosa e lo stesso momento, e la somiglianza passava il quaranta.
  ///
  /// **Le forme di prima si ricalcolano**, dalla scena piu' vecchia alla piu'
  /// recente, con la stessa regola: il Diario conserva i pezzi, e i pezzi
  /// bastano. [precedenti] dalla piu' recente, come li da' il Diario.
  static int formaDellaScena(List<String> oggi, List<List<String>> precedenti) {
    final storia = [...precedenti.reversed, oggi];
    final forme = <int>[];
    for (var i = 0; i < storia.length; i++) {
      // Per ogni forma: quanto somigliava la scena piu' simile che l'ha
      // usata, e quando l'ha usata l'ultima volta.
      final peggiore = <int, int>{};
      final ultimaVolta = <int, int>{};
      for (var j = 0; j < i; j++) {
        final quanto = _quantoSomigliano(storia[j], storia[i]);
        if (quanto < 2) continue;
        final f = forme[j];
        if (quanto > (peggiore[f] ?? 0)) peggiore[f] = quanto;
        ultimaVolta[f] = j;
      }
      final cosa = storia[i].length > 1 ? storia[i][1] : '';
      final partenza = FiloDellaVoce.da([cosa, 'forma']).seme % quanteForme;
      var scelta = partenza;
      for (var k = 1; k < quanteForme; k++) {
        final f = (partenza + k) % quanteForme;
        final pf = peggiore[f] ?? 0;
        final ps = peggiore[scelta] ?? 0;
        if (pf < ps ||
            (pf == ps &&
                (ultimaVolta[f] ?? -1) < (ultimaVolta[scelta] ?? -1))) {
          scelta = f;
        }
      }
      forme.add(scelta);
    }
    return forme.last;
  }

  /// **QUANTO SI SOMIGLIANO DUE SCENE**: i pezzi in comune, e un punto in
  /// piu' se hanno la stessa cosa, che e' il pezzo che si vede e che torna.
  /// Da due in su si somigliano.
  static int _quantoSomigliano(List<String> a, List<String> b) {
    var comuni = 0;
    for (var k = 0; k < a.length && k < b.length; k++) {
      if (a[k] == b[k]) comuni++;
    }
    if (a.length > 1 && b.length > 1 && a[1] == b[1]) comuni++;
    return comuni;
  }

  /// **COMPONE IL RESPONSO DI UNA DISCESA.**
  ///
  /// [dalModello] sono i quattro pezzi del modello quando sono arrivati in
  /// tempo e dentro il vocabolario, ordine DI voce 03; nullo, decide la via
  /// deterministica, che resta la rete di sicurezza. [discesa] e' quante
  /// discese c'erano prima di questa, [giaOggi] quante di queste nello stesso
  /// giorno. [storia] sono le discese di **prima**, dalla piu' recente,
  /// **senza quella di oggi**: i loro pezzi fanno il richiamo e la forma
  /// della scena, i loro titoli, risposte e azioni la memoria della voce,
  /// ordine DJ voce 02.
  static IlResponsoDelViaggio componi({
    required PezziScelti? dalModello,
    required String domanda,
    required DateTime giorno,
    required double nitidezza,
    required int discesa,
    required int giaOggi,
    required GuideAnimal animale,
    required TemaDellaDomanda? tema,
    required List<UnViaggio> storia,
    TestiDelModello scritti = TestiDelModello.nessuno,
    String? oggetto,
    Map<String, String> fontiGiaNote = const {},
    int? apparizioniPrima,
  }) {
    final precedenti = [for (final v in storia) v.pezzi];
    // Il nome si dice alla quarta: questa discesa e' ancora da contare. **Da
    // `IQuattroViaggi.siPuoNominare`**, ordine DJ voce 05: qui la regola era
    // riscritta a mano, e la funzione che la dice non la chiamava nessuno.
    // **ALLA QUARTA APPARIZIONE**, ordine DQ voce 03: cambiare domanda fa
    // ripartire il conto, e le discese di prima non contano piu'.
    final siPuoDire = IQuattroViaggi.siPuoNominare(apparizioniPrima ?? discesa);
    // Senza domanda, nessuna chiusura parla della domanda.
    final conDomanda = tema != null;
    final id = LaVoceDelMondoDiSotto.temaDi(tema);
    final letti = <ResponsoLetto>[
      for (final v in storia)
        (
          tema: v.temaDellaDomanda,
          titolo: v.titolo,
          risposta: v.risposta,
          gesto: v.gesto,
        ),
    ];
    // **IL TITOLO NON CONTIENE UN PEZZO DELLA SCENA DI QUELLA DISCESA.**
    // Ordine DN voce 03. **Non si salta il titolo, e' la scena che lo
    // evita**: il titolo di casa e' obbligato dal mazzo, che non ripete
    // prima di ventiquattro discese, e quello del modello e' la risposta a
    // colpo d'occhio, mentre la scena sta in fondo come fonte. Quando il
    // titolo nomina un pezzo della scena del modello, la scena si rifa'
    // dalla riserva saltando i pezzi che il titolo nomina, e quelli che la
    // risposta gia' dice. La prima stesura dava al titolo di casa il posto
    // di quello del modello, e la misura a cento discese ne perdeva uno su
    // sette.
    final titoloDiCasa = LaVoceDelMondoDiSotto.titoloDelGiorno(id, giorno,
        giaOggi: giaOggi, letti: letti, domanda: domanda);
    bool tocca(String t, ScenaDelViaggio s) =>
        LeGuardieDelResponso.titoloToccaLaScena(
            t, LaVoceDelMondoDiSotto.nomiDeiPezzi(s));
    ScenaDelViaggio diRiserva(String titolo) => ScenaSenzaModello.componi(
          domanda: domanda,
          giorno: giorno,
          nitidezza: nitidezza,
          // **IL NUMERO DELLA DISCESA ENTRA NEL SEME.** Ordine DF voce 05:
          // senza, due discese nello stesso giorno con la stessa domanda
          // riportavano su la stessa identica scena, parola per parola.
          discesa: discesa,
          // **L'ANIMALE ENTRA NELLA SCENA**, ordine DI voce 04: sceglie i
          // gesti che il suo corpo sa fare. Dopo la quarta discesa le da'
          // il suo nome.
          animale: animale,
          siPuoDire: siPuoDire,
          conDomanda: conDomanda,
          // **E LA RISPOSTA CHE NE NOMINA LA TESTA**, alla riprova a video
          // della 2260: *"un seme"* e il pezzo *"il seme"*. Il gesto
          // dell'animale si guarda solo per intero.
          evita: (pezzo) =>
              LeGuardieDelResponso.titoloToccaLaScena(titolo, [pezzo.nome]) ||
              (pezzo.categoria == CategoriaDellaScena.gesto
                  ? pezzo.nome.length > 3 &&
                      (scritti.risposta ?? '')
                          .toLowerCase()
                          .contains(pezzo.nome.toLowerCase())
                  : LeGuardieDelResponso.nominaIlPezzo(
                      scritti.risposta ?? '', pezzo.nome,
                      dellaDomanda: '$domanda ${oggetto ?? ''}')),
        );
    ScenaDelViaggio scena;
    String titolo;
    var scenaRifatta = false;
    if (dalModello != null) {
      scena = ScenaSenzaModello.daiPezzi(
        luogo: dalModello.luogo,
        cosa: dalModello.cosa,
        gesto: dalModello.gesto,
        momento: dalModello.momento,
        domanda: domanda,
        giorno: giorno,
        nitidezza: nitidezza,
        discesa: discesa,
        animale: animale,
        siPuoDire: siPuoDire,
        conDomanda: conDomanda,
      );
      titolo = scritti.titolo ?? titoloDiCasa;
      if (tocca(titolo, scena)) {
        scena = diRiserva(titolo);
        scenaRifatta = true;
      }
    } else {
      titolo = scritti.titolo ?? titoloDiCasa;
      scena = diRiserva(titolo);
    }
    final forma = formaDellaScena(scena.idDeiPezzi, precedenti);
    final voce = LaVoceDelMondoDiSotto.alGiorno(
      scena: scena,
      temaDomanda: id,
      temaInLettere: LaVoceDelMondoDiSotto.temaInLettereDi(tema),
      giornoDellaDiscesa: giorno,
      giaOggi: giaOggi,
      formaDellaScena: forma,
      letti: letti,
      oggettoDellaDomanda: oggetto,
      domanda: domanda,
    );
    // **IL TITOLO, LA RISPOSTA E IL GESTO DEL MODELLO**, ordine DL voci 07 e
    // 13: ognuno prende il posto di quello di casa soltanto se ha retto alle
    // guardie. La scena resta dove sta, in fondo, come fonte.
    final paragrafi = [...voce.paragrafi];
    // **LA RISERVA PRENDE POSIZIONE. Ordine ET voce 08.** Con una domanda,
    // quando nessuna risposta del modello ha retto (neanche la prima frase
    // di una scartata, `LaScenaDalModello.conLaPrimaFrase`), la riserva non
    // e' piu' la voce di casa, che parla del tema e di cose che la domanda
    // non ha: dice la posizione che il modello aveva scelto.
    final laPosizione = conDomanda
        ? rispostaCheSiSchiera(scritti.posizione,
            seme: discesa, domanda: domanda)
        : null;
    final rispostaDiRiserva = laPosizione ?? voce.risposta;
    // Senza la risposta del modello e senza una posizione il primo
    // paragrafo resta quello della voce di casa, con la sua ripresa
    // dell'oggetto: la prima stesura lo sostituiva con la sola risposta, e
    // le prove della ripresa l'hanno presa.
    final primo = scritti.risposta ?? laPosizione;
    if (primo != null && paragrafi.isNotEmpty) {
      paragrafi[0] = primo;
    }
    if (scritti.azione != null && paragrafi.length > 1) {
      paragrafi[1] = LaVoceDelMondoDiSotto.gestoDelModello(scritti.azione!,
          FiloDellaVoce.da([...scena.idDeiPezzi, 'gesto del modello']).seme);
    }
    String fonte(String pezzo, bool dalModello) {
      // **LA SECONDA CHIAMATA SI DICE**, ordine DQ voce 06: la riga di
      // collaudo e la misura sanno quale testo il modello ha riscritto.
      if (dalModello) {
        if (scritti.dallaSeconda.contains('$pezzo: prima frase')) {
          return 'modello: prima frase di una risposta scartata';
        }
        return scritti.dallaSeconda.contains(pezzo)
            ? 'modello: seconda chiamata'
            : 'modello';
      }
      final scarto = scritti.scarti
          .where((r) => r.pezzo == pezzo)
          .map((r) => r.motivo.name)
          .firstOrNull;
      final quale = pezzo == 'risposta'
          ? (laPosizione == null
              ? 'riserva'
              : 'riserva con la posizione ${scritti.posizione}')
          : 'riserva';
      return scarto == null ? quale : '$quale: $scarto';
    }

    final titoloDelModello = scritti.titolo != null && titolo == scritti.titolo;
    const anticipa = 'riserva: titoloAnticipaLaScena';
    final fonti = <String, String>{
      'scena': dalModello == null
          ? 'riserva'
          : scenaRifatta
              ? anticipa
              : 'modello',
      'titolo': fonte('titolo', titoloDelModello),
      'risposta': fonte('risposta', scritti.risposta != null),
      'gesto': fonte('azione', scritti.azione != null),
      ...fontiGiaNote,
    };
    return IlResponsoDelViaggio._(
      scena: scena,
      dalModello: dalModello != null && !scenaRifatta,
      titolo: titolo,
      paragrafi: paragrafi,
      // **NEL DIARIO VA CIO' CHE SI E' LETTO**, parola per parola: chi
      // riapre una discesa di sei mesi fa rilegge il testo del modello, e
      // non se ne scrive uno nuovo. Ordine DL voce 07.
      risposta: scritti.risposta ?? rispostaDiRiserva,
      gesto: scritti.azione ?? voce.gesto,
      fonti: fonti,
      oggetto: oggetto,
      // **IL RICHIAMO: questa scena riprende un elemento di una di prima?**
      // Ordine DE voce 11: si guarda cinque scene indietro e non di piu'.
      richiamo: IlRichiamoDelleScene.laRiga(
        precedenti: precedenti,
        oggi: scena.idDeiPezzi,
        nomeDellElemento: scena.cosa.nome,
        quale: 1,
      ),
    );
  }
}
