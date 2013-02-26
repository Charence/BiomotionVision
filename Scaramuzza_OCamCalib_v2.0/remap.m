[xpo,ypo,zpo]=select_rand_points(xp(1:15),yp(1:15),zp(1:15),10);

Xpo=[xpo';ypo';zpo'];
[x_color,y_color]=omni3d2pixel(ss,Xpo);
x_color=round(x_color+xc)';
y_color=round(y_color+yc)';
figure; imagesc(img1); colormap(gray); hold on; plot(y_color,x_color,'r.'); hold on; plot(y_color,x_color,'b.');

ind=(x_color-1)*width+y_color;

color=double([img1(ind),img1(ind),img1(ind)])/255;

plot3Dcolorpoint(xpo,ypo,zpo,color,5);
hold on; plot3(xp,yp,zp,'ro'); grid; axis equal; hold on; plot3(xp,yp,zp); axis equal; grid; grid;
