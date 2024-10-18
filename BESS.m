function dyb = BESS(Ew,t,yb,VdB1,VqB1,VdB1c,VqB1c,Ws,Thetaf,ThetaB1,Zbase,Vbase,Cbase,Wb,Pgs,Pbes,Qgs,Qbes)

%% Estados

Xep     = yb(1); 
Xid     = yb(2);
% ePb     = y(3);
% Xevb    = yb(3);
Xiq     = yb(3);
Idb     = yb(4);
Iqb     = yb(5);
% Uboc    = yb(7);
% Ub1     = yb(7);
% Ubdc    = yb(8);

%% Transformation

Tabc2dq  = (2/3)*[ sin(Thetaf)  sin(Thetaf-2*pi/3)  sin(Thetaf+2*pi/3)
                   cos(Thetaf)  cos(Thetaf-2*pi/3)  cos(Thetaf+2*pi/3)
                     1/2            1/2               1/2];

Tdq2abc = [sin(Thetaf)        cos(Thetaf)        1
            sin(Thetaf-2*pi/3) cos(Thetaf-2*pi/3) 1 
            sin(Thetaf+2*pi/3) cos(Thetaf+2*pi/3) 1];

Tabc2dqB1  = (2/3)*[ sin(ThetaB1)  sin(ThetaB1-2*pi/3)  sin(ThetaB1+2*pi/3)
                     cos(ThetaB1)  cos(ThetaB1-2*pi/3)  cos(ThetaB1+2*pi/3)
                        1/2            1/2               1/2];
Idqb = [Idb Iqb 0]';
Ib = Tdq2abc*Idqb;
Idqbc = Tabc2dqB1*Ib;
Idbc = Idqbc(1); Iqbc = Idqbc(2);

%% Párametros
% Valores del filtro
Lb = 0.3; % en pu
Rb = 0.003; % en pu
Rsw = 1e-3/Zbase; % En pu
% Cbp = 367.4/Cbase;
% Rbp = 10e3/Zbase;
% Rbs = 0.013/Cbase;
% Cb1 = 0.01/Cbase;
% Rb1 = 0.001/Zbase;
% Rbt = 0.00162/Zbase;
% Cbdc = 0.01/Cbase;

%% BESS Control

% Ganancias lazo d
Kpf = 0.1595;
Kif = 1/0.25;%1/2.5e-3;

Kpid = 3;%;
Kiid = 80;%0.05786;

% Ganancias lazo q
Kpv =  0.1595;%8;
Kiv =  1/0.25;%1/2.5e-3; %
 
Kpiq = 3;
Kiiq = 80;

% Referencias

Umax = 2200;
Umin = 1100;
f_ref = 1;
P_ref = -1;
Q_ref = 0;
Ubdc_ref = 1200;
Ubdc = 1200;

tbess = 10; %tiempo en que inicia Bess

% coordenada d

Pw = Ew/0.05;
eP = P_ref-Pgs-Pbes;

if t<tbess
    eP = 0;
end

dXep = Kif*eP;
Id_ref = Kpf*eP+Xep;

if t<tbess
    Id_ref = 0;
end

Eid = Id_ref-Idb;
dXid = Kiid*Eid;

Vd_ = Eid*Kpid+Xid;

if Vd_ > 1.1;
    Vdbs = 1.1;
elseif Vd_ < -1.1;
    Vdbs = -1.1;
else
    Vdbs= Vd_;
end

% Coordenada q

Iq_ref = 0.00;

Eiq = Iq_ref-Iqb;
dXiq = Eiq*Kiiq;

Vq_ = Eiq*Kpiq+Xiq;

% if t<tbess
%     dXevb = 0;
%     dXiq = 0;
%     Vq_ = 0;
% end

if Vq_ > 1.1;
    Vqbs = 1.1;
elseif Vq_ < -1.1;
    Vqbs = -1.1;
else
    Vqbs = Vq_;
end

Vdbctr = VdB1+1*Lb*Iqb-Vdbs;
Vqbctr = VqB1-1*Lb*Idb-Vqbs;

Vdq = sqrt(Vdbctr^2+Vqbctr^2); % Esto está en pu   
thetabs = atan2(Vqbctr,Vdbctr);
Vdqbss = Vdq*2*Vbase/Ubdc;

if Vdqbss > 1.1;
    Vdqbs = 1.1;
elseif Vdqbss <= 0;
    Vdqbs = 0;
else
    Vdqbs = Vdqbss;
end

% if t < 150
%     Vdqbs = 0;
%     thetabs = 0;
%     dXep  = 0;
%     dXid  = 0;
%     dXevb = 0;
%     dXiq  = 0;
% end

Vdbpwm = Vdqbs*cos(thetabs);
Vqbpwm = Vdqbs*sin(thetabs);
Vdqbpwm = [Vdbpwm Vqbpwm 0]';

Tvi = [sin(Thetaf)        cos(Thetaf)        1
       sin(Thetaf-2*pi/3) cos(Thetaf-2*pi/3) 1
       sin(Thetaf+2*pi/3) cos(Thetaf+2*pi/3) 1
       ];

Vabcbpwm = Tvi*Vdqbpwm; 

Vbmoda = Vabcbpwm(1);
Vbmodb = Vabcbpwm(2);
Vbmodc = Vabcbpwm(3);

Sba = Vbmoda/2+1/2;
Sbb = Vbmodb/2+1/2;
Sbc = Vbmodc/2+1/2;
% Sb  = [Sba Sbb Sbc]';

Sbx = (1/3)*(Sba+Sbb+Sbc);
Vbvsc = Ubdc*[Sba-Sbx Sbb-Sbx Sbc-Sbx]';

Vdqb = Tabc2dq*Vbvsc/Vbase;
Vdbvsc = Vdqb(1); Vqbvsc = Vdqb(2);

% Ibdc = Sba*Ib(1)+Sbb*Ib(2)+Sbc*Ib(3);
% Ibes = (Ubdc/Ubdc_ref-Ub1-Uboc)/(Rbt+Rbs);

%% Battery equations

% dUb1  = Wb*(Ibes-Ub1/Rb1)/Cb1;
% dUbdc = Wb*(Ibdc-Ibes)/Cbdc;

%% Filter Chuck equations for the BESS
We = 1;
dIdb = Wb*(VdB1+We*Lb*Iqb-(Rb+Rsw)*Idb-Vdbvsc)/Lb;
dIqb = Wb*(VqB1-We*Lb*Idb-(Rb+Rsw)*Iqb-Vqbvsc)/Lb;

dyb = [
      dXep 
      dXid  
%       dePb
%       dXevb    
      dXiq     
      dIdb    
      dIqb
%       dUb1
%       dUbdc
      ];










