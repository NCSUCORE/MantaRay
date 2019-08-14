clc;clear
if ~slreportgen.utils.isModelLoaded('OCTModel')
    OCTModel
end

lengthScaleFactor = 1/1;
densityScaleFactor = 1/1;
duration_s  = 60*sqrt(lengthScaleFactor);
dynamicCalc = '';

%% Load components
% Flight Controller
loadComponent('firstBuildPathFollowing');
% Ground station controller
loadComponent('oneDoFGSCtrlBasic');
% High level controller
loadComponent('testConstBasisParams')
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

%% Set basis parameters for high level controller
% hiLvlCtrl.basisParams.setValue([60 10 0 30 150],'') % Lemniscate of Gerono
hiLvlCtrl.basisParams.setValue([.75,1.5,.36,0,125],'') % Lemniscate of Booth


%% Environment IC's and dependant properties
% Set Values
flowspeed = 1.5; %m/s options are .1, .5, 1, 1.5, and 2
env.water.velVec.setValue([flowspeed 0 0],'m/s');

%% Ground Station IC's and dependant properties
gndStn.initAngPos.setValue(0,'rad');
gndStn.initAngVel.setValue(0,'rad/s');
%gndStn.thrAttch1.velVec.setValue([0 0 0]','m/s');

fltCtrl.setFcnName('lemOfBooth','');

%% Set vehicle initial conditions
vhcl.setICsOnPath(...
    0,... % Initial path position
    fltCtrl.fcnName.Value,... % Name of path function
    hiLvlCtrl.basisParams.Value,... % Geometry parameters
    6) % Initial speed
vhcl.setAddedMISwitch(false,'');

%% Controller User Def. Parameters and dependant properties
fltCtrl.outRanges.setValue( [...
    0           0.1250;
    0.3450      0.6250;
    0.8500      1.0000;],'');

fltCtrl.ctrlAllocMat.setValue([...
    -1.1584         0         0;
     1.1584         0         0;
     0             -2.0981    0;
     0              0         4.8067],'(deg)/(m^3)');
fltCtrl.winchSpeedIn.setValue(-flowspeed/3,'m/s')
fltCtrl.winchSpeedOut.setValue(flowspeed/3,'m/s')
fltCtrl.traditionalBool.setValue(0,'')

fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,hiLvlCtrl.basisParams.Value)

%% Tethers IC's and dependant properties
thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:),'m');
thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)+rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts.posVec.Value,'m');
thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecBdy.Value(:),'m/s');
thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');


%% winches IC's and dependant properties
wnch.setTetherInitLength(vhcl,env,thr);

%% gain tuning based on flow speed
switch norm(env.water.velVec.Value)
    case 0.1
        fltCtrl.setPerpErrorVal(7*pi/180,'rad');
        fltCtrl.rollMoment.setKp(4e5,'(N*m)/(rad)');
        fltCtrl.rollMoment.setKd(.2*fltCtrl.rollMoment.kp.Value,'(N*m)/(rad/s)');
    case 0.5
        fltCtrl.setPerpErrorVal(4*pi/180,'rad');
        fltCtrl.rollMoment.setKp(4e5,'(N*m)/(rad)');
        fltCtrl.rollMoment.setKd(.6*fltCtrl.rollMoment.kp.Value,'(N*m)/(rad/s)');
    case 1
        %     fltCtrl.perpErrorVal.setValue(3*pi/180,'rad');
        %     fltCtrl.rollMoment.kp.setValue(3e5,'(N*m)/(rad)');
        %     fltCtrl.rollMoment.kd.setValue(2*fltCtrl.rollMoment.kp.Value,'(N*m)/(rad/s)');
        fltCtrl.setPerpErrorVal(3*pi/180,'rad');
        fltCtrl.rollMoment.setKp(3e5,'(N*m)/(rad)');
        fltCtrl.rollMoment.setKd(2*fltCtrl.rollMoment.kp.Value,'(N*m)/(rad/s)');
        fltCtrl.velAng.setTau(.8,'s');
        fltCtrl.rollMoment.setTau(.8,'s');
        fltCtrl.maxBank.upperLimit.setValue(20*pi/180,'');
        fltCtrl.maxBank.lowerLimit.setValue(-20*pi/180,'');
    case 1.5
        %     fltCtrl.perpErrorVal.setValue(3*pi/180,'rad');
        %     fltCtrl.rollMoment.kp.setValue(4e5,'(N*m)/(rad)');
        %     fltCtrl.rollMoment.kd.setValue(2*fltCtrl.rollMoment.kp.Value,'(N*m)/(rad/s)');
        %     fltCtrl.velAng.tau.setValue(.01,'s');
        %     fltCtrl.rollMoment.tau.setValue (.01,'s');
        fltCtrl.setPerpErrorVal(3*pi/180,'rad');
        fltCtrl.rollMoment.setKp(3e5,'(N*m)/(rad)');
        fltCtrl.rollMoment.setKd(150000,'(N*m)/(rad/s)');
%         fltCtrl.rollMoment.setKd(0000,'(N*m)/(rad/s)');
        fltCtrl.velAng.setTau(.01,'s');
        fltCtrl.rollMoment.setTau(.01,'s');
    case 2
        fltCtrl.perpErrorVal.setValue(3*pi/180,'rad');
        fltCtrl.rollMoment.kp.setValue(5.9e5,'(N*m)/(rad)');
        fltCtrl.rollMoment.kd.setValue(4.5*fltCtrl.rollMoment.kp.Value,'(N*m)/(rad/s)');
    otherwise
        error('Controller tuning for that flow speed is not implemented')
end

fltCtrl.velAng.kp.setValue(fltCtrl.maxBank.upperLimit.Value/(100*(pi/180)),'(rad)/(rad)');
fltCtrl.velAng.kd.setValue(0.5,'(rad)/(rad/s)');
fltCtrl.rollMoment.kd.setValue(.2*fltCtrl.rollMoment.kp.Value,'(N*m)/(rad/s)');
fltCtrl.rollMoment.ki.setValue(1e10,'(N*m)/(rad*s)');

% Turn off spooling controller (get rid of this later)
fltCtrl.setWinchSpeedIn(0,'m/s');
fltCtrl.setWinchSpeedOut(0,'m/s');

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

%% Plot things
% Tether Release Speeds
plotThrReleaseSpeeds
% Desired And Achieved Moments
figure
subplot(3,1,1)
plot(tsc.MFluidBdy.Time,squeeze(tsc.MFluidBdy.Data(1,:,:)),...
    'LineWidth',1.5,'LineStyle','-','Color','k',...
    'DisplayName','Actual');
grid on
hold on
plot(tsc.rollMomCtrl.Time,tsc.rollMomCtrl.Data,...
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
plot(tsc.pitchMomCtrl.Time,tsc.pitchMomCtrl.Data,...
    'LineWidth',1.5,'LineStyle','--','Color','r',...
    'DisplayName','Desired');
xlabel('Time, [s]')
ylabel('Pitch Moment [Nm]')
legend

subplot(3,1,3)
plot(tsc.MFluidBdy.Time,squeeze(tsc.MFluidBdy.Data(3,:,:)),...
    'LineWidth',1.5,'LineStyle','-','Color','k',...
    'DisplayName','Actual');
grid on
hold on
plot(tsc.yawMomCtrl.Time,tsc.yawMomCtrl.Data,...
    'LineWidth',1.5,'LineStyle','--','Color','r',...
    'DisplayName','Desired');
xlabel('Time, [s]')
ylabel('Yaw Moment [Nm]')
legend 

linkaxes(findall(gcf,'Type','axes'),'x')
set(findall(gcf,'Type','axes'),'FontSize',16)

figure
tsc.tanRollDes.plot
grid on
hold on
tsc.tanRoll.plot



%% Animate the results
vhcl.animateSim(tsc,0.1,...
    'PathFunc',fltCtrl.fcnName.Value,...
    'PathPosition',true,...
    'NavigationVecs',true)
