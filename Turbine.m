function Twtpu = Turbine(t,yWTM)

%% Wind Power Model

Wwtpu = yWTM(1);
Wmb   = yWTM(2); 
Tb    = yWTM(3);

Vw = 13;            % Velocidad m/s

if t > 300
    Vw = 13;
end

DA = 1.225;         % (kg/m^3) Densidad del aire
Rwt = 37.5;         % (mts) Radio de las aspas de la turbina
C1 = 0.73; C2 = 151; C3 = 0.58; C4 = 0.002; C5 = 2.14; C6 = 13.2; C7 = 18.4;
C8 = -0.02; C9 = -0.003;
Lamda = 8.1; % 8.1
The = 0.05362346*180/pi; % Beta, inclinación de álabe...
Lamdai = ((1/(Lamda+C8*The))-(C9/(The^3+1)))^-1;
Cp = C1*(C2/Lamdai-C3*The-C4*The^C5-C6)*exp(-C7/Lamdai);
Awt = pi*Rwt^2;
Pwt = 0.5*DA*Awt*Cp*Vw^3;
Twt = Pwt/(Wwtpu*Wmb);
Twtpu = Twt/Tb;