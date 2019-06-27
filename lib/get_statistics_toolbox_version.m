function stats_version = get_statistics_toolbox_version()

    % Extract Statistics Toolbox version structure
    v = ver('stats');
    
    % If no structure was generated, toolbox is not installed
    if (isempty(v))
        stats_version = 0;
        return;
    end
    
    % Regular expression to parse a number from the version string
    reg_exp = '^(\d+\.\d+)';
    stats_version = str2num(regexp(v.Version, reg_exp, 'match', 'once'));

end