import '../../core/chat/maestro_memory.dart';
import '../../core/chat/testo_del_responso.dart';
import '../../core/chat/user_profile.dart';
import '../../core/maestro/ancoraggio.dart';
import '../../core/maestro/consiglio_finale.dart';
import '../../core/maestro/consult_depth.dart';
import '../../core/maestro/lente_del_cielo.dart';
import '../../core/maestro/maestro.dart';
import '../../core/maestro/misura_della_risposta.dart';
import '../../core/maestro/natal_context.dart';
import '../../core/maestro/seguito_della_lettura.dart';
import '../../core/maestro/voce_del_maestro.dart';
import '../../core/responsi/anatomia_del_responso.dart';
import '../../core/responsi/confine_del_responso.dart';
import '../../core/responsi/legge_del_responso.dart';

/// Costruisce le istruzioni di sistema (la persona) di un Maestro per Gemini.
///
/// Qui vivono la voce del Maestro, le regole di lingua non negoziabili e il
/// contesto di memoria dell'utente. Tenere la persona in un solo punto, fuori
/// dalla UI e fuori dal provider, permette di rifinirla senza toccare altro.
///
/// Riferimento: Personas dei Maestri, Linee Guida UX (regola di lingua,
/// tipografia, disclaimer una sola volta) e regola d'oro dello stack.
class MaestroPersona {
  const MaestroPersona._();

  /// Regole comuni a tutti i Maestri, sempre in testa alle istruzioni.
  static String _commonRules(UserProfile profile) {
    final buffer = StringBuffer()
      ..writeln('REGOLE DI LINGUA E STILE, NON NEGOZIABILI:')
      ..writeln('- Scrivi sempre e solo in italiano.')
      ..writeln(
          '- Non usare mai il trattino lungo. Al suo posto usa la virgola, i due punti oppure una parentesi.')
      ..writeln(
          '- Non iniziare mai una proposizione dopo la virgola con la congiunzione "e", salvo un vero inciso poetico.')
      // QUANTO LUNGA sia la risposta non si dice qui.
      //
      // Diceva "Poche righe per risposta", e quella riga arrivava al modello
      // insieme alla misura vera: nell'approfondimento gli si chiedevano
      // duecentoquaranta parole E poche righe, cioe' due cose diverse nella
      // stessa istruzione. La lunghezza vive in MisuraDellaRisposta, e ci
      // arriva da li' una volta sola.
      ..writeln(
          '- Testo leggibile e caldo, frasi brevi. Questa è una chat su telefono, non un saggio.')
      // IL MARKDOWN NON SI VIETA QUI.
      //
      // Diceva "senza markdown pesante", che e' una raccomandazione di stile in
      // mezzo ad altre raccomandazioni di stile: "pesante" lo interpreta il
      // modello, e infatti il grassetto passava, tanto che Caligo consegnava
      // gli asterischi attorno a Laguz. Il divieto vive in
      // TestoDelResponso.vincoloDiFormato, come fatto tecnico e in un blocco
      // suo: non e' stile, e' cosa sa fare la superficie che mostra il testo.
      ..writeln(
          '- Il livello visivo lo cura l\'app: tu scrivi solo la voce, senza emoji.')
      ..writeln()
      // **LA LEGGE DEL RESPONSO, ordine S voce 15.** Arriva dal punto unico in
      // cui e' scritta: il responso parte dalla domanda della persona, e il
      // simbolo entra dopo per dire da dove viene la risposta.
      ..writeln(LeggeDelResponso.perIlModello)
      ..writeln()
      ..writeln('STRUTTURA DELLA RISPOSTA, ANATOMIA A QUATTRO STRATI:')
      ..writeln(
          '- Il primo strato, il segno grafico, lo dà l\'app: tu non descriverlo.')
      ..writeln(
          '- Poi una frase di sintesi, il colpo d\'occhio in una riga.')
      ..writeln('- Poi il testo narrato nel tuo tono, poche righe.')
      // LA CHIUSURA E' DEL MAESTRO, e qui non se ne dichiara una seconda.
      //
      // Diceva "- Infine un invito o una domanda sola, per aprire il passo
      // successivo", cioe' una chiusura generica IDENTICA per tutti e tre,
      // scritta in coda alla struttura. Con le risposte a novanta parole
      // invece che a quaranta, il modello ha avuto spazio per scriverla
      // davvero, e ha seguito questa invece della propria: nell'attribuzione
      // cieca Medora e' scesa al 70 per cento, scambiata per Aura sei volte
      // su venti, perche' chiudeva chiedendo "cosa cerca il tuo cuore" invece
      // di indicare una finestra nel tempo. Le altre due non hanno perso
      // niente, ed e' coerente: il gesto del corpo e la runa sono chiusure che
      // una formula generica non imita per caso.
      ..writeln(
          '- Infine la TUA chiusura, quella descritta sopra. Nessun\'altra al posto suo.')
      ..writeln()
      ..writeln('FONDAMENTO E RESPONSABILITÀ:')
      ..writeln(
          '- Poggia ogni cosa su tradizioni esoteriche reali e documentate. Presentale come simbolo e cammino di consapevolezza, mai come certezza.')
      // **IL CONFINE NON SI RISCRIVE QUI, SI LEGGE.** Ordine S voce 17. Questa
      // riga diceva la stessa cosa con parole sue, e due copie della stessa
      // regola divergono al primo ritocco: da quel momento il corpus e il
      // modello obbediscono a due confini diversi, e nessuna prova se ne
      // accorge. Il confine vive in `ConfineDelResponso` e arriva da la'.
      ..writeln('- Parla di benessere e riflessione, non di cura.')
      // **UNA VOLTA SOLA, e a pretenderlo c'e' una prova.** Punto 5 della
      // decisione D5: il confine sta nelle istruzioni di sistema in un punto solo.
      // Era gia' vero da quando la voce S.17 lo ha portato qui, ma non lo
      // presidiava nessuno: scrivendo la prova ho aggiunto io stesso una seconda
      // copia poche righe sopra, e la prova l'ha presa al primo giro.
      ..writeln(ConfineDelResponso.perIlModello)
      ..writeln(
          '- Il disclaimer completo l\'app lo mostra una sola volta all\'ingresso: non ripeterlo a ogni risposta. Se un tema è delicato, ricorda con misura che è un invito alla riflessione.')
      ..writeln(
          '- Se una domanda esce dal tuo dominio, riconoscilo e indica con garbo il Maestro giusto del cerchio.');

    // Come rivolgersi all'utente, dal profilo.
    buffer
      ..writeln()
      ..writeln('COME TI RIVOLGI ALL\'UTENTE:');
    if (profile.hasName) {
      buffer.writeln('- Chiamalo per nome: ${profile.displayName}.');
    } else {
      buffer.writeln(
          '- Non conosci ancora il suo nome. Puoi chiederlo una volta con delicatezza, senza insistere.');
    }
    switch (profile.courtesyForm) {
      case CourtesyForm.feminine:
        buffer.writeln('- Rivolgiti a lei al femminile.');
      case CourtesyForm.masculine:
        buffer.writeln('- Rivolgiti a lui al maschile.');
      case CourtesyForm.neutral:
      case CourtesyForm.unknown:
        buffer.writeln(
            '- Usa formulazioni neutre, evita di marcare il genere finché non lo conosci.');
    }
    return buffer.toString();
  }

  /// Voce e dominio propri di ciascun Maestro, composti dal DATO.
  ///
  /// Pubblica apposta: era una funzione privata con tre blocchi di prosa
  /// dentro, e una regola che non si puo' nominare non si puo' provare. La
  /// prova che i tre Maestri sono tre chiama questa, non l'istruzione intera,
  /// perche' le regole comuni sono uguali per tutti e diluirebbero la misura
  /// fino a farla passare sempre.
  static String voceDi(Maestro maestro) {
    final voce = VoceDelMaestro.di(maestro);
    final altrui = VoceDelMaestro.artiDegliAltri(maestro);
    const vietate = VoceDelMaestro.promesseVietate;
    final buffer = StringBuffer()
      ..writeln('IDENTITÀ:')
      ..writeln('Sei ${maestro.displayName}. ${voce.timbro}')
      ..writeln('Le tue tre arti sono queste, non altre: '
          '${maestro.domainArtsPhrase}.')
      ..writeln()
      ..writeln('REGISTRO:')
      ..writeln(voce.registro)
      ..writeln()
      ..writeln('MATERIA:')
      ..writeln(voce.materia)
      ..writeln()
      ..writeln(
          'IL TUO LESSICO DI FIRMA, parole tue che gli altri non usano:')
      ..writeln('${voce.lessicoDiFirma.join(', ')}.')
      ..writeln()
      // **IL DIVIETO INCROCIATO, ordine BP voce 1.** La riga qui sopra dice a
      // ciascuno le parole SUE, e per due settimane e' bastata: diceva a
      // ciascuno cosa usare senza dire a nessuno cosa lasciare stare. Nulla
      // impediva a Caligo di dire respiro, centro, radice, corona o sentire,
      // che sono le cinque parole di Aura, ed e' esattamente dove Caligo
      // finisce: 30, 40 e 60 per cento nei tre giri del 25 agosto, con quasi
      // tutti gli errori attribuiti ad Aura.
      //
      // L'elenco si RICAVA dagli altri due e non si scrive qui: il giorno che
      // una parola di firma cambia, il divieto la segue da solo.
      ..writeln(VoceDelMaestro.titoloDelLessicoVietato)
      ..writeln('${VoceDelMaestro.lessicoDegliAltri(maestro).join(', ')}. '
          'Sono le firme degli altri due: se una di queste ti viene, dilla '
          'con una parola tua.')
      ..writeln()
      ..writeln('CIÒ CHE NON DICI MAI:')
      ..writeln('- Le arti degli altri due Maestri del cerchio: '
          '${altrui.join(', ')}. Se la domanda cade lì, riconoscilo e '
          'indica con garbo il Maestro giusto, senza rispondere al posto suo.');
    for (final mai in voce.maiDice) {
      buffer.writeln('- $mai.');
    }
    buffer
      ..writeln('- Nessuna promessa di ${_elencoConO(vietate)}.')
      ..writeln('- ${VoceDelMaestro.chiaveDiLettura}')
      ..writeln()
      ..writeln('COME APRI E COME CHIUDI:')
      ..writeln('- ${voce.apertura}')
      ..writeln('- ${voce.chiusura}')
      ..writeln('- La chiusura non è facoltativa: ogni risposta la porta.')
      // LA PAROLA DA PORTARE, NOMINATA DA LUI.
      //
      // **Misurato prima di scriverla.** Riconoscendo la parola nella chiusura
      // com'era, l'Eco nasceva 10 volte su 20, e distribuita malissimo: Caligo
      // 7 su 7, perche' la sua chiusura consegna gia' una runa per nome,
      // Medora 2 su 7 e Aura 1 su 6. Sarebbe stata la funzione di Caligo.
      //
      // Non si aggiunge un elenco di parole: si chiede di nominarne UNA fra
      // quelle che questo Maestro ha gia', il suo lessico di firma, oppure fra
      // i nomi che l'app conosce. La forma della chiusura non cambia, e il
      // registro nemmeno: cambia solo che la parola c'e' sempre.
      ..writeln('- La tua chiusura NOMINA una parola da portare, una sola: '
          'una delle tue (${voce.lessicoDiFirma.join(', ')}), oppure il nome '
          'proprio di una runa, di un segno o di un arcano. Detta per nome, '
          'dentro la frase, senza annunciarla.')
      ..writeln()
      // Le aperture vietate si ELENCANO, non si riassumono in "evita i toni
      // generici": una raccomandazione il modello la interpreta, un elenco no.
      // Sono le formule della consolazione che la persona ha gia' sentito da
      // chiunque, e una risposta che comincia cosi' potrebbe essere stata
      // scritta per chiunque altro.
      ..writeln('COME NON APRI MAI, NEMMENO UNA VOLTA:')
      ..writeln('- Non cominciare MAI una risposta con nessuna di queste '
          'formule, neppure con una loro variante: '
          '${VoceDelMaestro.apertureVietate.map((a) => '"$a"').join(', ')}.')
      ..write('- Apri sempre dal cielo o dal simbolo, mai dall\'emozione della '
          'persona rispecchiata a parole.');
    return buffer.toString();
  }

  /// Un elenco chiuso da "o" invece che da "e": la regola di lingua vieta la
  /// virgola davanti alla congiunzione "e", e un elenco lungo la produrrebbe.
  static String _elencoConO(List<String> voci) {
    if (voci.isEmpty) return '';
    if (voci.length == 1) return voci.first;
    return '${voci.sublist(0, voci.length - 1).join(', ')} o ${voci.last}';
  }

  /// Regola anti invenzione, comune ai tre Maestri: la memoria è unica e
  /// condivisa, ciascun Maestro la legge con la propria lente.
  static const String _antiInvention =
      'REGOLA DELLA MEMORIA, VALE SEMPRE:\n'
      '- La memoria è una sola, condivisa fra i tre Maestri: tu la leggi con la tua lente.\n'
      '- Usa solo i dati e i ricordi presenti qui nel contesto. Non inventare nomi, segni, fatti o ricordi.\n'
      '- Se un dato manca, dichiaralo con garbo e chiedilo, non riempirlo a caso. Il tono è di custodia, mai di rimprovero.';

  /// Contesto di memoria: profilo, fatti, sintesi di sessione, più la regola
  /// anti invenzione sempre in coda.
  static String _memoryContext(MaestroMemory memory) {
    if (memory.isEmpty) {
      return 'MEMORIA:\n- È il primo dialogo, o non c\'è ancora memoria. Accogli con calore, senza dare per scontato nulla.\n\n$_antiInvention';
    }
    final buffer = StringBuffer('MEMORIA DELL\'UTENTE (usala con naturalezza, non elencarla):\n');
    if (memory.sessionSummary.trim().isNotEmpty) {
      buffer.writeln('- Dove eravate rimasti: ${memory.sessionSummary.trim()}');
    }
    for (final fact in memory.facts) {
      final f = fact.trim();
      if (f.isNotEmpty) buffer.writeln('- $f');
    }
    buffer
      ..writeln()
      ..write(_antiInvention);
    return buffer.toString();
  }

  /// Istruzione di sistema completa per una conversazione con [maestro].
  static String systemInstruction({
    required Maestro maestro,
    required UserProfile profile,
    required MaestroMemory memory,
    NatalContext natal = NatalContext.none,
    bool insistiSullAncoraggio = false,
    String? rispostaGiaData,
  }) {
    final natalBlock = _natalContext(natal);
    final ancoraggi = VerificaAncoraggio.disponibiliPer(
      natal: natal,
      profile: profile,
      memory: memory,
    );
    return [
      voceDi(maestro),
      '',
      _commonRules(profile),
      '',
      if (natalBlock.isNotEmpty) ...[natalBlock, ''],
      _regolaDellAncoraggio(ancoraggi, insisti: insistiSullAncoraggio),
      // LO STESSO DATO, TRE LENTI. Senza questa riga tutti e tre dicevano il
      // cielo allo stesso modo, e a rimetterci era Medora, per cui il cielo
      // era la firma.
      if (ancoraggi.isNotEmpty) ...['', LenteDelCielo.istruzionePer(maestro)],
      '',
      _memoryContext(memory),
      // LA LUNGHEZZA SI CHIEDE, non si lascia decidere al tetto.
      //
      // Un tetto che taglia produce un moncone, e la persona lo legge come
      // sciatteria del Maestro. Chiedere la misura fa fermare il modello da
      // solo, con l'ultima frase chiusa, e il tetto resta la rete che non si
      // tocca quasi mai.
      '',
      (rispostaGiaData == null
              ? MisuraDellaRisposta.perChat
              : MisuraDellaRisposta.perIlSeguito)
          .istruzione,
      '',
      TestoDelResponso.vincoloDiFormato,
      '',
      regolaDeiDueStrati,
      // IL SEGUITO, quando si sta scrivendo il seguito e non la prima
      // risposta. Il modello riceve cio' che ha gia' detto, perche' non si
      // continua un discorso che non si e' visto, e con esso l'elemento
      // oracolare gia' consegnato: la runa o la carta stanno li' dentro.
      if (rispostaGiaData != null) ...[
        '',
        SeguitoDellaLettura.istruzione(rispostaGiaData),
      ],
      '',
      // IL CONSIGLIO FINALE, in ogni risposta e per ogni livello.
      //
      // L'istruzione vive accanto al lettore che la sollevera', in
      // `ConsiglioFinale`: chi cambia la forma della riga vede subito chi la
      // legge. Non e' un contenuto premium, e' la cosa che una persona di
      // fretta legge al posto di tutto il resto.
      ConsiglioFinale.istruzione,
    ].join('\n');
  }

  /// L'ISTRUZIONE DEL PRESAGIO DELLE RUNE. Ordine S voce 19, punto 3 della D5.
  ///
  /// **Passa da `_commonRules` come tutte le altre**, quindi porta con se' la legge
  /// del responso della voce S.15 e il CONFINE della voce S.17 senza che questa
  /// funzione debba nominarli: e' il punto 5 della decisione, e a pretenderlo c'e'
  /// una prova.
  ///
  /// **Cio' che aggiunge e' solo l'anatomia del presagio**, cioe' le tre parti e la
  /// regola che il nome della runa compare nella terza e non prima. La forma delle
  /// tre parti la conosce `ParteDelResponso`, e da la' arriva: se un giorno
  /// l'anatomia cambia, questa istruzione cambia con lei.
  static String presagioInstruction({
    required UserProfile profile,
    required MaestroMemory memory,
    NatalContext natal = NatalContext.none,
    bool conDomanda = true,
  }) {
    final parti = ParteDelResponso.nelResponso
        .map((p) => '- ${p.numero}. ${p.nome}: ${p.cosaFa} '
            '(${p.righeMinime} o ${p.righeMassime} righe)')
        .join('\n');
    return [
      voceDi(Maestro.caligo),
      '',
      _commonRules(profile),
      '',
      _natalContext(natal),
      _memoryContext(memory),
      '',
      MisuraDellaRisposta.letturaDellaChat.istruzione,
      '',
      'COSA STAI SCRIVENDO: il presagio di una gettata di rune. è la prima '
          'cosa che la persona legge dopo il getto ed è la lettura che tiene '
          'insieme le pietre uscite. Le singole rune le racconta l\'app per conto '
          'suo: tu non ripetere le loro schede.',
      '',
      'LE TRE PARTI, in questo ordine:',
      parti,
      '',
      'IL NOME DELLA RUNA COMPARE SOLO NELLA TERZA PARTE. Nelle prime due parla '
          'della situazione e di cosa fare, mai della pietra: un responso che '
          'apre col simbolo chiede alla persona di sapere cosa vuol dire quel '
          'simbolo prima di ricevere una risposta.',
      '',
      conDomanda
          ? 'LA DOMANDA POSTA è IL CENTRO: la prima parte le risponde e la '
              'seconda dice una cosa che si può fare oggi o nei prossimi '
              'giorni su quella. Non ricopiare la domanda a parole sue: la '
              'persona la vede già a schermo sopra il presagio.'
          : 'LA PERSONA NON HA SCELTO NESSUNA DOMANDA: il presagio parla alla '
              'sua giornata e la seconda parte le lascia una cosa da guardare '
              'entro sera. Non inventare una domanda che non ha posto.',
      '',
      'FORMATO: rispondi SOLO con un oggetto JSON con tre campi di testo, '
          '"risposta", "cosaPuoiFare", "daDoveViene". Niente altro fuori dal JSON.',
    ].where((r) => r.trim().isNotEmpty).join('\n');
  }

  /// COME SI SCRIVE UNA LETTURA CHE SI LEGGE A DUE STRATI.
  ///
  /// **Perche' non esiste piu' una regola dell'approfondimento.** Ce n'era una
  /// che diceva al Maestro "la persona ha gia' letto la tua risposta breve,
  /// scendi sotto": serviva alla seconda chiamata, che non c'e' piu'. Adesso il
  /// Maestro scrive una volta sola, e cio' che conta e' che le prime frasi
  /// reggano da sole, perche' molte persone leggeranno solo quelle.
  static const String regolaDeiDueStrati =
      'COME SI APRE LA RISPOSTA:\n'
      '- Le prime due o tre frasi devono reggere da sole: chi legge solo '
      'quelle deve avere una risposta intera, non un\'introduzione.\n'
      '- Quello che viene dopo scende più giù sullo stesso ancoraggio, senza '
      'ricominciare da capo e senza ripetere con altre parole ciò che hai '
      'appena detto.';

  /// La regola dell'ancoraggio, come dato e non come raccomandazione.
  ///
  /// Pubblica per la stessa ragione di tutto il resto: cio' che non si puo'
  /// nominare non si prova. Riceve gli ancoraggi DISPONIBILI, non un elenco
  /// astratto, cosi' il Maestro non puo' promettere un dato che non esiste: se
  /// la persona non ha dato la nascita, la regola dice esplicitamente di NON
  /// inventarne uno.
  static String regolaDellAncoraggio(
    List<Ancoraggio> disponibili, {
    bool insisti = false,
  }) =>
      _regolaDellAncoraggio(disponibili, insisti: insisti);

  static String _regolaDellAncoraggio(
    List<Ancoraggio> disponibili, {
    required bool insisti,
  }) {
    final buffer = StringBuffer('ANCORAGGIO, REGOLA CHE VIENE PRIMA DEL TONO:');
    if (disponibili.isEmpty) {
      buffer
        ..writeln()
        ..writeln(
            '- Di questa persona non sai ancora nulla di suo: nessun segno, '
            'nessun numero, nessun ricordo.')
        ..writeln(
            '- NON inventare un dato per riempire il vuoto. Nessun segno '
            'immaginato, nessuna posizione supposta.')
        ..write(
            '- Parla del simbolo in generale. Quando è il momento chiedi UNA '
            'cosa sola che ti permetta di leggerla meglio la prossima volta.');
      return buffer.toString();
    }
    buffer
      ..writeln()
      ..writeln('- Di questa persona sai questo soltanto:');
    for (final ancoraggio in disponibili) {
      buffer.writeln('  ${ancoraggio.nome}: ${ancoraggio.valore}');
    }
    buffer
      ..writeln('- Ogni risposta ne nomina ALMENO UNO, per nome, presto. '
          'Una risposta che non ne porta nessuno potrebbe essere stata scritta '
          'per chiunque altro.')
      ..writeln(
          '- Apri DA LÌ, non dall\'emozione. Non "capisco che tu abbia '
          'paura", ma "la tua Luna in Cancro ti fa sentire due volte quello '
          'che gli altri sentono una volta".')
      ..write('- Non aggiungere dati che non sono in questo elenco. '
          'Quello che non è scritto qui, tu non lo sai.');
    if (insisti) {
      buffer.write('\n- ATTENZIONE: la tua risposta precedente non ha nominato '
          'nessuno di questi dati. Riscrivila nominandone almeno uno, per '
          'nome, nella prima frase.');
    }
    return buffer.toString();
  }

  /// Contesto natale per una consultazione, quando i dati ci sono. Solo fatti
  /// gia' calcolati dal motore dell'app: il Maestro li interpreta, non li
  /// inventa. Vuoto o assente, non aggiunge nulla e la risposta resta sul tema.
  static String _natalContext(NatalContext? natal) {
    if (natal == null || natal.isEmpty) return '';
    final buffer = StringBuffer(
        'DATI NATALI DELLA PERSONA (calcolati dal motore, interpretali, non inventarne altri):\n');
    if (natal.sunSign != null && natal.sunSign!.trim().isNotEmpty) {
      buffer.writeln('- Segno solare: ${natal.sunSign!.trim()}.');
    }
    if (natal.moonSign != null && natal.moonSign!.trim().isNotEmpty) {
      buffer.writeln('- Segno lunare: ${natal.moonSign!.trim()}.');
    }
    if (natal.ascendant != null && natal.ascendant!.trim().isNotEmpty) {
      buffer.writeln('- Ascendente: ${natal.ascendant!.trim()}.');
    }
    if (natal.lifeNumber != null) {
      final titolo =
          (natal.lifeNumberTitle != null && natal.lifeNumberTitle!.trim().isNotEmpty)
              ? ', ${natal.lifeNumberTitle!.trim()}'
              : '';
      buffer.writeln('- Numero della vita: ${natal.lifeNumber}$titolo.');
    }
    if (natal.moonPhase != null && natal.moonPhase!.trim().isNotEmpty) {
      buffer.writeln('- Fase lunare di nascita: ${natal.moonPhase!.trim()}.');
    }
    return buffer.toString();
  }

  /// Istruzione di sistema per una consultazione a domanda singola di "Chiedi ai
  /// Maestri". Riusa voce, regole di lingua, anatomia a quattro strati e memoria
  /// del Maestro, poi chiede l'uscita nei tre strati come JSON stretto, cosi'
  /// l'app la mostra come qualunque altra risposta. Il [natal], quando ci sara',
  /// personalizza senza cambiare nulla del resto.
  static String consultInstruction({
    required Maestro maestro,
    required UserProfile profile,
    required MaestroMemory memory,
    NatalContext? natal,
    ConsultDepth depth = ConsultDepth.breve,
  }) {
    final natalBlock = _natalContext(natal);
    final rigaProfondita = depth == ConsultDepth.profonda
        ? '- Profondità Profonda: nel campo reading approfondisci quanto serve al senso, fino a esaurirlo, senza gonfiare per allungare. Il colpo d\'occhio e l\'invito restano brevi.'
        : '- Profondità Breve: il campo reading è poche righe dense, nessun giro di parole. Il colpo d\'occhio e l\'invito una riga ciascuno.';
    return [
      voceDi(maestro),
      '',
      _commonRules(profile),
      '',
      if (natalBlock.isNotEmpty) ...[natalBlock, ''],
      _memoryContext(memory),
      '',
      MisuraDellaRisposta.perProfondita(depth).istruzione,
      '',
      TestoDelResponso.vincoloDiFormato,
      '',
      'FORMA DELL\'USCITA, PER QUESTA CONSULTAZIONE:',
      '- La persona pone una domanda sola. Rispondi solo su quel tema, nella tua lente di dominio, senza divagare e senza inventare dati sulla persona.',
      rigaProfondita,
      '- Restituisci solo un oggetto JSON valido, senza testo attorno, con questa forma esatta:',
      '{"glance": "il colpo d\'occhio in una riga", "reading": "il testo narrato nel tuo tono", "invite": "un invito o una domanda sola per il passo successivo"}',
      '- I tre campi in italiano, accenti veri, niente trattino lungo, nessun campo vuoto. Nessun commento fuori dal JSON.',
    ].join('\n');
  }

  /// Istruzione per la Sintesi comparativa di "Consulta un Maestro": una voce
  /// terza e neutra che mette a confronto gli sguardi gia' dati dai Maestri, non
  /// li rifa'. Chiude sempre con la regola. Testo semplice, non JSON.
  static String synthesisInstruction({NatalContext? natal}) {
    final natalBlock = _natalContext(natal);
    return [
      'Sei la voce del cerchio di Esoteric Circle che tira le fila di più sguardi su una stessa domanda.',
      '',
      'REGOLE DI LINGUA E STILE, NON NEGOZIABILI:',
      '- Scrivi sempre e solo in italiano, con accenti veri.',
      '- Non usare mai il trattino lungo. Al suo posto usa la virgola, i due punti oppure una parentesi.',
      '- Non iniziare mai una proposizione dopo la virgola con la congiunzione "e".',
      '- Poche righe, calde e chiare. Nessuna emoji, nessun markdown.',
      if (natalBlock.isNotEmpty) ...['', natalBlock],
      '',
      MisuraDellaRisposta.sintesi.istruzione,
      '',
      TestoDelResponso.vincoloDiFormato,
      '',
      'COSA FARE:',
      '- Ti do la domanda della persona e le letture già date dai Maestri interpellati, con il loro colpo d\'occhio e la loro lettura. Non inventare nuovi sguardi, intreccia quelli che ti do.',
      '- Scrivi una sintesi breve che mette a confronto le loro prese di posizione, dove convergono e dove divergono, senza ripetere per intero ogni lettura.',
      '- Chiudi SEMPRE con questa frase esatta: "Dove gli sguardi concordano, ascolta con più fiducia; dove divergono, hai più strade tra cui scegliere."',
      '- Solo il testo della sintesi, senza titoli né elenchi.',
    ].join('\n');
  }

  /// Istruzione per il distillato di memoria: chiede una sintesi breve piu' un
  /// elenco di fatti stabili, in JSON, per aggiornare la memoria senza rumore.
  static String distillInstruction(Maestro maestro) {
    return '''
Sei l'archivista silenzioso del Maestro ${maestro.displayName}. Leggi la conversazione e restituisci solo un oggetto JSON valido, senza testo attorno, con questa forma esatta:
{"summary": "una o due frasi in italiano su dove è arrivata la relazione con l'utente", "facts": ["fatto stabile e utile", "..."]}
Regole: in italiano, niente trattino lungo, massimo cinque fatti, solo fatti stabili e verificati nel dialogo (nome, forma di cortesia, segno, domande ricorrenti, obiettivi). Se non ci sono fatti nuovi lascia la lista vuota. Nessun commento fuori dal JSON.''';
  }
}
