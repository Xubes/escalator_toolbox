function [unit] = findNearestUnit(stim_levels, val)
%Finds the nearest unit to val within the stimulus unit array stim_levels.
%If two units are equally close, one is randomly selected and returned in
%the unit object.

s = abs(stim_levels-val);
units = stim_levels(s == min(s));
if length(units) > 1
    i = randperm(length(units));
    unit = units(i(1));
else
    unit = units;
end