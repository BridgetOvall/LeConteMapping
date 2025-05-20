function [h,ax1,ax2]=MapXeitlSit(details)

arguments
    details.Year (1,1) double=2024 %year to pull data for
    details.Coord {mustBeMember(details.Coord,["xy","ll"])}="xy" %choose X-Y or lat-lon coordinates, cannot use default limits for lat-lon
    details.EWlim (1,2) double=[-1400 -100]  %map limits
    details.NSlim (1,2) double=[-600 950]
    details.Term (1,1) {mustBeFloat}=10 %choose a terminus line to plot
    details.Bathy {mustBeMember(details.Bathy,["line","fill","none"])}="line" %choose how to plot bathymetry
    details.ContourStep (1,1) {mustBeFloat}=15 %bathymetry contour intervals
    details.GL (1,1) {mustBeFloat} %choose a multibeam scan to plot as a grounding line (default no gl plotted)
    details.DO (1,1) {mustBeNumericOrLogical}=true %mark a discharge outlet 
    details.Sat (1,:) {mustBeNumericOrLogical}=true %include satellite image in map
    details.fs (1,1) double=16 %font size
end

currentDir=pwd;
folder2018='/Users/ovall/Documents/Rutgers/Research/LeConteData2018';
folder2024='/Users/ovall/Documents/Rutgers/Research/LeConteData2024';

if details.Year==2018
    cd(folder2018)
    load bathy_2018sep_2m
    load bathybounds
    load terminus_dem_orthos_v2_sept2018
    load TerminusOrigin
    load GroundingLine
    sat=imread('WV02_20180921_1030010084C82200_1030010086938300_058654773010_01_P001_058654774010_01_P001_2_ortho_UTM.tif');
    cd(currentDir)
    DO=[250 250 310 310]; %(Nicole's estimate of discharge outlet position from Shreve analysis)
elseif details.Year==2024
    cd(folder2024)
    load bathy_2024jul_4m
    load TerminusOrigin2024
    load terminus_lines.mat
    S=term; %to make variable names consistent between years
    %use old satellite data for now
    sat=imread([folder2018 '/WV02_20180921_1030010084C82200_1030010086938300_058654773010_01_P001_058654774010_01_P001_2_ortho_UTM.tif']);
    load([folder2018 '/bathybounds.mat'])
    cd(currentDir)
    DO=[]; %currently no estimate of discharge outlet position
end

glcol=[0 .3 .9]; %grounding line color
termcol=[0 .4 .9]; %terminus line color
bathmap=MonoGrad([1 1 .95],[.7 .6 .5],round(max(bathy.z,[],'all','omitnan'))); %colormap for filled bathymetry
if strcmp(details.Bathy,'fill')
    watercol=[.8 .8 .8]; %color for water where there is no bathymetry to fill
else
    watercol=[.8 .9 .95]; %color for water when drawing contour lines
end

ax1=gca;
h=[]; %handles to be returned
if strcmp(details.Coord,"xy")
    %redefine bathymetry in terms of new origin
    batx=bathy.x-xorig;
    baty=bathy.y-yorig;
    %redefine terminus in terms of new origin
    termx=S(details.Term).X-xorig;
    termy=S(details.Term).Y-yorig;
    si=size(termx);
    if si(1)>1
        termx=termx';
        termy=termy';
    end
    
    if details.Sat %satellite image as background
        [sx,sy,srange]=ScaleSat; %scale 2018 satellite image to map
        imagesc(sx,sy,sat(end:-1:1,:),srange)
        set(ax1,'Ydir','normal')
        colormap(ax1,'gray')
        hold on
    elseif details.EWlim(2)<0 %patch behind terminus for background
        ii=find(termy>=details.NSlim(1) & termy<=details.NSlim(2));
        miny=min(termy); maxy=max(termy);
        patch([termx(ii) 0 0],[termy(ii) maxy miny],'w','EdgeColor','none')
    end
    set(ax1,'Color',watercol,'FontSize',details.fs)
    ylabel('Northing (m)')
    xlabel('Easting (m)')
    axis equal
    xlim(details.EWlim)
    ylim(details.NSlim)

    ax2=axes('Position',ax1.Position);
    hold on
    %if using satellite image, grey out places where we don't know bathy
    if details.Sat 
        patch(lx,ly,[.8 .8 .8],'EdgeColor',[.8 .8 .8],'EdgeAlpha',.8,'LineWidth',5,'LineJoin','round');
        patch(bx,by,watercol,'EdgeColor',watercol,'EdgeAlpha',.8,'LineWidth',5,'LineJoin','round');
    end

    %add bathymetry
    if strcmp(details.Bathy,'line')
        contour(batx,baty,bathy.z,details.ContourStep:details.ContourStep:400,'color',[.5 .5 .5])
    elseif strcmp(details.Bathy,'fill')
        contourf(batx,baty,bathy.z,details.ContourStep:details.ContourStep:400,'LineStyle','none');
    end
    colormap(ax2,bathmap)
    axis equal
    xlim(details.EWlim)
    ylim(details.NSlim)
    xticklabels([])
    yticklabels([])
    ax2.Visible='off';

    %add grounding line
    if isfield(details,'GL')
        gl=plot(gx(details.GL,:),gy(details.GL,:),':','Color',glcol,'LineWidth',3,'DisplayName','Grounding Line');
        h=[h gl];
    end

    %add subaerial terminus
    th=plot(termx,termy,'Color',termcol,'LineWidth',3,'DisplayName','Subaerial Terminus');
    h=[th h];
    %patch behind terminus when using 2018 satellite image
    if details.Sat && details.Year==2024 
        ii=find(termy>=details.NSlim(1) & termy<=details.NSlim(2));
        miny=min(termy); maxy=max(termy);
        patch([termx(ii) 0 0],[termy(ii) maxy miny],'w','EdgeColor','none')
    end

    %add discharge outlet location
    if details.DO & ~isempty(DO)
        if details.EWlim(2)<0
            right=details.EWlim(2);
            width=10;
            left=details.EWlim(2)-width;
            lw=5;
        elseif details.EWlim(2)>=0 && details.EWlim(2)<100
            right=details.EWlim(2);
            width=20;
            left=details.EWlim(2)-width;
            lw=6;
        elseif details.EWlim(2)>=100
            right=-20; left=-50;
            lw=8;
        end
        do=patch([left right right left],DO,[.9 .5 0],'EdgeColor','none','DisplayName','Est. Discharge Outlet');
        h=[h do];
    end

    linkaxes([ax1 ax2])

elseif strcmp(details.Coord,"ll")
    m_proj('Mercator','longitudes',details.EWlim','latitudes',details.NSlim)
    m_grid('FontSize',fs,'BackgroundColor',[.8 .9 .95])
    hold on
    m_contour(bathy.lon,bathy.lat,bathy.z,details.ContourStep:details.ContourStep:400,'Color',[.5 .5 .5])
    m_plot(S(details.Term).lon,S(details.Term).lat,'Color',termcol,'LineWidth',2)
end


end
%% Local functions
function [sx,sy,srange]=ScaleSat
    yr=4400; yi=1000; yend=7461;
    xr=3920; xi=-2000; xend=9679;
    m=2;
    y0=yi+m*yr;
    y1=y0-m;
    yf=-m*yend+y0;
    x0=xi-m*xr;
    x1=x0+m;
    xf=m*xend+x0;
    sx=x1:xf;
    sy=yf:y1;
    srange=[-5000 20000];
end