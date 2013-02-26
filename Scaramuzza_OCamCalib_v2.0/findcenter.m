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
c=1;
d=0;
e=0;
ocam_model.ss=ss;
ocam_model.xc=xc;
ocam_model.yc=yc;
ocam_model.c=c;
ocam_model.d=d;
ocam_model.e=e;
ocam_model.width=width;
ocam_model.height=height;

if exist('taylor_order')
    if isempty(taylor_order),
        taylor_order = taylor_order_default;
    end
else
    taylor_order = taylor_order_default;
end

pxc=xc;
pyc=yc;
width=nx;
height=ny;
regwidth=(width/2);
regheight=(height/2);
yceil=5;
xceil=5;

xregstart=pxc-(regheight/2);
xregstop= pxc+(regheight/2);
yregstart=pyc-(regwidth/2);
yregstop= pyc+(regwidth/2);
fprintf(1,'Iteration ');
for glc=1:9
    [yreg,xreg]=meshgrid(yregstart:(yregstop-yregstart)/yceil:yregstop+1/yceil, xregstart:(xregstop-xregstart)/xceil:xregstop+1/xceil);
    ic_proc=[ 1:size(xreg,1) ];
    jc_proc=[ 1:size(xreg,2) ];    
    MSEA=inf*ones(size(xreg));
    for ic=ic_proc
        for jc=jc_proc
            xc=xreg(ic,jc);
            yc=yreg(ic,jc);
%            hold on; plot(yc,xc,'r.');
            
            [RRfin,ss]=calibrate(Xt, Yt, Xp_abs, Yp_abs, xc, yc, taylor_order, ima_proc);
            if RRfin==0
                MSEA(ic,jc)=inf;
                continue;
            end
            MSE=reprojectpoints_fun(Xt, Yt, Xp_abs, Yp_abs, xc, yc, RRfin, ss, ima_proc, width, height);
            if ic>1 & jc>1
                if MSE>MSEA(ic-1,jc)
                    jc_proc(find(jc_proc==jc))=inf;
                    jc_proc=sort(jc_proc);
                    jc_proc=jc_proc(1:end-1);
                    continue;
                elseif MSE>MSEA(ic,jc-1)
                    break;
                elseif MSE==NaN
                    break;
                end
            end
            MSEA(ic,jc)=MSE;
        end
    end
%    drawnow;
    indMSE=find(min(MSEA(:))==MSEA);
    xc=xreg(indMSE(1));
    yc=yreg(indMSE(1));
    dx_reg=abs((xregstop-xregstart)/xceil);
    dy_reg=abs((yregstop-yregstart)/yceil);
    xregstart=xc-dx_reg;
    xregstop =xc+dx_reg;
    yregstart=yc-dy_reg;
    yregstop =yc+dy_reg;
    fprintf(1,'%d...',glc);
end

fprintf(1,'\n');
[RRfin,ss]=calibrate(Xt, Yt, Xp_abs, Yp_abs, xc, yc, taylor_order, ima_proc);
reprojectpoints;
xc_default=xc;
yc_default=yc;
xc
yc

calibrated = 1; %This flag is 1 when the camera has been calibrated

ocam_model.ss=ss;
ocam_model.xc=xc;
ocam_model.yc=yc;
ocam_model.c=c;
ocam_model.d=d;
ocam_model.e=e;
ocam_model.width=width;
ocam_model.height=height;
