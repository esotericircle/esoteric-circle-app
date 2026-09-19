# Converte i master PNG in derivati WebP ottimizzati per l'app, in due misure.
import os
import sys
from PIL import Image

SRC = "output"
DST_FULL = os.path.join("output", "derivati", "webp")
DST_THUMB = os.path.join("output", "derivati", "webp_thumb")
TARGET = {
    "mazzo-tarocchi": 1400,
    "angeli": 1400,
    "ritratti-vip": 1200,
    "rune_bone": 1000,
    "animali": 1000,
    "cristalli": 1000,
}
QUALITY = 88
THUMB_LONG = 500
THUMB_QUALITY = 82
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

def converti(src_path, dst_path, target_long, quality):
    img = Image.open(src_path)
    if img.mode not in ("RGB", "RGBA"):
        img = img.convert("RGBA")
    w, h = img.size
    lung = max(w, h)
    if lung > target_long:
        scala = target_long / lung
        img = img.resize((round(w * scala), round(h * scala)), Image.LANCZOS)
    os.makedirs(os.path.dirname(dst_path), exist_ok=True)
    img.save(dst_path, "WEBP", quality=quality, method=6)
    return os.path.getsize(dst_path)

def dst_di(base, famiglia, nome_png):
    stem = os.path.splitext(nome_png)[0].lower()
    return os.path.join(base, famiglia, stem + ".webp")

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
        print(f"{fam}: {len(nomi)} file, lato lungo da {pmin} a {pmax} px, peso totale {peso_tot / 1048576:.1f} MB, piena {TARGET[fam]} px, miniatura {THUMB_LONG} px")

def campione():
    fam, nome = CAMPIONE
    src = os.path.join(SRC, fam, nome)
    p_full = converti(src, dst_di(DST_FULL, fam, nome), TARGET[fam], QUALITY)
    p_thumb = converti(src, dst_di(DST_THUMB, fam, nome), THUMB_LONG, THUMB_QUALITY)
    print(f"campione {fam}/{nome}, master {os.path.getsize(src) / 1048576:.2f} MB")
    print(f"  piena:     {p_full / 1024:.0f} KB")
    print(f"  miniatura: {p_thumb / 1024:.0f} KB")

def batch():
    n_file = 0
    tot_master = tot_full = tot_thumb = 0
    for fam in TARGET:
        f_full = f_thumb = 0
        nomi = file_png(fam)
        for nome in nomi:
            src = os.path.join(SRC, fam, nome)
            tot_master += os.path.getsize(src)
            f_full += converti(src, dst_di(DST_FULL, fam, nome), TARGET[fam], QUALITY)
            f_thumb += converti(src, dst_di(DST_THUMB, fam, nome), THUMB_LONG, THUMB_QUALITY)
            n_file += 1
        tot_full += f_full
        tot_thumb += f_thumb
        print(f"{fam}: {len(nomi)} file, piena {f_full / 1048576:.1f} MB, miniatura {f_thumb / 1048576:.1f} MB")
    print("---")
    print(f"Totale {n_file} file. Master {tot_master / 1048576:.0f} MB. Piena {tot_full / 1048576:.1f} MB. Miniatura {tot_thumb / 1048576:.1f} MB. Bundle app (piena piu' miniatura) {(tot_full + tot_thumb) / 1048576:.1f} MB")

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
