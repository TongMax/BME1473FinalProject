clear all; close all;

results_Haar = load("haar_bayes_threshold_4_nofilter_wdenoise.mat").xz;
results_db4 = load("db4_bayes_threshold_4_nofilter_wdenoise.mat").xz;

for i=1:95
    results_Haar(i, 5) = results_Haar(i,1)/(results_Haar(i,1)+ results_Haar(i,2))*100;
    results_db4(i, 5) = results_db4(i,1)/(results_db4(i,1)+ results_db4(i,2))*100;
end

%% Plot performance
no_spikes = load("no_spikes.mat").no_spikes;

err_pre_Haar = [];
err_re_Haar = [];

err_pre_db4 = [];
err_re_db4 = [];

mean_pre_Haar = [];
mean_re_Haar = [];

mean_pre_db4 = [];
mean_re_db4 = [];

for i= 2:20
    index = find(no_spikes == i);
    mean_pre_Haar(i) = mean(results_Haar(index, 5));
    mean_re_Haar(i) = mean(results_Haar(index, 4));

    mean_pre_db4(i) = mean(results_db4(index, 5));
    mean_re_db4(i) = mean(results_db4(index, 4));

    % Error bars
    err_pre_Haar(i, 2) = max(results_Haar(index, 5)) - mean_pre_Haar(i);
    err_pre_Haar(i, 1) = mean_pre_Haar(i) - min(results_Haar(index, 5));

    err_re_Haar(i, 2) = max(results_Haar(index, 4)) - mean_re_Haar(i);
    err_re_Haar(i, 1) = mean_re_Haar(i) - min(results_Haar(index, 4));
    
    err_pre_db4(i, 2) = max(results_db4(index, 5)) - mean_pre_db4(i);
    err_pre_db4(i, 1) = mean_pre_db4(i) - min(results_db4(index, 5));

    err_re_db4(i, 2) = max(results_db4(index, 4)) - mean_re_db4(i);
    err_re_db4(i, 1) = mean_re_db4(i) - min(results_db4(index, 4));
    
end

fig = figure;

ax(1)= subplot(1,2,1);
hold on;
errorbar(2:20, mean_pre_Haar(2:20), err_pre_Haar((2:20),1), err_pre_Haar((2:20),2), 'LineWidth', 2);
errorbar(2:20, mean_pre_db4(2:20), err_pre_db4((2:20),1), err_pre_db4((2:20),2), 'LineWidth', 2);

legend('Haar', 'db4', 'Location', 'SouthEast');
xlabel('Single Units');
ylabel('Percentage');
title("Precision");
hold off;


ax(2)= subplot(1,2,2);
hold on;
errorbar(2:20, mean_re_Haar(2:20), err_re_Haar((2:20),1), err_re_Haar((2:20),2), 'LineWidth', 2);
errorbar(2:20, mean_re_db4(2:20), err_re_db4((2:20),1), err_re_db4((2:20),2), 'LineWidth', 2);

legend('Haar', 'db4', 'Location', 'SouthEast');
xlabel('Single Units');
ylabel('Percentage');
title("Recall");
hold off;