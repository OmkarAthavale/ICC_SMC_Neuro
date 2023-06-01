import numpy as np
from SALib.sample import saltelli
import numpy as np

problemDef = {
    'num_vars': 4,
    'names': ['k_iAno1', 'k_iNSCC', 'k_iCa50', 'k_iSK'],
    'bounds': [[0.25355, 0.35258],
               [0.76517, 0.79896],
               [0.38393, 0.40164],
               [0.29620, 0.33465]
              ]
}

param_values = saltelli.sample(problemDef, 1024)
np.savetxt("param_values.txt", param_values)
