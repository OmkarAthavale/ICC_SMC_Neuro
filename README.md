# ICC_SMC_Neuro

Reproduces data from [1].

Run scripts in the sequence shown below to reproduce figures - figures are saved in generated_fig.

### Data generation scripts
1. Parameter optimisation procedure step 1: parameter_optimisation/optim_ICC.m
2. Parameter optimisation procedure step 2: parameter_optimisation/optim_SMC.m
3. Sensitivity analysis sampling: SA1_sampling.py
4. Sensitivity analysis parallel simulation: parallel_SA_simulate.m

### Plotting scripts
6. Figure 2A: baseline_plotter.m 
7. Figure 2B: aligned_event_plot.m
8. Figure 3: parameter_sweep_1D_combinedPlot.m
9. Figure 4: optimisation_results.m
10. Figure 5A: dosage_sweep_plot.m
11. Figure 5B: stimulation_plotter.m
12. Figure 6: SA2_analysis_plot.py

Note that Figure 1 is a model illustration, not a simulation result. 

[1] Athavale, O. N., Avci, R., Clark, A. R., Di Natale, M. R., Wang, X., Furness, J. B., Liu, Z., Cheng, L. K., & Du, P. (2023). A mathematical model of the neural regulation of slow waves and phasic contractions in the distal stomach. Unpublished.
