// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:esoteric_circle/core/archetypes/archetype_corpus.dart';
import 'package:esoteric_circle/core/archetypes/archetype_quiz.dart';
import 'package:esoteric_circle/core/archetypes/archetype_scoring.dart';
import 'package:esoteric_circle/core/astro/il_cielo_detto.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/chat/i_responsi_di_oggi.dart';
import 'package:esoteric_circle/core/chat/la_marca_del_genere.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/horoscope/cielo_di_oggi.dart';
import 'package:esoteric_circle/core/horoscope/horoscope.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/misura_della_risposta.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/core/rituals/arcano_dell_alba/diario_dell_alba.dart';
import 'package:esoteric_circle/core/rituals/arcano_dell_alba/responso_dell_alba.dart';
import 'package:esoteric_circle/core/rituals/dawn_gift.dart';
import 'package:esoteric_circle/core/rituals/dream_rite_corpus.dart';
import 'package:esoteric_circle/core/rituals/guide_animal_day.dart';
import 'package:esoteric_circle/core/rituals/guide_animal_derivation.dart';
import 'package:esoteric_circle/core/rituals/risposta_del_soffio.dart';
import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:esoteric_circle/core/rituals/rune_presage.dart';
import 'package:esoteric_circle/core/rituals/sunset_rune.dart';
import 'package:esoteric_circle/core/synastry/synastry_report.dart';
import 'package:esoteric_circle/core/synastry/vip_catalog.dart';
import 'package:esoteric_circle/core/tarot/stesa_in_corso.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread.dart';
import 'package:esoteric_circle/features/synastry/sinastria_vip_screen.dart';
import 'package:esoteric_circle/services/ai/firebase_maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/le_funzioni_del_cielo.dart';
import 'package:esoteric_circle/services/ai/maestro_persona.dart';

import 'package:flutter_test/flutter_test.dart';

/// **IL BANCO DI MEDORA E DEI RESPONSI.** Ordine EV voce 04.
///
/// Dieci responsi VERI, composti dalle stesse funzioni che li compongono
/// nell'app (Oroscopo coi suoi "Da dove viene", Stesa, Gettata, Sinastria,
/// Arcano dell'Alba, Sigillo del Sogno, Runa del Tramonto, Soffio del
/// Destino, Animale guida, Archetipo), registrati come li registra
/// `AzioniDelResponso` quando compaiono. Poi dieci domande a Medora, una per
/// responso: in quelle dispari la persona ha toccato "Parlane con...", in
/// quelle pari scrive a mano. Istruzione, configurazione e funzioni del
/// cielo vere, modello vero in europe-west1.
///
/// Accanto a ogni risposta: il responso che la persona aveva davanti, i nomi
/// che la risposta deve contenere e le frasi con cui Medora negava.
///
/// ```
/// flutter test tool/medora_e_il_responso.dart
/// ```
///
/// `PRIMA=1`: come prima dell'ordine EV, senza i responsi nell'istruzione.
void main() {
  const progetto = 'esoteric-circle';
  const regione = 'europe-west1';
  final prima = Platform.environment['PRIMA'] == '1';
  // PERSONA=2: un'altra persona con altri semi, per la seconda esecuzione
  // con dati diversi che la regola della chiusura chiede ai testi generati.
  final seconda = Platform.environment['PERSONA'] == '2';
  final uscita = Platform.environment['USCITA'] ??
      'docs/collaudo/EV/medora_e_il_responso${prima ? '_prima' : ''}'
          '${seconda ? '_persona2' : ''}.txt';
  final sole = seconda ? Zodiac.leo : Zodiac.cancer;
  final seme = seconda ? 11 : 7;
  final nato = seconda ? DateTime(1985, 8, 5, 12) : DateTime(1990, 7, 10, 12);
  final nome = seconda ? 'Marco' : 'Sofia';
  final lunaDiNascita = seconda ? 'Pesci' : 'Bilancia';
  final ascendente = seconda ? 'Vergine' : 'Scorpione';

  test('Medora e i responsi: dieci domande', () async {
    var gettone = await _gettone();
    if (gettone == null) fail('Serve una sessione gcloud attiva.');
    LaMarcaDelGenere.formaCorrente =
        seconda ? CourtesyForm.masculine : CourtesyForm.feminine;
    final adesso = DateTime.now();
    final oggi = DateTime(adesso.year, adesso.month, adesso.day, 12);
    final nascita = DateTime(nato.year, nato.month, nato.day);

    // 1. L'Oroscopo, coi suoi "Da dove viene".
    final cards = Horoscope.forSign(
        sign: sole,
        dayOfYear: Horoscope.dayOfYear(oggi),
        year: oggi.year,
        cielo: CieloDiOggi.perIlGiorno(adesso: oggi, carta: null),
        nascita: nascita);
    final conLivello = cards.where((c) => c.rigaDelLivello != null).toList();
    final schedaOroscopo = conLivello.isEmpty ? cards.first : conLivello.first;
    // 2. La Stesa.
    var stesa = StesaInCorso.nuova(
        mazzo: TarotSpread.mazzoMescolato(seed: seme), seme: seme);
    for (var i = 0; i < SpreadPosition.values.length; i++) {
      stesa = stesa.assegna(SpreadPosition.values[i], dalVentaglio: i);
    }
    final spread = stesa.stesaCompiuta!;
    // 3. La Gettata.
    final gettata = RuneCast.getta(gettataNorne, random: Random(seme));
    // 4. La Sinastria.
    final vip = VipCatalog.first;
    final sinastria = SynastryReport.perCieli(
        tuo: SinastriaVipScreenState.cieloDiRipiego(
            nato, sole, ''),
        vip: vip,
        quando: oggi);
    // 5. L'Arcano dell'Alba.
    final diario = DiarioDellAlba.nuovo(seme: '0123456789abcdef');
    final alba = diario
        .estrai(
            utente: diario.seme,
            giorno: DateTime(oggi.year, oggi.month, oggi.day, 7),
            caso: Random(seme))
        .responso;
    final cartaAlba = ResponsoDellAlba.cartaColVerso(alba.stato);
    // 6. Il Sigillo del Sogno (la notte prima).
    final sogno = DreamRiteCorpus.saluto(
        DateTime(oggi.year, oggi.month, oggi.day, 22),
        nascita: nascita);
    // 7. La Runa del Tramonto.
    final tramonto = SunsetRune.estrai(
        DateTime(oggi.year, oggi.month, oggi.day, 19),
        identita: SunsetRune.identitaPer(nascita: nascita, deviceId: ''));
    // 8. Il Soffio del Destino.
    final dataSoffio = DateTime(oggi.year, oggi.month, oggi.day, 8);
    final risp = RispostaDelSoffio.diOggi(
        CieloDiOggi.perIlGiorno(adesso: dataSoffio, carta: null));
    final soffio = DawnGift.forMaestro(dataSoffio, Maestro.aura,
        identity: BirthIdentity(
            birthMoment: nato, hasBirthTime: false),
        rispostaPropria: risp?.comeRisposta() ??
            RispostaDelSoffio.senzaIlTuoCielo(dataSoffio));
    // 9. L'Animale guida.
    final animale = GuideAnimalDerivation.forSign(sole);
    final giornoAnimale = GuideAnimalDay.per(
        animale: animale,
        soleNatale: sole,
        giorno: oggi,
        nascita: nascita);
    // 10. L'Archetipo.
    final profilo = ArchetypeScoring.calcola(
        [for (var i = 0; i < ArchetypeQuiz.tutte.length; i++) i % 4]);
    final dom = profilo.dominante;

    final responsi = <({
      ResponsoDiOggi r,
      String domanda,
      List<String> nomi,
    })>[
      (
        r: ResponsoDiOggi(
          arte: 'oroscopo',
          titolo: 'Il tuo oroscopo, ${sole.italianName}',
          testo: cards
              .map((c) => [
                    '${c.title}\n${c.text}',
                    if (c.rigaDelLivello != null)
                      'Da dove viene: ${c.rigaDelLivello}',
                  ].join('\n'))
              .join('\n\n'),
        ),
        domanda: 'Nell\'oroscopo di oggi, sotto "${schedaOroscopo.title}", '
            'c\'è il transito da cui nasce. Me lo spieghi?',
        nomi: [
          for (final p in [
            'Sole', 'Luna', 'Mercurio', 'Venere', 'Marte', 'Giove', //
            'Saturno', 'Urano', 'Nettuno', 'Plutone'
          ])
            if ((schedaOroscopo.rigaDelLivello ?? '').contains(p)) p,
        ],
      ),
      (
        r: ResponsoDiOggi(
            arte: 'stesa',
            titolo: 'La tua stesa a tre carte',
            testo: spread.reading),
        domanda: 'Cosa vuol dire la carta che mi è uscita al centro della '
            'stesa?',
        nomi: [spread.presente.card.name],
      ),
      (
        r: ResponsoDiOggi(
            arte: 'gettata',
            titolo: 'La tua gettata: ${gettata.gettata.nome}',
            testo: RunePresagio.componiIlResponso(gettata).inParole),
        domanda: 'Perché proprio queste rune, nella mia gettata?',
        nomi: [gettata.rune.first.rune.name],
      ),
      (
        r: ResponsoDiOggi(
            arte: 'sinastria',
            titolo: 'La tua sinastria con ${vip.name}',
            testo: sinastria.reading),
        domanda: 'Cosa vuol dire la mia sinastria con ${vip.name}?',
        nomi: [vip.name],
      ),
      (
        r: ResponsoDiOggi(
            arte: 'arcano_alba',
            titolo: 'Il tuo Arcano dell\'Alba',
            testo: [
              alba.primo,
              if (alba.parola != null) 'La parola di oggi: ${alba.parola}.',
              alba.secondo,
              if (alba.perche.trim().isNotEmpty) alba.perche,
              alba.terzo,
            ].join('\n\n')),
        domanda: 'Che carta mi è uscita stamattina all\'Alba, e cosa mi '
            'chiede?',
        nomi: [cartaAlba.split(' ').where((p) => p.length > 3).first],
      ),
      (
        r: ResponsoDiOggi(
            arte: 'sogno', titolo: 'Il tuo Sigillo del Sogno', testo: sogno),
        domanda: 'Il saluto del Sigillo del Sogno di stanotte cosa voleva '
            'dirmi?',
        nomi: const [],
      ),
      (
        r: ResponsoDiOggi(
            arte: 'tramonto',
            titolo: 'La tua runa del tramonto: ${tramonto.rune.name}',
            testo: tramonto.riga),
        domanda: 'La runa del tramonto di oggi cosa significa per me?',
        nomi: [tramonto.rune.name],
      ),
      (
        r: ResponsoDiOggi(
            arte: 'soffio',
            titolo: 'Il tuo Soffio del Destino',
            testo: soffio.orientation),
        domanda: 'Il Soffio del Destino di oggi mi ha detto una cosa: me la '
            'ricordi e me la spieghi?',
        nomi: const [],
      ),
      (
        r: ResponsoDiOggi(
            arte: 'animale',
            titolo: 'Il tuo animale guida: ${animale.name}',
            testo: giornoAnimale.testo),
        domanda: 'Il messaggio del mio animale guida di oggi cosa vuol dire?',
        nomi: [animale.name],
      ),
      (
        r: ResponsoDiOggi(
            arte: 'archetipo',
            titolo: 'Il tuo archetipo: ${dom.conArticolo}',
            testo: ArchetypeCorpus.di(dom).essenza),
        domanda: 'Il mio archetipo, quello che mi è uscito oggi, che cosa '
            'dice di me?',
        nomi: [dom.nome],
      ),
    ];

    final strumenti = [
      for (final t in LeFunzioniDelCielo.perIlMaestro(adesso: adesso))
        t.toJson()
    ];
    final config = FirebaseMaestroAiProvider.configurazionePer(
      MisuraDellaRisposta.perIlTurno(nelLive: false),
      temperature: 0.9,
      topP: 0.95,
    ).toJson();
    final natale = NatalContext(
      sunSign: sole.italianName,
      moonSign: lunaDiNascita,
      ascendant: ascendente,
      lifeNumber: 7,
      lifeNumberTitle: 'il Cercatore',
    );

    Future<Map<String, dynamic>?> chiama(Map<String, Object?> corpo) async {
      final uri = Uri.https(
        '$regione-aiplatform.googleapis.com',
        '/v1/projects/$progetto/locations/$regione/publishers/google/models/'
            '${FirebaseMaestroAiProvider.kMaestroChatModel}:generateContent',
      );
      for (var tentativo = 0; tentativo < 4; tentativo++) {
        final client = HttpClient();
        try {
          final r = await client.postUrl(uri);
          r.headers.set('Authorization', 'Bearer $gettone');
          r.headers.set('Content-Type', 'application/json');
          r.add(utf8.encode(jsonEncode(corpo)));
          final risposta = await r.close();
          final grezzo = await risposta.transform(utf8.decoder).join();
          if (risposta.statusCode == 401) {
            gettone = await _gettone();
            continue;
          }
          if (risposta.statusCode == 429 || risposta.statusCode >= 500) {
            await Future<void>.delayed(Duration(seconds: 5 * (tentativo + 1)));
            continue;
          }
          if (risposta.statusCode != 200) {
            stderr.writeln('HTTP ${risposta.statusCode}: $grezzo');
            return null;
          }
          return jsonDecode(grezzo) as Map<String, dynamic>;
        } finally {
          client.close(force: true);
        }
      }
      return null;
    }

    // Le frasi con cui un Maestro nega o non sa.
    final nega = RegExp(
        // Con il confine di parola: "non soffoca" non e' "non so" (secondo
        // giro del 1 ottobre, risposta 2, contata a torto).
        r"\bnon (?:ho|vedo|so|conosco|trovo|posso (?:vedere|sapere|leggere)|mi risulta|ho accesso)\b|"
        r"chi (?:l'ha|te l'ha|lo ha) (?:scritt|dett)|dimmi (?:tu )?(?:quale|quali|cosa dice)|"
        r"(?:quale|che) carta (?:ti e|ti è) uscita\?|raccontami (?:cosa|che cosa) (?:dice|ti ha)",
        caseSensitive: false);

    final righe = <String>[
      'BANCO DI MEDORA E DEI RESPONSI, ordine EV voce 04. '
          '${prima ? 'COME PRIMA DELL\'ORDINE EV (senza i responsi '
              'nell\'istruzione).' : 'CODICE DELL\'ORDINE EV.'}',
      'Eseguito il ${adesso.toIso8601String()} da tool/medora_e_il_responso.dart: '
          'modello ${FirebaseMaestroAiProvider.kMaestroChatModel} in '
          '$regione, istruzione, configurazione e funzioni del cielo vere. I '
          'dieci responsi sono composti dalle funzioni dell\'app che li '
          'compongono a video, per una persona del ${sole.italianName} nata il ${nato.day}/${nato.month}/'
          '${nato.year}, e registrati tutti come "letti oggi". Domande dispari: la '
          'persona ha toccato "Parlane con...". Pari: scrive a mano.',
      '',
    ];
    var negate = 0;
    var senzaNomi = 0;
    for (var i = 0; i < responsi.length; i++) {
      final voce = responsi[i];
      IResponsiDiOggi.dimentica();
      for (final x in responsi) {
        IResponsiDiOggi.ricorda(x.r, adesso: adesso);
      }
      final partenza = i.isEven;
      if (partenza) IResponsiDiOggi.apri(voce.r, adesso: adesso);
      final blocco = IResponsiDiOggi.bloccoPerIlModello(adesso);
      final natal = prima
          ? natale
          : natale.conIlCieloEIResponsi(responsiDiOggi: blocco);
      final istruzione = MaestroPersona.systemInstruction(
        maestro: Maestro.medora,
        profile: UserProfile(displayName: nome),
        memory: MaestroMemory.empty,
        natal: natal,
      );
      final contenuti = <Map<String, Object?>>[
        {
          'role': 'user',
          'parts': [
            {'text': voce.domanda}
          ]
        }
      ];
      var testo = '';
      final chiamate = <String>[];
      var sollecitato = false;
      var chiestoQuale = false;
      for (var giro = 0; giro < 5; giro++) {
        final d = await chiama({
          'systemInstruction': {
            'parts': [
              {'text': istruzione}
            ]
          },
          'contents': contenuti,
          if (!prima) 'tools': strumenti,
          'generationConfig': config,
        });
        if (d == null) break;
        final c = (d['candidates'] as List).first as Map<String, dynamic>;
        final contenuto = (c['content'] as Map?)?.cast<String, Object?>() ??
            const <String, Object?>{};
        final parti = ((contenuto['parts'] as List?) ?? const [])
            .cast<Map<String, dynamic>>();
        final funzioni = [
          for (final p in parti)
            if (p['functionCall'] != null)
              (p['functionCall'] as Map).cast<String, dynamic>()
        ];
        if (funzioni.isEmpty) {
          testo = parti
              .where((p) => p['thought'] != true)
              .map((p) => '${p['text'] ?? ''}')
              .join()
              .trim();
          // Il sollecito dell'app quando la risposta rimanda (come nel
          // provider, `LeFunzioniDelCielo.rimanda`).
          if (!prima &&
              !sollecitato &&
              chiamate.isEmpty &&
              LeFunzioniDelCielo.rimanda(domanda: voce.domanda, risposta: testo)) {
            sollecitato = true;
            chiamate.add('(sollecito: la prima risposta rimandava: "$testo")');
            contenuti.add({'role': 'model', 'parts': parti});
            contenuti.add({
              'role': 'user',
              'parts': [
                {'text': LeFunzioniDelCielo.sollecito}
              ]
            });
            continue;
          }
          // E quello quando chiede quale responso (`IResponsiDiOggi`).
          if (!prima && !chiestoQuale && IResponsiDiOggi.chiedeQuale(testo)) {
            chiestoQuale = true;
            chiamate.add('(sollecito: la prima risposta chiedeva quale: '
                '"$testo")');
            contenuti.add({'role': 'model', 'parts': parti});
            contenuti.add({
              'role': 'user',
              'parts': [
                {'text': IResponsiDiOggi.sollecito}
              ]
            });
            continue;
          }
          break;
        }
        contenuti.add({'role': 'model', 'parts': parti});
        contenuti.add({
          'role': 'user',
          'parts': [
            for (final f in funzioni)
              {
                'functionResponse': {
                  'name': f['name'],
                  'response': f['name'] == LeFunzioniDelCielo.cieloDelGiorno
                      ? LeFunzioniDelCielo.giorno(
                          ((f['args'] as Map?) ?? const {})
                              .cast<String, Object?>())
                      : LeFunzioniDelCielo.periodo(
                          ((f['args'] as Map?) ?? const {})
                              .cast<String, Object?>()),
                }
              }
          ]
        });
        for (final f in funzioni) {
          chiamate.add('${f['name']}(${jsonEncode(f['args'])})');
        }
      }
      // La rete del cielo detto, come in chat.
      final diNascita = {'Sole': sole.italianName, 'Luna': lunaDiNascita};
      final tolte = IlCieloDetto.smentite(testo,
          adesso: adesso, diNascita: diNascita);
      testo = IlCieloDetto.senzaLeSmentite(testo,
          adesso: adesso, diNascita: diNascita);
      final negazioni = [
        for (final m in nega.allMatches(testo)) m.group(0)!,
      ];
      final mancano = [
        for (final n in voce.nomi)
          if (!testo.toLowerCase().contains(n.toLowerCase())) n,
      ];
      if (negazioni.isNotEmpty) negate++;
      if (mancano.isNotEmpty) senzaNomi++;
      righe
        ..add('=' * 72)
        ..add('${i + 1}. [${partenza ? 'da "Parlane con..."' : 'scritta a mano'}] '
            '${voce.r.titolo}')
        ..add('DOMANDA: ${voce.domanda}')
        ..add('Funzioni del cielo chiamate: '
            '${chiamate.isEmpty ? 'nessuna' : chiamate.join('; ')}')
        ..add('RISPOSTA DI MEDORA (a video):')
        ..add(testo)
        ..add('Frasi tolte dalla rete del cielo detto: '
            '${tolte.isEmpty ? 'nessuna' : tolte.map((t) => '${t.frase} (${t.perche})').join(' | ')}')
        ..add('Frasi che negano o non sanno: '
            '${negazioni.isEmpty ? 'nessuna' : negazioni.join(' | ')}')
        ..add('Nomi del responso attesi nella risposta: '
            '${voce.nomi.isEmpty ? '(nessun nome da cercare: si legge)' : voce.nomi.join(', ')}; '
            'mancano: ${mancano.isEmpty ? 'nessuno' : mancano.join(', ')}')
        ..add('IL RESPONSO CHE LA PERSONA AVEVA DAVANTI:')
        ..add(voce.r.testo)
        ..add('');
      print('${i + 1}/${responsi.length}');
    }
    righe.insert(
        3,
        'CONTO: risposte con una frase che nega o non sa $negate su '
        '${responsi.length}; risposte senza il nome del responso $senzaNomi '
        'su ${responsi.length}. Il conto automatico cerca frasi e nomi: la '
        'lettura di ogni risposta, qui sotto, e\' quella che decide.\n');
    File(uscita).writeAsStringSync('${righe.join('\n')}\n');
    print('Scritto $uscita: negate $negate, senza nomi $senzaNomi');
  }, timeout: const Timeout(Duration(minutes: 30)));
}

Future<String?> _gettone() async {
  try {
    final esito = await Process.run('gcloud', ['auth', 'print-access-token'],
        runInShell: true);
    if (esito.exitCode != 0) return null;
    final t = (esito.stdout as String).trim();
    return t.isEmpty ? null : t;
  } catch (_) {
    return null;
  }
}
