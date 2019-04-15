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

Simple usage

```matlab
load example1.mat % Load network setup for m=5 readers
L
conf
sol = anneal([],L,[0.2 0.2 0 0.2 0.2],[1 1 1 1 1],conf,0)
```
