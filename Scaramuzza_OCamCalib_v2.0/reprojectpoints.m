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

m=[];
xx=[];
err=[];
stderr=[];
rhos=[];
num_points=size(Xp_abs,1);
MSE=0;
counterr=0;
for i=ima_proc
    counterr=counterr+1;
    xx=RRfin(:,:,i)*[Xt';Yt';ones(size(Xt'))];
    [Xp_reprojected,Yp_reprojected]=omni3d2pixel(ss,xx,width, height); %convert 3D coordinates in 2D pixel coordinates    
    stt= sqrt( (Xp_abs(:,:,i)-xc-Xp_reprojected').^2 + (Yp_abs(:,:,i)-yc-Yp_reprojected').^2 ) ;
    err(counterr)=(mean(stt));
    stderr(counterr)=std(stt);
    MSE=MSE+sum( (  Xp_abs(:,:,i)-xc-Xp_reprojected').^2 + (Yp_abs(:,:,i)-yc-Yp_reprojected').^2 );
end

fprintf(1,'\n Average reprojection error computed for each chessboard [pixels]:\n\n');
for i=1:length(err)
    fprintf(' %3.2f ± %3.2f\n',err(i),stderr(i));
end
%err'
fprintf(1,'\n Average error [pixels]\n\n %f\n',mean(err));
fprintf(1,'\n Sum of squared errors\n\n %f\n',MSE);