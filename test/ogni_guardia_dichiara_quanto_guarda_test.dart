import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// OGNI GUARDIA CHE SCORRE I SORGENTI DICHIARA QUANTO HA GUARDATO.
/// Ordine CL voce 04.
///
/// **E' la voce che vale piu' di tutte le altre di quell'ordine messe
/// insieme, perche' uccide due specie di cecita' su quattro e costa
/// pochissimo.**
///
/// Una guardia che gira su un insieme scoperto a esecuzione **diventa verde
/// quando quell'insieme e' vuoto**: non trova difetti perche' non guarda
/// niente. Nell'ordine CI ne sono state trovate quattro cosi', per caso,
/// mentre si lavorava ad altro, e tutte e quattro erano verdi.
///
/// **Le due specie che questa regola uccide.** Quella VUOTA PER COSTRUZIONE
/// non puo' nascere, perche' un insieme vuoto diventa rosso il giorno stesso.
/// Quella DEGRADATA non puo' sopravvivere, perche' la modifica che toglie il
/// bersaglio a una guardia la fa cadere **dentro lo stesso lavoro che l'ha
/// causata**, invece che tre ordini dopo.
///
/// **La forma della regola.** Chi scorre i sorgenti di `lib` passa da
/// `sorgentiDiLib()`, che il cardinale lo dichiara una volta per tutti.
/// Oppure dichiara il proprio, con un `expect` sul numero di elementi
/// guardati. Chi non fa ne' l'una ne' l'altra sta in un elenco scritto qui
/// sotto, **e quell'elenco puo' solo accorciarsi**.
void main() {
  /// **IL DEBITO, CONTATO E NON STIMATO.** Il 1 settembre 2026 le guardie che
  /// scorrono `lib` sono 108: 17 dichiarano gia' il loro cardinale, 12 sono
  /// state portate alla porta comune dall'ordine CL, e queste restano.
  ///
  /// **Non sono cieche**, e va detto: sono guardie che non hanno ancora
  /// dichiarato quanto guardano, cioe' non sappiamo se il loro verde valga.
  /// Ognuna esce da questo elenco il giorno che qualcuno la porta alla porta
  /// comune, che e' una riga sola di lavoro.
  const senzaCardinale = <String>{
    'aspetti_di_oggi_test.dart',
    'attestazione_non_ferma_la_voce_test.dart',
    'avvisi_del_rito_test.dart',
    'carta_natale_arriva_test.dart',
    'cosmo_e_interruttori_test.dart',
    'costellazione_ripetuta_test.dart',
    'dati_nascita_sbloccano_test.dart',
    'dove_si_spendono_eos_test.dart',
    'entitlement_soldi2_test.dart',
    'free_astro_client_test.dart',
    'i_nove_ereditati_test.dart',
    'i_ricordi_hanno_una_rotta_sola_test.dart',
    'i_testi_seguono_i_nomi_nuovi_test.dart',
    'il_benvenuto_e_la_dote_test.dart',
    'il_borsellino_si_aggiorna_ovunque_test.dart',
    'il_borsellino_si_vede_sempre_test.dart',
    'il_busto_e_la_forma_del_maestro_test.dart',
    'il_censimento_delle_stringhe_dice_il_vero_test.dart',
    'il_cielo_arriva_al_maestro_test.dart',
    'il_cielo_dice_da_dove_test.dart',
    'il_cielo_si_muove_test.dart',
    'il_consiglio_mostra_tre_voci_test.dart',
    'il_continua_come_restituisce_il_cammino_test.dart',
    'il_filo_si_traccia_test.dart',
    'il_gating_non_ha_fondi_bianchi_test.dart',
    'il_genere_non_si_indovina_test.dart',
    'il_giorno_si_conta_dalla_porta_test.dart',
    'il_listino_vivo_test.dart',
    'il_motore_locale_e_per_oggi_test.dart',
    'il_quaderno_dei_sogni_non_torna_test.dart',
    'il_respiro_vive_nel_soffio_test.dart',
    'il_ripiego_non_si_traveste_da_carta_test.dart',
    'il_secondo_strato_e_premium_test.dart',
    'il_suono_si_ferma_test.dart',
    'il_velo_e_uno_solo_test.dart',
    'l_alba_si_legge_test.dart',
    'l_onboarding_riconosce_e_propone_test.dart',
    'la_barra_sottile_e_la_casa_unica_test.dart',
    'la_card_vecchia_e_demolita_test.dart',
    'la_carta_natale_sopravvive_test.dart',
    'la_catena_dei_dati_di_nascita_test.dart',
    'la_celebrazione_offre_sempre_la_condivisione_test.dart',
    'la_colonna_dei_suggerimenti_non_esiste_piu_test.dart',
    'la_domanda_scelta_arriva_al_responso_test.dart',
    'la_festa_aspetta_la_riflessione_test.dart',
    'la_misura_del_ritorno_test.dart',
    'la_nota_non_mente_test.dart',
    'la_parola_voce_resta_allaudio_test.dart',
    'la_registrazione_non_interrompe_il_risveglio_test.dart',
    'la_striscia_delle_arti_anche_in_home_test.dart',
    'le_descrizioni_hanno_una_misura_sola_test.dart',
    'le_due_cose_che_non_servivano_test.dart',
    'le_frasi_della_custodia_dicono_il_vero_test.dart',
    'le_parole_dicono_tieni_premuto_test.dart',
    'le_push_dei_doni_test.dart',
    'le_sette_chiavi_del_collaudo_test.dart',
    'lo_spazio_dentro_lo_scroll_test.dart',
    'motore_audio_unico_test.dart',
    'nessun_catch_muto_test.dart',
    'niente_eco_test.dart',
    'niente_sottolineature_gialle_test.dart',
    'niente_vocativo_a_schermo_test.dart',
    'nove_arti_test.dart',
    'ogni_rotta_passa_dal_nero_test.dart',
    'ogni_sensore_ha_il_suo_ripiego_test.dart',
    'ora_di_nascita_test.dart',
    'ora_e_luogo_sopravvivono_test.dart',
    'ora_si_puo_correggere_test.dart',
    'palette_sensoriale_test.dart',
    'passport_carta_natale_test.dart',
    'porta_dati_nascita_test.dart',
    'simboli_dello_zodiaco_test.dart',
    'tarot_accordo_rovescio_test.dart',
    'tipografia_minimi_test.dart',
    'un_ripiego_non_costa_test.dart',
    'una_luna_sola_test.dart',
    'una_sola_porta_per_i_transiti_test.dart',
    'una_spirale_per_volta_test.dart',
    'una_voce_alla_volta_test.dart',
  };

  test('chi scorre i sorgenti dichiara quanto ha guardato', () {
    final nudi = <String>[];
    var scorrono = 0;
    for (final f in Directory('test').listSync()) {
      if (f is! File || !f.path.endsWith('_test.dart')) continue;
      final nome = f.path.split(Platform.pathSeparator).last;
      final testo = f.readAsStringSync();
      if (!testo.contains("Directory('lib')")) continue;
      scorrono++;
      if (testo.contains('sorgentiDiLib(') || testo.contains('righeDiLib(')) {
        continue;
      }
      if (RegExp(r'expect\((quanti|guardati|controllate|usi|trovate|censiti|'
              r'esaminate|contate|[a-zA-Z]+\.length), greaterThan')
          .hasMatch(testo)) {
        continue;
      }
      if (senzaCardinale.contains(nome)) continue;
      nudi.add(nome);
    }

    // Senza questa riga, il giorno che nessuna guardia scorresse piu' i
    // sorgenti questa prova sarebbe verde avendo guardato zero guardie: e'
    // la stessa cecita' che sta sorvegliando, applicata a se stessa.
    expect(scorrono, greaterThanOrEqualTo(90),
        reason: 'questa prova ha trovato solo $scorrono guardie che scorrono '
            'i sorgenti: o sono sparite, o non le sta piu\' riconoscendo, e '
            'in tutti e due i casi non sta sorvegliando niente');

    expect(nudi, isEmpty,
        reason: 'queste guardie scorrono i sorgenti senza dichiarare quanto '
            'guardano, quindi diventerebbero VERDI su un insieme vuoto:\n'
            '${nudi.join("\n")}\n'
            'Passa da sorgentiDiLib(), che il cardinale lo dichiara per tutti, '
            'oppure scrivi il tuo con un expect sul numero di elementi '
            'guardati. L\'elenco delle deroghe puo\' solo accorciarsi.');

    // ignore: avoid_print
    print('ORDINE CL VOCE 04: guardie che scorrono i sorgenti $scorrono, '
        'senza cardinale ${senzaCardinale.length}');
  });

  test('nessuna deroga resta appesa a una guardia che non c\'e\' piu\'', () {
    final sparite = <String>[];
    for (final nome in senzaCardinale) {
      if (!File('test/$nome').existsSync()) sparite.add(nome);
    }
    expect(sparite, isEmpty,
        reason: 'queste deroghe non hanno piu\' una guardia da scusare, e un '
            'elenco di scuse per file che non esistono e\' il modo in cui '
            'questa regola smetterebbe di significare qualcosa: $sparite');
  });
}
