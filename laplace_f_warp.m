function [w_a] = laplace_f_warp(f, Fs)
%LAPLACE_F_WARP 
% Warps a normalised digital frequency for use in the f domain;
T = 1 / Fs;

w_d = 2 * pi * f;
w_a = (2 / T) * tan(w_d * (T/2));
end

