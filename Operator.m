function Offspring = Operator(Problem,Particle,Pbest,Gbest)
% Particle swarm optimization in MOPSO-CD
    %% Parameter setting
    N = length(Particle);
    D = size(Particle(1).decs,2);
    ParticleDec = [];
    PbestDec = [];
    GbestDec=[];
    for i=1:N
        ParticleDec = [ParticleDec;Particle(i).decs];
        PbestDec    = [PbestDec;Pbest(i).decs];
        GbestDec    = [GbestDec;Gbest(i).decs];
    end
    ParticleVel = Particle.adds(zeros(N,D));

    decMin = min(Particle.decs);
    decMax = max(Particle.decs);
    if isscalar(decMin)
        decMin = Particle.decs;
        decMax = Particle.decs;
    end 

    %% Particle swarm optimization
    W  = repmat(unifrnd(0.1,0.5,N,1),1,D);
    r1 = repmat(rand(N,1),1,D);
    r2 = repmat(rand(N,1),1,D);
    C1 = 1.5;
    C2 = 1.5;
    OffVel = W.*ParticleVel + C1*r1.*(PbestDec-ParticleDec) + C2.*r2.*(GbestDec-ParticleDec);
    OffDec = ParticleDec + OffVel;
    
    %% Deterministic back
    Lower  = repmat(Problem.lower,N,1);
    Upper  = repmat(Problem.upper,N,1);
    repair = OffDec < Lower | OffDec > Upper;
    OffVel(repair) = -OffVel(repair);
    OffDec = max(min(OffDec,Upper),Lower);
    
    Offspring = Problem.Evaluation(OffDec,OffVel);
end