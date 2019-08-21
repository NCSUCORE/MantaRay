clc;clear
if ~slreportgen.utils.isModelLoaded('OCTModel')
    OCTModel
end

lengthScaleFactor = 1/1;
densityScaleFactor = 1/1;
duration_s  = 300*sqrt(lengthScaleFactor);
dynamicCalc = '';
SPOOLINGCONTROLLER = 'nonTrad';
PATHGEOMETRY = 'lemOfBooth';
% ZERO FOR MITCHELLS CONTROL ALLOCATION, ONE OLD CONTROL ALLOCATION MATRIX
controlAllocationBit = 0;

%% PLOT BITS
DAMPlot = false; % desired and achieved moments
CSDPlot = false; % control surface deflections
YMCTPlot = false; % yaw moment controller things
TRTPlot = false; % tangent roll things
%% Load components
% Flight Controller
loadComponent('firstBuildPathFollowing');
% Ground station controller
loadComponent('oneDoFGSCtrlBasic');
% High Level Con
loadComponent('constBoothLem')
% Ground station
loadComponent('pathFollowingGndStn');
% Winches 
loadComponent('oneDOFWnch');
% Tether
loadComponent('pathFollowingTether');
% Vehicle
loadComponent('pathFollowingVhcl');
% Environment
loadComponent('pathFollowingEnv');
%% Choose Path Shape and Set basis parameters for high level controller
fltCtrl.setFcnName('lemOfBooth','');
% fltCtrl.setFcnName('circleOnSphere','');
% fltCtrl.setFcnName('lemOfGerono','');

% hiLvlCtrl.basisParams.setValue([60 10 0 30 150],'') % Lemniscate of Gerono
  hiLvlCtrl.basisParams.setValue([.73,1.4,.36,0,125],'');% Lemniscate of Booth
% hiLvlCtrl.basisParams.setValue([.73,1,.36,0,50],'');% Lemniscate of Booth
% hiLvlCtrl.basisParams.setValue([pi/8,-3*pi/8,0,125],''); % Circle
%% Set vehicle initial conditions
vhcl.setICsOnPath(...
    .4,... % Initial path position
    fltCtrl.fcnName.Value,... % Name of path function
    hiLvlCtrl.basisParams.Value,... % Geometry parameters
    6) % Initial speed
vhcl.setAddedMISwitch(false,'');
%% Environment IC's and dependant properties
% Set Values
flowspeed = 1.5; %m/s options are .1, .5, 1, 1.5, and 2 ************************************************************************************************************Right Here*************************************************88
env.water.velVec.setValue([flowspeed 0 0],'m/s');
%% Ground Station IC's and dependant properties
gndStn.initAngPos.setValue(0,'rad');
gndStn.initAngVel.setValue(0,'rad/s');
%gndStn.thrAttch1.velVec.setValue([0 0 0]','m/s');
%% Tethers IC's and dependant properties
thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:),'m');
thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)+rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts.posVec.Value,'m');
thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecBdy.Value(:),'m/s');
thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');
thr.tether1.density.setValue(1000,'kg/m^3');
%% winches IC's and dependant properties
wnch.setTetherInitLength(vhcl,env,thr);
%% ALL Controller Properties
%Initilization and General
fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,hiLvlCtrl.basisParams.Value)
fltCtrl.setStartControl(1,'s')

%Level 1, Velocity Angle Selection
    fltCtrl.setSearchSize(.5,'');
    fltCtrl.perpErrorVal.setValue(3*pi/180,'rad')

%Level 2, Tangent Roll Selection
    fltCtrl.maxBank.upperLimit.setValue(45*pi/180,'');
    fltCtrl.maxBank.lowerLimit.setValue(-45*pi/180,'');

    fltCtrl.velAng.kp.setValue(0.1,'(rad)/(rad)');
    fltCtrl.velAng.ki.setValue(0,'(rad)/(rad*s)');
    fltCtrl.velAng.kd.setValue(1.5*fltCtrl.velAng.kp.Value,'(rad)/(rad/s)');
    fltCtrl.velAng.tau.setValue(0.01,'s');

%Level 3 Moment Selection
    fltCtrl.rollMoment.kp.setValue(2500 / (10*pi/180),'(N*m)/(rad)'); %This needs to be scheduled with flow speed
    fltCtrl.rollMoment.ki.setValue(0,'(N*m)/(rad*s)');
    fltCtrl.rollMoment.kd.setValue(5*fltCtrl.rollMoment.kp.Value,'(N*m)/(rad/s)');
    fltCtrl.rollMoment.tau.setValue(0.01,'s');

    fltCtrl.yawMoment.kp.setValue(0 / (2*pi/180),'(N*m)/(rad)');
    fltCtrl.yawMoment.ki.setValue(0,'(N*m)/(rad*s)');
    fltCtrl.yawMoment.kd.setValue(0,'(N*m)/(rad/s)');
    fltCtrl.yawMoment.tau.setValue(0.01,'s');

%Control Allocation
    allMat = zeros(4,3);
    allMat(1,1)=-1/(2*vhcl.portWing.GainCL.Value(2)*...
       vhcl.portWing.refArea.Value*abs(vhcl.portWing.aeroCentPosVec.Value(2)));
    allMat(2,1)=-1*allMat(1,1);
    allMat(3,2)=-1/(vhcl.hStab.GainCL.Value(2)*...
       vhcl.hStab.refArea.Value*abs(vhcl.hStab.aeroCentPosVec.Value(1)));
    allMat(4,3)= 1/(vhcl.vStab.GainCL.Value(2)*...
       vhcl.vStab.refArea.Value*abs(vhcl.vStab.aeroCentPosVec.Value(1)));
    % allMat = [-1.1584         0         0;
    %           1.1584         0         0;
    %           0             -2.0981    0;
    %           0              0         4.8067]; 
    fltCtrl.ctrlAllocMat.setValue(allMat,'(deg)/(m^3)');
    
    fltCtrl.controlSigMax.upperLimit.setValue(30,'')
    fltCtrl.controlSigMax.lowerLimit.setValue(-30,'')

%Winch Controller
    fltCtrl.traditionalBool.setValue(0,'')

    fltCtrl.winchSpeedIn.setValue(-0*flowspeed/3,'m/s')
    fltCtrl.winchSpeedOut.setValue(0*flowspeed/3,'m/s')

    fltCtrl.elevatorReelInDef.setValue(0,'deg')

    fltCtrl.setMinR(100,'m')
    fltCtrl.setMaxR(200,'m')

    % fltCtrl.outRanges.setValue([0.49   1.0000;
    %                             2.0000    2.0000],''); %circle
    fltCtrl.outRanges.setValue( [0    0.1250;
                                 0.3750    0.6250;
                                 0.8750    1.0000;],'');
%% Scale
% scale environment
env.scale(lengthScaleFactor,densityScaleFactor);
% scale vehicle
vhcl.scale(lengthScaleFactor,densityScaleFactor);
vhcl.calcFluidDynamicCoefffs;
% scale ground station
gndStn.scale(lengthScaleFactor,densityScaleFactor);
% scale tethers
thr.scale(lengthScaleFactor,densityScaleFactor);
% scale winches
wnch.scale(lengthScaleFactor,densityScaleFactor);
% scale controller
fltCtrl.scale(lengthScaleFactor,densityScaleFactor);
%% Run the simulation
simWithMonitor('OCTModel')
parseLogsout;
% kiteAxesPlot
%stopCallback
%% Desired And Achieved Moments
if DAMPlot
figure
subplot(3,1,1)
plot(tsc.MFluidBdy.Time,squeeze(tsc.MFluidBdy.Data(1,:,:)),...
    'LineWidth',1.5,'LineStyle','-','Color','k',...
    'DisplayName','Actual');
grid on
hold on
title('Desired and Achieved Moments')
plot(tsc.desiredMoment.Time,tsc.desiredMoment.Data(:,1),...
    'LineWidth',1.5,'LineStyle','--','Color','r',...
    'DisplayName','Desired');
xlabel('Time, [s]')
ylabel('Roll Moment [Nm]')
legend
subplot(3,1,2)
plot(tsc.MFluidBdy.Time,squeeze(tsc.MFluidBdy.Data(2,:,:)),...
    'LineWidth',1.5,'LineStyle','-','Color','k',...
    'DisplayName','Actual');
grid on
hold on
plot(tsc.desiredMoment.Time,tsc.desiredMoment.Data(:,2),...
    'LineWidth',1.5,'LineStyle','--','Color','r',...
    'DisplayName','Desired');xlabel('Time, [s]')
ylabel('Pitch Moment [Nm]')
legend
subplot(3,1,3)
plot(tsc.MFluidBdy.Time,squeeze(tsc.MFluidBdy.Data(3,:,:)),...
    'LineWidth',1.5,'LineStyle','-','Color','k',...
    'DisplayName','Actual');
grid on
hold on
plot(tsc.desiredMoment.Time,tsc.desiredMoment.Data(:,3),...
    'LineWidth',1.5,'LineStyle','--','Color','r',...
    'DisplayName','Desired');
xlabel('Time, [s]')
ylabel('Yaw Moment [Nm]')
legend

linkaxes(findall(gcf,'Type','axes'),'x')
set(findall(gcf,'Type','axes'),'FontSize',16)

end 
%% Control Surf Def
if CSDPlot
plotControlSurfaceDeflections
end
%% Plot yaw moment controller things
if YMCTPlot
figure
subplot(3,1,1)
tsc.betaRad.plot('LineWidth',1.5,'LineStyle','-','Color','k',...
    'DisplayName','Actual')
grid on
hold on
tsc.betaSP.plot('LineWidth',1.5,'LineStyle','--','Color','r',...
    'DisplayName','Setpoint')
xlabel('Time, t [s]')
ylabel('$\beta$,[rad]')
legend
title('Yaw controller breakdown')

subplot(3,1,2)
plot(tsc.ctrlSurfDeflection.Time,...
    squeeze(tsc.ctrlSurfDeflection.Data(4,:,:)),...
    'LineWidth',1.5,'LineStyle','-','Color','k')
grid on
xlabel('Time, t [s]')
ylabel({'Rudder Defl [deg]'})

subplot(3,1,3)
plot(tsc.MFluidBdy.Time,squeeze(tsc.MFluidBdy.Data(3,:,:)),...
    'LineWidth',1.5,'LineStyle','-','Color','k',...
    'DisplayName','Actual');
grid on
hold on
plot(tsc.desiredMoment.Time,tsc.desiredMoment.Data(:,3),...
    'LineWidth',1.5,'LineStyle','--','Color','r',...
    'DisplayName','Desired');
xlabel('Time, t [s]')
ylabel('Moment, [N*m]')
legend

linkaxes(findall(gcf,'Type','axes'),'x')
set(findall(gcf,'Type','axes'),'FontSize',16)
end
%% Plot tangent roll tracking
if TRTPlot
figure
tsc.tanRoll.plot('LineWidth',1.5,'LineStyle','-','Color','k',...
    'DisplayName','Actual Tan Roll');
grid on
hold on
tsc.tanRollDes.plot('LineWidth',1.5,'LineStyle','--','Color','r',...
    'DisplayName','Desired Tan Roll');
legend
end