function output = fitPsych(varargin)
%Fit cumulative Gaussian psychometric function using Palamedes function
%PAL_PFML_Fit. Two possible input options:
%INPUT OPTION 1: Output struct from trialBlock
% fitPsych(output_struct)
%REQUIRED INPUT:
%   - output_struct = output struct from trialBlock
%INPUT OPTION 2: Multiple variables
%REQUIRED INPUTS:
% fitPsych(trial_unit, trial_resp, stim_levels)
%   - trial_unit = array of trial units presented in the study
%   - trial_resp = array of responses (1 = positive, 0 = negative)
%   corresponding to each the trial units in trial_unit
%   - stim_levels = array of all possible units used in the study
%OUTPUT:
%   - output = struct with two values. output.threshold is the
%   threshold. output.slopw is the slope of the function (the inverse of
%   the beta paramter

if length(varargin) == 1
    output_data = varargin{1};
    trial_unit = output_data.trial_unit_fit;
    trial_resp = output_data.trial_resp_fit;
    stim_levels = output_data.stim_levels;
elseif length(varargin) == 3
    trial_unit = varargin{1};
    trial_resp = varargin{2};
    stim_levels = varargin{3};
else 
    disp('Incorrect input arguments');
end

    searchGrid.alpha = stim_levels;
    searchGrid.beta = 10.^[-1:.1:2]; %#ok<NBRAK>
    searchGrid.gamma = 0;
    searchGrid.lambda = 0;           
    [STIM, HIT, N] = PAL_PFML_GroupTrialsbyX(trial_unit, trial_resp, ones(size(trial_resp)));
    [paramsValues] = PAL_PFML_Fit(STIM, HIT, N, searchGrid, [1 1 0 0 ], @PAL_CumulativeNormal);
    
    output.threshold = paramsValues(1);
    output.slope = 1./paramsValues(2);
    output.trial_unit = trial_unit;
    output.trial_unit_fit = trial_unit;
    output.trial_resp = trial_resp;
    output.trial_resp_fit = trial_resp;
    output.id = '';
    output.condition = '';
end

