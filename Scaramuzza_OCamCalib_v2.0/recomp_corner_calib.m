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

disp('Window size for corner finder (wintx and winty):');
wintx = input(['wintx ([] = ' num2str(wintx_default) ') = ']);
if isempty(wintx), wintx = wintx_default; end;
wintx = round(wintx);
winty = input(['winty ([] = ' num2str(winty_default) ') = ']);
if isempty(winty), winty = winty_default; end;
winty = round(winty);

fprintf(1,'Window size = %dx%d\n',2*wintx+1,2*winty+1);
for kk = ima_proc,
    eval(['I = I_' num2str(kk) ';']);
    for count = 1:(n_sq_x+1)*(n_sq_y+1),
        xx=RRfin(:,:,kk)*[Xt';Yt';ones(size(Xt'))];
        [Xp_reprojected,Yp_reprojected]=omni3d2pixel(ss,xx,width,height); %convert 3D coordinates in 2D pixel coordinates  
        if wintx~=0 & winty~=0
            [xxi] = cornerfinder([Yp_reprojected(count) + yc ;Xp_reprojected(count) + xc],I,winty,wintx);
        else
            [xxi] = [Yp_reprojected(count) + yc ;Xp_reprojected(count) + xc];
        end;
        Yp_abs(count,1,kk) = xxi(1);
        Xp_abs(count,1,kk) = xxi(2);
    end;
end;
fprintf(1,'Corners recomputed \nDone');
