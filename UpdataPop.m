function [newPop,newPbest] = UpdataPop(pop,N,weight_obj, weight_dec)

    % 非支配排序
    FrontNo = NDSort(pop.objs, inf); 
    
    % 选择个体
    newPop = [];
    newPbest=[];
    currentFront = 1;
    while length(newPop) + sum(FrontNo == currentFront) <= N
        newPop = [newPop, pop(FrontNo == currentFront)];
        currentFront = currentFront + 1;
    end
    
    % 如果还需要选择更多个体
    if length(newPop) < N
        LastFront = pop(FrontNo == currentFront);
        % 计算拥挤距离
        CrowdDis = CrowdDistance(LastFront,weight_obj, weight_dec);
        [~, idx] = sort(CrowdDis, 'descend');
        numNeeded = N - length(newPop);
        newPop = [newPop, LastFront(idx(1:numNeeded))];
    end

end