# TR-1um layout generator (KLayout: klayout.sh -zz -c ~/.klayout/klayoutrc -rd variant=full -rd out=... -r gen_layout.py)
#   variant = "inverter_only" | "full"
# セル構成:
#   ytr0_top
#   ├── ytr0_inverter  (A, Q, VDD, VSS)
#   ├── ytr0_tempsens  (TEMP1, TEMP8, VDD, VSS)   ... variant=full のときだけ
#   └── art_ytr0       (M2 のシリコンアート、配線なし)
# 電源レールは ytr0_top 側に置く。ytr0_tempsens を削除してもインバータの電源は切れない。
import pya

ly = pya.Layout(); ly.technology_name = "TR-1um"; ly.dbu = 0.001
L = lambda a, b: ly.layer(a, b)
M1, M2, GC, WN, AP, TXM1 = L(13, 0), L(20, 0), L(8, 1), L(140, 0), L(3, 1), L(48, 0)

def inst(cell, name, x, y, p={}):
    c = ly.create_cell(name, "TR-1um", p); assert c, name
    cell.insert(pya.DCellInstArray(c.cell_index(), pya.DTrans(x, y)))
def path(cell, pts, w, layer=M1):
    cell.shapes(layer).insert(pya.DPath([pya.DPoint(*q) for q in pts], w))
def box(cell, x1, y1, x2, y2, layer):
    cell.shapes(layer).insert(pya.DBox(x1, y1, x2, y2))
def label(cell, t, x, y, layer=TXM1):
    cell.shapes(layer).insert(pya.DText(t, x, y))

# ---------------------------------------------------------------- inverter
def build_inverter():
    c = ly.create_cell("ytr0_inverter")
    yP, yN, yG, yVDD, yVSS = 0.0, -23.0, -15.0, 8.0, -29.0
    inst(c, "fet_p", 0, yP, {"w": 8.2, "l": 1.0})
    inst(c, "fet_n", 0, yN, {"w": 3.4, "l": 1.0})
    path(c, [(0, yP - 5.3), (0, yN + 2.9)], 1.0, GC)          # gates joined by poly
    inst(c, "cont_g", 0, yG)
    path(c, [(0, yG), (-10.0, yG)], 1.8); label(c, "A", -9.5, yG)
    path(c, [(2.0, yP), (4.2, yP), (4.2, yN), (2.0, yN)], 1.8)  # drains -> Q
    path(c, [(4.2, yG), (10.0, yG)], 1.8); label(c, "Q", 9.5, yG)
    path(c, [(-2.0, yP), (-2.0, yVDD)], 1.8)                   # sources -> rails
    path(c, [(-10.0, yVDD), (8.0, yVDD)], 2.6)
    inst(c, "cont_n", -8.0, yVDD); label(c, "VDD", -9.5, yVDD)
    path(c, [(-2.0, yN), (-2.0, yVSS)], 1.8)
    path(c, [(-10.0, yVSS), (8.0, yVSS)], 2.6)
    inst(c, "cont_p", -8.0, yVSS); label(c, "VSS", -9.5, yVSS)
    ap = pya.DBox(-3.3, yP - 4.1, 3.3, yP + 4.1)               # N-well: AP.WN 7.0 / AN.WN(M) 5.0
    tie = pya.DBox(-9.3, yVDD - 1.3, -6.7, yVDD + 1.3)
    box(c, min(ap.left - 7, tie.left - 5), min(ap.bottom - 7, tie.bottom - 5),
           max(ap.right + 7, tie.right + 5), max(ap.top + 7, tie.top + 5), WN)
    return c

# ---------------------------------------------------------------- temp sensor
# DP ダイオード 9 個を 1 列に並べた dVbe センサ（1 次元コモンセントロイド）
#   中央 1 個   -> TEMP1     周囲 8 個を並列 -> TEMP8     N ウェル(共通カソード) -> VSS
# DP = ポリに触れない AP が WN の中にあるもの (02_Device.drc)。上を M2 で覆って遮光する。
def build_tempsens():
    c = ly.create_cell("ytr0_tempsens")
    d, gap = 3.6, 2.0                       # AP 3.6um 角, AP.S1 >= 1.4 / M1.S1 >= 1.4
    pitch = d + gap
    xs = [(i - 4) * pitch for i in range(9)]  # 9 個: index 4 が中央
    for x in xs:
        inst(c, "diode_p", x, 0.0)
    yBus, yStub = 7.0, -7.0                 # 上に TEMP8 のバス, 下に TEMP1 の引き出し
    for i, x in enumerate(xs):
        if i != 4:
            path(c, [(x, 0.0), (x, yBus)], 1.8)
    path(c, [(xs[0] - 0.9, yBus), (xs[-1] + 0.9, yBus)], 1.8)   # 端を半幅ぶん伸ばしてノッチを防ぐ
    label(c, "TEMP8", xs[0], yBus)
    global TS_T8_X, TS_T8_Y; TS_T8_X, TS_T8_Y = xs[0], yBus
    path(c, [(xs[4], 0.0), (xs[4], yStub)], 1.8)
    label(c, "TEMP1", xs[4], yStub)
    global TS_T1_X, TS_T1_Y; TS_T1_X, TS_T1_Y = xs[4], yStub
    xTie = xs[0] - d / 2 - 2.8 - 1.3        # N+ tie: AP.AN >= 2.8
    inst(c, "cont_n", xTie, 0.0)
    path(c, [(xTie, 0.0), (xTie, yStub)], 1.8); label(c, "VSS", xTie, yStub)
    global TS_VSS_X, TS_VSS_Y; TS_VSS_X, TS_VSS_Y = xTie, yStub
    apL, apR = xs[0] - d / 2, xs[-1] + d / 2
    box(c, min(apL - 7, xTie - 1.3 - 5), min(-d / 2 - 7, -1.3 - 5),
           apR + 7, d / 2 + 7, WN)          # AP.WN 7.0 / AN.WN(M) 5.0
    bb = c.dbbox()
    box(c, bb.left, -d / 2 - 2, bb.right, d / 2 + 2, M2)   # 遮光板（浮き M2, V1 なし）
    return c

# ---------------------------------------------------------------- silicon art
GLYPHS = {
 "y": ["#...#", "#...#", "#...#", "#####", "....#", "....#", "#####"],
 "t": [".#...", ".#...", "####.", ".#...", ".#...", ".#...", ".###."],
 "r": [".....", ".....", "####.", "#....", "#....", "#....", "#...."],
 "0": ["#####", "#...#", "#...#", "#.#.#", "#...#", "#...#", "#####"],
}
def build_art(text, px=3.0):               # M2 幅 3.0 / 間隔 2.0 を満たすピクセル文字
    c = ly.create_cell("art_" + text)
    reg = pya.Region()
    for k, ch in enumerate(text):
        for r, row in enumerate(GLYPHS[ch]):
            for col, v in enumerate(row):
                if v == "#":
                    x, y = (k * 6 + col) * px, (6 - r) * px
                    reg.insert(pya.DBox(x, y, x + px, y + px).to_itype(ly.dbu))
    c.shapes(M2).insert(reg.merged())
    return c

# ---------------------------------------------------------------- top
variant = variant if "variant" in dir() else "full"
assert variant in ("inverter_only", "full"), variant
top = ly.create_cell("ytr0_top")
inv = build_inverter()
top.insert(pya.DCellInstArray(inv.cell_index(), pya.DTrans(0, 0)))
top.insert(pya.DCellInstArray(build_art("ytr0").cell_index(), pya.DTrans(16.0, -20.0)))
# トップセルのラベル = LVS のピン（子セル内のラベルは top のピンにならない）
for t, x, y in (("A", -9.5, -15.0), ("Q", 9.5, -15.0), ("VDD", -9.5, 8.0), ("VSS", -9.5, -29.0)):
    label(top, t, x, y)
if variant == "full":
    ts = build_tempsens()
    # インバータの右下に配置（重なりなし・ウェル同士も離す）
    top.insert(pya.DCellInstArray(ts.cell_index(), pya.DTrans(60.0, -70.0)))
    # VSS レール（top 側に置く。ytr0_tempsens を消してもここは残る）
    # 温度センサは VDD を使わない（N ウェル = 共通カソードを VSS に落とすだけ）
    xv, yv = 60.0 + TS_VSS_X, -70.0 + TS_VSS_Y     # センサの VSS 引き出し線の端
    path(top, [(-10.0, -29.0), (xv, -29.0), (xv, yv)], 2.6)
    label(top, "TEMP1", 60.0 + TS_T1_X, -70.0 + TS_T1_Y)
    label(top, "TEMP8", 60.0 + TS_T8_X, -70.0 + TS_T8_Y)
ly.write(out)
print("WROTE %s variant=%s top=%s bbox=%s" % (out, variant, top.name, top.dbbox()))
