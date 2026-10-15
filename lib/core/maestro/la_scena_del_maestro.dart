import 'maestro.dart';

/// **LA SCENA DI OGNI MAESTRO**, ordine FW, 15 ottobre 2026: il video, il
/// primo e l'ultimo fotogramma per il dominio e per la chat, un punto solo.
///
/// I file nel ramo dicono il POSTO in cui vivono nell'app (FW.01), non la
/// cartella da cui vengono: i due video di Caligo sono scambiati (FW.05,
/// il fondatore, 15 ottobre 2026: *"l'ultimo video di Caligo dove lo avvolge
/// il fuoco, io lo userei per il suo dominio essendo di forte impatto e
/// l'altro per la chat"*), e il nome nel ramo riflette gia' lo scambio: lo
/// script `tool/gli_asset_dell_ordine_fw.py` lo porta cosi'.
class LaScenaDelMaestro {
  const LaScenaDelMaestro._({
    required this.video,
    required this.primoFotogramma,
    required this.ultimoFotogramma,
  });

  /// Il video, in `brand_assets/maestri_scena/`.
  final String video;

  /// La scena ferma prima che il video sia pronto, in
  /// `assets/img/maestri_scena/`.
  final String primoFotogramma;

  /// La scena ferma dopo il video, con Riduci Movimento, con la grafica
  /// alleggerita o se il video non si carica.
  final String ultimoFotogramma;

  static LaScenaDelMaestro _di(String posto) => LaScenaDelMaestro._(
        video: 'brand_assets/maestri_scena/${posto}_v1.mp4',
        primoFotogramma:
            'assets/img/maestri_scena/${posto}_primo_fotogramma_v1.webp',
        ultimoFotogramma:
            'assets/img/maestri_scena/${posto}_ultimo_fotogramma_v1.webp',
      );

  /// La scena del dominio di [maestro], all'apertura della sua home.
  static LaScenaDelMaestro delDominio(Maestro maestro) =>
      _di('${maestro.id}_dominio');

  /// La scena della chat di [maestro], prima del primo messaggio.
  static LaScenaDelMaestro dellaChat(Maestro maestro) =>
      _di('${maestro.id}_chat');
}
