
COVID-19 Vaccination Strategy Simulation
======================================================================


This is an agent-based simulation that is written to study the following research question:

“When the total vaccine supply is limited, what is the optimal allocation between receiving only one dose each and agents receiving two doses?”

The current version of the code executes the simulation under the prescribed vaccine distribution ratio. It does not return the optimal ratio.

For detailed information about the simulation, please refer to https://academicworks.cuny.edu/cgi/viewcontent.cgi?article=2020&context=hc_sas_etds.

----------------------------------------------------------------------
1. How to execute the simulation
----------------------------------------------------------------------

(1) Install Wolfram Mathematica. Any version that was released 2022 should work.

(2) Download the ZIP file and extract it.

(3) Open main.nb

(4) Either select the first cell, or place the cursor anywhere in it

(5) Either press Shift+Enter, or click Evaluation >> Evaluate cells on the menu bar.

(6) After the evaluation, check the time series and the animation. The output will be produced in a couple of seconds in default setting.


----------------------------------------------------------------------
2. The Simulation Model
----------------------------------------------------------------------

The traditional aggregate approach normally takes into account the number of agents in different health statuses, without considering individual locations and their mobility.
In this simulation, agents’ mobility is a crucial part of virus transmission.

2.1 Virtual space and multi-cell

- The virtual space is represented as a grid with default size 14 x 4, and multiple agents can be in the same cell (can be changed in src/constants.wl).

- Their initial locations are random.

- The agents in the same cell are considered to be within the safety distance and they may transmit the virus to the succeptible agents in the same cell with a prescribed probability.

2.2. Movement rule

- At each time slot, agents that are SUSCEPTIBLE, EXPOSED or MILD state either stay in the current cell or one of the eight adjacent cells uniformly at random.

- The severe and the dead are removed from the grid. The severe are moved back to the grid when they have recovered. The dead is removed permanently.

2.3. Virus transmission

- Since the severe are confined, only the exposed and the mild can transmit the virus to the susceptible. If the susceptible are in the same cell with the exposed or the mild, each susceptible is exposed to the virus by the following probability:

1-(1-perCapitaRate)^n,

where n is the number of contagious agents in the cell.

2.4. Health states and protection levels

- Each agent has one of the following six health states: SUSCEPTIBLE, PROTECTED, EXPOSED, MILD, SEVERE and DEAD

- Moreover, each agent has one of the following protection levels: NONE, PARTIAL and FULL based on their vaccination status and the prescribed probability for the antibody development (or, shield production).

- An agent at PARTIAL or FULL protection level can create a shield, i.e., develop the corresponding antibody with prescribed delays and probability.  

- The disease progression, recovery, death and loss of protection are processed by the prescribed transmission probabilities and delays.


----------------------------------------------------------------------
3. Configuration
----------------------------------------------------------------------

- There is no separate configuration file.
- The initial exposed rate, the total amount of vaccines and the number of agents receiving only one dose can be changed in the main.nb
- All other probabilities and rates can be modified in src/constants.wl
- If recordAgents is set to false, the simulation produces only the time series.
- The simulation is supposed to run for 180 simulation days, but the simulation can end if there are no agents in EXPOSED or MILD states. This 180 can be modified in src/initialization.wl

----------------------------------------------------------------------
4. Output
----------------------------------------------------------------------

4.1. Time series

- By default, it shows how the number of agents in each disease state changes over 180 days.
- In the default setting 96 time slots represent one day (one time slot = 15 minutes).
- Each curve represents the number of total number of agents in the corresponding health state at corresponding time. For example, the curve for EXPOSED must not be interpreted as the number of the new exposed per day or the cumulative number of exposed.

4.2. Animation

- Each agent is represented by a circle with an ID in it.
- The severe and the dead are placed in a separate area below the grid.
- To play the animation, click + button on the top left corner in the animation box, and click the play button.
- One can modify the speed of the animation, or drag the status bar to the left or right.


----------------------------------------------------------------------
5. Program files
----------------------------------------------------------------------
- main.nb: An executable Mathematica file.
- src
  - /constants.wl: Constants, the transition probabilities and delays
  - /datastructure.wl: Data structures for agents’ history (health states, location, etc)
  - /dynamics.wl: Virus transmission probability, antibody-production rule and agent-movement rule.
  - /visualization.wl: Time series and animation
  - /initialization.wl: Initialization of the program
  - /simulation.wl: The main loop of the simulation

- Load sequence of the modules: constants.wl -> datastructure.wl -> dynamics.wl -> visualization.wl -> initialization.wl -> simulation.wl


----------------------------------------------------------------------
6. How to use the simulation
----------------------------------------------------------------------

- Fix the vaccine supply, population, grid size and the initial exposed rate and the disease parameters, and try various partialAllocationControl.

- Since the simulation is a random process, repeat the simulation under multiple seed numbers.

