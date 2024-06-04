function [cbar,mbtime]=Plot3DTerm(mb)

load '/Users/ovall/Documents/Rutgers/Research/FromNicoleAbib/Sep2018_rotatedice_dy5_dz5'
load TerminusOrigin
load bathy_2018sep_2m.mat
load ColorPalette

%***NOTE***
% This function calls the shadem() function for hillshade, which can be found at https://www.mathworks.com/matlabcentral/fileexchange/49065-shadem

mbtime=datetime(td(mb),'ConvertFrom','datenum');
xlimits=[-400 -30];
ylimits=[0 750];

%redefine bathymetry coordinates (map coords)
botx=bathy.x-xorig;
boty=bathy.y-yorig;
botz=-bathy.z;

%clip bathymetry to near-glacier region
si=size(botx);
ii=inpolygon(botx,boty,[xlimits(1) xlimits(2) xlimits(2) xlimits(1)],[ylimits(1) ylimits(1) ylimits(2) ylimits(2)]);
nn=NaN(si);
nn(ii)=1;
botx=botx.*nn; 
boty=boty.*nn;
botz=botz.*nn;

%create vertical surfaces to enclose bathymetry (to make seafloor look solid)
[r,c]=find(~isnan(nn));
rr=unique(r)'; cc=unique(c);
for i=1:length(rr)
    rc=min(c(r==rr(i)));
    zW(i)=botz(rr(i),rc);
end
zW=zW(9:end); %trimming some odd edges
xW=ones(size(zW))*xlimits(1);
yW=linspace(ylimits(1),ylimits(2),length(zW));

for i=1:length(cc)
    cr=max(r(c==cc(i)));
    zN(i)=botz(cr,cc(i));
end
zN=zN(15:end); zN(94:110)=linspace(zN(93),zN(111),17); %trim an odd edge and fill a gap
xN=linspace(xlimits(1),xlimits(2),length(zN));
yN=ones(size(zN))*ylimits(2);
zWlower=ones(size(zW))*-200;
zNlower=ones(size(zN))*-200;

%find rotated x location of ice at estimated SGD outlet and peak melt (These are in Nicole's coords)
ymelt_bot=280:5:300; ymelt_top=300:5:360; yshreve=210:5:270; %rough estimate of along-terminus location
[toprow,~]=find(ZQ==-30,1); %index for row of data at -30m
[botrow,~]=find(ZQ==-165,1); %index for row of data at -165m
melloc_bot=find(YQ(botrow,:)==ymelt_bot(1)):find(YQ(botrow,:)==ymelt_bot(end)); %indices for columns of data that line up with high melt at bottom
melloc_top=find(YQ(toprow,:)==ymelt_top(1)):find(YQ(toprow,:)==ymelt_top(end)); %indices for columns of data that line up with high melt at top
sgdloc=find(YQ(botrow,:)==yshreve(1)):find(YQ(botrow,:)==yshreve(end)); %indices for columns of data that line up with sgd outlet

%rotate to map coordinates
[xx,yy]=IceFjordRotation(sub(mb).vq,YQ);
[melt_bot_xx,melt_bot_yy]=IceFjordRotation(sub(mb).vq(botrow,melloc_bot),ymelt_bot);
[melt_top_xx,melt_top_yy]=IceFjordRotation(sub(mb).vq(toprow,melloc_top),ymelt_top);
[sgd_xx,sgd_yy]=IceFjordRotation(sub(mb).vq(botrow,sgdloc),yshreve);

% Make asthetic tweak to bathymetry (there are a couple other scans that need something similar done)
if mb==6
    % a small section of bathy sits above ice
    botz(1443:1462,1506:1518)=botz(1443:1462,1506:1518)-9; 
end

%% plot 3D map
%setting up manual colormap for bathymetry
bathmap=MonoGrad([1 1 .95],[.7 .6 .5],round(max(-botz,[],'all')));  
bathcol=NaN(si(1),si(2),3);
for i=1:si(1)
    for j=1:si(2)
        if ~isnan(botz(i,j))
            bathcol(i,j,:)=bathmap(round(-botz(i,j)),:);
        end
    end
end
bathcolW=permute(repmat(bathmap(end,:),length(zW),1,2),[3 1 2]);
bathcolN=permute(repmat(bathmap(end,:),length(zN),1,2),[3 1 2]);

bottom=surf(botx,boty,botz,bathcol,'EdgeColor','none','DisplayName','Bathymetry');
hold on
surf([xW;xW],[yW;yW],[zW;zWlower],bathcolW)
surf([xN;xN],[yN;yN],[zN;zNlower],bathcolN)
ice=surf(xx,yy,ZQ,xx,'EdgeColor','none');
% plot3(melt_bot_xx,melt_bot_yy,-165*ones(length(ymelt_bot)),'r','LineWidth',5)
% melt=plot3(melt_top_xx,melt_top_yy,-30*ones(length(ymelt_top)),'r','LineWidth',5,'DisplayName','Region of Highest Melt');
% outlet=plot3(sgd_xx,sgd_yy,-165*ones(length(yshreve)),'Color',docol,'LineWidth',5,'DisplayName','Estimated Discharge Outlet');
axis equal
colormap(anom_cmap(100:-1:1,:))
cbar=colorbar;
ylabel(cbar,'Up-Fjord Distance (m)','FontSize',14)
xlim(xlimits)
ylim(ylimits)
% [lighth,MatType,gain,LightType,LightAng]=shadem([-60,20]);
set(gca,'Color',[.8 .8 .8])
% cbar.Position=[.93 .275 .011 .5];
view(-100,15)

shading flat

