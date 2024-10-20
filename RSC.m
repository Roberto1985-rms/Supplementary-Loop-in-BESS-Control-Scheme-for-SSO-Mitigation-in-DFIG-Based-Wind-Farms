function [dX1,dX2,dXus,dXvdr,dXw,dXvqr,Vqr,Vdr,Sr] = RSC(Wmpu_ref,Vrms_ref,X1,X2,Xus,Xvdr,Xw,Xvqr,Iqs,Iqr,Ids,Idr,Ir,Thetar,Betaf,VdB1,VqB1,Wmpu,Ws,Vdc,Zbase,Vbase,Wb,t)
% Rotor-Side Converter

tctr = 1; % tiempo en donde se activa el RSCC

Lls = 0.18;
Lm  = 2.9;
Llr = 0.16;
Lr = Llr+Lm;
Ls = Lls+Lm;
rsw = 1e-3/Zbase;

% flujos en el marco de referencia s�ncrono
Fqs = (Iqs*Ls+Iqr*Lm);
Fds = (Ids*Ls+Idr*Lm);
Fss = sqrt(Fds^2+Fqs^2);
Phi_P = atan2(Fqs,Fds);
if t < tctr*0.1; Phi_P = 0; end

% Filtro para el flujo
Z = 1;
Wo = 10*2*pi;
G = 1;
dX1 = X2;
dX2 = -2*Z*Wo*X2-Wo^2*X1+Wo^2*Phi_P*G;
Phi = X1;

ThetaPhi = mod(Wb*t+Phi,2*pi);
ThetaPR = ThetaPhi-Thetar;

% plot(t,ThetaPR,'x'); hold on;

if Fss <= 0.01
    Fs = 0.01;
else
    Fs = Fss;
end

% Rotor currents transformation into ThetaPR refernce frame
Tabc2dqR = (2/3)*[ sin(ThetaPR)  sin(ThetaPR-2*pi/3)  sin(ThetaPR+2*pi/3)
                   cos(ThetaPR)  cos(ThetaPR-2*pi/3)  cos(ThetaPR+2*pi/3)
                     1/2            1/2               1/2];

Idq0r_F = Tabc2dqR*Ir;
Idr_F = Idq0r_F(1);
Iqr_F = Idq0r_F(2);
% plot(t,Idr_F,'x'); hold on

% Proportional and integral gains
Kpus = 2;
Kius = 1/0.05;
Kpidr = 0.01;
Kiidr = 1/4;

Kpw = 5.3731;
Kiw =1/1.6667;
Kpiqr = 0.05;
Kiiqr = 1/0.02;

VrmsB1 = sqrt(VdB1^2+VqB1^2);
% VrmsB1 = sqrt(VdB1^2);

Evrms = Vrms_ref-VrmsB1;

if t < tctr*1; Evrms = 0; end
dXus = Kius*Evrms;
Idr_ref = Kpus*Evrms+Xus;

Eidr = Idr_ref-Idr_F;
if t < tctr*1; Eidr = 0; end
dXvdr = Kiidr*Eidr;
Vdrs = Kpidr*Eidr+Xvdr;

if Vdrs > 1.1;
    Vdrc = 1.1;
elseif Vdrs < -1.1;
    Vdrc = -1.1;
else
    Vdrc = Vdrs;
end

Ew = Wmpu_ref-Wmpu;
if t < tctr; Ew = 0; end
dXw = Kiw*Ew;
Iqr_ref_p = Kpw*Ew+Xw;
Iqr_ref = -Iqr_ref_p*Ls/(Lm*Fs);

Eiqr = Iqr_ref-Iqr_F;
if t < tctr; Eiqr = 0; end
dXvqr = Kiiqr*Eiqr;
Vqrs = Kpiqr*Eiqr+Xvqr;

if Vqrs > 1.1;
    Vqrc = 1.1;
elseif Vqrs < -1.1;
    Vqrc = -1.1;
else
    Vqrc = Vqrs;
end

Wslip = Ws-Wmpu;
alpha = 1-(Lm^2/(Ls*Lr));

Vdrctr = Vdrc-Wslip*alpha*Lr*Iqr_F;
Vqrctr = Vqrc+Wslip*(Fs*Lm/Ls+Lr*alpha*Idr_F);

Vdqrb = sqrt(Vdrctr^2+Vqrctr^2); % Esto est� en pu   
thetar = atan2(Vqrctr,Vdrctr);
Vdqrs = Vdqrb*Vbase*2/Vdc;

if Vdqrs > 1.1;
    Vdqr = 1.1;
elseif Vdqrs <= 0;
    Vdqr = 0;
else
    Vdqr = Vdqrs;
end

Vdrpwm = Vdqr*cos(thetar);
Vqrpwm = Vdqr*sin(thetar);

if t < tctr
    Vdrpwm = 0;
    Vqrpwm = 0;
end

Vdqrpwm = [Vdrpwm Vqrpwm 0]';

Tvir = [sin(ThetaPR)        cos(ThetaPR)         1
        sin(ThetaPR-2*pi/3) cos(ThetaPR-2*pi/3)  1
        sin(ThetaPR+2*pi/3) cos(ThetaPR+2*pi/3)  1];

Vabcpwmr = Tvir*Vdqrpwm; 

Vrmoda = Vabcpwmr(1);
Vrmodb = Vabcpwmr(2);
Vrmodc = Vabcpwmr(3);

% trir = sawtooth(2*pi*2000*t+pi*3/2,0.5);
Sra = Vrmoda/2+1/2;% > trir;
Srb = Vrmodb/2+1/2;% > trir;
Src = Vrmodc/2+1/2;% > trir;
Sr = [Sra Srb Src]';

Srx = (1/3)*(Sra+Srb+Src);
Vrvsc = Vdc*[Sra-Srx Srb-Srx Src-Srx]';

Vr = Vrvsc/Vbase-Ir*rsw;    % Voltaje del rotor [pu]

% Rotor
Vrab = Vr(1)-Vr(2);
Vrbc = Vr(2)-Vr(3);
Tvrotor = (1/3)*[2*cos(Betaf) cos(Betaf)+sqrt(3)*sin(Betaf)
                2*sin(Betaf) sin(Betaf)-sqrt(3)*cos(Betaf)];

Vrqd = Tvrotor*[Vrab Vrbc]';
Vqr = Vrqd(1); 
Vdr = Vrqd(2);











