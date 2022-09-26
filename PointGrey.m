% ----------------- Point Grey package --------------------
% Author : Bo-Hao, Peng
% update at 2022 / 03 / 28
classdef PointGrey < handle & dynamicprops
    properties (SetAccess = private)
        vid, src, serial, adaptor_name, format, hwInfo, connect_status, set_boundary; % Camara parameters
    end
    properties (Access = private)
        gui_data, handles; % GUI data
    end
    properties (Dependent)
        shutter_boundary, framerate_boundary;
        shutter, framerate;
    end
    properties (SetAccess = public)
        WFSsensor; % camera struct data;
    end
    
    methods (Static) % Constructure
        function obj = PointGrey(device_index, framerate, WFSsensor)
            if (nargin < 1 || isempty(device_index))
                device_index = 1;
            end
            if (nargin < 2 || isempty(framerate))
                framerate = [];
            end
            if (nargin < 3 || isempty(WFSsensor))
                WFSsensor = [];
            end
            obj.WFSsensor = WFSsensor;
            % get CCD information
            try 
                obj.hwInfo = imaqhwinfo('pointgrey');
            catch
                errordlg('您尚未安裝Pointgrey package')
                obj.connect_status = false;
                return
            end
            % check hwInfo is empty or not.
            if isempty(obj.hwInfo.DeviceIDs)
                obj.connect_status = false;
                return
            end
            % CCD connect
            obj.format = 'F7_Mono8_2048x2048_Mode0';
            try
                obj.vid = videoinput(obj.hwInfo.AdaptorName, obj.hwInfo.DeviceInfo(device_index).DeviceID, obj.format) ; 
            catch
                errordlg('Camera Disconnect')
                obj.connect_status = false;
            end
            obj.src = getselectedsource(obj.vid) ;
            obj.ParameterInitialize(); % parameters initialized
            obj.serial = obj.src.SerialNumber;
            obj.adaptor_name = obj.hwInfo.AdaptorName;
            obj.connect_status = true;
            disp('CameraSatus : Connect');
            obj.SetFrameRate(framerate);
        end
    end
    methods
        % Get Snapshot
        function frame = Getsnapshot(self)
            frame = getsnapshot(self.vid);
        end
        % Set FrameRate
        function SetFrameRate(self, value)
            if ~isempty(value)
                bound = self.framerate_boundary;
                if (value < bound(1) || value > bound(2))
                    warning(strcat('Framerate is out of range! ( Range：',num2str(bound(1)),' ~ ',num2str(bound(2)),'(frames/sec) )'));
                else
                    set(self.src, "FrameRate", value);
                    self.set_boundary = propinfo(self.src);
                end
            end
            disp(['FrameRate : ', num2str(self.src.FrameRate)]);
        end
        % Set Shutter
        function SetShutter(self, value)
            bound = self.shutter_boundary;
            if (value < bound(1) || value > bound(2))
                warning(strcat('Shutter is out of range! ( Range：',num2str(bound(1)),' ~ ',num2str(bound(2)),'(ms) )'));
            else
                set(self.src, "Shutter", value);
            end
        end
        % Frame per Trigger
        function SetFramesPerTrigger(self, value)
            self.vid.FramesPerTrigger = value;
        end
        % Trigger repeat
        function SetTriggerRepeat(self,value)
            self.vid.TriggerRepeat = value;
        end
        % Preview
        function Preview(self)
            self.GUI_interface();
            if isempty(self.WFSsensor)
                set(self.gui_data.alignment_cross, 'Enable', 'off');
            end
        end
        % Disconnect
        function Disconnect(self)
            imaqreset
            self.connect_status = false;
            disp('CameraSatus : Disconnect');
        end
    end
    methods % For Dependent Properties Get & Set Methods
        function value = get.shutter_boundary(self)
            value = self.set_boundary.Shutter.ConstraintValue;
        end
        function value = get.framerate_boundary(self)
            value = self.set_boundary.FrameRate.ConstraintValue;
        end
        function value = get.shutter(self)
            value = self.src.Shutter;
        end
        function value = get.framerate(self)
            value = self.src.FrameRate;
        end
    end
    methods (Access = private)
        % Camera parameters initialized
        function ParameterInitialize(self)
            self.set_boundary = propinfo(self.src);
            self.src.Brightness = 0 ;
            self.src.ExposureMode = 'Off' ;
            self.src.FrameRateMode = 'Manual' ;
            self.src.FrameRate = round(self.framerate_boundary(2),-1) ;
            self.src.GainMode = 'Manual';
            self.src.Gain = 0 ;
            self.src.GammaMode = 'Off' ;
            self.src.Gamma = 1 ;
            self.src.ShutterMode = 'Manual' ;
            self.src.Shutter = 0.1 ;
            triggerconfig(self.vid, 'Manual');
        end
        % GUI button & axes setting
        function GUI_interface(self)
            self.gui_data.screen_size = get(0,'Screensize');
            self.gui_data.sensor_size = [2048 2048 0 255]; % sensor X, sensor Y, grey Level Low, grey Level High 
            % main frame
            self.gui_data.mframe = figure('Position',[floor(self.gui_data.screen_size(3)/2.5) floor(self.gui_data.screen_size(4)/4) ...
                                                 floor(self.gui_data.screen_size(4)/1.5) floor(self.gui_data.screen_size(4)/1.5)] ...
                                      ,'NumberTitle','off','Name','Preview','color','k');
            % Preview axes
            self.gui_data.preview_axes = axes('Position', [0.3 0.05 0.65 0.65],'color','w','Xtick',[],'Ytick',[]);
            self.gui_data.preview_image = imshow(ones(2048),'Parent',self.gui_data.preview_axes);
            setappdata(self.gui_data.preview_image,'UpdatePreviewWindowFcn',@(handle, event, himage)HistogramCallback(self, handle, event, himage));
            % X Histogram
            self.gui_data.x_axes = axes('Position', [0.3 0.8  0.65 0.15], ...
                                     'color','k','Xcolor','w','Ycolor','w', ...
                                     'Xlim',[1 self.gui_data.sensor_size(1)],'Ylim',self.gui_data.sensor_size(3:4),'Ygrid','on');
            % Y Histogram
            self.gui_data.y_axes = axes('Position', [0.05 0.05 0.15 0.65], ...
                                     'color','k','Xcolor','w','Ycolor','w', ...
                                     'YDir','reverse','XAxisLocation','top', ...
                                     'Xlim',[1 self.gui_data.sensor_size(2)],'Ylim',self.gui_data.sensor_size(3:4),'Ygrid','on','view',[90 90]);
            % Switch button
            self.gui_data.switch_button = uicontrol('Style','togglebutton','Unit','normalize', ...
                                               'Position',[0.05 0.9 0.15 0.05],'String','ON', ...
                                               'FontSize',20,'Callback',@(handle, event) ButtonCallback(self, handle));
            % Flip Pop-up Menu
            self.gui_data.flip_test = uicontrol('Style','text','Unit','normalize', ...
                                            'Position',[0.01 0.84 0.05 0.05],'String','Flip:', ...
                                            'ForegroundColor','white','BackgroundColor','none', ...
                                            'HorizontalAlignment','left','FontSize', 13);
            self.gui_data.flip_menu = uicontrol('Style','popupmenu','Unit','normalize', ...
                                            'Position',[0.09 0.84 0.11 0.05],'String',{'None';'Up & Down';'Left & Right'});
            % Rotate Pop-up Menu
            self.gui_data.rotate_test = uicontrol('Style','text','Unit','normalize', ...
                                            'Position',[0.01 0.82 0.08 0.03],'String','Rotate:', ...
                                            'ForegroundColor','white','BackgroundColor','none', ...
                                            'HorizontalAlignment','left','FontSize', 12);
            self.gui_data.rotate_menu = uicontrol('Style','popupmenu','Unit','normalize', ...
                                            'Position',[0.09 0.8 0.11 0.05],'FontSize',10, ...
                                            'String',{'0';'90';'180';'270'});
            % Check box (Alignment Cross)
            self.gui_data.alignment_cross = uicontrol('Style','checkbox','Unit','normalize', ...
                                                'Position',[0.01 0.76 0.2 0.05], 'String','Alignment Cross', ...
                                                'BackgroundColor','none','ForegroundColor','white', ...
                                                'FontSize', 12, 'Callback', @(handle, event) AlignmentCrossCallback(self, handle));
            self.gui_data.plot_register = [];
            % Check box (Overexposure & Underexpoure)
            self.gui_data.exposure_check = uicontrol('Style','checkbox','Unit','normalize', ...
                                                'Position',[0.01 0.72 0.2 0.05], 'String','Exposure Check', ...
                                                'BackgroundColor','none','ForegroundColor','white', ...
                                                'FontSize', 12);
            % Create GUI data
            self.handles = guihandles(self.gui_data.mframe);
        end
        % Button Callback
        function ButtonCallback(self, handle)
            switch get(handle,'Value')
                case 1 % Switch to "ON"
                    set(handle,'String','OFF');
                    preview(self.vid, self.gui_data.preview_image);
                case 0 % Switch to "OFF"
                    set(handle,'String','ON');
                    stoppreview(self.vid);
                    self.gui_data.preview_image.CData = ones(2048,2048,3);
            end
        end
        % Histogram Callback
        function HistogramCallback(self, ~, event, himage)
            image = event.Data;
            % Flip
            switch get(self.gui_data.flip_menu,'Value')
                case 2
                    image = flipud(image);
                case 3
                    image = fliplr(image);
            end
            % Rotate
            image = rot90(image, 1-get(self.gui_data.rotate_menu,'Value'));
            % Exposure Check
            if (get(self.gui_data.exposure_check,'Value'))
                image_R = double(image).*(image > 30);
                image_GB = double(image).*(image ~= 255);
                image = uint8(cat(3, image_R, image_GB, image_GB));
            end
            % Plot Data on Preview
            set(himage, 'CData', image)
            % load the boundary of preview window
            x_bound = get(self.gui_data.preview_axes,'XLim');
            y_bound = get(self.gui_data.preview_axes,'YLim');
            x_bound = [ceil(x_bound(1)) floor(x_bound(2))];
            y_bound = [ceil(y_bound(1)) floor(y_bound(2))];
            image = image(y_bound(1):y_bound(2), x_bound(1):x_bound(2));
            Row_max = max(image,[],1);
            Col_max = max(image,[],2);
            plot(self.gui_data.x_axes, x_bound(1):x_bound(2), Row_max, 'Color','r');
            plot(self.gui_data.y_axes, y_bound(1):y_bound(2), Col_max, 'Color','r');
            set(self.gui_data.x_axes,'color','k','Xcolor','w','Ycolor','w', ...
               'Xlim',[x_bound(1) x_bound(2)],'Ylim',self.gui_data.sensor_size(3:4),'Ygrid','on');
            set(self.gui_data.y_axes,'color','k','Xcolor','w','Ycolor','w','YDir','reverse','XAxisLocation','top', ...
               'Xlim',[y_bound(1) y_bound(2)],'Ylim',self.gui_data.sensor_size(3:4),'Ygrid','on','view',[90 90]);
        end
        % Alignment Cross Callback
        function AlignmentCrossCallback(self, handle)
            if get(handle,'Value')
                if isempty(self.gui_data.plot_register)
                    crossX = self.WFSsensor.col_ref(:, self.WFSsensor.center_axis(2));
                    crossY = self.WFSsensor.col_ref(self.WFSsensor.center_axis(1),:);
                    cross = cat(1, crossX(:), crossY(:));
                    hold(self.gui_data.preview_axes,'on');
                    self.gui_data.plot_register = plot(real(cross),imag(cross),'co','Parent',self.gui_data.preview_axes);
                else
                    set(self.gui_data.plot_register,'Visible','on');
                end
            else
                set(self.gui_data.plot_register,'Visible','off');
            end
        end
    end
end