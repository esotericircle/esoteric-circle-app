# La stima dei costi di Google Cloud degli ultimi 30 giorni

**È una stima, non la fattura.** Le quantità vengono dalle metriche di Google
Cloud (Cloud Monitoring), i prezzi dalle pagine pubbliche di Google lette il 2
ottobre 2026. Gli importi veri sono quelli del report Fatturazione della
console, che vede solo il fondatore. In più, il progetto è sul credito di prova
di 300 USD: quello che segue è quanto vale il consumo, non quanto è uscito dal
conto.

Ordine extra del 2 ottobre 2026, senza sigla. Il fondatore: *"Code potrebbe
dirmi i costi che ho sostenuto derivanti dall'app?"*, *"Si per gli ultimi 30
GG"*. Lavoro in sola lettura: nessuna risorsa, quota, funzione, regola o
impostazione è stata creata, cambiata o cancellata, e nessun documento di
Firestore è stato letto.

**Il periodo**: dal 2 settembre 2026 alle 00:00 al 2 ottobre 2026 alle 00:00,
ora di Roma (in UTC dal 1 settembre 22:00 al 1 ottobre 22:00), cioè i 30 giorni
interi fino al 1 ottobre compreso.

## In una riga

**Circa 95 dollari in 30 giorni, e 90 di questi non vengono dall'app.** Quasi
tutto è Gemini 2.5 Flash chiamato dai banchi di prova di Code durante lo
sviluppo (le prove col modello vero degli ordini DN, ES, ER, ET, EU ed EV: 93.808
chiamate su 96.287). L'app usata dai telefoni vale **circa 5 dollari**, metà testo
e metà voce dei Maestri. I costi fissi, che si pagano anche se nessuno apre
l'app, sono **circa 18 centesimi** al mese. Tutto il resto (le funzioni del
server, Firestore, i registri, le build) sta dentro le quote gratuite.

## I progetti

| Progetto | Uso nei 30 giorni |
| --- | --- |
| Esoteric Circle | l'app: tutto quello che segue |
| Default Gemini Project | nessuna chiamata registrata |
| My First Project (due progetti con questo nome) | nessuna chiamata registrata |

Per gli ultimi tre, `serviceruntime.googleapis.com/api/request_count` nei 30
giorni non ha nessuna serie: zero chiamate a qualunque servizio.

## La tabella per servizio, dal più caro

| Servizio | Quantità nei 30 giorni | Prezzo unitario | Quota gratuita | Costo stimato |
| --- | --- | --- | --- | --- |
| Vertex AI, Gemini 2.5 Flash (europe-west1) | 200.602.541 token in ingresso, 11.728.643 in uscita, 80.143 chiamate | 0,30 $ per milione in ingresso, 2,50 $ in uscita | nessuna | **89,50 $** |
| Vertex AI, voce Gemini 2.5 Flash TTS (europe-west1) | 61.279 token di testo, 269.792 token audio (circa 3 ore di voce, a 25 token al secondo), 1.057 chiamate | 0,50 $ per milione di testo, 10 $ per milione audio | nessuna | **2,73 $** |
| Vertex AI, Gemini 2.5 Flash-Lite (europe-west1, più 4 chiamate in us-central1) | 11.153.031 token in ingresso, 367.133 in uscita, 14.970 chiamate | 0,10 $ e 0,40 $ per milione | nessuna | **1,27 $** |
| Vertex AI, Gemini 3 Pro Image (global) | 3.213 token in ingresso, 9.170 in uscita, 4 chiamate | 2 $ per milione in ingresso, 120 $ per milione di immagine in uscita | nessuna | **1,11 $** |
| Vertex AI, Gemini 3.6 Flash (global) | 194.373 in ingresso, 9.825 in uscita, 182 chiamate | 0,75 $ e 3,75 $ per milione | nessuna | **0,18 $** |
| Vertex AI, voce Gemini 2.5 Pro TTS (europe-west1) | 2.293 token di testo, 7.614 token audio, 51 chiamate | 1 $ e 20 $ per milione | nessuna | **0,15 $** |
| Cloud Scheduler | 4 lavori pianificati | 0,10 $ al mese per lavoro | 3 lavori | **0,10 $** (fisso) |
| Secret Manager | 7 versioni attive (una per segreto), 852 accessi | 0,06 $ al mese per versione; 0,03 $ ogni 10.000 accessi | 6 versioni, 10.000 accessi | **0,06 $** (fisso) |
| Cloud Storage (europe-west1, Standard) | 1,01 GB in media (master 893 MB, cdn 106 MB, sorgenti delle funzioni 11 MB); 8,7 MB in uscita; 49 richieste | 0,020 $ per GB al mese | nessuna in Europa (i 5 GB gratuiti valgono solo in alcune regioni USA) | **0,02 $** (fisso) |
| Vertex AI, Gemini 3.5 Flash-Lite (global) | 45.683 in ingresso, 313 in uscita, 169 chiamate | 0,30 $ e 2,50 $ per milione | nessuna | **0,01 $** |
| Cloud Run (le 36 funzioni del server, seconda generazione) | 27.224 vCPU-secondi, 2.885 GiB-secondi, 9.572 richieste, 11.484 secondi di istanza; nessuna istanza minima accesa | da listino | 180.000 vCPU-s, 360.000 GiB-s, 2 milioni di richieste al mese | **0 $** |
| Traffico in uscita da Cloud Run | 665 MB (soprattutto l'audio della voce dei Maestri) | 0,12 $ per GiB verso l'Europa | 1 GiB verso l'Europa | **0 $** |
| Firestore | 52.120 letture, 5.738 scritture, 379 cancellazioni; 2,9 MB occupati | da listino | 50.000 letture, 20.000 scritture e 20.000 cancellazioni **al giorno**; 1 GiB | **0 $** |
| Cloud Logging | 46 MB di registri ricevuti | 0,50 $ per GiB | 50 GiB per progetto al mese | **0 $** |
| Artifact Registry | 147 MB di immagini delle funzioni | 0,10 $ per GB al mese | 0,5 GB | **0 $** |
| Cloud Build | 25 build, 19,3 minuti | da listino | 2.500 minuti al mese | **0 $** |
| Text-to-Speech, voci Chirp 3 HD | 96 richieste (112 in tutto) | 30 $ per milione di caratteri | 1 milione di caratteri al mese | **0 $** (vedi sotto) |
| Firebase Auth, Cloud Messaging, App Check, Play Integrity, App Distribution, Installations, Remote Config, Pub/Sub, Eventarc | poche centinaia di richieste ciascuno | gratuiti o in quota gratuita | | **0 $** |
| **Totale** | | | | **circa 95,13 $** |

**Le voci Chirp 3 HD** non hanno una metrica dei caratteri. Ma una richiesta di
sintesi non può superare i 5.000 byte: 96 richieste fanno al massimo 480.000
caratteri, meno della metà del milione gratuito. Il costo è zero con certezza,
anche senza sapere il numero esatto.

## Chi ha fatto le chiamate a Gemini

La metrica dei token non dice chi chiama. Lo dice invece quella delle richieste
(`serviceruntime.googleapis.com/api/request_count`, etichetta della
credenziale):

| Chi chiama | Chiamate a Vertex AI nei 30 giorni |
| --- | --- |
| **I banchi di prova di Code**, dal PC con lo strumento `gcloud` (le prove col modello vero, le sonde, i collaudi alla cieca) | 93.808 |
| **L'app dai telefoni**, attraverso Firebase AI Logic (chat dei Maestri, Doni, Viaggio, Tarocchi, Rune, Sigillo...) | 1.636 (di cui 128 in streaming) |
| **Le funzioni del server** (la voce dei Maestri, la sessione del LIVE) | 838 |
| La console di Google (Vertex AI Studio, Model Garden) | 5 |

**Il giorno per giorno lo conferma.** Il 17, il 19 e il 20 settembre i banchi
non hanno girato (zero chiamate da `gcloud`): Flash ha ricevuto 18.226, 2.591 e
0 token in ingresso. Il 30 settembre, giorno di banco, ne ha ricevuti 58
milioni.

## Il costo per funzione dell'app, dal più caro

La parte dell'app è stimata così: giorno per giorno, i token di ogni modello si
dividono fra banchi e app in proporzione alle chiamate di quel giorno; per la
voce, in proporzione alle chiamate delle funzioni del server sul totale delle
chiamate di sintesi (838 su 1.108). Comprende anche le prove che Code ha fatto
**sul telefono di collaudo con l'app**, che passano dalla stessa strada dei
vostri telefoni e non si possono separare.

| Funzione | Modello | Costo stimato nei 30 giorni |
| --- | --- | --- |
| **La voce dei Maestri** (lettura delle risposte, LIVE) | Gemini 2.5 Flash TTS e Pro TTS; Chirp 3 HD nella quota gratuita | **2,18 $** |
| **I Maestri e i Doni col modello Flash**: chat (risposta Profonda e normale), risposte del LIVE, Rune, Tarocchi, Viaggio dello Sciamano (la scena), Sigillo, distillato della memoria | Gemini 2.5 Flash | **2,84 $** (non divisibile fra queste funzioni: vedi sotto) |
| **Le risposte Brevi e il piano Free**, la domanda capita del Viaggio, i titoli delle conversazioni | Gemini 2.5 Flash-Lite | **0,04 $** |
| Le 36 funzioni del server (Cerchio, cammino, Eos, ONLINE, Doni pianificati, LIVE) | Cloud Run | **0 $** (in quota gratuita) |
| Firestore (fra cui il contatore ONLINE: 481 chiamate a `chieonline`) | | **0 $** (in quota gratuita) |
| **Totale dell'app** | | **circa 5,06 $** |

**Fuori dall'app**: i banchi di prova di Code valgono **circa 87,89 $** (Flash e
Flash-Lite) più circa 0,70 $ di voce; i modelli "global" Gemini 3.6 Flash, 3.5
Flash-Lite e 3 Pro Image, che l'app non chiama mai (la regola della regione dei
dati), valgono **circa 1,31 $**: sono prove dalla console o da strumenti fuori
dall'app.

## Costi fissi e costi che crescono con l'uso

| | Che cosa | Al mese |
| --- | --- | --- |
| **Fissi** (anche se nessuno apre l'app) | Cloud Storage 1,01 GB (0,02 $), il quarto lavoro pianificato (0,10 $), la settima versione di segreto (0,06 $) | **circa 0,18 $** |
| | Nessuna istanza sempre accesa, nessun database Cloud SQL, nessun Redis, Artifact Registry e Firestore nella quota gratuita | 0 $ |
| **Con l'uso** | Gemini (testo e voce): tutto il resto | circa 94,95 $ in questi 30 giorni, di cui circa 5 dell'app |

## Che cosa non si è potuto misurare, e perché

1. **La fattura vera.** Il report Fatturazione e l'esportazione dei costi in
   BigQuery non sono leggibili dall'account di Code: servirebbe il ruolo
   "Visualizzatore fatturazione" sul conto di fatturazione. È anche il solo modo
   di sapere quanto del credito di prova è stato usato.
2. **I token del "ragionamento" di Gemini 2.5 Flash.** Google li fa pagare come
   token in uscita; la metrica `token_count` non dice se li contiene. Se non li
   contiene, il costo di Flash in uscita è sottostimato.
3. **Il costo di ogni singola funzione fra quelle che usano Flash** (chat, LIVE,
   Viaggio, Tarocchi, Rune, Sigillo): le metriche di Vertex dicono il modello,
   non chi lo chiama dentro l'app, e la metrica di Firebase AI Logic è vuota.
   Servirebbe un'etichetta per funzione nelle chiamate dell'app, che oggi non
   c'è.
4. **La divisione esatta fra banchi e app.** Le metriche dei token non dicono
   la credenziale: la divisione è una proporzione sulle chiamate di ogni giorno,
   dichiarata sopra. E le prove di Code sul telefono di collaudo contano come
   app.
5. **I caratteri di Chirp 3 HD**: nessuna metrica; il limite massimo calcolato
   sopra basta a dire che il costo è zero.
6. **I servizi fuori da Google**: LiveKit (il LIVE), Protoface (gli avatar),
   FreeAstroAPI e il servizio di posta (SMTP) hanno i loro conti e non stanno
   in queste metriche.

## Come rifare la stima

Tutto in sola lettura, col token di `gcloud` dell'account di sviluppo. Lo
strumento è `tool/stima_costi_30_giorni.py` (periodo scritto in cima al file);
l'allineamento è sempre l'intera finestra di 30 giorni, o 86.400 secondi per il
giorno per giorno.

```
# chiamate per servizio, e per credenziale su Vertex AI
python tool/stima_costi_30_giorni.py serie serviceruntime.googleapis.com/api/request_count esoteric-circle ALIGN_SUM resource.label.service
#   (con filtro resource.label.service = "aiplatform.googleapis.com" e raggruppamento resource.label.credential_id, resource.label.method)

# token e chiamate di Gemini per modello
python tool/stima_costi_30_giorni.py serie aiplatform.googleapis.com/publisher/online_serving/token_count esoteric-circle ALIGN_SUM resource.label.model_user_id metric.label.type resource.label.location
python tool/stima_costi_30_giorni.py serie aiplatform.googleapis.com/publisher/online_serving/model_invocation_count esoteric-circle ALIGN_SUM resource.label.model_user_id resource.label.location

# Cloud Run (le funzioni)
python tool/stima_costi_30_giorni.py serie run.googleapis.com/container/cpu/allocation_time esoteric-circle ALIGN_SUM resource.label.service_name
python tool/stima_costi_30_giorni.py serie run.googleapis.com/container/memory/allocation_time esoteric-circle ALIGN_SUM resource.label.service_name
python tool/stima_costi_30_giorni.py serie run.googleapis.com/request_count esoteric-circle ALIGN_SUM resource.label.service_name
python tool/stima_costi_30_giorni.py serie run.googleapis.com/container/network/sent_bytes_count esoteric-circle

# Firestore, Storage, Logging
python tool/stima_costi_30_giorni.py serie firestore.googleapis.com/document/read_ops_count esoteric-circle
python tool/stima_costi_30_giorni.py serie firestore.googleapis.com/document/write_ops_count esoteric-circle
python tool/stima_costi_30_giorni.py serie firestore.googleapis.com/document/delete_ops_count esoteric-circle
python tool/stima_costi_30_giorni.py serie firestore.googleapis.com/storage/data_and_index_storage_bytes esoteric-circle ALIGN_MEAN
python tool/stima_costi_30_giorni.py serie storage.googleapis.com/storage/total_bytes esoteric-circle ALIGN_MEAN resource.label.bucket_name
python tool/stima_costi_30_giorni.py serie storage.googleapis.com/network/sent_bytes_count esoteric-circle ALIGN_SUM resource.label.bucket_name
python tool/stima_costi_30_giorni.py serie logging.googleapis.com/billing/bytes_ingested esoteric-circle
python tool/stima_costi_30_giorni.py serie serviceruntime.googleapis.com/quota/rate/net_usage esoteric-circle ALIGN_SUM resource.label.service metric.label.quota_metric

# configurazioni (sola lettura)
gcloud services list --enabled --project <progetto>
gcloud run services list --project esoteric-circle
gcloud artifacts repositories list --project esoteric-circle
gcloud secrets list --project esoteric-circle ; gcloud secrets versions list <segreto> --project esoteric-circle
gcloud scheduler jobs list --project esoteric-circle --location europe-west1
gcloud sql instances list --project esoteric-circle ; gcloud redis instances list --region europe-west1 --project esoteric-circle
gcloud builds list --project esoteric-circle --region europe-west1 --filter='createTime>="2026-09-01T22:00:00Z" AND createTime<"2026-10-01T22:00:00Z"'
```

## I prezzi, con la pagina e la data

Tutte lette il 2 ottobre 2026, in dollari, per la regione europe-west1 dove
l'app lavora (i modelli "global" al prezzo global).

| Voce | Pagina |
| --- | --- |
| Gemini 2.5 Flash 0,30 / 2,50 $; 2.5 Flash-Lite 0,10 / 0,40 $; 3.6 Flash 0,75 / 3,75 $ (prezzo promozionale fino al 31 dicembre 2026); 3.5 Flash-Lite 0,30 / 2,50 $; 3 Pro Image 2 $ in ingresso, 120 $ per l'immagine in uscita; nessuna quota gratuita | https://cloud.google.com/vertex-ai/generative-ai/pricing |
| Gemini 2.5 Flash TTS 0,50 $ testo, 10 $ audio; 2.5 Pro TTS 1 $ e 20 $ (25 token audio al secondo); Chirp 3 HD 30 $ per milione di caratteri, il primo milione al mese gratis | https://cloud.google.com/text-to-speech/pricing |
| Cloud Run: 180.000 vCPU-s, 360.000 GiB-s e 2 milioni di richieste gratis al mese; traffico in uscita al prezzo Premium | https://cloud.google.com/run/pricing |
| Traffico in uscita verso l'Europa: 1 GiB gratis, poi 0,12 $ per GiB | https://cloud.google.com/vpc/network-pricing |
| Firestore: 1 GiB, 50.000 letture, 20.000 scritture e 20.000 cancellazioni al giorno gratis | https://cloud.google.com/firestore/pricing |
| Cloud Storage Standard: 0,020 $ per GB al mese | https://cloud.google.com/storage/pricing |
| Cloud Logging: 50 GiB per progetto al mese gratis | https://cloud.google.com/stackdriver/pricing |
| Secret Manager: 6 versioni attive e 10.000 accessi gratis, poi 0,06 $ per versione al mese | https://cloud.google.com/secret-manager/pricing |
| Cloud Scheduler: 3 lavori gratis, poi 0,10 $ per lavoro al mese | https://cloud.google.com/scheduler/pricing |
| Artifact Registry: 0,5 GB gratis | https://cloud.google.com/artifact-registry/pricing |
| Cloud Build: 2.500 minuti al mese gratis | https://cloud.google.com/build/pricing |
