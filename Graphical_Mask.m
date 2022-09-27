% ----------------- Graphical Mask --------------------
% Author : Bo-Hao, Peng
% update at 2022 / 05 / 06
function mask = Graphical_Mask(WFSdata)
    uidata = GUI_interface(WFSdata);
    % Graphical Circle Mask
    cout_mask = drawcircle(uidata.ImageAxes, "Center", WFSdata.MLA_num/2, 'Radius', WFSdata.MLA_num(1)/2, ...
                            'Visible','off', 'DrawingArea','unlimited', 'Color', 'b');
    cin_mask  = drawcircle(uidata.ImageAxes, "Center", WFSdata.MLA_num/2, 'Radius', WFSdata.MLA_num(1)/4, ...
                            'Visible','off', 'DrawingArea','unlimited', 'Color', 'g');
    addlistener(cout_mask, 'ROIMoved', @OuterCircleMaskMoved);
    addlistener(cin_mask , 'ROIMoved', @InnerCircleMaskMoved);
    setappdata(uidata.UIFigure, 'cout_mask', cout_mask);
    setappdata(uidata.UIFigure, 'cin_mask' , cin_mask);
    
    uiwait(uidata.UIFigure);
    % mask output
    flag = [getappdata(uidata.UIFigure, 'inmaskFlag'), getappdata(uidata.UIFigure, 'outmaskFlag')];
    if sum(flag)
        mask = true(WFSdata.MLA_num);
        [X,Y] = ndgrid(1:WFSdata.MLA_num);
        if flag(1) % Outter Mask
            Rout = (X-cin_mask.Center(1)).^2 + (Y-cin_mask.Center(2)).^2;
            mask(Rout < cin_mask.Radius^2) = false;
        end
        if flag(2) % Inner Mask
            Rin = (X-cout_mask.Center(1)).^2 + (Y-cout_mask.Center(2)).^2;
            mask(Rin > cout_mask.Radius^2) = false;
        end
        mask = fliplr(mask);
    else
        mask = [];
    end
    delete(uidata.UIFigure);
end

% Sub-function
    function uidata = GUI_interface(WFSdata)
        uidata = struct();
        uidata.UIFigure = uifigure('Visible','off');
        screen_size = get(0,'Screensize');
        frame_size = [floor(screen_size(3)/2.5) floor(screen_size(4)/2)]; % Frame Size
        frame_size = repmat(frame_size, 1, 2); % Append the frame size for normalized Calculate
    % uifigure
        uidata.UIFigure.Position = [floor(screen_size(3)/2.5), floor(screen_size(4)/4), frame_size(1), frame_size(2)];
        uidata.UIFigure.Name = 'Graphical Circle Mask';
    % gridlayout
        uidata.GridLayout = uigridlayout(uidata.UIFigure, [8 2]);
        uidata.GridLayout.RowHeight = {'0.5x', '1x', '1x', '4x', '4x', '1x', '1x', '0.5x'};
        uidata.GridLayout.ColumnWidth = {'1x', '0.4x'};
    % panel
        uidata.CoutPanel = uipanel(uidata.GridLayout, 'Title', 'Outer Mask', 'FontSize', 18);
        uidata.CoutPanel.Layout.Row = 4;
        uidata.CoutPanel.Layout.Column = 2;
    
        uidata.CinPanel = uipanel(uidata.GridLayout, 'Title', 'Inner Mask', 'FontSize', 18);
        uidata.CinPanel.Layout.Row = 5;
        uidata.CinPanel.Layout.Column = 2;
    % gridlayout in panel
        uidata.CoutLayout = uigridlayout(uidata.CoutPanel, [2, 3]);
        uidata.CoutLayout.ColumnWidth = {'1x', '0.7x'};
        uidata.CinLayout  = uigridlayout(uidata.CinPanel , [2, 3]);
        uidata.CinLayout.ColumnWidth = {'1x', '0.7x'};
    % uiaxes
        uidata.ImageAxes = uiaxes(uidata.GridLayout);
        uidata.ImageAxes.Layout.Row = [1,8];
        uidata.ImageAxes.Layout.Column = 1;

        uidata.ExposureImage = imagesc(uidata.ImageAxes, flipud(WFSdata.exposure_quality'));
        axis(uidata.ImageAxes, 'equal','tight');
        colorbar(uidata.ImageAxes)
    % label
        % Outer Mask
        uidata.Label_Xout = uilabel(uidata.CoutLayout, 'Text', 'X :', 'FontSize', 18, 'HorizontalAlignment', 'right');
        uidata.Label_Xout.Layout.Row = 1;
        uidata.Label_Xout.Layout.Column = 1;

        uidata.Label_Yout = uilabel(uidata.CoutLayout, 'Text', 'Y :', 'FontSize', 18, 'HorizontalAlignment', 'right');
        uidata.Label_Yout.Layout.Row = 2;
        uidata.Label_Yout.Layout.Column = 1;

        uidata.Label_Rout = uilabel(uidata.CoutLayout, 'Text', 'Radius :', 'FontSize', 18, 'HorizontalAlignment', 'right');
        uidata.Label_Rout.Layout.Row = 3;
        uidata.Label_Rout.Layout.Column = 1;
        % Inner Mask
        uidata.Label_Xin = uilabel(uidata.CinLayout, 'Text', 'X :', 'FontSize', 18, 'HorizontalAlignment', 'right');
        uidata.Label_Xin.Layout.Row = 1;
        uidata.Label_Xin.Layout.Column = 1;

        uidata.Label_Yin = uilabel(uidata.CinLayout, 'Text', 'Y :', 'FontSize', 18, 'HorizontalAlignment', 'right');
        uidata.Label_Yin.Layout.Row = 2;
        uidata.Label_Yin.Layout.Column = 1;

        uidata.Label_Rin = uilabel(uidata.CinLayout, 'Text', 'Radius :', 'FontSize', 18, 'HorizontalAlignment', 'right');
        uidata.Label_Rin.Layout.Row = 3;
        uidata.Label_Rin.Layout.Column = 1;
    % editfield
        % Outer Mask
        uidata.XoutEditfield = uieditfield(uidata.CoutLayout, 'numeric', 'FontSize', 18);
        uidata.XoutEditfield.Value = round(WFSdata.MLA_num(1)/2, 2);
        uidata.XoutEditfield.Layout.Row = 1;
        uidata.XoutEditfield.Layout.Column = 2;
        
        uidata.YoutEditfield = uieditfield(uidata.CoutLayout, 'numeric', 'FontSize', 18);
        uidata.YoutEditfield.Value = round(WFSdata.MLA_num(2)/2, 2);
        uidata.YoutEditfield.Layout.Row = 2;
        uidata.YoutEditfield.Layout.Column = 2;

        uidata.RoutEditfield = uieditfield(uidata.CoutLayout, 'numeric', 'FontSize', 18);
        uidata.RoutEditfield.Value = round(WFSdata.MLA_num(1)/2, 2);
        uidata.RoutEditfield.Layout.Row = 3;
        uidata.RoutEditfield.Layout.Column = 2;
        % Inner Mask
        uidata.XinEditfield = uieditfield(uidata.CinLayout, 'numeric', 'FontSize', 18);
        uidata.XinEditfield.Value = round(WFSdata.MLA_num(1)/2, 2);
        uidata.XinEditfield.Layout.Row = 1;
        uidata.XinEditfield.Layout.Column = 2;
        
        uidata.YinEditfield = uieditfield(uidata.CinLayout, 'numeric', 'FontSize', 18);
        uidata.YinEditfield.Value = round(WFSdata.MLA_num(2)/2, 2);
        uidata.YinEditfield.Layout.Row = 2;
        uidata.YinEditfield.Layout.Column = 2;

        uidata.RinEditfield = uieditfield(uidata.CinLayout, 'numeric', 'FontSize', 18);
        uidata.RinEditfield.Value = round(WFSdata.MLA_num(1)/4, 2);
        uidata.RinEditfield.Layout.Row = 3;
        uidata.RinEditfield.Layout.Column = 2;
    % button
        uidata.OuterMaskButton = uibutton(uidata.GridLayout, 'state', 'Text', 'Outer Circle(blue)', 'FontSize', 18);
        uidata.OuterMaskButton.Layout.Row = 2;
        uidata.OuterMaskButton.Layout.Column = 2;

        uidata.InnerMaskButton = uibutton(uidata.GridLayout, 'state', 'Text', 'Inner Circle (green)', 'FontSize', 18);
        uidata.InnerMaskButton.Layout.Row = 3;
        uidata.InnerMaskButton.Layout.Column = 2;

        uidata.ConfirmButton = uibutton(uidata.GridLayout, 'Text', 'Confirm', 'FontSize', 18);
        uidata.ConfirmButton.Layout.Row = 6;
        uidata.ConfirmButton.Layout.Column = 2;

        uidata.CancelButton = uibutton(uidata.GridLayout, 'Text', 'Cancel', 'FontSize', 18);
        uidata.CancelButton.Layout.Row = 7;
        uidata.CancelButton.Layout.Column = 2;
    % Parameters
        setappdata(uidata.UIFigure, 'outmaskFlag', false);
        setappdata(uidata.UIFigure, 'inmaskFlag', false);
        setappdata(uidata.UIFigure, 'uidata', uidata);
    % Create Callback Function
        uidata.UIFigure.CloseRequestFcn = @(fig, event) CircleMask_CloseFcn(fig);
        % Outer Mask
        uidata.XoutEditfield.ValueChangedFcn = @(src, event) XEditfieldCallback(src,'cout_mask');
        uidata.YoutEditfield.ValueChangedFcn = @(src, event) YEditfieldCallback(src,'cout_mask');
        uidata.RoutEditfield.ValueChangedFcn = @(src, event) REditfieldCallback(src,'cout_mask');
        uidata.OuterMaskButton.ValueChangedFcn = @(src, event) OuterMaskButtonCallback(src, event,'cout_mask');
        % Inner Mask
        uidata.XinEditfield.ValueChangedFcn = @(src, event) XEditfieldCallback(src,'cin_mask');
        uidata.YinEditfield.ValueChangedFcn = @(src, event) YEditfieldCallback(src,'cin_mask');
        uidata.RinEditfield.ValueChangedFcn = @(src, event) REditfieldCallback(src,'cin_mask');
        uidata.InnerMaskButton.ValueChangedFcn = @(src, event) InnerMaskButtonCallback(src, event,'cin_mask');
        % Button
        uidata.ConfirmButton.ButtonPushedFcn = @(src, event) ConfirmButtonCallback(src);
        uidata.CancelButton.ButtonPushedFcn = @(src, event) CancelButtonCallback(src);

        uidata.UIFigure.Visible = 'on';
    end
% Callback
    % Circle mask Move Listener Callback
    function OuterCircleMaskMoved(src, ~)
        uidata = getappdata(src.Parent.Parent.Parent, 'uidata');
        uidata.XoutEditfield.Value = round(src.Center(1), 2);
        uidata.YoutEditfield.Value = round(src.Center(2), 2);
        uidata.RoutEditfield.Value = round(src.Radius, 2);
    end
    function InnerCircleMaskMoved(src, ~)
        uidata = getappdata(src.Parent.Parent.Parent, 'uidata');
        uidata.XinEditfield.Value = round(src.Center(1), 2);
        uidata.YinEditfield.Value = round(src.Center(2), 2);
        uidata.RinEditfield.Value = round(src.Radius, 2);
    end
    % UIFigure CloseRequsetFcn
    function CircleMask_CloseFcn(fig)
        uiresume(fig);
    end
    % XoutEditfield 
    function XEditfieldCallback(src, varname)
        circlemask = getappdata(src.Parent.Parent.Parent.Parent, varname);
        circlemask.Center(1) = src.Value;
    end
    % YoutEditfield 
    function YEditfieldCallback(src, varname)
        circlemask = getappdata(src.Parent.Parent.Parent.Parent, varname);
        circlemask.Center(2) = src.Value;
    end
    % XoutEditfield 
    function REditfieldCallback(src, varname)
        circlemask = getappdata(src.Parent.Parent.Parent.Parent, varname);
        circlemask.Radius = src.Value;
    end
    % OuterMaskButton Callback
    function OuterMaskButtonCallback(src, event, varname)
        circlemask = getappdata(src.Parent.Parent, varname);
        if event.Value
            setappdata(src.Parent.Parent, 'outmaskFlag', true);
            circlemask.Visible = 'on';
        else
            setappdata(src.Parent.Parent, 'outmaskFlag', false);
            circlemask.Visible = 'off';
        end
    end
    % InnerMaskButton Callback
    function InnerMaskButtonCallback(src, event, varname)
        circlemask = getappdata(src.Parent.Parent, varname);
        if event.Value
            setappdata(src.Parent.Parent, 'inmaskFlag', true);
            circlemask.Visible = 'on';
        else
            setappdata(src.Parent.Parent, 'inmaskFlag', false);
            circlemask.Visible = 'off';
        end
    end
    % ConfirmButton Callback
    function ConfirmButtonCallback(src)
        uiresume(src.Parent.Parent);
    end
    % CancelButton Callback
    function CancelButtonCallback(src)
        setappdata(src.Parent.Parent, 'outmaskFlag', false);
        setappdata(src.Parent.Parent, 'inmaskFlag', false);
        uiresume(src.Parent.Parent);
    end