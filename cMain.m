function [recPatientChoice, recComputerChoice, recWinner, recVoice] = cMain()
%CMAIN The app implements the scheme that counts down from 10-1, for every
%half seconds. It implements a voice recording

clear all;
rng;

%% parameters
patName         = 'Patient';    % patient name
expName         = 'Uri';        % experimenter name
initialMoney    = 5;            % initial endowment
rounds          = 1;            % rounds

%% set up
recPatientChoice = zeros(rounds, 1);
recComputerChoice = zeros(rounds, 1);
recWinner = zeros(rounds, 1);
recVoice = {};

patMoney = initialMoney;
expMoney = initialMoney;

res = RespBox();
scr = Screen();
recObj = audiorecorder;

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
    t = timer('StartDelay', 0, 'Period', 0.5, 'TasksToExecute', 10, ...
        'ExecutionMode', 'fixedRate');
    t.TimerFcn = {@updateCountdown, scr};
    tic;
    start(t);
    
    ret = res.monitorChangeWaitTime(5);
    if ~cmpBtns(ret,[-1 -1 -1 -1]) % lift hands too early
        stop(t);
        scr.setMainText('You lift your hands too early. Please put your hands down');
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
    recComputerChoice(i) = round(rand()) + 1;
        
    patChoice = res.monitorChangeWaitTime(0.5);
    if cmpBtns(patChoice,[1 0 0 0]) % right hand
        recPatientChoice(i) = 1;
        scr.setP1Text('X  O');
    elseif cmpBtns(patChoice,[0 1 0 0]) %left hand
        recPatientChoice(i) = 2;
        scr.setP1Text('O  X');
    elseif cmpBtns(patChoice,[-1 -1 -1 -1]) % too late
        scr.setMainText('You are too late. Please put your hands down');
        patMoney = patMoney - .1;
        scr.setMoney(1, patMoney);
        res.setVal([1 0 1 0 0 0 0 0]);
        res.monitorTargetWait([1 1 0 0]);
        res.clearVal();
        pause(0.5);
        continue;
    else % wrong hands
        scr.setMainText('You lift both hands. Please put your hands down');
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
    scr.setMainText('When did you made your decision? Hands down when finish');
    record(recObj);
    while sum(res.getVal == [1 1 0 0])~= 4
    end
    stop(recObj);
    recVoice{i} = getaudiodata(recObj);
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
ret = sum(btn1 == btn2) == 4;
end
