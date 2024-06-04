% Roulette wheel selection method
function [selectedIndex, selectedPop] = rouletteWheelSelection(population, fitnessValues_)
    fitnessValues = normalizeArray(fitnessValues_);
    cumulativeFitness = cumsum(fitnessValues);
    r = rand() * cumulativeFitness(end);
    selectedIndex = find(cumulativeFitness >= r, 1, 'first');
    selectedPop = population(selectedIndex, :);
end


function normalizedArray = normalizeArray(array)
    if isrow(array)
        array = array';
    end

    totalSum = sum(array);
    
    normalizedArray = array / totalSum;
end