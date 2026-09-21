v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N 350 -650 350 -590 {lab=vout}
N 280 -560 310 -560 {lab=vin}
N 280 -680 280 -560 {lab=vin}
N 280 -680 310 -680 {lab=vin}
N 350 -680 390 -680 {lab=#net1}
N 390 -710 390 -680 {lab=#net1}
N 350 -710 390 -710 {lab=#net1}
N 350 -560 380 -560 {lab=GND}
N 380 -560 380 -530 {lab=GND}
N 350 -530 380 -530 {lab=GND}
N 200 -620 280 -620 {lab=vin}
N 350 -620 440 -620 {lab=vout}
N 350 -750 350 -710 {lab=#net1}
N 350 -530 350 -490 {lab=GND}
N 440 -620 440 -570 {lab=vout}
N 440 -510 440 -490 {lab=GND}
N 350 -850 350 -830 {lab=VDD}
N 350 -770 350 -750 {lab=#net1}
N 90 -530 90 -510 {lab=vin}
N 90 -450 90 -430 {lab=GND}
N 30 -450 30 -430 {lab=GND}
N 30 -530 30 -510 {lab=VDD}
C {devices/title.sym} 160 -30 0 0 {name=l1 author="ytr0"}
C {devices/code.sym} 40 -260 0 0 {name=TR-1um_MODELS
only_toplevel=true
format="tcleval( @value )"
value=".include $::LIB/ip62_models"
spice_ignore=false}
C {TR-1umLIB/MN.sym} 310 -560 0 0 {name=XM1
model=NMOS
w=3.4u
l=1u
m=1
spiceprefix=X
as=0
ad=0
ps=0
pd=0
nrd=0
nrs=0}
C {TR-1umLIB/MP.sym} 310 -680 0 0 {name=XM2
model=PMOS
w=8.2u
l=1u
m=1
spiceprefix=X
as=0
ad=0
ps=0
pd=0
nrd=0
nrs=0}
C {devices/vdd.sym} 350 -850 0 0 {name=l2 lab=VDD}
C {devices/gnd.sym} 350 -490 0 0 {name=l3 lab=GND}
C {devices/lab_pin.sym} 200 -620 0 0 {name=p1 sig_type=std_logic lab=vin
}
C {devices/lab_pin.sym} 440 -620 2 0 {name=p2 sig_type=std_logic lab=vout
}
C {devices/capa.sym} 440 -540 0 0 {name=C1
m=1
value=10f
footprint=1206
device="ceramic capacitor"}
C {devices/gnd.sym} 440 -490 0 0 {name=l4 lab=GND}
C {devices/code_shown.sym} 700 -640 0 0 {name=spice only_toplevel=false value=".option savecurrent
.control
save all

*DC analysis
dc vin 0 5.0 0.01
plot vout vin
plot i(vmeas)
wrdata ~/inverter_tb.txt v(vout)
write inverter_tb.raw
.endc
"}
C {devices/vsource.sym} 90 -480 0 0 {name=vin value=5 savecurrent=false}
C {devices/ammeter.sym} 350 -800 0 0 {name=Vmeas savecurrent=true spice_ignore=0}
C {devices/lab_pin.sym} 90 -530 1 0 {name=p3 sig_type=std_logic lab=vin
}
C {devices/gnd.sym} 90 -430 0 0 {name=l5 lab=GND}
C {devices/vdd.sym} 30 -530 0 0 {name=l6 lab=VDD}
C {devices/vsource.sym} 30 -480 0 0 {name=vin1 value=5 savecurrent=false}
C {devices/gnd.sym} 30 -430 0 0 {name=l7 lab=GND}
C {devices/code_shown.sym} 700 -360 0 0 {name=measure only_toplevel=false value=".measure dc Vinv when v(vout)=2.5"}
