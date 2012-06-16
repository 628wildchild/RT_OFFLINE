function Main()
%MAIN The app implements the scheme that asks the patient to press down 
%  buttons as soon as he/she makes the decision. It counts from 5 - 1 then 
%  GO-GO-GO. Patient can play with either computer or human

clear all;
rng;

%% parameters
player          = 0;            % play with computer (0) or human (1)
patName         = 'Patient';    % patient name
expName         = 'Uri';        % experimenter name
initialMoney    = 5;            % initial endowment
rounds          = 5;            % rounds

%% set up
recDecisionTime = zeros(rounds, 1);
recPatientChoice = zeros(rounds, 1);
recComputerChoice = zeros(rounds, 1);
recWinner = zeros(rounds, 1);

patMoney = initialMoney;
expMoney = initialMoney;

res = RespBox();
src = Screen();

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
    % COUNT DOWN
    res.setVal([1 0 1 0 0 1 0 1]);
    t = timer('StartDelay', 0, 'Period', 1, 'TasksToExecute', 5, ...
        'ExecutionMode', 'fixedRate');
    t.TimerFcn = {@updateCountdown, scr};
    tic;
    start(t);
    ret = res.monitorTargetWaitTime([1 1 0 0], 5);
    if ~cmpBtns(ret, [1 1 0 0]) % not fast enough making decision 
        stop(t);
        scr.setMainText('You did not make your decision fast enough. Please put your hands down to coninue');
        patMoney = patMoney - .1;
        scr.setMoney(1, patMoney);
        res.setVal([1 0 1 0 0 0 0 0]);
        res.monitorTargetWait([1 1 0 0]);
        res.clearVal();
        scr.setMainText('When you are ready, lift both hands to continue the next round');
        res.monitorTargetWait([0 0 0 0]);
        delete(t);
        continue;
    end
    recDecisionTime(i) = toc;
    res.setVal([0 0 0 0 0 0 0 0]);
    ret = obj.res.monitorChangeWaitTime(5-toc);
    if ~cmpBtns(ret,[-1 -1 -1 -1]) % lift hands too early
        stop(t);
        scr.setMainText('You lift your hands too early. Please put your hands down');
        patMoney = patMoney - .1;
        scr.setMoney(1, patMoney);
        res.setVal([1 0 1 0 0 0 0 0]);
        res.monitorTargetWait([1 1 0 0]);
        res.clearVal();
        scr.setMainText('When you are ready, lift both hands to continue the next round');
        res.monitorTargetWait([0 0 0 0]);
        delete(t);
        continue;
    end
    delete(t);
    
    % GET DECISIONS
    scr.setMainText('GO-GO-GO');
    patChoice = res.monitorChangeWaitTime(0.5);
    if cmpBtns(patChoice,[1 0 0 0]) % right hand
        recPatientChoice(i) = 1;
    elseif comBtns(patChoice,[0 1 0 0]) %left hand
        recPatientChoice(I) = 2;
    elseif comBtns(patChoice,[-1 -1 -1 -1]) % too late
        scr.setMainText('You are too late. Please put your hands down');
        patMoney = patMoney - .1;
        scr.setMoney(1, patMoney);
        res.setVal([1 0 1 0 0 0 0 0]);
        res.monitorTargetWait([1 1 0 0]);
        res.clearVal();
        scr.setMainText('When you are ready, lift both hands to continue the next round');
        res.monitorTargetWait([0 0 0 0]);
        continue;
    else % wrong hands
        scr.setMainText('You lift both hands. Please put your hands down');
        patMoney = patMoney - .1;
        scr.setMoney(1, patMoney);
        res.setVal([1 0 1 0 0 0 0 0]);
        res.monitorTargetWait([1 1 0 0]);
        res.clearVal();
        scr.setMainText('When you are ready, lift both hands to continue the next round');
        res.monitorTargetWait([0 0 0 0]);
        continue;
    end
    recComputerChoice(i) = round(rand()) + 1;
    
    % ANNOUNCE THE WINNER
    if recComputerChoice(i) == recComputerChoice(i)
        
    
end

end

function updateCountdown(tobj, tevent, scr)
scr.setMainText(6-tobj.TasksExecuted);
end

function ret = cmpBtns(btn1, btn2)
ret = sum(btn1 == btn2) == 4;
end