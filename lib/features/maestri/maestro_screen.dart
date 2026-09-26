import 'dart:async';
import '../../core/arts/le_arti_del_giorno.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../shell/spazio_della_barra.dart';
import 'widgets/striscia_altre_arti.dart';

// La striscia e il suo criterio vivevano qui: le prove nate allora li
// importano da qui, e l'export tiene fede a quegli import senza dare al
// codice una seconda copia.
export 'widgets/striscia_altre_arti.dart'
    show StrisciaAltreArti, artiDaScoprire, maestroDellArte, rottaDiProva;

import '../../core/arts/art_catalog.dart';
import '../../core/arts/gli_sfondi_delle_schede.dart';
import '../../core/arts/l_ordine_dei_domini.dart';
import '../schede/la_luce_delle_schede.dart';
import '../schede/la_riga_delle_schede.dart';
import '../schede/la_scheda_dell_arte.dart';
import '../../core/chat/immersive_intents.dart';
import '../../core/config/app_flags.dart';
import '../../core/entitlement/plan_catalog.dart';
import '../../core/lang/euphonic.dart';
import '../../core/identity/profile_controller.dart';
import '../../core/maestro/maestro.dart';
import '../../design_system/components/section_title.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../services/app_services.dart';
import 'art_navigation.dart';
import 'chat/maestro_chat_screen.dart';
import 'widgets/busto_del_maestro.dart';
import '../../design_system/components/titolo_che_non_si_spezza.dart';
import '../../core/primo_uso/suggerimenti_di_zona.dart';
import '../../design_system/components/suggerimento_al_primo_uso.dart';
import '../../design_system/transizioni/velo_del_cerchio.dart';

/// Sezione di un Maestro.
///
/// In C1 e' una schermata di dominio navigabile: intestazione cerimoniale del
/// Maestro e le sue funzioni nei tre stati. Le esperienze vere (chat, oracoli,
/// avatar animati) arrivano nei checkpoint successivi.
///
/// Niente qui e' cablato su un Maestro: pilastri, sottocategorie, stati di
/// apertura e conteggi nascono tutti dal catalogo, quindi la stessa struttura
/// vale identica per Medora, Aura e Caligo.
class MaestroScreen extends StatefulWidget {
  const MaestroScreen({
    super.key,
    required this.maestro,
    this.demo = AppFlags.isDemo,
  });

  final Maestro maestro;

  /// La vista: quella Demo per gli investitori mostra tutto il piano, quella
  /// della persona si ferma alla soglia delle fasi. Iniettabile per i test.
  final bool demo;

  @override
  State<MaestroScreen> createState() => _MaestroScreenState();
}

class _MaestroScreenState extends State<MaestroScreen> {
  @override
  Widget build(BuildContext context) {
    final sezioni = LOrdineDeiDomini.di(widget.maestro);
    final inArrivo =
        LOrdineDeiDomini.inArrivo(widget.maestro, demo: widget.demo);

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                SpacingTokens.lg,
                SpacingTokens.lg,
                SpacingTokens.lg,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // **LA ZONA SI PRESENTA, la prima volta e una sola.**
                  // Ordine CE voce 12. Sta qui in cima e dentro la
                  // colonna, non sopra di essa: cosi' tutto quello che c'e'
                  // sotto resta toccabile mentre si legge.
                  const SuggerimentoAlPrimoUso(zona: ZonaDelCerchio.dominio),
                  // In cima la presenza del Maestro: il nome e i tre pilastri
                  // del dominio stanno gia' nella barra, quindi qui nessuna
                  // carta identitaria ridondante. IL BUSTO DALLA PORTA UNICA,
                  // ordine I voce 1: la figura intera in alto non esiste piu',
                  // e la grandezza e' quella canonica della Stesa.
                  BustoDelMaestro(maestro: widget.maestro),
                  const SizedBox(height: SpacingTokens.md),
                  // Poi il titolo del dominio, poi l'azione principale.
                  SectionTitle(
                    title: 'Le Arti di ${widget.maestro.displayName}',
                    subtitle:
                        'Il suo dominio, dalle arti vive a quelle in cammino.',
                  ),
                  const SizedBox(height: SpacingTokens.md),
                  // Una sola voce per la conversazione: la chat, dove si dialoga
                  // e dove il confronto a piu' voci vive dentro l'esperienza.
                  _ConsultaMaestroCard(maestro: widget.maestro),
                  const SizedBox(height: SpacingTokens.lg),
                ],
              ),
            ),
          ),
          // **LE SEZIONI SONO RIGHE DI SCHEDE. Ordine EO voce 10.** Il
          // fondatore: *"Nei domini le arti usano la scheda delle voci da
          // EO.02 a EO.07"*, e l'ordine di sezioni e schede e' il suo
          // (`LOrdineDeiDomini`), anche contro la regola che metteva prima le
          // sezioni con arti vive. **Il formato lo sceglie Code**: verticale,
          // come le locandine, perche' in un dominio si sceglie fra poche arti
          // della stessa famiglia e la scheda alta le fa leggere per prime.
          SliverToBoxAdapter(
            child: LaLuceDelleSchede(
              child: Column(
                key: const Key('dominio_righe'),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final s in sezioni)
                    LaRigaDelleSchede(
                      chiave: 'dominio_${s.titolo.toLowerCase()}',
                      titolo: s.titolo,
                      formato: FormatoDellaScheda.verticale,
                      arti: LOrdineDeiDomini.artiDi(s, demo: widget.demo),
                      maestroDi: (_) => widget.maestro,
                      mostraFase: widget.demo,
                    ),
                  // **LA RIGA "IN ARRIVO", ordine EO voce 13**: le arti del
                  // Maestro che non stanno nelle sezioni, con lo sfondo del
                  // Maestro senza emblema e l'icona dell'arte in oro.
                  if (inArrivo.isNotEmpty)
                    LaRigaDelleSchede(
                      chiave: 'dominio_in_arrivo',
                      titolo: 'In arrivo',
                      formato: FormatoDellaScheda.quadrata,
                      arti: inArrivo,
                      maestroDi: (_) => widget.maestro,
                      sfondoDelMaestro: true,
                      mostraFase: widget.demo,
                    ),
                ],
              ),
            ),
          ),
          // In fondo, oltre il dominio del Maestro, il ponte al cerchio
          // condiviso: le arti degli altri Maestri.
          SliverToBoxAdapter(
            child: StrisciaAltreArti(corrente: widget.maestro),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: SpacingTokens.xxxl),
          ),
          // La coda che riporta l'ultima carta sopra la barra: prima l'ultimo
          // elemento si fermava sotto la barra visibile, e si leggeva solo
          // quando la barra si era ritirata.
          const SliverSpazioDellaBarra(),
        ],
      ),
    );
  }
}

// **LAPIDE: qui viveva `_ArtSectionBox`**, il riquadro di una
// sottocategoria con le card a riga, il contatore e i collassi delle arti in
// cammino. Dall'ordine EO voce 10 le sezioni del dominio sono righe di
// schede, e le arti in cammino hanno la loro riga "In arrivo" in fondo.

/// Un'arte del cerchio nella striscia "Scopri altre arti del Cerchio": il
/// Maestro a cui appartiene, la funzione immersiva che apre, l'icona e il nome.
/// Un'arte della striscia del cerchio, col Maestro a cui appartiene.
///
/// Pubblica apposta, come il painter del sigillo: il colore della bolla e' una
/// cosa che un test deve poter misurare senza montare l'intero dominio con i
/// suoi servizi.
class CircleArt {
  const CircleArt({
    required this.maestro,
    required this.target,
    required this.icon,
    required this.title,
  });

  final Maestro maestro;
  final ImmersiveTarget target;
  final IconData icon;
  final String title;
}

/// Una tessera della striscia, nel colore del Maestro dell'arte. Al tocco apre
/// la funzione e vira il tema su quel Maestro, poi lo ripristina al ritorno.
class CircleArtTile extends StatelessWidget {
  const CircleArtTile({
    super.key,
    required this.art,
    required this.maestro,
    required this.palette,
  });

  /// L'arte, presa dal CATALOGO e non da una lista scritta a mano.
  final ArtEntry art;

  /// Il Maestro a cui l'arte appartiene, per il colore della tessera.
  final Maestro maestro;

  final MaestroPalette palette;

  Future<void> _open(BuildContext context) async {
    // **LA NASCITA VIAGGIA ANCHE DA QUI, e prima non viaggiava.**
    // Ordine DC voce 11, 10 settembre 2026.
    //
    // **Il fatto del fondatore**: la card "Angelo Custode personale" apriva
    // "I tuoi dati di nascita" dalla striscia in home, e "I tuoi tre Angeli"
    // dal dominio di Medora. Sembrava lo stesso nome con due destinazioni.
    //
    // **La causa era un'altra, e piu' larga del sintomo**: questa tessera
    // chiamava `artRouteFor` **senza la data di nascita**, mentre lo scaffale
    // del Maestro e il Santuario gliela passano. La mappa delle rotte e' una
    // sola e faceva il suo dovere: mandava a dare la data a chi, per quanto
    // ne sapeva, non ce l'aveva. **Non erano due destinazioni: era una porta
    // che arrivava a mani vuote.**
    //
    // Le arti colpite erano **sei e non una**: `guardian_angel`,
    // `guide_animal`, `horoscope`, `magic_sigil`, `rune_draw` e
    // `synastry_vip`, cioe' tutte quelle che senza la nascita non hanno
    // niente da calcolare.
    final profile = context.read<ProfileController>();
    final route = artRouteFor(
      art.id,
      userBirth:
          profile.identity.isExample ? null : profile.identity.birthMoment,
      userName: profile.hasName ? profile.vocative : null,
    );
    if (route == null) return;
    // Il puntino d'oro delle arti del giorno si spegne da qualunque porta
    // (ordine EP voce 06).
    LeArtiDelGiorno.istanza.aperta(art.id);
    // Nessun cambio di tema qui. Il colore dell'arte lo dichiara l'arte
    // stessa, tramite il proprietario del suo MaestroScope, quindi c'e' dal
    // primo frame da qualunque strada si arrivi.
    //
    // Prima il tema veniva virato QUI, cioe' in questa singola tessera: chi
    // apriva la stessa arte dallo scaffale del suo Maestro, dalla chat o da
    // una rotta diretta entrava col colore di chi stava guardando prima, e al
    // primo ingresso nell'app col neutro. Per di piu' il ripristino era
    // condizionato a `previous != null`, quindi partendo dal tema neutro il
    // colore dell'arte restava addosso al Cerchio anche dopo essere usciti.
    await Navigator.of(context).push(route);
  }

  @override
  Widget build(BuildContext context) {
    // Il colore del PROPRIETARIO dell'arte, non quello del dominio in cui la
    // striscia sta ne' quello del tema attivo. Prima le bolle erano tutte nel
    // viola condiviso: la striscia diceva a parole di chi fosse ogni arte, con
    // una scritta piccola sotto il nome, senza mostrarlo. Il colpo d'occhio
    // visivo viene prima del testo, quindi il proprietario si riconosce senza
    // leggere.
    //
    // Il fondo condiviso resta sotto, velato: la striscia continua a essere
    // una striscia sola, non tre strisce accostate.
    final propria = MaestroPalette.forKey(ThemeKey.of(maestro));
    return Material(
      color: Colors.transparent,
      child: InkWell(
        enableFeedback: false,
        key: Key('other_art_${art.id}'),
        onTap: () => _open(context),
        borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
        child: Container(
          // **CENTOTTANTOTTO, E IL NUMERO VIENE DALLA PAROLA PIU' LUNGA.**
          // Ordine CE voce 11. A centosettantadue restavano 138 punti di
          // contenuto, e "Astrocartografia" ne chiede 150 anche sceso al
          // pavimento dei tredici: piu' stretto di cosi', quella parola si
          // spezza a meta' comunque si faccia. Misurato, non stimato.
          width: 188,
          padding: const EdgeInsets.all(SpacingTokens.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                // Il colore del Maestro sopra il viola condiviso: si riconosce
                // il proprietario senza che la tessera urli.
                Color.alphaBlend(
                  propria.primary.withValues(alpha: 0.55),
                  palette.surfaceElevated,
                ).withValues(alpha: 0.92),
                Color.alphaBlend(
                  propria.primary.withValues(alpha: 0.22),
                  palette.surface,
                ).withValues(alpha: 0.78),
              ],
            ),
            border: Border.all(color: propria.gold.withValues(alpha: 0.45)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: propria.primary,
                  border:
                      Border.all(color: propria.gold.withValues(alpha: 0.75)),
                ),
                alignment: Alignment.center,
                child: Icon(art.icon, color: propria.goldSoft, size: 22),
              ),
              // **IL BLOCCO DEL NOME E' FLESSIBILE.** Ordine CE voce 11: la
              // striscia ha un'altezza fissa e il nome adesso puo' andare a
              // capo, quindi senza questo la colonna traboccherebbe. Succede
              // anche in prova, dove il carattere di ripiego e' molto piu'
              // largo di Cinzel e porta lo stesso nome a cinque righe.
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Il nome si adatta a scendere invece di spezzarsi a meta'
                    // parola: "Meditazione" e' una parola sola e in Cinzel, che e'
                    // tutto maiuscolo, andava a capo male.
                    //
                    // **MA IL `FittedBox` SCENDEVA SENZA FONDO.** Ordine CE voce
                    // 11, misurato: qui dentro "Oroscopo Personalizzato"
                    // dichiarava sedici punti e ne veniva dipinto OTTO E SEI,
                    // cioe' quasi la meta', e "Estrazione Rune" tredici e sei.
                    // Nessuna prova poteva vederlo, perche' il testo c'e' tutto e
                    // la misura dichiarata e' giusta: si vede solo misurando
                    // quanto il disegno lo scala.
                    //
                    // `TitoloCheNonSiSpezza` fa la stessa cosa ma con un fondo:
                    // scende finche' la parola piu' lunga ci sta, non sotto
                    // tredici punti, e li' preferisce andare a capo che
                    // diventare illeggibile.
                    Flexible(
                      child: SizedBox(
                        width: double.infinity,
                        child: TitoloCheNonSiSpezza(
                          art.title,
                          allineamento: TextAlign.left,
                          minimo: 13,
                          // Due righe e non tre: la striscia ha un'altezza fissa,
                          // e tre nomi del catalogo ne prendevano tre.
                          righeMassime: 2,
                          stile: TypographyTokens.titoloDiRiga()
                              .copyWith(color: palette.textPrimary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(maestro.displayName,
                        style: TypographyTokens.etichetta().copyWith(
                          color: propria.goldSoft.withValues(alpha: 0.95),
                          letterSpacing: 0.6,
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// L'azione principale del dominio: una sola voce per la conversazione.
///
/// "Parla con" e "Consulta" erano due porte per la stessa cosa: qui restano una
/// sola, Consulta [Nome], che apre la chat. Il confronto a piu' voci non e'
/// orfano, vive dentro l'esperienza: dall'header della chat, col tasto della
/// bilancia, la stessa domanda va agli altri Maestri e torna con la sintesi.
class _ConsultaMaestroCard extends StatelessWidget {
  const _ConsultaMaestroCard({required this.maestro});

  final Maestro maestro;

  /// La scheda come voce: non sta nel catalogo, e non ha una rotta d'arte.
  static ArtEntry voce(Maestro maestro) => ArtEntry(
        id: 'consulta_${maestro.name}',
        title: 'Consulta ${maestro.displayName}',
        teaser: 'Dialoga, chiedi e metti a confronto gli sguardi del Cerchio.',
        icon: Icons.forum_outlined,
        state: ArtState.attiva,
      );

  /// **LA SCHEDA "CONSULTA" IN CIMA AL DOMINIO.** Ordine EP voce 12, 26
  /// settembre 2026. Il fondatore: *"Nel dominio di ogni maestro serve anche
  /// fare la scheda "Consulta [nome Maestro]"."*, e sulle immagini *"Ok,
  /// tutto ok."* Prima era un riquadro con l'icona della chat e due righe;
  /// ora e' una scheda come le altre del dominio (ordine EO voce 02), alla
  /// misura del dominio, con l'immagine del suo Maestro. **Orizzontale**: il
  /// fondatore, a ordine aperto, *"in ogni dominio, in alto ci devi mettere
  /// la scheda della chat orizzontale e non quadrata."* Il tocco apre la
  /// chat di quel Maestro.
  @override
  Widget build(BuildContext context) {
    final scala = MediaQuery.textScalerOf(context).scale(1);
    return KeyedSubtree(
      key: const Key('domain_consulta_card'),
      child: LaSchedaDellArte(
        art: voce(maestro),
        maestro: maestro,
        formato: FormatoDellaScheda.orizzontale,
        larghezza: LaSchedaDellArte.larghezzaPer(
            FormatoDellaScheda.orizzontale,
            scalaDelTesto: scala),
        sfondo: GliSfondiDelleSchede.consultaDi(maestro),
        onApri: (c) async {
          final services = c.read<AppServices>();
          await Navigator.of(c).push(
            MaestroChatScreen.route(maestro: maestro, services: services),
          );
        },
      ),
    );
  }
}

/// L'anticipo di un'arte non ancora apribile: dice con onesta' a che punto e' e
/// cosa dara', senza mai lasciare un vicolo cieco.
Future<void> showArtPreview(
  BuildContext context, {
  required ArtEntry art,
  required Maestro maestro,
}) {
  final palette = MaestroPalette.forKey(ThemeKey.of(maestro));
  // La fase e' un dato di piano: alla persona si dice soltanto che l'arte sta
  // arrivando, il dettaglio resta nella vista Demo per gli investitori.
  final fase = AppFlags.isDemo && art.phase != null
      ? ' La sua fase di lavorazione è ${art.phase}.'
      : '';
  final riga = art.state == ArtState.premium
      ? 'Questa arte è pronta e vive nel Cerchio: si apre '
          '${art.requiredTier == null ? 'con l\'abbonamento' : conPiano(PlanCatalog.forTier(art.requiredTier!).name)}.'
      : 'Questa arte è in cammino. Quando sarà pronta la troverai qui.$fase';
  return foglioDelCerchio<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => Container(
      key: const Key('art_preview'),
      padding: const EdgeInsets.fromLTRB(SpacingTokens.lg, SpacingTokens.md,
          SpacingTokens.lg, SpacingTokens.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [palette.surfaceElevated, palette.deepest],
        ),
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(SpacingTokens.radiusXl)),
        border: Border.all(color: palette.gold.withValues(alpha: 0.3)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(art.icon, color: palette.goldSoft, size: 24),
                const SizedBox(width: SpacingTokens.sm),
                Expanded(
                  child: Text(art.title,
                      style: TypographyTokens.titoloDiSchermata()
                          .copyWith(color: palette.goldSoft)),
                ),
              ],
            ),
            const SizedBox(height: SpacingTokens.sm),
            Text(art.teaser,
                style: TypographyTokens.corpo()
                    .copyWith(color: ColorTokens.textPrimary, height: 1.4)),
            const SizedBox(height: SpacingTokens.sm),
            Text(riga,
                style: TypographyTokens.corpo()
                    .copyWith(color: ColorTokens.textSecondary, height: 1.4)),
            // LA CORNICE ONESTA E' USCITA DA QUI, ed era uno dei SETTE
            // disclaimer a schermo. Le linee guida dicevano da sempre
            // "una volta sola", e per sette volte ognuno ha pensato
            // che il proprio fosse quella volta. Adesso sta in un
            // posto solo, nell'area privacy.
            const SizedBox(height: SpacingTokens.lg),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(sheetContext).pop(),
                child: Text('Va bene',
                    style: TypographyTokens.label(size: 13)
                        .copyWith(color: palette.goldSoft)),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// **LAPIDE: qui viveva `_CardDelViaggio`**, la card che cambiava la
// promessa del Viaggio col Diario (ordini DE voce 02 e DQ voce 03). Dall'ordine
// EO voce 10 la promessa sta sul retro della scheda dell'arte
// (`la_scheda_dell_arte.dart`), letta dallo stesso Diario.
