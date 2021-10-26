function dsv  = calSatClockBias(eph, t)
%output the Delta_t_SV only

config;
%semi-major axis
A = eph.sqrtA.^2;

%mean motion (rad/s)
n0 = sqrt(mu./A.^3);

%corrected mean motion
n = n0+ eph.dn;

%time corrected for transit time
tk = t - eph.toe;

if (tk > 302400)
tk = tk - 604800;
elseif (tk < -302400)
tk = tk + 604800;
end

%mean anomaly (r)
Mk = eph.m0 + n.*tk;

%eccentric anomaly solved by iteration (radians)
E_old = Mk;
error = 1;

%Kepler's Equation: Mk = Ek -e*sin(Ek)

while(error > 1e-12)
    Ek = Mk + eph.e * sin(E_old);
    error = abs(Ek - E_old);
    E_old = Ek;
end 

%relativistic corretion term 
deltr = F .* eph.e .* eph.sqrtA .* sin(Ek);

%satellite clock correction
dsv = eph.af0 + eph.af1 .* (t - eph.toc) + eph.af2 .* ((t - eph.toc).^2) + deltr;
end

