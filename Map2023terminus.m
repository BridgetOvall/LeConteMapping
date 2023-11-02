% This script maps the head of LeConte Bay with bathymetry and satellite image from 2018 and
% plots terminus lines from 2023 fieldwork, shading in the region between 2023 and 2018 termini
% 
% Required: m_map package for converting from lat/lon to UTM
% Calls: Map_2018background

clear
basepath='/Users/ovall/Library/CloudStorage/GoogleDrive-bovall@marine.rutgers.edu/Shared drives/Ice-ocean-interactions/fieldwork_docs_and_data/Leconte2309/data/processed/';
dronefiles=dir([basepath 'Drone/Mavic3E/terminusPosition/' 'leconte_2023*.mat']);

%establish zone and map projection for converting from lat/lon to UTM
m_proj('UTM','ellipsoid','wgs84','zone',8)

figure('Position',[10 10 800 1000])
[lx,ly]=Map_2018background; %input x and y limits to override defaults
for i=2:length(dronefiles) %first file contains no data
    termfile=fullfile(dronefiles(i).folder,dronefiles(i).name);
    term=load(termfile);
    [X,Y]=m_ll2xy(term.lon,term.lat,'clip','off');
    if i==2
        px=lx(lx>max(X))'; px=[px X(~isnan(X))];
        py=ly(lx>max(X))'; py=[py Y(~isnan(Y))];
        patch(px,py,'w','FaceAlpha',.5,'EdgeColor','w','LineWidth',2)
    end
    plot(X,Y,'b','LineWidth',2)
end
ylabel('Northing')
xlabel('Easting')
