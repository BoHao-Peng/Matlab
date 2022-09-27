function point_r = MyQuaternion(point, center, r_axis, theta, corFlag)
    % point_r = MyQuaternion(point, center, r_axis, theta, corFlag);
    % Rotation direction : Right-hand rule
    % Input:
    %        point   -> coordinated point to be rotated (final dimension must be 3 [X,Y,Z] )
    %        center  -> [xc, yc, zc] (center of rotation)
    %        r_axis  -> rotary axis, represented by vector
    %        theta   -> rotary angle (unit : degree)
    %        corFlag -> True : use variable "center" as new orgin
    %                   False: (default) use original coordinate
    % Output:
    %        point_r -> coordinate point after rotation (Same size as "point")
    if (nargin < 5) || isempty(corFlag)
        corFlag = false;
    end
    
    dim = size(point); % dim of point array
    if dim(end) ~= 3
        error('Final Dimension must be 3 !! (x,y,z)');
    end
    
    data_len = prod(dim(1:end-1)); % data length of x / y / z
    x = point(1:data_len) - center(1);
    y = point(data_len+1 : 2*data_len) - center(2);
    z = point(2*data_len+1 : 3*data_len) - center(3);
    
    q = cat(2, zeros(data_len,1), x', y', z');
    r_axis = r_axis(:) / rssq(r_axis(:));
    p = [cosd(theta/2) ; sind(theta/2) * r_axis];
    p_conj = [cosd(theta/2) ; -sind(theta/2) * r_axis];
    
    p = repmat(p', data_len);
    p_conj = repmat(p_conj', data_len);
    
    out = Quater_Cal(p, Quater_Cal(q, p_conj));
    
    point_r = zeros(dim);
    if corFlag
        point_r(1:data_len) = out(:,2);
        point_r(data_len+1 : 2*data_len) = out(:,3);
        point_r(2*data_len+1 : 3*data_len) = out(:,4);
    else % Go back to original coordinate
        point_r(1:data_len) = out(:,2) + center(1);
        point_r(data_len+1 : 2*data_len) = out(:,3) + center(2);
        point_r(2*data_len+1 : 3*data_len) = out(:,4) + center(3);
    end
end
% Nested function
function output = Quater_Cal(u, v)
    output = zeros(size(u));
    output(:,1) = u(:,1).*v(:,1) - u(:,2).*v(:,2) - u(:,3).*v(:,3) - u(:,4).*v(:,4);
    output(:,2) = u(:,1).*v(:,2) + u(:,2).*v(:,1) + u(:,3).*v(:,4) - u(:,4).*v(:,3);
    output(:,3) = u(:,1).*v(:,3) + u(:,3).*v(:,1) - u(:,2).*v(:,4) + u(:,4).*v(:,2);
    output(:,4) = u(:,1).*v(:,4) + u(:,4).*v(:,1) + u(:,2).*v(:,3) - u(:,3).*v(:,2);
end
