% Esteban Javier Cristaldo Morales
% Example script to simulate DAPHNE waveforms using the HD cold amplifier and HPK and FBK SiPMs.
% The simulation sample time is Ts = 16e-9.
% The first part consist of an example to generate waveforms.

% load the .mat file containing the transfer functions and charge fit
% functions.
% Description of the data:
% Fit functions:
%   -afe_vgain_to_decibels(VGAIN): returns the AFE gain in dB for a given VGAIN in
%                           volts [V] in the range 0V to 1.2V. (LNA gain 12dB; PGA gain 24dB)
%   -fit_charge_fbk(ov): returns the total SiPM single microcell charge displacement
%                        in a Geiger discharge event(in other words, the charge generated
%                        by a photon hit) for a given ov (overvoltage) in volts [V].
% Transfer functions:
%   -tf_model_fbk: FBK+coldamp transfer function.
%   -tf_model_hpk: HPK+coldamp transfer function.
%   -tf_model_AFE: AFE transfer function (integrators off).
%   -tf_model_AFE_integrator: AFE integrators enabled transfer function (must be aplied after tf_model_AFE).

load('simulation_data.mat')

% Setting the simulation sample time.
Ts = 16e-9;

% Simulation parameters. 
VGAIN = 0.89; %[V] - AFE VGAIN configuration.
fbk_ov = 4.5; %[V] - FBK overvoltage for a photon detection efficiency of 45%
hpk_ov = 2.5; %[V] - HPK overvoltage for a photon detection efficiency of 45%
Cadc = (2^14)/2; % DAPHNE V to ADU conversion factor
offset = 2^14/2; % offset at the midpoint.

% Calculation of the amount of charge generated in a event for both HPK and FBK SiPMs.
fbk_spe_charge = fit_charge_fbk(fbk_ov); % [C] FBK single P.E. generated charge in coulomb.
hpk_spe_charge = fit_charge_hpk(hpk_ov); % [C] HPK single P.E. generated charge in coulomb. 

% Let's create a delta event at around 1us
len_event = 4096; %Length of an event.
time = 0:Ts:Ts*(len_event-1); %Time vector of the event.
delta_event = zeros(1,len_event); % vector of zeros
delta_event(round(1e-6/Ts)) = 1; % Photon hit at around 1us

% Now, multiply the charge to the delta
delta_event_fbk = fbk_spe_charge*delta_event;
delta_event_hpk = hpk_spe_charge*delta_event;
clear delta_event;

% Overimposing a simulation of 0 to 5 P.E.
coldamp_signal_fbk = zeros(6,len_event);
coldamp_signal_hpk = zeros(6,len_event);

% In this for cycle, we multiply the vector with the number of photons nf. 
for nf=1:6
    % The filter function performs the convolution of the delta functions
    % and the transfer functions.
    % Also, we add a white gaussian noise with 300uV RMS (uncomment to enable)
    coldamp_signal_fbk(nf,:) = filter(tf_model_fbk.Numerator,tf_model_fbk.Denominator,nf*delta_event_fbk); % + wgn(1,len_event,20*log10(300e-6)); 
    coldamp_signal_hpk(nf,:) = filter(tf_model_hpk.Numerator,tf_model_hpk.Denominator,nf*delta_event_hpk); % + wgn(1,len_event,20*log10(300e-6));
end

% Plotting the results
close all
figure(1)
plot(time*1e6,coldamp_signal_fbk*1e6)
grid on 
title('HD Cold amplifier simulation','SiPM: FBK','FontSize',14,'Interpreter','latex')
xlabel('Time [$\mu$s]','FontSize',12,'Interpreter','latex')
ylabel('Amplitude [$\mu$V]','FontSize',12,'Interpreter','latex')
xlim([0 10])
figure(2)
plot(time*1e6,coldamp_signal_fbk*1e6)
grid on
title('HD Cold amplifier simulation','SiPM: HPK','FontSize',14,'Interpreter','latex')
xlabel('Time [$\mu$s]','FontSize',12,'Interpreter','latex')
ylabel('Amplitude [$\mu$V]','FontSize',12,'Interpreter','latex')
xlim([0 10])

% Now, we have to filter the output of the cold amplifier with the AFE
% transfer function. 
% But first, we have to calculate the AFE gain. 
AFE_gain_dB = afe_vgain_to_decibels(VGAIN); % AFE gain in dB. 
AFE_gain = 10^(AFE_gain_dB/20); % absolute AFE gain.

% Finally, we apply the conversion factor from volts to ADU. 
AFE_total_gain = Cadc*AFE_gain;

% Apply the AFE filters.
DAPHNE_signal_fbk = zeros(6,len_event);
DAPHNE_signal_hpk = zeros(6,len_event);

for nf=1:6
    % The tf_model_AFE outputs a normalized waveform, so we multiply the
    % total gain to the filtered vectors.
    DAPHNE_signal_fbk(nf,:) = AFE_total_gain*filter(tf_model_AFE.Numerator,tf_model_AFE.Denominator,coldamp_signal_fbk(nf,:)) + offset;
    DAPHNE_signal_hpk(nf,:) = AFE_total_gain*filter(tf_model_AFE.Numerator,tf_model_AFE.Denominator,coldamp_signal_hpk(nf,:)) + offset;
end

%Lets convert the data to a fixed point data, 14 bits unsigned data.
DAPHNE_signal_fbk = fi(DAPHNE_signal_fbk,false,14,0);
DAPHNE_signal_hpk = fi(DAPHNE_signal_hpk,false,14,0);
% Plotting the results
figure(3)
plot(time*1e6,DAPHNE_signal_fbk)
grid on 
title('HD DAPHNE simulation','SiPM: FBK','FontSize',14,'Interpreter','latex')
xlabel('Time [$\mu$s]','FontSize',12,'Interpreter','latex')
ylabel('Amplitude [ADU]','FontSize',12,'Interpreter','latex')
xlim([0 10])
figure(4)
plot(time*1e6,DAPHNE_signal_hpk)
grid on
title('HD DAPHNE simulation','SiPM: HPK','FontSize',14,'Interpreter','latex')
xlabel('Time [$\mu$s]','FontSize',12,'Interpreter','latex')
ylabel('Amplitude [ADU]','FontSize',12,'Interpreter','latex')
xlim([0 10])

% No in this part, let's simulate a scintillation event from the data that
% Maritza simulated. 

%Load the montecarlo data with a specific energy. In this case 0.5GeV
%The data is stored in a cell array, it comprises of 100 events, 480 channels each with a
%vector of photon hits. The variable is called: events. 
load('montecarlo_photons_0_5GeV.mat')

%Let's load an specific event

event_number = 50;
channel = 100;
event_data = events{event_number}{channel}; % event_number: 1 to 100; channel: 1 to 480;
channel_number_int = event_data(1); % this variable is unused, corresponds to channel number: 0 to 479 
number_of_photons = event_data(2); % Number of photons in the event. 
photon_hits = event_data(3:end); % from sample 3 to the end: photon hits in microseconds units.


Ts_u = Ts*1e6; % Sampling time in microseconds.
histogramEdges = 0:Ts_u:Ts_u*len_event; % defining the histogram edges. 
deltaPhotonWaveform = histcounts(photon_hits,histogramEdges); % generate the histogram of photon hits with x axis in microseconds.
deltaPhotonWaveform = circshift(deltaPhotonWaveform,round(1e-6/Ts)); % shift 1us to the rigth to have a pedestal.

% Now, with the scintillation hits vector: deltaPhotonWaveform. We generate
% the waveforms as we did above.

% deltaPhotonWaveform are deltas with y axis in P.E. so we need to multiply
% by the SiPMs spe charge.
deltaPhotonWaveform_fbk = fbk_spe_charge*deltaPhotonWaveform;
deltaPhotonWaveform_hpk = hpk_spe_charge*deltaPhotonWaveform;

% Filter with SiPM+coldamp transfer function.
coldamp_signal_fbk_scintillation = filter(tf_model_fbk.Numerator,tf_model_fbk.Denominator,deltaPhotonWaveform_fbk); % + wgn(1,len_event,20*log10(300e-6));
coldamp_signal_hpk_scintillation = filter(tf_model_fbk.Numerator,tf_model_fbk.Denominator,deltaPhotonWaveform_hpk); % + wgn(1,len_event,20*log10(300e-6));

% Filter with AFE transfer function. Multiply by the total gain.
DAPHNE_signal_fbk_scintillation = AFE_total_gain*filter(tf_model_AFE.Numerator,tf_model_AFE.Denominator,coldamp_signal_fbk_scintillation) + offset;
DAPHNE_signal_hpk_scintillation = AFE_total_gain*filter(tf_model_AFE.Numerator,tf_model_AFE.Denominator,coldamp_signal_hpk_scintillation) + offset;

% Convert the data to fixed point numbers.
DAPHNE_signal_fbk_scintillation = fi(DAPHNE_signal_fbk_scintillation,false,14,0);
DAPHNE_signal_hpk_scintillation = fi(DAPHNE_signal_hpk_scintillation,false,14,0);

%Plotting the data
figure(5)
plot(time*1e6,deltaPhotonWaveform)
grid on 
title('Scintillation - HD DAPHNE simulation','Photon Hits','FontSize',14,'Interpreter','latex')
xlabel('Time [$\mu$s]','FontSize',12,'Interpreter','latex')
ylabel('Amplitude [P.E.]','FontSize',12,'Interpreter','latex')
xlim([0 20])
figure(6)
plot(time*1e6,DAPHNE_signal_fbk_scintillation)
grid on 
title('Scintillation - HD DAPHNE simulation','SiPM: FBK','FontSize',14,'Interpreter','latex')
xlabel('Time [$\mu$s]','FontSize',12,'Interpreter','latex')
ylabel('Amplitude [ADU]','FontSize',12,'Interpreter','latex')
xlim([0 20])
figure(7)
plot(time*1e6,DAPHNE_signal_hpk_scintillation)
grid on
title('Scintillation - HD DAPHNE simulation','SiPM: HPK','FontSize',14,'Interpreter','latex')
xlabel('Time [$\mu$s]','FontSize',12,'Interpreter','latex')
ylabel('Amplitude [ADU]','FontSize',12,'Interpreter','latex')
xlim([0 20])

