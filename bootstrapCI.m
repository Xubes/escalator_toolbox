function [output] = bootstrapCI(varargin)
%Parametric bootstrap using Palamedes function
%PAL_PFML_BootstrapParametric. Based on the proportion of positive
%responses at each unit and the number of trials at each unit, data will be
%randomly simulated from psychometric function and refit for a specified
%number of Monte Carlo iterations. Each simulation will then be refit to
%create a large array of simulated threshold and slope parameters.
%Confidence intervals for the threshold and slope are calculated from these
%samples, as well as boostrapped estimates for the threshold and slope (and
%the standard deviations of those estimates). There are two possible input
%options.

%INPUT OPTION 1: struct object from trialBlock
% boostrapCI(output_struct, iterations)
% REQUIRED INPUT:
%   - output_struct = struct resulting from a trialBlock function
%   - iterations = the number of Monte Carlo iterations to perform.
%   Reasonable estimates can usually be drawn from 500-1000 iterations.
%   Increasing the number of iterations will drastically increase
%   processing time. 

%INPUT OPTION 2: multiple variables 
% boostrapCI(trial_unit, trial_response, stim_levels, iterations)
%REQUIRED INPUT:
%   - trial_unit = array of trial units presented in the study
%   - trial_resp = array of responses (1 = positive, 0 = negative)
%   corresponding to each the trial units in trial_unit
%   - stim_levels = array of all possible units used in the study
%   - iterations = the number of Monte Carlo iterations to perform.
%   Reasonable estimates can usually be drawn from 500-1000 iterations.
%   Increasing the number of iterations will drastically increase
%   processing time. 

%OUTPUT:
%All simulated values are output into a single output struct with the
%following fields:
%   - output.threshold_sim = mean of all simulated threshold parameters
%   - output.slope_sim = mean of all simulated slope parameters
%   - output.threshold_sd = standard deviation of simulated thresholds
%   - output.slope_sd = standard deviation of simulated slopes
%   - output.threshold_CI5 = 5% confidence boundary for the threshold
%   - output.threshold_CI95 = 95% confidnce boundary for the threshold
%   - output.slope_CI5 = 5% confidence boundary for the slope
%   - output.slope_CI95 = 95% confidence boudnary for the slope
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
elseif length(varargin) == 4
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
    [SD, paramsSim, ~, converged] = PAL_PFML_BootstrapParametric(STIM, N, paramsValues, [1 1 0 0], iterations, @PAL_CumulativeNormal, 'searchGrid', searchGrid);
    muSim = sort(paramsSim(:,1));
    sigSim = sort(1./paramsSim(:,2));
    output.threshold_sim = mean(muSim);
    output.slope_sim = mean(sigSim);
    output.threshold_sd = SD(1);
    output.slope_sd = 1./SD(2);
    output.threshold_CI5 = muSim(floor(iterations * .05));
    output.threshold_CI95 = muSim(floor(iterations * .95));
    output.slope_CI5 = sigSim(floor(iterations * .05));
    output.slope_CI95 = sigSim(floor(iterations * .95));
    output.prop_converged = sum(converged)./iterations;

end
