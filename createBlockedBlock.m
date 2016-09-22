function output = createBlockedBlock(trial_unit, abs_rel, randomized, repeats, use_for_fit)
%Create a customized block of trials in 'blocked' mode. Blocked trials are
%preset based on the specified trial units (either absolute or relative to
%the current threshold estimate) and can be randomized or ordered. 
%REQUIRED INPUTS:
%   - trial_unit: an array with the list of trial units (e.g. for absolute
%   units, 20:5:40, [15 20 25 40 45 50], for relative units, -10:2:10 or
%   [-10 -5 0 5 10]). 0 refers to the current threshold estimate when in
%   relative mode. Units need not be evenly spaced. Note, absolute units
%   will be used as is, even if the specified units are not in the
%   stim_levels range. Relative units will find the nearest units in
%   stim_levels based on the current threshold estimate at the time the
%   block is started. 
%   - abs_rel = 'abs' for absolute mode, 'rel' for relative mode. Note,
%   relative mode cannot be used for the initial sub_block because there is
%   no current threshold estimate!
%   - randomized = 'true' to randomize the trials, 'false' to
%   keep them ordered. If false is selected, trials will be presented in
%   the order specified in trial_unit. 
%   - repeats = how many times to repeat the trials in trial_units. If 0,
%   trials will be presented once. If 1, trial_units will be presented two
%   times. If randomized is selected, each successive block will be
%   presented in a random order. 
%   - use_for_fit = if true, trials from this subblock will be used to
%   calculate slope and threshold parameters and will appear in the final
%   graph. If false, these trials will be ignored in calculations. 
%OUTPUT:
%   - output: a struct containing all of the specifications for the sub
%   block. The output object can be saved and stored in a cell array to
%   pass to the trialBlock function.

output.mode = 'blocked';
output.trial_unit = trial_unit;
output.abs_rel = abs_rel;
output.randomized = randomized;
output.repeats = repeats;
output.use_for_fit = use_for_fit;