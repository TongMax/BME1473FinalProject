clear all; close all;
fs = 24000;
data=struct2cell(load("simulation_95.mat"));
ground_truth = load("ground_truth.mat");
gt_spike_classes = load("gt_spike_classes.mat");
gt_classes = gt_spike_classes.spike_classes{1,95};
gt_waveforms = ground_truth.su_waveforms{1,95};
gt_timepoints = ground_truth.spike_first_sample{1,95};
gt_timepoints_nomulti = gt_timepoints((gt_classes > 0));
gt_class_nomulti = gt_classes(gt_classes > 0);

%%Get a 45 sample window for each spike
numSpikes = length(gt_timepoints_nomulti); % Number of true spikes
windowSize = 45; % Size of the window
% halfWindow = floor(windowSize / 2); % Half size for centering

% Initialize output matrix
Spikes{1,1} = zeros(windowSize, numSpikes);

for i = 1:numSpikes
    spikeIndex = gt_timepoints_nomulti(i);
    
    % Calculate start and end indices for the window
    startIdx = spikeIndex;
    endIdx = min(length(data), spikeIndex + windowSize);
    Spikes{1,1}(1:45,i) = data{1,1}(:, spikeIndex:(spikeIndex+44))';
end

%% Plot spikes

figure(1);
plot(Spikes{1,1}(:, :));
NumbersofSpikes=size(Spikes{1,1}(:,:),1);

LoadData = true;
LoadSpikes = true;

%% PCA

[PCA_weights, PCA_variable, latent, tsquared, explained] = pca(Spikes{1,1}');

numPCs = find(cumsum(explained) >= 95, 1); % Retain 95% variance
reducedMatrix = PCA_variable(:, 1:numPCs);

% Clustering using DBSCAN

% Plot the clusters in 3D
k = 4; % Assuming MinPts = 5
distances = pdist2(reducedMatrix, reducedMatrix);
sortedDistances = sort(distances, 2);
kthDistances = sortedDistances(:, k + 1);
[~, elbowIdx] = findchangepts(sort(kthDistances), 'Statistic', 'linear');
epsilon = kthDistances(round(elbowIdx)); % Optimal epsilon

IDX_PCA=dbscan(reducedMatrix,0.6,6);

% Get unique cluster indices (excluding noise)
clusters_PCA = unique(IDX_PCA);

% Define a color palette
figure;
colors = lines(length(clusters_PCA));

subplot(1,3,1);
for i = 1:length(clusters_PCA)
    if clusters_PCA(i) < 1
        continue;
    end
    % Extract the points belonging to the current cluster
    hold on;
    scatter3(PCA_variable(IDX_PCA == clusters_PCA(i), 1), ...
             PCA_variable(IDX_PCA == clusters_PCA(i), 2), ...
             PCA_variable(IDX_PCA == clusters_PCA(i), 3), ...
             36, colors(i, :), 'filled', 'DisplayName', ['Cluster ' num2str(clusters_PCA(i))]);
end

% Customize plot
title('PCA');
xlabel('PCA Dimension 1');
ylabel('PCA Dimension 2');
zlabel('PCA Dimension 3');
legend show;
grid on;
view(3); % Set to 3D view
hold off;

%% tsne
%Set to some default value?
perplexity = 70;

% %tsne
Y_tsne = tsne(Spikes{1,1}', 'NumDimensions',3,'Distance','euclidean','Perplexity',perplexity);

% Clustering using DBSCAN
epsilon=3.394;
MinPts=2.5862;

IDX_tsne=DBSCAN(Y_tsne,epsilon,MinPts);

% Plot the clusters in 3D

% Get unique cluster indices (excluding noise)
clusters_tsne = unique(IDX_tsne);

% Define a color palette
colors = lines(length(clusters_tsne));


subplot(1,3,2);
for i = 1:length(clusters_tsne)
    % Extract the points belonging to the current cluster
    if clusters_tsne(i) < 1
        continue;
    end
    hold on;
    scatter3(Y_tsne(IDX_tsne == clusters_tsne(i), 1), ...
             Y_tsne(IDX_tsne == clusters_tsne(i), 2), ...
             Y_tsne(IDX_tsne == clusters_tsne(i), 3), ...
             36, colors(i, :), 'filled', 'DisplayName', ['Cluster ' num2str(clusters_tsne(i))]);
end

% Customize plot
title('t-SNE');
xlabel('t-SNE Dimension 1');
ylabel('t-SNE Dimension 2');
zlabel('t-SNE Dimension 3');
legend show;
grid on;
view(3); % Set to 3D view
hold off;

%% UMAP

[reduction, umap, IDX_umap, extras] = run_umap(Spikes{1,1}', 'n_components', 3,"verbose", "none", Method="Java");

% Get unique cluster indices (excluding noise)
clusters_umap = unique(IDX_umap);

% Define a color palette
colors = lines(length(clusters_umap));

%%

subplot(1,3,3);
for i = 1:length(clusters_umap)
    hold on;
    % Extract the points belonging to the current cluster
    scatter3(reduction(IDX_umap == clusters_umap(i), 1), ...
             reduction(IDX_umap == clusters_umap(i), 2), ...
             reduction(IDX_umap == clusters_umap(i), 3), ...
             36, colors(i, :), 'filled', 'DisplayName', ['Cluster ' num2str(clusters_umap(i))]);
end

% Customize plot
title('UMAP');
xlabel('UMAP Dimension 1');
ylabel('UMAP Dimension 2');
zlabel('UMAP Dimension 3');
legend show;
grid on;
view(3); % Set to 3D view
hold off;

%% Get Ground Truth Cluster Counts

classes = unique(gt_class_nomulti, 'stable');

true_classes_total = [];
for i=1:length(classes)
    curClass = classes(i);
    true_classes_total(i) = sum(gt_class_nomulti(:)== curClass);
end

%% Get Predicted Cluster Counts

clusters_total_PCA = length(clusters_PCA(clusters_PCA > 0));
clusters_total_tsne = length(clusters_tsne(clusters_tsne > 0));
clusters_total_umap = length(clusters_umap(clusters_umap > 0));

true_positive_PCA = IDX_PCA==gt_class_nomulti';
true_positive_tsne = IDX_tsne==gt_class_nomulti';
true_positive_umap = IDX_umap==gt_class_nomulti';

predicted_PCA = sum(true_positive_PCA(:))/length(gt_class_nomulti)*100;
predicted_tsne = sum(true_positive_tsne(:))/length(gt_class_nomulti)*100;
predicted_umap = sum(true_positive_umap(:))/length(gt_class_nomulti)*100;


