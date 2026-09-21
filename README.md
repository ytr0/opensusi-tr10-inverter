# opensusi-tr10-inverter

OpenSUSI-TR10（TR-1um PDK, 1µm CMOS）で作った CMOS インバータ一式。
回路図（xschem）、レイアウト（KLayout / PCell 生成スクリプト）、DRC・LVS・ポストレイアウト検証を
1 コマンドで回せるようにしてある。

| 項目 | 値 |
|---|---|
| PDK | [OpenSUSI/TR-1um](https://github.com/OpenSUSI/TR-1um) v1.2609.0 |
| デバイス | PMOS W=8.2µm / NMOS W=3.4µm, L=1µm |
| セルサイズ | 24.6 × 44.6µm（シリコンアートを含めて 99 × 45µm） |
| DRC | 違反 0 件 |
| LVS | 一致（Netlists match） |
| Vinv / VOH / VOL | 2.498V / 5.00V / 0.00V（VDD=5V） |
| tpHL / tpLH | 0.84ns / 0.70ns（100fF 負荷、27℃） |

PMOS の W は、しきい値電圧が VDD/2 になり、かつ立ち上がりと立ち下がりが対称（tr 1.14ns / tf 1.17ns）に
なる 8.2µm を選んでいる。

![レイアウト](docs/layout.png)

左がインバータ、右が M2 で描いたシリコンアート `ytr0`。

## 構成
| ファイル | 内容 |
|---|---|
| `inverter.sch` | インバータ本体の回路図（LVS の対象） |
| `sim.sch` | インバータの DC 特性を見るテストベンチ |
| `main.sch` | 新規設計用の雛形（モデル読み込み + シミュレーション設定のブロックのみ） |
| `inverter.gds` | レイアウト。トップセル名 `inverter`、シリコンアート `art_ytr0` を含む |
| `postlayout/gen_inverter_layout.py` | レイアウトを生成する KLayout スクリプト（PCell を配置し、N ウェルの寸法はルールから逆算） |
| `postlayout/run.sh` | DRC → LVS → 回路図とレイアウトのシミュレーション比較を通しで実行 |

## 使い方
PDK のセットアップは [ishi-kai/OpenEDA-PDK_SetupScript](https://github.com/ishi-kai/OpenEDA-PDK_SetupScript) を参照。
`$PDK_ROOT` と `$PDK`（= `TR-1um`）が設定されている前提。

```sh
# 回路図・テストベンチ
xschem sim.sch

# レイアウト（KLayout は必ず klayout.sh 経由で、プロジェクトのディレクトリから起動する）
klayout.sh -n TR-1um inverter.gds

# レイアウトを生成し直す
klayout.sh -zz -c ~/.klayout/klayoutrc -rd out=inverter.gds -r postlayout/gen_inverter_layout.py

# DRC → LVS → シミュレーション比較
postlayout/run.sh
```

`run.sh` の出力例:
```
>> 1b. DRC     violations: 0
>> 2.  LVS     INFO : Congratulations! Netlists match.
>> 3.  schematic   Vinv=2.49807e+00  VOH=5.00000e+00  VOL=1.89753e-08
        layout      Vinv=2.49807e+00  VOH=5.00000e+00  VOL=1.89753e-08
```

## この PDK で詰まった点
- **LVS が読む回路図のパス**: KLayout の LVS は、レイアウトファイルと同じディレクトリの
  `simulation/<トップセル名>.spice` を探す。レイアウトのトップセル名は回路図の subckt 名と一致させる。
- **LVS 用のネットリスト**: xschem で `lvs_netlist` を有効にして出力する。シミュレーション用の
  コードブロック（`.include` や `.control`）は `lvs_ignore=open` を付けて除外しないと、
  KLayout の SPICE リーダーがパスの解釈に失敗する。
- **シリコンアート**: M2（幅 3.0µm 以上、間隔 2.0µm 以上）の浮いた図形なら、DRC・LVS ともに影響しない。
  V1 と TXM2 のテキストは使わないこと（配線やピンとして認識されるため）。
- **パッシベーション開口（PO）はパッドにしか開けられない**（`PO.Z3`）。可動部を持つ MEMS 構造は、
  この標準フローでは作れない。

## ライセンス
Apache License 2.0
