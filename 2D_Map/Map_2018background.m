function [lX,lY]=Map_2018background(xlimits,ylimits)
    arguments
        xlimits (1,2) double=[659600 661500]    %east-west limits in UTM
        ylimits (1,2) double=[6300600 6303000]  %north-south limits in UTM
    end

    % This function maps 2018 satellite image and bathymetry into the current figure
    % 
    % Required: Matlab 2019b or later
    % File path to satellite image on next line will need to be corrected
    
    sat=imread('/Users/ovall/Dropbox/LeConte/satellite_imagery/Worldview/WV02_20180921_1030010084C82200_1030010086938300_058654773010_01_P001_058654774010_01_P001_2_ortho_UTM.tif');
    load bathy_2018sep_2m
    load bathybounds

    %scaling for satellite image
    yr=4400; yi=6302938.85; yend=7461;
    xr=3920; xi=659423.22; xend=9679;
    m=2;
    y0=yi+m*yr;
    y1=y0-m;
    yf=-m*yend+y0;
    x0=xi-m*xr;
    x1=x0+m;
    xf=m*xend+x0;
    
    %plot satellite image
    imagesc(x1:xf,yf:y1,sat(end:-1:1,:),[-5000 20000])
    set(gca,'Ydir','normal')
    colormap(gca,'gray')
    hold on
    patch(lX,lY,[.8 .8 .8],'EdgeColor',[.8 .8 .8],'EdgeAlpha',.8,'LineWidth',5,'LineJoin','round');
    patch(bX,bY,[.8,.9,.95],'EdgeColor',[.8,.9,.95],'EdgeAlpha',.8,'LineWidth',5,'LineJoin','round');

    %plot 2018 bathymetry
    contour(bathy.x,bathy.y,bathy.z,15:15:400,'color',[.7 .7 .7])

    set(gca,'FontSize',16)
    axis equal
    xlim(xlimits)
    ylim(ylimits)
end  
