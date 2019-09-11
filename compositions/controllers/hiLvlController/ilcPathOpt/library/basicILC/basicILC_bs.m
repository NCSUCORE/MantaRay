hiLvlCtrl = CTR.controller;
HILVLCONTROLLER = 'ilcPathOpt';
PATHGEOMETRY = 'lemOfBooth';
hiLvlCtrl.add('GainNames',...
    {...
    'pathVarLowerLim',...
    'pathVarUpperLim',...
    'numInitLaps',...
    'distPenaltyWght',...
    'initBasisParams',...
    'learningGain',...
    'forgettingFactor',...
    'trustRegion',...
    'excitationAmp',...
    'filtTimeConst'},...
    'GainUnits',...
    {...
    '',...
    '',...
    '',...
    'W/deg',...
    '[deg deg]',...
    '',... % Still need to figure out these units
    '',...
    '[deg deg]',...
    '[deg deg]',...
    's',...
    ''});

hiLvlCtrl.pathVarLowerLim.setValue(0.001,'');
hiLvlCtrl.pathVarUpperLim.setValue(0.05,'');
hiLvlCtrl.numInitLaps.setValue(2,'');
hiLvlCtrl.distPenaltyWght.setValue(10000,'W/deg');
hiLvlCtrl.learningGain.setValue(1e-4,'');
hiLvlCtrl.forgettingFactor.setValue(0.99,'');
hiLvlCtrl.trustRegion.setValue([1 1],'[deg deg]');
hiLvlCtrl.excitationAmp.setValue([0 0],'[deg deg]');
hiLvlCtrl.filtTimeConst.setValue(0.1,'s');

%% save file in its respective directory
saveFile = saveBuildFile('hiLvlCtrl',mfilename,'variant','HILVLCONTROLLER');
save(saveFile,'PATHGEOMETRY','-append')
