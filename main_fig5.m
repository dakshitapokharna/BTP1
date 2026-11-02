% Reproduces Fig. 5 of Majumder & Nagy (2013): CGM (Al3+) hinders growth in x1.
% Solid dark lines = our code, thick light dashed lines = paper (digitized).
clear; clc; close all;
p = kdp_params();

pure  = kdp_run(p, 0, 'pure');                 % no CGM
const = kdp_run(p, 1, 'const', 20);            % CGM = 20 mg/l, constant
ctrl  = kdp_run(p, 1, 'control', [10 2.5]);    % P control, Kp = 10, r_sp = 2.5

blue = [0 0 1];  green = [0 0.5 0];  red = [1 0 0];

figure('Position',[100 50 1000 900],'Name','Fig 5 comparison');
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 11 10],'PaperSize',[11 10]);
a1 = subplot(3,1,1);  a2 = subplot(3,1,2);  a3 = subplot(3,1,3);

% (a) CGM flow rate
plot_pair(a1, pure.tk,  pure.Fk,  '',                  blue,  'Pure solution', '-.');
plot_pair(a1, const.tk, const.Fk, '',                  green, 'CGM = 20 mg/l', '-');
plot_pair(a1, ctrl.tk,  ctrl.Fk,  'f5_flow_ctrl.csv',  red,   'Control (Kp=10)', '-');
ylabel('CGM flow rate [ml/s]'); xlabel('time [s]'); axis([0 15000 0 15]);
legend('Location','eastoutside','FontSize',6); box on;

% (a) CGM concentration
plot_pair(a2, pure.t,  pure.C,  '',                  blue,  'Pure solution', '-.');
plot_pair(a2, const.t, const.C, 'f5_conc_const.csv', green, 'CGM = 20 mg/l', '-');
plot_pair(a2, ctrl.t,  ctrl.C,  'f5_conc_ctrl.csv',  red,   'Control (Kp=10)', '-');
ylabel('CGM Conc [mg/l]'); xlabel('time [s]'); axis([0 15000 0 60]);
legend('Location','eastoutside','FontSize',6); box on;

% (a) aspect ratio
plot_pair(a3, pure.t,  pure.r,  'f5_r_pure.csv',  blue,  'Pure solution', '-.');
plot_pair(a3, const.t, const.r, 'f5_r_const.csv', green, 'CGM = 20 mg/l', '-');
plot_pair(a3, ctrl.t,  ctrl.r,  'f5_r_ctrl.csv',  red,   'Control (Kp=10)', '-');
plot([0 15000],[2.5 2.5],'k:','LineWidth',1.2,'DisplayName','Setpoint 2.5');
ylabel('Aspect ratio, r'); xlabel('time [s]'); axis([0 15000 0.5 4.5]);
legend('Location','eastoutside','FontSize',6); box on;

fprintf('\nFig 5 : final aspect ratio at 14400 s\n');
fprintf('  case                  paper    ours\n');
fprintf('  Pure solution         2.09     %.3f\n', pure.rend);
fprintf('  CGM = 20 mg/l         4.06     %.3f\n', const.rend);
fprintf('  Control (Kp=10)       2.50     %.3f\n', ctrl.rend);
fprintf('  peak F_CGM [ml/s]     ~13      %.2f\n', max(ctrl.Fk));
fprintf('  peak C_CGM [mg/l]     ~52      %.1f\n', max(ctrl.C));
