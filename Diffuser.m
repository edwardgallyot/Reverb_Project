function [y_n] = Diffuser(x_n, steps, time, stretch, lines)
%DIFFUSER Summary of this function goes here
%   time in ms
%   stretch between 0 and 10
%   steps between 1 and 8

% Convert input audio to mono for ease
x_n = x_n(:, 1);

% zero pad the array to account for diffuser tail
x_n = padarray(x_n, 44100 * 5, 0, 'post');

% Find the length of the zero padded array
N = length(x_n);

% Create a Delay Buffer 
delayBuffer = zeros(1000000, 1);
delayBufferLength = length(delayBuffer);

% Set the Number of Channels
delayTime = 10;
N_Ch = lines;
 
% Create a 2D Circular Buffer
multi = repmat(delayBuffer, 1, N_Ch);

% Make some 1D Parameters
readPosition = delayBufferLength - delayTime;
writePosition = 1;

% Make them 2D with the 
readPositions = repmat(readPosition, 1, N_Ch);
writePositions = repmat(writePosition, 1, N_Ch);

% Divide the delay times up across the diffusion length
delayTimes = linspace(10, time, N_Ch);

% Turn ms to samples
delayTimes = (delayTimes) .* (44.1);

% Modify the delay line read heads
for i = 1:length(readPositions)
    readPositions(i) = mod(delayBufferLength - delayTimes(i), delayBufferLength -1); 
end

% Create 2D and 1D outputs
y = zeros(N, N_Ch);
y_n = zeros(N, 1);

% Stretch the delay times across the diffusion steps
diffusion_steps = steps;
eveness_factor = 1 + ((stretch / 100));
multiplier = 1;

% Split input
multi_x = repmat(x_n, 1, N_Ch);

for j = 1:diffusion_steps   
    % Reset the circular Buffer for each diffusion step 
    readPositions = repmat(readPosition, 1, N_Ch);
    writePositions = repmat(writePosition, 1, N_Ch);
    delayBuffer = zeros(1000000, 1);
    multi = repmat(delayBuffer, 1, N_Ch);

    % Modify Delay Times over each step
    multiplier = multiplier * eveness_factor;
    delayTimes = delayTimes .* (multiplier);
    delayTimes = round(delayTimes);
    
    % Modify Read Positions Based on Each steps Delay Times
    for i = 1:length(readPositions)
        readPositions(i) = mod(delayBufferLength - delayTimes(i), delayBufferLength -1); 
    end

    % MultiChannel Output y
    y = zeros(N, N_Ch);

    for i = 1:N
        for k = 1:length(multi(1, :))
            % Getting the input sample
            x = multi_x(i, k);
            % Getting the delayed z^-m
            z_M = multi(readPositions(k), k); 
            
            % Write the input sample to the output
            y(i, k) = y(i, k) + z_M;  
            
            % Also write it to the circular buffer with the feedback
            multi(writePositions(k), k) = x;
            
            % Update the 2D circular Buffers Positions
            readPositions(k) = mod(readPositions(k), delayBufferLength - 1) + 1;
            writePositions(k) = mod(writePositions(k), delayBufferLength - 1) + 1;
        end
    end

    % Create the hadamard Mixing Matrix
    MM = hadamard(N_Ch);
    hadamard_lines = zeros(N, N_Ch);
    
    % Creating Hadamard Mixed Delay Lines
    for i = 1:N
        for k = 1:N_Ch
          for g = 1:N_Ch
              hadamard_lines(i, k) = hadamard_lines(i, k) +  (y(i, g) * MM(g, k));
          end
        end
    end

    % Shuffling
    hadamard_lines = hadamard_lines(:,randperm(N_Ch));

    % Some Inverted Polaritys
    for i = 1:N_Ch
        if randi(3) == 1
            hadamard_lines(:, i) = hadamard_lines(:, i) .* -1;
        end
    end


    multi_x = hadamard_lines .* (1 / sqrt(N_Ch));
end

y_n = multi_x;

end

