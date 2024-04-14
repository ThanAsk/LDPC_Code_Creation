function [l_degs, p_degs] = testLDPC(a, max_l_deg, max_p_deg)

l_degs = zeros(1, max_l_deg);
p_degs = zeros(1, max_p_deg);

for i = 1:max_l_deg
    l_degs(i) = sum(sum(a) == i);
end

for i = 1:max_p_deg
    p_degs(i) = sum(sum(a, 2) == i);
end