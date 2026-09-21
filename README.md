# opensusi-tr10-inverter

OpenSUSI-TR10（TR-1um PDK、1µm CMOS）で作った CMOS インバータ一式です。

回路図は xschem、レイアウトは KLayout で作りました。

| 項目 | 値 |
|---|---|
| PDK | [OpenSUSI/TR-1um](https://github.com/OpenSUSI/TR-1um) v1.2609.0 |
| トランジスタ | PMOS W=8.2µm / NMOS W=3.4µm（L=1µm） |
| 大きさ | インバータ 24.6 × 44.6µm / SRAM 94 × 45µm（full 全体で 196 × 45µm） |
| DRC | 違反 0 件 |
| LVS | 一致 |
| SRAM | トランジスタ 8個。書き込み・保持・読み出しを確認済み |
| しきい値 / VOH / VOL | 2.498V / 5.00V / 0.00V（VDD=5V） |
| 遅延 tpHL / tpLH | 0.84ns / 0.70ns（負荷 100fF、27℃） |

PMOS の幅を 8.2µm に。
この値だと、しきい値が VDD のちょうど半分になり、
立ち上がりと立ち下がりの速さもそろいます（1.14ns と 1.17ns）。

### inverter_only

![inverter_only](docs/layout_inverter_only.png)

左がインバータ、右が M2 で描いた `ytr0` の文字です。

### full（SRAM 付き）

![full](docs/layout_full.png)

左がインバータ、中央が M2 のアート、右が 1ビットの SRAM です。
上下の太い線が VDD と VSS。この電源の配線はトップのセルにあるので、SRAM を消しても切れません。

### sram_only（SRAM だけを拡大）

![sram_only](docs/layout_sram_only.png)

左の2列がラッチ、3列目が WORD を反転するインバータ、右端がトランスミッションゲートです。
灰色の横帯は M2 の配線（上が Q のたすきがけ、下が WORD）。小さな四角が M1 と M2 をつなぐ V1 です。

## 渡すファイル

追加パッドをもらえるかどうかで中身が変わるので、複数を用意しました。
**ファイルを差し替えるだけ**で切り替わります。トップセル名はどちらも `ytr0_top` です。
GDS を編集してもらう必要はありません。

| 名前 | 中身 | ピン | 場所 |
|---|---|---|---|
| `inverter_only` | インバータ + アート | A, Q, VDD, VSS | `variants/inverter_only/ytr0_top.gds` |
| `full` | 上記 + 1ビット SRAM | 上記 + DATA, WORD | `variants/full/ytr0_top.gds` |
| `sram_only` | SRAM 単体（検証用） | DATA, WORD, VDD, VSS | `variants/sram_only/ytr0_top.gds` |

いずれも DRC は 0 件、LVS は一致します。
LVS 用のネットリストは、それぞれの `simulation/ytr0_top.spice` に入っています。

詳しい手順（動かし方、渡し方、SRAM の使い方、ファイルの一覧、PDK でつまずいたところ）は
[USAGE.md](USAGE.md) にまとめてあります。
