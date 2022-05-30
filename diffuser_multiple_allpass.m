% Data read as (sample, channel)

[x_n, Fs] = audioread("Finger_Snap.wav");

% Create a Delay Buffer 
delayBuffer = zeros(10000, 1);
delayBufferLength = length(delayBuffer);

% Set the Number of Channels
delayTime = 10;
N_Ch = 8;
 
% Create a 2D Circular Buffer
multi = repmat(delayBuffer, 1, N_Ch);

% Decide some Feedback Coefficients
[B, A] = allpass_coeff(2000, Fs);

% Make some 1D Parameters
readPosition = delayBufferLength - delayTime;
writePosition = 1;

% Make them 2D with the 
readPositions = repmat(readPosition, 1, 8);
writePositions = repmat(writePosition, 1, 8);

delayTimes = [10, 20, 40, 80, 160, 320, 640, 1280];

for i = 1:length(readPositions)
    readPositions(i) = delayBufferLength - delayTimes(i); 
end

% Create 2D and 1D outputs
y = zeros(length(x_n), N_Ch);
y_n = zeros(length(x_n), 1);

for i = 1:length(x_n)
    for k = 1:length(multi(1, :))
        % Getting the input sample
        x = x_n(i);
        % Getting the delayed z^-m
        z_M = multi(readPositions(k), k); 
        
        % Write the input sample to the output
        y(i, k) = A(1) * x + z_M;  
        
        % Also write it to the circular buffer with the feedback
        multi(writePositions(k), k) = x_n(i) + B(2) * y(i, k);
        
        % Update the 2D circular Buffers Positions
        readPositions(k) = mod(readPositions(k), delayBufferLength - 1) + 1;
        writePositions(k) = mod(writePositions(k), delayBufferLength - 1) + 1;
    end
end

% Summing the 8 channels
for i = 1:length(x_n)
    for k = 1:N_Ch
        y_n(i) = y_n(i) + (y(i, k) / 8); 
    end
end

audiowrite("MultipleAllPassFingerSnapEven.wav", y_n, Fs);