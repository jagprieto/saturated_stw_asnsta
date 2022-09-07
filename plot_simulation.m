
% Plot simulation 
function plot_simulation(SIMULATION_DATA, PARAMETERS)

    fig1 = figure(1);
    clf(fig1);
    subplot(3,1,1);
    plot(SIMULATION_DATA.STW(:,1), SIMULATION_DATA.REFERENCE - SIMULATION_DATA.STW(:,2),'-', 'Color', 'k', 'LineWidth',1.0);
    grid on;
    hold on;
    plot(SIMULATION_DATA.STW_SAT(:,1), SIMULATION_DATA.REFERENCE -SIMULATION_DATA.STW_SAT(:,2),'-', 'Color', 'b', 'LineWidth',1.0);
    plot(SIMULATION_DATA.ASNSTA1(:,1), SIMULATION_DATA.REFERENCE - SIMULATION_DATA.ASNSTA1(:,2),'-', 'Color', 'r', 'LineWidth',1.2);
    plot(SIMULATION_DATA.ASNSTA2(:,1), SIMULATION_DATA.REFERENCE - SIMULATION_DATA.ASNSTA2(:,2),'-', 'Color', 'm', 'LineWidth',1.2);
    ylabel('$\sigma(t)$', 'FontSize', PARAMETERS.PLOT.FONT_SIZE,'Interpreter','latex');
    xlabel('Time (s)', 'FontSize', PARAMETERS.PLOT.FONT_SIZE,'Interpreter','latex');
    title('Error', 'FontSize', PARAMETERS.PLOT.FONT_SIZE,'Interpreter','latex');
    xlim([0.0, PARAMETERS.SIMULATION.TOTAL_TIME]);
    legend_1 = 'STW';
    legend_2 = 'STW/SAT';
    legend_3 = strcat('ASNSTA ($\chi = ',num2str(PARAMETERS.CONTROL.CHI1), '$)');
    legend_4 = strcat('ASNSTA ($\chi = ',num2str(PARAMETERS.CONTROL.CHI2), '$)');
    legend({legend_1, legend_2, legend_3, legend_4}, 'Interpreter','latex');

    subplot(3,1,2);
    plot(SIMULATION_DATA.STW(:,1), SIMULATION_DATA.STW(:,3),'-', 'Color', 'k', 'LineWidth',1.0);
    grid on;
    hold on;
    plot(SIMULATION_DATA.STW_SAT(:,1), SIMULATION_DATA.STW_SAT(:,3),'-', 'Color', 'b', 'LineWidth',1.0);
    plot(SIMULATION_DATA.ASNSTA1(:,1), SIMULATION_DATA.ASNSTA1(:,3),'-', 'Color', 'r', 'LineWidth',1.2);
    plot(SIMULATION_DATA.ASNSTA2(:,1), SIMULATION_DATA.ASNSTA2(:,3),'-', 'Color', 'm', 'LineWidth',1.2);
    plot([0,PARAMETERS.SIMULATION.TOTAL_TIME], [PARAMETERS.CONTROL.MAX,PARAMETERS.CONTROL.MAX],'--', 'Color', 'g', 'LineWidth',2.5);
    plot([0,PARAMETERS.SIMULATION.TOTAL_TIME], [-PARAMETERS.CONTROL.MAX,-PARAMETERS.CONTROL.MAX],'--', 'Color', 'g', 'LineWidth',2.5);
    ylabel('$u(t)$', 'FontSize', PARAMETERS.PLOT.FONT_SIZE,'Interpreter','latex');
    xlabel('Time (s)', 'FontSize', PARAMETERS.PLOT.FONT_SIZE,'Interpreter','latex');
    title('Control', 'FontSize', PARAMETERS.PLOT.FONT_SIZE,'Interpreter','latex');
    xlim([0.0, PARAMETERS.SIMULATION.TOTAL_TIME]);
    ylim([-1.2*PARAMETERS.CONTROL.MAX,1.2*PARAMETERS.CONTROL.MAX]);
    
    subplot(3,3,7);
    plot(SIMULATION_DATA.STW(:,1), SIMULATION_DATA.STW(:,2),'-', 'Color', 'k', 'LineWidth',1.0);
    grid on;
    hold on;
    plot(SIMULATION_DATA.STW_SAT(:,1), SIMULATION_DATA.REFERENCE - SIMULATION_DATA.STW_SAT(:,2),'-', 'Color', 'b', 'LineWidth',1.0);
    plot(SIMULATION_DATA.ASNSTA1(:,1), SIMULATION_DATA.REFERENCE - SIMULATION_DATA.ASNSTA1(:,2),'-', 'Color', 'r', 'LineWidth',1.2);
    plot(SIMULATION_DATA.ASNSTA2(:,1), SIMULATION_DATA.REFERENCE - SIMULATION_DATA.ASNSTA2(:,2),'-', 'Color', 'm', 'LineWidth',1.2);
    ylabel('$\sigma(t)$', 'FontSize', PARAMETERS.PLOT.FONT_SIZE,'Interpreter','latex');
    xlabel('Time (s)', 'FontSize', PARAMETERS.PLOT.FONT_SIZE,'Interpreter','latex');
    if PARAMETERS.SIMULATION.SCENARIO == 1
        title('Error detail for $t \in [3.5,5.5]$', 'FontSize', PARAMETERS.PLOT.FONT_SIZE,'Interpreter','latex');
        xlim([3.5,5.5]);
    elseif PARAMETERS.SIMULATION.SCENARIO == 2
        title('Error detail for $t \in [6,10]$', 'FontSize', PARAMETERS.PLOT.FONT_SIZE,'Interpreter','latex');
        xlim([6, 10]);
    elseif PARAMETERS.SIMULATION.SCENARIO == 3
        title('Error detail for $t \in [4,7]$', 'FontSize', PARAMETERS.PLOT.FONT_SIZE,'Interpreter','latex');
        xlim([4, 7]);
     else
        title('Error detail for $t \in [6, 10]$', 'FontSize', PARAMETERS.PLOT.FONT_SIZE,'Interpreter','latex');
        xlim([6, 10]);
    end

    subplot(3,3,8);
    plot(SIMULATION_DATA.STW_SAT(:,1), SIMULATION_DATA.REFERENCE - SIMULATION_DATA.STW_SAT(:,2),'-', 'Color', 'b', 'LineWidth',1.0);
    grid on;
    hold on;
    plot(SIMULATION_DATA.ASNSTA1(:,1), SIMULATION_DATA.REFERENCE - SIMULATION_DATA.ASNSTA1(:,2),'-', 'Color', 'r', 'LineWidth',1.2);
    plot(SIMULATION_DATA.ASNSTA2(:,1), SIMULATION_DATA.REFERENCE - SIMULATION_DATA.ASNSTA2(:,2),'-', 'Color', 'm', 'LineWidth',1.2);
    plot(SIMULATION_DATA.STW(:,1), SIMULATION_DATA.REFERENCE - SIMULATION_DATA.STW(:,2),'-', 'Color', 'k', 'LineWidth',1.0);
    plot([0,PARAMETERS.SIMULATION.TOTAL_TIME], [-PARAMETERS.CONTROL.ALFA,-PARAMETERS.CONTROL.ALFA],'--', 'Color', 'g', 'LineWidth',2.5);
    plot([0,PARAMETERS.SIMULATION.TOTAL_TIME], [PARAMETERS.CONTROL.ALFA,PARAMETERS.CONTROL.ALFA],'--', 'Color', 'g', 'LineWidth',2.5);
    
    ylabel('$\sigma(t)$', 'FontSize', PARAMETERS.PLOT.FONT_SIZE,'Interpreter','latex');
    xlabel('Time (s)', 'FontSize', PARAMETERS.PLOT.FONT_SIZE,'Interpreter','latex');
    title('Error detail', 'FontSize', PARAMETERS.PLOT.FONT_SIZE,'Interpreter','latex');
    
    if PARAMETERS.SIMULATION.SCENARIO == 1
        xlim([PARAMETERS.SIMULATION.TOTAL_TIME-0.5, PARAMETERS.SIMULATION.TOTAL_TIME]);
    elseif PARAMETERS.SIMULATION.SCENARIO == 2
        xlim([PARAMETERS.SIMULATION.TOTAL_TIME-0.5, PARAMETERS.SIMULATION.TOTAL_TIME]);
    else
        xlim([PARAMETERS.SIMULATION.TOTAL_TIME-0.5, PARAMETERS.SIMULATION.TOTAL_TIME]);
    end

    
    subplot(3,3,9);
    plot(SIMULATION_DATA.STW(:,1), SIMULATION_DATA.STW(:,3),'-', 'Color', 'k', 'LineWidth',1.0);
    grid on;
    hold on;
    plot(SIMULATION_DATA.STW_SAT(:,1), SIMULATION_DATA.STW_SAT(:,3),'-', 'Color', 'b', 'LineWidth',1.0);
    plot(SIMULATION_DATA.ASNSTA1(:,1), SIMULATION_DATA.ASNSTA1(:,3),'-', 'Color', 'r', 'LineWidth',1.2);
    plot(SIMULATION_DATA.ASNSTA2(:,1), SIMULATION_DATA.ASNSTA2(:,3),'-', 'Color', 'm', 'LineWidth',1.2);
    ylabel('$u(t)$', 'FontSize', PARAMETERS.PLOT.FONT_SIZE,'Interpreter','latex');
    xlabel('Time (s)', 'FontSize', PARAMETERS.PLOT.FONT_SIZE,'Interpreter','latex');
    title('Control detail', 'FontSize', PARAMETERS.PLOT.FONT_SIZE,'Interpreter','latex');
    
    if PARAMETERS.SIMULATION.SCENARIO == 1
        title('Control detail for $t \in [3.5,5.5]$', 'FontSize', PARAMETERS.PLOT.FONT_SIZE,'Interpreter','latex');
        xlim([3.5,5.5]);
    elseif PARAMETERS.SIMULATION.SCENARIO == 2
        title('Control detail for $t \in [6,10]$', 'FontSize', PARAMETERS.PLOT.FONT_SIZE,'Interpreter','latex');
        xlim([6,10]);
    elseif PARAMETERS.SIMULATION.SCENARIO == 3
        title('Control detail for $t \in [4,7]$', 'FontSize', PARAMETERS.PLOT.FONT_SIZE,'Interpreter','latex');
        xlim([4,7]);
    else
        title('Control detail for $t \in [6,10]$', 'FontSize', PARAMETERS.PLOT.FONT_SIZE,'Interpreter','latex');
        xlim([6,10]);
    end
    
    if PARAMETERS.PLOT.CREATE_PDF
        graph_file_path = strcat('../MANUSCRIPT/GRAPHICS/scenario_', num2str(PARAMETERS.SIMULATION.SCENARIO),'_state_and_control_tau_',num2str(PARAMETERS.SIMULATION.SAMPLING_TIME_INDEX),'.pdf')
        export_fig(graph_file_path, '-transparent', '-nocrop');
    end
    
    fig2 = figure(2);
    clf(fig2);
    subplot(2,1,1);
    plot(SIMULATION_DATA.ASNSTA1(:,1), SIMULATION_DATA.ASNSTA1(:,4),'-', 'Color', 'r', 'LineWidth',2.0);    
    grid on;
    hold on; 
    xlim([0.0, PARAMETERS.SIMULATION.TOTAL_TIME]);  
    ylabel('$d(t)$', 'FontSize', PARAMETERS.PLOT.FONT_SIZE,'Interpreter','latex');
    xlabel('Time (s)', 'FontSize', PARAMETERS.PLOT.FONT_SIZE,'Interpreter','latex');
    title('Disturbance', 'FontSize', PARAMETERS.PLOT.FONT_SIZE,'Interpreter','latex');
     
    subplot(2,1,2);
    plot(SIMULATION_DATA.ASNSTA1(:,1), SIMULATION_DATA.ASNSTA1_K2(:,1),'-', 'Color', 'r', 'LineWidth',1.2);    
    grid on;
    hold on;
    plot(SIMULATION_DATA.ASNSTA2(:,1), SIMULATION_DATA.ASNSTA2_K2(:,1),'-', 'Color', 'm', 'LineWidth',1.2);    
    xlim([0.0, PARAMETERS.SIMULATION.TOTAL_TIME]);
    ylabel('$k_2(\sigma)$', 'FontSize', PARAMETERS.PLOT.FONT_SIZE,'Interpreter','latex');
    xlabel('Time (s)', 'FontSize', PARAMETERS.PLOT.FONT_SIZE,'Interpreter','latex');
    title('Parameter $k_2$', 'FontSize', PARAMETERS.PLOT.FONT_SIZE,'Interpreter','latex');
    
    if PARAMETERS.PLOT.CREATE_PDF
        graph_file_path = strcat('../MANUSCRIPT/GRAPHICS/scenario_', num2str(PARAMETERS.SIMULATION.SCENARIO),'_disturbance_estimation_tau_',num2str(PARAMETERS.SIMULATION.SAMPLING_TIME_INDEX),'.pdf')
        export_fig(graph_file_path, '-transparent', '-nocrop');
    end
    
end

