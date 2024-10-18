function [dXidg,dXvdg,dXvqg,dIdg,dIqg,Sg] = GSC(t,ThetaB1,Ig,Vbase,Wb,Vdc_ref,Vdc,Xidg,Xvdg,Xvqg,VdB1c,VqB1c,VdB1,VqB1,Ws,Zbase,Thetaf)

%% Grid-Side Converter

% Transformation Matrix
Tabc2dqB1  = (2/3)*[ sin(ThetaB1)  sin(ThetaB1-2*pi/3)  sin(ThetaB1+2*pi/3)
                    cos(ThetaB1)  cos(ThetaB1-2*pi/3)  cos(ThetaB1+2*pi/3)
                        1/2            1/2               1/2];
Tabc2dq  = (2/3)*[ sin(Thetaf)  sin(Thetaf-2*pi/3)  sin(Thetaf+2*pi/3)
                   cos(Thetaf)  cos(Thetaf-2*pi/3)  cos(Thetaf+2*pi/3)
                     1/2            1/2               1/2];

Idqgc = Tabc2dqB1*Ig;
Idgc = Idqgc(1); Iqgc = Idqgc(2);

Kp1 = 8;
Ki1 = 1/2.5e-3;
Kp2 = 0.83;
Ki2 = 1/0.2;

Lg = 0.3;
Rg = 0.003;

Evdc = (Vdc_ref-Vdc)/Vdc_ref;                
dXidg = Ki1*Evdc;
Idg_ref = Kp1*Evdc+Xidg;

Eidg = Idg_ref-Idgc;
dXvdg = Ki2*Eidg;
Vdgs = Kp2*Eidg+Xvdg;

if Vdgs > 1.1;
    Vdg = 1.1;
elseif Vdgs < -1.1;
    Vdg = -1.1;
else
    Vdg = Vdgs;
end

Iqg_ref = 0;
Eiqg = Iqg_ref-Iqgc;
dXvqg = Ki2*Eiqg;
Vqgs = Kp2*Eiqg+Xvqg;

if Vqgs > 1.1;
    Vqg = 1.1;
elseif Vqgs < -1.1;
    Vqg = -1.1;
else
    Vqg = Vqgs;
end

Vdgctr = VdB1c+Ws*Lg*Iqgc-Vdg;
Vqgctr = VqB1c-Ws*Lg*Idgc-Vqg;

Vdqgb = sqrt(Vdgctr^2+Vqgctr^2); % Esto está en pu   
thetag = atan2(Vqgctr,Vdgctr);
Vdqgs = Vdqgb*Vbase*2/Vdc;

if Vdqgs > 1.1;
    Vdqg = 1.1;
elseif Vdqgs <= 0;
    Vdqg = 0;
else
    Vdqg = Vdqgs;
end

if t < 0.0
    mar = 0.1;
    Vdqg = mar*Vbase*2/Vdc;
    thetag = -10*pi/180;
    dXidg = 0;
    dXvdg = 0;
    dXvqg = 0;
end

Vdgpwm = Vdqg*cos(thetag);
Vqgpwm = Vdqg*sin(thetag);
Vdqgpwm = [Vdgpwm Vqgpwm 0]';

Tvi = [sin(ThetaB1)        cos(ThetaB1)        1
       sin(ThetaB1-2*pi/3) cos(ThetaB1-2*pi/3) 1
       sin(ThetaB1+2*pi/3) cos(ThetaB1+2*pi/3) 1
       ];

Vabcgpwm = Tvi*Vdqgpwm; 

Vgmoda = Vabcgpwm(1);
Vgmodb = Vabcgpwm(2);
Vgmodc = Vabcgpwm(3);

Sga = Vgmoda/2+1/2;
Sgb = Vgmodb/2+1/2;
Sgc = Vgmodc/2+1/2;
Sg  = [Sga Sgb Sgc]';

Sgx = (1/3)*(Sga+Sgb+Sgc);
Vgvsc = Vdc*[Sga-Sgx Sgb-Sgx Sgc-Sgx]';

% Inductancia y resistencia serie (Choke)
Rch = Rg;  %5.951e-4; % 9.919e-5; % 
Lch = Lg; %1.579e-4; % 2.631e-5; %
rsw = 1e-3/Zbase;  %Ohms

% Vdvscg = Vdgpwm*Vdc/(2*Vbase); 
% Vqvscg = Vqgpwm*Vdc/(2*Vbase);

Vdqgx = Tabc2dq*Vgvsc/Vbase;
Vdvscg = Vdqgx(1); Vqvscg = Vdqgx(2);

Idqg = Tabc2dq*Ig;
Idg = Idqg(1); Iqg = Idqg(2);

dIdg = Wb*(VdB1+Ws*Lch*Iqg-Vdvscg-Idg*(Rch+rsw))/(Lch);
dIqg = Wb*(VqB1-Ws*Lch*Idg-Vqvscg-Iqg*(Rch+rsw))/(Lch);




