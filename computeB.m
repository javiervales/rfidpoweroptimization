function [B, SINR] = computeB(L,P,t,conf)
	
	for i=1:size(P,1)
		[B(i,:), SINR(i,:)] = bip(P(i,:)', L, t, conf);
	end
end
