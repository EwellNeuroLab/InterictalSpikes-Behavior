function [] =inspect_detections(sig,ts,ts_spikes,line,plot_sig)
    if plot_sig
        plot(ts,sig)
        hold on

        if line
            xline(ts_spikes,'Alpha',0.4)
        else
            scatter(ts_spikes,ones(size(ts_spikes)),100,"|","LineWidth",2)
        end
        hold off
    else
        if line
            xline(ts_spikes,'Alpha',0.4)
        else
            scatter(ts_spikes,ones(size(ts_spikes)),100,"|","LineWidth",2)
        end
        hold off
    end
end

