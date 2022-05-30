function [y_n] = allpass(x_n, Fs, f_c)
%ALLPASS Summary of this function goes here
%   Detailed explanation goes here
T = 1 / Fs;

w_b = laplace_f_warp(f_c, Fs);

x = w_b / (2 / T);

coeff_1 = (1 - x) / (1 + x); 
coeff_2 = (-x - 1) / (1 + x);
coeff_3 = (x - 1) / (1 + x);

A = [coeff_1, coeff_2];
B = [1, coeff_3];

y_n = filter(A, B, x_n);


end

