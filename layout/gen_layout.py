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
M1, M2, V1, GC, WN, AP, TXM1, TXM2, PRB = L(13, 0), L(20, 0), L(19, 0), L(8, 1), L(140, 0), L(3, 1), L(48, 0), L(49, 0), L(235, 0)

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


# ---------------------------------------------------------------- 1-bit SRAM
# 列: invA(0) invB(20) wordINV(40) TG(60)   PMOS y=0 / NMOS y=-23
# 交差する配線は M2 に逃がす: WORDB(y=-3.5) Q(y=-10) WORD(y=-15)
# TG のゲートはポリを横に振って、拡散から離れた場所にコンタクトを置く
def build_sram():
    c = ly.create_cell("ytr0_sram")
    yP, yN, yVDD, yVSS = 0.0, -23.0, 8.0, -29.0
    A, B, W, T = 0.0, 20.0, 40.0, 60.0
    def fets(x):
        inst(c, "fet_p", x, yP, {"w": 8.2, "l": 1.0}); inst(c, "fet_n", x, yN, {"w": 3.4, "l": 1.0})
    def inverter_at(x):
        fets(x)
        path(c, [(x, yP - 5.3), (x, yN + 2.9)], 1.0, GC)
        inst(c, "cont_g", x, -15.0)
        path(c, [(x + 2.0, yP), (x + 4.2, yP), (x + 4.2, yN), (x + 2.0, yN)], 1.8)
        path(c, [(x - 2.0, yP), (x - 2.0, yVDD)], 1.8)
        path(c, [(x - 2.0, yN), (x - 2.0, yVSS)], 1.8)
    def via(x, y):
        box(c, x - 1.7, y - 1.7, x + 1.7, y + 1.7, M1)
        box(c, x - 0.7, y - 0.7, x + 0.7, y + 0.7, V1)
        box(c, x - 1.7, y - 1.7, x + 1.7, y + 1.7, M2)
    for x in (A, B, W):
        inverter_at(x)
    fets(T)                                                     # transmission gate
    path(c, [(T, yP - 5.3), (T, -7.0), (50.0, -7.0)], 1.0, GC); inst(c, "cont_g", 50.0, -7.0)    # PMOS gate = WORDB
    path(c, [(T, yN + 2.9), (T, -19.0), (49.0, -19.0)], 1.0, GC); inst(c, "cont_g", 49.0, -19.0) # NMOS gate = WORD
    path(c, [(T - 2.0, yP), (T - 4.2, yP), (T - 4.2, yN), (T - 2.0, yN)], 1.8)                   # 左 S/D = Q
    path(c, [(T + 2.0, yP), (T + 6.0, yP), (T + 6.0, yN), (T + 2.0, yN)], 1.8)                   # 右 S/D = DATA
    path(c, [(T + 6.0, -15.0), (T + 12.0, -15.0)], 1.8); label(c, "DATA", T + 11.5, -15.0)
    path(c, [(A + 4.2, -19.0), (B, -19.0), (B, -15.0)], 1.8)                                     # QB (M1)
    via(B + 4.2, -9.5); via(T - 4.2, -9.5); via(A - 8.0, -9.5)                                # Q (M2)
    path(c, [(A - 8.0, -9.5), (T - 4.2, -9.5)], 3.0, M2)
    path(c, [(A - 8.0, -9.5), (A - 8.0, -15.0), (A, -15.0)], 1.8)
    path(c, [(W, -15.0), (34.0, -15.0)], 1.8); via(34.0, -15.0)                                  # WORD (M2)
    box(c, 47.3, -20.3, 50.7, -13.3, M1); via(49.0, -15.0)          # コンタクトとビアを 1 枚の M1 でつなぐ
    path(c, [(A - 14.0, -15.0), (49.0, -15.0)], 3.0, M2); label(c, "WORD", A - 13.5, -15.0, TXM2)
    via(W + 4.2, -3.5); via(50.0, -3.5)                                                          # WORDB (M2)
    path(c, [(W + 4.2, -3.5), (50.0, -3.5)], 3.0, M2)
    box(c, 48.3, -8.3, 51.7, -1.8, M1)
    xl, xr = A - 18.0, T + 12.0
    path(c, [(xl, yVDD), (xr, yVDD)], 2.6); inst(c, "cont_n", xl + 2.0, yVDD); label(c, "VDD", xl + 1.0, yVDD)
    path(c, [(xl, yVSS), (xr, yVSS)], 2.6); inst(c, "cont_p", xl + 2.0, yVSS); label(c, "VSS", xl + 1.0, yVSS)
    tie = pya.DBox(xl + 0.7, yVDD - 1.3, xl + 3.3, yVDD + 1.3)
    box(c, min(A - 3.3 - 7, tie.left - 5), min(yP - 4.1 - 7, tie.bottom - 5),
           max(T + 3.3 + 7, tie.right + 5), max(yP + 4.1 + 7, tie.top + 5), WN)
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
# variant = "inverter_only" | "full"(= inverter + SRAM) | "sram_only"
# 外部接続の方針:
#   - 信号は 5um 角のパッドでブロックの外周に出す（作業者が迷わないように）
#   - Q と WORD は電源レールを M1 でまたげないので M2 で下へ抜く
#   - VDD / VSS のレールは左右の端まで伸ばす（他ブロックと共有して数珠つなぎにできる）
#   - prBoundary でブロックの範囲を示す
PAD = 2.5                                   # パッドは 5um 角

def port_m1(cell, name, x, y):
    box(cell, x - PAD, y - PAD, x + PAD, y + PAD, M1); label(cell, name, x, y)
def port_m2(cell, name, x, y):
    box(cell, x - PAD, y - PAD, x + PAD, y + PAD, M2); label(cell, name, x, y, TXM2)
def m1_to_m2(cell, x, y):                   # V1 + 上下の 3.4 角パッド
    box(cell, x - 1.7, y - 1.7, x + 1.7, y + 1.7, M1)
    box(cell, x - 0.7, y - 0.7, x + 0.7, y + 0.7, V1)
    box(cell, x - 1.7, y - 1.7, x + 1.7, y + 1.7, M2)

variant = variant if "variant" in dir() else "full"
assert variant in ("inverter_only", "full", "sram_only"), variant
top = ly.create_cell("ytr0_top")
XL, YBOT = -20.0, -36.0                     # 左端 / 下端のパッド位置

if variant == "sram_only":
    sr = build_sram()
    top.insert(pya.DCellInstArray(sr.cell_index(), pya.DTrans(0, 0)))
    XR = 88.0
    path(top, [(71.5, -15.0), (XR, -15.0)], 1.8); port_m1(top, "DATA", XR, -15.0)
    path(top, [(-12.5, -15.0), (-12.5, YBOT)], 3.0, M2); port_m2(top, "WORD", -12.5, YBOT)
    for nm, yy in (("VDD", 8.0), ("VSS", -29.0)):
        path(top, [(XL, yy), (XR, yy)], 2.6)
        port_m1(top, nm, XL, yy); port_m1(top, nm, XR, yy)   # 左右どちらからでもつなげる（名前は同じ）
else:
    inv = build_inverter()
    top.insert(pya.DCellInstArray(inv.cell_index(), pya.DTrans(0, 0)))
    top.insert(pya.DCellInstArray(build_art("ytr0").cell_index(), pya.DTrans(16.0, -20.0)))
    XR = 88.0
    if variant == "full":
        SX = 110.0
        sr = build_sram()
        top.insert(pya.DCellInstArray(sr.cell_index(), pya.DTrans(SX, 0.0)))
        XR = SX + 76.0
        path(top, [(SX + 71.5, -15.0), (XR, -15.0)], 1.8); port_m1(top, "DATA", XR, -15.0)
        path(top, [(SX - 12.5, -15.0), (SX - 12.5, YBOT)], 3.0, M2)   # 横配線の端に合わせる（角の欠け対策）
        port_m2(top, "WORD", SX - 12.5, YBOT)
    # A: 左へ / Q: M2 で下へ
    path(top, [(-10.0, -15.0), (XL, -15.0)], 1.8); port_m1(top, "A", XL, -15.0)
    m1_to_m2(top, 10.0, -15.0)
    path(top, [(10.0, -15.0), (10.0, YBOT)], 3.0, M2); port_m2(top, "Q", 10.0, YBOT)
    # 電源レール: 左右の端まで通す（共有しやすいように両端にパッド）
    for nm, yy in (("VDD", 8.0), ("VSS", -29.0)):
        path(top, [(XL, yy), (XR, yy)], 2.6)
        port_m1(top, nm, XL, yy); port_m1(top, nm, XR, yy)   # 左右どちらからでもつなげる（名前は同じ）

bb = top.dbbox()
top.shapes(PRB).insert(pya.DBox(bb.left - 1, bb.bottom - 1, bb.right + 1, bb.top + 1))
ly.write(out)
print("WROTE %s variant=%s top=%s bbox=%s" % (out, variant, top.name, top.dbbox()))
