function [Precision,Recall,F1,F05] = PrecSummary(dets_clean,gt_roi_lims)
    % classify each detection & ROI according to the ground-truth as follows:
    % for a given ROI, if there is at least one detection inside, call one the
    % TP. All others inside are FP. Similarly, any detections outside an ROI is
    % a FP. Finally, ROIs which lack detection are FN. We do not explicitly
    % consider TNs.
    
    TP = 0;
    FP = 0;
    FN = 0;
    
    for i = 1:length(gt_roi_lims)
        % how many detections within this ROI?
        num_dets=length(find((dets_clean>=gt_roi_lims(i,1)/1000 & dets_clean<gt_roi_lims(i,2)/1000)));
    
        if num_dets == 0
            FN = FN + 1;
        elseif num_dets == 1
            TP = TP + 1;
        elseif num_dets > 1
            TP = TP + 1;
            FP = FP + num_dets-1;
        end
    end

    % how many detections outside an ROI?
    num_dets = length(find((dets_clean<gt_roi_lims(1,1)/1000)));
    FP = FP + num_dets;

    for i = 1:length(gt_roi_lims)-1
        % how many detections between end of ROI(i) and start of ROI(i+1)?
        num_dets=length(find((dets_clean>=gt_roi_lims(i,2)/1000 & dets_clean<gt_roi_lims(i+1,1)/1000)));

        FP = FP + num_dets;
    end

    num_dets = length(find((dets_clean>=gt_roi_lims(end,2)/1000)));
    FP = FP + num_dets;
    
    Precision = TP/(TP + FP);
    Recall = TP/(TP+FN);
    F1 = (2*Precision*Recall)/(Precision+Recall);
    F05 = ((1+0.5^2)*Precision*Recall)/((0.5^2)*Precision+Recall);
end

