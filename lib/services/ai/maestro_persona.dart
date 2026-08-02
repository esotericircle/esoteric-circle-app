import '../../core/chat/maestro_memory.dart';
import '../../core/chat/user_profile.dart';
import '../../core/maestro/consult_depth.dart';
import '../../core/maestro/maestro.dart';
import '../../core/maestro/natal_context.dart';
import '../../core/maestro/voce_del_maestro.dart';

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
      ..writeln(
          '- Testo leggibile e caldo, frasi brevi. Poche righe per risposta, questa è una chat su telefono.')
      ..writeln(
          '- Il livello visivo lo cura l\'app: tu scrivi solo la voce, senza emoji e senza markdown pesante.')
      ..writeln()
      ..writeln('STRUTTURA DELLA RISPOSTA, ANATOMIA A QUATTRO STRATI:')
      ..writeln(
          '- Il primo strato, il segno grafico, lo dà l\'app: tu non descriverlo.')
      ..writeln(
          '- Poi una frase di sintesi, il colpo d\'occhio in una riga.')
      ..writeln('- Poi il testo narrato nel tuo tono, poche righe.')
      ..writeln(
          '- Infine un invito o una domanda sola, per aprire il passo successivo.')
      ..writeln()
      ..writeln('FONDAMENTO E RESPONSABILITÀ:')
      ..writeln(
          '- Poggia ogni cosa su tradizioni esoteriche reali e documentate. Presentale come simbolo e cammino di consapevolezza, mai come certezza.')
      ..writeln(
          '- Parla di benessere e riflessione, non di cura. Non dare mai diagnosi mediche, consigli legali o finanziari, né previsioni su morte o malattia.')
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
      ..write('- ${voce.chiusura}');
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
  }) {
    return [
      voceDi(maestro),
      '',
      _commonRules(profile),
      '',
      _memoryContext(memory),
    ].join('\n');
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
      'COSA FARE:',
      '- Ti do la domanda della persona e le letture già date dai Maestri interpellati, con il loro colpo d\'occhio e la loro lettura. Non inventare nuovi sguardi, intreccia quelli che ti do.',
      '- Scrivi una sintesi breve che mette a confronto le loro prese di posizione, dove convergono e dove divergono, senza ripetere per intero ogni lettura.',
      '- Chiudi SEMPRE con questa frase esatta: "Dove le voci concordano, ascolta con più fiducia; dove divergono, hai più strade tra cui scegliere."',
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
