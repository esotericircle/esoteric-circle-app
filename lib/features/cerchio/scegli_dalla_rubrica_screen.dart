import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'widgets/disegni_del_cerchio.dart';

import '../../core/brand/brand.dart';
import '../../core/cerchio/il_cerchio_sociale.dart';
import '../../core/cerchio/la_rubrica_del_telefono.dart';
import '../../core/condivisione/la_porta_dei_messaggi.dart';
import '../../core/entitlement/listino_degli_eos.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../design_system/transizioni/passaggio_del_cerchio.dart';

/// IL MESSAGGIO DELL'INVITO, gia' scritto. Ordine FD voce 06.5: il numero
/// degli Eos viene dal listino, mai scritto a mano nel testo.
abstract final class IlMessaggioDellInvito {
  static String testo(String link) =>
      'Ti chiamo nel mio Cerchio su ${Brand.name}. Entrando da qui ricevi '
      '${ListinoDegliEos.premioDiChiArrivaConUnInvito} Eos:\n$link';

  /// Quanti contatti per invio. FD.06.4: gli operatori bloccano gli invii
  /// identici in blocco, e un invito a tutta la rubrica non porta persone
  /// nel Cerchio.
  static const int tetto = 10;

  /// La riga che compare al tetto, alla lettera.
  static const String rigaDelTetto = 'Dieci per volta.';
}

/// SCEGLI DALLA RUBRICA. Ordine FD voce 06.
///
/// La rubrica si legge qui, in memoria, e basta: la lista vive nello stato
/// di questa schermata e si svuota quando la schermata si chiude
/// ([dispose]). Nessun contatto va al server, in un file o nelle preferenze.
/// La scelta si ferma a [IlMessaggioDellInvito.tetto]; il pulsante in fondo
/// consegna UN messaggio gia' scritto all'app dei messaggi, e l'invio lo fa
/// la persona.
class ScegliDallaRubricaScreen extends StatefulWidget {
  const ScegliDallaRubricaScreen({super.key});

  static Route<void> route() => PassaggioDelCerchio.rotta<void>((_) =>
      const MaestroScope(neutro: true, child: ScegliDallaRubricaScreen()));

  @override
  State<ScegliDallaRubricaScreen> createState() =>
      _ScegliDallaRubricaScreenState();
}

class _ScegliDallaRubricaScreenState extends State<ScegliDallaRubricaScreen> {
  List<ContattoDellaRubrica>? _contatti;
  final Set<int> _scelti = {};
  String _filtro = '';
  String? _riga;
  bool _inCorso = false;

  @override
  void initState() {
    super.initState();
    _carica();
  }

  Future<void> _carica() async {
    List<ContattoDellaRubrica> letti;
    try {
      letti =
          LaRubricaDelTelefono.scegliibili(await LaRubricaDelTelefono.leggi());
    } catch (errore) {
      // Una rubrica che non si legge e' una rubrica vuota per chi guarda:
      // la schermata lo dice e non si rompe (FD.06.9 h).
      debugPrint('La rubrica non si legge: $errore');
      letti = const [];
    }
    if (mounted) setState(() => _contatti = letti);
  }

  @override
  void dispose() {
    // FD.06.3: alla chiusura la lista in memoria si svuota.
    _contatti = null;
    _scelti.clear();
    super.dispose();
  }

  void _tocca(int i) {
    setState(() {
      if (_scelti.contains(i)) {
        _scelti.remove(i);
      } else {
        // Al tetto la spunta e' gia' spenta (`pieno`, qui sotto): un secondo
        // controllo qui era un doppione che nessuna prova poteva vedere, ed
        // e' stato tolto (Regola A, ordine FD, innesto A27).
        _scelti.add(i);
      }
    });
  }

  Future<void> _manda() async {
    final contatti = _contatti;
    if (contatti == null || _scelti.isEmpty || _inCorso) return;
    setState(() {
      _inCorso = true;
      _riga = null;
    });
    final sociale = context.read<IlCerchioSociale>();
    final codice = await sociale.codiceDelLink();
    if (!mounted) return;
    if (codice == null) {
      setState(() {
        _inCorso = false;
        _riga = EsitoDelGesto.silenzio.riga;
      });
      return;
    }
    final numeri = [for (final i in _scelti) contatti[i].numero];
    final aperta = await LaPortaDeiMessaggi.consegna(
        numeri, IlMessaggioDellInvito.testo(IlCerchioSociale.linkDi(codice)));
    if (!mounted) return;
    setState(() {
      _inCorso = false;
      _riga =
          aperta ? null : 'L’app dei messaggi non si apre su questo telefono.';
    });
    if (aperta) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    const palette = MaestroPalette.neutral;
    final contatti = _contatti;
    final corpo =
        TypographyTokens.corpo().copyWith(color: ColorTokens.textPrimary);
    final pieno = _scelti.length >= IlMessaggioDellInvito.tetto;
    Widget elenco;
    if (contatti == null) {
      elenco = const Center(child: CircularProgressIndicator());
    } else if (contatti.isEmpty) {
      elenco = Padding(
        padding: const EdgeInsets.all(SpacingTokens.lg),
        child: Text('Nella tua rubrica non ci sono contatti con un numero.',
            key: const Key('rubrica_vuota'), style: corpo),
      );
    } else {
      final f = _filtro.trim().toLowerCase();
      final visibili = [
        for (var i = 0; i < contatti.length; i++)
          if (f.isEmpty || contatti[i].nome.toLowerCase().contains(f)) i,
      ];
      elenco = ListView.builder(
        key: const Key('rubrica_elenco'),
        itemCount: visibili.length,
        itemBuilder: (c, k) {
          final i = visibili[k];
          final scelto = _scelti.contains(i);
          return CheckboxListTile(
            key: Key('rubrica_$i'),
            value: scelto,
            activeColor: palette.gold,
            checkColor: palette.onPrimary,
            // Al tetto le spunte non si attivano piu' (FD.06.4).
            onChanged: scelto || !pieno ? (_) => _tocca(i) : null,
            title: Text(contatti[i].nome, style: corpo),
            subtitle: Text(contatti[i].numero,
                style: TypographyTokens.didascalia()
                    .copyWith(color: ColorTokens.textSecondary)),
          );
        },
      );
    }
    // Lo stesso cielo e la stessa soglia dei quattordici anni delle altre
    // schermate del Cerchio: la barra in alto sta sul cielo, non su un fondo
    // grigio (visto nell'anteprima dell'ordine FD).
    return conIPulsantiDOro(
        context,
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: palette.goldSoft),
            title: Text('Chiama chi conosci',
                style: TypographyTokens.titoloDiSchermata()
                    .copyWith(color: palette.goldSoft)),
          ),
          body: SafeArea(
            top: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (contatti != null && contatti.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(SpacingTokens.md,
                        SpacingTokens.xs, SpacingTokens.md, SpacingTokens.xs),
                    child: TextField(
                      key: const Key('rubrica_ricerca'),
                      maxLength: 40,
                      style: corpo,
                      onChanged: (v) => setState(() => _filtro = v),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search_rounded),
                        hintText: 'Cerca un nome',
                        counterText: '',
                      ),
                    ),
                  ),
                Expanded(child: elenco),
                if (pieno)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: SpacingTokens.md),
                    child: Text(IlMessaggioDellInvito.rigaDelTetto,
                        key: const Key('rubrica_tetto'),
                        textAlign: TextAlign.center,
                        style: corpo.copyWith(color: palette.goldSoft)),
                  ),
                if (_riga != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: SpacingTokens.md),
                    child: Text(_riga!,
                        key: const Key('rubrica_riga'),
                        textAlign: TextAlign.center,
                        style: corpo),
                  ),
                if (contatti != null && contatti.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(SpacingTokens.md),
                    child: FilledButton(
                      key: const Key('rubrica_manda'),
                      onPressed: _scelti.isEmpty || _inCorso ? null : _manda,
                      style: FilledButton.styleFrom(
                        backgroundColor: palette.gold,
                        foregroundColor: palette.onPrimary,
                        minimumSize: const Size.fromHeight(52),
                      ),
                      child: Text('Manda l’invito',
                          style: TypographyTokens.etichetta()),
                    ),
                  ),
              ],
            ),
          ),
        ));
  }
}
