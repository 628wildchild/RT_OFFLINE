function [recPatientChoice, recComputerChoice, recWinner] = countMain()
%COUNTMAIN The app implements the scheme that counts down from 5-1, each every
%one second. (The basic count-down function). With the computer

clear all;
rng;

%% parameters
patName         = 'Patient';    % patient name
expName         = 'Computer';        % experimenter name
initialMoney    = 5;            % initial endowment
rounds          = 10;            % rounds

%% set up
recPatientChoice = zeros(rounds, 1);
recComputerChoice = zeros(rounds, 1);
recWinner = zeros(rounds, 1);

patMoney = initialMoney;
expMoney = initialMoney;

res = RespBox();
scr = Screen();
my_lptwrite(0);

%% initial stage
scr.initiate(patName,expName,initialMoney);
scr.setMainText('Please put your hands down to start');

res.setVal([1 0 1 0 0 0 0 0]);
res.monitorTargetWait([1 1 0 0]);
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
    my_lptwrite(201);
    
    ret = res.monitorChangeWaitTime(5);
    if ~cmpBtns(ret,[-1 -1 -1 -1]) % lift hands too early
        stop(t);
        scr.setMainText('You lift your hands too early. Please put your hands down');
        my_lptwrite(101);
        patMoney = patMoney - .1;
        scr.setMoney(1, patMoney);
        res.setVal([1 0 1 0 0 0 0 0]);
        res.monitorTargetWait([1 1 0 0]);
        res.clearVal();
        delete(t);
        continue;
    end
    delete(t);
    
    % GET DECISIONS
    scr.setMainText('GO-GO-GO');
    my_lptwrite(202);
    
    if i == 1
        recComputerChoice(i) = behaviorPred('reset');
    else
        recComputerChoice(i) = behaviorPred(recPatientChoice(i-1));
    end
        
    patChoice = res.monitorChangeWaitTime(0.5);
    if cmpBtns(patChoice,[1 0 0 0]) % right hand
        my_lptwrite(211);
        recPatientChoice(i) = 1;
        scr.setP1Text('X  O');
    elseif cmpBtns(patChoice,[0 1 0 0]) %left hand
        my_lptwrite(212);
        recPatientChoice(i) = 2;
        scr.setP1Text('O  X');
    elseif cmpBtns(patChoice,[-1 -1 -1 -1]) % too late
        scr.setMainText('You are too late. Please lift both of your hands');
        my_lptwrite(102);
        patMoney = patMoney - .1;
        scr.setMoney(1, patMoney);
        res.setVal([1 0 1 0 0 0 0 0]);
        res.monitorTargetWait([0 0 0 0]);
        scr.setMainText('Press the buttons to coninue');
        res.monitorTargetWait([1 1 0 0]);
        res.clearVal();
        continue;
    else % wrong hands
        scr.setMainText('You lift both hands. Please put your hands down');
        my_lptwrite(103);
        scr.setP1Text('O  O');
        patMoney = patMoney - .1;
        scr.setMoney(1, patMoney);
        res.setVal([1 0 1 0 0 0 0 0]);
        res.monitorTargetWait([1 1 0 0]);
        res.clearVal();
        continue;
    end
    
    if recComputerChoice(i) == 1
        scr.setP2Text('X  O');
    else
        scr.setP2Text('O  X');
    end
    
    % ANNOUNCE THE WINNER
    if recComputerChoice(i) == recPatientChoice(i) % computer wins
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
    res.setVal([1 0 1 0 0 0 0 0]);
    scr.setMainText('Please press hands down.');
    while sum(res.getVal == [1 1 0 0])~= 4
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
scr.setMainText(6-tobj.TasksExecuted);
end

function ret = cmpBtns(btn1, btn2)
ret = sum(btn1 == btn2) == 4;
end
