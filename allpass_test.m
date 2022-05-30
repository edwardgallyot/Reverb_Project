Fs = 44100;

T = 1 / Fs;

f_c = 1000;

w_b = laplace_f_warp(f_c, Fs);

x = w_b / (2 / T);

coeff_1 = (1 - x) / (1 + x); 
coeff_2 = (-1 - x) / (1 + x);
coeff_3 = (x - 1) / (x + 1);

A = [coeff_1, coeff_2];

B = [1, coeff_3];

[hz, f] = freqz(A, B, 22050, Fs);

plot(f, 360/(2*pi)*angle(hz));

plot(f, abs(hz));

set(gca,'Xscale','log');


