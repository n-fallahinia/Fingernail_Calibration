%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Process the image using the desired color method.  Available methods are:
%   (1) 'gray' - Average the three colors to find one grayscale value
%           (i.e., the intensity of the HSI color map).  Also accepts
%           'grey'.
%   (2) 'red' - Use only the Red color channel
%   (3) 'green' - Use only the Green color channel
%   (4) 'blue' - Use only the Blue color channel
%   (5) 'all' - Use all three RGB colors (requires larger matrices for
%           storage and more processing time)
% 
% Not case-sensitive.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function imgOut = convert_image(imgIn, color_channel)

    % Determine color method to use
    if ((strcmpi(color_channel, 'gray')) || (strcmpi(color_channel, 'grey')))
        imgOut = sum(imgIn,3,'double')/(3*255);
    elseif (strcmpi(color_channel, 'red'))
        imgOut = double(imgIn(:,:,1)) / 255;
    elseif (strcmpi(color_channel, 'green'))
        imgOut = double(imgIn(:,:,2)) / 255;
    elseif (strcmpi(color_channel, 'blue'))
        imgOut = double(imgIn(:,:,3)) / 255;
    elseif (strcmpi(color_channel, 'all'))
        imgOut = double(imgIn) / 255;
    else
        error('Unknown color method!');
    end

end % convert_image

