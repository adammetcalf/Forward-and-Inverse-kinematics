close all;
clear;
clc;

phantomActive = false;
needleActive = true;
trajectoryActive = false;

%% Load NeedleFK Lookup tables
bendData = readmatrix("C:/Users/bsgx043/Desktop/Forward-and-Inverse-kinematics/KinematicsMATLAB/Robotics/FlexibleSyringe/bend_data.csv");
yawData = readmatrix("C:/Users/bsgx043/Desktop/Forward-and-Inverse-kinematics/KinematicsMATLAB/Robotics/FlexibleSyringe/yaw_data.csv");
baseData = readmatrix("C:/Users/bsgx043/Desktop/Forward-and-Inverse-kinematics/KinematicsMATLAB/Robotics/FlexibleSyringe/bend_base_data.csv");

%% Define Parameters

%Define Trajectory Height
yHeight = 0.6;


%Define Target Point Robot 1
TargetPoint1 = [0.02,-0.5,0.51];
EndTarget1 = [0.02,-0.459,0.51];
TargetPoint2 = [0.02,-0.459,0.51];
EndTarget2 = [0.02,-0.375,0.51];

targetTraj1 =[(linspace(TargetPoint1(1),EndTarget1(1),20))', (linspace(TargetPoint1(2),EndTarget1(2),20))',(linspace(TargetPoint1(3),EndTarget1(3),20))'];
targetTraj2 =[(linspace(TargetPoint2(1),EndTarget2(1),40))', (linspace(TargetPoint2(2),EndTarget2(2),40))',(linspace(TargetPoint2(3),EndTarget2(3),40))'];

targetTraj = [targetTraj1;targetTraj2];

needleTraj1 = (linspace(0,0,45))';
needleTraj2 = (round(linspace(0,13,15)))';

needleTraj = [needleTraj1;needleTraj2];

%Define Magnet Orientation Robot 1
MagOrient1 =[0, 0, -pi/2];               %[Rx, Ry Rz]

%% Load Phantom
%Load phantom
if phantomActive
    phantom = importrobot('urdf/phantom.urdf','DataFormat','row');
end

%% Setup Animation

% Create a figure for the animation
hFig = figure;

% Set the figure to fullscreen
set(hFig, 'units', 'normalized', 'outerposition', [0 0 1 1]);

% Set up the axes for the 3D plot
ax = axes('Parent', hFig);
hold(ax, 'on');
axis(ax, 'equal');
axis(ax, [-1.2 1.2 -1.2 1.2 0 1]);
%axis(ax, [-0.3 0.15 -0.3 0.15 0 1]);
grid(ax, 'on');
xlabel(ax, 'X');
ylabel(ax, 'Y');
zlabel(ax, 'Z');
title(ax, 'Robot Trajectories');
view(52.9545, 21.4000);
%view(90, 90);

%% Define robots

%Robot joint limits
jointLimits = [-170,170;
               -90,120; % Elbow Up
               -170,170;
               -120,120;
               -170,170;
               -120,120;
               -175,175];

%Load robot 1
robot1 = importrobot('urdf/kuka_iiwa_1.urdf','DataFormat','row');

%Create initial guess
initialguess1 = robot1.homeConfiguration;

%% Generate Trajectory
if trajectoryActive
    Trajectory1 = GenerateTrajectory([0.02,-0.5,yHeight],[0.02,-0.065,yHeight],20);
    [Trajectory2, ~] = calculateCurvePointsTraj([0.02,-0.5,yHeight], [0.02,-0.065,yHeight], [0.00, 0.016,yHeight], 10);
    
    
    Trajectory = [Trajectory1; Trajectory2];
    
end

%% Generate Trajectory
for i=1:length(targetTraj)

    %Create Inverse Kinematic solver
    IK1 = generalizedInverseKinematics('RigidBodyTree', robot1,'ConstraintInputs', {'position','aiming','joint','orientation'});
    
    %Define Position Constraints
    posConstraint1 = constraintPositionTarget('lbr_iiwa_link_7');
    posConstraint1.TargetPosition = targetTraj(i,:);
    
    %Define Aiming Constraint
    aimConstraint1 = constraintAiming('lbr_iiwa_link_7');
    aimConstraint1.TargetPoint =  targetTraj(i,:);
    
    %Define Oirentation Constraints
    oirConstraint1 = constraintOrientationTarget('lbr_iiwa_link_7');
    oirConstraint1.OrientationTolerance = deg2rad(0.2);
    oirConstraint1.TargetOrientation = eul2quat(MagOrient1);
    
    %Define Constraints
    jointConstraint1 = constraintJointBounds(robot1);
    jointConstraint1.Bounds = deg2rad(jointLimits);
    
    %Inverse kinematics (optimisation routine)
    [Angles1,success1] = IK1(initialguess1, posConstraint1, aimConstraint1, jointConstraint1, oirConstraint1);

    Angles(i,:) = Angles1;
    initialguess1 = Angles1;

    % Compute transformation matrix for robots from base to end effector
    transformMatrix1 = getTransform(robot1, Angles1, 'lbr_iiwa_link_7', 'base_link');

    %% Add points to visualise the flexible needle
    % Extract position and rotation matrix from transformation matrix
    position1 = transformMatrix1(1:3, 4);
    rotationMatrix1 = transformMatrix1(1:3, 1:3);

    if needleActive
        % Define the local offset in the end effector's frame
        % This is 0.145 units along the local Z-axis (ie start position of the
        % needle)
        localOffset = [0; 0; 0.145];
        
        % Transform the local offset to the global coordinate system
        globalOffset = rotationMatrix1 * localOffset;
        
        % Calculate the global position of the needle
        BasePos = position1 + globalOffset;
        
        BendStep = needleTraj(i,1);
    
        %Create Syringe
        [Base, T01, T02, T03, T04, curve] = DHFinal(BendStep,bendData,yawData,baseData,BasePos,transformMatrix1);
    
        %Create plotable points  
        Point0(i,:) = Base(1:3,4);
        Point1(i,:) = T01(1:3,4);
        Point2(i,:) = T02(1:3,4);
        Point3(i,:) = T03(1:3,4);
        Point4(i,:) = T04(1:3,4);

        Curve(:,:,i) = curve;

    end

end


% Loop through each step in the trajectory
for step = 1:length(Angles)

    % Clear previous robots and fields for the new frame (optional)
    cla(ax);

    show(robot1,Angles(step,:),'Frames','off');
    hold on

    if phantomActive
        show(phantom,"Frames","off");
        hold on
    end

    if needleActive
        plot3([Point0(step,1),Point1(step,1)],[Point0(step,2),Point1(step,2)],[Point0(step,3),Point1(step,3)],'-k', 'LineWidth', 1, 'Marker', 'o', 'MarkerSize',2, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k');
        hold on
        plot3([Point1(step,1),Point2(step,1)],[Point1(step,2),Point2(step,2)],[Point1(step,3),Point2(step,3)],'-b', 'LineWidth', 1, 'Marker', 'o', 'MarkerSize',2, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k');
        plot3([Point2(step,1),Point3(step,1)],[Point2(step,2),Point3(step,2)],[Point2(step,3),Point3(step,3)],'-b', 'LineWidth', 1, 'Marker', 'o', 'MarkerSize',2, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k');
        plot3(Point4(step,1),Point4(step,2),Point4(step,3),'Marker', 'o', 'MarkerSize',2, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k');
        plot3(Curve(:,1,step), Curve(:,2,step), Curve(:,3,step), 'r-', 'LineWidth', 2);
    end

    if trajectoryActive
        plot3(Trajectory(:,1), Trajectory(:,2), Trajectory(:,3), '.b');
        hold on
    end

    % Pause to control the speed of animation
    pause(0.02);

    % Capture frames for a video
    frames(step) = getframe(hFig);
end

% Save the animation as a video file
video = VideoWriter('Hybrid1.avi');
video.FrameRate = 10;
open(video);
writeVideo(video, frames);
close(video);
