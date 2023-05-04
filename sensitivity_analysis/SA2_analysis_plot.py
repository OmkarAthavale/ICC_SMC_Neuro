import numpy as np
from SALib.sample import saltelli
import numpy as np

from SALib.analyze import sobol
from matplotlib import pyplot as plt

print("Def SA problem")
problemDef = {
    'num_vars': 4,
    'names': ['k_iAno1', 'k_iNSCC', 'k_iCa50', 'k_iSK'],
    'bounds': [[0.25355, 0.35258],
               [0.76517, 0.79896],
               [0.38393, 0.40164],
               [0.29620, 0.33465]
              ]
}

print("Load results")
Y_freq = np.loadtxt("output_frequency.txt", float)
Y_amp = np.loadtxt("output_plateau.txt", float)

Si_freq = sobol.analyze(problemDef, Y_freq)
Si_amp = sobol.analyze(problemDef, Y_amp)

fig, axes = plt.subplots(nrows=2, ncols=2, figsize=(4.48,4), tight_layout=True)

axes[0, 0].bar(np.array(np.linspace(0, 3, 4)), Si_amp['S1'], tick_label=problemDef['names'], yerr=Si_amp['S1_conf'], fill=False)
axes[0, 0].set_ylim(0, 1.5)
axes[0, 0].set_xticklabels([])
axes[0, 0].set_ylabel('$\mathregular{S_1}$')
axes[0, 0].set_title('Amplitude Metric')

axes[0, 1].bar(np.array(np.linspace(0, 3, 4)), Si_freq['S1'], tick_label=problemDef['names'], yerr=Si_freq['S1_conf'], fill=False)
axes[0, 1].set_ylim(0, 1.5)
axes[0, 1].set_xticklabels([])
axes[0, 1].set_yticklabels([])
axes[0, 1].set_title('Frequency Metric')

axes[1, 0].bar(np.array(np.linspace(0, 3, 4)), Si_amp['ST'], tick_label=problemDef['names'], yerr=Si_amp['ST_conf'], fill=False)
axes[1, 0].set_ylim(0, 1.5)
axes[1, 0].set_ylabel('$\mathregular{S_T}$')

axes[1, 1].bar(np.array(np.linspace(0, 3, 4)), Si_freq['ST'], tick_label=problemDef['names'], yerr=Si_freq['ST_conf'], fill=False)
axes[1, 1].set_ylim(0, 1.5)
axes[1, 1].set_yticklabels([])

fig.savefig('SA_bar_charts.svg')