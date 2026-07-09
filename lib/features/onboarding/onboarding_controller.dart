import 'package:flutter/material.dart';

import '../../core/astro/birth_details.dart';
import '../../core/astro/birth_place.dart';

/// I passi dell'onboarding Il Risveglio.
enum OnboardingStep { date, time, place, gender }

/// Flag di sola revisione (spento di default): precompila data e luogo per
/// scorrere velocemente il flusso ai checkpoint. Si attiva con
/// `--dart-define=DEMO_AUTOFILL=true`, non influisce sulla produzione.
const bool _kDemoAutofill = bool.fromEnvironment('DEMO_AUTOFILL');

/// Stato dei dati raccolti nell'onboarding.
///
/// Data e luogo sono obbligatori; ora e genere opzionali. Nessun contatto: la
/// registrazione e' progressiva e anonima, il telefono non entra mai nel form.
class OnboardingController extends ChangeNotifier {
  DateTime? _date;
  TimeOfDay? _time;
  bool _timeUnknown = false;
  BirthPlace? _place;
  Gender? _gender;
  int _stepIndex = 0;

  OnboardingController() {
    if (_kDemoAutofill) {
      _date = DateTime(1990, 6, 15);
      _time = const TimeOfDay(hour: 14, minute: 30);
      _place = const BirthPlace(
        label: 'Roma',
        province: 'RM',
        latitude: 41.9028,
        longitude: 12.4964,
        timezone: 'Europe/Rome',
      );
    }
  }

  DateTime? get date => _date;
  TimeOfDay? get time => _time;
  bool get timeUnknown => _timeUnknown;
  BirthPlace? get place => _place;
  Gender? get gender => _gender;

  int get stepIndex => _stepIndex;
  OnboardingStep get step => OnboardingStep.values[_stepIndex];
  int get stepsCount => OnboardingStep.values.length;
  bool get isLastStep => _stepIndex == stepsCount - 1;

  bool get dateValid => _date != null;
  bool get placeValid => _place != null;

  /// Se il passo corrente permette di proseguire.
  bool get canProceed => switch (step) {
        OnboardingStep.date => dateValid,
        OnboardingStep.time => true, // opzionale
        OnboardingStep.place => placeValid,
        OnboardingStep.gender => true, // opzionale
      };

  /// Tutti i dati obbligatori presenti.
  bool get isComplete => dateValid && placeValid;

  void setDate(DateTime value) {
    _date = value;
    notifyListeners();
  }

  void setTime(TimeOfDay? value) {
    _time = value;
    if (value != null) _timeUnknown = false;
    notifyListeners();
  }

  void setTimeUnknown(bool value) {
    _timeUnknown = value;
    if (value) _time = null;
    notifyListeners();
  }

  void setPlace(BirthPlace value) {
    _place = value;
    notifyListeners();
  }

  void setGender(Gender? value) {
    _gender = value;
    notifyListeners();
  }

  void goToStep(int index) {
    _stepIndex = index.clamp(0, stepsCount - 1);
    notifyListeners();
  }

  void next() => goToStep(_stepIndex + 1);
  void back() => goToStep(_stepIndex - 1);

  /// Costruisce i dettagli di nascita, o null se manca un obbligatorio.
  BirthDetails? build() {
    if (!isComplete) return null;
    return BirthDetails(
      date: _date!,
      place: _place!,
      time: _timeUnknown ? null : _time,
      gender: _gender,
    );
  }
}
