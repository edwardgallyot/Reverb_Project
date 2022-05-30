% Data read as (sample, channel)

[x_n, Fs] = audioread("Violin.wav");

x_n = x_n(:, 1);

x_n = x_n;

x_n = padarray(x_n, 44100 * 5, 0, 'post');

N = length(x_n);

% Create a Delay Buffer 
delayBuffer = zeros(1000000, 1);
delayBufferLength = length(delayBuffer);

% Set the Number of Channels
delayTime = 10;
N_Ch = 8;
 
% Create a 2D Circular Buffer
multi = repmat(delayBuffer, 1, N_Ch);

% Decide some Feedback Coefficients
[B, A] = allpass_coeff(1000, Fs);

% Make some 1D Parameters
readPosition = delayBufferLength - delayTime;
writePosition = 1;

% Make them 2D with the 
readPositions = repmat(readPosition, 1, 8);
writePositions = repmat(writePosition, 1, 8);

delayTimes = [10, 20, 30, 40, 50, 60, 70, 80];

delayTimes = linspace(10, 145, 8)

delayTimes = (delayTimes) .* (44.1);

for i = 1:length(readPositions)
    readPositions(i) = mod(delayBufferLength - delayTimes(i), delayBufferLength -1); 
end

% Create 2D and 1D outputs
y = zeros(N, N_Ch);
y_n = zeros(N, 1);

diffusion_steps = 6;

eveness_factor = 1.1;

multiplier = 1;

for j = 1:diffusion_steps   
    % Reset the circular Buffer for each diffusion step 
    readPositions = repmat(readPosition, 1, 8);
    writePositions = repmat(writePosition, 1, 8);
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
            [B, A] = allpass_coeff(5000, Fs);
            % Getting the input sample
            x = x_n(i);
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
    
    % Mixing the hadamard delay lines to a mono output
    for i = 1:N
        out = sum(hadamard_lines(i)) * (1 / sqrt(8));
        y_n(i) = y_n(i) + out;
    end

    x_n = y_n .* 0.4;
end




audiowrite("DiffuseDemo_Violin_1.1_6Steps_80ms.wav", y_n, Fs);