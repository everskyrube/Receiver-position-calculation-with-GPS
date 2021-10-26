function eph = formatEphData(eph_)
eph = [];
eph.rcvr_tow = eph_(1);
eph.svid = eph_(2);
eph.toc = eph_(3);
eph.toe = eph_(4);
eph.af0 = eph_(5);
eph.af1 = eph_(6);
eph.af2 = eph_(7);
eph.ura = eph_(8); 
eph.e = eph_(9);
eph.sqrtA = eph_(10);
eph.dn = eph_(11);
eph.m0 = eph_(12);
eph.w = eph_(13);
eph.omg0 = eph_(14);
eph.i0 = eph_(15);
eph.odot = eph_(16);
eph.idot = eph_(17);
eph.cus = eph_(18);
eph.cuc = eph_(19);
eph.cis = eph_(20);
eph.cic = eph_(21);
eph.crs = eph_(22);
eph.crc = eph_(23);
eph.iod = eph_(24);
end

