import numpy as np
from SALib.sample import saltelli
import numpy as np

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

param_values = saltelli.sample(problemDef, 1024)
np.savetxt("param_values.txt", param_values)
