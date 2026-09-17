(* ::Package:: *)

(* ::Input::Initialization:: *)
(*Shared agent data and local infectious counts.*)memoMat=Table[0,{x,1,XSIZE},{y,1,YSIZE}];
agList=Table[{ID,CSTATE,NSTATE,SHLV,TIMER,XPOS,YPOS},{id,1,POPULATION}];

(*Order scheduled state changes by timer.*)
Do[dsIDList[state]=CreateDataStructure["PriorityQueue",{},(Order[-agList[[#1]][[TIMER]],-agList[[#2]][[TIMER]]])&],{state,{PROTECTED,EXPOSED,MILD,SEVERE}}]
(*Store susceptible and dead agents in stacks.*)
dsIDList[DEAD]=CreateDataStructure["Stack"];
dsIDList[SUSCEPTIBLE]=CreateDataStructure["Stack"];

(*Hold updated agents before updating state collections.*)
dsBuffer=CreateDataStructure["Stack"];

(*Store state counts for each time step.*)
Do[dsStTraject[state]=CreateDataStructure["Stack"],{state,SUSCEPTIBLE,DEAD}];

(*Store agent snapshots for animation.*)
dsAgTraject=CreateDataStructure["Stack"];

(*Read recorded histories as lists.*)
Clear[AgTraject,stTraject];
AgTraject:=Normal[dsAgTraject];
stTraject[state_]:=Normal[dsStTraject[state]];
