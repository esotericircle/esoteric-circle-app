# Converte i master PNG in derivati WebP ottimizzati per l'app.
# Non tocca mai gli originali: legge da output/<famiglia>/ e scrive in
# output/derivati/webp/<famiglia>/. Ridimensiona al lato lungo target per
# famiglia (solo se il master e' piu' grande, mai upscale), poi salva WebP a
# qualita' alta con l'alpha preservato. Elabora solo i file .png al primo
# livello che non iniziano con "_" (salta report, sheet, cartelle interni e _raw).
import os
import sys
from PIL import Image

SRC = "output"
DST = os.path.join("output", "derivati", "webp")
TARGET = {
    "mazzo-tarocchi": 1400,
    "angeli": 1400,
    "ritratti-vip": 1200,
    "rune_bone": 1000,
    "animali": 1000,
    "cristalli": 1000,
}
QUALITY = 88
CAMPIONE = ("mazzo-tarocchi", "tar_rw_00_il-matto_v1.png")

def file_png(famiglia):
    d = os.path.join(SRC, famiglia)
    if not os.path.isdir(d):
        return []
    out = []
    for n in sorted(os.listdir(d)):
        p = os.path.join(d, n)
        if os.path.isfile(p) and n.lower().endswith(".png") and not n.startswith("_"):
            out.append(n)
    return out

def converti(src_path, dst_path, target_long):
    img = Image.open(src_path)
    if img.mode not in ("RGB", "RGBA"):
        img = img.convert("RGBA")
    w, h = img.size
    lung = max(w, h)
    if lung > target_long:
        scala = target_long / lung
        img = img.resize((round(w * scala), round(h * scala)), Image.LANCZOS)
    os.makedirs(os.path.dirname(dst_path), exist_ok=True)
    img.save(dst_path, "WEBP", quality=QUALITY, method=6)
    return img.size

def dst_di(famiglia, nome_png):
    stem = os.path.splitext(nome_png)[0].lower()
    return os.path.join(DST, famiglia, stem + ".webp")

def misura():
    for fam in TARGET:
        nomi = file_png(fam)
        if not nomi:
            print(f"{fam}: nessun png trovato")
            continue
        pmax = pmin = None
        peso_tot = 0
        for n in nomi:
            p = os.path.join(SRC, fam, n)
            peso_tot += os.path.getsize(p)
            with Image.open(p) as im:
                lung = max(im.size)
                pmax = lung if pmax is None else max(pmax, lung)
                pmin = lung if pmin is None else min(pmin, lung)
        print(f"{fam}: {len(nomi)} file, lato lungo da {pmin} a {pmax} px, peso totale {peso_tot / 1048576:.1f} MB, target {TARGET[fam]} px")

def campione():
    fam, nome = CAMPIONE
    src = os.path.join(SRC, fam, nome)
    dst = dst_di(fam, nome)
    size = converti(src, dst, TARGET[fam])
    vecchio = os.path.getsize(src)
    nuovo = os.path.getsize(dst)
    print(f"campione {fam}/{nome}")
    print(f"  master: {vecchio / 1048576:.2f} MB")
    print(f"  webp:   {nuovo / 1024:.0f} KB, {size[0]}x{size[1]} px")
    print(f"  scritto in {dst}")

def batch():
    tot_v = tot_n = n_file = 0
    for fam in TARGET:
        for nome in file_png(fam):
            src = os.path.join(SRC, fam, nome)
            dst = dst_di(fam, nome)
            converti(src, dst, TARGET[fam])
            tot_v += os.path.getsize(src)
            tot_n += os.path.getsize(dst)
            n_file += 1
        print(f"{fam}: convertito")
    print(f"Totale: {n_file} file, da {tot_v / 1048576:.0f} MB a {tot_n / 1048576:.1f} MB in WebP")

def main():
    modo = sys.argv[1] if len(sys.argv) > 1 else "misura"
    if modo == "misura":
        misura()
    elif modo == "campione":
        campione()
    elif modo == "batch":
        batch()
    else:
        print("modo non valido: usa misura, campione o batch")

if __name__ == "__main__":
    main()
