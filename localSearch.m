% local search
function improvedOut = localSearch(chromosome, processingTimes1, transportationTimes, processingTimes2, transCapacity, returnTime,...
    dueDates, earlinessPenalty, tardinessPenalty, numJobs, w1, w2)
    % chromosome (1, 30)
    improved = chromosome;

    [bestFitness, ~] = calculateFitness(improved, processingTimes1, transportationTimes, processingTimes2, transCapacity, returnTime,...
        dueDates, earlinessPenalty, tardinessPenalty, numJobs, w1, w2);
    
    newChromosome = reshape_2D(improved, numJobs);
    improvedOut = newChromosome;
    for k = 1:3
        tuple = 1:10;
        randomOrder = randperm(length(tuple));
        i = tuple(randomOrder(1));
        j = tuple(randomOrder(2));
        newChromosome(k, [i, j]) = newChromosome(k, [j, i]);
        [newFitness, ~] = calculateFitness(flatten(newChromosome), processingTimes1, transportationTimes, processingTimes2, transCapacity, returnTime,...
            dueDates, earlinessPenalty, tardinessPenalty, numJobs, w1, w2);
        if newFitness > bestFitness
            bestFitness = newFitness;
            improvedOut = newChromosome;
        end
    end
    improvedOut = flatten(improvedOut);
end