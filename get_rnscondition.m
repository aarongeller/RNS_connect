function get_rnscondition(subj, condition)

% conditions: Long_Episode, Magnet, Scheduled, Real_Time

if ~exist('condition', 'var')
    condition = 'Long_Episode';
end

tic;

subjdir = fullfile('data', subj);

figsdir = fullfile(subjdir, 'figs', condition);
if ~exist(figsdir, 'dir')
    mkdir(figsdir);
end

% get spreadsheet name
csvname = dir(fullfile(subjdir, '*.csv'));

% open spreadsheet
T = readtable(fullfile(subjdir, csvname.name));

% get column for LEs
ec_colnum = find(strcmp(T.Properties.VariableNames, 'ECoGTrigger'));
fn_colnum = find(strcmp(T.Properties.VariableNames, 'Filename'));

% get rows with desired value
rowinds = find(strcmp(T{:,ec_colnum}, condition));

for i=1:length(rowinds)
    % get filenames for event type
    origfile = T{rowinds(i), fn_colnum};
    fname_parts = split(origfile, '.');
    file_prefix = [subj '_' fname_parts{1}];
    cond_file = [file_prefix '.mat'];
    % load each file for that type
    load(fullfile(subjdir, 'MatDir', cond_file));

    figure('visible','off');
    timevec = (1:length(ECoG_data{1}))./ECoG_hdr.SamplingRate;
    numchannels = length(ECoG_data);
    % for each channel,
    for j=1:numchannels
        subplot(numchannels,1,j);
        % plot the channel
        plot(timevec, ECoG_data{j});
        ylabel([ECoG_hdr.ChannelMap{j} '\muV']);
        xlabel('Time (s)');
        ylim([-500 500]);
        xlim([0 90]);
    end

    % save figure
    print('-dpng', fullfile(figsdir, [file_prefix '.png']));
end

% make document 
system(['python make_rnscondition_pdf.py ' subj ' ' condition]);
toc;
