ocam_model.ss=ss;
ocam_model.xc=xc;
ocam_model.yc=yc;
ocam_model.c=c;
ocam_model.d=d;
ocam_model.e=e;
ocam_model.width=width;
ocam_model.height=height;

M = [Xt,Yt,zeros(size(Xt))];

reprojectpoints_adv(ocam_model, RRfin, ima_proc, Xp_abs, Yp_abs, M);

ss

xc

yc

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

