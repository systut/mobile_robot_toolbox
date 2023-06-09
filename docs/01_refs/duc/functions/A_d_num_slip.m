function A_d = A_d_num_slip(in1,in2,in3)
%A_D_NUM_SLIP
%    A_D = A_D_NUM_SLIP(IN1,IN2,IN3)

%    This function was generated by the Symbolic Math Toolbox version 8.5.
%    26-Jul-2020 11:41:59

h = in3(:,2);
i_l = in3(:,4);
i_r = in3(:,3);
u_lin1 = in2(1,:);
u_lin2 = in2(2,:);
x_lin3 = in1(3,:);
t2 = i_l-1.0;
t3 = i_r-1.0;
t4 = t2.*u_lin2;
t5 = t3.*u_lin1;
t6 = t4+t5;
A_d = reshape([1.0,0.0,0.0,0.0,1.0,0.0,(h.*t6.*sin(x_lin3))./2.0,h.*t6.*cos(x_lin3).*(-1.0./2.0),1.0],[3,3]);
