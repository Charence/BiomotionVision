figure;
clear all; load CalibResults_imgpp; plot(128/89*[0:floor(ny/2)],180/pi*atan2(0:floor(ny/2),-polyval([ss(end:-1:1)],[0:floor(ny/2)]))-90,'r'); hold on; grid on; axis equal
clear all; load CalibResults_imgp;  plot(128/100*[0:floor(ny/2)],180/pi*atan2(0:floor(ny/2),-polyval([ss(end:-1:1)],[0:floor(ny/2)]))-90,'g'); hold on; grid on; axis equal
clear all; load CalibResults_img;   plot(128/121*[0:floor(ny/2)],180/pi*atan2(0:floor(ny/2),-polyval([ss(end:-1:1)],[0:floor(ny/2)]))-90,'b'); hold on; grid on; axis equal
clear all; load CalibResults_imgg;  plot([0:floor(ny/2)],180/pi*atan2(0:floor(ny/2),-polyval([ss(end:-1:1)],[0:floor(ny/2)]))-90,'k'); hold on; grid on; axis equal
