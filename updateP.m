function P = updateP(sol)

P = sol.P;
prob = rand();

if prob<0.1 % Change the row with the least alfa
	alfa = sol.alfa + (1-sum(sol.alfa))/length(sol.alfa);	
	Dalfa = cumsum(alfa);
	fila = find(rand()<Dalfa,1,'first');
	P(fila,:) = sol.Ptx(randi(length(sol.Ptx),1,size(sol.L,1)));
elseif prob<0.15 % Erase unused rows
	if size(P,1)>5*size(sol.L,1)
		P = sol.P(sol.alfa>0,:);
	end
elseif prob<0.3 % Change row such alfa>0
	fila = randi(size(P,1));
	P(fila,:) = P(fila,:)-rand()*(2-randi(3,1,size(sol.L,1)));
elseif prob<0.4 % Change column
	col = randi(size(P,2));
	P(:,col) = P(:,col)-rand()*(2-randi(3,size(sol.P,1),1));
else % Add rows
	P = [sol.P; sol.Ptx(randi(length(sol.Ptx),10,size(sol.L,1)))];
end

P(P>sol.Ptx(end)) = sol.Ptx(end);
P(P<sol.Ptx(1)) = sol.Ptx(1);

end
