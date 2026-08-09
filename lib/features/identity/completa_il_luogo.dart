import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/astro/city_catalog.dart';
import '../../core/astro/natal_chart_controller.dart';
import '../../core/identity/birth_place.dart';
import '../../core/identity/natal_identity.dart';
import '../../core/identity/profile_controller.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';

/// COMPLETARE IL LUOGO DI NASCITA, da qualunque punto dell'app lo si scopra
/// mancante.
///
/// **Perche' esiste.** L'app diceva "per la mappa completa dei pianeti mi serve
/// il tuo luogo di nascita" e da quell'avviso non partiva nessuna strada: le si
/// dichiarava che mancava un dato senza offrirle il modo di darlo. Chi voleva
/// rimediare doveva indovinare che il posto era il Risveglio, che si fa una
/// volta sola. Un avviso senza gesto e' un vicolo cieco cortese.
///
/// **Una porta sola.** Il luogo si sceglie qui, e da qui si scrive nel profilo
/// e si rilancia il calcolo della carta: nessuna schermata rifa' questi tre
/// passi per conto suo. Le regole della scelta sono le stesse del Risveglio,
/// perche' vivono nel catalogo (`CityCatalog.unicaEsatta`) e non nella
/// schermata.
class CompletaIlLuogo {
  const CompletaIlLuogo._();

  /// Apre il foglio, e se la persona sceglie un luogo lo scrive nel profilo e
  /// fa ricalcolare la carta. Torna il luogo scelto, oppure nulla.
  static Future<BirthPlace?> chiedi(BuildContext context) async {
    final palette = context.palette;
    final scelto = await showModalBottomSheet<BirthPlace>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FoglioDelLuogo(palette: palette),
    );
    if (scelto == null || !context.mounted) return null;

    // 1. Il profilo, che e' la fonte che sopravvive alla chiusura dell'app.
    final profilo = context.read<ProfileController>();
    final vecchia = profilo.identity;
    final nuova = vecchia.copyWith(birthPlace: scelto);
    profilo.setIdentity(nuova);

    // 2. La carta, che senza luogo era un ripiego: adesso si puo' rifare per
    //    davvero, e si RIFA' da capo invece di ripescare quella ripiegata.
    final dettagli = nuova.toBirthDetails();
    if (context.mounted) {
      final carta = context.read<NatalChartController>();
      await carta.riprova(dettagli);
      if (!context.mounted) return scelto;
      // 3. E la porta di lettura riceve il risultato, altrimenti il resto
      //    dell'app continuerebbe a leggere la carta di prima.
      final identita = context.read<BirthIdentityController>();
      final calcolata = carta.chart;
      if (calcolata != null) identita.setBirth(dettagli, calcolata);
    }
    return scelto;
  }
}

class _FoglioDelLuogo extends StatefulWidget {
  const _FoglioDelLuogo({required this.palette});

  final MaestroPalette palette;

  @override
  State<_FoglioDelLuogo> createState() => _FoglioDelLuogoState();
}

class _FoglioDelLuogoState extends State<_FoglioDelLuogo> {
  final TextEditingController _campo = TextEditingController();
  final GlobalKey _elenco = GlobalKey();
  List<City> _risultati = const [];
  BirthPlace? _scelto;

  @override
  void initState() {
    super.initState();
    CityCatalog.ensureLoaded().then((_) {
      if (!mounted) return;
      if (_campo.text.trim().isNotEmpty) _cerca(_campo.text);
    });
  }

  @override
  void dispose() {
    _campo.dispose();
    super.dispose();
  }

  void _cerca(String query) {
    // La stessa regola del Risveglio, e sta nel catalogo perche' valga in
    // tutti e due i posti senza essere scritta due volte: un nome che in
    // catalogo e' unico non si fa scegliere, si sceglie.
    final unica = CityCatalog.unicaEsatta(query);
    if (unica != null) {
      setState(() {
        _scelto = unica.toPlace();
        _risultati = const [];
      });
      return;
    }
    setState(() {
      _risultati = CityCatalog.search(query);
      if (_scelto != null && _campo.text.trim() != _scelto!.city) {
        _scelto = null;
      }
    });
    if (_risultati.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctx = _elenco.currentContext;
        if (ctx == null) return;
        Scrollable.ensureVisible(ctx,
            alignment: 0.5, duration: const Duration(milliseconds: 200));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.palette;
    return Padding(
      // La tastiera non copre il foglio: e' lo stesso difetto del Risveglio,
      // e qui si evita alla radice lasciandole il suo spazio.
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        key: const Key('completa_luogo_foglio'),
        padding: const EdgeInsets.all(SpacingTokens.lg),
        decoration: BoxDecoration(
          color: p.deepest,
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(SpacingTokens.radiusLg)),
          border: Border.all(color: p.gold.withValues(alpha: 0.35)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Dove hai visto la luce',
                  style: TypographyTokens.display(size: 20)
                      .copyWith(color: p.goldSoft)),
              const SizedBox(height: SpacingTokens.sm),
              Text(
                'Il luogo ancora il cielo alla Terra: con lui arrivano '
                'l\'Ascendente e le case.',
                textAlign: TextAlign.center,
                style: TypographyTokens.body(size: 14)
                    .copyWith(color: ColorTokens.textSecondary),
              ),
              const SizedBox(height: SpacingTokens.md),
              TextField(
                key: const Key('completa_luogo_campo'),
                controller: _campo,
                autofocus: true,
                textAlign: TextAlign.center,
                onChanged: _cerca,
                style:
                    TypographyTokens.body(size: 17).copyWith(color: p.goldSoft),
                cursorColor: p.goldSoft,
                decoration: InputDecoration(
                  hintText: 'Cerca la tua città',
                  hintStyle: TypographyTokens.body(size: 16)
                      .copyWith(color: ColorTokens.textSecondary),
                  prefixIcon: Icon(Icons.search_rounded, color: p.goldSoft),
                ),
              ),
              if (_risultati.isNotEmpty)
                Container(
                  key: _elenco,
                  margin: const EdgeInsets.only(top: SpacingTokens.sm),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
                    border: Border.all(color: p.gold.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      for (final c in _risultati)
                        InkWell(
                          key: Key('completa_citta_${c.name}_${c.country}'),
                          onTap: () => setState(() {
                            _scelto = c.toPlace();
                            _campo.text = c.label;
                            _risultati = const [];
                          }),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: SpacingTokens.md,
                                vertical: SpacingTokens.sm),
                            child: Row(
                              children: [
                                Icon(Icons.place_outlined,
                                    size: 16, color: p.goldSoft),
                                const SizedBox(width: SpacingTokens.sm),
                                Expanded(
                                  child: Text(c.label,
                                      style: TypographyTokens.body(size: 15)
                                          .copyWith(
                                              color: ColorTokens.textPrimary)),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              if (_scelto != null) ...[
                const SizedBox(height: SpacingTokens.sm),
                Text('${_scelto!.city} · ${_scelto!.timeZoneId}',
                    key: const Key('completa_luogo_scelto'),
                    style: TypographyTokens.body(size: 13)
                        .copyWith(color: ColorTokens.textSecondary)),
              ],
              const SizedBox(height: SpacingTokens.lg),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  key: const Key('completa_luogo_conferma'),
                  style: FilledButton.styleFrom(
                    backgroundColor: p.gold,
                    foregroundColor: p.deepest,
                    padding:
                        const EdgeInsets.symmetric(vertical: SpacingTokens.md),
                  ),
                  // Spento finche' non c'e' una scelta: qui il pulsante non
                  // deve poter significare due cose diverse, che e' esattamente
                  // il difetto disinnescato al Risveglio.
                  onPressed: _scelto == null
                      ? null
                      : () => Navigator.of(context).pop(_scelto),
                  child: const Text('Salva il luogo'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
