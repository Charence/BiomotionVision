function [xpo,ypo,zpo]=select_rand_points(xp,yp,zp,N)

num_points=length(xp);
num_points2=length(xp)*2;
for i=1:N
    ind1=round((num_points-1)*rand(num_points2-1,1))+1;
    ind2=round((num_points-1)*rand(num_points2-1,1))+1;
    xp=[xp;(xp(ind1)+xp(ind2))*.5];
    yp=[yp;(yp(ind1)+yp(ind2))*.5];
    zp=[zp;(zp(ind1)+zp(ind2))*.5];        
    num_points2=length(xp)*2;
end
xpo=xp;
ypo=yp;
zpo=zp;
