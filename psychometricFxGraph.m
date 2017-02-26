function fig = psychometricFxGraph(varargin) 
%Graph the psychometric function and the proportion of positive responses
%at each unit. The size of markers for proportion of responses reflects the
%number of trials conducted at that unit. Note, this function is designed
%to take different types of input. See description below for differen
%options.
%INPUT OPTION 1: Struct input, do not save graph file
% psychometricFxGraph(output_struct)
% REQUIRED INPUT :
%   - output_struct: a struct created by the trialBlock function passed
%   directly into the function.
%INPUT OPTION 2. Multiple input variables, do not save graph file
% psychometricFxGraph(id, condition, threshold, slope, trial_unit,
% trial_resp)
%REQUIRED INPUT:
%   - id = id of participant as a string
%   - condition = string containing condition name
%   - threshold = threshold of the estimated psychometric fx
%   - slope = slope of the estimated psychometric fx
%   - trial_unit = array of trial units presented in the study
%   - trial_resp = array of responses (1 = positive, 0 = negative)
%   corresponding to each the trial units in trial_unit
%INPUT OPTION 3. Multiple input variables, save graph file
% psychometricFxGraph(id, condition, threshold, slope, trial_unit,
% trial_resp, graph_file)
%REQUIRED INPUT:
%   - id = id of participant as a string
%   - condition = string containing condition name
%   - threshold = threshold of the estimated psychometric fx
%   - slope = slope of the estimated psychometric fx
%   - trial_unit = array of trial units presented in the study
%   - trial_resp = array of responses (1 = positive, 0 = negative)
%   corresponding to each the trial units in trial_unit
%   - graph_file = file path name for location to save figure as .eps (to
%   change output format, edit the 'saveas' line at the bottom of the file)
MARKER_MAX_SIZE = 100; % max size for trial unit markers
WINDOW_SIZE = 20;

if length(varargin) == 1
    output_data = varargin{1};
    id = output_data.id;
    condition = output_data.condition;
    mu_est = output_data.threshold;
    sigma_est = output_data.slope;
    trial_unit = output_data.trial_unit_fit;
    trial_resp = output_data.trial_resp_fit;
    save_figure = false;
elseif length(varargin) == 6
    id = varargin{1};
    condition = varargin{2};
    mu_est = varargin{3};
    sigma_est = varargin{4};
    trial_unit = varargin{5};
    trial_resp = varargin{6};
    save_figure = false;
elseif length(varargin) == 7
    id = varargin{1};
    condition = varargin{2};
    mu_est = varargin{3};
    sigma_est = varargin{4};
    trial_unit = varargin{5};
    trial_resp = varargin{6};
    graph_file = varargin{7};
    save_figure = true;
else 
    disp('Incorrect input arguments');
end

fig = figure();

[STIM, HIT, N] = PAL_PFML_GroupTrialsbyX(trial_unit, trial_resp, ones(size(trial_resp)));
succtrials = HIT;
totaltrials = N;

minx = min(STIM);%mu_est - WINDOW_SIZE;
maxx = max(STIM);%mu_est + WINDOW_SIZE;

x = minx:.01:maxx;
affmu = mu_est;
affsig = sigma_est;
affrate = succtrials ./ totaltrials;
afftrials = totaltrials;
afx = normcdf(x,affmu, affsig);

sumTrials = sum(afftrials);
trialScale = round(MARKER_MAX_SIZE * (afftrials ./ sumTrials));
plot(x, afx,'b','LineWidth',2);
axis([minx maxx -.01 1.01])
xlabel('Environment Unit');
ylabel('Prop. Positive Responses');
hold on
for i = 1:length(STIM)
    if not(isnan(affrate(i))) && trialScale(i) > 0
        markersize = trialScale(i);
        plot(STIM(i),affrate(i),'ro','LineWidth',2,'MarkerSize',markersize);
        title(sprintf('%s %s, mu: %3.1f, sig: %3.1f', id, condition, mu_est, sigma_est));
    end
end
hold off

if save_figure
   saveas(1, graph_file, 'epsc');
end