wintx=8;
winty=8;
n_calib_points=4;
fig_ipolar=figure; imagesc(im_cam); colormap(gray);
x=[];
y=[];
for i=1:4
    pause;
    [xi,yi] = ginput3(1);
    [xxi] = cornerfinder([xi;yi],Ipolar,winty,wintx);
    xi = xxi(1);
    yi = xxi(2);
    figure(fig_ipolar);
    hold on; plot(xi,yi,'+','color',[ 1.000 0.314 0.510 ],'linewidth',2); hold off;
    drawnow;
    x = [x;xi];
    y = [y;yi];
end
