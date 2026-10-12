#!/usr/bin/env python3
"""Genera el banner de terminal Hercule a partir de la silueta (medios bloques ANSI)."""
import os, numpy as np
from PIL import Image

GREEN=(57,255,20); BG=(10,14,10)
HERE=os.path.dirname(os.path.abspath(__file__))
SRC=os.path.join(HERE,"..","identidad-visual","_fuentes_svg","hercule-silueta-fuente.png")

def load_on_black(width):
    sil=Image.open(SRC).convert("RGBA")
    # escala a ancho objetivo, alto par
    r=width/sil.width
    h=int(sil.height*r)
    if h%2: h+=1
    sil=sil.resize((width,h),Image.LANCZOS)
    bg=Image.new("RGBA",(width,h),BG+(255,))
    bg.alpha_composite(sil)
    return np.asarray(bg.convert("RGB"))

def to_ansi(arr):
    """Medios bloques: cada celda = 2 filas (arriba=fg via ▀, abajo=bg)."""
    h,w,_=arr.shape
    lines=[]
    for y in range(0,h,2):
        row=[]
        for x in range(w):
            tr,tg,tb=arr[y,x]
            br,bg,bb=arr[y+1,x] if y+1<h else (BG)
            row.append(f"\x1b[38;2;{tr};{tg};{tb}m\x1b[48;2;{br};{bg};{bb}m▀")
        row.append("\x1b[0m")
        lines.append("".join(row))
    return "\n".join(lines)

def to_ascii(arr, ramp=" .:-=+*#%@"):
    """Version monocromo (densidad por luminancia del verde)."""
    h,w,_=arr.shape
    out=[]
    for y in range(0,h,2):
        line=[]
        for x in range(w):
            r,g,b=arr[y,x].astype(int)
            lum=(0.299*r+0.587*g+0.114*b)/255.0
            line.append(ramp[min(len(ramp)-1,int(lum*(len(ramp)-1)))])
        out.append("".join(line))
    return "\n".join(out)

if __name__=="__main__":
    arr=load_on_black(46)
    ansi=to_ansi(arr)
    open(os.path.join(HERE,"hercule-banner.ans"),"w").write(ansi+"\n")
    open(os.path.join(HERE,"hercule-banner.txt"),"w").write(to_ascii(arr)+"\n")
    # preview PNG a escala de la version chica (para verificar legibilidad)
    prev=Image.fromarray(arr).resize((46*8,arr.shape[0]*8),Image.NEAREST)
    prev.save(os.path.join(HERE,"_preview_banner.png"))
    print("banner ANSI:", len(ansi.splitlines()), "filas de texto")
