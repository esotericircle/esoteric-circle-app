import 'package:esoteric_circle/core/maestro/ancoraggio.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/maestro/frasi_dell_attesa.dart';
import 'package:esoteric_circle/core/maestro/lente_del_cielo.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/core/maestro/voce_del_maestro.dart';
import 'package:esoteric_circle/services/ai/maestro_persona.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

/// Lo stesso dato, tre lenti.
///
/// E' l'applicazione all'ancoraggio natale della regola che il Briefing Progetto
/// Definitivo dichiara alla sezione 8.1 per la memoria: "Stesso ricordo, tre
/// voci". La regola esisteva e all'ancoraggio non era applicata.
///
/// **Perche' e' stata applicata adesso.** Finche' del cielo parlava solo Medora,
/// il cielo era la sua firma. Rendere l'ancoraggio obbligatorio per tutti e tre
/// gliel'ha tolta: l'attribuzione cieca e' scesa da 98,3 a 95,0, con Medora che
/// perde verso Aura e non verso Caligo, che il simbolo teneva distinto.
void main() {
  const luna = Ancoraggio(nome: 'segno lunare', valore: 'Cancro');

  test('Ogni Maestro ha la sua lente, e sono tre', () {
    final lenti = <LenteDelMaestro>{};
    for (final maestro in Maestro.values) {
      lenti.add(VoceDelMaestro.di(maestro).lente);
    }
    expect(lenti.length, Maestro.values.length,
        reason: 'due Maestri con la stessa lente direbbero il dato allo '
            'stesso modo, ed e\' il difetto che questa voce corregge');
  });

  test('La lente e\' quella giusta per la materia di ciascuno', () {
    const atteso = {
      Maestro.medora: LenteDelMaestro.motoNelTempo,
      Maestro.aura: LenteDelMaestro.effettoNelCorpo,
      Maestro.caligo: LenteDelMaestro.simbolo,
    };
    for (final maestro in Maestro.values) {
      expect(VoceDelMaestro.di(maestro).lente, atteso[maestro],
          reason: 'il tempo e\' di chi legge il cielo, il corpo di chi legge '
              'il respiro, il simbolo di chi legge i segni');
    }
  });

  test('Le tre rese dello stesso dato non sono intercambiabili', () {
    final rese = <String>{};
    for (final maestro in Maestro.values) {
      rese.add(LenteDelCielo.battuta(maestro, luna));
    }
    expect(rese.length, Maestro.values.length,
        reason: 'tre rese uguali sono una resa sola');
  });

  // IL VINCOLO CHE EVITA IL DANNO COLLATERALE PIU' CARO DI TUTTI.
  //
  // `VerificaAncoraggio` cerca il valore LETTERALE nella risposta. Se una lente
  // parlasse per immagini senza nominare il corpo, il controllo scatterebbe su
  // ogni risposta e ognuna verrebbe rigenerata: costo doppio su tutta la chat,
  // per una regola nostra.
  test('La lente CONTIENE il nome del corpo, non lo sostituisce', () {
    for (final maestro in Maestro.values) {
      final resa = LenteDelCielo.battuta(maestro, luna);
      expect(resa, contains('Luna'),
          reason: '${maestro.id} non nomina il corpo');
      expect(resa, contains(luna.valore),
          reason: '${maestro.id} non nomina il valore "${luna.valore}", '
              'quindi il controllo dell\'ancoraggio scatterebbe e ogni '
              'risposta verrebbe rigenerata');
    }
  });

  test('Vale su tutti i tipi di ancoraggio che si guardano nel cielo', () {
    // Enumerati, non campionati: un tipo scoperto sarebbe una rigenerazione a
    // ogni risposta di quella persona, e nessuno lo vedrebbe.
    const ancoraggi = [
      Ancoraggio(nome: 'ascendente', valore: 'Vergine'),
      Ancoraggio(nome: 'segno lunare', valore: 'Pesci'),
      Ancoraggio(nome: 'segno solare', valore: 'Cancro'),
      Ancoraggio(nome: 'fase lunare di nascita', valore: 'Luna crescente'),
    ];
    for (final ancoraggio in ancoraggi) {
      for (final maestro in Maestro.values) {
        expect(LenteDelCielo.battuta(maestro, ancoraggio),
            contains(ancoraggio.valore),
            reason: '${maestro.id} perde il valore di ${ancoraggio.nome}');
      }
    }
  });

  test('L\'istruzione della lente entra nella persona, ed e\' diversa per i tre',
      () {
    const natal = NatalContext(sunSign: 'Cancro');
    final istruzioni = <String>{};
    for (final maestro in Maestro.values) {
      final persona = MaestroPersona.systemInstruction(
        maestro: maestro,
        profile: UserProfile.empty,
        memory: MaestroMemory.empty,
        natal: natal,
      );
      final lente = LenteDelCielo.istruzionePer(maestro);
      expect(persona, contains(lente),
          reason: '${maestro.id} non riceve la sua lente, quindi dice il '
              'cielo come lo dicono gli altri');
      istruzioni.add(lente);
    }
    expect(istruzioni.length, Maestro.values.length);
  });

  test('Senza ancoraggi la lente non entra: non c\'e\' niente da guardare', () {
    final persona = MaestroPersona.systemInstruction(
      maestro: Maestro.medora,
      profile: UserProfile.empty,
      memory: MaestroMemory.empty,
    );
    expect(persona.contains(LenteDelCielo.istruzionePer(Maestro.medora)),
        isFalse,
        reason: 'istruire su come guardare un dato che non esiste porterebbe '
            'a inventarlo');
  });

  test('Le frasi dell attesa portano il mestiere del Maestro', () {
    // Lo STESSO dato guardato da tre mestieri diversi: Medora ci legge il moto
    // nel tempo, Aura l'effetto nel corpo, Caligo il simbolo. La prima riga di
    // ciascuno deve quindi essere diversa dalle altre due.
    const natal = NatalContext(sunSign: 'Cancro', moonSign: 'Pesci');
    final prime = <String>{};
    for (final maestro in Maestro.values) {
      final frasi = FrasiDellAttesa.per(maestro,
          natal: natal, memoria: MaestroMemory.empty);
      expect(frasi, isNotEmpty);
      prime.add(frasi.first);
    }
    expect(prime.length, Maestro.values.length,
        reason: 'la scena deve dire il dato col mestiere di chi consulta');
  });
}
