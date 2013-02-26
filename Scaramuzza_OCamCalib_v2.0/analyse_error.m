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

figure(5);
set(5,'Name','Analyse error','NumberTitle','off');
zoom on;

colors = 'brgkcm';
m=[];
xx=[];
err=[];
stderr=[];
rhos=[];
num_points=size(Xp_abs,1);
MSE=0;
count=0;
if (exist('c') & exist('d') & exist('e'))==0
    c=1;
    d=0;
    e=0;
end
for i=ima_proc
    count=count+1;
    xx=RRfin(:,:,i)*[Xt';Yt';ones(size(Xt'))];
    [xp,yp]=omni3d2pixel(ss,xx,width,height); %convert 3D coordinates in 2D pixel coordinates    
    xp=xp*c + yp*d + xc;
    yp=xp*e + yp + yc;    
    sqerr= (Xp_abs(:,:,i)-xp').^2+(Yp_abs(:,:,i)-yp').^2;
    err(count)=mean(sqrt(sqerr));
    stderr(count)=std(sqrt(sqerr));
    MSE=MSE+sum(sqerr);
    plot(Xp_abs(:,:,i)-xp', Yp_abs(:,:,i)-yp',[num2str(colors(rem(i-1,6)+1)) '+']); hold on;
end
hold off;
grid on;

fprintf(1,'\n Average reprojection error computed for each chessboard [pixels]:\n\n');
for i=1:length(err)
    fprintf(' %3.2f ± %3.2f\n',err(i),stderr(i));
end

fprintf(1,'\n Average error [pixels]\n\n %f\n',mean(err));
fprintf(1,'\n Sum of squared errors\n\n %f\n',MSE);
