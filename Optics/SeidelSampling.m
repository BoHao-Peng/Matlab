function wavefront = SeidelSampling(cor, n, m)
    p = abs(cor);
    theta = angle(cor);
    if m >= 0
        wavefront = p.^n .* cos(m*theta);
    else
        wavefront = p.^n .* sin(m*theta);
    end
end
