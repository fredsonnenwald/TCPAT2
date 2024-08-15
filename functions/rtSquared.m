% Calculate Young's RT2 correlation (goodness-of-fit) coefficient (see
% Young et al [1980] equation 14)
%
%     rt2 = rtSquared(original, new)
%
%      rt2: the goodness of fit where 1 is a perfect correlation, and less
%           than 0 indicates no correlation
%
% original: The measured data
%      new: The predicted data
%
% References
%
% Young, P., Jakeman, A., & McMurtrie, R. (1980). An instrumental variable
%     method for model order identification. Automatica, 16(3), 281-294.

function rt2 = rtSquared(original, new)

    % original and new must be the same size
    assert(all(size(original) == size(new)))

    rt2 = 1 - sum((original - new).^2) / sum(original.^2);
