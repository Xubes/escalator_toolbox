function [mu_est, sigma_est] = setGraphview(w, trial_resp, trial_unit, stim_levels, fit, symbol,color,id, condition)
    h = subplot(3,1,1);
    cla(h);
    set(1, 'Toolbar', 'none');
    set(1, 'MenuBar', 'none');
    t = text(0.01,0.5,sprintf('%04.2f', trial_unit(end)));
    set(t, 'FontSize', 120);
    set(t, 'Color', [0 1 0]);
    tt = text(0.01,0.9,sprintf('Trial # %03d', length(trial_unit)));
    set(tt, 'FontSize', 60);
    set(tt, 'Color', [0 0 1]);
    a = get(1, 'CurrentAxes');
    set(a, 'XTickLabel', '');
    set(a, 'YTickLabel', '');
    set(a, 'XTick', []);
    set(a, 'YTick', []);
    set(a, 'XColor', [1 1 1]);
    set(a, 'YColor', [1 1 1]);

    if fit
        searchGrid.alpha = stim_levels;
        searchGrid.beta = 10.^[-1:.1:2]; %#ok<NBRAK>
        searchGrid.gamma = 0;
        searchGrid.lambda = 0;

        [STIM, HIT, N] = PAL_PFML_GroupTrialsbyX(trial_unit, trial_resp, ones(size(trial_resp)));
        [paramsValues] = PAL_PFML_Fit(STIM, HIT, N, searchGrid, [1 1 0 0 ], @PAL_CumulativeNormal);
        mu_est = paramsValues(1);
        sigma_est = 1./paramsValues(2);
        succtrials = HIT;
        totaltrials = N;
        min = mu_est - w;
        max = mu_est + w;

        x = min:.01:max;
        affmu = mu_est;
        affsig = sigma_est;
        affrate = succtrials ./ totaltrials;
        afftrials = totaltrials;

        afx = normcdf(x,affmu, affsig);

        subplot(3,1,2); 
        plot(x, afx,color,'LineWidth',2);
        axis([min max -.01 1.01])
        xlabel('Environment Unit');
        ylabel('Prop. Positive Responses');
        hold on
        for i = 1:length(STIM)
            if not(isnan(affrate(i)))
                markersize = (afftrials(i) * 2) + 5;
                plot(STIM(i),affrate(i),symbol,'LineWidth',2,'MarkerSize',markersize);
                title(sprintf('%s %s, mu: %3.1f, sig: %3.1f', id, condition, mu_est, sigma_est));
            end
        end
        hold off

        subplot(3,1,3);
        plot(1:length(trial_unit), trial_unit, '--ko');
        xlabel('Trial Number');
        ylabel('Trial Unit');
        %grid minor;
        hold on
        for i = 1:length(trial_resp)
            if trial_resp(i) == 0
                plot(i, trial_unit(i), 'ko', 'MarkerFaceColor','r')
            end
        end
        if length(trial_unit) < 20
            axis([1 20 mu_est-8 mu_est+8]);
        else
            axis([length(trial_unit)-20 length(trial_unit) mu_est-8 mu_est+8]);
        end
        hold off

    end
end