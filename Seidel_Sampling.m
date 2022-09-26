function wavefront = Seidel_Sampling(pos, n, m)
    p = abs(pos);
    theta = angle(pos);
    if m >= 0
        wavefront = p.^n .* cos(m*theta);
    else
        wavefront = p.^n .* sin(m*theta);
    end
end