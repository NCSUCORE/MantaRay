%% Test script to test the floating ground station simulation and animation

waveNumber  =  linspace(.7392,0.0800,10);
Frequencies =  linspace(2.0944,0.7306,10);
Amplitudes  =  linspace(.27, 4.1,10);
tetherDist = [ 200 250 300 350 400]';





for k = 4:4
    for j = 2:2
        for i = 6:6
            
            clearvars -except 'Amplitudes' 'Frequencies' 'waveNumber' 'i' 'j' 'k' 'tetherDist'
            
            %%
            GROUNDSTATION         = 'groundStation001';
sixDOFDynamics         = 'sixDoFDynamicsEuler';
gndStn = OCT.sixDoFStation;

gndStn.cylRad.setValue(9,'m')
gndStn.angSpac.setValue(pi/4,'rad')
gndStn.heightSpac.setValue(1.5,'m')

gndStn.setVolume(pi*gndStn.cylRad.Value^2*6,'m^3');
gndStn.setMass(gndStn.volume.Value*(1000/2),'kg');
gndStn.setInertia([.25*gndStn.mass.Value*gndStn.cylRad.Value^2,0,0;...
   0,.25*gndStn.mass.Value*gndStn.cylRad.Value^2,0;
   0,0,.5*gndStn.mass.Value*gndStn.cylRad.Value^2],'kg*m^2');



gndStn.angMatExt.setValue([linspace(0,1.75*pi,8),linspace(0,1.75*pi,8),linspace(0,1.75*pi,8),linspace(0,1.75*pi,8)],'rad');
gndStn.zMatExt.setValue([-3*ones(1,8),3*ones(1,8),1.5*ones(1,8),-1.5*ones(1,8)],'m');
gndStn.rMatExt.setValue(repmat(gndStn.cylRad.Value,[1,32]),'m');

gndStn.angMatT.setValue([linspace(0,1.75*pi,8),0],'rad')
gndStn.angMatB.setValue([linspace(0,1.75*pi,8),0],'rad')

gndStn.zMatB.setValue(-3*ones(1,9),'m')
gndStn.zMatT.setValue(3*ones(1,9),'m')

gndStn.rMatT.setValue([repmat(.5*gndStn.cylRad.Value,[1,8]),0],'m')
gndStn.rMatB.setValue([repmat(.5*gndStn.cylRad.Value,[1,8]),0],'m')

gndStn.angMatInt.setValue([linspace(0,1.75*pi,8),linspace(0,1.75*pi,8),linspace(0,1.75*pi,8),linspace(0,1.75*pi,8)],'rad')
gndStn.zMatInt.setValue([-1.5*ones(1,8),1.5*ones(1,8),-.75*ones(1,8),.75*ones(1,8)],'m');
gndStn.rMatInt.setValue(repmat(.5*gndStn.cylRad.Value,[1,32]),'m')


%number of tethers that go from the GS to the KITE
gndStn.numTethers.setValue(1,'');  

gndStn.build;
gndStn.buildCylStation
gndStn.thrAttch1.posVec.setValue([0 0 0]','m');
gndStn.bouyancy

% added mass and drag coefficants of lumped masses
gndStn.cdX.setValue(1,'')
gndStn.cdY.setValue(1,'')
gndStn.cdZ.setValue(1,'')
gndStn.aMX.setValue(.1,'')
gndStn.aMY.setValue(.1,'')
gndStn.aMZ.setValue(.1,'')

gndStn.lumpedMassSphereRadius.setValue(.5*gndStn.heightSpac.Value,'m'); 


% tether attach point for the tether that goes from the GS to the KITE
% gndStn.addThrAttch('kitThrAttchPt1',[gndStn.cylRad.Value 0 -0.5*gndStn.cylTotH.Value]);
gndStn.addThrAttch('kitThrAttchPt1',[0 0 0]);


% tether attach points for the tether that goes from the GS to the GND
gndStn.addThrAttch('pltThrAttchPt1',[gndStn.cylRad.Value 0 -0.5*gndStn.cylTotH.Value]');
gndStn.addThrAttch('pltThrAttchPt2',rotation_sequence([0 0  2*pi/3])*gndStn.pltThrAttchPt1.posVec.Value(:));
gndStn.addThrAttch('pltThrAttchPt3',rotation_sequence([0 0 -2*pi/3])*gndStn.pltThrAttchPt1.posVec.Value(:));

gndStn.addThrAttch('inrThrAttchPt1',[tetherDist(k) 0 0]');
gndStn.addThrAttch('inrThrAttchPt2',rotation_sequence([0 0  2*pi/3])*gndStn.inrThrAttchPt1.posVec.Value(:));
gndStn.addThrAttch('inrThrAttchPt3',rotation_sequence([0 0 -2*pi/3])*gndStn.inrThrAttchPt1.posVec.Value(:));

gndStn.setInitPosVecGnd([0 0 200],'m')
% gndStn.calcInitTetherLen 0.9937
% gndStn.initAnchTetherLength.setValue(.9937*gndStn.calcInitTetherLen,'m')
gndStn.initAnchTetherLength.setValue(.985*gndStn.calcInitTetherLen,'m')


% Anchor Tethers
gndStn.anchThrs.setNumNodes(2,'');
gndStn.anchThrs.setNumTethers(3,'');
gndStn.anchThrs.build;

% Tether 1 properties
gndStn.anchThrs.tether1.diameter.setValue(.05,'m');              % tether diameter
gndStn.anchThrs.tether1.youngsMod.setValue(500e9,'Pa');          % tether Young's Modulus
gndStn.anchThrs.tether1.dampingRatio.setValue(.3,'');           % zeta, damping ratio
gndStn.anchThrs.tether1.dragCoeff.setValue(.5,'');               % drag coefficient for intermediate nodes
gndStn.anchThrs.tether1.density.setValue(1300,'kg/m^3');         % tether density
gndStn.anchThrs.tether1.vehicleMass.setValue(gndStn.mass.Value,'kg'); % mass of platform for damping coefficient calculations
gndStn.anchThrs.tether1.dragEnable.setValue(1,'');
gndStn.anchThrs.tether1.netBuoyEnable.setValue(1,'');


% Tether 2 properties
gndStn.anchThrs.tether2.diameter.setValue(.05,'m');              % tether diameter
gndStn.anchThrs.tether2.youngsMod.setValue(500e9,'Pa');          % tether Young's Modulus
gndStn.anchThrs.tether2.dampingRatio.setValue(.3,'');           % zeta, damping ratio
gndStn.anchThrs.tether2.dragCoeff.setValue(.5,'');               % drag coefficient for intermediate nodes
gndStn.anchThrs.tether2.density.setValue(1300,'kg/m^3');         % tether density
gndStn.anchThrs.tether2.vehicleMass.setValue(gndStn.mass.Value,'kg'); % mass of platform for damping coefficient calculations
gndStn.anchThrs.tether2.dragEnable.setValue(1,'');
gndStn.anchThrs.tether2.netBuoyEnable.setValue(1,'');



% Tether 3 properties
gndStn.anchThrs.tether3.diameter.setValue(.05,'m');              % tether diameter
gndStn.anchThrs.tether3.youngsMod.setValue(500e9,'Pa');          % tether Young's Modulus
gndStn.anchThrs.tether3.dampingRatio.setValue(.3,'');           % zeta, damping ratio
gndStn.anchThrs.tether3.dragCoeff.setValue(.5,'');               % drag coefficient for intermediate nodes
gndStn.anchThrs.tether3.density.setValue(1300,'kg/m^3');         % tether density
gndStn.anchThrs.tether3.vehicleMass.setValue(gndStn.mass.Value,'kg'); % mass of platform for damping coefficient calculations
gndStn.anchThrs.tether3.dragEnable.setValue(1,'');
gndStn.anchThrs.tether3.netBuoyEnable.setValue(1,'');

% Save the variable
saveBuildFile('gndStn','oneThrThreeAnchGndStn001_bs','variant','GROUNDSTATION');
            
%%            
            
            clc;close all
            simParams = SIM.simParams;
            simParams.setDuration(500,'s');
            dynamicCalc = '';
            
            %% Load components
            % Flight Controller
            loadComponent('pathFollowingCtrlForILC');
            % Ground station controller
            loadComponent('oneDoFGSCtrlBasic');
            % High level controller
            loadComponent('constBoothLem')
            % Ground station
            loadComponent('oneThrThreeAnchGndStn001');
            % Winches
            loadComponent('oneDOFWnchPTO');
            % Tether
            loadComponent('pathFollowingTether');
            % Vehicle
            loadComponent('pathFollowingVhclForComp');
            % Environment
            loadComponent('hurricaneSandyWave');
            % Sensors
            loadComponent('idealSensors')
            % Sensor processing
            loadComponent('idealSensorProcessing')
            
            %% Environment IC's and dependant properties
            env.water.setflowVec([j 0 0],'m/s')
            
            env.waterWave.waveParamMat.setValue([waveNumber(i),Frequencies(i),Amplitudes(i) ,0;0,0,0,0],'')
            %% Set basis parameters for high level controller
            hiLvlCtrl.basisParams.setValue([.8,1.6,-20*pi/180,0*pi/180,125],'') % Lemniscate of Booth
            
            %% Ground Station IC's and dependant properties
            gndStn.setInitPosVecGnd([0 0 200],'m')
            gndStn.setInitVelVecBdy([0 0 0],'m/s')
            gndStn.setInitEulAng([0 0 0],'rad');
            gndStn.initAngVelVec.setValue([0 0 0],'rad/s');
            
            %% Set vehicle initial conditions
            vhcl.setICsOnPath(...
                0,... % Initial path position
                PATHGEOMETRY,... % Name of path function
                hiLvlCtrl.basisParams.Value,... % Geometry parameters
                gndStn.initPosVecGnd.Value,... % Center point of path sphere
                (11/2)*norm(env.water.flowVec.Value)) % Initial speed
            
            %% Tethers IC's and dependant properties
            thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:)...
                +gndStn.initPosVecGnd.Value(:),'m');
            thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)...
                +rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts_B.posVec.Value,'m');
            
            thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
            thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecBdy.Value(:),'m/s');
            
            thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');
            
            %% Winches IC's and dependant properties
            wnch.setTetherInitLength(vhcl,gndStn.initPosVecGnd.Value,env,thr,[ 1 0 0]);
            
            %% Controller User Def. Parameters and dependant properties
            fltCtrl.setFcnName(PATHGEOMETRY,''); % PATHGEOMETRY is defined in fig8ILC_bs.m
            fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,...
                hiLvlCtrl.basisParams.Value,...
                gndStn.initPosVecGnd.Value);
            simWithMonitor('OCTModel')
            tsc = signalcontainer(logsout);
            
            %%
            % vhcl.animateSim(tsc,.4,...
            %     'PathFunc',fltCtrl.fcnName.Value,...
            %     'PlotTracer',true,...
            %     'FontSize',24,...
            %     'PowerBar',false,...
            %     'PlotAxes',false,...
            %     'TetherNodeForces',true,...
            %     'TracerDuration',10,...
            %     'GroundStation',gndStn,...
            %     'GifTimeStep',1/30)
            try
                h1 = figure;
                plotAnchThrTen;
                h2 =figure;
                tsc.gndStnPositionVec.plot;
                h3 = figure;
                plotPower
                
                % saveas(h1,sprintf('C:\\Users\\jcreed2\\GitStuff\\bubble3P0\\outputJames\\%d\\anchThrTen%d.png', 1,2))
                saveas(h1,sprintf('C:\\Users\\jcreed2\\GitStuff\\bubble3P0\\outputJames\\anchThrTen%d%d%d.png', i,j,k))
                saveas(h2,sprintf('C:\\Users\\jcreed2\\GitStuff\\bubble3P0\\outputJames\\gndStnPos%d%d%d.png', i,j,k))
                saveas(h3,sprintf('C:\\Users\\jcreed2\\GitStuff\\bubble3P0\\outputJames\\power%d%d%d.png', i,j,k))
            catch
            end
            % x = tsc.powerSummary;
            
        end
    end
end
vhcl.animateSim(tsc,1,...
    'PathFunc',fltCtrl.fcnName.Value,...
    'PlotTracer',true,...
    'FontSize',24,...
    'PowerBar',false,...
    'PlotAxes',false,...
    'TetherNodeForces',false,...
    'TracerDuration',10,...
    'GroundStation',gndStn,...
    'GifTimeStep',1/30,...
    'SaveGif',true)