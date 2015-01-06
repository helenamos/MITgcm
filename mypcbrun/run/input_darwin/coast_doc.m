clear;
addpath('~/work');
doc=rdbin('doc.10years.sixspecies.ecco.1x1.bin',[360 160 23 12]);
wet=rdbin('../run.10.18.2013-hg2only-parteq/hFacC.data',[360 160 23]);

docnew=doc;
for i=1:360
for j=1:160
  if wet(i,j,1) > 0.5
     ngrid=0;
     nwet=0;
     for ii=i-5:i+5
         iii=ii;
         if iii < 1
           iii=iii+360;
         end
         if iii > 360
           iii=iii-360;
         end
     for jj=j-5:j+5
         jjj=jj;
         if jjj > 160
            jjj = 160;
         end
         if jjj < 1
            jjj = 1;
         end
         if sqrt((iii-i)^2+(jjj-j)^2) <= 1.5
            ngrid=ngrid+1;
            nwet=nwet+wet(iii,jjj,1);
         end
     end
     end
  if ngrid ~= nwet
     for k=1:23
        if wet(i,j,k) > 0.5
          docnew(i,j,k,:)=500;
        end
     end
  end
end
end
end

subplot(1,2,1),draw(doc(:,:,1)),caxis([0,50]);
subplot(1,2,2),draw(docnew(:,:,1)),caxis([0,50]);

wtbin('doc.coast1d500.10years.sixspecies.ecco.1x1.bin',docnew);
