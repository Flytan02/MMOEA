% 更新超立方体网格的函数，每个超立方体的质量基于其内部粒子的数量
function [pop,GridIndex] = UpdateGrid(pop, nGrid, alpha)
    % 计算每个超立方体的边界
    fitness = pop.objs;
    fitnessMin = min(fitness);
    fitnessMax = max(fitness);
    if isscalar(fitnessMin)
        fitnessMin = fitness;
        fitnessMax = fitness;
    end   
    dc = fitnessMax-fitnessMin;
    fitnessMin = fitnessMin-alpha*dc;
    fitnessMax = fitnessMax+alpha*dc;
    
    nObj = size(fitness, 2);
    
    empty_grid.LB = [];
    empty_grid.UB = [];
    Grid = repmat(empty_grid, nObj, 1);
    
    for j = 1:nObj        
        cj = linspace(fitnessMin(j), fitnessMax(j), nGrid-1);
        
        Grid(j).LB = [-inf cj];
        Grid(j).UB = [cj +inf];        
    end
    
    % 计算每个粒子属于哪个立方体
    nPop = length(pop);
    GridSubIndex = zeros(nPop,nObj);
    GridIndex = zeros(nPop,1);
    for i = 1:nPop
        
        for j = 1:nObj  
            objs=pop(i).objs;
            GridSubIndex(i,j) = ...
                find(objs(j)<Grid(j).UB, 1, 'first');        
        end
    
        GridIndex(i) = GridSubIndex(i,1);
        for j = 2:nObj
            GridIndex(i) = GridIndex(i)-1;
            GridIndex(i) = nGrid*GridIndex(i);
            GridIndex(i) = GridIndex(i)+GridSubIndex(i,j);
        end
    end
end