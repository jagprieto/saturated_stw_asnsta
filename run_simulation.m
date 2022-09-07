function [SIMULATION_DATA, PARAMETERS] = run_simulation(PARAMETERS)
     
    % Prepare simulation data
    SIMULATION_DATA = {};
    SIMULATION_DATA.REFERENCE = zeros(PARAMETERS.SIMULATION.TOTAL_STEPS, 1);
    SIMULATION_DATA.STW = zeros(PARAMETERS.SIMULATION.TOTAL_STEPS, 5); % Time, state, control, disturbance, epsilon
    x_stw = PARAMETERS.SIMULATION.INITIAL_STATE;
    epsilon_stw = 0;
    SIMULATION_DATA.STW_SAT = zeros(PARAMETERS.SIMULATION.TOTAL_STEPS, 5); % Time, state, control, disturbance, epsilon
    x_stw_sat = PARAMETERS.SIMULATION.INITIAL_STATE;
    epsilon_stw_sat = 0;

    SIMULATION_DATA.ASNSTA1 = zeros(PARAMETERS.SIMULATION.TOTAL_STEPS, 6); % Time, state, control, disturbance, epsilon, omega_c
    SIMULATION_DATA.ASNSTA1_K2 = zeros(PARAMETERS.SIMULATION.TOTAL_STEPS, 1);
    x_asnsta1 = PARAMETERS.SIMULATION.INITIAL_STATE;
    epsilon_asnsta1 = 0;
    x_nom_asnsta1 = x_asnsta1;
    est_d_asnsta1 = 0;
    
    SIMULATION_DATA.ASNSTA2 = zeros(PARAMETERS.SIMULATION.TOTAL_STEPS, 6); % Time, state, control, disturbance, epsilon, omega_c
    SIMULATION_DATA.ASNSTA2_K2 = zeros(PARAMETERS.SIMULATION.TOTAL_STEPS, 1);
    x_asnsta2 = PARAMETERS.SIMULATION.INITIAL_STATE;
    epsilon_asnsta2 = 0;
    x_nom_asnsta2 = x_asnsta2;
    est_d_asnsta2 = 0;
    
    % Run simulation
    simulation_time = 0.0;
    step_reference_1 = ceil(PARAMETERS.SIMULATION.TOTAL_STEPS/3);
    step_reference_2 = ceil(2*PARAMETERS.SIMULATION.TOTAL_STEPS/3);
    step_disturbance = ceil(PARAMETERS.SIMULATION.TOTAL_STEPS/2);
    for simulation_step = 1:PARAMETERS.SIMULATION.TOTAL_STEPS
        
        % Reference
        if simulation_step < step_reference_1
            reference = 0;
        elseif simulation_step < step_reference_2
            reference = 1;
        else
            reference = -2;
        end
        SIMULATION_DATA.REFERENCE(simulation_step) = reference;
        
        % Disturbance
        if PARAMETERS.SIMULATION.SCENARIO == 1
            disturbance = 0;
        elseif PARAMETERS.SIMULATION.SCENARIO == 2
            disturbance = PARAMETERS.DISTURBANCE.D_MAX + function_sinusoidal_sum(PARAMETERS.DISTURBANCE.D_MAX, PARAMETERS.DISTURBANCE.DOT_D_MAX, simulation_time);
        elseif PARAMETERS.SIMULATION.SCENARIO == 3
            disturbance = PARAMETERS.DISTURBANCE.D_MAX + function_sinusoidal_sum(PARAMETERS.DISTURBANCE.D_MAX, PARAMETERS.DISTURBANCE.DOT_D_MAX, simulation_time);
        else
            disturbance = PARAMETERS.DISTURBANCE.D_MAX + function_sinusoidal_sum(PARAMETERS.DISTURBANCE.D_MAX, PARAMETERS.DISTURBANCE.DOT_D_MAX, simulation_time)*exp(-2.5*abs(cos(16.12*simulation_time - 0.52)));
        end        
        if simulation_step == step_disturbance
           PARAMETERS.DISTURBANCE.D_MAX = -PARAMETERS.DISTURBANCE.D_MAX;
        end


%         if simulation_step == step_reference_1
%             x_nom_asnsta1 = 1*x_asnsta1;
%             epsilon_asnsta1 = 0;
%         elseif simulation_step == step_reference_2
%             x_nom_asnsta1 = 1*x_asnsta1;
%             epsilon_asnsta1 = 0;
%         end


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %---------------------------------------------------------------------------------------------------------------------% 
        %------------------------------------------------------ STW ----------------------------------------------------------% 
        %---------------------------------------------------------------------------------------------------------------------% 
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if PARAMETERS.SIMULATION.NOISE_MODULE_DB > 0
            noise_x_stw = awgn(x_stw , PARAMETERS.SIMULATION.NOISE_MODULE_DB, "measured");   
        else
            noise_x_stw = x_stw;
        end 
        e_stw = noise_x_stw - reference;
        dot_epsilon_stw = -PARAMETERS.CONTROL.K2_STW*sign(e_stw);
        epsilon_stw = epsilon_stw + dot_epsilon_stw*PARAMETERS.SIMULATION.SAMPLING_TIME;       
        control_stw = -PARAMETERS.CONTROL.K1_STW*sqrt(abs(e_stw))*sign(e_stw) + epsilon_stw;
        control_stw = function_sat(control_stw, PARAMETERS.CONTROL.MAX);
        SIMULATION_DATA.STW(simulation_step,:) = [simulation_time; x_stw; control_stw; disturbance; epsilon_stw];
        dot_x_stw = control_stw + disturbance;
        x_stw = x_stw + dot_x_stw*PARAMETERS.SIMULATION.SAMPLING_TIME;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %---------------------------------------------------------------------------------------------------------------------% 
        %----------------------------------------------- STW/SATURATED -------------------------------------------------------% 
        %---------------------------------------------------------------------------------------------------------------------% 
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if PARAMETERS.SIMULATION.NOISE_MODULE_DB > 0
            noise_x_stw_sat = awgn(x_stw_sat , PARAMETERS.SIMULATION.NOISE_MODULE_DB, "measured");   
        else
            noise_x_stw_sat = x_stw_sat;
        end
        e_stw_sat = noise_x_stw_sat - reference;
        dot_epsilon_stw_sat = -PARAMETERS.CONTROL.K2_STW*sign(e_stw_sat)-PARAMETERS.CONTROL.K3_STW*epsilon_stw_sat;
        epsilon_stw_sat = epsilon_stw_sat + dot_epsilon_stw_sat*PARAMETERS.SIMULATION.SAMPLING_TIME;
        control_stw_sat = -PARAMETERS.CONTROL.K1_STW*function_sat(sqrt(abs(e_stw_sat)), PARAMETERS.CONTROL.EPSILON)*sign(e_stw_sat) + epsilon_stw_sat;
        control_stw_sat = function_sat(control_stw_sat, PARAMETERS.CONTROL.MAX);
        SIMULATION_DATA.STW_SAT(simulation_step,:) = [simulation_time; x_stw_sat; control_stw_sat; disturbance; epsilon_stw_sat];
        dot_x_stw_sat = control_stw_sat + disturbance;
        x_stw_sat = x_stw_sat + dot_x_stw_sat*PARAMETERS.SIMULATION.SAMPLING_TIME;
   
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %---------------------------------------------------------------------------------------------------------------------% 
        %----------------------------------------------------- ASNSTA1 --------------------------------------------------------% 
        %---------------------------------------------------------------------------------------------------------------------% 
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Read ouput
        if PARAMETERS.SIMULATION.NOISE_MODULE_DB > 0
            noise_x_asnsta1 = awgn(x_asnsta1 , PARAMETERS.SIMULATION.NOISE_MODULE_DB, "measured");   
        else
            noise_x_asnsta1 = x_asnsta1;
        end
        
        % Update nominal reference model
        e_ref_asnsta1 = x_nom_asnsta1 - reference;        
        U = PARAMETERS.CONTROL.MAX - abs(est_d_asnsta1);
        dot_x_nom_asnsta1 = -U*tanh(PARAMETERS.CONTROL.CHI1*e_ref_asnsta1);
        x_nom_asnsta1 = x_nom_asnsta1 + dot_x_nom_asnsta1*PARAMETERS.SIMULATION.SAMPLING_TIME;
        
        % Trayectory error 
        z_asnsta1 = noise_x_asnsta1 - x_nom_asnsta1;
        if abs(z_asnsta1) > PARAMETERS.CONTROL.ALFA*0.5
            ASNSTA1_K2 = PARAMETERS.CONTROL.K1/(2*PARAMETERS.CONTROL.P2) + (PARAMETERS.CONTROL.K3/(PARAMETERS.CONTROL.P2*abs(tanh(PARAMETERS.CONTROL.GAMMA*z_asnsta1))));
        else
            ASNSTA1_K2 = PARAMETERS.CONTROL.K1/(2*PARAMETERS.CONTROL.P2);
        end
        ASNSTA1_K2 = function_sat(ASNSTA1_K2, PARAMETERS.CONTROL.K2_MAX); 
        SIMULATION_DATA.ASNSTA1_K2(simulation_step) = ASNSTA1_K2; 

        % Trayectory error control
        dot_epsilon_asnsta1 = PARAMETERS.CONTROL.LAMBDA2*z_asnsta1 + ASNSTA1_K2*tanh(PARAMETERS.CONTROL.GAMMA*z_asnsta1);
        epsilon_asnsta1 = epsilon_asnsta1 + dot_epsilon_asnsta1*PARAMETERS.SIMULATION.SAMPLING_TIME;
        est_d_asnsta1 = PARAMETERS.CONTROL.LAMBDA1*z_asnsta1 + PARAMETERS.CONTROL.K1*tanh(PARAMETERS.CONTROL.GAMMA*z_asnsta1) + epsilon_asnsta1;
        control_asnsta1 = dot_x_nom_asnsta1 - est_d_asnsta1;
        control_asnsta1 = function_sat(control_asnsta1, PARAMETERS.CONTROL.MAX);
        SIMULATION_DATA.ASNSTA1(simulation_step,:) = [simulation_time; x_asnsta1; control_asnsta1; disturbance; epsilon_asnsta1; est_d_asnsta1];
        dot_x_asnsta1 = control_asnsta1 + disturbance;
        x_asnsta1 = x_asnsta1 + dot_x_asnsta1*PARAMETERS.SIMULATION.SAMPLING_TIME;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %---------------------------------------------------------------------------------------------------------------------% 
        %----------------------------------------------------- ASNSTA2 --------------------------------------------------------% 
        %---------------------------------------------------------------------------------------------------------------------% 
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Read ouput
        if PARAMETERS.SIMULATION.NOISE_MODULE_DB > 0
            noise_x_asnsta2 = awgn(x_asnsta2 , PARAMETERS.SIMULATION.NOISE_MODULE_DB, "measured");   
        else
            noise_x_asnsta2 = x_asnsta2;
        end
        
        % Update nominal reference model
        e_ref_asnsta2 = x_nom_asnsta2 - reference;        
        U = PARAMETERS.CONTROL.MAX - abs(est_d_asnsta2);
        dot_x_nom_asnsta2 = -U*tanh(PARAMETERS.CONTROL.CHI2*e_ref_asnsta2);
        x_nom_asnsta2 = x_nom_asnsta2 + dot_x_nom_asnsta2*PARAMETERS.SIMULATION.SAMPLING_TIME;
        
        % Trayectory error 
        z_asnsta2 = noise_x_asnsta2 - x_nom_asnsta2;       
        if abs(z_asnsta2) > PARAMETERS.CONTROL.ALFA*0.5
            ASNSTA2_K2 = PARAMETERS.CONTROL.K1/(2*PARAMETERS.CONTROL.P2) + (PARAMETERS.CONTROL.K3/(PARAMETERS.CONTROL.P2*abs(tanh(PARAMETERS.CONTROL.GAMMA*z_asnsta2))));
        else
            ASNSTA2_K2 = PARAMETERS.CONTROL.K1/(2*PARAMETERS.CONTROL.P2);
        end
        ASNSTA2_K2 = function_sat(ASNSTA2_K2, PARAMETERS.CONTROL.K2_MAX); 
        SIMULATION_DATA.ASNSTA2_K2(simulation_step) = ASNSTA2_K2; 

        % Trayectory error control
        dot_epsilon_asnsta2 = PARAMETERS.CONTROL.LAMBDA2*z_asnsta2 + ASNSTA2_K2*tanh(PARAMETERS.CONTROL.GAMMA*z_asnsta2);
        epsilon_asnsta2 = epsilon_asnsta2 + dot_epsilon_asnsta2*PARAMETERS.SIMULATION.SAMPLING_TIME;
        est_d_asnsta2 = PARAMETERS.CONTROL.LAMBDA1*z_asnsta2 + PARAMETERS.CONTROL.K1*tanh(PARAMETERS.CONTROL.GAMMA*z_asnsta2) + epsilon_asnsta2;
        control_asnsta2 = dot_x_nom_asnsta2 - est_d_asnsta2;
        control_asnsta2 = function_sat(control_asnsta2, PARAMETERS.CONTROL.MAX);
        SIMULATION_DATA.ASNSTA2(simulation_step,:) = [simulation_time; x_asnsta2; control_asnsta2; disturbance; epsilon_asnsta2; est_d_asnsta2];
        dot_x_asnsta2 = control_asnsta2 + disturbance;
        x_asnsta2 = x_asnsta2 + dot_x_asnsta2*PARAMETERS.SIMULATION.SAMPLING_TIME;
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Update time
        simulation_time = simulation_time + PARAMETERS.SIMULATION.SAMPLING_TIME;
    end
end
        