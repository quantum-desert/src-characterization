%% MAC EGEN src characterization
% constants
show_1=1;
show_2=1;
dark_green = '#4E6766';
light_green = '#b4c292';
dark_pink = '#EFAAC4';
light_pink = '#FFC4D1';

% automate file scan
files = dir; 
files = files(~[files.isdir]); % remove dir nav
files = files(~contains(string({files.name}), "ini", 'IgnoreCase', true));
filenames = string({files.name});

% select most recent from each type
dates = [files.datenum];
[~, order] = sort(dates, "descend");
filenames = filenames(order);
% filenames = filenames(1:min(10,numel(filenames)));

traceIdxS1 = find(contains(filenames, 'Trace') & contains(filenames, 'S1'), 1, 'first');
traceIdxS2 = find(contains(filenames, 'Trace') & contains(filenames, 'S2'), 1, 'first');

histIdxS1  = find(~contains(filenames, 'Trace') & contains(filenames, 'S1'), 1, 'first');
histIdxS2  = find(~contains(filenames, 'Trace') & contains(filenames, 'S2'), 1, 'first');

fname_S1 = filenames(histIdxS1);
fname_S1_trc = filenames(traceIdxS1);

fname_S2 = filenames(histIdxS2);
fname_S2_trc = filenames(traceIdxS2);


disp(strcat('Reading S1 hist: ',fname_S1));
disp(strcat('Reading S1 trace: ',fname_S1_trc));

disp(strcat('Reading S2 hist: ',fname_S2));
disp(strcat('Reading S2 trace: ',fname_S2_trc));
disp(' ');

% =zeros(1e4,2)

d1=read_time_tagger(fname_S1);
d2=read_time_tagger(fname_S2);
trc1=read_time_tagger(fname_S1_trc);
trc2=read_time_tagger(fname_S2_trc);

% coincidence data
t1=d1(:,1); c1=d1(:,2);
t2=d2(:,1); c2=d2(:,2);

% time trace data
% *** nomenclature ***
% tagger C1 / SNSPD P3 = signal 
% tagger C2 / SNSPD P4 = idler

% source 1
t1_trc=trc1(:,1); 
dsig1_trc=trc1(:,3); % channel 1, signal
didl1_trc=trc1(:,2); % channel 2, idler

% source 2
t2_trc=trc2(:,1); 
dsig2_trc=trc2(:,3); % channel 1, signal
didl2_trc=trc2(:,2); % channel 2, idler

% find CAR
% report_1 = compute_symmetric_CAR(t1,c1);
% report_2 = compute_symmetric_CAR(t2,c2);
% 
% src1='S1 ';
% src2='S2 ';
% 
% disp(strcat(src1,' Symmetric CAR=',num2str(round(report_1.CAR,3))))
% disp(strcat(src2,' Symmetric CAR=',num2str(round(report_2.CAR,3))))
% 
%% calculate asymmetric CAR
report_1_asym = compute_asymmetric_CAR(t1,c1,t1_trc,didl1_trc,dsig1_trc);
report_2_asym = compute_asymmetric_CAR(t2,c2,t2_trc,didl2_trc,dsig2_trc);

if(show_1)
% disp(strcat('S1 Asymmetric CAR=',num2str(round(report_1_asym.CAR_asym,3))))
% disp(strcat('S1 Cacc: ',num2str(report_1_asym.Cacc)));
% disp(' ');
end

if(show_2)
% disp(strcat('S2 Asymmetric CAR=',num2str(round(report_2_asym.CAR_asym,3))))
% disp(strcat('S2 Cacc: ',num2str(report_2_asym.Cacc)));
% disp(' ');

end
% disp(strcat('S2 S_i: ',num2str(report_2_asym.S_i)));
% disp(strcat('S2 S_s: ',num2str(report_2_asym.S_s)));

%% Calculate heralding efficiency

% measured 3/6/26 weekly report
eta_hs1 = 0.37; % collection efficiency signal arm (src 1)
eta_hs2 = 0.366; % collection efficiency signal arm (src 2)
eta_hi1 = 0.387; % collection efficiency of idler arm (src 1)
eta_hi2 = 0.387; % collection efficiency of idler arm (src 1)




report_S1 = compute_heralding_eff(t1,c1,didl1_trc,dsig1_trc,eta_hi1,eta_hs1);
report_S2 = compute_heralding_eff(t2,c2,didl2_trc,dsig2_trc,eta_hi2,eta_hs2);

if(show_1)
disp(strcat('S1 peak rate =',num2str(round(1e2*report_S1.c_true_r,2))," CpS"));
disp(strcat('S1 raw Heralding Efficiency=',num2str(round(1e2*report_S1.h_raw,2)),'%'));
disp(strcat('S1 Heralding Efficiency=',num2str(round(1e2*report_S1.h,2)),'%'));
disp(strcat('S1 Asymmetric CAR=',num2str(round(report_1_asym.CAR_asym,3))))
disp(strcat('S1 Cacc: ',num2str(report_1_asym.Cacc)));end

if(show_2)
disp(strcat('S2 peak rate =',num2str(round(1e2*report_S2.c_true_r,2))," CpS"));
disp(strcat('S2 raw Heralding Efficiency=',num2str(round(1e2*report_S2.h_raw,2)),'%'));
disp(strcat('S2 Heralding Efficiency=',num2str(round(1e2*report_S2.h,2)),'%'));
disp(strcat('S2 Asymmetric CAR=',num2str(round(report_2_asym.CAR_asym,3))))
disp(strcat('S2 Cacc: ',num2str(report_2_asym.Cacc)));


end





%% plotting
figure; hold on;
if(show_1)
    % show coincidence counts
    plot(t1,c1,LineWidth=1.5,DisplayName='Counts S_1');
    % show peak window
    xline(report_1_asym.left_t,LineWidth=1.5,DisplayName='Peak Integration Boundary (L)');
    xline(report_1_asym.right_t,LineWidth=1.5,DisplayName='Peak Integration Boundary (R)');
    xline(report_1_asym.loc,color='m',LineWidth=1.5,DisplayName='Peak Loc.');

    % % show bg window
    % xline(t1(report_1.start_bg_idx),color='b',LineWidth=1.5,DisplayName='BG Integration Boundary (L)');
    % xline(t1(report_1.Nbg+report_1.start_bg_idx),color='b',LineWidth=1.5,DisplayName='BG Integration Boundary (R)');
end

if(show_2)
    % show coincidence counts
    plot(t2,c2,LineWidth=1.5,DisplayName='Counts S_2');
    % show peak window
    xline(report_2_asym.left_t,LineWidth=1.5,DisplayName='Peak Integration Boundary (L)');
    xline(report_2_asym.right_t,LineWidth=1.5,DisplayName='Peak Integration Boundary (R)');
    xline(report_2_asym.loc,color='m',LineWidth=1.5,DisplayName='Peak Loc.');

    % % show bg window
    % xline(t2(report_2_asym.start_bg_idx),color='b',LineWidth=1.5,DisplayName='BG Integration Boundary (L)');
    % xline(t2(report_2_asym.Nbg+report_2_asym.start_bg_idx),color='b',LineWidth=1.5,DisplayName='BG Integration Boundary (R)');


end

xlim([min(report_2_asym.left_t,report_1_asym.left_t)-1e3 max(report_2_asym.right_t,report_1_asym.right_t)+1e3]);

legend;
xlabel('Time Diff (ps)'); ylabel('Counts');
ylim([-10 max(max(c1),max(c2))+50]);

% plot time trace data
figure; hold on;
if(show_1)
    plot(t1_trc,dsig1_trc,LineWidth=1.5,DisplayName='(S1) Signal Count Rate')
    plot(t1_trc,didl1_trc,LineWidth=1.5,DisplayName='(S1) Idler Count Rate')
end
if(show_2)
    plot(t2_trc,dsig2_trc,LineWidth=1.5,DisplayName='(S2) Signal Count Rate')
    plot(t2_trc,didl2_trc,LineWidth=1.5,DisplayName='(S2) Idler Count Rate')
end
% styling
colororder("sail"); 
xlabel('Time (ps)'); ylabel('Counts');
title('Count Rate (Counts/s)');
legend('Location','east');



%% functions 
function data = read_time_tagger(filename)
    % read_time_tagger Reads a TXT file with time and counts data
    % Input:
    %   filename - path to the txt file
    %
    % Output:
    %   data - table with columns: time offset (ps), counts (#)
    data = readmatrix(filename, 'NumHeaderLines', 1);

    
end

function report = find_peak_int(t,c)
    % find peak, integrate, return integral and width, standardized
    Pmin=max(c)*0.5; % peak prominence threshold
    [pk,loc,width]=findpeaks(c,t,'MinPeakProminence', Pmin);
    [~,id_sel]=max(pk);
    pk=pk(id_sel); loc=loc(id_sel); width=width(id_sel);
    width=2.5*width; % expand FWHM integration region (ps)
    
    % integrate over peak (asymmetrically)
    asymmetry=0.5; % 0.5 = balanced
    left_t = loc-width*asymmetry;
    right_t = loc+width*(1-asymmetry);
    [~, idx_l] = min(abs(t - left_t));
    [~, idx_r] = min(abs(t - right_t));
    Npk = idx_r-idx_l; % num bins in peak integral
    C_pk = sum(c(idx_l:idx_r));

    % build report
    report.Npk = Npk;
    report.C_pk = C_pk;
    report.width = width;
    report.left_t = left_t;
    report.right_t = right_t;
    report.loc = loc;
end

function report = compute_symmetric_CAR(t,c)
    % compute symmetric CAR
    % sample rate
    
    rate=t(2)-t(1); % ps

    % Find peak + integrate
    r = find_peak_int(t,c); 
    
    % compute background counts / bin
    Nb = length(t); % number of bins
    Nbg = 1*floor(r.width/rate); % bins in noise window
    % count in background window of same width
    start_bg_idx=1e3; % choose based on flatness
    
    % calculate bg counts
    C_bg = sum(c(start_bg_idx:Nbg+start_bg_idx));
    
    % normalize to peak width
    Cacc_meas = C_bg*r.Npk/Nbg;
    
    % Estimate CAR
    % "True to Accidental formulation"
    CAR = (r.C_pk-Cacc_meas)/Cacc_meas;

    % build report
    report.Cpk = r.C_pk;
    report.Cacc = Cacc_meas;
    report.CAR = CAR;
    report.left_t=r.left_t;
    report.right_t=r.right_t;
    report.Nbg=Nbg;
    report.start_bg_idx=start_bg_idx;
    report.loc=r.loc;
end

function report = compute_asymmetric_CAR(t,c,t_trc,ri_trc,rs_trc)
    % GOAL: Compute asymmetric CAR

    % t = coincidence histogram time
    % c = coincidence histogram data
    % t_trc = single count time
    % ri_trc = idler singles rate
    % rs_trc = signal singles rate

    % sample rate
    rate=t(2)-t(1); % ps
    
    % Find peak + integrate
    r = find_peak_int(t,c); 

    % compute background counts / bin
    % Nb = length(t); % number of bins
    Nbg = 1*floor(r.width/rate); % bins in noise window (convert to index)
    % count in background window of same width
    start_bg_idx=1e2; % choose based on flatness
    
    % calculate bg counts
    C_bg = sum(c(start_bg_idx:Nbg+start_bg_idx));
    
    % normalize to peak width
    C_acc_sym = C_bg*r.Npk/Nbg;

    % true counts within peak window
    C_true=r.C_pk-C_acc_sym;



    % peak acquisition time
    tau_c=rate*r.Npk*1e-12; % seconds

    % idler singles measurement (rate basis)
    S_i = mean(ri_trc);

    % signal singles measurement (rate basis)
    S_s = mean(rs_trc);

    % accidental coincidence rate
    R_acc = S_i*S_s*tau_c; % rate basis s^-1 


    % accidental coincidence counts
    C_acc_asym = R_acc*(t_trc(end)-t_trc(1))/1e12; % count basis

    % compute asymmetric count rate
    CAR_asym = C_true / C_acc_asym;

    % calculate rate / rate
    T=10; % (s), integration time
    Herald = (r.C_pk/T)/(S_i);

    % build report
    report.Cpk = r.C_pk;
    report.Cacc = C_acc_sym;
    report.left_t=r.left_t;
    report.right_t=r.right_t;
    report.Nbg=Nbg;
    report.start_bg_idx=start_bg_idx;
    report.S_i = S_i;
    report.S_s = S_s;
    report.tau_c = tau_c;
    report.CAR_asym = CAR_asym;
    report.h = Herald;
    report.loc = r.loc;
end

% TESTED: THIS PRODUCES SAME HERALDING AS PREV
function report = compute_heralding_eff(t,c,ri_trc,rs_trc,eta_i,eta_s)
% 


    % compute the corrected heralding efficiency
    % conditioned in signal click

    % t = coincidence histogram time
    % c = coincidence histogram data
    % rs_trc = signal singles rate
    % eta_i = idler collection efficiency, including up to SNSPD

    % constants (S1)
    bg_idler = 800; % counts / s
    bg_signal = 800; % counts / s


    % sample rate
    sample_rate=t(2)-t(1); % ps

    % integration time
    T=10; % seconds
    
    % Find peak + integrate
    r = find_peak_int(t,c);

    % compute background counts / bin
    Nacc = 1*floor(r.width/sample_rate); % bins in noise window (convert to index)
    % count in background window of same width
    
    % check peak index outside (1:Nbg)
    % r.loc
    % r.width
    % if(r.loc<2*r.width)
    %     disp("Warning: noise integration WITHIN peak window");
    % end

    % calculate accidental counts (normalized to peak width)
    C_acc = sum(c(1:Nacc));

    % convert to accidental count rate basis
    c_acc_r = C_acc/T; % counts/s

    % coincidence count rate basis
    c_r = r.C_pk/T;  % counts/s

    % calculate true coincidence rate
    c_true_r = max(c_r - c_acc_r,0); % counts / s  ; zero clamp

    % % signal rate, background corrected
    s_net = mean(rs_trc) - bg_signal/T; % eta_s not needed, cancels out

    
    % % signal rate, background corrected
    i_net = (mean(ri_trc) - bg_idler); % 

    % % calculate signal-conditioned idler heralding efficiency
    % % included: correction for accidentals + bg + signal / idler loss
    % h = (1/eta_i)*c_true_r/s_net; % probability idler clicks given signal clicked

    % raw
    h_raw = c_true_r/s_net; % probability idler clicks given signal clicked
    h = h_raw / eta_i;


    % comput idler-conditioned herlading efficiency
    % h = (1/eta_s)*c_true_r/i_net;
    report.h_raw = h_raw;
    report.h = h;
    report.c_true_r = c_true_r;
    report.c_acc_r = c_acc_r;
    report.CAR = c_true_r / c_acc_r;
end