%%
data=struct2cell(load("simulation_94.mat"));
ground_truth = load("ground_truth.mat");
gt_classes = ground_truth.spike_classes{1,94};
gt_waveforms = ground_truth.su_waveforms{1,94};
gt_timepoints = ground_truth.spike_first_sample{1,94};

%Filter
xden = wdenoise(data{1,1},5,Wavelet="haar", DenoisingMethod="Bayes", ThresholdRule="Median");

data2{1, 1} = xden;
filtered_signal = data2{1, 1};
% 
% Denoise
[coefficients,levels] = wavedec(filtered_signal,5,'haar');

% Reconstruct using only levels 2-5
d2 = wrcoef('d',coefficients,levels, "haar", 2);
d3 = wrcoef('d',coefficients,levels, "haar", 3);
d4 = wrcoef('d',coefficients,levels, "haar", 4);
d5 = wrcoef('d',coefficients,levels, "haar", 5);

combinedSignal_300_6000 =abs(d2) + abs(d3) + abs(d4) + abs(d5);

madValue = median(abs(combinedSignal_300_6000) )/ 0.6745;
threshold = madValue * 4; % Initial threshold multiplier (adjustable)

data3{1,1} = combinedSignal_300_6000;

% Original Signal
Fs = 24000;
range=40000;
Limits=[1,size(data2{1,1},2)-1-range];
time_start=max(1, round(0 * Fs));
time_end=time_start+range;    
fig = figure;

ax(1)=subplot(3,1,1);
if size(data{1,1},2)>range-1
    plot((time_start:time_end-1)/Fs,data{1,1}(time_start:time_end-1))
    hold on;
    plot((time_start:time_end-1)/Fs,threshold*ones(1,range),'red')
    title("Original Signal");
    hold off;
end

% Filtered Signal
Fs = 24000;
range=40000;
Limits=[1,size(data2{1,1},2)-1-range];
time_start=max(1, round(0 * Fs));
time_end=time_start+range; 

ax(2)=subplot(3,1,2);
if size(data{1,1},2)>range-1
    plot((time_start:time_end-1)/Fs,data2{1,1}(time_start:time_end-1))
    hold on;
    plot((time_start:time_end-1)/Fs,threshold*ones(1,range),'red')
    title("Filtered Signal")
    hold off;
end

% Denoised Signal
Fs = 24000;
range=40000;
Limits=[1,size(data2{1,1},2)-1-range];
time_start=max(1, round(0 * Fs));
time_end=time_start+range;    

ax(3)=subplot(3,1,3);
if size(data{1,1},2)>range-1
    plot((time_start:time_end-1)/Fs,data3{1,1}(time_start:time_end-1))
    hold on;
    plot((time_start:time_end-1)/Fs,threshold*ones(1,range),'red')
    title("Denoised Signal");
    hold off;
end

han=axes(fig,'visible','off'); 
han.XLabel.Visible='on';
han.YLabel.Visible='on';
ylabel(han, 'Amplitude');
xlabel(han, 'Time (s)');