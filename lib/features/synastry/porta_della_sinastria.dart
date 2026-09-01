import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/astro/zodiac.dart';
import '../../core/maestro/maestro.dart';
import '../../core/synastry/vip_catalog.dart';
import '../../design_system/components/cosmos_background.dart';
import '../../design_system/components/vip_frame.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../design_system/components/titolo_che_non_si_rompe.dart';
import '../maestri/rotta_arte.dart';
import 'sinastria_gallery_screen.dart';
import 'sinastria_vip_screen.dart';
import '../../design_system/transizioni/passaggio_del_cerchio.dart';

/// LA PORTA DELLA SINASTRIA VIP. Ordine CA voce 01.
///
/// **Parole del fondatore:** "LA SINASTRIA VIP DEVE PARTIRE con la schermata
/// dove ci sono le 2 carte in alto dove l'utente puo' scegliere il VIP a destra
/// e a sinistra c'e' la carta dell'utente con titolo sopra La Tua
/// Compatibilita' con un VIP", e "le bolle di fai sinastria vip oppure calcola
/// il tuo gemello astrale VIP devono stare nella prima schermata che vede
/// l'utente e non nella schermata di scelta del vip".
///
/// **Cosa c'era prima.** L'arte apriva sulla galleria "Scegli il tuo VIP", e le
/// tre scelte vivevano dentro di lei, sopra il catalogo: chi entrava vedeva un
/// elenco di volti e doveva capire da solo cosa ci si facesse. La voce BZ.09
/// aveva messo le due carte in cima alla galleria; quest'ordine le sposta dove
/// vanno, cioe' in una schermata loro, e la galleria torna a fare una cosa
/// sola: scegliere un volto e restituirlo.
///
/// **LE TRE SCELTE STANNO IN FILA, E LA SCELTA E' DICHIARATA.** L'ordine lascia
/// a me la forma e chiede di dichiararla: il fondatore aveva proposto una
/// tendina "Scegli il tipo di sinastria", l'Architetto le tre voci visibili
/// tutte insieme. **Ho scelto la fila**, con la ragione dell'Architetto, che e'
/// misurabile: il gemello astrale non chiede di scegliere nessuno ed e' la
/// funzione piu' condivisibile dell'app; dietro una tendina costerebbe due
/// gesti e una parola che non promette niente, e una funzione virale che
/// chiede due gesti non e' piu' virale.
///
/// **Si rovescia con una riga**: [leTreScelteInFila] a falso e le stesse tre
/// voci diventano la tendina che il fondatore aveva in mente. Le due forme
/// vivono qui sotto, e nessuna delle due e' scritta due volte: leggono lo
/// stesso elenco.
class PortaDellaSinastria extends StatefulWidget {
  const PortaDellaSinastria({
    super.key,
    this.userSign,
    this.userName,
    this.userBirth,
  });

  final Zodiac? userSign;
  final String? userName;
  final DateTime? userBirth;

  /// **LA RIGA CHE ROVESCIA LA FORMA DELLE TRE SCELTE.** Vera: tre porte in
  /// fila, tutte visibili. Falsa: una tendina sola, "Scegli il tipo di
  /// sinastria", come il fondatore aveva proposto.
  static const bool leTreScelteInFila = true;

  static Route<void> route({
    Zodiac? userSign,
    String? userName,
    DateTime? userBirth,
  }) {
    return PassaggioDelCerchio.rotta<void>((_) => SogliaArte(
          id: 'synastry_vip',
          maestro: Maestro.medora,
          child: PortaDellaSinastria(
            userSign: userSign,
            userName: userName,
            userBirth: userBirth,
          ),
        ));
  }

  @override
  State<PortaDellaSinastria> createState() => _PortaDellaSinastriaState();
}

/// I tre modi di fare una sinastria, in un elenco solo: le due forme della
/// schermata lo leggono, e aggiungerne un quarto non chiede di toccare
/// nessuna delle due.
enum ModoDellaSinastria {
  conUnVip(
    'Sinastria con un VIP',
    'Il tuo cielo contro quello di un volto famoso',
    Icons.favorite_rounded,
  ),
  fraDueVip(
    'Confronta 2 VIP',
    'Scegli tu i due volti da mettere uno contro l\'altro',
    Icons.compare_arrows_rounded,
  ),
  gemelloAstrale(
    'Trova il tuo gemello astrale VIP',
    'Il volto famoso che porta il tuo stesso cielo',
    Icons.auto_awesome,
  );

  const ModoDellaSinastria(this.titolo, this.sotto, this.icona);

  final String titolo;
  final String sotto;
  final IconData icona;

  String get chiave => 'sinastria_modo_$name';
}

class _PortaDellaSinastriaState extends State<PortaDellaSinastria> {
  /// La prima casella: nulla vuol dire "sei tu", che e' il modo predefinito.
  Vip? _primo;

  /// La seconda casella, sempre un VIP, finche' non si sceglie e' vuota.
  Vip? _secondo;

  ModoDellaSinastria _modo = ModoDellaSinastria.conUnVip;

  MaestroPalette get _palette =>
      MaestroPalette.forKey(const ThemeKey.of(Maestro.medora));

  /// Apre la galleria perche' scelga un volto e lo RIPORTI indietro.
  ///
  /// **La galleria non apre piu' il responso da sola** quando la si chiama
  /// cosi': era quello il modo in cui la carta toccata e la carta cambiata
  /// potevano essere due carte diverse (voce CA.02). Qui chi chiede sa quale
  /// casella sta riempiendo, e la riempie lui.
  Future<void> _scegli({required bool perLaPrima}) async {
    final scelto = await Navigator.of(context).push<Vip>(
      SinastriaGalleryScreen.scegliUnVip(
        userSign: widget.userSign,
        userName: widget.userName,
        userBirth: widget.userBirth,
        titolo: perLaPrima
            ? 'Scegli il primo dei due VIP'
            : 'Scegli il VIP da confrontare',
      ),
    );
    if (scelto == null || !mounted) return;
    setState(() {
      if (perLaPrima) {
        _primo = scelto;
        _modo = ModoDellaSinastria.fraDueVip;
      } else {
        _secondo = scelto;
      }
    });
  }

  void _tornaATe() => setState(() {
        _primo = null;
        _modo = ModoDellaSinastria.conUnVip;
      });

  Future<void> _apriIlResponso() async {
    final secondo = _secondo;
    if (secondo == null) {
      await _scegli(perLaPrima: false);
      return;
    }
    if (!mounted) return;
    await Navigator.of(context).push(SinastriaVipScreen.route(
      vip: secondo,
      primoVip: _primo,
      userSign: widget.userSign,
      userName: widget.userName,
      userBirth: widget.userBirth,
    ));
  }

  Future<void> _scegliIlModo(ModoDellaSinastria modo) async {
    switch (modo) {
      case ModoDellaSinastria.conUnVip:
        setState(() {
          _primo = null;
          _modo = modo;
        });
        await _scegli(perLaPrima: false);
      case ModoDellaSinastria.fraDueVip:
        setState(() => _modo = modo);
        await _scegli(perLaPrima: true);
      case ModoDellaSinastria.gemelloAstrale:
        setState(() => _modo = modo);
        await Navigator.of(context).push(
          SinastriaGalleryScreen.route(
            userSign: widget.userSign,
            userName: widget.userName,
            userBirth: widget.userBirth,
            cercaSubitoIlGemello: true,
          ),
        );
    }
  }

  String get _dataTua {
    final d = widget.userBirth;
    if (d == null) return '';
    return '${d.day}.${d.month}.${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final palette = _palette;
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: palette.deepest.withValues(alpha: 0.35),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: palette.goldSoft),
        // **NESSUNA MISURA SCRITTA A MANO**, che sarebbe debito: il titolo
        // della barra prende il ruolo del titolo di sezione, e la misura la
        // decide il design system.
        title: TitoloCheNonSiRompe(
            testo: 'Sinastria VIP', stile: TypographyTokens.titoloSezione()),
        actions: const [AngoloDellaBarra()],
      ),
      body: CosmosBackground(
        seed: 17,
        showZodiac: false,
        child: SafeArea(
          child: ListView(
            key: const Key('sinastria_porta'),
            padding: const EdgeInsets.fromLTRB(SpacingTokens.lg, kToolbarHeight,
                SpacingTokens.lg, SpacingTokens.xxxl),
            children: [
              Text(
                _primo == null
                    ? 'La Tua Compatibilità con un VIP'
                    : 'La Compatibilità fra ${_primo!.name} e un VIP',
                key: const Key('sinastria_titolo_confronto'),
                textAlign: TextAlign.center,
                style: TypographyTokens.titoloSezione()
                    .copyWith(color: palette.goldSoft, height: 1.2),
              ),
              const SizedBox(height: SpacingTokens.md),
              _leDueCarte(palette),
              const SizedBox(height: SpacingTokens.md),
              _ilBottone(palette),
              const SizedBox(height: SpacingTokens.lg),
              if (PortaDellaSinastria.leTreScelteInFila)
                _treScelteInFila(palette)
              else
                _treScelteATendina(palette),
              if (_primo != null) ...[
                const SizedBox(height: SpacingTokens.md),
                Center(
                  child: TextButton.icon(
                    key: const Key('sinastria_torna_a_te'),
                    onPressed: _tornaATe,
                    style: TextButton.styleFrom(
                        foregroundColor: palette.goldSoft,
                        minimumSize: const Size.fromHeight(48)),
                    icon: const Icon(Icons.person_rounded, size: 18),
                    // Corpo e non maiuscoletto: una frase che va a capo
                    // in maiuscoletto diventa un muro di lettere larghe.
                    label: Text('Rimetti il tuo cielo al primo posto',
                        style: TypographyTokens.corpo()),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _leDueCarte(MaestroPalette palette) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _Casella(
            chiave: const Key('sinastria_carta_tua'),
            palette: palette,
            // **LA CARTA CHE SI TOCCA E' LA CARTA CHE CAMBIA. Voce CA.02.**
            // Nel responso il tocco su una delle due caselle tornava sempre
            // alla galleria del SECONDO, perche' la scelta la faceva la pila
            // del Navigator invece di chi toccava. Qui ogni casella sa quale
            // e', e chiede il volto per se'.
            onTocco: () => _scegli(perLaPrima: true),
            sotto: _primo == null ? 'Tu' : _primo!.name,
            ritratto: _primo == null
                ? VipFramedPortrait(
                    palette: palette,
                    name: widget.userName ?? 'Il tuo cielo',
                    date: _dataTua,
                    sign: widget.userSign?.symbol,
                  )
                : VipFramedPortrait(
                    palette: palette,
                    name: _primo!.name,
                    date: _primo!.note,
                    sign: _primo!.sign.symbol,
                    vipAsset: _primo!.fullPath,
                  ),
          ),
        ),
        Padding(
          // Il cuore sta all'altezza del ritratto e non della colonna: lo
          // spazio viene dal design system, non da un numero battuto qui.
          padding: const EdgeInsets.only(top: SpacingTokens.xxxl),
          child:
              Icon(Icons.favorite_rounded, color: palette.goldSoft, size: 24),
        ),
        Expanded(
          child: _Casella(
            chiave: const Key('sinastria_carta_da_scegliere'),
            palette: palette,
            onTocco: () => _scegli(perLaPrima: false),
            sotto: _secondo?.name ?? 'Scegli il VIP',
            ritratto: _secondo == null
                ? VipFramedPortrait(
                    palette: palette,
                    name: 'Scegli il VIP',
                    date: '',
                    sign: '?',
                  )
                : VipFramedPortrait(
                    palette: palette,
                    name: _secondo!.name,
                    date: _secondo!.note,
                    sign: _secondo!.sign.symbol,
                    vipAsset: _secondo!.fullPath,
                  ),
          ),
        ),
      ],
    );
  }

  Widget _ilBottone(MaestroPalette palette) {
    final pronto = _secondo != null;
    return Center(
      child: FilledButton.icon(
        key: const Key('sinastria_fai_il_confronto'),
        onPressed: _apriIlResponso,
        style: FilledButton.styleFrom(
          backgroundColor: pronto ? palette.gold : palette.surfaceElevated,
          foregroundColor: pronto ? palette.deepest : palette.goldSoft,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
            side: BorderSide(color: palette.goldSoft.withValues(alpha: 0.6)),
          ),
        ),
        icon: const Icon(Icons.auto_awesome, size: 18),
        label: Text(
          pronto ? 'Scopri la compatibilità' : 'Scegli il VIP',
          style: TypographyTokens.titoloScheda(),
        ),
      ),
    );
  }

  Widget _treScelteInFila(MaestroPalette palette) {
    return Column(
      key: const Key('sinastria_tre_scelte'),
      children: [
        for (final modo in ModoDellaSinastria.values) ...[
          _PortaDelModo(
            chiave: Key(modo.chiave),
            modo: modo,
            palette: palette,
            attivo: modo == _modo,
            onTocco: () => _scegliIlModo(modo),
          ),
          const SizedBox(height: SpacingTokens.sm),
        ],
      ],
    );
  }

  /// La forma che il fondatore aveva proposto: una tendina sola. Vive qui
  /// accanto all'altra e legge lo stesso elenco, cosi' la scelta della forma
  /// resta una riga e non una riscrittura.
  Widget _treScelteATendina(MaestroPalette palette) {
    return Column(
      key: const Key('sinastria_tre_scelte'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Scegli il tipo di sinastria',
            style: TypographyTokens.etichetta()
                .copyWith(color: palette.goldSoft, letterSpacing: 1.1)),
        const SizedBox(height: SpacingTokens.xs),
        DecoratedBox(
          decoration: BoxDecoration(
            color: palette.surfaceElevated,
            borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
            border: Border.all(color: palette.goldSoft.withValues(alpha: 0.5)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.md),
            child: DropdownButton<ModoDellaSinastria>(
              key: const Key('sinastria_tendina_modo'),
              value: _modo,
              isExpanded: true,
              underline: const SizedBox.shrink(),
              dropdownColor: palette.surfaceElevated,
              iconEnabledColor: palette.goldSoft,
              items: [
                for (final modo in ModoDellaSinastria.values)
                  DropdownMenuItem(
                    key: Key(modo.chiave),
                    value: modo,
                    child: Text(modo.titolo,
                        style: TypographyTokens.corpo()
                            .copyWith(color: ColorTokens.textPrimary)),
                  ),
              ],
              onChanged: (m) => m == null ? null : _scegliIlModo(m),
            ),
          ),
        ),
      ],
    );
  }
}

/// Una delle due caselle: il ritratto, il nome sotto, e il tocco che riempie
/// QUESTA casella e non l'altra.
class _Casella extends StatelessWidget {
  const _Casella({
    required this.chiave,
    required this.palette,
    required this.ritratto,
    required this.sotto,
    required this.onTocco,
  });

  final Key chiave;
  final MaestroPalette palette;
  final Widget ritratto;
  final String sotto;
  final VoidCallback onTocco;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: chiave,
      onTap: onTocco,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          ritratto,
          const SizedBox(height: SpacingTokens.xs),
          Text(
            sotto,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style:
                TypographyTokens.etichetta().copyWith(color: palette.goldSoft),
          ),
        ],
      ),
    );
  }
}

/// Una delle tre porte, alta e col bordo d'oro: la stessa forma che le due
/// funzioni virali avevano nella galleria, portata qui.
class _PortaDelModo extends StatelessWidget {
  const _PortaDelModo({
    required this.chiave,
    required this.modo,
    required this.palette,
    required this.attivo,
    required this.onTocco,
  });

  final Key chiave;
  final ModoDellaSinastria modo;
  final MaestroPalette palette;
  final bool attivo;
  final VoidCallback onTocco;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: chiave,
      onTap: onTocco,
      behavior: HitTestBehavior.opaque,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color:
              palette.surfaceElevated.withValues(alpha: attivo ? 0.95 : 0.65),
          borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
          border: Border.all(
              color: palette.goldSoft.withValues(alpha: attivo ? 0.9 : 0.4),
              width: attivo ? 1.6 : 1),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: SpacingTokens.md, vertical: SpacingTokens.md),
          child: Row(
            children: [
              Icon(modo.icona, color: palette.goldSoft, size: 22),
              const SizedBox(width: SpacingTokens.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(modo.titolo,
                        style: TypographyTokens.titoloScheda()
                            .copyWith(color: palette.goldSoft)),
                    const SizedBox(height: SpacingTokens.xxs),
                    Text(modo.sotto,
                        style: TypographyTokens.etichetta()
                            .copyWith(color: ColorTokens.textSecondary)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: palette.goldSoft.withValues(alpha: 0.7)),
            ],
          ),
        ),
      ),
    );
  }
}
