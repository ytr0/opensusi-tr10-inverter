v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
T {ytr0_top (full: inverter + 1-bit SRAM)} -300 -220 0 0 0.4 0.4 {}
C {../../ytr0_inverter.sym} 0 0 0 0 {name=X1}
C {devices/lab_pin.sym} -150 -20 0 0 {name=piA sig_type=std_logic lab=A}
C {devices/lab_pin.sym} 150 -20 0 0 {name=piVDD sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} 150 0 0 0 {name=piQ sig_type=std_logic lab=Q}
C {devices/lab_pin.sym} 150 20 0 0 {name=piVSS sig_type=std_logic lab=VSS}
C {../../ytr0_sram.sym} 0 200 0 0 {name=X2}
C {devices/lab_pin.sym} 150 170 0 0 {name=psDATA sig_type=std_logic lab=DATA}
C {devices/lab_pin.sym} 150 190 0 0 {name=psWORD sig_type=std_logic lab=WORD}
C {devices/lab_pin.sym} 150 210 0 0 {name=psVDD sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} 150 230 0 0 {name=psVSS sig_type=std_logic lab=VSS}
C {devices/iopin.sym} -300 -340 0 0 {name=P_A lab=A}
C {devices/iopin.sym} -300 -310 0 0 {name=P_Q lab=Q}
C {devices/iopin.sym} -300 -280 0 0 {name=P_VDD lab=VDD}
C {devices/iopin.sym} -300 -250 0 0 {name=P_VSS lab=VSS}
C {devices/iopin.sym} -300 -220 0 0 {name=P_DATA lab=DATA}
C {devices/iopin.sym} -300 -190 0 0 {name=P_WORD lab=WORD}
