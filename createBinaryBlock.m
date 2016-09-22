function output = createBinaryBlock(tolerance, use_for_fit)
%Create a customized block of trials in 'bianry' search mode. Binary search
%starts at the largest unit in stim_levels, then goes to the smallest unit,
%and then the midway point between them. Then the procedure continues to
%hone in on the threshold by presenting a trial midway between the smallest
%positive response and largest negative response. The block exits when
%either 1) the largest negative response is larger than the smallest
%positive response, or 2) the largest negative response is within a certain
%number of units away (according to tolerance). 
% See Franchak, van der Zalm, & Adolph (2010) Vision Research for more
% informaiton about the binary search procedure.
%REQUIRED INPUTS:
%   - tolerance = define the criterion for stopping the block based on how
%the largest negative and smallest positive responses can be. A tolerance
%of 1 means that the binary search will continue until successive trials
%are 1 unit apart; 5 would stop the procedure after successive trials are 5
%units apart. Using a smaller tolerance value will get a more accurate
%threshold measurement, but will present many consecutive trials at similar
%units.
%   - use_for_fit = if true, trials from this subblock will be used to
%calculate slope and threshold parameters and will appear in the final
%graph. If false, these trials will be ignored in calculations.
%OUTPUT:
%   - output: a struct containing all of the specifications for the sub
%block. The output object can be saved and stored in a cell array to pass
%to the trialBlock function.

output.mode = 'binary';
output.tolerance = tolerance;
output.use_for_fit = use_for_fit;