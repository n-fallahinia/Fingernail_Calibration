function varargout = find_break_points(varargin)
% BASE M-file for base.fig
%      BASE, by itself, creates a new BASE or raises the existing
%      singleton*.
%
%      H = BASE returns the handle to a new BASE or the handle to
%      the existing singleton*.
%
%      BASE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BASE.M with the given input arguments.
%
%      BASE('Property','Value',...) creates a new BASE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before base_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to base_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help base

% Last Modified by GUIDE v2.5 01-Feb-2013 12:01:22

    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @base_OpeningFcn, ...
                       'gui_OutputFcn',  @base_OutputFcn, ...
                       'gui_LayoutFcn',  [] , ...
                       'gui_Callback',   []);
    if nargin && ischar(varargin{1})
        gui_State.gui_Callback = str2func(varargin{1});
    end
    
    if nargout
        [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
    else
        gui_mainfcn(gui_State, varargin{:});
    end
end % base
% End initialization code - DO NOT EDIT

% --- Executes just before base is made visible.
function base_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to base (see VARARGIN)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Handle variable user inputs
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Process all optional inputs
    num_varargs = length(varargin);
    for varargIdx = 1:(num_varargs-1)
        if (strcmp(varargin{varargIdx}, 'Current'))
            % Look for the 'Current' optional input
            handles.current = varargin{varargIdx+1};
        elseif (strcmp(varargin{varargIdx}, 'Previous'))
            % Look for the 'Current' optional input
            handles.previous = varargin{varargIdx+1};
        elseif (strcmp(varargin{varargIdx}, 'Options'))
            % Look for the 'Options' optional input
            options = varargin{varargIdx+1};
            
            % Extract the optional fields of the options structure
            if (isfield(options,'default_position'))
                handles.default_position = options.default_position;
            else
                handles.default_position = [46 46 1000 750];
            end
            if (isfield(options,'trajIdx'))
                trajIdx = options.trajIdx;
            else
                trajIdx = 1;
            end
        end
    end % varargIdx
    
    % Verify that the current and previous trajectories were read
    if ((~isfield(handles,'current')) || (~isfield(handles,'previous')))
        close(handles.figure1);
        error('Did not correctly read ''Current'' or ''Previous'' data!');
    end
    
    % Plot the two trajectories and determine the best division point
    axes(handles.my_axes);
    [handles.output.break_point, handles.output.eliminate, is_good] = find_break(handles.current, handles.previous, trajIdx);
    set(handles.figure1,'Position',handles.default_position);
    set(handles.my_axes,'YLim',[-2 1]+trajIdx);
    set(handles.my_axes,'YTick',(-2:1)+trajIdx);
    
    if (is_good)
        % Update handles structure
        handles.output.button_pressed = 'None';
        guidata(hObject, handles);
    else
        % Update handles structure
        guidata(hObject, handles);
        
        % Wait for user to click a button
        uiwait(handles.figure1);
    end

end % base_OpeningFcn

function [break_point, eliminate, is_good] = find_break(current_traj, previous_traj, trajIdx)

    % Defaults
    marker_size = 15;
    num_curr = length(current_traj);
    num_prev = length(previous_traj);
    
    % Find the intended break point between the two
    break_point = min(current_traj);
    previous_valid = (previous_traj < break_point);
    current_valid = (current_traj >= break_point);
    num_curr_invalid = sum(~current_valid);
    num_prev_invalid = sum(~previous_valid);
    
    % Attempt to correct the break point estimate, if needed
    if ((num_prev_invalid/num_prev > 0.5) || (num_curr_invalid/num_curr > 0.5))
        % Calculate the next-best estimate of the break point
        curr_diff = diff(current_traj(current_valid));
        num_elim = 1;
        next_break = find(curr_diff > 1, 1) + num_elim;
        
        % Loop until (a) no more break points are found or (b) a good
        % estimate is found
        while ((~isempty(next_break)) && ((num_prev_invalid/num_prev > 0.5) || (num_curr_invalid/num_curr > 0.5)))
            % Update the "valid point" arrays
            break_point = current_traj(next_break);
            previous_valid = (previous_traj < break_point);
            current_valid = (current_traj >= break_point);
            num_curr_invalid = sum(~current_valid);
            num_prev_invalid = sum(~previous_valid);
            
            % Find the next estimate of the break point
            curr_diff = diff(current_traj(current_valid));
            num_elim = num_elim + 1;
            next_break = find(curr_diff > 1, 1) + num_elim;
        end
        
        % Assign output
        is_good = (~isempty(next_break));
    else
        is_good = true;
    end
    
    % Extract the values to be eliminated from the previous trajectory
    eliminate = [previous_traj(~previous_valid); current_traj(~current_valid)];
    legend_entries{1} = 'Current Trajectory';
    
    % Plot the two trajectories
    plot(current_traj,trajIdx*ones(size(current_traj)),'k.','MarkerSize',marker_size);
    hold on;
    if (num_curr_invalid > 0)
        plot(current_traj(~current_valid),trajIdx*ones(num_curr_invalid,1),'.','Color',0.5*[1 1 1],'MarkerSize',marker_size);
        legend_entries{end+1} = 'Current (Invalid)';
    end
    if (sum(previous_valid) > 0)
        plot(previous_traj(previous_valid),(trajIdx-1)*ones(size(previous_traj(previous_valid))),'r.','MarkerSize',marker_size);
        legend_entries{end+1} = 'Previous (Valid)';
    end
    if (num_prev_invalid > 0)
        plot(previous_traj(~previous_valid),(trajIdx-1)*ones(num_prev_invalid,1),'.','Color',0.5*[1 0 0],'MarkerSize',marker_size);
        legend_entries{end+1} = 'Previous (Invalid)';
    end
    hold off;
    
    % Write the legend
    legend(legend_entries);

end % plot_and_break

% --- Outputs from this function are returned to the command line.
function varargout = base_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    % Process the 'User hit the 'x' button' case
    if (isempty(handles))
        varargout{1} = 0;
        varargout{2} = 0;
        varargout{3} = 'x';
    else
        % Get default command line output from handles structure
        varargout{1} = handles.output.break_point;
        varargout{2} = handles.output.eliminate;
        varargout{3} = handles.output.button_pressed;
        
        % Close the figure
        close(handles.figure1);
    end

end % base_OutputFcn

% --- Executes on button press in btnStop.
function btnStop_Callback(hObject, eventdata, handles)
% hObject    handle to btnStop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    % Store this button as the one that was hit
    handles.output.button_pressed = 'Stop';
    
    % Update handles structure
    guidata(hObject, handles);
    
    % Resume program execution
    uiresume(handles.figure1);

end % btnStop_Callback

% --- Executes on button press in btnYes.
function btnYes_Callback(hObject, eventdata, handles)
% hObject    handle to btnYes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    % Store this button as the one that was hit
    handles.output.button_pressed = 'Yes';
    
    % Update handles structure
    guidata(hObject, handles);
    
    % Resume program execution
    uiresume(handles.figure1);

end % btnYes_Callback

% --- Executes on button press in btnNo.
function btnNo_Callback(hObject, eventdata, handles)
% hObject    handle to btnNo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    % Store this button as the one that was hit
    handles.output.button_pressed = 'No';
    
    % Update handles structure
    guidata(hObject, handles);
    
    % Resume program execution
    uiresume(handles.figure1);

end % btnNo_Callback

