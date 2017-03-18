
function varargout = GUI(varargin)
% GUI MATLAB code for GUI.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI.M with the given input arguments.
%
%      GUI('Property','Value',...) creates a new GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI

% Last Modified by GUIDE v2.5 17-Mar-2017 22:13:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_OutputFcn, ...
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


% --- Executes just before GUI is made visible.
function GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI (see VARARGIN)

% Choose default command line output for GUI
handles.output = hObject;

% THIS IS WHERE YOU PUT THE CODE************

% used for getting slider data
handles.sliderListener = addlistener(handles.videoScrubber, 'ContinuousValueChange', @(hFigure, eventdata) videoScrubberContValCallback(hObject, eventdata));

% load video
video = VideoReader('sampleVideo.mp4');
% gets info about video file
handles.videoHeight = video.Height;
handles.videoWidth = video.Width;
handles.fps = video.FrameRate;
handles.videoDuration = video.Duration;
handles.totalFrames = video.NumberOfFrames;

video = VideoReader('sampleVideo.mp4');
% gets first frame of video
handles.currentFrame = readFrame(video);

handles.videoFrames = [handles.currentFrame];

% process video frames
i = 2;
while hasFrame(video)
    handles.currentFrame = readFrame(video);
    handles.videoFrames(:,:,:,i) = handles.currentFrame;
    i = i + 1;
    clc;
    fprintf('Processing frame %.0f.\n', i);
end
clc;
fprintf('Done processing video!\n');
% sets text boxes in the GUI
handles.resolutionString = [num2str(handles.videoWidth), ' X ' , num2str(handles.videoHeight)];
set(handles.resolutionText, 'String', handles.resolutionString);
set(handles.fpsText, 'String', handles.fps);
set(handles.durationText, 'String', handles.videoDuration);
% set first frame into video frame in GUI
imshow(handles.currentFrame, 'Parent', handles.videoFrame);
drawnow;

% Boolean variables used for buttons
handles.isStopButton = false;
handles.isNextFrameButton = false;
handles.isBackFrameButton = false;
handles.isPauseButton = false;
handles.isSliderMoved = false;

handles.currentFrameNumber = 1;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function videoScrubber_Callback(hObject, eventdata, handles)
% hObject    handle to videoScrubber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

function videoScrubberContValCallback(hFigure, eventdata)

handles = guidata(hFigure);

% use get(handles.videoScruber, 'Value') to get slider position from 0 to
% 1, multiply by number of frames in video to get the desired frame.
fprintf('slider value: %f\n', get(handles.videoScrubber, 'Value'));
handles.scrubberValue = get(handles.videoScrubber, 'Value');
handles.isSliderMoved = true;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function videoScrubber_CreateFcn(hObject, eventdata, handles)
% hObject    handle to videoScrubber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in playButton.
function playButton_Callback(hObject, eventdata, handles)
% hObject    handle to playButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

while handles.currentFrameNumber < handles.totalFrames
    if handles.isStopButton == true
        handles.currentFrame = handles.videoFrames(:,:,:,1);
        handles.currentFrameNumber = 1;
        handles.isStopButton = false;
        guidata(hObject, handles);
        imshow(handles.currentFrame, 'Parent', handles.videoFrame);
        drawnow;
        break;
    elseif handles.isPauseButton == true
        handles.isPauseButton = false;
        guidata(hObject, handles);
        imshow(handles.currentFrame, 'Parent', handles.videoFrame);
        drawnow;
        break;
    elseif handles.isNextFrameButton == true
        handles.currentFrameNumber = handles.currentFrameNumber + 1;
        handles.currentFrame = handles.videoFrames(:,:,:,handles.currentFrameNumber);
        handles.isNextFrameButton = false;
        guidata(hObject, handles);
        imshow(handles.currentFrame, 'Parent', handles.videoFrame);
        drawnow;
        break;
    elseif handles.isBackFrameButton == true
        handles.currentFrameNumber = handles.currentFrameNumber - 1;
        handles.currentFrame = handles.videoFrames(:,:,:,handles.currentFrameNumber);
        handles.isBackFrameButton = false;
        guidata(hObject, handles);
        imshow(handles.currentFrame, 'Parent', handles.videoFrame);
        drawnow;
        break;
    elseif handles.isSliderMoved == true
        handles.currentFrameNumber = ceil(handles.currentFrameNumber * handles.scrubberValue);
        handles.currentFrame = handles.videoFrames(:,:,:,handles.currentFrameNumber);
        handles.isSliderMoved = false;
        guidata(hObject, handles);
        imshow(handles.currentFrame, 'Parent', handles.videoFrame);
        drawnow;
    else
        tic;
        handles.currentFrame = handles.videoFrames(:,:,:,handles.currentFrameNumber);
        handles.currentFrameNumber = handles.currentFrameNumber + 1;
        guidata(hObject, handles);
        imshow(handles.currentFrame, 'Parent', handles.videoFrame);
        drawnow;
        delta = toc;
        pause((1/handles.fps) - delta);
    end
end

guidata(hObject, handles);



% --- Executes on button press in stopButton.
function stopButton_Callback(hObject, eventdata, handles)
% hObject    handle to stopButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.isStopButton = true;
guidata(hObject, handles);

% --- Executes on button press in backButton.
function backButton_Callback(hObject, eventdata, handles)
% hObject    handle to backButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.isBackFrameButton = true;
guidata(hObject, handles);


% --- Executes on button press in forwardButton.
function forwardButton_Callback(hObject, eventdata, handles)
% hObject    handle to forwardButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.isNextFrameButton = true;
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function videoFrame_CreateFcn(hObject, eventdata, handles)
% hObject    handle to videoFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate videoFrame

% --- Executes on button press in pauseButton.
function pauseButton_Callback(hObject, eventdata, handles)
% hObject    handle to pauseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.isPauseButton = true;
fprintf('test\n');
guidata(hObject, handles);
