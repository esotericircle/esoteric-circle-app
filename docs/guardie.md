# IL REGISTRO DELLE GUARDIE

Ordine CL voce 05. **Casa unica della conoscenza sulle guardie di questo
progetto.** Una riga per guardia, e la colonna che conta e' l'ultima ma una:
**una guardia che non e' mai stata vista rossa non e' una guardia, e' una
speranza.**

## Che cos'e' una guardia, e cosa non lo e'

E' una guardia una prova che asserisce su un'**assenza** oppure su un
**insieme scoperto a esecuzione**: legge i sorgenti e ci cerca dentro, scorre
elenchi di file o di rotte o di chiavi, scatta fotografie e le confronta,
oppure pretende che qualcosa NON ci sia.

**Non** e' una guardia la prova che chiama una funzione con un valore e ne
verifica il risultato: quella non puo' essere cieca, perche' se la funzione
sparisce non compila.

La differenza e' tutta qui: **una prova che asserisce su un valore fallisce
quando il valore e' sbagliato; una che asserisce su un insieme diventa VERDE
quando l'insieme e' vuoto.**

## Le quattro specie di cecita'

1. **Vuota per costruzione.** L'insieme e' vuoto, il ciclo non gira, la prova
   e' verde senza aver guardato niente.
2. **Cieca al bersaglio.** L'insieme non e' vuoto ma non contiene la classe
   da sorvegliare.
3. **Scollegata.** Verifica un componente vero e funzionante che nessuno usa.
4. **Degradata.** Era viva, una modifica le ha tolto il bersaglio, e invece
   di diventare rossa e' diventata muta.

## I numeri, contati il 1 settembre 2026

| | |
| --- | ---: |
| File di prova totali | 702 |
| **Guardie secondo la definizione** | **242** |
| Guardie che scorrono i sorgenti di `lib` | 108 |
| Di queste, passate alla porta comune dall'ordine CL | 14 |
| Guardie senza nessun cardinale dichiarato | 201 |
| **Guardie mai viste rosse** | **233** |

## Come si legge la tavola

**Cardinale minimo**: quante cose deve trovare per potersi dire verde. "Dalla
porta comune" vuol dire che passa da `sorgentiDiLib()`, che pretende almeno
400 file Dart. "Nessuno" vuol dire che quella guardia, su un insieme vuoto,
sarebbe verde.

**Priorita'**: 1 sono quelle senza cardinale che sorvegliano una proprieta'
gia' violata in passato; 2 le altre su quelle proprieta'; 3 tutte le altre.

| guardia | cosa sorveglia | specie esposte | cardinale minimo | vista rossa | prio |
| --- | --- | --- | --- | --- | --- |
| `accenti_veri_test.dart` | accenti veri | 1 | dalla porta comune, 400 file | 01/09/2026, ordine CL | 2 |
| `accents_test.dart` | accents | 1 | **nessuno** | mai | 3 |
| `alone_dietro_le_figure_test.dart` | alone dietro le figure | 4, 1 | **nessuno** | mai | 3 |
| `anteprime_non_velate_test.dart` | anteprime non velate | 1 | proprio, dichiarato | mai | 3 |
| `anteprime_ordine_e_test.dart` | anteprime ordine e | 4 | **nessuno** | mai | 3 |
| `arti_preferite_test.dart` | arti preferite | 1 | **nessuno** | mai | 3 |
| `aspetti_di_oggi_test.dart` | aspetti di oggi | 1, 2 | **nessuno** | mai | 3 |
| `attestazione_non_ferma_la_voce_test.dart` | attestazione non ferma la voce | 1, 2 | **nessuno** | mai | 3 |
| `avvisi_del_rito_test.dart` | avvisi del rito | 1, 2 | **nessuno** | mai | 3 |
| `barra_arte_non_si_copre_test.dart` | barra arte non si copre | 1, 2 | **nessuno** | mai | 3 |
| `bolla_non_copre_avatar_test.dart` | bolla non copre avatar | 4 | **nessuno** | mai | 3 |
| `bolla_non_copre_test.dart` | bolla non copre | 1 | **nessuno** | mai | 3 |
| `carosello_ruota_test.dart` | carosello ruota | 1 | **nessuno** | mai | 3 |
| `carta_natale_arriva_test.dart` | carta natale arriva | 1, 2 | **nessuno** | mai | 3 |
| `cielo_segue_la_posizione_test.dart` | cielo segue la posizione | 4 | **nessuno** | mai | 3 |
| `codemagic_regge_lo_schema_test.dart` | codemagic regge lo schema | 1, 2 | proprio, dichiarato | mai | 3 |
| `colore_del_dono_test.dart` | colore del dono | 1, 2, 4 | proprio, dichiarato | mai | 3 |
| `corpus_rune_attestato_test.dart` | corpus rune attestato | 1, 2 | proprio, dichiarato | mai | 3 |
| `corredo_anteprime_test.dart` | corredo anteprime | 1, 2 | **nessuno** | mai | 3 |
| `cosmo_e_interruttori_test.dart` | cosmo e interruttori | 1, 2 | **nessuno** | mai | 3 |
| `costellazione_ripetuta_test.dart` | costellazione ripetuta | 1, 2 | **nessuno** | mai | 3 |
| `dati_nascita_sbloccano_test.dart` | dati nascita sbloccano | 1, 2 | **nessuno** | mai | 3 |
| `dove_si_spendono_eos_test.dart` | dove si spendono eos | 1, 2 | **nessuno** | mai | 3 |
| `entitlement_soldi2_test.dart` | entitlement soldi2 | 1, 2 | **nessuno** | mai | 3 |
| `etichette_e_lettura_test.dart` | etichette e lettura | 1, 2 | proprio, dichiarato | mai | 3 |
| `fase_lunare_vera_test.dart` | fase lunare vera | 1, 2 | **nessuno** | mai | 3 |
| `free_astro_client_test.dart` | free astro client | 1, 2 | **nessuno** | mai | 3 |
| `gli_ancoraggi_vengono_dall_arte_test.dart` | gli ancoraggi vengono dall arte | 4, 1 | **nessuno** | mai | 3 |
| `gli_eos_hanno_un_nome_test.dart` | gli eos hanno un nome | 1, 2, 4 | **nessuno** | mai | 3 |
| `i_caratteri_dichiarati_esistono_test.dart` | i caratteri dichiarati esistono | 1, 2 | proprio, dichiarato | mai | 2 |
| `i_doni_si_agganciano_test.dart` | i doni si agganciano | 1, 2 | proprio, dichiarato | mai | 3 |
| `i_due_grigi_si_distinguono_test.dart` | i due grigi si distinguono | 1, 4 | **nessuno** | mai | 1 |
| `i_grigi_si_leggono_test.dart` | i grigi si leggono | 1 | dalla porta comune, 400 file | 01/09/2026, ordine CL | 2 |
| `i_maestri_non_coprono_il_cielo_test.dart` | i maestri non coprono il cielo | 1, 2 | **nessuno** | mai | 3 |
| `i_maestri_non_perdono_la_testa_test.dart` | i maestri non perdono la testa | 4, 1 | **nessuno** | mai | 3 |
| `i_maestri_sui_pixel_e_non_sui_rettangoli_test.dart` | i maestri sui pixel e non sui rettangoli | 4 | **nessuno** | mai | 3 |
| `i_movimenti_dicono_il_guadagno_test.dart` | i movimenti dicono il guadagno | 1, 2 | **nessuno** | mai | 3 |
| `i_nomi_non_si_sovrappongono_test.dart` | i nomi non si sovrappongono | 4 | **nessuno** | mai | 3 |
| `i_nove_ereditati_test.dart` | i nove ereditati | 1, 2 | **nessuno** | mai | 3 |
| `i_piani_del_cielo_si_muovono_test.dart` | i piani del cielo si muovono | 4, 1 | **nessuno** | mai | 3 |
| `i_ricordi_hanno_una_rotta_sola_test.dart` | i ricordi hanno una rotta sola | 1, 2 | **nessuno** | mai | 3 |
| `i_testi_da_leggere_hanno_una_misura_sola_test.dart` | i testi da leggere hanno una misura sola | 1, 2 | **nessuno** | mai | 3 |
| `i_testi_del_dono_non_stanno_sulla_carta_test.dart` | i testi del dono non stanno sulla carta | 1, 2 | **nessuno** | mai | 3 |
| `i_testi_seguono_i_nomi_nuovi_test.dart` | i testi seguono i nomi nuovi | 1, 2 | **nessuno** | mai | 3 |
| `i_tre_esiti_del_permesso_test.dart` | i tre esiti del permesso | 1, 2 | **nessuno** | mai | 3 |
| `i_tre_lucchetti_del_cielo_test.dart` | i tre lucchetti del cielo | 1, 2, 4 | proprio, dichiarato | mai | 3 |
| `i_tre_maestri_dominano_la_home_test.dart` | i tre maestri dominano la home | 4 | **nessuno** | mai | 3 |
| `i_tre_sentieri_si_disegnano_test.dart` | i tre sentieri si disegnano | 4 | **nessuno** | mai | 3 |
| `icona_cerchio_capture_test.dart` | icona cerchio capture | 4 | **nessuno** | mai | 3 |
| `il_benvenuto_e_la_dote_test.dart` | il benvenuto e la dote | 1, 2 | **nessuno** | mai | 3 |
| `il_bordo_dei_piani_non_si_vede_test.dart` | il bordo dei piani non si vede | 4, 1 | **nessuno** | mai | 3 |
| `il_borsellino_si_aggiorna_ovunque_test.dart` | il borsellino si aggiorna ovunque | 1, 2 | **nessuno** | mai | 3 |
| `il_borsellino_si_vede_sempre_test.dart` | il borsellino si vede sempre | 1, 2 | **nessuno** | mai | 3 |
| `il_busto_e_la_forma_del_maestro_test.dart` | il busto e la forma del maestro | 1, 2 | **nessuno** | mai | 3 |
| `il_cambio_dell_email_test.dart` | il cambio dell email | 1, 2 | **nessuno** | mai | 3 |
| `il_campo_di_scrittura_e_opaco_test.dart` | il campo di scrittura e opaco | 4 | **nessuno** | mai | 3 |
| `il_catalogo_copre_il_mondo_test.dart` | il catalogo copre il mondo | 1, 2 | **nessuno** | mai | 3 |
| `il_censimento_dei_grigi_test.dart` | il censimento dei grigi | 1, 2 | proprio, dichiarato | 01/09/2026, ordine CI | 2 |
| `il_censimento_delle_stringhe_dice_il_vero_test.dart` | il censimento delle stringhe dice il vero | 1, 2 | **nessuno** | mai | 1 |
| `il_cielo_arriva_al_maestro_test.dart` | il cielo arriva al maestro | 1, 2 | **nessuno** | mai | 3 |
| `il_cielo_di_nascita_si_muove_test.dart` | il cielo di nascita si muove | 2, 4 | **nessuno** | mai | 3 |
| `il_cielo_dice_da_dove_test.dart` | il cielo dice da dove | 1, 2 | **nessuno** | mai | 3 |
| `il_cielo_si_muove_davvero_test.dart` | il cielo si muove davvero | 4 | **nessuno** | mai | 3 |
| `il_cielo_si_muove_test.dart` | il cielo si muove | 1, 2, 4 | **nessuno** | mai | 3 |
| `il_compimento_dei_tre_sentieri_test.dart` | il compimento dei tre sentieri | 4, 1 | **nessuno** | mai | 3 |
| `il_confronto_ha_il_suo_tetto_test.dart` | il confronto ha il suo tetto | 1, 2 | **nessuno** | mai | 3 |
| `il_consiglio_in_oro_test.dart` | il consiglio in oro | 1, 2 | **nessuno** | mai | 3 |
| `il_consiglio_mostra_tre_voci_test.dart` | il consiglio mostra tre voci | 1, 2 | **nessuno** | mai | 3 |
| `il_consiglio_non_si_riscrive_test.dart` | il consiglio non si riscrive | 1, 2 | **nessuno** | mai | 3 |
| `il_continua_come_restituisce_il_cammino_test.dart` | il continua come restituisce il cammino | 1, 2 | **nessuno** | mai | 3 |
| `il_conto_e_uno_solo_test.dart` | il conto e uno solo | 1, 2 | **nessuno** | mai | 3 |
| `il_disco_dell_oracolo_dice_cosa_e_test.dart` | il disco dell oracolo dice cosa e | 1 | **nessuno** | mai | 3 |
| `il_filo_si_traccia_test.dart` | il filo si traccia | 1, 2 | **nessuno** | mai | 3 |
| `il_foglio_dell_email_dice_cosa_non_va_test.dart` | il foglio dell email dice cosa non va | 1, 2 | **nessuno** | mai | 3 |
| `il_gating_non_ha_fondi_bianchi_test.dart` | il gating non ha fondi bianchi | 1 | **nessuno** | mai | 3 |
| `il_gemello_ha_la_sua_schermata_test.dart` | il gemello ha la sua schermata | 1, 2 | **nessuno** | mai | 3 |
| `il_genere_non_si_indovina_test.dart` | il genere non si indovina | 1, 2 | **nessuno** | mai | 3 |
| `il_giorno_si_conta_dalla_porta_test.dart` | il giorno si conta dalla porta | 1, 2 | **nessuno** | mai | 3 |
| `il_journal_arriva_in_fondo_test.dart` | il journal arriva in fondo | 4, 1 | **nessuno** | mai | 3 |
| `il_listino_vivo_test.dart` | il listino vivo | 1 | **nessuno** | mai | 3 |
| `il_livello_visivo_prima_del_testo_nei_riti_test.dart` | il livello visivo prima del testo nei riti | 1, 2 | **nessuno** | mai | 3 |
| `il_luogo_di_nascita_e_la_sua_nazione_test.dart` | il luogo di nascita e la sua nazione | 4, 1 | **nessuno** | mai | 3 |
| `il_luogo_pulsa_e_si_trova_test.dart` | il luogo pulsa e si trova | 4 | **nessuno** | mai | 3 |
| `il_maestro_non_resta_muto_test.dart` | il maestro non resta muto | 1 | **nessuno** | mai | 3 |
| `il_menu_delle_notifiche_si_tocca_test.dart` | il menu delle notifiche si tocca | 1 | **nessuno** | mai | 3 |
| `il_motore_delle_eclissi_test.dart` | il motore delle eclissi | 1, 2 | **nessuno** | mai | 3 |
| `il_motore_locale_e_per_oggi_test.dart` | il motore locale e per oggi | 1, 2 | **nessuno** | mai | 3 |
| `il_nome_breve_dell_oroscopo_test.dart` | il nome breve dell oroscopo | 1 | **nessuno** | mai | 3 |
| `il_nome_del_consiglio_test.dart` | il nome del consiglio | 1, 2 | **nessuno** | mai | 3 |
| `il_nome_dichiara_la_sua_forma_test.dart` | il nome dichiara la sua forma | 1, 2 | dalla porta comune, 400 file | mai | 2 |
| `il_pannello_ha_due_titoli_test.dart` | il pannello ha due titoli | 1, 2 | **nessuno** | mai | 3 |
| `il_passaporto_porta_a_sbloccare_test.dart` | il passaporto porta a sbloccare | 1, 2 | **nessuno** | mai | 3 |
| `il_pozzo_in_attesa_non_e_un_vuoto_test.dart` | il pozzo in attesa non e un vuoto | 4, 1 | **nessuno** | mai | 3 |
| `il_pozzo_non_ha_lacqua_rossa_test.dart` | il pozzo non ha lacqua rossa | 4 | **nessuno** | mai | 3 |
| `il_quaderno_dei_sogni_non_torna_test.dart` | il quaderno dei sogni non torna | 1, 2 | **nessuno** | mai | 3 |
| `il_respiro_vive_nel_soffio_test.dart` | il respiro vive nel soffio | 1, 2 | **nessuno** | mai | 3 |
| `il_responso_e_lo_stesso_fino_a_mezzanotte_test.dart` | il responso e lo stesso fino a mezzanotte | 1, 2 | **nessuno** | mai | 3 |
| `il_retro_vergine_ha_una_porta_sola_test.dart` | il retro vergine ha una porta sola | 1, 2 | dalla porta comune, 400 file | mai | 2 |
| `il_rientro_non_muore_in_silenzio_test.dart` | il rientro non muore in silenzio | 1 | **nessuno** | mai | 3 |
| `il_ripiego_non_si_traveste_da_carta_test.dart` | il ripiego non si traveste da carta | 1, 2 | **nessuno** | mai | 3 |
| `il_secondo_strato_e_premium_test.dart` | il secondo strato e premium | 1, 2 | **nessuno** | mai | 3 |
| `il_seguito_scende_sotto_test.dart` | il seguito scende sotto | 1, 2 | **nessuno** | mai | 3 |
| `il_sentiero_si_legge_test.dart` | il sentiero si legge | 1, 2 | **nessuno** | mai | 3 |
| `il_sigillo_del_giorno_e_un_sigillo_test.dart` | il sigillo del giorno e un sigillo | 4 | **nessuno** | mai | 3 |
| `il_simbolo_si_compone_test.dart` | il simbolo si compone | 1, 2 | **nessuno** | mai | 3 |
| `il_soffio_non_somiglia_all_alba_test.dart` | il soffio non somiglia all alba | 2, 4 | **nessuno** | mai | 3 |
| `il_solco_scava_la_pietra_vera_test.dart` | il solco scava la pietra vera | 4 | **nessuno** | mai | 3 |
| `il_suono_si_ferma_test.dart` | il suono si ferma | 1, 2 | **nessuno** | mai | 3 |
| `il_target_ios_e_il_massimo_dei_plugin_test.dart` | il target ios e il massimo dei plugin | 1, 2 | **nessuno** | mai | 3 |
| `il_titolo_del_respiro_sta_sul_velo_test.dart` | il titolo del respiro sta sul velo | 4 | **nessuno** | mai | 3 |
| `il_titolo_non_si_rompe_test.dart` | il titolo non si rompe | 1, 2 | **nessuno** | mai | 3 |
| `il_titolo_non_stampa_sul_contenuto_test.dart` | il titolo non stampa sul contenuto | 1, 2, 4 | **nessuno** | mai | 3 |
| `il_velo_e_uno_solo_test.dart` | il velo e uno solo | 1 | **nessuno** | 01/09/2026, ordine CL | 3 |
| `il_video_e_lo_sfondo_della_rivelazione_test.dart` | il video e lo sfondo della rivelazione | 1 | **nessuno** | mai | 3 |
| `il_volto_nel_tondo_test.dart` | il volto nel tondo | 4 | **nessuno** | mai | 3 |
| `il_vuoto_sotto_i_maestri_test.dart` | il vuoto sotto i maestri | 1 | **nessuno** | mai | 3 |
| `intro_test.dart` | intro | 1, 2 | **nessuno** | mai | 3 |
| `l_account_dice_chi_sei_e_come_uscire_test.dart` | l account dice chi sei e come uscire | 1, 2 | **nessuno** | mai | 3 |
| `l_alba_si_legge_test.dart` | l alba si legge | 1, 2, 4 | **nessuno** | mai | 3 |
| `l_anello_del_livello_test.dart` | l anello del livello | 4 | **nessuno** | mai | 3 |
| `l_arcano_del_giorno_test.dart` | l arcano del giorno | 1, 2 | proprio, dichiarato | mai | 3 |
| `l_emblema_sta_nel_suo_riquadro_test.dart` | l emblema sta nel suo riquadro | 4 | **nessuno** | mai | 3 |
| `l_onboarding_riconosce_e_propone_test.dart` | l onboarding riconosce e propone | 1, 2 | **nessuno** | mai | 3 |
| `la_barra_scivola_sopra_test.dart` | la barra scivola sopra | 1 | **nessuno** | mai | 3 |
| `la_barra_sottile_e_la_casa_unica_test.dart` | la barra sottile e la casa unica | 1, 2 | **nessuno** | mai | 3 |
| `la_bolla_dei_traguardi_test.dart` | la bolla dei traguardi | 1, 2 | **nessuno** | mai | 3 |
| `la_bolla_respira_in_fondo_test.dart` | la bolla respira in fondo | 4 | **nessuno** | mai | 3 |
| `la_card_vecchia_e_demolita_test.dart` | la card vecchia e demolita | 1, 2 | **nessuno** | mai | 3 |
| `la_carta_natale_sopravvive_test.dart` | la carta natale sopravvive | 1, 2 | **nessuno** | mai | 3 |
| `la_catena_dei_dati_di_nascita_test.dart` | la catena dei dati di nascita | 1, 2 | **nessuno** | mai | 3 |
| `la_celebrazione_offre_sempre_la_condivisione_test.dart` | la celebrazione offre sempre la condivisione | 1, 2 | **nessuno** | mai | 3 |
| `la_chat_si_legge_test.dart` | la chat si legge | 2, 4, 1 | **nessuno** | mai | 3 |
| `la_chiave_e_il_consiglio_si_vedono_test.dart` | la chiave e il consiglio si vedono | 1, 2, 4 | proprio, dichiarato | mai | 3 |
| `la_colonna_dei_suggerimenti_non_esiste_piu_test.dart` | la colonna dei suggerimenti non esiste piu | 1 | **nessuno** | mai | 3 |
| `la_corsa_dello_zodiaco_test.dart` | la corsa dello zodiaco | 1 | proprio, dichiarato | mai | 3 |
| `la_domanda_scelta_arriva_al_responso_test.dart` | la domanda scelta arriva al responso | 1, 2 | **nessuno** | mai | 3 |
| `la_domanda_viene_prima_test.dart` | la domanda viene prima | 4, 1 | **nessuno** | mai | 3 |
| `la_fascia_in_fondo_alla_home_test.dart` | la fascia in fondo alla home | 1 | **nessuno** | mai | 3 |
| `la_festa_aspetta_la_riflessione_test.dart` | la festa aspetta la riflessione | 1, 2 | **nessuno** | mai | 3 |
| `la_freccia_del_fumetto_si_vede_test.dart` | la freccia del fumetto si vede | 1, 2 | **nessuno** | mai | 3 |
| `la_galleria_vip_si_capisce_test.dart` | la galleria vip si capisce | 1 | proprio, dichiarato | mai | 3 |
| `la_home_non_copre_e_non_tronca_test.dart` | la home non copre e non tronca | 1 | **nessuno** | mai | 3 |
| `la_home_non_rallenta_al_ritorno_test.dart` | la home non rallenta al ritorno | 1 | **nessuno** | mai | 3 |
| `la_lampadina_si_accende_al_traguardo_test.dart` | la lampadina si accende al traguardo | 4 | **nessuno** | mai | 3 |
| `la_lampadina_si_distingue_test.dart` | la lampadina si distingue | 4, 1 | **nessuno** | mai | 3 |
| `la_misura_del_ritorno_test.dart` | la misura del ritorno | 1, 2 | **nessuno** | mai | 3 |
| `la_nota_non_mente_test.dart` | la nota non mente | 1, 2 | **nessuno** | mai | 3 |
| `la_parola_voce_resta_allaudio_test.dart` | la parola voce resta allaudio | 1 | **nessuno** | mai | 3 |
| `la_porta_della_sinastria_test.dart` | la porta della sinastria | 1 | **nessuno** | mai | 3 |
| `la_registrazione_non_interrompe_il_risveglio_test.dart` | la registrazione non interrompe il risveglio | 1, 2 | **nessuno** | mai | 3 |
| `la_riga_del_campo_e_pulita_test.dart` | la riga del campo e pulita | 4, 1 | **nessuno** | mai | 3 |
| `la_runa_cade_e_non_e_gia_li_test.dart` | la runa cade e non e gia li | 1, 2 | proprio, dichiarato | mai | 3 |
| `la_scena_non_copre_la_conversazione_test.dart` | la scena non copre la conversazione | 1, 2, 4 | proprio, dichiarato | mai | 3 |
| `la_spirale_di_stelle_test.dart` | la spirale di stelle | 2, 4 | **nessuno** | mai | 3 |
| `la_stella_che_chiama_il_tocco_test.dart` | la stella che chiama il tocco | 4 | **nessuno** | mai | 3 |
| `la_stesa_si_capisce_test.dart` | la stesa si capisce | 1, 2, 4 | proprio, dichiarato | mai | 3 |
| `la_striscia_delle_arti_anche_in_home_test.dart` | la striscia delle arti anche in home | 1, 2 | **nessuno** | mai | 3 |
| `la_testata_non_copre_il_maestro_test.dart` | la testata non copre il maestro | 1, 2 | **nessuno** | mai | 3 |
| `la_voce_account_nelle_impostazioni_e_viva_test.dart` | la voce account nelle impostazioni e viva | 1, 2 | **nessuno** | mai | 3 |
| `language_rule_test.dart` | language rule | 1, 2 | dalla porta comune, 400 file | 01/09/2026, ordine CL | 2 |
| `le_cose_che_dichiarano_il_falso_test.dart` | le cose che dichiarano il falso | 1, 2 | dalla porta comune, 400 file | mai | 2 |
| `le_descrizioni_hanno_una_misura_sola_test.dart` | le descrizioni hanno una misura sola | 1, 2 | **nessuno** | mai | 3 |
| `le_due_cose_che_non_servivano_test.dart` | le due cose che non servivano | 1, 2 | **nessuno** | mai | 3 |
| `le_feste_e_le_regole_che_le_trattengono_test.dart` | le feste e le regole che le trattengono | 1, 2 | proprio, dichiarato | mai | 3 |
| `le_feste_si_vedono_diverse_test.dart` | le feste si vedono diverse | 2, 4, 1 | **nessuno** | mai | 3 |
| `le_frasi_della_custodia_dicono_il_vero_test.dart` | le frasi della custodia dicono il vero | 1, 2 | **nessuno** | mai | 3 |
| `le_parole_dicono_tieni_premuto_test.dart` | le parole dicono tieni premuto | 1, 2 | **nessuno** | mai | 3 |
| `le_pietre_sono_scontornate_test.dart` | le pietre sono scontornate | 1 | **nessuno** | mai | 3 |
| `le_push_dei_doni_test.dart` | le push dei doni | 1, 2 | **nessuno** | mai | 3 |
| `le_sette_chiavi_del_collaudo_test.dart` | le sette chiavi del collaudo | 1, 2 | **nessuno** | mai | 3 |
| `lo_sbarramento_distingue_i_rossi_test.dart` | lo sbarramento distingue i rossi | 1, 2 | proprio, dichiarato | 31/08/2026, ordine CH | 3 |
| `lo_scuotimento_ha_una_porta_sola_test.dart` | lo scuotimento ha una porta sola | 1, 2 | dalla porta comune, 400 file | mai | 2 |
| `lo_spazio_dentro_lo_scroll_test.dart` | lo spazio dentro lo scroll | 1, 2 | **nessuno** | mai | 3 |
| `mai_piu_blu_sul_loto_test.dart` | mai piu blu sul loto | 4, 1 | **nessuno** | mai | 3 |
| `miniature_intere_test.dart` | miniature intere | 1, 2 | **nessuno** | mai | 3 |
| `motore_audio_unico_test.dart` | motore audio unico | 1, 2 | **nessuno** | mai | 3 |
| `nessun_campo_dice_di_aspettare_test.dart` | nessun campo dice di aspettare | 1, 2 | proprio, dichiarato | mai | 3 |
| `nessun_catch_muto_test.dart` | nessun catch muto | 1 | **nessuno** | mai | 3 |
| `nessun_foglio_e_bianco_test.dart` | nessun foglio e bianco | 1, 2 | proprio, dichiarato | mai | 3 |
| `nessun_invito_a_un_permesso_e_muto_test.dart` | nessun invito a un permesso e muto | 1, 2 | **nessuno** | mai | 3 |
| `nessun_quadrato_rosso_test.dart` | nessun quadrato rosso | 4 | **nessuno** | mai | 3 |
| `nessun_testo_finisce_sotto_test.dart` | nessun testo finisce sotto | 4, 1 | **nessuno** | mai | 3 |
| `nessuna_azione_committa_da_sola_test.dart` | nessuna azione committa da sola | 1 | **nessuno** | mai | 3 |
| `nessuna_promessa_di_memoria_integrale_test.dart` | nessuna promessa di memoria integrale | 1, 2 | proprio, dichiarato | mai | 3 |
| `nessuno_disegna_oltre_la_tela_test.dart` | nessuno disegna oltre la tela | 1, 2 | proprio, dichiarato | mai | 3 |
| `niente_eco_test.dart` | niente eco | 1, 2 | **nessuno** | mai | 3 |
| `niente_resta_di_te_test.dart` | niente resta di te | 1, 2 | proprio, dichiarato | mai | 3 |
| `niente_sottolineature_gialle_test.dart` | niente sottolineature gialle | 1, 2 | **nessuno** | mai | 3 |
| `niente_vocativo_a_schermo_test.dart` | niente vocativo a schermo | 1, 2 | **nessuno** | mai | 3 |
| `nome_ovunque_test.dart` | nome ovunque | 1, 2 | **nessuno** | mai | 3 |
| `nove_arti_test.dart` | nove arti | 1, 2 | **nessuno** | mai | 3 |
| `ogni_arte_entra_nel_cammino_test.dart` | ogni arte entra nel cammino | 1, 2 | **nessuno** | mai | 3 |
| `ogni_budget_dichiara_il_suo_residuo_test.dart` | ogni budget dichiara il suo residuo | 1, 2 | dalla porta comune, 400 file | mai | 2 |
| `ogni_condivisione_dichiara_gli_eos_test.dart` | ogni condivisione dichiara gli eos | 1, 2 | **nessuno** | mai | 1 |
| `ogni_freccia_mantiene_test.dart` | ogni freccia mantiene | 1, 2 | proprio, dichiarato | 31/08/2026, ordine CG | 3 |
| `ogni_perla_porta_alla_sua_voce_test.dart` | ogni perla porta alla sua voce | 1 | **nessuno** | mai | 3 |
| `ogni_rotta_passa_dal_nero_test.dart` | ogni rotta passa dal nero | 1, 2 | **nessuno** | mai | 3 |
| `ogni_schermata_dichiara_la_barra_test.dart` | ogni schermata dichiara la barra | 1 | dalla porta comune, 400 file | mai | 2 |
| `ogni_sensore_ha_il_suo_ripiego_test.dart` | ogni sensore ha il suo ripiego | 1, 2 | **nessuno** | mai | 3 |
| `ogni_tessera_che_apre_lo_dice_test.dart` | ogni tessera che apre lo dice | 1, 2 | **nessuno** | mai | 3 |
| `ogni_via_dice_cosa_si_accetta_test.dart` | ogni via dice cosa si accetta | 1, 2 | proprio, dichiarato | mai | 3 |
| `ora_di_nascita_test.dart` | ora di nascita | 1, 2 | **nessuno** | mai | 3 |
| `ora_e_luogo_sopravvivono_test.dart` | ora e luogo sopravvivono | 1, 2 | **nessuno** | mai | 3 |
| `ora_si_puo_correggere_test.dart` | ora si puo correggere | 1, 2 | **nessuno** | mai | 3 |
| `ordine_ch_guard_test.dart` | ordine ch guard | 1, 2 | **nessuno** | mai | 3 |
| `palette_sensoriale_test.dart` | palette sensoriale | 1, 2 | **nessuno** | mai | 3 |
| `passport_carta_natale_test.dart` | passport carta natale | 1, 2 | **nessuno** | mai | 3 |
| `passport_test.dart` | passport | 1 | **nessuno** | mai | 3 |
| `porta_dati_nascita_test.dart` | porta dati nascita | 1, 2 | **nessuno** | mai | 3 |
| `prima_dopo_capture_test.dart` | prima dopo capture | 4, 1 | **nessuno** | mai | 3 |
| `pulsante_non_copre_carta_test.dart` | pulsante non copre carta | 4 | **nessuno** | mai | 3 |
| `ronda_dei_motori_test.dart` | ronda dei motori | 1, 2 | proprio, dichiarato | mai | 3 |
| `rune_draw_screen_test.dart` | rune draw screen | 1 | **nessuno** | mai | 3 |
| `santuario_shelf_test.dart` | santuario shelf | 1 | **nessuno** | mai | 3 |
| `scelta_del_soffio_resta_test.dart` | scelta del soffio resta | 1, 2 | **nessuno** | mai | 3 |
| `scena_unica_test.dart` | scena unica | 1, 2 | proprio, dichiarato | mai | 3 |
| `screenshot_capture_test.dart` | screenshot capture | 1, 4 | **nessuno** | 01/09/2026, ordine CI | 3 |
| `segno_non_e_parametro_test.dart` | segno non e parametro | 1 | **nessuno** | mai | 3 |
| `segno_vero_test.dart` | segno vero | 1 | **nessuno** | mai | 3 |
| `sigillo_al_centro_test.dart` | sigillo al centro | 1 | **nessuno** | mai | 3 |
| `simboli_dello_zodiaco_test.dart` | simboli dello zodiaco | 1, 2 | dalla porta comune, 400 file | mai | 3 |
| `sinastria_accents_test.dart` | sinastria accents | 1 | **nessuno** | mai | 3 |
| `stato_asset_test.dart` | stato asset | 1 | **nessuno** | mai | 3 |
| `stesa_tre_carte_test.dart` | stesa tre carte | 1 | **nessuno** | mai | 3 |
| `sunset_incisione_pixel_test.dart` | sunset incisione pixel | 4 | **nessuno** | mai | 3 |
| `tarot_accordo_rovescio_test.dart` | tarot accordo rovescio | 1, 2 | **nessuno** | mai | 3 |
| `tarot_cartigli_test.dart` | tarot cartigli | 4 | **nessuno** | mai | 3 |
| `testi_falsi_test.dart` | testi falsi | 1, 2 | proprio, dichiarato | mai | 3 |
| `testo_a_video_test.dart` | testo a video | 1, 2 | dalla porta comune, 400 file | 01/09/2026, ordine CL | 2 |
| `tipografia_minimi_test.dart` | tipografia minimi | 1 | **nessuno** | mai | 3 |
| `un_ripiego_non_costa_test.dart` | un ripiego non costa | 1, 2 | **nessuno** | mai | 3 |
| `un_solo_istante_test.dart` | un solo istante | 1, 2 | **nessuno** | mai | 3 |
| `una_barra_sola_test.dart` | una barra sola | 1 | **nessuno** | mai | 3 |
| `una_festa_alla_volta_e_il_fondo_si_oscura_test.dart` | una festa alla volta e il fondo si oscura | 1, 2, 4 | **nessuno** | mai | 3 |
| `una_figura_sola_test.dart` | una figura sola | 2, 4, 1 | **nessuno** | mai | 3 |
| `una_luna_sola_test.dart` | una luna sola | 1, 4 | **nessuno** | mai | 3 |
| `una_porta_per_il_confronto_test.dart` | una porta per il confronto | 1, 2 | dalla porta comune, 400 file | mai | 2 |
| `una_porta_sola_per_larchetipo_test.dart` | una porta sola per larchetipo | 1, 2, 4 | dalla porta comune, 400 file | mai | 2 |
| `una_prova_dichiara_il_suo_istante_test.dart` | una prova dichiara il suo istante | 1, 2 | **nessuno** | mai | 1 |
| `una_sola_porta_per_i_transiti_test.dart` | una sola porta per i transiti | 1, 2 | **nessuno** | mai | 3 |
| `una_spirale_per_volta_test.dart` | una spirale per volta | 1, 2 | **nessuno** | mai | 3 |
| `una_voce_alla_volta_test.dart` | una voce alla volta | 1, 2 | **nessuno** | mai | 3 |
