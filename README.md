Repository for the paper "Supplementary Loop in BESS Control Scheme for SSO Mitigation in DFIG-Based Wind Farms"
The Authors:
R. Moreno-Sanchez, N. Visairo-Cruz, C. A. Núñez-Gutiérrez, J. Cesar Hernández-Ramirez, and J. Segundo-Ramírez
In this repository, you will find the files needed to simulate the wind system, as shown in Figure 1 of the paper. These files are in ".m" and ".txt" format, you just have to compile the main file named “RunSys” and you will be able to plot any state variable you need. It is necessary to have knowledge of MatLab ODES solution. These files correspond to the dynamic models of the complete system which includes the following:
* BESS.m: in this file the model of the BESS is included.
* DFIG.m: in this file the model of the doubly fed induction machine is modeled.
* GSC.m: in this file, the grid side converter and its controls of the back-to-back converter of the type 3 wind farm is modeled.
* LineSec.m: the transmission line and the transformer are modeled and included.
* PLL.m: the phase-locked loop is modeled in this file.
* RSC.m: in this file, the rotor side converter and its controls of the back-to-back converter of the type 3 wind farm is modeled.
* RunSys.m: the main instruction is included in this file, you should run this first.
* Shaft.m: in this file, the two mass model is included.
* System.m in this file, the integration of all dynamic equations are performed in this file.
* Turbine.m: the turbine model of 4 blades is considered in this file.
* VoltageB1.m: the dynamic equation of the bus B1 is managed in this file.
* dcLink.m: the DC link of the back-to-back converter of the type 3 wind farm is managed in this file.
