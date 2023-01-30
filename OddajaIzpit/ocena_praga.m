function ocena_praga(record, annot, st, hz)
    %vhod funkcije je 'eegmmidb/S001/S001R03.edf' oziroma 'event'
    %hz je 13 ali 30 za filter
    %st je n in je koeficient natancnosti za keo filter
    %output je graf raztrosa
    [sig, fs, ts] = rdsamp(record, 1:64);
    [ant, t, s, c, n, cmt]=rdann(record, annot);
    

    %empty celica kam boš shranla vse intervale signalov
    signaliT1 = {};
    signaliT2 = {};
    %transposaj signal. nov signal je n x m signal krat cas, n je 64
    sig_trans = sig.';
    [stolpec,vrstica] = size(sig_trans);
    %pridobi intervale 
    [T0, T1, T2] = getIntervals(record,annot,fs,vrstica);
    %shrani signale iz intervalov v celico 
    %shranjevanje na konec, vseh 64 signalov ampak samo določeni intervali
    for j=1:size(T1,1)
        signaliT1{end+1} = sig_trans(:,T1(j,1):T1(j,2));
    end
    for j=1:size(T2,1)
        signaliT2{end+1} = sig_trans(:,T2(j,1):T2(j,2));
    end
    
    %interval prepuscanja 8-13
    F = [0 8 8 hz hz fs/2]/(fs/2);
    %da povem kje se prepusca 
    A = [0 0 1 1 0 0];
    %n=25;
    n=st;
    %izracunaj koeficiente za filter
    b= firls(n, F, A);
    %izracunaj matriko za ucenje drugih intervalov
    [W] = f_CSP(cell2mat(signaliT1(1)), cell2mat(signaliT2(1)));
    x_T1 = [];
    y_T1 = [];
    x_T2 = [];
    y_T2 = [];
  
    %vzemi enako st intervalov
    meja = min(size(signaliT1,2), size(signaliT2,2));
    
    for i=2:meja
        %uporabi spv filter
        st1_spv = W*cell2mat(signaliT1(i));
        %filtriraj prvi in zadnji signal s keo filterjem 
        sT1_to_filter = [st1_spv(1,:); st1_spv(64,:)];
        sT1_filtered = filter(b,1,sT1_to_filter);
        %izracunaj log in var na filtriranih signalih
        x_T1 = [x_T1 log(var(sT1_filtered(1,:)))];
        y_T1 = [y_T1 log(var(sT1_filtered(2,:)))];
        
    end
    for i=2:meja
        %uporabi spv filter
        st2_spv = W*cell2mat(signaliT2(i));
        %filtriraj prvi in zadnji signal s keo filterjem 
        sT2_to_filter = [st2_spv(1,:); st2_spv(64,:)];
        sT2_filtered = filter(b,1,sT2_to_filter);
        %izracunaj log in var na filtriranih signalih
        x_T2 = [x_T2 log(var(sT2_filtered(1,:)))];
        y_T2 = [y_T2 log(var(sT2_filtered(2,:)))];
       

    end
    
    %nariši diagram raztresa
    figure('NumberTitle', 'off', 'Name', num2str(n));
    scatter(x_T1, y_T1);
    hold on
    scatter(x_T2, y_T2);
   
end