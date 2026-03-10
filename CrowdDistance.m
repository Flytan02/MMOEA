function CrowdingDistance = CrowdDistance(pop,weight_obj, weight_dec)
        % 计算目标空间拥挤距离
        nPop = length(pop);
        nObj = size(pop.objs,2);
        ObjCrowding = zeros(nPop,1);   
    
        fitness = pop.objs;
        for j = 1:nObj
            [jFit,idx] = sort(fitness(:,j),'ascend');
            jFit_up     = [jFit(2:end); Inf];
            jFit_down   = [-Inf; jFit(1:end-1)];
            distance = (jFit_up-jFit_down)./(max(jFit)-min(jFit));
            [~,idx]  = sort(idx,'ascend');
            ObjCrowding = ObjCrowding + distance(idx);
        end
        ObjCrowding(isnan(ObjCrowding)) = Inf;
        ObjCrowding_min = min(ObjCrowding);
        ObjCrowding_max = max(ObjCrowding(ObjCrowding<100000));
    
        % 计算决策空间拥挤距离
        nVar = size(pop.decs,2);
        TotalDistX = zeros(nPop,1);
        NearDistX = zeros(nPop,1);
        VarCrowding = zeros(nPop,1);
        CrowdingDistance = zeros(nPop,1);
        position = pop.decs;
        for i = 1:nPop
            NearDistX(i) = Inf;
            for j = 1:nPop
                if i == j
                    continue;
                end
                Gdistance = 0;
                for k = 1:nVar
                    Gdistance = Gdistance+abs(position(i,k)-position(j,k))/(max(position(:,k))-min(position(:,k)));
                end
                TotalDistX(i) = Gdistance+TotalDistX(i);
                if Gdistance < NearDistX(i)
                    NearDistX(i) = Gdistance;
                end
            end
        end
        for i=1:nPop
            VarCrowding(i) = TotalDistX(i) * NearDistX(i);            
        end

        VarCrowding_max = max(VarCrowding);
        VarCrowding_min = min(VarCrowding);

        for i=1:nPop
            if ObjCrowding_min < 100000
                ObjCrowding(i) = (ObjCrowding(i)-ObjCrowding_min)/(ObjCrowding_max-ObjCrowding_min);
            end
            VarCrowding(i) = (VarCrowding(i)-VarCrowding_min)/(VarCrowding_max-VarCrowding_min);            
        end
                
        for i = 1:nPop
            CrowdingDistance(i) = weight_obj*ObjCrowding(i)+weight_dec*VarCrowding(i);
        end
        
end