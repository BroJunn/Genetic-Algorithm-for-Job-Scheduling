% encodeChromosome
function chromosome = encodeChromosome(numJobs)
    chromosome = zeros(3, numJobs);
    for i = 1:3
        chromosome(i, :) = randperm(numJobs);
    end
end