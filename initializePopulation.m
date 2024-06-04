function population = initializePopulation(numJobs, popSize)
    population = zeros(popSize, 3 * numJobs);
    for i = 1:popSize
        chromosome = encodeChromosome(numJobs);
        population(i, :) = [chromosome(1, :), chromosome(2, :), chromosome(3, :)];
    end
end

function chromosome = encodeChromosome(numJobs)
    chromosome = zeros(3, numJobs);
    for i = 1:3
        chromosome(i, :) = randperm(numJobs);
    end
end
