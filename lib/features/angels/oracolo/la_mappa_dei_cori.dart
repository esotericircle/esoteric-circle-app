import 'package:flutter/material.dart';

import '../../../core/angels/angel_catalog.dart';
import '../../../core/oracolo_angeli/i_ruoli_e_l_estrazione.dart';
import '../../../design_system/theme/maestro_palette.dart';
import '../../../design_system/tokens/color_tokens.dart';
import '../../../design_system/tokens/spacing_tokens.dart';
import '../../../design_system/tokens/typography_tokens.dart';

/// **IL COLPO D'OCCHIO DELL'ORACOLO: LA MAPPA DEI NOVE CORI.** Ordine GD voce
/// GD.12, 23 ottobre 2026.
///
/// Il fondatore: *"la prima cosa che l'utente vede del responso è doppia:
/// vede in colonna «fare, sentire, capire» e poi subito sotto con a fianco
/// gli angeli e poi in riquadro con una scala colorata che non serve a niente
/// e non aggiunge nulla, le stesse cose. Serve un restauro del responso e
/// inserimento di infografica che veramente dica qualcosa e abbia un valore
/// aggiunto"*. E il vincolo dello stesso giorno: l'infografica e' la stessa
/// dentro tutta la funzionalita' (stesa a una carta e a tre, assaggio
/// compreso).
///
/// **IL DATO VERO.** I 72 angeli stanno in nove cori di otto, e i nove cori
/// in tre sfere (la tradizione dello Pseudo-Dionigi, nell'ordine di Lenain,
/// *La Science cabalistique*, 1823, lo stesso del catalogo,
/// `AngelCatalog.choirs`): la prima sfera e' la piu' vicina al divino, la
/// terza la piu' vicina a chi chiede. La mappa accende i cori da cui vengono
/// le carte uscite, letti dagli angeli della lettura ([coriDi]), e la frase
/// sotto dichiara il conto ([frase]): da quante sfere e da quali cori. Nessun
/// numero e' scritto a mano: cambia con le carte.
///
/// **E' UN'ALTRA FORMA (legge del visivo dei Maestri)**: una griglia di tre
/// sfere per tre cori, coi segni dei cori dipinti dal fondatore
/// (`assets/img/simboli/sig_coro_*`, ordine GC, R8). Non sono le piste dei
/// semi della Stesa di Tarocchi ne' le ruote e le colonne dell'Oroscopo. Il
/// codice disegna solo cio' che e' funzionale: quale coro si accende e la
/// cornice della sfera.
///
/// LAPIDE: dall'ordine GC voce GC.18 qui stava `LaScalaDelResponso`, la
/// scala di luce che accendeva un gradino per carta: ripeteva la terna
/// fare, sentire, capire che il responso aveva appena scritto.
class LaMappaDeiCori extends StatelessWidget {
  const LaMappaDeiCori({
    super.key,
    required this.carte,
    required this.palette,
    this.chiuse = const {},
  });

  /// Le carte uscite; una sola nella stesa a una carta.
  final List<CartaDellOracolo> carte;

  final MaestroPalette palette;

  /// I ruoli chiusi dall'assaggio del Viandante: i loro cori restano spenti
  /// e la frase non li conta.
  final Set<RuoloDellAngelo> chiuse;

  /// Le tre sfere, coi loro nomi e il loro senso nella tradizione.
  static const List<({String nome, String senso})> sfere = [
    (nome: 'Prima sfera', senso: 'la più vicina al divino'),
    (nome: 'Seconda sfera', senso: 'quella che regge l\'ordine del creato'),
    (nome: 'Terza sfera', senso: 'la più vicina a te'),
  ];

  /// Il posto del coro nei nove, da 0 (Serafini) a 8 (Angeli).
  static int postoDel(AngelChoir c) =>
      AngelCatalog.choirs.indexWhere((x) => x.name == c.name);

  /// La sfera del coro, da 0 a 2.
  static int sferaDel(AngelChoir c) => postoDel(c) ~/ 3;

  /// Il segno dipinto del coro (`assets/img/simboli/`, ordine GC). Il
  /// catalogo chiama "Potenze" il coro che il file chiama "potesta", e
  /// scrive "Virtu'" con l'apostrofo.
  static String segnoDi(AngelChoir c) {
    final nome = switch (c.name) {
      'Potenze' => 'potesta',
      "Virtu'" => 'virtu',
      final altro => altro.toLowerCase(),
    };
    return 'assets/img/simboli/sig_coro_${nome}_v1.webp';
  }

  /// Il nome del coro con l'accento vero.
  static String nomeDel(AngelChoir c) => c.name.replaceAll("u'", 'ù');

  /// Le carte che contano: scoperte e non chiuse dall'assaggio.
  static List<CartaDellOracolo> contate(
          List<CartaDellOracolo> carte, Set<RuoloDellAngelo> chiuse) =>
      [
        for (final c in carte)
          if (!c.coperta && !chiuse.contains(c.ruolo)) c,
      ];

  /// I posti dei cori accesi, dagli angeli della lettura.
  static Set<int> coriDi(
          List<CartaDellOracolo> carte, Set<RuoloDellAngelo> chiuse) =>
      {for (final c in contate(carte, chiuse)) postoDel(c.angelo.choir)};

  static const List<String> _numeri = ['nessuna', 'una', 'due', 'tre'];

  /// **LA FRASE CHE DICHIARA IL DATO**, calcolata dalle carte.
  static String frase(
      List<CartaDellOracolo> carte, Set<RuoloDellAngelo> chiuse) {
    final c = contate(carte, chiuse);
    if (c.isEmpty) return '';
    final perSfera = <int, int>{};
    for (final x in c) {
      perSfera.update(sferaDel(x.angelo.choir), (n) => n + 1,
          ifAbsent: () => 1);
    }
    final cori = {for (final x in c) nomeDel(x.angelo.choir)}.toList();
    final dei = cori.length == 1
        ? 'dal coro dei ${cori.first}'
        : 'dai cori dei ${cori.sublist(0, cori.length - 1).join(', dei ')} '
            'e dei ${cori.last}';
    if (c.length == 1) {
      final s = sfere[sferaDel(c.first.angelo.choir)];
      return 'La tua carta viene $dei, nella ${s.nome.toLowerCase()}, '
          '${s.senso}.';
    }
    final principale =
        perSfera.entries.reduce((a, b) => b.value > a.value ? b : a);
    final s = sfere[principale.key];
    if (perSfera.length == 1) {
      return 'Le ${_numeri[c.length]} carte vengono tutte dalla '
          '${s.nome.toLowerCase()}, ${s.senso}: $dei.';
    }
    if (principale.value > 1) {
      return '${_maiuscola(_numeri[principale.value])} carte su '
          '${_numeri[c.length]} vengono dalla ${s.nome.toLowerCase()}, '
          '${s.senso}. I cori: ${cori.join(', ')}.';
    }
    return 'Le ${_numeri[c.length]} carte vengono da '
        '${_numeri[perSfera.length]} sfere diverse, $dei: la risposta tocca '
        'più livelli del cielo.';
  }

  static String _maiuscola(String s) => s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    final accesi = coriDi(carte, chiuse);
    final etichetta = TypographyTokens.etichetta()
        .copyWith(color: palette.goldSoft, letterSpacing: 1.2);
    return Container(
      key: const Key('oracolo_colpo_d_occhio'),
      padding: const EdgeInsets.all(SpacingTokens.sm),
      decoration: BoxDecoration(
        color: palette.deepest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
        border: Border.all(color: palette.goldSoft.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('DA QUALI CORI VENGONO LE TUE CARTE',
              textAlign: TextAlign.center, style: etichetta),
          const SizedBox(height: SpacingTokens.xs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var s = 0; s < 3; s++) ...[
                if (s > 0) const SizedBox(width: SpacingTokens.xs),
                Expanded(
                  child: _LaSfera(
                    key: Key('oracolo_sfera_$s'),
                    indice: s,
                    accesi: accesi,
                    palette: palette,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: SpacingTokens.xs),
          Text(frase(carte, chiuse),
              key: const Key('oracolo_frase_dei_cori'),
              textAlign: TextAlign.center,
              style: TypographyTokens.didascalia()
                  .copyWith(color: ColorTokens.textPrimary, height: 1.35)),
        ],
      ),
    );
  }
}

class _LaSfera extends StatelessWidget {
  const _LaSfera({
    super.key,
    required this.indice,
    required this.accesi,
    required this.palette,
  });

  final int indice;
  final Set<int> accesi;
  final MaestroPalette palette;

  static const double latoDelSegno = 30;

  @override
  Widget build(BuildContext context) {
    final accesa = [0, 1, 2].any((k) => accesi.contains(indice * 3 + k));
    return Container(
      padding: const EdgeInsets.symmetric(
          vertical: SpacingTokens.xs, horizontal: SpacingTokens.xxs),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusSm),
        border: Border.all(
            color: accesa
                ? palette.gold.withValues(alpha: 0.8)
                : palette.goldSoft.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(LaMappaDeiCori.sfere[indice].nome,
              textAlign: TextAlign.center,
              style: TypographyTokens.didascalia().copyWith(
                  color: accesa ? palette.goldSoft : ColorTokens.textSecondary,
                  height: 1.1)),
          const SizedBox(height: SpacingTokens.xxs),
          for (var k = 0; k < 3; k++) ...[
            _IlCoro(
              posto: indice * 3 + k,
              acceso: accesi.contains(indice * 3 + k),
              palette: palette,
            ),
          ],
        ],
      ),
    );
  }
}

class _IlCoro extends StatelessWidget {
  const _IlCoro({
    required this.posto,
    required this.acceso,
    required this.palette,
  });

  final int posto;
  final bool acceso;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    final coro = AngelCatalog.choirs[posto];
    return Padding(
      key: Key('oracolo_coro_della_mappa_$posto${acceso ? '_acceso' : ''}'),
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Opacity(
        opacity: acceso ? 1 : 0.28,
        child: Row(
          children: [
            SizedBox(
              width: _LaSfera.latoDelSegno,
              height: _LaSfera.latoDelSegno,
              child: Image.asset(LaMappaDeiCori.segnoDi(coro),
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.medium,
                  errorBuilder: (_, __, ___) => DecoratedBox(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: palette.gold.withValues(alpha: 0.6)))),
            ),
            const SizedBox(width: 4),
            // Il nome del coro su una riga: nella sfera stretta "Dominazioni"
            // si rimpicciolisce invece di andare a capo o uscire.
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(LaMappaDeiCori.nomeDel(coro),
                    maxLines: 1,
                    style: TypographyTokens.didascalia().copyWith(
                        color: acceso
                            ? palette.goldSoft
                            : ColorTokens.textSecondary,
                        fontWeight: acceso ? FontWeight.w600 : FontWeight.w400,
                        height: 1.1)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
