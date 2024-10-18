function [didt, dWmpu, dThetam] = DFIG(Wmb,Wb,Wmpu,pp,Ids,Iqs,Idr,Iqr,Vds,Vqs,Vdr,Vqr,Tmpu)

%% Ecuaciones de la máquina de inducción

Rs  = 0.023;
Rr  = 0.016; 
Lls = 0.18;
Llr = 0.16;
Lm  = 2.9;
Hg  = 0.685;      % Inertia Constant del generador
F   = 0.01;       % Generator mechanical damping *Tb/Wmb;

Ls = Lls+Lm;
Lr = Llr+Lm;

% Marcos de referencia rotor
wr = Wmpu*Wmb*pp/Wb;   % Sistema en pu
wf = Wb/Wb;         % Sistema en pu

L = [Ls 0  Lm 0
     0  Ls 0  Lm
     Lm 0  Lr 0
     0  Lm 0  Lr ];

Fiqs = (Ls*Iqs+Lm*Iqr);
Fids = (Ls*Ids+Lm*Idr);
Fiqr = (Lr*Iqr+Lm*Iqs);
Fidr = (Lr*Idr+Lm*Ids);

Vqdsr = [Vqs-Rs*Iqs-wf*Fids
         Vds-Rs*Ids+wf*Fiqs
         Vqr-Rr*Iqr-(wf-wr)*Fidr
         Vdr-Rr*Idr+(wf-wr)*Fiqr];

didt = Wb*L^-1*Vqdsr; % didt = [dIqs dIds dIqr dIdr]'
% diqs = didt(1); dids = didt(2);
% diqr = didt(3); didr = didt(4);

% Te = 1.5*pp*(Fiqs*Ids-Fids*Iqs); % Unidades físicas
Te = Lm*(Iqr*Ids-Idr*Iqs);         % En pu

dWmpu = (1/(2*Hg))*(Tmpu-Te-F*Wmpu); % por unidad
dThetam = Wmb*Wmpu;



