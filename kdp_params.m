function p = kdp_params()
% All parameters taken from Majumder & Nagy (2013), Table 1 and text.
% Units: length [um], time [s], solute conc. [g/g water], CGM conc. [mg/l]

% ---- Growth kinetics (Table 1) ----
p.g1  = 1.48;   p.kg1 = 12.1;     % x1 direction (prismatic {100} faces)
p.g2  = 1.74;   p.kg2 = 100.75;   % x2 direction (pyramidal {101} faces)
p.rho = 2.338e-12;                % crystal density [g/um^3]

% ---- CGM adsorption / pinning (Table 1) ----
p.tau  = 36000;                   % adsorption time constant [s]
p.Ki   = 0.0648;                  % Langmuir constant [l/mg]
p.gam  = 34.15;                   % gamma_i*a/(k*L_i) [1/K]
p.Gmin = 1e-4;                    % min growth rate [um/s] (see p.useGmin)
p.useGmin = false;                % false: G = max(G,0)   true: G = max(G,Gmin)

% ---- Crystal geometry (Appendix A, KDP unit cell) ----
p.a_cell = 7.45;  p.c_cell = 6.97;          % [Angstrom]
p.tanth  = p.c_cell/p.a_cell;               % tan(theta) of {101} face

% ---- Seed crystals (Eq. 14): grid + n(0,x) ----
p.x1s = linspace(180,220,401);
p.x2s = linspace(220,260,401);

% ---- Crystallizer / control set-up (Section 3.2, 3.3) ----
p.V     = 220;      % [ml]
p.Fin   = 50;       % pure solution flow [ml/s]
p.C0    = 250;      % CGM conc. in feed [mg/l]
p.tend  = 14400;    % batch time [s]
p.Ts    = 300;      % controller sampling time [s]

% ---- Initial solute concentration (NOT given in paper -> assumption) ----
p.c0_offset = 0;    % c(0) = csat(33C) + offset   [g/g]
% Basis of the crystal number density n (paper does not state it).
% Calibrated so that the pure-solution run gives r = 2.09 (paper); 1.3 is about
% (1 + csat), i.e. "per g of solution" instead of "per g of water".
p.massScale = 1.3;
end
