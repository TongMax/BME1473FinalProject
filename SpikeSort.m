clear all; close all;

results_PCA = zeros(95, 2);
results_tsne = zeros(95, 2);
results_umap = zeros(95, 2);

for i=1:95
    [results_PCA(i, 1), results_tsne(i, 1), results_umap(i, 1), results_PCA(i,2), results_tsne(i,2), results_umap(i,2)] = spike_sort(i);
end

function [clusters_total_PCA, clusters_total_tsne, clusters_total_umap, predicted_PCA, predicted_tsne, predicted_umap] = spike_sort(sim_no)
    sim_filename = sprintf("simulation_%d.mat",sim_no);
    data=struct2cell(load(sim_filename));
    ground_truth = load("ground_truth.mat");
    gt_spike_classes = load("gt_spike_classes.mat");
    gt_classes = gt_spike_classes.spike_classes{1,sim_no};
    gt_waveforms = ground_truth.su_waveforms{1,sim_no};
    gt_timepoints = ground_truth.spike_first_sample{1,sim_no};
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
    
    %% PCA
    
    [PCA_weights, PCA_variable, latent, tsquared, explained] = pca(Spikes{1,1}');

    numPCs = find(cumsum(explained) >= 95, 1); % Retain 95% variance
    reducedMatrix = PCA_variable(:, 1:numPCs);
    
    % Clustering using DBSCAN
    
    IDX_PCA=dbscan(reducedMatrix,0.6,6);
    
    % Plot the clusters in 3D
    
    % Get unique cluster indices (excluding noise)
    clusters_PCA = unique(IDX_PCA);
    
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
    
    %% UMAP
    
    [reduction, umap, IDX_umap, extras] = run_umap(Spikes{1,1}', 'n_components', 3,"verbose", "none", Method="Java");
    
    % Get unique cluster indices (excluding noise)
    clusters_umap = unique(IDX_umap);
    
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

end