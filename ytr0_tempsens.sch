v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
T {dVbe temperature sensor: DP x1 (TEMP1) vs DP x8 (TEMP8), common cathode (N-well) to VSS} -20 -120 0 0 0.4 0.4 {}
C {TR-1umLIB/DP.sym} 0 0 0 0 {name=D1
model=DP
w=3.6u
l=3.6u
a=12.96p
p=14.4u
m=1
spiceprefix=D}
C {devices/lab_pin.sym} 0 60 0 0 {name=p1a sig_type=std_logic lab=TEMP1}
C {devices/lab_pin.sym} 0 0 0 0 {name=p1c sig_type=std_logic lab=VSS}
C {TR-1umLIB/DP.sym} 120 0 0 0 {name=D2
model=DP
w=3.6u
l=3.6u
a=12.96p
p=14.4u
m=1
spiceprefix=D}
C {devices/lab_pin.sym} 120 60 0 0 {name=p2a sig_type=std_logic lab=TEMP8}
C {devices/lab_pin.sym} 120 0 0 0 {name=p2c sig_type=std_logic lab=VSS}
C {TR-1umLIB/DP.sym} 180 0 0 0 {name=D3
model=DP
w=3.6u
l=3.6u
a=12.96p
p=14.4u
m=1
spiceprefix=D}
C {devices/lab_pin.sym} 180 60 0 0 {name=p3a sig_type=std_logic lab=TEMP8}
C {devices/lab_pin.sym} 180 0 0 0 {name=p3c sig_type=std_logic lab=VSS}
C {TR-1umLIB/DP.sym} 240 0 0 0 {name=D4
model=DP
w=3.6u
l=3.6u
a=12.96p
p=14.4u
m=1
spiceprefix=D}
C {devices/lab_pin.sym} 240 60 0 0 {name=p4a sig_type=std_logic lab=TEMP8}
C {devices/lab_pin.sym} 240 0 0 0 {name=p4c sig_type=std_logic lab=VSS}
C {TR-1umLIB/DP.sym} 300 0 0 0 {name=D5
model=DP
w=3.6u
l=3.6u
a=12.96p
p=14.4u
m=1
spiceprefix=D}
C {devices/lab_pin.sym} 300 60 0 0 {name=p5a sig_type=std_logic lab=TEMP8}
C {devices/lab_pin.sym} 300 0 0 0 {name=p5c sig_type=std_logic lab=VSS}
C {TR-1umLIB/DP.sym} 360 0 0 0 {name=D6
model=DP
w=3.6u
l=3.6u
a=12.96p
p=14.4u
m=1
spiceprefix=D}
C {devices/lab_pin.sym} 360 60 0 0 {name=p6a sig_type=std_logic lab=TEMP8}
C {devices/lab_pin.sym} 360 0 0 0 {name=p6c sig_type=std_logic lab=VSS}
C {TR-1umLIB/DP.sym} 420 0 0 0 {name=D7
model=DP
w=3.6u
l=3.6u
a=12.96p
p=14.4u
m=1
spiceprefix=D}
C {devices/lab_pin.sym} 420 60 0 0 {name=p7a sig_type=std_logic lab=TEMP8}
C {devices/lab_pin.sym} 420 0 0 0 {name=p7c sig_type=std_logic lab=VSS}
C {TR-1umLIB/DP.sym} 480 0 0 0 {name=D8
model=DP
w=3.6u
l=3.6u
a=12.96p
p=14.4u
m=1
spiceprefix=D}
C {devices/lab_pin.sym} 480 60 0 0 {name=p8a sig_type=std_logic lab=TEMP8}
C {devices/lab_pin.sym} 480 0 0 0 {name=p8c sig_type=std_logic lab=VSS}
C {TR-1umLIB/DP.sym} 540 0 0 0 {name=D9
model=DP
w=3.6u
l=3.6u
a=12.96p
p=14.4u
m=1
spiceprefix=D}
C {devices/lab_pin.sym} 540 60 0 0 {name=p9a sig_type=std_logic lab=TEMP8}
C {devices/lab_pin.sym} 540 0 0 0 {name=p9c sig_type=std_logic lab=VSS}
C {devices/iopin.sym} -120 -90 0 0 {name=P_TEMP1 lab=TEMP1}
C {devices/iopin.sym} -120 -60 0 0 {name=P_TEMP8 lab=TEMP8}
C {devices/iopin.sym} -120 -30 0 0 {name=P_VSS lab=VSS}
