function [fitness, totalPenalty] = calculateFitness(chromosome, processingTimes1, transportationTimes, processingTimes2, transCapacity, returnTime, ...
    dueDates, earlinessPenalty, tardinessPenalty, numJobs, w1, w2)
    % chromosome (1, 30)
    chromosome_ = reshape(chromosome, numJobs, [])';
    maxCompletionTime = decodeChromosome(chromosome_, processingTimes1, transportationTimes, processingTimes2, transCapacity, returnTime);
    totalPenalty = calculateTotalPenalty(chromosome_, processingTimes1, transportationTimes, processingTimes2, transCapacity, returnTime, ...
        dueDates, earlinessPenalty, tardinessPenalty);
    fitness = 1 / (w1 * maxCompletionTime + w2 * totalPenalty);
end

% Calculate the total early/late penalty
function totalPenalty = calculateTotalPenalty(chromosome, processingTimes1, transportationTimes, processingTimes2, transCapacity, returnTime, ...
    dueDates, earlinessPenalty, tardinessPenalty)

    numJobs = size(chromosome, 2);
    
    timeOnMachine1 = zeros(1, numJobs);
    timeOnTransport = zeros(1, numJobs);
    timeOnMachine2 = zeros(1, numJobs);

    % Calculate the processing time for the first machine
    for i = 1:numJobs
        job = chromosome(1, i);
        if i == 1
            timeOnMachine1(i) = processingTimes1(job);
        else
            timeOnMachine1(i) = timeOnMachine1(i-1) + processingTimes1(job);
        end
    end


    % consider transport capacity
    numRounds = ceil(numJobs / transCapacity);
    lastTransportEndTime = 0;
    for round = 1:numRounds
        if transCapacity*round > numJobs
            endNum = numJobs;
        else
            endNum = transCapacity*round;
        end
    
        job = chromosome(2, transCapacity*(round-1)+1:endNum);
        maxTransTime = max(transportationTimes(job));

        lis = [];
        for j = job
            jobIndexInMachine1 = find(chromosome(1,:) == j, 1);
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
        job = chromosome(3, i);
        jobIndexInTrans= find(chromosome(2,:) == job, 1);
        if i == 1
            timeOnMachine2(i) = timeOnTransport(jobIndexInTrans) + processingTimes2(job);
        else
            timeOnMachine2(i) = max(timeOnMachine2(i-1), timeOnTransport(jobIndexInTrans)) + processingTimes2(job);
        end
    end

    % Calculate the total early/late penalty
    totalPenalty = 0;
    for i = 1:numJobs
        job = chromosome(3, i);
        completionTime = timeOnMachine2(i);
        dueDate = dueDates(job);
        if completionTime < dueDate
            totalPenalty = totalPenalty + earlinessPenalty(job) * (dueDate - completionTime);
        else
            totalPenalty = totalPenalty + tardinessPenalty(job) * (completionTime - dueDate);
        end
    end
end