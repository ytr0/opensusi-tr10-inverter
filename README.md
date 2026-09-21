# opensusi-tr10-inverter

OpenSUSI-TR10（TR-1um PDK、1µm CMOS）で作った CMOS インバータ一式です。

回路図は xschem、レイアウトは KLayout で作りました。
DRC と LVS、それにレイアウトから抽出した回路のシミュレーションまで、コマンド1つで通せます。

| 項目 | 値 |
|---|---|
| PDK | [OpenSUSI/TR-1um](https://github.com/OpenSUSI/TR-1um) v1.2609.0 |
| トランジスタ | PMOS W=8.2µm / NMOS W=3.4µm（L=1µm） |
| 大きさ | 24.6 × 44.6µm（アートを入れて 99 × 45µm） |
| DRC | 違反 0 件 |
| LVS | 一致 |
| しきい値 / VOH / VOL | 2.498V / 5.00V / 0.00V（VDD=5V） |
| 遅延 tpHL / tpLH | 0.84ns / 0.70ns（負荷 100fF、27℃） |

PMOS の幅を 8.2µm にしたのには理由があります。
この値だと、しきい値が VDD のちょうど半分になり、
立ち上がりと立ち下がりの速さもそろいます（1.14ns と 1.17ns）。

### inverter_only

![inverter_only](docs/layout_inverter_only.png)

左がインバータ、右が M2 で描いた `ytr0` の文字です。

### full（温度センサ付き）

![full](docs/layout_full.png)

右下が温度センサです。緑の枠が N ウェルで、その中に小さなダイオードが9個ならびます。
中央の1個が TEMP1、のこり8個は上のバスでまとめて TEMP8 になります。
ダイオードにかかる斜めの帯は、光をさえぎる M2 のふたです。
左上から回りこむ線が VSS です。

## 渡すファイル

追加パッドをもらえるかどうかで中身が変わるので、2つ用意しました。
**ファイルを差し替えるだけ**で切り替わります。トップセル名はどちらも `ytr0_top` です。
GDS を編集してもらう必要はありません。

| 名前 | 中身 | ピン | 場所 |
|---|---|---|---|
| `inverter_only` | インバータ + アート | A, Q, VDD, VSS | `variants/inverter_only/ytr0_top.gds` |
| `full` | 上記 + 温度センサ | 上記 + TEMP1, TEMP8 | `variants/full/ytr0_top.gds` |

どちらも DRC は 0 件、LVS は一致します。
LVS 用のネットリストは、それぞれの `simulation/ytr0_top.spice` に入っています。

## 動かし方

PDK の用意は [ishi-kai/OpenEDA-PDK_SetupScript](https://github.com/ishi-kai/OpenEDA-PDK_SetupScript) を見てください。
`$PDK_ROOT` と `$PDK`（= `TR-1um`）が設定されている前提です。

```sh
./check.sh                 # 2つとも レイアウト生成 → DRC → LVS
./check.sh full            # 片方だけ

xschem sim.sch             # 回路図とテストベンチを開く
postlayout/run.sh          # インバータ単体の DRC → LVS → シミュレーション比較
ngspice postlayout/tb_tempsens.spice   # 温度センサの特性をグラフで見る
```

レイアウトを KLayout で開くときは、**かならず `klayout.sh` を使ってください**。
ライブラリを相対パスで読むので、直接起動すると落ちます。

```sh
cd variants/full && klayout.sh -n TR-1um ytr0_top.gds
```

`check.sh` の出力はこうなります。

```
=== full
>> layout    WROTE .../variants/full/ytr0_top.gds
>> DRC       violations: 0
>> LVS       INFO : Congratulations! Netlists match.
```

## 温度センサの使い方

中身は ΔVbe 方式です。同じ大きさのダイオードを、1個と8個で比べます。
2つの電圧の差が温度に比例するので、**ダイオードの個体差に左右されません**。

1. TEMP1 に 10µA を流して、VSS との電圧を測る（25℃ で約 0.762V）
2. 同じ電流源を TEMP8 につなぎかえて、もう一度測る（25℃ で約 0.704V）
3. 差をとって温度に直す

```
ΔVbe = V(TEMP1) − V(TEMP8)          25℃ で約 57.9mV
T[℃] = 25 + (ΔVbe[mV] − 57.9) / 0.193
```

気をつける点です。

- 電流源は**1つを切り替えて**使ってください。別々にすると、1% の差が約 1.3℃ の誤差になります
- 電圧源を直接つながないでください。かならず電流源か、直列の抵抗（5V なら 430kΩ で約 10µA）を通します
- 電流は 100µA までにしてください。それ以上だと直線からずれます
- 測っている間は、インバータの入力を動かさないでください。VSS に電流が流れて、数 mV ずれます
- 普通のテスタで読みたいときは、TEMP1 の電圧だけを使う簡易な方法もあります。
  感度は -1.26mV/℃ と大きいかわりに、個体差が乗るので1点校正が必要です

センサ自体の作りは次のとおりです。

- ダイオードは DP（N ウェルの中の P+）。9個を一列にならべ、中央を TEMP1 にしています。
  ウェハ上の特性の傾きを打ち消すための配置です
- N ウェルが共通のカソードで、VSS につないでいます。**VDD は使いません**
- 上を M2 でふさいで遮光しています。パッケージに光が入っても値がずれません

## ファイル

| ファイル | 中身 |
|---|---|
| `ytr0_inverter.sch` | インバータの回路図 |
| `ytr0_tempsens.sch` | 温度センサの回路図（DP ダイオード 9個） |
| `variants/*/ytr0_top.sch` | トップの回路図（ブロックをならべたもの） |
| `variants/*/ytr0_top.gds` | トップのレイアウト |
| `layout/gen_layout.py` | レイアウトを作るスクリプト（`-rd variant=full`） |
| `check.sh` | 2つのバリアントの DRC と LVS |
| `sim.sch` | インバータの DC 特性を見るテストベンチ |
| `main.sch` | 新しく設計を始めるときの雛形 |
| `postlayout/run.sh` | インバータ単体の検証（DRC → LVS → シミュレーション比較） |
| `postlayout/tb_tempsens.spice` | 温度センサの温度特性を見るテストベンチ |

## センサだけ外せる作りになっています

```
ytr0_top
├── ytr0_inverter  (A, Q, VDD, VSS)
├── ytr0_tempsens  (TEMP1, TEMP8, VSS)   ← full のみ
└── art_ytr0       (M2 のアート、配線なし)
```

- 電源の配線は `ytr0_top` 側にあります。センサのセルを消しても、インバータの電源は切れません
- TEMP1 と TEMP8 のラベルはセンサのセルの中にあるので、セルを消せば一緒に消えます
- とはいえ、`inverter_only` のファイルに差し替えてもらうのが確実です

## この PDK で詰まったところ

同じところで止まる人がいそうなので、書き残しておきます。

**LVS が読む回路図の場所**
KLayout の LVS は、レイアウトと同じフォルダの `simulation/<トップセル名>.spice` を探します。
レイアウトのトップセル名と、回路図の subckt 名をそろえてください。

**LVS 用のネットリスト**
xschem で `lvs_netlist` を有効にして出します。
このとき、シミュレーション用のコードブロック（`.include` や `.control`）には `lvs_ignore=open` を付けて外します。
外さないと、KLayout の SPICE リーダーがパスの解釈でつまずきます。

**ピンになるのはトップセルのラベルだけ**
ブロックのセルの中に置いたラベルは、トップのピンになりません。
トップセルにも同じ名前のラベルを置いてください。

**シリコンアート**
M2 の浮いた図形なら、DRC も LVS も通ります。幅は 3.0µm 以上、間隔は 2.0µm 以上です。
V1 と TXM2 のテキストは使わないでください。配線やピンとして認識されてしまいます。

**パッシベーションの穴はパッドにしか開けられません**（`PO.Z3`）。
可動部のある MEMS は、この標準のフローでは作れません。
