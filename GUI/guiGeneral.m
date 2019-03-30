function varargout = guiGeneral(varargin)
% GUIGENERAL MATLAB code for guiGeneral.fig
%      GUIGENERAL, by itself, creates a new GUIGENERAL or raises the existing
%      singleton*.
%
%      H = GUIGENERAL returns the handle to a new GUIGENERAL or the handle to
%      the existing singleton*.
%
%      GUIGENERAL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUIGENERAL.M with the given input arguments.
%
%      GUIGENERAL('Property','Value',...) creates a new GUIGENERAL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before guiGeneral_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to guiGeneral_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help guiGeneral

% Last Modified by GUIDE v2.5 20-Feb-2017 21:44:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @guiGeneral_OpeningFcn, ...
                   'gui_OutputFcn',  @guiGeneral_OutputFcn, ...
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


% --- Executes just before guiGeneral is made visible.
function guiGeneral_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to guiGeneral (see VARARGIN)

% Choose default command line output for guiGeneral
handles.output = hObject;

handles.res = [];

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes guiGeneral wait for user response (see UIRESUME)
uiwait(handles.gui);


% --- Outputs from this function are returned to the command line.
function varargout = guiGeneral_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ok = get(handles.ok_button,'Value');

res.application = get(handles.application_popup,'String');
if(size(res.application,1) > 1)
    index.application = get(handles.application_popup,'Value');
    res.application = res.application{index.application};
end

res.dataset = get(handles.dataset_popup,'String');
if(size(res.dataset,1) > 1)
    index.dataset = get(handles.dataset_popup,'Value');
    res.dataset = res.dataset{index.dataset};
end

res.errorName = get(handles.error_popup,'String');
if(size(res.errorName,1) > 1)
    index.errorName = get(handles.error_popup,'Value');
    res.errorName = res.errorName{index.errorName};
end

res.selection = get(handles.selection_popup,'String');
if(size(res.selection,1) > 1)
    index.selection = get(handles.selection_popup,'Value');
    res.selection = res.selection{index.selection};
end

varargout{1} = res;
varargout{2} = ok;

delete(handles.gui);


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in dataset_popup.
function dataset_popup_Callback(hObject, eventdata, handles)
% hObject    handle to dataset_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns dataset_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from dataset_popup


% --- Executes during object creation, after setting all properties.
function dataset_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dataset_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2


% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in application_popup.
function application_popup_Callback(hObject, eventdata, handles)
% hObject    handle to application_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns application_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from application_popup


% --- Executes during object creation, after setting all properties.
function application_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to application_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in load_checkbox.
function load_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to load_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of load_checkbox


% --- Executes on mouse press over figure background.
% hObject    handle to gui (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in ok_button.
function ok_button_Callback(hObject, eventdata, handles)
% hObject    handle to ok_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isequal(get(handles.gui, 'waitstatus'), 'waiting')
    uiresume(handles.gui);
else
    delete(handles.gui);
end


% --- Executes when user attempts to close gui.
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


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over ok_button.
function ok_button_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to ok_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in process_checkbox.
function process_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to process_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of process_checkbox


% --- Executes on selection change in error_popup.
function error_popup_Callback(hObject, eventdata, handles)
% hObject    handle to error_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns error_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from error_popup


% --- Executes during object creation, after setting all properties.
function error_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to error_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cancel_button.
function cancel_button_Callback(hObject, eventdata, handles)
% hObject    handle to cancel_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isequal(get(handles.gui, 'waitstatus'), 'waiting')
    uiresume(handles.gui);
else
    delete(handles.gui);
end


% --- Executes on selection change in selection_popup.
function selection_popup_Callback(hObject, eventdata, handles)
% hObject    handle to selection_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns selection_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from selection_popup


% --- Executes during object creation, after setting all properties.
function selection_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to selection_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
