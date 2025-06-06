function do_rns_fxy_plots(gc_info, figsdir, tfsclim, zclim, timevec, ...
                      overwrite_all_figs, overwrite_ioz_figs);

if ~exist(figsdir, 'dir')
    mkdir(figsdir);
end

forwarddir = fullfile(figsdir, 'forward');
if ~exist(forwarddir, 'dir')
    mkdir(forwarddir);
end

% forwardthreshdir = fullfile(figsdir, 'forward_thresh');
% if ~exist(forwardthreshdir, 'dir')
%     mkdir(forwardthreshdir);
% end

backwarddir = fullfile(figsdir, 'backward');
if ~exist(backwarddir, 'dir')
    mkdir(backwarddir);
end

% backwardthreshdir = fullfile(figsdir, 'backward_thresh');
% if ~exist(backwardthreshdir, 'dir')
%     mkdir(backwardthreshdir);
% end

% diffdir = fullfile(figsdir, 'diff');
% if ~exist(diffdir, 'dir')
%     mkdir(diffdir);
% end

if ~exist('sz_onset_s', 'var')
    sz_onset_s = nan;
end

if ~exist('sz_offset_s', 'var')
    sz_offset_s = nan;
end

if ~exist('overwrite_all_figs', 'var')
    overwrite_all_figs = 1;
end

if ~exist('overwrite_z_figs', 'var')
    overwrite_ioz_figs = 1;
end

tic;

% p = gcp;
% total = size(gc_info.Fxy,1);
% ppm = ParforProgressbar(total, 'parpool', {'local', 4}, ...
%                         'showWorkerProgress', true, 'title', ...
%                         'Plotting Forward Connectivity');

elecs = size(gc_info{1}.Fxy, 1);
freqs = size(gc_info{1}.Fxy, 2);
timepts = size(gc_info{1}.Fxy, 3);
baseline_timepts = size(gc_info{1}.Fxy_baseline, 3);

RowNames = gc_info{1}.channel_names;

allvals_Fxy = nan(elecs, length(gc_info), freqs, timepts);
allvals_Fyx = nan(elecs, length(gc_info), freqs, timepts);
meanvals_Fxy = nan(elecs, freqs, timepts);
meanvals_Fyx = nan(elecs, freqs, timepts);
baselinevals_Fxy = nan(elecs, length(gc_info), freqs, baseline_timepts);
baselinevals_Fyx = nan(elecs, length(gc_info), freqs, baseline_timepts);
baselinemeans_Fxy = nan(elecs, freqs, baseline_timepts);
baselinemeans_Fyx = nan(elecs, freqs, baseline_timepts);

zvals_Fxy = nan(size(meanvals_Fxy));
zvals_Fyx = nan(size(meanvals_Fxy));
iozzvals_Fxy = nan(size(meanvals_Fxy));
iozzvals_Fyx = nan(size(meanvals_Fxy));
noniozzvals_Fxy = nan(size(meanvals_Fxy));
noniozzvals_Fyx = nan(size(meanvals_Fxy));

for i=1:length(gc_info) % for every file,
    for j=1:elecs
        allvals_Fxy(j,i,:,:) = gc_info{i}.Fxy(j,:,:);
        allvals_Fyx(j,i,:,:) = gc_info{i}.Fyx(j,:,:);
        baselinevals_Fxy(j,i,:,:) = gc_info{i}.Fxy_baseline(j,:,:);
        baselinevals_Fyx(j,i,:,:) = gc_info{i}.Fyx_baseline(j,:,:);
    end
end

skipthese = get_skip();

badinds = get_matching_inds(RowNames, skipthese);
goodinds = setdiff(1:elecs, badinds);

for i=1:elecs
    if length(find(badinds==i))>0
        continue
    else
        meanvals_Fxy(i,:,:) = squeeze(mean(allvals_Fxy(i,:,:,:), "omitnan"));
        meanvals_Fyx(i,:,:) = squeeze(mean(allvals_Fyx(i,:,:,:), "omitnan"));
        baselinemeans_Fxy(i,:,:) = squeeze(mean(baselinevals_Fxy(i,:,:,:), "omitnan"));
        baselinemeans_Fyx(i,:,:) = squeeze(mean(baselinevals_Fyx(i,:,:,:), "omitnan"));
        zvals_Fxy(i,:,:) = do_zscore(squeeze(meanvals_Fxy(i,:,:)), squeeze(baselinemeans_Fxy(i,:,:)));
        zvals_Fyx(i,:,:) = do_zscore(squeeze(meanvals_Fyx(i,:,:)), squeeze(baselinemeans_Fyx(i,:,:)));
    end
end

channel_names = {};
for i=1:length(gc_info{1}.channel_names)
    channel_names{end+1} = gc_info{1}.channel_names{i}{1};
end

channel_names_long = {channel_names{2:4} channel_names{3:4} channel_names{4}};

if overwrite_all_figs
    for i=1:elecs
        if i<4
            seedstr = channel_names{1};
        elseif i<6
            seedstr = channel_names{2};
        else
            seedstr = channel_names{3};
        end
        figname = [sprintf('%03d', i) '_' seedstr '_' channel_names_long{i} '.png'];
        figpath = fullfile(forwarddir, figname);
        titstr = [seedstr ' -> ' channel_names_long{i}];
        do_tfs_fig(squeeze(meanvals_Fxy(i,:,:)), tfsclim, gc_info{1}.freqs, ...
                   gc_info{1}.srate, titstr, figpath, timevec);
        
        zfigname = ['z_' sprintf('%03d', i) '_' seedstr '_' channel_names_long{i} '.png'];
        zfigpath = fullfile(forwarddir, zfigname);
        ztitstr = ['Z-Score ' seedstr ' -> ' channel_names_long{i}];
        do_tfs_fig(squeeze(zvals_Fxy(i,:,:)), zclim, gc_info{1}.freqs, gc_info{1}.srate, ...
                   ztitstr, zfigpath, timevec);
        
            % pause(100/total);
            % ppm.increment();
            
    end
end
% delete(ppm);
% ppm = ParforProgressbar(total, 'parpool', {'local', 4}, ...
%                         'showWorkerProgress', true, 'title', ...
%                         'Plotting Backward Connectivity');

if overwrite_all_figs
    for i=1:elecs
        if i<4
            seedstr = channel_names{1};
        elseif i<6
            seedstr = channel_names{2};
        else
            seedstr = channel_names{3};
        end
        
        figname = [sprintf('%03d', i) '_' channel_names_long{i} '_' seedstr '.png'];
        figpath = fullfile(backwarddir, figname);
        titstr = [channel_names_long{i} ' -> ' seedstr];
        do_tfs_fig(squeeze(meanvals_Fyx(i,:,:)), tfsclim, gc_info{1}.freqs, ...
                   gc_info{1}.srate, titstr, figpath, timevec);
        
        zfigname = ['z_' sprintf('%03d', i) '_' channel_names_long{i} '_' seedstr '.png'];
        zfigpath = fullfile(backwarddir, zfigname);
        ztitstr = ['Z-Score ' channel_names_long{i} ' -> ' seedstr];
        do_tfs_fig(squeeze(zvals_Fyx(i,:,:)), zclim, gc_info{1}.freqs, gc_info{1}.srate, ...
                   ztitstr, zfigpath, timevec);
        % pause(100/total);
        %    ppm.increment();

    end
end
% delete(ppm);

close all;
toc;

function do_tfs_fig(dat, cl, freqs, srate, titstr, figpath, ...
                    timevec);
figure('visible', 'off'); 
imagesc(dat); 
axis xy;
colorbar; 
clim(cl);
yticklabels(freqs(yticks));
ylabel('Frequency (Hz)');
xtickvec = 511:2*srate:5001;
xticks(xtickvec);
xticklabels(timevec(xtickvec));
xlabel('Time (s)');
title(titstr);
print('-dpng', figpath);
