options=optimset('Display','final',...
                 'LargeScale','on', ...
                 'TolX',1e-4,...
                 'TolFun',1e-4,...
                 'DerivativeCheck','off',...
                 'Diagnostics','off',...
                 'Jacobian','off',...
                 'JacobMult',[],... % JacobMult set to [] by default
                 'JacobPattern','sparse(ones(Jrows,Jcols))',...
                 'MaxFunEvals','100*numberOfVariables',...
                 'DiffMaxChange',1e-1,...
                 'DiffMinChange',1e-8,...
                 'PrecondBandWidth',0,...
                 'TypicalX','ones(numberOfVariables,1)',...
                 'MaxPCGIter','max(1,floor(numberOfVariables/2))', ...
                 'TolPCG',0.1,...
                 'MaxIter',10000,...
                 'LineSearchType','quadcubic',...
                 'LevenbergMarquardt','off'); 


M=[Xt,Yt,zeros(size(Xt))]; %Coordinate assolute 3D dei punti di calibrazione nel riferimento della scacchiera
%costruisci vettore di stato
if exist('c') & exist('d') & exist('e')
    x0=[c;d;e];
else
    x0=[1;1;1];
end
for i=ima_proc
    r1=RRfin(:,1,i);
    r2=RRfin(:,2,i);
    rod=rodrigues( [r1,r2,cross(r1,r2)] );
    Tod=RRfin(:,3,i);
    x0=[x0;rod;Tod];
end
ss0=ss;
x0=[x0;xc;yc];
x0=[x0;ones(size(ss0))];
xc0=xc;
yc0=yc;
tic;
[allout,resnorm,residual,exitflag,output] =lsqnonlin(@prova_all,x0,-inf,inf,options,ss0,ima_proc,Xp_abs,Yp_abs,M,width,height);
toc;
xc=allout(end-length(ss)-1);
yc=allout(end-length(ss));
c=allout(1)
d=allout(2)
e=allout(3)
%costruisci vettore ssc
ssc=allout(end-length(ss0)+1:end);
ss=ss0.*ssc;
%costruisci RRfin
count=0;
for i=ima_proc
    Rod=rodrigues( allout(6*count+4:6*count+6) );
    Tod= allout(6*count+7:6*count+9);
    RRfinOpt(:,:,i)=Rod;
    RRfinOpt(:,3,i)=Tod;
    count=count+1;
end

RRfin=RRfinOpt;

ocam_model.ss=ss;
ocam_model.xc=xc;
ocam_model.yc=yc;
ocam_model.c=c;
ocam_model.d=d;
ocam_model.e=e;
ocam_model.width=width;
ocam_model.height=height;

reprojectpoints_adv(ocam_model, RRfin, ima_proc, Xp_abs, Yp_abs, M);
ss
