
function plotGanttChart(chromosome, processingTimes1, transportationTimes, processingTimes2, transCapacity, returnTime)
    numJobs = length(processingTimes1);
    numStages = 3;

    % Initialize start and end time matrices.
    startTime = zeros(numStages, numJobs);
    endTime = zeros(numStages, numJobs);

    % Calculate the processing time for the first machine.
    for i = 1:numJobs
        job = chromosome(1, i);
        if i == 1
            startTime(1, job) = 0;
        else
            prevJob = chromosome(1, i-1);
            startTime(1, job) = endTime(1, prevJob);
        end
        endTime(1, job) = startTime(1, job) + processingTimes1(job);
    end

    % Consider transport capacity.
    numRounds = ceil(numJobs / transCapacity);
    batchEndTimes = zeros(1, numRounds);
    batchIdx = 1;

    for round = 1:numRounds
        if transCapacity * round > numJobs
            endNum = numJobs;
        else
            endNum = transCapacity * round;
        end

        jobBatch = chromosome(2, transCapacity*(round-1)+1:endNum);
        maxTransTime = max(transportationTimes(jobBatch));

        % lis = [];
        % for j = jobBatch
        %     jobIndexInMachine1 = find(chromosome(1,:) == j, 1);
        %     lis = [lis; jobIndexInMachine1];
        % end
        % maxTimeOnMachine1 = max(endTime(1, lis));
        maxTimeOnMachine1 = max(endTime(1, jobBatch));

        for i = transCapacity*(round-1)+1:endNum
            job = chromosome(2, i);
            if round == 1
                startTime(2, job) = maxTimeOnMachine1;
            else
                % startTime(2, job) = max(batchEndTimes(batchIdx-1), maxTimeOnMachine1);
                startTime(2, job) = max(batchEndTimes(batchIdx-1) + returnTime, maxTimeOnMachine1);
            end
            endTime(2, job) = startTime(2, job) + maxTransTime;
        end
        batchEndTimes(batchIdx) = max(endTime(2, jobBatch));
        batchIdx = batchIdx + 1;
    end

    % Calculate the processing time for the second machine
    for i = 1:numJobs
        job = chromosome(3, i);
        % jobIndexInTransport = find(chromosome(2,:) == job, 1);
        if i == 1
            % startTime(3, job) = endTime(2, jobIndexInTransport);
            startTime(3, job) = endTime(2, job);
        else
            prevJob = chromosome(3, i-1);
            startTime(3, job) = max(endTime(2, job), endTime(3, prevJob));
        end
        endTime(3, job) = startTime(3, job) + processingTimes2(job);
    end

    maxTime = max(endTime(:));
    fprintf('Total time: %d\n', maxTime);

    plotGanttChart_(chromosome, startTime, endTime, returnTime)

end


function plotGanttChart_(chromosome, startTime, endTime, returnTime)


    [uniqueValues, ~, idx] = unique(startTime(2, :), 'stable');

    % Initialize storage indices
    indices = cell(size(uniqueValues));
    
    % Find the indices of each unique value
    for i = 1:length(uniqueValues)
        indices{i} = find(startTime(2, :) == uniqueValues(i));
    end

    numJobs = size(chromosome, 2);
    numStages = size(chromosome, 1);

    % define colors
    colors = lines(numJobs);

    figure;
    hold on;

    % Plot bar charts for stages of machine 1 and machine 2
    for stage = numStages:-1:1 
        for job = 1:numJobs
            % Retrieve the start time and end time of the current task
            st = startTime(stage, job);
            et = endTime(stage, job);
            
            if stage ~= 2
                patch([st et et st], [numStages-stage+1-0.2 numStages-stage+1-0.2 numStages-stage+1+0.2 numStages-stage+1+0.2], colors(job, :), 'EdgeColor', 'k');
            end
        end
    end
    
    % Plot the transport stage
    lastTime = 0;
    for ind = indices
        ind = cell2mat(ind);
        for i = ind
            pos = find(ind == i, 1);
            yBase = 3-2+1 + (pos-1)*0.4/3 - 0.4/3;
            if lastTime == startTime(2, i)
                st = startTime(2, i) + returnTime;
            else
                st = startTime(2, i);
            end
            et = endTime(2, i);
            patch([st et et st], [yBase yBase yBase + 0.4/3 yBase + 0.4/3], colors(i, :), 'EdgeColor', 'k');
        end
        lastTime = et;
    end

    % set y-axis
    set(gca, 'YTick', 1:numStages, 'YTickLabel', {'Machine 2', 'Transport', 'Machine 1'});
    ylabel('Stage');
    xlabel('Time');
    title('Gantt Chart');
    grid on;

    % Add legend
    legendEntries = arrayfun(@(job) sprintf('Job %d', job), 1:numJobs, 'UniformOutput', false);
    legend(legendEntries, 'Location', 'bestoutside');

    hold off;
end