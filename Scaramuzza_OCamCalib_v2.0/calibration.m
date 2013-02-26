%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
%   Copyright (C) 2006 DAVIDE SCARAMUZZA
%   
%   Author: Davide Scaramuzza - email: davsca@tiscali.it
%   
%   This program is free software; you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation; either version 2 of the License, or
%   (at your option) any later version.
%   
%   This program is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%   
%   You should have received a copy of the GNU General Public License
%   along with this program; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
%   USA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

format long;

taylor_order = input(['\nDegree of polynomial expansion ([]=' num2str(taylor_order_default) ') = ']); %4
if isempty(taylor_order), taylor_order = taylor_order_default; end;

c=1;
d=0;
e=0;
[RRfin,ss]=calibrate(Xt, Yt, Xp_abs, Yp_abs, xc, yc, taylor_order, ima_proc);
calibrated = 1; %This flag i s1 when the camera has been calibrated
reprojectpoints;
ss

figure(3);
set(3,'Name','Calibration results','NumberTitle','off');
subplot(2,1,1);
plot(0:floor(nx/2),polyval([ss(end:-1:1)],[0:floor(nx/2)])); grid on; axis equal; 
xlabel('Distance ''rho'' from the image center in pixels');
ylabel('f(rho)');
title('Forward projection function');
%
subplot(2,1,2);
plot(0:floor(nx/2),180/pi*atan2(0:floor(nx/2),-polyval([ss(end:-1:1)],[0:floor(nx/2)]))-90); grid on;
xlabel('Distance ''rho'' from the image center in pixels');
ylabel('Degrees');
title('Angle of optical ray as a function of distance from circle center (pixels)');


ocam_model.ss=ss;
ocam_model.xc=xc;
ocam_model.yc=yc;
ocam_model.c=c;
ocam_model.d=d;
ocam_model.e=e;
ocam_model.width=width;
ocam_model.height=height;
