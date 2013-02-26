%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
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

var2fix = 'dX_default';

fixvariable;

var2fix = 'dY_default';

fixvariable;

var2fix = 'map';

fixvariable;

calibrated = 0; %this flag is - when the camera has not yet been calibrated

if ~exist('n_ima'),
    data_calib;
end;

check_active_images;

if ~exist(['I_' num2str(ind_active(1))]),
    ima_read_calib;
    if isempty(ind_read),
        disp('Cannot extract corners without images');
        return;
    end;
end;


fprintf(1,'\nExtraction of the grid corners on the images\n');


if (exist('map')~=1), map = gray(256); end;


%disp('WARNING!!! Do not forget to change dX_default and dY_default in click_calib.m!!!')

if exist('dX'),
    dX_default = dX;
end;

if exist('dY'),
    dY_default = dY;
end;

if exist('n_sq_x'),
    n_sq_x_default = n_sq_x;
end;

if exist('n_sq_y'),
    n_sq_y_default = n_sq_y;
end;

if exist('taylor_order'),
    taylor_order_default = taylor_order;
end;


if ~exist('dX_default')|~exist('dY_default');
    dX_default = 30;
    dY_default = 30;
end;

if ~exist('n_sq_x_default')|~exist('n_sq_y_default'),
    n_sq_x_default = 10;
    n_sq_y_default = 10;
end;

if ~exist('wintx_default')|~exist('winty_default'),
    wintx_default = max(round(nx/128),round(ny/96));
    winty_default = wintx_default;
    clear wintx winty
end;

if ~exist('xc_default'),
    xc_default = round(ny/2);
end;

if ~exist('yc_default'),
    yc_default = round(nx/2);
end;

if ~exist('taylor_order')
    taylor_order_default=4;
end;

if ~exist('wintx') | ~exist('winty'),
    clear_windows; % Clear all the window sizes (to re-initiate)
end;



if ~exist('dont_ask'),
    dont_ask = 0;
end;

if ~exist('ima_proc'),
    ima_proc=[];
end;


if ~isempty(ima_proc)
    fprintf(1,'\nCurrently, corners have been axtracted for the following image(s): %s\n',num2str(ima_proc));
    suppress_image = input('  Do you want to suppress the current image(s) ([] = no, other = yes)? ','s');
    if isempty(suppress_image),
        ima_numbers = input('Type a vector containing the Images to add (e.g. [1 2 3]) = ');
        for i=ima_numbers
            if ~isempty(find(ima_proc==i)),
                fprintf(1,'\nYou have already extracted corners from image %d',i);
                replace_image = input(', are you sure you want to replace this image ([] = yes, other = no)?\n','s');                
                if isempty(replace_image)
                    ima_proc=ima_proc(find( ima_proc~=i));
                else
                    ima_numbers(find(ima_numbers==i))=0;
                end
            end
        end
        ima_numbers= ima_numbers(find(ima_numbers~=0));
    else
        ima_proc=[];
        ima_numbers=[];
        answer = input('\nType the images you want to process (e.g. [1 2 3], [] = all images) = ');
        if isempty(answer)
            ima_numbers = 1:n_ima;
        else
            ima_numbers=answer;
        end
    end;
else
    answer=input('\nType the images you want to process (e.g. [1 2 3], [] = all images) = ');
    if isempty(answer)
        ima_numbers = 1:n_ima;
    else
        ima_numbers=answer;
    end
end;


%% TO DO!
% if ~dont_ask,
%     fprintf(1,'Do you want to use the automatic square counting mechanism (0=[]=default)\n');
%     manual_squares = input('  or do you always want to enter the number of squares manually (1,other)? ');
%     if isempty(manual_squares),
%         manual_squares = 0;
%     else
%         manual_squares = ~~manual_squares;
%     end;
% else
%     manual_squares = 0;
% end;
manual_squares=1;

if manual_squares,
    
    n_sq_x = input(['Number of squares along the X direction ([]=' num2str(n_sq_x_default) ') = ']); %6
    if isempty(n_sq_x), n_sq_x = n_sq_x_default; end;
    n_sq_y = input(['Number of squares along the Y direction ([]=' num2str(n_sq_y_default) ') = ']); %6
    if isempty(n_sq_y), n_sq_y = n_sq_y_default; end; 
    
end;

num_points=(n_sq_x+1)*(n_sq_y+1);

n_sq_x_default = n_sq_x;
n_sq_y_default = n_sq_y;


if (exist('dX')~=1)|(exist('dY')~=1), % This question is now asked only once
    % Enter the size of each square
    
    dX = input(['Size dX of each square along the X direction ([]=' num2str(dX_default) 'mm) = ']);
    dY = input(['Size dY of each square along the Y direction ([]=' num2str(dY_default) 'mm) = ']);
    if isempty(dX), dX = dX_default; else dX_default = dX; end;
    if isempty(dY), dY = dY_default; else dY_default = dY; end;
    
else
    
    fprintf(1,['Size of each square along the X direction: dX=' num2str(dX) 'mm\n']);
    fprintf(1,['Size of each square along the Y direction: dY=' num2str(dY) 'mm   (Note: To reset the size of the squares, clear the variables dX and dY)\n']);
    %fprintf(1,'Note: To reset the size of the squares, clear the variables dX and dY\n');
    
end;

square_vert_side=dX; %mm
square_horiz_side=dY; %mm
num_vert_square=n_sq_x;
num_horiz_square=n_sq_y;

xc=input(['X coordinate (along height) of the omnidirectional image center = ([]=' num2str(xc_default) ') = ']);    
yc=input(['Y coordinate (along width) of the omnidirectional image center = ([]=' num2str(yc_default) ') = ']);    
if isempty(xc), xc = xc_default; else xc_default = xc; end;
if isempty(yc), yc = yc_default; else yc_default = yc; end;
% xc=385.48;
% yc=516.36;


fprintf(1,'\nEXTRACTION OF THE GRID CORNERS\n');
fprintf(1,'Do you want to use the automatic corner extraction\n');
answer=input('or do you want to extract all the points manually ( [] = automatic, other = manual )? ','s');

% If you opted for the AUTOMATIC extraction
if isempty(answer)
    use_automatic = 1;
    use_corner_find=0;
else
    use_automatic = 0;
end

fprintf(1,'\n');
% If you opted for the MANUAL extraction
if use_automatic == 0 %IF manual Extraction
    answer=input('Do you want your clicking to be assisted by a corner detector ( [] = yes, other = no )? ','s');
    if isempty(answer)
        use_corner_find=1;
        disp('Window size for corner finder (wintx and winty): ');
        wintx = input(['wintx ([] = ' num2str(wintx_default) ') = ']);
        if isempty(wintx), wintx = wintx_default; end;
        wintx = round(wintx);
        winty = input(['winty ([] = ' num2str(winty_default) ') = ']);
        if isempty(winty), winty = winty_default; end;
        winty = round(winty);
        fprintf(1,'Window size = %dx%d\n',2*wintx+1,2*winty+1);

    else
        use_corner_find=0;
    end
end
        
% 
% Xp_abs=zeros((n_sq_x+1)*(n_sq_y+1),1);
% Yp_abs=zeros((n_sq_x+1)*(n_sq_y+1),1);
% X=zeros((n_sq_x+1)*(n_sq_y+1),1);
% Y=zeros((n_sq_x+1)*(n_sq_y+1),1);
% RRfin=zeros(3,3);


%Arranging the pixel of the world
Xt=[];
Yt=[];
for i=0:n_sq_x
    for j=0:n_sq_y
        Yt=[Yt;j*dY];
        Xt=[Xt;i*dX];
    end
end

%START MARTIN
iter_r = 1; %Used inside "click_ima_calib_rufli"
keepDist=[];
%END MARTIN
for kk = ima_numbers,
    if exist(['I_' num2str(kk)])
        if use_automatic == 0 %IF manual extraction
            click_ima_calib;
        else %IF automatic extraction
            click_ima_calib_rufli;
            %click_ima_calib_vladimir
        end
        active_images(kk) = 1;
        ima_proc= sort([ima_proc, kk]);
    else
        eval(['dX_' num2str(kk) ' = NaN;']);
        eval(['dY_' num2str(kk) ' = NaN;']);  
        
        eval(['wintx_' num2str(kk) ' = NaN;']);
        eval(['winty_' num2str(kk) ' = NaN;']);
        
        eval(['x_' num2str(kk) ' = NaN*ones(2,1);']);
        eval(['X_' num2str(kk) ' = NaN*ones(3,1);']);
        
        eval(['n_sq_x_' num2str(kk) ' = NaN;']);
        eval(['n_sq_y_' num2str(kk) ' = NaN;']);
    end;
end;


check_active_images;



% Fix potential non-existing variables:

for kk = 1:n_ima,
    if ~exist(['x_' num2str(kk)]),
        eval(['dX_' num2str(kk) ' = NaN;']);
        eval(['dY_' num2str(kk) ' = NaN;']);  
        
        eval(['x_' num2str(kk) ' = NaN*ones(2,1);']);
        eval(['X_' num2str(kk) ' = NaN*ones(3,1);']);
        
        eval(['n_sq_x_' num2str(kk) ' = NaN;']);
        eval(['n_sq_y_' num2str(kk) ' = NaN;']);
    end;
    
    if ~exist(['wintx_' num2str(kk)]) | ~exist(['winty_' num2str(kk)]),
        
        eval(['wintx_' num2str(kk) ' = NaN;']);
        eval(['winty_' num2str(kk) ' = NaN;']);
        
    end;
end;

% string_save = 'save calib_data active_images ind_active wintx winty n_ima type_numbering N_slots first_num image_numbers format_image calib_name Hcal Wcal nx ny map dX_default dY_default dX dY wintx_default winty_default';
% 
% for kk = 1:n_ima,
%     string_save = [string_save ' X_' num2str(kk) ' x_' num2str(kk) ' n_sq_x_' num2str(kk) ' n_sq_y_' num2str(kk) ' wintx_' num2str(kk) ' winty_' num2str(kk) ' dX_' num2str(kk) ' dY_' num2str(kk)];
% end;
% 
% eval(string_save);
% 
% disp('done');

return;


