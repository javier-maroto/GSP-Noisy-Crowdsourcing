function varargout = guiErrorOptimal(varargin)
% GUIERROROPTIMAL MATLAB code for guiErrorOptimal.fig
%      GUIERROROPTIMAL, by itself, creates a new GUIERROROPTIMAL or raises the existing
%      singleton*.
%
%      H = GUIERROROPTIMAL returns the handle to a new GUIERROROPTIMAL or the handle to
%      the existing singleton*.
%
%      GUIERROROPTIMAL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUIERROROPTIMAL.M with the given input arguments.
%
%      GUIERROROPTIMAL('Property','Value',...) creates a new GUIERROROPTIMAL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before guiErrorOptimal_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to guiErrorOptimal_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help guiErrorOptimal

% Last Modified by GUIDE v2.5 21-Feb-2017 00:10:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @guiErrorOptimal_OpeningFcn, ...
                   'gui_OutputFcn',  @guiErrorOptimal_OutputFcn, ...
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
% End initialization code - DO NOT EDIT


% --- Executes just before guiErrorOptimal is made visible.
function guiErrorOptimal_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to guiErrorOptimal (see VARARGIN)

% Choose default command line output for guiErrorOptimal
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes guiErrorOptimal wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = guiErrorOptimal_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ok = get(handles.togglebutton1,'Value');
a = str2num(get(handles.edit1,'String'));


% Get default command line output from handles structure
varargout{1} = a;
varargout{2} = ok;

delete(handles.figure1);



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in togglebutton1.
function togglebutton1_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isequal(get(handles.figure1, 'waitstatus'), 'waiting')
    uiresume(handles.figure1);
else
    delete(handles.figure1);
end

function gui_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to gui (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
if isequal(get(hObject, 'waitstatus'), 'waiting')
    uiresume(hObject);
else
    delete(hObject);
end
