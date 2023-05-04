function tgt_ind = find_time(t, currInd, t_delta)
tgt_time = t(currInd)+t_delta;
if tgt_time > max(t)
    tgt_ind = NaN;
else
    [~, tgt_ind] = min(abs(tgt_time-t));
end
end