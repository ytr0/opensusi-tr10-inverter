import pya
ly = pya.Layout(); ly.technology_name = "TR-1um"; ly.dbu = 0.001
top = ly.create_cell("inverter")
L = lambda a,b: ly.layer(a,b)
M1, GC, WN, TXT = L(13,0), L(8,1), L(140,0), L(48,0)
def inst(name, x, y, p={}):
    c = ly.create_cell(name, "TR-1um", p); assert c, name
    top.insert(pya.DCellInstArray(c.cell_index(), pya.DTrans(x, y)))
def path(pts, w, layer=M1):
    top.shapes(layer).insert(pya.DPath([pya.DPoint(*q) for q in pts], w))
def label(t, x, y): top.shapes(TXT).insert(pya.DText(t, x, y))
yP, yN, yG, yVDD, yVSS = 0.0, -23.0, -15.0, 8.0, -29.0
inst("fet_p", 0, yP, {"w": 8.2, "l": 1.0})           # AP: y -4.1..4.1
inst("fet_n", 0, yN, {"w": 3.4, "l": 1.0})           # AN: y -24.7..-21.3
# gate: one poly line joining both gates, contact outside the well, M1 to A
path([(0, yP-5.3), (0, yN+2.9)], 1.0, GC)
inst("cont_g", 0, yG)
path([(0, yG), (-10.0, yG)], 1.8); label("A", -9.5, yG)
# output: both drains (right S/D) -> Q
path([(2.0, yP), (4.2, yP), (4.2, yN), (2.0, yN)], 1.8)
path([(4.2, yG), (10.0, yG)], 1.8); label("Q", 9.5, yG)
# supplies: sources (left S/D) -> rails, with well tie (N+ in WN) and substrate tie (P+)
path([(-2.0, yP), (-2.0, yVDD)], 1.8); path([(-10.0, yVDD), (8.0, yVDD)], 2.6)
inst("cont_n", -8.0, yVDD); label("VDD", -9.5, yVDD)
path([(-2.0, yN), (-2.0, yVSS)], 1.8); path([(-10.0, yVSS), (8.0, yVSS)], 2.6)
inst("cont_p", -8.0, yVSS); label("VSS", -9.5, yVSS)
# N-well: AP enclosure >= 7.0 (AP.WN), N+ tie enclosure >= 5.0 (AN.WN(M))
ap = pya.DBox(-3.3, yP-4.1, 3.3, yP+4.1); tie = pya.DBox(-9.3, yVDD-1.3, -6.7, yVDD+1.3)
top.shapes(WN).insert(pya.DBox(min(ap.left-7, tie.left-5), min(ap.bottom-7, tie.bottom-5),
                               max(ap.right+7, tie.right+5), max(ap.top+7, tie.top+5)))
# ---- silicon art: "ytr0" on M2 (floating; no V1, no TXM2 text) --------------------------
# 5x7 pixel font, pixel 3.0um (= M2 min width), 1-pixel gap between letters (3.0um >= M2 min space 2.0um)
# glyphs avoid corner-only pixel contacts (would create zero-width/zero-space DRC errors)
GLYPHS = {
 "y": ["#...#","#...#","#...#","#####","....#","....#","#####"],
 "t": [".#...",".#...","####.",".#...",".#...",".#...",".###."],
 "r": [".....",".....","####.","#....","#....","#....","#...."],
 "0": ["#####","#...#","#...#","#.#.#","#...#","#...#","#####"],
}
def art_cell(text, px=3.0):
    c = ly.create_cell("art_" + text); m2 = ly.layer(20, 0)
    reg = pya.Region()
    for k, ch in enumerate(text):
        for r, row in enumerate(GLYPHS[ch]):
            for col, v in enumerate(row):
                if v == "#":
                    x = (k*6 + col)*px; y = (6 - r)*px
                    reg.insert(pya.DBox(x, y, x+px, y+px).to_itype(ly.dbu))
    c.shapes(m2).insert(reg.merged())
    return c
art = art_cell("ytr0")
top.insert(pya.DCellInstArray(art.cell_index(), pya.DTrans(16.0, -20.0)))
ly.write(out); print("WROTE", out, top.dbbox())
