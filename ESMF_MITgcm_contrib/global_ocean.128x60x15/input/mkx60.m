%fni='bathymetry.bin'; nr=1;
%fni='lev_clim_temp.bin'; nr=15;
%fni='lev_clim_salt.bin'; nr=15;
%fni='ncep_taux.bin';nr=12;
%fni='ncep_tauy.bin';nr=12;
%fni='lev_monthly_temp.bin';nr=12;
%fni='lev_monthly_salt.bin';nr=12;

nx=128;nyi=64;cropy=2;
fid=fopen(fni,'r','ieee-be');
phi=fread(fid,nx*nyi*nr,'float32');
fclose(fid);
phi=reshape(phi,[nx nyi nr]);
phio=phi(:,1+cropy:end-cropy,:);
fno=sprintf('%s_06',fni);
fid=fopen(fno,'w','ieee-be');
fwrite(fid,phio,'float32');
fclose(fid);
