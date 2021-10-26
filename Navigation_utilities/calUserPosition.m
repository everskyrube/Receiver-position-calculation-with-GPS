clear all; clc;
% Note: Requires the script config.m to be in the same directory.
% Note: The Data folder should be put in the project directory (relative path)
config; % run config.m script to retrieve GPS constants. 

ephDataFile = fullfile(pwd, 'Data/eph.dat');
rcvrDataFile = fullfile(pwd, 'Data/rcvr.dat');
eph = importdata(ephDataFile);
rcvr = importdata(rcvrDataFile);

% find unique satellite indicies
sv_arr = unique(eph(2,:)); 
svid_arr = eph(:, 2); %fetch svid only
numSV = length(svid_arr);
numRangeInfo = length(rcvr);

%construct ephemeris data with indices
%match the pseudorange with svid
eph_formatted_ = [];
pr = [];
rcvr_tow_ = [];
for i=1:numSV,
  eph_formatted_{end+1} = formatEphData(eph(i,:)); %reconstructure for later processing
  for j = 1:numRangeInfo, 
    if (rcvr(j, 2) == eph(i,2)), %find the corresponding svid
        pr(i,1) = rcvr(j,3);      
        rcvr_tow_(end+1) = rcvr(j,1);
    end
  end
end

%calculate satellite positions and satellite clock bias
for i=1:numSV,
  tau = pr(i)/c;
  t_s = rcvr_tow_(i) - tau;
  [x_s(i,1) y_s(i,1) z_s(i,1)] = calSatPosition(eph_formatted_{i}, t_s);
  Delta_t_SV(i,1) = calSatClockBias(eph_formatted_{i}, t_s);
  %corrected measured pseudoranage by the calculated satellite clock bias
  prc(i, 1) = pr(i) + Delta_t_SV(i, 1) * c;
end

%Linearized equation
delta_x = ones(4,1); % coarsely initialize delta_x for iteration 
while norm(delta_x(1:3)) >= 1e-4
    x0 = x0 + delta_x;  %x0_new = x0_old + delta_x;
    delta_t_u = x0(4)/-c; %x0(4) is the term (-c * delta_t_u)
    pr_hat = sqrt((x_s-x0(1)).^2 + (y_s-x0(2)).^2 + (z_s-x0(3)).^(2)) + c * delta_t_u;
    delta_pr = pr_hat - prc; %prc: corrected pseudorange by the calculated satellite clock bias
    a_x = (x_s-x0(1))./sqrt((x_s-x0(1)).^2 + (y_s-x0(2)).^2 + (z_s-x0(3)).^(2));
    a_y = (y_s-x0(2))./sqrt((x_s-x0(1)).^2 + (y_s-x0(2)).^2 + (z_s-x0(3)).^(2));
    a_z = (z_s-x0(3))./sqrt((x_s-x0(1)).^2 + (y_s-x0(2)).^2 + (z_s-x0(3)).^(2));
    H = [a_x a_y a_z ones(numSV,1)];
    delta_x = inv(H'*H)*H'*delta_pr;
end

%final result of user position
final_x = x0 + delta_x;
%convert user clock bias, delta_x(4) = -c * delta_tu
final_x(4) = final_x(4)/-c; 
disp(final_x); %output final_x matrix [x_u, y_u, z_u, user_clock_bias]



	
