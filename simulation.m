clc;
clear('all');
rng('default');
warning('off','all');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SIMULATION CONFIGURATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PARAMETERS = {};
PARAMETERS.SIMULATION = {};
PARAMETERS.CONTROL = {};
PARAMETERS.DISTURBANCE = {};
PARAMETERS.PLOT = {};
PARAMETERS.SIMULATION.TOTAL_TIME = 20;
PARAMETERS.PLOT.CREATE_PDF = 0;
PARAMETERS.SIMULATION.SCENARIO = 1;
PARAMETERS.SIMULATION.SAMPLING_TIME_INDEX = 2;
PARAMETERS.SIMULATION.SAMPLING_TIMES = [1E-1, 1E-2, 1E-3];
PARAMETERS.SIMULATION.SAMPLING_TIME = PARAMETERS.SIMULATION.SAMPLING_TIMES(PARAMETERS.SIMULATION.SAMPLING_TIME_INDEX);
PARAMETERS.CONTROL.CUTOFFS = -[2.5 5 5] .* log10(PARAMETERS.SIMULATION.SAMPLING_TIMES);
PARAMETERS.CONTROL.LAMBDAS = 2.*PARAMETERS.CONTROL.CUTOFFS;
PARAMETERS.CONTROL.GAMMAS = [1 2 4] ./ (PARAMETERS.SIMULATION.SAMPLING_TIMES);

PARAMETERS.SIMULATION.INITIAL_STATE = 20;
PARAMETERS.SIMULATION.NOISE_MODULE_DB = 0;

PARAMETERS.PLOT.FONT_SIZE = 12;
if PARAMETERS.SIMULATION.SCENARIO == 1
    PARAMETERS.CONTROL.K1_STW = 2;
    PARAMETERS.CONTROL.K2_STW = 1;
    PARAMETERS.CONTROL.K3_STW = 1;
    PARAMETERS.CONTROL.MAX = 5;
    PARAMETERS.CONTROL.EPSILON = 2;
%     PARAMETERS.DISTURBANCE.D_MAX = 0;
%     PARAMETERS.DISTURBANCE.DOT_D_MAX = 0;
elseif PARAMETERS.SIMULATION.SCENARIO == 2
    PARAMETERS.CONTROL.K1_STW = 4;
    PARAMETERS.CONTROL.K2_STW = 9;
    PARAMETERS.CONTROL.K3_STW = 2;
    PARAMETERS.CONTROL.MAX = 5;
    PARAMETERS.CONTROL.EPSILON = 0.1;
%     PARAMETERS.DISTURBANCE.D_MAX = 1;
%     PARAMETERS.DISTURBANCE.DOT_D_MAX = 2;
elseif PARAMETERS.SIMULATION.SCENARIO == 3
    PARAMETERS.CONTROL.K1_STW = 4;
    PARAMETERS.CONTROL.K2_STW = 9;
    PARAMETERS.CONTROL.K3_STW = 2;
    PARAMETERS.CONTROL.MAX = 5;
    PARAMETERS.CONTROL.EPSILON = 0.1;
%     PARAMETERS.DISTURBANCE.D_MAX = 1;
%     PARAMETERS.DISTURBANCE.DOT_D_MAX = 4;
else
    PARAMETERS.CONTROL.K1_STW = 2;
    PARAMETERS.CONTROL.K2_STW = 1;
    PARAMETERS.CONTROL.K3_STW = 1;
    PARAMETERS.CONTROL.MAX = 5;
    PARAMETERS.CONTROL.EPSILON = 2;
%     PARAMETERS.DISTURBANCE.D_MAX = 1;
%     PARAMETERS.DISTURBANCE.DOT_D_MAX = 4;
end
PARAMETERS.DISTURBANCE.D_MAX = 1;
PARAMETERS.DISTURBANCE.DOT_D_MAX = 4;

PARAMETERS.CONTROL.GAIN = 0.5;
if PARAMETERS.SIMULATION.NOISE_MODULE_DB > 0
  gain = (1-exp(-PARAMETERS.CONTROL.GAIN*PARAMETERS.SIMULATION.SAMPLING_TIME*PARAMETERS.SIMULATION.NOISE_MODULE_DB));
end
PARAMETERS.CONTROL.LAMBDA1 = PARAMETERS.CONTROL.LAMBDAS(PARAMETERS.SIMULATION.SAMPLING_TIME_INDEX); 
PARAMETERS.CONTROL.LAMBDA2 = PARAMETERS.CONTROL.LAMBDA1^2 / 4;
PARAMETERS.CONTROL.GAMMA = PARAMETERS.CONTROL.GAMMAS(PARAMETERS.SIMULATION.SAMPLING_TIME_INDEX); %/(PARAMETERS.SIMULATION.SAMPLING_TIME);
PARAMETERS.CONTROL.CHI1 = 3;
PARAMETERS.CONTROL.CHI2 = 1;
PARAMETERS.CONTROL.P1 = (PARAMETERS.CONTROL.LAMBDA2 + 1) / (2*PARAMETERS.CONTROL.LAMBDA1);
PARAMETERS.CONTROL.P2 = (PARAMETERS.CONTROL.LAMBDA1^2 + PARAMETERS.CONTROL.LAMBDA2 + 1) / (2*PARAMETERS.CONTROL.LAMBDA1*PARAMETERS.CONTROL.LAMBDA2);
PARAMETERS.CONTROL.P3 = (4*PARAMETERS.CONTROL.P2*PARAMETERS.CONTROL.P1-1)/(4*PARAMETERS.CONTROL.P2);

% PARAMETERS.CONTROL.K1_old = PARAMETERS.CONTROL.GAIN*((1/PARAMETERS.SIMULATION.SAMPLING_TIME) - PARAMETERS.CONTROL.LAMBDA1)/PARAMETERS.CONTROL.GAMMA;
PARAMETERS.CONTROL.K1 = ((1/(2*PARAMETERS.SIMULATION.SAMPLING_TIME)) - PARAMETERS.CONTROL.LAMBDA1)/PARAMETERS.CONTROL.GAMMA;
PARAMETERS.CONTROL.XI = sqrt(2)*max([0.5, PARAMETERS.CONTROL.P2]); 
PARAMETERS.DISTURBANCE.DOT_D_MAX_DELTA = sqrt(PARAMETERS.CONTROL.K1/2)*(1/PARAMETERS.CONTROL.XI);

PARAMETERS.CONTROL.K3 = 2*PARAMETERS.CONTROL.P3;
PARAMETERS.CONTROL.DELTA = sqrt(1/PARAMETERS.CONTROL.GAMMA);
PARAMETERS.CONTROL.MU = sqrt(5/2)*(1/PARAMETERS.CONTROL.GAMMA);
PARAMETERS.CONTROL.RHO = tanh(PARAMETERS.CONTROL.GAMMA*PARAMETERS.CONTROL.MU )/PARAMETERS.CONTROL.MU;
PARAMETERS.CONTROL.NU = (1/(PARAMETERS.CONTROL.DELTA + (1-PARAMETERS.CONTROL.DELTA)*PARAMETERS.CONTROL.RHO))^(1/(1-PARAMETERS.CONTROL.DELTA));
PARAMETERS.CONTROL.ALFA = max(PARAMETERS.CONTROL.MU, PARAMETERS.CONTROL.NU);
% PARAMETERS.CONTROL.K2_MAX_old = PARAMETERS.CONTROL.GAIN*((1/PARAMETERS.SIMULATION.SAMPLING_TIME^2) - PARAMETERS.CONTROL.LAMBDA2)/PARAMETERS.CONTROL.GAMMA;
PARAMETERS.CONTROL.K2_MAX = ((1/(2*PARAMETERS.SIMULATION.SAMPLING_TIME^2)) - PARAMETERS.CONTROL.LAMBDA2)/PARAMETERS.CONTROL.GAMMA;
PARAMETERS.CONTROL.MIN_TAU_1 = 1 / (PARAMETERS.CONTROL.LAMBDA1 + PARAMETERS.CONTROL.K1*PARAMETERS.CONTROL.GAMMA);
PARAMETERS.CONTROL.MIN_TAU_2 = sqrt(1 / (PARAMETERS.CONTROL.LAMBDA2 + PARAMETERS.CONTROL.K2_MAX*PARAMETERS.CONTROL.GAMMA));

simulation_time = 0:PARAMETERS.SIMULATION.SAMPLING_TIME:PARAMETERS.SIMULATION.TOTAL_TIME;
PARAMETERS.SIMULATION.TOTAL_STEPS = size(simulation_time, 2);
SIMULATION_DATA = run_simulation(PARAMETERS);
plot_simulation(SIMULATION_DATA, PARAMETERS);
PARAMETERS.CONTROL
PARAMETERS.SIMULATION
PARAMETERS.DISTURBANCE