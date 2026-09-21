v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N 350 -650 350 -590 {lab=Q}
N 280 -560 310 -560 {lab=A}
N 280 -680 280 -560 {lab=A}
N 280 -680 310 -680 {lab=A}
N 350 -680 390 -680 {lab=VDD}
N 390 -710 390 -680 {lab=VDD}
N 350 -710 390 -710 {lab=VDD}
N 350 -560 380 -560 {lab=GND}
N 380 -560 380 -530 {lab=GND}
N 350 -530 380 -530 {lab=GND}
N 200 -620 280 -620 {lab=A}
N 350 -620 440 -620 {lab=Q}
N 350 -750 350 -710 {lab=VDD}
N 350 -530 350 -490 {lab=GND}
C {devices/title.sym} 160 -30 0 0 {name=l1 author="ytr0"}
C {devices/code.sym} 40 -260 0 0 {name=TR-1um_MODELS
lvs_ignore=open
only_toplevel=true
format="tcleval( @value )"
value=".include $::LIB/ip62_models"
spice_ignore=false}
C {devices/code_shown.sym} 240 -260 0 0 {name=SIM
lvs_ignore=open
only_toplevel=true
value="
.control
save all
tran 1n 1u
write main.raw
.endc
"}
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
C {devices/ipin.sym} 200 -620 0 0 {name=p1 lab=A}
C {devices/opin.sym} 440 -620 0 0 {name=p2 lab=Q}
C {devices/iopin.sym} 350 -750 0 0 {name=p3 lab=VDD}
C {devices/iopin.sym} 350 -490 0 0 {name=p4 lab=VSS}
