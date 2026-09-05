import 'package:flutter/material.dart';

import '../../core/astro/city_catalog.dart';
import '../../core/astro/luogo_attuale.dart';
import '../../core/astro/sky_location.dart';
import '../../core/maestro/maestro.dart';
import '../../core/permissions/app_permission.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';

/// IL PUNTO IN CUI SI CHIEDE DOVE SEI, CON GARBO. Ordine P voce 23, terza parte.
///
/// **E' la parte che pesa piu' delle altre due, e la ragione e' aritmetica.** Il
/// campo del luogo attuale e la sua conservazione non servono a niente se
/// nessuno arriva a riempirlo: chi non concede mai la posizione non vedra' mai
/// la fascia dell'alba, e chi non concede la posizione e' la maggioranza.
///
/// **Compare solo dove serve e solo quando serve.** Non all'avvio dell'app, non
/// come schermata, non come finestra di sistema a tradimento: dentro il dono del
/// mattino, e SOLTANTO quando l'ora del sorgere non si puo' dichiarare, cioe'
/// quando il rito sta rinunciando a dire una cosa vera. Chi legge ha appena
/// visto cosa gli manca.
///
/// **DUE STRADE, e la seconda non chiede niente a nessuno.** Il permesso e' la
/// prima, col suo pre-avviso che dice a cosa serve; scegliere la citta' e' la
/// seconda, e per il sorgere vale quanto il GPS. Chi dice no al permesso non
/// resta fuori: e' la differenza fra chiedere con garbo e chiedere e basta.
class DoveSeiAdesso extends StatefulWidget {
  const DoveSeiAdesso({
    super.key,
    required this.palette,
    required this.maestro,
    required this.location,
    required this.suScelto,
  });

  final MaestroPalette palette;
  final Maestro maestro;

  /// La porta della posizione, la stessa del resto dell'app.
  final SkyLocation location;

  /// Chiamato quando il luogo c'e': il rito si ricompone con l'ora vera.
  final ValueChanged<LuogoAttuale> suScelto;

  @override
  State<DoveSeiAdesso> createState() => _DoveSeiAdessoState();
}

class _DoveSeiAdessoState extends State<DoveSeiAdesso> {
  /// Vero quando l'elenco delle citta' e' aperto.
  bool _cercando = false;
  List<City> _risultati = const [];

  @override
  void initState() {
    super.initState();
    CityCatalog.ensureLoaded();
  }

  Future<void> _chiediIlPermesso() async {
    final concesso = await requestPermissionWithPrelude(
      context,
      permission: AppPermission.location,
      palette: widget.palette,
      maestro: widget.maestro,
      // NON il testo generico dei permessi: quello parla del cielo che si
      // orienta. Qui si dice l'unica cosa che questa richiesta ottiene.
      copy: const PermissionCopy(
        icon: Icons.wb_twilight_rounded,
        title: 'A che ora sorge il sole, da te?',
        body: 'Serve la tua posizione per dire l\'ora vera del sorgere dove '
            'sei adesso. Non si condivide con nessuno e non lascia il telefono. '
            'Se preferisci non darla, puoi scegliere la tua città: per il '
            'sorgere vale allo stesso modo.',
        cta: 'Usa la mia posizione',
      ),
      systemRequest: () async {
        // **LA RISPOSTA INTERA, NON UN NULL, ordine BE voce 06.** Qui si
        // usava `resolveSeConcesso`, che appiattisce ogni esito su un nulla:
        // col permesso negato per sempre il dialogo di sistema non compare
        // mai piu', il nulla tornava in silenzio, e sul telefono del
        // fondatore il tocco restava MUTO. E' lo stesso appiattimento gia'
        // curato una volta sulla Runa del Tramonto (BB.08), da un'altra
        // porta: i due no restano distinti fino a schermo.
        final risposta = await widget.location.chiedi();
        if (!mounted) return risposta.concessa;
        switch (risposta.esito) {
          case EsitoPosizione.concessa:
            break;
          case EsitoPosizione.negataPerSempre:
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              key: Key('alba_posizione_negata_per_sempre'),
              content: Text(
                  'La posizione è stata negata per sempre a questa app: ti '
                  'porto alle impostazioni per riattivarla. Oppure scegli '
                  'la tua città qui sotto.'),
              duration: Duration(seconds: 6),
            ));
            await widget.location.apriImpostazioni();
          case EsitoPosizione.servizioSpento:
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              key: Key('alba_posizione_servizio_spento'),
              content:
                  Text('La posizione del telefono è spenta: accendila dalle '
                      'impostazioni, oppure scegli la tua città qui sotto.'),
              duration: Duration(seconds: 6),
            ));
          case EsitoPosizione.negata:
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              key: Key('alba_posizione_negata'),
              content: Text(
                  'Senza posizione posso comunque usare la tua città: '
                  'scegli qui sotto, per il sorgere vale allo stesso modo.'),
            ));
          case EsitoPosizione.nonDisponibile:
            break;
        }
        return risposta.concessa;
      },
    );
    if (!concesso || !mounted) return;
    final luogo = await widget.location.resolveSeConcesso();
    if (luogo == null || !mounted) return;
    final attuale = LuogoAttuale.dalDispositivo(luogo);
    await DoveSonoAdesso.scrivi(attuale);
    if (mounted) widget.suScelto(attuale);
  }

  Future<void> _scegli(City c) async {
    final attuale = LuogoAttuale.dallaCitta(c);
    await DoveSonoAdesso.scrivi(attuale);
    if (mounted) widget.suScelto(attuale);
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    return Container(
      key: const Key('dove_sei_adesso'),
      width: double.infinity,
      padding: const EdgeInsets.all(SpacingTokens.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
        border: Border.all(color: palette.gold.withValues(alpha: 0.45)),
        // **IL VETRO DI NOTTE, ordine BE voce 06.** Parole del fondatore,
        // maiuscole sue: "QUELLE SCRITTE CON SFONDO DEL MARE NON SI
        // VEDONO". La card stava NUDA sulla fotografia del mare
        // illuminato: solo bordo, nessun fondo. Lo stesso vetro scuro dei
        // responsi (BB.09) le da' un fondo prevedibile su qualunque foto.
        color: palette.deepest.withValues(alpha: 0.90),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // COSA MANCA, detto senza girarci intorno: la riga esiste perche' il
          // rito sta rinunciando a dire una cosa vera.
          Text(
            'Non so dove sei, quindi non ti dico l\'ora del sorgere: '
            'preferisco tacerla che sbagliarla. Chi è nato a Sydney e vive '
            'a Milano riceverebbe l\'alba di Sydney.',
            key: const Key('dove_sei_perche'),
            style: TypographyTokens.didascalia().copyWith(height: 1.4),
          ),
          const SizedBox(height: SpacingTokens.sm),
          if (!_cercando)
            Wrap(
              spacing: SpacingTokens.sm,
              runSpacing: SpacingTokens.xs,
              children: [
                if (widget.location.available)
                  OutlinedButton.icon(
                    key: const Key('dove_sei_permesso'),
                    onPressed: _chiediIlPermesso,
                    icon: const Icon(Icons.my_location_rounded, size: 16),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: palette.goldSoft,
                      side: BorderSide(
                          color: palette.gold.withValues(alpha: 0.55)),
                    ),
                    label: Text('Usa la mia posizione',
                        style: TypographyTokens.didascalia()
                            .copyWith(color: palette.goldSoft)),
                  ),
                // LA SECONDA STRADA C'E' SEMPRE, anche dove il sensore non c'e'
                // o il permesso e' negato per sempre: e' il ripiego che rende
                // la fascia raggiungibile a tutti.
                OutlinedButton.icon(
                  key: const Key('dove_sei_scegli'),
                  onPressed: () => setState(() => _cercando = true),
                  icon: const Icon(Icons.location_city_rounded, size: 16),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: palette.goldSoft,
                    side:
                        BorderSide(color: palette.gold.withValues(alpha: 0.55)),
                  ),
                  label: Text('Scelgo la mia città',
                      style: TypographyTokens.didascalia()
                          .copyWith(color: palette.goldSoft)),
                ),
              ],
            )
          else ...[
            TextField(
              key: const Key('dove_sei_campo'),
              autofocus: true,
              style: TypographyTokens.corpo(),
              decoration: InputDecoration(
                hintText: 'La città in cui vivi',
                hintStyle: TypographyTokens.didascalia(),
                isDense: true,
                enabledBorder: UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: palette.gold.withValues(alpha: 0.5)),
                ),
              ),
              onChanged: (q) =>
                  setState(() => _risultati = CityCatalog.search(q)),
            ),
            for (final c in _risultati.take(5))
              ListTile(
                key: Key('dove_sei_citta_${c.name}'),
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text('${c.name}, ${c.country}',
                    style: TypographyTokens.didascalia()),
                onTap: () => _scegli(c),
              ),
          ],
        ],
      ),
    );
  }
}
