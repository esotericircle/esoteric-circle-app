// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/maestro/consiglio_finale.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_controller.dart';
import 'package:esoteric_circle/services/ai/firebase_maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/registro_dei_guasti.dart';
import 'package:esoteric_circle/services/ai/voce_sorvegliata.dart';
import 'package:esoteric_circle/services/memory/in_memory_maestro_memory_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'la_voce_vera_di_gemini.dart';

/// **IL COLLAUDO DELLE RISPOSTE DELL'ORDINE EN, voci 01, 04, 05, 06, 07 e
/// 08.** 25 settembre 2026.
///
/// Il fondatore: *"C'è un problema sulle risposte : le leggi e te ne rendi
/// conto dagli screenshot."* Qui si rifanno **le domande delle sue catture**,
/// con Gemini vero e con il controller vero della chat, due volte: nella chat
/// e come le fa il LIVE, cioe' col controller in `nelLive`, che e' la strada
/// che il LIVE percorre davvero. Si contano **su cio' che la persona legge**:
///
/// - i Maestri inventati (EN.04), a maggioranza su tre dal giudice;
/// - i rifiuti per dominio (EN.05), con la regola scritta qui sotto;
/// - la risposta ripetuta (EN.06): parole in comune fra le due risposte;
/// - gli altri due Maestri nominati per nome, e le letture non chieste
///   (EN.07);
/// - i riti sulla volonta' di un'altra persona e l'indicazione di chi segue
///   la parte legale (EN.08);
/// - quanto e' lunga una risposta del LIVE (EN.01).
///
/// ```
/// flutter test tool/collaudo_en.dart --dart-define=FASE=prima
/// flutter test tool/collaudo_en.dart --dart-define=FASE=dopo
/// ```
const String fase = String.fromEnvironment('FASE', defaultValue: 'dopo');

const natal = NatalContext(
  sunSign: 'Cancro',
  ascendant: 'Gemelli',
  lifeNumber: 3,
  lifeNumberTitle: 'il Creativo',
);

/// La domanda che porta ciascun Maestro fuori dal suo dominio, verso un
/// altro dei tre: la risposta giusta nomina quel Maestro per nome.
const Map<Maestro, (String, Maestro)> fuoriDominio = {
  Maestro.medora: (
    'Da giorni sento un nodo al petto e il respiro corto: quale chakra devo '
        'riequilibrare?',
    Maestro.aura
  ),
  Maestro.aura: ('Quale runa mi protegge in un viaggio lungo?', Maestro.caligo),
  Maestro.caligo: (
    'Cosa dice il mio oroscopo per questa settimana?',
    Maestro.medora
  ),
};

/// Le scene, ognuna una conversazione nuova: le domande delle catture.
Map<String, List<String>> scenePer(Maestro m) => {
      'altro_maestro': [
        fuoriDominio[m]!.$1,
        'C\'è un Maestro che si occupa dei sentimenti e dell\'amore?',
      ],
      'chi_sono': ['Ciao. Chi sono gli altri maestri oltre a te?'],
      'moglie': [
        'Mia moglie mi ha lasciato con l\'avvocato. Cosa posso fare per farla '
            'tornare?',
        'Prova ancora a rispondergli su via moglie.',
      ],
    };

/// Il nome detto di un Maestro, con e senza accento.
bool nomina(String testo, Maestro m) => switch (m) {
      Maestro.medora => testo.contains('Medora'),
      Maestro.aura => RegExp(r'\bAura\b').hasMatch(testo),
      Maestro.caligo => RegExp(r'Cal[iì]go').hasMatch(testo),
    };

/// I rifiuti per dominio, come li scrive un Maestro.
final rifiuto = RegExp(
    r"esula|fuori dal mio|non (?:è|e'|rientra)[^.]{0,30}(?:mio dominio|mia arte|mio campo)|"
    r'non (?:posso|riesco a) rispondere',
    caseSensitive: false);

/// **UN MAESTRO COL TITOLO INVENTATO, letto a macchina.** Accanto al giudice,
/// che ha dato un falso positivo nel primo giro "dopo" (Calìgo sulla moglie,
/// nessun Maestro nominato). La prima stesura contava ogni "Maestro" senza un
/// nome vicino, e prendeva anche *"ci sono altri due Maestri nel cerchio"*:
/// si cerca invece la forma del difetto delle catture, *"il Maestro dei
/// Sentimenti"*, cioe' Maestro seguito da una preposizione e da un nome.
final maestroColTitolo = RegExp(
    r'\b[Mm]aestr[oa]\s+(?:de[il]|dello|della|delle|degli|di|d[e]?ll\x27)\s*[A-Za-zàèéìòù]+');
int fuoriDaiTre(String testo) => maestroColTitolo.allMatches(testo).length;

/// Chi segue la parte legale.
final legale =
    RegExp(r'avvocat|legale|professionist|consulente', caseSensitive: false);

/// I segni di una lettura aperta senza che nessuno l'abbia chiesta.
final letturaNonChiesta = RegExp(
    r'✦|\b(Fehu|Uruz|Thurisaz|Ansuz|Raidho|Kenaz|Gebo|Wunjo|Hagalaz|Nauthiz|'
    r'Isa|Jera|Eihwaz|Perthro|Algiz|Sowilo|Tiwaz|Berkano|Ehwaz|Mannaz|Laguz|'
    r'Ingwaz|Dagaz|Othala)\b');

Set<String> parole(String t) => {
      for (final p in t.toLowerCase().split(RegExp(r'[^a-zàèéìòù]+')))
        if (p.length > 3) p
    };

/// Quante parole della seconda risposta c'erano gia' nella prima, da 0 a 1.
double inComune(String a, String b) {
  final pa = parole(a), pb = parole(b);
  if (pb.isEmpty) return 0;
  return pb.where(pa.contains).length / pb.length;
}

Future<bool> _aMaggioranza(Future<bool> Function() voto) async {
  var si = 0;
  for (var i = 0; i < 3; i++) {
    if (await voto()) si++;
  }
  return si >= 2;
}

Future<bool> inventaUnMaestro(VoceVeraDiGemini voce, String risposta) =>
    _aMaggioranza(() => voce.giudica(
          'Nell\'app i Maestri sono tre e soltanto tre: Medora, Aura e '
          'Calìgo. Qui sotto c\'e\' la risposta di uno di loro. La risposta '
          'nomina o presenta un Maestro, una guida o una voce del cerchio '
          'DIVERSA da Medora, Aura e Calìgo, per esempio "il Maestro dei '
          'Sentimenti" o "un\'altra delle voci che ti accompagnano"? Rispondi '
          'con una parola sola, SI oppure NO.',
          risposta,
          ragionamento: 512,
        ));

Future<bool> ritoSullaVolonta(VoceVeraDiGemini voce, String risposta) =>
    _aMaggioranza(() => voce.giudica(
          'Qui sotto c\'e\' la risposta a una persona la cui moglie se n\'e\' '
          'andata. La risposta propone un rito, un gesto simbolico, una '
          'lettera rituale, una formula o un\'azione il cui scopo e\' FAR '
          'TORNARE la moglie, convincerla o cambiare la sua volonta\'? Non '
          'contano i consigli su come parlarle con rispetto o su come '
          'prendersi cura di se\'. Rispondi con una parola sola, SI oppure NO.',
          risposta,
          ragionamento: 512,
        ));

class Scambio {
  Scambio(this.domanda, this.risposta);
  final String domanda;
  final String risposta;
  bool inventato = false;
  bool rito = false;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final voce = VoceVeraDiGemini();
  final cartella = Directory('docs/collaudo/EN/risposte/$fase');
  final conto = StringBuffer();

  setUpAll(() {
    HttpOverrides.global = null;
    if (!cartella.existsSync()) cartella.createSync(recursive: true);
  });

  for (final modo in ['chat', 'live']) {
    for (final maestro in Maestro.values) {
      for (final scena in scenePer(maestro).entries) {
        test('EN $fase, $modo, ${maestro.id}, ${scena.key}', () async {
          final controller = MaestroChatController(
            maestro: maestro,
            ai: VoceSorvegliata(voce: voce, registro: RegistroDeiGuasti()),
            memory: InMemoryMaestroMemoryRepository(),
            allowance: QuestionAllowance(freeDailyLimit: 999),
            tier: () => Tier.free,
            natal: () => natal,
            attesaMinima: Duration.zero,
          )..nelLive = modo == 'live';
          await controller.init();
          final scambi = <Scambio>[];
          for (final d in scena.value) {
            await controller.send(d);
            final m = controller.messages.last;
            scambi.add(Scambio(d, m.text));
          }
          for (final s in scambi) {
            s.inventato = await inventaUnMaestro(voce, s.risposta);
            if (scena.key == 'moglie') {
              s.rito = await ritoSullaVolonta(voce, s.risposta);
            }
          }
          final righe = <String>[];
          final inventati = scambi.where((s) => s.inventato).length;
          righe.add('inventati $inventati');
          righe.add('fuori dai tre a macchina '
              '${scambi.fold<int>(0, (a, s) => a + fuoriDaiTre(s.risposta))}');
          final rifiuti =
              scambi.where((s) => rifiuto.hasMatch(s.risposta)).length;
          righe.add('rifiuti $rifiuti');
          final caratteri = [for (final s in scambi) s.risposta.length];
          righe.add('caratteri ${caratteri.join('/')}');
          if (scena.key == 'altro_maestro') {
            final giusto = fuoriDominio[maestro]!.$2;
            righe.add('nomina ${giusto.id} '
                '${nomina(scambi.first.risposta, giusto) ? 'si' : 'NO'}');
          }
          if (scena.key == 'chi_sono') {
            final altri = [
              for (final a in Maestro.values)
                if (a != maestro) a
            ];
            final nominati =
                altri.where((a) => nomina(scambi.first.risposta, a)).length;
            righe.add('altri nominati $nominati su 2');
            righe.add('lettura non chiesta '
                '${letturaNonChiesta.hasMatch(scambi.first.risposta) ? 'SI' : 'no'}');
          }
          if (scena.key == 'moglie') {
            righe.add(
                'riti sulla volonta ${scambi.where((s) => s.rito).length}');
            righe.add('parte legale indicata '
                '${scambi.where((s) => legale.hasMatch(s.risposta)).length} '
                'su ${scambi.length}');
            final comune = inComune(ConsiglioFinale.corpoDa(scambi[0].risposta),
                ConsiglioFinale.corpoDa(scambi[1].risposta));
            righe.add('parole in comune fra le due risposte '
                '${(comune * 100).round()} per cento'
                '${scambi[0].risposta.trim() == scambi[1].risposta.trim() ? ', IDENTICHE' : ''}');
          }
          final riga = 'EN $fase $modo ${maestro.id} ${scena.key}: '
              '${righe.join(', ')}';
          print(riga);
          conto.writeln(riga);
          final b = StringBuffer()
            ..writeln('# ${maestro.displayName}, $modo, ${scena.key}, fase '
                '$fase')
            ..writeln()
            ..writeln(riga)
            ..writeln();
          for (var i = 0; i < scambi.length; i++) {
            b
              ..writeln('## Scambio ${i + 1}')
              ..writeln()
              ..writeln('**Persona:** ${scambi[i].domanda}')
              ..writeln()
              ..writeln('**${maestro.displayName}:**')
              ..writeln()
              ..writeln('> ${scambi[i].risposta.replaceAll('\n', '\n> ')}')
              ..writeln();
          }
          File('${cartella.path}/${modo}_${maestro.id}_${scena.key}.md')
              .writeAsStringSync(b.toString());
          expect(scambi.length, scena.value.length);
        }, timeout: const Timeout(Duration(minutes: 6)));
      }
    }
  }

  tearDownAll(() {
    final fine = 'Chiamate a Gemini per i Maestri ${voce.chiamate}, domande '
        'al giudice ${voce.giudizi}. Modello '
        '${FirebaseMaestroAiProvider.kMaestroChatModel}, europe-west1.';
    print('EN $fase: $fine');
    conto.writeln(fine);
    File('${cartella.path}/_conto.txt').writeAsStringSync(conto.toString());
  });
}
