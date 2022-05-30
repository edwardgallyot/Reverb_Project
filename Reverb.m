clear;

[x_n, Fs] = audioread("Violin.wav");

x_n = x_n;

y_n = Diffuser(x_n, 4, 60, 10, 64);

z_n = y_n;

y_n = FeedbackNetwork(z_n, 213, 8.5, 64);

h_n = zeros(length(y_n), 1);

% Mixing the delay lines to a mono output
for i = 1:length(y_n)
    out = sum(y_n(i, :));
    h_n(i) = out;
end

% Mix should be between 0 and 1
mix = 0.5;

padding = length(h_n) - length(x_n);

x_n = padarray(x_n, padding, 0, 'post');

h_n = mix .* h_n + (1 - mix) .* x_n(:, 1);


audiowrite("Reverbed_Violin.wav", h_n, Fs);