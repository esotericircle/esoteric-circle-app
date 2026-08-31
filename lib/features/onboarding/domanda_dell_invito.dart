import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../design_system/typography/paragrafi_di_lettura.dart';
import '../account/riscatta_l_invito.dart';
import '../../design_system/transizioni/velo_del_cerchio.dart';

/// **TI HA INVITATO QUALCUNO? Ordine CC voce 08.**
///
/// **Il fatto del fondatore.** "Il premio piu' alto della condivisione e'
/// quello dell'invito che porta qualcuno dentro davvero, e vale 60 Eos. Il
/// server sa pagarlo, ma l'app non sa da quale invito arriva chi la installa."
/// La conseguenza che ha scritto lui: "oggi quel premio si riscuote solo se la
/// persona invitata incolla il codice a mano".
///
/// **Cosa ho misurato prima di scegliere.** Tre cose, tutte e tre sul ramo.
/// La callable `riscattaLInvito` **e' distribuita** dal 28 agosto 2026, quindi
/// il lato che paga esiste e funziona. Nell'app non c'e' **nessuna** gestione
/// di collegamenti in arrivo: l'unico `intent-filter` di
/// `AndroidManifest.xml` e' `MAIN`/`LAUNCHER`, e in `pubspec.yaml` non ci sono
/// ne `app_links`, ne `uni_links`, ne `install_referrer`. E la porta per
/// riscattare vive **dentro il menu' Account**, dove chi arriva da un invito
/// non ha nessun motivo di andare a guardare.
///
/// **LA SCELTA, e perche' questa.** Il difetto vero non e' che il codice vada
/// incollato: e' che **nessuno lo chiede mai**. Chi entra grazie a un invito
/// deve trovare la domanda davanti, una volta, nel momento in cui il link e'
/// ancora negli appunti del suo telefono. Qui la domanda si fa, e il codice
/// entra con **un tocco**.
///
/// **Perche' gli appunti si leggono solo quando lo chiede la persona.** Un'app
/// che guarda gli appunti da sola all'avvio legge tutto quello che c'e' li'
/// dentro, che spesso e' una password o un indirizzo: su iOS il sistema lo
/// dice pure a schermo. Qui si legge **solo dopo un tocco sul pulsante
/// Incolla**, e si tiene solo cio' che ha la forma di un codice nostro: se
/// negli appunti c'e' altro, non entra niente e non si mostra niente.
///
/// **Cosa questa voce NON risolve, detto qui e non nascosto.** L'attribuzione
/// vera dell'installazione, quella che non chiede niente a nessuno, su Android
/// esiste e si chiama Play Install Referrer; su iOS **non esiste** un
/// equivalente aperto. Portarla dentro vuol dire un pacchetto nuovo, codice
/// nativo e una build vera per provarla: il fondatore le build le ordina lui,
/// e senza una build quel pezzo non si potrebbe verificare, quindi non si
/// scrive alla cieca.
abstract final class MemoriaDellInvito {
  /// **Sotto `avvisi.`**, che e' gia' fra i prefissi di `CioCheETuo`: chi
  /// cancella tutto se ne va anche da qui, e al rientro la domanda torna.
  static const String chiave = 'avvisi.invito.chiesto';

  static Future<bool> giaChiesto() async {
    try {
      final p = await SharedPreferences.getInstance();
      return p.getBool(chiave) ?? false;
    } catch (errore) {
      // Senza disco si preferisce non chiedere: una domanda che torna a ogni
      // avvio e' peggio di un premio non riscosso.
      return true;
    }
  }

  static Future<void> segnaChiesta() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setBool(chiave, true);
    } catch (errore) {
      // Best effort.
    }
  }
}

/// **VERO SE QUESTO PUO' ESSERE UN CODICE NOSTRO.**
///
/// Serve a non far entrare negli appunti incollati qualcosa che non c'entra.
/// I limiti sono **gli stessi del server**, che rifiuta sotto gli 8 e sopra i
/// 200 caratteri: pretenderne altri qui vorrebbe dire due regole diverse sullo
/// stesso dato, e prima o poi divergono.
bool sembraUnCodiceDInvito(String codice) {
  if (codice.length < 8 || codice.length > 200) return false;
  // La forma e' `uid` oppure `uid.maestro`: lettere, cifre, punto, trattino.
  return RegExp(r'^[A-Za-z0-9._-]+$').hasMatch(codice);
}

/// La domanda, come foglio dal basso. Torna il codice, oppure nullo se chi
/// legge ha detto che non lo ha invitato nessuno.
class DomandaDellInvito extends StatefulWidget {
  const DomandaDellInvito({super.key});

  static Future<String?> chiedi(BuildContext context) {
    return foglioDelCerchio<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const DomandaDellInvito(),
    );
  }

  @override
  State<DomandaDellInvito> createState() => _DomandaDellInvitoState();
}

class _DomandaDellInvitoState extends State<DomandaDellInvito> {
  final TextEditingController _scritto = TextEditingController();
  String? _avviso;

  @override
  void dispose() {
    _scritto.dispose();
    super.dispose();
  }

  /// **GLI APPUNTI SI LEGGONO QUI, e solo qui.** Sul tocco della persona, mai
  /// da soli. Cio' che si trova non si mostra mai per intero: o e' un codice
  /// nostro e finisce nel campo, o non lo e' e si dice soltanto che li' dentro
  /// non c'era un codice.
  Future<void> _incolla() async {
    String trovato = '';
    try {
      final appunti = await Clipboard.getData(Clipboard.kTextPlain);
      trovato = codiceDaCioCheEStatoIncollato(appunti?.text ?? '');
    } catch (errore) {
      trovato = '';
    }
    if (!mounted) return;
    setState(() {
      if (sembraUnCodiceDInvito(trovato)) {
        _scritto.text = trovato;
        _avviso = null;
      } else {
        _avviso = 'Negli appunti non c\'è un codice del Cerchio.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = MaestroScope.forse(context) ?? MaestroPalette.neutral;
    return Container(
      key: const Key('invito_domanda'),
      padding: EdgeInsets.only(
        left: SpacingTokens.lg,
        right: SpacingTokens.lg,
        top: SpacingTokens.lg,
        bottom: MediaQuery.viewInsetsOf(context).bottom + SpacingTokens.lg,
      ),
      decoration: BoxDecoration(
        color: palette.surfaceElevated,
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(SpacingTokens.radiusLg)),
        border: Border.all(color: palette.gold.withValues(alpha: 0.35)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ti ha invitato qualcuno?',
                style: TypographyTokens.titoloScheda()
                    .copyWith(color: palette.goldSoft)),
            const SizedBox(height: SpacingTokens.sm),
            ParagrafiDiLettura(
              testo: 'Se sei arrivato qui da un invito, chi te lo ha mandato '
                  'riceve il suo premio. Tocca Incolla: dal link che hai '
                  'ricevuto prendiamo soltanto il codice. Si fa una volta '
                  'sola.',
              stile: TypographyTokens.lettura()
                  .copyWith(color: ColorTokens.textPrimary),
            ),
            const SizedBox(height: SpacingTokens.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    key: const Key('invito_campo'),
                    controller: _scritto,
                    style: TypographyTokens.didascalia()
                        .copyWith(color: ColorTokens.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Il codice, o il link intero',
                      hintStyle: TypographyTokens.didascalia()
                          .copyWith(color: ColorTokens.textSecondary),
                      filled: true,
                      fillColor: palette.deepest.withValues(alpha: 0.45),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(SpacingTokens.radiusMd),
                        borderSide: BorderSide(
                            color: palette.gold.withValues(alpha: 0.35)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: SpacingTokens.sm),
                OutlinedButton(
                  key: const Key('invito_incolla'),
                  onPressed: _incolla,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: palette.goldSoft,
                    side: BorderSide(
                        color: palette.gold.withValues(alpha: 0.55)),
                    // Stretto quanto basta: la parola sta in ottantotto
                    // punti, e ogni punto in piu' lo perde il campo, che e'
                    // dove si legge il codice.
                    minimumSize: const Size(88, 48),
                    maximumSize: const Size(120, 56),
                    padding: const EdgeInsets.symmetric(
                        horizontal: SpacingTokens.sm),
                  ),
                  child: Text('Incolla',
                      style: TypographyTokens.etichetta()),
                ),
              ],
            ),
            if (_avviso != null) ...[
              const SizedBox(height: SpacingTokens.xs),
              Text(_avviso!,
                  key: const Key('invito_avviso'),
                  style: TypographyTokens.didascalia()
                      .copyWith(color: ColorTokens.textSecondary)),
            ],
            const SizedBox(height: SpacingTokens.md),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                key: const Key('invito_conferma'),
                onPressed: () => Navigator.of(context)
                    .pop(codiceDaCioCheEStatoIncollato(_scritto.text.trim())),
                style: FilledButton.styleFrom(
                    backgroundColor: palette.gold,
                    foregroundColor: palette.onPrimary,
                    minimumSize: const Size.fromHeight(48)),
                child: Text('Riconosci chi ti ha invitato',
                    style: TypographyTokens.etichetta()),
              ),
            ),
            const SizedBox(height: SpacingTokens.xs),
            // **LA VIA D'USCITA E' UNA RIGA VERA, non una X in un angolo.** La
            // maggior parte di chi apre l'app non e' stata invitata da
            // nessuno, e per loro questa domanda deve costare un tocco.
            Align(
              alignment: Alignment.center,
              child: TextButton(
                key: const Key('invito_nessuno'),
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                    foregroundColor: ColorTokens.textSecondary,
                    minimumSize: const Size.fromHeight(48)),
                child: Text('Nessuno mi ha invitato',
                    style: TypographyTokens.etichetta()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
