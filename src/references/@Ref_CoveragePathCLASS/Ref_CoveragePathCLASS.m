classdef Ref_CoveragePathCLASS
    properties
        % Params
        R = 20; 
        tMAX;
        dt;
        % States
        x;
        dxdt;
        ddxddt;
        % Input
        u;
        u_norm;
        x_out;
        % Timestamp
        t;
        % Class
        mode;
        className;
        folderPath;
    end

    % Private Properties
    properties (SetAccess = private, GetAccess = private)
        model;        % A model object
    end
    
    methods
        function obj = Ref_CoveragePathCLASS(model)
            %CTRL_BASECLASS Construct an instance of this class
            %   Detailed explanation goes here
            obj.model = model;

            obj.mode = "normal";

            obj.className = class(obj);

            [obj.folderPath] = fileparts(which(obj.className));
        end

        function obj = Generate(obj)
            %LE Summary of this function goes here
            %   Detailed explanation goes here
            if strcmp(obj.mode, "load")

                obj = obj.Load();

                return;
            end

            obj.t = linspace(0, obj.tMAX, (1/obj.dt) * obj.tMAX); % should take 60s to complete with 20 Hz sampling rate
            v = 2; % m/s

            obj.x = [];
            obj.dxdt = [];
            obj.ddxddt = [];

            for index=1:length(obj.t)/3
                [x_, dxdt_, ddxddt_] = obj.GenerateStraightLine(v, [0;0;0], obj.t(index));

                obj.x = [obj.x, x_];

                obj.dxdt = [obj.dxdt, dxdt_];

                obj.ddxddt = [obj.ddxddt, ddxddt_];
            end
                    
            for index=1:length(obj.t)/3
                [x_, dxdt_, ddxddt_] = obj.GenerateClockwiseHalfCircle([v*length(obj.t)*obj.dt/3; 0; 0], obj.R, obj.t(index));

                obj.x = [obj.x, x_];

                obj.dxdt = [obj.dxdt, dxdt_];

                obj.ddxddt = [obj.ddxddt, ddxddt_];
            end


            for index=1:length(obj.t)/3
                [x_, dxdt_, ddxddt_] = obj.GenerateStraightLine(-v,[v*length(obj.t)*obj.dt/3; 2*obj.R; pi],obj.t(index));

                obj.x = [obj.x, x_];

                obj.dxdt = [obj.dxdt, dxdt_];

                obj.ddxddt = [obj.ddxddt, ddxddt_];
            end
    
            if isa(obj.model, 'Mdl_BicycleCLASS')
                v = sqrt(obj.dxdt(1, :).^2 + obj.dxdt(2, :).^2);

                delta = atan(obj.model.length_base * (obj.ddxddt(2, :) .* obj.dxdt(1, :) - obj.ddxddt(1, :) .* obj.dxdt(2, :)) ./ (v.^3));

                ddeltadt = zeros(1, length(obj.t));

                for index = 1:length(obj.t)-1
                    ddeltadt(1, index) = (delta(1, index+1) - delta(1, index)) / obj.dt; 
                end

                obj.u = [v; ddeltadt]; 

            elseif isa(obj.model, 'Mdl_TractorTrailerCLASS')
                w = (obj.ddxddt(2, :) .* obj.dxdt(1, :) - obj.ddxddt(1, :) .* obj.dxdt(2, :)) ./ (obj.dxdt(1, :).^2 + obj.dxdt(2, :).^2);
                
                v = sqrt(obj.dxdt(1, :).^2 + obj.dxdt(2, :).^2);

                w_ = zeros(1, length(obj.t));

                v_ = zeros(1, length(obj.t));

                obj.x_out = [zeros(3, length(obj.t));obj.x];

                for index = 2:length(obj.t)
                    [v_(index),w_(index),obj.x_out(3, index)] = obj.solveW(v(index), w(index), obj.x_out(6, index), obj.x_out(3, index-1));
                    
                    obj.x_out(1, index) = obj.x_out(1, index-1) + v_(index) * cos(obj.x_out(3, index-1)) * obj.dt;

                    obj.x_out(2, index) = obj.x_out(2, index-1) + v_(index) * sin(obj.x_out(3, index-1)) * obj.dt;

                end

                obj.x = obj.x_out;

                v_r = obj.model.distance * w_ + v_;
                v_l = -obj.model.distance * w_ + v_;

                obj.u = [v_r; v_l];

                obj.u_norm = [v_;w_];

            else
                dthetadt = (obj.ddxddt(2, :) .* obj.dxdt(1, :) - obj.ddxddt(1, :) .* obj.dxdt(2, :)) ./ (obj.dxdt(1, :).^2 + obj.dxdt(2, :).^2);

                v_r = obj.model.distance * dthetadt + sqrt(obj.dxdt(1, :).^2 + obj.dxdt(2, :).^2);
                v_l = -obj.model.distance * dthetadt + sqrt(obj.dxdt(1, :).^2 + obj.dxdt(2, :).^2);

                obj.u = [v_r; v_l];

                obj.u_norm = [dthetadt; sqrt(obj.dxdt(1, :).^2 + obj.dxdt(2, :).^2)];
            end
        end

        function [v_out, w_out, theta_out] = solveW(obj, v, w, theta, theta_)
            syms temp;
            
            theta_out_ = theta_ + temp*obj.dt;

            equation = v*sin(theta - theta_out_) + obj.model.length_front*w*cos(theta - theta_out_) - obj.model.length_back*temp == 0;

            solution = vpasolve(equation, temp, -1);

            w_out = solution;

            v_out = subs(v*cos(theta - theta_out_) - obj.model.length_front*w*sin(theta - theta_out_), temp, w_out); 
        
            theta_out = subs(theta_out_, temp, w_out);
        end   
        
        function Save(obj)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            data = [obj.t', obj.x', obj.u'];

            data = round(data, 6);

            output = [num2cell(data)];
            
            fileName = append(class(obj), '.csv');

            filePath = append(obj.folderPath, '/', fileName);

            writecell(output, filePath); % introduced in Matlab 2019a
        end

        function obj = Load(obj)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            fileName = append(class(obj), '.csv');

            filePath = append(obj.folderPath, '/', fileName);

            data = readmatrix(filePath);

            obj.t = data(:, 1)';
            
            obj.x = data(:, 2:2+obj.model.nx-1)';

            obj.u = data(:, 2+obj.model.nx:2+obj.model.nx+obj.model.nu-1)';
        end
    end

    methods(Static)
        function [x, dxdt, ddxddt] = GenerateStraightLine(v, x0, t)
            x      = x0 + [v * t; 0; 0];

            dxdt   = [v; 0];

            ddxddt = [0; 0];
        end

        function [x, dxdt, ddxddt] = GenerateClockwiseHalfCircle(x0, R, t)
            x      = [x0(1); R; x0(3)] + [-R*cos(pi/2 + pi/R*t); -R*sin(pi/2 + pi/R*t); pi/R*t];

            dxdt   = [R * (pi/R) * sin(pi/2 + pi/R*t)        ; -R * (pi/R) * cos(pi/2 + pi/R*t)];

            ddxddt = [R * (pi/R) * (pi/R) * cos(pi/2 + pi/R*t); R * (pi/R) * (pi/R) * sin(pi/2 + pi/R*t)];
        end  
    end
end



 