function [b, sinr] = bip(P, L, t, conf)
% function [b, sinr] = bip(P, L, t, conf)
% This function returns the matrix B (Batch identification probabilities) and SINR
% given the loss matrix L, the power configuuration vector P, the timeslot durantion t
% and the RFID anti-collision configuration
% 
% P(m,1) dBm
% L(m,m) dBm is a matrix of network losses
% t is the time scheduled to transmit
%
% EXAMPLE: 
% [a b]= bip2([30;0;20;0;20], L, 0.3, conf)
%-----
% "conf" is a struct with 'protocol' 0 (DFSA) or 1 (FSA) , 
% and traffic_type' 0 (Poisson) or 1 (fixed size 100 tags).
%
% Default L matrix for Default Network of 5 
% L = [65 48 68 NaN NaN; 48 65 58 NaN NaN; 68 58 65 58 68; NaN NaN 58 65 48;NaN NaN 68 48 65]
% Power Vector Test [30; 30; 30; 30; 30] dBm


N = -97.958; 
N_linear = 10^(N/10);


% convert the powers vector into a matrix with identical columns
P_matrix =repmat(P,[1,length(P)]);
% L
PL = (P_matrix - L); % powerTx in dBm - Losses(dBm)
PL_linear = (10.^(PL./10))./1000;
% select the diagonal elements of PL_linear
S_linear = PL_linear.*eye(size(L));
% select the non-diagonal elements of PL_linear
PI_linear = PL_linear.*(ones(size(L))-eye(size(L)));
sinr_linear = nansum(S_linear)./(nansum(PI_linear) + N_linear);
sinr = 10*log10(sinr_linear);

m=size(P);
b = zeros(1,m(1));
load('B.mat');
for i=1:m(1) 
    trail = strcat('_',num2str(conf(i).protocol),num2str(conf(i).traffic_type));
    conf(i).B = {strcat('B1',trail),strcat('B2',trail),strcat('B3',trail)};    
   
     B1 = eval(char(conf(i).B(1)));
     B2 = eval(char(conf(i).B(2)));    
     B3 = eval(char(conf(i).B(3)));

   F = scatteredInterpolant(B1(:),B2(:),B3(:),'nearest','nearest');
   b(i) = F(t, sinr(i));
end
b(isnan(b))=0;
end
