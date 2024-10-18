function [dWi,dgamaB1,Ws,VdB1c,VqB1c] = PLL(ThetaB1,Wi,f,Wb,VB1)

%% PLL bu B1

Kp = 180;
Ki = 3200;
% Kit = 1;

Tv = (2/3)*[sin(ThetaB1) sin(ThetaB1-2*pi/3) sin(ThetaB1+2*pi/3)
            cos(ThetaB1) cos(ThetaB1-2*pi/3) cos(ThetaB1+2*pi/3)
            1/2      1/2             1/2];

VdqB1c = Tv*VB1;
VdB1c = VdqB1c(1);
VqB1c = VdqB1c(2);
dWi = Ki*VqB1c/Wb;
W = Kp*VqB1c+Wi;
Freq = W/(2*pi);
% dThetaB1 = Kit*W;
dgamaB1 = W-Wb;
Ws = Freq/f;
