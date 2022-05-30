N = length(y_n);

% Set the Number of Channels
delayTime = 10;
N_Ch = 8;


% Create a Delay Buffer 
delayBuffer = zeros(1000000, 1);
delayBufferLength = length(delayBuffer);

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

delayTimes = linspace(100, 400, 8)

delayTimes = (delayTimes) .* (44.1);

for i = 1:length(readPositions)
    readPositions(i) = mod(delayBufferLength - delayTimes(i), delayBufferLength -1); 
end

% y_n = zeros(N, 1);
multi_x = y_n;

diffusion_steps = 1; 

% Reset the circular Buffer for each diffusion step 
readPositions = repmat(readPosition, 1, 8);
writePositions = repmat(writePosition, 1, 8);
delayBuffer = zeros(1000000, 1);
multi = repmat(delayBuffer, 1, N_Ch);

% Modify Read Positions Based on Each steps Delay Times
for i = 1:length(readPositions)
    readPositions(i) = mod(delayBufferLength - delayTimes(i), delayBufferLength -1) + 1; 
end

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
        y(i, k) = z_M;%+ A(1)*x;  
        
        % Also write it to the circular buffer with the feedback
        multi(writePositions(k), k) = x + (0.8*z_M);

       
        % Update the 2D circular Buffers Positions
        readPositions(k) = mod(readPositions(k), delayBufferLength - 1) + 1;
        writePositions(k) = mod(writePositions(k), delayBufferLength - 1) + 1;
    end
end

multi_x = y;

y_n = multi_x;
z_n = zeros(N, 1);

for p = 1:N
    z_n(p) = sum(y_n(p, :));
end 

audiowrite("FeedBackNetwork.wav", z_n, Fs);