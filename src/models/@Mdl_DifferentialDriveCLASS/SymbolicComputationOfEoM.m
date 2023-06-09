function SymbolicComputationOfEoM()
    %SYMBOLICCOMPUTATIONOFEOM Summary of this function goes here
    %   Detailed explanation goes here
    syms slip_right slip_left wheel_distance dt

    p = [slip_right, slip_left, wheel_distance];

    nx = 3;

    nu = 2;
    
    % [x, y, theta]
    x = sym('x',[nx,1]);
    
    % [v_r, v_l]
    u = sym('u',[nu,1]);

    % [x, y, theta]
    state = sym('x',[nx,1]);
    
    % [v_r, v_l]
    input = sym('u',[nu,1]);

    v = ((1 - slip_right) * u(1) + (1 - slip_left) * u(2))/2;

    w = ((1 - slip_right) * u(1) - (1 - slip_left) * u(2))/(2 * wheel_distance);

    dfdt = [cos(x(3)) * v;
             sin(x(3)) * v;
             w];

    f = state + subs(dfdt,[x;u],[state;input]) * dt;

    A_linearized   = subs(jacobian(dfdt, x),[x; u],[state;input]);

    B_linearized   = subs(jacobian(dfdt, u),[x; u],[state;input]);

    A   = eye(nx) + A_linearized * dt;

    B   = B_linearized * dt;

    %% Create MATLAB-functions:
    % identify the current file location, to place all functions there
    filename = mfilename('fullpath');
    [filepath,~,~] = fileparts(filename);
    % dummy variable for obj, so that these can be used within the CLASS
    syms obj 
    % for dynamics:
    matlabFunction(A,'file',[filepath,'/SystemMatrix'],'vars',{obj, state, input, dt, p});
    matlabFunction(B,'file',[filepath,'/ControlMatrix'],'vars',{obj, state, input, dt, p});
    matlabFunction(f,'file',[filepath,'/Function'],'vars',{obj, state, input, dt, p});

end

