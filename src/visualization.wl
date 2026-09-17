(* ::Package:: *)

(* ::Input::Initialization:: *)
(*Colors and labels for disease states.*)

bgColor[state_]:=Which[state===SUSCEPTIBLE,LightGreen,state===EXPOSED,LightOrange,state===MILD,LightBrown,state===PROTECTED,LightBlue,state===SEVERE,LightRed,state===DEAD,LightGray]

stColor[SUSCEPTIBLE]=Darker[Green];
stColor[EXPOSED]=Orange;
stColor[MILD]=Brown;
stColor[PROTECTED]=Blue;
stColor[SEVERE]=Red;
stColor[DEAD]=Black;

visualizeState[SUSCEPTIBLE]=Text[Style["SUSCEPTIBLE",stColor[SUSCEPTIBLE],Bold],Background->bgColor[SUSCEPTIBLE]];
visualizeState[EXPOSED]=Text[Style["EXPOSED",stColor[EXPOSED],Bold],Background->bgColor[EXPOSED]];
visualizeState[MILD]=Text[Style["MILD",stColor[MILD],Bold],Background->bgColor[MILD]];
visualizeState[PROTECTED]=Text[Style["PROTECTED",stColor[PROTECTED],Bold],Background->bgColor[PROTECTED]];
visualizeState[SEVERE]=Text[Style["SEVERE",stColor[SEVERE],Bold],Background->bgColor[SEVERE]];
visualizeState[DEAD]=Text[Style["DEAD",stColor[DEAD],Bold],Background->bgColor[DEAD]];

(*Format a full agent record for display.*)
visualizeAgent[{id_,cstate_,nstate_,shlv_,timer_,xpos_,ypos_}]:=Block[{visualizedShlv,visualizedTimer},visualizedShlv=Which[shlv===NONE,"NONE",Or[shlv===PARTIAL],Text[Style["PARTIAL",Bold],Background->RGBColor["#D3D3D3"]],shlv===FULL,Text[Style["FULL",Bold],Background->RGBColor["#FFD700"]]];
visualizedTimer=If[timer=!=\[Infinity],Style[ToString[timer],Bold],Style["\[Infinity]",Bold]];
{id,visualizeState[cstate],visualizeState[nstate],visualizedShlv,visualizedTimer,xpos,ypos}]

(*Look up an agent from an ID and timer pair.*)
visualizeAgent[{id_,timer_}]:=visualizeAgent[agList[[id]]]

(*Display the count for each disease state.*)
visualizedCountsTotal[countsTotal_]:=Row[Table[Row[{visualizeState[cstate],": ",countsTotal[[cstate]],"  "}],{cstate,SUSCEPTIBLE,DEAD}]]

(*Plot state histories with a legend.*)
listplot[1]:=ListLinePlot[Table[stTraject[state],{state,SUSCEPTIBLE,DEAD}],PlotRange->{{0,maxtimeslot},{0,POPULATION}},PlotStyle->Table[stColor[state],{state,SUSCEPTIBLE,DEAD}],PlotLegends->SwatchLegend[Table[visualizeState[state],{state,SUSCEPTIBLE,DEAD}],LegendFunction->(Framed[#,RoundingRadius->5]&),LegendLayout->"Row"],ImageSize->500]
(*Plot state histories without a legend.*)
listplot[0]:=ListLinePlot[Table[stTraject[state],{state,SUSCEPTIBLE,DEAD}],PlotRange->{{0,maxtimeslot},{0,POPULATION}},PlotStyle->Table[stColor[state],{state,SUSCEPTIBLE,DEAD}]]

(*Grid layout for spatial displays.*)
cpad=.5;
gridlines={Table[.5+i,{i,0,XSIZE}],Table[.5+j,{j,0,YSIZE}]};
(*Build display positions from recorded agent snapshots.*)
buildLocTrj[]:=Block[{temp=AgTraject},Table[Table[Block[{id2,cstate,nstate,shlv,timer,xpos,ypos,q1,q2,r1,r2,c,r},{id2,cstate,nstate,shlv,timer,xpos,ypos}=temp[[timeslot]][[id]];
Which[cstate===SEVERE,{q1,r1}=QuotientRemainder[id,9];
{q2,r2}=QuotientRemainder[r1,3];
{xpos,ypos}={q1+1-(((0.1)/(4))+0.3),-1+(((0.1)/(4))+0.3)}+{r2*(((0.1)/(4))+0.3),-q2*(((0.1)/(4))+0.3)},cstate===DEAD,{q1,r1}=QuotientRemainder[id,9];
{q2,r2}=QuotientRemainder[r1,3];
{xpos,ypos}={q1+1-(((0.1)/(4))+0.3),-1+(((0.1)/(4))+0.3)}+{r2*(((0.1)/(4))+0.3),-q2*(((0.1)/(4))+0.3)}+{0,-1},True,xpos+=RandomReal[{-0.5+0.15,0.5-0.15}];
ypos+=RandomReal[{-0.5+0.15,0.5-0.15}];];
{id2,cstate,nstate,shlv,timer,xpos,ypos}],{id,1,POPULATION}],{timeslot,1,Length[temp]}]]

(*Check agent history and prepare animation data.*)
Clear[prepareAnimation];
prepareAnimation::history="Agent history is missing. Run initialize[...] and mainloop[True] first.";

prepareAnimation[]:=Module[{},If[dsAgTraject["Length"]<2,Message[prepareAnimation::history];
Return[$Failed];];
locTrj=BlockRandom[buildLocTrj[]];
Null];

(*Draw one recorded time step.*)
visualizeSettlement[timeslot_]:=Column[{Show[Graphics[Table[Block[{cstate,xpos,ypos,pos},cstate=locTrj[[timeslot]][[id]][[CSTATE]];
pos={locTrj[[timeslot]][[id]][[XPOS]],locTrj[[timeslot]][[id]][[YPOS]]};
{xpos,ypos}={pos[[1]],pos[[2]]};
{{EdgeForm[{Thickness[Large],stColor[cstate]}],bgColor[cstate],Opacity[.6],Disk[{xpos,ypos},{.15,.15}]},Text[Style[id,Black,Bold,FontSize->10],{xpos+.02,ypos-.02}]}],{id,1,POPULATION}],GridLines->gridlines,Frame->True,ImageSize->Scaled[.6]],Graphics[Line[{{cpad,cpad},{XSIZE+cpad,cpad},{XSIZE+cpad,YSIZE+cpad},{cpad,YSIZE+cpad},{cpad,cpad}}]],Graphics[{Line[{{cpad,-cpad},{XSIZE+cpad,-cpad},{XSIZE+cpad,-(2+cpad)},{cpad,-(2+cpad)},{cpad,-cpad}}],{Dashed,Line[{{cpad,-1-cpad},{XSIZE+cpad,-1-cpad}}]}},GridLines->gridlines,Frame->True]],Row[Table[Row[{visualizeState[state],"     "}],{state,SUSCEPTIBLE,DEAD}]]},Alignment->Center]

(*Interpolate positions between recorded time steps.*)
animate[timeslot_]:=Column[{Show[Graphics[Table[Block[{cstate,pos1,pos2,xpos,ypos},cstate=locTrj[[Floor[timeslot+1]]][[id]][[CSTATE]];
pos1={locTrj[[Floor[timeslot]+1]][[id]][[XPOS]],locTrj[[Floor[timeslot]+1]][[id]][[YPOS]]};
pos2={locTrj[[Floor[timeslot]+2]][[id]][[XPOS]],locTrj[[Floor[timeslot]+2]][[id]][[YPOS]]};
{xpos,ypos}=(1-(timeslot-Floor[timeslot]))*pos1+(timeslot-Floor[timeslot])*pos2;
{{EdgeForm[{Thickness[Large],stColor[cstate]}],bgColor[cstate],Opacity[.6],Disk[{xpos,ypos},{.15,.15}]},Text[Style[id,Black,Bold,FontSize->10],{xpos+.02,ypos-.02}]}],{id,1,POPULATION}],GridLines->gridlines,Frame->True,ImageSize->Scaled[.6]],Graphics[Line[{{cpad,cpad},{XSIZE+cpad,cpad},{XSIZE+cpad,YSIZE+cpad},{cpad,YSIZE+cpad},{cpad,cpad}}]],Graphics[{Line[{{cpad,-cpad},{XSIZE+cpad,-cpad},{XSIZE+cpad,-(2+cpad)},{cpad,-(2+cpad)},{cpad,-cpad}}],{Dashed,Line[{{cpad,-1-cpad},{XSIZE+cpad,-1-cpad}}]}},GridLines->gridlines,Frame->True]],Row[Table[Row[{visualizeState[state],"     "}],{state,SUSCEPTIBLE,DEAD}]]},Alignment->Center]
