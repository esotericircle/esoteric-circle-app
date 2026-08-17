import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/identity/account_del_cerchio.dart';
import '../../services/app_services.dart';
import 'custodia_del_cielo.dart';

import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../pricing/pricing_screen.dart';
import '../settings/settings_screen.dart';
import 'profile_screen.dart';
import 'dati_di_nascita_screen.dart';

/// L'area account, aperta dall'icona Utente in alto a destra nel Cerchio.
///
/// Raccoglie le voci personali (Profilo, Impostazioni, Abbonamento, Notifiche,
/// Privacy), distinte dal Cosmic Passport, che resta il profilo esoterico nella
/// barra in basso. Alcune voci portano gia' alla loro schermata, altre sono in
/// arrivo e lo dichiarano, mai un vicolo cieco.
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  static Route<void> route() => MaterialPageRoute<void>(
        builder: (_) => const AccountScreen(),
      );

  @override
  Widget build(BuildContext context) {
    final entries = <_AccountEntry>[
      _AccountEntry(
        id: 'profilo',
        title: 'Profilo',
        subtitle: 'Nome, avatar e dati personali',
        icon: Icons.person_outline_rounded,
        onTap: (context) => Navigator.of(context).push(ProfileScreen.route()),
      ),
      // I DATI DI NASCITA SI CORREGGONO. Prima si raccoglievano una volta sola
      // nel Risveglio e non c'era piu' modo di toccarli: chi l'aveva concluso
      // senza dare l'ora non poteva piu' darla, e si rivedeva per sempre
      // "l'Ascendente e le Case restano velati". Un dato che si raccoglie una
      // volta sola e mai piu' non e' un dato, e' una trappola.
      _AccountEntry(
        id: 'nascita',
        title: 'I tuoi dati di nascita',
        subtitle: 'Giorno e ora esatta, per Ascendente e Case',
        icon: Icons.cake_outlined,
        onTap: (context) =>
            Navigator.of(context).push(DatiDiNascitaScreen.route()),
      ),
      _AccountEntry(
        id: 'impostazioni',
        title: 'Impostazioni',
        subtitle: 'Preferenze, lingua, qualità grafica',
        icon: Icons.settings_outlined,
        onTap: (context) =>
            Navigator.of(context).push(SettingsScreen.route()),
      ),
      _AccountEntry(
        id: 'abbonamento',
        title: 'Abbonamento',
        subtitle: 'Il tuo piano e i livelli del Cerchio',
        icon: Icons.workspace_premium_outlined,
        onTap: (context) =>
            Navigator.of(context).push(PricingScreen.route()),
      ),
      const _AccountEntry(
        id: 'notifiche',
        title: 'Notifiche',
        subtitle: 'Gli appuntamenti che ti avvisano',
        icon: Icons.notifications_none_rounded,
      ),
      const _AccountEntry(
        id: 'privacy',
        title: 'Privacy',
        subtitle: 'Dati, consensi e sicurezza',
        icon: Icons.shield_outlined,
      ),
      // CUSTODIRE IL PROPRIO CIELO, ordine N voce 1c: la via che resta a chi
      // ha rimandato. La voce compare SOLO a chi e' ancora anonimo, perche' a
      // chi ha gia' custodito direbbe una cosa gia' fatta.
      if (_eAnonimo(context))
        _AccountEntry(
          id: 'custodia',
          title: 'Custodisci il tuo cielo',
          subtitle: 'Collegalo a te: ti segue anche se cambi telefono',
          icon: Icons.shield_moon_outlined,
          onTap: (context) async {
            final momenti =
                await context.read<AppServices>().memory.quantiMomenti();
            if (!context.mounted) return;
            // Dall'area account si chiede sempre, anche con zero momenti: qui
            // e' la persona ad averlo cercato, e un invito che non si apre
            // sarebbe un vicolo cieco.
            await mostraInvitoACustodire(context,
                momenti: momenti > 0 ? momenti : 1);
          },
        ),
      // IL DIRITTO ALL'OBLIO, voce 1f: e' un obbligo, non una gentilezza, e
      // cancella anche cio' che vive sul server.
      _AccountEntry(
        id: 'oblio',
        title: 'Cancella il tuo account',
        subtitle: 'Il Cerchio dimentica tutto, qui e sul server',
        icon: Icons.delete_outline_rounded,
        onTap: (context) => _chiediLOblio(context),
      ),
    ];

    return Scaffold(
      backgroundColor: ColorTokens.neutralDeepest,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          color: ColorTokens.textPrimary,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text('Il tuo account',
            style: TypographyTokens.display(size: 20)),
      ),
      body: SafeArea(
        top: false,
        child: ListView.separated(
          key: const Key('account_list'),
          padding: const EdgeInsets.fromLTRB(SpacingTokens.lg, SpacingTokens.md,
              SpacingTokens.lg, SpacingTokens.xxxl),
          itemCount: entries.length,
          separatorBuilder: (_, __) => const SizedBox(height: SpacingTokens.sm),
          itemBuilder: (context, i) => _AccountTile(entry: entries[i]),
        ),
      ),
    );
  }
}

/// L'account, se l'albero ce l'ha. Le prove che montano questa schermata da
/// sola non lo hanno, e devono poterla montare lo stesso: senza account la
/// voce della custodia semplicemente non c'e'.
bool _eAnonimo(BuildContext context) {
  try {
    return context.watch<AccountDelCerchio>().eAnonimo;
  } catch (errore) {
    // Si ignora: senza account nell'albero la voce della custodia non c'e',
    // ed e' il comportamento voluto nelle prove che montano la schermata da
    // sola.
    return false;
  }
}

/// LA DOMANDA PRIMA DELL'OBLIO, che si fa una volta sola e per intero.
///
/// Si dice cosa sparisce, e non "sei sicuro?": chi cancella deve sapere che
/// se ne vanno la carta natale, la memoria dei Maestri, i Sigilli e gli Eos,
/// e che non c'e' un ripensamento dopo.
Future<void> _chiediLOblio(BuildContext context) async {
  final conferma = await showDialog<bool>(
    context: context,
    builder: (dialogo) => AlertDialog(
      key: const Key('oblio_conferma'),
      backgroundColor: ColorTokens.neutralSurface,
      title: Text('Cancellare tutto?',
          style: TypographyTokens.titoloScheda()),
      content: Text(
        'Spariscono la tua carta natale, la memoria dei Maestri, i tuoi '
        'Sigilli e i tuoi Eos, qui e sul server. Non si torna indietro.',
        style: TypographyTokens.corpo()
            .copyWith(color: ColorTokens.textSecondary, height: 1.4),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogo).pop(false),
          child: const Text('Resto nel Cerchio'),
        ),
        TextButton(
          key: const Key('oblio_conferma_si'),
          onPressed: () => Navigator.of(dialogo).pop(true),
          child: const Text('Cancella tutto'),
        ),
      ],
    ),
  );
  if (conferma != true || !context.mounted) return;
  final servizi = context.read<AppServices>();
  await servizi.memory.deleteAllData();
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      key: Key('oblio_fatto'),
      content: Text('Il Cerchio ti ha dimenticato. Puoi ricominciare quando '
          'vuoi.'),
    ),
  );
}

class _AccountEntry {
  const _AccountEntry({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;

  /// Azione della voce. Se assente, la sezione e' ancora in arrivo.
  final void Function(BuildContext context)? onTap;

  bool get isLive => onTap != null;
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({required this.entry});

  final _AccountEntry entry;

  void _open(BuildContext context) {
    if (entry.onTap != null) {
      entry.onTap!(context);
      return;
    }
    // Mai un vicolo cieco: un anticipo elegante per le sezioni in arrivo.
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        key: const Key('account_coming_soon'),
        padding: const EdgeInsets.fromLTRB(SpacingTokens.lg, SpacingTokens.md,
            SpacingTokens.lg, SpacingTokens.xl),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [ColorTokens.neutralSurface, ColorTokens.neutralDeepest],
          ),
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(SpacingTokens.radiusXl)),
          border: Border.all(color: ColorTokens.gold.withValues(alpha: 0.3)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(entry.icon, color: ColorTokens.goldLight, size: 24),
                  const SizedBox(width: SpacingTokens.sm),
                  Text(entry.title,
                      style: TypographyTokens.display(size: 19)
                          .copyWith(color: ColorTokens.goldLight)),
                ],
              ),
              const SizedBox(height: SpacingTokens.sm),
              Text(
                'Questa sezione sta per aprirsi nel Cerchio. Torna presto per '
                'trovarla pronta.',
                style: TypographyTokens.corpo()
                    .copyWith(color: ColorTokens.textSecondary, height: 1.4),
              ),
              const SizedBox(height: SpacingTokens.lg),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  child: Text('Va bene',
                      style: TypographyTokens.label(size: 13)
                          .copyWith(color: ColorTokens.goldLight)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: Key('account_${entry.id}'),
        onTap: () => _open(context),
        borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(SpacingTokens.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
            color: ColorTokens.neutralSurface.withValues(alpha: 0.5),
            border: Border.all(color: ColorTokens.gold.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ColorTokens.neutralDeep,
                  border:
                      Border.all(color: ColorTokens.gold.withValues(alpha: 0.4)),
                ),
                alignment: Alignment.center,
                child: Icon(entry.icon, color: ColorTokens.goldLight, size: 22),
              ),
              const SizedBox(width: SpacingTokens.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // **IL TITOLO NON SI SPEZZA DENTRO LE PAROLE.** Ordine AI
                    // voce 03, dalla foto di Mauro: "NOTIFIC HE" a 360 punti.
                    // Il distintivo "In arrivo" stava FUORI dalla colonna e
                    // rubava la riga: al titolo restavano 83 punti, meno di
                    // una parola. La composizione scelta e' lo SPAZIO
                    // DISPONIBILE: titolo e distintivo vivono in un Wrap
                    // dentro la colonna, il titolo ha tutta la sua larghezza
                    // e il distintivo scende sotto quando non c'e' posto.
                    Wrap(
                      spacing: SpacingTokens.sm,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(entry.title,
                            style: TypographyTokens.display(size: 17)),
                        if (!entry.isLive)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  SpacingTokens.radiusPill),
                              color: ColorTokens.gold.withValues(alpha: 0.16),
                              border: Border.all(
                                  color: ColorTokens.gold
                                      .withValues(alpha: 0.5)),
                            ),
                            child: Text('In arrivo',
                                style: TypographyTokens.etichetta()
                                    .copyWith(color: ColorTokens.goldLight)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(entry.subtitle,
                        style: TypographyTokens.corpo().copyWith(
                            color: ColorTokens.textSecondary, height: 1.3)),
                  ],
                ),
              ),
              const SizedBox(width: SpacingTokens.xs),
              Icon(
                entry.isLive
                    ? Icons.chevron_right_rounded
                    : Icons.lock_clock_rounded,
                size: 20,
                color: ColorTokens.goldLight
                    .withValues(alpha: entry.isLive ? 0.9 : 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
