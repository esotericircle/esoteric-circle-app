# LE TRE TRANSIZIONI DI STELLE, dal .mov al WebP animato. Ordine AU voci 01 e 02.
#
# **Perche' esiste questo file invece di una riga di comando appuntata da
# qualche parte.** La conversione ha sei parametri e uno di essi, la
# ricostruzione dell'alpha dalla luminanza per Medora, e' una decisione del
# fondatore presa il 22 agosto 2026 dopo una misura. Se resta in una riga di
# shell, il giorno che arriva un sorgente nuovo nessuno sa piu' come si e'
# fatto e con quale gamma.
#
# **Il difetto che ha causato tutto**, misurato nell'ordine AT voce 02:
# `Star-Transition-8.mov`, destinato a Medora, ha `pix_fmt=argb` come gli altri
# due ma il canale alpha e' 255 su tutti i fotogrammi. Il file non e' rotto: e'
# stato esportato su fondo nero invece che su trasparenza. Siccome il fondo E'
# nero, la luminanza di quel filmato E' gia' la maschera che serve, e si puo'
# ricostruire senza tornare ad After Effects.
import os
import subprocess
import sys

SORGENTI = "transition"
DESTINAZIONE = os.path.join("assets", "transizioni")

# **CHI USA COSA.** Ordine AT voce 08. Il numero e' quello del file sorgente.
FILM = {
    "medora": ("Star-Transition-8.mov", True),
    "caligo": ("Star-Transition-9.mov", False),
    "aura": ("Star-Transition-10.mov", False),
}

# **LA MISURA, decisa nell'ordine AU voce 02.** Tre Maestri, stessa dignita':
# tutti e tre a 720 per 1280, nessuno rimpicciolito per stare in un tetto.
LARGHEZZA = 720
ALTEZZA = 1280
QUALITA = 70

# **IL TETTO, alzato dall'ordine AU voce 02**, che pero' non e' servito.
# Quello vecchio, 2 MB per file e 6 MB in tutto, aveva costretto Aura a 600 per
# 1067 mentre gli altri due stavano a 720 per 1280. La diagnosi di allora, "il
# peso dipende dal movimento e non dalla qualita'", era giusta a meta': il peso
# dipendeva dal CANALE ALPHA, che `libwebp` comprime senza perdita anche quando
# il colore va a perdita. Ridotto l'alpha a otto gradini, tutti e tre stanno a
# 720 per 1280 e la somma rientra perfino nel tetto vecchio.
TETTO_FILE = 3_000_000
TETTO_TOTALE = 8_500_000

# **LA GAMMA DELLA MASCHERA**, ordine AU voce 01. Sotto uno schiarisce, quindi
# le stelle deboli restano visibili invece di spegnersi. Il fondatore ha
# indicato 0,75 come punto di partenza.
GAMMA_MASCHERA = 0.75

# **SOTTO QUESTO VALORE IL FONDO E' FONDO**, e diventa trasparente netto.
# Vedi il commento dentro `converti`: senza soglia il file pesa il doppio.
SOGLIA_DEL_FONDO = 20

# **LA SOSTITUZIONE CONDIZIONALE, ed e' la leva che tiene il peso.** Sopra
# questa soglia un blocco che e' cambiato poco rispetto al fotogramma prima non
# viene riscritto: si tiene quello di prima. Su un filmato dove il fondo e'
# fermo e si muovono solo le stelle vuol dire non ripagare ogni fotogramma per
# intero. A zero e' spento, ed e' cosi' che i primi tre file sono usciti.
CR_SOGLIA = 0

# **A QUANTI GRADINI SI RIDUCE LA MASCHERA, ed e' la leva vera sul peso.**
# `libwebp` comprime il canale alpha SENZA PERDITA anche quando il colore va a
# perdita: un alpha con duecentocinquantasei livelli di sfumatura costa piu'
# dell'immagine che accompagna, ed e' per questo che la prima ricostruzione di
# Medora e' uscita a 6.660.122 byte contro il milione e mezzo del file opaco.
# Ridotta a pochi gradini, la maschera si comprime quasi a niente e le stelle
# restano quelle: nessuno guarda una stella e conta le sfumature del suo alone.
# A zero la riduzione e' spenta.
LIVELLI_DELL_ALPHA = 8


def _corri(argomenti):
    esito = subprocess.run(argomenti, capture_output=True, text=True)
    if esito.returncode != 0:
        raise RuntimeError(f"{argomenti[0]} caduto: {esito.stderr[-800:]}")
    return esito.stdout


def converti(maestro, ricostruisci_alpha, gamma=GAMMA_MASCHERA,
             qualita=QUALITA, soglia=SOGLIA_DEL_FONDO, morbidezza=0.0,
             ripresa=CR_SOGLIA, livelli=LIVELLI_DELL_ALPHA):
    """Fa un WebP animato dal .mov del Maestro, e ne restituisce il peso."""
    nome, _ = FILM[maestro]
    sorgente = os.path.join(SORGENTI, nome)
    uscita = os.path.join(DESTINAZIONE, f"stella_{maestro}.webp")
    os.makedirs(DESTINAZIONE, exist_ok=True)
    scala = f"scale={LARGHEZZA}:{ALTEZZA}:flags=lanczos"
    if ricostruisci_alpha:
        # **L'ALPHA DALLA LUMINANZA.** Si divide il flusso in due: uno resta
        # l'immagine, l'altro diventa scala di grigi, prende la gamma e fa da
        # maschera. `alphamerge` li rimette insieme. Il nero del fondo diventa
        # trasparente, il bianco delle stelle resta pieno.
        # **LA SOGLIA SOTTO LA GAMMA, e non e' estetica ma peso.** Il fondo
        # del sorgente non e' nero perfetto: e' nero con un velo di rumore di
        # compressione. Portato in alpha, quel velo diventa migliaia di pixel
        # appena diversi fra loro, e un canale alpha rumoroso non si comprime:
        # la prima prova, con la sola gamma, e' uscita a 6.742.900 byte, piu'
        # del doppio del tetto. Azzerare i valori sotto la soglia rende il
        # fondo trasparente PIATTO, che si comprime quasi a niente, e per di
        # piu' toglie l'alone grigio attorno alle stelle.
        filtro = (
            f"[0:v]{scala},format=rgba,split=2[img][mas];"
            f"[mas]format=gray,eq=gamma={gamma},"
            f"lutyuv=y='if(lt(val,{soglia}),0,"
            + (f"floor(val/{256 // livelli})*{256 // livelli}" if livelli else "val")
            + ")'"
            + (f",gblur=sigma={morbidezza}" if morbidezza else "") + "[alpha];"
            f"[img][alpha]alphamerge[out]"
        )
    elif livelli:
        # **ANCHE L'ALPHA CHE C'E' GIA' SI RIDUCE A GRADINI**, e per la stessa
        # ragione: `libwebp` lo comprime senza perdita, quindi le sfumature del
        # canale alpha costano piu' del colore che accompagnano. Qui l'alpha
        # non si ricostruisce, si estrae com'e' e si quantizza: le stelle
        # restano identiche, il peso scende. E' questa la leva che riporta
        # Aura a 720 per 1280 senza sfondare il tetto.
        filtro = (
            f"[0:v]{scala},format=rgba,split=2[img][mas];"
            f"[mas]alphaextract,"
            f"lutyuv=y='floor(val/{256 // livelli})*{256 // livelli}'[alpha];"
            f"[img][alpha]alphamerge[out]"
        )
    else:
        filtro = f"[0:v]{scala},format=rgba[out]"
    _corri([
        "ffmpeg", "-y", "-i", sorgente,
        "-filter_complex", filtro, "-map", "[out]",
        "-c:v", "libwebp_anim", "-pix_fmt", "yuva420p",
        "-lossless", "0", "-q:v", str(qualita), "-compression_level", "6",
        "-cr_threshold", str(ripresa),
        "-loop", "1", "-an", uscita,
    ])
    return os.path.getsize(uscita)


def quote_trasparenti(percorso, soglia=26, quanti=50):
    """La quota di pixel quasi trasparenti in OGNI fotogramma, da 0 a 1.

    **La misura che l'ordine AU voce 01 pretende**: a inizio e a fine
    transizione lo schermo deve essere quasi tutto vuoto, se no la festa
    comincia con un lampo che copre il traguardo, e al fotogramma dello stacco
    il fondo si deve vedere attraverso. Soglia 26 su 255, cioe' il dieci per
    cento: sotto quel valore un pixel non si vede.

    **SI RIPORTA A VENTICINQUE AL SECONDO, e serve.** Il WebP animato non ha
    cinquanta fotogrammi ma quaranta, venticinque o trentanove, perche'
    `libwebp` fonde quelli identici e ne allunga la durata (misurato, ordine AT
    voce 02). Chiedere "il fotogramma 49" a un file che ne dichiara 25 non da'
    niente, ed e' cosi' che la prima stesura di questa misura e' caduta. Con
    `fps=25` il fotogramma torna a essere l'istante: il ventunesimo e' 840
    millesimi tanto nel sorgente quanto nel derivato.
    """
    lato_l, lato_a = 90, 160
    grezzo = subprocess.run([
        "ffmpeg", "-v", "error", "-i", percorso,
        "-vf", f"alphaextract,fps=25,scale={lato_l}:{lato_a}",
        "-frames:v", str(quanti),
        "-f", "rawvideo", "-pix_fmt", "gray", "-",
    ], capture_output=True)
    dati = grezzo.stdout
    per_fotogramma = lato_l * lato_a
    if len(dati) < per_fotogramma:
        raise RuntimeError(f"nessun fotogramma da {percorso}: {grezzo.stderr[-300:]}")
    quote = []
    for i in range(len(dati) // per_fotogramma):
        f = dati[i * per_fotogramma:(i + 1) * per_fotogramma]
        quote.append(sum(1 for p in f if p < soglia) / per_fotogramma)
    return quote


def sorgente_di(maestro):
    return os.path.join(SORGENTI, FILM[maestro][0])


def misura_tutti():
    """Stampa la tabella che l'ordine chiede: peso, e la quota trasparente."""
    totale = 0
    for maestro in FILM:
        percorso = os.path.join(DESTINAZIONE, f"stella_{maestro}.webp")
        if not os.path.exists(percorso):
            print(f"{maestro}: non convertito")
            continue
        peso = os.path.getsize(percorso)
        totale += peso
        fuori = " FUORI TETTO" if peso > TETTO_FILE else ""
        print(f"{maestro}: {peso:,} byte{fuori}")
    print(f"somma: {totale:,} byte su un tetto di {TETTO_TOTALE:,}"
          f"{' FUORI TETTO' if totale > TETTO_TOTALE else ''}")
    return totale


def main():
    modo = sys.argv[1] if len(sys.argv) > 1 else "misura"
    if modo == "misura":
        misura_tutti()
    elif modo == "tutti":
        for maestro, (_, ricostruisci) in FILM.items():
            peso = converti(maestro, ricostruisci)
            print(f"{maestro}: {peso:,} byte"
                  f"{' con alpha ricostruito' if ricostruisci else ''}")
        misura_tutti()
    elif modo in FILM:
        peso = converti(modo, FILM[modo][1])
        print(f"{modo}: {peso:,} byte")
    else:
        print("modo non valido: misura, tutti, o il nome di un Maestro")


if __name__ == "__main__":
    main()
