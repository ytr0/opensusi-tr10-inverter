v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
T {1-bit SRAM: cross-coupled inverters + transmission gate (WORD is inverted on chip)} -60 -300 0 0 0.4 0.4 {}
C {TR-1umLIB/MP.sym} 0 -140 0 0 {name=MP1
model=PMOS
w=8.2u
l=1u
m=1
spiceprefix=X
nrd=0
nrs=0}
C {devices/lab_pin.sym} 40 -110 0 0 {name=p_MP1_D sig_type=std_logic lab=QB}
C {devices/lab_pin.sym} 0 -140 0 0 {name=p_MP1_G sig_type=std_logic lab=Q}
C {devices/lab_pin.sym} 40 -170 0 0 {name=p_MP1_S sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} 40 -140 0 0 {name=p_MP1_BG sig_type=std_logic lab=VDD}
C {TR-1umLIB/MN.sym} 0 0 0 0 {name=MN1
model=NMOS
w=3.4u
l=1u
m=1
spiceprefix=X
nrd=0
nrs=0}
C {devices/lab_pin.sym} 40 -30 0 0 {name=p_MN1_D sig_type=std_logic lab=QB}
C {devices/lab_pin.sym} 0 0 0 0 {name=p_MN1_G sig_type=std_logic lab=Q}
C {devices/lab_pin.sym} 40 30 0 0 {name=p_MN1_S sig_type=std_logic lab=VSS}
C {devices/lab_pin.sym} 40 0 0 0 {name=p_MN1_BG sig_type=std_logic lab=VSS}
C {TR-1umLIB/MP.sym} 200 -140 0 0 {name=MP2
model=PMOS
w=8.2u
l=1u
m=1
spiceprefix=X
nrd=0
nrs=0}
C {devices/lab_pin.sym} 240 -110 0 0 {name=p_MP2_D sig_type=std_logic lab=Q}
C {devices/lab_pin.sym} 200 -140 0 0 {name=p_MP2_G sig_type=std_logic lab=QB}
C {devices/lab_pin.sym} 240 -170 0 0 {name=p_MP2_S sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} 240 -140 0 0 {name=p_MP2_BG sig_type=std_logic lab=VDD}
C {TR-1umLIB/MN.sym} 200 0 0 0 {name=MN2
model=NMOS
w=3.4u
l=1u
m=1
spiceprefix=X
nrd=0
nrs=0}
C {devices/lab_pin.sym} 240 -30 0 0 {name=p_MN2_D sig_type=std_logic lab=Q}
C {devices/lab_pin.sym} 200 0 0 0 {name=p_MN2_G sig_type=std_logic lab=QB}
C {devices/lab_pin.sym} 240 30 0 0 {name=p_MN2_S sig_type=std_logic lab=VSS}
C {devices/lab_pin.sym} 240 0 0 0 {name=p_MN2_BG sig_type=std_logic lab=VSS}
C {TR-1umLIB/MP.sym} 400 -140 0 0 {name=MP3
model=PMOS
w=8.2u
l=1u
m=1
spiceprefix=X
nrd=0
nrs=0}
C {devices/lab_pin.sym} 440 -110 0 0 {name=p_MP3_D sig_type=std_logic lab=WORDB}
C {devices/lab_pin.sym} 400 -140 0 0 {name=p_MP3_G sig_type=std_logic lab=WORD}
C {devices/lab_pin.sym} 440 -170 0 0 {name=p_MP3_S sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} 440 -140 0 0 {name=p_MP3_BG sig_type=std_logic lab=VDD}
C {TR-1umLIB/MN.sym} 400 0 0 0 {name=MN3
model=NMOS
w=3.4u
l=1u
m=1
spiceprefix=X
nrd=0
nrs=0}
C {devices/lab_pin.sym} 440 -30 0 0 {name=p_MN3_D sig_type=std_logic lab=WORDB}
C {devices/lab_pin.sym} 400 0 0 0 {name=p_MN3_G sig_type=std_logic lab=WORD}
C {devices/lab_pin.sym} 440 30 0 0 {name=p_MN3_S sig_type=std_logic lab=VSS}
C {devices/lab_pin.sym} 440 0 0 0 {name=p_MN3_BG sig_type=std_logic lab=VSS}
C {TR-1umLIB/MP.sym} 600 -140 0 0 {name=MP4
model=PMOS
w=8.2u
l=1u
m=1
spiceprefix=X
nrd=0
nrs=0}
C {devices/lab_pin.sym} 640 -110 0 0 {name=p_MP4_D sig_type=std_logic lab=DATA}
C {devices/lab_pin.sym} 600 -140 0 0 {name=p_MP4_G sig_type=std_logic lab=WORDB}
C {devices/lab_pin.sym} 640 -170 0 0 {name=p_MP4_S sig_type=std_logic lab=Q}
C {devices/lab_pin.sym} 640 -140 0 0 {name=p_MP4_BG sig_type=std_logic lab=VDD}
C {TR-1umLIB/MN.sym} 600 0 0 0 {name=MN4
model=NMOS
w=3.4u
l=1u
m=1
spiceprefix=X
nrd=0
nrs=0}
C {devices/lab_pin.sym} 640 -30 0 0 {name=p_MN4_D sig_type=std_logic lab=DATA}
C {devices/lab_pin.sym} 600 0 0 0 {name=p_MN4_G sig_type=std_logic lab=WORD}
C {devices/lab_pin.sym} 640 30 0 0 {name=p_MN4_S sig_type=std_logic lab=Q}
C {devices/lab_pin.sym} 640 0 0 0 {name=p_MN4_BG sig_type=std_logic lab=VSS}
C {devices/iopin.sym} -220 -360 0 0 {name=P_DATA lab=DATA}
C {devices/iopin.sym} -220 -330 0 0 {name=P_WORD lab=WORD}
C {devices/iopin.sym} -220 -300 0 0 {name=P_VDD lab=VDD}
C {devices/iopin.sym} -220 -270 0 0 {name=P_VSS lab=VSS}
