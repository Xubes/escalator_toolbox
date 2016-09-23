function [responses_moa] = methodOfAdjustment(num_trials, start_dir)
%Start_dir 1 equals narrow, start_dir 0 equals wide
%Can exit prematurely, responses will be length of actual judgments
%collected

trial_num = 1;
while(1)
    %Alternate MOA direction
    if mod(trial_num,2) == start_dir
        direction = 'narrow';
    else
        direction = 'wide';
    end
    reply = input(sprintf('JUDGMENT #%d %s>> ',trial_num,direction),'s');    
    %If reply is a number, record value and go to next trial
    if ~isnan(str2double(reply))
        responses_moa(trial_num) = str2double(reply); %#ok<*AGROW>
        trial_num = trial_num + 1;
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