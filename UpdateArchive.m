function Archive = UpdateArchive(Archive,N)
% Update the archive

%------------------------------- Copyright --------------------------------
% Copyright (c) 2024 BIMK Group. You are free to use the PlatEMO for
% research purposes. All publications which use this platform or any code
% in the platform should acknowledge the use of "PlatEMO" and reference "Ye
% Tian, Ran Cheng, Xingyi Zhang, and Yaochu Jin, PlatEMO: A MATLAB platform
% for evolutionary multi-objective optimization [educational forum], IEEE
% Computational Intelligence Magazine, 2017, 12(4): 73-87".
%--------------------------------------------------------------------------

    %% Find the non-dominated solutions
    Archive = Archive(NDSort(Archive.objs,1)==1);
    
    %% Truncate the archive according to the crowding distances
    if length(Archive) > N
        % 计算目标空间拥挤距离
        nPop = length(Archive);
        nDel = nPop-N;
        rank = zeros(nPop,1);
        nObj = size(Archive.objs,2);
        ObjCrowding = zeros(nPop,1);   
    
        fitness = Archive.objs;
        for j = 1:nObj
            [jFit,idx] = sort(fitness(:,j),'ascend');
            jFit_up     = [jFit(2:end); Inf];
            jFit_down   = [-Inf; jFit(1:end-1)];
            distance = (jFit_up-jFit_down)./(max(jFit)-min(jFit));
            [~,idx]  = sort(idx,'ascend');
            ObjCrowding = ObjCrowding + distance(idx);
        end
        ObjCrowding(isnan(ObjCrowding)) = Inf;
               
        % 删除拥挤距离最小的额外粒子
        [~,del_idx] = sort(ObjCrowding,'ascend');
        for i = 1:nDel
            rank(del_idx(i)) = 1;
        end
        Archive = Archive(rank<1);
    end
end