function [xc, yc, R] = Circle_fit(x, y)
    % Mathematical method from https://www.sciencedirect.com/science/article/pii/0734189X89900881
    % [xc, yc, R] = Circle_fit(x, y);
    % Input :
    %         x, y   -> the coordinate of points
    % Output:
    %         xc, yc -> the coordinate of center
    %         R      -> radius of circle
    x = x(:);
    y = y(:);
    if length(x) ~= length(y)
        error('The size of input arguments must be the same.')
    end
    % variable (sum)
        N = length(x);
        sig_x = sum(x);
        sig_y = sum(y);
        sig_x2 = sum(x.^2);
        sig_y2 = sum(y.^2);
        sig_x3 = sum(x.^3);
        sig_y3 = sum(y.^3);
        sig_xy = sum(x.*y);
        sig_x2y = sum(x.^2.*y);
        sig_xy2 = sum(x.*y.^2);
    % variable (otther)
        a1 = 2 * (sig_x^2 - N*sig_x2);
        a2 = 2 * (sig_x*sig_y - N*sig_xy);
        b1 = a2;
        b2 = 2 * (sig_y^2 - N*sig_y2);
        c1 = sig_x2*sig_x - N*sig_x3 + sig_x*sig_y2 - N*sig_xy2;
        c2 = sig_x2*sig_y - N*sig_y3 + sig_y*sig_y2 - N*sig_x2y;
    % Solve xc , yc, R
        xc = (c1*b2 - c2*b1) / (a1*b2 - a2*b1);
        yc = (a1*c2 - a2*c1) / (a1*b2 - a2*b1);
        R = sqrt((sig_x2 - 2*sig_x*xc + N*xc^2 + sig_y2 - 2*sig_y*yc + N*yc^2)/N);
end
