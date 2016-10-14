function [output] = methodOfAdjustment(out_dir, id, condition,num_trials, start_dir, write_file, stim_levels, threshold_actual, slope_actual)
%Start_dir 1 equals ascending, start_dir 0 equals descending
%Can exit prematurely, responses will be length of actual judgments
%collected
if nargin == 6
    disp(sprintf('Starting method of adjustment block, condition = %s',condition));
    outfile = strcat(out_dir,'/',id, '_', condition,'.csv');
    trial_num = 1;

    while(1)
        %Alternate MOA direction
        if mod(trial_num,2) == start_dir
            direction = 'ascending';
        else
            direction = 'descending';
        end
        reply = input(sprintf('JUDGMENT #%d %s>> ',trial_num,direction),'s');    
        %If reply is a number, record value and go to next trial
        if ~isnan(str2double(reply))
            responses(trial_num) = str2double(reply); %#ok<*AGROW>
            trial_num = trial_num + 1;
            if write_file
                csvwrite(outfile, responses');
            end
        elseif strcmp(reply, 'exit')
            break;
        else
            disp('Input not recognized, please enter a number')
        end  
        %Break when we've passed the alloted number of trials
        if trial_num == num_trials + 1
            break;
        end    
    end

    disp('Completed method of adjustment block')
else
    flip_levels = fliplr(stim_levels);
    for j = 1:num_trials
        if mod(j,2) == start_dir
            ascending = true;
        else
            ascending = false;
        end
        if ascending
            for i = 1:length(stim_levels)
                if rand(1,1) < normcdf(stim_levels(i),threshold_actual, slope_actual);
                    responses(j) = stim_levels(i);
                    break;
                end
            end
        else
            for i = 1:length(flip_levels)
                if rand(1,1) > normcdf(flip_levels(i),threshold_actual, slope_actual);
                    responses(j) = flip_levels(i);
                    break;
                end
            end
        end
    end
    output.id = id;
    
end

output.id = id;
output.condition = condition;
output.responses = responses;
if write_file
    csvwrite(outfile, responses');
end