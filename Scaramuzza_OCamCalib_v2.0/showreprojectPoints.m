xx=[];
err=[];
stderr=[];

for i=ima_proc
    xx=RRfin(:,:,i)*[Xt';Yt';ones(size(Xt'))];
    [Xp_reprojected,Yp_reprojected]=omni3d2pixel(ss,xx); %convert 3D coordinates in 2D pixel coordinates

    figure; imagesc(aa(:,:,:,i)); hold on; plot(Yp_abs(:,:,i), Xp_abs(:,:,i),'r+'); hold on; plot(Yp_reprojected+yc, Xp_reprojected+xc,'bo'); colormap(gray);
%plot(Yp_abs(:,:,i),Xp_abs(:,:,i),'bo');
    
    stt= sqrt( (Xp_abs(:,:,i)-xc-Xp_reprojected').^2 + (Yp_abs(:,:,i)-yc-Yp_reprojected').^2 ) ;
    err(i)=(mean(stt));
    stderr(i)=std(stt);
end

for i=1:length(err)
%    fprintf('%3.2f ± %3.2f\n',err(i),stderr(i));
end
%err'
mean(err);