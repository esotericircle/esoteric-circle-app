import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/astro/zodiac.dart';
import '../../core/identity/device_id.dart';
import '../../core/identity/natal_identity.dart';
import '../../core/identity/profile_controller.dart';
import '../../core/maestro/maestro.dart';
import '../../core/rituals/sunset_rune.dart';
import '../../design_system/components/zodiac_glyph.dart';
import '../scene/la_scena_in_video.dart';

/// **IL PUNTO DEL PALMO**, in pixel del fotogramma dipinto (1080 per 1920),
/// e la larghezza del dono che ci si posa sopra, nella stessa misura.
class IlPalmo {
  const IlPalmo({required this.x, required this.y, required this.larghezza});

  /// Il centro del dono, da sinistra.
  final double x;

  /// Il centro del dono, dall'alto.
  final double y;

  /// Quanto e' largo il dono sul fotogramma.
  final double larghezza;
}

/// **IL DONO NEL PALMO DEL MAESTRO, ordine GD voci GD.01 e GD.02, 23 ottobre
/// 2026.** Il fondatore: *"nei video di ingresso ai domini mancano le
/// personalizzazioni promesse: Medora alla fine mostra la mano aperta e
/// dovrebbe comparire il segno zodiacale dell'utente, ma non compare"*, e per
/// Caligo *"nella sua mano aperta dovrebbe comparire la runa del tramonto del
/// giorno"*.
///
/// Il dono e' un pezzo DIPINTO gia' nel ramo (R8): l'emblema del segno
/// solare per Medora (`assets/img/zodiac/`), la pietra della runa per Caligo
/// (`assets/img/rune_bone/`). Il codice lo sceglie e lo posa sul palmo
/// dell'ultimo fotogramma, non disegna niente.
///
/// **AURA NON HA ANCORA IL SUO DONO (GD.03).** Il chakra del giorno esiste
/// come dato (`ChakraDelGiorno.di`), ma nel ramo non c'e' nessun simbolo
/// dipinto dei sette chakra: disegnarlo in codice violerebbe R8, quindi il
/// palmo di Aura resta vuoto finche' il fondatore non porta le sette arti.
abstract final class IlDonoNelPalmo {
  /// La misura dei fotogrammi di scena dei Maestri (e dei loro video),
  /// letta coi file: `assets/img/maestri_scena/*_ultimo_fotogramma_v1.webp`
  /// e `brand_assets/maestri_scena/*.mp4` sono tutti 1080 per 1920.
  static const Size fotogramma = Size(1080, 1920);

  /// **IL PALMO DI MEDORA**, misurato sull'ultimo fotogramma del dominio
  /// (`medora_dominio_ultimo_fotogramma_v1.webp`) con un righello a passo
  /// venti pixel sovrapposto al ritaglio ingrandito tre volte: la mano tesa
  /// va da x 160 (la punta delle dita) a x 320 (il polso), il palmo aperto
  /// sta fra y 970 e y 1060. Il segno si posa appena sopra il palmo, nella
  /// scia di polvere d'oro che la mano solleva: centro a x 245 e y 915,
  /// largo 140 pixel, cosi' il suo bordo basso sfiora le dita senza coprirle.
  static const IlPalmo palmoDiMedora = IlPalmo(x: 245, y: 915, larghezza: 140);

  /// **IL PALMO DI CALIGO**, misurato sull'ultimo fotogramma della scena col
  /// cerchio di fuoco verde (`caligo_dominio_ultimo_fotogramma_v1.webp`
  /// dopo lo scambio della GD.02), con lo stesso righello ingrandito due
  /// volte: la mano aperta e' in basso a y 1100, l'anello di fuoco le sta
  /// sopra e il suo vuoto va da x 745 a x 880 e da y 800 a y 1060. La pietra
  /// si posa al centro di quel vuoto, x 812 e y 935, larga 112 pixel: sta
  /// dentro la fiamma come un oggetto tenuto dalla mano.
  static const IlPalmo palmoDiCaligo = IlPalmo(x: 812, y: 935, larghezza: 112);

  /// Il palmo di [maestro], oppure nullo se non ha ancora un dono.
  static IlPalmo? palmoDi(Maestro maestro) => switch (maestro) {
        Maestro.medora => palmoDiMedora,
        Maestro.caligo => palmoDiCaligo,
        Maestro.aura => null,
      };

  /// Il dono di Medora: l'emblema dipinto del segno solare.
  static String segnoDiMedora(Zodiac segno) => ZodiacArt.emblemPath(segno);

  /// Il dono di Caligo: la runa del tramonto di [adesso] per [identita], dalla
  /// stessa estrazione della schermata del rituale (`SunsetRune.estrai`).
  static EstrazioneTramonto runaDiCaligo(DateTime adesso, String identita) =>
      SunsetRune.estrai(adesso, identita: identita);

  /// **DOVE CADE IL PALMO SULLO SCHERMO.** Il fotogramma e il video stanno in
  /// [scatola] con `BoxFit.cover` centrato: la stessa scala per i due assi
  /// (la maggiore delle due), e l'eccedenza tagliata a meta' per parte. Il
  /// riquadro e' largo quanto il dono e alto [altezzaSuLarghezza] volte.
  static Rect riquadroSulloSchermo(
    IlPalmo palmo,
    Size scatola, {
    double altezzaSuLarghezza = 1.15,
  }) {
    final scala = math.max(
        scatola.width / fotogramma.width, scatola.height / fotogramma.height);
    final dx = (scatola.width - fotogramma.width * scala) / 2;
    final dy = (scatola.height - fotogramma.height * scala) / 2;
    final larghezza = palmo.larghezza * scala;
    return Rect.fromCenter(
      center: Offset(dx + palmo.x * scala, dy + palmo.y * scala),
      width: larghezza,
      height: larghezza * altezzaSuLarghezza,
    );
  }
}

/// **IL DONO POSATO SUL PALMO**, sopra l'ultimo fotogramma del dominio.
///
/// Sta nello stesso riquadro della scena (chi lo monta lo mette nello stesso
/// `Transform.translate` del fotogramma) e compare come il resto della
/// schermata ([IlRestoDopoLaScena]): mai mentre il video gira, in
/// dissolvenza quando finisce o lo si salta, subito quando la scena e'
/// ferma dalla prima immagine (Riduci Movimento, grafica alleggerita, video
/// che non si carica).
class IlDonoSulPalmo extends StatefulWidget {
  const IlDonoSulPalmo({
    super.key,
    required this.maestro,
    required this.scenaFerma,
    required this.subito,
    this.adesso,
  });

  final Maestro maestro;

  /// La scena e' ferma sul suo ultimo fotogramma ([RegiaDellaScena.ferma]).
  final bool scenaFerma;

  /// Nessun video e' stato in scena: il dono compare senza dissolvenza.
  final bool subito;

  /// L'ora da cui si legge la runa del tramonto. Nulla vuol dire adesso;
  /// la passano le prove per fissare il giorno.
  final DateTime? adesso;

  @override
  State<IlDonoSulPalmo> createState() => _IlDonoSulPalmoState();
}

class _IlDonoSulPalmoState extends State<IlDonoSulPalmo> {
  /// L'identita' della runa del tramonto: la nascita quando c'e', altrimenti
  /// l'id del dispositivo, come nella schermata del rituale
  /// (`SunsetRuneScreen._prepara`), cosi' la pietra nel palmo e' quella che
  /// la persona trovera' gettando la runa stasera.
  String? _identita;
  DateTime? _nascitaLetta;
  bool _oraLetta = false;
  bool _chiesta = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.maestro != Maestro.caligo) return;
    final id = _forse<ProfileController>(context)?.identity;
    final nascita = (id == null || id.isExample) ? null : id.birthMoment;
    final oraNota = nascita != null && id!.hasBirthTime;
    if (_chiesta && nascita == _nascitaLetta && oraNota == _oraLetta) return;
    _chiesta = true;
    _nascitaLetta = nascita;
    _oraLetta = oraNota;
    if (nascita != null) {
      _identita = SunsetRune.identitaPer(
          nascita: nascita, oraNota: oraNota, deviceId: '');
      return;
    }
    _identita = null;
    DeviceId.corrente().then((deviceId) {
      if (!mounted || _nascitaLetta != null) return;
      setState(() => _identita = deviceId);
    });
  }

  T? _forse<T>(BuildContext context) {
    try {
      return Provider.of<T>(context);
    } catch (senzaProvider) {
      // Chi monta il dominio da solo (anteprime, prove) puo' non avere il
      // controller: il palmo resta vuoto invece di inventare un dato.
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final palmo = IlDonoNelPalmo.palmoDi(widget.maestro);
    if (palmo == null) return const SizedBox.shrink();
    String? dono;
    var capovolto = false;
    String? etichetta;
    switch (widget.maestro) {
      case Maestro.medora:
        // IL SEGNO DALLA FONTE CHE NON SI PERDE: la data di nascita
        // (`BirthIdentity.sunSign`), nullo finche' i dati sono d'esempio;
        // in sua vece la carta di nascita, come l'avatar dell'utente.
        final segno = _forse<ProfileController>(context)?.identity.sunSign ??
            _forse<BirthIdentityController>(context)?.sunSign;
        if (segno != null) {
          dono = IlDonoNelPalmo.segnoDiMedora(segno);
          etichetta = 'Il tuo segno nel palmo di Medora: ${segno.italianName}';
        }
      case Maestro.caligo:
        final identita = _identita;
        if (identita != null) {
          final e = IlDonoNelPalmo.runaDiCaligo(
              widget.adesso ?? DateTime.now(), identita);
          dono = e.rune.fullPath;
          // Il verso d'ombra si mostra capovolto, come nel rituale.
          capovolto = e.inOmbra;
          etichetta = 'La runa del tramonto nel palmo di Calìgo: '
              '${e.rune.name}${e.inOmbra ? ' (rovesciata)' : ''}';
        }
      case Maestro.aura:
        break;
    }
    if (dono == null) return const SizedBox.shrink();
    final immagine = Image.asset(
      dono,
      key: Key('dono_nel_palmo_${widget.maestro.id}'),
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      semanticLabel: etichetta,
      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
    );
    return IlRestoDopoLaScena(
      scenaFerma: widget.scenaFerma,
      subito: widget.subito,
      child: IgnorePointer(
        child: LayoutBuilder(
          builder: (context, vincoli) {
            final riquadro =
                IlDonoNelPalmo.riquadroSulloSchermo(palmo, vincoli.biggest);
            return Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fromRect(
                  rect: riquadro,
                  child: capovolto
                      ? Transform.rotate(angle: math.pi, child: immagine)
                      : immagine,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
