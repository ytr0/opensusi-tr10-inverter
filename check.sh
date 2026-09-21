#!/bin/zsh
# 全バリアントを検証: レイアウト生成 -> DRC -> LVS（回路図は xschem から生成）
#   usage: ./check.sh [inverter_only|full]   (省略時は両方)
set -e
P=${0:A:h}
PDK_T=$PDK_ROOT/$PDK/libs.tech
if (( $# )); then variants=($@); else variants=(inverter_only full); fi

for v in $variants; do
  D=$P/variants/$v
  mkdir -p $D/simulation
  print "=== $v"

  print ">> layout"
  klayout.sh -zz -c $HOME/.klayout/klayoutrc -rd variant=$v -rd out=$D/ytr0_top.gds \
    -r $P/layout/gen_layout.py 2>&1 | grep -E '^WROTE' | sed 's/^/   /'

  print ">> schematic -> LVS netlist"
  ( cd $D && xschem -x -q -n -s --tcl 'set lvs_netlist 1; set lvs_ignore 1' \
      --netlist_path $D/simulation ytr0_top.sch >/dev/null 2>&1 )
  print "   $(grep -c '^[MDX]' $D/simulation/ytr0_top.spice) devices/instances"

  print ">> DRC"
  klayout.sh -zz -c $HOME/.klayout/klayoutrc -r $PDK_T/klayout/tech/drc/run.drc \
    -rd input=$D/ytr0_top.gds -rd report=$D/drc.lyrdb > $D/drc.log 2>&1 || true
  print "   violations: $(grep -c '<item>' $D/drc.lyrdb || print '?')"

  print ">> LVS"
  klayout.sh -zz -c $HOME/.klayout/klayoutrc -r $PDK_T/klayout/tech/lvs/run.lvs \
    -rd input=$D/ytr0_top.gds -rd report=$D/lvs.lvsdb > $D/lvs.log 2>&1 || true
  grep -E "Congratulations|Netlists don't match|ERROR : " $D/lvs.log | grep -v IP62 | sed 's/^/   /'
done
