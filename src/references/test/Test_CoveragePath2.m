% Params
R = 10;
dt = 0.05;
tSTART = 0;
tMAX = 60;

model = Mdl_TractorTrailerCLASS();
trajectory = Ref_CoveragePath2CLASS(model);

trajectory.tMAX   = tMAX;                      % maximum simulation time
trajectory.dt = dt; 
trajectory.R = R; 
trajectory.mode = "normal";
trajectory = trajectory.Generate();

figure;
grey = [0.2431,    0.2667,    0.2980];
green = [0.0000, 0.6902, 0.3137];
red = [0.6902, 0, 0.3137];
blue = [0.0000, 0.3176, 0.6196];

plot(trajectory.x(1,:), trajectory.x(2,:), '--', 'Color', grey, 'linewidth', 1.5), grid on, hold on,

plot(trajectory.x(4,:), trajectory.x(5,:), '--', 'Color', green, 'linewidth', 1.5)