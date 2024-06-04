

function population = initializePopulationNEH(numJobs, popSize, processingTimes1, transportationTimes, processingTimes2, transCapacity)
    population = zeros(popSize, 3 * numJobs);
    for i = 1:popSize
        chromosome = encodeChromosome(numJobs, processingTimes1, transportationTimes, processingTimes2, transCapacity);
        population(i, :) = [chromosome(1, :), chromosome(2, :), chromosome(3, :)];
    end
end

function chromosome = encodeChromosome(numJobs, processingTimes1, transportationTimes, processingTimes2, transCapacity)
    % Calculate the total processing time for each job
    totalTimes = processingTimes1 + transportationTimes + processingTimes2;
    
    % Sort jobs in descending order based on total processing time
    [~, sortedIndices] = sort(totalTimes, 'descend');
    
    % Initialize chromosomes
    chromosome = zeros(3, numJobs);
    
    % Initial sequence: Choose the sequence of the first two jobs with the smallest completion time
    bestSeq = [];
    for count = 1:numJobs
        job = sortedIndices(count);
        
        if isempty(bestSeq)
            bestSeq = job;
        elseif length(bestSeq) == 1
            bestSeq = [bestSeq, job];
            bestSeq = chooseBestSequence(bestSeq, processingTimes1, transportationTimes, processingTimes2, transCapacity);
        else
            bestSeq = insertJob(bestSeq, job, processingTimes1, transportationTimes, processingTimes2, transCapacity);
        end
    end
    
    % Assign the best sequence to each row of the chromosome
    for k = 1:3
        chromosome(k, :) = bestSeq;
    end
end

function bestSeq = chooseBestSequence(seq, processingTimes1, transportationTimes, processingTimes2, transCapacity)
    % Generate two possible sequences
    seq1 = seq;
    seq2 = fliplr(seq);
    
    % Calculate the completion time of the two sequences
    completionTime1 = calculateCompletionTime(seq1, processingTimes1, transportationTimes, processingTimes2, transCapacity);
    completionTime2 = calculateCompletionTime(seq2, processingTimes1, transportationTimes, processingTimes2, transCapacity);
    
    % Select the sequence with the smallest completion time
    if completionTime1 < completionTime2
        bestSeq = seq1;
    else
        bestSeq = seq2;
    end
end

function bestFullSeq = insertJob(currentSeq, job, processingTimes1, transportationTimes, processingTimes2, transCapacity)
    numJobs = length(currentSeq);
    bestSeq = [];
    minCompletionTime = inf;
    
    % Attempt to insert the new job at the beginning, middle, and end of the current sequence
    for newSeq_ = {[job, currentSeq(numJobs-1), currentSeq(numJobs)], ...
            [ currentSeq(numJobs-1), job,currentSeq(numJobs)], ...
            [currentSeq(numJobs-1), currentSeq(numJobs), job]}
        newSeq = cell2mat(newSeq_);
        completionTime = calculateCompletionTime(newSeq, processingTimes1, transportationTimes, processingTimes2, transCapacity);
        
        if completionTime < minCompletionTime
            minCompletionTime = completionTime;
            bestSeq = newSeq;
        end
    end
    bestFullSeq = [currentSeq(1:numJobs-2) bestSeq];
end

function completionTime = calculateCompletionTime(seq, processingTimes1, transportationTimes, processingTimes2, transCapacity)
    numJobs = length(seq);
    
    % init time
    timeOnMachine1 = zeros(1, numJobs);
    timeOnTransport = zeros(1, numJobs);
    timeOnMachine2 = zeros(1, numJobs);

    % Calculate the processing time for the first machine
    for i = 1:numJobs
        job = seq(i);
        if i == 1
            timeOnMachine1(i) = processingTimes1(job);
        else
            timeOnMachine1(i) = timeOnMachine1(i-1) + processingTimes1(job);
        end
    end

    numRounds = ceil(numJobs / transCapacity);
    lastTransportEndTime = 0;
    for round = 1:numRounds
        if transCapacity*round > numJobs
            endNum = numJobs;
        else
            endNum = transCapacity*round;
        end
    
        job = seq(transCapacity*(round-1)+1:endNum);
        maxTransTime = max(transportationTimes(job));

        lis = [];
        for j = job
            jobIndexInMachine1 = find(seq(:) == j, 1);
            lis = [lis; jobIndexInMachine1];
        end
        maxTimeOnMachine1 = max(timeOnMachine1(lis));

        for i = transCapacity*(round-1)+1:endNum
            if round == 1
                timeOnTransport(i) = maxTimeOnMachine1 + maxTransTime;
            else
                % timeOnTransport(i) = max(timeOnTransport(i-transCapacity), maxTimeOnMachine1) + maxTransTime;
                timeOnTransport(i) = max(timeOnTransport(i-transCapacity), max(lastTransportEndTime + returnTime, maxTimeOnMachine1)) + maxTransTime;
            end
        end
        lastTransportEndTime = timeOnTransport(endNum);
    end

    % Calculate the processing time for the second machine
    for i = 1:numJobs
        job = seq(i);
        jobIndexInTrans= find(seq(:) == job, 1);
        if i == 1
            timeOnMachine2(i) = timeOnTransport(jobIndexInTrans) + processingTimes2(job);
        else
            timeOnMachine2(i) = max(timeOnMachine2(i-1), timeOnTransport(jobIndexInTrans)) + processingTimes2(job);
        end
    end

    % The completion time is the completion time of the last job on the second machine
    completionTime = timeOnMachine2(end);
end
