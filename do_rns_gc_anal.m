function do_rns_gc_anal(subj, cond, overwrite_all_figs, overwrite_ioz_figs, ...
                    overwrite_data, overwrite_all_data, tfsclim, ...
                    clim, srate, halfwindow_s)

if ~exist('overwrite_all_figs', 'var')
    overwrite_all_figs = 1;
end

if ~exist('overwrite_ioz_figs', 'var')
    overwrite_ioz_figs = 1;
end

if ~exist('overwrite_data', 'var')
    overwrite_data = 0;
end

if ~exist('overwrite_all_data', 'var')
    overwrite_all_data = 0;
end

if ~exist('tfsclim', 'var')
    tfsclim = [0 1];
end

if ~exist('zclim', 'var')
    zclim = [-5 5];
end

if ~exist('srate', 'var')
    srate = 250;
end

if ~exist('halfwindow_s', 'var')
    halfwindow_s = 10;
end

datapath = '/Users/aaron/Documents/school/4202/RNS_connect/data/';

prefix = fullfile(datapath, subj);

switch subj
  case 'AAB'
    duration_s = 30;
    seedstr = 'LCM2';
    sz_onset_s = [30 35 ...
                 ];
    sz_offset_s = nan;
    if strcmp(cond, 'onset')
        duration_s = 20;
        eegfiles = { 'MatDir/AAB_133164069519770000.mat' ...
                     'MatDir/AAB_133165770759930000.mat' ...
                   };
        % ioz = {'LPT5', 'LPT6', 'LPT7', 'LPT8'};
    elseif strcmp(cond, 'offset')
        offset_s = 70;
        eegfile = 'data_block001_notch.mat';
        extra_offset = 0;
    end
end

outputdir = ['granger_' cond];
analdir = fullfile('analyses', subj);
figsdir = fullfile(analdir, 'figs', outputdir);

% load(fullfile([prefix channeldirpart], ));

% select 20 sec around onset time
order = 10; % need to pad beginning by this many samples

varname =  [subj '_gcinfo_' cond];
filename = [varname '.mat'];
datapath = fullfile("analyses", subj, filename);

samplevec = (round(-srate*halfwindow_s) - order):round(srate*halfwindow_s);
timevec = samplevec./srate;

% compute gc if necessary
if overwrite_data
    if ~exist(datapath, 'file') || overwrite_all_data
        gc_info.files = {};
        gc_info.data = {};

        if ~exist(analdir, 'dir')
            mkdir(analdir);
        end
    else
        load(datapath);
        eval(['gc_info = ' varname ';']);
    end
    for i=1:length(eegfiles)
        d = fprintf('%s ', datetime("now"));
        fprintf([d int2str(i) '/' int2str(length(eegfiles)) ') ']);
        if any(strcmp(eegfiles{i}, gc_info.files)) && ~overwrite_all_data
            display(['Skipping ' eegfiles{i} '.']);
            continue
        else
            gc_info.files{end+1} = eegfiles{i};
        end
        display(['Analyzing ' eegfiles{i} '...']);
        eegfname = fullfile(prefix, eegfiles{i});
        load(eegfname);

        timevec = (1:length(ECoG_data{1}))./ECoG_hdr.SamplingRate;
        onset_sample = min(find(timevec >= sz_onset_s(i)));

        start_sample = onset_sample + samplevec(1);
        end_sample = onset_sample + samplevec(end);

        thisgcinfo = do_seeded_gc(ecog_struct_to_mat(ECoG_data), srate, ECoG_hdr.ChannelMap, ...
                                  [], start_sample, end_sample);
        thisgcinfo.eegfname = eegfname;

        gc_info.data{end+1} = thisgcinfo;

        eval([varname ' = gc_info;']);
        save(datapath, varname, '-v7.3');
    end

else
    load(datapath);
    eval(['gc_info = ' varname ';']);
end

% make figs if necessary
if overwrite_all_figs | overwrite_ioz_figs
    do_rns_fxy_plots(gc_info.data, figsdir, tfsclim, zclim, timevec, ...
                 overwrite_all_figs, overwrite_ioz_figs);
    system(['python make_rns_gc_pdf.py ' subj ' granger_' cond]);
end

function m = ecog_struct_to_mat(st)
numchans = length(st);
samples = length(st{1});
m = zeros(numchans, samples);

for i=1:numchans
    m(i,:) = st{i};
end
