function out = kdp_run(p, face, mode, arg)
% Method-of-moments simulation of KDP cooling crystallization with a CGM.
%
%   face : 0 = no CGM effect, 1 = CGM blocks x1 growth (Fig 5),
%                             2 = CGM blocks x2 growth (Fig 6)
%   mode : 'pure'    -> no CGM at all
%          'const'   -> CGM held at constant concentration arg [mg/l]
%          'control' -> P controller, arg = [Kp  r_setpoint]
%
% State y = [mu00 mu10 mu01 mu11 mu20 c  C_cgm]

[m0 ] = seed_moments(p);
Tfun = @(t) 33 - (33-23)/(3600*4)*t;                 % Eq. 37 [C]
csat = @(T) 9.3027e-5*T.^2 - 9.7629e-5*T + 0.2087;   % Eq. 17 [g/g]
c0   = csat(33) + p.c0_offset;
y0   = [m0(1) m0(2) m0(3) m0(4) m0(5) c0 0];

switch mode
    case 'pure',    face = 0;
    case 'const',   y0(7) = arg;
end

t_all = 0; y_all = y0; F_all = 0;
tk_list = [];  Fk_list = [];
tk = 0;  y = y0;
opts = odeset('RelTol',1e-8,'AbsTol',1e-12);

while tk < p.tend - 1e-9
    tn = min(tk + p.Ts, p.tend);
    % ---- controller action (zero-order hold over one sample) ----
    r = y(3)/y(2);                                    % Eq. 36
    switch mode
        case 'control'
            Kp = arg(1);  rsp = arg(2);
            F  = max(0, 0 + Kp*(rsp - r));            % Eq. 38, F_CGM,0 = 0
        otherwise
            F = 0;
    end
    tk_list(end+1,1) = tk;  Fk_list(end+1,1) = F;     % controller output at sample time
    [t, Y] = ode45(@(t,y) rhs(t,y,p,face,mode,F,Tfun,csat), [tk tn], y, opts);
    t_all = [t_all; t(2:end)];  y_all = [y_all; Y(2:end,:)];
    F_all = [F_all; F*ones(numel(t)-1,1)];
    tk = tn;  y = Y(end,:);
end
% controller output at the very end of the batch (for a closed-looking curve)
if strcmp(mode,'control')
    tk_list(end+1,1) = p.tend;
    Fk_list(end+1,1) = max(0, arg(1)*(arg(2) - y(3)/y(2)));
else
    tk_list(end+1,1) = p.tend;  Fk_list(end+1,1) = 0;
end

out.tk   = tk_list;     % sample times [s]
out.Fk   = Fk_list;     % controller flow at sample times (paper plots these joined by lines)
out.t    = t_all;
out.r    = y_all(:,3)./y_all(:,2);
out.C    = y_all(:,7);
out.F    = F_all;
out.c    = y_all(:,6);
out.rend = out.r(end);
end

% ------------------------------------------------------------------
function dy = rhs(t,y,p,face,mode,F,Tfun,csat)
m00=y(1); m10=y(2); m01=y(3); m11=y(4); m20=y(5); c=y(6); C=y(7);
T  = Tfun(t);  cs = csat(T);
sig = max((c-cs)/cs, 0);                              % Eq. 2

% CGM coverage, Eqs. 5-6 (contact time eta = t, all seeds)
thEq  = p.Ki*C/(1+p.Ki*C);
theta = thEq*(1-exp(-t/p.tau));
th1 = 0; th2 = 0;
if face==1, th1 = theta; elseif face==2, th2 = theta; end

G1 = growth(p.kg1,p.g1,sig,th1,T,p);                  % Eqs. 1,3,4
G2 = growth(p.kg2,p.g2,sig,th2,T,p);

dy = zeros(7,1);
dy(1) = 0;                                            % Eq. 29  (B0 = 0)
dy(2) = G1*m00;                                       % Eq. 30
dy(3) = G2*m00;                                       % Eq. 31
dy(4) = G1*m01 + G2*m10;                              % Eq. 32
dy(5) = 2*G1*m10;                                     % Eq. 33
dy(6) = -p.rho*p.massScale*(2*G1*m11 + G2*m20 - 2*G1*m20*p.tanth); % Eq. 35

if strcmp(mode,'control')                             % Eqs. 19-20 (CGM balance)
    Fout = F + p.Fin;
    dy(7) = (F*p.C0 - Fout*C)/p.V;
end                                                   % 'const'/'pure': C fixed
end

% ------------------------------------------------------------------
function G = growth(kg,g,sig,theta,T,p)
% G = G0*(1 - alpha*theta),  G0 = kg*sig^g,  alpha = gam/(T*sig)
if sig <= 0
    G = 0; return
end
G = kg*sig^g - kg*sig^(g-1)*p.gam*theta/(T+273.15);
if p.useGmin, G = max(G,p.Gmin); else, G = max(G,0); end
end

% ------------------------------------------------------------------
function m = seed_moments(p)
% moments of seed distribution Eq. (14) by 2-D trapezoidal integration
[X1,X2] = meshgrid(p.x1s,p.x2s);
n = -0.00034786*(X1.^2+(X2-40).^2) + 0.1363609*(X1+(X2-40)) - 13.2743*2;
I = @(f) trapz(p.x2s, trapz(p.x1s, f, 2));
m = [I(n) I(n.*X1) I(n.*X2) I(n.*X1.*X2) I(n.*X1.^2)];
end
