
if ~exist('n_ima'),
   fprintf(1,'No calibration data available.\n');
   return;
end;

if ~exist('no_image'),
    no_image = 0;
end;

check_active_images;

save_name = 'Omni_Calib_Results';

if exist([ save_name '.mat'])==2,
    disp('WARNING: File Omni_Calib_Results.mat already exists');
    if exist('copyfile')
        pfn = -1;
        cont = 1;
        while cont,
            pfn = pfn + 1;
            postfix = ['_old' num2str(pfn)];
            save_name = [ 'Omni_Calib_Results' postfix];
            cont = (exist([ save_name '.mat'])==2);
        end;
        copyfile('Omni_Calib_Results.mat',[save_name '.mat']);
        disp(['Copying the current Omni_Calib_Results.mat file to ' save_name '.mat']);
        if exist('Omni_Calib_Results.m')==2,
            copyfile('Omni_Calib_Results.m',[save_name '.m']);
            disp(['Copying the current Omni_Calib_Results.m file to ' save_name '.m']);
        end;
        cont_save = 1;
    else
        disp('The file Omni_Calib_Results.mat is about to be changed.');
        cont_save = input('Do you want to continue? ([]=no,other=yes) ','s');
        cont_save = ~isempty(cont_save);
    end;
else
    cont_save = 1;
end;


if cont_save,

    if exist('calib_name'),
        fprintf(1,['\nSaving calibration results under ' save_name '.mat, please wait ...\n']);  
    end;
    
    save_name = 'Omni_Calib_Results';
    string_save = ['save ' save_name];
    eval(string_save);

    fprintf(1,'done\n');
    
end;
