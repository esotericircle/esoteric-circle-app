import 'package:flutter/material.dart';

import '../../../core/angels/guardian_angels.dart';
import '../../../core/assets/family_image.dart';
import '../../../core/astro/birth_details.dart';
import '../../../core/astro/zodiac.dart';
import '../../../core/identity/birth_identity.dart';
import '../../../core/rituals/animal_catalog.dart';
import '../../../core/viaggio/diario_dei_viaggi.dart';
import '../../../core/viaggio/il_nome_si_puo_dire.dart';
import '../../../core/viaggio/l_animale_di_potere.dart';
import '../../maestri/caligo/viaggio/l_ombra_dell_animale.dart';
import '../../../design_system/components/depth_card.dart';
import '../../angels/angelo_ingrandito.dart';
import '../../../design_system/theme/maestro_scope.dart';
import '../../../design_system/theme/maestro_palette.dart';
import '../../../design_system/tokens/color_tokens.dart';
import '../../../design_system/tokens/spacing_tokens.dart';
import '../../../design_system/tokens/typography_tokens.dart';
import '../../angels/angels_screen.dart';
import '../../../design_system/components/miniatura_intera.dart';

/// Chi accompagna la persona dalla nascita: l'Animale Guida e i tre Angeli.
///
/// Vive dentro la carta natale accanto a Sole, Luna, Ascendente e Numero della
/// Vita, perche' l'identita' di nascita e' una cosa sola e non va spezzata fra
/// schermate diverse. L'Animale Guida resta anche nel Passport, dove gia' era.
class BirthCompanions extends StatelessWidget {
  const BirthCompanions({
    super.key,
    required this.details,
    this.identity,
  });

  final BirthDetails details;

  /// L'identita' completa, quando c'e': serve solo ad aprire la schermata dei
  /// tre Angeli. Senza, le tessere restano leggibili ma non aprono nulla.
  final BirthIdentity? identity;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final triade = GuardianAngels.forBirth(details);
    final segno = details.segno;

    return Column(
      key: const Key('carta_compagni'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('CHI TI ACCOMPAGNA',
            style: TypographyTokens.label(size: 13)
                .copyWith(color: palette.goldSoft, letterSpacing: 3)),
        const SizedBox(height: SpacingTokens.sm),
        // **IL SEGNO, NON L'ANIMALE GIA' DERIVATO**, ordine FZ voce 01 e 02:
        // la tessera non puo' piu' ricevere un animale "suo" dal segno e
        // chiedere semplicemente se quel nome si puo' dire, perche' quel
        // nome potrebbe non essere affatto quello che il Viaggio
        // riconoscera'. Chiede lei stessa al Diario chi e' stato
        // riconosciuto, e il segno le serve solo per la migrazione una
        // tantum di chi aveva gia' concluso.
        _TesseraDellAnimale(segno: segno, palette: palette),
        const SizedBox(height: SpacingTokens.sm),
        DepthCard(
          key: const Key('carta_angeli'),
          raised: true,
          padding: const EdgeInsets.all(SpacingTokens.md),
          onTap: identity == null
              ? null
              : () => Navigator.of(context)
                  .push(AngelsScreen.route(identity: identity!)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('I tuoi Angeli',
                      style: TypographyTokens.etichetta()
                          .copyWith(color: palette.goldSoft, letterSpacing: 2)),
                  const Spacer(),
                  if (identity != null)
                    Icon(Icons.chevron_right_rounded, color: palette.goldSoft),
                ],
              ),
              const SizedBox(height: SpacingTokens.xs),
              // Una riga di volti, uno per angelo, col nome sotto il proprio.
              // Prima i tre stavano su una riga sola con i nomi accanto, e in
              // colonna stretta restava spazio per una miniatura soltanto:
              // il conto tornava nel codice, non sullo schermo.
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final a in triade.known)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: SpacingTokens.xs),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Ogni carta apre l'ingrandimento, LO STESSO che
                            // si apre dal trionfo: un secondo componente
                            // sarebbe due verita' che col tempo divergono.
                            Center(
                              child: GestureDetector(
                                key: Key('carta_angelo_${a.number}'),
                                behavior: HitTestBehavior.opaque,
                                onTap: () => AngeloIngrandito.apri(
                                  context,
                                  angelo: a,
                                  ruolo: RuoloAngelo.perIndice(
                                      triade.known.indexOf(a)),
                                ),
                                child: _Miniatura(
                                  path: FamilyImage.thumb(
                                      AssetFamily.angeli, a.artStem),
                                  ripiego: Icons.auto_awesome,
                                  palette: palette,
                                  larghezza: 62,
                                  // Due terzi: la proporzione di una carta.
                                  proporzione: 2 / 3,
                                ),
                              ),
                            ),
                            const SizedBox(height: SpacingTokens.xxs),
                            Text(
                              a.name,
                              style: TypographyTokens.corpo(),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              if (!triade.hasIntellect) ...[
                const SizedBox(height: SpacingTokens.xs),
                Text(
                  'Il terzo Angelo arriva con l\'ora di nascita.',
                  style: TypographyTokens.corpo()
                      .copyWith(color: ColorTokens.textMuted),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// La miniatura dei compagni di nascita passa dal COMPONENTE CONDIVISO.
///
/// Era una classe privata di questo file, giusta e invisibile agli altri: gli
/// altri quattro punti che mostrano le stesse immagini usavano `cover` e le
/// tagliavano. Un componente che risolve il difetto in un file solo non e' un
/// componente, e' una correzione locale.
typedef _Miniatura = MiniaturaIntera;

/// **LA TESSERA DELL'ANIMALE, e sa tacere.** Ordine DG voce 02,
/// 12 settembre 2026.
///
/// **Qui c'era il nome scritto a lettere intere**, accanto al totem a colori,
/// dentro la carta natale che si apre subito dopo la scheda che promette di
/// non svelarlo. La regola non era sbagliata da nessuna parte: **era scritta
/// in una schermata sola**, il Passaporto. Adesso sta in
/// `IlNomeSiPuoDire`, e questa tessera gliela chiede.
///
/// **Chiede all'archivio e non si accontenta di cio' che sa gia'**: e' una
/// scheda che si costruisce una volta e resta, quindi puo' aspettare, e una
/// risposta vera vale piu' di una risposta immediata.
///
/// **DALL'ORDINE FZ VOCE 01 E 02 NON RICEVE PIU' UN ANIMALE GIA' DERIVATO
/// DAL SEGNO**: riceve [segno] solo per la migrazione una tantum di chi
/// aveva gia' concluso, e chiede lei stessa al Diario chi e' stato davvero
/// riconosciuto. Chiedere "si puo' dire il nome di QUESTO animale" a un
/// animale indovinato dal segno avrebbe sempre risposto no, anche a
/// riconoscimento fatto, perche' il segno non decide piu' nessun animale.
class _TesseraDellAnimale extends StatefulWidget {
  const _TesseraDellAnimale({required this.segno, required this.palette});

  final Zodiac segno;
  final MaestroPalette palette;

  @override
  State<_TesseraDellAnimale> createState() => _TesseraDellAnimaleState();
}

class _TesseraDellAnimaleState extends State<_TesseraDellAnimale> {
  /// **NASCE CHIUSA.** Finche' l'archivio non ha risposto il nome non si dice:
  /// un lampo del nome giusto seguito dall'ombra sarebbe la rivelazione fatta
  /// male, non la rivelazione evitata.
  GuideAnimal? _animale;

  final DiarioDeiViaggi _diario = DiarioDeiViaggi();

  @override
  void initState() {
    super.initState();
    AnimaleDiPotere.caricaERisolvi(_diario, widget.segno).then((esito) {
      if (mounted) setState(() => _animale = esito.animale);
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    final animale = _animale;
    return DepthCard(
      key: const Key('carta_animale_guida'),
      raised: true,
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: animale != null
                ? _Miniatura(
                    path: animale.thumbPath,
                    ripiego: Icons.pets,
                    palette: palette,
                    // Piu' grande di prima: contenuto invece che ritagliato,
                    // in 44 px il totem diventava un francobollo illeggibile.
                    larghezza: 64,
                  )
                // **LA SAGOMA NEUTRA, non piu' "la sua"**: prima del
                // riconoscimento non c'e' nessun animale che sia "suo",
                // quindi nessuna sagoma specifica da velare.
                : OmbraDellAnimale(
                    key: const Key('carta_animale_in_ombra'),
                    immagine: AnimaleDiPotere.sagomaNonRivelata,
                    giaSagoma: true,
                    quantaLuce: 0.20 +
                        0.20 * IlNomeSiPuoDire.quanteDisceseNote.clamp(0, 3),
                  ),
          ),
          const SizedBox(width: SpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Animale guida',
                    style: TypographyTokens.etichetta()
                        .copyWith(color: palette.goldSoft, letterSpacing: 2)),
                Text(
                  animale != null
                      ? animale.name
                      : IlNomeSiPuoDire.alPostoDelNome,
                  key: const Key('carta_animale_nome'),
                  style: TypographyTokens.titoloScheda(),
                ),
                if (animale == null)
                  Text(IlNomeSiPuoDire.percheNonSiDice,
                      style: TypographyTokens.didascalia()
                          .copyWith(color: palette.goldSoft)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
