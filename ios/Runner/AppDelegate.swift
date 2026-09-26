import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    // LO SCHERMO RESTA ACCESO NEL LIVE. Ordine EK, guasto trovato alla prova
    // sul Realme del 24 settembre 2026: il LIVE si fa parlando senza toccare
    // il telefono, e con lo schermo spento il microfono tace e il LIVE si
    // chiude. Su iOS e' il timer di inattivita' da sospendere, finche' la
    // schermata del LIVE e' aperta.
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "LoSchermoAcceso") {
      let canale = FlutterMethodChannel(
        name: "esoteric_circle/schermo", binaryMessenger: registrar.messenger())
      canale.setMethodCallHandler { chiamata, risposta in
        guard chiamata.method == "tieniAcceso" else {
          risposta(FlutterMethodNotImplemented)
          return
        }
        let acceso = (chiamata.arguments as? Bool) ?? false
        DispatchQueue.main.async {
          UIApplication.shared.isIdleTimerDisabled = acceso
          risposta(nil)
        }
      }
    }
  }
}
