function iNRRankAgg = loadWorkerRanking(Header,Spec)
    %Loads current rank aggregation ranking
    getFile = 0;
    iMin = 0;
    while getFile == 0 && iMin < 30;
        try
            iNRRankAgg = load(['../data/Output/',Header,Spec,'/NRAgg.txt']);
            getFile = 1;
        catch
            pause(60);
            iMin = iMin + 1;
        end
    end
    if iMin == 30
        error('Failed to load NRAgg.txt')
    end
    iNRRankAgg(:,2) = vec(1:numel(iNRRankAgg));
    iNRRankAgg    = sortrows(iNRRankAgg,1);
end