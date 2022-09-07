function value_sat = function_sat(value, max_value)
    value_sat = min(max_value, abs(value))*sign(value);
%     if abs(value) < max_value
%         value_sat = value;
%     else
%         value_sat = max_value*sign(value);
%     end
end