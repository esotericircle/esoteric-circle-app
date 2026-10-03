import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/chat/chi_di_dovere.dart';
import 'package:esoteric_circle/core/maestro/la_voce_non_si_confonde.dart';
import 'package:esoteric_circle/core/maestro/consiglio_finale.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/voce_del_maestro.dart';
import 'package:esoteric_circle/core/responsi/confine_del_responso.dart';
import 'package:esoteric_circle/services/ai/maestro_persona.dart';
import 'package:flutter_test/flutter_test.dart';

/// **I MAESTRI SI CONOSCONO PER NOME, NON RIFIUTANO UNA DOMANDA PER UN
/// DETTAGLIO, E NON DETTANO RITI SULLA VOLONTA' DI UN ALTRO.** Ordine EN voci
/// 04, 05, 07 e 08, 25 settembre 2026.
///
/// Il fondatore: *"C'è un problema sulle risposte : le leggi e te ne rendi
/// conto dagli screenshot."* Nelle catture Medora presenta *"il Maestro dei
/// Sentimenti"*, rifiuta in chat la domanda sulla moglie perche' *"esula dal
/// mio dominio"* e nel LIVE comincia a dettare un gesto per farla tornare;
/// Calìgo, a *"Chi sono gli altri maestri oltre a te?"*, risponde *"Non ti è
/// dato sapere"*.
///
/// **Qui si guarda l'istruzione che parte davvero**, quella che il provider
/// manda a Gemini: il collaudo con Gemini vero sta in `tool/collaudo_en.dart`
/// e le sue trascrizioni in `docs/collaudo/EN/risposte/`.
void main() {
  String istruzioneDi(Maestro m) => MaestroPersona.systemInstruction(
        maestro: m,
        profile: UserProfile.empty,
        memory: MaestroMemory.empty,
      );

  group('EN.04 ed EN.07, il cerchio per nome', () {
    test('ogni Maestro riceve il nome e le arti degli altri due', () {
      for (final m in Maestro.values) {
        final istr = istruzioneDi(m);
        for (final altro in Maestro.values) {
          final nome = VoceDelMaestro.nomeDetto(altro);
          expect(istr.contains('$nome (${altro.domainArtsPhrase}'), isTrue,
              reason: '${m.id} non riceve "$nome" con le sue arti: il '
                  'modello sa che esiste un Maestro giusto e non sa come si '
                  'chiama, ed e\' cosi\' che e\' nato "il Maestro dei '
                  'Sentimenti"');
        }
        expect(istr, contains('sono tre e soltanto tre'));
        expect(istr, contains('Non inventarne mai uno'));
        // Il genere di ciascuno: nel collaudo Aura ha scritto "Calìgo, la
        // Maestra che sa leggere".
        expect(
            istr, contains('Medora e Aura sono Maestre, Calìgo è un Maestro'));
      }
    });

    test('la domanda su chi sono i Maestri non apre una lettura', () {
      for (final m in Maestro.values) {
        final istr = istruzioneDi(m);
        expect(istr, contains('chi sono gli altri Maestri'));
        expect(istr, contains('non apre nessuna lettura'));
      }
      // E il consiglio finale, che dice SEMPRE, conosce l'eccezione: e' la
      // riga che aveva fatto chiudere Calìgo con Perthro.
      expect(ConsiglioFinale.istruzione,
          contains('chi sono gli altri Maestri, non c\'è un passo da dare'));
    });
  });

  group('EN.05, la domanda d\'amore e\' di Medora', () {
    test('la materia di Medora nomina l\'amore e la coppia', () {
      final materia = VoceDelMaestro.di(Maestro.medora).materia;
      expect(materia, contains('amore'));
      expect(materia, contains('coppia'));
      expect(materia, contains('sinastria'));
      // E gli altri due lo sanno, per indicarla: nel primo giro del collaudo
      // Aura ha detto che il cerchio "non parla di sentimenti o amore".
      for (final m in [Maestro.aura, Maestro.caligo]) {
        expect(istruzioneDi(m), contains('sono sue anche l\'amore'),
            reason: '${m.id} non sa che l\'amore e\' di Medora');
      }
    });

    test('nessun Maestro rifiuta tutta la domanda per un avvocato', () {
      for (final m in Maestro.values) {
        expect(istruzioneDi(m),
            contains('Una domanda non si rifiuta per un dettaglio'),
            reason: '${m.id}: il confine vieta le indicazioni legali, e senza '
                'questa riga il modello legge l\'avvocato come se la domanda '
                'intera fosse legale');
      }
    });
  });

  group('EN.08, la volonta\' di un\'altra persona e\' sua', () {
    test('il confine lo dice, e arriva a tutti e tre', () {
      final riga = ConfineDelResponso.nonSiPuoMai
          .where((r) => r.contains('volontà di un\'altra persona'))
          .toList();
      expect(riga, hasLength(1),
          reason: 'lo diceva la sola voce di Calìgo, e Medora nel LIVE ha '
              'cominciato a dettare un gesto per far tornare la moglie');
      for (final m in Maestro.values) {
        expect(istruzioneDi(m), contains(riga.single),
            reason: '${m.id} non riceve il divieto');
        // E che cosa dire al suo posto: nel collaudo Medora legava ancora
        // l'incontro alla Luna piena.
        expect(
            istruzioneDi(m),
            contains('nessun gesto, rito, lettera o momento '
                'del cielo fa tornare qualcuno'));
        expect(
            istruzioneDi(m), contains('non si lega mai a una fase della Luna'));
      }
    });
  });

  group('EN.08, a chi di dovere, sempre', () {
    const domanda = 'Mia moglie mi ha lasciato con l\'avvocato. Cosa posso '
        'fare per farla tornare?';
    const senza = 'Chiedile un incontro, uno solo, e accetta la risposta.\n'
        '✦ Stasera scrivi le tre cose che vuoi dirle.';

    test('la frase arriva, prima della riga d\'oro, con la voce di chi parla',
        () {
      for (final m in Maestro.values) {
        final detta = ChiDiDovere.conLaFrase(
            maestro: m, domanda: domanda, risposta: senza);
        expect(detta, contains('a un avvocato tuo'),
            reason: '${m.id}: la persona ha nominato l\'avvocato e la '
                'risposta non le dice a chi rivolgersi');
        expect(detta.indexOf('avvocato'), lessThan(detta.indexOf('✦')),
            reason: 'la frase va nel testo, non dopo la riga d\'oro');
        expect(LaVoceNonSiConfonde.paroleAltruiIn(m, detta), isEmpty,
            reason: '${m.id}: la frase porta le parole di un altro Maestro');
      }
    });

    test('non si aggiunge due volte, e non si aggiunge senza motivo', () {
      const con = 'Affidati al tuo avvocato per le carte. Parlale di persona.';
      expect(
          ChiDiDovere.conLaFrase(
              maestro: Maestro.medora, domanda: domanda, risposta: con),
          con);
      expect(
          ChiDiDovere.conLaFrase(
              maestro: Maestro.medora,
              domanda: 'Cosa mi dice il cielo oggi?',
              risposta: senza),
          senza);
      // Il medico e il denaro hanno la loro frase.
      expect(
          ChiDiDovere.conLaFrase(
              maestro: Maestro.aura,
              domanda: 'Il medico mi ha dato una terapia, che centro ascolto?',
              risposta: senza),
          contains('a un medico'));
      expect(
          ChiDiDovere.conLaFrase(
              maestro: Maestro.caligo,
              domanda: 'Ho un debito con mio fratello, che runa mi aiuta?',
              risposta: senza),
          contains('a un consulente di fiducia'));
    });
  });

  group('EN.06, chi chiede di riprovare riceve una risposta, non un guasto',
      () {
    test('nessun Maestro parla delle sue risposte da programma', () {
      // "Il mio sistema mi dice che ho già risposto" e "la risposta precedente
      // è stata inviata per errore", nel collaudo, a "Prova ancora".
      for (final m in Maestro.values) {
        expect(istruzioneDi(m), contains('sei un Maestro, non un programma'),
            reason: '${m.id} non sa che cosa fare quando gli chiedono di '
                'riprovare');
      }
    });
  });
}
