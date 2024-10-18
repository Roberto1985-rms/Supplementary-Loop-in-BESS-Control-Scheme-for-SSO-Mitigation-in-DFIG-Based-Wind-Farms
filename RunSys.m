% RunSys

% Code to compile the Complete system
clc;

dy = zeros;
% Initial Conditions

x2 = [0 0];
x5 = [0 0 0 0 0];
x10 = [x5 x5];

x01 = [1 0 1 x2 x2 1 x5 0 1 0 x10 x5 0]'; % System

disp('Cantidad de variables de estado sistema 1:');
length(x01)

% opciones del ODE

options=odeset('RelTol',1e-6,'AbsTol',1e-6);

% Sistema de ecuaciones
disp('Time of no linear system computing, System 1:');
tic;[t1,y1]=ode23tb('System',[0,5],x01,options);toc;

% gamam = y1(end,21);
% 
% x012 = y1(end,1:end-2);
% disp('Cantidad de variables de estado sistema 2:');
% length(x012)
% % Sistema 2 de ecuaciones
% disp('Time of no linear system computing, System 2:');
% tic;[t2,y2]=ode23tb('System2',[100,101],x012,options);toc;




