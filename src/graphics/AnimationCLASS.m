classdef AnimationCLASS
    %TIMESTEPPINGCLASS Summary of this class goes here
    %   Detailed explanation goes here

    % Public Properties
    properties (SetAccess = public, GetAccess = public)
        % Constants  
        grey = [0.2431,    0.2667,    0.2980];
        green = [0.0000, 0.6902, 0.3137];
        blue = [0.0000, 0.3176, 0.6196];
    end
    
    % Private Properties
    properties (SetAccess = private, GetAccess = private)
        model;        % A model object
        controller;
        trajectory;
        simulation;
        fig; % The output window
        ax;  % The output axis
    end

    methods
        function obj = AnimationCLASS(model, trajectory, controller, simulation)
            % Constructor creates a simulation for a specific model
            obj.model      = model;
            obj.controller = controller;
            obj.trajectory = trajectory;
            obj.simulation = simulation; 
            % Set up output figure:
            obj.fig = figure;
            obj.ax = axes;
            hold on
            box on
            grid on
            axis equal
            set(obj.fig,'Name','2D-Output');
            set(obj.fig,'Color','w');
        end

        function obj = Animate(obj)
            % Bring window to front:
            figure(obj.fig);
            plot(obj.trajectory.x(1,:), obj.trajectory.x(2,:), '--', 'Color', obj.grey, 'linewidth', 1.5), grid on, hold on,
            
            plot(obj.simulation.x_out(1,:), obj.simulation.x_out(2,:), '--', 'Color', obj.green, 'linewidth', 1.5)

            if isa(obj.model,'Mdl_TractorTrailerCLASS')
                plot(obj.simulation.x_out(4,:), obj.simulation.x_out(5,:), '-', 'Color', obj.blue, 'linewidth', 1.5)
            end

            ylim([-3.0,0.5]);
        end
    end
end

