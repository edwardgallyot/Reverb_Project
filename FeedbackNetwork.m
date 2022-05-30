function [y_n] = FeedbackNetwork(x_n, time, size, lines)
%FEEDBACKNETWORK Summary of this function goes here
%   x_n should be a multi channel diffused signal
%   Fs is sample rate
%   time is the delay time in ms 100-1000
%   Size is the amount of feedback in the network 0-10

size = size / 11;

y_n = x_n;

N = length(y_n);

% Set the Number of Channels
delayTime = 10;
N_Ch = lines;


% Create a Delay Buffer 
delayBuffer = zeros(1000000, 1);
delayBufferLength = length(delayBuffer);

% Create a 2D Circular Buffer
multi = repmat(delayBuffer, 1, N_Ch);

% Make some 1D Parameters
readPosition = delayBufferLength - delayTime;
writePosition = 1;

% Make them 2D with the 
readPositions = repmat(readPosition, 1, N_Ch);
writePositions = repmat(writePosition, 1, N_Ch);

delayTimes = linspace(10, time, N_Ch);

delayTimes = (delayTimes) .* (44.1);

for i = 1:length(readPositions)
    readPositions(i) = mod(delayBufferLength - delayTimes(i), delayBufferLength -1); 
end

readPositions = round(readPositions);

multi_x = y_n;

% MultiChannel Output y
y = zeros(N, N_Ch);

for i = 1:N
    % Summing the Delay Lines with a House Holder Matrix
    housesum = 0;
    multiplier = -2 / N_Ch;
    for g = 1:N_Ch
          housesum = housesum + multi(readPositions(g), g);
    end
    housesum = housesum * multiplier;
    for g = 1:N_Ch
        multi(readPositions(g), g) = multi(readPositions(g),g) + housesum;
    end

    % Enter the Delay Lines for Each Sample
    for k = 1:length(multi(1, :))

        % Getting the input sample
        x = multi_x(i, k);
        % Getting the delayed z^-m
        z_M = multi(readPositions(k), k); 
        
        % Write the input sample to the output
        y(i, k) = z_M;
        
        % Also write it to the circular buffer with the feedback
        multi(writePositions(k), k) = x + (size*z_M);

        % Update the 2D circular Buffers Positions
        readPositions(k) = mod(readPositions(k), delayBufferLength - 1) + 1;
        writePositions(k) = mod(writePositions(k), delayBufferLength - 1) + 1;
    end
end

multi_x = y;

y_n = multi_x;
end

