function [dets] = spike_simple_detection_pipeline(sig,ts,fs,flow,fhigh,theta)
    % get a set of signals, L, and putative events
    dets = spike_detector(sig,ts,fs,flow,fhigh,theta);
end

