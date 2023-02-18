function [xout,yout]=IceFjordRotation(xin,yin,dir)
%This function rotates a set of coordinates from ice coordinates (used by Nicole Abib in her 2018 ice melt analysis) to 
%fjord coordinates (used by Bridget Ovall in her 2018 kayak analysis)
%
%Fjord coordinates are standard N-S-E-W directions with an origin roughly coinciding with the southern end of the glacier terminus.
%Ice coordinates are rotated so that the y-direction is roughly parallel to the glacier terminus and the origin is behind the south 
%end of the glacier terminus

arguments
    xin double
    yin double
    dir {mustBeMember(dir,["I2F","F2I"])}="I2F" %rotate coordinates from ice-to-fjord or fjord-to-ice
end

load TerminusOrigin
if strcmp(dir,"I2F")
    rotmat=[cosd(N_ang) -sind(N_ang); sind(N_ang) cosd(N_ang)];
    if length(xin)==1 && length(yin)==1
        rot=[xin,yin]*rotmat;
        xout=rot(1)+N_xorig-xorig;
        yout=rot(2)+N_yorig-yorig;
    elseif length(xin)>1 && length(yin)>1
        sz=size(xin);
        len=sz(1)*sz(2);
        X=reshape(xin,[len,1]);
        Y=reshape(yin,[len,1]);
        XYrot=[X,Y]*rotmat;
        xout=XYrot(:,1)+N_xorig-xorig;
        xout=reshape(xout,sz);
        yout=XYrot(:,2)+N_yorig-yorig;
        yout=reshape(yout,sz);
    end
elseif strcmp(dir,"F2I")
    rotmat=[cosd(-N_ang) -sind(-N_ang); sind(-N_ang) cosd(-N_ang)];
    if length(xin)==1 && length(yin)==1
        xtran=xin-N_xorig+xorig;
        ytran=yin-N_yorig+yorig;
        rot=[xtran,ytran]*rotmat;
        xout=rot(1);
        yout=rot(2);
    elseif length(xin)>1 && length(yin)>1
        sz=size(xin);
        len=sz(1)*sz(2);
        X=reshape(xin,[len,1]);
        Y=reshape(yin,[len,1]);
        Xtran=X-N_xorig+xorig;
        Ytran=Y-N_yorig+yorig;
        XYrot=[Xtran,Ytran]*rotmat;
        xout=XYrot(:,1);
        xout=reshape(xout,sz);
        yout=XYrot(:,2);
        yout=reshape(yout,sz);
    end

end
