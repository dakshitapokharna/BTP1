% Reproduces Fig. 6 of Majumder & Nagy (2013): CGM hinders growth in x2.
% Solid dark lines = our code, thick light dashed lines = paper (digitized).
clear; clc; close all;
p = kdp_params();

pure = kdp_run(p, 0, 'pure');                   % no CGM
k10  = kdp_run(p, 2, 'control', [-10 1.5]);     % Kp = -10, r_sp = 1.5
k20  = kdp_run(p, 2, 'control', [-20 1.5]);     % Kp = -20, r_sp = 1.5

blue = [0 0 1];  green = [0 0.5 0];  red = [1 0 0];

figure('Position',[100 50 1000 900],'Name','Fig 6 comparison');
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 11 10],'PaperSize',[11 10]);
a1 = subplot(3,1,1);  a2 = subplot(3,1,2);  a3 = subplot(3,1,3);

% (a) CGM flow rate
plot_pair(a1, pure.tk, pure.Fk, '',                 blue,  'Pure solution', '-.');
plot_pair(a1, k10.tk,  k10.Fk,  'f6_flow_kp10.csv', green, 'Control (Kp=-10)', '-');
plot_pair(a1, k20.tk,  k20.Fk,  'f6_flow_kp20.csv', red,   'Control (Kp=-20)', '-');
ylabel('CGM flow rate [ml/s]'); xlabel('time [s]'); axis([0 15000 0 6]);
legend('Location','eastoutside','FontSize',6); box on;

% (a) CGM concentration
plot_pair(a2, pure.t, pure.C, '',                 blue,  'Pure solution', '-.');
plot_pair(a2, k10.t,  k10.C,  'f6_conc_kp10.csv', green, 'Control (Kp=-10)', '-');
plot_pair(a2, k20.t,  k20.C,  'f6_conc_kp20.csv', red,   'Control (Kp=-20)', '-');
ylabel('CGM Conc [mg/l]'); xlabel('time [s]'); axis([0 15000 0 25]);
legend('Location','eastoutside','FontSize',6); box on;

% (a) aspect ratio
plot_pair(a3, pure.t, pure.r, 'f6_r_pure.csv', blue,  'Pure solution', '-.');
plot_pair(a3, k10.t,  k10.r,  'f6_r_kp10.csv', green, 'Control (Kp=-10)', '-');
plot_pair(a3, k20.t,  k20.r,  'f6_r_kp20.csv', red,   'Control (Kp=-20)', '-');
plot([0 15000],[1.5 1.5],'k:','LineWidth',1.2,'DisplayName','Setpoint 1.5');
ylabel('Aspect ratio, r'); xlabel('time [s]'); axis([0 15000 1.2 2.2]);
legend('Location','eastoutside','FontSize',6); box on;

fprintf('\nFig 6 : final aspect ratio at 14400 s\n');
fprintf('  case                  paper    ours\n');
fprintf('  Pure solution         2.09     %.3f\n', pure.rend);
fprintf('  Control (Kp=-10)      1.55     %.3f\n', k10.rend);
fprintf('  Control (Kp=-20)      1.52     %.3f\n', k20.rend);
fprintf('  peak F_CGM [ml/s]     ~2.9/4.9 %.2f / %.2f\n', max(k10.Fk), max(k20.Fk));
fprintf('  peak C_CGM [mg/l]     ~13.5/22 %.1f / %.1f\n', max(k10.C), max(k20.C));
