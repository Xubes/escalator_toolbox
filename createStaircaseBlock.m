function output = createStaircaseBlock(start_unit, down_step, up_step, num_trials, use_for_fit)
%Create a customized block of trials in 'staircase' mode. The staircase
%will start at start_unit, and then decrease the unit by the number of
%down_steps for each positive response and increase the unit by up_steps
%after each negative response. The block will continue for a specified
%number of trials (num_trials). Step size is based on the difference
%between the first and second units in stim_levels. If stim_levels are not
%evenly spaced, staircasing may not produce the expected behavior.
%REQUIRED INPUTS:
%   - start_unit = the first unit used in the staircase (must be an
%   absolute value, not relative to threshold). start_unit will find the
%   nearest unit based on stim_levels. If the first unit used in a
%   staircase block is the current threshold estimate, enter NaN for start_unit.
%   - down_step = integer number of steps to decrease after a positive
%   response (e.g., if stim_levels = 10:.5:50, down_step = 3 would decrease
%   by 3 * .5 = 1.5 units). 
%   - up_step = integer number of steps to increase after a negative
%   response
%   - num_trials = number of staircase trials to present
%   - use_for_fit = if true, trials from this subblock will be used to
%calculate slope and threshold parameters and will appear in the final
%graph. If false, these trials will be ignored in calculations.
%OUTPUT:
%   - output: a struct containing all of the specifications for the sub
%block. The output object can be saved and stored in a cell array to pass
%to the trialBlock function.

output.mode = 'staircase';
output.start_unit = start_unit;
output.down_step = down_step;
output.up_step = up_step;
output.num_trials = num_trials;
output.use_for_fit = use_for_fit;