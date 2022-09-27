function point_r = Cor_Rotate(point, center, angle, corFlag)
    % point_r = Cor_Rotate(point, center, angle, corFlag);
    % Rotation Order : alpha -> beta -> gamma
    % Input:
    %        point   -> coordinated point to be rotated (final dimension must be 3 [X,Y,Z] )
    %        center  -> [xc, yc, zc] (center of rotation)
    %        angle   -> [alpha, beta, gamma] (same as Code V)
    %        corFlag -> True : use variable "center" as new orgin
    %                   False: (default) use original coordinate
    % Output:
    %        point_r -> coordinate point after rotation (Same size as "point")
    if (nargin < 6) || isempty(corFlag)
        corFlag = false;
    end
    dim = size(point); % dim of point array
    if dim(end) ~= 3
        error('Final Dimension must be 3 !! (x,y,z)');
    end
    point_r = zeros(dim);
    
    data_len = prod(dim(1:end-1)); % data length of x / y / z
    x = point(1:data_len) - center(1);
    y = point(data_len+1 : 2*data_len) - center(2);
    z = point(2*data_len+1 : 3*data_len) - center(3);
% Rotation Matrix
    alpha_rotate = [1 0 0 ; 0 cosd(angle(1)) sind(angle(1)) ; 0 -sind(angle(1)) cosd(angle(1))];
    beta_rotate = [cosd(angle(2)) 0 -sind(angle(2)) ; 0 1 0 ; sind(angle(2)) 0 cosd(angle(2))];
    gamma_rotate = [cosd(angle(3)) sind(angle(3)) 0 ; -sind(angle(3)) cosd(angle(3)) 0 ; 0 0 1];
%  Coordinate Rotate
    for i = 1 : length(x(:))
        pos = [x(i) ; y(i) ; z(i)];
        pos = gamma_rotate * beta_rotate * alpha_rotate * pos;
        point_r(i) = pos(1);
        point_r(data_len + i) = pos(2);
        point_r(2*data_len + i) = pos(3);
    end
% Go back to original coordinate
    if ~corFlag
        point_r(1:data_len) = point_r(1:data_len) + center(1);
        point_r(data_len+1 : 2*data_len) = point_r(data_len+1 : 2*data_len) + center(2);
        point_r(2*data_len+1 : 3*data_len) =  point_r(2*data_len+1 : 3*data_len) + center(3);
    end
end
