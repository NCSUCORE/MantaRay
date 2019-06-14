createModAyazPlantBus
createModAyazFlowEnvironmentBus
createTestUntilRollCtrlBus

%%%%%%%%% Plant Attributes %%%%%%%%%%
mass = 6182; %kgs
tetherLength = 50; %meters
%lift = 
tetherTen = 30000; % newtons

%%%%%%%%% Moment Controller %%%%%%
kpM =.5;
kiM = .005;
kdM = 1.6;
tauM = .05; 
dead=.05;
 r_curve_max = 10;
%velMag=.05;



%accelMag=.5;%velMag^2/r_curve_max;
l = .5;
p = .6;
r = 50;
path = r*[cos(l).*cos(p);
         sin(l).*cos(p);
         sin(p);];
init_pos = [path(1);path(2);path(3);];
maxBank=45*pi/180;
kp_chi=maxBank/(pi/2); %max bank divided by large error
ki_chi=kp_chi/100;
kd_chi=kp_chi;
tau_chi=.1;
flow=[1;0;0;];
sim_time=100;

simWithMonitor('momentTest_th')

aB=1;bB=1;phi_curve=.5;
lamda=@(s) aB*sin(s)./(1+(aB/bB)^2*cos(s).^2);
phi=@(s) (aB/bB)^2*sin(s).*cos(s)./(1 + (aB/bB)^2*cos(s).^2);
path = @(s)[cos(lamda(s)).*cos(phi_curve+phi(s));...
            sin(lamda(s)).*cos(phi_curve+phi(s));...
            sin(phi_curve+phi(s));];
a=parseLogsout;
%% 
close all
figure
ax=axes;
runtime=10;
waittime=.05;
pathvals=path(0:.01:2*pi);
filename="Dummy_Controller_2_lowaccel.gif";
for i=1:floor(length(a.pos.Data(:,1))/(runtime/waittime)):length(a.pos.Data(:,1))
plot3(pathvals(1,:),pathvals(2,:),pathvals(3,:),'lineWidth',.5)
hold on
plot3(a.pos.Data(1:i,1),a.pos.Data(1:i,2),a.pos.Data(1:i,3),'lineWidth',2)
title(['T=' num2str(a.pos.Time(i))])
[x,y,z]=sphere;h=surfl(x,y,z);set(h,'FaceAlpha',0.5);shading(ax,'interp')
view(90,30)
% scatter3(a.star_pos.Data(1:i,1),a.star_pos.Data(1:i,2),a.star_pos.Data(1:i,3),'k')
hold off
pause(waittime)
                        % Capture the plot as an image 
                        frame = getframe(ax); 
                        im = frame2im(frame); 
                        [imind,cm] = rgb2ind(im,256); 
                        % Write to the GIF File 
                        if i == 1 
                          imwrite(imind,cm,filename,'gif', 'Loopcount',inf); 
                        else 
                          imwrite(imind,cm,filename,'gif','DelayTime',0.05,'WriteMode','append'); 
                        end 
end