import numpy as np
from SALib.sample import saltelli
import numpy as np

from SALib.analyze import sobol
from matplotlib import pyplot as plt

print("Def SA problem")
problemDef = {
    'num_vars': 5,
    'names': ['k_iAno1', 'k_iNSCC', 'k_iCa50', 'k_iSK', 'k_eIP3'],
    'bounds': [[0.28873, 0.34498],
               [0.76787, 0.78711],
               [0.37868, 0.40218],
               [0.29319, 0.34290],
               [0.82, 1]
              ]
}

print("Load results")
Y_freq = np.loadtxt("output_frequency.txt", float)
Y_amp = np.loadtxt("output_plateau.txt", float)

Si_freq = sobol.analyze(problemDef, Y_freq)
Si_amp = sobol.analyze(problemDef, Y_amp)

fig, axes = plt.subplots(nrows=2, ncols=2, figsize=(4.48,4), tight_layout=True)

axes[0, 0].bar(np.array(np.linspace(0, problemDef['num_vars']-1, problemDef['num_vars'])), Si_amp['S1'], tick_label=problemDef['names'], yerr=Si_amp['S1_conf'], fill=False)
axes[0, 0].set_ylim(0, 1.2)
axes[0, 0].set_xticklabels([])
axes[0, 0].set_ylabel('$\mathregular{S_1}$')
axes[0, 0].set_title('Amplitude Metric')

axes[0, 1].bar(np.array(np.linspace(0, problemDef['num_vars']-1, problemDef['num_vars'])), Si_freq['S1'], tick_label=problemDef['names'], yerr=Si_freq['S1_conf'], fill=False)
axes[0, 1].set_ylim(0, 1.2)
axes[0, 1].set_xticklabels([])
axes[0, 1].set_yticklabels([])
axes[0, 1].set_title('Frequency Metric')

axes[1, 0].bar(np.array(np.linspace(0, problemDef['num_vars']-1, problemDef['num_vars'])), Si_amp['ST'], tick_label=problemDef['names'], yerr=Si_amp['ST_conf'], fill=False)
axes[1, 0].set_ylim(0, 1.2)
axes[1, 0].set_ylabel('$\mathregular{S_T}$')

axes[1, 1].bar(np.array(np.linspace(0, problemDef['num_vars']-1, problemDef['num_vars'])), Si_freq['ST'], tick_label=problemDef['names'], yerr=Si_freq['ST_conf'], fill=False)
axes[1, 1].set_ylim(0, 1.2)
axes[1, 1].set_yticklabels([])

fig.savefig('../generated_fig/SA_bar_charts.svg')

total_amp, first_amp, second_amp = Si_amp.to_df()
print('Amplitude')
print(total_amp)
print(first_amp)
print(second_amp)

total_freq, first_freq, second_freq = Si_freq.to_df()
print('Frequency')
print(total_freq)
print(first_freq)
print(second_freq)