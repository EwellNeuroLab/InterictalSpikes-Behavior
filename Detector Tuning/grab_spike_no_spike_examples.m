%% load in some signals
load("./Labeling Ground Truth/ls_label_3min_fixed_2462_PART2_MERGED_labelled.mat")

which_to_cat = {{1,2,3,4},{5,6,7,8},{9,10,11,12},{13,14,15,16},...
    {17,18,19,20},{21,22,23,24}};
%% calculating performance
clear gt_roi_lims
clear gt_roi_lims_temp
wh_animal = 2;

sig = ls.Source{which_to_cat{wh_animal}{1},1}.Variables;
ts = seconds(ls.Source{which_to_cat{wh_animal}{1},1}.Time);
gt_roi_lims =  round(1+(ls.Labels.Spike{which_to_cat{wh_animal}{1},1}.ROILimits)*1000);

for i = 2:length(which_to_cat{wh_animal})
    wh = which_to_cat{wh_animal}{i};

    sig_temp = ls.Source{wh,1}.Variables;
    ts_temp = seconds(ls.Source{wh,1}.Time) + ts(end);
    
    % ROI lms
    if ~isempty( ls.Labels.Spike{wh,1}.ROILimits)
        gt_roi_lims_temp = round(1+(ts(end) + ls.Labels.Spike{wh,1}.ROILimits)*1000);
        gt_roi_lims = [gt_roi_lims; gt_roi_lims_temp];
    end
    sig = [sig; sig_temp];
    ts = [ts; ts_temp];    
end

% detect spikes
dets_clean = spike_simple_detection_pipeline(sig,ts,1000,16,400,900);

%calculate the performance of the detector with these settings
[Precision,Recall,F1,F05] = PrecSummary(dets_clean,gt_roi_lims);

disp("The Precision is: "+string(Precision))
disp("The Recall is: "+string(Recall))
disp("The F1 is: "+string(F1))
disp("The F0.5 is: "+string(F05))


% ground-truth ROI maskss
gt_roi_mask = signalMask(sigroi2binmask(gt_roi_lims,length(sig)),'SampleRate',1000);

%%
figure()
plotsigroi(gt_roi_mask,sig,true)
hold on
inspect_detections(sig,ts,dets_clean,false,false)
hold off

%% skecth a performance curve
thetas = 100:200:2000;%30:20:300;%100:100:2000;%20:20:500;%300:100:2000;
freq_lows = 2.^(0:2:6);

for h = 1:length(freq_lows)
    Precs = nan(size(thetas));
    Recs = nan(size(thetas));
    F1s = nan(size(thetas));
    F05s = nan(size(thetas));

    for j = 1:length(thetas)
        try 
        % detect spikes
        [dets_clean,idx_clust,...
            coeff,l,latent,explained] = ...
        spike_detection_pipeline(sig,ts,1000,freq_lows(h),400,thetas(j),100,3000,1);
    
        %calculate the performance of the detector with these settings
        [Precs(j),Recs(j),F1s(j),F05s(j)] = PrecSummary(dets_clean,gt_roi_lims);
        catch 
            disp("Skipping "+j)
        end
    end

figure(1)
hold on
plot(Recs,Precs,'-o')
xlabel("Recall")
ylabel("Precision")
xlim([0 1.1])
ylim([0 1.1])
hold off

figure(2)
hold on
plot(thetas,F1s,'-o')
xlabel("Threshold (\mu V)")
ylabel("F1 score")
hold off

figure(3)
hold on
plot(thetas,F05s,'-o')
xlabel("Threshold (\mu V)")
ylabel("F0.5 score")
hold off
end
