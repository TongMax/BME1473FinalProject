clear all; close all;
results_PCA = load("results_PCA.mat").results_PCA;
results_tsne = load("results_tsne.mat").results_tsne;
results_umap = load("results_umap.mat").results_umap;
no_spikes = load("no_spikes.mat").no_spikes;

mean_PCA = [];
mean_tsne = [];
mean_umap = [];

err_PCA = [];
err_tsne = [];
err_umap = [];

for i= 2:20
    index = find(no_spikes == i);
    mean_PCA(i) = mean(results_PCA(index, 1));
    mean_tsne(i) = mean(results_tsne(index, 1));
    mean_umap(i) = mean(results_umap(index, 1));

    err_PCA(i, 2) = max(results_PCA(index, 1)) - mean_PCA(i);
    err_PCA(i, 1) = mean_PCA(i) - min(results_PCA(index, 1));
    err_tsne(i, 2) = max(results_tsne(index, 1)) - mean_tsne(i);
    err_tsne(i, 1) = mean_tsne(i) - min(results_tsne(index, 1));
    err_umap(i, 2) = max(results_umap(index, 1)) - mean_umap(i);
    err_umap(i, 1) = mean_umap(i) - min(results_umap(index, 1));
    
end

figure;
subplot(1,2,1);
hold on;
errorbar(2:20, mean_PCA(2:20), err_PCA((2:20),1), err_PCA((2:20),2), 'LineWidth', 2);
errorbar(2:20, mean_tsne(2:20), err_tsne((2:20),1), err_tsne((2:20),2), 'LineWidth', 2);
errorbar(2:20, mean_umap(2:20), err_umap((2:20),1), err_umap((2:20),2), 'LineWidth', 2);
plot(0:20,0:20,'Color','k','LineStyle','--');
legend('PCA', 'tsne', 'umap', 'Location', 'NorthWest');
xlabel('Single Units');
ylabel('Hits');

%%

for i= 2:20
    index = find(no_spikes == i);
    mean_PCA(i) = mean(results_PCA(index, 2));
    mean_tsne(i) = mean(results_tsne(index, 2));
    mean_umap(i) = mean(results_umap(index, 2));

    err_PCA(i, 2) = max(results_PCA(index, 2)) - mean_PCA(i);
    err_PCA(i, 1) = mean_PCA(i) - min(results_PCA(index, 2));
    err_tsne(i, 2) = max(results_tsne(index, 2)) - mean_tsne(i);
    err_tsne(i, 1) = mean_tsne(i) - min(results_tsne(index, 2));
    err_umap(i, 2) = max(results_umap(index, 2)) - mean_umap(i);
    err_umap(i, 1) = mean_umap(i) - min(results_umap(index, 2));
    
end

subplot(1,2,2);
hold on;
errorbar(2:20, mean_PCA(2:20), err_PCA((2:20),1), err_PCA((2:20),2), 'LineWidth', 2);
errorbar(2:20, mean_tsne(2:20), err_tsne((2:20),1), err_tsne((2:20),2), 'LineWidth', 2);
errorbar(2:20, mean_umap(2:20), err_umap((2:20),1), err_umap((2:20),2), 'LineWidth', 2);
legend('PCA', 'tsne', 'umap', 'Location', 'SouthEast');
xlabel('Single Units');
ylabel('Percentage Spikes Sorted Correctly');