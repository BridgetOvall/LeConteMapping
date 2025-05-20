function grad=MonoGrad(light_color,dark_color,len)%len is # of colors to make
if isa(light_color,'char')
    light=rgb(light_color);
else
    light=light_color;
end
if isa(dark_color,'char')
    dark=rgb(dark_color);
else
    dark=dark_color;
end
r=linspace(light(1),dark(1),len);
g=linspace(light(2),dark(2),len);
b=linspace(light(3),dark(3),len);
grad=[r' g' b'];
end