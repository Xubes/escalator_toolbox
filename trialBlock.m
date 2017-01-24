function output = trialBlock(out_dir, id, condition, stim_levels, sub_blocks, save_figs, threshold_actual, slope_actual)
%trialBlock function runs a block of trials to find a single threshold and
%slope for a single participant. User-specified sub blocks (defined using
%the supplied creation functions) allow for a variety of ways to present
%trials. At run time, user is prompted with a particular unit and indicates
%a positive responses by typing 'y' and negative reponses by typing 'n'.
%Typing 'exit' moves on to the next block before stopping criteria are met.
%REQUIRED INPUTS:
%   - out_dir = path to a file directory where text and graph files will be written
%   - id = participant id as a string, such as '1' or 'P1'
%   - condition = condition name as a string such as 'pretest' or 'affordance'
%   - stim_levels = array containing list of all units that can be used by
%   the binary search and staircase procedures, such as 0:2:100 or
%   15:.05:60. Stimulus levels must be ascending but need not be evenly
%   spaced. Note, if you specify absolute trial increments these can
%   override stim_levels
%   - sub_blocks = cell array of sub_block structs defined by the block
%   creation functions in the form {sub_block1, sub_block2, sub_block3}.
%   Note, if only a single block is used, the block must still be passed as
%   a cell array, e.g. {only_block}
%   - save_figs = 'true' or 'false' to save a graph of the function fit
%OPTIONAL INPUTS:
%If optional inputs threshold_actual and slope_actual are supplied, the
%trialBlock program will simulate the entire experiment based on an
%observer with the supplied parameters, allowing users to test the efficacy
%of different trial procedures
%   - threshold_actual: The true threshold of the simulated participant (numeric)
%   - slope_actual: The true slope of the simulated participant (numeric)
%OUTPUT:
%The program returns a single output struct containing with the fields
%below. This struct can be passed directly to bootstrapCI, fitPsych,
%goodnessOfFit, and psychometricFxGraph for further processing. Particular
%values can be accessed using dot notation (to access the threshold in
%output, type 'output.threshold'). 
%   - output.id = participant id
%   - output.condition = condition
%   - output.threshold = estimated threshold
%   - output.slope = estimated slope
%   - output.trial_unit = array of the trial units presented to the
%   participant in the order they appeared
%   - output.trial_unit_fit = array of trial units from blocks where
%   use_for_fit == true (used for final fits and graphs)
%   - output.trial_resp = participant's response at each trial (1 = 'y', 0
%   = 'no')
%   - output.trial_resp_fit = array of trial responses only from blocks where
%   use_for_fit == true (used for final fits and graphs)
%   - output.trial_mode = array listing the sub_block type for each trial
%   (%binary = 1, blocked = 2, staircase = 3, random = 4)
%   - output.trial_subblock = array listing the subblock that each trial
%   belonged to
%   - output.stim_levels = the stim_levels variable that was entered as an
%   input (preserved for post-processing)
%   - output.elapsed_time = the time (in seconds) that it took to run the
%   entire trial block

simulate = false;
rng('shuffle');

if nargin > 6
    simulate = true;
else 
    threshold_actual = 30; %Simulating arguments for code-testing purposes
    slope_actual = 2;
end

tic
addpath('Palamedes/')
addpath('Util/')

if ~simulate
    close all;
    clf;
    h = figure(1);
    set(h,'Position',[0,0,450,1000]);
end

outfile = strcat(out_dir,'/',id, '_', condition,'.csv');
graphfile = strcat(out_dir,'/',id, '_', condition,'.eps');

trial_unit = []; %array to keep track of presented trials
trial_resp = []; %array to keep track of trial responses (0 no/fail, 1 yes/succeed)
trial_mode = []; %binary = 1, blocked = 2, staircase = 3, random = 4
trial_subblock = []; %keep track of which block of trials
trial_num = 1;
first_block = true;

disp(sprintf('Starting trial block, condition = %s',condition));

%ITERATE THROUGH SUB BLOCKS
for b = 1:numel(sub_blocks)
    
    %Set loop conditions
    exit = false;
    block_i = 1; %Restart block counter
    if b == 2
        first_block = false;
    end
    
    %Turn mode into a numeric
    if strcmp(sub_blocks{b}.mode, 'binary')
        mode = 1;
    elseif strcmp(sub_blocks{b}.mode, 'blocked')
        mode = 2;
    elseif strcmp(sub_blocks{b}.mode, 'staircase')
        mode = 3;
    elseif strcmp(sub_blocks{b}.mode, 'random')
        mode = 4;
    else
        mode = 0;
    end
    
    disp(sprintf('Starting sub block %d of %d, %s', b, numel(sub_blocks), sub_blocks{b}.mode));
    
    %Assign staircase start unit based on preferences
    if strcmp(sub_blocks{b}.mode, 'staircase')        
        if isnan(sub_blocks{b}.start_unit)
            if first_block
                disp('Relative units cannot be calculated in block 1');
            else
                sub_blocks{b}.start_unit = findNearestUnit(stim_levels, mu_est);
            end
        end
    end
                
    %Assign blocked units based on prefs 
    if strcmp(sub_blocks{b}.mode, 'blocked')        
        if strcmp(sub_blocks{b}.abs_rel, 'rel')
            if first_block
                disp('Relative units cannot be calculated in block 1');
            else
                mu_block = findNearestUnit(stim_levels, mu_est);
                block = sub_blocks{b}.trial_unit + mu_block;
            end
        else
            block = sub_blocks{b}.trial_unit;
        end
        if sub_blocks{b}.randomized
            if sub_blocks{b}.repeats > 0
                block_temp = block;
                block = block(randperm(length(block)));
                for r = 1:sub_blocks{b}.repeats
                    block = [block block(randperm(length(block_temp)))];
                end
            else
                block = block(randperm(length(block)));
            end
        else
            if sub_blocks{b}.repeats > 0
                block_temp = block;
                for r = 1:sub_blocks{b}.repeats
                    block = [block block_temp];
                end
            end
        end
    end
                
    %Loop through trials until user chooses to exit or end of specified
    %blocks is reached
    while(~exit)        
        %Select next trial unit
        if strcmp(sub_blocks{b}.mode,'binary') %Start with largest and smallest, then binary search
            if trial_num == 1
                trial_unit(trial_num) = max(stim_levels); %#ok<*AGROW,*SAGROW>
                min_pos = length(stim_levels);
            elseif trial_num == 2
                trial_unit(trial_num) = min(stim_levels);
                max_neg = 1;
            else 
                trial_unit(trial_num) = stim_levels(round(mean([min_pos max_neg])));
            end
        elseif strcmp(sub_blocks{b}.mode, 'blocked')%Choose predefined trials from block
            trial_unit(trial_num) = block(block_i); 
        elseif strcmp(sub_blocks{b}.mode,'random') %Randomize units based on sigma
            if sigma_est >= 1.5 
                rand_unit = mu_est + randn(1,1).* sigma_est;
            else
                rand_unit = mu_est + randn(1,1).* 1.5;
            end
            trial_unit(trial_num) = findNearestUnit(stim_levels, rand_unit);
        elseif strcmp(sub_blocks{b}.mode, 'staircase') %staircase
            %Start at initial location, then staircase
            if block_i == 1
                trial_unit(trial_num) = findNearestUnit(stim_levels, sub_blocks{b}.start_unit);
            else
                step_size = stim_levels(2) - stim_levels(1);
                if trial_resp(trial_num - 1) == 1
                    trial_unit(trial_num) = findNearestUnit(stim_levels, trial_unit(trial_num-1) - step_size*sub_blocks{b}.down_step);                
                elseif trial_resp(trial_num - 1) == 0
                    trial_unit(trial_num) = findNearestUnit(stim_levels, trial_unit(trial_num-1) + step_size*sub_blocks{b}.up_step);
                end
            end
        end

        setGraphview(10,trial_resp, trial_unit, stim_levels, 0,'ro','b',id, condition);
        
        %Get user input unless simulating
        if ~simulate
            while(1)
                reply = input(sprintf('Trial #%d at %2.1f>> ',trial_num,trial_unit(trial_num)),'s');
                if strcmp(reply, 'exit')
                    exit = true;
                    break;
                elseif strcmp(reply, 'y')
                    trial_resp(trial_num) = 1;
                    trial_mode(trial_num) = mode;
                    trial_subblock(trial_num) = b;
                    break;
                elseif strcmp(reply, 'n')
                    trial_resp(trial_num) = 0;
                    trial_mode(trial_num) = mode;
                    trial_subblock(trial_num) = b;
                    break;
                elseif strcmp(reply, 's') %Simulation response for code-testing purposes only
                    trial_resp(trial_num) = rand(1,1) >= 1 - normcdf(trial_unit(trial_num),threshold_actual, slope_actual);
                    trial_mode(trial_num) = mode;
                    trial_subblock(trial_num) = b;
                    break;
                elseif strcmp(reply,'undo') %Not implemented
    %                 trial_num = trial_num - 1;
    %                 trial_unit = trial_unit(1:trial_num);
    %                 trial_resp = trial_resp(1:trial_num);
                elseif ~isempty(str2double(reply))
    %                 val = str2double(reply);
    %                 level = find(stim_levels == val);
    %                 if ~isempty(level)
    %                     trial_unit(trial_num) = stim_levels(level);
    %                     setGraphview(10,trial_resp, trial_unit, stim_levels, 0,'ro','b',id, condition);
    %                 end 
                else
                    disp('Input not recognized, please type y, n, or exit')
                end  
            end
        else %commands for simulation
            trial_resp(trial_num) = rand(1,1) >= 1 - normcdf(trial_unit(trial_num),threshold_actual, slope_actual);
            trial_mode(trial_num) = mode;
            trial_subblock(trial_num) = b;
        end
        
        %Update graphview, trial/block number, and parameter estimates
        block_i = block_i + 1;
        trial_num = trial_num + 1;
        if ~simulate
            [mu_est, sigma_est] = setGraphview(10,trial_resp, trial_unit, stim_levels, 1,'ro','b',id, condition);
            csvwrite(outfile, [trial_unit' trial_resp' trial_mode' trial_subblock']);
        end
        
        %Check if blocks are completed
        if strcmp(sub_blocks{b}.mode,'binary') && block_i > 3
            if trial_resp(trial_num-1) == 1
                min_pos = find(stim_levels == trial_unit(trial_num-1));
            elseif trial_resp(trial_num-1) == 0
                max_neg = find(stim_levels == trial_unit(trial_num-1));
            end
            if max_neg >= min_pos || abs(max_neg - min_pos) <= sub_blocks{b}.tolerance %Condition for stopping
                %Run a fit on the current data       
                paramsValues = fitPsych(trial_unit, trial_resp, stim_levels);
                mu_est = paramsValues(1);   
                break;
            end
        elseif strcmp(sub_blocks{b}.mode, 'blocked')
            if block_i > numel(block) 
                paramsValues = fitPsych(trial_unit, trial_resp, stim_levels);
                mu_est = paramsValues(1);   
                break;
            end
        elseif strcmp(sub_blocks{b}.mode,'random') 
            
        elseif strcmp(sub_blocks{b}.mode, 'staircase')
            if block_i > sub_blocks{b}.num_trials
                paramsValues = fitPsych(trial_unit, trial_resp, stim_levels);
                mu_est = paramsValues(1);   
                break;
            end
        elseif exit == true %Skip next section and exit 
            trial_unit = trial_unit(1:end-1); %Get rid of planned trial if exiting early
            break;
        end
    end
    
end

%After all sub blocks have been run, calculate final fit parameters, graph
%the fit, and save data to file

%select subset of data to use for fits
use_blocks = [];
for b = 1:numel(sub_blocks)
    if sub_blocks{b}.use_for_fit
        use_blocks = [use_blocks b];
    end
end
trial_unit_fit = trial_unit(ismember(trial_subblock,use_blocks));
trial_resp_fit = trial_resp(ismember(trial_subblock,use_blocks));

%final curve fits
paramsValues = fitPsych(trial_unit_fit, trial_resp_fit, stim_levels);
mu_est = paramsValues(1);
sigma_est = 1./paramsValues(2);

%compile output
output.id = id;
output.condition = condition;
output.threshold = mu_est;
output.slope = sigma_est;
output.trial_unit = trial_unit;
output.trial_unit_fit = trial_unit_fit;
output.trial_resp = trial_resp;
output.trial_resp_fit = trial_resp_fit;
output.trial_mode = trial_mode;
output.trial_subblock = trial_subblock;
output.stim_levels = stim_levels;
output.elapsed_time = toc;

%text and graph files
if ~simulate
    csvwrite(outfile, [trial_unit' trial_resp' trial_mode' trial_subblock']);
end
if save_figs 
    psychometricFxGraph(id, condition, mu_est, sigma_est, trial_unit_fit, trial_resp_fit, graphfile) 
end

disp('Completed trial block')
end
