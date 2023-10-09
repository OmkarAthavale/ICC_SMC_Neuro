
function [VOI, STATES, ALGEBRAIC, CONSTANTS] = ICC_SMC_Neuro_Tvar(f_e, f_i, duration)
   % Solves the combined ICC and SMC model with neurotransmission using the fitted weights 
   % and scaling constants but applying sitmulation only between 120 - 180 s. 
   % INPUTS
   % f_e: excitatory stimulation frequency in domain [0, 10]
   % f_i: inhibitory stimulation frequency in domain [0, 10]
   % duration (OPTIONAL): two element array of start and end time for
   %                      ode15s solver. Default [0 240000].
   %
   % OUTPUTS
   % VOI: n x 1 array with variable of integration for n steps (time in 
   %      milliseconds)
   % STATES: n x m array with state variable values at n steps for m (31)
   %         variables (see create legends function for variable sequence and units)
   % ALGEBRAIC: n x o array with algebraic variable values at n steps for o
   %            (82) variables (see create legends function for variable sequence and units)
   % CONSTANTS: 1 x p array with constant variable values for p (199)
   %            variables (see create legends function for variable sequence and units)
    if nargin < 5
        duration = [0 240000];
    end
   [VOI, STATES, ALGEBRAIC, CONSTANTS] = solveModel(f_e, f_i, duration);
end

function [algebraicVariableCount] = getAlgebraicVariableCount()
    % Used later when setting a global variable with the number of algebraic variables.
    % Note: This is not the "main method".
    algebraicVariableCount =72;
end
% There are a total of 22 entries in each of the rate and state variable arrays.
% There are a total of 151 entries in the constant variable array.
%

function [VOI, STATES, ALGEBRAIC, CONSTANTS] = solveModel(f_e, f_i, duration)
    % Create ALGEBRAIC of correct size
    global algebraicVariableCount;  algebraicVariableCount = getAlgebraicVariableCount();
    % Initialise constants and state variables
    [INIT_STATES, CONSTANTS] = initConsts(f_e, f_i);

    % Set timespan to solve over
    tspan = duration;

    % Set numerical accuracy options for ODE solver
    options = odeset('RelTol', 1e-06, 'AbsTol', 1e-06, 'MaxStep', 1);

    % Solve model with ODE solver
    [VOI, STATES] = ode15s(@(VOI, STATES)computeRates(VOI, STATES, CONSTANTS), tspan, INIT_STATES, options);

    % Compute algebraic variables
    [RATES, ALGEBRAIC] = computeRates(VOI, STATES, CONSTANTS);
    ALGEBRAIC = computeAlgebraic(ALGEBRAIC, CONSTANTS, STATES, VOI);
end

function [LEGEND_STATES, LEGEND_ALGEBRAIC, LEGEND_VOI, LEGEND_CONSTANTS] = createLegends()
    LEGEND_STATES = ''; LEGEND_ALGEBRAIC = ''; LEGEND_VOI = ''; LEGEND_CONSTANTS = '';
    LEGEND_VOI = strpad('time in component Time (time_units)');
    LEGEND_CONSTANTS(:,1) = strpad('T in component Environment (Temperature_units)');
    LEGEND_CONSTANTS(:,2) = strpad('T_exp in component Environment (Temperature_units)');
    LEGEND_CONSTANTS(:,3) = strpad('F in component Environment (F_units)');
    LEGEND_CONSTANTS(:,4) = strpad('R in component Environment (R_units)');
    LEGEND_CONSTANTS(:,5) = strpad('Q10Ca in component Environment (dimensionless)');
    LEGEND_CONSTANTS(:,6) = strpad('Q10K in component Environment (dimensionless)');
    LEGEND_CONSTANTS(:,7) = strpad('Q10Na in component Environment (dimensionless)');
    LEGEND_CONSTANTS(:,8) = strpad('Ca_o in component Environment (millimolar)');
    LEGEND_CONSTANTS(:,9) = strpad('Na_o in component Environment (millimolar)');
    LEGEND_CONSTANTS(:,10) = strpad('K_o in component Environment (millimolar)');
    LEGEND_CONSTANTS(:,11) = strpad('Cl_o in component Environment (millimolar)');
    LEGEND_CONSTANTS(:,122) = strpad('T_correction_Na in component Environment (dimensionless)');
    LEGEND_CONSTANTS(:,123) = strpad('T_correction_K in component Environment (dimensionless)');
    LEGEND_CONSTANTS(:,124) = strpad('T_correction_Ca in component Environment (dimensionless)');
    LEGEND_CONSTANTS(:,125) = strpad('T_correction_BK in component Environment (conductance_units)');
    LEGEND_CONSTANTS(:,126) = strpad('FoRT in component Environment (Inverse_Voltage_units)');
    LEGEND_CONSTANTS(:,127) = strpad('RToF in component Environment (voltage_units)');
    LEGEND_CONSTANTS(:,12) = strpad('Cm_SM in component SM_Membrane (capacitance_units)');
    LEGEND_CONSTANTS(:,13) = strpad('Vol_SM in component SM_Membrane (volume_units)');
    LEGEND_STATES(:,1) = strpad('Vm_SM in component SM_Membrane (voltage_units)');
    LEGEND_STATES(:,2) = strpad('Ca_i in component SM_Membrane (millimolar)');
    LEGEND_CONSTANTS(:,14) = strpad('Na_i in component SM_Membrane (millimolar)');
    LEGEND_CONSTANTS(:,15) = strpad('K_i in component SM_Membrane (millimolar)');
    LEGEND_ALGEBRAIC(:,54) = strpad('I_Na_SM in component I_Na_SM (current_units)');
    LEGEND_ALGEBRAIC(:,27) = strpad('I_Ltype_SM in component I_Ltype_SM (current_units)');
    LEGEND_ALGEBRAIC(:,33) = strpad('I_LVA_SM in component I_LVA_SM (current_units)');
    LEGEND_ALGEBRAIC(:,51) = strpad('I_kr_SM in component I_kr_SM (current_units)');
    LEGEND_ALGEBRAIC(:,58) = strpad('I_ka_SM in component I_ka_SM (current_units)');
    LEGEND_ALGEBRAIC(:,37) = strpad('I_BK_SM in component I_BK_SM (current_units)');
    LEGEND_ALGEBRAIC(:,41) = strpad('S_iSK in component neural_input (dimensionless)');
    LEGEND_ALGEBRAIC(:,44) = strpad('I_SK_SM in component I_SK_SM (current_units)');
    LEGEND_ALGEBRAIC(:,65) = strpad('I_NSCC_SM in component I_NSCC_SM (current_units)');
    LEGEND_ALGEBRAIC(:,47) = strpad('I_bk_SM in component I_bk_SM (current_units)');
    LEGEND_ALGEBRAIC(:,29) = strpad('J_CaSR_SM in component J_CaSR_SM (millimolar_per_millisecond)');
    LEGEND_ALGEBRAIC(:,6) = strpad('I_couple in component I_couple (current_units)');
    LEGEND_CONSTANTS(:,16) = strpad('g_couple in component I_couple (conductance_units)');
    LEGEND_STATES(:,3) = strpad('Vm in component ICC_Membrane (voltage_units)');
    LEGEND_ALGEBRAIC(:,1) = strpad('d_inf_Ltype_SM in component d_Ltype_SM (dimensionless)');
    LEGEND_CONSTANTS(:,139) = strpad('tau_d_Ltype_SM in component d_Ltype_SM (time_units)');
    LEGEND_STATES(:,4) = strpad('d_Ltype_SM in component d_Ltype_SM (dimensionless)');
    LEGEND_ALGEBRAIC(:,2) = strpad('f_inf_Ltype_SM in component f_Ltype_SM (dimensionless)');
    LEGEND_CONSTANTS(:,140) = strpad('tau_f_Ltype_SM in component f_Ltype_SM (time_units)');
    LEGEND_STATES(:,5) = strpad('f_Ltype_SM in component f_Ltype_SM (dimensionless)');
    LEGEND_ALGEBRAIC(:,3) = strpad('f_ca_inf_Ltype_SM in component f_ca_Ltype_SM (dimensionless)');
    LEGEND_CONSTANTS(:,141) = strpad('tau_f_ca_Ltype_SM in component f_ca_Ltype_SM (time_units)');
    LEGEND_STATES(:,6) = strpad('f_ca_Ltype_SM in component f_ca_Ltype_SM (dimensionless)');
    LEGEND_ALGEBRAIC(:,19) = strpad('E_Ca in component I_Ltype_SM (voltage_units)');
    LEGEND_CONSTANTS(:,17) = strpad('G_max_Ltype in component I_Ltype_SM (conductance_units)');
    LEGEND_CONSTANTS(:,18) = strpad('J_max_CaSR in component J_CaSR_SM (millimolar_per_millisecond)');
    LEGEND_ALGEBRAIC(:,4) = strpad('d_inf_LVA_SM in component d_LVA_SM (dimensionless)');
    LEGEND_CONSTANTS(:,142) = strpad('tau_d_LVA_SM in component d_LVA_SM (time_units)');
    LEGEND_STATES(:,7) = strpad('d_LVA_SM in component d_LVA_SM (dimensionless)');
    LEGEND_ALGEBRAIC(:,5) = strpad('f_inf_LVA_SM in component f_LVA_SM (dimensionless)');
    LEGEND_ALGEBRAIC(:,18) = strpad('tau_f_LVA_SM in component f_LVA_SM (time_units)');
    LEGEND_STATES(:,8) = strpad('f_LVA_SM in component f_LVA_SM (dimensionless)');
    LEGEND_ALGEBRAIC(:,31) = strpad('E_Ca in component I_LVA_SM (voltage_units)');
    LEGEND_CONSTANTS(:,19) = strpad('G_max_LVA in component I_LVA_SM (conductance_units)');
    LEGEND_ALGEBRAIC(:,35) = strpad('d_BK_SM in component d_BK_SM (dimensionless)');
    LEGEND_CONSTANTS(:,143) = strpad('E_K in component I_BK_SM (voltage_units)');
    LEGEND_CONSTANTS(:,20) = strpad('G_max_BK in component I_BK_SM (conductance_units)');
    LEGEND_ALGEBRAIC(:,48) = strpad('T in component active_tension (kilopascals)');
    LEGEND_CONSTANTS(:,21) = strpad('Ca50_0 in component active_tension (micromolar)');
    LEGEND_ALGEBRAIC(:,42) = strpad('S_iCa50 in component neural_input (dimensionless)');
    LEGEND_ALGEBRAIC(:,45) = strpad('Ca50 in component active_tension (micromolar)');
    LEGEND_CONSTANTS(:,22) = strpad('h in component active_tension (dimensionless)');
    LEGEND_CONSTANTS(:,23) = strpad('T_max in component active_tension (kilopascals)');
    LEGEND_CONSTANTS(:,24) = strpad('f_e in component neural_input (dimensionless)');
    LEGEND_CONSTANTS(:,25) = strpad('f_i in component neural_input (dimensionless)');
    LEGEND_CONSTANTS(:,26) = strpad('ns_start in component neural_input (time_units_ICC)');
    LEGEND_CONSTANTS(:,27) = strpad('ns_end in component neural_input (time_units_ICC)');
    LEGEND_ALGEBRAIC(:,15) = strpad('w_iICC in component neural_input (dimensionless)');
    LEGEND_ALGEBRAIC(:,39) = strpad('w_iSMC in component neural_input (dimensionless)');
    LEGEND_ALGEBRAIC(:,26) = strpad('w_e in component neural_input (dimensionless)');
    LEGEND_CONSTANTS(:,28) = strpad('f_max in component neural_input (Hertz)');
    LEGEND_CONSTANTS(:,29) = strpad('k_iAno1 in component neural_input (dimensionless)');
    LEGEND_CONSTANTS(:,30) = strpad('k_iNSCC in component neural_input (dimensionless)');
    LEGEND_CONSTANTS(:,31) = strpad('k_iCa50 in component neural_input (dimensionless)');
    LEGEND_CONSTANTS(:,32) = strpad('k_iSK in component neural_input (dimensionless)');
    LEGEND_CONSTANTS(:,33) = strpad('k_eIP3 in component neural_input (dimensionless)');
    LEGEND_ALGEBRAIC(:,28) = strpad('S_iAno1 in component neural_input (dimensionless)');
    LEGEND_ALGEBRAIC(:,30) = strpad('S_iNSCC in component neural_input (dimensionless)');
    LEGEND_ALGEBRAIC(:,32) = strpad('S_eIP3 in component neural_input (dimensionless)');
    LEGEND_CONSTANTS(:,34) = strpad('p_iICC in component neural_input (dimensionless)');
    LEGEND_CONSTANTS(:,35) = strpad('p_iSMC in component neural_input (dimensionless)');
    LEGEND_CONSTANTS(:,36) = strpad('p_e in component neural_input (dimensionless)');
    LEGEND_STATES(:,9) = strpad('x_SK_SM in component x_SK_SM (dimensionless)');
    LEGEND_ALGEBRAIC(:,7) = strpad('x_SK_inf_SM in component x_SK_SM (dimensionless)');
    LEGEND_ALGEBRAIC(:,20) = strpad('tau_x_SK_SM in component x_SK_SM (time_units)');
    LEGEND_CONSTANTS(:,37) = strpad('n in component x_SK_SM (dimensionless)');
    LEGEND_CONSTANTS(:,38) = strpad('EC50 in component x_SK_SM (micromolar)');
    LEGEND_CONSTANTS(:,144) = strpad('E_K in component I_SK_SM (voltage_units)');
    LEGEND_CONSTANTS(:,39) = strpad('G_max_SK in component I_SK_SM (conductance_units)');
    LEGEND_CONSTANTS(:,145) = strpad('E_K in component I_bk_SM (voltage_units)');
    LEGEND_CONSTANTS(:,40) = strpad('G_max_bk in component I_bk_SM (conductance_units)');
    LEGEND_ALGEBRAIC(:,8) = strpad('xr1_inf_SM in component xr1_SM (dimensionless)');
    LEGEND_CONSTANTS(:,146) = strpad('tau_xr1_SM in component xr1_SM (time_units)');
    LEGEND_STATES(:,10) = strpad('xr1_SM in component xr1_SM (dimensionless)');
    LEGEND_ALGEBRAIC(:,9) = strpad('xr2_inf_SM in component xr2_SM (dimensionless)');
    LEGEND_ALGEBRAIC(:,21) = strpad('tau_xr2_SM in component xr2_SM (time_units)');
    LEGEND_STATES(:,11) = strpad('xr2_SM in component xr2_SM (dimensionless)');
    LEGEND_CONSTANTS(:,147) = strpad('E_K in component I_kr_SM (voltage_units)');
    LEGEND_CONSTANTS(:,41) = strpad('G_max_kr_SM in component I_kr_SM (conductance_units)');
    LEGEND_ALGEBRAIC(:,10) = strpad('m_inf_Na in component m_Na_SM (dimensionless)');
    LEGEND_ALGEBRAIC(:,22) = strpad('tau_m_Na in component m_Na_SM (time_units)');
    LEGEND_STATES(:,12) = strpad('m_Na_SM in component m_Na_SM (dimensionless)');
    LEGEND_ALGEBRAIC(:,11) = strpad('h_inf_Na in component h_Na_SM (dimensionless)');
    LEGEND_ALGEBRAIC(:,23) = strpad('tau_h_Na in component h_Na_SM (time_units)');
    LEGEND_STATES(:,13) = strpad('h_Na_SM in component h_Na_SM (dimensionless)');
    LEGEND_CONSTANTS(:,148) = strpad('E_Na in component I_Na_SM (voltage_units)');
    LEGEND_CONSTANTS(:,42) = strpad('G_max_Na_SM in component I_Na_SM (conductance_units)');
    LEGEND_ALGEBRAIC(:,12) = strpad('xa1_inf_SM in component xa1_SM (dimensionless)');
    LEGEND_ALGEBRAIC(:,24) = strpad('tau_xa1_SM in component xa1_SM (time_units)');
    LEGEND_STATES(:,14) = strpad('xa1_SM in component xa1_SM (dimensionless)');
    LEGEND_ALGEBRAIC(:,13) = strpad('xa2_inf_SM in component xa2_SM (dimensionless)');
    LEGEND_CONSTANTS(:,149) = strpad('tau_xa2_SM in component xa2_SM (time_units)');
    LEGEND_STATES(:,15) = strpad('xa2_SM in component xa2_SM (dimensionless)');
    LEGEND_CONSTANTS(:,150) = strpad('E_K in component I_ka_SM (voltage_units)');
    LEGEND_CONSTANTS(:,43) = strpad('G_max_ka_SM in component I_ka_SM (conductance_units)');
    LEGEND_ALGEBRAIC(:,14) = strpad('m_inf_NSCC_SM in component m_NSCC_SM (dimensionless)');
    LEGEND_ALGEBRAIC(:,25) = strpad('tau_m_NSCC_SM in component m_NSCC_SM (time_units)');
    LEGEND_STATES(:,16) = strpad('m_NSCC_SM in component m_NSCC_SM (dimensionless)');
    LEGEND_CONSTANTS(:,44) = strpad('E_NSCC in component I_NSCC_SM (voltage_units)');
    LEGEND_CONSTANTS(:,45) = strpad('G_max_NSCC_SM in component I_NSCC_SM (conductance_units)');
    LEGEND_CONSTANTS(:,46) = strpad('Ach in component I_NSCC_SM (millimolar)');
    LEGEND_ALGEBRAIC(:,62) = strpad('f_ca_NSCC_SM in component I_NSCC_SM (dimensionless)');
    LEGEND_CONSTANTS(:,129) = strpad('rach_NSCC_SM in component I_NSCC_SM (dimensionless)');
    LEGEND_CONSTANTS(:,47) = strpad('p2m in component Parameters (dimensionless)');
    LEGEND_CONSTANTS(:,48) = strpad('umc2L in component Parameters (dimensionless)');
    LEGEND_CONSTANTS(:,49) = strpad('T in component Parameters (Temperature_units)');
    LEGEND_CONSTANTS(:,50) = strpad('F in component Parameters (F_units_ICC)');
    LEGEND_CONSTANTS(:,51) = strpad('R in component Parameters (R_units_ICC)');
    LEGEND_CONSTANTS(:,52) = strpad('z_ca in component Parameters (dimensionless)');
    LEGEND_CONSTANTS(:,53) = strpad('z_na in component Parameters (dimensionless)');
    LEGEND_CONSTANTS(:,54) = strpad('z_k in component Parameters (dimensionless)');
    LEGEND_CONSTANTS(:,55) = strpad('z_cl in component Parameters (dimensionless)');
    LEGEND_CONSTANTS(:,56) = strpad('Ca_o in component Parameters (micromolar)');
    LEGEND_CONSTANTS(:,57) = strpad('Cl_i in component Parameters (micromolar)');
    LEGEND_CONSTANTS(:,58) = strpad('Cl_o in component Parameters (micromolar)');
    LEGEND_CONSTANTS(:,59) = strpad('K_i in component Parameters (micromolar)');
    LEGEND_CONSTANTS(:,60) = strpad('K_o in component Parameters (micromolar)');
    LEGEND_CONSTANTS(:,61) = strpad('Na_i in component Parameters (micromolar)');
    LEGEND_CONSTANTS(:,62) = strpad('Na_o in component Parameters (micromolar)');
    LEGEND_CONSTANTS(:,63) = strpad('cellVol in component Volume (litre)');
    LEGEND_CONSTANTS(:,64) = strpad('cellPropER in component Volume (dimensionless)');
    LEGEND_CONSTANTS(:,65) = strpad('cellPropCyto in component Volume (dimensionless)');
    LEGEND_CONSTANTS(:,133) = strpad('volER in component Volume (litre)');
    LEGEND_CONSTANTS(:,151) = strpad('volCyto in component Volume (litre)');
    LEGEND_STATES(:,17) = strpad('Ca_i in component ICC_Membrane (micromolar)');
    LEGEND_CONSTANTS(:,66) = strpad('E_NSCC in component Nernst (voltage_units)');
    LEGEND_CONSTANTS(:,67) = strpad('E_NSV in component Nernst (voltage_units)');
    LEGEND_CONSTANTS(:,68) = strpad('E_SOC in component Nernst (voltage_units)');
    LEGEND_ALGEBRAIC(:,34) = strpad('E_Ca in component Nernst (voltage_units)');
    LEGEND_CONSTANTS(:,130) = strpad('E_Cl in component Nernst (voltage_units)');
    LEGEND_CONSTANTS(:,131) = strpad('E_Na in component Nernst (voltage_units)');
    LEGEND_CONSTANTS(:,132) = strpad('E_K in component Nernst (voltage_units)');
    LEGEND_CONSTANTS(:,69) = strpad('d_CaT_Vh in component d_CaT (voltage_units)');
    LEGEND_CONSTANTS(:,70) = strpad('d_CaT_S in component d_CaT (voltage_units)');
    LEGEND_CONSTANTS(:,71) = strpad('d_CaT_tau in component d_CaT (time_units_ICC)');
    LEGEND_ALGEBRAIC(:,16) = strpad('d_CaT_inf in component d_CaT (dimensionless)');
    LEGEND_STATES(:,18) = strpad('d_CaT in component d_CaT (dimensionless)');
    LEGEND_CONSTANTS(:,72) = strpad('f_CaT_Vh in component f_CaT (voltage_units)');
    LEGEND_CONSTANTS(:,73) = strpad('f_CaT_S in component f_CaT (voltage_units)');
    LEGEND_CONSTANTS(:,74) = strpad('f_CaT_tau in component f_CaT (time_units_ICC)');
    LEGEND_ALGEBRAIC(:,17) = strpad('f_CaT_inf in component f_CaT (dimensionless)');
    LEGEND_STATES(:,19) = strpad('f_CaT in component f_CaT (dimensionless)');
    LEGEND_CONSTANTS(:,75) = strpad('g_CaT in component I_CaT (conductance_units)');
    LEGEND_ALGEBRAIC(:,36) = strpad('I_CaT in component I_CaT (current_units)');
    LEGEND_ALGEBRAIC(:,38) = strpad('J_CaT in component I_CaT (micromolar_per_second)');
    LEGEND_CONSTANTS(:,76) = strpad('SOC_h in component P_SOC (micromolar)');
    LEGEND_STATES(:,20) = strpad('Ca_er in component Ca_er (micromolar)');
    LEGEND_CONSTANTS(:,77) = strpad('SOC_n in component P_SOC (dimensionless)');
    LEGEND_ALGEBRAIC(:,40) = strpad('P_SOC in component P_SOC (dimensionless)');
    LEGEND_CONSTANTS(:,78) = strpad('g_SOC in component I_SOC (conductance_units)');
    LEGEND_CONSTANTS(:,79) = strpad('SOCPropCa in component I_SOC (dimensionless)');
    LEGEND_ALGEBRAIC(:,43) = strpad('I_SOC in component I_SOC (current_units)');
    LEGEND_ALGEBRAIC(:,46) = strpad('J_SOC in component I_SOC (micromolar_per_second)');
    LEGEND_CONSTANTS(:,80) = strpad('g_BK in component I_BK (conductance_units)');
    LEGEND_ALGEBRAIC(:,49) = strpad('I_BK in component I_BK (current_units)');
    LEGEND_ALGEBRAIC(:,52) = strpad('I_stim in component I_stim (current_units)');
    LEGEND_CONSTANTS(:,81) = strpad('stim_amp in component I_stim (current_units)');
    LEGEND_CONSTANTS(:,82) = strpad('stim_start in component I_stim (time_units_ICC)');
    LEGEND_CONSTANTS(:,83) = strpad('stim_PW in component I_stim (time_units_ICC)');
    LEGEND_ALGEBRAIC(:,55) = strpad('P_NSCC in component P_NSCC (dimensionless)');
    LEGEND_CONSTANTS(:,84) = strpad('n_NSCC in component P_NSCC (dimensionless)');
    LEGEND_CONSTANTS(:,85) = strpad('Ca_NSCC in component P_NSCC (micromolar)');
    LEGEND_CONSTANTS(:,86) = strpad('g_NSCC in component I_NSCC (conductance_units)');
    LEGEND_ALGEBRAIC(:,59) = strpad('I_NSCC in component I_NSCC (current_units)');
    LEGEND_CONSTANTS(:,87) = strpad('Dc in component d_Ano1 (micrometer2_per_time)');
    LEGEND_CONSTANTS(:,88) = strpad('Dm in component d_Ano1 (micrometer2_per_time)');
    LEGEND_CONSTANTS(:,89) = strpad('Bm in component d_Ano1 (micromolar)');
    LEGEND_CONSTANTS(:,90) = strpad('Km in component d_Ano1 (micromolar)');
    LEGEND_CONSTANTS(:,91) = strpad('kc in component d_Ano1 (Inverse_Voltage_ICC)');
    LEGEND_CONSTANTS(:,92) = strpad('nSOC in component d_Ano1 (dimensionless)');
    LEGEND_CONSTANTS(:,134) = strpad('rad in component d_Ano1 (micrometer)');
    LEGEND_ALGEBRAIC(:,63) = strpad('mouthCa in component d_Ano1 (micromolar_per_second)');
    LEGEND_ALGEBRAIC(:,66) = strpad('localCa in component d_Ano1 (micromolar)');
    LEGEND_ALGEBRAIC(:,67) = strpad('d_Ano1_tau in component d_Ano1 (time_units_ICC)');
    LEGEND_CONSTANTS(:,93) = strpad('d_Ano1_tscale in component d_Ano1 (dimensionless)');
    LEGEND_CONSTANTS(:,94) = strpad('colocalRadius in component d_Ano1 (micrometer)');
    LEGEND_ALGEBRAIC(:,68) = strpad('d_Ano1_inf in component d_Ano1 (dimensionless)');
    LEGEND_STATES(:,21) = strpad('d_Ano1 in component d_Ano1 (dimensionless)');
    LEGEND_CONSTANTS(:,95) = strpad('Ano1_n in component d_Ano1 (dimensionless)');
    LEGEND_CONSTANTS(:,96) = strpad('Ano1_Vh in component d_Ano1 (voltage_units)');
    LEGEND_CONSTANTS(:,97) = strpad('Ano1_s in component d_Ano1 (Inverse_Voltage_ICC)');
    LEGEND_ALGEBRAIC(:,69) = strpad('h_Ano1 in component d_Ano1 (dimensionless)');
    LEGEND_CONSTANTS(:,98) = strpad('g_Ano1 in component I_Ano1 (conductance_units)');
    LEGEND_ALGEBRAIC(:,70) = strpad('I_Ano1 in component I_Ano1 (current_units)');
    LEGEND_CONSTANTS(:,99) = strpad('Ke in component J_SERCA (micromolar)');
    LEGEND_ALGEBRAIC(:,50) = strpad('J_SERCA in component J_SERCA (micromolar_per_second)');
    LEGEND_CONSTANTS(:,100) = strpad('Ve in component J_SERCA (micromolar_per_second)');
    LEGEND_CONSTANTS(:,101) = strpad('fc in component J_SERCA (dimensionless)');
    LEGEND_CONSTANTS(:,102) = strpad('fe in component J_SERCA (dimensionless)');
    LEGEND_ALGEBRAIC(:,60) = strpad('J_IPR in component J_IPR (micromolar_per_second)');
    LEGEND_CONSTANTS(:,103) = strpad('k1 in component y_bind (per_micromolarsecond)');
    LEGEND_CONSTANTS(:,104) = strpad('k2 in component y_bind (per_micromolarsecond)');
    LEGEND_CONSTANTS(:,105) = strpad('k3 in component y_bind (per_micromolarsecond)');
    LEGEND_CONSTANTS(:,106) = strpad('k4 in component y_bind (per_micromolarsecond)');
    LEGEND_CONSTANTS(:,107) = strpad('k5 in component y_bind (per_micromolarsecond)');
    LEGEND_CONSTANTS(:,108) = strpad('k_1 in component y_bind (rate_constants_units_second)');
    LEGEND_CONSTANTS(:,109) = strpad('k_2 in component y_bind (rate_constants_units_second)');
    LEGEND_CONSTANTS(:,110) = strpad('k_3 in component y_bind (rate_constants_units_second)');
    LEGEND_CONSTANTS(:,111) = strpad('k_4 in component y_bind (rate_constants_units_second)');
    LEGEND_CONSTANTS(:,112) = strpad('k_5 in component y_bind (rate_constants_units_second)');
    LEGEND_ALGEBRAIC(:,53) = strpad('IP3 in component J_IPR (micromolar)');
    LEGEND_CONSTANTS(:,135) = strpad('K1 in component y_bind (micromolar)');
    LEGEND_CONSTANTS(:,136) = strpad('K2 in component y_bind (micromolar)');
    LEGEND_CONSTANTS(:,128) = strpad('K3 in component y_bind (micromolar)');
    LEGEND_CONSTANTS(:,137) = strpad('K4 in component y_bind (micromolar)');
    LEGEND_CONSTANTS(:,138) = strpad('K5 in component y_bind (micromolar)');
    LEGEND_STATES(:,22) = strpad('y in component y_bind (dimensionless)');
    LEGEND_ALGEBRAIC(:,57) = strpad('phi1 in component y_bind (rate_constants_units_second)');
    LEGEND_ALGEBRAIC(:,61) = strpad('phi2 in component y_bind (rate_constants_units_second)');
    LEGEND_CONSTANTS(:,113) = strpad('kipr in component J_IPR (rate_constants_units_second)');
    LEGEND_ALGEBRAIC(:,56) = strpad('Pipr in component J_IPR (dimensionless)');
    LEGEND_CONSTANTS(:,114) = strpad('Jer in component J_IPR (rate_constants_units_second)');
    LEGEND_CONSTANTS(:,115) = strpad('IP3_base in component J_IPR (micromolar)');
    LEGEND_CONSTANTS(:,116) = strpad('g_PMCA in component J_PMCA (dimensionless)');
    LEGEND_CONSTANTS(:,117) = strpad('J_PMCA_max in component J_PMCA (micromolar_per_second)');
    LEGEND_CONSTANTS(:,118) = strpad('K_PMCA in component J_PMCA (micromolar)');
    LEGEND_CONSTANTS(:,119) = strpad('n_PMCA in component J_PMCA (dimensionless)');
    LEGEND_ALGEBRAIC(:,64) = strpad('J_PMCA in component J_PMCA (micromolar_per_second)');
    LEGEND_CONSTANTS(:,120) = strpad('g_BNa in component I_BNa (conductance_units)');
    LEGEND_ALGEBRAIC(:,71) = strpad('I_BNa in component I_BNa (current_units)');
    LEGEND_CONSTANTS(:,121) = strpad('Cm in component ICC_Membrane (capacitance_units_ICC)');
    LEGEND_ALGEBRAIC(:,72) = strpad('Iion in component ICC_Membrane (current_units)');
    LEGEND_RATES(:,1) = strpad('d/dt Vm_SM in component SM_Membrane (voltage_units)');
    LEGEND_RATES(:,2) = strpad('d/dt Ca_i in component SM_Membrane (millimolar)');
    LEGEND_RATES(:,4) = strpad('d/dt d_Ltype_SM in component d_Ltype_SM (dimensionless)');
    LEGEND_RATES(:,5) = strpad('d/dt f_Ltype_SM in component f_Ltype_SM (dimensionless)');
    LEGEND_RATES(:,6) = strpad('d/dt f_ca_Ltype_SM in component f_ca_Ltype_SM (dimensionless)');
    LEGEND_RATES(:,7) = strpad('d/dt d_LVA_SM in component d_LVA_SM (dimensionless)');
    LEGEND_RATES(:,8) = strpad('d/dt f_LVA_SM in component f_LVA_SM (dimensionless)');
    LEGEND_RATES(:,9) = strpad('d/dt x_SK_SM in component x_SK_SM (dimensionless)');
    LEGEND_RATES(:,10) = strpad('d/dt xr1_SM in component xr1_SM (dimensionless)');
    LEGEND_RATES(:,11) = strpad('d/dt xr2_SM in component xr2_SM (dimensionless)');
    LEGEND_RATES(:,12) = strpad('d/dt m_Na_SM in component m_Na_SM (dimensionless)');
    LEGEND_RATES(:,13) = strpad('d/dt h_Na_SM in component h_Na_SM (dimensionless)');
    LEGEND_RATES(:,14) = strpad('d/dt xa1_SM in component xa1_SM (dimensionless)');
    LEGEND_RATES(:,15) = strpad('d/dt xa2_SM in component xa2_SM (dimensionless)');
    LEGEND_RATES(:,16) = strpad('d/dt m_NSCC_SM in component m_NSCC_SM (dimensionless)');
    LEGEND_RATES(:,18) = strpad('d/dt d_CaT in component d_CaT (dimensionless)');
    LEGEND_RATES(:,19) = strpad('d/dt f_CaT in component f_CaT (dimensionless)');
    LEGEND_RATES(:,21) = strpad('d/dt d_Ano1 in component d_Ano1 (dimensionless)');
    LEGEND_RATES(:,20) = strpad('d/dt Ca_er in component Ca_er (micromolar)');
    LEGEND_RATES(:,22) = strpad('d/dt y in component y_bind (dimensionless)');
    LEGEND_RATES(:,3) = strpad('d/dt Vm in component ICC_Membrane (voltage_units)');
    LEGEND_RATES(:,17) = strpad('d/dt Ca_i in component ICC_Membrane (micromolar)');
    LEGEND_STATES  = LEGEND_STATES';
    LEGEND_ALGEBRAIC = LEGEND_ALGEBRAIC';
    LEGEND_RATES = LEGEND_RATES';
    LEGEND_CONSTANTS = LEGEND_CONSTANTS';
end

function [STATES, CONSTANTS] = initConsts(f_e, f_i)
    VOI = 0; CONSTANTS = []; STATES = []; ALGEBRAIC = [];
    CONSTANTS(:,1) = 310;
    CONSTANTS(:,2) = 297;
    CONSTANTS(:,3) = 96486;
    CONSTANTS(:,4) = 8314.4;
    CONSTANTS(:,5) = 2.1;
    CONSTANTS(:,6) = 1.365;
    CONSTANTS(:,7) = 2.45;
    CONSTANTS(:,8) = 2.5;
    CONSTANTS(:,9) = 137;
    CONSTANTS(:,10) = 5.9;
    CONSTANTS(:,11) = 134;
    CONSTANTS(:,12) = 77;
    CONSTANTS(:,13) = 3500;
    STATES(:,1) = -69.75;
    STATES(:,2) = 0.00008;
    CONSTANTS(:,14) = 10;
    CONSTANTS(:,15) = 164;
    CONSTANTS(:,16) = 1.3;
    STATES(:,3) = -66.0;
    STATES(:,4) = 0.0;
    STATES(:,5) = 0.95;
    STATES(:,6) = 1.0;
    CONSTANTS(:,17) = 65;
    CONSTANTS(:,18) = 0.31705;
    STATES(:,7) = 0.02;
    STATES(:,8) = 0.99;
    CONSTANTS(:,19) = 0.18;
    CONSTANTS(:,20) = 45.7;
    CONSTANTS(:,21) = 0.5623413;
    CONSTANTS(:,22) = 3.4;
    CONSTANTS(:,23) = 313;
    CONSTANTS(:,24) = f_e;
    CONSTANTS(:,25) = f_i;
    CONSTANTS(:,26) = 120;
    CONSTANTS(:,27) = 180;
    CONSTANTS(:,28) = 10;
    CONSTANTS(:,29) = 0.326;
    CONSTANTS(:,30) = 0.775;
    CONSTANTS(:,31) = 0.882;
    CONSTANTS(:,32) = 0.441;
    CONSTANTS(:,33) = 0.92;
    CONSTANTS(:,34) = 3.17;
    CONSTANTS(:,35) = 1.17;
    CONSTANTS(:,36) = 5;
    STATES(:,9) = 0;
    CONSTANTS(:,37) = 2;
    CONSTANTS(:,38) = 0.3;
    CONSTANTS(:,39) = 3.5;
    CONSTANTS(:,40) = 0.0144;
    STATES(:,10) = 0.0;
    STATES(:,11) = 0.82;
    CONSTANTS(:,41) = 35;
    STATES(:,12) = 0.005;
    STATES(:,13) = 0.05787;
    CONSTANTS(:,42) = 3;
    STATES(:,14) = 0.00414;
    STATES(:,15) = 0.72;
    CONSTANTS(:,43) = 9;
    STATES(:,16) = 0.0;
    CONSTANTS(:,44) = -28;
    CONSTANTS(:,45) = 50;
    CONSTANTS(:,46) = 0.00001;
    CONSTANTS(:,47) = 1e-09;
    CONSTANTS(:,48) = 1e+15;
    CONSTANTS(:,49) = 310;
    CONSTANTS(:,50) = 96.4846;
    CONSTANTS(:,51) = 8.3144;
    CONSTANTS(:,52) = 2;
						
    CONSTANTS(:,53) = 1;
    CONSTANTS(:,54) = 1;
    CONSTANTS(:,55) = -1;
    CONSTANTS(:,56) = 2000;
    CONSTANTS(:,57) = 78000;
    CONSTANTS(:,58) = 166000;
    CONSTANTS(:,59) = 140000;
    CONSTANTS(:,60) = 5000;
    CONSTANTS(:,61) = 30000;
    CONSTANTS(:,62) = 140000;
    CONSTANTS(:,63) = 1e-12;
    CONSTANTS(:,64) = 0.1;
    CONSTANTS(:,65) = 0.7;
    STATES(:,17) = 0.14;
						
    CONSTANTS(:,66) = 0;
    CONSTANTS(:,67) = 0;
    CONSTANTS(:,68) = 0;
    CONSTANTS(:,69) = -40;
    CONSTANTS(:,70) = -3;
    CONSTANTS(:,71) = 0.006;
    STATES(:,18) = 0.001271016263081;
    CONSTANTS(:,72) = -55;
    CONSTANTS(:,73) = 5;
    CONSTANTS(:,74) = 0.1;
    STATES(:,19) = 0.5;
    CONSTANTS(:,75) = 4;
    CONSTANTS(:,76) = 200;
    STATES(:,20) = 290.0;
    CONSTANTS(:,77) = 8;
    CONSTANTS(:,78) = 0.1;
    CONSTANTS(:,79) = 1;
    CONSTANTS(:,80) = 9;
    CONSTANTS(:,81) = 0;
    CONSTANTS(:,82) = 18;
    CONSTANTS(:,83) = 0.5;
    CONSTANTS(:,84) = 4;
    CONSTANTS(:,85) = 1.8;
    CONSTANTS(:,86) = 30;
    CONSTANTS(:,87) = 250;
    CONSTANTS(:,88) = 75;
    CONSTANTS(:,89) = 50;
    CONSTANTS(:,90) = 1;
    CONSTANTS(:,91) = 0.01248;
    CONSTANTS(:,92) = 50;
    CONSTANTS(:,93) = 1;
    CONSTANTS(:,94) = 0.05;
    STATES(:,21) = 0.01;
    CONSTANTS(:,95) = 2;
    CONSTANTS(:,96) = -100;
    CONSTANTS(:,97) = 0.0156;
    CONSTANTS(:,98) = 20;
    CONSTANTS(:,99) = 0.1;
    CONSTANTS(:,100) = 160;
    CONSTANTS(:,101) = 0.01;
    CONSTANTS(:,102) = 1;
    CONSTANTS(:,103) = 500;
    CONSTANTS(:,104) = 0.25;
    CONSTANTS(:,105) = 500;
    CONSTANTS(:,106) = 0.25;
    CONSTANTS(:,107) = 25;
    CONSTANTS(:,108) = 65;
    CONSTANTS(:,109) = 0.2625;
    CONSTANTS(:,110) = 471.5;
    CONSTANTS(:,111) = 0.03625;
    CONSTANTS(:,112) = 2.05;
    STATES(:,22) = 0.4;
    CONSTANTS(:,113) = 7;
    CONSTANTS(:,114) = 0.01;
    CONSTANTS(:,115) = 0.5;
    CONSTANTS(:,116) = 1;
    CONSTANTS(:,117) = 100;
    CONSTANTS(:,118) = 0.1;
						 
    CONSTANTS(:,119) = 2;
    CONSTANTS(:,120) = 2;
    CONSTANTS(:,121) = 0.025;
																						 
    CONSTANTS(:,122) = power(CONSTANTS(:,7), (CONSTANTS(:,1) - CONSTANTS(:,2))./10.0000);
    CONSTANTS(:,123) = power(CONSTANTS(:,6), (CONSTANTS(:,1) - CONSTANTS(:,2))./10.0000);
    CONSTANTS(:,124) = power(CONSTANTS(:,5), (CONSTANTS(:,1) - CONSTANTS(:,2))./10.0000);
    CONSTANTS(:,125) =  1.10000.*(CONSTANTS(:,1) - CONSTANTS(:,2));
    CONSTANTS(:,126) = CONSTANTS(:,3)./( CONSTANTS(:,4).*CONSTANTS(:,1));
    CONSTANTS(:,127) = ( CONSTANTS(:,4).*CONSTANTS(:,1))./CONSTANTS(:,3);
    CONSTANTS(:,128) = CONSTANTS(:,110)./CONSTANTS(:,105);
    CONSTANTS(:,129) = 1.00000./(1.00000+0.0100000./CONSTANTS(:,46));
    CONSTANTS(:,130) =  (( CONSTANTS(:,51).*CONSTANTS(:,49))./( CONSTANTS(:,50).*CONSTANTS(:,55))).*log(CONSTANTS(:,58)./CONSTANTS(:,57));
    CONSTANTS(:,131) =  (( CONSTANTS(:,51).*CONSTANTS(:,49))./( CONSTANTS(:,50).*CONSTANTS(:,53))).*log(CONSTANTS(:,62)./CONSTANTS(:,61));
    CONSTANTS(:,132) =  (( CONSTANTS(:,51).*CONSTANTS(:,49))./( CONSTANTS(:,50).*CONSTANTS(:,54))).*log(CONSTANTS(:,60)./CONSTANTS(:,59));
    CONSTANTS(:,133) =  CONSTANTS(:,63).*CONSTANTS(:,64);
									   
    CONSTANTS(:,134) = CONSTANTS(:,94);
    CONSTANTS(:,135) = CONSTANTS(:,108)./CONSTANTS(:,103);
    CONSTANTS(:,136) = CONSTANTS(:,109)./CONSTANTS(:,104);
    CONSTANTS(:,137) = CONSTANTS(:,111)./CONSTANTS(:,106);
    CONSTANTS(:,138) = CONSTANTS(:,112)./CONSTANTS(:,107);
    CONSTANTS(:,139) =  CONSTANTS(:,124).*0.470000;
    CONSTANTS(:,140) =  CONSTANTS(:,124).*86.0000;
    CONSTANTS(:,141) =  CONSTANTS(:,124).*2.00000;
    CONSTANTS(:,142) =  CONSTANTS(:,124).*3.00000;
    CONSTANTS(:,143) =  CONSTANTS(:,127).*log(CONSTANTS(:,10)./CONSTANTS(:,15));
    CONSTANTS(:,144) =  CONSTANTS(:,127).*log(CONSTANTS(:,10)./CONSTANTS(:,15));
    CONSTANTS(:,145) =  CONSTANTS(:,127).*log(CONSTANTS(:,10)./CONSTANTS(:,15));
    CONSTANTS(:,146) =  CONSTANTS(:,123).*80.0000;
    CONSTANTS(:,147) =  CONSTANTS(:,127).*log(CONSTANTS(:,10)./CONSTANTS(:,15));
    CONSTANTS(:,148) =  CONSTANTS(:,127).*log(CONSTANTS(:,9)./CONSTANTS(:,14));
    CONSTANTS(:,149) =  CONSTANTS(:,123).*90.0000;
    CONSTANTS(:,150) =  CONSTANTS(:,127).*log(CONSTANTS(:,10)./CONSTANTS(:,15));
    CONSTANTS(:,151) =  CONSTANTS(:,63).*CONSTANTS(:,65);
    if (isempty(STATES)), warning('Initial values for states not set');, end
end

function [RATES, ALGEBRAIC] = computeRates(VOI, STATES, CONSTANTS)
    global algebraicVariableCount;
    statesSize = size(STATES);
    statesColumnCount = statesSize(2);
    if ( statesColumnCount == 1)
        STATES = STATES';
        ALGEBRAIC = zeros(1, algebraicVariableCount);
        utilOnes = 1;
    else
        statesRowCount = statesSize(1);
        ALGEBRAIC = zeros(statesRowCount, algebraicVariableCount);
        RATES = zeros(statesRowCount, statesColumnCount);
        utilOnes = ones(statesRowCount, 1);
    end
    ALGEBRAIC(:,1) = 1.00000./(1.00000+exp((STATES(:,1)+17.0000)./ - 4.30000));
    RATES(:,4) = (ALGEBRAIC(:,1) - STATES(:,4))./CONSTANTS(:,139);
    ALGEBRAIC(:,2) = 1.00000./(1.00000+exp((STATES(:,1)+43.0000)./8.90000));
    RATES(:,5) = (ALGEBRAIC(:,2) - STATES(:,5))./CONSTANTS(:,140);
    ALGEBRAIC(:,3) = 1.00000 - 1.00000./(1.00000+exp(((STATES(:,2) - 8.99900e-05) - 0.000214000)./ - 1.31000e-05));
    RATES(:,6) = (ALGEBRAIC(:,3) - STATES(:,6))./CONSTANTS(:,141);
    ALGEBRAIC(:,4) = 1.00000./(1.00000+exp((STATES(:,1)+27.5000)./ - 10.9000));
    RATES(:,7) = (ALGEBRAIC(:,4) - STATES(:,7))./CONSTANTS(:,142);
    ALGEBRAIC(:,8) = 1.00000./(1.00000+exp((STATES(:,1)+27.0000)./ - 5.00000));
    RATES(:,10) = (ALGEBRAIC(:,8) - STATES(:,10))./CONSTANTS(:,146);
    ALGEBRAIC(:,13) = 0.100000+0.900000./(1.00000+exp((STATES(:,1)+65.0000)./6.20000));
    RATES(:,15) = (ALGEBRAIC(:,13) - STATES(:,15))./CONSTANTS(:,149);
    ALGEBRAIC(:,16) = 1.00000./(1.00000+exp((STATES(:,3) - CONSTANTS(:,69))./CONSTANTS(:,70)));
    RATES(:,18) = ((ALGEBRAIC(:,16) - STATES(:,18))./CONSTANTS(:,71)).*0.00100000;
    ALGEBRAIC(:,17) = 1.00000./(1.00000+exp((STATES(:,3) - CONSTANTS(:,72))./CONSTANTS(:,73)));
    RATES(:,19) = ((ALGEBRAIC(:,17) - STATES(:,19))./CONSTANTS(:,74)).*0.00100000;
    ALGEBRAIC(:,5) = 1.00000./(1.00000+exp((STATES(:,1)+15.8000)./7.00000));
    ALGEBRAIC(:,18) =  CONSTANTS(:,124).*7.58000.*exp( STATES(:,1).*0.00817000);
    RATES(:,8) = (ALGEBRAIC(:,5) - STATES(:,8))./ALGEBRAIC(:,18);
    ALGEBRAIC(:,7) = ( 0.810000.*power(STATES(:,2).*1000.00, CONSTANTS(:,37)))./(power(STATES(:,2).*1000.00, CONSTANTS(:,37))+power(CONSTANTS(:,38), CONSTANTS(:,37)));
    ALGEBRAIC(:,20) = 1.00000./( 0.0470000.*(STATES(:,2).*1000.00)+1.00000./76.0000);
    RATES(:,9) = (ALGEBRAIC(:,7) - STATES(:,9))./ALGEBRAIC(:,20);
    ALGEBRAIC(:,9) = 0.200000+0.800000./(1.00000+exp((STATES(:,1)+58.0000)./10.0000));
    ALGEBRAIC(:,21) =  CONSTANTS(:,123).*( - 707.000+ 1481.00.*exp((STATES(:,1)+36.0000)./95.0000));
    RATES(:,11) = (ALGEBRAIC(:,9) - STATES(:,11))./ALGEBRAIC(:,21);
    ALGEBRAIC(:,10) = 1.00000./(1.00000+exp((STATES(:,1)+47.0000)./ - 4.80000));
    ALGEBRAIC(:,22) =  CONSTANTS(:,122).*( STATES(:,1).* - 0.0170000.*1.00000+0.440000);
    RATES(:,12) = (ALGEBRAIC(:,10) - STATES(:,12))./ALGEBRAIC(:,22);
    ALGEBRAIC(:,11) = 1.00000./(1.00000+exp((STATES(:,1)+78.0000)./3.00000));
    ALGEBRAIC(:,23) =  CONSTANTS(:,122).*( STATES(:,1).* - 0.250000.*1.00000+5.50000);
    RATES(:,13) = (ALGEBRAIC(:,11) - STATES(:,13))./ALGEBRAIC(:,23);
    ALGEBRAIC(:,12) = 1.00000./(1.00000+exp((STATES(:,1)+26.5000)./ - 7.90000));
    ALGEBRAIC(:,24) =  CONSTANTS(:,123).*(31.8000+ 175.000.*exp(  - 0.500000.*power((STATES(:,1)+44.4000)./22.3000, 2.00000)));
    RATES(:,14) = (ALGEBRAIC(:,12) - STATES(:,14))./ALGEBRAIC(:,24);
    ALGEBRAIC(:,14) = 1.00000./(1.00000+exp((STATES(:,1)+25.0000)./ - 20.0000));
    ALGEBRAIC(:,25) =  (1.00000./(1.00000+exp((STATES(:,1)+66.0000)./ - 26.0000))).*150.000;
    RATES(:,16) = (ALGEBRAIC(:,14) - STATES(:,16))./ALGEBRAIC(:,25);
    ALGEBRAIC(:,19) =  0.500000.*CONSTANTS(:,127).*log(CONSTANTS(:,8)./STATES(:,2));
    ALGEBRAIC(:,27) =  CONSTANTS(:,17).*STATES(:,5).*STATES(:,4).*STATES(:,6).*(STATES(:,1) - ALGEBRAIC(:,19));
    ALGEBRAIC(:,31) =  0.500000.*CONSTANTS(:,127).*log(CONSTANTS(:,8)./STATES(:,2));
    ALGEBRAIC(:,33) =  CONSTANTS(:,19).*STATES(:,8).*STATES(:,7).*(STATES(:,1) - ALGEBRAIC(:,31));
    ALGEBRAIC(:,29) =  CONSTANTS(:,18).*power( STATES(:,2).*1.00000, 1.34000);
    RATES(:,2) = (  - 1.00000.*ALGEBRAIC(:,27)+  - 1.00000.*ALGEBRAIC(:,33))./( 2.00000.*0.00100000.*CONSTANTS(:,3).*CONSTANTS(:,13))+  - 1.00000.*ALGEBRAIC(:,29);
    ALGEBRAIC(:,50) = ( CONSTANTS(:,100).*power(STATES(:,17), 2.00000))./(power(CONSTANTS(:,99), 2.00000)+power(STATES(:,17), 2.00000));
    ALGEBRAIC(:,26) = piecewise({VOI.*0.00100000>CONSTANTS(:,26)&VOI.*0.00100000<CONSTANTS(:,27), (1.00000 - exp((  - CONSTANTS(:,36).*CONSTANTS(:,24))./CONSTANTS(:,28)))./(1.00000 - exp( - CONSTANTS(:,36))) }, 0.00000);
    ALGEBRAIC(:,32) =  ALGEBRAIC(:,26).*CONSTANTS(:,33);
    ALGEBRAIC(:,53) =  CONSTANTS(:,115).*(1.00000+ALGEBRAIC(:,32));
    ALGEBRAIC(:,56) = power(( ALGEBRAIC(:,53).*STATES(:,17).*(1.00000 - STATES(:,22)))./( (ALGEBRAIC(:,53)+CONSTANTS(:,135)).*(STATES(:,17)+CONSTANTS(:,138))), 3.00000);
    ALGEBRAIC(:,60) =  ( CONSTANTS(:,113).*ALGEBRAIC(:,56)+CONSTANTS(:,114)).*(STATES(:,20) - STATES(:,17));
    RATES(:,20) = (( CONSTANTS(:,102).*(ALGEBRAIC(:,50) - ALGEBRAIC(:,60)).*CONSTANTS(:,151))./CONSTANTS(:,133)).*0.00100000;
    ALGEBRAIC(:,57) = ( ( CONSTANTS(:,111).*CONSTANTS(:,136).*CONSTANTS(:,135)+ CONSTANTS(:,109).*CONSTANTS(:,137).*ALGEBRAIC(:,53)).*STATES(:,17))./( CONSTANTS(:,137).*CONSTANTS(:,136).*(CONSTANTS(:,135)+ALGEBRAIC(:,53)));
    ALGEBRAIC(:,61) = ( CONSTANTS(:,109).*ALGEBRAIC(:,53)+ CONSTANTS(:,111).*CONSTANTS(:,128))./(CONSTANTS(:,128)+ALGEBRAIC(:,53));
    RATES(:,22) = ( ALGEBRAIC(:,57).*(1.00000 - STATES(:,22)) -  ALGEBRAIC(:,61).*STATES(:,22)).*0.00100000;
    ALGEBRAIC(:,34) =  (( CONSTANTS(:,51).*CONSTANTS(:,49))./( CONSTANTS(:,50).*CONSTANTS(:,52))).*log(CONSTANTS(:,56)./STATES(:,17));
    ALGEBRAIC(:,36) =  CONSTANTS(:,75).*STATES(:,18).*STATES(:,19).*(STATES(:,3) - ALGEBRAIC(:,34));
    ALGEBRAIC(:,38) = (  - CONSTANTS(:,47).*ALGEBRAIC(:,36))./( CONSTANTS(:,52).*CONSTANTS(:,50).*CONSTANTS(:,151));
    ALGEBRAIC(:,40) = 1.00000./(1.00000+power(STATES(:,20)./CONSTANTS(:,76), CONSTANTS(:,77)));
    ALGEBRAIC(:,43) =  CONSTANTS(:,78).*ALGEBRAIC(:,40).*(STATES(:,3) - ALGEBRAIC(:,34));
    ALGEBRAIC(:,46) = (  - CONSTANTS(:,47).*CONSTANTS(:,79).*ALGEBRAIC(:,43))./( CONSTANTS(:,52).*CONSTANTS(:,50).*CONSTANTS(:,151));
    ALGEBRAIC(:,64) = ( CONSTANTS(:,116).*CONSTANTS(:,117).*1.00000)./(1.00000+power(CONSTANTS(:,118)./STATES(:,17), CONSTANTS(:,119)));
    RATES(:,17) = ( CONSTANTS(:,101).*(((ALGEBRAIC(:,60) - ALGEBRAIC(:,50))+ALGEBRAIC(:,46)+ALGEBRAIC(:,38)) - ALGEBRAIC(:,64))).*0.00100000;
    ALGEBRAIC(:,54) =  CONSTANTS(:,42).*STATES(:,13).*STATES(:,12).*(STATES(:,1) - CONSTANTS(:,148));
    ALGEBRAIC(:,51) =  CONSTANTS(:,41).*STATES(:,10).*STATES(:,11).*(STATES(:,1) - CONSTANTS(:,147));
    ALGEBRAIC(:,58) =  CONSTANTS(:,43).*STATES(:,14).*STATES(:,15).*(STATES(:,1) - CONSTANTS(:,150));
    ALGEBRAIC(:,35) = 1.00000./(1.00000+exp(STATES(:,1)./ - 17.0000 -  2.00000.*log(STATES(:,2)./0.00100000)));
    ALGEBRAIC(:,37) =  (CONSTANTS(:,20)+CONSTANTS(:,125)).*ALGEBRAIC(:,35).*(STATES(:,1) - CONSTANTS(:,143));
    ALGEBRAIC(:,39) = piecewise({VOI.*0.00100000>CONSTANTS(:,26)&VOI.*0.00100000<CONSTANTS(:,27), (1.00000 - exp((  - CONSTANTS(:,35).*CONSTANTS(:,25))./CONSTANTS(:,28)))./(1.00000 - exp( - CONSTANTS(:,35))) }, 0.00000);
    ALGEBRAIC(:,41) =  ALGEBRAIC(:,39).*CONSTANTS(:,32);
    ALGEBRAIC(:,44) =  CONSTANTS(:,39).*STATES(:,9).*ALGEBRAIC(:,41).*(STATES(:,1) - CONSTANTS(:,144));
    ALGEBRAIC(:,62) = 1.00000./(1.00000+power(STATES(:,2)./0.000200000,  - 4.00000));
    ALGEBRAIC(:,65) =  CONSTANTS(:,45).*STATES(:,16).*ALGEBRAIC(:,62).*CONSTANTS(:,129).*(STATES(:,1) - CONSTANTS(:,44));
    ALGEBRAIC(:,47) =  CONSTANTS(:,40).*(STATES(:,1) - CONSTANTS(:,145));
    ALGEBRAIC(:,6) =  CONSTANTS(:,16).*(STATES(:,3) - STATES(:,1));
    RATES(:,1) =  ((  - 1.00000.*1.00000)./CONSTANTS(:,12)).*(ALGEBRAIC(:,54)+ALGEBRAIC(:,44)+ALGEBRAIC(:,27)+ALGEBRAIC(:,33)+ALGEBRAIC(:,51)+ALGEBRAIC(:,58)+ALGEBRAIC(:,37)+ALGEBRAIC(:,65)+ALGEBRAIC(:,47)+  - 1.00000.*ALGEBRAIC(:,6));
    ALGEBRAIC(:,63) = ( 1.00000e+15.*ALGEBRAIC(:,46).*CONSTANTS(:,151))./CONSTANTS(:,92);
    ALGEBRAIC(:,66) = (((  - CONSTANTS(:,87).*CONSTANTS(:,90)+ALGEBRAIC(:,63)./( 2.00000.* pi.*CONSTANTS(:,134))+ CONSTANTS(:,87).*STATES(:,17)) - ( CONSTANTS(:,88).*CONSTANTS(:,89).*CONSTANTS(:,90))./(CONSTANTS(:,90)+STATES(:,17)))+power((power(( CONSTANTS(:,87).*CONSTANTS(:,90)+ALGEBRAIC(:,63)./( 2.00000.* pi.*CONSTANTS(:,134))+ CONSTANTS(:,87).*STATES(:,17)) - ( CONSTANTS(:,88).*CONSTANTS(:,89).*CONSTANTS(:,90))./(CONSTANTS(:,90)+STATES(:,17)), 2.00000)+ 4.00000.*CONSTANTS(:,87).*CONSTANTS(:,88).*CONSTANTS(:,89).*CONSTANTS(:,90)), 1.0 ./ 2))./( 2.00000.*CONSTANTS(:,87));
    ALGEBRAIC(:,67) =  CONSTANTS(:,93).*( 81.6300.*exp(  - 0.570000.*ALGEBRAIC(:,66))+ 76.1700.*exp(  - 0.0537400.*ALGEBRAIC(:,66)).*exp(STATES(:,3)./( 70.3000.*exp( 0.153000.*ALGEBRAIC(:,66))))).*0.00100000;
    ALGEBRAIC(:,68) = 1.00000./( (1.00000+exp( (CONSTANTS(:,96) - STATES(:,3)).*CONSTANTS(:,97))).*(1.00000+power(ALGEBRAIC(:,66)./( 1.39000.*exp(  - CONSTANTS(:,91).*STATES(:,3))),  - CONSTANTS(:,95))));
    RATES(:,21) = ((ALGEBRAIC(:,68) - STATES(:,21))./ALGEBRAIC(:,67)).*0.00100000;
    ALGEBRAIC(:,49) =  CONSTANTS(:,80).*(STATES(:,3) - CONSTANTS(:,132));
    ALGEBRAIC(:,52) = piecewise({VOI.*0.00100000>CONSTANTS(:,82)&VOI.*0.00100000<CONSTANTS(:,82)+CONSTANTS(:,83), CONSTANTS(:,81) }, 0.00000);
    ALGEBRAIC(:,15) = piecewise({VOI.*0.00100000>CONSTANTS(:,26)&VOI.*0.00100000<CONSTANTS(:,27), (1.00000 - exp((  - CONSTANTS(:,34).*CONSTANTS(:,25))./CONSTANTS(:,28)))./(1.00000 - exp( - CONSTANTS(:,34))) }, 0.00000);
    ALGEBRAIC(:,30) =  ALGEBRAIC(:,15).*CONSTANTS(:,30);
    ALGEBRAIC(:,55) = power(STATES(:,17), CONSTANTS(:,84))./(power(CONSTANTS(:,85), CONSTANTS(:,84))+power(STATES(:,17), CONSTANTS(:,84)));
    ALGEBRAIC(:,59) =  CONSTANTS(:,86).*(1.00000 - ALGEBRAIC(:,30)).*ALGEBRAIC(:,55).*(STATES(:,3) - CONSTANTS(:,66));
    ALGEBRAIC(:,28) =  ALGEBRAIC(:,15).*CONSTANTS(:,29);
    ALGEBRAIC(:,69) = ( STATES(:,21).*ALGEBRAIC(:,28).*1.00000)./(1.00000+power((ALGEBRAIC(:,68) - STATES(:,21))./ALGEBRAIC(:,67), 2.00000));
    ALGEBRAIC(:,70) =  CONSTANTS(:,98).*(STATES(:,21) - ALGEBRAIC(:,69)).*(STATES(:,3) - CONSTANTS(:,130));
    ALGEBRAIC(:,71) =  CONSTANTS(:,120).*(STATES(:,3) - CONSTANTS(:,131));
    ALGEBRAIC(:,72) = ALGEBRAIC(:,43)+ALGEBRAIC(:,70)+ALGEBRAIC(:,36)+ALGEBRAIC(:,49)+ALGEBRAIC(:,71)+ALGEBRAIC(:,59)+ALGEBRAIC(:,52);
    RATES(:,3) = ( - ALGEBRAIC(:,72)./CONSTANTS(:,121)).*0.00100000;
   RATES = RATES';
end

% Calculate algebraic variables
function ALGEBRAIC = computeAlgebraic(ALGEBRAIC, CONSTANTS, STATES, VOI)
    statesSize = size(STATES);
    statesColumnCount = statesSize(2);
    if ( statesColumnCount == 1)
        STATES = STATES';
        utilOnes = 1;
    else
        statesRowCount = statesSize(1);
        utilOnes = ones(statesRowCount, 1);
    end
    ALGEBRAIC(:,1) = 1.00000./(1.00000+exp((STATES(:,1)+17.0000)./ - 4.30000));
    ALGEBRAIC(:,2) = 1.00000./(1.00000+exp((STATES(:,1)+43.0000)./8.90000));
    ALGEBRAIC(:,3) = 1.00000 - 1.00000./(1.00000+exp(((STATES(:,2) - 8.99900e-05) - 0.000214000)./ - 1.31000e-05));
    ALGEBRAIC(:,4) = 1.00000./(1.00000+exp((STATES(:,1)+27.5000)./ - 10.9000));
    ALGEBRAIC(:,8) = 1.00000./(1.00000+exp((STATES(:,1)+27.0000)./ - 5.00000));
    ALGEBRAIC(:,13) = 0.100000+0.900000./(1.00000+exp((STATES(:,1)+65.0000)./6.20000));
    ALGEBRAIC(:,16) = 1.00000./(1.00000+exp((STATES(:,3) - CONSTANTS(:,69))./CONSTANTS(:,70)));
    ALGEBRAIC(:,17) = 1.00000./(1.00000+exp((STATES(:,3) - CONSTANTS(:,72))./CONSTANTS(:,73)));
    ALGEBRAIC(:,5) = 1.00000./(1.00000+exp((STATES(:,1)+15.8000)./7.00000));
    ALGEBRAIC(:,18) =  CONSTANTS(:,124).*7.58000.*exp( STATES(:,1).*0.00817000);
    ALGEBRAIC(:,7) = ( 0.810000.*power(STATES(:,2).*1000.00, CONSTANTS(:,37)))./(power(STATES(:,2).*1000.00, CONSTANTS(:,37))+power(CONSTANTS(:,38), CONSTANTS(:,37)));
    ALGEBRAIC(:,20) = 1.00000./( 0.0470000.*(STATES(:,2).*1000.00)+1.00000./76.0000);
    ALGEBRAIC(:,9) = 0.200000+0.800000./(1.00000+exp((STATES(:,1)+58.0000)./10.0000));
    ALGEBRAIC(:,21) =  CONSTANTS(:,123).*( - 707.000+ 1481.00.*exp((STATES(:,1)+36.0000)./95.0000));
    ALGEBRAIC(:,10) = 1.00000./(1.00000+exp((STATES(:,1)+47.0000)./ - 4.80000));
    ALGEBRAIC(:,22) =  CONSTANTS(:,122).*( STATES(:,1).* - 0.0170000.*1.00000+0.440000);
    ALGEBRAIC(:,11) = 1.00000./(1.00000+exp((STATES(:,1)+78.0000)./3.00000));
    ALGEBRAIC(:,23) =  CONSTANTS(:,122).*( STATES(:,1).* - 0.250000.*1.00000+5.50000);
    ALGEBRAIC(:,12) = 1.00000./(1.00000+exp((STATES(:,1)+26.5000)./ - 7.90000));
    ALGEBRAIC(:,24) =  CONSTANTS(:,123).*(31.8000+ 175.000.*exp(  - 0.500000.*power((STATES(:,1)+44.4000)./22.3000, 2.00000)));
    ALGEBRAIC(:,14) = 1.00000./(1.00000+exp((STATES(:,1)+25.0000)./ - 20.0000));
    ALGEBRAIC(:,25) =  (1.00000./(1.00000+exp((STATES(:,1)+66.0000)./ - 26.0000))).*150.000;
    ALGEBRAIC(:,19) =  0.500000.*CONSTANTS(:,127).*log(CONSTANTS(:,8)./STATES(:,2));
    ALGEBRAIC(:,27) =  CONSTANTS(:,17).*STATES(:,5).*STATES(:,4).*STATES(:,6).*(STATES(:,1) - ALGEBRAIC(:,19));
    ALGEBRAIC(:,31) =  0.500000.*CONSTANTS(:,127).*log(CONSTANTS(:,8)./STATES(:,2));
    ALGEBRAIC(:,33) =  CONSTANTS(:,19).*STATES(:,8).*STATES(:,7).*(STATES(:,1) - ALGEBRAIC(:,31));
    ALGEBRAIC(:,29) =  CONSTANTS(:,18).*power( STATES(:,2).*1.00000, 1.34000);
    ALGEBRAIC(:,50) = ( CONSTANTS(:,100).*power(STATES(:,17), 2.00000))./(power(CONSTANTS(:,99), 2.00000)+power(STATES(:,17), 2.00000));
    ALGEBRAIC(:,26) = piecewise({VOI.*0.00100000>CONSTANTS(:,26)&VOI.*0.00100000<CONSTANTS(:,27), (1.00000 - exp((  - CONSTANTS(:,36).*CONSTANTS(:,24))./CONSTANTS(:,28)))./(1.00000 - exp( - CONSTANTS(:,36))) }, 0.00000);
    ALGEBRAIC(:,32) =  ALGEBRAIC(:,26).*CONSTANTS(:,33);
    ALGEBRAIC(:,53) =  CONSTANTS(:,115).*(1.00000+ALGEBRAIC(:,32));
    ALGEBRAIC(:,56) = power(( ALGEBRAIC(:,53).*STATES(:,17).*(1.00000 - STATES(:,22)))./( (ALGEBRAIC(:,53)+CONSTANTS(:,135)).*(STATES(:,17)+CONSTANTS(:,138))), 3.00000);
    ALGEBRAIC(:,60) =  ( CONSTANTS(:,113).*ALGEBRAIC(:,56)+CONSTANTS(:,114)).*(STATES(:,20) - STATES(:,17));
    ALGEBRAIC(:,57) = ( ( CONSTANTS(:,111).*CONSTANTS(:,136).*CONSTANTS(:,135)+ CONSTANTS(:,109).*CONSTANTS(:,137).*ALGEBRAIC(:,53)).*STATES(:,17))./( CONSTANTS(:,137).*CONSTANTS(:,136).*(CONSTANTS(:,135)+ALGEBRAIC(:,53)));
    ALGEBRAIC(:,61) = ( CONSTANTS(:,109).*ALGEBRAIC(:,53)+ CONSTANTS(:,111).*CONSTANTS(:,128))./(CONSTANTS(:,128)+ALGEBRAIC(:,53));
    ALGEBRAIC(:,34) =  (( CONSTANTS(:,51).*CONSTANTS(:,49))./( CONSTANTS(:,50).*CONSTANTS(:,52))).*log(CONSTANTS(:,56)./STATES(:,17));
    ALGEBRAIC(:,36) =  CONSTANTS(:,75).*STATES(:,18).*STATES(:,19).*(STATES(:,3) - ALGEBRAIC(:,34));
    ALGEBRAIC(:,38) = (  - CONSTANTS(:,47).*ALGEBRAIC(:,36))./( CONSTANTS(:,52).*CONSTANTS(:,50).*CONSTANTS(:,151));
    ALGEBRAIC(:,40) = 1.00000./(1.00000+power(STATES(:,20)./CONSTANTS(:,76), CONSTANTS(:,77)));
    ALGEBRAIC(:,43) =  CONSTANTS(:,78).*ALGEBRAIC(:,40).*(STATES(:,3) - ALGEBRAIC(:,34));
    ALGEBRAIC(:,46) = (  - CONSTANTS(:,47).*CONSTANTS(:,79).*ALGEBRAIC(:,43))./( CONSTANTS(:,52).*CONSTANTS(:,50).*CONSTANTS(:,151));
    ALGEBRAIC(:,64) = ( CONSTANTS(:,116).*CONSTANTS(:,117).*1.00000)./(1.00000+power(CONSTANTS(:,118)./STATES(:,17), CONSTANTS(:,119)));
    ALGEBRAIC(:,54) =  CONSTANTS(:,42).*STATES(:,13).*STATES(:,12).*(STATES(:,1) - CONSTANTS(:,148));
    ALGEBRAIC(:,51) =  CONSTANTS(:,41).*STATES(:,10).*STATES(:,11).*(STATES(:,1) - CONSTANTS(:,147));
    ALGEBRAIC(:,58) =  CONSTANTS(:,43).*STATES(:,14).*STATES(:,15).*(STATES(:,1) - CONSTANTS(:,150));
    ALGEBRAIC(:,35) = 1.00000./(1.00000+exp(STATES(:,1)./ - 17.0000 -  2.00000.*log(STATES(:,2)./0.00100000)));
    ALGEBRAIC(:,37) =  (CONSTANTS(:,20)+CONSTANTS(:,125)).*ALGEBRAIC(:,35).*(STATES(:,1) - CONSTANTS(:,143));
    ALGEBRAIC(:,39) = piecewise({VOI.*0.00100000>CONSTANTS(:,26)&VOI.*0.00100000<CONSTANTS(:,27), (1.00000 - exp((  - CONSTANTS(:,35).*CONSTANTS(:,25))./CONSTANTS(:,28)))./(1.00000 - exp( - CONSTANTS(:,35))) }, 0.00000);
    ALGEBRAIC(:,41) =  ALGEBRAIC(:,39).*CONSTANTS(:,32);
    ALGEBRAIC(:,44) =  CONSTANTS(:,39).*STATES(:,9).*ALGEBRAIC(:,41).*(STATES(:,1) - CONSTANTS(:,144));
    ALGEBRAIC(:,62) = 1.00000./(1.00000+power(STATES(:,2)./0.000200000,  - 4.00000));
    ALGEBRAIC(:,65) =  CONSTANTS(:,45).*STATES(:,16).*ALGEBRAIC(:,62).*CONSTANTS(:,129).*(STATES(:,1) - CONSTANTS(:,44));
    ALGEBRAIC(:,47) =  CONSTANTS(:,40).*(STATES(:,1) - CONSTANTS(:,145));
    ALGEBRAIC(:,6) =  CONSTANTS(:,16).*(STATES(:,3) - STATES(:,1));
    ALGEBRAIC(:,63) = ( 1.00000e+15.*ALGEBRAIC(:,46).*CONSTANTS(:,151))./CONSTANTS(:,92);
    ALGEBRAIC(:,66) = (((  - CONSTANTS(:,87).*CONSTANTS(:,90)+ALGEBRAIC(:,63)./( 2.00000.* pi.*CONSTANTS(:,134))+ CONSTANTS(:,87).*STATES(:,17)) - ( CONSTANTS(:,88).*CONSTANTS(:,89).*CONSTANTS(:,90))./(CONSTANTS(:,90)+STATES(:,17)))+power((power(( CONSTANTS(:,87).*CONSTANTS(:,90)+ALGEBRAIC(:,63)./( 2.00000.* pi.*CONSTANTS(:,134))+ CONSTANTS(:,87).*STATES(:,17)) - ( CONSTANTS(:,88).*CONSTANTS(:,89).*CONSTANTS(:,90))./(CONSTANTS(:,90)+STATES(:,17)), 2.00000)+ 4.00000.*CONSTANTS(:,87).*CONSTANTS(:,88).*CONSTANTS(:,89).*CONSTANTS(:,90)), 1.0 ./ 2))./( 2.00000.*CONSTANTS(:,87));
    ALGEBRAIC(:,67) =  CONSTANTS(:,93).*( 81.6300.*exp(  - 0.570000.*ALGEBRAIC(:,66))+ 76.1700.*exp(  - 0.0537400.*ALGEBRAIC(:,66)).*exp(STATES(:,3)./( 70.3000.*exp( 0.153000.*ALGEBRAIC(:,66))))).*0.00100000;
    ALGEBRAIC(:,68) = 1.00000./( (1.00000+exp( (CONSTANTS(:,96) - STATES(:,3)).*CONSTANTS(:,97))).*(1.00000+power(ALGEBRAIC(:,66)./( 1.39000.*exp(  - CONSTANTS(:,91).*STATES(:,3))),  - CONSTANTS(:,95))));
    ALGEBRAIC(:,49) =  CONSTANTS(:,80).*(STATES(:,3) - CONSTANTS(:,132));
    ALGEBRAIC(:,52) = piecewise({VOI.*0.00100000>CONSTANTS(:,82)&VOI.*0.00100000<CONSTANTS(:,82)+CONSTANTS(:,83), CONSTANTS(:,81) }, 0.00000);
    ALGEBRAIC(:,15) = piecewise({VOI.*0.00100000>CONSTANTS(:,26)&VOI.*0.00100000<CONSTANTS(:,27), (1.00000 - exp((  - CONSTANTS(:,34).*CONSTANTS(:,25))./CONSTANTS(:,28)))./(1.00000 - exp( - CONSTANTS(:,34))) }, 0.00000);
    ALGEBRAIC(:,30) =  ALGEBRAIC(:,15).*CONSTANTS(:,30);
    ALGEBRAIC(:,55) = power(STATES(:,17), CONSTANTS(:,84))./(power(CONSTANTS(:,85), CONSTANTS(:,84))+power(STATES(:,17), CONSTANTS(:,84)));
    ALGEBRAIC(:,59) =  CONSTANTS(:,86).*(1.00000 - ALGEBRAIC(:,30)).*ALGEBRAIC(:,55).*(STATES(:,3) - CONSTANTS(:,66));
    ALGEBRAIC(:,28) =  ALGEBRAIC(:,15).*CONSTANTS(:,29);
    ALGEBRAIC(:,69) = ( STATES(:,21).*ALGEBRAIC(:,28).*1.00000)./(1.00000+power((ALGEBRAIC(:,68) - STATES(:,21))./ALGEBRAIC(:,67), 2.00000));
    ALGEBRAIC(:,70) =  CONSTANTS(:,98).*(STATES(:,21) - ALGEBRAIC(:,69)).*(STATES(:,3) - CONSTANTS(:,130));
    ALGEBRAIC(:,71) =  CONSTANTS(:,120).*(STATES(:,3) - CONSTANTS(:,131));
    ALGEBRAIC(:,72) = ALGEBRAIC(:,43)+ALGEBRAIC(:,70)+ALGEBRAIC(:,36)+ALGEBRAIC(:,49)+ALGEBRAIC(:,71)+ALGEBRAIC(:,59)+ALGEBRAIC(:,52);
    ALGEBRAIC(:,42) =  ALGEBRAIC(:,39).*CONSTANTS(:,31);
    ALGEBRAIC(:,45) =  CONSTANTS(:,21).*(1.00000+ALGEBRAIC(:,42));
    ALGEBRAIC(:,48) = ( CONSTANTS(:,23).*power(STATES(:,2).*1000.00, CONSTANTS(:,22)))./(power(STATES(:,2).*1000.00, CONSTANTS(:,22))+power(ALGEBRAIC(:,45), CONSTANTS(:,22)));
end

% Compute result of a piecewise function
function x = piecewise(cases, default)
    set = [0];
    for i = 1:2:length(cases)
        if (length(cases{i+1}) == 1)
            x(cases{i} & ~set,:) = cases{i+1};
        else
            x(cases{i} & ~set,:) = cases{i+1}(cases{i} & ~set);
        end
        set = set | cases{i};
        if(set), break, end
    end
    if (length(default) == 1)
        x(~set,:) = default;
    else
        x(~set,:) = default(~set);
    end
end

% Pad out or shorten strings to a set length
function strout = strpad(strin)
    req_length = 160;
    insize = size(strin,2);
    if insize > req_length
        strout = strin(1:req_length);
    else
        strout = [strin, blanks(req_length - insize)];
    end
end

