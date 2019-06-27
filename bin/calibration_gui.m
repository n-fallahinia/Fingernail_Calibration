% ###############################################################
% Written by Navid Fallahinia
% Modified 2 Feb 2017 to allow assembling lists of grasping data
% BioRobotics Lab
% University of Utah
% ###############################################################

function varargout = fingernail_gui(varargin)
% Begin initialization code - DO NOT EDIT !!!
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @calibration_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @calibration_gui_OutputFcn, ...
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
% End initialization code - DO NOT EDIT !!!

% --- Executes just before calibration_gui is made visible.
function calibration_gui_OpeningFcn(hObject, ~, handles, varargin)
    handles.output = hObject;
    clc
    evalin( 'base', 'clearvars *' )
    backgroundImage = imread('Uni_logo.jpg');
    image(backgroundImage)
    axis off
    axis image
    
    if isfield(handles, 'values')
        handles = rmfield(handles, 'values');
    end
    
    % Setting the initial current data
    handles.edit1.String = '1';
    handles.edit2.String = '1';
    handles.pushbutton1.String = 'Start Registeration';
    handles.pushbutton2.String = 'Start Calibration\Prediction';
    handles.popupmenu1.String = {'Manual calibration','Individual calibration','Grasping calibration', 'Grasping experiments','AAM compare'};
    handles.popupmenu2.String = {'Thumb', 'Index', 'Middle', 'Ring', 'Little'};
    handles.popupmenu3.String = {'White', 'Green'};
    
    SubIdx_val = handles.edit1.String;
    dataTyp_val = handles.popupmenu1.Value;
    FingTyp_val = handles.popupmenu2.Value;
    ColoTyp_val =handles.popupmenu3.Value;
    TestIdx_val = handles.edit2.String;
    handles.values ={SubIdx_val, dataTyp_val, FingTyp_val, ColoTyp_val, TestIdx_val};
        
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = calibration_gui_OutputFcn(~, ~, handles) 

varargout{1} = handles.output;

% ###################################################
%            GUI and Callbacks
% ###################################################

% subject index callback
function edit1_Callback(~, ~, handles)
if str2num(handles.edit1.String)>0
    if mod(str2num(handles.edit1.String),1) == 0
        SubIdx_val = handles.edit1.String;
        dataTyp_val = handles.popupmenu1.Value;
        FingTyp_val = handles.popupmenu2.Value;
        ColoTyp_val =handles.popupmenu3.Value;
        TestIdx_val = handles.edit2.String;
        handles.values ={SubIdx_val, dataTyp_val, FingTyp_val, ColoTyp_val, TestIdx_val};
    else
        msg = 'MUST BE INTEGER !!';
        handles.edit1.String = msg;
    end
else
    msg = 'MUST BE POSITIVE !!';
    handles.edit1.String = msg;
end

% Executes subject index editor
function edit1_CreateFcn(hObject, ~, ~)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% test index callback
function edit2_Callback(~, ~, handles)
if str2num(handles.edit2.String)>0
    if mod(str2num(handles.edit2.String),1) == 0
        SubIdx_val = handles.edit1.String;
        dataTyp_val = handles.popupmenu1.Value;
        FingTyp_val = handles.popupmenu2.Value;
        ColoTyp_val =handles.popupmenu3.Value;
        TestIdx_val = handles.edit2.String;
        handles.values ={SubIdx_val, dataTyp_val, FingTyp_val, ColoTyp_val, TestIdx_val};
    else
        msg = 'MUST BE INTEGER !!';
        handles.edit2.String = msg;
    end
else
    msg = 'MUST BE POSITIVE !!';
    handles.edit2.String = msg;
end

% Executes test index editor
function edit2_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% data type popupmenu callback
function popupmenu1_Callback(~, ~, handles)
        SubIdx_val = handles.edit1.String;
        dataTyp_val = handles.popupmenu1.Value;
        FingTyp_val = handles.popupmenu2.Value;
        ColoTyp_val =handles.popupmenu3.Value;
        TestIdx_val = handles.edit2.String;
        handles.values ={SubIdx_val, dataTyp_val, FingTyp_val, ColoTyp_val, TestIdx_val};
        
% Executes data type popupmenu
function popupmenu1_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% finger type popupmenu callback
function popupmenu2_Callback(~, ~, handles)
        SubIdx_val = handles.edit1.String;
        dataTyp_val = handles.popupmenu1.Value;
        FingTyp_val = handles.popupmenu2.Value;
        ColoTyp_val =handles.popupmenu3.Value;
        TestIdx_val = handles.edit2.String;
        handles.values ={SubIdx_val, dataTyp_val, FingTyp_val, ColoTyp_val, TestIdx_val};
        
% Executes finger type popupmenu
function popupmenu2_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% color type popupmenu callback 
function popupmenu3_Callback(~, ~, handles)
        SubIdx_val = handles.edit1.String;
        dataTyp_val = handles.popupmenu1.Value;
        FingTyp_val = handles.popupmenu2.Value;
        ColoTyp_val =handles.popupmenu3.Value;
        TestIdx_val = handles.edit2.String;
        handles.values ={SubIdx_val, dataTyp_val, FingTyp_val, ColoTyp_val, TestIdx_val};
        
% Executes color type popupmenu
function popupmenu3_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function axes4_CreateFcn(~, ~, ~)
    backgroundImage = imread('Uni_logo.jpg');
    image(backgroundImage)
    axis off
    axis image
    
% --- Executes during object creation, after setting all properties.
function pushbutton1_CreateFcn(~, ~, ~)

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, ~, handles)
SubIdx_val = handles.edit1.String;
dataTyp_val = handles.popupmenu1.Value;
FingTyp_val = handles.popupmenu2.Value;
ColoTyp_val =handles.popupmenu3.Value;
TestIdx_val = handles.edit2.String;
hObject.String = 'Registration Started...';
handles.values ={SubIdx_val, dataTyp_val, FingTyp_val, ColoTyp_val, TestIdx_val};

subjectIdx = str2double(handles.values{1});
typeIdx = handles.values{2};
fingerIdx = handles.values{3};
colorIdx = handles.values{4};
testIdx = str2double(handles.values{5});
data_registration_func( subjectIdx, typeIdx, fingerIdx, colorIdx, testIdx )
hObject.String = 'Registration Completed';


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, ~, handles)
SubIdx_val = handles.edit1.String;
dataTyp_val = handles.popupmenu1.Value;
FingTyp_val = handles.popupmenu2.Value;
ColoTyp_val =handles.popupmenu3.Value;
TestIdx_val = handles.edit2.String;
hObject.String = 'Calibration Started...';
handles.values ={SubIdx_val, dataTyp_val, FingTyp_val, ColoTyp_val, TestIdx_val};

subjectIdx = str2double(handles.values{1});
typeIdx = handles.values{2};
fingerIdx = handles.values{3};
colorIdx = handles.values{4};
testIdx = str2double(handles.values{5});
data_calibration_func( subjectIdx, typeIdx, fingerIdx, colorIdx, testIdx )
hObject.String = 'Calibration Completed';



