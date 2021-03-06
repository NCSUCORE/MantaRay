% clear;clc;close all
simParams = SIM.simParams;
simParams.setDuration(500,'s');
dynamicCalc = '';

%% Load components
% Flight Controller
% loadComponent('pathFollowingCtrlAddedMass');
loadComponent('pathFollowingCtrlForILC');
SPOOLINGCONTROLLER = 'netZeroSpoolingController';
% Ground station controller
loadComponent('oneDoFGSCtrlBasic');
% High level controller
loadComponent('constBoothLem');
% Ground station
loadComponent('pathFollowingGndStn');
% Winches
loadComponent('oneDOFWnch');
% Tether
loadComponent('pathFollowingTether');
% Sensors
loadComponent('idealSensors')
% Sensor processing
loadComponent('idealSensorProcessing')
% Vehicle
loadComponent('fullScale1thr');

% Environment
% loadComponent('CNAPsNoTurbJosh');
% loadComponent('CNAPsTurbJames');
% loadComponent('CNAPsTurbMitchell');
loadComponent('ConstXYZT');

%% Environment IC's and dependant properties
env.water.setflowVec([1.5 0 0],'m/s')

%% Set basis parameters for high level controller
% hiLvlCtrl.initBasisParams.setValue([0.8,1.4,-20*pi/180,0*pi/180,125],'[]') % Lemniscate of Booth
hiLvlCtrl.basisParams.setValue([1,1.4,-.36,0*pi/180,125],'') % Lemniscate of Booth
%% Ground Station IC's and dependant properties
gndStn.setPosVec([0 0 200],'m')
gndStn.initAngPos.setValue(0,'rad');
gndStn.initAngVel.setValue(0,'rad/s');

%% Set vehicle initial conditions
vhcl.setICsOnPath(...
    0,... % Initial path position
    PATHGEOMETRY,... % Name of path function
    hiLvlCtrl.basisParams.Value,... % Geometry parameters
    gndStn.posVec.Value,... % Center point of path sphere
    (11/2)*norm([ 1 0 0 ])) % Initial speed


%% Tethers IC's and dependant properties
thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:)...
    +gndStn.posVec.Value(:),'m');
thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)...
    +rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts_B.posVec.Value,'m');

thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecBdy.Value(:),'m/s');

thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');
%% Winches IC's and dependant properties
% wnch.setTetherInitLength(vhcl,gndStn.posVec.Value,env,thr,env.water.flowVec.Value);
wnch.setTetherInitLength(vhcl,gndStn.posVec.Value,env,thr,[ 1 0 0]);

%% Controller User Def. Parameters and dependant properties
fltCtrl.setFcnName(PATHGEOMETRY,''); % PATHGEOMETRY is defined in fig8ILC_bs.m
% vhcl.addedMass.setValue(zeros(3,3),'kg')
fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,...
    hiLvlCtrl.basisParams.Value,...
    gndStn.posVec.Value);
%% Run Simulation
% vhcl.setFlowGradientDist(.01,'m')
% simWithMonitor('OCTModel')
% tsc = signalcontainer(logsout);
%     vhcl.setMa6x6([125 0    0     0     0     0;...
%                    0   1233 0     -627  0     2585;...
%                    0   0    8922  0     -7359 0;...
%                    0   -627 0     67503 0     -2892;...
%                    9   0    -7359 0     20312 0;...
%                    0   2525 0     -2892 0     14381;],'');
%     vhcl.setMa6x6(diag([5300 4184 9246 24040 11760 35800]),'');
%     vhcl.setMa6x6(diag([126 4072 12154 67350 11733 11760]),'');
    simWithMonitor('OCTModel')
    tsc = signalcontainer(logsout);
    fprintf("Mean central angle = %g deg\n",180/pi*mean(tsc.centralAngle.Data))
% 
% vhcl.setFlowGradientDist(.1,'m')
% simWithMonitor('OCTModel')
% tsc1 = signalcontainer(logsout);
% 
% vhcl.setFlowGradientDist(1,'m')
% simWithMonitor('OCTModel')
% tsc2 = signalcontainer(logsout);

% vhcl.setFlowGradientDist(5,'m')
% simWithMonitor('OCTModel')
% tsc3 = signalcontainer(logsout);

% vhcl6 = vhcl;

% SIXDOFDYNAMICS='sixDoFDynamicsEuler';
% simWithMonitor('OCTModel')
% tsce = signalcontainer(logsout);
% vhcle = vhcl;

% %%
% vhcl.animateSim(tsc,1,'PathFunc',fltCtrl.fcnName.Value,'PlotTracer',true,'FontSize',18)