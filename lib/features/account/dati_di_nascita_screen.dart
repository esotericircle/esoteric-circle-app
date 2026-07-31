import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/identity/birth_identity.dart';
import '../../core/identity/profile_controller.dart';
import '../../design_system/components/cosmos_background.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';

/// DOVE SI CORREGGONO I DATI DI NASCITA DOPO IL RISVEGLIO.
///
/// **Perche' esiste, e perche' e' urgente.** Il fondatore ha segnalato tre volte
/// che l'ora di nascita non si registra. La catena di persistenza regge in ogni
/// suo anello, e c'e' una prova per ciascuno; nel giro scorso ho anche corretto
/// il controller che viveva in memoria. Restava il fatto piu' semplice e piu'
/// grave: `setIdentity` era chiamato in UN SOLO punto di tutto il progetto,
/// l'onboarding, quindi **chi aveva gia' fatto il Risveglio senza dare l'ora non
/// poteva piu' darla in nessun modo**. Nessuna correzione a valle poteva servire
/// a lui, ed e' proprio il suo caso.
///
/// Un dato che si raccoglie una volta sola, e mai piu', non e' un dato: e' una
/// trappola. Qui si corregge, e il cielo si rifa' col dato nuovo.
class DatiDiNascitaScreen extends StatefulWidget {
  const DatiDiNascitaScreen({super.key});

  static Route<void> route() => MaterialPageRoute<void>(
        builder: (_) => const DatiDiNascitaScreen(),
      );

  @override
  State<DatiDiNascitaScreen> createState() => _DatiDiNascitaScreenState();
}

class _DatiDiNascitaScreenState extends State<DatiDiNascitaScreen> {
  DateTime? _data;
  int? _ora;
  int? _minuto;
  bool _caricato = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_caricato) return;
    _caricato = true;
    final identita = context.read<ProfileController>().identity;
    // I dati d'esempio non si mostrano come se fossero i tuoi: chi arriva qui
    // senza aver dato niente trova i campi vuoti, non la nascita di qualcun altro.
    if (identita.isExample) return;
    _data = identita.birthDate;
    if (identita.hasBirthTime) {
      _ora = identita.birthMoment.hour;
      _minuto = identita.birthMoment.minute;
    }
  }

  bool get _completo => _data != null;

  void _salva() {
    final data = _data;
    if (data == null) return;
    final profilo = context.read<ProfileController>();
    // Si conserva il luogo che c'e' gia': questa schermata corregge data e ora,
    // e non deve poter cancellare in silenzio un dato che non ha toccato.
    profilo.setIdentity(BirthIdentity.fromParts(
      birthDate: data,
      birthHour: _ora,
      birthMinute: _minuto,
      birthPlace: profilo.identity.birthPlace,
    ));
    Navigator.of(context).pop();
  }

  Future<void> _scegliData() async {
    final scelta = await showDatePicker(
      context: context,
      initialDate: _data ?? DateTime(1990, 6, 15),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Il giorno in cui sei nato',
    );
    if (scelta != null) setState(() => _data = scelta);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: palette.goldSoft),
        title: Text('I tuoi dati di nascita',
            style: TypographyTokens.display(size: 19)),
      ),
      body: CosmosBackground(
        seed: 11,
        showZodiac: false,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(SpacingTokens.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Da qui puoi correggerli quando vuoi. Con l\'ora esatta il tuo '
                  'cielo guadagna l\'Ascendente e le Case, che senza restano velati.',
                  style: TypographyTokens.body(size: TypographyTokens.guide)
                      .copyWith(color: ColorTokens.textSecondary),
                ),
                const SizedBox(height: SpacingTokens.lg),
                _Riga(
                  etichetta: 'Giorno di nascita',
                  valore: _data == null
                      ? 'Da scegliere'
                      : '${_data!.day.toString().padLeft(2, '0')} '
                          '${_mesi[_data!.month - 1]} ${_data!.year}',
                  chiave: 'nascita_data',
                  onTap: _scegliData,
                  palette: palette,
                ),
                const SizedBox(height: SpacingTokens.md),
                Text('Ora di nascita',
                    style: TypographyTokens.label(size: 13)
                        .copyWith(color: palette.goldSoft, letterSpacing: 2)),
                const SizedBox(height: SpacingTokens.sm),
                Row(
                  children: [
                    _Ruota(
                      chiave: 'nascita_ora',
                      invito: 'Ora',
                      valore: _ora,
                      valori: [for (var h = 0; h < 24; h++) h],
                      palette: palette,
                      onCambia: (v) => setState(() => _ora = v),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: SpacingTokens.sm),
                      child: Text(':',
                          style: TypographyTokens.display(size: 20)
                              .copyWith(color: palette.goldSoft)),
                    ),
                    _Ruota(
                      chiave: 'nascita_minuto',
                      invito: 'Minuti',
                      valore: _minuto,
                      valori: [for (var m = 0; m < 60; m++) m],
                      palette: palette,
                      onCambia: (v) => setState(() => _minuto = v),
                    ),
                  ],
                ),
                const SizedBox(height: SpacingTokens.sm),
                Text(
                  'Se non la conosci lascia i campi vuoti: il resto del tuo '
                  'cielo resta saldo lo stesso.',
                  style: TypographyTokens.body(size: 13)
                      .copyWith(color: ColorTokens.textSecondary),
                ),
                const SizedBox(height: SpacingTokens.lg),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    key: const Key('nascita_salva'),
                    style: FilledButton.styleFrom(
                      backgroundColor: palette.gold,
                      foregroundColor: palette.deepest,
                      padding: const EdgeInsets.symmetric(
                          vertical: SpacingTokens.md),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(SpacingTokens.radiusPill),
                      ),
                    ),
                    onPressed: _completo ? _salva : null,
                    child: Text('Salva',
                        style: TypographyTokens.body(size: 17, weight: 600)
                            .copyWith(color: palette.deepest)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

const _mesi = [
  'gennaio',
  'febbraio',
  'marzo',
  'aprile',
  'maggio',
  'giugno',
  'luglio',
  'agosto',
  'settembre',
  'ottobre',
  'novembre',
  'dicembre',
];

class _Riga extends StatelessWidget {
  const _Riga({
    required this.etichetta,
    required this.valore,
    required this.chiave,
    required this.onTap,
    required this.palette,
  });

  final String etichetta;
  final String valore;
  final String chiave;
  final VoidCallback onTap;
  final dynamic palette;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: Key(chiave),
      onTap: onTap,
      borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(SpacingTokens.md),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
          border: Border.all(color: palette.gold.withValues(alpha: 0.35)),
          color: palette.deepest.withValues(alpha: 0.4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(etichetta,
                style: TypographyTokens.body(size: TypographyTokens.guide)
                    .copyWith(color: ColorTokens.textSecondary)),
            Text(valore,
                style: TypographyTokens.display(size: 16)
                    .copyWith(color: palette.goldSoft)),
          ],
        ),
      ),
    );
  }
}

class _Ruota extends StatelessWidget {
  const _Ruota({
    required this.chiave,
    required this.invito,
    required this.valore,
    required this.valori,
    required this.palette,
    required this.onCambia,
  });

  final String chiave;
  final String invito;
  final int? valore;
  final List<int> valori;
  final dynamic palette;
  final ValueChanged<int> onCambia;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.sm),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
        border: Border.all(color: palette.gold.withValues(alpha: 0.35)),
        color: palette.deepest.withValues(alpha: 0.4),
      ),
      child: DropdownButton<int>(
        key: Key(chiave),
        value: valore,
        hint: Text(invito,
            style: TypographyTokens.label(size: 12)
                .copyWith(color: ColorTokens.textSecondary)),
        dropdownColor: palette.deepest,
        underline: const SizedBox.shrink(),
        iconEnabledColor: palette.goldSoft,
        style: TypographyTokens.display(size: 18)
            .copyWith(color: palette.goldSoft),
        items: [
          for (final v in valori)
            DropdownMenuItem<int>(
              value: v,
              child: Text(v.toString().padLeft(2, '0')),
            ),
        ],
        onChanged: (v) => v == null ? null : onCambia(v),
      ),
    );
  }
}
