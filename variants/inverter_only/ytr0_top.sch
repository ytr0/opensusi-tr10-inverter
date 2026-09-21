v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
T {ytr0_top (inverter_only)} -300 -200 0 0 0.4 0.4 {}
C {../../ytr0_inverter.sym} 0 0 0 0 {name=X1}
C {devices/lab_pin.sym} -150 -20 0 0 {name=pa sig_type=std_logic lab=A}
C {devices/lab_pin.sym} 150 -20 0 0 {name=pvdd sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} 150 0 0 0 {name=pq sig_type=std_logic lab=Q}
C {devices/lab_pin.sym} 150 20 0 0 {name=pvss sig_type=std_logic lab=VSS}
C {devices/iopin.sym} -300 -300 0 0 {name=P_A lab=A}
C {devices/iopin.sym} -300 -270 0 0 {name=P_Q lab=Q}
C {devices/iopin.sym} -300 -240 0 0 {name=P_VDD lab=VDD}
C {devices/iopin.sym} -300 -210 0 0 {name=P_VSS lab=VSS}
