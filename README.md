# Optimal power stationary policies for synchronous queued RFID networks
Algorithm for computing the optimal power policy in a synchronous queued RFID network

This software computes the optimal transmission powers for a network of RFID readers where:

1) RFID cells produce mutual interferences, defined through a loss matrix L, which indicates at element L_jj' 
the path-loss between readers j and j', or the reader-tags-reader path-loss in the diagonal elements
2) Readers operate synchronously, in timeslots of duration t
3) The goal is obtaining a stationary policy defining a probability distribution α to randomly draw, at the beggining of each timeslot, 
the transmission power configuration to be used in the netwoek. 

The optimizer obtains a matrix P, where each row indicates a network transmission power configuration (the ith element of 
the row is the transmission power to be set for the ith reader), and the probability distribution α to be used. 

<h2> Examples </h2>

Simple usage, small network with m=5

```matlab
load example1.mat % Load network setup for m=5 readers
L, conf % Show configuration
L = L + 30 - 30*eye(5) % Add transmit mask DRE additional gap
amin = [0.2 0.2 0 0.2 0.2]; % Minimal traffic per reader
v = [1 1 1 1 1]; % Readers to optimize
sol = anneal([],L,amin,v,conf,0) % Run optimizer indepent power policy
solonoff = anneal([],L,amin,v,conf,1) % Run optimizer onoff power policy
sol = anneal(solonoff,L,amin,v,conf,0) % Run optimizer indepent power policy starting with solonoff solution
```

Simple usage, large network with m=50

```matlab
load example2.mat % Load network setup for m=50 readers
L, conf % Show configuration
L = L + 30 - 30*eye(50) % Add transmit mask DRE additional gap
amin = ones(1,50)/70; % Minimal traffic per reader
v = ones(1,50); % Readers to optimize
sol = anneal([],L,amin,v,conf,0) % Run optimizer indepent power policy
sol = anneal([],L,amin,v,conf,1) % Run optimizer onoff power policy
```
