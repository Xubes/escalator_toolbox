%Implements a basic pretest/practice/posttest design. Pretest trials are
%judgments, practice trials are used to estimate the affordance function,
%and posttest trials are judgments, similar to Experiment 3 in Franchak &
%Adolph (2014) APP. Determine whether the particular sub block procedure
%used yields similar results when simulating data with the same
%pretest/posttest errors as Franchak & Adolph (2014). Simulate running 30
%participants with true afordance thresholds of M = 28, SD = 2. Simulate
%pretest judgments that erred by M = 10.5 cm SD = 6.5 and posttest
%judgments that erred by 0.5 cm = SD 3. 
clear all 

out_dir = pwd; %Set the directory to save the file to
stim_levels = 15:0.5:65; %Set an array of stimulus levels
save_figs = false; %Choose whether or not to save figures after each trial block

% SUB BLOCKS FOR JUDGMENT TRIALS
%Create a binary search subblock
block1 = createBinaryBlock(1, false); 
%Create a blocked subblock with trials relative to the threshold estimate,
%repeat the block three times and randomize the trial order
block2 = createBlockedBlock(-8:2:8,'rel',true,3, true); 
%Arrange the sub blocks in order into a single sub_block cell array
sub_blocks_judgment = {block1; block2};

% SUB BLOCKS FOR PRACTICE TRIALS
%Create a binary search subblock
block1 = createStaircaseBlock(35,4,3,20,true); 
sub_blocks_practice = {block1};

%Create arrays of true parameters for participants for simulation
n_participants = 30;
threshold_aff = 28 + 2 .* randn(n_participants,1);
slope_aff = .5; %fix the slope to a small value
threshold_pre = threshold_aff + 10.5 + 6.5 .* randn(n_participants,1);
threshold_pst = threshold_aff + .5 + 3 .* randn(n_participants,1);
slope_judgement = 1.5; %Fix judgment slopes to 1.5 (ignoring change in judgment variability)

%Loop through each simulated participant and run the experiment, saving
%data to output arrays for pretest, affordance, and posttest
for i = 1:n_participants
    disp(sprintf('Simulating participant %d of %d', i, n_participants));
    output_pre(i) = trialBlock(out_dir, num2str(i), 'pretest', stim_levels, sub_blocks_judgment, save_figs, threshold_pre(i), slope_judgement);
    output_aff(i) = trialBlock(out_dir, num2str(i), 'affordance', stim_levels, sub_blocks_practice, save_figs, threshold_aff(i), slope_aff);
    output_pst(i) = trialBlock(out_dir, num2str(i), 'posttest', stim_levels, sub_blocks_judgment, save_figs, threshold_pst(i), slope_judgement);
end

clf
error_pre = [output_pre.threshold] - [output_aff.threshold]; %calculate the pretest error
error_pst = [output_pst.threshold] - [output_aff.threshold]; %calculate the posttest error
plot(zeros(n_participants,1) + 1, error_pre, 'ro','MarkerSize',4); %plot the individual pretest errors
hold on
plot(zeros(n_participants,1) + 3, error_pst, 'ro','MarkerSize',4); %plot the individual posttest errors
plot([.75 1.25], [mean(error_pre) mean(error_pre)],'k','LineWidth',2) %plot the mean pretest error
plot([2.75 3.25], [mean(error_pst) mean(error_pst)],'k','LineWidth',2) %plot the mean posttest error

[rejectH, pval, CI, stats] = ttest(error_pre, error_pst); %run a paired t test comparing pretest and posttest error
stats
pval