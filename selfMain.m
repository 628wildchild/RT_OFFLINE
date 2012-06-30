function [  ] = selfMain()
%SELFMAIN Self-initiated decision making. No count-down
%   

clear all;
rng;

%% parameters
patName         = 'Patient';    % patient name
expName         = 'Uri';        % experimenter name
initialMoney    = 5;            % initial endowment
rounds          = 5;            % rounds

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
scr.setMainText('When you are ready, lift both hands to start the game');
res.monitorTargetWait([0 0 0 0]);

%% trial stage
for i = 1:rounds
    % MONITOR PRESSING DOWN
    scr.setMainText('When you made your decision, please press down buttons');
    res.setVal([1 0 1 0 0 0 0 0]);
    res.monitorTargetWait([1 1 0 0]);
    my_lptwrite(201);
    
    % PAUSE
    scr.setMainText('');
    val = res.monitorChangeWaitTime(2);
    if ~cmpBtns(val, [-1 -1 -1 -1]) % lift hands too early
        scr.setMainText('You lifted your hands too early. Please put your hands down');
        my_lptwrite(101);
        patMoney = patMoney - .1;
        scr.setMoney(1, patMoney);
        res.setVal([1 0 1 0 0 0 0 0]);
        res.monitorTargetWait([1 1 0 0]);
        res.clearVal();
        scr.setMainText('When you are ready, lift both hands to continue the next round');
        res.monitorTargetWait([0 0 0 0]);
        continue;
    end
    
    % GET DECISIONS
    scr.setMainText('GO-GO-GO');
    recComputerChoice(i) = behaviorPred();
        
    patChoice = res.monitorChangeWaitTime(0.5);
    if cmpBtns(patChoice,[1 0 0 0]) % right hand
        my_lptwrite(210);
        recPatientChoice(i) = 1;
        scr.setP1Text('X  O');
    elseif cmpBtns(patChoice,[0 1 0 0]) %left hand
        my_lptwrite(211);
        recPatientChoice(i) = 2;
        scr.setP1Text('O  X');
    elseif cmpBtns(patChoice,[-1 -1 -1 -1]) % too late
        scr.setMainText('You are too late. Please put your hands down');
        my_lptwrite(103);
        patMoney = patMoney - .1;
        scr.setMoney(1, patMoney);
        res.setVal([1 0 1 0 0 0 0 0]);
        res.monitorTargetWait([1 1 0 0]);
        res.clearVal();
        pause(0.5);
        scr.setMainText('When you are ready, lift both hands to continue the next round');
        res.monitorTargetWait([0 0 0 0]);
        continue;
    else % wrong hands
        scr.setMainText('You lift both hands. Please put your hands down');
        my_lptwrite(304);
        scr.setP1Text('O  O');
        patMoney = patMoney - .1;
        scr.setMoney(1, patMoney);
        res.setVal([1 0 1 0 0 0 0 0]);
        res.monitorTargetWait([1 1 0 0]);
        res.clearVal();
        scr.setMainText('When you are ready, lift both hands to continue the next round');
        res.monitorTargetWait([0 0 0 0]);
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
    
    res.clearVal();
    scr.setMainText('Please lift your hands');
    res.monitorTargetWait([0 0 0 0]);
    
end

if patMoney > expMoney
    scr.setMainText(sprintf('Session Ended. %s is the winner', patName));
elseif patMoney < expMoney
    scr.setMainText(sprintf('Session Ended. %s is the winner', expName));
else 
    scr.setMainText('Session Ended. Tied.');
end

end

function ret = cmpBtns(btn1, btn2)
ret = sum(btn1 == btn2) == 4;
end