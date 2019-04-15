function solucion = solveLP(L, P, t, a, v, conf)

% Convertimos a dBm
PdBm = 10*log10(P*1000);
[B, SINR] = computeB(L,PdBm,t,conf);
%B(isnan(B))=0;

% PARAMETROS EXTERNOS
K = size(B,1);
N = size(B,2);

% Solucion LP
%f = -[v'*B', -v'];   % fcost f'x, x=[alfa epsilon]' % - para convertir el problema en una maximizacion
f = -[v'*B'];   % fcost f'x, x=[alfa] % - para convertir el problema en una maximizacion
%f = -[v'*B', zeros(1,N)];   % fcost f'x, x=[alfa epsilon]' % - para convertir el problema en una maximizacion
%A = [ones(1,K) zeros(1,N); -B' eye(N)]; % A x <= b
A = [ones(1,K); -B']; % A x <= b
b = [1; -a];

options = optimoptions('linprog','Algorithm','dual-simplex','Display','none','OptimalityTolerance',1.0e-4);
%options = optimoptions('linprog','Algorithm','interior-point','Display','none','OptimalityTolerance',1.0e-3);
[x,fval,exitflag,~] = linprog(f,A,b,[],[],zeros(1,K),ones(1,K),options);

if exitflag==1 
	solucion.alfa = x(1:K);
	solucion.resultado = 1;
	solucion.tasas = B'*solucion.alfa;
	solucion.tasaobj = v'*solucion.tasas;
else
	solucion.alfa = zeros(K,1);
	solucion.resultado = 0;
	solucion.tasas = zeros(N,1);
	solucion.tasaobj = NaN;
end

solucion.P = P;
solucion.B = B;
solucion.L = L;
solucion.t = t;

end
