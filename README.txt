Escalator Toolbox v0.1 for perception action research
Copyright (C) 2016,  John Franchak (franchak@gmail.com)
https://github.com/JohnFranchak/escalator_toolbox

LICENSE 

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

IMPORTANT NOTE REGARDING PALAMEDES

Please note that the Palamedes Toolbox, which is required to use Escalator, 
is not in any way associated with the Escalator Toolbox project. Escalator calls Palamedes toolbox functions for curve fitting, bootstrapping, and goodness of fit procedures. If you use the Escalator Toolbox, be sure to acknowledge the use of the Palamedes Toolbox in your paper:

Prins, N & Kingdom, F. A. A. (2009) Palamedes: Matlab routines for analyzing psychophysical data.  http://www.palamedestoolbox.org 

PURPOSE

The Escalator Toolbox is a collection of Matlab functions designed for perception-action researchers to run data collections and process the resulting data. Additional functionality lets users simulate data collections to test trial procedures prospectively and explore how trial procedures affect the resulting data. 

- Data collection. The primary function of the Escalator Toolbox is to run adaptive procedures to find perceptual and/or motor thresholds in action/action judgment tasks. Efficient trial procedures can save researchers from running more trials than are needed to get sound estimates of participants’ abilities. Users can choose a variety of blocks of trials to present, such as staircase, binary search, ordered, and randomized blocks [It’s more than just a staircase…it’s an escalator! Get it?]. Curve fits are graphed after each trial so you can monitor how well the software is finding the threshold over time. Trial outputs are saved to a .csv file for easy importing into other software, and summary data are available in the Matlab variable output that can be saved to a .mat file (but this isn’t done automatically). See FUNCTION DESCRIPTIONS for more details about how to create different blocks of trials or look through one of the ANNOTATED EXAMPLES.

- Curve fitting. The Escalator Toolbox relies on the Palamedes Toolbox, one of the standard psychophysical toolboxes, to fit psychometric functions to your data. Functions are fit automatically during and after your data are collected, providing parameter estimates for the threshold and slope of the cumulative Gaussian model (other psychometric functions are not supported right now). Bundled functions let you view and save graphs of your curve fit with raw trial data for visualization. 

- Goodness of fit. Using Palamedes Toolbox functions, Escalator lets you assess the goodness of fit and calculate bootstrapped confidence intervals for your threshold and slope parameters. 

- Simulation. While the main purpose of Escalator is to run live data collections, the simulation mode lets you run an entire procedure based on a simulated participant. Supply a true threshold and slope and see how well your procedure does at estimating the threshold. Tweak your settings in simulation mode before running live participants and realizing you needed more trials or a different set of increments. Run goodness of fit tests to anticipate how well fits will be given the quality of raw data. Using simulations also lets users explore how curve fitting works by playing with different settings. Run your own brute force power analysis by simulating hundreds or thousands of participants for your anticipated effect to see what proportion of time your trial procedure finds the difference. 

COMPATIBILITY

The Escalator Toolbox was tested in Matlab 2016a and Palamedes Toolbox v1.80. Compatibility with prior/future versions of Matlab/Palamedes is not guaranteed.

SETUP

Download the toolbox from git and place the ‘escalator_toolbox’ folder in your Matlab directory or a directory of your choosing. The entire Palamedes Toolbox must be contained in a folder named ‘Palamedes’ within the ‘escalator_toolbox’ folder to function correctly. To download Palamedes, visit http://www.palamedestoolbox.org. To test that your setup is correct, run one of the example scripts. If you want to call Escalator Toolbox functions outside of the escalator_toolbox folder, be sure to add the folder and sub-folders to your Matlab path. 

GETTING STARTED

First, what do you need to know to use the Escalator Toolbox? Users should have some basic knowledge of Matlab, but the routines are written simply enough that a beginner can figure it out after looking through the examples. A great text for learning Matlab is Rosenbaum, Vaughan, & Wyble ‘MATLAB for Behavioral Scientists’ http://cw.routledge.com/textbooks/matlab/. To fully understand how the adaptive procedures and curve fitting works, Kingdom and Prins have a fantastic textbook that can be downloaded through most university libraries that explains the basic concepts with examples of how to run them in Palamedes. http://store.elsevier.com/Psychophysics/Frederick-Kingdom/isbn-9780080920221/. 

Once you’re ready to start, I recommend checking out the ANNOTATED EXAMPLES, explained in more detail below. One example covers a live data collection and the other demonstrates a simulation. The easiest way to program your own experiment script is to copy one of the examples into a new Matlab .m script file and edit to your needs. If you’re having trouble with the syntax for any of the functions listed below, either open up the function in the Matlab code editor or type ‘help function_name’ in the Matlab console to read the function descriptions. I recommend that you set up your entire data collection procedure in a script (rather than typing commands in the console) so that you can easily replicate your procedure each time. 

FUNCTION DESCRIPTIONS

For each function, see the help information for more details about specific input/output parameters and options. This is just a broad overview of the included functionality of the toolbox.

- trialBlock: Trial block is the main function in the Escalator Toolbox. Everything else is either used to set up the initial conditions to run trialBlock or is used to process the output from trialBlock. trialBlock specifies a set of trial procedures to estimate 1 function for a single condition/phase of the experiment. A simple experiment might need only a single call of trialBlock (estimating a single perceptual judgment threshold), but users can configure multiple trialBlocks in order to run more complex designs, such as a pretest judgment block, followed by an action block, followed by a posttest judgment block (running trialBlock 3 times with different parameters). Each trialBlock runs one or more *sub blocks* that the users configures with creation functions listed below. These sub blocks give users the flexibility to use a variety of different adaptive (or not adaptive) procedures that are commonly used. In a live data collection, the Matlab console displays the unit to run on each trial and receives trial outcome input from the user. Optional parameters convert trialBlock from a live data collection to a simulated data collection. 

The trial creation functions are:
- createStaircaseBlock: Run an n-down/m-up staircase procedure to find a threshold from a given starting unit and specified number of trials. 
- createBinaryBlock: Use a binary search procedure to rapidly hone in on a threshold
- createBlockedBlock: Specify a set of units to present in a particular (or random order) for fixed trials. 
- createRandomBlock: Coming soon.

Post processing functions:
- fitPsych: Uses maximum likelihood estimation to fit a cumulative Gaussian to the data with threshold and slope parameters. The function is setup to directly fit the results from a trialBlock or can be configured to run on raw data specified by the user (in cases where Escalator is not used for data collection but only post processing)
- bootstrapCI: A parametric bootstrap of the data. Data are resamples over many Monte Carlo iterations to yield confidence intervals of the parameters, mean resampled parameters, and standard deviations of parameter estimates.
- goodnessOfFit: Calculate the deviance of curve fits
- psychometricFxGraph: Graph the psychometric function overlaid against the raw trial data 
- moa

ANNOTATED EXAMPLES

Annotated scripts are included that show how to use the toolbox in various ways:

exampleDataCollectionScript - Runs a simple experiment to estimate a single slope and threshold. A staircase and blocked sub block are created and then run in a single trialBlock. Afterwards, the output is refit using fitPsych and then graphed with psychometricFxGraph. Goodness of fit and bootstrapped CIs are calculated using the output from trialBlock. 95% confidence intervals are graphed overlaid on the psychometric function graph to illustrate the CI on top of the data and original fit. 

exampleSimulation Script - %Implements a basic pretest/practice/posttest design. Pretest trials are judgments, practice trials are used to estimate the affordance function, and posttest trials are judgments, similar to Experiment 3 in Franchak & Adolph (2014) APP. Determine whether the particular sub block procedure (a binary search followed by repeated blocks of trials) yields similar results when simulating data with the same pretest/posttest errors as Franchak & Adolph (2014). 30 participants are simulated with true affordance thresholds of M = 28, SD = 2. Simulate pretest judgments that erred by M = 10.5 cm SD = 6.5 and posttest judgments that erred by 0.5 cm = SD 3. Signed error values are calculated by subtracting the affordance values from the pretest and posttest judgments, and a t test compares pretest and posttest errors. Because simulated participants are randomized, running the function multiple times will procedure varying output. 

SUPPORT

Questions, errors, and suggestions for improvements should be sent to John Franchak (franchak@gmail.com). 