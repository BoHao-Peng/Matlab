function OPD = zernike_sampling(term, pos)
% OPD = zernike_sampling(index, pos)
% Input :
    %    term   -> the term of zernike (0 : Piston, 1,2 : tip,tilt)
    %    pos    -> the sampling point of normalized coordinate
    %               (complex matrix -> real: X, imag: Y)
    % Output:
    %    OPD    -> output is Optical Path Difference
    term = term + 1;
    [n,m] = Fringe(term);
    abs_m = abs(m);
    p = abs(pos);% ρ
    phi = angle(pos); % φ
    
    R = zeros(size(p));
    for k = 0 : (n-abs_m)/2
        R = R + (-1)^k * factorial(n-k) .* p.^(n-2*k) / ...
            (factorial(k) * factorial((n+abs_m)/2-k) * factorial((n-abs_m)/2-k));
    end
    if m < 0
        OPD = R .* sin(m*phi);
    else
        OPD = R .* cos(m*phi);
    end
end
% Nested Function
function [n,m] = Fringe(term)
    main_term = ceil(sqrt(term));
    n = (main_term-1)*2;
    d = main_term^2 - term;
    n = n - ceil(d/2);
    m = ceil(d/2);
    if mod(d,2) ~= 0
        m = -m;
    end
end
