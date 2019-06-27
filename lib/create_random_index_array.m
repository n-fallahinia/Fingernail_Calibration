function result_array = create_random_index_array(array_size, max_index, no_duplicates)

    % Verify inputs
    if (nargin() == 2)
        no_duplicates = true;
    elseif (nargin() ~= 3)
        error('Must have 2 or 3 inputs!');
    end
    
    % Initialize the output with a random array
    result_array = ceil(rand(1,array_size)*max_index);
    
    % If duplicates are not permitted, must verify that none are present
    if (no_duplicates)
        % Verify that the desired result is possible
        if (array_size > max_index)
            error('Cannot create an array without duplicates if the array size is larger than the maximum index!');
        end
        
        % Iterate to check the values in the array
        for idx = 2:array_size
            % Assume the first (i-1) values are unique.
            % If the ith value is not unique, replace it with new values
            % until it is.
            while (find(result_array(1:idx-1) == result_array(idx)))
                result_array(idx) = ceil(rand()*max_index);
            end
        end
    end

end % function