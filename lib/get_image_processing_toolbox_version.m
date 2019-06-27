function ipt_version = get_image_processing_toolbox_version()

    % Extract Image Processing Toolbox version structure
    v = ver('images');
    
    % If no structure was generated, toolbox is not installed
    if (isempty(v))
        ipt_version = 0;
        return;
    end
    
    % Regular expression to parse a number from the version string
    reg_exp = '^(\d+\.\d+)';
    ipt_version = str2double(regexp(v.Version, reg_exp, 'match', 'once'));

end