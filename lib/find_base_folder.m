function [base_folder, docs_folder] = find_base_folder()

    % List of data locations
    base_folder = '/home/navid/Force_Estimation';
    home_computer = 'C:\Users\Navid\Documents\MATLAB';
    work_computer = 'C:\Users\Navid\Documents\MATLAB';
    home_laptop = 'C:\Users\Navid\Documents\MATLAB';
    maglev_computer = '/home/navid/UUSoftware';
    
    % Check which computer this code is being run on
    if (exist(home_computer,'dir'))
        docs_folder = home_computer;
    elseif (exist(work_computer,'dir'))
        docs_folder = work_computer;
    elseif (exist(home_laptop,'dir'))
        docs_folder = home_laptop;
    elseif (exist(maglev_computer,'dir'))
        fprintf('It is not a Windows machine! \n')
        base_folder = base_folder;
        docs_folder = '/home/navid/Documents/MATLAB';
    else
        error('No Matlab DOCS folder detected! \n');
    end

end % find_base_folder