function [VdB1,VqB1,dVdct,dVqct] = VoltageB1(Vdct,Vqct,Idcol,Iqcol,Ids,Iqs,Idg,Iqg,Idb,Iqb,Zbase,Cb,Wb)

%% Parameters
Rt = 0;%1e3/Zbase;  % en pu
Ct = 1e-3/Cb;
% Rli = 10e-3/Zbase;
%% Voltage bus B1
Idt = Idcol-Ids-Idg-Idb;
Iqt = Iqcol-Iqs-Iqg-Iqb;
dVdct = Wb*(Idt+1*Ct*Vqct)/Ct;
dVqct = Wb*(Iqt-1*Ct*Vdct)/Ct;
VdB1 = Vdct+Rt*Idt;
VqB1 = Vqct+Rt*Iqt;

