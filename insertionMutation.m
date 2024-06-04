% insertionMutation
function mutated = insertionMutation(chromosome, numJobs)
    chromosome = reshape(chromosome, numJobs, [])';
    for k = 1:3
        n = numJobs;
        pos1 = randi(n);
        pos2 = randi(n);
        
        if pos1 ~= pos2
            temp = chromosome(k, pos1);
            chromosome(k, pos1) = chromosome(k, pos2);
            chromosome(k, pos2) = temp;
        end
    end
    mutated = [chromosome(1, :) chromosome(2, :) chromosome(3, :) ];