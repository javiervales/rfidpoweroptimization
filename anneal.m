function solglobal = anneal(solinit, L, a, v, conf, onoff)
% function solglobal = anneal(solinit, L, a, v, conf, onoff)
% Search for the best transmission power configurations and application probabilities
% L: Loss matrix
% a: minimal traffic per reader 
% v: readers for joint traffic maximization
% conf: configuration of the anti-collision protocol in each reader
% onoff: use independent powers (0) or same power (1)

global solglobal;

% External parameters
rand('seed',1);
N = size(L,1);
a = a(:); % Column
v = v(:); % Column

% Internal parameters
timeslot = 0.3; % s
Ptx = 0:0.0025:1;  % W
REPMAX = 100;
LAGRANGEMENOR = 100000;

% Annealing initialization
fmax = -1;
rep = 0;
cambios = 0;
KT = 5.0;
delta = 1.0;
prob = exp(-KT)

% Search for start solution, round robin correspond to identity matrix
if ~isempty(solinit)
	P = solinit.P;
else
	P = eye(size(L));
end

sol = solveLP(L,P,timeslot,a,v,conf);
sol.fobj = sol.tasaobj;
sol.Ptx = Ptx;
sol.KT = KT;
sol.prob= prob;
sol.potencia = sum(sol.P'*sol.alfa);
% Add secondary goal of reducing joint transmission power 
sol.fobj = sol.tasaobj-sol.potencia/LAGRANGEMENOR; 
if isnan(sol.fobj) 
	fprintf('Unfeasible problem\n');
	solglobal = NaN;
	return 
end

solglobal = sol;
fprintf('Initial solution: %0.6f, %d\nStarting annealing...\n', sol.fobj, size(sol.P,1));

% Annealing running
cambios = 0;
while 1
	countloop = 0;
	while 1
		P = updateP(sol);
		if onoff 
			potencia = Ptx(randi(length(sol.Ptx))); 
			P(P>0) = potencia;
		end

		% Solve associated LP
		solaux = solveLP(L, P, timeslot, a, v, conf);
		solaux.fobj = solaux.tasaobj;
		solaux.potencia = sum(solaux.P'*solaux.alfa);
		solaux.fobj = solaux.tasaobj-solaux.potencia/LAGRANGEMENOR; 

		% If feasible solution break
		countloop = countloop + 1;
		if ~isnan(solaux.fobj) break; end
	end
	fprintf('Sol updated: %0.6f %0.6f %d %d %d  \r', solaux.tasaobj, solaux.potencia, size(solaux.P,1), rep, countloop);

	% Is solution accepted?
	cambio = 0;
	forzado = 0;
	if solaux.fobj>sol.fobj 
		cambio = 1;
	elseif rand()<prob
		cambio = 1;
		forzado = 1;
	end

	if cambio
		cambios = cambios + 1;
		cambio = 0;
		sol = solaux;
		sol.Ptx = Ptx;
		sol.KT = KT;
		sol.prob = prob;
		fprintf('\t\t\t\t\t +Sol accepted, prob: %0.3f, changes: %d, forzed: %d       ', prob, cambios, forzado)
		if solglobal.fobj < sol.fobj
			solglobal = sol;
			fprintf('[Sol global updated: %0.6f %d %d]\n', solglobal.fobj, size(sol.P,1), sum(sol.alfa>0));
		else
			fprintf('[No global updated]\n');
		end
	end

	% Have we finish?
	rep = rep + 1;
	if rep==REPMAX || forzado
		if cambios 
			rep = 0;
			KT = KT+delta;
			delta = 2*delta;
			prob = exp(-KT)
			cambios = 0;
			if ~forzado 
				fprintf('\nReset sol to solglobal\n');
				sol = solglobal; % Reseting after a cycle without improvements in global solution 
			end
		else
			fprintf('\nFinished with fobj: %0.3f %d\n', solglobal.fobj, size(solglobal.P,1));
			mask = solglobal.alfa>0;
			solglobal.P = solglobal.P(mask,:);
			solglobal.B = solglobal.B(mask,:);
			solglobal.alfa = solglobal.alfa(mask);
			break % End of annealing
		end
	end
end



end
