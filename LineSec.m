% function dyli = LineSec(t,yli)
function dyli = LineSec(yli,t,Vdso,Vqso,VdB1,VqB1,Cbase,Lbase,Wb)

%% States Variables

Idcol = yli(1);
Iqcol = yli(2);
Vdcs  = yli(3);
Vqcs  = yli(4);

%% Parameters

Lt = 0.005/3;    % en pu, impedancia del transformador
Lnt = 0.006;     % en pu, impedancia del sistema
Ll = 0.4*0.049321323; % en pu, línea más transformador
Xl = Ll*Lbase*Wb;
Xcs = 0.1*Xl;   % porcentaje de compensación

if t > 100
    Xcs = 0.8*Xl;
end

Ltot = Ll+Lt+Lnt;

% Ll = 0.4*0.049321323; % en pu, línea más transformador
% Xcs = 0.7*Llt*Lbase*Wb;
Cs = (1/(Xcs*Wb))/Cbase;

Rtot = 0.02772526; % en pu, línea más transformador

dIdcol = Wb*(Vdso-VdB1-Vdcs-Rtot*Idcol+1*Ltot*Iqcol)/Ltot;
dIqcol = Wb*(Vqso-VqB1-Vqcs-Rtot*Iqcol-1*Ltot*Idcol)/Ltot;

dVdcs = Wb*(Idcol+1*Cs*Vqcs)/Cs;
dVqcs = Wb*(Iqcol-1*Cs*Vdcs)/Cs;

dyli = [
        dIdcol 
        dIqcol
        dVdcs
        dVqcs 
           ];

