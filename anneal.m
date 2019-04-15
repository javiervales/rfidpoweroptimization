function solglobal = anneal(solinit, L, a, v, conf, onoff)
% L: matriz de perdidas de la red
% a: vector de traficos por slot. Si NaN significa trafico no asignado
% Busca el maximo trafico conjunto admisible en los N sin trafico asignado

global solglobal;

% PARAMETROS EXTERNOS
rand('seed',1);
N = size(L,1);
a = a(:); % Columna
v = v(:); % Columna

% PARAMETROS INTERNOS
timeslot = 0.3; % s
Ptx = 0:0.0025:1;  % W
REPMAX = 100;
LAGRANGEMENOR = 100000;

% Inicializacion del annealing
fmax = -1;
rep = 0;
cambios = 0;
KT = 5.0;
delta = 1.0;
prob = exp(-KT)

% Buscamos solucion de arranque
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
sol.fobj = sol.tasaobj-sol.potencia/LAGRANGEMENOR; % Buscamos soluciones con la menor potencia media añadiendo un lagrangiano menor
if isnan(sol.fobj) 
	fprintf('No existe solucion feasible\n');
	solglobal = NaN;
	return 
end

solglobal = sol;
fprintf('Solucion inicial: %0.6f, %d\nComenzando annealing...\n', sol.fobj, size(sol.P,1));

% Ejecucion del annealing
cambios = 0;
while 1
	countloop = 0;
	while 1
		P = updateP(sol);
		if onoff 
			potencia = Ptx(randi(length(sol.Ptx))); 
			P(P>0) = potencia;
		end

		% Resolvemos problema LP asociado
		solaux = solveLP(L, P, timeslot, a, v, conf);
		solaux.fobj = solaux.tasaobj;
		solaux.potencia = sum(solaux.P'*solaux.alfa);
		solaux.fobj = solaux.tasaobj-solaux.potencia/LAGRANGEMENOR; % Buscamos soluciones con la menor potencia media añadiendo un lagrangiano menor

		% Si la solucion es feasible salimos
		countloop = countloop + 1;
		if ~isnan(solaux.fobj) break; end
	end
	fprintf('Sol updated: %0.6f %0.6f %d %d %d  \r', solaux.tasaobj, solaux.potencia, size(solaux.P,1), rep, countloop);

	% Aceptamos la nueva solucion?
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
		fprintf('\t\t\t\t\t +Sol accepted, prob: %0.3f, cambios: %d, forzada: %d       ', prob, cambios, forzado)
		if solglobal.fobj < sol.fobj
			solglobal = sol;
			fprintf('[Sol global updated: %0.6f %d %d]\n', solglobal.fobj, size(sol.P,1), sum(sol.alfa>0));
			%solglobal.P(solglobal.alfa>0,:)
			%solglobal.tasas
			%solglobal.alfa(solglobal.alfa>0,:)
			%solglobal
		else
			fprintf('[NO global updated]\n');
		end
	end

	% Hemos terminado?
	rep = rep + 1;
	if rep==REPMAX || forzado
		if cambios 
			rep = 0;
			KT = KT+delta;
			delta = 2*delta;
			prob = exp(-KT)
			cambios = 0;
			if ~forzado 
				fprintf('\nReseteada sol a solglobal\n');
				sol = solglobal; % reseteamos tras un ciclo con cambios que no mejore la solglobal
			end
		else
			fprintf('\nFinalizado con fobj: %0.3f %d\n', solglobal.fobj, size(solglobal.P,1));
			mask = solglobal.alfa>0;
			solglobal.P = solglobal.P(mask,:);
			solglobal.B = solglobal.B(mask,:);
			solglobal.alfa = solglobal.alfa(mask);
			break % FIN DEL ANNEALING
		end
	end
end



end
