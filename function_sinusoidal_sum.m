function value = function_sinusoidal_sum(max_module, max_frequency, time)
%     k = 3;
    value = 0;
    alfas = [0.2, 0.3, 0.5];
    for i = 1:3
        value = value + alfas(i)*max_module*sin((max_frequency/(alfas(i)*max_module))*time);
    end
end