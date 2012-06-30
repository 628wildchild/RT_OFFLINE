function [ recPatientChoice, recExperimenterChoice, recWinner ] = countMainExp()
%COUNTMAINEXP The app implements the scheme that counts down from 5-1, each every
%one second. (The basic count-down function). With the experimenter

clear all;
rng;

%% parameters
patName         = 'Patient';    % patient name
expName         = 'Uri';        % experimenter name
initialMoney    = 5;            % initial endowment
rounds          = 5;            % rounds

%% set up
recPatientChoice = zeros(rounds, 1);
recExperimenterChoice = zeros(rounds, 1);
recWinner = zeros(rounds, 1);

patMoney = initialMoney;
expMoney = initialMoney;

res = RespBox();
scr = Screen();

%% initial stage
scr.initiate(patName,expName,initialMoney);
scr.setMainText('Please put your hands down to start');

res.setVal([1 0 1 0 0 1 0 1]);
res.monitorTargetWait([1 1 1 1]);
res.clearVal();

%% trial stage
for i = 1:rounds
    % COUNT DOWN
    scr.setP1Text(''); scr.setP2Text('');
    res.setVal([1 0 1 0 0 1 0 1]);
    t = timer('StartDelay', 0, 'Period', 1, 'TasksToExecute', 5, ...
        'ExecutionMode', 'fixedRate');
    t.TimerFcn = {@updateCountdown, scr};
    tic;
    start(t);
    
    ret = res.monitorChangeWaitTime(5);
    if ~cmpBtns(ret,[-1 -1 -1 -1]) % lift hands too early
        stop(t);
        if cmpBtns(ret,[0 0 1 1]) || cmpBtns(ret,[0 1 1 1])
            scr.setMainText(sprintf('%s lift your hands too early. Please put your hands down', patName));
            patMoney = patMoney - .1;
            scr.setMoney(1, patMoney);
        elseif cmpBtns(ret,[1 1 0 0]) || cmpBtns(ret,[1 1 1 0])
            scr.setMainText(sprintf('%s lift your hands too early. Please put your hands down', expName));
            expMoney = expMoney - .1;
            scr.setMoney(2, expMoney);
        else 
            scr.setMainText('Both lift your hands too early. Please put your hands down');
            expMoney = expMoney - .1;
            patMoney = patMoney - .1;
            scr.setMoney(1, patMoney);
            scr.setMoney(2, expMoney);
        end
            
        res.setVal([1 0 1 0 0 1 0 1]);
        res.monitorTargetWait([1 1 1 1]);
        res.clearVal();
        delete(t);
        continue;
    end
    delete(t);
    
    % GET DECISIONS
    scr.setMainText('GO-GO-GO');
    pause(0.5);
    pplChoice = res.getVal();
    
    errTrue = [0 0];
    % patient choice 
    if cmpBtns(pplChoice(1:2),[1 0]) % right hand
        recPatientChoice(i) = 1;
        scr.setP1Text('X  O');
    elseif cmpBtns(pplChoice(1:2),[0 1]) %left hand
        recPatientChoice(i) = 2;
        scr.setP1Text('O  X');
    elseif cmpBtns(pplChoice(1:2),[1 1]) % too late
        scr.setP1Text('X  X');
        scr.setMainText(sprintf('%s is too late. Please put your hands down', patName));
        patMoney = patMoney - .1;
        scr.setMoney(1, patMoney);
        errTrue(1) = errTrue(1) + 1;
    elseif cmpBtns(pplChoice(1:2),[0 0]) % both hands up
        scr.setP1Text('X  X');
        scr.setMainText(sprintf('%s raised both hands. Please put your hands down', patName));
        patMoney = patMoney - .1;
        scr.setMoney(1, patMoney);
        errTrue(2) = errTrue(2) + 1;
    end
    % experimenter choice
    if cmpBtns(pplChoice(3:4),[1 0]) % right hand
        recExperimenterChoice(i) = 1;
        scr.setP1Text('X  O');
    elseif cmpBtns(pplChoice(3:4),[0 1]) %left hand
        recExperimenterChoice(i) = 2;
        scr.setP2Text('O  X');
    elseif cmpBtns(pplChoice(3:4),[1 1]) % too late
        scr.setP2Text('X  X');
        scr.setMainText(sprintf('%s is too late. Please put your hands down', expName));
        expMoney = expMoney - .1;
        scr.setMoney(2, expMoney);
        errTrue(1) = errTrue(1) + 1;
    elseif cmpBtns(pplChoice(3:4),[0 0]) % both hands up
        scr.setP2Text('X  X');
        scr.setMainText(sprintf('%s raised both hands. Please put your hands down', expName));
        expMoney = expMoney - .1;
        scr.setMoney(2, expMoney);
        errTrue(2) = errTrue(2) + 1;
    end
    % both no action
    if errTrue(1) == 2
        ecr.setMainText('Both are too late. Please put your hands down')
    end
    % both lift both hands
    if errTrue(2) == 2
        ecr.setMainText('Both lift both hands. Please put your hands down')
    end
    
    % error handing
    if sum(errTrue) > 0
        res.setVal([1 0 1 0 0 1 0 1]);
        res.monitorTargetWait([1 1 1 1]);
        res.clearVal();
        continue;
    end
    
    
    % ANNOUNCE THE WINNER
    if recExperimenterChoice(i) == recPatientChoice(i) % computer wins
        recWinner(i) = 1;
        scr.setMainText(sprintf('%s wins!', expName));
        patMoney = patMoney - .1;
        expMoney = expMoney + .1;
        scr.setMoney(1, patMoney);
        scr.setMoney(2, expMoney);
    else % patient wins
        recWinner(i) = 2;
        scr.setMainText(sprintf('%s wins!', patName));
        patMoney = patMoney + .1;
        expMoney = expMoney - .1;
        scr.setMoney(1, patMoney);
        scr.setMoney(2, expMoney);
    end
    
    pause(1);
    
    % ASK WHEN DECISION IS MADE
    res.setVal([1 0 1 0 0 1 0 1]);
    scr.setMainText('Press down your hands');
    while sum(res.getVal == [1 1 1 1])~= 4
    end
    res.clearVal();
    
end

%% announce the winner
if patMoney > expMoney
    scr.setMainText(sprintf('Ended. %s wins!', patName));
elseif patMoney < expMoney
    scr.setMainText(sprintf('Ended. %s wins!', expName));
else 
    scr.setMainText('Ended. Ties!');
end

end

function updateCountdown(tobj, tevent, scr)
scr.setMainText(11-tobj.TasksExecuted);
end

function ret = cmpBtns(btn1, btn2)
ret = sum(btn1 == btn2) == length(btn1);
end
