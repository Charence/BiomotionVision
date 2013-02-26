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

fprintf(1,'\nProcessing image %d...\n',kk);

eval(['I = I_' num2str(kk) ';']);

if exist(['wintx_' num2str(kk)]),
    
    eval(['wintxkk = wintx_' num2str(kk) ';']);
    
    if ~isempty(wintxkk) & ~isnan(wintxkk),
        
        eval(['wintx = wintx_' num2str(kk) ';']);
        eval(['winty = winty_' num2str(kk) ';']);
        
    end;
end;

if use_corner_find
    fprintf(1,'Using (wintx,winty)=(%d,%d) - Window size = %dx%d\n',wintx,winty,2*wintx+1,2*winty+1);
    %fprintf(1,'Note: To reset the window size, clear wintx and winty and run ''Extract grid corners'' again\n');
end


figure(2);
image(I);
colormap(map);
set(2,'color',[1 1 1]);

title(['Press ENTER and then Click on the extreme corners of the rectangular pattern (first corner = origin)... Image ' num2str(kk)]);

disp('Press ENTER and then Click on the extreme corners of the rectangular complete pattern (the first clicked corner is the origin)...');
pause;
x= [];y = [];
figure(2); hold on;
for count = 1:(n_sq_x+1)*(n_sq_y+1),
    [xi,yi] = ginput3(1);
    if use_corner_find
        [xxi] = cornerfinder([xi;yi],I,winty,wintx);
        xi = xxi(1);
        yi = xxi(2);
    end
    figure(2);
    plot(xi,yi,'+','color',[ 1.000 0.314 0.510 ],'linewidth',2);
    x = [x;xi];
    y = [y;yi];
    drawnow;
end;
hold off;
Xc = cornerfinder([x';y'],I,winty,wintx);
Yp_abs(:,:,kk)=x;
Xp_abs(:,:,kk)=y;




