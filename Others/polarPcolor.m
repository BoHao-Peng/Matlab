function polarPcolor(axes, R, theta, Z)
    % Modify from : https://www.mathworks.com/matlabcentral/fileexchange/49040-pcolor-in-polar-coordinates
    % polarPcolor(axes, R, theta, Z)
    % Input:
    %        axes  -> the figure you want to show this
    %        R     -> the circle data (array size 1 x M)
    %        theta -> the spoke data (array size 1 x N)
    %        Z     -> the color data  (array size M x N)
    if isempty(axes)
        figure;
        axes = newplot;
    end
    cosTheta = cosd(90-theta);
    sinTheta = sind(90-theta);
    Rpos = (R - R(1)) / (R(end) - R(1));
    X = Rpos' * cosTheta;
    Y = Rpos' * sinTheta;
    pcolor(axes, X, Y, Z);
    shading interp;
    axis off equal;
    hold(axes,'on');
    CreateSpokes(axes,theta, 0);
    CreateCircles(axes, R(1), R(end), theta(1), theta(end));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Nested function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot Spokes on polarPcolor
function CreateSpokes(axes, theta, mincirclePos)
    cosSpoke = cosd(90 - theta);
    sinSpoke = sind(90 - theta);
    % Plot Spokes
    for t = 1 : length(theta)
        X = cosSpoke(t) * [mincirclePos 1];
        Y = sinSpoke(t) * [mincirclePos 1];
        plot(axes, X, Y, 'color', [0.5,0.5,0.5], 'linewidth', 0.75);
        % Add text (angle) on polarPcolor
        if theta(t) < 360
            text(axes, 1.1.*cosSpoke(t), 1.1.*sinSpoke(t),...
                 [num2str(theta(t),3),char(176)],...
                 'horiz', 'center', 'vert', 'middle');
        end
    end
end
% Plot Circles on polarPcolor
function CreateCircles(axes, rMin, rMax, thetaMin, thetaMax)
    % Theta 
        thetalist = thetaMin : thetaMax;
        cosTheta = cosd( 90 - thetalist);
        sinTheta = sind( 90 - thetalist);
    % Radius
        
        radius = rMin : 10^floor(log10(rMax - rMin)) : rMax;
        radiusPos = (radius - rMin) / (rMax - rMin);
    % Plot Circles
    for t = 1 : length(radius)
        X = radiusPos(t) * cosTheta;
        Y = radiusPos(t) * sinTheta;
        plot(axes, X, Y, 'color', [0.5,0.5,0.5], 'linewidth', 1);
        % Add text (circle position) on polarPcolor
        if thetaMax < 360
             text(axes, (radiusPos(t)).*cosd(85-thetaMax),...
                  (radiusPos(t)).*sind(85-thetaMax),...
                  num2str(radius(t)),'verticalalignment','BaseLine',...
                  'horizontalAlignment', 'center',...
                  'handlevisibility','off');
        else
            text(axes, (radiusPos(t)).*cosd(20),...
                 (radiusPos(t)).*sind(20),...
                 num2str(radius(t)),'verticalalignment','BaseLine',...
                 'horizontalAlignment', 'center',...
                 'handlevisibility','off');
        end
    end
end
