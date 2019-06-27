function poly_matrix = form_polynomial_matrix(data_matrix, order, cross_terms)

    % Verify number of inputs
    if (nargin() == 2)
        cross_terms = true;
    elseif (nargin() ~= 3)
        error('Must have 2 or 3 inputs!');
    end
    
    % Verify that we can handle the input value
    if (order > MAX_ORDER)
        error('I cannot handle this level of detail yet!');
    end % switch
    
    % Determine size of input
    [num_values, num_variables] = size(data_matrix);
    
    % Form constant term
    if (order >= 0)
        zero_matrix = ones(num_values,1);
    else
        error('Must have order >= 0!');
    end
    
    % Form linear terms
    if (order >= 1)
        linear_matrix = data_matrix;
    else
        linear_matrix = [];
    end
    
    % Form quadratic terms
    if (order >= 2)
        quad_matrix = form_quad_matrix(data_matrix, cross_terms);
    else
        quad_matrix = [];
    end
    
    % Form cubic terms
    if (order >= 3)
        cubic_matrix = form_cubic_matrix(data_matrix, cross_terms);
    else
        cubic_matrix = [];
    end
    
    % Form quartic terms
    if (order >= 4)
        quartic_matrix = form_quartic_matrix(data_matrix, cross_terms);
    else
        quartic_matrix = [];
    end
    
    % Form quintic terms
    if (order >= 5)
        quintic_matrix = form_quintic_matrix(data_matrix, cross_terms);
    else
        quintic_matrix = [];
    end
    
    % Form sextic terms
    if (order >= 6)
        sextic_matrix = form_sextic_matrix(data_matrix, cross_terms);
    else
        sextic_matrix = [];
    end
    
    % Form septic terms
    if (order >= 7)
        septic_matrix = form_septic_matrix(data_matrix, cross_terms);
    else
        septic_matrix = [];
    end
    
    % Form the final matrix
    poly_matrix = [zero_matrix linear_matrix quad_matrix cubic_matrix quartic_matrix quintic_matrix sextic_matrix septic_matrix];

end % form_polynomial_matrix

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Form the terms specific to the quadratic (i.e., 2nd-order) terms
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function quad_matrix = form_quad_matrix(data_matrix, cross_terms)

    % Determine size of input
    [num_values, num_variables] = size(data_matrix);
    
    if (cross_terms)
        % Create a list of cross-multiplying terms (e.g., x*y)
        if (num_variables < 2)
            cross_pairs = [];
        else
            cross_pairs = nchoosek(1:num_variables,2);
        end
        num_pairs = size(cross_pairs,1);
    else
        num_pairs = 0;
    end
    
    % Preallocate output
    quad_matrix = zeros(num_values, num_variables+num_pairs);
    
    % Assign the quadratic terms (e.g., x^2)
    quad_matrix(:,1:num_variables) = data_matrix.^2;
    
    if (cross_terms)
        % Assign the cross-multiplying terms
        for pairIdx = 1:num_pairs
            quad_matrix(:,pairIdx+num_variables) = data_matrix(:,cross_pairs(pairIdx,1)).*data_matrix(:,cross_pairs(pairIdx,2));
        end % pairIdx
    end

end % form_quad_matrix

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Form the terms specific to the cubic (i.e., 3rd-order) terms
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function cubic_matrix = form_cubic_matrix(data_matrix, cross_terms)

    % Determine size of input
    [num_values, num_variables] = size(data_matrix);
    
    if (cross_terms)
        % Create a list of cross-multiplying terms (e.g., x^2*y)
        if (num_variables < 2)
            cross_pairs = [];
        else
            cross_pairs = nchoosek(1:num_variables,2);
        end
        num_pairs = size(cross_pairs,1);
        
        % Create a list of 3rd-order cross-multiplying terms (e.g., x*y*z)
        if (num_variables < 3)
            cross_trios = [];
        else
            cross_trios = nchoosek(1:num_variables,3);
        end
        num_trios = size(cross_trios,1);
    else
        num_pairs = 0;
        num_trios = 0;
    end
    
    % Preallocate output
    cubic_matrix = zeros(num_values, num_variables+2*num_pairs+num_trios);
    
    % Assign the cubic terms (e.g., x^3)
    cubic_matrix(:,1:num_variables) = data_matrix.^3;
    
    if (cross_terms)
        % Assign the cross-multiplying terms
        for pairIdx = 1:num_pairs
            % Populate the cross-multiplying terms
            cubic_matrix(:,pairIdx+num_variables) = data_matrix(:,cross_pairs(pairIdx,1)).^2.*data_matrix(:,cross_pairs(pairIdx,2));
            cubic_matrix(:,pairIdx+num_variables+num_pairs) = data_matrix(:,cross_pairs(pairIdx,1)).*data_matrix(:,cross_pairs(pairIdx,2)).^2;
        end % pairIdx
        
        % Assign the 3rd-order cross-multiplying terms
        for trioIdx = 1:num_trios
            % Populate the cross-multiplying terms
            cubic_matrix(:,trioIdx+num_variables+2*num_pairs) = data_matrix(:,cross_trios(trioIdx,1)).*data_matrix(:,cross_trios(trioIdx,2)).*data_matrix(:,cross_trios(trioIdx,3));
        end % trioIdx
    end

end % form_cubic_matrix

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Form the terms specific to the quartic (i.e., 4th-order) terms
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function quartic_matrix = form_quartic_matrix(data_matrix, cross_terms)

    % Determine size of input
    [num_values, num_variables] = size(data_matrix);
    
    if (cross_terms)
        % Create a list of cross-multiplying terms (e.g., x^3*y)
        if (num_variables < 2)
            cross_pairs = [];
        else
            cross_pairs = nchoosek(1:num_variables,2);
        end
        num_pairs = size(cross_pairs,1);
        
        % Create a list of 3rd-order cross-multiplying terms (e.g., x^2*y*z)
        if (num_variables < 3)
            cross_trios = [];
        else
            cross_trios = nchoosek(1:num_variables,3);
        end
        num_trios = size(cross_trios,1);
        
        % Create a list of 4th-order cross-multiplying terms (e.g., w*x*y*z)
        if (num_variables < 4)
            cross_quads = [];
        else
            cross_quads = nchoosek(1:num_variables,4);
        end
        num_quads = size(cross_quads,1);
    else
        num_pairs = 0;
        num_trios = 0;
        num_quads = 0;
    end
    
    % Preallocate output
    quartic_matrix = zeros(num_values, num_variables+3*num_pairs+3*num_trios+num_quads);
    
    % Assign the quartic terms (e.g., x^4)
    quartic_matrix(:,1:num_variables) = data_matrix.^4;
    
    if (cross_terms)
        % Assign the cross-multiplying terms
        for pairIdx = 1:num_pairs
            % Populate the cross-multiplying terms
            quartic_matrix(:,pairIdx+num_variables) = data_matrix(:,cross_pairs(pairIdx,1)).^3.*data_matrix(:,cross_pairs(pairIdx,2));
            quartic_matrix(:,pairIdx+num_variables+num_pairs) = data_matrix(:,cross_pairs(pairIdx,1)).^2.*data_matrix(:,cross_pairs(pairIdx,2)).^2;
            quartic_matrix(:,pairIdx+num_variables+2*num_pairs) = data_matrix(:,cross_pairs(pairIdx,1)).*data_matrix(:,cross_pairs(pairIdx,2)).^3;
        end % pairIdx
        
        % Assign the 3rd-order cross-multiplying terms
        for trioIdx = 1:num_trios
            % Populate the cross-multiplying terms
            quartic_matrix(:,trioIdx+num_variables+3*num_pairs) = data_matrix(:,cross_trios(trioIdx,1)).^2 .* data_matrix(:,cross_trios(trioIdx,2)) .* data_matrix(:,cross_trios(trioIdx,3));
            quartic_matrix(:,trioIdx+num_variables+3*num_pairs+num_trios) = data_matrix(:,cross_trios(trioIdx,1)) .* data_matrix(:,cross_trios(trioIdx,2)).^2 .* data_matrix(:,cross_trios(trioIdx,3));
            quartic_matrix(:,trioIdx+num_variables+3*num_pairs+2*num_trios) = data_matrix(:,cross_trios(trioIdx,1)) .* data_matrix(:,cross_trios(trioIdx,2)) .* data_matrix(:,cross_trios(trioIdx,3)).^2;
        end % trioIdx
        
        % Assign the 4th-order cross-multiplying terms
        for quadIdx = 1:num_quads
            % Populate the cross-multiplying terms
            quartic_matrix(:,quadIdx+num_variables+3*num_pairs+3*num_trios) = data_matrix(:,cross_quads(quadIdx,1)) .* data_matrix(:,cross_quads(quadIdx,2)) .* data_matrix(:,cross_quads(quadIdx,3)) .* data_matrix(:,cross_quads(quadIdx,4));
        end % trioIdx
    end

end % form_quartic_matrix

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Form the terms specific to the quintic (i.e., 5th-order) terms
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function quintic_matrix = form_quintic_matrix(data_matrix, cross_terms)

    % Determine size of input
    [num_values, num_variables] = size(data_matrix);
    
    if (cross_terms)
        % Create a list of cross-multiplying terms (e.g., x^3*y)
        if (num_variables < 2)
            cross_pairs = [];
        else
            cross_pairs = nchoosek(1:num_variables,2);
        end
        num_pairs = size(cross_pairs,1);
        
        % Create a list of 3rd-order cross-multiplying terms (e.g., x^2*y*z)
        if (num_variables < 3)
            cross_trios = [];
        else
            cross_trios = nchoosek(1:num_variables,3);
        end
        num_trios = size(cross_trios,1);
        
        % Create a list of 4th-order cross-multiplying terms (e.g., w*x*y*z)
        if (num_variables < 4)
            cross_quads = [];
        else
            cross_quads = nchoosek(1:num_variables,4);
        end
        num_quads = size(cross_quads,1);
        
        % Create a list of 5th-order cross-multiplying terms (e.g., v*w*x*y*z)
        if (num_variables < 5)
            cross_quints = [];
        else
            cross_quints = nchoosek(1:num_variables,5);
        end
        num_quints = size(cross_quints,1);
    else
        num_pairs = 0;
        num_trios = 0;
        num_quads = 0;
        num_quints = 0;
    end
    
    % Preallocate output
    quintic_matrix = zeros(num_values, num_variables+4*num_pairs+6*num_trios+4*num_quads+num_quints);
    
    % Assign the quintic terms (e.g., x^5)
    quintic_matrix(:,1:num_variables) = data_matrix.^5;
    
    if (cross_terms)
        % Assign the cross-multiplying terms
        for pairIdx = 1:num_pairs
            % Populate the cross-multiplying terms
            quintic_matrix(:,pairIdx+num_variables)             = data_matrix(:,cross_pairs(pairIdx,1)).^4 .* data_matrix(:,cross_pairs(pairIdx,2));
            quintic_matrix(:,pairIdx+num_variables+num_pairs)   = data_matrix(:,cross_pairs(pairIdx,1)).^3 .* data_matrix(:,cross_pairs(pairIdx,2)).^2;
            quintic_matrix(:,pairIdx+num_variables+2*num_pairs) = data_matrix(:,cross_pairs(pairIdx,1)).^2 .* data_matrix(:,cross_pairs(pairIdx,2)).^3;
            quintic_matrix(:,pairIdx+num_variables+3*num_pairs) = data_matrix(:,cross_pairs(pairIdx,1))    .* data_matrix(:,cross_pairs(pairIdx,2)).^4;
        end % pairIdx
        
        % Assign the 3rd-order cross-multiplying terms
        for trioIdx = 1:num_trios
            % Populate the cross-multiplying terms
            quintic_matrix(:,trioIdx+num_variables+4*num_pairs)             = data_matrix(:,cross_trios(trioIdx,1)).^3 .* data_matrix(:,cross_trios(trioIdx,2))    .* data_matrix(:,cross_trios(trioIdx,3));
            quintic_matrix(:,trioIdx+num_variables+4*num_pairs+num_trios)   = data_matrix(:,cross_trios(trioIdx,1)).^2 .* data_matrix(:,cross_trios(trioIdx,2)).^2 .* data_matrix(:,cross_trios(trioIdx,3));
            quintic_matrix(:,trioIdx+num_variables+4*num_pairs+2*num_trios) = data_matrix(:,cross_trios(trioIdx,1)).^2 .* data_matrix(:,cross_trios(trioIdx,2))    .* data_matrix(:,cross_trios(trioIdx,3)).^2;
            quintic_matrix(:,trioIdx+num_variables+4*num_pairs+3*num_trios) = data_matrix(:,cross_trios(trioIdx,1))    .* data_matrix(:,cross_trios(trioIdx,2)).^3 .* data_matrix(:,cross_trios(trioIdx,3));
            quintic_matrix(:,trioIdx+num_variables+4*num_pairs+4*num_trios) = data_matrix(:,cross_trios(trioIdx,1))    .* data_matrix(:,cross_trios(trioIdx,2)).^2 .* data_matrix(:,cross_trios(trioIdx,3)).^2;
            quintic_matrix(:,trioIdx+num_variables+4*num_pairs+5*num_trios) = data_matrix(:,cross_trios(trioIdx,1))    .* data_matrix(:,cross_trios(trioIdx,2))    .* data_matrix(:,cross_trios(trioIdx,3)).^3;
        end % trioIdx
        
        % Assign the 4th-order cross-multiplying terms
        for quadIdx = 1:num_quads
            % Populate the cross-multiplying terms
            quintic_matrix(:,quadIdx+num_variables+4*num_pairs+6*num_trios)             = data_matrix(:,cross_quads(quadIdx,1)).^2 .* data_matrix(:,cross_quads(quadIdx,2))    .* data_matrix(:,cross_quads(quadIdx,3))    .* data_matrix(:,cross_quads(quadIdx,4));
            quintic_matrix(:,quadIdx+num_variables+4*num_pairs+6*num_trios+num_quads)   = data_matrix(:,cross_quads(quadIdx,1))    .* data_matrix(:,cross_quads(quadIdx,2)).^2 .* data_matrix(:,cross_quads(quadIdx,3))    .* data_matrix(:,cross_quads(quadIdx,4));
            quintic_matrix(:,quadIdx+num_variables+4*num_pairs+6*num_trios+2*num_quads) = data_matrix(:,cross_quads(quadIdx,1))    .* data_matrix(:,cross_quads(quadIdx,2))    .* data_matrix(:,cross_quads(quadIdx,3)).^2 .* data_matrix(:,cross_quads(quadIdx,4));
            quintic_matrix(:,quadIdx+num_variables+4*num_pairs+6*num_trios+3*num_quads) = data_matrix(:,cross_quads(quadIdx,1))    .* data_matrix(:,cross_quads(quadIdx,2))    .* data_matrix(:,cross_quads(quadIdx,3))    .* data_matrix(:,cross_quads(quadIdx,4)).^2;
        end % quadIdx
        
        % Assign the 5th-order cross-multiplying terms
        for quintIdx = 1:num_quints
            % Populate the cross-multiplying terms
            quintic_matrix(:,quintIdx+num_variables+4*num_pairs+6*num_trios+4*num_quads) = data_matrix(:,cross_quints(quintIdx,1)) .* data_matrix(:,cross_quints(quintIdx,2)) .* data_matrix(:,cross_quints(quintIdx,3)) .* data_matrix(:,cross_quints(quintIdx,4)) .* data_matrix(:,cross_quints(quintIdx,5));
        end % quintIdx
    end

end % form_quintic_matrix

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Form the terms specific to the sextic (i.e., 6th-order) terms
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function sextic_matrix = form_sextic_matrix(data_matrix, cross_terms)

    % Determine size of input
    [num_values, num_variables] = size(data_matrix);
    
    if (cross_terms)
        % Create a list of cross-multiplying terms (e.g., x^3*y)
        if (num_variables < 2)
            cross_pairs = [];
        else
            cross_pairs = nchoosek(1:num_variables,2);
        end
        num_pairs = size(cross_pairs,1);
        
        % Create a list of 3rd-order cross-multiplying terms (e.g., x^2*y*z)
        if (num_variables < 3)
            cross_trios = [];
        else
            cross_trios = nchoosek(1:num_variables,3);
        end
        num_trios = size(cross_trios,1);
        
        % Create a list of 4th-order cross-multiplying terms (e.g., w*x*y*z)
        if (num_variables < 4)
            cross_quads = [];
        else
            cross_quads = nchoosek(1:num_variables,4);
        end
        num_quads = size(cross_quads,1);
        
        % Create a list of 5th-order cross-multiplying terms (e.g., v*w*x*y*z)
        if (num_variables < 5)
            cross_quints = [];
        else
            cross_quints = nchoosek(1:num_variables,5);
        end
        num_quints = size(cross_quints,1);
        
        % Create a list of 6th-order cross-multiplying terms (e.g., u*v*w*x*y*z)
        if (num_variables < 6)
            cross_sixths = [];
        else
            cross_sixths = nchoosek(1:num_variables,6);
        end
        num_sixths = size(cross_sixths,1);
    else
        num_pairs = 0;
        num_trios = 0;
        num_quads = 0;
        num_quints = 0;
        num_sixths = 0;
    end
    
    % Preallocate output
    sextic_matrix = zeros(num_values, num_variables+5*num_pairs+10*num_trios+10*num_quads+5*num_quints+num_sixths);
    
    % Assign the sextic terms (e.g., x^6)
    sextic_matrix(:,1:num_variables) = data_matrix.^6;
    
    if (cross_terms)
        % Assign the cross-multiplying terms
        for pairIdx = 1:num_pairs
            % Populate the cross-multiplying terms
            sextic_matrix(:,pairIdx+num_variables)             = data_matrix(:,cross_pairs(pairIdx,1)).^5 .* data_matrix(:,cross_pairs(pairIdx,2));
            sextic_matrix(:,pairIdx+num_variables+num_pairs)   = data_matrix(:,cross_pairs(pairIdx,1)).^4 .* data_matrix(:,cross_pairs(pairIdx,2)).^2;
            sextic_matrix(:,pairIdx+num_variables+2*num_pairs) = data_matrix(:,cross_pairs(pairIdx,1)).^3 .* data_matrix(:,cross_pairs(pairIdx,2)).^3;
            sextic_matrix(:,pairIdx+num_variables+3*num_pairs) = data_matrix(:,cross_pairs(pairIdx,1)).^2 .* data_matrix(:,cross_pairs(pairIdx,2)).^4;
            sextic_matrix(:,pairIdx+num_variables+4*num_pairs) = data_matrix(:,cross_pairs(pairIdx,1))    .* data_matrix(:,cross_pairs(pairIdx,2)).^5;
        end % pairIdx
        
        % Assign the 3rd-order cross-multiplying terms
        for trioIdx = 1:num_trios
            % Populate the cross-multiplying terms
            sextic_matrix(:,trioIdx+num_variables+5*num_pairs)             = data_matrix(:,cross_trios(trioIdx,1)).^4 .* data_matrix(:,cross_trios(trioIdx,2))    .* data_matrix(:,cross_trios(trioIdx,3));
            sextic_matrix(:,trioIdx+num_variables+5*num_pairs+num_trios)   = data_matrix(:,cross_trios(trioIdx,1)).^3 .* data_matrix(:,cross_trios(trioIdx,2)).^2 .* data_matrix(:,cross_trios(trioIdx,3));
            sextic_matrix(:,trioIdx+num_variables+5*num_pairs+2*num_trios) = data_matrix(:,cross_trios(trioIdx,1)).^3 .* data_matrix(:,cross_trios(trioIdx,2))    .* data_matrix(:,cross_trios(trioIdx,3)).^2;
            sextic_matrix(:,trioIdx+num_variables+5*num_pairs+3*num_trios) = data_matrix(:,cross_trios(trioIdx,1)).^2 .* data_matrix(:,cross_trios(trioIdx,2)).^3 .* data_matrix(:,cross_trios(trioIdx,3));
            sextic_matrix(:,trioIdx+num_variables+5*num_pairs+4*num_trios) = data_matrix(:,cross_trios(trioIdx,1)).^2 .* data_matrix(:,cross_trios(trioIdx,2)).^2 .* data_matrix(:,cross_trios(trioIdx,3)).^2;
            sextic_matrix(:,trioIdx+num_variables+5*num_pairs+5*num_trios) = data_matrix(:,cross_trios(trioIdx,1)).^2 .* data_matrix(:,cross_trios(trioIdx,2))    .* data_matrix(:,cross_trios(trioIdx,3)).^3;
            sextic_matrix(:,trioIdx+num_variables+5*num_pairs+6*num_trios) = data_matrix(:,cross_trios(trioIdx,1))    .* data_matrix(:,cross_trios(trioIdx,2)).^4 .* data_matrix(:,cross_trios(trioIdx,3));
            sextic_matrix(:,trioIdx+num_variables+5*num_pairs+7*num_trios) = data_matrix(:,cross_trios(trioIdx,1))    .* data_matrix(:,cross_trios(trioIdx,2)).^3 .* data_matrix(:,cross_trios(trioIdx,3)).^2;
            sextic_matrix(:,trioIdx+num_variables+5*num_pairs+8*num_trios) = data_matrix(:,cross_trios(trioIdx,1))    .* data_matrix(:,cross_trios(trioIdx,2)).^2 .* data_matrix(:,cross_trios(trioIdx,3)).^3;
            sextic_matrix(:,trioIdx+num_variables+5*num_pairs+9*num_trios) = data_matrix(:,cross_trios(trioIdx,1))    .* data_matrix(:,cross_trios(trioIdx,2))    .* data_matrix(:,cross_trios(trioIdx,3)).^4;
        end % trioIdx
        
        % Assign the 4th-order cross-multiplying terms
        for quadIdx = 1:num_quads
            % Populate the cross-multiplying terms
            sextic_matrix(:,quadIdx+num_variables+5*num_pairs+10*num_trios)             = data_matrix(:,cross_quads(quadIdx,1)).^3 .* data_matrix(:,cross_quads(quadIdx,2))    .* data_matrix(:,cross_quads(quadIdx,3))    .* data_matrix(:,cross_quads(quadIdx,4));
            sextic_matrix(:,quadIdx+num_variables+5*num_pairs+10*num_trios+num_quads)   = data_matrix(:,cross_quads(quadIdx,1)).^2 .* data_matrix(:,cross_quads(quadIdx,2)).^2 .* data_matrix(:,cross_quads(quadIdx,3))    .* data_matrix(:,cross_quads(quadIdx,4));
            sextic_matrix(:,quadIdx+num_variables+5*num_pairs+10*num_trios+2*num_quads) = data_matrix(:,cross_quads(quadIdx,1)).^2 .* data_matrix(:,cross_quads(quadIdx,2))    .* data_matrix(:,cross_quads(quadIdx,3)).^2 .* data_matrix(:,cross_quads(quadIdx,4));
            sextic_matrix(:,quadIdx+num_variables+5*num_pairs+10*num_trios+3*num_quads) = data_matrix(:,cross_quads(quadIdx,1)).^2 .* data_matrix(:,cross_quads(quadIdx,2))    .* data_matrix(:,cross_quads(quadIdx,3))    .* data_matrix(:,cross_quads(quadIdx,4)).^2;
            sextic_matrix(:,quadIdx+num_variables+5*num_pairs+10*num_trios+4*num_quads) = data_matrix(:,cross_quads(quadIdx,1))    .* data_matrix(:,cross_quads(quadIdx,2)).^3 .* data_matrix(:,cross_quads(quadIdx,3))    .* data_matrix(:,cross_quads(quadIdx,4));
            sextic_matrix(:,quadIdx+num_variables+5*num_pairs+10*num_trios+5*num_quads) = data_matrix(:,cross_quads(quadIdx,1))    .* data_matrix(:,cross_quads(quadIdx,2)).^2 .* data_matrix(:,cross_quads(quadIdx,3)).^2 .* data_matrix(:,cross_quads(quadIdx,4));
            sextic_matrix(:,quadIdx+num_variables+5*num_pairs+10*num_trios+6*num_quads) = data_matrix(:,cross_quads(quadIdx,1))    .* data_matrix(:,cross_quads(quadIdx,2)).^2 .* data_matrix(:,cross_quads(quadIdx,3))    .* data_matrix(:,cross_quads(quadIdx,4)).^2;
            sextic_matrix(:,quadIdx+num_variables+5*num_pairs+10*num_trios+7*num_quads) = data_matrix(:,cross_quads(quadIdx,1))    .* data_matrix(:,cross_quads(quadIdx,2))    .* data_matrix(:,cross_quads(quadIdx,3)).^3 .* data_matrix(:,cross_quads(quadIdx,4));
            sextic_matrix(:,quadIdx+num_variables+5*num_pairs+10*num_trios+8*num_quads) = data_matrix(:,cross_quads(quadIdx,1))    .* data_matrix(:,cross_quads(quadIdx,2))    .* data_matrix(:,cross_quads(quadIdx,3)).^2 .* data_matrix(:,cross_quads(quadIdx,4)).^2;
            sextic_matrix(:,quadIdx+num_variables+5*num_pairs+10*num_trios+9*num_quads) = data_matrix(:,cross_quads(quadIdx,1))    .* data_matrix(:,cross_quads(quadIdx,2))    .* data_matrix(:,cross_quads(quadIdx,3))    .* data_matrix(:,cross_quads(quadIdx,4)).^3;
        end % quadIdx
        
        % Assign the 5th-order cross-multiplying terms
        for quintIdx = 1:num_quints
            % Populate the cross-multiplying terms
            sextic_matrix(:,quintIdx+num_variables+5*num_pairs+10*num_trios+10*num_quads)              = data_matrix(:,cross_quints(quintIdx,1)).^2 .* data_matrix(:,cross_quints(quintIdx,2))    .* data_matrix(:,cross_quints(quintIdx,3))    .* data_matrix(:,cross_quints(quintIdx,4))    .* data_matrix(:,cross_quints(quintIdx,5));
            sextic_matrix(:,quintIdx+num_variables+5*num_pairs+10*num_trios+10*num_quads+num_quints)   = data_matrix(:,cross_quints(quintIdx,1))    .* data_matrix(:,cross_quints(quintIdx,2)).^2 .* data_matrix(:,cross_quints(quintIdx,3))    .* data_matrix(:,cross_quints(quintIdx,4))    .* data_matrix(:,cross_quints(quintIdx,5));
            sextic_matrix(:,quintIdx+num_variables+5*num_pairs+10*num_trios+10*num_quads+2*num_quints) = data_matrix(:,cross_quints(quintIdx,1))    .* data_matrix(:,cross_quints(quintIdx,2))    .* data_matrix(:,cross_quints(quintIdx,3)).^2 .* data_matrix(:,cross_quints(quintIdx,4))    .* data_matrix(:,cross_quints(quintIdx,5));
            sextic_matrix(:,quintIdx+num_variables+5*num_pairs+10*num_trios+10*num_quads+3*num_quints) = data_matrix(:,cross_quints(quintIdx,1))    .* data_matrix(:,cross_quints(quintIdx,2))    .* data_matrix(:,cross_quints(quintIdx,3))    .* data_matrix(:,cross_quints(quintIdx,4)).^2 .* data_matrix(:,cross_quints(quintIdx,5));
            sextic_matrix(:,quintIdx+num_variables+5*num_pairs+10*num_trios+10*num_quads+4*num_quints) = data_matrix(:,cross_quints(quintIdx,1))    .* data_matrix(:,cross_quints(quintIdx,2))    .* data_matrix(:,cross_quints(quintIdx,3))    .* data_matrix(:,cross_quints(quintIdx,4))    .* data_matrix(:,cross_quints(quintIdx,5)).^2;
        end % quintIdx
        
        % Assign the 6th-order cross-multiplying terms
        for sixthIdx = 1:num_sixths
            sextic_matrix(:,sixthIdx+num_variables+5*num_pairs+10*num_trios+10*num_quads+5*num_quints) = data_matrix(:,cross_sixths(sixthIdx,1)) .* data_matrix(:,cross_sixths(sixthIdx,2)) .* data_matrix(:,cross_sixths(sixthIdx,3)) .* data_matrix(:,cross_sixths(sixthIdx,4)) .* data_matrix(:,cross_sixths(sixthIdx,5)) .* data_matrix(:,cross_sixths(sixthIdx,6));
        end % sixthIdx
    end

end % form_sextic_matrix

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Form the terms specific to the septic (i.e., 7th-order) terms
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function septic_matrix = form_septic_matrix(data_matrix, cross_terms)

    % Determine size of input
    [num_values, num_variables] = size(data_matrix);
    
    if (cross_terms)
        % Create a list of cross-multiplying terms (e.g., x^3*y)
        if (num_variables < 2)
            cross_pairs = [];
        else
            cross_pairs = nchoosek(1:num_variables,2);
        end
        num_pairs = size(cross_pairs,1);
        
        % Create a list of 3rd-order cross-multiplying terms (e.g., x^2*y*z)
        if (num_variables < 3)
            cross_trios = [];
        else
            cross_trios = nchoosek(1:num_variables,3);
        end
        num_trios = size(cross_trios,1);
        
        % Create a list of 4th-order cross-multiplying terms (e.g., w*x*y*z)
        if (num_variables < 4)
            cross_quads = [];
        else
            cross_quads = nchoosek(1:num_variables,4);
        end
        num_quads = size(cross_quads,1);
        
        % Create a list of 5th-order cross-multiplying terms (e.g., v*w*x*y*z)
        if (num_variables < 5)
            cross_quints = [];
        else
            cross_quints = nchoosek(1:num_variables,5);
        end
        num_quints = size(cross_quints,1);
        
        % Create a list of 6th-order cross-multiplying terms (e.g., u*v*w*x*y*z)
        if (num_variables < 6)
            cross_sixths = [];
        else
            cross_sixths = nchoosek(1:num_variables,6);
        end
        num_sixths = size(cross_sixths,1);
        
        % Create a list of 7th-order cross-multiplying terms (e.g., t*u*v*w*x*y*z)
        if (num_variables < 7)
            cross_sevenths = [];
        else
            cross_sevenths = nchoosek(1:num_variables,7);
        end
        num_sevenths = size(cross_sevenths,1);
    else
        num_pairs = 0;
        num_trios = 0;
        num_quads = 0;
        num_quints = 0;
        num_sixths = 0;
        num_sevenths = 0;
    end
    
    % Preallocate output
    septic_matrix = zeros(num_values, num_variables+6*num_pairs+15*num_trios+20*num_quads+15*num_quints+6*num_sixths+num_sevenths);
    
    % Assign the septic terms (e.g., x^7)
    septic_matrix(:,1:num_variables) = data_matrix.^7;
    
    if (cross_terms)
        % Assign the cross-multiplying terms
        for pairIdx = 1:num_pairs
            % Populate the cross-multiplying terms
            septic_matrix(:,pairIdx+num_variables)             = data_matrix(:,cross_pairs(pairIdx,1)).^6 .* data_matrix(:,cross_pairs(pairIdx,2));
            septic_matrix(:,pairIdx+num_variables+  num_pairs) = data_matrix(:,cross_pairs(pairIdx,1)).^5 .* data_matrix(:,cross_pairs(pairIdx,2)).^2;
            septic_matrix(:,pairIdx+num_variables+2*num_pairs) = data_matrix(:,cross_pairs(pairIdx,1)).^4 .* data_matrix(:,cross_pairs(pairIdx,2)).^3;
            septic_matrix(:,pairIdx+num_variables+3*num_pairs) = data_matrix(:,cross_pairs(pairIdx,1)).^3 .* data_matrix(:,cross_pairs(pairIdx,2)).^4;
            septic_matrix(:,pairIdx+num_variables+4*num_pairs) = data_matrix(:,cross_pairs(pairIdx,1)).^2 .* data_matrix(:,cross_pairs(pairIdx,2)).^5;
            septic_matrix(:,pairIdx+num_variables+5*num_pairs) = data_matrix(:,cross_pairs(pairIdx,1))    .* data_matrix(:,cross_pairs(pairIdx,2)).^6;
        end % pairIdx
        
        % Assign the 3rd-order cross-multiplying terms
        for trioIdx = 1:num_trios
            % Populate the cross-multiplying terms
            septic_matrix(:,trioIdx+num_variables+6*num_pairs)              = data_matrix(:,cross_trios(trioIdx,1)).^5 .* data_matrix(:,cross_trios(trioIdx,2))    .* data_matrix(:,cross_trios(trioIdx,3));
            septic_matrix(:,trioIdx+num_variables+6*num_pairs+   num_trios) = data_matrix(:,cross_trios(trioIdx,1)).^4 .* data_matrix(:,cross_trios(trioIdx,2)).^2 .* data_matrix(:,cross_trios(trioIdx,3));
            septic_matrix(:,trioIdx+num_variables+6*num_pairs+ 2*num_trios) = data_matrix(:,cross_trios(trioIdx,1)).^4 .* data_matrix(:,cross_trios(trioIdx,2))    .* data_matrix(:,cross_trios(trioIdx,3)).^2;
            septic_matrix(:,trioIdx+num_variables+6*num_pairs+ 3*num_trios) = data_matrix(:,cross_trios(trioIdx,1)).^3 .* data_matrix(:,cross_trios(trioIdx,2)).^3 .* data_matrix(:,cross_trios(trioIdx,3));
            septic_matrix(:,trioIdx+num_variables+6*num_pairs+ 4*num_trios) = data_matrix(:,cross_trios(trioIdx,1)).^3 .* data_matrix(:,cross_trios(trioIdx,2))    .* data_matrix(:,cross_trios(trioIdx,3)).^3;
            septic_matrix(:,trioIdx+num_variables+6*num_pairs+ 5*num_trios) = data_matrix(:,cross_trios(trioIdx,1)).^3 .* data_matrix(:,cross_trios(trioIdx,2)).^2 .* data_matrix(:,cross_trios(trioIdx,3)).^2;
            septic_matrix(:,trioIdx+num_variables+6*num_pairs+ 6*num_trios) = data_matrix(:,cross_trios(trioIdx,1)).^2 .* data_matrix(:,cross_trios(trioIdx,2)).^4 .* data_matrix(:,cross_trios(trioIdx,3));
            septic_matrix(:,trioIdx+num_variables+6*num_pairs+ 7*num_trios) = data_matrix(:,cross_trios(trioIdx,1)).^2 .* data_matrix(:,cross_trios(trioIdx,2))    .* data_matrix(:,cross_trios(trioIdx,3)).^4;
            septic_matrix(:,trioIdx+num_variables+6*num_pairs+ 8*num_trios) = data_matrix(:,cross_trios(trioIdx,1)).^2 .* data_matrix(:,cross_trios(trioIdx,2)).^2 .* data_matrix(:,cross_trios(trioIdx,3)).^3;
            septic_matrix(:,trioIdx+num_variables+6*num_pairs+ 9*num_trios) = data_matrix(:,cross_trios(trioIdx,1)).^2 .* data_matrix(:,cross_trios(trioIdx,2)).^3 .* data_matrix(:,cross_trios(trioIdx,3)).^2;
            septic_matrix(:,trioIdx+num_variables+6*num_pairs+10*num_trios) = data_matrix(:,cross_trios(trioIdx,1))    .* data_matrix(:,cross_trios(trioIdx,2)).^5 .* data_matrix(:,cross_trios(trioIdx,3));
            septic_matrix(:,trioIdx+num_variables+6*num_pairs+11*num_trios) = data_matrix(:,cross_trios(trioIdx,1))    .* data_matrix(:,cross_trios(trioIdx,2)).^4 .* data_matrix(:,cross_trios(trioIdx,3)).^2;
            septic_matrix(:,trioIdx+num_variables+6*num_pairs+12*num_trios) = data_matrix(:,cross_trios(trioIdx,1))    .* data_matrix(:,cross_trios(trioIdx,2)).^3 .* data_matrix(:,cross_trios(trioIdx,3)).^3;
            septic_matrix(:,trioIdx+num_variables+6*num_pairs+13*num_trios) = data_matrix(:,cross_trios(trioIdx,1))    .* data_matrix(:,cross_trios(trioIdx,2)).^2 .* data_matrix(:,cross_trios(trioIdx,3)).^4;
            septic_matrix(:,trioIdx+num_variables+6*num_pairs+14*num_trios) = data_matrix(:,cross_trios(trioIdx,1))    .* data_matrix(:,cross_trios(trioIdx,2))    .* data_matrix(:,cross_trios(trioIdx,3)).^5;
        end % trioIdx
        
        % Assign the 4th-order cross-multiplying terms
        for quadIdx = 1:num_quads
            % Populate the cross-multiplying terms
            septic_matrix(:,quadIdx+num_variables+6*num_pairs+15*num_trios)              = data_matrix(:,cross_quads(quadIdx,1)).^4 .* data_matrix(:,cross_quads(quadIdx,2))    .* data_matrix(:,cross_quads(quadIdx,3))    .* data_matrix(:,cross_quads(quadIdx,4));
            septic_matrix(:,quadIdx+num_variables+6*num_pairs+15*num_trios+   num_quads) = data_matrix(:,cross_quads(quadIdx,1)).^3 .* data_matrix(:,cross_quads(quadIdx,2)).^2 .* data_matrix(:,cross_quads(quadIdx,3))    .* data_matrix(:,cross_quads(quadIdx,4));
            septic_matrix(:,quadIdx+num_variables+6*num_pairs+15*num_trios+ 2*num_quads) = data_matrix(:,cross_quads(quadIdx,1)).^3 .* data_matrix(:,cross_quads(quadIdx,2))    .* data_matrix(:,cross_quads(quadIdx,3)).^2 .* data_matrix(:,cross_quads(quadIdx,4));
            septic_matrix(:,quadIdx+num_variables+6*num_pairs+15*num_trios+ 3*num_quads) = data_matrix(:,cross_quads(quadIdx,1)).^3 .* data_matrix(:,cross_quads(quadIdx,2))    .* data_matrix(:,cross_quads(quadIdx,3))    .* data_matrix(:,cross_quads(quadIdx,4)).^2;
            septic_matrix(:,quadIdx+num_variables+6*num_pairs+15*num_trios+ 4*num_quads) = data_matrix(:,cross_quads(quadIdx,1)).^2 .* data_matrix(:,cross_quads(quadIdx,2)).^3 .* data_matrix(:,cross_quads(quadIdx,3))    .* data_matrix(:,cross_quads(quadIdx,4));
            septic_matrix(:,quadIdx+num_variables+6*num_pairs+15*num_trios+ 5*num_quads) = data_matrix(:,cross_quads(quadIdx,1)).^2 .* data_matrix(:,cross_quads(quadIdx,2))    .* data_matrix(:,cross_quads(quadIdx,3)).^3 .* data_matrix(:,cross_quads(quadIdx,4));
            septic_matrix(:,quadIdx+num_variables+6*num_pairs+15*num_trios+ 6*num_quads) = data_matrix(:,cross_quads(quadIdx,1)).^2 .* data_matrix(:,cross_quads(quadIdx,2))    .* data_matrix(:,cross_quads(quadIdx,3))    .* data_matrix(:,cross_quads(quadIdx,4)).^3;
            septic_matrix(:,quadIdx+num_variables+6*num_pairs+15*num_trios+ 7*num_quads) = data_matrix(:,cross_quads(quadIdx,1)).^2 .* data_matrix(:,cross_quads(quadIdx,2)).^2 .* data_matrix(:,cross_quads(quadIdx,3)).^2 .* data_matrix(:,cross_quads(quadIdx,4));
            septic_matrix(:,quadIdx+num_variables+6*num_pairs+15*num_trios+ 8*num_quads) = data_matrix(:,cross_quads(quadIdx,1)).^2 .* data_matrix(:,cross_quads(quadIdx,2)).^2 .* data_matrix(:,cross_quads(quadIdx,3))    .* data_matrix(:,cross_quads(quadIdx,4)).^2;
            septic_matrix(:,quadIdx+num_variables+6*num_pairs+15*num_trios+ 9*num_quads) = data_matrix(:,cross_quads(quadIdx,1)).^2 .* data_matrix(:,cross_quads(quadIdx,2))    .* data_matrix(:,cross_quads(quadIdx,3)).^2 .* data_matrix(:,cross_quads(quadIdx,4)).^2;
            septic_matrix(:,quadIdx+num_variables+6*num_pairs+15*num_trios+10*num_quads) = data_matrix(:,cross_quads(quadIdx,1))    .* data_matrix(:,cross_quads(quadIdx,2)).^4 .* data_matrix(:,cross_quads(quadIdx,3))    .* data_matrix(:,cross_quads(quadIdx,4));
            septic_matrix(:,quadIdx+num_variables+6*num_pairs+15*num_trios+11*num_quads) = data_matrix(:,cross_quads(quadIdx,1))    .* data_matrix(:,cross_quads(quadIdx,2)).^3 .* data_matrix(:,cross_quads(quadIdx,3)).^2 .* data_matrix(:,cross_quads(quadIdx,4));
            septic_matrix(:,quadIdx+num_variables+6*num_pairs+15*num_trios+12*num_quads) = data_matrix(:,cross_quads(quadIdx,1))    .* data_matrix(:,cross_quads(quadIdx,2)).^3 .* data_matrix(:,cross_quads(quadIdx,3))    .* data_matrix(:,cross_quads(quadIdx,4)).^2;
            septic_matrix(:,quadIdx+num_variables+6*num_pairs+15*num_trios+13*num_quads) = data_matrix(:,cross_quads(quadIdx,1))    .* data_matrix(:,cross_quads(quadIdx,2)).^2 .* data_matrix(:,cross_quads(quadIdx,3)).^3 .* data_matrix(:,cross_quads(quadIdx,4));
            septic_matrix(:,quadIdx+num_variables+6*num_pairs+15*num_trios+14*num_quads) = data_matrix(:,cross_quads(quadIdx,1))    .* data_matrix(:,cross_quads(quadIdx,2)).^2 .* data_matrix(:,cross_quads(quadIdx,3))    .* data_matrix(:,cross_quads(quadIdx,4)).^3;
            septic_matrix(:,quadIdx+num_variables+6*num_pairs+15*num_trios+15*num_quads) = data_matrix(:,cross_quads(quadIdx,1))    .* data_matrix(:,cross_quads(quadIdx,2)).^2 .* data_matrix(:,cross_quads(quadIdx,3)).^2 .* data_matrix(:,cross_quads(quadIdx,4)).^2;
            septic_matrix(:,quadIdx+num_variables+6*num_pairs+15*num_trios+16*num_quads) = data_matrix(:,cross_quads(quadIdx,1))    .* data_matrix(:,cross_quads(quadIdx,2))    .* data_matrix(:,cross_quads(quadIdx,3)).^4 .* data_matrix(:,cross_quads(quadIdx,4));
            septic_matrix(:,quadIdx+num_variables+6*num_pairs+15*num_trios+17*num_quads) = data_matrix(:,cross_quads(quadIdx,1))    .* data_matrix(:,cross_quads(quadIdx,2))    .* data_matrix(:,cross_quads(quadIdx,3)).^3 .* data_matrix(:,cross_quads(quadIdx,4)).^2;
            septic_matrix(:,quadIdx+num_variables+6*num_pairs+15*num_trios+18*num_quads) = data_matrix(:,cross_quads(quadIdx,1))    .* data_matrix(:,cross_quads(quadIdx,2))    .* data_matrix(:,cross_quads(quadIdx,3)).^2 .* data_matrix(:,cross_quads(quadIdx,4)).^3;
            septic_matrix(:,quadIdx+num_variables+6*num_pairs+15*num_trios+19*num_quads) = data_matrix(:,cross_quads(quadIdx,1))    .* data_matrix(:,cross_quads(quadIdx,2))    .* data_matrix(:,cross_quads(quadIdx,3))    .* data_matrix(:,cross_quads(quadIdx,4)).^4;
        end % quadIdx
        
        % Assign the 5th-order cross-multiplying terms
        for quintIdx = 1:num_quints
            % Populate the cross-multiplying terms
            septic_matrix(:,quintIdx+num_variables+6*num_pairs+15*num_trios+20*num_quads)               = data_matrix(:,cross_quints(quintIdx,1)).^3 .* data_matrix(:,cross_quints(quintIdx,2))    .* data_matrix(:,cross_quints(quintIdx,3))    .* data_matrix(:,cross_quints(quintIdx,4))    .* data_matrix(:,cross_quints(quintIdx,5));
            septic_matrix(:,quintIdx+num_variables+6*num_pairs+15*num_trios+20*num_quads+   num_quints) = data_matrix(:,cross_quints(quintIdx,1)).^2 .* data_matrix(:,cross_quints(quintIdx,2)).^2 .* data_matrix(:,cross_quints(quintIdx,3))    .* data_matrix(:,cross_quints(quintIdx,4))    .* data_matrix(:,cross_quints(quintIdx,5));
            septic_matrix(:,quintIdx+num_variables+6*num_pairs+15*num_trios+20*num_quads+ 2*num_quints) = data_matrix(:,cross_quints(quintIdx,1)).^2 .* data_matrix(:,cross_quints(quintIdx,2))    .* data_matrix(:,cross_quints(quintIdx,3)).^2 .* data_matrix(:,cross_quints(quintIdx,4))    .* data_matrix(:,cross_quints(quintIdx,5));
            septic_matrix(:,quintIdx+num_variables+6*num_pairs+15*num_trios+20*num_quads+ 3*num_quints) = data_matrix(:,cross_quints(quintIdx,1)).^2 .* data_matrix(:,cross_quints(quintIdx,2))    .* data_matrix(:,cross_quints(quintIdx,3))    .* data_matrix(:,cross_quints(quintIdx,4)).^2 .* data_matrix(:,cross_quints(quintIdx,5));
            septic_matrix(:,quintIdx+num_variables+6*num_pairs+15*num_trios+20*num_quads+ 4*num_quints) = data_matrix(:,cross_quints(quintIdx,1)).^2 .* data_matrix(:,cross_quints(quintIdx,2))    .* data_matrix(:,cross_quints(quintIdx,3))    .* data_matrix(:,cross_quints(quintIdx,4))    .* data_matrix(:,cross_quints(quintIdx,5)).^2;
            septic_matrix(:,quintIdx+num_variables+6*num_pairs+15*num_trios+20*num_quads+ 5*num_quints) = data_matrix(:,cross_quints(quintIdx,1))    .* data_matrix(:,cross_quints(quintIdx,2)).^3 .* data_matrix(:,cross_quints(quintIdx,3))    .* data_matrix(:,cross_quints(quintIdx,4))    .* data_matrix(:,cross_quints(quintIdx,5));
            septic_matrix(:,quintIdx+num_variables+6*num_pairs+15*num_trios+20*num_quads+ 6*num_quints) = data_matrix(:,cross_quints(quintIdx,1))    .* data_matrix(:,cross_quints(quintIdx,2)).^2 .* data_matrix(:,cross_quints(quintIdx,3)).^2 .* data_matrix(:,cross_quints(quintIdx,4))    .* data_matrix(:,cross_quints(quintIdx,5));
            septic_matrix(:,quintIdx+num_variables+6*num_pairs+15*num_trios+20*num_quads+ 7*num_quints) = data_matrix(:,cross_quints(quintIdx,1))    .* data_matrix(:,cross_quints(quintIdx,2)).^2 .* data_matrix(:,cross_quints(quintIdx,3))    .* data_matrix(:,cross_quints(quintIdx,4)).^2 .* data_matrix(:,cross_quints(quintIdx,5));
            septic_matrix(:,quintIdx+num_variables+6*num_pairs+15*num_trios+20*num_quads+ 8*num_quints) = data_matrix(:,cross_quints(quintIdx,1))    .* data_matrix(:,cross_quints(quintIdx,2)).^2 .* data_matrix(:,cross_quints(quintIdx,3))    .* data_matrix(:,cross_quints(quintIdx,4))    .* data_matrix(:,cross_quints(quintIdx,5)).^2;
            septic_matrix(:,quintIdx+num_variables+6*num_pairs+15*num_trios+20*num_quads+ 9*num_quints) = data_matrix(:,cross_quints(quintIdx,1))    .* data_matrix(:,cross_quints(quintIdx,2))    .* data_matrix(:,cross_quints(quintIdx,3)).^3 .* data_matrix(:,cross_quints(quintIdx,4))    .* data_matrix(:,cross_quints(quintIdx,5));
            septic_matrix(:,quintIdx+num_variables+6*num_pairs+15*num_trios+20*num_quads+10*num_quints) = data_matrix(:,cross_quints(quintIdx,1))    .* data_matrix(:,cross_quints(quintIdx,2))    .* data_matrix(:,cross_quints(quintIdx,3)).^2 .* data_matrix(:,cross_quints(quintIdx,4)).^2 .* data_matrix(:,cross_quints(quintIdx,5));
            septic_matrix(:,quintIdx+num_variables+6*num_pairs+15*num_trios+20*num_quads+11*num_quints) = data_matrix(:,cross_quints(quintIdx,1))    .* data_matrix(:,cross_quints(quintIdx,2))    .* data_matrix(:,cross_quints(quintIdx,3)).^2 .* data_matrix(:,cross_quints(quintIdx,4))    .* data_matrix(:,cross_quints(quintIdx,5)).^2;
            septic_matrix(:,quintIdx+num_variables+6*num_pairs+15*num_trios+20*num_quads+12*num_quints) = data_matrix(:,cross_quints(quintIdx,1))    .* data_matrix(:,cross_quints(quintIdx,2))    .* data_matrix(:,cross_quints(quintIdx,3))    .* data_matrix(:,cross_quints(quintIdx,4)).^3 .* data_matrix(:,cross_quints(quintIdx,5));
            septic_matrix(:,quintIdx+num_variables+6*num_pairs+15*num_trios+20*num_quads+13*num_quints) = data_matrix(:,cross_quints(quintIdx,1))    .* data_matrix(:,cross_quints(quintIdx,2))    .* data_matrix(:,cross_quints(quintIdx,3))    .* data_matrix(:,cross_quints(quintIdx,4)).^2 .* data_matrix(:,cross_quints(quintIdx,5)).^2;
            septic_matrix(:,quintIdx+num_variables+6*num_pairs+15*num_trios+20*num_quads+14*num_quints) = data_matrix(:,cross_quints(quintIdx,1))    .* data_matrix(:,cross_quints(quintIdx,2))    .* data_matrix(:,cross_quints(quintIdx,3))    .* data_matrix(:,cross_quints(quintIdx,4))    .* data_matrix(:,cross_quints(quintIdx,5)).^3;
        end % quintIdx
        
        % Assign the 6th-order cross-multiplying terms
        for sixthIdx = 1:num_sixths
            septic_matrix(:,sixthIdx+num_variables+6*num_pairs+15*num_trios+20*num_quads+15*num_quints)              = data_matrix(:,cross_sixths(sixthIdx,1)).^2 .* data_matrix(:,cross_sixths(sixthIdx,2))    .* data_matrix(:,cross_sixths(sixthIdx,3))    .* data_matrix(:,cross_sixths(sixthIdx,4))    .* data_matrix(:,cross_sixths(sixthIdx,5))    .* data_matrix(:,cross_sixths(sixthIdx,6));
            septic_matrix(:,sixthIdx+num_variables+6*num_pairs+15*num_trios+20*num_quads+15*num_quints+num_sixths)   = data_matrix(:,cross_sixths(sixthIdx,1))    .* data_matrix(:,cross_sixths(sixthIdx,2)).^2 .* data_matrix(:,cross_sixths(sixthIdx,3))    .* data_matrix(:,cross_sixths(sixthIdx,4))    .* data_matrix(:,cross_sixths(sixthIdx,5))    .* data_matrix(:,cross_sixths(sixthIdx,6));
            septic_matrix(:,sixthIdx+num_variables+6*num_pairs+15*num_trios+20*num_quads+15*num_quints+2*num_sixths) = data_matrix(:,cross_sixths(sixthIdx,1))    .* data_matrix(:,cross_sixths(sixthIdx,2))    .* data_matrix(:,cross_sixths(sixthIdx,3)).^2 .* data_matrix(:,cross_sixths(sixthIdx,4))    .* data_matrix(:,cross_sixths(sixthIdx,5))    .* data_matrix(:,cross_sixths(sixthIdx,6));
            septic_matrix(:,sixthIdx+num_variables+6*num_pairs+15*num_trios+20*num_quads+15*num_quints+3*num_sixths) = data_matrix(:,cross_sixths(sixthIdx,1))    .* data_matrix(:,cross_sixths(sixthIdx,2))    .* data_matrix(:,cross_sixths(sixthIdx,3))    .* data_matrix(:,cross_sixths(sixthIdx,4)).^2 .* data_matrix(:,cross_sixths(sixthIdx,5))    .* data_matrix(:,cross_sixths(sixthIdx,6));
            septic_matrix(:,sixthIdx+num_variables+6*num_pairs+15*num_trios+20*num_quads+15*num_quints+4*num_sixths) = data_matrix(:,cross_sixths(sixthIdx,1))    .* data_matrix(:,cross_sixths(sixthIdx,2))    .* data_matrix(:,cross_sixths(sixthIdx,3))    .* data_matrix(:,cross_sixths(sixthIdx,4))    .* data_matrix(:,cross_sixths(sixthIdx,5)).^2 .* data_matrix(:,cross_sixths(sixthIdx,6));
            septic_matrix(:,sixthIdx+num_variables+6*num_pairs+15*num_trios+20*num_quads+15*num_quints+5*num_sixths) = data_matrix(:,cross_sixths(sixthIdx,1))    .* data_matrix(:,cross_sixths(sixthIdx,2))    .* data_matrix(:,cross_sixths(sixthIdx,3))    .* data_matrix(:,cross_sixths(sixthIdx,4))    .* data_matrix(:,cross_sixths(sixthIdx,5))    .* data_matrix(:,cross_sixths(sixthIdx,6)).^2;
        end % sixthIdx
        
        % Assign the 7th-order cross-multiplying terms
        for seventhIdx = 1:num_sevenths
            septic_matrix(:,seventhIdx+num_variables+6*num_pairs+15*num_trios+20*num_quads+15*num_quints+6*num_sixths) = data_matrix(:,cross_sevenths(seventhIdx,1)) .* data_matrix(:,cross_sevenths(seventhIdx,2)) .* data_matrix(:,cross_sevenths(seventhIdx,3)) .* data_matrix(:,cross_sevenths(seventhIdx,4)) .* data_matrix(:,cross_sevenths(seventhIdx,5)) .* data_matrix(:,cross_sevenths(seventhIdx,6)) .* data_matrix(:,cross_sevenths(seventhIdx,7));
        end % sixthIdx
    end

end % form_septic_matrix

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define the maximum order allowed by this function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function maximum_order = MAX_ORDER()

    maximum_order = 7;

end % MAX_ORDER
