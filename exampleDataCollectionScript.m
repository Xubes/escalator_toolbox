%Run a single experimental block of trials. Start with a staircase to find
%the threshold, then run trials -3 -2 -1 0 +1 +2 +3 relative to the
%threshold to get a better function estimate. Run a variety of
%post-processing functions to assess goodness of fit and confidence intervals
%for parameter estimates. Use the 'run section' option to execute each
%section of code separately to observe the results.

clear all
id = 'test'; %Set the participants' id name as a string
condition = 'test'; %Set the participants' condition as a string
out_dir = uigetdir(pwd,'Choose an output directory'); %Set the directory to save the file to
stim_levels = 15:0.5:65; %Set an array of stimulus levels
save_figs = true; %Choose whether or not to save figures after each trial block

%Create a staircased block that runs a 4-down/3-up staircase starting from
%30 and repeats for 25 trials
block1 = createStaircaseBlock(30, 4, 3, 25, true); 
%Create a blocked subblock with trials relative to the threshold estimate,
%repeat the block six times and randomize the trial order
block2 = createBlockedBlock(-3:1:3,'rel',true,6, true);

%Arrange the sub blocks in order into a single sub_block cell array
sub_blocks = {block1; block2};

%Run the trialBlock based on the above parameters and save the output
output = trialBlock(out_dir, id, condition, stim_levels, sub_blocks, save_figs);

%%
%Refit the slope and assign output to threshold and slope variables
[threshold, slope] = fitPsych(output);

%Graph the output as a psychometric function fitted to the data
psychometricFxGraph(output);
%%
%Assess goodness of fit of the output with 500 bootstrap iterations, save
%the results of the goodness of fit tests to fit_output
[fit_output] = goodnessOfFit(output, 400);
disp(fit_output);
%%
%Assess confidence intervals for the threshold and slope parameters by
%resampling 500 times. Save the output of those simulations to sim_output.
[sim_output] = bootstrapCI(output, 500);
disp(sim_output);
%%
%Graph the function fit relative to the 95% confidence interval for the
%threshold
clf
psychometricFxGraph(output); %Graph the psychometric function
hold on
x = min(stim_levels):.01:max(stim_levels);
y5 = normcdf(x, sim_output.threshold_CI5, output.slope);
y95 = normcdf(x, sim_output.threshold_CI95, output.slope);
plot(x, y5,'b') %Plot psychometric fx for the 5% CI threshold
plot(x, y95,'b') %Plot psychometric fx for the 95% CI threshold
hold off
