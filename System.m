function dy = System(t,y)
% function dy = System(y)
% t=100;
%% Valores base

% Parámetros
f = 60;
nP = 6;
pp = nP/2;
Wb = 2*pi*f;
Wmb = Wb/pp; 
Pb = (5/6)*2e6;
Tb = Pb/Wmb;

% Valores base
Vbase = 575*sqrt(2/3);
Ibase = (Pb*sqrt(2)/(575*sqrt(3)));
Zbase = Vbase/Ibase;

Lbase = Zbase/Wb;
Cbase = 1/(Wb*Zbase);

% Vbase2 = 25e3*sqrt(2/3);
% Ibase2 = (Pb*sqrt(2)/(25e3*sqrt(3)));

%% Referencias

Vdc_ref = 1150;
Vrms_ref = 1.0;

% if t < 100
%     Wmpu_ref = 0.95;
% elseif t>100 && t<150
    Wmpu_ref = 1.02;
% else
%     Wmpu_ref = 0.85;
% end

%% States Variables

Wmpu    = y(1);
gama    = y(2);
Wwtpu   = y(3);
Iqs     = y(4);
Ids     = y(5);
Iqr     = y(6);
Idr     = y(7);
Wi      = y(8)*Wb;
gamaB1  = y(9);
Xidg    = y(10);
Xvdg    = y(11);
Xvqg    = y(12);
Idg     = y(13);
Iqg     = y(14);
Vdcf    = y(15)*Vdc_ref;
X1      = y(16);
X2      = y(17);
Xus     = y(18);
Xvdr    = y(19);
Xw      = y(20);
Xvqr    = y(21);
Vdct    = y(22);
Vqct    = y(23);
Idcol   = y(24);
Iqcol   = y(25);
Vdcs    = y(26);
Vqcs    = y(27);
Xep     = y(28); 
Xid     = y(29);
% Xevb    = y(30);
Xiq     = y(30);
Idb     = y(31);
Iqb     = y(32);

%% Marco de referncia (syncrono)
Kiw =1/1.6667;
Wau = -Xw/Kiw;
% dWau = (Wmpu-Wmpu_ref);
Thetar = Wb*(Wmpu_ref*t+Wau);

Thetaf = Wb*t;
Betaf = Thetaf-Thetar;
ThetaB1 = mod(Wb*t+gamaB1,2*pi);

%% avoid zero-crosing

if Vdcf < 0.001
    Vdc = 0.001;
else
    Vdc = Vdcf;
end

%% Transformations matrices abc2dq and dq2abc (síncronas)

Tdq02abc = [sin(Thetaf)        cos(Thetaf)        1
            sin(Thetaf-2*pi/3) cos(Thetaf-2*pi/3) 1 
            sin(Thetaf+2*pi/3) cos(Thetaf+2*pi/3) 1];

Tabc2dq  = (2/3)*[ sin(Thetaf)  sin(Thetaf-2*pi/3)  sin(Thetaf+2*pi/3)
                   cos(Thetaf)  cos(Thetaf-2*pi/3)  cos(Thetaf+2*pi/3)
                     1/2            1/2               1/2];

Tdq02abcR = [sin(Betaf)        cos(Betaf)        1
            sin(Betaf-2*pi/3) cos(Betaf-2*pi/3) 1 
            sin(Betaf+2*pi/3) cos(Betaf+2*pi/3) 1];

%% States dq0 to abc

Idqg   = [Idg Iqg 0]';
Idqr   = [Idr Iqr 0]';
% Idql    = [Idl Iql 0]';
% Idqbs   = [Idb Iqb 0]';
% 
Ig    = Tdq02abc*Idqg;
Ir    = Tdq02abcR*Idqr;
% Icol  = Tdq02abc*Idql;
% Ibs   = Tdq02abc*Idqbs;

%% Source

vp = 575*sqrt(2/3);
Vpa = vp*sin(Wb*t);
Vpb = vp*sin(Wb*t-2*pi/3);
Vpc = vp*sin(Wb*t+2*pi/3);
Vso = [Vpa Vpb Vpc]'/Vbase;

Vdqso = Tabc2dq*Vso;
Vdso = Vdqso(1); Vqso = Vdqso(2);

%% Voltage bus B1

[VdB1,VqB1,dVdct,dVqct] = VoltageB1(Vdct,Vqct,Idcol,Iqcol,Ids,Iqs,Idg,Iqg,Idb,Iqb,Zbase,Cbase,Wb);
VdqB1 = [VdB1 VqB1 0]';
VB1 = Tdq02abc*VdqB1;

%% Cálculo de potencias

Pgs = VdB1*(Ids+Idg)+VqB1*(Iqs+Iqg);
Qgs = VqB1*(Ids+Idg)-VdB1*(Iqs+Iqg);
Pbes = VdB1*Idb+VqB1*Iqb;
Qbes = VqB1*Idb-VdB1*Iqb;
%% Line

yli = [Idcol,Iqcol,Vdcs,Vqcs]';
dyli = LineSec(yli,t,Vdso,Vqso,VdB1,VqB1,Cbase,Lbase,Wb);

%% Wind and Turbine Model

yWTM = [Wwtpu, Wmb, Tb]';
Twtpu = Turbine(t,yWTM);

%% Drive Train Model

yDTM = [Wwtpu, Wmb, gama, Wmpu, Twtpu]';
[Tmpu,dWwtpu,dgama] = Shaft(yDTM);

%% PLL Model

[dWi,dgamaB1,Ws,VdB1c,VqB1c] = PLL(ThetaB1,Wi,f,Wb,VB1);

%% BESS model

Ew = Wmpu_ref-Wmpu;
% % yb = [Xep Xid Xevb Xiq Idb Iqb]';
yb = [Xep Xid Xiq Idb Iqb]';
dyb = BESS(Ew,t,yb,VdB1,VqB1,VdB1c,VqB1c,Ws,Thetaf,ThetaB1,Zbase,Vbase,Cbase,Wb,Pgs,Pbes,Qgs,Qbes);

%% Grid-Side Converter and Control

[dXidg,dXvdg,dXvqg,dIdg,dIqg,Sg] = GSC(t,ThetaB1,Ig,Vbase,Wb,Vdc_ref,Vdc,Xidg,Xvdg,Xvqg,VdB1c,VqB1c,VdB1,VqB1,Ws,Zbase,Thetaf);

%% Rotor-Side Converter and Control

[dX1,dX2,dXus,dXvdr,dXw,dXvqr,Vqr,Vdr,Sr] = RSC(Wmpu_ref,Vrms_ref,X1,X2,Xus,Xvdr,Xw,Xvqr,Iqs,Iqr,Ids,Idr,Ir,Thetar,Betaf,VdB1,VqB1,Wmpu,Ws,Vdc,Zbase,Vbase,Wb,t);

%% Dc-Link Back to Back Converter

dVdcf = dcLink(Vdc_ref,Wb,Zbase,Ig,Ir,Sg,Sr);

%% DFIG Model (marco de referencia sincrono)

[didt, dWmpu, dThetam] = DFIG(Wmb,Wb,Wmpu,pp,Ids,Iqs,Idr,Iqr,VdB1,VqB1,Vdr,Vqr,Tmpu);

%% Differencial equations 

dy = [
      dWmpu
      dgama
      dWwtpu
      didt
      dWi
      dgamaB1
      dXidg
      dXvdg
      dXvqg
      dIdg
      dIqg
      dVdcf
      dX1
      dX2
      dXus
      dXvdr
      dXw
      dXvqr
      dVdct
      dVqct
      dyli
      dyb
      ];









