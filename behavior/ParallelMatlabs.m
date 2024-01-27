%% Start a parallel pool with 2 workers
parpool('local', 2);

%%
parfor i = 1:2
    if i == 1
        ToneDiscrimination; % Run your first script
    else
        leverIN2leverBytes; % Run your second script
    end
end

%%
delete(gcp); % Close the parallel pool