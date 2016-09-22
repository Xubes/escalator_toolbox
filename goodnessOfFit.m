function [output] = goodnessOfFit(varargin)
%Calculate goodness of fit after running a trialBlock. Takes the experiment
%results and calculates deviance using Palamedes Toolbox
%PAL_PFML_GoodnessOfFit. Goodness of fit uses model comparison between the
%model fit and a saturated model. Monte Carlo simulations compare the
%deviance of the model fit to resampled data to derive a p value. There are
%two different input options.
%
%INPUT OPTION 1: Output struct from trialBlock
%goodnessOfFit(output_struct)
%REQUIRED INPUT:
%   - output_struct = output struct from trialBlock
%
%INPUT OPTION 2: multiple variables 
% goodnessOfFit(trial_unit, trial_response, stim_levels, iterations)
%REQUIRED INPUT:
%   - trial_unit = array of trial units presented in the study
%   - trial_resp = array of responses (1 = positive, 0 = negative)
%   corresponding to each the trial units in trial_unit
%   - stim_levels = array of all possible units used in the study
%   - iterations = the number of Monte Carlo iterations to perform.
%   Reasonable estimates can usually be drawn from 500-1000 iterations.
%   Increasing the number of iterations will drastically increase
%   processing time. 
%
%OUTPUT
%Returns a single output struct with fields
%   - output.deviance = Deviance of fit 
%   - output.prop_deviance = PDev from PAL_PFML_GoodnessOfFit. Values < .05
%   are considered unacceptably poor fits. See Kingdom & Prins (2016)
%   _Psychophysics_ for more details on testing goodness of fit. 
%   - output.prop_converged = proportion of Monte Carlo iterations where
%   parameters were able to be fit to the data. If prop_converged is lower
%   than 1, confidence interval values (and the overall quality of the fit)
%   may be compromised. 

if length(varargin) == 2
    output_data = varargin{1};
    trial_unit = output_data.trial_unit_fit;
    trial_resp = output_data.trial_resp_fit;
    stim_levels = output_data.stim_levels;
    iterations = varargin{2};
elseif length(varargin) == 3
    trial_unit = varargin{1};
    trial_resp = varargin{2};
    stim_levels = varargin{3};
    iterations = varargin{4};
else 
    disp('Incorrect input arguments');
end
    searchGrid.alpha = stim_levels;
    searchGrid.beta = 10.^[-1:.1:2]; %#ok<NBRAK>
    searchGrid.gamma = 0;
    searchGrid.lambda = 0;
    
    [STIM, HIT, N] = PAL_PFML_GroupTrialsbyX(trial_unit, trial_resp, ones(size(trial_resp)));
    [paramsValues] = PAL_PFML_Fit(STIM, HIT, N, searchGrid, [1 1 0 0 ], @PAL_CumulativeNormal);
    [Dev, pDev, ~, converged] = PAL_PFML_GoodnessOfFit(STIM, HIT, N,paramsValues, [1 1 0 0], iterations, @PAL_CumulativeNormal);
    output.deviance = Dev;
    output.prop_dev = pDev;
    output.prop_converged = sum(converged) ./ iterations;
end
