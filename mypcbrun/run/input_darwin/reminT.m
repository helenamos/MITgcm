% impose a temperature variation for remin rate
clear all;
close all;
addpath('~/work');

% load temperature
tdir='/home/yxzhang/MITgcm/mydarwinrun/input/DDtheta/';
T=zeros(360,160,23,12);
for month=1:12
 month
 for ttime=78936+(month-1)*720:24:79632+(month-1)*720
  temp=rdbin(strcat(tdir,'DDtheta.00000',num2str(ttime),'.data'),[360 160 23]);
  T(:,:,:,month)=T(:,:,:,month)+temp;
 end
end
T=T/30;

          Tkel=273.15;
          TempAe=-4000.;
          Tempref=293.15;
reminTempFunction=exp(TempAe*(1./(T+Tkel) -1/(Tempref) ) );

% load original fremin data
data=rdbin('fremin.10years.sixspecies.incdoc.ecco.1x1.bin',[360 160 23 12]);

newdata=data.*reminTempFunction;
wtbin('fremin_new.10years.sixspecies.incdoc.ecco.1x1.bin',newdata,'real4');
