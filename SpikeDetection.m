% clear all; close all;
xz = zeros(95,4);
for i=1:95
    [xz(i, 1), xz(i, 2), xz(i, 3)] = validate(i);
    xz(i, 4) = xz(i, 1)/(xz(i, 1) + xz(i, 3)) * 100;
end

function [TP, FP, FN] = validate(sim_no)
    sim_filename = sprintf("simulation_%d.mat",sim_no);
    data=struct2cell(load(sim_filename));
    ground_truth = load("ground_truth.mat");
    gt_classes = ground_truth.spike_classes{1,sim_no};
    gt_timepoints = ground_truth.spike_first_sample{1,sim_no};
    gt_timepoints_nomulti = gt_timepoints((gt_classes > 0));
    
    %Filter Design: Use FIR for Linear Phase Response
    Fs = 24000; % Sampling frequency
    
    % xden = wdenoise(data{1,1},Wavelet="haar", DenoisingMethod="UniversalThreshold", ThresholdRule="Hard");
    xden = wdenoise(data{1,1},5,Wavelet="db4", DenoisingMethod="Bayes", ThresholdRule="Median");
    % filterOrder = 200; % Higher order for sharper cutoff
    % cutoffFreq = [300, 6000]; % Bandpass range (Hz)
    % 
    % % FIR filter design
    % d = designfilt('bandpassfir', 'FilterOrder', filterOrder, ...
    %     'CutOffFrequency1', cutoffFreq(1), 'CutOffFrequency2', cutoffFreq(2), ...
    %     'SampleRate', Fs);
    % 
    % % Apply zero-phase filtering
    % data2{1, 1} = filtfilt(d, xden);
    data2{1, 1} = xden;
    filtered_signal = data2{1, 1};
    % 
    % %Peak + Wavelet algorithm
    [coefficients,levels] = wavedec(filtered_signal,5,'db4');
    
    % Reconstruir la señal ECG a partir de los coeficientes de detalle de los primeros 7 niveles
    d2 = wrcoef('d',coefficients,levels, "db4", 2);
    d3 = wrcoef('d',coefficients,levels, "db4", 3);
    d4 = wrcoef('d',coefficients,levels, "db4", 4);
    d5 = wrcoef('d',coefficients,levels, "db4", 5);
    
    combinedSignal_300_6000 =abs(d2) + abs(d3) + abs(d4) + abs(d5);
    
    % energy = abs(combinedSignal_300_6000).^2;
    % 
    % threshold = mean(energy(:)) + 5 * std(energy(:));

    % madValue = median(abs(combinedSignal_300_6000(1:end)) )/ 0.6745; % MAD for noise estimation
    madValue = median(abs(combinedSignal_300_6000) )/ 0.6745;
    threshold = madValue * 4; % Initial threshold multiplier (adjustable)
    fprintf("%d\n", threshold);
    % threshold = mean(combinedSignal_300_6000) + 3 * std(combinedSignal_300_6000);
    data3{1,1} = combinedSignal_300_6000;
    
    r1=(downsample(data3,round(Fs/24000)));
    r=r1{1,1}(:,:);
    % x=find(r>threshold | r<-1*threshold);
    % Find spikes based on wavelet thresholding
    x=find(r>threshold);
    x=x(x>100);
    % With the found indexes with possible spikes, match that to the original
    % signal
    r1=(downsample(data,round(Fs/24000)));
    r=r1{1,1}(:,:);
    g=diff(x);
    %             n=0;
    rr=cell(0);
    x2=[];
    Y33=zeros(size(g,2)-1,45);
    Time_Stamp{1,1}=[];
     for i=1:size(g,2)-1
    %             disp(i)
    %                 n=n+1;
        try
            signal1=r((x(i)-70):(x(i)+20));
            cc=find (r((x(i)-70):(x(i)+20))==max(signal1),1);
            x2(i)=cc+x(i)-70;
            Time_Stamp{1,1}(i)=x2(i);
            rr{i}=(r(x2(i)-100:x2(i)+120));
            TT=rr{i};
            maxTT=find(TT==max(TT(80:140)),1);
        catch
            continue
        end
    %                 disp(size(TT,2))
        if maxTT>15 && maxTT<175
            TT =TT(maxTT-19:maxTT+25);
            Time_Stamp{1,1}(i)=x2(i);
            Y33(i,:)=TT;
        end  
     end
    
    % Delete duplicates
    [Y44,ia,~]=unique(Y33,'stable','rows');
    Y33=Y44;
    %             AllTIME=app.Time_Stamp{1,1};
    Time_Stamp{1,1}=Time_Stamp{1,1}(:,ia);
    
    %             app.Time_Stamp{1,1}=[];
    %             app.Time_Stamp{1,1}=AllTIME;
    Spikes{1,1}=Y33;
    
    mspikes=[];
    mspikes_orginal=[];
    mspikes=Spikes;
    mspikes_orginal=Spikes;
    
    % Validate 
    
    TP = 0; 
    FP = 0; 
    N = 0;
    FN = length(gt_timepoints_nomulti); % Start with all gt_timepoints as FN
    time_series = Time_Stamp{1,1};
    
    for j = 1:length(gt_timepoints_nomulti)
        if j < length(gt_timepoints_nomulti)
            window = find((time_series < gt_timepoints_nomulti(j+1)) & (time_series >= gt_timepoints_nomulti(j)));
        else
            window = find(time_series >= gt_timepoints_nomulti(j)); % Last element case
        end
        
        hasTP = false;
        
        if isempty(window)
            % No predictions in this time window
            N = N + 1;
            continue; % Skip to next iteration
        else
            for k = 1:length(window)
                if abs(time_series(window(k)) - gt_timepoints_nomulti(j)) <= 50 % Check within tolerance
                    hasTP = true;
                    break; % Found a true positive
                end
            end
            
            if hasTP
                TP = TP + 1; % Increment true positives count
                FN = FN - 1; % Decrement false negatives since we found a match
                
                % Count false positives only if there are additional detections in this window
                FP = FP + (length(window) - 1); % All other detections in this window are false positives
            else
                FP = FP + length(window); % All detections in this window are false positives since no match was found
            end
        end
    end
end