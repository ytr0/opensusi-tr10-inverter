#!/bin/zsh
# inverter: 回路図(inverter.sch) ↔ レイアウト(GDS) を LVS で対応付け、
# 同じテストベンチで「回路図」と「レイアウト抽出」の両方をシミュレーションして比較する。
#   usage: postlayout/run.sh [layout.gds]   (default: <project>/inverter.gds)
set -e
P=${0:A:h:h}                       # project dir
GDS=${1:-$P/inverter.gds}
CELL=inverter
OUT=$P/postlayout
PDK_T=$PDK_ROOT/$PDK/libs.tech
mkdir -p $OUT $P/simulation

print ">> 1. 回路図 → LVS用ネットリスト"
( cd $P && xschem -x -q -n -s --tcl 'set lvs_netlist 1; set lvs_ignore 1' \
    --netlist_path $P/simulation $CELL.sch >/dev/null 2>&1 )
print "   $P/simulation/$CELL.spice"
# シミュレーション用（PDK の MOS はサブサーキットなので X 素子で出力）: top を .subckt 化、モデル/制御ブロックは lvs_ignore で除外
( cd $P && xschem -x -q -n -s --tcl 'set top_is_subckt 1; set lvs_ignore 1' \
    --netlist_path $OUT $CELL.sch >/dev/null 2>&1 )

print ">> 1b. DRC: $GDS"
klayout.sh -zz -c $HOME/.klayout/klayoutrc -r $PDK_T/klayout/tech/drc/run.drc \
  -rd input=$GDS -rd report=$OUT/$CELL.drc.lyrdb > $OUT/drc.log 2>&1 || true
ndrc=$(grep -c '<item>' $OUT/$CELL.drc.lyrdb 2>/dev/null || echo "?")
print "   violations: $ndrc  (詳細: KLayout で $OUT/$CELL.drc.lyrdb を開く)"

print ">> 2. LVS（レイアウト抽出 + 回路図と照合）: $GDS"
klayout.sh -zz -c $HOME/.klayout/klayoutrc -r $PDK_T/klayout/tech/lvs/run.lvs \
  -rd input=$GDS -rd circuit=$P/simulation/$CELL.spice \
  -rd extracted=$OUT/$CELL.extracted.spice -rd report=$OUT/$CELL.lvsdb \
  > $OUT/lvs.log 2>&1 || true
grep -E "Netlists (don't )?match|Congratulations|ERROR : |RuntimeError" $OUT/lvs.log | grep -v IP62 | sed 's/^/   /'
[[ -s $OUT/$CELL.extracted.spice ]] || { print "   抽出ネットリストが出力されていません ($OUT/lvs.log)"; exit 1; }

print ">> 3. 同じテストベンチで シミュレーション（DC: vin 0→5V, VDD=5V）"
sim() {  # $1=label $2=netlist file ; subckt 名とピン順は netlist の .subckt 行から取る
  local hdr=$(grep -i -m1 '^\.subckt' $2)
  local words=(${(s: :)hdr}); local name=$words[2] pins=(${words[3,-1]})
  local nodes=() p
  for p in $pins; do case ${p:u} in A) nodes+=in;; Q) nodes+=out;; A\|Q|Q\|A) nodes+=in_out_shorted;; VDD) nodes+=vdd;; VSS|GND) nodes+=0;; *) nodes+=nc_$p;; esac; done
  cat > $OUT/tb_$1.spice <<EOF
* $1 testbench
.include $PDK_T/spice/models/ip62_models
.include $2
VDD vdd 0 5
VIN in 0 0
X1 ${nodes[*]} $name
.dc VIN 0 5 0.01
.measure dc vinv when v(out)=2.5
.measure dc voh find v(out) at=0
.measure dc vol find v(out) at=4.99
.control
run
wrdata $OUT/$1.dat v(out)
.endc
.end
EOF
  ngspice -b $OUT/tb_$1.spice > $OUT/tb_$1.log 2>&1 || true
  printf "   %-10s  Vinv=%-12s VOH=%-12s VOL=%s\n" $1 \
    "$(awk '$1=="vinv"{print $3; exit}' $OUT/tb_$1.log)" "$(awk '$1=="voh"{print $3; exit}' $OUT/tb_$1.log)" "$(awk '$1=="vol"{print $3; exit}' $OUT/tb_$1.log)"
  grep -iE '^error|failed' $OUT/tb_$1.log | head -2 | sed 's/^/     /'
}
sim schematic $OUT/$CELL.spice
# 抽出ネットリストのダイオードの A=/P= は LVS 用の表記（PDK 独自: A=..p は um^2）で ngspice は受け付けない。
# PDK の回路図シミュレーション用フォーマット（DN.sym/DP.sym: "@model m=@m"）も面積を渡さないので、同じ扱いにそろえる
sed -E '/^D/s/ (A|P)=[^ ]+//g' $OUT/$CELL.extracted.spice > $OUT/$CELL.extracted.sim.spice
sim layout    $OUT/$CELL.extracted.sim.spice
print "   波形: $OUT/{schematic,layout}.dat"
