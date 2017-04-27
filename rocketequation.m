function [] = rocketequation(minitial,mfinal)
%Takes an isp and calculated a predicted rocket path from the ideal rocket
%equation
%% Constants
    g = 9.80655;
%% Initial Launch
    isp = statictest;
    deltaV = isp*g*log(minitial/mfinal);
%% Projectile Stage
    %Forces: gravity, assuming 45 degree start
    yaccel = -g;
    xaccel = 0;
    yvel = (2/sqrt(2))*deltaV;
    xvel = (2/sqrt(2))*deltaV;
    t = linspace(0,15,100);
    instyvel = yvel-g.*t;
    ypos = instyvel.*t-0.5*g.*t.^2;
    xpos = xvel*t;
    posinstant = sqrt(ypos.^2 + xpos.^2);
    figure
    plot(t,posinstant);
    title('Position vs Time');
%%
end

