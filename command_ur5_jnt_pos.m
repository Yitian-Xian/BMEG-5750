clear all;
clc;

disp('Program started');
% sim=remApi('remoteApi','extApi.h'); % using the header (requires a compiler)
sim=remApi('remoteApi'); % using the prototype file (remoteApiProto.m)
sim.simxFinish(-1); % just in case, close all opened connections
clientID=sim.simxStart('127.0.0.1',19999,true,true,5000,5);

if (clientID>-1)
    
    disp('Connected to remote API server');

    %% enable the synchronous mode on the client:
    sim.simxSynchronous(clientID,true);
    %% start the simulation:
    sim.simxStartSimulation(clientID,sim.simx_opmode_oneshot_wait);
    
    %% Time triggering
    sim.simxSynchronousTrigger(clientID);

    %% Define robot name
    robot_name = 'UR5';

    %% Obtain object handle of each joint
    armJoints = -ones(1,6);
    for i=1:6
        [res,armJoints(i)] = sim.simxGetObjectHandle(clientID,[robot_name,'_joint',num2str(i)],sim.simx_opmode_oneshot_wait);
    end
    
    pause(1);
    
    %% Define an array to store joint position
    joint_position = zeros(6,1);

    %% Begin the loop:
    while sim.simxGetConnectionId(clientID)~=-1
        %% Read joint position
        for i=1:6
            [res,joint_position(i)] = sim.simxGetJointPosition(clientID,armJoints(i),sim.simx_opmode_oneshot_wait); % joint position
        end
        
        %% Define target joint position
        target_joint_position = joint_position;
        %% Modify target position of the 1st joint
        target_joint_position(1) = target_joint_position(1) + deg2rad(1);

        %% Send tagret joint position
        for i=1:6
            res = sim.simxSetJointTargetPosition(clientID, armJoints(i),target_joint_position(i), sim.simx_opmode_oneshot);
        end

        %% Time triggering
        sim.simxSynchronousTrigger(clientID);
    end

    %% Before closing the connection to CoppeliaSim, make sure that the last command sent out had time to arrive. You can guarantee this with (for example):
    sim.simxGetPingTime(clientID);

    %% Now close the connection to CoppeliaSim:    
    sim.simxFinish(clientID);

else
    disp('Failed connecting to remote API server');
end

sim.delete(); % call the destructor!

disp('Program ended');


