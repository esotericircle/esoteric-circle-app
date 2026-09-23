import 'dart:async';

import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart' as lk;

import '../../../core/maestro/maestro.dart';
import '../../../design_system/tokens/color_tokens.dart';
import '../../../design_system/tokens/spacing_tokens.dart';
import '../../../design_system/tokens/typography_tokens.dart';
import '../../../services/live/porta_del_live.dart';
import 'stato_della_schermata_live.dart';

/// **LA SCHERMATA LIVE.** Ordine EG voce 05.
///
/// **Il widget disegna e basta.** Le regole, i momenti, le frasi dei rifiuti e
/// il conto del tempo vivono in `stato_della_schermata_live.dart`, dove una
/// prova li puo' chiamare: e' la lezione dell'ordine EI, dove una frase chiusa
/// in uno `State` privato e' rimasta un anno senza che nessuna prova potesse
/// raggiungerla.
///
/// **Qui dentro resta solo cio' che ha bisogno di uno schermo**: la stanza di
/// LiveKit, il riquadro del video e la tastiera.
class SchermataLive extends StatefulWidget {
  const SchermataLive({super.key, required this.maestro});

  final Maestro maestro;

  @override
  State<SchermataLive> createState() => _SchermataLiveState();
}

class _SchermataLiveState extends State<SchermataLive> {
  late QuadroDelLive _quadro =
      QuadroDelLive(momento: MomentoDelLive.siApre, maestro: widget.maestro);

  lk.Room? _stanza;
  Timer? _orologio;
  final _campo = TextEditingController();

  @override
  void initState() {
    super.initState();
    unawaited(_apri());
  }

  @override
  void dispose() {
    _orologio?.cancel();
    _campo.dispose();
    // **La stanza si chiude sempre**, anche se la persona esce col tasto
    // indietro: una stanza lasciata aperta continua a consumare minuti che
    // nessuno sta usando.
    unawaited(_stanza?.disconnect());
    super.dispose();
  }

  Future<void> _apri() async {
    try {
      final s = await PortaDelLive.apri(widget.maestro);
      final stanza = lk.Room();
      await stanza.connect(s.url, s.gettone);
      if (!mounted) {
        await stanza.disconnect();
        return;
      }
      setState(() {
        _stanza = stanza;
        _quadro = _quadro.con(
          momento: MomentoDelLive.siAspettaIlVolto,
          sessione: s,
        );
      });
      _orologio = Timer.periodic(const Duration(seconds: 1), (_) => _batti());
    } on IlLiveNonSiApre catch (e) {
      if (!mounted) return;
      setState(() {
        _quadro = _quadro.con(
          momento: MomentoDelLive.nonSiApre,
          perche: e.perche,
        );
      });
    }
  }

  /// Un secondo passa: si aggiorna il conto e si guarda se il volto e'
  /// arrivato.
  void _batti() {
    if (!mounted) return;
    final passati = _quadro.secondiPassati + 1;
    setState(() => _quadro = _quadro.con(secondiPassati: passati));

    // **Il tempo finisce qui e non sul server**, perche' il server non sa
    // quando la persona ha smesso di guardare. Il tetto lo manda lui, il
    // conto lo tiene lo schermo.
    if (_quadro.ilTempoEFinito) {
      unawaited(_chiudi());
      return;
    }

    // Il volto arriva in qualche secondo: si chiede, ma non ogni secondo.
    if (_quadro.momento == MomentoDelLive.siAspettaIlVolto &&
        passati % 3 == 0) {
      unawaited(_guardaSeIlVoltoEArrivato());
    }
  }

  Future<void> _guardaSeIlVoltoEArrivato() async {
    final id = _quadro.sessione?.sessione;
    if (id == null || id.isEmpty) return;
    final stato = await PortaDelLive.stato(id);
    if (!mounted || !stato.ilVoltoEArrivato) return;
    setState(() => _quadro = _quadro.con(momento: MomentoDelLive.vivo));
  }

  Future<void> _chiudi() async {
    _orologio?.cancel();
    await _stanza?.disconnect();
    if (!mounted) return;
    setState(() => _quadro = _quadro.con(momento: MomentoDelLive.finito));
  }

  /// **IL RIPIEGO TATTILE.** `CLAUDE.md` lo rende obbligatorio per ogni
  /// esperienza che poggia su un sensore, e qui il sensore e' il microfono.
  Future<void> _mandaScritto() async {
    final testo = _campo.text.trim();
    if (testo.isEmpty) return;
    _campo.clear();
    setState(() => _quadro = _quadro.con(sottotitolo: testo));
    // Il testo viaggia sul canale dati della stanza: il worker di Protoface lo
    // riceve come se fosse stato detto a voce.
    await _stanza?.localParticipant?.publishData(
      const Utf8Encoder().convert(testo),
      reliable: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorTokens.medoraDeepest,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(widget.maestro.displayName),
        actions: [
          if (_quadro.sessione != null)
            Padding(
              padding: const EdgeInsets.only(right: SpacingTokens.md),
              child: Center(
                child: Text(
                  key: const Key('live_tempo'),
                  _tempoAVideo(),
                  style: TypographyTokens.didascalia()
                      .copyWith(color: ColorTokens.textSecondary),
                ),
              ),
            ),
          IconButton(
            key: const Key('live_chiudi'),
            icon: const Icon(Icons.close),
            onPressed: () async {
              await _chiudi();
              if (context.mounted) Navigator.of(context).maybePop();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _ilVolto()),
            if (_quadro.sottotitolo.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(SpacingTokens.md),
                child: Text(
                  key: const Key('live_sottotitolo'),
                  _quadro.sottotitolo,
                  style: TypographyTokens.corpo(),
                  textAlign: TextAlign.center,
                ),
              ),
            if (_quadro.siPuoScrivere) _laTastiera(),
          ],
        ),
      ),
    );
  }

  String _tempoAVideo() {
    final s = _quadro.mancanoSecondi();
    final m = s ~/ 60;
    return '$m:${(s % 60).toString().padLeft(2, '0')}';
  }

  Widget _ilVolto() {
    if (_quadro.momento == MomentoDelLive.nonSiApre) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(SpacingTokens.xl),
          child: Text(
            key: const Key('live_rifiuto'),
            _quadro.laFraseDelRifiuto(),
            style: TypographyTokens.corpo(),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // **Finche' il volto non arriva si mostra il ritratto fermo del Maestro**,
    // non una rotella: chi apre il LIVE vuole vedere il Maestro, e un ritratto
    // e' gia' lui.
    final traccia = _primaTracciaVideo();
    if (traccia == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(widget.maestro.avatarAsset, height: 220),
            const SizedBox(height: SpacingTokens.lg),
            Text(
              key: const Key('live_attesa'),
              _quadro.momento == MomentoDelLive.siApre
                  ? 'Sto arrivando.'
                  : 'Un momento, e sono con te.',
              style: TypographyTokens.corpo(),
            ),
          ],
        ),
      );
    }
    return lk.VideoTrackRenderer(traccia);
  }

  lk.VideoTrack? _primaTracciaVideo() {
    final altri = _stanza?.remoteParticipants.values;
    if (altri == null) return null;
    for (final p in altri) {
      for (final t in p.videoTrackPublications) {
        final traccia = t.track;
        if (traccia is lk.VideoTrack) return traccia;
      }
    }
    return null;
  }

  Widget _laTastiera() => Padding(
        padding: const EdgeInsets.all(SpacingTokens.md),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                key: const Key('live_campo'),
                controller: _campo,
                style: TypographyTokens.corpo(),
                decoration: const InputDecoration(
                  hintText: 'Oppure scrivimi',
                ),
                onSubmitted: (_) => _mandaScritto(),
              ),
            ),
            IconButton(
              key: const Key('live_manda'),
              icon: const Icon(Icons.send),
              onPressed: _mandaScritto,
            ),
          ],
        ),
      );
}

/// Il convertitore sta qui perche' `dart:convert` porterebbe un nome che
/// confligge con quello di LiveKit.
class Utf8Encoder {
  const Utf8Encoder();
  List<int> convert(String s) => s.codeUnits;
}
