close all;
clear;
clc;

%Define Workspace Origin
Origin = [0,0,0];

%Define Robot 1 Origin
O_1 = [-0.5,0,0];

%Define Robot 2 Origin
O_2 = [0.5,0,0];

%Define Angles robot 1
T1 = pi/2;
T2 = pi/2;
T3 = pi/2;
T4 = pi/2;
T5 = pi/2;
T6 = pi/2;
T7 = pi/2;

%Define Angles robot 2
T2_1 = -pi/2;
T2_2 = pi/2;
T2_3 = pi/2;
T2_4 = pi/2;
T2_5 = pi/2;
T2_6 = pi/2;
T2_7 = pi/2;

%Forward Kinematics Robot 1
[T01,T02,T03,T04,T05,T06,T07] = f_MDH(O_1,T1,T2,T3,T4,T5,T6,T7);

%Forward Kinematics Robot 2
[T201,T202,T203,T204,T205,T206,T207] = f_MDH(O_2,T2_1,T2_2,T2_3,T2_4,T2_5,T2_6,T2_7);

%x, y , z coordinates for robot 1
X1 = [O_1(1), T01(1,4), T03(1,4), T03(1,4), T04(1,4), T05(1,4), T06(1,4), T07(1,4)];
Y1 = [O_1(2), T01(2,4), T03(2,4), T03(2,4), T04(2,4), T05(2,4), T06(2,4), T07(2,4)];
Z1 = [O_1(3), T01(3,4), T03(3,4), T03(3,4), T04(3,4), T05(3,4), T06(3,4), T07(3,4)];

%x, y , z coordinates for robot 2
X2 = [O_2(1), T201(1,4), T203(1,4), T203(1,4), T204(1,4), T205(1,4), T206(1,4), T207(1,4)];
Y2 = [O_2(2), T201(2,4), T203(2,4), T203(2,4), T204(2,4), T205(2,4), T206(2,4), T207(2,4)];
Z2 = [O_2(3), T201(3,4), T203(3,4), T203(3,4), T204(3,4), T205(3,4), T206(3,4), T207(3,4)];

figure(1) 
%Plot Robot 1 position
plot3(X1,Y1,Z1,'--ro', 'MarkerSize', 4, 'MarkerFaceColor', 'k')
axis([-1.8 1.8 -1.8 1.8 0 1.8])
hold on
% Adding orientation for world origin
addOrigin();
% Adding orientation arrows for Robot 1
addOrientationArrows(T01, T01(1,4), T01(2,4), T01(3,4));
addOrientationArrows(T02, T02(1,4), T02(2,4), T02(3,4));
addOrientationArrows(T03, T03(1,4), T03(2,4), T03(3,4));
addOrientationArrows(T04, T04(1,4), T04(2,4), T04(3,4));
addOrientationArrows(T05, T05(1,4), T05(2,4), T05(3,4));
addOrientationArrows(T06, T06(1,4), T06(2,4), T06(3,4));
addOrientationArrows(T07, T07(1,4), T07(2,4), T07(3,4));
%Plot robot 2 position
plot3(X2,Y2,Z2,'--ro', 'MarkerSize', 4, 'MarkerFaceColor', 'k')
% Adding orientation arrows for Robot 2
addOrientationArrows(T201, T201(1,4), T201(2,4), T201(3,4));
addOrientationArrows(T202, T202(1,4), T202(2,4), T202(3,4));
addOrientationArrows(T203, T203(1,4), T203(2,4), T203(3,4));
addOrientationArrows(T204, T204(1,4), T204(2,4), T204(3,4));
addOrientationArrows(T205, T205(1,4), T205(2,4), T205(3,4));
addOrientationArrows(T206, T206(1,4), T206(2,4), T206(3,4));
addOrientationArrows(T207, T207(1,4), T207(2,4), T207(3,4));
hold off

%Function to add WorldOrigin orienation arrows
function addOrigin()
    quiver3(0, 0, 0, 0.2, 0, 0, 'r', 'LineWidth', 1.5); % X-axis
    quiver3(0, 0, 0, 0, 0.2, 0, 'g', 'LineWidth', 1.5); % Y-axis
    quiver3(0, 0, 0, 0, 0, 0.2, 'b', 'LineWidth', 1.5); % Z-axis
end

% Function to add orientation arrows
function addOrientationArrows(T, x, y, z)
    scale = 0.1; % Adjust the scale to fit your plot
    quiver3(x, y, z, scale*T(1,1), scale*T(2,1), scale*T(3,1), 'r', 'LineWidth', 1.5); % X-axis
    quiver3(x, y, z, scale*T(1,2), scale*T(2,2), scale*T(3,2), 'g', 'LineWidth', 1.5); % Y-axis
    quiver3(x, y, z, scale*T(1,3), scale*T(2,3), scale*T(3,3), 'b', 'LineWidth', 1.5); % Z-axis
end

