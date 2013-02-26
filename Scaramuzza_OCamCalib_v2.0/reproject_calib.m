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

%%%%%%%%%%%%%%%%%%%% REPROJECT ON THE IMAGES %%%%%%%%%%%%%%%%%%%%%%%%

if ~exist('n_ima') | calibrated==0,
   fprintf(1,'\nNo calibration data available. You must first calibrate you camera.\nClick on "Calibration" or "Find center"\n\n');
   return;
end;

if ~exist('no_image'),
   no_image = 0;
end;

if ~exist('nx')&~exist('ny'),
   fprintf(1,'WARNING: No image size (nx,ny) available. Setting nx=640 and ny=480\n');
   nx = 640;
   ny = 480;
end;


check_active_images;


% Color code for each image:

colors = 'brgkcm';

% Reproject the patterns on the images, and compute the pixel errors:

% Reload the images if necessary
if n_ima ~= 0,
if ~exist('ss'),
   fprintf(1,'Need to calibrate before showing image reprojection. Maybe need to load Calib_Results.mat file.\n');
   return;
end;
end;

if n_ima ~= 0,
if ~no_image,
	if ~exist(['I_' num2str(ind_active(1)) ]'),
	   n_ima_save = n_ima;
	   active_images_save = active_images;
	   ima_read_calib;
	   n_ima = n_ima_save;
	   active_images = active_images_save;
	   check_active_images;
   	if no_image_file,
	   fprintf(1,'WARNING: Do not show the original images\n'); %return;
   	end;
   end;
else
   no_image_file = 1;
end;
end;


if ~exist('dont_ask'),
   dont_ask = 0;
end;

if (exist('c') & exist('d') & exist('e'))==0
    c=1;
    d=0;
    e=0;
end

for kk = ima_proc,            
    
            if exist(['I_' num2str(kk)]),
                eval(['I = I_' num2str(kk) ';']);
            else
                I = 255*ones(ny,nx);
            end;

            xx = RRfin(:,:,kk)*[Xt';Yt';ones(size(Xt'))];       
            m = world2cam(xx, ocam_model);
            xp = m(1,:);
            yp = m(2,:);
            figure(5+kk);
            image(I); hold on;
            colormap(gray(256));
            hold on;
            title(['Image ' num2str(kk) ' - Image points (+) and reprojected grid points (o)']);            
            plot(Yp_abs(:,:,kk), Xp_abs(:,:,kk),'r+');             
            plot(yp, xp, [num2str(colors(rem(kk-1,6)+1)) 'o']);
            plot(yc,xc,'ro'); %plot the image center
            axis([1 nx 1 ny]);
            drawnow;
            set(5+kk,'color',[1 1 1]);
            set(5+kk,'Name',['Image ' num2str(kk)],'NumberTitle','off');
            draw_axes(Xp_abs(:,:,kk), Yp_abs(:,:,kk),n_sq_y); %draws axes and origin on the image
            hold off;
            zoom on;
            
end;
        
        
            