function p = Plane_fit(point)
    % p = Plane_fit(point)
    % Input :
    %         point   -> the coordinate of points (the last dimension size must be 3 ! (x,y,z))
    % Output:
    %         p -> parameters of x,y, z, and constant, as following:
    %              p(1) * x + p(2) * y + p(3) * z + p(4) = 0; % P(3) = 1
    dim = size(point);
    if dim(end) ~= 3
        error('The last dimension must be 3! (x,y,z)');
    end
    data_len = prod(dim(1:end-1));
    x = point(1:data_len);
    y = point(data_len+1 : 2*data_len);
    z = point(2*data_len+1 : 3*data_len);
    M = cat(2,x', y', ones(length(y),1));
    C = -z';
    p = M\C;
    p = cat(1,p(1:2), 1, p(3));
end
