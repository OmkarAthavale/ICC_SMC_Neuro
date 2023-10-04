# ICC_SMC_Neuro

Reproduces data from [1].

Run scripts in the sequence shown below to reproduce data and figures - figures are saved in generated_fig. 
Outputs for scripts 1-4 are provided, and scripts can be run starting at 5 to generate figures without re-generating data outputs. 
Note that Figure 1 is a model illustration, not a simulation result. 

### Data generation scripts
1. Parameter optimisation procedure step 1: parameter_optimisation/optim_ICC.m
2. Parameter optimisation procedure step 2: parameter_optimisation/optim_SMC.m
3. Sensitivity analysis sampling: SA1_sampling.py
4. Sensitivity analysis parallel simulation: parallel_SA_simulate.m

### Plotting scripts
5. Figure 2A: baseline_plotter.m 
6. Figure 2B: aligned_event_plot.m
7. Figure 3: parameter_sweep_1D_combinedPlot.m
8. Figure 4: optimisation_results.m
9. Figure 5A-B: dosage_sweep_plot.m
10. Figure 5C: stimulation_plotter.m
11. Figure 6: SA2_analysis_plot.py

### Dependencies
The following MATLAB toolboxes are required to run the MATLAB scripts as is: Statistics, Signal Processing, Parallel Computing, Optimization.
The following Python libraries are required to run the sensitivity analysis Python scripts as is: numpy, matplotlib, SALib. These can be installed via pip from PyPI.

### References
[1] Athavale, O. N., Avci, R., Clark, A. R., Di Natale, M. R., Wang, X., Furness, J. B., Liu, Z., Cheng, L. K., & Du, P. A mathematical model of the neural regulation of slow waves and phasic contractions in the distal stomach. Unpublished.
