function [samples] = delayTimeToSamples(delayTime, sampleRate)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    samples = round((sampleRate / 1000) * delayTime);
end

