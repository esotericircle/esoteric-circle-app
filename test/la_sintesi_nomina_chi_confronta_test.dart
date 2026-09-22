import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/maestro/consult_depth.dart';
import 'package:esoteric_circle/core/maestro/la_sintesi_nomina_chi_confronta.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_reply.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/core/responsi/anatomia_del_responso.dart';
import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:esoteric_circle/services/ai/maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/maestro_oracle.dart';
import 'package:esoteric_circle/services/ai/registro_dei_guasti.dart';
import 'package:esoteric_circle/services/ai/voce_sorvegliata.dart';
import 'package:flutter_test/flutter_test.dart';

/// **LA SINTESI DEL CONSIGLIO NOMINA CHI CONFRONTA.** Ordine EE voce 10,
/// 23 settembre 2026.
///
/// **Il testo del primo caso e' quello vero della cattura del fondatore**,
/// non uno inventato per far cadere la guardia: e' la sintesi che gli e'
/// arrivata a video sul Consiglio del 23 settembre, che dice quattro volte
/// "tutti e tre dicono la stessa cosa" e non chiama per nome nessuno dei tre.
///
/// **La rete e' un ritentativo, non un cancello**, perche' il difetto e' raro:
/// il collaudo, mossa 17, ha rifatto quella sintesi sette volte con lo stesso
/// materiale e ha avuto sette volte tre nomi su tre.
void main() {
  const laSintesiDellaCattura =
      'Le letture convergono su un momento di raccolto. Tutti gli sguardi '
      'sottolineano il valore del lavoro fatto insieme. Si evidenzia la '
      'maestria di chi ha costruito con pazienza. La Ruota della Fortuna, '
      'per tutti, segna un ciclo che si rinnova.';

  const iTre = [Maestro.medora, Maestro.caligo, Maestro.aura];

  group('Il controllo puro', () {
    test('la sintesi vera della cattura non nomina nessuno dei tre', () {
      expect(
        LaSintesiNominaChiConfronta.nominatiIn(iTre, laSintesiDellaCattura),
        isEmpty,
      );
      expect(
        LaSintesiNominaChiConfronta.nonNominaNessuno(
            iTre, laSintesiDellaCattura),
        isTrue,
      );
    });

    test('una sintesi che confronta davvero passa, e ne bastano due', () {
      const confronta =
          'Medora guarda al riconoscimento del lavoro, Caligo all\'espansione '
          'che ne segue. Dove concordano, ascolta con più fiducia.';
      expect(
        LaSintesiNominaChiConfronta.nominatiIn(iTre, confronta),
        [Maestro.medora, Maestro.caligo],
      );
      expect(
        LaSintesiNominaChiConfronta.nonNominaNessuno(iTre, confronta),
        isFalse,
        reason: 'due nomi su tre sono due termini da confrontare: pretenderne '
            'tre farebbe richiedere una sintesi buona',
      );
    });

    test('sotto i due sguardi non c\'è confronto, e non si giudica', () {
      expect(
        LaSintesiNominaChiConfronta.nonNominaNessuno(
            const [Maestro.medora], 'Le carte parlano di un ciclo.'),
        isFalse,
      );
    });

    test('a parità di nomi vince la prima, che la persona avrebbe avuto', () {
      const a = 'Medora dice una cosa.';
      const b = 'Caligo dice un\'altra cosa.';
      expect(LaSintesiNominaChiConfronta.laPiuNominata(iTre, a, b), a);
      expect(
        LaSintesiNominaChiConfronta.laPiuNominata(
            iTre, a, 'Medora e Caligo si incontrano.'),
        'Medora e Caligo si incontrano.',
      );
    });
  });

  group('La rete dentro la sorveglianza', () {
    test('una sintesi senza nomi si richiede una volta sola', () async {
      final voce = _VoceDiProva([
        laSintesiDellaCattura,
        'Medora guarda al lavoro, Caligo all\'espansione, Aura al respiro.',
      ]);
      final registro = RegistroDeiGuasti();
      final sorvegliata = VoceSorvegliata(voce: voce, registro: registro);

      final esito = await sorvegliata.synthesize(
        theme: 'Denaro e fortuna',
        lenses: _lenti(iTre),
      );

      expect(voce.chiamate, 2,
          reason: 'la rete deve aver richiesto, e una volta sola');
      expect(esito, contains('Medora'));
      expect(registro.guasti, isEmpty,
          reason: 'la seconda ha nominato: non c\'è niente da registrare');
    });

    test('una sintesi che nomina non si richiede', () async {
      final voce = _VoceDiProva([
        'Medora e Aura si incontrano sul valore del tempo.',
        'questa non deve mai uscire',
      ]);
      final sorvegliata =
          VoceSorvegliata(voce: voce, registro: RegistroDeiGuasti());

      final esito = await sorvegliata.synthesize(
        theme: 'Denaro e fortuna',
        lenses: _lenti(iTre),
      );

      expect(voce.chiamate, 1);
      expect(esito, contains('Medora'));
    });

    test('due volte senza nomi: passa la prima e il guasto resta scritto',
        () async {
      final voce = _VoceDiProva([
        laSintesiDellaCattura,
        'Anche la seconda parla di tutti gli sguardi e di nessuno.',
      ]);
      final registro = RegistroDeiGuasti();
      final sorvegliata = VoceSorvegliata(voce: voce, registro: registro);

      final esito = await sorvegliata.synthesize(
        theme: 'Denaro e fortuna',
        lenses: _lenti(iTre),
      );

      expect(voce.chiamate, 2);
      expect(esito, laSintesiDellaCattura, reason: 'a parità vince la prima');
      expect(registro.guasti, hasLength(1),
          reason: 'la persona legge un riassunto: noi dobbiamo saperlo');
      expect(registro.guasti.single.operazione, 'synthesize');
    });

    test('la seconda richiesta che non riesce non lascia senza sintesi',
        () async {
      final voce = _VoceDiProva([laSintesiDellaCattura], sollevaDopo: 1);
      final registro = RegistroDeiGuasti();
      final sorvegliata = VoceSorvegliata(voce: voce, registro: registro);

      final esito = await sorvegliata.synthesize(
        theme: 'Denaro e fortuna',
        lenses: _lenti(iTre),
      );

      expect(esito, laSintesiDellaCattura);
      expect(registro.guasti, isNotEmpty,
          reason: 'un guasto inghiottito qui non lo vede più nessuno');
    });
  });
}

List<MaestroLens> _lenti(List<Maestro> maestri) => [
      for (final m in maestri)
        MaestroLens.strati(
          maestro: m,
          glance: 'colpo d\'occhio di ${m.displayName}',
          reading: 'lettura di ${m.displayName}',
          invite: 'invito di ${m.displayName}',
        ),
    ];

/// Una voce che rende le sintesi di un elenco, una per chiamata.
class _VoceDiProva implements MaestroAiProvider {
  _VoceDiProva(this._sintesi, {this.sollevaDopo});

  final List<String> _sintesi;

  /// Dopo quante chiamate riuscite la voce comincia a sollevare.
  final int? sollevaDopo;

  int chiamate = 0;

  @override
  bool get isReady => true;

  @override
  Future<String> synthesize({
    required String theme,
    required List<MaestroLens> lenses,
    NatalContext? natal,
    UserProfile? profile,
  }) async {
    if (sollevaDopo != null && chiamate >= sollevaDopo!) {
      chiamate++;
      throw const MaestroAiUnavailable('la voce non ha risposto');
    }
    final testo = _sintesi[chiamate.clamp(0, _sintesi.length - 1)];
    chiamate++;
    return testo;
  }

  @override
  Future<String> reply({
    required Maestro maestro,
    required UserProfile profile,
    required MaestroMemory memory,
    required List<ChatMessage> history,
    required String userMessage,
    NatalContext natal = NatalContext.none,
    bool insistiSullAncoraggio = false,
    String? rispostaGiaData,
  }) async =>
      '';

  @override
  Future<MaestroReply> consult({
    required Maestro maestro,
    required String theme,
    required UserProfile profile,
    MaestroMemory memory = MaestroMemory.empty,
    NatalContext? natal,
    ConsultDepth depth = ConsultDepth.breve,
  }) async =>
      throw UnimplementedError();

  @override
  Future<Responso> presagioDelleRune({
    required EsitoGettata esito,
    required String domanda,
    required UserProfile profile,
  }) async =>
      throw UnimplementedError();

  @override
  Future<MemoryDigest?> distill({
    required Maestro maestro,
    required UserProfile profile,
    required MaestroMemory previous,
    required List<ChatMessage> history,
  }) async =>
      null;
}
