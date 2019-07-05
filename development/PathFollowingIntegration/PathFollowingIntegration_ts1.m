clear all;clc
bdclose OCTModel
OCTModel

scaleFactor = 1;
duration_s  = 200*sqrt(scaleFactor);
startControl= 20; %duration_s for 0 control signals

%% Set up simulation
VEHICLE = 'modVehicle000';
WINCH = 'winch000';
TETHERS = 'tether000';
GROUNDSTATION = 'groundStation000';
% PLANT = 'modularPlant';
ENVIRONMENT = 'constantUniformFlow';
CONTROLLER = 'pathFollowingController';
VARIANTSUBSYSTEM = 'twoNodeTether';

%% Create busses
createConstantUniformFlowEnvironmentBus
createPlantBus;
createPathFollowingControllerCtrlBus;

%% Set up environment
% Create
env = ENV.env;
env.addFlow({'water'},'FlowDensities',1000);
% Set Values
env.water.velVec.setValue([1 0 0],'m/s');
% Scale up/down
env.scale(scaleFactor);
%% Create Vehicle and Initial conditions
% Create
vhcl = OCT.vehicle;
vhcl.numTethers.setValue(1,'');
vhcl.numTurbines.setValue(2,'');
vhcl.build('partDsgn1_lookupTables.mat');
%IC's
tetherLength = 200;
long = 0;
lat = pi/4;
tanToGr = [-sin(lat)*cos(long) -sin(long) -cos(lat)*cos(long);
           -sin(lat)*sin(long) cos(long)  -cos(lat)*sin(long);
           cos(lat)            0          -sin(lat);];
ini_Rcm = tetherLength*[cos(long).*cos(lat);
         sin(long).*cos(lat);
         sin(lat);];
% path_init=tetherLength * boothSToGroundPos(.68*(2*pi),1,1,.5,0);
constantVelMag=34; %Constant velocity or Constant initial velocity
initVelAng = 90;%degrees
ini_Vcm= constantVelMag*tanToGr*[cosd(initVelAng);sind(initVelAng);0];

ini_pitch=atan2(ini_Vcm(3),sqrt(ini_Vcm(1)^2+ini_Vcm(2)^2));
ini_yaw=atan2(-ini_Vcm(2),-ini_Vcm(1));

[bodyToGr,~]=rotation_sequence([0 ini_pitch ini_yaw]);
bodyY_before_roll=bodyToGr*[0 1 0]';
tanZ=tanToGr*[0 0 1]';
ini_roll=(pi/2)-acos(dot(bodyY_before_roll,tanZ)/(norm(bodyY_before_roll)*norm(tanZ)));

ini_Vcm_body = [-constantVelMag;0;0];
ini_eul=[ini_roll ini_pitch ini_yaw];
vhcl.setICs('InitPos',ini_Rcm,'InitVel',ini_Vcm_body,'InitEulAng',ini_eul);

%% Vehicle Parameters
% Set Values
% vhcl.mass.Value = (8.9360e+04)*(1/4)^3;%0.8*(945.352);
% vhcl.Ixx.Value = 14330000*(1/4)^5;%(6.303e9)*10^-6;
% vhcl.Iyy.Value = 143200*(1/4)^5;%2080666338.077*10^-6;
% vhcl.Izz.Value = 15300000*(1/4)^5;%(8.32e9)*10^-6;
% vhcl.Ixy.Value = 0;
% vhcl.Ixz.Value = 0;%81875397*10^-6;
% vhcl.Iyz.Value = 0;
% vhcl.volume.Value = 111.7*(1/4)^3;%9453552023*10^-6;

vhcl.Ixx.setValue(6303,'kg*m^2');
vhcl.Iyy.setValue(2080.7,'kg*m^2');
vhcl.Izz.setValue(8320.4,'kg*m^2');
vhcl.Ixy.setValue(0,'kg*m^2');
vhcl.Ixz.setValue(0,'kg*m^2');
vhcl.Iyz.setValue(0,'kg*m^2');
vhcl.volume.setValue(0.9454,'m^3');
vhcl.mass.setValue(945.4,'kg'); %old=859.4
vhcl.centOfBuoy.setValue([0 0 0]','m');
vhcl.thrAttch1.posVec.setValue([0 0 0]','m');

vhcl.turbine1.diameter.setValue(0,'m');
vhcl.turbine1.axisUnitVec.setValue([1 0 0]','');
vhcl.turbine1.attachPtVec.setValue([-1.25 -5 0]','m');
vhcl.turbine1.powerCoeff.setValue(0.5,'');
vhcl.turbine1.dragCoeff.setValue(0.8,'');

vhcl.turbine2.diameter.setValue(0,'m');
vhcl.turbine2.axisUnitVec.setValue([1 0 0]','');
vhcl.turbine2.attachPtVec.setValue([-1.25  5 0]','m');
vhcl.turbine2.powerCoeff.setValue(0.5,'');
vhcl.turbine2.dragCoeff.setValue(0.8,'');

% vhcl.aeroSurf1.aeroCentPosVec.Value(1) = -1.25;
% vhcl.aeroSurf2.aeroCentPosVec.Value(1) = -1.25;

% Scale up/down
vhcl.scale(scaleFactor);

%% Ground Station
% Create
gndStn = OCT.station;
gndStn.numTethers.setValue(1,'');
gndStn.build;

% Set values
gndStn.inertia.setValue(1,'kg*m^2');
gndStn.posVec.setValue([0 0 0],'m');
gndStn.dampCoeff.setValue(1,'(N*m)/(rad*s)');
gndStn.initAngPos.setValue(0,'rad');
gndStn.initAngVel.setValue(0,'rad/s');
gndStn.thrAttch1.posVec.setValue([0 0 0],'m');
gndStn.freeSpnEnbl.setValue(false,'');

% Scale up/down
gndStn.scale(scaleFactor);

%% Tethers
% Create
thr = OCT.tethers;
thr.numTethers.setValue(1,'');
thr.build;

% Set parameter values
thr.tether1.numNodes.setValue(2,'');
thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:),'m');
thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)+rotation_sequence(vhcl.initEulAngBdy.Value)*vhcl.thrAttch1.posVec.Value(:),'m');
thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecGnd.Value(:),'m/s');
% thr.tether1.diameter.setValue(0.025,'m');
thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');
thr.tether1.youngsMod.setValue(3.89e9,'Pa');
thr.tether1.dampingRatio.setValue(0.05,'');
thr.tether1.dragCoeff.setValue(0.5,'');
thr.tether1.density.setValue(1300,'kg/m^3');

thr.designTetherDiameter(vhcl,env);

% Scale up/down
thr.scale(scaleFactor);


%% Winches
% Create
wnch = OCT.winches;
wnch.numWinches.setValue(1,'');
wnch.build;
% Set values
wnch.winch1.maxSpeed.setValue(0.4,'m/s');
wnch.winch1.timeConst.setValue(1,'s');
wnch.winch1.maxAccel.setValue(inf,'m/s^2');

wnch = wnch.setTetherInitLength(vhcl,env,thr);

% Scale up/down
wnch.scale(scaleFactor);


%% %%%%%%%%%Controller Params%%%%%%
aBooth=1;bBooth=1;latCurve=.5;

perpErrorVal = 15*pi/180;

%2 deg/s^2 for an error of 1 radian
MOI_X=vhcl.Ixx.Value;
kpRollMom =2*MOI_X;
kdRollMom = 5*MOI_X;
tauRollMom = .01; 

maxBank=20*pi/180;
kpVelAng=maxBank/(pi/2); %max bank divided by large error
kiVelAng=kpVelAng/100;
kdVelAng=kpVelAng;
tauVelAng=.01;

controlAlMat = [1 0 0 ; 0 1 0 ; 0 0 1];
controlSigMax = 5*10^7;

%% Plant Modification Options
%Pick 0 or 1 to turn on:
MMAddBool = 1;
MMOverrideBool = 0;

%Pick 0 or 1 to turn on:
constantVelBool = 0;
constantNormVelBool = 0;

%Only meaningful if using constantNormVel
radialMotionBool = 1;

%% Run the simulation
% try
% disp("running the first time")
% sim('OCTModel')
% catch
% disp("second time")
% sim('OCTModel')
% end

simWithMonitor('OCTModel')
% Run stop callback to plot everything
kiteAxesPlot
% clear h
% animateSim
 %%
% stopCallback


 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Script to help implement the pathFollowingController with the modularized model
% % clear all;clc;
% 
% %% Define Variants an busses
% VEHICLE = 'modVehicle000';
% WINCH = 'winch000';
% TETHERS = 'tether000';
% GROUNDSTATION = 'groundStation000';
% PLANT = 'modularPlant';
% ENVIRONMENT = 'constantUniformFlow';
% CONTROLLER = 'pathFollowingController';
% 
% createPathFollowingControllerCtrlBus;
% %% Initialize Plant Parameters
% %scaling
% scaleFactor = 1;
% duration_s = 500*sqrt(scaleFactor);
% 
% %AeroStruct
% load('partDsgn1_lookupTables.mat')
% 
% aeroStruct(1).aeroCentPosVec(1) = -aeroStruct(1).aeroCentPosVec(1);
% aeroStruct(2).aeroCentPosVec(1) = -aeroStruct(2).aeroCentPosVec(1);
% 
% simParam = simParamClass;
% simParam.tether_param.tether_youngs.Value = simParam.tether_param.tether_youngs.Value/3;
% 
% %%
% tetherLength=200;
