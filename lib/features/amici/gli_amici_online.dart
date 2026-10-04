import 'package:flutter/material.dart';

import '../../core/cerchio/il_cerchio_sociale.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../cerchio/il_tuo_cerchio_screen.dart';
import '../cerchio/invita_nel_cerchio_screen.dart';
import '../cerchio/la_tendina_del_cerchio.dart';
import '../cerchio/widgets/disegni_del_cerchio.dart';

/// **GLI AMICI ONLINE NELLA RUBRICA, ordine FC voce 09 nella forma del
/// fondatore del 4 ottobre 2026.**
///
/// Il fondatore, prima: *"in amico vorrei che comparissero anche gli amici
/// online"*. Poi, guardando la riga che portava al Cerchio: *"anziche'
/// aprire una nuova schermata per gli amici online, sarebbe meglio inserire
/// 2 pulsanti: a sinistra offline e a destra online con a fianco il numero di
/// amici online e un cerchietto verde. Di default e' selezionato il pulsante
/// offline che mostra gli amici creati dall'utente e se clicca su online
/// compaiono gli amici online."*
///
/// **LE DUE RUBRICHE RESTANO DUE**: Offline sono le schede che la persona
/// scrive, sul telefono; Online sono gli amici del Cerchio presenti adesso,
/// dal server. Il selettore le mette sotto lo stesso titolo, non le fonde:
/// cosa succede a una scheda quando quella persona entra nel Cerchio resta
/// una decisione del fondatore.
///
/// **IL COSTO, DETTO COI NUMERI.** Il numero accanto a Online e l'elenco
/// vengono dalla tendina del Cerchio, la stessa dell'indicatore online. La
/// prima forma della voce non la chiamava mai; questa la chiama **al piu'
/// una volta all'apertura della rubrica**, e mai se:
///   * la tendina e' arrivata da meno di [freschezzaDellaTendina]: si riusa;
///   * nel Cerchio non c'e' nessun amico: il numero e' zero, ed e' vero;
///   * il Cerchio e' chiuso per eta' o la porta non c'e'.
/// Una chiamata legge cinque documenti (misurati dalla guardia
/// `la_tendina_non_supera_dieci_letture`) e ne scrive uno (il tetto della
/// porta): ai prezzi di Firestore in europe-west1, 0,029 euro ogni centomila
/// letture e 0,0871 ogni centomila scritture, piu' l'invocazione della
/// funzione, sono circa 0,0000027 euro, cioe' 0,27 centesimi ogni mille
/// aperture della rubrica.
/// La tendina ha un tetto di trenta chiamate l'ora per persona; il riuso di
/// un minuto fa si' che la rubrica da sola non lo raggiunga aprendosi e
/// chiudendosi.
///
/// **NESSUNO ZERO INVENTATO**: finche' la tendina non e' arrivata, o se il
/// Cerchio non risponde, accanto a Online non c'e' un numero.
abstract final class GliAmiciOnline {
  /// Quanto puo' essere vecchia la tendina per essere riusata.
  static const Duration freschezzaDellaTendina = Duration(minutes: 1);

  /// Se la tendina c'e' ed e' fresca all'istante [adesso].
  static bool tendinaFresca(IlCerchioSociale s, DateTime adesso) {
    final arrivata = s.tendinaArrivata;
    return s.tendina != null &&
        arrivata != null &&
        !adesso.isBefore(arrivata) &&
        adesso.difference(arrivata) <= freschezzaDellaTendina;
  }

  /// Se all'apertura la rubrica deve chiedere la tendina: solo quando il
  /// numero non si sa gia' e c'e' qualcuno da contare.
  static bool vaChiesta(IlCerchioSociale s, DateTime adesso) =>
      s.vivo &&
      !s.chiusoPerEta &&
      s.cerchio.amici.isNotEmpty &&
      !tendinaFresca(s, adesso);

  /// Quanti amici sono online: zero se nel Cerchio non ce n'e' nessuno,
  /// il numero della tendina se e' fresca o se e' arrivata per questa
  /// apertura ([arrivataQui]), altrimenti nullo.
  static int? quanti(IlCerchioSociale s, DateTime adesso,
      {bool arrivataQui = false}) {
    if (s.chiusoPerEta) return null;
    if (s.cerchio.amici.isEmpty) return 0;
    final t = s.tendina;
    if (t == null) return null;
    if (arrivataQui || tendinaFresca(s, adesso)) return t.amiciPresenti.length;
    return null;
  }
}

/// **I DUE PULSANTI**, Offline a sinistra e Online a destra, col numero e
/// il cerchietto verde. Il cerchietto e' pieno quando qualcuno c'e', velato
/// quando nessuno c'e' o il numero non si sa ancora.
class IlSelettoreDegliAmici extends StatelessWidget {
  const IlSelettoreDegliAmici({
    super.key,
    required this.suOnline,
    required this.quanti,
    required this.palette,
    required this.onOffline,
    required this.onOnline,
  });

  final bool suOnline;
  final int? quanti;
  final MaestroPalette palette;
  final VoidCallback onOffline;
  final VoidCallback onOnline;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.md),
      child: Row(children: [
        Expanded(
          child: _Pulsante(
            chiave: const Key('amici_offline'),
            scelto: !suOnline,
            palette: palette,
            onTap: onOffline,
            child: Text('Offline', style: _stile(!suOnline)),
          ),
        ),
        const SizedBox(width: SpacingTokens.sm),
        Expanded(
          child: _Pulsante(
            chiave: const Key('amici_online'),
            scelto: suOnline,
            palette: palette,
            onTap: onOnline,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(child: Text('Online', style: _stile(suOnline))),
                if (quanti != null) ...[
                  const SizedBox(width: SpacingTokens.xs),
                  Text('$quanti',
                      key: const Key('amici_online_quanti'),
                      style: _stile(suOnline)),
                ],
                const SizedBox(width: SpacingTokens.xs),
                Container(
                  key: const Key('amici_online_lucina'),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ColorTokens.lucinaOnline
                        .withValues(alpha: (quanti ?? 0) > 0 ? 1 : 0.35),
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  TextStyle _stile(bool scelto) => TypographyTokens.etichetta()
      .copyWith(color: scelto ? palette.deepest : palette.goldSoft);
}

class _Pulsante extends StatelessWidget {
  const _Pulsante({
    required this.chiave,
    required this.scelto,
    required this.palette,
    required this.onTap,
    required this.child,
  });

  final Key chiave;
  final bool scelto;
  final MaestroPalette palette;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final forma = BorderRadius.circular(SpacingTokens.radiusMd);
    return Semantics(
      button: true,
      selected: scelto,
      child: Material(
        color: scelto ? palette.goldSoft : Colors.transparent,
        borderRadius: forma,
        child: InkWell(
          key: chiave,
          enableFeedback: false,
          borderRadius: forma,
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.sm),
            decoration: BoxDecoration(
              borderRadius: forma,
              border: Border.all(color: palette.gold.withValues(alpha: 0.6)),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// **L'ELENCO ONLINE**: gli amici del Cerchio presenti adesso, con la stessa
/// riga della tendina ([AmicoPresente]). Sotto, la strada al Cerchio intero.
///
/// **I TESTI NUOVI SONO SEGNAPOSTO DICHIARATI** (li scrive l'Architetto):
/// la riga in cima e quella del Cerchio che non risponde. Gli altri sono gli
/// stessi della tendina e dell'invito, gia' in uso.
class ElencoDegliAmiciOnline extends StatelessWidget {
  const ElencoDegliAmiciOnline({
    super.key,
    required this.sociale,
    required this.inAttesa,
    required this.valida,
    required this.riga,
    required this.onRiprova,
    required this.palette,
  });

  final IlCerchioSociale sociale;

  /// La tendina chiesta all'apertura non e' ancora arrivata.
  final bool inAttesa;

  /// La tendina e' fresca, o e' arrivata per questa apertura: si puo'
  /// mostrare. Una tendina vecchia non si mostra come se fosse di adesso.
  final bool valida;

  /// Perche' la tendina non e' arrivata, se non e' arrivata.
  final String? riga;
  final VoidCallback onRiprova;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    final corpo = TypographyTokens.corpo()
        .copyWith(color: ColorTokens.textSecondary, height: 1.4);
    if (sociale.chiusoPerEta) {
      return Text(IlCerchioSociale.rigaDeiQuattordici,
          key: const Key('amici_online_quattordici'), style: corpo);
    }
    if (sociale.cerchio.amici.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Il tuo Cerchio è ancora da chiamare.',
              key: const Key('amici_online_nessuno_nel_cerchio'), style: corpo),
          const SizedBox(height: SpacingTokens.md),
          _Strada(
            chiave: const Key('amici_online_invita'),
            etichetta: 'Invita nel tuo Cerchio',
            icona: Icons.person_add_alt_1_rounded,
            palette: palette,
            onTap: () =>
                Navigator.of(context).push(InvitaNelCerchioScreen.route()),
          ),
        ],
      );
    }
    final t = sociale.tendina;
    final figli = <Widget>[
      // SEGNAPOSTO, ordine FC voce 09.
      Text('I tuoi amici del Cerchio che sono qui adesso.', style: corpo),
      const SizedBox(height: SpacingTokens.md),
    ];
    if (inAttesa) {
      figli.add(const Padding(
        padding: EdgeInsets.all(SpacingTokens.lg),
        child: Center(child: CircularProgressIndicator()),
      ));
    } else if (!valida || t == null) {
      figli.addAll([
        Text(riga ?? EsitoDelGesto.silenzio.riga!,
            key: const Key('amici_online_silenzio'), style: corpo),
        const SizedBox(height: SpacingTokens.sm),
        _Strada(
          chiave: const Key('amici_online_riprova'),
          etichetta: 'Riprova',
          icona: Icons.refresh_rounded,
          palette: palette,
          onTap: onRiprova,
        ),
      ]);
    } else {
      if (t.visibilita == VisibilitaNelCerchio.invisibile) {
        figli.add(Padding(
          padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
          child: Text('Sei invisibile: nessuno ti vede e tu vedi gli altri.',
              style: TypographyTokens.didascalia()
                  .copyWith(color: palette.goldSoft)),
        ));
      }
      if (t.amiciPresenti.isEmpty) {
        figli.add(Text('Nessuno dei tuoi amici è qui adesso.',
            key: const Key('amici_online_vuoto'), style: corpo));
      }
      figli.add(ElencoDelCerchio(
        persone: t.amiciPresenti,
        child: Column(children: [
          for (final p in t.amiciPresenti)
            AmicoPresente(persona: p, chiudiPrima: false),
        ]),
      ));
    }
    figli.addAll([
      const SizedBox(height: SpacingTokens.md),
      _Strada(
        chiave: const Key('amici_online_al_cerchio'),
        etichetta: 'Il tuo Cerchio',
        icona: Icons.blur_circular_rounded,
        palette: palette,
        onTap: () => Navigator.of(context).push(IlTuoCerchioScreen.route()),
      ),
    ]);
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, children: figli);
  }
}

class _Strada extends StatelessWidget {
  const _Strada({
    required this.chiave,
    required this.etichetta,
    required this.icona,
    required this.palette,
    required this.onTap,
  });

  final Key chiave;
  final String etichetta;
  final IconData icona;
  final MaestroPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
        key: chiave,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 48),
          side: BorderSide(color: palette.gold.withValues(alpha: 0.6)),
        ),
        onPressed: onTap,
        icon: Icon(icona, color: palette.goldSoft),
        label: Text(etichetta,
            style: TypographyTokens.corpo().copyWith(color: palette.goldSoft)),
      );
}
