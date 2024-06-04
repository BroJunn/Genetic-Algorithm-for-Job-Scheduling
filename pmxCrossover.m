
function [child1, child2] = pmxCrossover(parent1, parent2, numJobs)
    parent1 = reshape(parent1, numJobs, [])';
    parent2 = reshape(parent2, numJobs, [])';
    child1 = zeros(3, numJobs);
    child2 = zeros(3, numJobs);

    % Select two crossover points
    pt1 = randi([1, numJobs-1]);
    pt2 = randi([pt1+1, numJobs]);

    for k = 1:3
        % Copy the segment between the crossover points
        child1(k, pt1:pt2) = parent1(k, pt1:pt2);
        child2(k, pt1:pt2) = parent2(k, pt1:pt2);
        
        parent1Outside = [parent1(k, 1:pt1-1), parent1(k, pt2+1:end)];
        parent2Outside = [parent2(k, 1:pt1-1), parent2(k, pt2+1:end)];
        
        remaining1 = setdiff(parent2(k, :), child1(k, pt1:pt2), 'stable');
        remaining2 = setdiff(parent1(k, :), child2(k, pt1:pt2), 'stable');


        % Fill in the remaining portion of offspring 1
        child1(k, 1:pt1-1) = remaining1(1:pt1-1);
        child1(k, pt2+1:end) = remaining1(pt1:end);

        % Fill in the remaining portion of offspring 2
        child2(k, 1:pt1-1) = remaining2(1:pt1-1);
        child2(k, pt2+1:end) = remaining2(pt1:end);
    end

    child1 = [child1(1,:) child1(2,:) child1(3,:) ];
    child2 = [child2(1,:) child2(2,:) child2(3,:) ];
end