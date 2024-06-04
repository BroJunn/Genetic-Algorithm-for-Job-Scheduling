%%
clear;
clc;
rng(20240519);

%% task params
processingTimes1 = [5, 2, 4, 7, 7, 1, 9, 6, 8, 3];
transportationTimes = [2, 5, 1, 1, 4, 1, 3, 3, 2, 1];
processingTimes2 = [6, 6, 8, 1, 5, 2, 7, 3, 4, 7];
transCapacity = 3;
returnTime = 1;

dueDates = [20, 15, 30, 10, 25, 18, 22, 12, 28, 14]; % Delivery time
earlinessPenalty = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1]; % Early penalty
tardinessPenalty = [2, 2, 2, 2, 2, 2, 2, 2, 2, 2]; % Delay penalty
w1 = 0.001; % Parameters of the fitness function
w2 = 0.001; % Parameters of the fitness function

%% Parameters related to genetic algorithms
numGenerations = 1000; % Iteration count
popSize = 20; % Population size
crossoverRate = 0.8;
mutationRate = 0.1;

use_NEH = true;
use_local_search = true;

%% Initializing population
numJobs = length(processingTimes1);
if use_NEH
    population = initializePopulationNEH(numJobs, popSize, processingTimes1, transportationTimes, processingTimes2, transCapacity);
else
    population = initializePopulation(numJobs, popSize);
end

% Initial fitness values
fitnessValues = zeros(1, popSize);
for i = 1:popSize
    [fitnessValues(i), ~] = calculateFitness(population(i, :), processingTimes1, transportationTimes, processingTimes2, transCapacity, returnTime, ...
        dueDates, earlinessPenalty, tardinessPenalty, numJobs, w1, w2);
end

%% Genetic algorithm loop
bestFitnessEver = -inf;
for gen = 1:numGenerations
    % selection
    [selectedIndex1, parent1] = rouletteWheelSelection(population, fitnessValues);
    [selectedIndex2, parent2] = rouletteWheelSelection(population, fitnessValues);

    % Crossover
    if rand() < crossoverRate
        [child1, child2] = pmxCrossover(parent1, parent2, numJobs);
    else
        child1 = parent1;
        child2 = parent2;
    end

    % Mutation
    if rand() < mutationRate
        child1 = insertionMutation(child1, numJobs);
    end
    if rand() < mutationRate
        child2 = insertionMutation(child2, numJobs);
    end

    % Local search
    if use_local_search
        child1 = localSearch(child1, processingTimes1, transportationTimes, processingTimes2, transCapacity, returnTime,...
            dueDates, earlinessPenalty, tardinessPenalty, numJobs, w1, w2);
        child2 = localSearch(child2, processingTimes1, transportationTimes, processingTimes2, transCapacity, returnTime,...
            dueDates, earlinessPenalty, tardinessPenalty, numJobs, w1, w2);
    end
    
    % update
    population(selectedIndex1, :) = child1;
    population(selectedIndex2, :) = child2;

    % Fitness evaluation
    fitnessValues = zeros(1, popSize);
    penaltyValues = zeros(1, popSize);
    for i = 1:popSize
        [fitnessValues(i), penaltyValues(i)] = calculateFitness(population(i, :), processingTimes1, transportationTimes, processingTimes2, transCapacity, returnTime, ...
            dueDates, earlinessPenalty, tardinessPenalty, numJobs, w1, w2);
    end

    % Current generation's best fitness value
    [bestFitness, bestIdx] = max(fitnessValues);
    if bestFitness > bestFitnessEver
        bestFitnessEver = bestFitness;
        bestSolutionEver = population(bestIdx, :);
        penaltyOfBestPop = penaltyValues(bestIdx);
    end
    bestSolution = population(bestIdx, :);
    fprintf('Generation No.%d: Best fitness value = %f\n', gen, bestFitness);
end

res = reshape_2D(bestSolutionEver, numJobs);
fprintf(['The final best fitness value is: ' num2str(bestFitnessEver) '\n']);
fprintf(['The penalty sum corresponding to the final best result is: ' num2str(penaltyOfBestPop) '\n']);

fprintf(['The final best result is: \n' num2str(res(1, :)) '\n' num2str(res(2, :)) '\n' num2str(res(3, :)) '\n']);

plotGanttChart(res, processingTimes1, transportationTimes, processingTimes2, transCapacity, returnTime)