for i=1:Nframes

    figure; imagesc(aa(:,:,:,i)); axis equal;
    hold on; plot(Yp(:,:,i)+yc, Xp(:,:,i)+xc,'r.','MarkerSize',2);
end
