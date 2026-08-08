import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/permissions/app_permission.dart';
import '../../core/permissions/esito_del_permesso.dart';

/// Da dove arriva la foto dell'utente per la card.
enum UserPhotoSource { camera, gallery }

/// Astrazione della sorgente foto, cosi' la schermata non dipende dal plugin e
/// resta testabile senza fotocamera ne galleria.
abstract class UserPhotoService {
  /// Chiede una foto all'utente. Ritorna i byte, oppure null se l'utente
  /// annulla o nega il permesso. Nessun file resta su disco a nostro carico.
  Future<Uint8List?> pick(UserPhotoSource source);
}

/// Implementazione reale con image_picker. La foto viene letta in memoria e
/// restituita come byte: non la salviamo, non la carichiamo da nessuna parte.
class ImagePickerPhotoService implements UserPhotoService {
  ImagePickerPhotoService([ImagePicker? picker])
      : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  /// L'ESITO DELL'ULTIMA SCELTA, nei tre valori distinti.
  ///
  /// Ordine 2166, voce 2: il selettore torna una foto oppure niente, e
  /// "niente" valeva sia per chi ha annullato sia per chi ha negato il
  /// permesso per sempre. Adesso i due casi si distinguono, e la schermata
  /// puo' dire la cosa giusta invece di lasciare la card vuota in silenzio.
  EsitoDelPermesso? esitoDelPermesso;

  @override
  Future<Uint8List?> pick(UserPhotoSource source) async {
    final permesso = source == UserPhotoSource.camera
        ? AppPermission.camera
        : AppPermission.photoLibrary;
    Uint8List? scelta;
    esitoDelPermesso = await PortaDelPermesso.chiedi(
      permesso,
      richiestaDiSistema: () async {
        final file = await _picker.pickImage(
          source: source == UserPhotoSource.camera
              ? ImageSource.camera
              : ImageSource.gallery,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 88,
          preferredCameraDevice: CameraDevice.front,
        );
        if (file == null) return false;
        scelta = await file.readAsBytes();
        return true;
      },
    );
    return scelta;
  }
}

/// Stato della foto dell'utente per la Sinastria: vive solo in memoria, per la
/// durata della schermata. Se l'utente non mette una foto, resta il segnaposto
/// a costellazione. La foto entra solo nella card che l'utente decide di
/// condividere, mai su un server, mai su disco a nostro carico.
class UserPhotoController extends ChangeNotifier {
  UserPhotoController({UserPhotoService? service})
      : _service = service ?? ImagePickerPhotoService();

  final UserPhotoService _service;

  Uint8List? _bytes;
  bool _busy = false;

  /// I byte della foto scelta, oppure null se non c'e'.
  Uint8List? get bytes => _bytes;

  /// Vero se una foto e' stata scelta ed e' pronta.
  bool get hasPhoto => _bytes != null;

  /// Vero durante la scelta, per mostrare un piccolo stato di attesa.
  bool get busy => _busy;

  /// Chiede una foto dalla sorgente scelta e la tiene in memoria. Ritorna vero
  /// se ora c'e' una foto. Ogni errore del plugin si traduce in un semplice
  /// nulla di fatto: si resta col segnaposto, senza schianti.
  Future<bool> pickFrom(UserPhotoSource source) async {
    if (_busy) return _bytes != null;
    _busy = true;
    notifyListeners();
    try {
      final data = await _service.pick(source);
      if (data != null) _bytes = data;
    } catch (_) {
      // Permesso negato o plugin assente: si resta al segnaposto.
    } finally {
      _busy = false;
      notifyListeners();
    }
    return _bytes != null;
  }

  /// Precarica la foto dal profilo dell'utente (avatar gia' scelto e tenuto in
  /// locale), cosi' la Sinastria parte col volto gia' pronto invece che dal solo
  /// segnaposto. Non sovrascrive una foto gia' scelta in questa schermata.
  void seed(Uint8List? bytes) {
    if (_bytes != null) return;
    if (bytes == null || bytes.isEmpty) return;
    _bytes = bytes;
    notifyListeners();
  }

  /// Toglie la foto e torna al segnaposto a costellazione.
  void clear() {
    if (_bytes == null) return;
    _bytes = null;
    notifyListeners();
  }
}
