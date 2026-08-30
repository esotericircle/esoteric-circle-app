import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/archetypes/archetype.dart';
import '../../core/chat/maestro_memory.dart';
import '../../core/maestro/frasi_dell_attesa.dart';
import '../../core/maestro/maestro.dart';
import '../../core/maestro/natal_context.dart';
import '../../core/maestro/simbolo_dellattesa.dart';
import 'loto_dorato.dart';
import '../../core/maestro/tempi_dell_attesa.dart';
import '../../core/quality/quality_tier.dart';
import '../theme/maestro_scope.dart';
import '../tokens/spacing_tokens.dart';
import '../tokens/typography_tokens.dart';

/// L'ATTESA SI DEVE POTER LEGGERE.
///
/// Vive nel design system e non dentro la chat perche' le superfici che
/// aspettano una risposta sono DUE, la chat e il Consulta.
///
/// **Cosa c'era prima, e perche' e' cambiato.** La scena mostrava il corpo
/// celeste che il Maestro stava guardando, un emblema di segno oppure il disco
/// lunare, e le righe si succedevano ogni 1,6 secondi. Il fondatore lo ha
/// guardato sul telefono: le frasi sono scritte per essere lette e non se ne
/// aveva il tempo, sembravano sei difetti di seguito. E l'emblema cambiava con
/// la riga, quindi la scena non aveva un centro.
///
/// **La scena adesso.** Un SIMBOLO solo, al centro, che si compone dall'alto
/// verso il basso in tre secondi e poi resta fermo e pieno. Sotto, centrata,
/// una frase alla volta, due secondi netti ciascuna. Il minimo garantito e' di
/// due frasi intere: se la risposta arriva prima, la scena finisce comunque il
/// suo minimo. Se tarda, le frasi ricominciano dalla prima SENZA che il
/// simbolo si ricomponga, perche' un caricamento che riparte da zero dice che
/// qualcosa e' andato storto, mentre non e' andato storto niente.
///
/// **IL SIMBOLO E' DELLA PERSONA, non il volto del Maestro.** Qui si accendeva
/// il ritratto di chi stava rispondendo: era una lettura sbagliata di cio' che
/// era stato chiesto. Il segno di Medora, l'animale guida di Caligo,
/// l'archetipo di Aura: quale sia lo dice [SimboloDellAttesa], che e' l'unico
/// punto che lo sa. Il volto del Maestro sta gia' nell'intestazione della chat
/// e accanto a ogni sua bolla.
///
/// **E si COMPONE, non si colora.** L'accensione da grigio a colore e' uscita
/// per intero, matrice compresa: un tratto che scende dall'alto dice "sto
/// scrivendo qualcosa per te", una cosa che si colora dice "sto caricando
/// un'immagine".
///
/// **Le frasi dicono il vero.** Nascono da [FrasiDellAttesa], che le lascia
/// passare solo quando il dato che nominano e' davvero nel contesto che parte
/// verso il modello.
///
/// Con Riduci Movimento o Quality Tier basso l'emblema c'e' ed e' GIA' a
/// colori, e nessun controllore viene creato: non uno lasciato fermo, proprio
/// nessuno.
class ConsultoDelCieloView extends StatefulWidget {
  const ConsultoDelCieloView({
    super.key,
    required this.natal,
    this.maestro,
    this.memoria = MaestroMemory.empty,
    this.archetipo,
    this.rotazione = 0,
    this.durataFrase = TempiDellAttesa.durataBattuta,
  });

  /// I dati di questa persona. Decidono QUALI frasi si possono dire.
  final NatalContext natal;

  /// Chi sta consultando. Le frasi sono sue, dal suo mestiere: nessuna riga e'
  /// condivisa fra i tre.
  final Maestro? maestro;

  /// La memoria del Maestro con questa persona. Anche lei decide una frase.
  final MaestroMemory memoria;

  /// L'archetipo gia' scoperto col Test, se c'e'. E' il simbolo di Aura.
  /// Nullo vuol dire "non ancora scoperto", e non "non ne ha uno".
  final Archetype? archetipo;

  /// Quale giro di frasi. Cresce a ogni domanda, cosi' due attese vicine non
  /// aprono sulla stessa riga.
  final int rotazione;

  /// Quanto resta a schermo ogni frase. Il valore vive in [TempiDellAttesa]:
  /// qui c'e' solo il modo di scavalcarlo in una prova.
  final Duration durataFrase;

  /// Il lato del simbolo quando lo spazio abbonda.
  static const double tettoDelCorpo = 220;

  /// Il lato sotto il quale non si stringe: piu' giu' il simbolo diventa una
  /// macchia, e una macchia non dice niente a nessuno.
  static const double pavimentoDelCorpo = 72;

  /// Gli stacchi fra le righe della colonna, piu' il rientro verticale.
  static const double stacchiERientri = 12 + 16 + 16;

  /// Quanto chiede la riga sotto l'emblema, MISURATA sulla frase vera.
  ///
  /// Non e' una costante, e non lo e' per un motivo pagato: una costante
  /// peggiore-caso era gia' stata scritta, valeva 130 e sforava lo stesso,
  /// perche' basta una frase nuova o una lingua nuova e smette di essere il
  /// peggiore senza che nessuno lo dica.
  static double riservaPer(String frase, double larghezza, {String? invito}) {
    final utile = larghezza - SpacingTokens.lg * 2;
    final massimo = utile > 0 ? utile : larghezza;
    double alta(String testo, TextStyle stile) => (TextPainter(
          text: TextSpan(text: testo, style: stile),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        )..layout(maxWidth: massimo))
        .height;

    var somma = alta(frase, TypographyTokens.titoloScheda());
    // **ANCHE L'INVITO OCCUPA SPAZIO.** Senza questa riga la scena sforava di
    // 1,7 pixel appena Aura, senza archetipo, aggiungeva la riga che invita al
    // Test: la riserva misurava una riga e a schermo ne comparivano due.
    if (invito != null) {
      somma += SpacingTokens.sm + alta(invito, TypographyTokens.body(size: 16));
    }
    return somma + stacchiERientri;
  }

  /// Quanto e' grande l'emblema dato lo spazio libero.
  static double corpoPer(double altezzaLibera, double riserva) =>
      (altezzaLibera - riserva).clamp(pavimentoDelCorpo, tettoDelCorpo);

  @override
  State<ConsultoDelCieloView> createState() => _ConsultoDelCieloViewState();
}

class _ConsultoDelCieloViewState extends State<ConsultoDelCieloView>
    with SingleTickerProviderStateMixin {
  /// La composizione, gia' curvata. NULLA a moto fermo, e non creata e
  /// lasciata ferma: un controllore che nessuno fa girare resta un ticker
  /// registrato nell'albero.
  Animation<double>? _composizione;

  /// Il motore sotto la curva, tenuto per poterlo chiudere.
  AnimationController? _motore;

  Timer? _passo;
  int _corrente = 0;

  /// Quanto dura una battuta per QUESTA scena. Vedi didChangeDependencies.
  Duration _durataDellaBattuta = TempiDellAttesa.durataBattuta;
  List<String> _frasi = const [];
  bool _avviata = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_avviata) return;
    _avviata = true;

    _frasi = FrasiDellAttesa.per(
      widget.maestro ?? Maestro.medora,
      natal: widget.natal,
      memoria: widget.memoria,
    );
    // La rotazione sposta il punto di partenza, non l'ordine.
    if (_frasi.isNotEmpty) _corrente = widget.rotazione % _frasi.length;

    // LA BATTUTA SI ALLARGA QUANDO SOTTO C'E' UN INVITO DA LEGGERE, cioe' oggi
    // solo per Aura prima del Test. Si chiede al modello invece di dedurlo dal
    // Maestro: se domani un altro Maestro avesse un invito, la scena si
    // adeguerebbe da sola.
    final simbolo = SimboloDellAttesa.per(
      widget.maestro ?? Maestro.medora,
      natal: widget.natal,
      archetipo: widget.archetipo,
    );
    _durataDellaBattuta = simbolo.invito == null
        ? widget.durataFrase
        : TempiDellAttesa.durataBattutaConInvito;

    if (_fermo) return;
    // IL TRATTO SCENDE DA ZERO A UNO nei tre secondi gia' approvati.
    //
    // `easeInOut` senza intervallo: qui non c'e' piu' nessun grigio da tenere
    // fermo prima di salire, perche' non c'e' piu' nessuna colorazione. Un
    // tratto che si disegna e' leggibile dal primo istante, che e' proprio la
    // ragione per cui la colorazione e' uscita.
    final motore = AnimationController(
      vsync: this,
      duration: TempiDellAttesa.composizioneDelSimbolo,
    );
    _composizione = CurvedAnimation(parent: motore, curve: Curves.easeInOut);
    _motore = motore;
    motore.forward();
    _passo = Timer.periodic(_durataDellaBattuta, (_) {
      if (!mounted || _frasi.isEmpty) return;
      // SI RICOMINCIA DALLA PRIMA, e l'emblema non si scolora: il controllore
      // della colorazione non viene toccato qui.
      setState(() => _corrente = (_corrente + 1) % _frasi.length);
    });
  }

  /// Vero quando il moto e' spento, per scelta di sistema o per qualita' bassa.
  bool get _fermo =>
      MediaQuery.of(context).disableAnimations ||
      context.read<QualityTierController>().tier == QualityTier.low;

  @override
  void dispose() {
    _passo?.cancel();
    _motore?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final maestro = widget.maestro ?? Maestro.medora;
    final frase = _frasi.isEmpty ? '' : _frasi[_corrente % _frasi.length];
    final simbolo = SimboloDellAttesa.per(maestro,
        natal: widget.natal, archetipo: widget.archetipo);

    return LayoutBuilder(builder: (context, vincoli) {
      final libero = vincoli.maxHeight.isFinite && vincoli.maxHeight > 0
          ? vincoli.maxHeight
          : MediaQuery.of(context).size.height;
      final larghezza = vincoli.maxWidth.isFinite && vincoli.maxWidth > 0
          ? vincoli.maxWidth
          : MediaQuery.of(context).size.width;
      final riserva = ConsultoDelCieloView.riservaPer(frase, larghezza,
          invito: simbolo.invito);
      // TRE GRADINI, E IL TERZO E' IL VUOTO.
      //
      // Con la conversazione piena lo spazio libero misurato nella chat vera
      // scende a 48,3 punti mentre la riga ne chiede oltre cento: una riga
      // schiacciata sotto un emblema schiacciato non e' una scena piu'
      // piccola, e' un guasto. La bolla in attesa sotto dice gia' che il
      // Maestro sta rispondendo.
      if (libero < riserva) return const SizedBox.shrink();
      final ciSta = libero >= ConsultoDelCieloView.pavimentoDelCorpo + riserva;
      final lato = ConsultoDelCieloView.corpoPer(libero, riserva);

      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.lg,
          vertical: SpacingTokens.md,
        ),
        child: Column(
          key: const Key('consulto_del_cielo'),
          mainAxisSize: MainAxisSize.min,
          children: [
            // La figura entra dallo STESSO ritaglio che scende, sia che venga
            // da un file sia che sia disegnata: il loto si compone come gli
            // altri simboli, e non c'e' un secondo modo di farla comparire.
            if (ciSta && (simbolo.asset != null || simbolo.loto)) ...[
              _SimboloCheSiCompone(
                key: const Key('consulto_corpo'),
                figura: simbolo.loto
                    ? LotoDorato(lato: lato, colore: palette.gold)
                    : Image.asset(
                        simbolo.asset!,
                        width: lato,
                        height: lato,
                        fit: BoxFit.contain,
                        // Se un simbolo manca dal bundle la scena non si rompe
                        // e non mente: resta lo spazio vuoto e la frase sotto
                        // continua a dire il vero.
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                lato: lato,
                composizione: _composizione,
              ),
              const SizedBox(height: SpacingTokens.sm),
            ],
            // UNA FRASE ALLA VOLTA, e senza dissolvenza incrociata: due righe
            // sovrapposte a meta' transizione erano illeggibili, e l'anteprima
            // del 3 agosto 2026 le mostrava accavallate.
            Text(
              frase,
              key: ValueKey('consulto_frase_$_corrente'),
              textAlign: TextAlign.center,
              style: TypographyTokens.titoloScheda()
                  .copyWith(color: palette.textPrimary),
            ),
            // L'INVITO, solo quando il simbolo manca DAVVERO.
            //
            // Oggi capita a una sola persona in un solo caso: chi non ha
            // ancora fatto il Test Archetipo, mentre aspetta Aura. La riga
            // dice cosa manca e come farlo nascere, invece di mostrare al
            // posto suo un simbolo che direbbe una cosa falsa.
            if (simbolo.invito != null) ...[
              const SizedBox(height: SpacingTokens.sm),
              Text(
                simbolo.invito!,
                key: const Key('consulto_invito'),
                textAlign: TextAlign.center,
                // CORPO 16, non 14: e' l'unica riga che dice cosa manca e
                // come farlo nascere, e a 14 in oro all'85 per cento si
                // leggeva come una nota a pie' di pagina.
                style: TypographyTokens.body(size: 16).copyWith(
                  color: palette.goldSoft.withValues(alpha: 0.85),
                ),
              ),
            ],
          ],
        ),
      );
    });
  }
}

/// IL SIMBOLO CHE SI COMPONE DALL'ALTO VERSO IL BASSO.
///
/// **Come e' fatto, e perche' cosi'.** Un `ClipRect` con un rettangolo alto
/// quanto la frazione gia' composta, ancorato in cima: l'immagine si scopre
/// scendendo, come un tratto che viene giu'. Non e' una dissolvenza e non e'
/// una colorazione, ed e' la differenza che si vede: una cosa che si disegna
/// dice "sto scrivendo qualcosa per te", una cosa che sbiadisce dentro dice
/// "sto caricando un'immagine".
///
/// Con [composizione] nulla il simbolo e' gia' intero e non si muove: e' il
/// ramo di Riduci Movimento, dove non esiste nessun controllore da far girare.
class _SimboloCheSiCompone extends StatelessWidget {
  const _SimboloCheSiCompone({
    super.key,
    required this.figura,
    required this.lato,
    required this.composizione,
  });

  /// LA FIGURA, che puo' essere un'immagine oppure un disegno.
  ///
  /// Prima era un percorso e qui dentro si costruiva l'`Image.asset`. Non
  /// bastava piu': il loto di Aura non e' un file, e un ritaglio che sa
  /// scoprire solo immagini avrebbe costretto a un secondo ritaglio per il
  /// disegno, cioe' a due modi diversi di far comparire la stessa cosa.
  final Widget figura;
  final double lato;
  final Animation<double>? composizione;

  @override
  Widget build(BuildContext context) {
    final immagine = figura;
    final vivo = composizione;
    if (vivo == null) {
      return SizedBox(width: lato, height: lato, child: immagine);
    }
    return SizedBox(
      width: lato,
      height: lato,
      child: AnimatedBuilder(
        animation: vivo,
        builder: (context, figlio) => ClipRect(
          clipper: _TrattoCheScende(vivo.value),
          child: figlio,
        ),
        child: immagine,
      ),
    );
  }
}

/// Il rettangolo che scende: ancorato in cima, alto quanto la frazione fatta.
class _TrattoCheScende extends CustomClipper<Rect> {
  const _TrattoCheScende(this.quanto);

  final double quanto;

  @override
  Rect getClip(Size size) => Rect.fromLTWH(
        0,
        0,
        size.width,
        size.height * quanto.clamp(0.0, 1.0),
      );

  @override
  bool shouldReclip(_TrattoCheScende vecchio) => vecchio.quanto != quanto;
}
