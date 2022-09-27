classdef CONEXController < handle
    % CONEX Controller Documentation
    % Link : https://www.newport.com/mam/celum/celum_assets/resources/CONEX-CC_-_Controller_Documentation.pdf?1
    % Unused function :
    %       'SE': Configure/Execute simultaneous started move
    %       'TB': Get command error string
    %       'TS': Get positioner error and controller state
    %       'VE': Get controller revision information
    %       'ZT': Get all configuration parameters
    properties (SetAccess = private)
        s % serial port
        sProp % serial properties
        controller_Address; % Controller address
        feedbackData; % Feedback Data from CONEX_Controller
        identity;
        status;
        controllerState;
        error
    end
    
    methods(Static) % Constructor
        function obj = CONEXController(com,address)
            if (nargin < 2)
                address = 1;
            end
            % Predifine communication settings
            try
                obj.sProp = struct();
                obj.sProp.comPort = com;
                obj.sProp.baudRate = 921600;
                obj.sProp.parity = 'none';
                obj.sProp.stopBits = 1;
                obj.sProp.flowControl = 'software';
                obj.sProp.terminator = {'CR/LF','CR/LF'};
                obj.s = serialport(obj.sProp.comPort, obj.sProp.baudRate, ...
                    "Parity"     , obj.sProp.parity, ...
                    "StopBits"   , obj.sProp.stopBits, ...
                    "FlowControl", obj.sProp.flowControl);
                configureTerminator(obj.s, obj.sProp.terminator{1}, obj.sProp.terminator{2});
                configureCallback(obj.s, "terminator", @obj.readFeedback)
                % Identity
                obj.controller_Address = address;
                obj.identity = struct();
                obj.sendCommand('ID','?');
                obj.identity.ID = obj.feedbackData;
                % Initialized
                obj.controllerState = 'UNKNOWN';
                obj.sendCommand('RS'); % Reset
                times = 1;
                while ~strcmp(obj.controllerState, 'READY')
                    obj.sendCommand('OR'); % Home search
                    pause(0.5);
                    obj.Error_and_State(); % Error & State read
                    times = times + 1;
                    if (times > 5)
                        break;
                    end
                end
                if ~strcmp(obj.controllerState, 'READY')
                    warning('Connect failed.');
                else
                    obj.status = true;
                    disp('CONEX_Controller is Connected.')
                end
            catch error
                errordlg(error.message)
                obj.status = false;
            end
        end
    end
    % Public Funciton
    methods
        % Move
        function Move(self, value, mode)
            % obj.Move(value, mode)
            %     value : SR > value > SL (unit : angle)
            %      mode : 'rel'(default) -> relative angle
            %           : 'abs'          -> absolute angle
            if (nargin < 3)
                mode = 'rel';
            end
            self.sendCommand('SL','?');
            L_lim = self.feedbackData(4:end);
            self.sendCommand('SR','?');
            R_lim = self.feedbackData(4:end);
            if ((value < str2double(L_lim)) || (value > str2double(R_lim)))
                warning(strcat('Value is out of range ! (from ',L_lim,' to ',R_lim,' )'));
            else
                switch mode
                    case 'abs'
                        self.sendCommand('PA',value);
                    case 'rel'
                        self.sendCommand('PR',value);
                    otherwise
                        warning('Unknown mode of Move function !');
                end
            end
        end
        % Stop motion
        function Stop(self)
            % obj.Stop()
            self.sendCommand('ST');
        end
        % evaluate motiontime
        function cost = MotiontimeEvaluate(self, angle)
            % cost = obj.MotiontimeEvaluate(angle)
            % Variables :
            %         cost : move times of relative move
            %        angle : relative angle of move
            cost = zeros(size(angle));
            for i = 1:length(angle(:))
                self.sendCommand('PT',abs(angle(i)));
                cost(i) = str2double(self.feedbackData(4:end));
            end
        end
        % Get set-point position
        function pos = SettingPosition(self)
            % pos = obj.SettingPosition();
            % Variables :
            %            pos : set-point position
            self.sendCommand('TH');
            pos = str2double(self.feedbackData(4:end));
        end
        % Get current position
        function pos = CurrentPosition(self)
            % pos = obj.CurrentPosition();
            % Variables :
            %            pos : current position
            self.sendCommand('TP');
            pos = str2double(self.feedbackData(4:end));
        end
        % Reset Controller
        function Reset(self)
            % obj.Reset()
            self.sendCommand('RS');
            self.Error_and_State();
            times = 1;
            while ~strcmp(self.controllerState, 'READY')
                self.sendCommand('OR'); % Home search
                pause(0.1);
                self.Error_and_State(); % Error & State read
                pause(0.1);
                if (times < 5)
                    times = times + 1;
                else
                    break;
                end
            end
            if ~strcmp(self.controllerState, 'READY')
                warning('Connect failed.');
            end
        end
        % Get positioner error and controller state
        function Error_and_State(self)
            % error = obj.Error_and_State()
            % Variables:
            %           error : error of Controller(save as cell)
            self.error = ["Not used.", "Not used.", "Not used.", "Not used.", ...
                     "Not used.", "Not used.", "80 W output power exceeded.", "DC voltage too low.", ...
                     "Wrong ESP stage", "Homing time out", "Following error", "Short circuit detection", ...
                     "RMS current limit", "Peak current limit", "Positive end of run", "Negative end of run"];
            self.sendCommand('TS');
            pause(0.1); % wait feedbackData
            state_list = self.feedbackData(end-1:end);
            switch state_list
                case '0A'
                    self.controllerState = 'NOT REFERENCED';
                case '0B'
                    self.controllerState = 'NOT REFERENCED';
                case '0C'
                    self.controllerState = 'NOT REFERENCED';
                case '0D'
                    self.controllerState = 'NOT REFERENCED';
                case '0E'
                    self.controllerState = 'NOT REFERENCED';
                case '0F'
                    self.controllerState = 'NOT REFERENCED';
                case '10'
                    self.controllerState = 'NOT REFERENCED';
                case '14'
                    self.controllerState = 'CONFIGURATION';
                case '1E'
                    self.controllerState = 'HOMING';
                case '28'
                    self.controllerState = 'MOVING';
                case '32'
                    self.controllerState = 'READY';
                case '33'
                    self.controllerState = 'READY';
                case '34'
                    self.controllerState = 'READY';
                case '36'
                    self.controllerState = 'READY';
                case '37'
                    self.controllerState = 'READY';
                case '38'
                    self.controllerState = 'READY';
                case '3C'
                    self.controllerState = 'DISABLE';
                case '3D'
                    self.controllerState = 'DISABLE';
                case '3E'
                    self.controllerState = 'DISABLE';
                case '3F'
                    self.controllerState = 'DISABLE';
                case '46'
                    self.controllerState = 'TRACKING';
                case '47'
                    self.controllerState = 'TRACKING';
                otherwise
                    self.controllerState = 'UNKNOWN';
            end
            error_list = self.feedbackData(4:7);
            mask = dec2bin(hex2dec(error_list(:)),4);
            mask = mask - '0';
            self.error(~mask) = [];
            % Show error list
            if ~isempty(self.error)
                warning('Error occur.')
                for i = 1 : length(self.error)
                    warning(self.error(i))
                end
            end
        end
        % Set parameters
        function Set(self, command, value)
            error_flag = false;
            switch command
                case 'AC' % acceleration
                    if (value < 1E-6)  || (value > 1E12)
                        warning('Value is out of range ! (from 1E-6 to 1E12)')
                        error_flag = true;
                    end
                case 'BA' % backlash compensation
                    if (value < 0)  || (value > 1E12)
                        warning('Value is out of range !(from 0 to 1E12)')
                        error_flag = true;
                    end
                case 'BH' % hysteresis compensation
                    if (value < 0)  || (value > 1E12)
                        warning('Value is out of range !(from 0 to 1E12)')
                        error_flag = true;
                    end
                case 'DV' % driver voltage
                    if (value < 12)  || (value > 48)
                        warning('Value is out of range !(from 12 to 48)')
                        error_flag = true;
                    end
                case 'FD' % low pass filter cut off frequency for Kd
                    if (value < 1E-6)  || (value > 2000)
                        warning('Value is out of range !(from 1E-6 to 2000)')
                        error_flag = true;
                    end
                case 'FE' % following error limit
                    if (value < 1E-6)  || (value > 1E12)
                        warning('Value is out of range !(from 1E-6 to 1E12)')
                        error_flag = true;
                    end
                case 'FF' % friction compensation
                    self.sendCommand('DV','?')
                    lim = self.feedbackData(4:end);
                    if (value < 0)  || (value > str2double(lim))
                        warning(strcat('Value is out of range !(from 0 to ',lim,')'))
                        error_flag = true;
                    end
                case 'HT' % HOME search type
                    if (value < 0)  || (value > 4)
                        warning('Value is out of range !(from 0 to 4)')
                        disp("HOME search type('HT')")
                        disp('   value:0 use MZ switch and encoder Index.')
                        disp('         1 use current position as HOME.')
                        disp('         2 use MZ switch only.')
                        disp('         3 use EoR- switch and encoder Index.')
                        disp('         4 use EoR- switch only")')
                        error_flag = true;
                    end
                case 'ID' % stage identifier
                    if (value < 1)  || (value > 31)
                        warning('Value is out of range !(from 1 to 31)')
                        error_flag = true;
                    end
                case 'JR' % jerk time
                    if (value < 1E-3)  || (value > 1E12)
                        warning('Value is out of range !(from 1E-3 to 1E12)')
                        error_flag = true;
                    end
                case 'KD' % derivative gain
                    if (value < 0)  || (value > 1E12)
                        warning('Value is out of range !(from 0 to 1E12)')
                        error_flag = true;
                    end
                case 'KI' % integral gain
                    if (value < 0)  || (value > 1E12)
                        warning('Value is out of range !(from 0 to 1E12)')
                        error_flag = true;
                    end
                case 'KP' % proportional gain
                    if (value < 0)  || (value > 1E12)
                        warning('Value is out of range !(from 0 to 1E12)')
                        error_flag = true;
                    end
                case 'KV' % velocity feed forward
                    if (value < 0)  || (value > 1E12)
                        warning('Value is out of range !(from 0 to 1E12)')
                        error_flag = true;
                    end
                case 'OH' % HOME search velocity
                    if (value < 1E-6)  || (value > 1E12)
                        warning('Value is out of range !(from 1E-6 to 1E12)')
                        error_flag = true;
                    end
                case 'OR' % Execute HOME search
                    value = [];
                case 'OT' % HOME search time-out
                    if (value < 1)  || (value > 1E3)
                        warning('Value is out of range !(from 1 to 1E3)')
                        error_flag = true;
                    end
                case 'QIL' % Motor¡¦s peak current limit
                    if (value < 0.05)  || (value > 3)
                        warning('Value is out of range !(from 0.05 to 3)')
                        error_flag = true;
                    end
                case 'QIR' % Motor¡¦s rms current limit.
                    if (value < 0.05)  || (value > 1.5)
                        warning('Value is out of range !(from 0.05 to 1.5)')
                        error_flag = true;
                    end
                case 'QIT' % Motor¡¦s rms current averaging time
                    if (value < 0.01)  || (value > 100)
                        warning('Value is out of range !(from 0.05 to 3)')
                        error_flag = true;
                    end
                case 'RS##' % Reset controller¡¦s address
                    value = [];
                case 'SA' % controller¡¦s RS-485 address
                    if (value < 2)  || (value > 31)
                        warning('Value is out of range !(from 2 to 31)')
                        error_flag = true;
                    end
                case 'SC' % control loop state
                    if (value < 2)  || (value > 31)
                        warning('Value is out of range !(from 0 to 1)')
                        disp("Control loop state('SC')")
                        disp('   value:0 OPEN loop control.')
                        disp('         1 CLOSED loop control.')
                        error_flag = true;
                    end
                case 'SL' % negative software limit
                    if (value < -1E12)  || (value > 0)
                        warning('Value is out of range !(from -1E12 to 0)')
                        error_flag = true;
                    end
                case 'SR' % positive software limit
                    if (value < 0)  || (value > 1E12)
                        warning('Value is out of range !(from 0 to 1E12)')
                        error_flag = true;
                    end
                case 'SU' % encoder increment value
                    if (value < 1E-6)  || (value > 1E12)
                        warning('Value is out of range !(from 1E-6 to 1E12)')
                        error_flag = true;
                    end
                case 'VA' % velocity
                    if (value < 1E-6)  || (value > 1E12)
                        warning('Value is out of range !(from 1E-6 to 1E12)')
                        error_flag = true;
                    end
                    
                case 'MM' % Enter/Leave DISABLE state
                    if (value < 0)  || (value > 1)
                        warning('Value is out of range !(from 0 to 1)')
                        disp("Enter/Leave DISABLE state('MM')")
                        disp('   value:0 changes state from READY to DISABLE.')
                        disp('         1 changes state from DISABLE to READY.')
                        error_flag = true;
                    end
                case 'PW' % Enter/Leave CONFIGURATION state
                    if (value < 0)  || (value > 1)
                        warning('Value is out of range !(from 0 to 1)')
                        disp("Enter/Leave CONFIGURATION state('PW')")
                        disp('   value:0 Go from CONFIGURATION state to NOT REFERENCED state.')
                        disp('         1 Go from NOT REFERENCED state to CONFIGURATION state.')
                        error_flag = true;
                    end
                case 'TK' % Enter/Leave TRACKING mode
                    if (value < 0)  || (value > 1)
                        warning('Value is out of range !(from 0 to 1)')
                        disp("Enter/Leave TRACKING state('TK')")
                        disp('   value:0 Go from TRACKING state to READY state.')
                        disp('         1 Go from READY state to TRACKING state.')
                        error_flag = true;
                    end
                    
                otherwise
                    warning('Undefinded function!')
            end
            % Send Data
            if (~error_flag)
                self.sendCommand(command, value)
            end
        end
        % Get parameters
        function output = Get(self, command)
            self.sendCommand(command,'?');
            output = self.feedbackData;
        end
        % Send string to CONEX_Controller
        function sendCommand(self, command, value)
            if (nargin < 3)
                value = [];
            end
            writeline(self.s, strcat(num2str(self.controller_Address),command, num2str(value)));
            pause(0.1);
        end
        % Disconnect
        function Disconnect(self)
            delete(self.s);
            self.s = [];
            self.status = false;
            disp('CONEX_Controller is disconnected.')
        end
    end
    % Private Function
    methods(Access = private)
        % Read feedback from CONEX_Controller
        function readFeedback(obj,~,~)
            obj.feedbackData = char(readline(obj.s));
        end
    end
end
