function [Tmpu,dWwtpu,dgama] = Shaft(yDTM)

%% Drive train model

Wwtpu = yDTM(1);
Wmb   = yDTM(2);
gama  = yDTM(3); 
Wmpu  = yDTM(4);
Twtpu = yDTM(5);

Ks = 1.11;  % Shaft Stiffness ----> Rigidez del eje
D = 1.5;    % Mutual Damping -----> Amortiguamiento mutuo
Hwt = 4.32; % Inertia Constant ---> Constante de inercia para turbina

Tmpu = Ks*gama+D*Wmb*(Wwtpu-Wmpu);
dWwtpu = (Twtpu-Tmpu)/(2*Hwt);
dgama = Wmb*(Wwtpu-Wmpu);

  