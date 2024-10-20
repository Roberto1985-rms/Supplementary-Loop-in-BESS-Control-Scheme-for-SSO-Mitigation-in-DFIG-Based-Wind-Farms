function dVdcf = dcLink(Vdc_ref,Wb,Zbase,Ig,Ir,Sg,Sr)

% Par�metros de B2B
Cbase = 1/(Wb*Zbase);
Cdcf = 0.01/Cbase;

% Ecuaci�n del capacitor
Igdc = Ig(1)*Sg(1)+Ig(2)*Sg(2)+Ig(3)*Sg(3);
Irdc = Ir(1)*Sr(1)+Ir(2)*Sr(2)+Ir(3)*Sr(3);

dVdcf = Wb*(Igdc-Irdc)/(Cdcf);