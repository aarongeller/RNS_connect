function brainstorm_import_ecog(subj, fname)

% check if brainstorm is running and if not, start it
if ~brainstorm('status')
    brainstorm;
end

protocolname = 'RNS_connect';
gui_brainstorm('SetCurrentProtocol', bst_get('Protocol', protocolname));

ecogdir = fullfile('~/Documents/school/4202/RNS_connect/data', subj, 'MatDir');
datapath = fullfile(ecogdir, fname);

s = load(datapath);

% convert to matrix and save
ofname = split(fname, '.');
ofname = [ofname{1} '_data.mat'];
rawfilepath = fullfile(ecogdir, ofname);
m = ecog_struct_to_mat(s.ECoG_data);
save(rawfilepath, 'm');

% review raw EEG file
sFileRaw = bst_process('CallProcess', 'process_import_data_raw', [], [], ...
                       'subjectname',    subj, ...
                       'datafile',       {{rawfilepath}, 'EEG-MAT'}, ...
                       'channelreplace', 0, 'channelalign',   0);

