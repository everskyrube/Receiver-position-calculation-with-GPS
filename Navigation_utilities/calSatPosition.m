function [x y z] = calSatPosition(eph, t)
%calculate the XYZ positions for satellite at time (t_s) rcvr_tow - tau
%Note: Requires the script config.m to be in the same directory

config;
%semi-major axis
A = eph.sqrtA.^2;

%mean motion (rad/s)
n0 = sqrt(mu./A.^3);

%corrected mean motion
n = n0+ eph.dn;

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

%compute the true anomaly and argument of latitude
vk = atan2((sqrt(1-eph.e^2))*sin(Ek)/(1-eph.e*cos(Ek)), (cos(Ek)-eph.e)/(1-eph.e*cos(Ek)));
phi_k = vk + eph.w;

%compute second harmonic perturbations
deltauk = eph.cus .* sin(2*phi_k) + eph.cuc .* cos(2*phi_k);
deltark = eph.crs .* sin(2*phi_k) + eph.crc .* cos(2*phi_k);
deltaik = eph.cis .* sin(2*phi_k) + eph.cic .* cos(2*phi_k);

%corrected argument of latitude
uk = phi_k + deltauk;
%corrected radius
rk = (eph.sqrtA.^2) .* (1 - eph.e.* cos(Ek)) + deltark;
%corrected inclination
ik = eph.i0  + eph.idot .* tk + deltaik;

%compute the positions in orbital plane
x_k = rk .* cos(uk);
y_k = rk .* sin(uk);

%corrected longitude of ascending node
%the angle between acending node and greenwich 
omegak = eph.omg0 + (eph.odot - wedot).* tk  - wedot .* eph.toe;

%The position of satellites (Earth fixed coordinates / ECEF)
x = x_k .* cos(omegak) - y_k .* cos(ik) .* sin(omegak);
y = x_k .* sin(omegak) + y_k .* cos(ik) .* cos(omegak);
z = y_k .* sin(ik);
end

