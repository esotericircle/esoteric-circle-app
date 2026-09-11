import 'package:flutter/material.dart';

import '../../../core/angels/guardian_angels.dart';
import '../../../core/assets/family_image.dart';
import '../../../core/astro/birth_details.dart';
import '../../../core/astro/night_sky.dart';
import '../../../core/identity/birth_identity.dart';
import '../../../core/rituals/guide_animal_derivation.dart';
import '../../../core/rituals/animal_catalog.dart';
import '../../../core/viaggio/il_nome_si_puo_dire.dart';
import '../../maestri/caligo/viaggio/la_lente_che_scopre.dart';
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
    final segno = NightSky.sunSign(details.dateTime);
    final animale = GuideAnimalDerivation.forSign(segno);

    return Column(
      key: const Key('carta_compagni'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('CHI TI ACCOMPAGNA',
            style: TypographyTokens.label(size: 13)
                .copyWith(color: palette.goldSoft, letterSpacing: 3)),
        const SizedBox(height: SpacingTokens.sm),
        _TesseraDellAnimale(animale: animale, palette: palette),
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
class _TesseraDellAnimale extends StatefulWidget {
  const _TesseraDellAnimale({required this.animale, required this.palette});

  final GuideAnimal animale;
  final MaestroPalette palette;

  @override
  State<_TesseraDellAnimale> createState() => _TesseraDellAnimaleState();
}

class _TesseraDellAnimaleState extends State<_TesseraDellAnimale> {
  /// **NASCE CHIUSA.** Finche' l'archivio non ha risposto il nome non si dice:
  /// un lampo del nome giusto seguito dall'ombra sarebbe la rivelazione fatta
  /// male, non la rivelazione evitata.
  bool _siPuoDire = false;

  @override
  void initState() {
    super.initState();
    IlNomeSiPuoDire.chiedendoloAllArchivio(widget.animale.name).then((si) {
      if (mounted && si) setState(() => _siPuoDire = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    return DepthCard(
      key: const Key('carta_animale_guida'),
      raised: true,
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: _siPuoDire
                ? _Miniatura(
                    path: widget.animale.thumbPath,
                    ripiego: Icons.pets,
                    palette: palette,
                    // Piu' grande di prima: contenuto invece che ritagliato,
                    // in 44 px il totem diventava un francobollo illeggibile.
                    larghezza: 64,
                  )
                // **LA SUA OMBRA, non una sagoma generica**: la stessa che si
                // incontrera' scendendo, e la stessa che mostra il Passaporto.
                : OmbraDellAnimale(
                    key: const Key('carta_animale_in_ombra'),
                    immagine: widget.animale.ombraPath,
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
                  _siPuoDire
                      ? widget.animale.name
                      : IlNomeSiPuoDire.alPostoDelNome,
                  key: const Key('carta_animale_nome'),
                  style: TypographyTokens.titoloScheda(),
                ),
                if (!_siPuoDire)
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
