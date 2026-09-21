#!/bin/zsh
# 発注担当に渡す zip を作る: deliver/ytr0_top_<variant>.zip
#   usage: ./deliver.sh [inverter_only|full]   (省略時は inverter_only と full)
# 中身: GDS / LVS用ネットリスト / 回路図 / DRC・LVS の結果 / MANIFEST / PINLIST
set -e
P=${0:A:h}
if (( $# )); then variants=($@); else variants=(inverter_only full); fi
OUT=$P/deliver
mkdir -p $OUT

for v in $variants; do
  D=$P/variants/$v
  [[ -f $D/ytr0_top.gds ]] || { print "$v: ytr0_top.gds がありません。先に ./check.sh を実行してください"; exit 1; }
  [[ -f $D/simulation/ytr0_top.spice ]] || { print "$v: ネットリストがありません。先に ./check.sh を実行してください"; exit 1; }

  ndrc=$( { grep -c '<item>' $D/drc.lyrdb || true; } 2>/dev/null | head -1 )
  lvs=$(grep -hoE "Congratulations! Netlists match|Netlists don't match" $D/lvs.log 2>/dev/null | head -1)
  [[ $ndrc == 0 && $lvs == "Congratulations! Netlists match" ]] || {
      print "$v: DRC=$ndrc / LVS=$lvs のため中断しました（./check.sh をやり直してください）"; exit 1; }

  S=$OUT/ytr0_top_$v
  rm -rf $S; mkdir -p $S
  cp $D/ytr0_top.gds $D/ytr0_top.sch $S/
  cp $D/simulation/ytr0_top.spice $S/
  cp $D/drc.lyrdb $D/lvs.lvsdb $S/ 2>/dev/null || true
  cp $P/PINLIST.md $S/

  {
    print "ytr0_top ($v)"
    print "作成日: $(date '+%Y-%m-%d %H:%M')"
    print "PDK: OpenSUSI TR-1um v1.2609.0"
    print "トップセル: ytr0_top"
    print "DRC: 違反 $ndrc 件"
    print "LVS: $lvs"
    print ""
    print "md5:"
    (cd $S && md5 -r *.gds *.spice *.sch 2>/dev/null)
  } > $S/MANIFEST.txt

  (cd $OUT && rm -f ytr0_top_$v.zip && zip -qr ytr0_top_$v.zip ytr0_top_$v)
  print "$OUT/ytr0_top_$v.zip  ($(du -h $OUT/ytr0_top_$v.zip | cut -f1))  DRC=$ndrc  LVS=OK"
done
