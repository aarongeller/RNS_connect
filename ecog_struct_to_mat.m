function m = ecog_struct_to_mat(st)
numchans = length(st);
samples = length(st{1});
m = zeros(numchans, samples);

for i=1:numchans
    m(i,:) = st{i};
end
