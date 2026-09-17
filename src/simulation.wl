(* ::Package:: *)

(* ::Input::Initialization:: *)
(*Run time steps and optionally record agent snapshots.*)
Clear[mainloop];

mainloop[recordAgents_:True]:=( 
Do[(*Move susceptible,exposed,and mildly ill agents.*)
Do[relocateAgent[timeslot]/@Normal[dsIDList[state]],{state,{SUSCEPTIBLE,EXPOSED,MILD}}];
(*Test new exposures among susceptible agents.*)
setNext[timeslot]/@Normal[dsIDList[SUSCEPTIBLE]];dsIDList[SUSCEPTIBLE]["DropAll"];
(*Apply state changes due at the current time step.*)
Do[While[!dsIDList[state]["EmptyQ"]&&agList[[dsIDList[state]["Peek"]]][[TIMER]]===timeslot,evolveDisease[timeslot][dsIDList[state]["Pop"]];];,{state,{PROTECTED,EXPOSED,MILD,SEVERE}}];

(*Update agents whose protection is developing.*)
checkSpecialCases[timeslot]/@agCreatingShldList;

(*Return buffered agents to their state collections.*)
releaseBuffer/@Normal[dsBuffer];
dsBuffer["DropAll"];

(*Reset local infectious counts for the next time step.*)
memoMat=Table[0,{x,1,XSIZE},{y,1,YSIZE}];

(*Save state counts and optional agent snapshots.*)
Do[dsStTraject[state]["Push",dsIDList[state]["Length"]],{state,SUSCEPTIBLE,DEAD}];
If[TrueQ[recordAgents],dsAgTraject["Push",agList]];
(*Stop early when no exposed or mildly ill agents remain.*)
If[dsIDList[EXPOSED]["Length"]===0&&dsIDList[MILD]["Length"]===0,maxtimeslot=timeslot;Break[]];,{timeslot,2,maxtimeslot}]
);
