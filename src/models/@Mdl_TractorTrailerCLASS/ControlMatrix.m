function B = ControlMatrix(obj,in2,in3,dt,in5)
%ControlMatrix
%    B = ControlMatrix(OBJ,IN2,IN3,DT,IN5)

%    This function was generated by the Symbolic Math Toolbox version 9.0.
%    13-Jul-2023 16:42:30

length_back = in5(:,2);
length_front = in5(:,1);
slip_left = in5(:,4);
slip_right = in5(:,3);
wheel_distance = in5(:,5);
x3 = in2(3,:);
x6 = in2(6,:);
t2 = cos(x3);
t3 = cos(x6);
t4 = sin(x3);
t5 = sin(x6);
t6 = 1.0./length_front;
t7 = slip_left-1.0;
t8 = slip_right-1.0;
t9 = 1.0./wheel_distance;
t10 = -x6;
t11 = slip_left./2.0;
t12 = slip_right./2.0;
t13 = t10+x3;
t16 = t11-1.0./2.0;
t17 = t12-1.0./2.0;
t14 = cos(t13);
t15 = sin(t13);
B = reshape([-dt.*t2.*t17,-dt.*t4.*t17,dt.*t8.*t9.*(-1.0./2.0),-dt.*(t3.*t14.*t17+(length_back.*t3.*t8.*t9.*t15)./2.0),-dt.*(t5.*t14.*t17+(length_back.*t5.*t8.*t9.*t15)./2.0),-dt.*(t6.*t15.*t17-(length_back.*t6.*t8.*t9.*t14)./2.0),-dt.*t2.*t16,-dt.*t4.*t16,(dt.*t7.*t9)./2.0,-dt.*(t3.*t14.*t16-(length_back.*t3.*t7.*t9.*t15)./2.0),-dt.*(t5.*t14.*t16-(length_back.*t5.*t7.*t9.*t15)./2.0),-dt.*(t6.*t15.*t16+(length_back.*t6.*t7.*t9.*t14)./2.0)],[6,2]);
