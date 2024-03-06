%  Color supplement
function color = getColor(idx,num)
    count =fix(num/3) + 1;
    g_count = fix((idx+2)/3);
    b_count = fix((idx+1)/3);
    r_count = fix(idx/3);
    color = [1-g_count/count,1-b_count/count,1-r_count/count];
end
